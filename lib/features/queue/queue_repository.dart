import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'queue.dart';

class QueueRepository {
  QueueRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _queueDoc(
      String chamberId, String date) {
    return _firestore
        .collection('chambers')
        .doc(chamberId)
        .collection('queues')
        .doc(date);
  }

  CollectionReference<Map<String, dynamic>> _entriesCol(
      String chamberId, String date) {
    return _queueDoc(chamberId, date).collection('entries');
  }

  Stream<Queue?> watchQueue(String chamberId, String date) {
    return _queueDoc(chamberId, date).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      return Queue.fromMap(data);
    });
  }

  Stream<List<QueueEntry>> watchEntries(String chamberId, String date) {
    return _entriesCol(chamberId, date)
        .orderBy('serial')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QueueEntry.fromMap(d.id, d.data())).toList());
  }

  Future<void> openQueue(String chamberId, String date) async {
    await _queueDoc(chamberId, date).set({
      'chamberId': chamberId,
      'date': date,
      'status': QueueStatus.open.name,
      'doctorStatus': DoctorStatus.available.name,
      'statusNote': '',
      'openedAt': FieldValue.serverTimestamp(),
      'closedAt': null,
    }, SetOptions(merge: true));
  }

  Future<void> closeQueue(String chamberId, String date) async {
    await _queueDoc(chamberId, date).set({
      'status': QueueStatus.closed.name,
      'doctorStatus': DoctorStatus.doneForDay.name,
      'closedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> reopenQueue(String chamberId, String date) async {
    await _queueDoc(chamberId, date).set({
      'status': QueueStatus.open.name,
      'doctorStatus': DoctorStatus.available.name,
      'closedAt': null,
    }, SetOptions(merge: true));
  }

  Future<void> setDoctorStatus({
    required String chamberId,
    required String date,
    required DoctorStatus status,
    required String note,
  }) async {
    await _queueDoc(chamberId, date).set({
      'doctorStatus': status.name,
      'statusNote': note,
    }, SetOptions(merge: true));
  }

  Future<void> addEntry({
    required String chamberId,
    required String date,
    required String patientName,
    required String patientPhone,
  }) async {
    final snap = await _entriesCol(chamberId, date)
        .orderBy('serial', descending: true)
        .limit(1)
        .get();
    final nextSerial = snap.docs.isEmpty
        ? 1
        : ((snap.docs.first.data()['serial'] as num).toInt() + 1);

    await _entriesCol(chamberId, date).add({
      'serial': nextSerial,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'status': QueueEntryStatus.waiting.name,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus({
    required String chamberId,
    required String date,
    required String entryId,
    required QueueEntryStatus newStatus,
  }) async {
    await _entriesCol(chamberId, date)
        .doc(entryId)
        .update({'status': newStatus.name});
  }

  Future<void> startConsultation({
    required String chamberId,
    required String date,
    required String entryId,
  }) async {
    final batch = _firestore.batch();
    final currentInConsultation = await _entriesCol(chamberId, date)
        .where('status', isEqualTo: QueueEntryStatus.inConsultation.name)
        .get();
    for (final doc in currentInConsultation.docs) {
      if (doc.id != entryId) {
        batch.update(doc.reference, {'status': QueueEntryStatus.done.name});
      }
    }
    batch.update(_entriesCol(chamberId, date).doc(entryId),
        {'status': QueueEntryStatus.inConsultation.name});
    await batch.commit();
  }

  Future<void> deleteEntry({
    required String chamberId,
    required String date,
    required String entryId,
  }) async {
    await _entriesCol(chamberId, date).doc(entryId).delete();
  }

  Future<void> restoreToSerial({
    required String chamberId,
    required String date,
    required String entryId,
    required int newSerial,
  }) async {
    await _entriesCol(chamberId, date).doc(entryId).update({
      'status': QueueEntryStatus.waiting.name,
      'serial': newSerial,
    });
  }
}

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return QueueRepository(FirebaseFirestore.instance);
});

final queueStreamProvider =
    StreamProvider.family<Queue?, QueueKey>((ref, key) {
  return ref.watch(queueRepositoryProvider).watchQueue(key.chamberId, key.date);
});

final queueEntriesStreamProvider =
    StreamProvider.family<List<QueueEntry>, QueueKey>((ref, key) {
  return ref.watch(queueRepositoryProvider).watchEntries(key.chamberId, key.date);
});
