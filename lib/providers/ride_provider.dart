import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

class RideProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthProvider _auth;

  RideProvider(this._auth) {
    _restartRidesListener();
    _restartMyRidesListener();
  }

  void updateAuth(AuthProvider auth) {
    _auth = auth;
    _restartRidesListener();
    _restartMyRidesListener();
    notifyListeners();
  }

  @override
  void dispose() {
    _ridesSub?.cancel();
    _ridesController.close();
    _myRidesSub?.cancel();
    _myRidesController.close();
    super.dispose();
  }

  // ── Form state ─────────────────────────────────────────────────────────────
  String _origin = '';
  String _destination = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final Set<int> _selectedSeats = {1, 2, 3, 4};
  int _price = 0;
  bool _acChecked = true;
  bool _luggageChecked = true;
  bool _petsChecked = false;
  bool _noSmokingChecked = true;
  String _additionalNotes = '';
  bool _isPublishing = false;

  // ── Price from admin ───────────────────────────────────────────────────────
  int? _adminPrice;
  bool _loadingPrice = false;
  String _priceError = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  String get origin => _origin;
  String get destination => _destination;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  int get seats => _selectedSeats.length;
  Set<int> get selectedSeats => Set.unmodifiable(_selectedSeats);
  int get price => _price;
  bool get acChecked => _acChecked;
  bool get luggageChecked => _luggageChecked;
  bool get petsChecked => _petsChecked;
  bool get noSmokingChecked => _noSmokingChecked;
  String get additionalNotes => _additionalNotes;
  bool get isPublishing => _isPublishing;
  int? get adminPrice => _adminPrice;
  bool get loadingPrice => _loadingPrice;
  String get priceError => _priceError;
  bool get hasAdminPrice => _adminPrice != null;

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

  void setOrigin(String v) {
    _origin = v;
    _adminPrice = null;
    _priceError = '';
    notifyListeners();
    if (_origin.isNotEmpty && _destination.isNotEmpty) fetchRoutePrice();
  }

  void setDestination(String v) {
    _destination = v;
    _adminPrice = null;
    _priceError = '';
    notifyListeners();
    if (_origin.isNotEmpty && _destination.isNotEmpty) fetchRoutePrice();
  }

  void setDate(DateTime d) { _selectedDate = d; notifyListeners(); }
  void setTime(TimeOfDay t) { _selectedTime = t; notifyListeners(); }
  void tapSeat(int index) {
    if (index < 1 || index > 4) return;
    if (_selectedSeats.contains(index)) {
      if (_selectedSeats.length > 1) _selectedSeats.remove(index);
    } else {
      _selectedSeats.add(index);
    }
    notifyListeners();
  }
  void toggleAc(bool v) { _acChecked = v; notifyListeners(); }
  void toggleLuggage(bool v) { _luggageChecked = v; notifyListeners(); }
  void togglePets(bool v) { _petsChecked = v; notifyListeners(); }
  void toggleNoSmoking(bool v) { _noSmokingChecked = v; notifyListeners(); }
  void setAdditionalNotes(String v) { _additionalNotes = v; notifyListeners(); }

  // ── Fetch route price from admin ──────────────────────────────────────────

  Future<void> fetchRoutePrice() async {
    if (_origin.trim().isEmpty || _destination.trim().isEmpty) return;

    _loadingPrice = true;
    _adminPrice = null;
    _priceError = '';
    notifyListeners();

    try {
      // Try direct direction: origin → destination
      final snap = await _db
          .collection('routes')
          .where('fromCity', isEqualTo: _origin.trim())
          .where('toCity', isEqualTo: _destination.trim())
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        _adminPrice = (snap.docs.first.data()['basePrice'] as num).toInt();
        _price = _adminPrice!;
      } else {
        // Try reverse direction: destination → origin
        final reverseSnap = await _db
            .collection('routes')
            .where('fromCity', isEqualTo: _destination.trim())
            .where('toCity', isEqualTo: _origin.trim())
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();

        if (reverseSnap.docs.isNotEmpty) {
          _adminPrice =
              (reverseSnap.docs.first.data()['basePrice'] as num).toInt();
          _price = _adminPrice!;
        } else {
          _priceError = 'No price set for this route yet. Contact admin.';
        }
      }
    } catch (e) {
      debugPrint('fetchRoutePrice error: $e');
      _priceError = 'Could not fetch route price.';
    }

    _loadingPrice = false;
    notifyListeners();
  }

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
    _selectedSeats
      ..clear()
      ..addAll({1, 2, 3, 4});
    _price = 0;
    _acChecked = true;
    _luggageChecked = true;
    _petsChecked = false;
    _noSmokingChecked = true;
    _additionalNotes = '';
    _adminPrice = null;
    _priceError = '';
    _loadingPrice = false;
    notifyListeners();
  }

  // ── Publish ───────────────────────────────────────────────────────────────

  Future<String?> publishRide({
    required String driverId,
    required String driverName,
  }) async {
    final user = _auth.currentUser;

    if (user == null) return 'Not logged in.';

    if (user.verificationStatus != VerificationStatus.verified) {
      return 'Your account is not verified yet. Please submit your ID for verification and wait for admin approval.';
    }

    if (user.isBlocked) {
      return 'Your account has been blocked. Please contact support.';
    }

    if (_adminPrice == null) {
      return 'No price has been set for this route by the admin yet.';
    }

    _isPublishing = true;
    notifyListeners();

    try {
      await _db.collection('rides').add({
        'driverId': driverId,
        'driverName': driverName,
        'carMake': user.carMake,
        'carModel': user.carModel,
        'carColor': user.carColor,
        'plateNumber': user.plateNumber,
        'origin': _origin.trim(),
        'destination': _destination.trim(),
        'date': dateIso,
        'time': timeLabel,
        'totalSeats': _selectedSeats.length,
        'bookedSeats': 0,
        'pricePerSeat': _adminPrice,
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

  // ── Cancel ride ──────────────────────────────────────────────────────────

  Future<void> cancelRide(String rideId) async {
    final uid = _auth.currentUser?.uid;
    // Cancel both confirmed and pending bookings for this ride.
    final confirmedSnap = await _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'confirmed')
        .get();
    final pendingSnap = await _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _db.batch();
    batch.update(_db.collection('rides').doc(rideId), {'status': 'cancelled'});
    for (final doc in [...confirmedSnap.docs, ...pendingSnap.docs]) {
      batch.update(doc.reference, {'status': 'cancelled'});
    }
    await batch.commit();
  }

  Future<void> startRide(String rideId) async {
    await _db.collection('rides').doc(rideId).update({'status': 'live'});
  }

  Future<void> announceArrival(String rideId) async {
    await _db.collection('rides').doc(rideId).update({'driverArrived': true});
  }

  /// Marks a ride and all its bookings (confirmed + pending) as 'completed'.
  Future<void> completeRide(String rideId) async {
    final uid = _auth.currentUser?.uid;
    // Fetch both confirmed AND pending bookings so none are missed
    final confirmedSnap = await _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'confirmed')
        .get();
    final pendingSnap = await _db
        .collection('bookings')
        .where('rideId', isEqualTo: rideId)
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _db.batch();
    batch.update(
        _db.collection('rides').doc(rideId), {'status': 'completed'});
    for (final doc in [...confirmedSnap.docs, ...pendingSnap.docs]) {
      batch.update(doc.reference, {'status': 'completed'});
    }
    await batch.commit();
  }

  // ── Available rides stream (persistent, auth-aware) ──────────────────────

  final _ridesController = StreamController<List<RideModel>>.broadcast();
  StreamSubscription<QuerySnapshot>? _ridesSub;
  List<RideModel> _lastRides = const [];

  Stream<List<RideModel>> get availableRidesStream => _ridesController.stream;
  List<RideModel> get lastAvailableRides => List.unmodifiable(_lastRides);

  void _restartRidesListener() {
    _ridesSub?.cancel();
    final uid = _auth.currentUser?.uid;
    _ridesSub = _db
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen(
      (snap) {
        final now = DateTime.now();
        final todayStr = '${now.year}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';
        final rides = snap.docs
            .map(RideModel.fromDoc)
            .where((r) =>
                r.driverId != uid &&
                !r.isFull &&
                r.date.compareTo(todayStr) >= 0)
            .toList();
        rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _lastRides = rides;
        if (!_ridesController.isClosed) _ridesController.add(rides);
      },
      onError: (e) => debugPrint('availableRides stream error: $e'),
    );
  }

  /// Fetch a single ride by ID — used by deep link handler.
  Future<RideModel?> getRideById(String rideId) async {
    try {
      final doc = await _db.collection('rides').doc(rideId).get();
      if (!doc.exists) return null;
      return RideModel.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  /// Emits the driver's currently live ride, or null if none.
  Stream<RideModel?> get liveRideStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db
        .collection('rides')
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: 'live')
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : RideModel.fromDoc(snap.docs.first));
  }

  // ── My rides stream (persistent, auth-aware) ─────────────────────────────

  final _myRidesController = StreamController<List<RideModel>>.broadcast();
  StreamSubscription<QuerySnapshot>? _myRidesSub;
  List<RideModel> _lastMyRides = const [];

  Stream<List<RideModel>> get myRidesStream => _myRidesController.stream;
  List<RideModel> get lastMyRides => List.unmodifiable(_lastMyRides);

  void _restartMyRidesListener() {
    _myRidesSub?.cancel();
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _myRidesSub = _db
        .collection('rides')
        .where('driverId', isEqualTo: uid)
        .snapshots()
        .listen(
      (snap) {
        final rides = snap.docs.map(RideModel.fromDoc).toList();
        rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _lastMyRides = rides;
        if (!_myRidesController.isClosed) _myRidesController.add(rides);
      },
      onError: (e) => debugPrint('myRides stream error: $e'),
    );
  }

  /// Stream that emits the count of completed rides for a driver.
  /// Updates live every time a ride is marked completed.
  Stream<int> completedRidesCountStream(String driverId) {
    if (driverId.isEmpty) return Stream.value(0);
    return _db
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}