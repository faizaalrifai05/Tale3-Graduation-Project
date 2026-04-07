import 'package:flutter/foundation.dart';

/// Manages the bottom navigation bar index for both driver and passenger
/// home shells.
///
/// Keeps separate tab indices so switching between driver/passenger roles
/// preserves the last-viewed tab in each context.
class NavigationProvider extends ChangeNotifier {
  int _driverTabIndex = 0;
  int _passengerTabIndex = 0;

  /// Current tab index for the driver home screen.
  int get driverTabIndex => _driverTabIndex;

  /// Current tab index for the passenger home screen.
  int get passengerTabIndex => _passengerTabIndex;

  /// Update the driver home bottom nav tab.
  void setDriverTab(int index) {
    if (_driverTabIndex != index) {
      _driverTabIndex = index;
      notifyListeners();
    }
  }

  /// Update the passenger home bottom nav tab.
  void setPassengerTab(int index) {
    if (_passengerTabIndex != index) {
      _passengerTabIndex = index;
      notifyListeners();
    }
  }

  /// Reset both tab indices to their defaults (Home tab).
  void resetTabs() {
    _driverTabIndex = 0;
    _passengerTabIndex = 0;
    notifyListeners();
  }
}
