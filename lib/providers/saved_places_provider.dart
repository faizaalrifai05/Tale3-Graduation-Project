import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A saved location (Home, Work, custom).
class SavedPlace {
  final String id;
  final String title;
  final String subtitle;
  final String iconName; // 'home', 'work', 'star', 'place'

  const SavedPlace({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
  });

  IconData get icon {
    switch (iconName) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'iconName': iconName,
      };

  factory SavedPlace.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedPlace(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      iconName: data['iconName'] ?? 'place',
    );
  }
}

/// Manages the current user's saved places, synced with Firestore.
/// Call [init] once after login with the user's UID.
class SavedPlacesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<SavedPlace> _places = [];
  bool _isLoading = false;
  String? _uid;

  List<SavedPlace> get places => List.unmodifiable(_places);
  bool get isLoading => _isLoading;

  CollectionReference<Map<String, dynamic>>? get _col =>
      _uid == null ? null : _db.collection('users').doc(_uid).collection('savedPlaces');

  /// Load saved places for a given user UID. Call this after login.
  Future<void> init(String uid) async {
    if (_uid == uid) return; // already loaded for this user
    _uid = uid;
    _places = [];
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _col!.orderBy('title').get();
      _places = snap.docs.map(SavedPlace.fromDoc).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  /// Clear data on logout.
  void clear() {
    _uid = null;
    _places = [];
    notifyListeners();
  }

  /// Add a new saved place. Returns null on success, error message on failure.
  Future<String?> addPlace({
    required String title,
    required String subtitle,
    required String iconName,
  }) async {
    if (_col == null) return 'Not logged in.';
    try {
      final doc = await _col!.add(SavedPlace(
        id: '',
        title: title,
        subtitle: subtitle,
        iconName: iconName,
      ).toMap());
      _places.add(SavedPlace(id: doc.id, title: title, subtitle: subtitle, iconName: iconName));
      _places.sort((a, b) => a.title.compareTo(b.title));
      notifyListeners();
      return null;
    } catch (_) {
      return 'Failed to save place. Please try again.';
    }
  }

  /// Delete a saved place by ID.
  Future<void> deletePlace(String id) async {
    _places.removeWhere((p) => p.id == id);
    notifyListeners();
    _col?.doc(id).delete().catchError((_) {});
  }
}
