import 'package:flutter/foundation.dart';

/// Manages app-wide settings like notifications, language, and theme.
class SettingsProvider extends ChangeNotifier {
  bool _pushNotificationsEnabled = true;
  String _language = 'English';
  String _themeMode = 'System';

  // --- Getters ---
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  String get language => _language;
  String get themeMode => _themeMode;

  // --- Setters ---
  void togglePushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setThemeMode(String mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
