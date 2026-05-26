import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../doctor/doctor_profile_repository.dart';
import 'chamber.dart';
import 'chamber_repository.dart';

class AddChamberScreen extends ConsumerStatefulWidget {
  const AddChamberScreen({super.key});

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
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }
    setState(() => _saving = true);
    final chamber = Chamber(
      id: '',
      doctorId: kDevDoctorId,
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
      await ref.read(chamberRepositoryProvider).add(chamber);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Chamber')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Chamber name',
                  hintText: 'Popular Diagnostic Centre, Dhanmondi',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'House 25, Road 2, Dhanmondi, Dhaka',
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Open days',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
              const Text('Hours',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text('Start: ${_formatTime(_startTime)}'),
                      onPressed: _pickStart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text('End: ${_formatTime(_endTime)}'),
                      onPressed: _pickEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(
                  labelText: 'Consultation fee (BDT)',
                  prefixText: '৳ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return 'Enter a fee';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Booking mode',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              RadioGroup<ChamberBookingMode>(
                groupValue: _bookingMode,
                onChanged: (v) => setState(() => _bookingMode = v!),
                child: Column(
                  children: ChamberBookingMode.values
                      .map(
                        (mode) => RadioListTile<ChamberBookingMode>(
                          value: mode,
                          title: Text(mode.displayName),
                          subtitle: Text(mode.description),
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
                  decoration: const InputDecoration(
                    labelText: 'Daily app booking cap',
                    helperText:
                        'Max patients who can book via app per day. Rest are walk-in.',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (_bookingMode != ChamberBookingMode.hybridWithCap) {
                      return null;
                    }
                    final n = int.tryParse(v?.trim() ?? '');
                    if (n == null || n <= 0) return 'Enter a cap';
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
                    : const Text('Save chamber'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
