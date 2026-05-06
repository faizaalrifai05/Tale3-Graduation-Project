import 'package:flutter/material.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/screens/passenger/select_seat_screen.dart';


class RideDetailsScreen extends StatelessWidget {
  final RideModel ride;

  const RideDetailsScreen({super.key, required this.ride});

  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF8E1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.star, color: Color(0xFFFFC107), size: 12),
                                          SizedBox(width: 2),
                                          Text(
                                            '4.8',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFF57F17),
                                            ),
                                          ),
                                        ],
                                      ),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  // Placeholder map image
                                  Container(
                                    color: const Color(0xFFE0F7FA),
                                    child: Center(
                                      child: Icon(Icons.map, size: 64, color: Colors.blue[200]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                    SizedBox(height: 4),
                                    Text(
                                      '${ride.origin} → ${ride.destination}',
                                      style: TextStyle(
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000), // Colors.black.withOpacity(0.05)
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_seat, color: _primaryColor, size: 24),
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
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SelectSeatScreen(ride: ride),
                          ));
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 20),
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


