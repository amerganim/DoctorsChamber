import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  String get _noteLabel => switch (_status) {
        DoctorDayStatus.available => 'Note (optional)',
        DoctorDayStatus.onLeave => 'Reason (optional)',
        DoctorDayStatus.atHospital => 'Hospital name',
      };

  String get _noteHint => switch (_status) {
        DoctorDayStatus.available => 'e.g. Visiting hours flexible today',
        DoctorDayStatus.onLeave => 'e.g. Personal',
        DoctorDayStatus.atHospital => 'e.g. Square Hospital, Cardiology unit',
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Today's availability"),
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
                        title: Text(s.displayName),
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
                labelText: _noteLabel,
                hintText: _noteHint,
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
