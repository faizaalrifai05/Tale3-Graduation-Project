import 'package:flutter/foundation.dart';

/// Manages seat selection state for the passenger booking flow.
///
/// Seat states: 0 = available, 1 = selected, 2 = occupied, 3 = driver.
/// Only seats in state 0 or 1 can be toggled by the user.
class BookingProvider extends ChangeNotifier {
  /// Price per seat in JOD (mock value).
  static const int pricePerSeat = 5;

  /// Map of seat index → seat state.
  final Map<int, int> _seatStates = {
    0: 3, // Driver
    1: 2, // Front passenger (occupied)
    2: 0, // Back left (available)
    3: 1, // Back middle (selected)
    4: 0, // Back right (available)
  };

  /// Read-only view of the current seat states.
  Map<int, int> get seatStates => Map.unmodifiable(_seatStates);

  /// Number of seats currently selected by the user.
  int get selectedCount => _seatStates.values.where((v) => v == 1).length;

  /// Total price based on the number of selected seats.
  int get totalPrice => selectedCount * pricePerSeat;

  /// Toggle a seat between available (0) and selected (1).
  /// Occupied (2) and driver (3) seats cannot be toggled.
  void toggleSeat(int index) {
    final current = _seatStates[index];
    if (current == 0) {
      _seatStates[index] = 1;
      notifyListeners();
    } else if (current == 1) {
      _seatStates[index] = 0;
      notifyListeners();
    }
  }

  /// Reset all selectable seats back to available.
  void resetSelection() {
    for (final key in _seatStates.keys) {
      if (_seatStates[key] == 1) {
        _seatStates[key] = 0;
      }
    }
    notifyListeners();
  }
}
