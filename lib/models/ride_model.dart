import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final String carMake;
  final String carModel;
  final String carColor;
  final String plateNumber;
  final String origin;
  final String destination;
  final String date;
  final String time;
  final int totalSeats;
  final int bookedSeats;
  final int pricePerSeat;
  final bool acEnabled;
  final bool luggageEnabled;
  final bool petsAllowed;
  final bool noSmoking;
  final String notes;
  final String status;
  final DateTime createdAt;
  final int pendingSeats;
  final Map<String, String> pendingGenderEntries;
  /// Specific seat indices (1–4) the driver has opened for passengers.
  /// Empty list = legacy ride; treat all 1..totalSeats as open.
  final List<int> seatIndices;

  const RideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.carMake,
    required this.carModel,
    required this.carColor,
    required this.plateNumber,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.totalSeats,
    required this.bookedSeats,
    required this.pricePerSeat,
    required this.acEnabled,
    required this.luggageEnabled,
    required this.petsAllowed,
    required this.noSmoking,
    required this.notes,
    required this.status,
    required this.createdAt,
    this.pendingSeats = 0,
    this.pendingGenderEntries = const {},
    this.seatIndices = const [],
  });

  int get availableSeats {
    final a = totalSeats - bookedSeats;
    return a < 0 ? 0 : a;
  }
  bool get isFull => totalSeats > 0 && availableSeats <= 0;
  String get carShortInfo => '$carMake $carModel';
  String get carFullInfo => '$carMake $carModel \u00b7 $carColor';

  factory RideModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RideModel(
      id: doc.id,
      driverId: d['driverId'] as String? ?? '',
      driverName: d['driverName'] as String? ?? '',
      carMake: d['carMake'] as String? ?? '',
      carModel: d['carModel'] as String? ?? '',
      carColor: d['carColor'] as String? ?? '',
      plateNumber: d['plateNumber'] as String? ?? '',
      origin: d['origin'] as String? ?? '',
      destination: d['destination'] as String? ?? '',
      date: d['date'] as String? ?? '',
      time: d['time'] as String? ?? '',
      totalSeats: (d['totalSeats'] as num?)?.toInt() ?? 0,
      bookedSeats: (d['bookedSeats'] as num?)?.toInt() ?? 0,
      pricePerSeat: (d['pricePerSeat'] as num?)?.toInt() ?? 0,
      acEnabled: d['acEnabled'] as bool? ?? false,
      luggageEnabled: d['luggageEnabled'] as bool? ?? false,
      petsAllowed: d['petsAllowed'] as bool? ?? false,
      noSmoking: d['noSmoking'] as bool? ?? false,
      notes: d['notes'] as String? ?? '',
      status: d['status'] as String? ?? 'active',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pendingSeats: (d['pendingSeats'] as num?)?.toInt() ?? 0,
      pendingGenderEntries: (d['pendingGenderEntries'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      seatIndices: (d['seatIndices'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() => {
        'driverId': driverId,
        'driverName': driverName,
        'carMake': carMake,
        'carModel': carModel,
        'carColor': carColor,
        'plateNumber': plateNumber,
        'origin': origin,
        'destination': destination,
        'date': date,
        'time': time,
        'totalSeats': totalSeats,
        'bookedSeats': bookedSeats,
        'pricePerSeat': pricePerSeat,
        'acEnabled': acEnabled,
        'luggageEnabled': luggageEnabled,
        'petsAllowed': petsAllowed,
        'noSmoking': noSmoking,
        'notes': notes,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'seatIndices': seatIndices,
      };
}
