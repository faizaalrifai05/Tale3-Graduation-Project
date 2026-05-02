import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/community_guidelines_screen.dart';
import 'package:testtale3/screens/driver/driver_home_screen.dart';
import 'package:testtale3/screens/passenger/passenger_home_screen.dart';

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

      // Wait for Firebase to resolve auth state if not ready yet
      if (!auth.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
      }

      Widget destination;
      if (auth.isLoggedIn) {
        if (auth.userRole == UserRole.driver) {
          destination = const DriverHomeScreen();
        } else if (auth.userRole == UserRole.admin) {
          // TODO: replace with AdminPanelScreen once created
          destination = const PassengerHomeScreen();
        } else {
          destination = const PassengerHomeScreen();
        }
      } else {
        destination = const CommunityGuidelinesScreen();
      }

      // Navigate first
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );

      // Show blocked dialog AFTER navigation if user was blocked
      if (auth.wasBlocked) {
        auth.clearBlockedFlag();
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.block_rounded, color: Colors.red, size: 26),
                SizedBox(width: 10),
                Text(
                  'Account Blocked',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Your account has been blocked by the admin. '
              'If you believe this is a mistake, please contact '
              'support at support@tale3.app.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      }
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
              // Logo
              SizedBox(
                width: 350,
                height: 300,
                child: Image.asset(
                  'assets/images/logomodified.png',
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 24),
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
                        const Text(
                          'Preparing your journey...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5C0A1A),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Text(
                              '${(_progressController.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5C0A1A),
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
                            backgroundColor: const Color(0x26FFFFFF),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFE8C06A),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}