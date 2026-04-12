import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/driver/driver_create_ride_screen.dart';
import 'package:testtale3/screens/driver/driver_profile_screen.dart';
import 'package:testtale3/screens/driver/driver_ride_details_screen.dart';
import 'package:testtale3/screens/driver/pickup_schedule_screen.dart';
import 'package:testtale3/screens/chat_screen.dart';

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
          ChatScreen(),
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

class _DriverHomeTab extends StatelessWidget {
  const _DriverHomeTab();

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
                    // Top row: avatar + greeting + notification
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
                                'Capt. ${context.watch<app_auth.AuthProvider>().userName}',
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
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Earnings',
                          value: '\$142.50',
                          iconColor: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.star_rounded,
                          label: 'Reviews',
                          value: '4.9',
                          iconColor: const Color(0xFFFFD700),
                          onTap: () => _showReviewsSheet(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════
          //  CREATE RIDE BUTTON (overlapping card)
          // ═══════════════════════════════════════════════════════
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                shadowColor: AppStyles.primaryColor.withValues(alpha: 0.3),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DriverCreateRideScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B1A2B), Color(0xFF5C0A1A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Create New Ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),



          // ═══════════════════════════════════════════════════════
          //  CURRENT ACTIVE RIDE
          // ═══════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      'Active Ride',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppStyles.textPrimary),
                    ),
                    SizedBox(width: 8),
                    _LiveDot(),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const DriverRideDetailsScreen()),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppStyles.highlightBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Details →',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppStyles.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildActiveRideCard(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  static Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
      ),
    );
  }

  static void _showReviewsSheet(BuildContext context) {
    final reviews = [
      _Review(name: 'Hassan A.', rating: 5.0, date: 'Today', text: 'Great driver, very punctual and friendly. The car was clean and the ride was smooth.'),
      _Review(name: 'Sarah T.', rating: 5.0, date: 'Yesterday', text: 'Very comfortable ride. Arrived right on time!'),
      _Review(name: 'Ali H.', rating: 4.0, date: '2 days ago', text: 'Good ride overall. Would ride again.'),
      _Review(name: 'Lina K.', rating: 5.0, date: 'Last week', text: 'Best carpooling experience I\'ve had. Super reliable!'),
      _Review(name: 'Omar S.', rating: 5.0, date: 'Last week', text: 'Always on time and very professional driver.'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppStyles.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'My Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppStyles.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppStyles.highlightBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 14,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${reviews.length} reviews from passengers',
                style: const TextStyle(fontSize: 13, color: AppStyles.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Review list
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const Divider(height: 28),
                itemBuilder: (_, i) {
                  final r = reviews[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppStyles.highlightBackgroundColor,
                            child: Text(
                              r.name[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppStyles.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppStyles.textPrimary,
                                  ),
                                ),
                                Text(
                                  r.date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppStyles.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Stars
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (si) {
                              return Icon(
                                si < r.rating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFFFD700),
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        r.text,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppStyles.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppStyles.borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Route timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dots
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppStyles.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppStyles.primaryColor.withValues(alpha: 0.3),
                            width: 3),
                      ),
                    ),
                    Container(
                        width: 2, height: 28, color: AppStyles.borderColor),
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
              // Route text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amman, University St.',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppStyles.textPrimary),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Irbid, Yarmouk University',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppStyles.textPrimary),
                    ),
                  ],
                ),
              ),
              // Price tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppStyles.highlightBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '12 JOD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info chips
          Row(
            children: [
              _infoChip(Icons.access_time_rounded, 'Today, 2:30 PM'),
              const SizedBox(width: 8),
              _infoChip(Icons.airline_seat_recline_normal_rounded, '3 / 4 seats'),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Passenger row
          Row(
            children: [
              // Stacked avatars
              SizedBox(
                width: 60,
                height: 32,
                child: Stack(
                  children: [
                    _stackedAvatar(0, 'H'),
                    _stackedAvatar(20, 'S'),
                    _stackedAvatar(40, 'A'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '3 passengers booked',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppStyles.textSecondary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'On Track',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _infoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppStyles.textTertiary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppStyles.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Positioned _stackedAvatar(double left, String letter) {
    return Positioned(
      left: left,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: AppStyles.highlightBackgroundColor,
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppStyles.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

}


// ── Animated live dot ───────────────────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Review data class ───────────────────────────────────────────────────────
class _Review {
  final String name;
  final double rating;
  final String date;
  final String text;

  const _Review({
    required this.name,
    required this.rating,
    required this.date,
    required this.text,
  });
}
