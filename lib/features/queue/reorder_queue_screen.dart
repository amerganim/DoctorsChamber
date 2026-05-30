import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import 'queue.dart';
import 'queue_repository.dart';

class ReorderQueueScreen extends ConsumerStatefulWidget {
  const ReorderQueueScreen({super.key, required this.chamberId});

  final String chamberId;

  @override
  ConsumerState<ReorderQueueScreen> createState() =>
      _ReorderQueueScreenState();
}

class _ReorderQueueScreenState extends ConsumerState<ReorderQueueScreen> {
  List<QueueEntry> _entries = [];
  List<int> _originalSerials = [];
  bool _loading = true;
  bool _saving = false;
  bool _changed = false;
  String? _error;

  late final String _date = todayDateKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await ref
          .read(queueRepositoryProvider)
          .fetchEntriesOnce(widget.chamberId, _date);
      final upcoming = all
          .where((e) =>
              e.status == QueueEntryStatus.waiting ||
              e.status == QueueEntryStatus.arrived)
          .toList()
        ..sort((a, b) => a.serial.compareTo(b.serial));
      if (!mounted) return;
      setState(() {
        _entries = upcoming;
        _originalSerials = upcoming.map((e) => e.serial).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, item);
      _changed = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final assignments = <({String entryId, int newSerial})>[];
      for (var i = 0; i < _entries.length; i++) {
        final newSerial = _originalSerials[i];
        if (_entries[i].serial != newSerial) {
          assignments
              .add((entryId: _entries[i].id, newSerial: newSerial));
        }
      }
      if (assignments.isNotEmpty) {
        await ref.read(queueRepositoryProvider).reassignSerials(
              chamberId: widget.chamberId,
              date: _date,
              assignments: assignments,
            );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).saveFailedSnack(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reorderQueueTitle),
        actions: [
          TextButton(
            onPressed: _changed && !_saving ? _save : null,
            child: Text(_saving ? l10n.savingEllipsis : l10n.save),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.failedToLoadGeneric(_error ?? ''),
                        textAlign: TextAlign.center),
                  ),
                )
              : _entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.queue_outlined,
                                size: 64, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noWaitingToReorder,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          color: scheme.surfaceContainerHighest,
                          child: Text(
                            l10n.reorderHint,
                            style: TextStyle(
                                fontSize: 12, color: scheme.onSurfaceVariant),
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            itemCount: _entries.length,
                            onReorderItem: _onReorder,
                            itemBuilder: (_, i) {
                              final e = _entries[i];
                              final newSerial = _originalSerials[i];
                              final changedHere = e.serial != newSerial;
                              return Container(
                                key: ValueKey(e.id),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: changedHere
                                      ? scheme.primaryContainer
                                          .withValues(alpha: 0.4)
                                      : scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: scheme.outlineVariant),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: scheme.outlineVariant),
                                      ),
                                      child: Text(
                                        '#$newSerial',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.patientName.isEmpty
                                                ? '(no name)'
                                                : e.patientName,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.w600),
                                          ),
                                          if (changedHere)
                                            Text(
                                              'was #${e.serial}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: scheme
                                                      .onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.drag_handle,
                                        color: scheme.onSurfaceVariant),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
