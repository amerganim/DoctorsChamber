import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/current_user.dart';
import '../chambers/chamber.dart';
import '../queue/queue_repository.dart';

class BookSerialDialog extends ConsumerStatefulWidget {
  const BookSerialDialog({super.key, required this.chamber});

  final Chamber chamber;

  @override
  ConsumerState<BookSerialDialog> createState() => _BookSerialDialogState();
}

class _BookSerialDialogState extends ConsumerState<BookSerialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(queueRepositoryProvider);
    final result = await repo.bookForPatient(
      chamber: widget.chamber,
      date: todayDateKey(),
      patientId: currentPatientId(),
      patientName: _nameController.text.trim(),
      patientPhone: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
    );
    if (!mounted) return;
    if (result.errorMessage != null) {
      setState(() {
        _saving = false;
        _error = result.errorMessage;
      });
      return;
    }
    Navigator.of(context).pop(result.assignedSerial);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.bookSerialDialogTitle(widget.chamber.name)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todayWeekday(),
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l10n.patientNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_saving,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.phoneLabel,
                  counterText: '',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                enabled: !_saving,
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.ageOptionalLabel,
                  counterText: '',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: scheme.error, fontSize: 13),
                ),
              ],
            ],
          ),
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
              : Text(l10n.bookAction),
        ),
      ],
    );
  }
}
