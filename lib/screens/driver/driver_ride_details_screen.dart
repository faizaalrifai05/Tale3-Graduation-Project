import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/screens/driver/driver_ride_live_screen.dart';
import 'package:testtale3/screens/shared/conversation_screen.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/l10n/app_localizations.dart';

// ignore_for_file: use_build_context_synchronously

class DriverRideDetailsScreen extends StatefulWidget {
  final RideModel? ride;
  const DriverRideDetailsScreen({super.key, this.ride});

  @override
  State<DriverRideDetailsScreen> createState() =>
      _DriverRideDetailsScreenState();
}

class _DriverRideDetailsScreenState extends State<DriverRideDetailsScreen> {
  bool _cancelling = false;
  RideModel? _liveRide;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;

  RideModel? get _ride => _liveRide ?? widget.ride;

  @override
  void initState() {
    super.initState();
    _liveRide = widget.ride;
    final rideId = widget.ride?.id;
    if (rideId != null) {
      _rideSub = FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .snapshots()
          .listen((snap) {
        if (!mounted || !snap.exists) return;
        setState(() => _liveRide = RideModel.fromDoc(snap));
      });
    }
  }

  @override
  void dispose() {
    _rideSub?.cancel();
    super.dispose();
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.cancelRide,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'This will cancel the ride and notify all booked passengers.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.keepRide,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.confirmCancellation,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _cancelling = true);
    try {
      await context.read<RideProvider>().cancelRide(_ride!.id);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _showShareSheet(BuildContext context) {
    final r = _ride;
    final shareText = r != null
        ? 'Check out this ride on Tale3!\n🚗 ${r.origin} → ${r.destination} • ${r.date} at ${r.time}\nBook now on Tale3 — the trusted carpool app.'
        : 'Check out this ride on Tale3!\nBook now on Tale3 — the trusted carpool app.';
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: ctx.colors.borderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(ctx.l10n.shareRide, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ctx.colors.textPrimary)),
            const SizedBox(height: 8),
            Text(shareText, style: TextStyle(fontSize: 14, color: ctx.colors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: Text(ctx.l10n.copyRideDetails, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: shareText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.rideCopied),
                    backgroundColor: AppStyles.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.darkMaroon,
                  foregroundColor: AppStyles.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              color: context.colors.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.l10n.rideDetails,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: context.colors.highlightBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share, color: AppStyles.primaryColor, size: 18),
                      onPressed: () => _showShareSheet(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ── Map placeholder ──────────────────────────────────────
                    _MapSection(origin: _ride?.origin, destination: _ride?.destination),
                    const SizedBox(height: 8),

                    // ── Route timeline ───────────────────────────────────────
                    _RouteSection(origin: _ride?.origin, destination: _ride?.destination),
                    const SizedBox(height: 8),

                    // ── Info cards (date / seats / price) ────────────────────
                    Container(
                      color: context.colors.surfaceColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          _buildInfoCard(context, Icons.calendar_today_rounded,
                              context.l10n.dateAndTime.toUpperCase(),
                              '${_ride?.date ?? '-'}\n${_ride?.time ?? '-'}'),
                          const SizedBox(width: 12),
                          _buildInfoCard(context, Icons.event_seat_rounded,
                              context.l10n.seatsLeft.toUpperCase(),
                              '${_ride?.availableSeats ?? '-'} / ${_ride?.totalSeats ?? '-'}'),
                          const SizedBox(width: 12),
                          _buildInfoCard(context, Icons.payments_outlined,
                              context.l10n.price.toUpperCase(),
                              '${_ride?.pricePerSeat ?? '-'} JOD',
                              isPrice: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Pending requests ─────────────────────────────────────
                    _RequestsSection(ride: _ride),
                    const SizedBox(height: 8),

                    // ── Confirmed passengers ──────────────────────────────────
                    _PassengersSection(rideId: _ride?.id),
                    const SizedBox(height: 8),

                    // ── Rules & preferences ──────────────────────────────────
                    _RulesSection(ride: _ride),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_ride?.status == 'active' || _ride?.status == 'live') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final perm = await Geolocator.checkPermission();
                          if (!context.mounted) return;
                          if (perm == LocationPermission.denied ||
                              perm == LocationPermission.deniedForever) {
                            await showLocationSettingsReminder(context);
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DriverRideLiveScreen(
                                rideId: _ride!.id,
                                origin: _ride!.origin,
                                destination: _ride!.destination,
                                driverName: _ride!.driverName,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          _ride?.status == 'live'
                              ? Icons.directions_car_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 22,
                        ),
                        label: Text(
                          _ride?.status == 'live' ? 'Resume Ride' : context.l10n.startRide,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ride?.status == 'live'
                              ? AppStyles.successColor
                              : AppStyles.darkMaroon,
                          foregroundColor: AppStyles.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    if (_ride?.status == 'active') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _cancelling ? null : () => _confirmCancel(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _cancelling
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.red),
                                )
                              : Text(
                                  context.l10n.cancelRide,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ] else
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.colors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _ride?.status == 'cancelled'
                            ? context.l10n.rideCancelled
                            : context.l10n.rideCompleted,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _ride?.status == 'cancelled'
                              ? Colors.red
                              : AppStyles.successDarkText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label,
      String value, {bool isPrice = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.highlightBackgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppStyles.primaryColor, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: context.colors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isPrice ? AppStyles.primaryColor : context.colors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAP SECTION — real Google Map with route polyline
// ─────────────────────────────────────────────────────────────────────────────
class _MapSection extends StatefulWidget {
  final String? origin;
  final String? destination;
  const _MapSection({this.origin, this.destination});

  @override
  State<_MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<_MapSection> {
  GoogleMapController? _mapController;
  List<LatLng> _polylinePoints = [];
  bool _loading = true;

  static const LatLng _fallback = LatLng(31.9454, 35.9284); // Amman

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final origin = widget.origin;
    final destination = widget.destination;
    if (origin == null || destination == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final points = await MapsService.getRoute(origin, destination);
      if (mounted) setState(() { _polylinePoints = points; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (_polylinePoints.isEmpty) return;
    final bounds = await MapsService.getBounds(
        widget.origin!, widget.destination!);
    if (bounds != null && mounted) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 48),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: _loading
              ? Container(
                  color: AppStyles.successLightBg,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _polylinePoints.isNotEmpty
                        ? _polylinePoints[0]
                        : _fallback,
                    zoom: 10,
                  ),
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  markers: {
                    if (_polylinePoints.isNotEmpty) ...[
                      Marker(
                        markerId: const MarkerId('origin'),
                        position: _polylinePoints.first,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                        infoWindow: InfoWindow(
                            title: widget.origin ?? ''),
                      ),
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: _polylinePoints.last,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen),
                        infoWindow: InfoWindow(
                            title: widget.destination ?? ''),
                      ),
                    ],
                  },
                  polylines: {
                    if (_polylinePoints.isNotEmpty)
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: _polylinePoints,
                        color: AppStyles.primaryColor,
                        width: 4,
                      ),
                  },
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROUTE SECTION — origin → dropoffs → destination timeline
// ─────────────────────────────────────────────────────────────────────────────
class _RouteSection extends StatelessWidget {
  final String? origin;
  final String? destination;
  const _RouteSection({this.origin, this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.route.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _routeStop(
            context,
            icon: Icons.radio_button_checked,
            iconColor: AppStyles.primaryColor,
            label: context.l10n.pickup,
            address: origin ?? '-',
            isLast: false,
          ),
          _routeStop(
            context,
            icon: Icons.location_on_rounded,
            iconColor: AppStyles.successDarkText,
            label: context.l10n.finalDestination,
            address: destination ?? '-',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _routeStop(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    required bool isLast,
    bool isDim = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + connecting line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDim
                    ? context.colors.cardBackgroundColor
                    : iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 16,
                  color: isDim ? context.colors.textTertiary : iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.borderColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDim ? context.colors.textSecondary : context.colors.textPrimary,
                  ),
                ),
                if (!isLast) const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REQUESTS SECTION — pending bookings the driver can accept or reject
// ─────────────────────────────────────────────────────────────────────────────
class _RequestsSection extends StatefulWidget {
  final RideModel? ride;
  const _RequestsSection({this.ride});

  @override
  State<_RequestsSection> createState() => _RequestsSectionState();
}

class _RequestsSectionState extends State<_RequestsSection> {
  final Set<String> _processing = {};
  final Map<String, String> _errors = {};

  Future<void> _accept(BuildContext context, BookingModel booking) async {
    setState(() {
      _processing.add(booking.id);
      _errors.remove(booking.id);
    });
    final error = await context.read<BookingProvider>().acceptBooking(booking);
    if (!mounted) return;
    setState(() {
      _processing.remove(booking.id);
      if (error != null) {
        _errors[booking.id] = switch (error) {
          'not_enough_seats'   => context.l10n.noSeatsAvailable,
          'ride_not_accepting' => context.l10n.rideAlreadyStarted,
          'ride_not_found'     => context.l10n.rideNotFound,
          'permission_denied'  => context.l10n.permissionDenied,
          _                    => context.l10n.somethingWentWrong,
        };
      }
    });
  }

  Future<void> _reject(BuildContext context, BookingModel booking) async {
    setState(() => _processing.add(booking.id));
    try {
      await context.read<BookingProvider>().rejectBooking(booking);
    } finally {
      if (mounted) setState(() => _processing.remove(booking.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    if (ride == null || ride.status == 'in_progress') return const SizedBox.shrink();

    return StreamBuilder<List<BookingModel>>(
      stream: context.read<BookingProvider>().pendingBookingsStream(ride.id),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) return const SizedBox.shrink();

        return Container(
          color: context.colors.surfaceColor,
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.bookingRequests,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textTertiary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.pendingLightBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${requests.length} ${context.l10n.pendingLabel}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.colors.pendingColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...requests.map((b) => _RequestRow(
                    booking: b,
                    ride: ride,
                    isProcessing: _processing.contains(b.id),
                    errorMessage: _errors[b.id],
                    onAccept: () => _accept(context, b),
                    onReject: () => _reject(context, b),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  final BookingModel booking;
  final RideModel ride;
  final bool isProcessing;
  final String? errorMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestRow({
    required this.booking,
    required this.ride,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
    this.errorMessage,
  });

  void _viewLocations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PassengerLocationSheet(
        booking: booking,
        ride: ride,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPickup = booking.pickupLat != null && booking.pickupLng != null;
    final detour = hasPickup
        ? MapsService.detourKm(
            LatLng(booking.pickupLat!, booking.pickupLng!),
            ride.origin,
            ride.destination,
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.pendingBadgeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.pendingBadgeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.colors.highlightBackgroundColor,
                child: Text(
                  booking.passengerName.isNotEmpty
                      ? booking.passengerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.passengerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}  •  ${booking.totalPrice} JOD',
                      style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Detour badge
              if (detour != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: detour > 5
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.alt_route_rounded,
                        size: 12,
                        color: detour > 5
                            ? const Color(0xFFB71C1C)
                            : const Color(0xFF2E7D32),
                      ),
                      Text(
                        '+${detour.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: detour > 5
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.l10n.noPin,
                    style: TextStyle(fontSize: 10, color: context.colors.textTertiary),
                  ),
                ),
            ],
          ),
          // View locations button (only if passenger set pins)
          if (hasPickup) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _viewLocations(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.infoLinkBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_rounded, size: 14, color: context.colors.infoLinkColor),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.viewPickupDropoff,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.infoLinkColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 14, color: context.colors.infoLinkColor),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (isProcessing)
            const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      side: const BorderSide(color: Color(0xFFB71C1C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.l10n.reject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: Text(context.l10n.accept, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.errorLightBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppStyles.errorColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 14, color: AppStyles.errorColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(fontSize: 12, color: AppStyles.errorColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PASSENGER LOCATION SHEET — map with pickup + drop-off pins
// ─────────────────────────────────────────────────────────────────────────────
class _PassengerLocationSheet extends StatefulWidget {
  final BookingModel booking;
  final RideModel ride;
  const _PassengerLocationSheet({required this.booking, required this.ride});

  @override
  State<_PassengerLocationSheet> createState() => _PassengerLocationSheetState();
}

class _PassengerLocationSheetState extends State<_PassengerLocationSheet> {
  GoogleMapController? _mapController;

  LatLng get _pickup => LatLng(widget.booking.pickupLat!, widget.booking.pickupLng!);
  LatLng? get _dropoff => widget.booking.dropoffLat != null && widget.booking.dropoffLng != null
      ? LatLng(widget.booking.dropoffLat!, widget.booking.dropoffLng!)
      : null;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    final drop = _dropoff;
    if (drop == null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_pickup, 15));
      return;
    }
    final sw = LatLng(
      _pickup.latitude < drop.latitude ? _pickup.latitude : drop.latitude,
      _pickup.longitude < drop.longitude ? _pickup.longitude : drop.longitude,
    );
    final ne = LatLng(
      _pickup.latitude > drop.latitude ? _pickup.latitude : drop.latitude,
      _pickup.longitude > drop.longitude ? _pickup.longitude : drop.longitude,
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(LatLngBounds(southwest: sw, northeast: ne), 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drop = _dropoff;
    final detour = MapsService.detourKm(_pickup, widget.ride.origin, widget.ride.destination);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF3E5F5),
                  child: Text(
                    widget.booking.passengerName.isNotEmpty
                        ? widget.booking.passengerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF8B1A2B),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.booking.passengerName}\'s locations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: detour > 5 ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.alt_route_rounded, size: 12,
                            color: detour > 5 ? const Color(0xFFB71C1C) : const Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          '+${detour.toStringAsFixed(1)} km detour',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: detour > 5 ? const Color(0xFFB71C1C) : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Map
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _pickup, zoom: 13),
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: _pickup,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: const InfoWindow(title: 'Passenger Pickup'),
                    ),
                    if (drop != null)
                      Marker(
                        markerId: const MarkerId('dropoff'),
                        position: drop,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        infoWindow: const InfoWindow(title: 'Passenger Drop-off'),
                      ),
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _legendDot(const Color(0xFFE53935), 'Pickup'),
                const SizedBox(width: 20),
                if (drop != null) _legendDot(const Color(0xFF2E7D32), 'Drop-off'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.textPrimary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PASSENGERS SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PassengersSection extends StatelessWidget {
  final String? rideId;
  const _PassengersSection({this.rideId});

  @override
  Widget build(BuildContext context) {
    if (rideId == null) return const SizedBox.shrink();

    return StreamBuilder<List<BookingModel>>(
      stream: context.read<BookingProvider>().driverRideBookingsStream(rideId!),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        return Container(
          color: context.colors.surfaceColor,
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.passengers.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textTertiary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppStyles.successLightBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${bookings.fold(0, (s, b) => s + b.seatsBooked)} ${context.l10n.booked}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.successDarkText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (bookings.isEmpty)
                Text(
                  context.l10n.noPassengersYet,
                  style: TextStyle(
                      fontSize: 13, color: context.colors.textSecondary),
                )
              else
                ...() {
                  int seatNum = 1;
                  final rows = <_PassengerRow>[];
                  final bp = context.read<BookingProvider>();
                  for (final b in bookings) {
                    final genders = b.passengerGender.isNotEmpty
                        ? b.passengerGender.split(',')
                        : <String>[];
                    for (int i = 0; i < b.seatsBooked; i++) {
                      final gender = i < genders.length ? genders[i].trim() : '';
                      rows.add(_PassengerRow(
                        name: b.passengerName,
                        passengerId: b.passengerId,
                        seat: 'Seat $seatNum',
                        passengerGender: gender,
                        bookingProvider: bp,
                      ));
                      seatNum++;
                    }
                  }
                  return rows;
                }(),
            ],
          ),
        );
      },
    );
  }
}

class _PassengerRow extends StatefulWidget {
  final String name;
  final String passengerId;
  final String seat;
  final String passengerGender;
  final BookingProvider bookingProvider;
  const _PassengerRow({
    required this.name,
    required this.passengerId,
    required this.seat,
    required this.bookingProvider,
    this.passengerGender = '',
  });

  @override
  State<_PassengerRow> createState() => _PassengerRowState();
}

class _PassengerRowState extends State<_PassengerRow> {
  late Future<({String name, String photoUrl, double averageRating, int ratingCount})> _infoFuture;

  @override
  void initState() {
    super.initState();
    _infoFuture = widget.bookingProvider.fetchPassengerInfo(
      widget.passengerId,
      fallbackName: widget.name.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({String name, String photoUrl, double averageRating, int ratingCount})>(
      future: _infoFuture,
      builder: (context, snap) {
        final displayName = snap.data?.name.isNotEmpty == true
            ? snap.data!.name
            : widget.name.trim();
        final photoUrl = snap.data?.photoUrl ?? '';
        final ratingCount = snap.data?.ratingCount ?? 0;
        final ratingDisplay = ratingCount == 0
            ? '—'
            : (snap.data!.averageRating).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: context.colors.highlightBackgroundColor,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty ? displayName : 'Passenger',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  widget.seat,
                  style: TextStyle(
                      fontSize: 12, color: context.colors.textSecondary),
                ),
                if (widget.passengerGender.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Builder(builder: (_) {
                    final g = widget.passengerGender.toLowerCase();
                    final isFemale = g == 'female' || g == 'أنثى';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFemale ? Icons.woman_rounded : Icons.man_rounded,
                          size: 13,
                          color: isFemale ? const Color(0xFFE91E8C) : const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isFemale ? 'Female' : 'Male',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isFemale ? const Color(0xFFE91E8C) : const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
          // Rating badge
          Row(
            children: [
              Icon(Icons.star_rounded,
                  size: 13,
                  color: ratingCount == 0
                      ? context.colors.textTertiary
                      : AppStyles.starRatingColor),
              const SizedBox(width: 3),
              Text(
                ratingDisplay,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ConversationScreen(
                otherUserId: widget.passengerId,
                otherUserName: displayName.isNotEmpty ? displayName : 'Passenger',
              ),
            )),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.colors.highlightBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: AppStyles.primaryColor),
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RULES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _RulesSection extends StatelessWidget {
  final RideModel? ride;
  const _RulesSection({this.ride});

  @override
  Widget build(BuildContext context) {
    final r = ride;
    final rules = [
      (Icons.ac_unit_rounded, context.l10n.airConditioning, r?.acEnabled ?? false),
      (Icons.luggage_rounded, context.l10n.luggageSpaceAvailable, r?.luggageEnabled ?? false),
      (Icons.smoke_free_rounded, context.l10n.noSmoking, r?.noSmoking ?? false),
      (Icons.pets_rounded, context.l10n.petsAllowed, r?.petsAllowed ?? false),
    ];
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.ridePreferences.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rules.map((r) {
              final (icon, label, enabled) = r;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppStyles.successLightBg
                      : context.colors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: enabled
                        ? AppStyles.successColor.withValues(alpha: 0.3)
                        : context.colors.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: enabled
                          ? AppStyles.successDarkText
                          : context.colors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppStyles.successDarkText
                            : context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
