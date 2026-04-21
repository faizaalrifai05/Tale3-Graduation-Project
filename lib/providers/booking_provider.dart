import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/booking_model.dart';
import 'auth_provider.dart';

class BookingProvider extends ChangeNotifier {
  static const int _passengerSlots = 4;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthProvider _auth;

  BookingProvider(this._auth);

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    notifyListeners();
  }

  RideModel? _currentRide;

  // Seat states: 0=available, 1=selected, 2=occupied, 3=driver
  final Map<int, int> _seatStates = {
    0: 3,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
  };

  Map<int, int> get seatStates => Map.unmodifiable(_seatStates);

  int get selectedCount => _seatStates.values.where((v) => v == 1).length;

  int get totalPrice => selectedCount * (_currentRide?.pricePerSeat ?? 0);

  /// Initialises the seat map from [ride]'s real-time booked / total counts.
  void initFromRide(RideModel ride) {
    _currentRide = ride;
    for (int i = 1; i <= _passengerSlots; i++) {
      if (i > ride.totalSeats) {
        _seatStates[i] = 2; // beyond capacity — render as occupied
      } else if (i <= ride.bookedSeats) {
        _seatStates[i] = 2; // already taken
      } else {
        _seatStates[i] = 0; // available
      }
    }
    notifyListeners();
  }

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

  void resetSelection() {
    for (final key in _seatStates.keys) {
      if (_seatStates[key] == 1) _seatStates[key] = 0;
    }
    notifyListeners();
  }

  /// Writes the booking to Firestore inside a transaction that checks seat
  /// availability. Returns the created [BookingModel] or null on failure.
  Future<BookingModel?> confirmBooking() async {
    final ride = _currentRide;
    final user = _auth.currentUser;
    if (ride == null || user == null || selectedCount == 0) return null;

    final seats = selectedCount;

    try {
      BookingModel? result;
      final rideRef = _db.collection('rides').doc(ride.id);
      final bookingRef = _db.collection('bookings').doc();

      await _db.runTransaction((tx) async {
        final rideSnap = await tx.get(rideRef);
        final booked = (rideSnap.data()!['bookedSeats'] as num?)?.toInt() ?? 0;
        final total = (rideSnap.data()!['totalSeats'] as num?)?.toInt() ?? 0;
        if (booked + seats > total) {
          throw Exception('not_enough_seats');
        }

        final booking = BookingModel(
          id: bookingRef.id,
          rideId: ride.id,
          passengerId: user.uid,
          passengerName: user.name,
          driverId: ride.driverId,
          driverName: ride.driverName,
          carInfo: ride.carFullInfo,
          plateNumber: ride.plateNumber,
          origin: ride.origin,
          destination: ride.destination,
          date: ride.date,
          time: ride.time,
          seatsBooked: seats,
          totalPrice: totalPrice,
          status: 'confirmed',
          createdAt: DateTime.now(),
        );

        tx.set(bookingRef, booking.toMap());
        tx.update(rideRef, {'bookedSeats': FieldValue.increment(seats)});
        result = booking;
      });

      return result;
    } catch (_) {
      return null;
    }
  }

  /// Stream of bookings belonging to the currently logged-in passenger.
  Stream<List<BookingModel>> get myBookingsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('passengerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromDoc).toList());
  }

  /// Cancels a booking in Firestore and decrements the ride's booked seat count.
  Future<void> cancelBooking(BookingModel booking) async {
    final bookingRef = _db.collection('bookings').doc(booking.id);
    final rideRef = _db.collection('rides').doc(booking.rideId);

    await _db.runTransaction((tx) async {
      tx.update(bookingRef, {'status': 'cancelled'});
      tx.update(rideRef,
          {'bookedSeats': FieldValue.increment(-booking.seatsBooked)});
    });
  }
}
