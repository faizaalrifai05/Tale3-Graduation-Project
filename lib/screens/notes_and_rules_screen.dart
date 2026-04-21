import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/welcome_screen.dart';

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
          'Notes & Rules',
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
                    'Community Guidelines',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRuleItem(context, 'Tale3 is a shared carpool community — not a private car. Ride together, not alone.'),
              _buildRuleItem(context, 'Share rides, split costs, and travel smarter together.'),
              _buildRuleItem(context, 'Arrive a little early to keep things smooth. Showing up a few minutes before your driver arrives helps ensure a stress-free ride.'),
              _buildRuleItem(context, 'Carpooling helps keep travel affordable while building a friendly, trust-based community.'),
              const SizedBox(height: 32),

              // Seats Order Section
              Row(
                children: [
                  Icon(Icons.event_seat, color: AppStyles.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Seats Order',
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
                title: 'Back Row Selection',
                desc: 'Choose "Back Row" to reserve all three back seats for maximum comfort or luggage space.',
              ),
              const SizedBox(height: 16),
              _buildSeatRule(context,
                icon: Icons.group,
                title: 'Full Car Selection',
                desc: 'Choose "All" to reserve all four seats and have the entire vehicle to yourself.',
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
                        'Next',
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

