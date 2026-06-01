import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/driver/driver_home_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/theme/app_styles.dart';

class DriverVerificationStatusScreen extends StatelessWidget {
  const DriverVerificationStatusScreen({super.key});

  static const Color _primaryColor = Color(0xFF8B1A2B);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<app_auth.AuthProvider>().currentUser;
    final verificationStatus = user?.verificationStatus;

    String idStatusLabel;
    IconData idStatusIcon;
    Color idStatusColor;
    switch (verificationStatus) {
      case VerificationStatus.verified:
        idStatusLabel = context.l10n.statusVerified;
        idStatusIcon = Icons.check_circle;
        idStatusColor = const Color(0xFF4CAF50);
        break;
      case VerificationStatus.rejected:
        idStatusLabel = context.l10n.statusRejected;
        idStatusIcon = Icons.cancel;
        idStatusColor = const Color(0xFFE53935);
        break;
      case VerificationStatus.pending:
        idStatusLabel = context.l10n.pendingReview;
        idStatusIcon = Icons.access_time_filled;
        idStatusColor = const Color(0xFFFF9800);
        break;
      default:
        idStatusLabel = context.l10n.notSubmitted;
        idStatusIcon = Icons.radio_button_unchecked;
        idStatusColor = const Color(0xFF9E9E9E);
    }

    final carUploaded = (user?.carFrontUrl ?? '').isNotEmpty &&
        (user?.carBackUrl ?? '').isNotEmpty;
    final vehicleStatusLabel =
        carUploaded ? idStatusLabel : context.l10n.notSubmitted;
    final vehicleStatusIcon =
        carUploaded ? idStatusIcon : Icons.radio_button_unchecked;
    final vehicleStatusColor =
        carUploaded ? idStatusColor : const Color(0xFF9E9E9E);

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.verificationStatus,
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
                child: const Center(
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: _primaryColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                context.l10n.identityVerification,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                context.l10n.verificationDocsBeingReviewed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Status Cards
              _buildStatusCard(
                context: context,
                icon: Icons.badge_outlined,
                title: context.l10n.idVerification,
                status: idStatusLabel,
                statusIcon: idStatusIcon,
                statusColor: idStatusColor,
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                context: context,
                icon: Icons.directions_car_outlined,
                title: context.l10n.vehicleInspection,
                status: vehicleStatusLabel,
                statusIcon: vehicleStatusIcon,
                statusColor: vehicleStatusColor,
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
                    backgroundColor: context.colors.cardBackgroundColor,
                    foregroundColor: context.colors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.goToDashboard,
                    style: const TextStyle(
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
                    foregroundColor: _primaryColor,
                    side: const BorderSide(color: _primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.contactSupport,
                    style: const TextStyle(
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

  Widget _buildStatusCard({
    required BuildContext context,
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
              color: _primaryColor,
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


