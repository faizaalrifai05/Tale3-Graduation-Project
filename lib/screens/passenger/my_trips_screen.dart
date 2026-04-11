import 'package:flutter/material.dart';
import '../../theme/app_styles.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // AppBar-style header
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
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'UPCOMING'),
                    Tab(text: 'PAST'),
                    Tab(text: 'CANCELED'),
                  ],
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                // UPCOMING TAB
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildActiveTripCard(),
                    const SizedBox(height: 16),
                    _buildUpcomingTripCard('Tomorrow • 08:30 AM', 'Amman → Irbid', '15.00 JOD'),
                  ],
                ),
                // PAST TAB
                const Center(
                  child: Text('No past trips yet.', style: TextStyle(color: AppStyles.textSecondary)),
                ),
                // CANCELED TAB
                const Center(
                  child: Text('No canceled trips.', style: TextStyle(color: AppStyles.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripCard() {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: const Color(0xFFE0F7FA),
            child: const Center(
              child: Icon(Icons.map, color: Colors.blueAccent, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppStyles.highlightBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ACTIVE TRIP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                    const Text(
                      '12.50 JOD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.location_on, color: AppStyles.primaryColor, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amman, Jordan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppStyles.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.location_city, color: AppStyles.textTertiary, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Irbid, Jordan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppStyles.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppStyles.cardBackgroundColor,
                      child: Icon(Icons.person, color: AppStyles.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hassan Abdullah',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppStyles.textPrimary),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppStyles.starRatingColor, size: 12),
                              const SizedBox(width: 4),
                              const Text('4.9', style: TextStyle(fontSize: 12, color: AppStyles.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppStyles.cardBackgroundColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chat_bubble_outline, color: AppStyles.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppStyles.cardBackgroundColor, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.phone, color: AppStyles.primaryColor, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTripCard(String time, String route, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyles.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppStyles.textSecondary)),
              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppStyles.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(route, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppStyles.textPrimary)),
        ],
      ),
    );
  }
}


