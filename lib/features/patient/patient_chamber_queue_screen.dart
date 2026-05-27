import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/weekday.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../queue/queue.dart';
import '../queue/queue_repository.dart';
import 'book_serial_dialog.dart';

const _avgConsultationMinutes = 10;

class PatientChamberQueueScreen extends ConsumerWidget {
  const PatientChamberQueueScreen({super.key, required this.chamberId});

  final String chamberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chambersAsync = ref.watch(allChambersStreamProvider);
    final chamber = chambersAsync.value
        ?.where((c) => c.id == chamberId)
        .firstOrNull;

    final qKey = QueueKey(chamberId, todayDateKey());
    final queueAsync = ref.watch(queueStreamProvider(qKey));
    final entriesAsync = ref.watch(queueEntriesStreamProvider(qKey));

    final today = todayDateKey();
    final entries = entriesAsync.value ?? const <QueueEntry>[];
    QueueEntry? ownActiveBooking;
    for (final e in entries) {
      if (e.bookedById == kDevPatientId &&
          e.date == today &&
          e.status.isActive) {
        ownActiveBooking = e;
        break;
      }
    }

    final canBook = chamber != null &&
        chamber.bookingMode != ChamberBookingMode.queueOnly &&
        queueAsync.value?.status == QueueStatus.open &&
        ownActiveBooking == null;

    return Scaffold(
      appBar: AppBar(title: Text(chamber?.name ?? 'Chamber')),
      body: SafeArea(
        child: queueAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed: $e')),
          data: (queue) => entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed: $e')),
            data: (entries) => _Body(
              chamber: chamber,
              queue: queue,
              entries: entries,
              ownBooking: ownActiveBooking,
            ),
          ),
        ),
      ),
      floatingActionButton: canBook
          ? FloatingActionButton.extended(
              onPressed: () => _book(context, chamber),
              icon: const Icon(Icons.add),
              label: const Text('Book serial'),
            )
          : null,
    );
  }

  Future<void> _book(BuildContext context, Chamber chamber) async {
    final serial = await showDialog<int>(
      context: context,
      builder: (_) => BookSerialDialog(chamber: chamber),
    );
    if (serial != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booked as #$serial')),
      );
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.chamber,
    required this.queue,
    required this.entries,
    required this.ownBooking,
  });

  final Chamber? chamber;
  final Queue? queue;
  final List<QueueEntry> entries;
  final QueueEntry? ownBooking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    if (queue == null || queue!.status == QueueStatus.pending) {
      return _Centered(
        icon: Icons.schedule_outlined,
        title: "Queue hasn't started yet",
        subtitle: chamber == null
            ? null
            : "Open hours: ${chamber!.startTime} – ${chamber!.endTime}",
      );
    }

    final current = entries
        .where((e) => e.status == QueueEntryStatus.inConsultation)
        .toList();
    final upcoming = entries
        .where((e) =>
            e.status == QueueEntryStatus.waiting ||
            e.status == QueueEntryStatus.arrived)
        .toList();
    final completed = entries.where((e) => !e.status.isActive).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _StatusBanner(queue: queue!),
        if (queue!.broadcastMessage.isNotEmpty) ...[
          const SizedBox(height: 12),
          _BroadcastBanner(message: queue!.broadcastMessage),
        ],
        const SizedBox(height: 16),
        if (ownBooking != null) ...[
          _OwnBookingBanner(
            booking: ownBooking!,
            positionFromNow: _positionAmongUpcoming(),
            onCancel: () => _confirmCancel(context, ref),
          ),
          const SizedBox(height: 16),
        ],
        if (current.isNotEmpty) ...[
          _NowServingCard(serial: current.first.serial),
          const SizedBox(height: 20),
        ] else if (queue!.status == QueueStatus.open) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.pause_circle_outline,
                    color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('No active consultation right now'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Up next (${upcoming.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...upcoming.asMap().entries.map((pair) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _UpNextRow(
                  entry: pair.value,
                  positionFromNow: pair.key,
                  isOwn: pair.value.id == ownBooking?.id,
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Completed today (${completed.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: completed
                .map((e) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${e.serial}',
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            decoration: e.status == QueueEntryStatus.done
                                ? null
                                : TextDecoration.lineThrough),
                      ),
                    ))
                .toList(),
          ),
        ],
        if (queue!.status == QueueStatus.open &&
            current.isEmpty &&
            upcoming.isEmpty &&
            completed.isEmpty)
          const _Centered(
            icon: Icons.people_outline,
            title: 'No patients in the queue yet',
          ),
      ],
    );
  }

  int? _positionAmongUpcoming() {
    if (ownBooking == null) return null;
    final upcoming = entries
        .where((e) =>
            e.status == QueueEntryStatus.waiting ||
            e.status == QueueEntryStatus.arrived)
        .toList();
    for (var i = 0; i < upcoming.length; i++) {
      if (upcoming[i].id == ownBooking!.id) return i;
    }
    return null;
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cancel booking #${ownBooking!.serial}?'),
        content: const Text('Your serial will be released. You can re-book if the queue still has space.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep booking'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(queueRepositoryProvider).updateStatus(
            chamberId: ownBooking!.chamberId,
            date: ownBooking!.date,
            entryId: ownBooking!.id,
            newStatus: QueueEntryStatus.cancelled,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking #${ownBooking!.serial} cancelled')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancel failed: $e')),
      );
    }
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.queue});

  final Queue queue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = switch (queue.doctorStatus) {
      DoctorStatus.available => Colors.green.shade50,
      DoctorStatus.runningLate => Colors.amber.shade50,
      DoctorStatus.notArrived => Colors.amber.shade50,
      DoctorStatus.onBreak => Colors.blue.shade50,
      DoctorStatus.doneForDay => scheme.surfaceContainerHighest,
    };
    final fg = switch (queue.doctorStatus) {
      DoctorStatus.available => Colors.green.shade900,
      DoctorStatus.runningLate => Colors.amber.shade900,
      DoctorStatus.notArrived => Colors.amber.shade900,
      DoctorStatus.onBreak => Colors.blue.shade900,
      DoctorStatus.doneForDay => scheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(queue.doctorStatus.icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  queue.doctorStatus.displayName,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: fg),
                ),
                if (queue.statusNote.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(queue.statusNote,
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

class _NowServingCard extends StatelessWidget {
  const _NowServingCard({required this.serial});

  final int serial;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_services_outlined,
              color: scheme.onPrimaryContainer, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Now serving',
                  style: TextStyle(
                      fontSize: 13,
                      color: scheme.onPrimaryContainer,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '#$serial',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnBookingBanner extends StatelessWidget {
  const _OwnBookingBanner({
    required this.booking,
    required this.positionFromNow,
    required this.onCancel,
  });

  final QueueEntry booking;
  final int? positionFromNow;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final waitMin = positionFromNow == null
        ? null
        : (positionFromNow! + 1) * _avgConsultationMinutes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number_outlined,
                  color: scheme.onPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Your booking',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#${booking.serial}',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  booking.status.displayName,
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              if (waitMin != null && booking.status == QueueEntryStatus.waiting)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '~$waitMin min wait',
                    style: TextStyle(
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.entry,
    required this.positionFromNow,
    this.isOwn = false,
  });

  final QueueEntry entry;
  final int positionFromNow;
  final bool isOwn;

  String get _statusLabel => switch (entry.status) {
        QueueEntryStatus.arrived => 'Arrived',
        QueueEntryStatus.waiting => 'Not arrived',
        _ => entry.status.displayName,
      };

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (entry.status) {
      QueueEntryStatus.arrived => Colors.amber.shade900,
      QueueEntryStatus.waiting => scheme.onSurfaceVariant,
      _ => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final estimateMin = (positionFromNow + 1) * _avgConsultationMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isOwn ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwn ? scheme.primary : scheme.outlineVariant,
          width: isOwn ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${entry.serial}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _statusColor(context),
              ),
            ),
          ),
          Text(
            '~$estimateMin min',
            style: TextStyle(
                fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _BroadcastBanner extends StatelessWidget {
  const _BroadcastBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From the chamber',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                      fontSize: 14, color: Colors.amber.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
