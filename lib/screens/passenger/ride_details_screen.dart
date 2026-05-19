import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/screens/passenger/booking_status_screen.dart';
import 'package:testtale3/screens/passenger/select_seat_screen.dart';
import 'package:testtale3/widgets/permission_dialog.dart';
import 'package:testtale3/screens/shared/route_map_widget.dart';

// ignore_for_file: use_build_context_synchronously

class RideDetailsScreen extends StatefulWidget {
  final RideModel ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  RideModel get ride => widget.ride;

  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  String? _locationError;

  Future<void> _handleBooking() async {
    final perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (!mounted) return;
      await showLocationSettingsReminder(context);
      return;
    }

    if (!mounted) return;
    setState(() => _locationError = null);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SelectSeatScreen(ride: ride)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light gray background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.l10n.rideDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDF2F4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: _primaryColor, size: 18),
                      onPressed: () {},
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
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const CircleAvatar(
                              radius: 32,
                              backgroundColor: Color(0xFFE0E0E0),
                              child: Icon(Icons.person, color: Colors.white, size: 40),
                            ),
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
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // ── Dynamic rating badge ──────────────
                                    FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(ride.driverId)
                                          .get(),
                                      builder: (context, snap) {
                                        double avg = 0.0;
                                        int count = 0;
                                        if (snap.hasData && snap.data!.exists) {
                                          final data = snap.data!.data()
                                              as Map<String, dynamic>;
                                          avg = (data['averageRating'] as num?)
                                                  ?.toDouble() ??
                                              0.0;
                                          count = (data['ratingCount'] as num?)
                                                  ?.toInt() ??
                                              0;
                                        }
                                        // Show nothing if no ratings yet
                                        if (count == 0) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.star_border,
                                                    color: Color(0xFF9E9E9E),
                                                    size: 12),
                                                SizedBox(width: 2),
                                                Text(
                                                  'New',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF9E9E9E),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF8E1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Color(0xFFFFC107),
                                                  size: 12),
                                              const SizedBox(width: 2),
                                              Text(
                                                avg.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFF57F17),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ride.carShortInfo} \u2022 ${ride.plateNumber}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.verified, color: _primaryColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.l10n.verifiedDriver,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _primaryColor,
                                        letterSpacing: 1,
                                      ),
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

                    // Map Section
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          RouteMapWidget(
                            origin: ride.origin,
                            destination: ride.destination,
                            height: 160,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on, color: _primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.route,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9E9E9E),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${ride.origin} → ${ride.destination}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    context.l10n.estTime,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF9E9E9E),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '1h 15m',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Time, Seats, Price Cards
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
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.tripRulesFeatures,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9E9E9E),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (ride.noSmoking) _buildRuleItem(Icons.smoke_free, context.l10n.noSmokingAllowed),
                          if (ride.luggageEnabled) _buildRuleItem(Icons.luggage, context.l10n.luggageSpaceAvailable),
                          if (ride.acEnabled) _buildRuleItem(Icons.ac_unit, context.l10n.airConditioning),
                          if (ride.petsAllowed) _buildRuleItem(Icons.pets, context.l10n.petsAllowed),
                          if (!ride.noSmoking && !ride.luggageEnabled && !ride.acEnabled && !ride.petsAllowed)
                            Text(context.l10n.noSpecialRules, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Booking Bar
            StreamBuilder<BookingModel?>(
              stream: context
                  .read<BookingProvider>()
                  .existingBookingStream(ride.id),
              builder: (context, snapshot) {
                final existing = snapshot.data;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: existing != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF2E7D32), size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "You've already booked this ride",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      BookingStatusScreen(booking: existing),
                                )),
                                icon: const Icon(Icons.receipt_long_rounded,
                                    size: 20),
                                label: const Text(
                                  'View My Booking',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFFFCDD2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_off_rounded,
                                        color: Color(0xFFB71C1C), size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _locationError!,
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
                            ],
                            Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_seat,
                                    color: _primaryColor, size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.selectSeat,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryColor,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _handleBooking,
                                  icon: const Icon(Icons.check_circle_outline,
                                      size: 20),
                                  label: Text(
                                    context.l10n.requestBooking,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _darkMaroon,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF2F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: _primaryColor, size: 20),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF757575),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isPrice ? _primaryColor : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}