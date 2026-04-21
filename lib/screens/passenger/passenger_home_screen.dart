import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/passenger/ride_results_screen.dart';
import 'package:testtale3/screens/passenger/my_trips_screen.dart';
import 'package:testtale3/screens/chat_screen.dart';
import 'package:testtale3/screens/passenger/passenger_profile_screen.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the navigation provider to rebuild when the tab index changes.
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: IndexedStack(
        index: navProvider.passengerTabIndex,
        children: const [
          _HomeTab(),
          MyTripsScreen(),
          ChatScreen(),
          PassengerProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navProvider.passengerTabIndex,
        onTap: (index) {
          context.read<NavigationProvider>().setPassengerTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'MY TRIPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'CHAT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}

// ── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════
          //  GRADIENT HERO HEADER
          // ═══════════════════════════════════════════════════════
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B1A2B),
                  Color(0xFF5C0A1A),
                  Color(0xFF3D0611),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  children: [
                    // Top row: avatar + greeting + notification bell
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0x33FFFFFF),
                            child: Icon(Icons.person,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOOD ${_getGreeting().toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hello, ${context.watch<app_auth.AuthProvider>().userName}!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Notification bell
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.notifications_none_rounded,
                                  color: Colors.white, size: 22),
                              Positioned(
                                top: 9,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF5C0A1A),
                                        width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Stats row ──
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.directions_car_rounded,
                          label: 'Trips Taken',
                          value: '24',
                          iconColor: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.star_rounded,
                          label: 'My Rating',
                          value: '4.8',
                          iconColor: const Color(0xFFFFD700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════
          //  SEARCH RIDES BUTTON (overlapping card)
          // ═══════════════════════════════════════════════════════
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 6,
                shadowColor: AppStyles.primaryColor.withValues(alpha: 0.2),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan your trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location inputs
                      Container(
                        decoration: BoxDecoration(
                          color: AppStyles.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Choose from map',
                                hintStyle: TextStyle(
                                  color: AppStyles.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.map_outlined,
                                  color: AppStyles.primaryColor,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            Divider(height: 1, indent: 48),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Destination (Amman)',
                                hintStyle:
                                    TextStyle(color: AppStyles.textTertiary),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: AppStyles.primaryColor,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date and passenger inputs
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppStyles.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(width: 12),
                                  Icon(Icons.calendar_today,
                                      color: AppStyles.textTertiary, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      color: AppStyles.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppStyles.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(width: 12),
                                  Icon(Icons.person_outline,
                                      color: AppStyles.textTertiary, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    '1 passenger',
                                    style: TextStyle(
                                      color: AppStyles.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RideResultsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search, size: 20),
                          label: const Text(
                            'Search Rides',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Recommended for you
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RideResultsScreen()),
                    );
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ride Cards
          _buildRideCard(
            context: context,
            driverName: 'Ahmad M.',
            route: 'Amman → Irbid',
            departure: 'Departure: 04:00 PM',
            rating: '4.9 (124 reviews)',
            price: '12.00 JOD',
          ),
          _buildRideCard(
            context: context,
            driverName: 'Khaled S.',
            route: 'Amman → Aqaba',
            departure: 'Departure: 05:15 PM',
            rating: '4.8 (89 reviews)',
            price: '15.50 JOD',
          ),
          _buildRideCard(
            context: context,
            driverName: 'Tariq A.',
            route: 'Irbid → Zarqa',
            departure: 'Departure: 06:00 PM',
            rating: '4.7 (218 reviews)',
            price: '9.00 JOD',
          ),

          const SizedBox(height: 24),

          // Quick Destinations
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Quick Destinations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppStyles.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDestinationCard(context, 'Amman'),
                _buildDestinationCard(context, 'Aqaba'),
                _buildDestinationCard(context, 'Irbid'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard({
    required BuildContext context,
    required String driverName,
    required String route,
    required String departure,
    required String rating,
    required String price,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RideResultsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppStyles.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppStyles.cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car, color: AppStyles.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppStyles.highlightBackgroundColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          route,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    departure,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppStyles.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppStyles.starRatingColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppStyles.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppStyles.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, String city) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RideResultsScreen()),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppStyles.highlightBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/${city.toLowerCase()}_city.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x88000000)],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Text(
                city,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
