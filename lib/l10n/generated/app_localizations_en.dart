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

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutDialogTitle => 'Sign out?';

  @override
  String get signOutDialogBodyDoctor =>
      'You will need to sign in again to manage your chambers.';

  @override
  String get signOutDialogBodyAdmin =>
      'You will need to sign in again to manage chambers.';

  @override
  String get stay => 'Stay';

  @override
  String get signingOut => 'Signing you out…';

  @override
  String get signingIn => 'Signing you in…';

  @override
  String get doctorAppBarTitle => 'Doctor';

  @override
  String get adminAppBarTitle => 'Chamber Admin';

  @override
  String get patientAppBarTitle => 'Find a doctor';

  @override
  String loadProfileFailed(String error) {
    return 'Failed to load profile:\n$error';
  }

  @override
  String get doctorWelcome => 'Welcome!';

  @override
  String get doctorWelcomePrompt =>
      'Set up your profile so patients can find you.';

  @override
  String yearsOfExperience(int years) {
    return '$years years of experience';
  }

  @override
  String get editProfile => 'Edit profile';

  @override
  String get createProfile => 'Create profile';

  @override
  String get manageChambers => 'Manage chambers';

  @override
  String todayStatusLabel(String status) {
    return 'Today: $status';
  }

  @override
  String get todaysQueuesSection => 'Today\'s queues';

  @override
  String get todaysChambersSection => 'Today\'s chambers';

  @override
  String get queueBadgeNotOpened => 'Not opened';

  @override
  String get queueBadgeLive => 'Live';

  @override
  String get queueBadgeClosed => 'Closed';

  @override
  String get chamberClosedToday => 'Closed today';

  @override
  String get nowSeeing => 'Now seeing';

  @override
  String get waiting => 'Waiting';

  @override
  String get done => 'Done';

  @override
  String get patientsWaitingPrompt => 'Patients are waiting — tap to start';

  @override
  String get noChambersAssigned => 'No chambers assigned';

  @override
  String get noChambersAssignedHint =>
      'A doctor needs to invite you to manage their chamber.';

  @override
  String get invitationsSection => 'Invitations';

  @override
  String get invitedHeader => 'YOU\'VE BEEN INVITED';

  @override
  String get invitationBodyAnonymous =>
      'A doctor wants you to manage a chamber.';

  @override
  String invitationBodyByDoctor(String doctorName) {
    return '$doctorName wants you to manage a chamber.';
  }

  @override
  String get invitationJoined => 'Joined the chamber.';

  @override
  String invitationFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get doctorStatusNotArrived => 'Doctor not arrived';

  @override
  String get doctorStatusRunningLate => 'Doctor running late';

  @override
  String get doctorStatusAvailable => 'Doctor available';

  @override
  String get doctorStatusOnBreak => 'Doctor on break';

  @override
  String get doctorStatusDoneForDay => 'Doctor done for today';

  @override
  String get doctorStatusShortNotArrived => 'Not arrived';

  @override
  String get doctorStatusShortRunningLate => 'Running late';

  @override
  String get doctorStatusShortAvailable => 'Available';

  @override
  String get doctorStatusShortOnBreak => 'On break';

  @override
  String get doctorStatusShortDoneForDay => 'Done for today';

  @override
  String get dayStatusAvailable => 'Available';

  @override
  String get dayStatusOnLeave => 'On leave today';

  @override
  String get dayStatusAtHospital => 'At hospital today';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get searchHint => 'Search by doctor, specialty, or chamber';

  @override
  String get noDoctorsYet => 'No doctors yet';

  @override
  String get noDoctorsMatch => 'No doctors match your search';

  @override
  String get noDoctorsYetHint => 'Doctors will appear here as they sign up.';

  @override
  String get noDoctorsMatchHint => 'Try a different keyword or clear filters.';

  @override
  String get availableTodayFilter => 'Available today';

  @override
  String get todayBadge => 'TODAY';

  @override
  String morePlus(int n) {
    return '+$n more';
  }

  @override
  String get doctorScreenTitle => 'Doctor';

  @override
  String loadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get doctorNotFound => 'Doctor not found';

  @override
  String loadChambersFailed(String error) {
    return 'Failed to load chambers: $error';
  }

  @override
  String bmdcLabel(String value) {
    return 'BMDC: $value';
  }

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String reviewsCount(String avg, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$avg · $_temp0';
  }

  @override
  String get rateAction => 'Rate';

  @override
  String get thanksForRating => 'Thanks for your rating!';

  @override
  String get aboutSection => 'About';

  @override
  String get languagesSection => 'Languages';

  @override
  String get recentReviewsSection => 'Recent reviews';

  @override
  String get chambersSection => 'Chambers';

  @override
  String get noChambersListed => 'No chambers listed yet.';

  @override
  String get noActiveConsultation => 'No active consultation';

  @override
  String nowServingSerial(int serial) {
    return 'Now serving: #$serial';
  }

  @override
  String waitingCount(int n) {
    return '$n waiting';
  }

  @override
  String get bookingBadgeBook => 'Book a serial';

  @override
  String get bookingBadgeWalkIn => 'Walk-in only';

  @override
  String get bookingBadgeClosedToday => 'Closed today';

  @override
  String get bookingBadgeClosedForToday => 'Closed for today';

  @override
  String get bookingBadgeOpensLater => 'Opens later';

  @override
  String get verifiedByBmdc => 'Verified by BMDC';

  @override
  String get verificationPending => 'Verification pending';

  @override
  String get verificationRejected => 'Verification rejected';

  @override
  String get queueLoading => 'Loading…';

  @override
  String queueLoadFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get queueNotYetOpen => 'Queue not yet open today';

  @override
  String get queueClosedSimple => 'Closed today';

  @override
  String get queueClosedForToday => 'Closed for today';

  @override
  String get closedForTodayBanner => 'Closed for today';

  @override
  String closedAtPattern(String time) {
    return 'The doctor wrapped up at $time. New bookings will open on the next chamber day.';
  }

  @override
  String get closedNoTimeMessage =>
      'No new bookings are being accepted. Please check back on the next chamber day.';

  @override
  String get nowServingTitle => 'Now serving';

  @override
  String get noConsultationRightNow => 'No active consultation right now';

  @override
  String upNextSection(int n) {
    return 'Up next ($n)';
  }

  @override
  String completedTodaySection(int n) {
    return 'Completed today ($n)';
  }

  @override
  String get noPatientsInQueue => 'No patients in the queue yet';

  @override
  String bookedAsSerial(int serial) {
    return 'Booked as #$serial';
  }

  @override
  String get bookSerial => 'Book serial';

  @override
  String get fromTheChamber => 'From the chamber';

  @override
  String get yourBooking => 'Your booking';

  @override
  String get cancelBookingAction => 'Cancel booking';

  @override
  String yourSerialIs(int serial) {
    return 'Your serial: #$serial';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String cancelBookingTitle(int serial) {
    return 'Cancel booking #$serial?';
  }

  @override
  String get cancelBookingBody =>
      'Your serial will be released. You can re-book if the queue still has space.';

  @override
  String get keepBooking => 'Keep booking';

  @override
  String bookingCancelled(int serial) {
    return 'Booking #$serial cancelled';
  }

  @override
  String cancelFailed(String error) {
    return 'Cancel failed: $error';
  }

  @override
  String get broadcastFromChamber => 'From the chamber';

  @override
  String yourPosition(int position) {
    String _temp0 = intl.Intl.pluralLogic(
      position,
      locale: localeName,
      other: '$position ahead of you',
      one: '1 ahead of you',
      zero: 'You\'re next',
    );
    return '$_temp0';
  }

  @override
  String get entryWaiting => 'Waiting';

  @override
  String get entryArrived => 'Arrived';

  @override
  String get entryInConsultation => 'In consultation';

  @override
  String get entryDone => 'Done';

  @override
  String get entryNoShow => 'No-show';

  @override
  String get entryCancelled => 'Cancelled';

  @override
  String get entryNotArrived => 'Not arrived';

  @override
  String waitMin(int n) {
    return '~$n min wait';
  }

  @override
  String approxMin(int n) {
    return '~$n min';
  }

  @override
  String get queueNotStartedTitle => 'Queue hasn\'t started yet';

  @override
  String get chamberClosedTodayTitle => 'Chamber closed today';

  @override
  String get adminWillOpenSoon =>
      'The admin will open the queue when the chamber begins. Check back at the start time below.';

  @override
  String get differentDaysHint =>
      'This chamber operates on different days. See the schedule below.';

  @override
  String get openDaysLabel => 'Open days';

  @override
  String get hoursLabel => 'Hours';

  @override
  String get consultationFeeLabel => 'Consultation fee';

  @override
  String get bookingLabel => 'Booking';

  @override
  String get bookingModeFullDigital => 'Book via app';

  @override
  String get bookingModeHybrid => 'App + walk-in';

  @override
  String get bookingModeQueueOnly => 'Walk-in only';

  @override
  String get queueScreenFallback => 'Queue';

  @override
  String get broadcastTooltip => 'Broadcast';

  @override
  String get reorderTooltip => 'Reorder queue';

  @override
  String get scanRegisterTooltip => 'Scan register';

  @override
  String get closeQueueTooltip => 'Close queue';

  @override
  String get moreMenuTooltip => 'More';

  @override
  String get clearAllPatientsMenu => 'Clear all patients';

  @override
  String get reopenQueueTooltip => 'Reopen queue';

  @override
  String failedShort(String error) {
    return 'Failed: $error';
  }

  @override
  String get addPatientFab => 'Add patient';

  @override
  String get closeQueueDialogTitle => 'Close queue for today?';

  @override
  String get closeQueueDialogBody =>
      'No more patients can be added. Existing entries stay visible.';

  @override
  String get closeQueueButton => 'Close queue';

  @override
  String get clearAllDialogTitle => 'Clear all patients?';

  @override
  String get clearAllDialogBody =>
      'This will delete every entry from today\'s queue, including those already seen. The queue stays open so you can start fresh. This cannot be undone.';

  @override
  String get clearAllButton => 'Clear all';

  @override
  String get queueClearedSnack => 'Queue cleared';

  @override
  String clearFailedSnack(String error) {
    return 'Clear failed: $error';
  }

  @override
  String get broadcastDialogTitle => 'Broadcast to patients';

  @override
  String get broadcastDialogBody =>
      'Short message shown to everyone watching this queue right now (e.g. \'Lunch break, back at 3 PM\'). Will stay visible until you clear it.';

  @override
  String get broadcastHint => 'What should patients see?';

  @override
  String get clearButton => 'Clear';

  @override
  String get sendButton => 'Send';

  @override
  String restoreDialogTitle(int serial) {
    return 'Restore #$serial?';
  }

  @override
  String restoreMarkedEarlier(String status) {
    return 'Marked $status earlier today.';
  }

  @override
  String get restorePatientHere => 'Patient is here now.';

  @override
  String get restoreAtSerial => 'Restore at serial:';

  @override
  String restoreOriginalChip(int serial) {
    return 'Original #$serial';
  }

  @override
  String get placeButton => 'Place';

  @override
  String addPatientFailedSnack(String error) {
    return 'Failed to add: $error';
  }

  @override
  String get addPatientDialogTitle => 'Add patient';

  @override
  String get patientNameLabel => 'Patient name';

  @override
  String get patientPhoneLabel => 'Phone (optional)';

  @override
  String get addButton => 'Add';

  @override
  String get setTokensAndOpen => 'Set tokens & open';

  @override
  String get openQueueButton => 'Open queue';

  @override
  String get todaysTokensTitle => 'Today\'s tokens';

  @override
  String get numberOfTokensLabel => 'Number of tokens';

  @override
  String get openButton => 'Open';

  @override
  String get doctorStatusDialogTitle => 'Doctor status';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get noteHint => 'e.g. Back in 15 min';

  @override
  String get updateButton => 'Update';

  @override
  String get clearBroadcastTooltip => 'Clear broadcast';

  @override
  String get clearBroadcastTitle => 'Clear broadcast?';

  @override
  String get clearBroadcastBody =>
      'Patients will stop seeing the current message.';

  @override
  String get keepButton => 'Keep';

  @override
  String get addPatientDetailsButton => 'Add patient details';

  @override
  String get markArrivedButton => 'Mark arrived';

  @override
  String get startConsultationButton => 'Start consultation';

  @override
  String get noShowAction => 'No-show';

  @override
  String get doneAction => 'Done';

  @override
  String actionFailedSnack(String error) {
    return 'Action failed: $error';
  }

  @override
  String get queuePending => 'Queue not opened today';

  @override
  String get queueOpenPrompt => 'Open the queue to start accepting patients.';

  @override
  String get queueClosedTitle => 'Queue closed';

  @override
  String tokenMode(int n) {
    return 'Tokens mode: $n slots';
  }

  @override
  String get broadcastActiveLabel => 'BROADCAST ACTIVE · patients see this';

  @override
  String get queueClosedAdminTitle => 'Queue is closed';

  @override
  String get queueClosedAdminBody =>
      'Reopen the queue to keep editing today\'s entries.';

  @override
  String markedArrivedMsg(String serial) {
    return '$serial marked arrived';
  }

  @override
  String cancelledMsg(String serial) {
    return '$serial cancelled';
  }

  @override
  String startedConsultationMsg(String serial) {
    return 'Started consultation for $serial';
  }

  @override
  String markedNoShowMsg(String serial) {
    return '$serial marked no-show';
  }

  @override
  String doneMsg(String serial) {
    return '$serial done';
  }

  @override
  String get restoreAction => 'Restore';

  @override
  String patientSerialDialogTitle(int serial) {
    return 'Patient #$serial';
  }

  @override
  String get myChambersTitle => 'My Chambers';

  @override
  String get noChambersYet => 'No chambers yet';

  @override
  String get noChambersYetHint =>
      'Add a chamber so patients can find you and book serials.';

  @override
  String get addChamberFab => 'Add chamber';

  @override
  String get editChamberTooltip => 'Edit';

  @override
  String get deleteChamberTooltip => 'Delete';

  @override
  String get manageAdminsTooltip => 'Manage chamber admins';

  @override
  String get deleteChamberTitle => 'Delete chamber?';

  @override
  String deleteChamberBody(String name) {
    return '\"$name\" will be removed. This cannot be undone.';
  }

  @override
  String get addChamberTitle => 'Add Chamber';

  @override
  String get editChamberTitle => 'Edit Chamber';

  @override
  String get chamberNameLabel => 'Chamber name';

  @override
  String get chamberNameHint => 'Popular Diagnostic Centre, Dhanmondi';

  @override
  String get chamberAddressLabel => 'Address';

  @override
  String get chamberAddressHint => 'House 25, Road 2, Dhanmondi, Dhaka';

  @override
  String get openDaysSection => 'Open days';

  @override
  String get hoursSection => 'Hours';

  @override
  String startTimePrefix(String time) {
    return 'Start: $time';
  }

  @override
  String endTimePrefix(String time) {
    return 'End: $time';
  }

  @override
  String get consultationFeeBdt => 'Consultation fee (BDT)';

  @override
  String get bookingModeSection => 'Booking mode';

  @override
  String get dailyAppCapLabel => 'Daily app booking cap';

  @override
  String get dailyAppCapHelper =>
      'Max patients who can book via app per day. Rest are walk-in.';

  @override
  String get saveChamberButton => 'Save chamber';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String saveFailedSnack(String error) {
    return 'Save failed: $error';
  }

  @override
  String get selectAtLeastOneDay => 'Select at least one day';

  @override
  String get bookingModeFullDigitalDesc =>
      'All bookings via the app. No walk-ins.';

  @override
  String get bookingModeHybridDesc =>
      'Daily cap on app bookings. Rest of the queue is walk-in.';

  @override
  String get bookingModeQueueOnlyDesc =>
      'Walk-ins only. Patients see the live queue but cannot book in advance.';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get updatePhotoTooltip => 'Update photo';

  @override
  String get photoUpdatedSnack => 'Photo updated — save to keep it';

  @override
  String couldNotLoadImageSnack(String error) {
    return 'Could not load image: $error';
  }

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get selectAtLeastOneSpecialty => 'Select at least one specialty';

  @override
  String get profileSavedSnack => 'Profile saved';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Dr. Md. Karim Ahmed';

  @override
  String get bmdcRegistrationLabel => 'BMDC registration number';

  @override
  String get bmdcRegistrationHint => 'A-12345';

  @override
  String get qualificationsLabel => 'Qualifications';

  @override
  String get qualificationsHint => 'MBBS, FCPS (Cardiology)';

  @override
  String get specialtiesSection => 'Specialties';

  @override
  String get languagesSpokenSection => 'Languages spoken';

  @override
  String get yearsOfExperienceLabel => 'Years of experience';

  @override
  String get bioLabel => 'Bio';

  @override
  String get bioHint => 'A short introduction patients will see';

  @override
  String get saveProfileButton => 'Save profile';

  @override
  String get requiredField => 'Required';

  @override
  String get chamberAdminsTitle => 'Chamber admins';

  @override
  String get inviteAdminFab => 'Invite admin';

  @override
  String get invitationSentSnack => 'Invitation sent';

  @override
  String get removeAdminTitle => 'Remove admin?';

  @override
  String removeAdminBody(String name) {
    return '$name will no longer be able to manage this chamber.';
  }

  @override
  String get removeAction => 'Remove';

  @override
  String removedSnack(String name) {
    return '$name removed';
  }

  @override
  String get invitationRevokedSnack => 'Invitation revoked';

  @override
  String get revokeTooltip => 'Revoke';

  @override
  String get noAdminsYet => 'No admins yet';

  @override
  String get noAdminsHint =>
      'Invite someone by Google email to manage this chamber\'s daily queue.';

  @override
  String currentAdminsHeader(int n) {
    return 'CURRENT ADMINS ($n)';
  }

  @override
  String pendingInvitationsHeader(int n) {
    return 'PENDING INVITATIONS ($n)';
  }

  @override
  String get todaysAvailability => 'Today\'s availability';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get noteOptionalHint =>
      'Patients see this on your chamber pages today';

  @override
  String get inviteAdminTitle => 'Invite chamber admin';

  @override
  String get adminEmailLabel => 'Admin email';

  @override
  String get adminEmailHint => 'admin@gmail.com';

  @override
  String get inviteAction => 'Invite';

  @override
  String rateDoctorTitle(String name) {
    return 'Rate $name';
  }

  @override
  String get consultationQuestion => 'How was your consultation?';

  @override
  String get commentOptionalLabel => 'Comment (optional)';

  @override
  String get commentHint => 'Share more about your experience';

  @override
  String get submitAction => 'Submit';

  @override
  String bookSerialDialogTitle(String name) {
    return 'Book serial · $name';
  }

  @override
  String get phoneLabel => 'Phone';

  @override
  String get ageOptionalLabel => 'Age (optional)';

  @override
  String get bookAction => 'Book';

  @override
  String get reorderQueueTitle => 'Reorder queue';

  @override
  String get savingEllipsis => 'Saving…';

  @override
  String failedToLoadGeneric(String error) {
    return 'Failed to load:\n$error';
  }

  @override
  String get noBookingsYet => 'No bookings yet';

  @override
  String get noBookingsHint =>
      'Find a doctor and book a serial to see it here.';

  @override
  String get bookingsTodaySection => 'Today';

  @override
  String get bookingsPastSection => 'Past';

  @override
  String get chamberFallback => 'Chamber';

  @override
  String get rateDoctorAction => 'Rate doctor';

  @override
  String get noEntriesToAdd => 'No entries to add';

  @override
  String bulkAddSuccess(int n) {
    return 'Added $n patients to queue';
  }

  @override
  String bulkAddFailed(String error) {
    return 'Bulk add failed: $error';
  }

  @override
  String get scanRegisterTitle => 'Scan register';

  @override
  String get rescanTooltip => 'Rescan';

  @override
  String get readingRegister => 'Reading register…';

  @override
  String addNToQueue(int n) {
    return 'Add $n to queue';
  }

  @override
  String get takePhotoButton => 'Take photo';

  @override
  String get chooseGalleryButton => 'Choose from gallery';

  @override
  String get addRowManually => 'Add row manually';

  @override
  String get nameLabel => 'Name';

  @override
  String get deleteRowTooltip => 'Delete row';

  @override
  String get retry => 'Retry';

  @override
  String get verificationQueueTitle => 'Verification queue';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterVerified => 'Verified';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get filterAll => 'All';

  @override
  String get noDoctorsAwaitingReview => 'No doctors awaiting review';

  @override
  String get noVerifiedDoctorsYet => 'No verified doctors yet';

  @override
  String get noRejectedDoctors => 'No rejected doctors';

  @override
  String get noDoctorsInSystem => 'No doctors in the system';

  @override
  String get noNameFallback => '(no name)';

  @override
  String get noBmdcProvided => 'No BMDC number provided';

  @override
  String get copyBmdcTooltip => 'Copy BMDC number';

  @override
  String get bmdcCopiedSnack => 'BMDC number copied';

  @override
  String get markVerifiedAction => 'Mark verified';

  @override
  String get rejectAction => 'Reject';

  @override
  String get resetToPendingAction => 'Reset to pending';

  @override
  String markedAsSnack(String status) {
    return 'Marked as $status';
  }

  @override
  String get platformAdminScreenTitle => 'Platform admin';

  @override
  String get operationsSection => 'Operations';

  @override
  String get verificationQueueCard => 'Verification queue';

  @override
  String get verificationQueueCardSub =>
      'Review BMDC numbers and approve doctors';

  @override
  String get dataRetentionSection => 'Data retention';

  @override
  String get queueAutoDeleteWindow => 'Queue auto-delete window';

  @override
  String get queueAutoDeleteDescription =>
      'New queues and entries expire after this many days. The app sweeps expired data when a doctor or admin opens their home screen. Existing docs keep their original expiry.';

  @override
  String get daysSuffix => 'days';

  @override
  String get loadingCurrentSetting => 'Loading current setting…';

  @override
  String retentionSetSnack(int days) {
    return 'Retention set to $days days';
  }

  @override
  String get enterPositiveDays => 'Enter a positive number of days.';

  @override
  String get use3650OrFewer => 'Use 3650 days or fewer.';

  @override
  String failedPrefix(String error) {
    return 'Failed: $error';
  }

  @override
  String get setPinTitle => 'Set platform admin PIN';

  @override
  String get enterPinTitle => 'Enter PIN';

  @override
  String get setPinHint =>
      'No PIN has been set yet. Choose a PIN (4–8 digits) to protect the platform admin area. You can change it anytime in Firestore at platform/config.pin.';

  @override
  String get restrictedAreaText =>
      'This area is restricted to the platform team.';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPinLabel => 'Confirm PIN';

  @override
  String get pinTooShort => 'PIN must be at least 4 digits';

  @override
  String get pinsDontMatch => 'PINs don\'t match';

  @override
  String get wrongPin => 'Wrong PIN';

  @override
  String get setPinAction => 'Set PIN';

  @override
  String get unlockAction => 'Unlock';

  @override
  String saveToPrefsFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get scanIntroTitle => 'Scan a register page';

  @override
  String get scanIntroHint =>
      'Hold the page flat, fill the viewfinder, and take a clear photo. Each detected row becomes an editable entry you can review before adding.';

  @override
  String get noWaitingToReorder => 'No waiting patients to reorder';

  @override
  String get reorderHint =>
      'Drag patients to change order. Serial numbers are reassigned by position when you Save.';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noNetworkHint =>
      'No internet connection. Check your network and try again.';

  @override
  String get permissionDeniedHint =>
      'Permission denied by the server. Sign out and back in if this keeps happening.';

  @override
  String get tryAgainShortly => 'Try again in a few seconds.';
}
