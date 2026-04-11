import 'package:flutter/material.dart';
import 'package:testtale3/screens/driver/driver_registration_screen.dart';
import 'package:testtale3/screens/passenger/passenger_registration_screen.dart';
import 'package:testtale3/screens/passenger/passenger_login_screen.dart';
import 'package:testtale3/screens/driver/driver_login_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  final bool isLogin;
  const ChooseRoleScreen({super.key, this.isLogin = false});

  static const Color _primaryColor = Color(0xFF8B1A2B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Tale3 logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tale3',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),

              // Settings icon at top right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF757575),
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),

              const Spacer(flex: 2),

              // Choose Your Role heading
              Text(
                isLogin ? 'Log in to your account' : 'Choose Your Role',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isLogin ? 'سجل الدخول لحسابك' : 'اختر دورك',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin 
                    ? 'Welcome back! How would you like\nto log in today?' 
                    : 'How would you like to use Tale3?\nChoose one to get started.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // Role cards
              _buildRoleCard(
                context: context,
                icon: Icons.person_outline,
                title: 'Passenger',
                titleAr: 'راكب',
                description: 'Find & book rides between cities',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => isLogin 
                          ? const PassengerLoginScreen() 
                          : const PassengerRegistrationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context: context,
                icon: Icons.directions_car_outlined,
                title: 'Driver',
                titleAr: 'سائق',
                description: 'Offer rides & earn money driving',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => isLogin 
                          ? const DriverLoginScreen() 
                          : const DriverRegistrationScreen(),
                    ),
                  );
                },
              ),

              const Spacer(flex: 3),

              // Bottom navigation bar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, 'Home', false),
                    _buildNavItem(
                        Icons.directions_car_outlined, 'Rides', false),
                    _buildNavItem(Icons.person_outline, 'Profile', true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String titleAr,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF2F4), // Light pink/rose background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF5D5DB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0x1A8B1A2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        titleAr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? _primaryColor : const Color(0xFF9E9E9E),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? _primaryColor : const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

