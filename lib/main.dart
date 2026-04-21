import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testtale3/Services/FCM_service.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/providers/navigation_provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/providers/chat_provider.dart';
import 'package:testtale3/providers/settings_provider.dart';
import 'package:testtale3/providers/saved_places_provider.dart';
import 'package:testtale3/screens/splash_screen.dart';
import 'package:testtale3/theme/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMService.setup(); 
  
  runApp(const Tale3App());
}

class Tale3App extends StatelessWidget {
  const Tale3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RideProvider>(
          create: (ctx) => RideProvider(ctx.read<AuthProvider>()),
          update: (_, auth, prev) => prev!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (ctx) => BookingProvider(ctx.read<AuthProvider>()),
          update: (_, auth, prev) => prev!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (ctx) => ChatProvider(ctx.read<AuthProvider>()),
          update: (_, auth, prev) => prev!..updateAuth(auth),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SavedPlacesProvider>(
          create: (_) => SavedPlacesProvider(),
          update: (_, auth, places) {
            if (auth.currentUser != null) {
              places!.init(auth.currentUser!.uid);
            } else {
              places?.clear();
            }
            return places ?? SavedPlacesProvider();
          },
        ),
      ],
      // Consumer rebuilds MaterialApp whenever SettingsProvider changes,
      // so themeMode and locale updates take effect immediately app-wide.
      child: Consumer<SettingsProvider>(
        builder: (_, settings, _) => MaterialApp(
          title: 'Tale3',
          debugShowCheckedModeBanner: false,

          // ── Theme (driven by SettingsProvider) ──────────────────────
          theme: AppStyles.lightTheme,
          darkTheme: AppStyles.darkTheme,
          themeMode: settings.themeMode,

          // ── Localization (driven by SettingsProvider) ────────────────
          locale: settings.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          home: const SplashScreen(),
        ),
      ),
    );
  }
}
