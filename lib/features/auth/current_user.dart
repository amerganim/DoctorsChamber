import 'package:firebase_auth/firebase_auth.dart';

import '../queue/queue_repository.dart' show kDevPatientId;

/// Patient identity for the current device.
///
/// Returns the Firebase Auth UID when anonymous (or any other) sign-in
/// has succeeded; otherwise falls back to the [kDevPatientId] sentinel so
/// the rest of the app keeps working during local development.
String currentPatientId() {
  return FirebaseAuth.instance.currentUser?.uid ?? kDevPatientId;
}
