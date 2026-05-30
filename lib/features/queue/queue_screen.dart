import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import 'queue.dart';
import 'queue_repository.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key, required this.chamberId});

  final String chamberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = todayDateKey();
    final key = QueueKey(chamberId, date);
    final queueAsync = ref.watch(queueStreamProvider(key));
    final entriesAsync = ref.watch(queueEntriesStreamProvider(key));
    final chambersAsync = ref.watch(allChambersStreamProvider);

    final chamber = chambersAsync.value?.firstWhere(
      (c) => c.id == chamberId,
      orElse: () => const Chamber(
        id: '',
        doctorId: '',
        name: 'Chamber',
        address: '',
        days: [],
        startTime: '',
        endTime: '',
        consultationFee: 0,
        bookingMode: ChamberBookingMode.fullDigital,
      ),
    );

    final l10n = AppLocalizations.of(context);
    return ScaffoldMessenger(
      child: Scaffold(
      appBar: AppBar(
        title: Text(chamber?.name ?? l10n.queueScreenFallback),
        actions: [
          if (queueAsync.value?.status == QueueStatus.open) ...[
            IconButton(
              tooltip: l10n.broadcastTooltip,
              icon: const Icon(Icons.campaign_outlined),
              onPressed: () => _showBroadcastDialog(
                context,
                ref,
                chamberId,
                date,
                queueAsync.value?.broadcastMessage ?? '',
              ),
            ),
            IconButton(
              tooltip: l10n.reorderTooltip,
              icon: const Icon(Icons.swap_vert),
              onPressed: () =>
                  context.push('/admin/queue/$chamberId/reorder'),
            ),
            IconButton(
              tooltip: l10n.scanRegisterTooltip,
              icon: const Icon(Icons.document_scanner_outlined),
              onPressed: () =>
                  context.push('/admin/queue/$chamberId/scan'),
            ),
            IconButton(
              tooltip: l10n.closeQueueTooltip,
              icon: const Icon(Icons.lock_outline),
              onPressed: () =>
                  _confirmCloseQueue(context, ref, chamberId, date),
            ),
            PopupMenuButton<String>(
              tooltip: l10n.moreMenuTooltip,
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'clear_all') {
                  _confirmClearAll(context, ref, chamberId, date);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(
                  value: 'clear_all',
                  child: ListTile(
                    leading: const Icon(Icons.delete_sweep_outlined),
                    title: Text(l10n.clearAllPatientsMenu),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
          if (queueAsync.value?.status == QueueStatus.closed)
            IconButton(
              tooltip: l10n.reopenQueueTooltip,
              icon: const Icon(Icons.lock_open_outlined),
              onPressed: () =>
                  ref.read(queueRepositoryProvider).reopenQueue(chamberId, date),
            ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.failedShort(e.toString()))),
        data: (queue) {
          final status = queue?.status ?? QueueStatus.pending;
          if (status == QueueStatus.pending) {
            return _PendingState(
              chamberId: chamberId,
              date: date,
              chamber: chamber,
            );
          }
          return _QueueBody(
            chamberId: chamberId,
            date: date,
            queue: queue!,
            entriesAsync: entriesAsync,
          );
        },
      ),
      floatingActionButton: queueAsync.value?.status == QueueStatus.open
          ? FloatingActionButton.extended(
              onPressed: () => _showAddPatient(context, ref, chamberId, date),
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addPatientFab),
            )
          : null,
      ),
    );
  }

  Future<void> _confirmCloseQueue(BuildContext context, WidgetRef ref,
      String chamberId, String date) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.closeQueueDialogTitle),
        content: Text(l10n.closeQueueDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.closeQueueButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(queueRepositoryProvider).closeQueue(chamberId, date);
    }
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref,
      String chamberId, String date) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.clearAllDialogTitle),
        content: Text(l10n.clearAllDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.clearAllButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(queueRepositoryProvider)
          .clearAllEntries(chamberId: chamberId, date: date);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.queueClearedSnack),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clearFailedSnack(e.toString()))),
      );
    }
  }

  Future<void> _showAddPatient(BuildContext context, WidgetRef ref,
      String chamberId, String date) {
    return showDialog<void>(
      context: context,
      builder: (_) => _AddPatientDialog(
        onSubmit: (name, phone) => ref.read(queueRepositoryProvider).addEntry(
              chamberId: chamberId,
              date: date,
              patientName: name,
              patientPhone: phone,
            ),
      ),
    );
  }

  Future<void> _showBroadcastDialog(
    BuildContext context,
    WidgetRef ref,
    String chamberId,
    String date,
    String current,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => _BroadcastDialog(
        currentMessage: current,
        onSubmit: (message) => ref.read(queueRepositoryProvider).sendBroadcast(
              chamberId: chamberId,
              date: date,
              message: message,
            ),
      ),
    );
  }
}

class _BroadcastDialog extends StatefulWidget {
  const _BroadcastDialog({
    required this.currentMessage,
    required this.onSubmit,
  });

  final String currentMessage;
  final Future<void> Function(String) onSubmit;

  @override
  State<_BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<_BroadcastDialog> {
  late final _controller =
      TextEditingController(text: widget.currentMessage);
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool clear}) async {
    setState(() => _saving = true);
    try {
      await widget.onSubmit(clear ? '' : _controller.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasExisting = widget.currentMessage.isNotEmpty;
    return AlertDialog(
      title: Text(l10n.broadcastDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.broadcastDialogBody),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !_saving,
              maxLines: 3,
              maxLength: 200,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.broadcastHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (hasExisting)
          TextButton(
            onPressed: _saving ? null : () => _submit(clear: true),
            child: Text(l10n.clearButton),
          ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : () => _submit(clear: false),
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.sendButton),
        ),
      ],
    );
  }
}

class _RestoreDialog extends StatefulWidget {
  const _RestoreDialog({
    required this.originalSerial,
    required this.suggestedSerial,
    required this.currentInConsultation,
    required this.maxSerial,
  });

  final int originalSerial;
  final int suggestedSerial;
  final int? currentInConsultation;
  final int maxSerial;

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.suggestedSerial.toString());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.restoreDialogTitle(widget.originalSerial)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.currentInConsultation != null) ...[
            Text(
              '${l10n.entryInConsultation}: #${widget.currentInConsultation}',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '${l10n.entryDone}: #${widget.maxSerial}',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(l10n.restoreAtSerial),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(prefixText: '#  '),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(widget.originalSerial),
          child: Text(l10n.restoreOriginalChip(widget.originalSerial)),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(_controller.text.trim());
            if (n != null && n > 0) Navigator.of(context).pop(n);
          },
          child: Text(l10n.placeButton),
        ),
      ],
    );
  }
}

class _AddPatientDialog extends StatefulWidget {
  const _AddPatientDialog({required this.onSubmit});

  final Future<void> Function(String name, String phone) onSubmit;

  @override
  State<_AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<_AddPatientDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
          _nameController.text.trim(), _phoneController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).addPatientFailedSnack(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addPatientDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.patientNameLabel),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_saving,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.patientPhoneLabel,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.addButton),
        ),
      ],
    );
  }
}

class _PendingState extends ConsumerWidget {
  const _PendingState({
    required this.chamberId,
    required this.date,
    required this.chamber,
  });

  final String chamberId;
  final String date;
  final Chamber? chamber;

  bool get _isQueueOnly =>
      chamber?.bookingMode == ChamberBookingMode.queueOnly;

  Future<void> _openQueue(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(queueRepositoryProvider);
    if (!_isQueueOnly) {
      await repo.openQueue(chamberId, date);
      return;
    }
    final slotCount = await showDialog<int>(
      context: context,
      builder: (_) => const _OpenSlotsDialog(),
    );
    if (slotCount == null || slotCount <= 0) return;
    await repo.openQueueWithEmptySlots(
      chamberId: chamberId,
      date: date,
      slotCount: slotCount,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline,
                size: 80, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.queueNotStartedTitle,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.queueOpenPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(_isQueueOnly
                  ? l10n.setTokensAndOpen
                  : l10n.openQueueButton),
              onPressed: () => _openQueue(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenSlotsDialog extends StatefulWidget {
  const _OpenSlotsDialog();

  @override
  State<_OpenSlotsDialog> createState() => _OpenSlotsDialogState();
}

class _OpenSlotsDialogState extends State<_OpenSlotsDialog> {
  final _controller = TextEditingController(text: '30');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.todaysTokensTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.queueOpenPrompt),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.numberOfTokensLabel,
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(_controller.text.trim());
            if (n != null && n > 0 && n <= 200) Navigator.of(context).pop(n);
          },
          child: Text(l10n.openButton),
        ),
      ],
    );
  }
}

class _QueueBody extends ConsumerWidget {
  const _QueueBody({
    required this.chamberId,
    required this.date,
    required this.queue,
    required this.entriesAsync,
  });

  final String chamberId;
  final String date;
  final Queue queue;
  final AsyncValue<List<QueueEntry>> entriesAsync;

  bool get isClosed => queue.status == QueueStatus.closed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final l10nLocal = AppLocalizations.of(context);
    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(l10nLocal.failedShort(e.toString()))),
      data: (entries) {
        final current = entries
            .where((e) => e.status == QueueEntryStatus.inConsultation)
            .toList();
        final upcoming = entries
            .where((e) =>
                e.status == QueueEntryStatus.waiting ||
                e.status == QueueEntryStatus.arrived)
            .toList();
        final completed = entries.where((e) => !e.status.isActive).toList();

        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    isClosed ? 'Queue closed.' : 'No patients yet.',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  if (!isClosed) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add patient" to start.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            _DoctorStatusBanner(
              chamberId: chamberId,
              date: date,
              queue: queue,
            ),
            if (queue.broadcastMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              _AdminBroadcastBanner(
                message: queue.broadcastMessage,
                chamberId: chamberId,
                date: date,
              ),
            ],
            const SizedBox(height: 12),
            if (current.isNotEmpty) ...[
              _SectionHeader('In consultation'),
              ...current.map((e) => _EntryCard(
                    entry: e,
                    allEntries: entries,
                    chamberId: chamberId,
                    date: date,
                    isClosed: isClosed,
                  )),
              const SizedBox(height: 16),
            ],
            if (upcoming.isNotEmpty) ...[
              _SectionHeader('Waiting (${upcoming.length})'),
              ...upcoming.map((e) => _EntryCard(
                    entry: e,
                    allEntries: entries,
                    chamberId: chamberId,
                    date: date,
                    isClosed: isClosed,
                  )),
              const SizedBox(height: 16),
            ],
            if (completed.isNotEmpty) ...[
              _SectionHeader('Completed (${completed.length})'),
              ...completed.map((e) => _EntryCard(
                    entry: e,
                    allEntries: entries,
                    chamberId: chamberId,
                    date: date,
                    isClosed: isClosed,
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _DoctorStatusBanner extends ConsumerWidget {
  const _DoctorStatusBanner({
    required this.chamberId,
    required this.date,
    required this.queue,
  });

  final String chamberId;
  final String date;
  final Queue queue;

  Color _bgColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (queue.doctorStatus) {
      DoctorStatus.available => Colors.green.shade50,
      DoctorStatus.runningLate => Colors.amber.shade50,
      DoctorStatus.notArrived => Colors.amber.shade50,
      DoctorStatus.onBreak => Colors.blue.shade50,
      DoctorStatus.doneForDay => scheme.surfaceContainerHighest,
    };
  }

  Color _fgColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (queue.doctorStatus) {
      DoctorStatus.available => Colors.green.shade900,
      DoctorStatus.runningLate => Colors.amber.shade900,
      DoctorStatus.notArrived => Colors.amber.shade900,
      DoctorStatus.onBreak => Colors.blue.shade900,
      DoctorStatus.doneForDay => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final bg = _bgColor(context);
    final fg = _fgColor(context);
    final editable = queue.status == QueueStatus.open;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: editable ? () => _showEditDialog(context, ref) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg),
                    ),
                    if (queue.statusNote.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        queue.statusNote,
                        style: TextStyle(fontSize: 13, color: fg),
                      ),
                    ],
                  ],
                ),
              ),
              if (editable)
                Icon(Icons.edit, size: 16, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DoctorStatusDialog(
        currentStatus: queue.doctorStatus,
        currentNote: queue.statusNote,
        onSubmit: (status, note) => ref
            .read(queueRepositoryProvider)
            .setDoctorStatus(
                chamberId: chamberId, date: date, status: status, note: note),
      ),
    );
  }
}

class _DoctorStatusDialog extends StatefulWidget {
  const _DoctorStatusDialog({
    required this.currentStatus,
    required this.currentNote,
    required this.onSubmit,
  });

  final DoctorStatus currentStatus;
  final String currentNote;
  final Future<void> Function(DoctorStatus, String) onSubmit;

  @override
  State<_DoctorStatusDialog> createState() => _DoctorStatusDialogState();
}

class _DoctorStatusDialogState extends State<_DoctorStatusDialog> {
  late DoctorStatus _status = widget.currentStatus;
  late final TextEditingController _noteController =
      TextEditingController(text: widget.currentNote);
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSubmit(_status, _noteController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).failedShort(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.doctorStatusDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<DoctorStatus>(
              groupValue: _status,
              onChanged: (v) {
                if (_saving || v == null) return;
                setState(() => _status = v);
              },
              child: Column(
                children: DoctorStatus.values
                    .map((s) => RadioListTile<DoctorStatus>(
                          value: s,
                          title: Text(l10n.doctorStatusShort(s)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: l10n.noteLabel,
                hintText: l10n.noteHint,
              ),
              maxLength: 80,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.updateButton),
        ),
      ],
    );
  }
}

class _AdminBroadcastBanner extends ConsumerWidget {
  const _AdminBroadcastBanner({
    required this.message,
    required this.chamberId,
    required this.date,
  });

  final String message;
  final String chamberId;
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign,
              color: Colors.amber.shade900, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).broadcastActiveLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).clearBroadcastTooltip,
            icon: Icon(Icons.close,
                color: Colors.amber.shade900, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: () => _confirmClear(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.clearBroadcastTitle),
        content: Text(l10n.clearBroadcastBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepButton),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.clearButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(queueRepositoryProvider).sendBroadcast(
          chamberId: chamberId,
          date: date,
          message: '',
        );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  const _EntryCard({
    required this.entry,
    required this.allEntries,
    required this.chamberId,
    required this.date,
    required this.isClosed,
  });

  final QueueEntry entry;
  final List<QueueEntry> allEntries;
  final String chamberId;
  final String date;
  final bool isClosed;

  int get _maxSerial {
    var max = 0;
    for (final e in allEntries) {
      if (e.serial > max) max = e.serial;
    }
    return max;
  }

  QueueEntry? get _inConsultation {
    for (final e in allEntries) {
      if (e.status == QueueEntryStatus.inConsultation) return e;
    }
    return null;
  }

  Future<void> _showRestoreDialog(
      BuildContext context, QueueRepository repo) async {
    final maxSerial = _maxSerial;
    final inConsult = _inConsultation;
    final newSerial = await showDialog<int>(
      context: context,
      builder: (_) => _RestoreDialog(
        originalSerial: entry.serial,
        suggestedSerial: maxSerial + 1,
        currentInConsultation: inConsult?.serial,
        maxSerial: maxSerial,
      ),
    );
    if (newSerial == null) return;
    if (!context.mounted) return;
    if (newSerial == entry.serial) {
      await _safeRun(
        context,
        () => _setStatus(repo, QueueEntryStatus.waiting),
        successMessage: '#${entry.serial} restored',
      );
    } else {
      await _safeRun(
        context,
        () => repo.restoreToSerial(
          chamberId: chamberId,
          date: date,
          entryId: entry.id,
          newSerial: newSerial,
        ),
        successMessage: 'Restored as #$newSerial',
      );
    }
  }

  Color _statusBg(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (entry.status) {
      QueueEntryStatus.inConsultation => scheme.primaryContainer,
      QueueEntryStatus.arrived => Colors.amber.shade100,
      QueueEntryStatus.done => Colors.green.shade100,
      QueueEntryStatus.noShow => scheme.errorContainer,
      QueueEntryStatus.cancelled => scheme.errorContainer,
      QueueEntryStatus.waiting => scheme.surfaceContainerHighest,
    };
  }

  Color _statusFg(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (entry.status) {
      QueueEntryStatus.inConsultation => scheme.onPrimaryContainer,
      QueueEntryStatus.arrived => Colors.amber.shade900,
      QueueEntryStatus.done => Colors.green.shade900,
      QueueEntryStatus.noShow => scheme.onErrorContainer,
      QueueEntryStatus.cancelled => scheme.onErrorContainer,
      QueueEntryStatus.waiting => scheme.onSurfaceVariant,
    };
  }

  Future<void> _showAddDetailsDialog(
      BuildContext context, QueueRepository repo) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _EntryDetailsDialog(
        serial: entry.serial,
        initialName: entry.patientName,
        initialPhone: entry.patientPhone,
        onSubmit: (name, phone) => repo.updateEntryDetails(
          chamberId: chamberId,
          date: date,
          entryId: entry.id,
          name: name,
          phone: phone,
        ),
      ),
    );
  }

  Future<void> _safeRun(
    BuildContext context,
    Future<void> Function() action, {
    String? successMessage,
    Future<void> Function()? undo,
  }) async {
    try {
      await action();
      if (!context.mounted || successMessage == null) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      final controller = messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: undo == null
              ? null
              : SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    try {
                      await undo();
                    } catch (_) {}
                  },
                ),
        ),
      );
      // Android extends snackbar duration when there's an action button
      // (accessibility "time to take action"). Force-close after 5s.
      Future<void>.delayed(const Duration(seconds: 5), () {
        controller.close();
      });
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).actionFailedSnack(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final repo = ref.read(queueRepositoryProvider);
    final highlighted = entry.status == QueueEntryStatus.inConsultation;
    final actions = isClosed ? <Widget>[] : _actionsFor(context, repo);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: highlighted
          ? scheme.primaryContainer.withValues(alpha: 0.3)
          : scheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: highlighted
            ? BorderSide(color: scheme.primary, width: 1.5)
            : BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Text(
                    '${entry.serial}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.patientName.isEmpty
                            ? '(no name)'
                            : entry.patientName,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      if (entry.patientPhone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          entry.patientPhone,
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBg(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)
                        .entryStatusDisplay(entry.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusFg(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(children: actions),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _setStatus(QueueRepository repo, QueueEntryStatus status) {
    return repo.updateStatus(
      chamberId: chamberId,
      date: date,
      entryId: entry.id,
      newStatus: status,
    );
  }

  List<Widget> _actionsFor(BuildContext context, QueueRepository repo) {
    final l10n = AppLocalizations.of(context);
    final serial = '#${entry.serial}';
    switch (entry.status) {
      case QueueEntryStatus.waiting:
        if (entry.patientName.isEmpty) {
          return [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () => _showAddDetailsDialog(context, repo),
                child: Text(l10n.addPatientDetailsButton),
              ),
            ),
          ];
        }
        return [
          Expanded(
            child: FilledButton.tonal(
              onPressed: () => _safeRun(
                context,
                () => _setStatus(repo, QueueEntryStatus.arrived),
                successMessage: l10n.markedArrivedMsg(serial),
                undo: () => _setStatus(repo, QueueEntryStatus.waiting),
              ),
              child: Text(l10n.markArrivedButton),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _safeRun(
              context,
              () => _setStatus(repo, QueueEntryStatus.cancelled),
              successMessage: l10n.cancelledMsg(serial),
              undo: () => _setStatus(repo, QueueEntryStatus.waiting),
            ),
            child: Text(l10n.cancel),
          ),
        ];
      case QueueEntryStatus.arrived:
        return [
          Expanded(
            child: FilledButton(
              onPressed: () => _safeRun(
                context,
                () => repo.startConsultation(
                  chamberId: chamberId,
                  date: date,
                  entryId: entry.id,
                ),
                successMessage: l10n.startedConsultationMsg(serial),
              ),
              child: Text(l10n.startConsultationButton),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _safeRun(
              context,
              () => _setStatus(repo, QueueEntryStatus.noShow),
              successMessage: l10n.markedNoShowMsg(serial),
              undo: () => _setStatus(repo, QueueEntryStatus.arrived),
            ),
            child: Text(l10n.noShowAction),
          ),
        ];
      case QueueEntryStatus.inConsultation:
        return [
          Expanded(
            child: FilledButton(
              onPressed: () => _safeRun(
                context,
                () => _setStatus(repo, QueueEntryStatus.done),
                successMessage: l10n.doneMsg(serial),
                undo: () => _setStatus(repo, QueueEntryStatus.inConsultation),
              ),
              child: Text(l10n.doneAction),
            ),
          ),
        ];
      case QueueEntryStatus.done:
      case QueueEntryStatus.noShow:
      case QueueEntryStatus.cancelled:
        return [
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.restore, size: 18),
            onPressed: () => _showRestoreDialog(context, repo),
            label: Text(l10n.restoreAction),
          ),
        ];
    }
  }
}

class _EntryDetailsDialog extends StatefulWidget {
  const _EntryDetailsDialog({
    required this.serial,
    required this.initialName,
    required this.initialPhone,
    required this.onSubmit,
  });

  final int serial;
  final String initialName;
  final String initialPhone;
  final Future<void> Function(String name, String phone) onSubmit;

  @override
  State<_EntryDetailsDialog> createState() => _EntryDetailsDialogState();
}

class _EntryDetailsDialogState extends State<_EntryDetailsDialog> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _phoneController =
      TextEditingController(text: widget.initialPhone);
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
          _nameController.text.trim(), _phoneController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).failedShort(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.patientSerialDialogTitle(widget.serial)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.patientNameLabel),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              enabled: !_saving,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.patientPhoneLabel,
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}
