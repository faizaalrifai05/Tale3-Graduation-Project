import 'package:flutter/material.dart';
import 'package:testtale3/screens/welcome_screen.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);
  static const Color _primaryLight = Color(0x1A8B1A2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  
                  const SizedBox(width: 4),
                  const Text(
                    'Before you start',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
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
                    _buildSectionHeader(
                      icon: Icons.people_outline,
                      title: 'Community Guidelines',
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Please review how Tale3 works to ensure a great experience for everyone.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildGuidelineItem(
                      icon: Icons.people_outline,
                      title: 'Shared Community',
                      description:
                          'Tale3 is a shared carpool community — not a private cab. Ride together, not alone.',
                    ),
                    _buildGuidelineItem(
                      icon: Icons.lightbulb_outline,
                      title: 'Travel Smarter',
                      description:
                          'Share rides, split costs, and travel smarter together.',
                    ),
                    _buildGuidelineItem(
                      icon: Icons.access_time,
                      title: 'Be Punctual',
                      description:
                          'Arrive a little early to keep things smooth. Showing up a few minutes before your driver arrives helps ensure a stress-free ride.',
                    ),
                    _buildGuidelineItem(
                      icon: Icons.handshake_outlined,
                      title: 'Trust & Community',
                      description:
                          'Carpooling helps keep travel affordable while building a friendly, trust-based community.',
                    ),

                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Color(0xFFF0F0F0)),
                    ),
                    const SizedBox(height: 20),

                    // ── Seats Order ───────────────────────────────────
                    _buildSectionHeader(
                      icon: Icons.event_seat,
                      title: 'Seats Order',
                    ),
                    const SizedBox(height: 16),

                    // Visual seat diagram
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF2F4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Front row: driver + front passenger
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSeatIcon(Icons.directions_car,
                                    color: const Color(0xFFE0E0E0)),
                                _buildSeatIcon(Icons.person,
                                    color: _primaryColor, isHighlighted: true),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Back row: 3 passengers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSeatIcon(Icons.person,
                                    color: _primaryColor, isHighlighted: true),
                                _buildSeatIcon(Icons.person,
                                    color: _primaryColor, isHighlighted: true),
                                _buildSeatIcon(Icons.person,
                                    color: _primaryColor, isHighlighted: true),
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
                          _buildSeatRule(
                            icon: Icons.looks_one,
                            title: 'Back Row Selection',
                            desc:
                                'Choose "Back Row" to reserve all three back seats for maximum comfort or luggage space.',
                          ),
                          const SizedBox(height: 16),
                          _buildSeatRule(
                            icon: Icons.group,
                            title: 'Full Car Selection',
                            desc:
                                'Choose "All" to reserve all four seats and have the entire vehicle to yourself.',
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
                    backgroundColor: _darkMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'I Understand & Get Started',
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

  Widget _buildSectionHeader({
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
              color: _primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem({
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
              color: _primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
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
        color: isHighlighted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          color: isHighlighted ? Colors.white : color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSeatRule({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
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
