import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chambers/chamber.dart';
import 'queue.dart';

const kDevPatientId = 'dev-patient';
const kDevAdminId = 'dev-admin';

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
      'chamberId': chamberId,
      'date': date,
      'bookedBy': 'admin',
      'bookedById': kDevAdminId,
    });
  }

  Future<List<int>> bulkAddEntries({
    required String chamberId,
    required String date,
    required List<({String name, String phone})> patients,
  }) async {
    if (patients.isEmpty) return const [];
    final snap = await _entriesCol(chamberId, date)
        .orderBy('serial', descending: true)
        .limit(1)
        .get();
    var nextSerial = snap.docs.isEmpty
        ? 1
        : ((snap.docs.first.data()['serial'] as num).toInt() + 1);

    final batch = _firestore.batch();
    final assigned = <int>[];
    for (final p in patients) {
      final doc = _entriesCol(chamberId, date).doc();
      batch.set(doc, {
        'serial': nextSerial,
        'patientName': p.name,
        'patientPhone': p.phone,
        'status': QueueEntryStatus.waiting.name,
        'addedAt': FieldValue.serverTimestamp(),
        'chamberId': chamberId,
        'date': date,
        'bookedBy': 'admin',
        'bookedById': kDevAdminId,
      });
      assigned.add(nextSerial);
      nextSerial++;
    }
    await batch.commit();
    return assigned;
  }

  Future<({String? errorMessage, int? assignedSerial})> bookForPatient({
    required Chamber chamber,
    required String date,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required int? age,
  }) async {
    if (chamber.bookingMode == ChamberBookingMode.queueOnly) {
      return (
        errorMessage: 'This chamber is walk-in only.',
        assignedSerial: null,
      );
    }

    final queueSnap = await _queueDoc(chamber.id, date).get();
    final queueData = queueSnap.data();
    if (queueData == null ||
        QueueStatus.fromString(queueData['status'] as String?) !=
            QueueStatus.open) {
      return (
        errorMessage: "Today's queue isn't open yet. Please try later.",
        assignedSerial: null,
      );
    }

    final myExisting = await _entriesCol(chamber.id, date)
        .where('bookedById', isEqualTo: patientId)
        .get();
    for (final doc in myExisting.docs) {
      final status =
          QueueEntryStatus.fromString(doc.data()['status'] as String?);
      if (status.isActive) {
        final existingSerial = (doc.data()['serial'] as num).toInt();
        return (
          errorMessage:
              "You already have an active booking here (#$existingSerial).",
          assignedSerial: null,
        );
      }
    }

    if (chamber.bookingMode == ChamberBookingMode.hybridWithCap) {
      final cap = chamber.dailyAppBookingCap ?? 0;
      if (cap > 0) {
        final existing = await _entriesCol(chamber.id, date)
            .where('bookedBy', isEqualTo: 'patient')
            .get();
        if (existing.docs.length >= cap) {
          return (
            errorMessage:
                "Today's app bookings full. Please call the chamber.",
            assignedSerial: null,
          );
        }
      }
    }

    final snap = await _entriesCol(chamber.id, date)
        .orderBy('serial', descending: true)
        .limit(1)
        .get();
    final nextSerial = snap.docs.isEmpty
        ? 1
        : ((snap.docs.first.data()['serial'] as num).toInt() + 1);

    await _entriesCol(chamber.id, date).add({
      'serial': nextSerial,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'age': age,
      'status': QueueEntryStatus.waiting.name,
      'addedAt': FieldValue.serverTimestamp(),
      'chamberId': chamber.id,
      'date': date,
      'bookedBy': 'patient',
      'bookedById': patientId,
    });

    return (errorMessage: null, assignedSerial: nextSerial);
  }

  Stream<List<QueueEntry>> watchPatientBookings(String patientId) {
    return _firestore
        .collectionGroup('entries')
        .where('bookedById', isEqualTo: patientId)
        .snapshots()
        .map((snap) {
      final entries = snap.docs
          .map((d) => QueueEntry.fromMap(d.id, d.data()))
          .toList();
      entries.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return entries;
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

final patientBookingsStreamProvider =
    StreamProvider.family<List<QueueEntry>, String>((ref, patientId) {
  return ref.watch(queueRepositoryProvider).watchPatientBookings(patientId);
});
