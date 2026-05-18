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

class _DriverRideLiveScreenState extends State<DriverRideLiveScreen> {
  bool _completing = false;
  String? _actionError;
  final Map<String, bool> _arrivingFor = {};

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
  int _lastStopIndex = -1;
  GoogleMapController? _mapController;

  LatLng? _driverPosition;
  StreamSubscription<Position>? _locationSub;

  // ── Computed ──────────────────────────────────────────────────────────────
  List<BookingModel> get _allStops =>
      [..._orderedPassengers, ..._passengersWithoutGps];

  int get _currentStopIndex {
    final stops = _allStops;
    for (int i = 0; i < stops.length; i++) {
      if (stops[i].driverArrivedAt == null) return i;
    }
    return stops.length;
  }

  bool get _allPickedUp =>
      _bookings.isNotEmpty && _currentStopIndex >= _allStops.length;

  @override
  void initState() {
    super.initState();
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
      if (bookings.length != _lastBookingCount) {
        _lastBookingCount = bookings.length;
        _optimizeRoute(withGps);
      } else {
        _maybeAdvanceStop();
      }
    });
  }

  void _maybeAdvanceStop() {
    final idx = _currentStopIndex;
    if (idx != _lastStopIndex) {
      _lastStopIndex = idx;
      _zoomToCurrentStop(idx);
    }
  }

  void _zoomToCurrentStop(int idx) {
    if (_mapController == null) return;
    final stops = _allStops;
    if (idx < stops.length) {
      final stop = stops[idx];
      if (stop.pickupLat != null && stop.pickupLng != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(stop.pickupLat!, stop.pickupLng!), 15),
        );
      }
    } else if (stops.isNotEmpty) {
      final destCoords = MapsService.cityCoords(widget.destination);
      if (destCoords != null) {
        _mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(destCoords, 12));
      } else {
        final pts = _optimizedRoute?.polylinePoints ?? _fallbackRoutePoints;
        if (pts.isNotEmpty) _fitRouteBounds(pts);
      }
    }
  }

  Future<void> _optimizeRoute(List<BookingModel> withGps) async {
    if (!mounted) return;
    setState(() {
      _loadingRoute = true;
      _optimizedRoute = null;
      _isOptimized = false;
    });

    if (withGps.isEmpty) {
      await _loadFallbackRoute();
      return;
    }

    final pickups =
        withGps.map((b) => LatLng(b.pickupLat!, b.pickupLng!)).toList();
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
      _maybeAdvanceStop();
    } else {
      await _loadFallbackRoute();
    }
  }

  Future<void> _loadFallbackRoute() async {
    final points =
        await MapsService.getRoute(widget.origin, widget.destination);
    if (!mounted) return;
    setState(() {
      _fallbackRoutePoints = points;
      _isOptimized = false;
      _routeFailed = points.isEmpty;
      _loadingRoute = false;
    });
    _maybeAdvanceStop();
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
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
            northeast: LatLng(maxLat, maxLng)),
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
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((pos) {
      if (!mounted) return;
      setState(() => _driverPosition = LatLng(pos.latitude, pos.longitude));
    });
  }

  @override
  void dispose() {
    _bookingsSub?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }

  Future<void> _markArrived(String bookingId) async {
    setState(() => _arrivingFor[bookingId] = true);
    try {
      await context
          .read<BookingProvider>()
          .markDriverArrivedForBooking(bookingId);
    } catch (_) {
      if (mounted) {
        setState(() =>
            _actionError = 'Failed to notify passenger. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _arrivingFor.remove(bookingId));
    }
  }

  Future<void> _confirmComplete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Complete Ride',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Mark this ride as completed? Passengers will be able to leave a rating.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not Yet')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Complete',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final passengersToRate = List<BookingModel>.from(_bookings);
    setState(() {
      _completing = true;
      _actionError = null;
    });
    try {
      await context.read<RideProvider>().completeRide(widget.rideId);
      if (!mounted) return;
      await _showPassengerRatingSheet(passengersToRate);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
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
  }

  void _showShareSheet(BuildContext context) {
    final shareText =
        'I\'m on a live ride on Tale3!\n🚗 ${widget.origin} → ${widget.destination}\nJoin me on Tale3 — the trusted carpool app.';
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    borderRadius: BorderRadius.circular(2)),
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.rideCopied),
                    backgroundColor: AppStyles.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ));
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

  Future<void> _showPassengerRatingSheet(
      List<BookingModel> passengers) async {
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final stops = _allStops;
    final stopIdx = _currentStopIndex;
    final allDone = _allPickedUp;
    final completedStops =
        stops.where((b) => b.driverArrivedAt != null).toList();

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
              fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: context.colors.textPrimary),
            onPressed: () => _showShareSheet(context),
            tooltip: context.l10n.shareRide,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress pill
              _buildProgressPill(stopIdx, stops.length, allDone),
              const SizedBox(height: 20),

              // Route map
              _buildRouteMap(stops, stopIdx),
              const SizedBox(height: 20),

              // Current stop card
              if (!allDone && stops.isNotEmpty && stopIdx < stops.length) ...[
                _buildCurrentStopCard(stops[stopIdx]),
                const SizedBox(height: 20),
              ],

              // Loading placeholder while first optimizing
              if (!allDone && _loadingRoute && stops.isEmpty) ...[
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.colors.inputFillColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.borderColor),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 20),
              ],

              // All passengers picked up banner
              if (allDone) ...[
                _buildAllPickedUpBanner(),
                const SizedBox(height: 20),
              ],

              // Completed pickups list
              if (completedStops.isNotEmpty) ...[
                _buildCompletedSection(completedStops),
                const SizedBox(height: 20),
              ],

              // Route info card (origin → destination)
              _buildRouteInfoCard(),
              const SizedBox(height: 24),

              // Error banner
              if (_actionError != null) ...[
                _buildErrorBanner(),
                const SizedBox(height: 16),
              ],

              // Complete Ride button — enabled only when all picked up
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      (allDone && !_completing) ? _confirmComplete : null,
                  icon: _completing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.flag_rounded, size: 20),
                  label: Text(
                    allDone
                        ? 'Complete Ride'
                        : 'Pick up all passengers first',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.successColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dashboard button
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

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildProgressPill(int current, int total, bool allDone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: allDone
            ? const Color(0xFFE8F5E9)
            : context.colors.inputFillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: allDone
                ? const Color(0xFF81C784)
                : context.colors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  allDone ? const Color(0xFF2E7D32) : AppStyles.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              allDone
                  ? Icons.check_rounded
                  : Icons.directions_car_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone
                      ? 'All passengers picked up!'
                      : total == 0
                          ? 'Loading stops…'
                          : 'Stop ${current + 1} of $total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: allDone
                        ? const Color(0xFF2E7D32)
                        : context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  allDone
                      ? 'Drive to ${widget.destination}'
                      : 'Head to the next pickup point',
                  style: TextStyle(
                    fontSize: 12,
                    color: allDone
                        ? const Color(0xFF388E3C)
                        : context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Progress dots
          if (total > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(total, (i) {
                final isDone = i < current || allDone;
                final isCurrent = i == current && !allDone;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 10 : 8,
                  height: isCurrent ? 10 : 8,
                  margin: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? const Color(0xFF2E7D32)
                        : isCurrent
                            ? AppStyles.primaryColor
                            : context.colors.borderColor,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStopCard(BookingModel b) {
    final isFemale = b.passengerGender.toLowerCase() == 'female' ||
        b.passengerGender.toLowerCase() == 'أنثى';
    final isMale = b.passengerGender.toLowerCase() == 'male' ||
        b.passengerGender.toLowerCase() == 'ذكر';
    final avatarColor = isFemale
        ? const Color(0xFFF48FB1)
        : isMale
            ? const Color(0xFF90CAF9)
            : const Color(0xFFBDBDBD);
    final avatarIcon =
        isFemale ? Icons.female : isMale ? Icons.male : Icons.person;
    final hasGps = b.pickupLat != null && b.pickupLng != null;
    final isArriving = _arrivingFor[b.id] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppStyles.primaryColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppStyles.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CURRENT PICKUP',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppStyles.primaryColor,
                      letterSpacing: 0.8),
                ),
              ),
              if (!hasGps) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off,
                          size: 11, color: Color(0xFFF57F17)),
                      SizedBox(width: 4),
                      Text('No GPS',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFF57F17),
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Passenger info
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor,
                child: Icon(avatarIcon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.passengerName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${b.seatsBooked} seat${b.seatsBooked == 1 ? '' : 's'}  •  '
                      '${isFemale ? 'Female' : isMale ? 'Male' : 'Unknown'}',
                      style: TextStyle(
                          fontSize: 13, color: context.colors.textSecondary),
                    ),
                    if (hasGps) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.my_location_rounded,
                              size: 13, color: Color(0xFF8B1A2B)),
                          const SizedBox(width: 4),
                          Text(
                            '${b.pickupLat!.toStringAsFixed(4)}, '
                            '${b.pickupLng!.toStringAsFixed(4)}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF757575)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              if (hasGps) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1'
                        '&destination=${b.pickupLat},${b.pickupLng}'
                        '&travelmode=driving',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.navigation_rounded, size: 18),
                    label: const Text('Navigate',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppStyles.primaryColor,
                      side: BorderSide(
                          color:
                              AppStyles.primaryColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isArriving ? null : () => _markArrived(b.id),
                  icon: isArriving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.location_on_rounded, size: 18),
                  label: Text(
                    isArriving ? 'Notifying…' : 'I\'ve Arrived',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.successColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllPickedUpBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF2E7D32), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All passengers on board!',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32)),
                ),
                Text(
                  'Drive to ${widget.destination} and tap Complete Ride when done.',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF388E3C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection(List<BookingModel> completed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Picked Up (${completed.length})',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textSecondary),
        ),
        const SizedBox(height: 8),
        ...completed.map((b) {
          final isFemale = b.passengerGender.toLowerCase() == 'female' ||
              b.passengerGender.toLowerCase() == 'أنثى';
          final isMale = b.passengerGender.toLowerCase() == 'male' ||
              b.passengerGender.toLowerCase() == 'ذكر';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isFemale
                      ? const Color(0xFFF48FB1)
                      : isMale
                          ? const Color(0xFF90CAF9)
                          : const Color(0xFFBDBDBD),
                  child: Icon(
                      isFemale
                          ? Icons.female
                          : isMale
                              ? Icons.male
                              : Icons.person,
                      color: Colors.white,
                      size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    b.passengerName,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary),
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32), size: 20),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRouteInfoCard() {
    return Container(
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
            child: Icon(Icons.route, color: AppStyles.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.departure,
                    style: TextStyle(
                        fontSize: 12, color: context.colors.textSecondary)),
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
                        fontSize: 12, color: context.colors.textSecondary)),
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
    );
  }

  Widget _buildErrorBanner() {
    return Container(
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
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteMap(List<BookingModel> stops, int currentIdx) {
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
        final isDone =
            i < stops.length && stops[i].driverArrivedAt != null;
        final isCurrent = i == currentIdx;
        final name = i < _orderedPassengers.length
            ? _orderedPassengers[i].passengerName
            : 'Stop ${i + 1}';
        markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: route.orderedPickups[i],
          icon: isDone
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen)
              : isCurrent
                  ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed)
                  : BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
          infoWindow:
              InfoWindow(title: isDone ? '✓ $name' : '${i + 1}. $name'),
          alpha: isDone ? 0.6 : 1.0,
        ));
      }
    } else {
      final withGps = _bookings
          .where((b) => b.pickupLat != null && b.pickupLng != null)
          .toList();
      for (int i = 0; i < withGps.length; i++) {
        final isDone = withGps[i].driverArrivedAt != null;
        markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(withGps[i].pickupLat!, withGps[i].pickupLng!),
          icon: isDone
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: withGps[i].passengerName),
          alpha: isDone ? 0.6 : 1.0,
        ));
      }
    }

    // Initial camera: current stop's pickup or mid-route
    LatLng initialTarget;
    double initialZoom = 13;
    if (currentIdx < stops.length && stops[currentIdx].pickupLat != null) {
      initialTarget =
          LatLng(stops[currentIdx].pickupLat!, stops[currentIdx].pickupLng!);
      initialZoom = 15;
    } else {
      initialTarget = polylinePoints[polylinePoints.length ~/ 2];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isOptimized ? 'Optimized Pickup Route' : 'Route',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary),
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
                      CameraPosition(target: initialTarget, zoom: initialZoom),
                  polylines: {polyline},
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                    _zoomToCurrentStop(_currentStopIndex);
                  },
                ),
              ),
            ),
            // "My Location" button
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  if (_driverPosition != null) {
                    _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_driverPosition!, 15));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location_rounded,
                          size: 14, color: context.colors.textPrimary),
                      const SizedBox(width: 4),
                      Text('My Location',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!_routeFailed) ...[
          const SizedBox(height: 6),
          Text(
            _isOptimized
                ? 'Route optimized — ${_orderedPassengers.length} stop${_orderedPassengers.length == 1 ? '' : 's'} in best order.'
                : 'Showing direct route.',
            style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PASSENGER RATING SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _PassengerRatingSheet extends StatefulWidget {
  final BookingModel booking;
  final RatingProvider ratingProvider;
  const _PassengerRatingSheet(
      {required this.booking, required this.ratingProvider});

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
    final isFemale =
        widget.booking.passengerGender.toLowerCase() == 'female' ||
            widget.booking.passengerGender.toLowerCase() == 'أنثى';
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: context.colors.borderColor,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 32,
            backgroundColor: isFemale
                ? const Color(0xFFF48FB1)
                : const Color(0xFF90CAF9),
            child: Icon(isFemale ? Icons.female : Icons.male,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            widget.booking.passengerName,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text('Rate this passenger',
              style: TextStyle(
                  fontSize: 13, color: context.colors.textSecondary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppStyles.goldStar,
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _submitting ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textSecondary,
                    side: BorderSide(color: context.colors.borderColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Skip',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Submit',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
