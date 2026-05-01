import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import 'ride_posted_screen.dart';

// ignore_for_file: use_build_context_synchronously

/// Confirmation screen shown after filling the Create Ride form.
/// Displays all ride details for review before publishing.
class RideConfirmationScreen extends StatelessWidget {
  const RideConfirmationScreen({super.key});

  Future<void> _publish(BuildContext context) async {
    final ride = context.read<RideProvider>();
    final auth = context.read<AuthProvider>();

    final error = await ride.publishRide(
      driverId: auth.currentUser?.uid ?? '',
      driverName: auth.userName,
    );

    if (!context.mounted) return;

    if (error != null) {
      // Show dialog for verification/block errors, snackbar for others
      if (error.contains('not verified') || error.contains('blocked')) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  error.contains('blocked')
                      ? Icons.block_rounded
                      : Icons.verified_user_outlined,
                  color: AppStyles.errorColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  error.contains('blocked')
                      ? 'Account Blocked'
                      : 'Not Verified Yet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Regular errors show as snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppStyles.errorColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final origin = ride.origin;
    final destination = ride.destination;
    ride.resetForm();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            RidePostedScreen(origin: origin, destination: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review Ride',
          style: TextStyle(
            color: context.colors.textPrimary,
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
                    Text(
                      'Please review your ride details\nbefore publishing.',
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textSecondary,
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
                                      color: context.colors.borderColor,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppStyles.successColor,
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
                                    Text(
                                      'FROM',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textTertiary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ride.origin.isEmpty
                                          ? 'Not specified'
                                          : ride.origin,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'TO',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textTertiary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ride.destination.isEmpty
                                          ? 'Not specified'
                                          : ride.destination,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textPrimary,
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
                                value: ride.dateLabel,
                              ),
                              _DetailItem(
                                icon: Icons.access_time_rounded,
                                label: 'Time',
                                value: ride.timeLabel,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _DetailItem(
                                icon: Icons.airline_seat_recline_normal_rounded,
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
                                _featureChip(context, Icons.ac_unit_rounded,
                                    'Air Conditioning'),
                              if (ride.luggageChecked)
                                _featureChip(context, Icons.luggage_rounded,
                                    'Luggage'),
                              if (ride.petsChecked)
                                _featureChip(
                                    context, Icons.pets_rounded, 'Pets Allowed'),
                              if (ride.noSmokingChecked)
                                _featureChip(context, Icons.smoke_free_rounded,
                                    'No Smoking'),
                              if (!ride.acChecked &&
                                  !ride.luggageChecked &&
                                  !ride.petsChecked &&
                                  !ride.noSmokingChecked)
                                Text(
                                  'No features selected',
                                  style: TextStyle(
                                    color: context.colors.textTertiary,
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
                              style: TextStyle(
                                fontSize: 14,
                                color: context.colors.textSecondary,
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
                        color: context.colors.highlightBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppStyles.primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total if fully booked',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          Text(
                            '\$${ride.price * ride.seats}',
                            style: TextStyle(
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
                color: context.colors.surfaceColor,
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
                          foregroundColor: context.colors.textPrimary,
                          side: BorderSide(color: context.colors.borderColor),
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
                        onPressed: ride.isPublishing
                            ? null
                            : () => _publish(context),
                        icon: ride.isPublishing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppStyles.onPrimary,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          ride.isPublishing
                              ? 'Publishing...'
                              : 'Confirm & Publish',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.darkMaroon,
                          foregroundColor: AppStyles.onPrimary,
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

  static Widget _featureChip(
      BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppStyles.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
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
        color: context.colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context.colors.borderColor.withValues(alpha: 0.5)),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
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
              color: context.colors.cardBackgroundColor,
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
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}