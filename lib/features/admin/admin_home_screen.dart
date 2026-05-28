import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../../shared/widgets/error_state.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../queue/queue.dart';
import '../queue/queue_repository.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chambersAsync = ref.watch(allChambersStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamber Admin'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: chambersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          detail: ErrorState.friendly(e),
          onRetry: () => ref.invalidate(allChambersStreamProvider),
        ),
        data: (chambers) {
          if (chambers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        size: 64, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    const Text(
                      'No chambers assigned',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A doctor needs to invite you to manage their chamber.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  "Today's chambers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ...chambers.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChamberTile(chamber: c, today: today),
                ),
              ),
            ],
          );
        },
      ),
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
    final inConsultation =
        entries.where((e) => e.status == QueueEntryStatus.inConsultation).length;
    final completed =
        entries.where((e) => !e.status.isActive).length;

    final (badgeColor, badgeText) = switch (queueStatus) {
      QueueStatus.pending => (scheme.surfaceContainerHigh, 'Not opened'),
      QueueStatus.open => (Colors.green.shade100, 'Queue open'),
      QueueStatus.closed => (scheme.errorContainer, 'Closed'),
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
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: queueStatus == QueueStatus.open
                              ? Colors.green.shade900
                              : scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(chamber.address,
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${chamber.startTime} – ${chamber.endTime}',
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                  const SizedBox(width: 12),
                  if (!openToday)
                    Text('• Closed today',
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic)),
                ],
              ),
              if (queueAsync.value != null &&
                  queueStatus != QueueStatus.pending) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.event_outlined,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _formatQueueTime(queueAsync.value!),
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              if (queueStatus == QueueStatus.open || entries.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    if (inConsultation > 0)
                      _StatPill(
                          label: 'In consultation',
                          value: inConsultation,
                          color: scheme.primary),
                    if (waitingCount + arrivedCount > 0)
                      _StatPill(
                          label: 'Waiting',
                          value: waitingCount + arrivedCount,
                          color: scheme.onSurfaceVariant),
                    if (completed > 0)
                      _StatPill(
                          label: 'Done',
                          value: completed,
                          color: scheme.onSurfaceVariant),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatQueueTime(Queue queue) {
  if (queue.status == QueueStatus.closed && queue.closedAt != null) {
    return 'Closed at ${formatTime12h(queue.closedAt!)}';
  }
  if (queue.status == QueueStatus.open && queue.openedAt != null) {
    return 'Opened at ${formatTime12h(queue.openedAt!)}';
  }
  return '';
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
