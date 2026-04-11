import 'package:flutter/material.dart';
import '../../theme/app_styles.dart';

class PickupScheduleScreen extends StatefulWidget {
  const PickupScheduleScreen({super.key});

  @override
  State<PickupScheduleScreen> createState() => _PickupScheduleScreenState();
}

class _PickupScheduleScreenState extends State<PickupScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 0),
          child: const Row(
            children: [
              Text(
                'My Rides',
                style: TextStyle(
                  color: AppStyles.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        // ── Tab bar ──
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppStyles.primaryColor,
            unselectedLabelColor: AppStyles.textTertiary,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: AppStyles.primaryColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppStyles.borderColor,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),

        // ── Tab content ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _UpcomingRidesTab(),
              _CompletedRidesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  UPCOMING RIDES TAB
// ─────────────────────────────────────────────────────────────────────────────
class _UpcomingRidesTab extends StatelessWidget {
  const _UpcomingRidesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildRideCard(
          from: 'Amman, University St.',
          to: 'Irbid, Yarmouk University',
          date: 'Today, 2:30 PM',
          price: '12.00 JOD',
          seats: '3 / 4',
          status: 'active',
        ),
        _buildRideCard(
          from: 'Amman, 7th Circle',
          to: 'Zarqa, New City',
          date: 'Tomorrow, 8:00 AM',
          price: '8.50 JOD',
          seats: '1 / 4',
          status: 'upcoming',
        ),
        _buildRideCard(
          from: 'Irbid, City Center',
          to: 'Amman, Abdali',
          date: 'Wed, 6:00 PM',
          price: '12.00 JOD',
          seats: '0 / 4',
          status: 'upcoming',
        ),
      ],
    );
  }

  static Widget _buildRideCard({
    required String from,
    required String to,
    required String date,
    required String price,
    required String seats,
    required String status,
  }) {
    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppStyles.primaryColor.withValues(alpha: 0.3)
              : AppStyles.borderColor.withValues(alpha: 0.5),
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppStyles.primaryColor.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Status badge row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.circle
                          : Icons.schedule_rounded,
                      size: 8,
                      color: isActive
                          ? const Color(0xFF4CAF50)
                          : AppStyles.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isActive ? 'Active Now' : 'Scheduled',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF2E7D32)
                            : AppStyles.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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

          const SizedBox(height: 14),

          // Route timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dots + line
              Padding(
                padding: const EdgeInsets.only(top: 3),
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
                          width: 3,
                        ),
                      ),
                    ),
                    Container(
                        width: 2,
                        height: 22,
                        color: AppStyles.borderColor),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      from,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppStyles.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      to,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppStyles.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Bottom info row
          Row(
            children: [
              _infoTag(Icons.access_time_rounded, date),
              const SizedBox(width: 10),
              _infoTag(Icons.airline_seat_recline_normal_rounded, '$seats seats'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _infoTag(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppStyles.textTertiary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppStyles.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPLETED RIDES TAB
// ─────────────────────────────────────────────────────────────────────────────
class _CompletedRidesTab extends StatelessWidget {
  const _CompletedRidesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildCompletedCard(
          from: 'Amman',
          to: 'Irbid',
          date: 'Today, 9:30 AM',
          price: '12.00 JOD',
          passengers: 3,
          rating: 4.9,
        ),
        _buildCompletedCard(
          from: 'Zarqa',
          to: 'Amman',
          date: 'Yesterday, 4:15 PM',
          price: '8.50 JOD',
          passengers: 2,
          rating: 5.0,
        ),
        _buildCompletedCard(
          from: 'Amman',
          to: 'Aqaba',
          date: 'Mon, 7:00 AM',
          price: '25.00 JOD',
          passengers: 4,
          rating: 4.8,
        ),
        _buildCompletedCard(
          from: 'Irbid',
          to: 'Amman',
          date: 'Sun, 3:00 PM',
          price: '12.00 JOD',
          passengers: 3,
          rating: 4.7,
        ),
        _buildCompletedCard(
          from: 'Amman',
          to: 'Madaba',
          date: 'Sat, 10:00 AM',
          price: '6.00 JOD',
          passengers: 1,
          rating: 5.0,
        ),
      ],
    );
  }

  static Widget _buildCompletedCard({
    required String from,
    required String to,
    required String date,
    required String price,
    required int passengers,
    required double rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyles.borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Top: route + price
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route_rounded,
                    color: AppStyles.primaryColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$from → $to',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppStyles.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Bottom: stats row
          Row(
            children: [
              // Completed badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 12, color: Color(0xFF4CAF50)),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Passengers
              const Icon(Icons.person_outline,
                  size: 14, color: AppStyles.textTertiary),
              const SizedBox(width: 4),
              Text(
                '$passengers',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppStyles.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              // Rating
              const Icon(Icons.star_rounded,
                  size: 14, color: AppStyles.starRatingColor),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppStyles.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
