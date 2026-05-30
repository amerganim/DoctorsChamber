// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Doctor Inside';

  @override
  String get appTagline => 'Find doctors, book serials, manage chambers.';

  @override
  String get whoAreYou => 'Who are you?';

  @override
  String get rolePatient => 'Patient';

  @override
  String get rolePatientSubtitle =>
      'Find doctors, book serials, see live queues';

  @override
  String get roleDoctor => 'Doctor';

  @override
  String get roleDoctorSubtitleSignedIn => 'Manage chambers and queue';

  @override
  String get roleDoctorSubtitleSignedOut =>
      'Sign in with Google · manage chambers and queue';

  @override
  String get roleChamberAdmin => 'Chamber Admin';

  @override
  String get roleChamberAdminSubtitleSignedIn =>
      'Run the daily queue for a doctor';

  @override
  String get roleChamberAdminSubtitleSignedOut =>
      'Sign in with Google · run the daily queue for a doctor';

  @override
  String get platformAdmin => 'Platform admin';

  @override
  String get languageEnglishShort => 'EN';

  @override
  String get languageBanglaShort => 'বাং';

  @override
  String get languageSwitchTooltip => 'Change language';
}
