import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../auth/current_user.dart';
import '../auth/user_role_enrollment.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../queue/queue.dart';
import '../queue/queue_janitor.dart';
import '../queue/queue_repository.dart';
import 'doctor_day_status.dart';
import 'doctor_day_status_dialog.dart';
import 'doctor_day_status_repository.dart';
import 'doctor_profile_repository.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You will need to sign in again to manage your chambers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    LoadingOverlay.show(context, 'Signing you out…');
    await signOutDoctor();
    ref.invalidate(userRoleEnrollmentProvider);
    if (!context.mounted) return;
    LoadingOverlay.dismiss(context);
    if (!context.mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync =
        ref.watch(doctorProfileStreamProvider(currentDoctorId()));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load profile:\n$e',
                textAlign: TextAlign.center),
          ),
        ),
        data: (profile) {
          final hasProfile = profile != null && profile.name.isNotEmpty;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasProfile) ...[
                  const Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up your profile so patients can find you.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ] else ...[
                  Text(
                    profile.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  if (profile.qualifications.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(profile.qualifications,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                  if (profile.specialties.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.specialties.join(' • '),
                      style: TextStyle(
                          color: scheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (profile.yearsOfExperience > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile.yearsOfExperience} years of experience',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                const _TodayStatusSection(),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(hasProfile ? 'Edit profile' : 'Create profile'),
                  onPressed: () => context.push('/doctor/profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: const Text('Manage chambers'),
                  onPressed: () => context.push('/doctor/chambers'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
                const _ManageQueueSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayStatusSection extends ConsumerWidget {
  const _TodayStatusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = todayDateKey();
    final statusAsync = ref.watch(
      doctorDayStatusProvider(DoctorDayStatusKey(currentDoctorId(), date)),
    );
    final scheme = Theme.of(context).colorScheme;
    final doc = statusAsync.value;
    if (doc == null) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final (bg, fg) = switch (doc.status) {
      DoctorDayStatus.available => (
          Colors.green.shade50,
          Colors.green.shade900
        ),
      DoctorDayStatus.onLeave => (
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
      DoctorDayStatus.atHospital => (
          Colors.amber.shade50,
          Colors.amber.shade900,
        ),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => DoctorDayStatusDialog(
            doctorId: currentDoctorId(),
            date: date,
            current: doc,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(doc.status.icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today: ${doc.status.displayName}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: fg),
                    ),
                    if (doc.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        doc.note,
                        style: TextStyle(fontSize: 12, color: fg),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.edit, size: 16, color: fg.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageQueueSection extends ConsumerWidget {
  const _ManageQueueSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chambersAsync =
        ref.watch(chambersByDoctorStreamProvider(currentDoctorId()));
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();

    final chambers = chambersAsync.value;
    if (chambers == null || chambers.isEmpty) return const SizedBox.shrink();

    return QueueJanitorRunner(
      chamberIds: chambers.map((c) => c.id).toList(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Today's queues",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chambers.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final c in chambers)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DoctorChamberCard(chamber: c, today: today),
            ),
        ],
      ),
    );
  }
}

class _DoctorChamberCard extends ConsumerWidget {
  const _DoctorChamberCard({required this.chamber, required this.today});

  final Chamber chamber;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dateKey = todayDateKey();
    final queueAsync =
        ref.watch(queueStreamProvider(QueueKey(chamber.id, dateKey)));
    final entriesAsync =
        ref.watch(queueEntriesStreamProvider(QueueKey(chamber.id, dateKey)));
    final openToday = chamber.days.contains(today);

    final queueStatus = queueAsync.value?.status ?? QueueStatus.pending;
    final entries = entriesAsync.value ?? const [];
    final waitingCount =
        entries.where((e) => e.status == QueueEntryStatus.waiting).length;
    final arrivedCount =
        entries.where((e) => e.status == QueueEntryStatus.arrived).length;
    final inConsultation = entries
        .where((e) => e.status == QueueEntryStatus.inConsultation)
        .length;
    final completed = entries.where((e) => !e.status.isActive).length;
    final inConsultationEntries = entries
        .where((e) => e.status == QueueEntryStatus.inConsultation)
        .toList();
    final currentSerial = inConsultationEntries.isEmpty
        ? 0
        : inConsultationEntries.first.serial;

    final (badgeColor, badgeFg, badgeIcon, badgeText) = switch (queueStatus) {
      QueueStatus.pending => (
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
          Icons.schedule_outlined,
          'Not opened',
        ),
      QueueStatus.open => (
          Colors.green.shade100,
          Colors.green.shade900,
          Icons.circle,
          'Live',
        ),
      QueueStatus.closed => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.lock_outline,
          'Closed',
        ),
    };

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/admin/queue/${chamber.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chamber.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 11, color: badgeFg),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeFg),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                chamber.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 13, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${chamber.startTime} – ${chamber.endTime}',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  if (!openToday) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.event_busy_outlined,
                        size: 13, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Closed today',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (queueStatus == QueueStatus.open || entries.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DoctorStat(
                          label: 'Now seeing',
                          value: currentSerial > 0 ? '#$currentSerial' : '—',
                          highlight: currentSerial > 0,
                        ),
                      ),
                      _StatDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _DoctorStat(
                          label: 'Waiting',
                          value: '${waitingCount + arrivedCount}',
                        ),
                      ),
                      _StatDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _DoctorStat(
                          label: 'Done',
                          value: '$completed',
                        ),
                      ),
                    ],
                  ),
                ),
                if (inConsultation == 0 && (waitingCount + arrivedCount) > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 13, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Patients are waiting — tap to start',
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorStat extends StatelessWidget {
  const _DoctorStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: highlight ? scheme.primary : scheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: color);
  }
}
