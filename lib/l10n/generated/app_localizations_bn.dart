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

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signOutDialogTitle => 'সাইন আউট করবেন?';

  @override
  String get signOutDialogBodyDoctor =>
      'চেম্বার পরিচালনা করতে আবার সাইন ইন করতে হবে।';

  @override
  String get signOutDialogBodyAdmin =>
      'চেম্বার পরিচালনা করতে আবার সাইন ইন করতে হবে।';

  @override
  String get stay => 'থাকুন';

  @override
  String get signingOut => 'সাইন আউট হচ্ছে…';

  @override
  String get signingIn => 'সাইন ইন হচ্ছে…';

  @override
  String get doctorAppBarTitle => 'ডাক্তার';

  @override
  String get adminAppBarTitle => 'চেম্বার অ্যাডমিন';

  @override
  String get patientAppBarTitle => 'ডাক্তার খুঁজুন';

  @override
  String loadProfileFailed(String error) {
    return 'প্রোফাইল লোড করা যায়নি:\n$error';
  }

  @override
  String get doctorWelcome => 'স্বাগতম!';

  @override
  String get doctorWelcomePrompt =>
      'প্রোফাইল সেট করুন যাতে রোগীরা আপনাকে খুঁজে পান।';

  @override
  String yearsOfExperience(int years) {
    return '$years বছরের অভিজ্ঞতা';
  }

  @override
  String get editProfile => 'প্রোফাইল এডিট';

  @override
  String get createProfile => 'প্রোফাইল তৈরি';

  @override
  String get manageChambers => 'চেম্বার পরিচালনা';

  @override
  String todayStatusLabel(String status) {
    return 'আজ: $status';
  }

  @override
  String get todaysQueuesSection => 'আজকের কিউ';

  @override
  String get todaysChambersSection => 'আজকের চেম্বার';

  @override
  String get queueBadgeNotOpened => 'শুরু হয়নি';

  @override
  String get queueBadgeLive => 'চলমান';

  @override
  String get queueBadgeClosed => 'বন্ধ';

  @override
  String get chamberClosedToday => 'আজ বন্ধ';

  @override
  String get nowSeeing => 'চলছে';

  @override
  String get waiting => 'অপেক্ষায়';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get patientsWaitingPrompt => 'রোগী অপেক্ষায় — শুরু করতে ট্যাপ করুন';

  @override
  String get noChambersAssigned => 'কোনো চেম্বার নেই';

  @override
  String get noChambersAssignedHint =>
      'ডাক্তারকে আপনাকে চেম্বার পরিচালনার জন্য আমন্ত্রণ জানাতে হবে।';

  @override
  String get invitationsSection => 'আমন্ত্রণ';

  @override
  String get invitedHeader => 'আপনাকে আমন্ত্রণ জানানো হয়েছে';

  @override
  String get invitationBodyAnonymous =>
      'একজন ডাক্তার আপনাকে চেম্বার পরিচালনায় চান।';

  @override
  String invitationBodyByDoctor(String doctorName) {
    return '$doctorName আপনাকে চেম্বার পরিচালনায় চান।';
  }

  @override
  String get invitationJoined => 'চেম্বারে যোগ দিয়েছেন।';

  @override
  String invitationFailed(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get accept => 'গ্রহণ';

  @override
  String get decline => 'প্রত্যাখ্যান';

  @override
  String get doctorStatusNotArrived => 'ডাক্তার আসেননি';

  @override
  String get doctorStatusRunningLate => 'ডাক্তার দেরিতে আসছেন';

  @override
  String get doctorStatusAvailable => 'ডাক্তার আছেন';

  @override
  String get doctorStatusOnBreak => 'ডাক্তার বিরতিতে';

  @override
  String get doctorStatusDoneForDay => 'ডাক্তার আজকের জন্য শেষ';

  @override
  String get doctorStatusShortNotArrived => 'আসেননি';

  @override
  String get doctorStatusShortRunningLate => 'দেরিতে';

  @override
  String get doctorStatusShortAvailable => 'আছেন';

  @override
  String get doctorStatusShortOnBreak => 'বিরতিতে';

  @override
  String get doctorStatusShortDoneForDay => 'আজকের জন্য শেষ';

  @override
  String get dayStatusAvailable => 'আছেন';

  @override
  String get dayStatusOnLeave => 'আজ ছুটিতে';

  @override
  String get dayStatusAtHospital => 'আজ হাসপাতালে';

  @override
  String get myBookings => 'আমার বুকিং';

  @override
  String get searchHint => 'ডাক্তার, বিশেষত্ব বা চেম্বার খুঁজুন';

  @override
  String get noDoctorsYet => 'এখনো কোনো ডাক্তার নেই';

  @override
  String get noDoctorsMatch => 'অনুসন্ধানে কোনো ডাক্তার মেলেনি';

  @override
  String get noDoctorsYetHint => 'নতুন ডাক্তার সাইন আপ করলে এখানে দেখাবে।';

  @override
  String get noDoctorsMatchHint =>
      'ভিন্ন কীওয়ার্ড চেষ্টা করুন বা ফিল্টার মুছুন।';

  @override
  String get availableTodayFilter => 'আজ উপলব্ধ';

  @override
  String get todayBadge => 'আজ';

  @override
  String morePlus(int n) {
    return '+আরও $n';
  }

  @override
  String get doctorScreenTitle => 'ডাক্তার';

  @override
  String loadFailed(String error) {
    return 'লোড ব্যর্থ: $error';
  }

  @override
  String get doctorNotFound => 'ডাক্তার পাওয়া যায়নি';

  @override
  String loadChambersFailed(String error) {
    return 'চেম্বার লোড ব্যর্থ: $error';
  }

  @override
  String bmdcLabel(String value) {
    return 'BMDC: $value';
  }

  @override
  String get noReviewsYet => 'এখনো কোনো রিভিউ নেই';

  @override
  String reviewsCount(String avg, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রিভিউ',
      one: '১টি রিভিউ',
    );
    return '$avg · $_temp0';
  }

  @override
  String get rateAction => 'রেট';

  @override
  String get thanksForRating => 'রেটিং-এর জন্য ধন্যবাদ!';

  @override
  String get aboutSection => 'পরিচিতি';

  @override
  String get languagesSection => 'ভাষা';

  @override
  String get recentReviewsSection => 'সাম্প্রতিক রিভিউ';

  @override
  String get chambersSection => 'চেম্বার';

  @override
  String get noChambersListed => 'এখনো কোনো চেম্বার নেই।';

  @override
  String get noActiveConsultation => 'কোনো চলমান কনসালটেশন নেই';

  @override
  String nowServingSerial(int serial) {
    return 'চলছে: #$serial';
  }

  @override
  String waitingCount(int n) {
    return '$n অপেক্ষায়';
  }

  @override
  String get bookingBadgeBook => 'সিরিয়াল বুক করুন';

  @override
  String get bookingBadgeWalkIn => 'শুধু ওয়াক-ইন';

  @override
  String get bookingBadgeClosedToday => 'আজ বন্ধ';

  @override
  String get bookingBadgeClosedForToday => 'আজকের জন্য বন্ধ';

  @override
  String get bookingBadgeOpensLater => 'পরে শুরু হবে';

  @override
  String get verifiedByBmdc => 'BMDC যাচাইকৃত';

  @override
  String get verificationPending => 'যাচাই চলছে';

  @override
  String get verificationRejected => 'যাচাই প্রত্যাখ্যাত';

  @override
  String get queueLoading => 'লোড হচ্ছে…';

  @override
  String queueLoadFailed(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get queueNotYetOpen => 'আজকের কিউ এখনো শুরু হয়নি';

  @override
  String get queueClosedSimple => 'আজ বন্ধ';

  @override
  String get queueClosedForToday => 'আজকের জন্য বন্ধ';

  @override
  String get closedForTodayBanner => 'আজকের জন্য বন্ধ';

  @override
  String closedAtPattern(String time) {
    return 'ডাক্তার $time-এ আজকের কাজ শেষ করেছেন। পরবর্তী চেম্বার দিনে বুকিং খুলবে।';
  }

  @override
  String get closedNoTimeMessage =>
      'নতুন কোনো বুকিং নেওয়া হচ্ছে না। পরবর্তী চেম্বার দিনে চেক করুন।';

  @override
  String get nowServingTitle => 'চলছে';

  @override
  String get noConsultationRightNow => 'এই মুহূর্তে কোনো কনসালটেশন চলছে না';

  @override
  String upNextSection(int n) {
    return 'পরবর্তী ($n)';
  }

  @override
  String completedTodaySection(int n) {
    return 'আজ সম্পন্ন ($n)';
  }

  @override
  String get noPatientsInQueue => 'এখনো কোনো রোগী কিউতে নেই';

  @override
  String bookedAsSerial(int serial) {
    return '#$serial হিসেবে বুক হয়েছে';
  }

  @override
  String get bookSerial => 'সিরিয়াল বুক';

  @override
  String get fromTheChamber => 'চেম্বার থেকে';

  @override
  String get yourBooking => 'আপনার বুকিং';

  @override
  String get cancelBookingAction => 'বুকিং বাতিল';

  @override
  String yourSerialIs(int serial) {
    return 'আপনার সিরিয়াল: #$serial';
  }

  @override
  String get cancel => 'বাতিল';

  @override
  String get delete => 'মুছুন';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String cancelBookingTitle(int serial) {
    return 'বুকিং #$serial বাতিল?';
  }

  @override
  String get cancelBookingBody =>
      'আপনার সিরিয়াল ছেড়ে দেওয়া হবে। কিউতে জায়গা থাকলে পুনরায় বুক করতে পারবেন।';

  @override
  String get keepBooking => 'বুকিং রাখুন';

  @override
  String bookingCancelled(int serial) {
    return 'বুকিং #$serial বাতিল হয়েছে';
  }

  @override
  String cancelFailed(String error) {
    return 'বাতিল ব্যর্থ: $error';
  }

  @override
  String get broadcastFromChamber => 'চেম্বার থেকে';

  @override
  String yourPosition(int position) {
    String _temp0 = intl.Intl.pluralLogic(
      position,
      locale: localeName,
      other: '$position জন এগিয়ে',
      one: '১ জন এগিয়ে',
      zero: 'আপনি পরবর্তী',
    );
    return '$_temp0';
  }

  @override
  String get entryWaiting => 'অপেক্ষায়';

  @override
  String get entryArrived => 'এসেছেন';

  @override
  String get entryInConsultation => 'কনসালটেশনে';

  @override
  String get entryDone => 'সম্পন্ন';

  @override
  String get entryNoShow => 'অনুপস্থিত';

  @override
  String get entryCancelled => 'বাতিল';

  @override
  String get entryNotArrived => 'আসেননি';

  @override
  String waitMin(int n) {
    return '~$n মিনিট অপেক্ষা';
  }

  @override
  String approxMin(int n) {
    return '~$n মিনিট';
  }

  @override
  String get queueNotStartedTitle => 'কিউ এখনো শুরু হয়নি';

  @override
  String get chamberClosedTodayTitle => 'চেম্বার আজ বন্ধ';

  @override
  String get adminWillOpenSoon =>
      'চেম্বার শুরু হলে অ্যাডমিন কিউ চালু করবেন। নিচের শুরুর সময়ে আবার দেখুন।';

  @override
  String get differentDaysHint =>
      'এই চেম্বার অন্য দিনগুলোতে চলে। নিচের সময়সূচি দেখুন।';

  @override
  String get openDaysLabel => 'খোলা দিন';

  @override
  String get hoursLabel => 'সময়';

  @override
  String get consultationFeeLabel => 'ফি';

  @override
  String get bookingLabel => 'বুকিং';

  @override
  String get bookingModeFullDigital => 'অ্যাপে বুক';

  @override
  String get bookingModeHybrid => 'অ্যাপ + ওয়াক-ইন';

  @override
  String get bookingModeQueueOnly => 'শুধু ওয়াক-ইন';

  @override
  String get queueScreenFallback => 'কিউ';

  @override
  String get broadcastTooltip => 'ব্রডকাস্ট';

  @override
  String get reorderTooltip => 'কিউ পুনর্বিন্যাস';

  @override
  String get scanRegisterTooltip => 'রেজিস্টার স্ক্যান';

  @override
  String get closeQueueTooltip => 'কিউ বন্ধ';

  @override
  String get moreMenuTooltip => 'আরও';

  @override
  String get clearAllPatientsMenu => 'সব রোগী মুছুন';

  @override
  String get reopenQueueTooltip => 'কিউ আবার খুলুন';

  @override
  String failedShort(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get addPatientFab => 'রোগী যোগ';

  @override
  String get closeQueueDialogTitle => 'আজকের কিউ বন্ধ করবেন?';

  @override
  String get closeQueueDialogBody =>
      'নতুন কোনো রোগী যোগ করা যাবে না। আগের এন্ট্রি দৃশ্যমান থাকবে।';

  @override
  String get closeQueueButton => 'কিউ বন্ধ';

  @override
  String get clearAllDialogTitle => 'সব রোগী মুছবেন?';

  @override
  String get clearAllDialogBody =>
      'আজকের কিউ থেকে সব এন্ট্রি মুছে যাবে — দেখা শেষ রোগীসহ। কিউ খোলা থাকবে যাতে নতুন করে শুরু করা যায়। এই কাজ পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get clearAllButton => 'সব মুছুন';

  @override
  String get queueClearedSnack => 'কিউ মুছে দেওয়া হয়েছে';

  @override
  String clearFailedSnack(String error) {
    return 'মুছতে ব্যর্থ: $error';
  }

  @override
  String get broadcastDialogTitle => 'রোগীদের ব্রডকাস্ট';

  @override
  String get broadcastDialogBody =>
      'এই মুহূর্তে কিউ দেখছেন এমন সবাইকে দেখানো ছোট বার্তা (যেমন: \'লাঞ্চ ব্রেক, ৩টায় ফিরছি\')। আপনি মুছে না দিলে দেখাতে থাকবে।';

  @override
  String get broadcastHint => 'রোগীরা কী দেখবে?';

  @override
  String get clearButton => 'মুছুন';

  @override
  String get sendButton => 'পাঠান';

  @override
  String restoreDialogTitle(int serial) {
    return '#$serial ফেরাবেন?';
  }

  @override
  String restoreMarkedEarlier(String status) {
    return 'আগে $status হিসেবে চিহ্নিত হয়েছিল।';
  }

  @override
  String get restorePatientHere => 'রোগী এখন এসেছেন।';

  @override
  String get restoreAtSerial => 'যে সিরিয়ালে ফেরাবেন:';

  @override
  String restoreOriginalChip(int serial) {
    return 'মূল #$serial';
  }

  @override
  String get placeButton => 'রাখুন';

  @override
  String addPatientFailedSnack(String error) {
    return 'যোগ ব্যর্থ: $error';
  }

  @override
  String get addPatientDialogTitle => 'রোগী যোগ';

  @override
  String get patientNameLabel => 'রোগীর নাম';

  @override
  String get patientPhoneLabel => 'ফোন (ঐচ্ছিক)';

  @override
  String get addButton => 'যোগ';

  @override
  String get setTokensAndOpen => 'টোকেন সেট ও খুলুন';

  @override
  String get openQueueButton => 'কিউ খুলুন';

  @override
  String get todaysTokensTitle => 'আজকের টোকেন';

  @override
  String get numberOfTokensLabel => 'টোকেন সংখ্যা';

  @override
  String get openButton => 'খুলুন';

  @override
  String get doctorStatusDialogTitle => 'ডাক্তারের অবস্থা';

  @override
  String get noteLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get noteHint => 'যেমন: ১৫ মিনিটে ফিরছি';

  @override
  String get updateButton => 'আপডেট';

  @override
  String get clearBroadcastTooltip => 'ব্রডকাস্ট মুছুন';

  @override
  String get clearBroadcastTitle => 'ব্রডকাস্ট মুছবেন?';

  @override
  String get clearBroadcastBody => 'রোগীরা আর বর্তমান বার্তা দেখবে না।';

  @override
  String get keepButton => 'রাখুন';

  @override
  String get addPatientDetailsButton => 'রোগীর তথ্য যোগ';

  @override
  String get markArrivedButton => 'এসেছেন চিহ্নিত';

  @override
  String get startConsultationButton => 'কনসালটেশন শুরু';

  @override
  String get noShowAction => 'অনুপস্থিত';

  @override
  String get doneAction => 'সম্পন্ন';

  @override
  String actionFailedSnack(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get queuePending => 'আজকের কিউ এখনো শুরু হয়নি';

  @override
  String get queueOpenPrompt => 'রোগী নিতে কিউ খুলুন।';

  @override
  String get queueClosedTitle => 'কিউ বন্ধ';

  @override
  String tokenMode(int n) {
    return 'টোকেন মোড: $nটি স্লট';
  }

  @override
  String get broadcastActiveLabel => 'ব্রডকাস্ট সক্রিয় · রোগীরা এটি দেখছে';

  @override
  String get queueClosedAdminTitle => 'কিউ বন্ধ';

  @override
  String get queueClosedAdminBody =>
      'আজকের এন্ট্রি সম্পাদনা চালিয়ে যেতে কিউ আবার খুলুন।';

  @override
  String markedArrivedMsg(String serial) {
    return '$serial এসেছেন';
  }

  @override
  String cancelledMsg(String serial) {
    return '$serial বাতিল';
  }

  @override
  String startedConsultationMsg(String serial) {
    return '$serial-এর কনসালটেশন শুরু';
  }

  @override
  String markedNoShowMsg(String serial) {
    return '$serial অনুপস্থিত';
  }

  @override
  String doneMsg(String serial) {
    return '$serial সম্পন্ন';
  }

  @override
  String get restoreAction => 'ফেরান';

  @override
  String patientSerialDialogTitle(int serial) {
    return 'রোগী #$serial';
  }

  @override
  String get myChambersTitle => 'আমার চেম্বার';

  @override
  String get noChambersYet => 'এখনো কোনো চেম্বার নেই';

  @override
  String get noChambersYetHint =>
      'চেম্বার যোগ করুন যাতে রোগীরা আপনাকে খুঁজে সিরিয়াল বুক করতে পারেন।';

  @override
  String get addChamberFab => 'চেম্বার যোগ';

  @override
  String get editChamberTooltip => 'এডিট';

  @override
  String get deleteChamberTooltip => 'মুছুন';

  @override
  String get manageAdminsTooltip => 'চেম্বার অ্যাডমিন পরিচালনা';

  @override
  String get deleteChamberTitle => 'চেম্বার মুছবেন?';

  @override
  String deleteChamberBody(String name) {
    return '\"$name\" মুছে যাবে। এটি পূর্বাবস্থায় ফেরানো যাবে না।';
  }

  @override
  String get addChamberTitle => 'চেম্বার যোগ';

  @override
  String get editChamberTitle => 'চেম্বার এডিট';

  @override
  String get chamberNameLabel => 'চেম্বারের নাম';

  @override
  String get chamberNameHint => 'পপুলার ডায়াগনস্টিক সেন্টার, ধানমন্ডি';

  @override
  String get chamberAddressLabel => 'ঠিকানা';

  @override
  String get chamberAddressHint => 'বাড়ি ২৫, রোড ২, ধানমন্ডি, ঢাকা';

  @override
  String get openDaysSection => 'খোলা দিন';

  @override
  String get hoursSection => 'সময়';

  @override
  String startTimePrefix(String time) {
    return 'শুরু: $time';
  }

  @override
  String endTimePrefix(String time) {
    return 'শেষ: $time';
  }

  @override
  String get consultationFeeBdt => 'ফি (টাকা)';

  @override
  String get bookingModeSection => 'বুকিং মোড';

  @override
  String get dailyAppCapLabel => 'দৈনিক অ্যাপ বুকিং সর্বোচ্চ';

  @override
  String get dailyAppCapHelper =>
      'প্রতিদিন সর্বোচ্চ যত রোগী অ্যাপে বুক করতে পারবে। বাকিরা ওয়াক-ইন।';

  @override
  String get saveChamberButton => 'চেম্বার সংরক্ষণ';

  @override
  String get saveChangesButton => 'পরিবর্তন সংরক্ষণ';

  @override
  String saveFailedSnack(String error) {
    return 'সংরক্ষণ ব্যর্থ: $error';
  }

  @override
  String get selectAtLeastOneDay => 'কমপক্ষে একটি দিন বেছে নিন';

  @override
  String get bookingModeFullDigitalDesc =>
      'সব বুকিং অ্যাপের মাধ্যমে। কোনো ওয়াক-ইন নেই।';

  @override
  String get bookingModeHybridDesc =>
      'অ্যাপ বুকিং-এর দৈনিক সীমা। বাকি কিউ ওয়াক-ইন।';

  @override
  String get bookingModeQueueOnlyDesc =>
      'শুধু ওয়াক-ইন। রোগী লাইভ কিউ দেখলেও আগে থেকে বুক করতে পারবে না।';

  @override
  String get editProfileTitle => 'প্রোফাইল এডিট';

  @override
  String get updatePhotoTooltip => 'ছবি আপডেট';

  @override
  String get photoUpdatedSnack => 'ছবি আপডেট হয়েছে — সংরক্ষণে রাখতে সেভ করুন';

  @override
  String couldNotLoadImageSnack(String error) {
    return 'ছবি লোড করা যায়নি: $error';
  }

  @override
  String get takeAPhoto => 'ছবি তুলুন';

  @override
  String get chooseFromGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get removePhoto => 'ছবি মুছুন';

  @override
  String get selectAtLeastOneSpecialty => 'কমপক্ষে একটি বিশেষত্ব বেছে নিন';

  @override
  String get profileSavedSnack => 'প্রোফাইল সংরক্ষিত';

  @override
  String get fullNameLabel => 'পূর্ণ নাম';

  @override
  String get fullNameHint => 'ডা. মো. করিম আহমেদ';

  @override
  String get bmdcRegistrationLabel => 'BMDC রেজিস্ট্রেশন নম্বর';

  @override
  String get bmdcRegistrationHint => 'A-12345';

  @override
  String get qualificationsLabel => 'যোগ্যতা';

  @override
  String get qualificationsHint => 'MBBS, FCPS (কার্ডিওলজি)';

  @override
  String get specialtiesSection => 'বিশেষত্ব';

  @override
  String get languagesSpokenSection => 'প্রদেয় ভাষা';

  @override
  String get yearsOfExperienceLabel => 'অভিজ্ঞতার বছর';

  @override
  String get bioLabel => 'পরিচিতি';

  @override
  String get bioHint => 'রোগীরা যে ছোট পরিচয় দেখবে';

  @override
  String get saveProfileButton => 'প্রোফাইল সংরক্ষণ';

  @override
  String get requiredField => 'আবশ্যক';

  @override
  String get chamberAdminsTitle => 'চেম্বার অ্যাডমিন';

  @override
  String get inviteAdminFab => 'অ্যাডমিন আমন্ত্রণ';

  @override
  String get invitationSentSnack => 'আমন্ত্রণ পাঠানো হয়েছে';

  @override
  String get removeAdminTitle => 'অ্যাডমিন সরাবেন?';

  @override
  String removeAdminBody(String name) {
    return '$name আর এই চেম্বার পরিচালনা করতে পারবেন না।';
  }

  @override
  String get removeAction => 'সরান';

  @override
  String removedSnack(String name) {
    return '$name সরানো হয়েছে';
  }

  @override
  String get invitationRevokedSnack => 'আমন্ত্রণ বাতিল';

  @override
  String get revokeTooltip => 'বাতিল';

  @override
  String get noAdminsYet => 'এখনো কোনো অ্যাডমিন নেই';

  @override
  String get noAdminsHint =>
      'এই চেম্বারের দৈনিক কিউ পরিচালনা করতে কাউকে Google ইমেইল দিয়ে আমন্ত্রণ জানান।';

  @override
  String currentAdminsHeader(int n) {
    return 'বর্তমান অ্যাডমিন ($n)';
  }

  @override
  String pendingInvitationsHeader(int n) {
    return 'অপেক্ষমাণ আমন্ত্রণ ($n)';
  }

  @override
  String get todaysAvailability => 'আজকের উপলব্ধতা';

  @override
  String get noteOptionalLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get noteOptionalHint => 'আজ রোগীরা আপনার চেম্বার পেজে দেখবে';

  @override
  String get inviteAdminTitle => 'চেম্বার অ্যাডমিন আমন্ত্রণ';

  @override
  String get adminEmailLabel => 'অ্যাডমিন ইমেইল';

  @override
  String get adminEmailHint => 'admin@gmail.com';

  @override
  String get inviteAction => 'আমন্ত্রণ';

  @override
  String rateDoctorTitle(String name) {
    return '$name-কে রেট দিন';
  }

  @override
  String get consultationQuestion => 'আপনার কনসালটেশন কেমন ছিল?';

  @override
  String get commentOptionalLabel => 'মন্তব্য (ঐচ্ছিক)';

  @override
  String get commentHint => 'অভিজ্ঞতা সম্পর্কে আরও জানান';

  @override
  String get submitAction => 'জমা';

  @override
  String bookSerialDialogTitle(String name) {
    return 'সিরিয়াল বুক · $name';
  }

  @override
  String get phoneLabel => 'ফোন';

  @override
  String get ageOptionalLabel => 'বয়স (ঐচ্ছিক)';

  @override
  String get bookAction => 'বুক';

  @override
  String get reorderQueueTitle => 'কিউ পুনর্বিন্যাস';

  @override
  String get savingEllipsis => 'সংরক্ষণ হচ্ছে…';

  @override
  String failedToLoadGeneric(String error) {
    return 'লোড করা যায়নি:\n$error';
  }

  @override
  String get noBookingsYet => 'এখনো কোনো বুকিং নেই';

  @override
  String get noBookingsHint => 'একজন ডাক্তার খুঁজে সিরিয়াল বুক করুন।';

  @override
  String get bookingsTodaySection => 'আজ';

  @override
  String get bookingsPastSection => 'অতীত';

  @override
  String get chamberFallback => 'চেম্বার';

  @override
  String get rateDoctorAction => 'ডাক্তারকে রেট';

  @override
  String get noEntriesToAdd => 'যোগ করার মতো কিছু নেই';

  @override
  String bulkAddSuccess(int n) {
    return 'কিউতে $n জন যোগ হয়েছে';
  }

  @override
  String bulkAddFailed(String error) {
    return 'যোগ করা ব্যর্থ: $error';
  }

  @override
  String get scanRegisterTitle => 'রেজিস্টার স্ক্যান';

  @override
  String get rescanTooltip => 'আবার স্ক্যান';

  @override
  String get readingRegister => 'রেজিস্টার পড়া হচ্ছে…';

  @override
  String addNToQueue(int n) {
    return '$n জন কিউতে যোগ';
  }

  @override
  String get takePhotoButton => 'ছবি তুলুন';

  @override
  String get chooseGalleryButton => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get addRowManually => 'ম্যানুয়ালি সারি যোগ';

  @override
  String get nameLabel => 'নাম';

  @override
  String get deleteRowTooltip => 'সারি মুছুন';

  @override
  String get retry => 'আবার চেষ্টা';

  @override
  String get verificationQueueTitle => 'যাচাই কিউ';

  @override
  String get filterPending => 'অপেক্ষমাণ';

  @override
  String get filterVerified => 'যাচাইকৃত';

  @override
  String get filterRejected => 'প্রত্যাখ্যাত';

  @override
  String get filterAll => 'সব';

  @override
  String get noDoctorsAwaitingReview => 'যাচাইয়ের জন্য কোনো ডাক্তার নেই';

  @override
  String get noVerifiedDoctorsYet => 'এখনো যাচাইকৃত ডাক্তার নেই';

  @override
  String get noRejectedDoctors => 'কোনো প্রত্যাখ্যাত ডাক্তার নেই';

  @override
  String get noDoctorsInSystem => 'সিস্টেমে কোনো ডাক্তার নেই';

  @override
  String get noNameFallback => '(নাম নেই)';

  @override
  String get noBmdcProvided => 'BMDC নম্বর দেওয়া নেই';

  @override
  String get copyBmdcTooltip => 'BMDC নম্বর কপি';

  @override
  String get bmdcCopiedSnack => 'BMDC নম্বর কপি হয়েছে';

  @override
  String get markVerifiedAction => 'যাচাইকৃত চিহ্নিত';

  @override
  String get rejectAction => 'প্রত্যাখ্যান';

  @override
  String get resetToPendingAction => 'অপেক্ষমাণে ফেরান';

  @override
  String markedAsSnack(String status) {
    return '$status হিসেবে চিহ্নিত';
  }

  @override
  String get platformAdminScreenTitle => 'প্ল্যাটফর্ম অ্যাডমিন';

  @override
  String get operationsSection => 'অপারেশনস';

  @override
  String get verificationQueueCard => 'যাচাই কিউ';

  @override
  String get verificationQueueCardSub => 'BMDC নম্বর দেখে ডাক্তার অনুমোদন করুন';

  @override
  String get dataRetentionSection => 'ডেটা সংরক্ষণ';

  @override
  String get queueAutoDeleteWindow => 'কিউ স্বয়ংক্রিয় মুছুনের সময়';

  @override
  String get queueAutoDeleteDescription =>
      'নতুন কিউ ও এন্ট্রি এই দিনের পরে মুছে যাবে। ডাক্তার বা অ্যাডমিন হোম স্ক্রিন খুললে অ্যাপ মেয়াদোত্তীর্ণ ডেটা সরিয়ে দেয়। বিদ্যমান ডকুমেন্টগুলোর মেয়াদ অপরিবর্তিত থাকে।';

  @override
  String get daysSuffix => 'দিন';

  @override
  String get loadingCurrentSetting => 'বর্তমান সেটিং লোড হচ্ছে…';

  @override
  String retentionSetSnack(int days) {
    return 'সংরক্ষণ $days দিনে সেট হয়েছে';
  }

  @override
  String get enterPositiveDays => 'ধনাত্মক সংখ্যা দিন।';

  @override
  String get use3650OrFewer => '৩৬৫০ দিন বা কম দিন।';

  @override
  String failedPrefix(String error) {
    return 'ব্যর্থ: $error';
  }

  @override
  String get setPinTitle => 'প্ল্যাটফর্ম অ্যাডমিন PIN সেট করুন';

  @override
  String get enterPinTitle => 'PIN দিন';

  @override
  String get setPinHint =>
      'এখনো PIN সেট করা হয়নি। ৪–৮ অঙ্কের PIN বেছে নিন। ভবিষ্যতে Firestore-এ platform/config.pin থেকে পরিবর্তন করতে পারবেন।';

  @override
  String get restrictedAreaText => 'এই অংশ প্ল্যাটফর্ম টিমের জন্য সীমাবদ্ধ।';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPinLabel => 'PIN নিশ্চিত করুন';

  @override
  String get pinTooShort => 'PIN কমপক্ষে ৪ অঙ্কের হতে হবে';

  @override
  String get pinsDontMatch => 'PIN মিলছে না';

  @override
  String get wrongPin => 'ভুল PIN';

  @override
  String get setPinAction => 'PIN সেট';

  @override
  String get unlockAction => 'আনলক';

  @override
  String saveToPrefsFailed(String error) {
    return 'সংরক্ষণ ব্যর্থ: $error';
  }

  @override
  String get scanIntroTitle => 'একটি রেজিস্টার পৃষ্ঠা স্ক্যান করুন';

  @override
  String get scanIntroHint =>
      'পৃষ্ঠা সমতল ধরুন, ভিউফাইন্ডার পূর্ণ করুন এবং স্পষ্ট ছবি তুলুন। প্রতিটি সারি এডিটযোগ্য এন্ট্রি হিসেবে দেখাবে যা যোগ করার আগে আপনি পর্যালোচনা করতে পারবেন।';

  @override
  String get noWaitingToReorder =>
      'পুনর্বিন্যাসের জন্য কোনো অপেক্ষমাণ রোগী নেই';

  @override
  String get reorderHint =>
      'ক্রম বদলাতে টেনে আনুন। সেভ করলে অবস্থান অনুসারে সিরিয়াল পুনর্নির্ধারণ হবে।';

  @override
  String get somethingWentWrong => 'কিছু একটা সমস্যা হয়েছে';

  @override
  String get noNetworkHint =>
      'ইন্টারনেট নেই। নেটওয়ার্ক চেক করে আবার চেষ্টা করুন।';

  @override
  String get permissionDeniedHint =>
      'সার্ভার অনুমতি দেয়নি। সমস্যা চলতে থাকলে সাইন আউট করে আবার সাইন ইন করুন।';

  @override
  String get tryAgainShortly => 'কয়েক সেকেন্ড পর আবার চেষ্টা করুন।';
}
