import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  // ── Form state ─────────────────────────────────────────────────────────────
  String _origin = '';
  String _destination = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _seats = 3;
  int _price = 15;
  bool _acChecked = true;
  bool _luggageChecked = true;
  bool _petsChecked = false;
  bool _noSmokingChecked = true;
  String _additionalNotes = '';
  bool _isPublishing = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  String get origin => _origin;
  String get destination => _destination;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  int get seats => _seats;
  int get price => _price;
  bool get acChecked => _acChecked;
  bool get luggageChecked => _luggageChecked;
  bool get petsChecked => _petsChecked;
  bool get noSmokingChecked => _noSmokingChecked;
  String get additionalNotes => _additionalNotes;
  bool get isPublishing => _isPublishing;

  String get dateLabel {
    if (_selectedDate == null) return 'Select date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${_selectedDate!.day} ${months[_selectedDate!.month - 1]} ${_selectedDate!.year}';
  }

  String get dateIso {
    if (_selectedDate == null) return '';
    final y = _selectedDate!.year;
    final m = _selectedDate!.month.toString().padLeft(2, '0');
    final d = _selectedDate!.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String get timeLabel {
    if (_selectedTime == null) return 'Select time';
    final h = _selectedTime!.hour.toString().padLeft(2, '0');
    final m = _selectedTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Setters ───────────────────────────────────────────────────────────────
  void setOrigin(String v) { _origin = v; notifyListeners(); }
  void setDestination(String v) { _destination = v; notifyListeners(); }
  void setDate(DateTime d) { _selectedDate = d; notifyListeners(); }
  void setTime(TimeOfDay t) { _selectedTime = t; notifyListeners(); }
  void incrementSeats() { _seats++; notifyListeners(); }
  void decrementSeats() { if (_seats > 1) { _seats--; notifyListeners(); } }
  void incrementPrice() { _price++; notifyListeners(); }
  void decrementPrice() { if (_price > 0) { _price--; notifyListeners(); } }
  void toggleAc(bool v) { _acChecked = v; notifyListeners(); }
  void toggleLuggage(bool v) { _luggageChecked = v; notifyListeners(); }
  void togglePets(bool v) { _petsChecked = v; notifyListeners(); }
  void toggleNoSmoking(bool v) { _noSmokingChecked = v; notifyListeners(); }
  void setAdditionalNotes(String v) { _additionalNotes = v; notifyListeners(); }

  // ── Validation ────────────────────────────────────────────────────────────
  String? validate() {
    if (_origin.trim().isEmpty) return 'Please enter the origin city.';
    if (_destination.trim().isEmpty) return 'Please enter the destination city.';
    if (_selectedDate == null) return 'Please select a departure date.';
    if (_selectedTime == null) return 'Please select a departure time.';
    return null;
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void resetForm() {
    _origin = '';
    _destination = '';
    _selectedDate = null;
    _selectedTime = null;
    _seats = 3;
    _price = 15;
    _acChecked = true;
    _luggageChecked = true;
    _petsChecked = false;
    _noSmokingChecked = true;
    _additionalNotes = '';
    notifyListeners();
  }

  // ── Publish ───────────────────────────────────────────────────────────────
  Future<String?> publishRide({
    required String driverId,
    required String driverName,
  }) async {
    _isPublishing = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      await _db.collection('rides').add({
        'driverId': driverId,
        'driverName': driverName,
        'carMake': user?.carMake ?? '',
        'carModel': user?.carModel ?? '',
        'carColor': user?.carColor ?? '',
        'plateNumber': user?.plateNumber ?? '',
        'origin': _origin.trim(),
        'destination': _destination.trim(),
        'date': dateIso,
        'time': timeLabel,
        'totalSeats': _seats,
        'bookedSeats': 0,
        'pricePerSeat': _price,
        'acEnabled': _acChecked,
        'luggageEnabled': _luggageChecked,
        'petsAllowed': _petsChecked,
        'noSmoking': _noSmokingChecked,
        'notes': _additionalNotes.trim(),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      debugPrint('publishRide error: $e');
      return 'Failed to publish ride. Please try again.';
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }

  // ── Firestore streams ─────────────────────────────────────────────────────

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
