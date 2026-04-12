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
              // Logo
                SizedBox(
                  width: 350,
                  height: 300,
              child: Container(
                child: Image.asset(
                 'assets/images/logomodified.png',
                  fit: BoxFit.fill,
                  ),
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
                        const Text(
                          'Preparing your journey...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5C0A1A), // white 70%
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Text(
                              '${(_progressController.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF5C0A1A), // white 70%
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
                            backgroundColor: const Color(0x26FFFFFF), // white 15%
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
              // Bottom text
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

