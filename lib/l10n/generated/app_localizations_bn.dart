// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'ডক্টর ইনসাইড';

  @override
  String get appTagline =>
      'ডাক্তার খুঁজুন, সিরিয়াল বুক করুন, চেম্বার পরিচালনা করুন।';

  @override
  String get whoAreYou => 'আপনি কে?';

  @override
  String get rolePatient => 'রোগী';

  @override
  String get rolePatientSubtitle =>
      'ডাক্তার খুঁজুন, সিরিয়াল বুক করুন, লাইভ কিউ দেখুন';

  @override
  String get roleDoctor => 'ডাক্তার';

  @override
  String get roleDoctorSubtitleSignedIn => 'চেম্বার ও কিউ পরিচালনা করুন';

  @override
  String get roleDoctorSubtitleSignedOut =>
      'Google দিয়ে সাইন ইন · চেম্বার ও কিউ পরিচালনা করুন';

  @override
  String get roleChamberAdmin => 'চেম্বার অ্যাডমিন';

  @override
  String get roleChamberAdminSubtitleSignedIn => 'ডাক্তারের দৈনিক কিউ চালান';

  @override
  String get roleChamberAdminSubtitleSignedOut =>
      'Google দিয়ে সাইন ইন · ডাক্তারের দৈনিক কিউ চালান';

  @override
  String get platformAdmin => 'প্ল্যাটফর্ম অ্যাডমিন';

  @override
  String get languageEnglishShort => 'EN';

  @override
  String get languageBanglaShort => 'বাং';

  @override
  String get languageSwitchTooltip => 'ভাষা পরিবর্তন';
}
