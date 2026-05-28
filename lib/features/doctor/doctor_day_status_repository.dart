import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'doctor_day_status.dart';

class DoctorDayStatusKey {
  const DoctorDayStatusKey(this.doctorId, this.date);

  final String doctorId;
  final String date;

  @override
  bool operator ==(Object other) =>
      other is DoctorDayStatusKey &&
      other.doctorId == doctorId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(doctorId, date);
}

class DoctorDayStatusRepository {
  DoctorDayStatusRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String doctorId, String date) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('dayStatus')
        .doc(date);
  }

  Stream<DoctorDayStatusDoc> watch(String doctorId, String date) {
    return _doc(doctorId, date).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) {
        return DoctorDayStatusDoc(
          doctorId: doctorId,
          date: date,
          status: DoctorDayStatus.available,
          note: '',
        );
      }
      return DoctorDayStatusDoc.fromMap(doctorId, date, data);
    });
  }

  Future<void> set({
    required String doctorId,
    required String date,
    required DoctorDayStatus status,
    required String note,
  }) async {
    await _doc(doctorId, date).set({
      'status': status.name,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final doctorDayStatusRepositoryProvider =
    Provider<DoctorDayStatusRepository>((ref) {
  return DoctorDayStatusRepository(FirebaseFirestore.instance);
});

final doctorDayStatusProvider =
    StreamProvider.family<DoctorDayStatusDoc, DoctorDayStatusKey>(
        (ref, key) {
  return ref
      .watch(doctorDayStatusRepositoryProvider)
      .watch(key.doctorId, key.date);
});
