import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/screens/passenger/booking_status_screen.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:geolocator/geolocator.dart';
import 'package:testtale3/screens/passenger/select_seat_screen.dart';
import 'package:testtale3/screens/shared/route_map_widget.dart';
import 'package:testtale3/widgets/permission_dialog.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/theme/app_styles.dart';

// ignore_for_file: use_build_context_synchronously

class RideDetailsScreen extends StatefulWidget {
  final RideModel ride;
  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  RideModel get ride => widget.ride;

  String? _locationError;
  bool _isBooking = false;
  late final Future<String> _durationFuture;

  @override
  void initState() {
    super.initState();
    _durationFuture = MapsService.fetchDrivingDuration(
        widget.ride.origin, widget.ride.destination);
  }

  Future<void> _handleBooking() async {
    if (_isBooking) return;
    setState(() => _isBooking = true);
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) await showLocationSettingsReminder(context);
        return;
      }
      if (!mounted) return;
      setState(() => _locationError = null);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SelectSeatScreen(ride: ride)),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showShareSheet(BuildContext context) {
    final shareText =
        'Check out this ride on Tale3!\n'
        '🚗 ${ride.origin} → ${ride.destination} • ${ride.date} at ${ride.time}\n'
        'Driver: ${ride.driverName} | ${ride.carShortInfo}\n'
        'Price: ${ride.pricePerSeat} JOD per seat\n'
        'Book now on Tale3 — the trusted carpool app.';

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
                decoration: BoxDecoration(
                  color: ctx.colors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.shareRide,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ctx.colors.textPrimary)),
            const SizedBox(height: 8),
            Text(shareText,
                style: TextStyle(fontSize: 14, color: ctx.colors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: Text(context.l10n.copyRideDetails,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: colors.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.l10n.rideDetails,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colors.highlightBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: AppStyles.primaryColor, size: 18),
                      onPressed: () => _showShareSheet(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Driver Card
                    Container(
                      color: colors.surfaceColor,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: colors.borderColor,
                            child: const Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      ride.driverName.isEmpty ? 'Driver' : ride.driverName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(ride.driverId)
                                          .get(),
                                      builder: (context, snap) {
                                        double avg = 0.0;
                                        int count = 0;
                                        if (snap.hasData && snap.data!.exists) {
                                          final data = snap.data!.data() as Map<String, dynamic>;
                                          avg = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
                                          count = (data['ratingCount'] as num?)?.toInt() ?? 0;
                                        }
                                        if (count == 0) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: colors.cardBackgroundColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.star_border, color: colors.textTertiary, size: 12),
                                                const SizedBox(width: 2),
                                                Text('New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textTertiary)),
                                              ],
                                            ),
                                          );
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppStyles.starRatingLightBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: AppStyles.starRatingColor, size: 12),
                                              const SizedBox(width: 2),
                                              Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppStyles.starRatingDarkText)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ride.carShortInfo} • ${ride.plateNumber}',
                                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.verified, color: AppStyles.primaryColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.l10n.verifiedDriver,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppStyles.primaryColor, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Map + Route Section
                    Container(
                      color: colors.surfaceColor,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          RouteMapWidget(origin: ride.origin, destination: ride.destination, height: 160),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on, color: AppStyles.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(context.l10n.route, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textTertiary, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text('${ride.origin} → ${ride.destination}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(context.l10n.estTime, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textTertiary, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  FutureBuilder<String>(
                                    future: _durationFuture,
                                    builder: (context, snap) => Text(snap.data ?? '—', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildInfoCard(context, Icons.access_time, context.l10n.departure, ride.time),
                              const SizedBox(width: 12),
                              _buildInfoCard(context, Icons.event_seat, context.l10n.seatsLeft, '${ride.availableSeats}'),
                              const SizedBox(width: 12),
                              _buildInfoCard(context, Icons.payments_outlined, context.l10n.price, '${ride.pricePerSeat} JOD', isPrice: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rules and Features
                    Container(
                      color: colors.surfaceColor,
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.tripRulesFeatures, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textTertiary, letterSpacing: 1)),
                          const SizedBox(height: 16),
                          if (ride.noSmoking) _buildRuleItem(context, Icons.smoke_free, context.l10n.noSmokingAllowed),
                          if (ride.luggageEnabled) _buildRuleItem(context, Icons.luggage, context.l10n.luggageSpaceAvailable),
                          if (ride.acEnabled) _buildRuleItem(context, Icons.ac_unit, context.l10n.airConditioning),
                          if (ride.petsAllowed) _buildRuleItem(context, Icons.pets, context.l10n.petsAllowed),
                          if (!ride.noSmoking && !ride.luggageEnabled && !ride.acEnabled && !ride.petsAllowed)
                            Text(context.l10n.noSpecialRules, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Booking Bar
            StreamBuilder<BookingModel?>(
              stream: context.read<BookingProvider>().existingBookingStream(ride.id),
              builder: (context, snapshot) {
                final existing = snapshot.data;
                final colors = context.colors;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surfaceColor,
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: existing != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(color: colors.successLightBg, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppStyles.successDarkText, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(context.l10n.alreadyBookedRide, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.successDarkText))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingStatusScreen(booking: existing))),
                                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                                label: Text(context.l10n.viewMyBooking, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppStyles.successDarkText,
                                  foregroundColor: AppStyles.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_locationError != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: colors.errorLightBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppStyles.errorColor.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_off_rounded, color: AppStyles.errorColor, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(_locationError!, style: const TextStyle(fontSize: 13, color: AppStyles.errorColor, fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ),
                            ],
                            Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.event_seat, color: AppStyles.primaryColor, size: 24),
                                    const SizedBox(height: 4),
                                    Text(context.l10n.selectSeat, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppStyles.primaryColor, height: 1.2)),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isBooking ? null : _handleBooking,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppStyles.darkMaroon,
                                        foregroundColor: AppStyles.onPrimary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: _isBooking
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.check_circle_outline, size: 20),
                                                const SizedBox(width: 8),
                                                Text(context.l10n.requestBooking, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, {bool isPrice = false}) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: colors.highlightBackgroundColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: AppStyles.primaryColor, size: 20),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: colors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isPrice ? AppStyles.primaryColor : colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, IconData icon, String label) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.cardBackgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
        ],
      ),
    );
  }
}
