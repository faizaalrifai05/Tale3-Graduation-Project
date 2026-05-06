import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/welcome_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class NotesAndRulesScreen extends StatelessWidget {
  const NotesAndRulesScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.notesAndRules,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Guidelines Section
              Row(
                children: [
                  Icon(Icons.people_outline, color: AppStyles.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.communityGuidelines,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRuleItem(context, context.l10n.guidelineSharedCarpool),
              _buildRuleItem(context, context.l10n.guidelineShareRides),
              _buildRuleItem(context, context.l10n.guidelineArriveEarly),
              _buildRuleItem(context, context.l10n.guidelineCarpooling),
              const SizedBox(height: 32),

              // Seats Order Section
              Row(
                children: [
                  Icon(Icons.event_seat, color: AppStyles.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.seatsOrder,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Seat layout diagram
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.highlightBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Front row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSeatIcon(Icons.directions_car, color: context.colors.borderColor),
                        _buildSeatIcon(Icons.person, color: AppStyles.primaryColor, isHighlighted: true),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Back row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSeatIcon(Icons.person, color: AppStyles.primaryColor, isHighlighted: true),
                        _buildSeatIcon(Icons.person, color: AppStyles.primaryColor, isHighlighted: true),
                        _buildSeatIcon(Icons.person, color: AppStyles.primaryColor, isHighlighted: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Seat rules explanations
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
              
              const SizedBox(height: 40),
              
              // Next Button
              SizedBox(
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
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: AppStyles.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.next,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppStyles.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textDeep,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatIcon(IconData icon, {required Color color, bool isHighlighted = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent, // transparent is intentional
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

  Widget _buildSeatRule(BuildContext context, {required IconData icon, required String title, required String desc}) {
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

