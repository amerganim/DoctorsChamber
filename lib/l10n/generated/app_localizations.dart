import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Doctor Inside'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Find doctors, book serials, manage chambers.'**
  String get appTagline;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get whoAreYou;

  /// No description provided for @rolePatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get rolePatient;

  /// No description provided for @rolePatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find doctors, book serials, see live queues'**
  String get rolePatientSubtitle;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// No description provided for @roleDoctorSubtitleSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Manage chambers and queue'**
  String get roleDoctorSubtitleSignedIn;

  /// No description provided for @roleDoctorSubtitleSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google · manage chambers and queue'**
  String get roleDoctorSubtitleSignedOut;

  /// No description provided for @roleChamberAdmin.
  ///
  /// In en, this message translates to:
  /// **'Chamber Admin'**
  String get roleChamberAdmin;

  /// No description provided for @roleChamberAdminSubtitleSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Run the daily queue for a doctor'**
  String get roleChamberAdminSubtitleSignedIn;

  /// No description provided for @roleChamberAdminSubtitleSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google · run the daily queue for a doctor'**
  String get roleChamberAdminSubtitleSignedOut;

  /// No description provided for @platformAdmin.
  ///
  /// In en, this message translates to:
  /// **'Platform admin'**
  String get platformAdmin;

  /// No description provided for @languageEnglishShort.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageEnglishShort;

  /// No description provided for @languageBanglaShort.
  ///
  /// In en, this message translates to:
  /// **'বাং'**
  String get languageBanglaShort;

  /// No description provided for @languageSwitchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get languageSwitchTooltip;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutDialogTitle;

  /// No description provided for @signOutDialogBodyDoctor.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to manage your chambers.'**
  String get signOutDialogBodyDoctor;

  /// No description provided for @signOutDialogBodyAdmin.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to manage chambers.'**
  String get signOutDialogBodyAdmin;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @signingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing you out…'**
  String get signingOut;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing you in…'**
  String get signingIn;

  /// No description provided for @doctorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorAppBarTitle;

  /// No description provided for @adminAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Chamber Admin'**
  String get adminAppBarTitle;

  /// No description provided for @patientAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a doctor'**
  String get patientAppBarTitle;

  /// No description provided for @loadProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile:\n{error}'**
  String loadProfileFailed(String error);

  /// No description provided for @doctorWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get doctorWelcome;

  /// No description provided for @doctorWelcomePrompt.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile so patients can find you.'**
  String get doctorWelcomePrompt;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'{years} years of experience'**
  String yearsOfExperience(int years);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get createProfile;

  /// No description provided for @manageChambers.
  ///
  /// In en, this message translates to:
  /// **'Manage chambers'**
  String get manageChambers;

  /// No description provided for @todayStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Today: {status}'**
  String todayStatusLabel(String status);

  /// No description provided for @todaysQueuesSection.
  ///
  /// In en, this message translates to:
  /// **'Today\'s queues'**
  String get todaysQueuesSection;

  /// No description provided for @todaysChambersSection.
  ///
  /// In en, this message translates to:
  /// **'Today\'s chambers'**
  String get todaysChambersSection;

  /// No description provided for @queueBadgeNotOpened.
  ///
  /// In en, this message translates to:
  /// **'Not opened'**
  String get queueBadgeNotOpened;

  /// No description provided for @queueBadgeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get queueBadgeLive;

  /// No description provided for @queueBadgeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get queueBadgeClosed;

  /// No description provided for @chamberClosedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get chamberClosedToday;

  /// No description provided for @nowSeeing.
  ///
  /// In en, this message translates to:
  /// **'Now seeing'**
  String get nowSeeing;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @patientsWaitingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Patients are waiting — tap to start'**
  String get patientsWaitingPrompt;

  /// No description provided for @noChambersAssigned.
  ///
  /// In en, this message translates to:
  /// **'No chambers assigned'**
  String get noChambersAssigned;

  /// No description provided for @noChambersAssignedHint.
  ///
  /// In en, this message translates to:
  /// **'A doctor needs to invite you to manage their chamber.'**
  String get noChambersAssignedHint;

  /// No description provided for @invitationsSection.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitationsSection;

  /// No description provided for @invitedHeader.
  ///
  /// In en, this message translates to:
  /// **'YOU\'VE BEEN INVITED'**
  String get invitedHeader;

  /// No description provided for @invitationBodyAnonymous.
  ///
  /// In en, this message translates to:
  /// **'A doctor wants you to manage a chamber.'**
  String get invitationBodyAnonymous;

  /// No description provided for @invitationBodyByDoctor.
  ///
  /// In en, this message translates to:
  /// **'{doctorName} wants you to manage a chamber.'**
  String invitationBodyByDoctor(String doctorName);

  /// No description provided for @invitationJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined the chamber.'**
  String get invitationJoined;

  /// No description provided for @invitationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String invitationFailed(String error);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @doctorStatusNotArrived.
  ///
  /// In en, this message translates to:
  /// **'Doctor not arrived'**
  String get doctorStatusNotArrived;

  /// No description provided for @doctorStatusRunningLate.
  ///
  /// In en, this message translates to:
  /// **'Doctor running late'**
  String get doctorStatusRunningLate;

  /// No description provided for @doctorStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Doctor available'**
  String get doctorStatusAvailable;

  /// No description provided for @doctorStatusOnBreak.
  ///
  /// In en, this message translates to:
  /// **'Doctor on break'**
  String get doctorStatusOnBreak;

  /// No description provided for @doctorStatusDoneForDay.
  ///
  /// In en, this message translates to:
  /// **'Doctor done for today'**
  String get doctorStatusDoneForDay;

  /// No description provided for @doctorStatusShortNotArrived.
  ///
  /// In en, this message translates to:
  /// **'Not arrived'**
  String get doctorStatusShortNotArrived;

  /// No description provided for @doctorStatusShortRunningLate.
  ///
  /// In en, this message translates to:
  /// **'Running late'**
  String get doctorStatusShortRunningLate;

  /// No description provided for @doctorStatusShortAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get doctorStatusShortAvailable;

  /// No description provided for @doctorStatusShortOnBreak.
  ///
  /// In en, this message translates to:
  /// **'On break'**
  String get doctorStatusShortOnBreak;

  /// No description provided for @doctorStatusShortDoneForDay.
  ///
  /// In en, this message translates to:
  /// **'Done for today'**
  String get doctorStatusShortDoneForDay;

  /// No description provided for @dayStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get dayStatusAvailable;

  /// No description provided for @dayStatusOnLeave.
  ///
  /// In en, this message translates to:
  /// **'On leave today'**
  String get dayStatusOnLeave;

  /// No description provided for @dayStatusAtHospital.
  ///
  /// In en, this message translates to:
  /// **'At hospital today'**
  String get dayStatusAtHospital;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by doctor, specialty, or chamber'**
  String get searchHint;

  /// No description provided for @noDoctorsYet.
  ///
  /// In en, this message translates to:
  /// **'No doctors yet'**
  String get noDoctorsYet;

  /// No description provided for @noDoctorsMatch.
  ///
  /// In en, this message translates to:
  /// **'No doctors match your search'**
  String get noDoctorsMatch;

  /// No description provided for @noDoctorsYetHint.
  ///
  /// In en, this message translates to:
  /// **'Doctors will appear here as they sign up.'**
  String get noDoctorsYetHint;

  /// No description provided for @noDoctorsMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or clear filters.'**
  String get noDoctorsMatchHint;

  /// No description provided for @availableTodayFilter.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get availableTodayFilter;

  /// No description provided for @todayBadge.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayBadge;

  /// No description provided for @morePlus.
  ///
  /// In en, this message translates to:
  /// **'+{n} more'**
  String morePlus(int n);

  /// No description provided for @doctorScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorScreenTitle;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String loadFailed(String error);

  /// No description provided for @doctorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Doctor not found'**
  String get doctorNotFound;

  /// No description provided for @loadChambersFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chambers: {error}'**
  String loadChambersFailed(String error);

  /// No description provided for @bmdcLabel.
  ///
  /// In en, this message translates to:
  /// **'BMDC: {value}'**
  String bmdcLabel(String value);

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{avg} · {count, plural, =1{1 review} other{{count} reviews}}'**
  String reviewsCount(String avg, int count);

  /// No description provided for @rateAction.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateAction;

  /// No description provided for @thanksForRating.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your rating!'**
  String get thanksForRating;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @languagesSection.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesSection;

  /// No description provided for @recentReviewsSection.
  ///
  /// In en, this message translates to:
  /// **'Recent reviews'**
  String get recentReviewsSection;

  /// No description provided for @chambersSection.
  ///
  /// In en, this message translates to:
  /// **'Chambers'**
  String get chambersSection;

  /// No description provided for @noChambersListed.
  ///
  /// In en, this message translates to:
  /// **'No chambers listed yet.'**
  String get noChambersListed;

  /// No description provided for @noActiveConsultation.
  ///
  /// In en, this message translates to:
  /// **'No active consultation'**
  String get noActiveConsultation;

  /// No description provided for @nowServingSerial.
  ///
  /// In en, this message translates to:
  /// **'Now serving: #{serial}'**
  String nowServingSerial(int serial);

  /// No description provided for @waitingCount.
  ///
  /// In en, this message translates to:
  /// **'{n} waiting'**
  String waitingCount(int n);

  /// No description provided for @bookingBadgeBook.
  ///
  /// In en, this message translates to:
  /// **'Book a serial'**
  String get bookingBadgeBook;

  /// No description provided for @bookingBadgeWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Walk-in only'**
  String get bookingBadgeWalkIn;

  /// No description provided for @bookingBadgeClosedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get bookingBadgeClosedToday;

  /// No description provided for @bookingBadgeClosedForToday.
  ///
  /// In en, this message translates to:
  /// **'Closed for today'**
  String get bookingBadgeClosedForToday;

  /// No description provided for @bookingBadgeOpensLater.
  ///
  /// In en, this message translates to:
  /// **'Opens later'**
  String get bookingBadgeOpensLater;

  /// No description provided for @verifiedByBmdc.
  ///
  /// In en, this message translates to:
  /// **'Verified by BMDC'**
  String get verifiedByBmdc;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPending;

  /// No description provided for @verificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Verification rejected'**
  String get verificationRejected;

  /// No description provided for @queueLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get queueLoading;

  /// No description provided for @queueLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String queueLoadFailed(String error);

  /// No description provided for @queueNotYetOpen.
  ///
  /// In en, this message translates to:
  /// **'Queue not yet open today'**
  String get queueNotYetOpen;

  /// No description provided for @queueClosedSimple.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get queueClosedSimple;

  /// No description provided for @queueClosedForToday.
  ///
  /// In en, this message translates to:
  /// **'Closed for today'**
  String get queueClosedForToday;

  /// No description provided for @closedForTodayBanner.
  ///
  /// In en, this message translates to:
  /// **'Closed for today'**
  String get closedForTodayBanner;

  /// No description provided for @closedAtPattern.
  ///
  /// In en, this message translates to:
  /// **'The doctor wrapped up at {time}. New bookings will open on the next chamber day.'**
  String closedAtPattern(String time);

  /// No description provided for @closedNoTimeMessage.
  ///
  /// In en, this message translates to:
  /// **'No new bookings are being accepted. Please check back on the next chamber day.'**
  String get closedNoTimeMessage;

  /// No description provided for @nowServingTitle.
  ///
  /// In en, this message translates to:
  /// **'Now serving'**
  String get nowServingTitle;

  /// No description provided for @noConsultationRightNow.
  ///
  /// In en, this message translates to:
  /// **'No active consultation right now'**
  String get noConsultationRightNow;

  /// No description provided for @upNextSection.
  ///
  /// In en, this message translates to:
  /// **'Up next ({n})'**
  String upNextSection(int n);

  /// No description provided for @completedTodaySection.
  ///
  /// In en, this message translates to:
  /// **'Completed today ({n})'**
  String completedTodaySection(int n);

  /// No description provided for @noPatientsInQueue.
  ///
  /// In en, this message translates to:
  /// **'No patients in the queue yet'**
  String get noPatientsInQueue;

  /// No description provided for @bookedAsSerial.
  ///
  /// In en, this message translates to:
  /// **'Booked as #{serial}'**
  String bookedAsSerial(int serial);

  /// No description provided for @bookSerial.
  ///
  /// In en, this message translates to:
  /// **'Book serial'**
  String get bookSerial;

  /// No description provided for @fromTheChamber.
  ///
  /// In en, this message translates to:
  /// **'From the chamber'**
  String get fromTheChamber;

  /// No description provided for @yourBooking.
  ///
  /// In en, this message translates to:
  /// **'Your booking'**
  String get yourBooking;

  /// No description provided for @cancelBookingAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBookingAction;

  /// No description provided for @yourSerialIs.
  ///
  /// In en, this message translates to:
  /// **'Your serial: #{serial}'**
  String yourSerialIs(int serial);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking #{serial}?'**
  String cancelBookingTitle(int serial);

  /// No description provided for @cancelBookingBody.
  ///
  /// In en, this message translates to:
  /// **'Your serial will be released. You can re-book if the queue still has space.'**
  String get cancelBookingBody;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get keepBooking;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking #{serial} cancelled'**
  String bookingCancelled(int serial);

  /// No description provided for @cancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancel failed: {error}'**
  String cancelFailed(String error);

  /// No description provided for @broadcastFromChamber.
  ///
  /// In en, this message translates to:
  /// **'From the chamber'**
  String get broadcastFromChamber;

  /// No description provided for @yourPosition.
  ///
  /// In en, this message translates to:
  /// **'{position, plural, =0{You\'re next} =1{1 ahead of you} other{{position} ahead of you}}'**
  String yourPosition(int position);

  /// No description provided for @entryWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get entryWaiting;

  /// No description provided for @entryArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get entryArrived;

  /// No description provided for @entryInConsultation.
  ///
  /// In en, this message translates to:
  /// **'In consultation'**
  String get entryInConsultation;

  /// No description provided for @entryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get entryDone;

  /// No description provided for @entryNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get entryNoShow;

  /// No description provided for @entryCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get entryCancelled;

  /// No description provided for @entryNotArrived.
  ///
  /// In en, this message translates to:
  /// **'Not arrived'**
  String get entryNotArrived;

  /// No description provided for @waitMin.
  ///
  /// In en, this message translates to:
  /// **'~{n} min wait'**
  String waitMin(int n);

  /// No description provided for @approxMin.
  ///
  /// In en, this message translates to:
  /// **'~{n} min'**
  String approxMin(int n);

  /// No description provided for @queueNotStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue hasn\'t started yet'**
  String get queueNotStartedTitle;

  /// No description provided for @chamberClosedTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Chamber closed today'**
  String get chamberClosedTodayTitle;

  /// No description provided for @adminWillOpenSoon.
  ///
  /// In en, this message translates to:
  /// **'The admin will open the queue when the chamber begins. Check back at the start time below.'**
  String get adminWillOpenSoon;

  /// No description provided for @differentDaysHint.
  ///
  /// In en, this message translates to:
  /// **'This chamber operates on different days. See the schedule below.'**
  String get differentDaysHint;

  /// No description provided for @openDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Open days'**
  String get openDaysLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursLabel;

  /// No description provided for @consultationFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee'**
  String get consultationFeeLabel;

  /// No description provided for @bookingLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingLabel;

  /// No description provided for @bookingModeFullDigital.
  ///
  /// In en, this message translates to:
  /// **'Book via app'**
  String get bookingModeFullDigital;

  /// No description provided for @bookingModeHybrid.
  ///
  /// In en, this message translates to:
  /// **'App + walk-in'**
  String get bookingModeHybrid;

  /// No description provided for @bookingModeQueueOnly.
  ///
  /// In en, this message translates to:
  /// **'Walk-in only'**
  String get bookingModeQueueOnly;

  /// No description provided for @queueScreenFallback.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueScreenFallback;

  /// No description provided for @broadcastTooltip.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcastTooltip;

  /// No description provided for @reorderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reorder queue'**
  String get reorderTooltip;

  /// No description provided for @scanRegisterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan register'**
  String get scanRegisterTooltip;

  /// No description provided for @closeQueueTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close queue'**
  String get closeQueueTooltip;

  /// No description provided for @moreMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreMenuTooltip;

  /// No description provided for @clearAllPatientsMenu.
  ///
  /// In en, this message translates to:
  /// **'Clear all patients'**
  String get clearAllPatientsMenu;

  /// No description provided for @reopenQueueTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reopen queue'**
  String get reopenQueueTooltip;

  /// No description provided for @failedShort.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedShort(String error);

  /// No description provided for @addPatientFab.
  ///
  /// In en, this message translates to:
  /// **'Add patient'**
  String get addPatientFab;

  /// No description provided for @closeQueueDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Close queue for today?'**
  String get closeQueueDialogTitle;

  /// No description provided for @closeQueueDialogBody.
  ///
  /// In en, this message translates to:
  /// **'No more patients can be added. Existing entries stay visible.'**
  String get closeQueueDialogBody;

  /// No description provided for @closeQueueButton.
  ///
  /// In en, this message translates to:
  /// **'Close queue'**
  String get closeQueueButton;

  /// No description provided for @clearAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all patients?'**
  String get clearAllDialogTitle;

  /// No description provided for @clearAllDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete every entry from today\'s queue, including those already seen. The queue stays open so you can start fresh. This cannot be undone.'**
  String get clearAllDialogBody;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllButton;

  /// No description provided for @queueClearedSnack.
  ///
  /// In en, this message translates to:
  /// **'Queue cleared'**
  String get queueClearedSnack;

  /// No description provided for @clearFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Clear failed: {error}'**
  String clearFailedSnack(String error);

  /// No description provided for @broadcastDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to patients'**
  String get broadcastDialogTitle;

  /// No description provided for @broadcastDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Short message shown to everyone watching this queue right now (e.g. \'Lunch break, back at 3 PM\'). Will stay visible until you clear it.'**
  String get broadcastDialogBody;

  /// No description provided for @broadcastHint.
  ///
  /// In en, this message translates to:
  /// **'What should patients see?'**
  String get broadcastHint;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @restoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore #{serial}?'**
  String restoreDialogTitle(int serial);

  /// No description provided for @restoreMarkedEarlier.
  ///
  /// In en, this message translates to:
  /// **'Marked {status} earlier today.'**
  String restoreMarkedEarlier(String status);

  /// No description provided for @restorePatientHere.
  ///
  /// In en, this message translates to:
  /// **'Patient is here now.'**
  String get restorePatientHere;

  /// No description provided for @restoreAtSerial.
  ///
  /// In en, this message translates to:
  /// **'Restore at serial:'**
  String get restoreAtSerial;

  /// No description provided for @restoreOriginalChip.
  ///
  /// In en, this message translates to:
  /// **'Original #{serial}'**
  String restoreOriginalChip(int serial);

  /// No description provided for @placeButton.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placeButton;

  /// No description provided for @addPatientFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Failed to add: {error}'**
  String addPatientFailedSnack(String error);

  /// No description provided for @addPatientDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add patient'**
  String get addPatientDialogTitle;

  /// No description provided for @patientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient name'**
  String get patientNameLabel;

  /// No description provided for @patientPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get patientPhoneLabel;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @setTokensAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Set tokens & open'**
  String get setTokensAndOpen;

  /// No description provided for @openQueueButton.
  ///
  /// In en, this message translates to:
  /// **'Open queue'**
  String get openQueueButton;

  /// No description provided for @todaysTokensTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s tokens'**
  String get todaysTokensTitle;

  /// No description provided for @numberOfTokensLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of tokens'**
  String get numberOfTokensLabel;

  /// No description provided for @openButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openButton;

  /// No description provided for @doctorStatusDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor status'**
  String get doctorStatusDialogTitle;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Back in 15 min'**
  String get noteHint;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @clearBroadcastTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear broadcast'**
  String get clearBroadcastTooltip;

  /// No description provided for @clearBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear broadcast?'**
  String get clearBroadcastTitle;

  /// No description provided for @clearBroadcastBody.
  ///
  /// In en, this message translates to:
  /// **'Patients will stop seeing the current message.'**
  String get clearBroadcastBody;

  /// No description provided for @keepButton.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keepButton;

  /// No description provided for @addPatientDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Add patient details'**
  String get addPatientDetailsButton;

  /// No description provided for @markArrivedButton.
  ///
  /// In en, this message translates to:
  /// **'Mark arrived'**
  String get markArrivedButton;

  /// No description provided for @startConsultationButton.
  ///
  /// In en, this message translates to:
  /// **'Start consultation'**
  String get startConsultationButton;

  /// No description provided for @noShowAction.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get noShowAction;

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @actionFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String actionFailedSnack(String error);

  /// No description provided for @queuePending.
  ///
  /// In en, this message translates to:
  /// **'Queue not opened today'**
  String get queuePending;

  /// No description provided for @queueOpenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Open the queue to start accepting patients.'**
  String get queueOpenPrompt;

  /// No description provided for @queueClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue closed'**
  String get queueClosedTitle;

  /// No description provided for @tokenMode.
  ///
  /// In en, this message translates to:
  /// **'Tokens mode: {n} slots'**
  String tokenMode(int n);

  /// No description provided for @broadcastActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'BROADCAST ACTIVE · patients see this'**
  String get broadcastActiveLabel;

  /// No description provided for @queueClosedAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue is closed'**
  String get queueClosedAdminTitle;

  /// No description provided for @queueClosedAdminBody.
  ///
  /// In en, this message translates to:
  /// **'Reopen the queue to keep editing today\'s entries.'**
  String get queueClosedAdminBody;

  /// No description provided for @markedArrivedMsg.
  ///
  /// In en, this message translates to:
  /// **'{serial} marked arrived'**
  String markedArrivedMsg(String serial);

  /// No description provided for @cancelledMsg.
  ///
  /// In en, this message translates to:
  /// **'{serial} cancelled'**
  String cancelledMsg(String serial);

  /// No description provided for @startedConsultationMsg.
  ///
  /// In en, this message translates to:
  /// **'Started consultation for {serial}'**
  String startedConsultationMsg(String serial);

  /// No description provided for @markedNoShowMsg.
  ///
  /// In en, this message translates to:
  /// **'{serial} marked no-show'**
  String markedNoShowMsg(String serial);

  /// No description provided for @doneMsg.
  ///
  /// In en, this message translates to:
  /// **'{serial} done'**
  String doneMsg(String serial);

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @patientSerialDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient #{serial}'**
  String patientSerialDialogTitle(int serial);

  /// No description provided for @myChambersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Chambers'**
  String get myChambersTitle;

  /// No description provided for @noChambersYet.
  ///
  /// In en, this message translates to:
  /// **'No chambers yet'**
  String get noChambersYet;

  /// No description provided for @noChambersYetHint.
  ///
  /// In en, this message translates to:
  /// **'Add a chamber so patients can find you and book serials.'**
  String get noChambersYetHint;

  /// No description provided for @addChamberFab.
  ///
  /// In en, this message translates to:
  /// **'Add chamber'**
  String get addChamberFab;

  /// No description provided for @editChamberTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editChamberTooltip;

  /// No description provided for @deleteChamberTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteChamberTooltip;

  /// No description provided for @manageAdminsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage chamber admins'**
  String get manageAdminsTooltip;

  /// No description provided for @deleteChamberTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chamber?'**
  String get deleteChamberTitle;

  /// No description provided for @deleteChamberBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed. This cannot be undone.'**
  String deleteChamberBody(String name);

  /// No description provided for @addChamberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Chamber'**
  String get addChamberTitle;

  /// No description provided for @editChamberTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Chamber'**
  String get editChamberTitle;

  /// No description provided for @chamberNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Chamber name'**
  String get chamberNameLabel;

  /// No description provided for @chamberNameHint.
  ///
  /// In en, this message translates to:
  /// **'Popular Diagnostic Centre, Dhanmondi'**
  String get chamberNameHint;

  /// No description provided for @chamberAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get chamberAddressLabel;

  /// No description provided for @chamberAddressHint.
  ///
  /// In en, this message translates to:
  /// **'House 25, Road 2, Dhanmondi, Dhaka'**
  String get chamberAddressHint;

  /// No description provided for @openDaysSection.
  ///
  /// In en, this message translates to:
  /// **'Open days'**
  String get openDaysSection;

  /// No description provided for @hoursSection.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursSection;

  /// No description provided for @startTimePrefix.
  ///
  /// In en, this message translates to:
  /// **'Start: {time}'**
  String startTimePrefix(String time);

  /// No description provided for @endTimePrefix.
  ///
  /// In en, this message translates to:
  /// **'End: {time}'**
  String endTimePrefix(String time);

  /// No description provided for @consultationFeeBdt.
  ///
  /// In en, this message translates to:
  /// **'Consultation fee (BDT)'**
  String get consultationFeeBdt;

  /// No description provided for @bookingModeSection.
  ///
  /// In en, this message translates to:
  /// **'Booking mode'**
  String get bookingModeSection;

  /// No description provided for @dailyAppCapLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily app booking cap'**
  String get dailyAppCapLabel;

  /// No description provided for @dailyAppCapHelper.
  ///
  /// In en, this message translates to:
  /// **'Max patients who can book via app per day. Rest are walk-in.'**
  String get dailyAppCapHelper;

  /// No description provided for @saveChamberButton.
  ///
  /// In en, this message translates to:
  /// **'Save chamber'**
  String get saveChamberButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesButton;

  /// No description provided for @saveFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailedSnack(String error);

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get selectAtLeastOneDay;

  /// No description provided for @bookingModeFullDigitalDesc.
  ///
  /// In en, this message translates to:
  /// **'All bookings via the app. No walk-ins.'**
  String get bookingModeFullDigitalDesc;

  /// No description provided for @bookingModeHybridDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily cap on app bookings. Rest of the queue is walk-in.'**
  String get bookingModeHybridDesc;

  /// No description provided for @bookingModeQueueOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Walk-ins only. Patients see the live queue but cannot book in advance.'**
  String get bookingModeQueueOnlyDesc;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @updatePhotoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Update photo'**
  String get updatePhotoTooltip;

  /// No description provided for @photoUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Photo updated — save to keep it'**
  String get photoUpdatedSnack;

  /// No description provided for @couldNotLoadImageSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not load image: {error}'**
  String couldNotLoadImageSnack(String error);

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @selectAtLeastOneSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Select at least one specialty'**
  String get selectAtLeastOneSpecialty;

  /// No description provided for @profileSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSavedSnack;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Dr. Md. Karim Ahmed'**
  String get fullNameHint;

  /// No description provided for @bmdcRegistrationLabel.
  ///
  /// In en, this message translates to:
  /// **'BMDC registration number'**
  String get bmdcRegistrationLabel;

  /// No description provided for @bmdcRegistrationHint.
  ///
  /// In en, this message translates to:
  /// **'A-12345'**
  String get bmdcRegistrationHint;

  /// No description provided for @qualificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualificationsLabel;

  /// No description provided for @qualificationsHint.
  ///
  /// In en, this message translates to:
  /// **'MBBS, FCPS (Cardiology)'**
  String get qualificationsHint;

  /// No description provided for @specialtiesSection.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialtiesSection;

  /// No description provided for @languagesSpokenSection.
  ///
  /// In en, this message translates to:
  /// **'Languages spoken'**
  String get languagesSpokenSection;

  /// No description provided for @yearsOfExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsOfExperienceLabel;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'A short introduction patients will see'**
  String get bioHint;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfileButton;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @chamberAdminsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chamber admins'**
  String get chamberAdminsTitle;

  /// No description provided for @inviteAdminFab.
  ///
  /// In en, this message translates to:
  /// **'Invite admin'**
  String get inviteAdminFab;

  /// No description provided for @invitationSentSnack.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSentSnack;

  /// No description provided for @removeAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove admin?'**
  String get removeAdminTitle;

  /// No description provided for @removeAdminBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be able to manage this chamber.'**
  String removeAdminBody(String name);

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @removedSnack.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String removedSnack(String name);

  /// No description provided for @invitationRevokedSnack.
  ///
  /// In en, this message translates to:
  /// **'Invitation revoked'**
  String get invitationRevokedSnack;

  /// No description provided for @revokeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revokeTooltip;

  /// No description provided for @noAdminsYet.
  ///
  /// In en, this message translates to:
  /// **'No admins yet'**
  String get noAdminsYet;

  /// No description provided for @noAdminsHint.
  ///
  /// In en, this message translates to:
  /// **'Invite someone by Google email to manage this chamber\'s daily queue.'**
  String get noAdminsHint;

  /// No description provided for @currentAdminsHeader.
  ///
  /// In en, this message translates to:
  /// **'CURRENT ADMINS ({n})'**
  String currentAdminsHeader(int n);

  /// No description provided for @pendingInvitationsHeader.
  ///
  /// In en, this message translates to:
  /// **'PENDING INVITATIONS ({n})'**
  String pendingInvitationsHeader(int n);

  /// No description provided for @todaysAvailability.
  ///
  /// In en, this message translates to:
  /// **'Today\'s availability'**
  String get todaysAvailability;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptionalLabel;

  /// No description provided for @noteOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Patients see this on your chamber pages today'**
  String get noteOptionalHint;

  /// No description provided for @inviteAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite chamber admin'**
  String get inviteAdminTitle;

  /// No description provided for @adminEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin email'**
  String get adminEmailLabel;

  /// No description provided for @adminEmailHint.
  ///
  /// In en, this message translates to:
  /// **'admin@gmail.com'**
  String get adminEmailHint;

  /// No description provided for @inviteAction.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get inviteAction;

  /// No description provided for @rateDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate {name}'**
  String rateDoctorTitle(String name);

  /// No description provided for @consultationQuestion.
  ///
  /// In en, this message translates to:
  /// **'How was your consultation?'**
  String get consultationQuestion;

  /// No description provided for @commentOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptionalLabel;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Share more about your experience'**
  String get commentHint;

  /// No description provided for @submitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitAction;

  /// No description provided for @bookSerialDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Book serial · {name}'**
  String bookSerialDialogTitle(String name);

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @ageOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get ageOptionalLabel;

  /// No description provided for @bookAction.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get bookAction;

  /// No description provided for @reorderQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder queue'**
  String get reorderQueueTitle;

  /// No description provided for @savingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingEllipsis;

  /// No description provided for @failedToLoadGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to load:\n{error}'**
  String failedToLoadGeneric(String error);

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookingsYet;

  /// No description provided for @noBookingsHint.
  ///
  /// In en, this message translates to:
  /// **'Find a doctor and book a serial to see it here.'**
  String get noBookingsHint;

  /// No description provided for @bookingsTodaySection.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get bookingsTodaySection;

  /// No description provided for @bookingsPastSection.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get bookingsPastSection;

  /// No description provided for @chamberFallback.
  ///
  /// In en, this message translates to:
  /// **'Chamber'**
  String get chamberFallback;

  /// No description provided for @rateDoctorAction.
  ///
  /// In en, this message translates to:
  /// **'Rate doctor'**
  String get rateDoctorAction;

  /// No description provided for @noEntriesToAdd.
  ///
  /// In en, this message translates to:
  /// **'No entries to add'**
  String get noEntriesToAdd;

  /// No description provided for @bulkAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added {n} patients to queue'**
  String bulkAddSuccess(int n);

  /// No description provided for @bulkAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Bulk add failed: {error}'**
  String bulkAddFailed(String error);

  /// No description provided for @scanRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan register'**
  String get scanRegisterTitle;

  /// No description provided for @rescanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescanTooltip;

  /// No description provided for @readingRegister.
  ///
  /// In en, this message translates to:
  /// **'Reading register…'**
  String get readingRegister;

  /// No description provided for @addNToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add {n} to queue'**
  String addNToQueue(int n);

  /// No description provided for @takePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhotoButton;

  /// No description provided for @chooseGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseGalleryButton;

  /// No description provided for @addRowManually.
  ///
  /// In en, this message translates to:
  /// **'Add row manually'**
  String get addRowManually;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @deleteRowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete row'**
  String get deleteRowTooltip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @verificationQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification queue'**
  String get verificationQueueTitle;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get filterVerified;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noDoctorsAwaitingReview.
  ///
  /// In en, this message translates to:
  /// **'No doctors awaiting review'**
  String get noDoctorsAwaitingReview;

  /// No description provided for @noVerifiedDoctorsYet.
  ///
  /// In en, this message translates to:
  /// **'No verified doctors yet'**
  String get noVerifiedDoctorsYet;

  /// No description provided for @noRejectedDoctors.
  ///
  /// In en, this message translates to:
  /// **'No rejected doctors'**
  String get noRejectedDoctors;

  /// No description provided for @noDoctorsInSystem.
  ///
  /// In en, this message translates to:
  /// **'No doctors in the system'**
  String get noDoctorsInSystem;

  /// No description provided for @noNameFallback.
  ///
  /// In en, this message translates to:
  /// **'(no name)'**
  String get noNameFallback;

  /// No description provided for @noBmdcProvided.
  ///
  /// In en, this message translates to:
  /// **'No BMDC number provided'**
  String get noBmdcProvided;

  /// No description provided for @copyBmdcTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy BMDC number'**
  String get copyBmdcTooltip;

  /// No description provided for @bmdcCopiedSnack.
  ///
  /// In en, this message translates to:
  /// **'BMDC number copied'**
  String get bmdcCopiedSnack;

  /// No description provided for @markVerifiedAction.
  ///
  /// In en, this message translates to:
  /// **'Mark verified'**
  String get markVerifiedAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAction;

  /// No description provided for @resetToPendingAction.
  ///
  /// In en, this message translates to:
  /// **'Reset to pending'**
  String get resetToPendingAction;

  /// No description provided for @markedAsSnack.
  ///
  /// In en, this message translates to:
  /// **'Marked as {status}'**
  String markedAsSnack(String status);

  /// No description provided for @platformAdminScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform admin'**
  String get platformAdminScreenTitle;

  /// No description provided for @operationsSection.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operationsSection;

  /// No description provided for @verificationQueueCard.
  ///
  /// In en, this message translates to:
  /// **'Verification queue'**
  String get verificationQueueCard;

  /// No description provided for @verificationQueueCardSub.
  ///
  /// In en, this message translates to:
  /// **'Review BMDC numbers and approve doctors'**
  String get verificationQueueCardSub;

  /// No description provided for @dataRetentionSection.
  ///
  /// In en, this message translates to:
  /// **'Data retention'**
  String get dataRetentionSection;

  /// No description provided for @queueAutoDeleteWindow.
  ///
  /// In en, this message translates to:
  /// **'Queue auto-delete window'**
  String get queueAutoDeleteWindow;

  /// No description provided for @queueAutoDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'New queues and entries expire after this many days. The app sweeps expired data when a doctor or admin opens their home screen. Existing docs keep their original expiry.'**
  String get queueAutoDeleteDescription;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysSuffix;

  /// No description provided for @loadingCurrentSetting.
  ///
  /// In en, this message translates to:
  /// **'Loading current setting…'**
  String get loadingCurrentSetting;

  /// No description provided for @retentionSetSnack.
  ///
  /// In en, this message translates to:
  /// **'Retention set to {days} days'**
  String retentionSetSnack(int days);

  /// No description provided for @enterPositiveDays.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number of days.'**
  String get enterPositiveDays;

  /// No description provided for @use3650OrFewer.
  ///
  /// In en, this message translates to:
  /// **'Use 3650 days or fewer.'**
  String get use3650OrFewer;

  /// No description provided for @failedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedPrefix(String error);

  /// No description provided for @setPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Set platform admin PIN'**
  String get setPinTitle;

  /// No description provided for @enterPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPinTitle;

  /// No description provided for @setPinHint.
  ///
  /// In en, this message translates to:
  /// **'No PIN has been set yet. Choose a PIN (4–8 digits) to protect the platform admin area. You can change it anytime in Firestore at platform/config.pin.'**
  String get setPinHint;

  /// No description provided for @restrictedAreaText.
  ///
  /// In en, this message translates to:
  /// **'This area is restricted to the platform team.'**
  String get restrictedAreaText;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @confirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinLabel;

  /// No description provided for @pinTooShort.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinTooShort;

  /// No description provided for @pinsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match'**
  String get pinsDontMatch;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @setPinAction.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPinAction;

  /// No description provided for @unlockAction.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// No description provided for @saveToPrefsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String saveToPrefsFailed(String error);

  /// No description provided for @scanIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a register page'**
  String get scanIntroTitle;

  /// No description provided for @scanIntroHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the page flat, fill the viewfinder, and take a clear photo. Each detected row becomes an editable entry you can review before adding.'**
  String get scanIntroHint;

  /// No description provided for @noWaitingToReorder.
  ///
  /// In en, this message translates to:
  /// **'No waiting patients to reorder'**
  String get noWaitingToReorder;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag patients to change order. Serial numbers are reassigned by position when you Save.'**
  String get reorderHint;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get noNetworkHint;

  /// No description provided for @permissionDeniedHint.
  ///
  /// In en, this message translates to:
  /// **'Permission denied by the server. Sign out and back in if this keeps happening.'**
  String get permissionDeniedHint;

  /// No description provided for @tryAgainShortly.
  ///
  /// In en, this message translates to:
  /// **'Try again in a few seconds.'**
  String get tryAgainShortly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
