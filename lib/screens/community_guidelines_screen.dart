import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/welcome_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.beforeYouStart,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/car_interior.png',
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Community Guidelines ──────────────────────────
                    _buildSectionHeader(context,
                      icon: Icons.people_outline,
                      title: context.l10n.communityGuidelines,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        context.l10n.guidelinesIntro,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildGuidelineItem(context,
                      icon: Icons.people_outline,
                      title: context.l10n.sharedCommunity,
                      description: context.l10n.guidelineSharedCab,
                    ),
                    _buildGuidelineItem(context,
                      icon: Icons.lightbulb_outline,
                      title: context.l10n.travelSmarter,
                      description: context.l10n.guidelineShareRides,
                    ),
                    _buildGuidelineItem(context,
                      icon: Icons.access_time,
                      title: context.l10n.bePunctual,
                      description: context.l10n.guidelineArriveEarly,
                    ),
                    _buildGuidelineItem(context,
                      icon: Icons.handshake_outlined,
                      title: context.l10n.trustAndCommunity,
                      description: context.l10n.guidelineCarpooling,
                    ),

                    const SizedBox(height: 28),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: context.colors.borderColor),
                    ),
                    const SizedBox(height: 20),

                    // ── Seats Order ───────────────────────────────────
                    _buildSectionHeader(context,
                      icon: Icons.event_seat,
                      title: context.l10n.seatsOrder,
                    ),
                    const SizedBox(height: 16),

                    // Visual seat diagram
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colors.highlightBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Front row: driver + front passenger
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSeatIcon(Icons.directions_car,
                                    color: context.colors.borderColor),
                                _buildSeatIcon(Icons.person,
                                    color: AppStyles.primaryColor, isHighlighted: true),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Back row: 3 passengers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSeatIcon(Icons.person,
                                    color: AppStyles.primaryColor, isHighlighted: true),
                                _buildSeatIcon(Icons.person,
                                    color: AppStyles.primaryColor, isHighlighted: true),
                                _buildSeatIcon(Icons.person,
                                    color: AppStyles.primaryColor, isHighlighted: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Seat rule explanations
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildSeatRule(context,
                            icon: Icons.looks_one,
                            title: context.l10n.backRowSelection,
                            desc: context.l10n.backRowSelectionDesc,
                          ),
                          const SizedBox(height: 16),
                          _buildSeatRule(context,
                            icon: Icons.group,
                            title: context.l10n.fullCarSelection,
                            desc: context.l10n.fullCarSelectionDesc,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: AppStyles.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.iUnderstandGetStarted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatIcon(IconData icon,
      {required Color color, bool isHighlighted = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent, // intentional
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          color: isHighlighted ? AppStyles.onPrimary : color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSeatRule(BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppStyles.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
