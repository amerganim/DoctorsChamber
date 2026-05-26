enum UserRole {
  patient,
  doctor,
  admin;

  String get displayName => switch (this) {
        UserRole.patient => 'Patient',
        UserRole.doctor => 'Doctor',
        UserRole.admin => 'Chamber Admin',
      };

  String get homeRoute => switch (this) {
        UserRole.patient => '/patient',
        UserRole.doctor => '/doctor',
        UserRole.admin => '/admin',
      };
}
