import 'package:flutter/material.dart';

enum DoctorDayStatus {
  available,
  onLeave,
  atHospital;

  String get displayName => switch (this) {
        DoctorDayStatus.available => 'Available',
        DoctorDayStatus.onLeave => 'On leave today',
        DoctorDayStatus.atHospital => 'At hospital today',
      };

  IconData get icon => switch (this) {
        DoctorDayStatus.available => Icons.check_circle_outline,
        DoctorDayStatus.onLeave => Icons.do_not_disturb_on_outlined,
        DoctorDayStatus.atHospital => Icons.local_hospital_outlined,
      };

  static DoctorDayStatus fromString(String? s) {
    return DoctorDayStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DoctorDayStatus.available,
    );
  }
}

class DoctorDayStatusDoc {
  const DoctorDayStatusDoc({
    required this.doctorId,
    required this.date,
    required this.status,
    required this.note,
  });

  final String doctorId;
  final String date;
  final DoctorDayStatus status;
  final String note;

  bool get isAvailable => status == DoctorDayStatus.available;

  factory DoctorDayStatusDoc.fromMap(
      String doctorId, String date, Map<String, dynamic> map) {
    return DoctorDayStatusDoc(
      doctorId: doctorId,
      date: date,
      status: DoctorDayStatus.fromString(map['status'] as String?),
      note: (map['note'] as String?) ?? '',
    );
  }
}
