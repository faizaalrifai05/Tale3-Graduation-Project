import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const Tale3App());
}

class Tale3App extends StatelessWidget {
  const Tale3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
