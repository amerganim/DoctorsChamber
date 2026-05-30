import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Overridden in main() with a real SharedPreferences instance loaded
/// before runApp, so synchronous reads from prefs are possible everywhere.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in main()');
});

String _cacheKey(String uid) => 'enrollment_$uid';

/// Reads the last-known enrollment for the current user synchronously from
/// SharedPreferences. Returns null if there's no cache hit (first launch or
/// user signed in with a different account).
final cachedEnrollmentProvider = Provider<UserRoleEnrollment?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return null;
  final raw = prefs.getString(_cacheKey(user.uid));
  if (raw == null) return null;
  try {
    return UserRoleEnrollment.values.byName(raw);
  } catch (_) {
    return null;
  }
});

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

  final result = (hasDoctorProfile && hasAdminChambers)
      ? UserRoleEnrollment.both
      : hasDoctorProfile
          ? UserRoleEnrollment.doctor
          : hasAdminChambers
              ? UserRoleEnrollment.admin
              : UserRoleEnrollment.neither;

  // Persist for instant render on the next cold start.
  try {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_cacheKey(user.uid), result.name);
  } catch (_) {
    // Cache miss isn't fatal — display still works.
  }

  return result;
});
