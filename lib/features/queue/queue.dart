import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum DoctorStatus {
  notArrived,
  runningLate,
  available,
  onBreak,
  doneForDay;

  String get displayName => switch (this) {
        DoctorStatus.notArrived => 'Doctor not arrived',
        DoctorStatus.runningLate => 'Doctor running late',
        DoctorStatus.available => 'Doctor available',
        DoctorStatus.onBreak => 'Doctor on break',
        DoctorStatus.doneForDay => 'Doctor done for today',
      };

  String get shortLabel => switch (this) {
        DoctorStatus.notArrived => 'Not arrived',
        DoctorStatus.runningLate => 'Running late',
        DoctorStatus.available => 'Available',
        DoctorStatus.onBreak => 'On break',
        DoctorStatus.doneForDay => 'Done for today',
      };

  IconData get icon => switch (this) {
        DoctorStatus.notArrived => Icons.schedule_outlined,
        DoctorStatus.runningLate => Icons.access_time,
        DoctorStatus.available => Icons.check_circle_outline,
        DoctorStatus.onBreak => Icons.coffee_outlined,
        DoctorStatus.doneForDay => Icons.do_not_disturb_on_outlined,
      };

  static DoctorStatus fromString(String? s) {
    return DoctorStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DoctorStatus.available,
    );
  }
}

enum QueueStatus {
  pending,
  open,
  closed;

  static QueueStatus fromString(String? s) {
    return QueueStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => QueueStatus.pending,
    );
  }
}

enum QueueEntryStatus {
  waiting,
  arrived,
  inConsultation,
  done,
  noShow,
  cancelled;

  String get displayName => switch (this) {
        QueueEntryStatus.waiting => 'Waiting',
        QueueEntryStatus.arrived => 'Arrived',
        QueueEntryStatus.inConsultation => 'In consultation',
        QueueEntryStatus.done => 'Done',
        QueueEntryStatus.noShow => 'No-show',
        QueueEntryStatus.cancelled => 'Cancelled',
      };

  bool get isActive => switch (this) {
        QueueEntryStatus.waiting => true,
        QueueEntryStatus.arrived => true,
        QueueEntryStatus.inConsultation => true,
        QueueEntryStatus.done => false,
        QueueEntryStatus.noShow => false,
        QueueEntryStatus.cancelled => false,
      };

  static QueueEntryStatus fromString(String? s) {
    return QueueEntryStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => QueueEntryStatus.waiting,
    );
  }
}

class Queue {
  const Queue({
    required this.chamberId,
    required this.date,
    required this.status,
    required this.doctorStatus,
    required this.statusNote,
    this.openedAt,
    this.closedAt,
  });

  final String chamberId;
  final String date;
  final QueueStatus status;
  final DoctorStatus doctorStatus;
  final String statusNote;
  final DateTime? openedAt;
  final DateTime? closedAt;

  factory Queue.fromMap(Map<String, dynamic> map) {
    return Queue(
      chamberId: (map['chamberId'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      status: QueueStatus.fromString(map['status'] as String?),
      doctorStatus: DoctorStatus.fromString(map['doctorStatus'] as String?),
      statusNote: (map['statusNote'] as String?) ?? '',
      openedAt: (map['openedAt'] as Timestamp?)?.toDate(),
      closedAt: (map['closedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.serial,
    required this.patientName,
    required this.patientPhone,
    required this.status,
    required this.addedAt,
    this.chamberId = '',
    this.date = '',
    this.age,
    this.bookedBy = 'admin',
    this.bookedById = '',
  });

  final String id;
  final int serial;
  final String patientName;
  final String patientPhone;
  final QueueEntryStatus status;
  final DateTime addedAt;
  final String chamberId;
  final String date;
  final int? age;
  final String bookedBy;
  final String bookedById;

  factory QueueEntry.fromMap(String id, Map<String, dynamic> map) {
    return QueueEntry(
      id: id,
      serial: (map['serial'] as num?)?.toInt() ?? 0,
      patientName: (map['patientName'] as String?) ?? '',
      patientPhone: (map['patientPhone'] as String?) ?? '',
      status: QueueEntryStatus.fromString(map['status'] as String?),
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      chamberId: (map['chamberId'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      age: (map['age'] as num?)?.toInt(),
      bookedBy: (map['bookedBy'] as String?) ?? 'admin',
      bookedById: (map['bookedById'] as String?) ?? '',
    );
  }
}

class QueueKey {
  const QueueKey(this.chamberId, this.date);

  final String chamberId;
  final String date;

  @override
  bool operator ==(Object other) =>
      other is QueueKey && other.chamberId == chamberId && other.date == date;

  @override
  int get hashCode => Object.hash(chamberId, date);
}
