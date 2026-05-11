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

  String? _confirmError;
  String? get confirmError => _confirmError;

  /// Initialises the seat map from [ride]'s real-time booked / total counts.
  void initFromRide(RideModel ride) {
    _currentRide = ride;
    for (int i = 1; i <= _passengerSlots; i++) {
      if (ride.totalSeats > 0 && i > ride.totalSeats) {
        _seatStates[i] = 2;
      } else if (i <= ride.bookedSeats) {
        _seatStates[i] = 2;
      } else {
        _seatStates[i] = 0;
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
  Future<BookingModel?> confirmBooking({
    double? pickupLat,
    double? pickupLng,
  }) async {
    final ride = _currentRide;
    final user = _auth.currentUser;
    if (ride == null || user == null || selectedCount == 0) return null;

    final seats = selectedCount;

    _confirmError = null;
    try {
      final existing = await _db
          .collection('bookings')
          .where('rideId', isEqualTo: ride.id)
          .where('passengerId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'confirmed')
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        _confirmError = 'already_booked';
        notifyListeners();
        return null;
      }

      BookingModel? result;
      final rideRef = _db.collection('rides').doc(ride.id);
      final bookingRef = _db.collection('bookings').doc();

      await _db.runTransaction((tx) async {
        final rideSnap = await tx.get(rideRef);
        final booked = (rideSnap.data()!['bookedSeats'] as num?)?.toInt() ?? 0;
        final total = (rideSnap.data()!['totalSeats'] as num?)?.toInt() ?? 0;
        if (total > 0 && booked + seats > total) {
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
          pickupLat: pickupLat,
          pickupLng: pickupLng,
        );

        tx.set(bookingRef, booking.toMap());
        tx.update(rideRef, {'bookedSeats': FieldValue.increment(seats)});
        result = booking;
      });

      return result;
    } catch (e) {
      final raw = e.toString();
      _confirmError = raw.contains('not_enough_seats')
          ? 'not_enough_seats'
          : raw.contains('permission-denied') || raw.contains('PERMISSION_DENIED')
              ? 'permission_denied'
              : 'booking_failed';
      notifyListeners();
      return null;
    }
  }

  /// Stream that emits the current user's confirmed booking for [rideId],
  /// or null if they haven't booked it (or cancelled).
  Stream<BookingModel?> existingBookingStream(String rideId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('passengerId', isEqualTo: uid)
        .where('status', isEqualTo: 'confirmed')
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : BookingModel.fromDoc(snap.docs.first));
  }

  /// Stream of confirmed bookings for a specific ride (driver view).
  Stream<List<BookingModel>> rideBookingsStream(String rideId) {
    return _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snap) {
          final bookings = snap.docs.map(BookingModel.fromDoc).toList();
          bookings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return bookings;
        });
  }

  /// One-shot fetch of all confirmed bookings for a ride (driver route planning).
  Future<List<BookingModel>> rideBookingsOnce(String rideId) async {
    final snap = await _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'confirmed')
        .get();
    return snap.docs.map(BookingModel.fromDoc).toList();
  }

  /// Stream of bookings belonging to the currently logged-in passenger.
  Stream<List<BookingModel>> get myBookingsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('passengerId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final bookings = snap.docs.map(BookingModel.fromDoc).toList();
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
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

  /// Stream of total earnings for a driver.
  /// Sums the [totalPrice] of all bookings where:
  ///   - driverId == [driverId]
  ///   - status   == 'completed'
  /// Emits 0 if the driver has no completed bookings yet.
  Stream<int> driverEarningsStream(String driverId) {
    if (driverId.isEmpty) return Stream.value(0);
    return _db
        .collection('bookings')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return 0;
          return snap.docs
              .map(BookingModel.fromDoc)
              .map((b) => b.totalPrice)
              .reduce((a, b) => a + b);
        });
  }
}