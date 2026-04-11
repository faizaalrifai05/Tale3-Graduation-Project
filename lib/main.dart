import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/providers/navigation_provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/screens/splash_screen.dart';

void main() {
  runApp(const Tale3App());
}

class Tale3App extends StatelessWidget {
  const Tale3App({super.key});

  @override
  Widget build(BuildContext context) {
    // Register all providers at the root of the widget tree.
    // Each provider is created lazily and available to every descendant.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Tale3',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B1A2B),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
