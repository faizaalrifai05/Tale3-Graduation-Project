import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import 'auth_provider.dart';

class RideProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthProvider _auth;

  RideProvider(this._auth);

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    notifyListeners();
  }

  // ── Form state ────────────────────────────────────────────────────────────

  String _origin = '';
  String _destination = '';
  String _date = '';
  String _time = '';
  int _seats = 3;
  int _price = 15;
  bool _acChecked = true;
  bool _luggageChecked = true;
  bool _petsChecked = false;
  bool _noSmokingChecked = true;
  String _additionalNotes = '';
  bool _isPublishing = false;

  String get origin => _origin;
  String get destination => _destination;
  String get date => _date;
  String get time => _time;
  int get seats => _seats;
  int get price => _price;
  bool get acChecked => _acChecked;
  bool get luggageChecked => _luggageChecked;
  bool get petsChecked => _petsChecked;
  bool get noSmokingChecked => _noSmokingChecked;
  String get additionalNotes => _additionalNotes;
  bool get isPublishing => _isPublishing;

  void setOrigin(String v) { _origin = v; notifyListeners(); }
  void setDestination(String v) { _destination = v; notifyListeners(); }
  void setDate(String v) { _date = v; notifyListeners(); }
  void setTime(String v) { _time = v; notifyListeners(); }
  void incrementSeats() { _seats++; notifyListeners(); }
  void decrementSeats() { if (_seats > 1) { _seats--; notifyListeners(); } }
  void incrementPrice() { _price++; notifyListeners(); }
  void decrementPrice() { if (_price > 0) { _price--; notifyListeners(); } }
  void toggleAc(bool v) { _acChecked = v; notifyListeners(); }
  void toggleLuggage(bool v) { _luggageChecked = v; notifyListeners(); }
  void togglePets(bool v) { _petsChecked = v; notifyListeners(); }
  void toggleNoSmoking(bool v) { _noSmokingChecked = v; notifyListeners(); }
  void setAdditionalNotes(String v) { _additionalNotes = v; notifyListeners(); }

  void resetForm() {
    _origin = '';
    _destination = '';
    _date = '';
    _time = '';
    _seats = 3;
    _price = 15;
    _acChecked = true;
    _luggageChecked = true;
    _petsChecked = false;
    _noSmokingChecked = true;
    _additionalNotes = '';
    notifyListeners();
  }

  // ── Firestore ─────────────────────────────────────────────────────────────

  /// Publishes the current ride to Firestore. Returns null on success,
  /// or an error message string on failure.
  Future<String?> publishRide() async {
    final user = _auth.currentUser;
    if (user == null) return 'Not logged in.';
    if (_origin.isEmpty || _destination.isEmpty) {
      return 'Please fill in origin and destination.';
    }
    if (_date.isEmpty || _time.isEmpty) {
      return 'Please select a date and time.';
    }

    _isPublishing = true;
    notifyListeners();

    try {
      await _db.collection('rides').add({
        'driverId': user.uid,
        'driverName': user.name,
        'carMake': user.carMake,
        'carModel': user.carModel,
        'carColor': user.carColor,
        'plateNumber': user.plateNumber,
        'origin': _origin,
        'destination': _destination,
        'date': _date,
        'time': _time,
        'totalSeats': _seats,
        'bookedSeats': 0,
        'pricePerSeat': _price,
        'acEnabled': _acChecked,
        'luggageEnabled': _luggageChecked,
        'petsAllowed': _petsChecked,
        'noSmoking': _noSmokingChecked,
        'notes': _additionalNotes,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      resetForm();
      return null;
    } catch (e) {
      return 'Failed to publish ride. Please try again.';
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  /// Streams rides available for passengers (active, not by current user).
  Stream<List<RideModel>> get availableRidesStream {
    final uid = _auth.currentUser?.uid;
    return _db
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map(RideModel.fromDoc)
            .where((r) => r.driverId != uid && !r.isFull)
            .toList());
  }

  /// Streams rides posted by the current driver.
  Stream<List<RideModel>> get myRidesStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('rides')
        .where('driverId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RideModel.fromDoc).toList());
  }
}
