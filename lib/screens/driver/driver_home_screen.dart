import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../providers/navigation_provider.dart';
import 'package:testtale3/screens/driver/driver_create_ride_screen.dart';
import 'package:testtale3/screens/driver/driver_profile_screen.dart';
import 'package:testtale3/screens/driver/driver_ride_details_screen.dart';
import 'package:testtale3/screens/driver/pickup_schedule_screen.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the navigation provider to rebuild when the tab index changes.
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: IndexedStack(
        index: navProvider.driverTabIndex,
        children: const [
          _DriverHomeTab(),
          PickupScheduleScreen(),
          _WalletTab(),
          DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navProvider.driverTabIndex,
        onTap: (index) {
          // Use listen: false via context.read – we're inside a callback.
          context.read<NavigationProvider>().setDriverTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'MY RIDES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'WALLET',
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

class _DriverHomeTab extends StatelessWidget {
  const _DriverHomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WELCOME BACK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppStyles.textTertiary,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Capt. Ahmed',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppStyles.cardBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.notifications_none, color: AppStyles.textPrimary),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: AppStyles.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Earnings Card + Create Ride
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppStyles.borderColor),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet, size: 16, color: AppStyles.primaryColor),
                                SizedBox(width: 8),
                                Text(
                                  'Today\'s Earnings',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppStyles.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '\$142.50',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppStyles.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppStyles.highlightBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '8',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppStyles.primaryColor,
                                ),
                              ),
                              Text(
                                'Rides',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppStyles.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DriverCreateRideScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        'Create New Ride',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.darkMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Current Active Ride
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Active Ride',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppStyles.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DriverRideDetailsScreen()),
                    ),
                    child: const Text(
                      'View Details >',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppStyles.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildActiveRideCard(context),

            const SizedBox(height: 24),

            // Pending Requests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Requests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppStyles.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildPendingRequestCard('Sarah T.'),
            _buildPendingRequestCard('Ali H.'),

            const SizedBox(height: 24),

            // Completed Rides
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Completed Rides',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppStyles.textPrimary),
                  ),
                  const Text(
                    'View All',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppStyles.primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppStyles.borderColor),
              ),
              child: Column(
                children: [
                  _buildCompletedRideRow('Dubai Mall → Marina', '\$24.50'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildCompletedRideRow('Airport → Downtown', '\$35.00'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRideCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyles.borderColor),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: AppStyles.primaryColor, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Downtown Dubai → Dubai Marina',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppStyles.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.access_time, color: AppStyles.textTertiary, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Today, 14:30 PM (in 15 mins)',
                          style: TextStyle(fontSize: 12, color: AppStyles.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Text(
                '\$45.00',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppStyles.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hassan Abdullah',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppStyles.textPrimary),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.star, color: AppStyles.starRatingColor, size: 12),
                      SizedBox(width: 4),
                      Text('4.9', style: TextStyle(fontSize: 12, color: AppStyles.textSecondary)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: AppStyles.primaryColor, size: 20)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.phone, color: AppStyles.primaryColor, size: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyles.borderColor),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppStyles.highlightBackgroundColor,
            child: Icon(Icons.person, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppStyles.textPrimary)),
                const SizedBox(height: 4),
                const Text('Downtown → Airport', style: TextStyle(fontSize: 12, color: AppStyles.textSecondary)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFEEBEE), borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppStyles.darkMaroon, borderRadius: BorderRadius.circular(8)),
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.white, size: 20),
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedRideRow(String route, String price) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(route, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppStyles.textPrimary)),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppStyles.primaryColor)),
        ],
      ),
    );
  }
}

// ── Wallet Tab (stub) ─────────────────────────────────────────────────────────
class _WalletTab extends StatelessWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Wallet coming soon!',
          style: TextStyle(color: AppStyles.textSecondary, fontSize: 16),
        ),
      ),
    );
  }
}
