import 'package:firebase_auth/firebase_auth.dart';

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
