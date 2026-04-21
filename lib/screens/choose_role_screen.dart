import 'package:flutter/material.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/screens/driver/driver_registration_screen.dart';
import 'package:testtale3/screens/passenger/passenger_registration_screen.dart';
import 'package:testtale3/screens/passenger/passenger_login_screen.dart';
import 'package:testtale3/screens/driver/driver_login_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  final bool isLogin;
  const ChooseRoleScreen({super.key, this.isLogin = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.height < 680;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: isSmall ? 4 : 8),

              // ── Logo ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppStyles.onPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.appName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // ── Heading ─────────────────────────────────────────────
              Text(
                isLogin ? l10n.loginTitle : l10n.chooseRole,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmall ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isLogin ? l10n.loginSubtitle : l10n.chooseRoleSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // ── Role cards ──────────────────────────────────────────
              _buildRoleCard(
                context: context,
                icon: Icons.person_outline,
                title: l10n.passenger,
                description: l10n.passengerDesc,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => isLogin
                      ? const PassengerLoginScreen()
                      : const PassengerRegistrationScreen(),
                )),
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                context: context,
                icon: Icons.directions_car_outlined,
                title: l10n.driver,
                description: l10n.driverDesc,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => isLogin
                      ? const DriverLoginScreen()
                      : const DriverRegistrationScreen(),
                )),
              ),

              const Spacer(flex: 3),
              SizedBox(height: isSmall ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.highlightBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.roleBorderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppStyles.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
