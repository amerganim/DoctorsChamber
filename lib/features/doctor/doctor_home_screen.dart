import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../chambers/chamber_repository.dart';
import 'doctor_day_status.dart';
import 'doctor_day_status_dialog.dart';
import 'doctor_day_status_repository.dart';
import 'doctor_profile_repository.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync =
        ref.watch(doctorProfileStreamProvider(kDevDoctorId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
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
          return Padding(
            padding: const EdgeInsets.all(24),
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
      doctorDayStatusProvider(DoctorDayStatusKey(kDevDoctorId, date)),
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
            doctorId: kDevDoctorId,
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
        ref.watch(chambersByDoctorStreamProvider(kDevDoctorId));
    final scheme = Theme.of(context).colorScheme;

    final chambers = chambersAsync.value;
    if (chambers == null || chambers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's queues",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        for (final c in chambers)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(c.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: TextButton(
                onPressed: () => context.push('/admin/queue/${c.id}'),
                child: const Text('Manage'),
              ),
            ),
          ),
      ],
    );
  }
}
