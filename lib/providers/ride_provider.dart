import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RideProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Form fields ─────────────────────────────────────────────────────────
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

  // ── Publish state ────────────────────────────────────────────────────────
  bool _isPublishing = false;

  // ── Getters ──────────────────────────────────────────────────────────────
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

  /// Human-readable date label, e.g. "15 Oct 2026" or "Select date"
  String get dateLabel {
    if (_selectedDate == null) return 'Select date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${_selectedDate!.day} ${months[_selectedDate!.month - 1]} ${_selectedDate!.year}';
  }

  /// ISO-8601 date string saved to Firestore, e.g. "2026-10-15"
  String get dateIso {
    if (_selectedDate == null) return '';
    final y = _selectedDate!.year;
    final m = _selectedDate!.month.toString().padLeft(2, '0');
    final d = _selectedDate!.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Human-readable time label, e.g. "14:30" or "Select time"
  String get timeLabel {
    if (_selectedTime == null) return 'Select time';
    final h = _selectedTime!.hour.toString().padLeft(2, '0');
    final m = _selectedTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Setters ──────────────────────────────────────────────────────────────
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
  /// Returns a user-facing error message, or null if all required fields are set.
  String? validate() {
    if (_origin.trim().isEmpty) return 'Please enter the origin city.';
    if (_destination.trim().isEmpty) return 'Please enter the destination city.';
    if (_selectedDate == null) return 'Please select a departure date.';
    if (_selectedTime == null) return 'Please select a departure time.';
    return null;
  }

  // ── Publish ───────────────────────────────────────────────────────────────
  /// Saves the ride to Firestore.
  /// Returns null on success, or an error message string on failure.
  Future<String?> publishRide({
    required String driverId,
    required String driverName,
  }) async {
    _isPublishing = true;
    notifyListeners();
    try {
      await _db.collection('rides').add({
        'driverId': driverId,
        'driverName': driverName,
        'origin': _origin.trim(),
        'destination': _destination.trim(),
        'date': dateIso,
        'time': timeLabel,
        'totalSeats': _seats,
        'availableSeats': _seats,
        'price': _price,
        'features': {
          'ac': _acChecked,
          'luggage': _luggageChecked,
          'pets': _petsChecked,
          'noSmoking': _noSmokingChecked,
        },
        'notes': _additionalNotes.trim(),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'bookings': [],
      });
      return null; // success
    } catch (e) {
      return 'Failed to publish ride. Please try again.';
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
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
}
