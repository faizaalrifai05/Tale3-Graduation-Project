import 'package:flutter/services.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/passenger/passenger_chat_screen.dart';
import 'package:testtale3/screens/passenger/select_seat_screen.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  void _showShareSheet(BuildContext context) {
    const shareText =
        'Check out this ride on Tale3!\n🚗 From → To • Today at 14:30\nBook now on Tale3 — the trusted carpool app.';
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: ctx.colors.borderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ctx.colors.textPrimary)),
            const SizedBox(height: 8),
            Text(shareText, style: TextStyle(fontSize: 14, color: ctx.colors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Ride Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: shareText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Ride details copied to clipboard'),
                    backgroundColor: AppStyles.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.darkMaroon,
                  foregroundColor: AppStyles.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: context.colors.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Ride Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: context.colors.highlightBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share, color: AppStyles.primaryColor, size: 18),
                      onPressed: () => _showShareSheet(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Driver Card
                    Container(
                      color: context.colors.surfaceColor,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PassengerChatScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: context.colors.borderColor,
                              child: Icon(Icons.person, color: AppStyles.onPrimary, size: 40),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Ahmed Al-Masri',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppStyles.starRatingLightBg,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, color: AppStyles.starRatingColor, size: 12),
                                          SizedBox(width: 2),
                                          Text(
                                            '4.8',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppStyles.starRatingDarkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kia Sportage • 40-1234',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: AppStyles.primaryColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'VERIFIED DRIVER',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppStyles.primaryColor,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Map Section
                    Container(
                      color: context.colors.surfaceColor,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: Stack(
                                children: [
                                  // Placeholder map image
                                  Container(
                                    color: context.colors.neutralLight,
                                    child: Center(
                                      child: Icon(Icons.map, size: 64, color: AppStyles.primaryColor.withValues(alpha: 0.4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: context.colors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.location_on, color: AppStyles.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ROUTE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textTertiary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Irbid → Amman',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'EST. TIME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textTertiary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '1h 15m',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Time, Seats, Price Cards
                          Row(
                            children: [
                              _buildInfoCard(context, Icons.access_time, 'DEPARTURE (EST)', '14:00'),
                              const SizedBox(width: 12),
                              _buildInfoCard(context, Icons.event_seat, 'SEATS LEFT', '3'),
                              const SizedBox(width: 12),
                              _buildInfoCard(context, Icons.payments_outlined, 'PRICE', '5 JOD', isPrice: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rules and Features
                    Container(
                      color: context.colors.surfaceColor,
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRIP RULES & FEATURES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textTertiary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRuleItem(context, Icons.smoke_free, 'No smoking allowed'),
                          _buildRuleItem(context, Icons.luggage, 'Luggage space available'),
                          _buildRuleItem(context, Icons.ac_unit, 'Air conditioning'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Booking Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_seat, color: AppStyles.primaryColor, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Select\nSeat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppStyles.primaryColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SelectSeatScreen()),
                        ),
                        icon: Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          'Request Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.darkMaroon,
                          foregroundColor: AppStyles.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, {bool isPrice = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.highlightBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppStyles.primaryColor, size: 20),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: context.colors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isPrice ? AppStyles.primaryColor : context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


