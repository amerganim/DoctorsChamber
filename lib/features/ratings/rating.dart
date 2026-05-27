import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  const Rating({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.stars,
    required this.text,
    required this.createdAt,
    required this.bookingId,
  });

  final String id;
  final String doctorId;
  final String patientId;
  final int stars;
  final String text;
  final DateTime createdAt;
  final String bookingId;

  factory Rating.fromMap(String id, Map<String, dynamic> map) {
    return Rating(
      id: id,
      doctorId: (map['doctorId'] as String?) ?? '',
      patientId: (map['patientId'] as String?) ?? '',
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      text: (map['text'] as String?) ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookingId: (map['bookingId'] as String?) ?? '',
    );
  }
}

class RatingSummary {
  const RatingSummary({required this.count, required this.average});

  final int count;
  final double average;

  static const empty = RatingSummary(count: 0, average: 0);
}
