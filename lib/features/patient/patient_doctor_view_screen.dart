import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/weekday.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../doctor/doctor_profile.dart';
import '../doctor/doctor_profile_repository.dart';
import 'package:go_router/go_router.dart';

import '../queue/queue.dart';
import '../queue/queue_repository.dart';
import '../ratings/rating.dart';
import '../ratings/rating_repository.dart';

class PatientDoctorViewScreen extends ConsumerWidget {
  const PatientDoctorViewScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(doctorProfileStreamProvider(doctorId));
    final chambersAsync = ref.watch(chambersByDoctorStreamProvider(doctorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Failed to load: $e', textAlign: TextAlign.center)),
        data: (doctor) {
          if (doctor == null) {
            return const Center(child: Text('Doctor not found'));
          }
          return chambersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Failed to load chambers: $e')),
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
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();
    final summary = ref.watch(ratingSummaryProvider(doctor.id));
    final ratings =
        ref.watch(ratingsByDoctorStreamProvider(doctor.id)).value ??
            const <Rating>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person,
                  size: 36, color: scheme.onPrimaryContainer),
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
                      '${doctor.yearsOfExperience} years of experience',
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
              Text('BMDC: ${doctor.bmdcNumber}',
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber.shade700),
            const SizedBox(width: 6),
            Text(
              summary.count == 0
                  ? 'No reviews yet'
                  : '${summary.average.toStringAsFixed(1)} · ${summary.count} review${summary.count == 1 ? '' : 's'}',
              style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (doctor.bio.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(doctor.bio, style: const TextStyle(height: 1.4)),
        ],
        if (doctor.languages.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Languages',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
          const Text('Recent reviews',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...ratings.take(5).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RatingCard(rating: r),
                ),
              ),
        ],
        const SizedBox(height: 24),
        const Text('Chambers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (chambers.isEmpty)
          Text(
            'No chambers listed yet.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
        else
          ...chambers.map((c) =>
              Padding(padding: const EdgeInsets.only(bottom: 12), child: _ChamberTile(chamber: c, today: today))),
      ],
    );
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    chamber.bookingMode.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                        queue?.status == QueueStatus.open
                            ? queue!.doctorStatus.icon
                            : Icons.people_outline,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          queue == null ||
                                  queue.status == QueueStatus.pending
                              ? (openToday
                                  ? 'Queue not yet open today'
                                  : 'Closed today')
                              : queue.doctorStatus.displayName,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant),
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
                                ? 'No active consultation'
                                : 'Now serving: #${inConsultation.serial}',
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
                            '$waitingCount waiting',
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
