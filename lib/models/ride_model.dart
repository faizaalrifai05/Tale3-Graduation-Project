import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final String origin;
  final String destination;
  final String date;       // "2026-10-15"
  final String time;       // "14:30"
  final int totalSeats;
  final int availableSeats;
  final int price;
  final bool acEnabled;
  final bool luggageAllowed;
  final bool petsAllowed;
  final bool noSmoking;
  final String notes;
  final String status;     // "active" | "completed" | "cancelled"
  final DateTime? createdAt;

  const RideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.totalSeats,
    required this.availableSeats,
    required this.price,
    required this.acEnabled,
    required this.luggageAllowed,
    required this.petsAllowed,
    required this.noSmoking,
    required this.notes,
    required this.status,
    this.createdAt,
  });

  factory RideModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final features = d['features'] as Map<String, dynamic>? ?? {};
    return RideModel(
      id: doc.id,
      driverId: d['driverId'] as String? ?? '',
      driverName: d['driverName'] as String? ?? '',
      origin: d['origin'] as String? ?? '',
      destination: d['destination'] as String? ?? '',
      date: d['date'] as String? ?? '',
      time: d['time'] as String? ?? '',
      totalSeats: (d['totalSeats'] as num?)?.toInt() ?? 0,
      availableSeats: (d['availableSeats'] as num?)?.toInt() ?? 0,
      price: (d['price'] as num?)?.toInt() ?? 0,
      acEnabled: features['ac'] as bool? ?? false,
      luggageAllowed: features['luggage'] as bool? ?? false,
      petsAllowed: features['pets'] as bool? ?? false,
      noSmoking: features['noSmoking'] as bool? ?? false,
      notes: d['notes'] as String? ?? '',
      status: d['status'] as String? ?? 'active',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'driverId': driverId,
        'driverName': driverName,
        'origin': origin,
        'destination': destination,
        'date': date,
        'time': time,
        'totalSeats': totalSeats,
        'availableSeats': availableSeats,
        'price': price,
        'features': {
          'ac': acEnabled,
          'luggage': luggageAllowed,
          'pets': petsAllowed,
          'noSmoking': noSmoking,
        },
        'notes': notes,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'bookings': [],
      };
}
