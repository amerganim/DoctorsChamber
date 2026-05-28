import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/current_user.dart';
import 'rating_repository.dart';

class RateDoctorDialog extends ConsumerStatefulWidget {
  const RateDoctorDialog({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.bookingId,
  });

  final String doctorId;
  final String doctorName;
  final String bookingId;

  @override
  ConsumerState<RateDoctorDialog> createState() => _RateDoctorDialogState();
}

class _RateDoctorDialogState extends ConsumerState<RateDoctorDialog> {
  int _stars = 0;
  final _textController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _saving = true);
    try {
      await ref.read(ratingRepositoryProvider).add(
            doctorId: widget.doctorId,
            patientId: currentPatientId(),
            bookingId: widget.bookingId,
            stars: _stars,
            text: _textController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text('Rate ${widget.doctorName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How was your consultation?'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _stars;
                return IconButton(
                  iconSize: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  onPressed: _saving
                      ? null
                      : () => setState(() => _stars = i + 1),
                  icon: Icon(
                    filled ? Icons.star : Icons.star_border,
                    color: filled ? Colors.amber.shade700 : scheme.outline,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              enabled: !_saving,
              maxLines: 3,
              maxLength: 240,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Share more about your experience',
                alignLabelWithHint: true,
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
          onPressed: _saving || _stars == 0 ? null : _submit,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Submit'),
        ),
      ],
    );
  }
}
