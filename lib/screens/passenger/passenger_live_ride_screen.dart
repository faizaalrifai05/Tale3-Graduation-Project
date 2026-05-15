import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/theme/app_styles.dart';

class PassengerLiveRideScreen extends StatefulWidget {
  final BookingModel booking;
  const PassengerLiveRideScreen({super.key, required this.booking});

  @override
  State<PassengerLiveRideScreen> createState() => _PassengerLiveRideScreenState();
}

class _PassengerLiveRideScreenState extends State<PassengerLiveRideScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  List<LatLng> _routePoints = [];
  bool _loadingRoute = true;
  GoogleMapController? _mapController;

  String _rideStatus = 'live';
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadRoute();
    _subscribeToRide();
  }

  Future<void> _loadRoute() async {
    final points = await MapsService.getRoute(
        widget.booking.origin, widget.booking.destination);
    if (!mounted) return;
    setState(() {
      _routePoints = points;
      _loadingRoute = false;
    });
    if (points.isNotEmpty && _mapController != null) _fitBounds(points);
  }

  void _subscribeToRide() {
    _rideSub = FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.booking.rideId)
        .snapshots()
        .listen((snap) {
      if (!mounted || !snap.exists) return;
      final status = snap.data()?['status'] as String? ?? 'live';
      setState(() => _rideStatus = status);
    });
  }

  void _fitBounds(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController?.animateCamera(
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
    _pulseController.dispose();
    _rideSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _rideStatus == 'completed';
    final statusColor = isCompleted ? AppStyles.successColor : AppStyles.primaryColor;

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isCompleted ? 'Ride Completed' : 'Live Ride',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('LIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE53935),
                      )),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pulse animation
              SizedBox(
                height: 160,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulse,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : Icons.directions_car_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isCompleted ? 'You\'ve Arrived!' : 'Your Ride is Live!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCompleted
                    ? 'Your ride has been completed. Thank you for travelling with Tale3!'
                    : 'Your driver is on the way. Sit tight!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Driver info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: context.colors.highlightBackgroundColor,
                      child: Text(
                        widget.booking.driverName.isNotEmpty
                            ? widget.booking.driverName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.booking.driverName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              )),
                          const SizedBox(height: 2),
                          Text(widget.booking.carInfo,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              )),
                          Text(widget.booking.plateNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(Icons.directions_car, color: AppStyles.primaryColor, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.booking.seatsBooked} seat${widget.booking.seatsBooked > 1 ? 's' : ''}',
                          style: TextStyle(
                              fontSize: 11, color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Route card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.borderColor),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.radio_button_checked, color: Color(0xFF8B1A2B), size: 16),
                        Container(width: 2, height: 28,
                            color: context.colors.borderColor),
                        const Icon(Icons.location_on_rounded, color: Color(0xFF2E7D32), size: 16),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.booking.origin,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary)),
                          const SizedBox(height: 16),
                          Text(widget.booking.destination,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Route map
              if (_loadingRoute)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.colors.inputFillColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.borderColor),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (_routePoints.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 220,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _routePoints[_routePoints.length ~/ 2],
                        zoom: 9,
                      ),
                      onMapCreated: (ctrl) {
                        _mapController = ctrl;
                        _fitBounds(_routePoints);
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _routePoints,
                          color: AppStyles.primaryColor,
                          width: 4,
                        ),
                      },
                      markers: {
                        if (_routePoints.isNotEmpty) ...[
                          Marker(
                            markerId: const MarkerId('origin'),
                            position: _routePoints.first,
                            infoWindow: InfoWindow(title: widget.booking.origin),
                          ),
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: _routePoints.last,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            infoWindow: InfoWindow(title: widget.booking.destination),
                          ),
                        ],
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    side: BorderSide(color: context.colors.borderColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
