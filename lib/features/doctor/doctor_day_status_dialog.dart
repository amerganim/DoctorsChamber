import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import 'doctor_day_status.dart';
import 'doctor_day_status_repository.dart';

class DoctorDayStatusDialog extends ConsumerStatefulWidget {
  const DoctorDayStatusDialog({
    super.key,
    required this.doctorId,
    required this.date,
    required this.current,
  });

  final String doctorId;
  final String date;
  final DoctorDayStatusDoc current;

  @override
  ConsumerState<DoctorDayStatusDialog> createState() =>
      _DoctorDayStatusDialogState();
}

class _DoctorDayStatusDialogState
    extends ConsumerState<DoctorDayStatusDialog> {
  late DoctorDayStatus _status = widget.current.status;
  late final TextEditingController _noteController =
      TextEditingController(text: widget.current.note);
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(doctorDayStatusRepositoryProvider).set(
            doctorId: widget.doctorId,
            date: widget.date,
            status: _status,
            note: _noteController.text.trim(),
          );
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
      title: Text(l10n.todaysAvailability),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<DoctorDayStatus>(
              groupValue: _status,
              onChanged: (v) {
                if (_saving || v == null) return;
                setState(() => _status = v);
              },
              child: Column(
                children: DoctorDayStatus.values
                    .map(
                      (s) => RadioListTile<DoctorDayStatus>(
                        value: s,
                        title: Text(l10n.dayStatusDisplay(s)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              enabled: !_saving,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: l10n.noteOptionalLabel,
                hintText: l10n.noteOptionalHint,
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
