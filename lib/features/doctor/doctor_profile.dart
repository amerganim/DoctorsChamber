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

  Map<String, dynamic> toMap() => {
        'name': name,
        'bmdcNumber': bmdcNumber,
        'qualifications': qualifications,
        'specialties': specialties,
        'bio': bio,
        'languages': languages,
        'yearsOfExperience': yearsOfExperience,
        'photoUrl': photoUrl,
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
    );
  }
}
