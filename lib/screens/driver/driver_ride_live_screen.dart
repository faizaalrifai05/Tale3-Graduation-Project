import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/providers/booking_provider.dart';
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

  OptimizedRoute? _optimizedRoute;
  List<LatLng> _fallbackRoutePoints = [];
  bool _loadingRoute = true;
  bool _routeFailed = false;
  List<BookingModel> _bookings = [];
  GoogleMapController? _mapController;

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
    _loadOptimizedRoute();
  }

  Future<void> _loadOptimizedRoute() async {
    List<BookingModel> sorted = [];
    try {
      final bookings = await context
          .read<BookingProvider>()
          .rideBookingsOnce(widget.rideId);

      sorted = [...bookings]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final pickups = sorted
          .where((b) => b.pickupLat != null && b.pickupLng != null)
          .map((b) => LatLng(b.pickupLat!, b.pickupLng!))
          .toList();

      if (pickups.isNotEmpty) {
        final route = await MapsService.getOptimizedRoute(
          origin: widget.origin,
          destination: widget.destination,
          pickups: pickups,
        );
        if (mounted) {
          if (route != null) {
            setState(() {
              _bookings = sorted;
              _optimizedRoute = route;
              _loadingRoute = false;
            });
            if (_mapController != null) _fitRouteBounds(route.polylinePoints);
            return;
          }
        }
      }
      await _loadFallbackRoute(sorted);
    } catch (e) {
      debugPrint('❌ _loadOptimizedRoute error: $e');
      await _loadFallbackRoute(sorted);
    }
  }

  Future<void> _loadFallbackRoute(List<BookingModel> sorted) async {
    final points = await MapsService.getRoute(widget.origin, widget.destination);
    if (!mounted) return;
    setState(() {
      _bookings = sorted;
      _fallbackRoutePoints = points;
      _routeFailed = points.isEmpty;
      _loadingRoute = false;
    });
    if (points.isNotEmpty && _mapController != null) {
      _fitRouteBounds(points);
    }
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _announceArrival() async {
    setState(() => _announcing = true);
    try {
      await context.read<RideProvider>().announceArrival(widget.rideId);
      setState(() => _arrived = true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send arrival notification. Try again.')),
      );
    } finally {
      setState(() => _announcing = false);
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
        final p = route.orderedPickups[i];
        markers.add(Marker(
          markerId: MarkerId('stop_$i'),
          position: p,
          infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
        ));
      }
    }

    final initialTarget = polylinePoints[polylinePoints.length ~/ 2];
    final label = route != null
        ? '${route.orderedPickups.length} stop${route.orderedPickups.length == 1 ? '' : 's'} optimized'
        : 'Route — ${widget.origin} → ${widget.destination}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          route != null ? 'Optimized Pickup Route' : 'Route',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: initialTarget, zoom: 10),
              polylines: {polyline},
              markers: markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                _fitRouteBounds(polylinePoints);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
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

              // Route status banner
              if (!_loadingRoute) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _routeFailed
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _routeFailed ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                        size: 16,
                        color: _routeFailed ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _routeFailed
                            ? 'Route optimization unavailable — check Maps API key or connectivity.'
                            : 'Route optimized: ${_bookings.length} passenger stop${_bookings.length == 1 ? '' : 's'}.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _routeFailed ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Passenger list with gender
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
                ..._bookings.map((b) {
                  final isFemale = b.passengerGender.toLowerCase() == 'female' ||
                      b.passengerGender.toLowerCase() == 'أنثى';
                  final isMale = b.passengerGender.toLowerCase() == 'male' ||
                      b.passengerGender.toLowerCase() == 'ذكر';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: context.colors.inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isFemale
                                ? const Color(0xFFFCE4EC)
                                : isMale
                                    ? const Color(0xFFE3F2FD)
                                    : context.colors.highlightBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFemale ? Icons.female : isMale ? Icons.male : Icons.person,
                            size: 20,
                            color: isFemale
                                ? const Color(0xFFE91E63)
                                : isMale
                                    ? const Color(0xFF1976D2)
                                    : AppStyles.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.passengerName.isEmpty ? 'Passenger' : b.passengerName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              if (b.passengerGender.isNotEmpty)
                                Text(
                                  b.passengerGender,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '${b.seatsBooked} seat${b.seatsBooked > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),

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
                          setState(() => _completing = true);
                          try {
                            await context
                                .read<RideProvider>()
                                .completeRide(widget.rideId);
                            if (mounted) {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          } catch (_) {
                            if (mounted) {
                              setState(() => _completing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Could not complete ride. Try again.')),
                              );
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
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
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
}
