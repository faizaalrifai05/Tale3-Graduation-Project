import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/driver/driver_home_screen.dart';

class DriverVerificationStatusScreen extends StatelessWidget {
  const DriverVerificationStatusScreen({super.key});

  

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
          'Verification Status',
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
              // Central Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colors.highlightBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: AppStyles.primaryColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Identity Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'Your documents are being reviewed.\nNotifications will be sent to your app\nand email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Status Cards
              _buildStatusCard(context,
                icon: Icons.security,
                title: 'Background Check',
                status: 'Active',
                statusIcon: Icons.check_circle,
                statusColor: AppStyles.successColor,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(context,
                icon: Icons.badge_outlined,
                title: 'ID Verification',
                status: 'Pending Review',
                statusIcon: Icons.access_time_filled,
                statusColor: AppStyles.pendingColor,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(context,
                icon: Icons.directions_car_outlined,
                title: 'Vehicle Inspection',
                status: 'Pending Review',
                statusIcon: Icons.access_time_filled,
                statusColor: AppStyles.pendingColor,
              ),
              const SizedBox(height: 48),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Dashboard. We can pop back to root or push replacement.
                    // Assuming returning to home or dashboard.
                    //Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => DriverHomeScreen()),
);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.neutralLight,
                    foregroundColor: context.colors.textPrimary,
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
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Handle contact support
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppStyles.primaryColor,
                    side: BorderSide(color: AppStyles.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String status,
    required IconData statusIcon,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        border: Border.all(color: context.colors.borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.highlightBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppStyles.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}


