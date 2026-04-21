import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String rideId;
  final String passengerId;
  final String passengerName;
  final String driverId;
  final String driverName;
  final String carInfo;
  final String plateNumber;
  final String origin;
  final String destination;
  final String date;
  final String time;
  final int seatsBooked;
  final int totalPrice;
  final String status;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    required this.driverId,
    required this.driverName,
    required this.carInfo,
    required this.plateNumber,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.seatsBooked,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      rideId: d['rideId'] as String? ?? '',
      passengerId: d['passengerId'] as String? ?? '',
      passengerName: d['passengerName'] as String? ?? '',
      driverId: d['driverId'] as String? ?? '',
      driverName: d['driverName'] as String? ?? '',
      carInfo: d['carInfo'] as String? ?? '',
      plateNumber: d['plateNumber'] as String? ?? '',
      origin: d['origin'] as String? ?? '',
      destination: d['destination'] as String? ?? '',
      date: d['date'] as String? ?? '',
      time: d['time'] as String? ?? '',
      seatsBooked: (d['seatsBooked'] as num?)?.toInt() ?? 0,
      totalPrice: (d['totalPrice'] as num?)?.toInt() ?? 0,
      status: d['status'] as String? ?? 'confirmed',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'rideId': rideId,
        'passengerId': passengerId,
        'passengerName': passengerName,
        'driverId': driverId,
        'driverName': driverName,
        'carInfo': carInfo,
        'plateNumber': plateNumber,
        'origin': origin,
        'destination': destination,
        'date': date,
        'time': time,
        'seatsBooked': seatsBooked,
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
