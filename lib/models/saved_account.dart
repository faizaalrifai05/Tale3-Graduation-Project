import 'dart:convert';

/// Represents a previously signed-in account stored locally.
class SavedAccount {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String role; // 'driver' | 'passenger'

  const SavedAccount({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.role,
  });

  bool get isDriver => role == 'driver';

  /// Initials for avatar fallback (e.g. "John Doe" → "JD")
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': role,
      };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String? ?? '',
        role: json['role'] as String,
      );

  static SavedAccount? tryDecode(String raw) {
    try {
      return SavedAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
