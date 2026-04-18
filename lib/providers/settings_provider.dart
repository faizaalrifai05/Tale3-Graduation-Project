import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsProvider extends ChangeNotifier {
  // ── Permissions ────────────────────────────────────────────────────────────
  bool _notificationsEnabled = false;
  bool _locationEnabled = false;

  // ── Theme ──────────────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.system;

  // ── Locale ────────────────────────────────────────────────────────────────
  Locale _locale = const Locale('en');

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;

  // Keep old getter for compatibility
  bool get pushNotificationsEnabled => _notificationsEnabled;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  /// Human-readable label for the current theme (used in settings tile).
  String get themeModeLabel {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Human-readable label for the current language (used in settings tile).
  String get languageLabel =>
      _locale.languageCode == 'ar' ? 'العربية' : 'English';

  // ── Theme ──────────────────────────────────────────────────────────────────
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  // ── Locale ────────────────────────────────────────────────────────────────
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  /// Call once at startup to sync toggles with real system permission state.
  Future<void> syncPermissions() async {
    final notifStatus = await Permission.notification.status;
    final locationStatus = await Permission.locationWhenInUse.status;
    _notificationsEnabled = notifStatus.isGranted;
    _locationEnabled = locationStatus.isGranted;
    notifyListeners();
  }

  /// Request notification permission and update state.
  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    _notificationsEnabled = status.isGranted;
    notifyListeners();
    return status.isGranted;
  }

  /// Request location permission and update state.
  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    _locationEnabled = status.isGranted;
    notifyListeners();
    return status.isGranted;
  }

  /// Toggle notification — opens app settings if permanently denied.
  Future<void> toggleNotifications(bool value) async {
    if (!value) {
      await openAppSettings();
      return;
    }
    final status = await Permission.notification.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      await requestNotifications();
    }
  }

  /// Toggle location — opens app settings if permanently denied.
  Future<void> toggleLocation(bool value) async {
    if (!value) {
      await openAppSettings();
      return;
    }
    final status = await Permission.locationWhenInUse.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      await requestLocation();
    }
  }

  // kept for old call sites
  void togglePushNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
