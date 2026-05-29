import 'package:cloud_firestore/cloud_firestore.dart';

class ChamberAdmin {
  const ChamberAdmin({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.addedAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final DateTime addedAt;

  String get label =>
      displayName.isNotEmpty ? displayName : (email.isNotEmpty ? email : uid);

  factory ChamberAdmin.fromMap(String uid, Map<String, dynamic> map) {
    return ChamberAdmin(
      uid: uid,
      email: (map['email'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? '',
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
