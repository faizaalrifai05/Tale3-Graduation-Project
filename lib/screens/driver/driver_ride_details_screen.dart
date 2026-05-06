import 'package:flutter/services.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/screens/driver/driver_ride_live_screen.dart';
import 'package:testtale3/screens/shared/conversation_screen.dart';
import 'package:testtale3/services/maps_service.dart';
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
      await context.read<RideProvider>().cancelRide(widget.ride!.id);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _showShareSheet(BuildContext context) {
    final r = widget.ride;
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
                    _MapSection(origin: widget.ride?.origin, destination: widget.ride?.destination),
                    const SizedBox(height: 8),

                    // ── Route timeline ───────────────────────────────────────
                    _RouteSection(origin: widget.ride?.origin, destination: widget.ride?.destination),
                    const SizedBox(height: 8),

                    // ── Info cards (date / seats / price) ────────────────────
                    Container(
                      color: context.colors.surfaceColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          _buildInfoCard(context, Icons.calendar_today_rounded,
                              context.l10n.dateAndTime.toUpperCase(),
                              '${widget.ride?.date ?? '-'}\n${widget.ride?.time ?? '-'}'),
                          const SizedBox(width: 12),
                          _buildInfoCard(context, Icons.event_seat_rounded,
                              context.l10n.seatsLeft.toUpperCase(),
                              '${widget.ride?.availableSeats ?? '-'} / ${widget.ride?.totalSeats ?? '-'}'),
                          const SizedBox(width: 12),
                          _buildInfoCard(context, Icons.payments_outlined,
                              context.l10n.price.toUpperCase(),
                              '${widget.ride?.pricePerSeat ?? '-'} JOD',
                              isPrice: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Passengers ───────────────────────────────────────────
                    _PassengersSection(rideId: widget.ride?.id),
                    const SizedBox(height: 8),

                    // ── Rules & preferences ──────────────────────────────────
                    _RulesSection(ride: widget.ride),
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
                  if (widget.ride?.status == 'active') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DriverRideLiveScreen(
                                rideId: widget.ride!.id,
                                origin: widget.ride!.origin,
                                destination: widget.ride!.destination,
                                driverName: widget.ride!.driverName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
                        label: Text(
                          context.l10n.startRide,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.darkMaroon,
                          foregroundColor: AppStyles.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
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
                                height: 20,
                                width: 20,
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
                  ] else
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.ride?.status == 'cancelled'
                            ? 'Ride Cancelled'
                            : 'Ride Completed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.ride?.status == 'cancelled'
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
    final points = await MapsService.getRoute(origin, destination);
    if (mounted) setState(() { _polylinePoints = points; _loading = false; });
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
//  PASSENGERS SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PassengersSection extends StatelessWidget {
  final String? rideId;
  const _PassengersSection({this.rideId});

  @override
  Widget build(BuildContext context) {
    if (rideId == null) return const SizedBox.shrink();

    return StreamBuilder<List<BookingModel>>(
      stream: context.read<BookingProvider>().rideBookingsStream(rideId!),
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
                      '${bookings.length} ${context.l10n.booked}',
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
                ...bookings.asMap().entries.map((e) => _PassengerRow(
                      name: e.value.passengerName,
                      passengerId: e.value.passengerId,
                      seat: 'Seat ${e.key + 1}',
                      seatsBooked: e.value.seatsBooked,
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _PassengerRow extends StatelessWidget {
  final String name;
  final String passengerId;
  final String seat;
  final int seatsBooked;
  const _PassengerRow({
    required this.name,
    required this.passengerId,
    required this.seat,
    this.seatsBooked = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.highlightBackgroundColor,
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  seat,
                  style: TextStyle(
                      fontSize: 12, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          // Rating badge
          Row(
            children: [
              Icon(Icons.star_rounded,
                  size: 13, color: AppStyles.starRatingColor),
              const SizedBox(width: 3),
              Text(
                '4.8',
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
                otherUserId: passengerId,
                otherUserName: name,
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
