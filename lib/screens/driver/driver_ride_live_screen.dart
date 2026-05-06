import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _loadingRoute = true;
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
    final bookings = await context
        .read<BookingProvider>()
        .rideBookingsOnce(widget.rideId);

    final pickups = bookings
        .where((b) => b.pickupLat != null && b.pickupLng != null)
        .map((b) => LatLng(b.pickupLat!, b.pickupLng!))
        .toList();

    if (pickups.isEmpty) {
      if (mounted) setState(() => _loadingRoute = false);
      return;
    }

    final route = await MapsService.getOptimizedRoute(
      origin: widget.origin,
      destination: widget.destination,
      pickups: pickups,
    );

    if (mounted) {
      setState(() {
        _optimizedRoute = route;
        _loadingRoute = false;
      });
      if (route != null && _mapController != null) {
        _fitRouteBounds(route.polylinePoints);
      }
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
    if (route == null) return const SizedBox.shrink();

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: route.polylinePoints,
      color: AppStyles.primaryColor,
      width: 4,
    );

    final markers = <Marker>{};
    for (int i = 0; i < route.orderedPickups.length; i++) {
      final p = route.orderedPickups[i];
      markers.add(Marker(
        markerId: MarkerId('stop_$i'),
        position: p,
        infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
      ));
    }

    final initialTarget = route.polylinePoints.isNotEmpty
        ? route.polylinePoints[route.polylinePoints.length ~/ 2]
        : LatLng(31.9539, 35.9106);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimized Pickup Route',
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
                _fitRouteBounds(route.polylinePoints);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${route.orderedPickups.length} passenger stop${route.orderedPickups.length == 1 ? '' : 's'} optimized',
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
