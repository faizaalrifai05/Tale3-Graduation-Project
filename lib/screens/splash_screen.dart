import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/providers/settings_provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/screens/community_guidelines_screen.dart';
import 'package:testtale3/screens/driver/driver_home_screen.dart';
import 'package:testtale3/screens/passenger/passenger_home_screen.dart';
import 'package:testtale3/widgets/permission_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;
      final auth = context.read<app_auth.AuthProvider>();
      final settings = context.read<SettingsProvider>();

      // Wait for Firebase to resolve auth state if not ready yet
      if (!auth.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
      }

      // Sync current system permission state into the provider
      await settings.syncPermissions();
      if (!mounted) return;

      // Show notification permission dialog if not already granted
      if (!settings.notificationsEnabled) {
        final allow = await showPermissionDialog(context, PermissionType.notifications);
        if (!mounted) return;
        if (allow) await settings.requestNotifications();
        if (!mounted) return;
      }

      // Show location permission dialog if not already granted
      if (!settings.locationEnabled) {
        final allow = await showPermissionDialog(context, PermissionType.location);
        if (!mounted) return;
        if (allow) await settings.requestLocation();
        if (!mounted) return;
      }

      Widget destination;
      if (auth.isLoggedIn) {
        destination = auth.userRole == UserRole.driver
            ? const DriverHomeScreen()
            : const PassengerHomeScreen();
      } else {
        destination = const CommunityGuidelinesScreen();
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => destination,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
       
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo — responsive: 70% of screen width, max 320px
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.70,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.30,
                ),
                child: Image.asset(
                  'assets/images/logomodified.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              // App name
             
              
              const Spacer(flex: 4),
              // Progress section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.preparingJourney,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Text(
                              '${(_progressController.value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 4,
                            backgroundColor: AppStyles.primaryColor.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppStyles.progressGold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Bottom text
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

