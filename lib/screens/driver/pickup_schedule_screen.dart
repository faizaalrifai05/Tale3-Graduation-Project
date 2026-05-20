import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/screens/driver/driver_ride_details_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class PickupScheduleScreen extends StatefulWidget {
  const PickupScheduleScreen({super.key});

  @override
  State<PickupScheduleScreen> createState() => _PickupScheduleScreenState();
}

class _PickupScheduleScreenState extends State<PickupScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<RideModel>> _stream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _stream = context.read<RideProvider>().myRidesStream;
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
          color: context.colors.surfaceColor,
          padding:
              const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 0),
          child: Row(
            children: [
              Text(
                context.l10n.myRides,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        // ── Tab bar ──
        Container(
          color: context.colors.surfaceColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppStyles.primaryColor,
            unselectedLabelColor: context.colors.textTertiary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: AppStyles.primaryColor,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: context.colors.borderColor,
            tabs: [
              Tab(text: context.l10n.active.toUpperCase()),
              Tab(text: context.l10n.completed.toUpperCase()),
              Tab(text: context.l10n.cancelled.toUpperCase()),
            ],
          ),
        ),

        // ── Tab content ──
        Expanded(
          child: StreamBuilder<List<RideModel>>(
            stream: _stream,
            initialData: context.read<RideProvider>().lastMyRides,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  (snapshot.data == null || snapshot.data!.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snapshot.data ?? [];
              final active = all
                  .where((r) => r.status == 'active' || r.status == 'live')
                  .toList();
              final completed =
                  all.where((r) => r.status == 'completed').toList();
              final cancelled =
                  all.where((r) => r.status == 'cancelled').toList();
              return TabBarView(
                controller: _tabController,
                children: [
                  _RideList(rides: active, emptyKey: 'active'),
                  _RideList(rides: completed, emptyKey: 'completed'),
                  _RideList(rides: cancelled, emptyKey: 'cancelled'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RIDE LIST (shared by both tabs)
// ─────────────────────────────────────────────────────────────────────────────
class _RideList extends StatelessWidget {
  final List<RideModel> rides;
  final String emptyKey;
  const _RideList({required this.rides, required this.emptyKey});

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      final msg = emptyKey == 'completed'
          ? context.l10n.noPastTrips
          : emptyKey == 'cancelled'
              ? context.l10n.noCancelledTrips
              : context.l10n.noUpcomingTrips;
      return Center(
        child: Text(msg, style: TextStyle(color: context.colors.textSecondary)),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: rides.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _RideCard(ride: rides[i]),
    );
  }
}

class _RideCard extends StatelessWidget {
  final RideModel ride;
  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isCancelled = ride.status == 'cancelled';

    Color badgeColor;
    Color badgeTextColor;
    IconData badgeIcon;
    String badgeLabel;

    final isCompleted = ride.status == 'completed';

    if (isCancelled) {
      badgeColor = const Color(0xFFFFEBEE);
      badgeTextColor = Colors.red;
      badgeIcon = Icons.cancel_outlined;
      badgeLabel = context.l10n.cancelled;
    } else if (isCompleted) {
      badgeColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
      badgeIcon = Icons.check_circle_outline;
      badgeLabel = 'Completed';
    } else {
      badgeColor = AppStyles.successLightBg;
      badgeTextColor = AppStyles.successDarkText;
      badgeIcon = Icons.circle;
      badgeLabel = context.l10n.activeNow;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => DriverRideDetailsScreen(ride: ride)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCancelled
                ? Colors.red.withValues(alpha: 0.2)
                : context.colors.borderColor.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 8, color: badgeTextColor),
                      const SizedBox(width: 5),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${ride.pricePerSeat} JOD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isCancelled
                        ? context.colors.textTertiary
                        : AppStyles.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            color: AppStyles.primaryColor.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                      ),
                      Container(width: 2, height: 22, color: context.colors.borderColor),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppStyles.successColor,
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
                      Text(ride.origin,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary)),
                      const SizedBox(height: 18),
                      Text(ride.destination,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoTag(context, Icons.access_time_rounded,
                    '${ride.date}  ${ride.time}'),
                const SizedBox(width: 10),
                _infoTag(
                    context,
                    Icons.airline_seat_recline_normal_rounded,
                    '${ride.availableSeats} / ${ride.totalSeats} seats'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoTag(BuildContext context, IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: context.colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: context.colors.textTertiary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 11,
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
}
