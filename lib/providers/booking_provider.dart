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

  /// Keeps seat states in sync with the live booking stream.
  /// Called whenever the booking stream fires.
  void updateOccupiedSeats(int bookedCount, int totalSeats) {
    for (int i = 1; i <= _passengerSlots; i++) {
      if (totalSeats > 0 && i > totalSeats) {
        _seatStates[i] = 2;
      } else if (i <= bookedCount) {
        if (_seatStates[i] != 1) _seatStates[i] = 2;
      } else {
        if (_seatStates[i] == 2) _seatStates[i] = 0;
      }
    }
    notifyListeners();
  }

  /// Writes a pending booking request to Firestore.
  /// Does NOT reserve seats — the driver must accept first.
  /// Returns the created [BookingModel] or null on failure.
  Future<BookingModel?> confirmBooking({
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
  }) async {
    final ride = _currentRide;
    final user = _auth.currentUser;

    if (ride == null || selectedCount == 0) {
      _confirmError = 'booking_failed';
      notifyListeners();
      return null;
    }

    if (user == null) {
      _confirmError = 'not_logged_in';
      notifyListeners();
      return null;
    }

    final seats = selectedCount;
    _confirmError = null;

    try {
      // Block if there's already a pending or confirmed booking for this ride.
      final existing = await _db
          .collection('bookings')
          .where('rideId', isEqualTo: ride.id)
          .where('passengerId', isEqualTo: user.uid)
          .where('status', whereIn: ['pending', 'confirmed'])
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        _confirmError = 'already_booked';
        notifyListeners();
        return null;
      }

      // Check fresh seat capacity (confirmed bookings only).
      final rideDoc = await _db.collection('rides').doc(ride.id).get();
      final latestBooked = (rideDoc.data()?['bookedSeats'] as num?)?.toInt() ?? 0;
      final latestTotal = (rideDoc.data()?['totalSeats'] as num?)?.toInt() ?? 0;
      if (latestTotal > 0 && latestBooked + seats > latestTotal) {
        _confirmError = 'not_enough_seats';
        notifyListeners();
        return null;
      }

      final bookingRef = _db.collection('bookings').doc();
      final booking = BookingModel(
        id: bookingRef.id,
        rideId: ride.id,
        passengerId: user.uid,
        passengerName: user.name,
        passengerGender: user.gender,
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
        status: 'pending',
        createdAt: DateTime.now(),
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
      );

      await bookingRef.set(booking.toMap());
      return booking;
    } catch (e) {
      final raw = e.toString();
      _confirmError = raw.contains('permission-denied') || raw.contains('PERMISSION_DENIED')
          ? 'permission_denied'
          : 'booking_failed';
      notifyListeners();
      return null;
    }
  }

  /// Driver accepts a pending booking — marks it confirmed and reserves seats.
  /// Returns true on success, false if seats are full or an error occurs.
  Future<bool> acceptBooking(BookingModel booking) async {
    final rideRef = _db.collection('rides').doc(booking.rideId);
    final bookingRef = _db.collection('bookings').doc(booking.id);
    try {
      await _db.runTransaction((tx) async {
        final rideSnap = await tx.get(rideRef);
        final booked = (rideSnap.data()!['bookedSeats'] as num?)?.toInt() ?? 0;
        final total = (rideSnap.data()!['totalSeats'] as num?)?.toInt() ?? 0;
        if (total > 0 && booked + booking.seatsBooked > total) {
          throw Exception('not_enough_seats');
        }
        tx.update(bookingRef, {'status': 'confirmed'});
        tx.update(rideRef, {'bookedSeats': FieldValue.increment(booking.seatsBooked)});
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Driver rejects a pending booking request.
  Future<void> rejectBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({'status': 'rejected'});
  }

  /// Live stream of pending booking requests for a specific ride (driver only).
  Stream<List<BookingModel>> pendingBookingsStream(String rideId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(BookingModel.fromDoc).toList();
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return list;
        });
  }

  /// Stream that emits the current user's active (pending or confirmed)
  /// booking for [rideId], or null if none exists.
  Stream<BookingModel?> existingBookingStream(String rideId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('passengerId', isEqualTo: uid)
        .where('status', whereIn: ['pending', 'confirmed'])
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : BookingModel.fromDoc(snap.docs.first));
  }

  /// Stream of confirmed bookings for a specific ride (passenger seat view).
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

  /// Live stream of confirmed bookings for a ride — driver only.
  /// Includes driverId filter so Firestore security rules are satisfied.
  Stream<List<BookingModel>> driverRideBookingsStream(String rideId) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snap) {
          final bookings = snap.docs
              .map((doc) {
                try {
                  return BookingModel.fromDoc(doc);
                } catch (_) {
                  return null;
                }
              })
              .whereType<BookingModel>()
              .toList();
          bookings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return bookings;
        });
  }

  /// One-shot fetch of all confirmed bookings for a ride (driver route planning).
  Future<List<BookingModel>> rideBookingsOnce(String rideId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'confirmed')
        .get();
    return snap.docs
        .map((doc) {
          try {
            return BookingModel.fromDoc(doc);
          } catch (e) {
            debugPrint('⚠️ Skipping malformed booking ${doc.id}: $e');
            return null;
          }
        })
        .whereType<BookingModel>()
        .toList();
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

  /// Cancels a booking. Only decrements bookedSeats if the booking was
  /// already confirmed (pending requests never reserved a seat).
  /// If the ride document is missing (deleted/cancelled by driver) the
  /// booking is still cancelled — seat count adjustment is skipped.
  Future<void> cancelBooking(BookingModel booking) async {
    final bookingRef = _db.collection('bookings').doc(booking.id);
    if (booking.status == 'confirmed') {
      final rideRef = _db.collection('rides').doc(booking.rideId);
      try {
        await _db.runTransaction((tx) async {
          final rideSnap = await tx.get(rideRef);
          tx.update(bookingRef, {'status': 'cancelled'});
          if (rideSnap.exists) {
            tx.update(rideRef,
                {'bookedSeats': FieldValue.increment(-booking.seatsBooked)});
          }
        });
      } catch (_) {
        // Transaction failed (e.g. permission denied on ride) —
        // still cancel the booking on its own so the user is unblocked.
        await bookingRef.update({'status': 'cancelled'});
      }
    } else {
      await bookingRef.update({'status': 'cancelled'});
    }
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