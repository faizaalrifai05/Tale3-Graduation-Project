import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Manages authentication state for the Tale3 app.
///
/// Tracks whether the user is logged in, their role (driver / passenger),
/// and basic profile information. Screens use this provider to:
/// - Trigger login/logout actions
/// - Display the current user's name and role
/// - Gate navigation based on auth status
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  /// The currently authenticated user, or null if not logged in.
  UserModel? get currentUser => _currentUser;

  /// Whether the user is currently logged in.
  bool get isLoggedIn => _currentUser != null;

  /// Whether an auth action (login/logout) is in progress.
  bool get isLoading => _isLoading;

  /// The display name of the current user, or empty string if not logged in.
  String get userName => _currentUser?.name ?? '';

  /// The current user's role, or null if not logged in.
  UserRole? get userRole => _currentUser?.role;

  /// Authenticate as a driver with the given credentials.
  ///
  /// In a real app this would call an API. For now we create a mock user.
  void loginAsDriver(String email, String password) {
    _isLoading = true;
    notifyListeners();

    // Simulate authentication (replace with real API call later)
    _currentUser = UserModel(
      name: 'Capt. Ahmed',
      email: email,
      role: UserRole.driver,
    );
    _isLoading = false;
    notifyListeners();
  }

  /// Authenticate as a passenger with the given credentials.
  void loginAsPassenger(String email, String password) {
    _isLoading = true;
    notifyListeners();

    _currentUser = UserModel(
      name: 'Ahmed',
      email: email,
      role: UserRole.passenger,
    );
    _isLoading = false;
    notifyListeners();
  }

  /// Log the user out and clear all auth state.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
