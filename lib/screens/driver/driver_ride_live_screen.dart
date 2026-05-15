import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/providers/rating_provider.dart';
import 'package:testtale3/screens/driver/driver_home_screen.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/l10n/app_localizations.dart';

// ignore_for_file: use_build_context_synchronously

class DriverRideLiveScreen extends StatefulWidget {
  final String rideId;
  final String origin;
  final String destination;
  final String driverName;

  const DriverRideLiveScreen({
    super.key,
    required this.rideId,
    required this.origin,
    required this.destination,
    required this.driverName,
  });

  @override
  State<DriverRideLiveScreen> createState() => _DriverRideLiveScreenState();
}

class _DriverRideLiveScreenState extends State<DriverRideLiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _arrived = false;
  bool _announcing = false;
  bool _completing = false;
  String? _actionError;

  OptimizedRoute? _optimizedRoute;
  List<LatLng> _fallbackRoutePoints = [];
  bool _loadingRoute = true;
  bool _routeFailed = false;
  bool _isOptimized = false;
  List<BookingModel> _bookings = [];
  List<BookingModel> _orderedPassengers = [];
  List<BookingModel> _passengersWithoutGps = [];
  StreamSubscription<List<BookingModel>>? _bookingsSub;
  int _lastBookingCount = -1;
  GoogleMapController? _mapController;

  // Live driver location
  LatLng? _driverPosition;
  StreamSubscription<Position>? _locationSub;
  bool _followDriver = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().startRide(widget.rideId);
      _subscribeToBookings();
      _startLocationTracking();
    });
  }

  void _subscribeToBookings() {
    _bookingsSub = context
        .read<BookingProvider>()
        .driverRideBookingsStream(widget.rideId)
        .listen((bookings) {
      if (!mounted) return;
      final withGps = bookings
          .where((b) => b.pickupLat != null && b.pickupLng != null)
          .toList();
      setState(() {
        _bookings = bookings;
        _passengersWithoutGps = bookings
            .where((b) => b.pickupLat == null || b.pickupLng == null)
            .toList();
      });
      // #2 — re-optimize only when booking count changes
      if (bookings.length != _lastBookingCount) {
        _lastBookingCount = bookings.length;
        _optimizeRoute(withGps);
      }
    });
  }

  Future<void> _optimizeRoute(List<BookingModel> withGps) async {
    if (!mounted) return;
    setState(() { _loadingRoute = true; _optimizedRoute = null; _isOptimized = false; });

    if (withGps.isEmpty) {
      await _loadFallbackRoute();
      return;
    }

    final pickups = withGps
        .map((b) => LatLng(b.pickupLat!, b.pickupLng!))
        .toList();

    final route = await MapsService.getOptimizedRoute(
      origin: widget.origin,
      destination: widget.destination,
      pickups: pickups,
    );

    if (!mounted) return;

    if (route != null) {
      final ordered = route.waypointOrder.isEmpty
          ? List<BookingModel>.from(withGps)
          : route.waypointOrder.map((i) => withGps[i]).toList();
      setState(() {
        _optimizedRoute = route;
        _orderedPassengers = ordered;
        _isOptimized = true;
        _routeFailed = false;
        _loadingRoute = false;
      });
      if (_mapController != null) _fitRouteBounds(route.polylinePoints);
    } else {
      await _loadFallbackRoute();
    }
  }

  Future<void> _loadFallbackRoute() async {
    final points = await MapsService.getRoute(widget.origin, widget.destination);
    if (!mounted) return;
    setState(() {
      _fallbackRoutePoints = points;
      _isOptimized = false;
      _routeFailed = points.isEmpty;
      _loadingRoute = false;
    });
    if (points.isNotEmpty && _mapController != null) _fitRouteBounds(points);
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        56,
      ),
    );
  }

  Future<void> _startLocationTracking() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) { return; }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // metres between updates
      ),
    ).listen((pos) {
      if (!mounted) return;
      final newPos = LatLng(pos.latitude, pos.longitude);
      setState(() => _driverPosition = newPos);
      if (_followDriver && _mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(newPos, 15));
      }
      _checkAutoArrival(newPos);
    });
  }

  /// Automatically triggers _announceArrival when the driver is within
  /// 200 m of the first (or nearest) passenger pickup point.
  void _checkAutoArrival(LatLng driverPos) {
    if (_arrived || _announcing) return;

    // 1. First pickup in optimised order that has GPS coordinates.
    LatLng? target;
    for (final b in _orderedPassengers) {
      if (b.pickupLat != null && b.pickupLng != null) {
        target = LatLng(b.pickupLat!, b.pickupLng!);
        break;
      }
    }

    // 2. Fall back to any confirmed booking with GPS (unoptimised state).
    if (target == null) {
      for (final b in _bookings) {
        if (b.pickupLat != null && b.pickupLng != null) {
          target = LatLng(b.pickupLat!, b.pickupLng!);
          break;
        }
      }
    }

    // 3. Last resort: origin city centre (no passenger set a pin).
    target ??= MapsService.cityCoords(widget.origin);
    if (target == null) return;

    final distKm = MapsService.distanceKm(driverPos, target);
    if (distKm <= 0.2) {
      // Within 200 m — announce arrival automatically.
      _announceArrival();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bookingsSub?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }

  Future<void> _announceArrival() async {
    setState(() { _announcing = true; _actionError = null; });
    try {
      await context.read<RideProvider>().announceArrival(widget.rideId);
      if (mounted) setState(() => _arrived = true);
    } catch (_) {
      if (mounted) setState(() => _actionError = 'Failed to send arrival notification. Please try again.');
    } finally {
      if (mounted) setState(() => _announcing = false);
    }
  }

  Widget _buildRouteMap() {
    if (_loadingRoute) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: context.colors.inputFillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.borderColor),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final route = _optimizedRoute;
    final polylinePoints = route?.polylinePoints ?? _fallbackRoutePoints;
    if (polylinePoints.isEmpty) return const SizedBox.shrink();

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: polylinePoints,
      color: AppStyles.primaryColor,
      width: 4,
    );

    final markers = <Marker>{};
    if (route != null) {
      for (int i = 0; i < route.orderedPickups.length; i++) {
        final name = i < _orderedPassengers.length
            ? _orderedPassengers[i].passengerName
            : 'Stop ${i + 1}';
        markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: route.orderedPickups[i],
          infoWindow: InfoWindow(title: '${i + 1}. $name'),
        ));
      }
    } else {
      // fallback: show markers for all passengers with GPS in booking order
      final withGps = _bookings
          .where((b) => b.pickupLat != null && b.pickupLng != null)
          .toList();
      for (int i = 0; i < withGps.length; i++) {
        markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(withGps[i].pickupLat!, withGps[i].pickupLng!),
          infoWindow: InfoWindow(title: withGps[i].passengerName),
        ));
      }
    }

    // Drop-off markers in green — one per passenger
    for (int i = 0; i < _bookings.length; i++) {
      final b = _bookings[i];
      if (b.dropoffLat != null && b.dropoffLng != null) {
        markers.add(Marker(
          markerId: MarkerId('dropoff_$i'),
          position: LatLng(b.dropoffLat!, b.dropoffLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: '↓ ${b.passengerName}'),
        ));
      }
    }

    final initialTarget = polylinePoints[polylinePoints.length ~/ 2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isOptimized ? 'Optimized Pickup Route' : 'Route',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: initialTarget, zoom: 10),
                  polylines: {polyline},
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                    _fitRouteBounds(polylinePoints);
                  },
                ),
              ),
            ),
            // Follow / Route toggle button
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() => _followDriver = !_followDriver);
                  if (_followDriver && _driverPosition != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_driverPosition!, 15),
                    );
                  } else {
                    _fitRouteBounds(polylinePoints);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _followDriver
                        ? AppStyles.primaryColor
                        : context.colors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _followDriver
                            ? Icons.navigation_rounded
                            : Icons.route_rounded,
                        size: 14,
                        color: _followDriver
                            ? Colors.white
                            : context.colors.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _followDriver ? 'Following' : 'View Route',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _followDriver
                              ? Colors.white
                              : context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context) {
    final shareText =
        'I\'m on a live ride on Tale3!\n🚗 ${widget.origin} → ${widget.destination}\nJoin me on Tale3 — the trusted carpool app.';

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.colors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.shareRide,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ctx.colors.textPrimary)),
            const SizedBox(height: 8),
            Text(shareText,
                style: TextStyle(
                    fontSize: 14,
                    color: ctx.colors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: Text(context.l10n.copyRideDetails,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: shareText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.rideCopied),
                      backgroundColor: AppStyles.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.darkMaroon,
                  foregroundColor: AppStyles.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPassengerRatingSheet() async {
    final passengers = List<BookingModel>.from(_bookings);
    if (passengers.isEmpty || !mounted) return;

    for (final booking in passengers) {
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _PassengerRatingSheet(
          booking: booking,
          ratingProvider: context.read<RatingProvider>(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.myRide,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radar animation
              SizedBox(
                height: 200,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_arrived ? AppStyles.successColor : AppStyles.primaryColor)
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_arrived ? AppStyles.successColor : AppStyles.primaryColor)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _arrived ? AppStyles.successColor : AppStyles.primaryColor,
                        ),
                        child: Icon(
                          _arrived ? Icons.location_on : Icons.directions_car,
                          color: AppStyles.onPrimary,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                _arrived ? 'You\'ve Arrived!' : context.l10n.rideIsLive,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _arrived
                    ? 'Passengers have been notified that you\'re at the pickup point.'
                    : context.l10n.matchingPassengers,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Route card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.highlightBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.route,
                          color: AppStyles.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.departure,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(widget.origin,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward,
                        color: context.colors.inputHintColor, size: 16),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.destination,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(widget.destination,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Optimized pickup route map
              _buildRouteMap(),

              // Route status banner — 3 states
              if (!_loadingRoute) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _routeFailed
                        ? const Color(0xFFFFEBEE)
                        : _isOptimized
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _routeFailed
                            ? Icons.error_outline_rounded
                            : _isOptimized
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                        size: 16,
                        color: _routeFailed
                            ? const Color(0xFFB71C1C)
                            : _isOptimized
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF57F17),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _routeFailed
                              ? 'Route unavailable — check connectivity.'
                              : _isOptimized
                                  ? 'Route optimized — ${_orderedPassengers.length} pickup stop${_orderedPassengers.length == 1 ? '' : 's'} in best order.'
                                  : 'Showing direct route — optimization unavailable.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _routeFailed
                                ? const Color(0xFFB71C1C)
                                : _isOptimized
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFF57F17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Passenger list
              if (_bookings.isNotEmpty) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Passengers (${_bookings.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // #4 — show in optimized pickup order when optimized, else booking order
                ...(_isOptimized
                        ? [
                            ..._orderedPassengers,
                            ..._passengersWithoutGps,
                          ]
                        : _bookings)
                    .map((b) => _buildPassengerTile(b, context)),
              ],

              const SizedBox(height: 32),

              // Inline error message
              if (_actionError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFB71C1C), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _actionError!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB71C1C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // "I've Arrived" button — hidden once tapped
              if (!_arrived)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _announcing ? null : _announceArrival,
                    icon: _announcing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on, size: 20),
                    label: const Text(
                      'I\'ve Arrived',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.successColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              if (!_arrived) const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showShareSheet(context),
                  icon: const Icon(Icons.share, size: 20),
                  label: Text(context.l10n.shareTrip,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: AppStyles.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Complete ride button — marks ride as done so passengers can rate
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _completing
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text('Complete Ride',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              content: const Text(
                                  'Mark this ride as completed? Passengers will be able to leave a rating.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Not Yet')),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Complete',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                          setState(() { _completing = true; _actionError = null; });
                          try {
                            await context
                                .read<RideProvider>()
                                .completeRide(widget.rideId);
                            if (!mounted) return;
                            // Show passenger rating sheet before going home
                            await _showPassengerRatingSheet();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const DriverHomeScreen()),
                                (route) => false,
                              );
                            }
                          } catch (_) {
                            if (mounted) {
                              setState(() {
                                _completing = false;
                                _actionError = 'Could not complete the ride. Please try again.';
                              });
                            }
                          }
                        },
                  icon: _completing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.flag_rounded, size: 20),
                  label: const Text('Complete Ride',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const DriverHomeScreen()),
                    (route) => false,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    backgroundColor: context.colors.cardBackgroundColor,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(context.l10n.goToDashboard,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerTile(BookingModel b, BuildContext context) {
    final isFemale = b.passengerGender.toLowerCase() == 'female' ||
        b.passengerGender.toLowerCase() == 'أنثى';
    final isMale = b.passengerGender.toLowerCase() == 'male' ||
        b.passengerGender.toLowerCase() == 'ذكر';
    final avatarColor = isFemale
        ? const Color(0xFFF48FB1)
        : isMale
            ? const Color(0xFF90CAF9)
            : const Color(0xFFBDBDBD);
    final avatarIcon = isFemale
        ? Icons.female
        : isMale
            ? Icons.male
            : Icons.person;

    final hasGps = b.pickupLat != null && b.pickupLng != null;
    final stopIndex = _isOptimized ? _orderedPassengers.indexOf(b) : -1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.borderColor),
      ),
      child: Row(
        children: [
          // Gender avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Icon(avatarIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          // Name + GPS status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.passengerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (!hasGps)
                  Row(
                    children: const [
                      Icon(Icons.location_off,
                          size: 13, color: Color(0xFFF57F17)),
                      SizedBox(width: 4),
                      Text(
                        'No pickup location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF57F17),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 8, color: Color(0xFF8B1A2B)),
                      const SizedBox(width: 4),
                      const Text('Pickup set',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF8B1A2B),
                              fontWeight: FontWeight.w500)),
                      if (b.dropoffLat != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.circle,
                            size: 8, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        const Text('Drop-off set',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          // Navigate button + stop badge + seat count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasGps)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1'
                      '&destination=${b.pickupLat},${b.pickupLng}'
                      '&travelmode=driving',
                    );
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppStyles.primaryColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_rounded, size: 12, color: AppStyles.primaryColor),
                        const SizedBox(width: 4),
                        Text('Navigate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppStyles.primaryColor)),
                      ],
                    ),
                  ),
                ),
              if (_isOptimized && stopIndex >= 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stop ${stopIndex + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${b.seatsBooked} seat${b.seatsBooked == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PASSENGER RATING SHEET — shown to driver after completing a ride
// ─────────────────────────────────────────────────────────────────────────────
class _PassengerRatingSheet extends StatefulWidget {
  final BookingModel booking;
  final RatingProvider ratingProvider;
  const _PassengerRatingSheet({required this.booking, required this.ratingProvider});

  @override
  State<_PassengerRatingSheet> createState() => _PassengerRatingSheetState();
}

class _PassengerRatingSheetState extends State<_PassengerRatingSheet> {
  int _stars = 5;
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.ratingProvider.submitPassengerRating(
      passengerId: widget.booking.passengerId,
      passengerName: widget.booking.passengerName,
      rideId: widget.booking.rideId,
      bookingId: widget.booking.id,
      stars: _stars,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isFemale = widget.booking.passengerGender.toLowerCase() == 'female' ||
        widget.booking.passengerGender.toLowerCase() == 'أنثى';
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.colors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 32,
            backgroundColor: isFemale
                ? const Color(0xFFF48FB1)
                : const Color(0xFF90CAF9),
            child: Icon(
              isFemale ? Icons.female : Icons.male,
              color: Colors.white, size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.booking.passengerName,
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rate this passenger',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _stars = i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppStyles.goldStar,
                  size: 44,
                ),
              ),
            )),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    side: BorderSide(color: context.colors.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Skip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
