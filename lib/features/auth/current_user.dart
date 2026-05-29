import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../doctor/doctor_profile_repository.dart' show kDevDoctorId;
import '../queue/queue_repository.dart' show kDevPatientId;

/// Patient identity for the current device.
///
/// Returns the Firebase Auth UID when anonymous (or any other) sign-in
/// has succeeded; otherwise falls back to the [kDevPatientId] sentinel so
/// the rest of the app keeps working during local development.
String currentPatientId() {
  return FirebaseAuth.instance.currentUser?.uid ?? kDevPatientId;
}

/// Doctor identity for the signed-in doctor.
///
/// Returns the Firebase Auth UID when a non-anonymous provider (Google)
/// has signed in; otherwise falls back to [kDevDoctorId] so dev bypass
/// keeps working.
String currentDoctorId() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return kDevDoctorId;
  return user.uid;
}

/// True when a real (non-anonymous) user is signed in.
bool isDoctorSignedIn() {
  final user = FirebaseAuth.instance.currentUser;
  return user != null && !user.isAnonymous;
}

/// True when a real (non-anonymous) user is signed in (alias for clarity).
bool isAdminSignedIn() => isDoctorSignedIn();

String? currentUserEmail() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return null;
  return user.email?.toLowerCase();
}

String? currentUserDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.isAnonymous) return null;
  return user.displayName;
}

/// Sign the doctor out of Google + Firebase, then immediately sign back
/// in anonymously so the patient flows keep working.
Future<void> signOutDoctor() async {
  try {
    await GoogleSignIn.instance.signOut();
  } catch (_) {}
  try {
    await FirebaseAuth.instance.signOut();
  } catch (_) {}
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (_) {}
}
