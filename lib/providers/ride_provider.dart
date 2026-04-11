import 'package:flutter/foundation.dart';

/// Manages the state of the "Create Ride" form for drivers.
///
/// Holds all ride configuration values (route, seats, price, features)
/// and provides methods to modify them. Extracted from
/// `DriverCreateRideScreen` to separate business logic from UI.
class RideProvider extends ChangeNotifier {
  String _origin = '';
  String _destination = '';
  int _seats = 3;
  int _price = 15;
  bool _acChecked = true;
  bool _luggageChecked = true;
  bool _petsChecked = false;
  bool _noSmokingChecked = true;
  String _additionalNotes = '';

  // ── Getters ──────────────────────────────────────────────────────────────

  String get origin => _origin;
  String get destination => _destination;
  int get seats => _seats;
  int get price => _price;
  bool get acChecked => _acChecked;
  bool get luggageChecked => _luggageChecked;
  bool get petsChecked => _petsChecked;
  bool get noSmokingChecked => _noSmokingChecked;
  String get additionalNotes => _additionalNotes;

  // ── Setters / Actions ────────────────────────────────────────────────────

  void setOrigin(String value) {
    _origin = value;
    notifyListeners();
  }

  void setDestination(String value) {
    _destination = value;
    notifyListeners();
  }

  void incrementSeats() {
    _seats++;
    notifyListeners();
  }

  void decrementSeats() {
    if (_seats > 1) {
      _seats--;
      notifyListeners();
    }
  }

  void incrementPrice() {
    _price++;
    notifyListeners();
  }

  void decrementPrice() {
    if (_price > 0) {
      _price--;
      notifyListeners();
    }
  }

  void toggleAc(bool value) {
    _acChecked = value;
    notifyListeners();
  }

  void toggleLuggage(bool value) {
    _luggageChecked = value;
    notifyListeners();
  }

  void togglePets(bool value) {
    _petsChecked = value;
    notifyListeners();
  }

  void toggleNoSmoking(bool value) {
    _noSmokingChecked = value;
    notifyListeners();
  }

  void setAdditionalNotes(String value) {
    _additionalNotes = value;
    notifyListeners();
  }

  /// Simulates publishing the ride. In a real app this would call an API.
  void publishRide() {
    // TODO: integrate with backend
  }

  /// Reset the form to default values (e.g. after successful publish).
  void resetForm() {
    _origin = '';
    _destination = '';
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
