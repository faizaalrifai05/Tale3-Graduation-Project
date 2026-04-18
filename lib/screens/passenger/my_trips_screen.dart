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
            color: context.colors.surfaceColor,
            padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Trips',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  labelColor: AppStyles.primaryColor,
                  unselectedLabelColor: context.colors.textTertiary,
                  indicatorColor: AppStyles.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
                    _buildActiveTripCard(context),
                    const SizedBox(height: 16),
                    _buildUpcomingTripCard(context, 'Tomorrow • 08:30 AM', 'Amman → Irbid', '15.00 JOD'),
                  ],
                ),
                // PAST TAB
                Center(
                  child: Text('No past trips yet.', style: TextStyle(color: context.colors.textSecondary)),
                ),
                // CANCELED TAB
                Center(
                  child: Text('No canceled trips.', style: TextStyle(color: context.colors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripCard(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: context.colors.neutralLight,
            child: Center(
              child: Icon(Icons.map, color: AppStyles.primaryColor.withValues(alpha: 0.4), size: 48),
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
                        color: context.colors.highlightBackgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ACTIVE TRIP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                    Text(
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
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppStyles.primaryColor, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amman, Jordan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_city, color: context.colors.textTertiary, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Irbid, Jordan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: context.colors.cardBackgroundColor,
                      child: Icon(Icons.person, color: AppStyles.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hassan Abdullah',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: AppStyles.starRatingColor, size: 12),
                              const SizedBox(width: 4),
                              Text('4.9', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: context.colors.cardBackgroundColor, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.chat_bubble_outline, color: AppStyles.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: context.colors.cardBackgroundColor, borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.phone, color: AppStyles.primaryColor, size: 20),
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

  Widget _buildUpcomingTripCard(BuildContext context, String time, String route, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
              Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppStyles.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(route, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
        ],
      ),
    );
  }
}


