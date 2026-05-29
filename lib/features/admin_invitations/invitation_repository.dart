import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chamber_admin.dart';
import 'invitation.dart';

class InvitationRepository {
  InvitationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _invitations(String chamberId) =>
      _firestore
          .collection('chambers')
          .doc(chamberId)
          .collection('invitations');

  Stream<List<Invitation>> watchForChamber(String chamberId) {
    return _invitations(chamberId).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Invitation.fromMap(d.id, chamberId, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Invitation>> watchForEmail(String email) {
    final lower = email.toLowerCase();
    return _firestore
        .collectionGroup('invitations')
        .where('email', isEqualTo: lower)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Invitation.fromMap(
                d.id, d.reference.parent.parent!.id, d.data()))
            .toList());
  }

  Future<void> invite({
    required String chamberId,
    required String email,
    required String invitedByDoctorId,
    required String invitedByDoctorName,
  }) async {
    final lower = email.toLowerCase().trim();
    await _invitations(chamberId).doc(lower).set({
      'email': lower,
      'invitedByDoctorId': invitedByDoctorId,
      'invitedByDoctorName': invitedByDoctorName,
      'status': InvitationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> revoke({
    required String chamberId,
    required String invitationId,
  }) async {
    await _invitations(chamberId).doc(invitationId).delete();
  }

  Future<void> accept({
    required String chamberId,
    required String invitationId,
    required String adminUid,
    required String adminEmail,
    required String adminDisplayName,
  }) async {
    final batch = _firestore.batch();
    batch.update(
      _firestore.collection('chambers').doc(chamberId),
      {
        'adminIds': FieldValue.arrayUnion([adminUid])
      },
    );
    batch.set(
      _firestore
          .collection('chambers')
          .doc(chamberId)
          .collection('admins')
          .doc(adminUid),
      {
        'email': adminEmail,
        'displayName': adminDisplayName,
        'addedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.update(
      _invitations(chamberId).doc(invitationId),
      {
        'status': InvitationStatus.accepted.name,
        'acceptedAt': FieldValue.serverTimestamp(),
        'acceptedByUid': adminUid,
      },
    );
    await batch.commit();
  }

  Stream<List<ChamberAdmin>> watchAdminsForChamber(String chamberId) {
    return _firestore
        .collection('chambers')
        .doc(chamberId)
        .collection('admins')
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ChamberAdmin.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => a.addedAt.compareTo(b.addedAt));
      return list;
    });
  }

  Future<void> removeAdmin({
    required String chamberId,
    required String adminUid,
  }) async {
    final batch = _firestore.batch();
    batch.update(
      _firestore.collection('chambers').doc(chamberId),
      {
        'adminIds': FieldValue.arrayRemove([adminUid])
      },
    );
    batch.delete(
      _firestore
          .collection('chambers')
          .doc(chamberId)
          .collection('admins')
          .doc(adminUid),
    );
    await batch.commit();
  }

  Future<void> decline({
    required String chamberId,
    required String invitationId,
  }) async {
    await _invitations(chamberId).doc(invitationId).update({
      'status': InvitationStatus.declined.name,
    });
  }
}

final invitationRepositoryProvider = Provider<InvitationRepository>((ref) {
  return InvitationRepository(FirebaseFirestore.instance);
});

final chamberInvitationsStreamProvider =
    StreamProvider.family<List<Invitation>, String>((ref, chamberId) {
  return ref.watch(invitationRepositoryProvider).watchForChamber(chamberId);
});

final emailInvitationsStreamProvider =
    StreamProvider.family<List<Invitation>, String>((ref, email) {
  return ref.watch(invitationRepositoryProvider).watchForEmail(email);
});

final chamberAdminsStreamProvider =
    StreamProvider.family<List<ChamberAdmin>, String>((ref, chamberId) {
  return ref
      .watch(invitationRepositoryProvider)
      .watchAdminsForChamber(chamberId);
});
