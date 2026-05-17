import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import 'auth_provider.dart';

class RatingProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthProvider _auth;

  RatingProvider(this._auth);

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    notifyListeners();
  }

  /// Submit a star rating + optional comment for a completed ride.
  /// Returns null on success, error string on failure.
  Future<String?> submitRating({
    required String driverId,
    required String rideId,
    required String bookingId,
    required int stars,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not logged in.';
    try {
      final existing = await _db
          .collection('ratings')
          .where('bookingId', isEqualTo: bookingId)
          .where('passengerId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return 'already_rated';

      final ref = _db.collection('ratings').doc();
      final rating = RatingModel(
        id: ref.id,
        driverId: driverId,
        passengerId: user.uid,
        passengerName: user.name,
        rideId: rideId,
        bookingId: bookingId,
        stars: stars,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await ref.set(rating.toMap());
      _updateDriverAverage(driverId);
      return null;
    } catch (e) {
      return 'Failed to submit rating. Please try again.';
    }
  }

  /// Stream of all ratings for a driver, newest first.
  Stream<List<RatingModel>> driverRatingsStream(String driverId) {
    return _db
        .collection('ratings')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(RatingModel.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Stream of all ratings a passenger has received from drivers.
  /// Reads from the `passengerRatings` collection.
  Stream<List<Map<String, dynamic>>> passengerRatingsStream(
      String passengerId) {
    if (passengerId.isEmpty) return Stream.value([]);
    return _db
        .collection('passengerRatings')
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Driver rates a passenger after a completed ride.
  Future<String?> submitPassengerRating({
    required String passengerId,
    required String passengerName,
    required String rideId,
    required String bookingId,
    required int stars,
    String comment = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not logged in.';
    try {
      final existing = await _db
          .collection('passengerRatings')
          .where('bookingId', isEqualTo: bookingId)
          .where('driverId', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return 'already_rated';

      final ref = _db.collection('passengerRatings').doc();
      await ref.set({
        'id': ref.id,
        'driverId': user.uid,
        'driverName': user.name,
        'passengerId': passengerId,
        'passengerName': passengerName,
        'rideId': rideId,
        'bookingId': bookingId,
        'stars': stars,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (_) {
      return 'Failed to submit rating. Please try again.';
    }
  }

  /// Stream that emits true if the driver has already rated this passenger booking.
  Stream<bool> hasRatedPassenger(String bookingId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(false);
    return _db
        .collection('passengerRatings')
        .where('bookingId', isEqualTo: bookingId)
        .where('driverId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  /// Stream that emits true if the current user has already rated this booking.
  Stream<bool> hasRatedBooking(String bookingId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(false);
    return _db
        .collection('ratings')
        .where('bookingId', isEqualTo: bookingId)
        .where('passengerId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);
  }

  /// Recomputes and writes the driver's averageRating + ratingCount to Firestore.
  Future<void> _updateDriverAverage(String driverId) async {
    try {
      final snap = await _db
          .collection('ratings')
          .where('driverId', isEqualTo: driverId)
          .get();
      if (snap.docs.isEmpty) return;
      final ratings = snap.docs.map(RatingModel.fromDoc).toList();
      final avg =
          ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;
      await _db.collection('users').doc(driverId).update({
        'averageRating': double.parse(avg.toStringAsFixed(1)),
        'ratingCount': ratings.length,
      });
    } catch (_) {}
  }
}