import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/booking_model.dart';
import 'auth_provider.dart';

class BookingProvider extends ChangeNotifier {
  static const int _passengerSlots = 4;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthProvider _auth;

  BookingProvider(this._auth) {
    _restartMyBookingsListener();
  }

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    _restartMyBookingsListener();
    notifyListeners();
  }

  @override
  void dispose() {
    _myBookingsSub?.cancel();
    _myBookingsController.close();
    super.dispose();
  }

  RideModel? _currentRide;

  // Seat states: 0=available, 1=selected, 2=occupied, 3=driver, 4=non-existent
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

  String? _rawError;
  String? get rawError => _rawError;

  /// Initialises the seat map from [ride]'s real-time booked / pending / total counts.
  void initFromRide(RideModel ride) {
    _currentRide = ride;
    // Use specific indices if stored, fall back to sequential for legacy rides.
    final indices = ride.seatIndices.isNotEmpty
        ? ride.seatIndices
        : List.generate(ride.totalSeats, (i) => i + 1);
    final indexSet = indices.toSet();
    final sorted = indices.toList()..sort();

    for (int i = 1; i <= _passengerSlots; i++) {
      if (!indexSet.contains(i)) {
        _seatStates[i] = 4; // non-existent
      } else {
        final pos = sorted.indexOf(i);
        if (pos < ride.bookedSeats) {
          _seatStates[i] = 2; // occupied
        } else if (pos < ride.bookedSeats + ride.pendingSeats) {
          _seatStates[i] = 5; // pending
        } else {
          _seatStates[i] = 0; // available
        }
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

  /// seat index → gender string for pending seats (populated from ride document).
  final Map<int, String> _pendingGenders = {};
  Map<int, String> get pendingGenders => Map.unmodifiable(_pendingGenders);

  /// Keeps seat states in sync using exact seat indices for pending requests.
  /// [seatIndices] lists which seat positions exist (driver's selection).
  /// [pendingGenders] maps seat index → gender so one notifyListeners covers both.
  void updateSeatsExact(
    int confirmedCount,
    List<int> pendingIndices,
    List<int> seatIndices, {
    Map<int, String> pendingGenders = const {},
  }) {
    _pendingGenders..clear()..addAll(pendingGenders);
    final indexSet = seatIndices.toSet();
    final sorted = seatIndices.toList()..sort();

    for (int i = 1; i <= _passengerSlots; i++) {
      if (!indexSet.contains(i)) {
        _seatStates[i] = 4; // non-existent
      } else {
        final pos = sorted.indexOf(i);
        if (pos < confirmedCount) {
          if (_seatStates[i] != 1) _seatStates[i] = 2;
        } else if (pendingIndices.contains(i)) {
          if (_seatStates[i] != 1) _seatStates[i] = 5;
        } else {
          if (_seatStates[i] == 2 || _seatStates[i] == 4 || _seatStates[i] == 5) {
            _seatStates[i] = 0;
          }
        }
      }
    }
    notifyListeners();
  }

  /// Keeps seat states in sync with the live confirmed + pending booking streams.
  void updateAllSeats(int confirmedCount, int pendingCount, int totalSeats) {
    for (int i = 1; i <= _passengerSlots; i++) {
      if (i > totalSeats) {
        _seatStates[i] = 4; // non-existent
      } else if (i <= confirmedCount) {
        if (_seatStates[i] != 1) _seatStates[i] = 2; // confirmed / occupied
      } else if (i <= confirmedCount + pendingCount) {
        if (_seatStates[i] != 1) _seatStates[i] = 5; // pending request
      } else {
        if (_seatStates[i] == 2 || _seatStates[i] == 4 || _seatStates[i] == 5) {
          _seatStates[i] = 0;
        }
      }
    }
    notifyListeners();
  }

  /// Writes a pending booking request to Firestore and increments pendingSeats.
  /// Does NOT reserve seats — the driver must accept first.
  /// Returns the created [BookingModel] or null on failure.
  Future<BookingModel?> confirmBooking({
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    String? passengerGender,
  }) async {
    final ride = _currentRide;
    final user = _auth.currentUser;

    if (ride == null || selectedCount == 0) {
      debugPrint('❌ confirmBooking: ride=$ride, selectedCount=$selectedCount — early exit');
      _confirmError = 'booking_failed';
      notifyListeners();
      return null;
    }

    if (user == null) {
      debugPrint('❌ confirmBooking: user is null');
      _confirmError = 'not_logged_in';
      notifyListeners();
      return null;
    }

    final seats = selectedCount;
    debugPrint('📋 confirmBooking: seats=$seats, ride=${ride.id}, uid=${user.uid}');
    _confirmError = null;

    try {
      // Block if there's already a pending or confirmed booking for this ride.
      // Use a simple 2-field query (no whereIn) to avoid needing a composite index.
      debugPrint('📋 confirmBooking: checking for existing booking...');
      final existingSnap = await _db
          .collection('bookings')
          .where('rideId', isEqualTo: ride.id)
          .where('passengerId', isEqualTo: user.uid)
          .get();
      final hasActive = existingSnap.docs.any((d) {
        final s = d.data()['status'] as String? ?? '';
        return s == 'pending' || s == 'confirmed';
      });
      if (hasActive) {
        debugPrint('📋 confirmBooking: already_booked');
        _confirmError = 'already_booked';
        notifyListeners();
        return null;
      }

      // Pre-generate the booking ref so we can use its ID in BookingModel.
      final bookingRef = _db.collection('bookings').doc();
      final rideRef = _db.collection('rides').doc(ride.id);

      // Capture selected seat indices BEFORE the transaction (stable snapshot).
      final selectedIndices = _seatStates.entries
          .where((e) => e.value == 1)
          .map((e) => e.key)
          .toList()..sort();

      debugPrint('📋 confirmBooking: selectedIndices=$selectedIndices');

      BookingModel? booking;

      // Transaction: atomically create the booking + increment pendingSeats only.
      debugPrint('📋 confirmBooking: starting transaction...');
      await _db.runTransaction((tx) async {
        final rideSnap = await tx.get(rideRef);
        final latestBooked = (rideSnap.data()?['bookedSeats'] as num?)?.toInt() ?? 0;
        final latestPending = (rideSnap.data()?['pendingSeats'] as num?)?.toInt() ?? 0;
        final latestTotal = (rideSnap.data()?['totalSeats'] as num?)?.toInt() ?? 0;
        if (latestTotal > 0 && latestBooked + latestPending + seats > latestTotal) {
          throw Exception('not_enough_seats');
        }
        booking = BookingModel(
          id: bookingRef.id,
          rideId: ride.id,
          passengerId: user.uid,
          passengerName: user.name.isNotEmpty
              ? user.name
              : user.email.split('@').first,
          passengerGender: passengerGender ?? user.gender,
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

        debugPrint('📋 confirmBooking: writing booking + pendingSeats...');
        tx.set(bookingRef, booking!.toMap());
        tx.update(rideRef, {
          'pendingSeats': FieldValue.increment(seats),
        });
      });
      debugPrint('📋 confirmBooking: transaction succeeded');

      // Post-transaction: write gender entries for seat-map display (best-effort).
      // Done separately so a rules mismatch here never kills the booking itself.
      if (booking != null && selectedIndices.isNotEmpty) {
        try {
          final genderParts = (passengerGender ?? user.gender).split(',');
          final genderEntry = List.generate(selectedIndices.length, (i) {
            final g = i < genderParts.length ? genderParts[i].trim() : 'unknown';
            return '${selectedIndices[i]}:$g';
          }).join(',');
          await rideRef.update({
            'pendingGenderEntries.${bookingRef.id}': genderEntry,
          });
        } catch (e) {
          debugPrint('⚠️ pendingGenderEntries write failed (non-critical): $e');
        }
      }

      return booking;
    } catch (e) {
      final raw = e.toString();
      debugPrint('❌ confirmBooking error: $raw');
      _rawError = raw;
      if (raw.contains('not_enough_seats')) {
        _confirmError = 'not_enough_seats';
      } else if (raw.contains('permission-denied') || raw.contains('PERMISSION_DENIED')) {
        _confirmError = 'permission_denied';
      } else if (raw.contains('already_booked')) {
        _confirmError = 'already_booked';
      } else {
        _confirmError = 'booking_failed';
      }
      notifyListeners();
      return null;
    }
  }

  /// Fetches display name, photo URL, and rating for a passenger.
  /// Runs user-doc read and passengerRatings query in parallel so rating is
  /// always accurate even when the user document is missing or stale.
  Future<({String name, String photoUrl, double averageRating, int ratingCount})>
      fetchPassengerInfo(String uid, {String fallbackName = ''}) async {
    if (uid.isEmpty) {
      return (name: fallbackName, photoUrl: '', averageRating: 0.0, ratingCount: 0);
    }
    try {
      final results = await Future.wait([
        _db.collection('users').doc(uid).get(),
        _db.collection('passengerRatings').where('passengerId', isEqualTo: uid).get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final ratingsSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;

      String name = fallbackName;
      String photoUrl = '';

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        name = (data['name'] as String? ?? '').trim();
        if (name.isEmpty) {
          final email = (data['email'] as String? ?? '').trim();
          name = email.isNotEmpty ? email.split('@').first : fallbackName;
        }
        photoUrl = (data['photoUrl'] as String? ?? '').trim();
      }

      final ratingDocs = ratingsSnap.docs;
      final ratingCount = ratingDocs.length;
      final averageRating = ratingCount == 0
          ? 0.0
          : ratingDocs.fold<double>(
                  0,
                  (acc, d) =>
                      acc + ((d.data()['stars'] as num?)?.toDouble() ?? 0)) /
              ratingCount;

      // Heal stale user-doc cache in the background (no-await).
      if (ratingCount > 0 && userDoc.exists) {
        _db.collection('users').doc(uid).update({
          'averageRating': double.parse(averageRating.toStringAsFixed(1)),
          'ratingCount': ratingCount,
        }).catchError((_) {});
      }

      return (name: name, photoUrl: photoUrl, averageRating: double.parse(averageRating.toStringAsFixed(1)), ratingCount: ratingCount);
    } catch (e) {
      debugPrint('👤 fetchPassengerInfo ERROR ($uid): $e');
      return (name: fallbackName, photoUrl: '', averageRating: 0.0, ratingCount: 0);
    }
  }

  /// Driver marks arrival at a specific passenger's pickup location.
  Future<void> markDriverArrivedForBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'driverArrivedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Driver accepts a pending booking — marks it confirmed and reserves seats.
  ///
  /// After confirming, automatically withdraws every OTHER pending booking the
  /// same passenger made for rides on the same date + time + origin +
  /// destination (duplicate requests). This prevents a passenger from being
  /// on multiple rides at the same time once one driver accepts them.
  ///
  /// Returns true on success, false if seats are full or an error occurs.
  Future<bool> acceptBooking(BookingModel booking) async {
    final rideRef = _db.collection('rides').doc(booking.rideId);
    final bookingRef = _db.collection('bookings').doc(booking.id);
    try {
      // ── Step 1: Confirm this booking (existing transaction logic) ──────────
      await _db.runTransaction((tx) async {
        final rideSnap = await tx.get(rideRef);
        final rideStatus = rideSnap.data()!['status'] as String? ?? 'active';
        if (rideStatus != 'active') throw Exception('ride_not_accepting');
        final booked = (rideSnap.data()!['bookedSeats'] as num?)?.toInt() ?? 0;
        final total = (rideSnap.data()!['totalSeats'] as num?)?.toInt() ?? 0;
        if (total > 0 && booked + booking.seatsBooked > total) {
          throw Exception('not_enough_seats');
        }
        tx.update(bookingRef, {'status': 'confirmed'});
        tx.update(rideRef, {
          'bookedSeats': FieldValue.increment(booking.seatsBooked),
          'pendingSeats': FieldValue.increment(-booking.seatsBooked),
          'pendingGenderEntries.${booking.id}': FieldValue.delete(),
        });
      });

      // ── Step 2: Auto-withdraw conflicting duplicate requests ────────────────
      // Find all OTHER pending bookings by this passenger for rides on the
      // same date, same time, same origin, same destination.
      // We query by passengerId + date + origin + destination then filter
      // for status=pending and rideId != this ride in Dart (avoids needing
      // a composite Firestore index on 5 fields).
      await _cancelConflictingBookings(booking);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cancels all pending booking requests made by [acceptedBooking.passengerId]
  /// that overlap with the just-accepted booking (same date, origin, destination)
  /// but belong to a DIFFERENT ride.
  ///
  /// For each cancelled booking we also decrement pendingSeats on its ride
  /// so the seat counts stay accurate.
  Future<void> _cancelConflictingBookings(BookingModel acceptedBooking) async {
    try {
      // Query: same passenger, same date, same origin, same destination.
      // Firestore requires an index for multi-field queries; using the minimum
      // set of indexed fields and filtering the rest in Dart.
      final snap = await _db
          .collection('bookings')
          .where('passengerId', isEqualTo: acceptedBooking.passengerId)
          .where('date', isEqualTo: acceptedBooking.date)
          .where('origin', isEqualTo: acceptedBooking.origin)
          .where('destination', isEqualTo: acceptedBooking.destination)
          .get();

      // Keep only: pending status + different ride + same time.
      final conflicts = snap.docs.where((d) {
        final s = d.data()['status'] as String? ?? '';
        final rid = d.data()['rideId'] as String? ?? '';
        final t = d.data()['time'] as String? ?? '';
        return s == 'pending' &&
            rid != acceptedBooking.rideId &&
            t == acceptedBooking.time;
      }).toList();

      if (conflicts.isEmpty) return;

      // Cancel each conflicting booking and decrement pendingSeats on its ride.
      // Use individual transactions so a failure on one doesn't roll back others.
      for (final doc in conflicts) {
        final conflictBooking = BookingModel.fromDoc(doc);
        final conflictRideRef =
            _db.collection('rides').doc(conflictBooking.rideId);
        final conflictBookingRef =
            _db.collection('bookings').doc(conflictBooking.id);
        try {
          await _db.runTransaction((tx) async {
            final rideSnap = await tx.get(conflictRideRef);
            tx.update(conflictBookingRef, {
              'status': 'cancelled',
              'cancellationReason': 'auto_withdrawn_accepted_elsewhere',
            });
            if (rideSnap.exists) {
              tx.update(conflictRideRef, {
                'pendingSeats': FieldValue.increment(-conflictBooking.seatsBooked),
                'pendingGenderEntries.${conflictBooking.id}':
                    FieldValue.delete(),
              });
            }
          });
          debugPrint(
              '✅ Auto-withdrawn conflicting booking ${conflictBooking.id} '
              'on ride ${conflictBooking.rideId}');
        } catch (e) {
          debugPrint(
              '⚠️ Failed to auto-withdraw booking ${conflictBooking.id}: $e');
        }
      }
    } catch (e) {
      // Non-fatal: the main booking was already confirmed.
      // Log but don't surface to the driver.
      debugPrint('_cancelConflictingBookings error: \$e');
    }
  }

  /// Driver rejects a pending booking request.
  Future<void> rejectBooking(BookingModel booking) async {
    try {
      final batch = _db.batch();
      batch.update(_db.collection('bookings').doc(booking.id), {'status': 'rejected'});
      batch.update(_db.collection('rides').doc(booking.rideId), {
        'pendingSeats': FieldValue.increment(-booking.seatsBooked),
        'pendingGenderEntries.${booking.id}': FieldValue.delete(),
      });
      await batch.commit();
    } catch (e) {
      debugPrint('rejectBooking error: $e');
    }
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

  /// Stream of pending booking requests for a ride — visible to all passengers
  /// so the seat map can show which seats are awaiting driver approval.
  Stream<List<BookingModel>> ridePendingBookingsStream(String rideId) {
    return _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'pending')
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

  // ── My bookings stream (persistent, auth-aware) ───────────────────────────

  final _myBookingsController = StreamController<List<BookingModel>>.broadcast();
  StreamSubscription<QuerySnapshot>? _myBookingsSub;
  List<BookingModel> _lastMyBookings = const [];

  Stream<List<BookingModel>> get myBookingsStream {
    final ctrl = StreamController<List<BookingModel>>();
    ctrl.add(_lastMyBookings);
    final sub = _myBookingsController.stream.listen(ctrl.add, onError: ctrl.addError, onDone: ctrl.close);
    ctrl.onCancel = sub.cancel;
    return ctrl.stream;
  }

  List<BookingModel> get lastMyBookings => List.unmodifiable(_lastMyBookings);

  void _restartMyBookingsListener() {
    _myBookingsSub?.cancel();
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _myBookingsSub = _db
        .collection('bookings')
        .where('passengerId', isEqualTo: uid)
        .snapshots()
        .listen(
      (snap) {
        final bookings = snap.docs.map(BookingModel.fromDoc).toList();
        bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _lastMyBookings = bookings;
        if (!_myBookingsController.isClosed) _myBookingsController.add(bookings);
      },
      onError: (e) => debugPrint('myBookings stream error: $e'),
    );
  }

  /// Cancels a booking. Decrements the appropriate seat counter on the ride:
  /// confirmed → bookedSeats, pending → pendingSeats.
  /// If the ride document is missing the booking is still cancelled.
  Future<void> cancelBooking(BookingModel booking) async {
    final bookingRef = _db.collection('bookings').doc(booking.id);
    if (booking.status == 'confirmed' || booking.status == 'pending') {
      final rideRef = _db.collection('rides').doc(booking.rideId);
      final field = booking.status == 'confirmed' ? 'bookedSeats' : 'pendingSeats';
      try {
        await _db.runTransaction((tx) async {
          final rideSnap = await tx.get(rideRef);
          tx.update(bookingRef, {'status': 'cancelled'});
          if (rideSnap.exists) {
            tx.update(rideRef, {
              field: FieldValue.increment(-booking.seatsBooked),
              if (booking.status == 'pending')
                'pendingGenderEntries.${booking.id}': FieldValue.delete(),
            });
          }
        });
      } catch (_) {
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

  /// Live count of ALL pending booking requests across every ride this driver owns.
  /// Used to show a badge on the "My Trips" nav bar tab.
  /// Emits 0 when there are no pending requests (badge is hidden).
  Stream<int> get totalPendingRequestsStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return _db
        .collection('bookings')
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}