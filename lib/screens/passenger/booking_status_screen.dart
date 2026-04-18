import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/passenger/cancel_trip_screen.dart';

class BookingStatusScreen extends StatelessWidget {
  const BookingStatusScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Booking Status',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppStyles.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppStyles.onPrimary,
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Success Text
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your ride has been confirmed. You can\ntrack its status at My Trips.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Map Snapshot Placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: AppStyles.successLightBg,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: AppStyles.successColor.withValues(alpha: 0.5)),
                      // Mocking a route line and pins
                      Positioned(
                        bottom: 40,
                        left: 80,
                        child: Icon(Icons.location_on, color: AppStyles.primaryColor, size: 24),
                      ),
                      Positioned(
                        top: 40,
                        right: 80,
                        child: Icon(Icons.location_city, color: AppStyles.primaryColor, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Trip Details Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRIP DETAILS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textTertiary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: AppStyles.primaryColor, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Toyota Camry - White\nPlate: 40-1234',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Icon(Icons.event_seat, color: AppStyles.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Seats: 1 Seat',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.highlightBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '15.00 JOD',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppStyles.primaryColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

               // Cancel Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CancelTripScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppStyles.primaryColor,
                    side: BorderSide(color: AppStyles.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel Ride',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          border: Border(top: BorderSide(color: context.colors.borderColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.surfaceColor,
          selectedItemColor: AppStyles.primaryColor,
          unselectedItemColor: context.colors.textTertiary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'MY TRIPS',
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
      ),
    );
  }
}


