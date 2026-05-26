import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chamber.dart';

class ChamberRepository {
  ChamberRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _chambers =>
      _firestore.collection('chambers');

  Stream<List<Chamber>> watchByDoctor(String doctorId) {
    return _chambers
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Chamber.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<Chamber>> watchAll() {
    return _chambers.snapshots().map((snap) => snap.docs
        .map((d) => Chamber.fromMap(d.id, d.data()))
        .toList());
  }

  Future<String> add(Chamber chamber) async {
    final ref = await _chambers.add(chamber.toMap());
    return ref.id;
  }

  Future<void> delete(String id) async {
    await _chambers.doc(id).delete();
  }
}

final chamberRepositoryProvider = Provider<ChamberRepository>((ref) {
  return ChamberRepository(FirebaseFirestore.instance);
});

final chambersByDoctorStreamProvider =
    StreamProvider.family<List<Chamber>, String>((ref, doctorId) {
  return ref.watch(chamberRepositoryProvider).watchByDoctor(doctorId);
});

final allChambersStreamProvider = StreamProvider<List<Chamber>>((ref) {
  return ref.watch(chamberRepositoryProvider).watchAll();
});
