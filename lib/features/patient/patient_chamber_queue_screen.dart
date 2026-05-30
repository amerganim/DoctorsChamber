import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../auth/current_user.dart';
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
      if (e.bookedById == currentPatientId() &&
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

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(chamber?.name ?? l10n.chambersSection)),
      body: SafeArea(
        child: queueAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text(l10n.queueLoadFailed(e.toString()))),
          data: (queue) => entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.queueLoadFailed(e.toString()))),
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
              label: Text(l10n.bookSerial),
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
        SnackBar(
            content: Text(
                AppLocalizations.of(context).bookedAsSerial(serial))),
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
      return _PendingChamberView(chamber: chamber);
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

    final isClosed = queue!.status == QueueStatus.closed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (isClosed) ...[
          _ClosedBanner(closedAt: queue!.closedAt),
          const SizedBox(height: 16),
        ] else ...[
          _StatusBanner(queue: queue!),
          if (queue!.broadcastMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _BroadcastBanner(message: queue!.broadcastMessage),
          ],
          const SizedBox(height: 16),
        ],
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
                Expanded(
                  child: Text(AppLocalizations.of(context)
                      .noConsultationRightNow),
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
              AppLocalizations.of(context).upNextSection(upcoming.length),
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
              AppLocalizations.of(context)
                  .completedTodaySection(completed.length),
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
          _Centered(
            icon: Icons.people_outline,
            title: AppLocalizations.of(context).noPatientsInQueue,
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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.cancelBookingTitle(ownBooking!.serial)),
        content: Text(l10n.cancelBookingBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepBooking),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.cancelBookingAction),
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
        SnackBar(content: Text(l10n.bookingCancelled(ownBooking!.serial))),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cancelFailed(e.toString()))),
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
                  AppLocalizations.of(context)
                      .doctorStatusDisplay(queue.doctorStatus),
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
                  AppLocalizations.of(context).nowServingTitle,
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
                AppLocalizations.of(context).yourBooking,
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
                child: Text(AppLocalizations.of(context).cancel),
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
                  AppLocalizations.of(context)
                      .entryStatusDisplay(booking.status),
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
                    AppLocalizations.of(context).waitMin(waitMin),
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

  String _statusLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (entry.status) {
      QueueEntryStatus.arrived => l10n.entryArrived,
      QueueEntryStatus.waiting => l10n.entryNotArrived,
      _ => l10n.entryStatusDisplay(entry.status),
    };
  }

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
              _statusLabel(context),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _statusColor(context),
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context).approxMin(estimateMin),
            style: TextStyle(
                fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PendingChamberView extends StatelessWidget {
  const _PendingChamberView({required this.chamber});

  final Chamber? chamber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();
    final openToday = chamber?.days.contains(today) ?? false;
    final openDaysLine = chamber == null
        ? ''
        : chamber!.days.join(', ');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: openToday
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                openToday ? Icons.schedule : Icons.event_busy_outlined,
                size: 56,
                color: openToday
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                openToday
                    ? l10n.queueNotStartedTitle
                    : l10n.chamberClosedTodayTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: openToday
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                openToday
                    ? l10n.adminWillOpenSoon
                    : l10n.differentDaysHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: openToday
                      ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
                      : scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (chamber != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chamber!.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                if (chamber!.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    chamber!.address,
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.openDaysLabel,
                  value: openDaysLine,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.access_time,
                  label: l10n.hoursLabel,
                  value:
                      '${chamber!.startTime} – ${chamber!.endTime}',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: l10n.consultationFeeLabel,
                  value: '৳${chamber!.consultationFee}',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.bookmark_outline,
                  label: l10n.bookingLabel,
                  value: l10n.bookingModeDisplay(chamber!.bookingMode),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.title});

  final IconData icon;
  final String title;

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
        ],
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner({required this.closedAt});

  final DateTime? closedAt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).closedForTodayBanner,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  closedAt != null
                      ? AppLocalizations.of(context)
                          .closedAtPattern(formatTime12h(closedAt!))
                      : AppLocalizations.of(context).closedNoTimeMessage,
                  style: TextStyle(
                      fontSize: 13, color: scheme.onErrorContainer),
                ),
              ],
            ),
          ),
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
                  AppLocalizations.of(context).broadcastFromChamber,
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
