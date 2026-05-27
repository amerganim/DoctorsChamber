import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rating.dart';

class RatingRepository {
  RatingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ratings(String doctorId) =>
      _firestore.collection('doctors').doc(doctorId).collection('ratings');

  Stream<List<Rating>> watchByDoctor(String doctorId) {
    return _ratings(doctorId).snapshots().map((snap) {
      final list =
          snap.docs.map((d) => Rating.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<Rating?> findForBooking({
    required String doctorId,
    required String bookingId,
  }) async {
    final snap = await _ratings(doctorId)
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return Rating.fromMap(d.id, d.data());
  }

  Future<void> add({
    required String doctorId,
    required String patientId,
    required String bookingId,
    required int stars,
    required String text,
  }) async {
    await _ratings(doctorId).add({
      'doctorId': doctorId,
      'patientId': patientId,
      'bookingId': bookingId,
      'stars': stars,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository(FirebaseFirestore.instance);
});

final ratingsByDoctorStreamProvider =
    StreamProvider.family<List<Rating>, String>((ref, doctorId) {
  return ref.watch(ratingRepositoryProvider).watchByDoctor(doctorId);
});

final ratingSummaryProvider =
    Provider.family<RatingSummary, String>((ref, doctorId) {
  final ratings =
      ref.watch(ratingsByDoctorStreamProvider(doctorId)).value ?? const [];
  if (ratings.isEmpty) return RatingSummary.empty;
  final total = ratings.fold<int>(0, (acc, r) => acc + r.stars);
  return RatingSummary(
    count: ratings.length,
    average: total / ratings.length,
  );
});
