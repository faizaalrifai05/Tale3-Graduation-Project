import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import 'booking_status_screen.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Trips',
                  style: TextStyle(
                    color: AppStyles.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  labelColor: AppStyles.primaryColor,
                  unselectedLabelColor: AppStyles.textTertiary,
                  indicatorColor: AppStyles.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'UPCOMING'),
                    Tab(text: 'PAST'),
                    Tab(text: 'CANCELED'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: context.read<BookingProvider>().myBookingsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                final upcoming =
                    all.where((b) => b.status == 'confirmed').toList();
                final cancelled =
                    all.where((b) => b.status == 'cancelled').toList();

                return TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _BookingList(
                      bookings: upcoming,
                      emptyMessage: 'No upcoming trips.',
                    ),
                    const Center(
                      child: Text('No past trips yet.',
                          style: TextStyle(color: AppStyles.textSecondary)),
                    ),
                    _BookingList(
                      bookings: cancelled,
                      emptyMessage: 'No cancelled trips.',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
            style: const TextStyle(color: AppStyles.textSecondary)),
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
    final isCancelled = booking.status == 'cancelled';

    return GestureDetector(
      onTap: isCancelled
          ? null
          : () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BookingStatusScreen(booking: booking),
              ));
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppStyles.borderColor),
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
                    color: isCancelled
                        ? const Color(0xFFF5F5F5)
                        : AppStyles.highlightBackgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isCancelled ? 'CANCELLED' : 'CONFIRMED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isCancelled
                          ? AppStyles.textTertiary
                          : AppStyles.primaryColor,
                    ),
                  ),
                ),
                Text(
                  '${booking.totalPrice} JOD',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isCancelled
                        ? AppStyles.textTertiary
                        : AppStyles.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${booking.origin} → ${booking.destination}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppStyles.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.date}  •  ${booking.time}',
              style: const TextStyle(
                  fontSize: 12, color: AppStyles.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}  •  ${booking.driverName}',
              style: const TextStyle(
                  fontSize: 12, color: AppStyles.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
