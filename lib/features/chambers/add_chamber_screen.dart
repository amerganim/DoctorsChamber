import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../auth/current_user.dart';
import 'chamber.dart';
import 'chamber_repository.dart';

class AddChamberScreen extends ConsumerStatefulWidget {
  const AddChamberScreen({super.key, this.existing});

  /// When non-null, the screen edits this chamber instead of creating a new one.
  final Chamber? existing;

  @override
  ConsumerState<AddChamberScreen> createState() => _AddChamberScreenState();
}

class _AddChamberScreenState extends ConsumerState<AddChamberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _feeController = TextEditingController(text: '500');
  final _capController = TextEditingController(text: '20');

  final Set<String> _selectedDays = {'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'};
  TimeOfDay _startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  ChamberBookingMode _bookingMode = ChamberBookingMode.fullDigital;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing == null) return;
    _nameController.text = existing.name;
    _addressController.text = existing.address;
    _feeController.text = existing.consultationFee.toString();
    _capController.text = (existing.dailyAppBookingCap ?? 20).toString();
    _selectedDays
      ..clear()
      ..addAll(existing.days);
    _startTime = _parseTime(existing.startTime);
    _endTime = _parseTime(existing.endTime);
    _bookingMode = existing.bookingMode;
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 17, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 17,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    _capController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickStart() async {
    final picked =
        await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEnd() async {
    final picked =
        await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).selectAtLeastOneDay)),
      );
      return;
    }
    setState(() => _saving = true);
    final existing = widget.existing;
    final chamber = Chamber(
      id: existing?.id ?? '',
      doctorId: existing?.doctorId ?? currentDoctorId(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      days: kWeekdays.where(_selectedDays.contains).toList(),
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      consultationFee: int.tryParse(_feeController.text.trim()) ?? 0,
      bookingMode: _bookingMode,
      dailyAppBookingCap: _bookingMode == ChamberBookingMode.hybridWithCap
          ? int.tryParse(_capController.text.trim())
          : null,
    );
    try {
      final repo = ref.read(chamberRepositoryProvider);
      if (_isEditing) {
        await repo.update(chamber);
      } else {
        await repo.add(chamber);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editChamberTitle : l10n.addChamberTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.chamberNameLabel,
                  hintText: l10n.chamberNameHint,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.chamberAddressLabel,
                  hintText: l10n.chamberAddressHint,
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 24),
              Text(l10n.openDaysSection,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: kWeekdays.map((day) {
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(l10n.hoursSection,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                          l10n.startTimePrefix(_formatTime(_startTime))),
                      onPressed: _pickStart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(l10n.endTimePrefix(_formatTime(_endTime))),
                      onPressed: _pickEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _feeController,
                decoration: InputDecoration(
                  labelText: l10n.consultationFeeBdt,
                  prefixText: '৳ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return l10n.requiredField;
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(l10n.bookingModeSection,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              RadioGroup<ChamberBookingMode>(
                groupValue: _bookingMode,
                onChanged: (v) => setState(() => _bookingMode = v!),
                child: Column(
                  children: ChamberBookingMode.values
                      .map(
                        (mode) => RadioListTile<ChamberBookingMode>(
                          value: mode,
                          title: Text(l10n.bookingModeDisplay(mode)),
                          subtitle: Text(l10n.bookingModeDescription(mode)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ),
              if (_bookingMode == ChamberBookingMode.hybridWithCap) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _capController,
                  decoration: InputDecoration(
                    labelText: l10n.dailyAppCapLabel,
                    helperText: l10n.dailyAppCapHelper,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (_bookingMode != ChamberBookingMode.hybridWithCap) {
                      return null;
                    }
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n <= 0) return l10n.requiredField;
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing
                        ? l10n.saveChangesButton
                        : l10n.saveChamberButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
