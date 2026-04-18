import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/passenger/passenger_home_screen.dart';

class PassengerVerificationSuccessScreen extends StatelessWidget {
  const PassengerVerificationSuccessScreen({super.key});

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Verification',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              
              // Animated style Success Graphic
              SizedBox(
                height: 180,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background concentric circles
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.highlightBackgroundColor.withValues(alpha: 0.5),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.highlightBackgroundColor,
                        ),
                      ),
                      // Top floating checkmark circle
                      Positioned(
                        top: 10,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppStyles.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: AppStyles.onPrimary, size: 28),
                        ),
                      ),
                      // Shield badge container below
                      Positioned(
                        bottom: 20,
                        child: Container(
                          width: 180,
                          height: 80,
                          decoration: BoxDecoration(
                            color: context.colors.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppStyles.onPrimary, width: 4),
                          ),
                          child: Center(
                            child: Icon(Icons.verified_user, color: AppStyles.primaryColor, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Title
              Text(
                'Verification\nSuccessful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Your email has been verified. You\ncan now use Tale3 to find and request a\nride. login', // "login" is present in the mockup string
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),

              // Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PassengerHomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: AppStyles.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Go to Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

