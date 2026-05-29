import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRoleEnrollment {
  /// Not signed in (or only anonymously) — show every card.
  neither,

  /// Has a doctor profile saved — hide the Admin card.
  doctor,

  /// Has been added to at least one chamber's adminIds — hide the Doctor
  /// card.
  admin,

  /// Both — show both Doctor and Admin cards.
  both;
}

final userRoleEnrollmentProvider =
    FutureProvider<UserRoleEnrollment>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return UserRoleEnrollment.neither;

  final firestore = FirebaseFirestore.instance;

  final doctorDoc = await firestore.collection('doctors').doc(user.uid).get();
  final hasDoctorProfile = doctorDoc.exists &&
      ((doctorDoc.data()?['name'] as String?) ?? '').isNotEmpty;

  final adminChambers = await firestore
      .collection('chambers')
      .where('adminIds', arrayContains: user.uid)
      .limit(1)
      .get();
  final hasAdminChambers = adminChambers.docs.isNotEmpty;

  if (hasDoctorProfile && hasAdminChambers) return UserRoleEnrollment.both;
  if (hasDoctorProfile) return UserRoleEnrollment.doctor;
  if (hasAdminChambers) return UserRoleEnrollment.admin;
  return UserRoleEnrollment.neither;
});
