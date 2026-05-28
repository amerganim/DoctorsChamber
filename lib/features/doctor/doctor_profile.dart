import 'package:flutter/material.dart';

enum DoctorVerificationStatus {
  pending,
  verified,
  rejected;

  String get displayName => switch (this) {
        DoctorVerificationStatus.pending => 'Verification pending',
        DoctorVerificationStatus.verified => 'Verified by BMDC',
        DoctorVerificationStatus.rejected => 'Verification rejected',
      };

  IconData get icon => switch (this) {
        DoctorVerificationStatus.pending => Icons.hourglass_top_outlined,
        DoctorVerificationStatus.verified => Icons.verified,
        DoctorVerificationStatus.rejected => Icons.gpp_bad_outlined,
      };

  static DoctorVerificationStatus fromString(String? s) {
    return DoctorVerificationStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DoctorVerificationStatus.pending,
    );
  }
}

class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.name,
    required this.bmdcNumber,
    required this.qualifications,
    required this.specialties,
    required this.bio,
    required this.languages,
    required this.yearsOfExperience,
    this.photoUrl,
    this.verificationStatus = DoctorVerificationStatus.pending,
  });

  final String id;
  final String name;
  final String bmdcNumber;
  final String qualifications;
  final List<String> specialties;
  final String bio;
  final List<String> languages;
  final int yearsOfExperience;
  final String? photoUrl;
  final DoctorVerificationStatus verificationStatus;

  Map<String, dynamic> toMap() => {
        'name': name,
        'bmdcNumber': bmdcNumber,
        'qualifications': qualifications,
        'specialties': specialties,
        'bio': bio,
        'languages': languages,
        'yearsOfExperience': yearsOfExperience,
        'photoUrl': photoUrl,
        'verificationStatus': verificationStatus.name,
      };

  factory DoctorProfile.fromMap(String id, Map<String, dynamic> map) {
    return DoctorProfile(
      id: id,
      name: (map['name'] as String?) ?? '',
      bmdcNumber: (map['bmdcNumber'] as String?) ?? '',
      qualifications: (map['qualifications'] as String?) ?? '',
      specialties: List<String>.from((map['specialties'] as List?) ?? const []),
      bio: (map['bio'] as String?) ?? '',
      languages: List<String>.from((map['languages'] as List?) ?? const []),
      yearsOfExperience: (map['yearsOfExperience'] as num?)?.toInt() ?? 0,
      photoUrl: map['photoUrl'] as String?,
      verificationStatus: DoctorVerificationStatus.fromString(
          map['verificationStatus'] as String?),
    );
  }
}
