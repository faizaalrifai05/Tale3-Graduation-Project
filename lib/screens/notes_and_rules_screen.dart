import 'package:flutter/material.dart';
import 'package:testtale3/screens/community_guidelines_screen.dart';
import 'package:testtale3/screens/welcome_screen.dart';

class NotesAndRulesScreen extends StatefulWidget {
  const NotesAndRulesScreen({super.key});

  @override
  State<NotesAndRulesScreen> createState() => _NotesAndRulesScreenState();
}

class _NotesAndRulesScreenState extends State<NotesAndRulesScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CommunityGuidelinesScreen()),
          ),
        ),
        title: const Text(
          'Notes & Rules',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
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
                  const Icon(Icons.people_outline, color: _primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Community Guidelines',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNote('Tale3 is a shared carpool community and not a private car. Ride together, not alone.'),
              _buildNote('Share rides, split costs, and travel smarter together.'),
              _buildNote('Arrive a little early to keep things smooth. Showing up a few minutes before your driver arrives helps ensure a stress-free ride.'),
              _buildNote('Carpooling helps keep travel affordable while building a friendly, trust-based community.'),
              const SizedBox(height: 32),

              // Seats Order Section
              Row(
                children: [
                  const Icon(Icons.event_seat, color: _primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Seats Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
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
                  color: const Color(0xFFFDF2F4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Front row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSeatIcon(Icons.directions_car, color: const Color(0xFFE0E0E0)),
                        _buildSeatIcon(Icons.person, color: _primaryColor, isHighlighted: true),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Back row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSeatIcon(Icons.person, color: _primaryColor, isHighlighted: true),
                        _buildSeatIcon(Icons.person, color: _primaryColor, isHighlighted: true),
                        _buildSeatIcon(Icons.person, color: _primaryColor, isHighlighted: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Seat rules explanations
              _buildSeatRule(
                icon: Icons.looks_one,
                title: 'Back Row Selection',
                desc: 'Choose "Back Row" to reserve all three back seats for maximum comfort or luggage space.',
              ),
              const SizedBox(height: 16),
              _buildSeatRule(
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
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
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

  Widget _buildNote(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF8B1A2B)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF424242),
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

  Widget _buildSeatRule({required IconData icon, required String title, required String desc}) {
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

