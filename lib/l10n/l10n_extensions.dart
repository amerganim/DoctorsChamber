import '../features/chambers/chamber.dart';
import '../features/doctor/doctor_day_status.dart';
import '../features/doctor/doctor_profile.dart';
import '../features/queue/queue.dart';
import 'generated/app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  String dayStatusDisplay(DoctorDayStatus s) => switch (s) {
        DoctorDayStatus.available => dayStatusAvailable,
        DoctorDayStatus.onLeave => dayStatusOnLeave,
        DoctorDayStatus.atHospital => dayStatusAtHospital,
      };

  String doctorStatusDisplay(DoctorStatus s) => switch (s) {
        DoctorStatus.notArrived => doctorStatusNotArrived,
        DoctorStatus.runningLate => doctorStatusRunningLate,
        DoctorStatus.available => doctorStatusAvailable,
        DoctorStatus.onBreak => doctorStatusOnBreak,
        DoctorStatus.doneForDay => doctorStatusDoneForDay,
      };

  String doctorStatusShort(DoctorStatus s) => switch (s) {
        DoctorStatus.notArrived => doctorStatusShortNotArrived,
        DoctorStatus.runningLate => doctorStatusShortRunningLate,
        DoctorStatus.available => doctorStatusShortAvailable,
        DoctorStatus.onBreak => doctorStatusShortOnBreak,
        DoctorStatus.doneForDay => doctorStatusShortDoneForDay,
      };

  String verificationDisplay(DoctorVerificationStatus s) => switch (s) {
        DoctorVerificationStatus.verified => verifiedByBmdc,
        DoctorVerificationStatus.pending => verificationPending,
        DoctorVerificationStatus.rejected => verificationRejected,
      };

  String entryStatusDisplay(QueueEntryStatus s) => switch (s) {
        QueueEntryStatus.waiting => entryWaiting,
        QueueEntryStatus.arrived => entryArrived,
        QueueEntryStatus.inConsultation => entryInConsultation,
        QueueEntryStatus.done => entryDone,
        QueueEntryStatus.noShow => entryNoShow,
        QueueEntryStatus.cancelled => entryCancelled,
      };

  String bookingModeDisplay(ChamberBookingMode m) => switch (m) {
        ChamberBookingMode.fullDigital => bookingModeFullDigital,
        ChamberBookingMode.hybridWithCap => bookingModeHybrid,
        ChamberBookingMode.queueOnly => bookingModeQueueOnly,
      };

  String bookingModeDescription(ChamberBookingMode m) => switch (m) {
        ChamberBookingMode.fullDigital => bookingModeFullDigitalDesc,
        ChamberBookingMode.hybridWithCap => bookingModeHybridDesc,
        ChamberBookingMode.queueOnly => bookingModeQueueOnlyDesc,
      };
}
