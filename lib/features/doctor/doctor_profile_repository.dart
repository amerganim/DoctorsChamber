import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'doctor_profile.dart';

// Hardcoded doctor ID used while [[project-phone-auth-billing]] dev bypass is on.
// Replace with FirebaseAuth.instance.currentUser!.uid when real auth is enabled.
const kDevDoctorId = 'dev-doctor';

class DoctorProfileRepository {
  DoctorProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _doctors =>
      _firestore.collection('doctors');

  Stream<DoctorProfile?> watch(String id) {
    return _doctors.doc(id).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      return DoctorProfile.fromMap(id, data);
    });
  }

  Future<DoctorProfile?> fetch(String id) async {
    final snap = await _doctors.doc(id).get();
    final data = snap.data();
    if (!snap.exists || data == null) return null;
    return DoctorProfile.fromMap(id, data);
  }

  Stream<List<DoctorProfile>> watchAll() {
    return _doctors.snapshots().map((snap) => snap.docs
        .map((d) => DoctorProfile.fromMap(d.id, d.data()))
        .where((p) => p.name.isNotEmpty)
        .toList());
  }

  Future<void> save(DoctorProfile profile) async {
    await _doctors
        .doc(profile.id)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}

final doctorProfileRepositoryProvider = Provider<DoctorProfileRepository>((ref) {
  return DoctorProfileRepository(FirebaseFirestore.instance);
});

final doctorProfileStreamProvider =
    StreamProvider.family<DoctorProfile?, String>((ref, id) {
  return ref.watch(doctorProfileRepositoryProvider).watch(id);
});

final allDoctorsStreamProvider = StreamProvider<List<DoctorProfile>>((ref) {
  return ref.watch(doctorProfileRepositoryProvider).watchAll();
});
