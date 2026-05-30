import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../doctor/doctor_day_status.dart';
import '../doctor/doctor_day_status_repository.dart';
import '../doctor/doctor_photo_service.dart';
import '../doctor/doctor_profile.dart';
import '../doctor/doctor_profile_repository.dart';
import 'package:go_router/go_router.dart';

import '../queue/queue.dart';
import '../queue/queue_repository.dart';
import '../ratings/rate_doctor_dialog.dart';
import '../ratings/rating.dart';
import '../ratings/rating_repository.dart';

class PatientDoctorViewScreen extends ConsumerWidget {
  const PatientDoctorViewScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(doctorProfileStreamProvider(doctorId));
    final chambersAsync = ref.watch(chambersByDoctorStreamProvider(doctorId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorScreenTitle)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text(l10n.loadFailed(e.toString()),
                textAlign: TextAlign.center)),
        data: (doctor) {
          if (doctor == null) {
            return Center(child: Text(l10n.doctorNotFound));
          }
          return chambersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.loadChambersFailed(e.toString()))),
            data: (chambers) => _DoctorDetail(doctor: doctor, chambers: chambers),
          );
        },
      ),
    );
  }
}

class _DoctorDetail extends ConsumerWidget {
  const _DoctorDetail({required this.doctor, required this.chambers});

  final DoctorProfile doctor;
  final List<Chamber> chambers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();
    final summary = ref.watch(ratingSummaryProvider(doctor.id));
    final ratings =
        ref.watch(ratingsByDoctorStreamProvider(doctor.id)).value ??
            const <Rating>[];
    final dayStatus = ref
        .watch(doctorDayStatusProvider(
            DoctorDayStatusKey(doctor.id, todayDateKey())))
        .value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        if (dayStatus != null && !dayStatus.isAvailable) ...[
          _DoctorDayStatusBanner(status: dayStatus),
          const SizedBox(height: 16),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.brightness == Brightness.light
                  ? scheme.primary
                  : scheme.primaryContainer,
              backgroundImage: doctorPhotoProvider(doctor.photoUrl),
              child: doctorPhotoProvider(doctor.photoUrl) == null
                  ? Icon(Icons.person,
                      size: 36,
                      color: scheme.brightness == Brightness.light
                          ? scheme.onPrimary
                          : scheme.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  if (doctor.qualifications.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(doctor.qualifications,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                  if (doctor.specialties.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      doctor.specialties.join(' • '),
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (doctor.yearsOfExperience > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.yearsOfExperience(doctor.yearsOfExperience),
                      style: TextStyle(
                          fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (doctor.bmdcNumber.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(l10n.bmdcLabel(doctor.bmdcNumber),
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
        const SizedBox(height: 8),
        _VerificationLine(status: doctor.verificationStatus),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber.shade700),
            const SizedBox(width: 6),
            Text(
              summary.count == 0
                  ? l10n.noReviewsYet
                  : l10n.reviewsCount(
                      summary.average.toStringAsFixed(1), summary.count),
              style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(l10n.rateAction),
              onPressed: () => _showRate(context),
            ),
          ],
        ),
        if (doctor.bio.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.aboutSection,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(doctor.bio, style: const TextStyle(height: 1.4)),
        ],
        if (doctor.languages.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.languagesSection,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.languages
                .map((l) => Chip(label: Text(l), visualDensity: VisualDensity.compact))
                .toList(),
          ),
        ],
        if (ratings.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(l10n.recentReviewsSection,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...ratings.take(5).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RatingCard(rating: r),
                ),
              ),
        ],
        const SizedBox(height: 24),
        Text(l10n.chambersSection,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (chambers.isEmpty)
          Text(
            l10n.noChambersListed,
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
        else
          ...chambers.map((c) =>
              Padding(padding: const EdgeInsets.only(bottom: 12), child: _ChamberTile(chamber: c, today: today))),
      ],
    );
  }

  Future<void> _showRate(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => RateDoctorDialog(
        doctorId: doctor.id,
        doctorName: doctor.name.isEmpty ? 'this doctor' : doctor.name,
        bookingId: '',
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).thanksForRating)),
      );
    }
  }
}

class _ChamberTile extends ConsumerWidget {
  const _ChamberTile({required this.chamber, required this.today});

  final Chamber chamber;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final openToday = chamber.days.contains(today);
    final qKey = QueueKey(chamber.id, todayDateKey());
    final queueAsync = ref.watch(queueStreamProvider(qKey));
    final entriesAsync = ref.watch(queueEntriesStreamProvider(qKey));
    final queue = queueAsync.value;
    final entries = entriesAsync.value ?? const <QueueEntry>[];
    final inConsultation = entries
        .where((e) => e.status == QueueEntryStatus.inConsultation)
        .firstOrNull;
    final waitingCount = entries
        .where((e) =>
            e.status == QueueEntryStatus.waiting ||
            e.status == QueueEntryStatus.arrived)
        .length;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push('/patient/chamber/${chamber.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chamber.name,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(chamber.address,
                style: TextStyle(
                    fontSize: 13, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(chamber.days.join(', '),
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
                const SizedBox(width: 12),
                Icon(Icons.access_time,
                    size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${chamber.startTime} – ${chamber.endTime}',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '৳${chamber.consultationFee}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: scheme.primary),
                ),
                const Spacer(),
                _BookingBadge(
                  mode: chamber.bookingMode,
                  queueStatus: queue?.status,
                  openToday: openToday,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        queue?.status == QueueStatus.closed
                            ? Icons.lock_outline
                            : queue?.status == QueueStatus.open
                                ? queue!.doctorStatus.icon
                                : Icons.people_outline,
                        size: 16,
                        color: queue?.status == QueueStatus.closed
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          queue?.status == QueueStatus.closed
                              ? AppLocalizations.of(context)
                                  .queueClosedForToday
                              : (queue == null ||
                                      queue.status == QueueStatus.pending)
                                  ? (openToday
                                      ? AppLocalizations.of(context)
                                          .queueNotYetOpen
                                      : AppLocalizations.of(context)
                                          .queueClosedSimple)
                                  : AppLocalizations.of(context)
                                      .doctorStatusDisplay(
                                          queue.doctorStatus),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: queue?.status == QueueStatus.closed
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: queue?.status == QueueStatus.closed
                                  ? scheme.error
                                  : scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                  if (queue != null && queue.statusNote.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 24, top: 2),
                      child: SizedBox.shrink(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 2),
                      child: Text(
                        queue.statusNote,
                        style: TextStyle(
                            fontSize: 11, color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                  if (queue?.status == QueueStatus.open) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(Icons.medical_services_outlined,
                            size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            inConsultation == null
                                ? AppLocalizations.of(context)
                                    .noActiveConsultation
                                : AppLocalizations.of(context)
                                    .nowServingSerial(inConsultation.serial),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: inConsultation == null
                                    ? scheme.onSurfaceVariant
                                    : scheme.primary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context)
                                .waitingCount(waitingCount),
                            style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _VerificationLine extends StatelessWidget {
  const _VerificationLine({required this.status});

  final DoctorVerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      DoctorVerificationStatus.verified => Colors.green.shade700,
      DoctorVerificationStatus.pending => Colors.amber.shade800,
      DoctorVerificationStatus.rejected => scheme.error,
    };
    return Row(
      children: [
        Icon(status.icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          AppLocalizations.of(context).verificationDisplay(status),
          style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _DoctorDayStatusBanner extends StatelessWidget {
  const _DoctorDayStatusBanner({required this.status});

  final DoctorDayStatusDoc status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status.status) {
      DoctorDayStatus.available =>
        (Colors.green.shade50, Colors.green.shade900),
      DoctorDayStatus.onLeave =>
        (scheme.errorContainer, scheme.onErrorContainer),
      DoctorDayStatus.atHospital =>
        (Colors.amber.shade50, Colors.amber.shade900),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(status.status.icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)
                      .dayStatusDisplay(status.status),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: fg),
                ),
                if (status.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(status.note,
                      style: TextStyle(fontSize: 13, color: fg)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating});

  final Rating rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < rating.stars ? Icons.star : Icons.star_border,
                size: 16,
                color: i < rating.stars
                    ? Colors.amber.shade700
                    : scheme.outline,
              ),
            ),
          ),
          if (rating.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(rating.text, style: const TextStyle(height: 1.3)),
          ],
        ],
      ),
    );
  }
}

class _BookingBadge extends StatelessWidget {
  const _BookingBadge({
    required this.mode,
    required this.queueStatus,
    required this.openToday,
  });

  final ChamberBookingMode mode;
  final QueueStatus? queueStatus;
  final bool openToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, bg, fg) = _resolve(l10n, scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color, Color) _resolve(
      AppLocalizations l10n, ColorScheme scheme) {
    if (!openToday) {
      return (
        l10n.bookingBadgeClosedToday,
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      );
    }
    if (queueStatus == QueueStatus.closed) {
      return (
        l10n.bookingBadgeClosedForToday,
        scheme.errorContainer,
        scheme.onErrorContainer,
      );
    }
    if (mode == ChamberBookingMode.queueOnly) {
      return (
        l10n.bookingBadgeWalkIn,
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      );
    }
    if (queueStatus == QueueStatus.open) {
      return (
        l10n.bookingBadgeBook,
        scheme.primary,
        scheme.onPrimary,
      );
    }
    return (
      l10n.bookingBadgeOpensLater,
      scheme.surfaceContainerHigh,
      scheme.onSurfaceVariant,
    );
  }
}
