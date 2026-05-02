import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/ride_provider.dart';
import '../../models/ride_model.dart';
import 'package:testtale3/screens/driver/driver_create_ride_screen.dart';
import 'package:testtale3/screens/driver/driver_profile_screen.dart';
import 'package:testtale3/screens/driver/driver_ride_details_screen.dart';
import 'package:testtale3/screens/driver/pickup_schedule_screen.dart';
import 'package:testtale3/screens/driver/driver_chat_screen.dart';
import 'package:testtale3/screens/community_guidelines_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<app_auth.AuthProvider>().addListener(_checkIfBlocked);
    });
  }

  @override
  void dispose() {
    context.read<app_auth.AuthProvider>().removeListener(_checkIfBlocked);
    super.dispose();
  }

  void _checkIfBlocked() {
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isLoggedIn && auth.wasBlocked) {
      auth.clearBlockedFlag();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.block_rounded, color: Colors.red, size: 26),
              SizedBox(width: 10),
              Text(
                'Account Blocked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your account has been blocked by the admin. '
            'If you believe this is a mistake, please contact '
            'support at support@tale3.app.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const CommunityGuidelinesScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      body: IndexedStack(
        index: navProvider.driverTabIndex,
        children: const [
          _DriverHomeTab(),
          PickupScheduleScreen(),
          DriverChatScreen(),
          DriverProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navProvider.driverTabIndex,
        onTap: (index) {
          context.read<NavigationProvider>().setDriverTab(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.l10n.home.toUpperCase(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_car_outlined),
            activeIcon: const Icon(Icons.directions_car),
            label: context.l10n.myRides.toUpperCase(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble),
            label: context.l10n.chat.toUpperCase(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.l10n.profile.toUpperCase(),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppStyles.primaryColor,
                  AppStyles.darkMaroon,
                  AppStyles.gradientDeepColor,
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
                                color: AppStyles.onPrimary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOOD ${_getGreeting(context).toUpperCase()}',
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
                                  color: AppStyles.onPrimary,
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
                                  color: AppStyles.onPrimary, size: 22),
                              Positioned(
                                top: 9,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppStyles.notificationDot,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppStyles.darkMaroon,
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
                          label: context.l10n.earnings,
                          value: '\$142.50',
                          iconColor: AppStyles.successColor,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.star_rounded,
                          label: context.l10n.reviews,
                          value: '4.9',
                          iconColor: AppStyles.goldStar,
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
                        colors: [AppStyles.primaryColor, AppStyles.darkMaroon],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded,
                            color: AppStyles.onPrimary, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.createNewRide,
                          style: const TextStyle(
                            color: AppStyles.onPrimary,
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
          //  RECENT RIDES (live from Firestore)
          // ═══════════════════════════════════════════════════════
          StreamBuilder<List<RideModel>>(
            stream: context.read<RideProvider>().myRidesStream,
            builder: (context, snapshot) {
              final rides = snapshot.data ?? [];
              final activeRide = rides.isNotEmpty ? rides.first : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              context.l10n.activeRide,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: context.colors.textPrimary),
                            ),
                            if (activeRide != null) ...[
                              const SizedBox(width: 8),
                              const _LiveDot(),
                            ],
                          ],
                        ),
                        if (activeRide != null)
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DriverRideDetailsScreen(ride: activeRide),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.highlightBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${context.l10n.details} →',
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
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (activeRide == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: context.colors.borderColor
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.directions_car_outlined,
                                size: 40,
                                color: context.colors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.noActiveRide,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildActiveRideCard(context, activeRide),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.goodMorning;
    if (hour < 17) return context.l10n.goodAfternoon;
    return context.l10n.goodEvening;
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
                  color: AppStyles.onPrimary,
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
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    context.l10n.myReviews,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.colors.highlightBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppStyles.goldStar, size: 16),
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
                style: TextStyle(
                    fontSize: 13, color: context.colors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 28),
                itemBuilder: (_, i) {
                  final r = reviews[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                context.colors.highlightBackgroundColor,
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  r.date,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (si) {
                              return Icon(
                                si < r.rating.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: AppStyles.goldStar,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        r.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: context.colors.textSecondary,
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

  Widget _buildActiveRideCard(BuildContext context, RideModel ride) {
    final bookedCount = ride.bookedSeats;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: context.colors.borderColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            color:
                                AppStyles.primaryColor.withValues(alpha: 0.3),
                            width: 3),
                      ),
                    ),
                    Container(
                        width: 2,
                        height: 28,
                        color: context.colors.borderColor),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
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
                      ride.origin,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: context.colors.textPrimary),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      ride.destination,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: context.colors.textPrimary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.highlightBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${ride.pricePerSeat} JOD',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _infoChip(context, Icons.calendar_today_rounded,
                  '${ride.date}  ·  ${ride.time}'),
              const SizedBox(width: 8),
              _infoChip(
                  context,
                  Icons.airline_seat_recline_normal_rounded,
                  '${ride.bookedSeats} / ${ride.totalSeats} ${context.l10n.seats}'),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          Row(
            children: [
              if (bookedCount > 0)
                SizedBox(
                  width: (bookedCount.clamp(1, 3) * 20 + 12).toDouble(),
                  height: 32,
                  child: Stack(
                    children: List.generate(
                      bookedCount.clamp(1, 3),
                      (i) => _stackedAvatar(context, i * 20.0, '${i + 1}'),
                    ),
                  ),
                )
              else
                Icon(Icons.person_outline,
                    size: 24, color: context.colors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$bookedCount ${context.l10n.passengers}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppStyles.successLightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppStyles.successColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.onTrack,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.successDarkText,
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

  static Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: context.colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: context.colors.textTertiary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Positioned _stackedAvatar(
      BuildContext context, double left, String letter) {
    return Positioned(
      left: left,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.surfaceColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: context.colors.highlightBackgroundColor,
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
          color: AppStyles.successColor,
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