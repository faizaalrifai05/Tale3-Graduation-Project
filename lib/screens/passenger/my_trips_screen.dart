import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import 'booking_status_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<BookingModel>> _stream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _stream = context.read<BookingProvider>().myBookingsStream;
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
        Container(
          color: context.colors.surfaceColor,
          padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.myTrips,
                style: const TextStyle(
                  color: AppStyles.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                labelColor: AppStyles.primaryColor,
                unselectedLabelColor: AppStyles.textTertiary,
                indicatorColor: AppStyles.primaryColor,
                indicatorWeight: 3,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(text: context.l10n.pending.toUpperCase()),
                  Tab(text: context.l10n.upcoming.toUpperCase()),
                  Tab(text: context.l10n.past.toUpperCase()),
                  Tab(text: context.l10n.cancelled.toUpperCase()),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<BookingModel>>(
            stream: _stream,
            initialData: context.read<BookingProvider>().lastMyBookings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = snapshot.data ?? [];
              final today = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );

              DateTime? parseDate(String d) {
                try { return DateTime.parse(d); } catch (_) { return null; }
              }

              final pending = all.where((b) => b.status == 'pending').toList();

              final upcoming = all.where((b) {
                if (b.status != 'confirmed') return false;
                final d = parseDate(b.date);
                return d == null || !d.isBefore(today);
              }).toList();

              final past = all.where((b) {
                if (b.status == 'completed') return true;
                if (b.status != 'confirmed') return false;
                final d = parseDate(b.date);
                return d != null && d.isBefore(today);
              }).toList();

              final cancelled = all
                  .where((b) => b.status == 'cancelled' || b.status == 'rejected')
                  .toList();

              return TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _BookingList(bookings: pending, emptyMessage: context.l10n.noUpcomingTrips),
                  _BookingList(bookings: upcoming, emptyMessage: context.l10n.noUpcomingTrips),
                  _BookingList(bookings: past, emptyMessage: context.l10n.noPastTrips),
                  _BookingList(bookings: cancelled, emptyMessage: context.l10n.noCancelledTrips),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;

  const _BookingList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(emptyMessage,
            style: TextStyle(color: context.colors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _BookingCard(booking: bookings[index]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';
    final isCancelled = status == 'cancelled';
    final isCompleted = status == 'completed';
    final isDim = isCancelled || isRejected;

    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    if (isPending) {
      badgeBg = context.colors.starRatingLightBg;
      badgeText = context.colors.starRatingDarkText;
      badgeLabel = context.l10n.pending;
    } else if (isRejected) {
      badgeBg = context.colors.errorLightBg;
      badgeText = AppStyles.errorColor;
      badgeLabel = context.l10n.rejected;
    } else if (isCancelled) {
      badgeBg = context.colors.cardBackgroundColor;
      badgeText = context.colors.textTertiary;
      badgeLabel = context.l10n.cancelled;
    } else if (isCompleted) {
      badgeBg = context.colors.successLightBg;
      badgeText = AppStyles.successDarkText;
      badgeLabel = context.l10n.completed;
    } else {
      badgeBg = context.colors.highlightBackgroundColor;
      badgeText = AppStyles.primaryColor;
      badgeLabel = context.l10n.confirmed;
    }

    return GestureDetector(
      onTap: (isDim && !isCompleted)
          ? null
          : () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BookingStatusScreen(
                  booking: booking,
                  showLiveTracking: false,
                ),
              ));
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
                  ),
                ),
                Text(
                  '${booking.totalPrice} JOD',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDim ? context.colors.textTertiary : AppStyles.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${booking.origin} → ${booking.destination}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.date}  •  ${booking.time}',
              style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}  •  ${booking.driverName}',
              style: TextStyle(fontSize: 12, color: context.colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
