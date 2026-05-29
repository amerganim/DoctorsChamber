import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationStatus {
  pending,
  accepted,
  declined;

  static InvitationStatus fromString(String? s) {
    return InvitationStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => InvitationStatus.pending,
    );
  }
}

class Invitation {
  const Invitation({
    required this.id,
    required this.chamberId,
    required this.email,
    required this.invitedByDoctorId,
    required this.invitedByDoctorName,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String chamberId;
  final String email;
  final String invitedByDoctorId;
  final String invitedByDoctorName;
  final InvitationStatus status;
  final DateTime createdAt;

  factory Invitation.fromMap(
      String id, String chamberId, Map<String, dynamic> map) {
    return Invitation(
      id: id,
      chamberId: chamberId,
      email: (map['email'] as String?) ?? '',
      invitedByDoctorId: (map['invitedByDoctorId'] as String?) ?? '',
      invitedByDoctorName: (map['invitedByDoctorName'] as String?) ?? '',
      status: InvitationStatus.fromString(map['status'] as String?),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
