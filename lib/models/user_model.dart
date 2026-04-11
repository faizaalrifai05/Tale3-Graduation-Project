/// Enum representing the user's role in the Tale3 app.
enum UserRole { driver, passenger }

/// Data model representing a Tale3 user.
///
/// Holds basic user identity and role information.
/// Used by [AuthProvider] to track the currently logged-in user.
class UserModel {
  final String name;
  final String email;
  final UserRole role;

  const UserModel({
    required this.name,
    required this.email,
    required this.role,
  });

  /// Creates a copy of this model with optional field overrides.
  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
