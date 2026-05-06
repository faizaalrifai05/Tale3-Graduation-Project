import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String driverId;
  final String passengerId;
  final String passengerName;
  final String rideId;
  final String bookingId;
  final int stars;
  final String comment;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.driverId,
    required this.passengerId,
    required this.passengerName,
    required this.rideId,
    required this.bookingId,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      driverId: d['driverId'] as String? ?? '',
      passengerId: d['passengerId'] as String? ?? '',
      passengerName: d['passengerName'] as String? ?? '',
      rideId: d['rideId'] as String? ?? '',
      bookingId: d['bookingId'] as String? ?? '',
      stars: (d['stars'] as num?)?.toInt() ?? 5,
      comment: d['comment'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'driverId': driverId,
        'passengerId': passengerId,
        'passengerName': passengerName,
        'rideId': rideId,
        'bookingId': bookingId,
        'stars': stars,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
