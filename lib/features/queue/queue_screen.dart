import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(chamber?.name ?? 'Queue'),
        actions: [
          if (queueAsync.value?.status == QueueStatus.open) ...[
            IconButton(
              tooltip: 'Reorder queue',
              icon: const Icon(Icons.swap_vert),
              onPressed: () =>
                  context.push('/admin/queue/$chamberId/reorder'),
            ),
            IconButton(
              tooltip: 'Scan register',
              icon: const Icon(Icons.document_scanner_outlined),
              onPressed: () =>
                  context.push('/admin/queue/$chamberId/scan'),
            ),
            IconButton(
              tooltip: 'Close queue',
              icon: const Icon(Icons.lock_outline),
              onPressed: () =>
                  _confirmCloseQueue(context, ref, chamberId, date),
            ),
          ],
          if (queueAsync.value?.status == QueueStatus.closed)
            IconButton(
              tooltip: 'Reopen queue',
              icon: const Icon(Icons.lock_open_outlined),
              onPressed: () =>
                  ref.read(queueRepositoryProvider).reopenQueue(chamberId, date),
            ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed: $e')),
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
              label: const Text('Add patient'),
            )
          : null,
    );
  }

  Future<void> _confirmCloseQueue(BuildContext context, WidgetRef ref,
      String chamberId, String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close queue for today?'),
        content: const Text(
            'No more patients can be added. Existing entries stay visible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close queue'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(queueRepositoryProvider).closeQueue(chamberId, date);
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
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Restore #${widget.originalSerial}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.currentInConsultation != null) ...[
            Text(
              'In consultation: #${widget.currentInConsultation}',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            'Last serial in queue: #${widget.maxSerial}',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const Text('Restore at serial:'),
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(widget.originalSerial),
          child: Text('Original #${widget.originalSerial}'),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(_controller.text.trim());
            if (n != null && n > 0) Navigator.of(context).pop(n);
          },
          child: const Text('Place'),
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
        SnackBar(content: Text('Failed to add: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add patient'),
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
              decoration: const InputDecoration(labelText: 'Patient name'),
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
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
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
            const Text(
              "Today's queue hasn't started yet",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isQueueOnly
                  ? 'Walk-in chamber. Set today\'s token count to start.'
                  : 'Open the queue to start adding patients.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(_isQueueOnly ? 'Set tokens & open' : 'Open queue'),
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
    return AlertDialog(
      title: const Text("Today's tokens"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How many empty token slots should the queue start with? '
            'Names get filled in as patients arrive.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Number of tokens',
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(_controller.text.trim());
            if (n != null && n > 0 && n <= 200) Navigator.of(context).pop(n);
          },
          child: const Text('Open'),
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

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
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
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Doctor status'),
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
                          title: Text(s.shortLabel),
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
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Back in 15 min',
              ),
              maxLength: 80,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update'),
        ),
      ],
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 4),
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
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
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
                    entry.status.displayName,
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
    final serial = '#${entry.serial}';
    switch (entry.status) {
      case QueueEntryStatus.waiting:
        if (entry.patientName.isEmpty) {
          return [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () => _showAddDetailsDialog(context, repo),
                child: const Text('Add patient details'),
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
                successMessage: '$serial marked arrived',
                undo: () => _setStatus(repo, QueueEntryStatus.waiting),
              ),
              child: const Text('Mark arrived'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _safeRun(
              context,
              () => _setStatus(repo, QueueEntryStatus.cancelled),
              successMessage: '$serial cancelled',
              undo: () => _setStatus(repo, QueueEntryStatus.waiting),
            ),
            child: const Text('Cancel'),
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
                successMessage: 'Started consultation for $serial',
              ),
              child: const Text('Start consultation'),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _safeRun(
              context,
              () => _setStatus(repo, QueueEntryStatus.noShow),
              successMessage: '$serial marked no-show',
              undo: () => _setStatus(repo, QueueEntryStatus.arrived),
            ),
            child: const Text('No-show'),
          ),
        ];
      case QueueEntryStatus.inConsultation:
        return [
          Expanded(
            child: FilledButton(
              onPressed: () => _safeRun(
                context,
                () => _setStatus(repo, QueueEntryStatus.done),
                successMessage: '$serial done',
                undo: () => _setStatus(repo, QueueEntryStatus.inConsultation),
              ),
              child: const Text('Done'),
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
            label: const Text('Restore'),
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
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Patient #${widget.serial}'),
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
              decoration: const InputDecoration(labelText: 'Patient name'),
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
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                counterText: '',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
