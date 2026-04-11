import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../providers/ride_provider.dart';
import 'ride_posted_screen.dart';

/// Confirmation screen shown after filling the Create Ride form.
/// Displays all ride details for review before publishing.
class RideConfirmationScreen extends StatelessWidget {
  const RideConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppStyles.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Review Ride',
          style: TextStyle(
            color: AppStyles.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header text ──
                    const Text(
                      'Please review your ride details\nbefore publishing.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppStyles.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ═══════════════════════════════════════════
                    //  ROUTE CARD
                    // ═══════════════════════════════════════════
                    _SectionCard(
                      child: Column(
                        children: [
                          _SectionHeader(
                              icon: Icons.route_rounded, title: 'Route'),
                          const SizedBox(height: 16),
                          // Route timeline
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppStyles.primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppStyles.primaryColor
                                              .withValues(alpha: 0.3),
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 28,
                                      color: AppStyles.borderColor,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FROM',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppStyles.textTertiary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ride.origin.isEmpty
                                          ? 'Not specified'
                                          : ride.origin,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppStyles.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'TO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppStyles.textTertiary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ride.destination.isEmpty
                                          ? 'Not specified'
                                          : ride.destination,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppStyles.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ═══════════════════════════════════════════
                    //  DATE, TIME, SEATS, PRICE
                    // ═══════════════════════════════════════════
                    _SectionCard(
                      child: Column(
                        children: [
                          _SectionHeader(
                              icon: Icons.info_outline_rounded,
                              title: 'Trip Details'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _DetailItem(
                                icon: Icons.calendar_today_rounded,
                                label: 'Date',
                                value: '15 Oct 2026',
                              ),
                              _DetailItem(
                                icon: Icons.access_time_rounded,
                                label: 'Time',
                                value: '14:30',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _DetailItem(
                                icon:
                                    Icons.airline_seat_recline_normal_rounded,
                                label: 'Seats',
                                value: '${ride.seats}',
                              ),
                              _DetailItem(
                                icon: Icons.attach_money_rounded,
                                label: 'Price / Seat',
                                value: '\$${ride.price}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ═══════════════════════════════════════════
                    //  FEATURES
                    // ═══════════════════════════════════════════
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                              icon: Icons.tune_rounded,
                              title: 'Features & Preferences'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (ride.acChecked)
                                _featureChip(
                                    Icons.ac_unit_rounded, 'Air Conditioning'),
                              if (ride.luggageChecked)
                                _featureChip(
                                    Icons.luggage_rounded, 'Luggage'),
                              if (ride.petsChecked)
                                _featureChip(Icons.pets_rounded, 'Pets Allowed'),
                              if (ride.noSmokingChecked)
                                _featureChip(
                                    Icons.smoke_free_rounded, 'No Smoking'),
                              if (!ride.acChecked &&
                                  !ride.luggageChecked &&
                                  !ride.petsChecked &&
                                  !ride.noSmokingChecked)
                                const Text(
                                  'No features selected',
                                  style: TextStyle(
                                    color: AppStyles.textTertiary,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Notes ──
                    if (ride.additionalNotes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                                icon: Icons.note_alt_outlined,
                                title: 'Additional Notes'),
                            const SizedBox(height: 12),
                            Text(
                              ride.additionalNotes,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppStyles.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Total estimate ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppStyles.highlightBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppStyles.primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total if fully booked',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppStyles.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${ride.price * ride.seats}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ──
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Edit button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppStyles.textPrimary,
                          side:
                              const BorderSide(color: AppStyles.borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm button
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<RideProvider>().publishRide();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const RidePostedScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline,
                            size: 20),
                        label: const Text(
                          'Confirm & Publish',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.darkMaroon,
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

  static Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppStyles.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppStyles.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyles.borderColor.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppStyles.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppStyles.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppStyles.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppStyles.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
