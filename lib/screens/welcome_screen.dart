import 'package:flutter/material.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/screens/choose_role_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Responsive breakpoints
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.height < 680;

    return Scaffold(
      backgroundColor: context.colors.surfaceColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: isSmall ? 12 : 20),

              // ── Top logo bar ─────────────────────────────────────────
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

              const Spacer(flex: 1),

              // ── Map illustration — responsive height ─────────────────
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.28, // max 28% of screen height
                  maxWidth: size.width * 0.85,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/jordan_map.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // ── Main heading ─────────────────────────────────────────
              Text(
                l10n.welcomeTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  // Scales down on very small phones
                  fontSize: isSmall ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  height: 1.25,
                ),
              ),
              SizedBox(height: isSmall ? 10 : 16),

              // ── Description ──────────────────────────────────────────
              Text(
                l10n.welcomeDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 1),

              // ── Register button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChooseRoleScreen(),
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
                  child: Text(
                    l10n.register,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Login button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChooseRoleScreen(isLogin: true),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppStyles.primaryColor,
                    side: const BorderSide(color: AppStyles.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.login,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmall ? 16 : 24),

              // ── Bottom badges ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge(context, Icons.verified_user_outlined, l10n.verifiedDrivers),
                  const SizedBox(width: 32),
                  _buildBadge(context, Icons.attach_money, l10n.affordablePricing),
                ],
              ),
              SizedBox(height: isSmall ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: context.colors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
