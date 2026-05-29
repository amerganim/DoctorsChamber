import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/current_user.dart';
import '../doctor/doctor_profile_repository.dart';
import 'invitation_repository.dart';

class InviteAdminDialog extends ConsumerStatefulWidget {
  const InviteAdminDialog({super.key, required this.chamberId});

  final String chamberId;

  @override
  ConsumerState<InviteAdminDialog> createState() =>
      _InviteAdminDialogState();
}

class _InviteAdminDialogState extends ConsumerState<InviteAdminDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final doctorId = currentDoctorId();
      final doctor = await ref
          .read(doctorProfileRepositoryProvider)
          .fetch(doctorId);
      final doctorName = doctor?.name.isNotEmpty == true
          ? doctor!.name
          : (currentUserDisplayName() ?? 'Doctor');
      await ref.read(invitationRepositoryProvider).invite(
            chamberId: widget.chamberId,
            email: _emailController.text.trim(),
            invitedByDoctorId: doctorId,
            invitedByDoctorName: doctorName,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Invite chamber admin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the admin\'s Google email. They sign in with the same '
                'email to accept and start managing this chamber.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                enabled: !_saving,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Admin email',
                  hintText: 'admin@gmail.com',
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Required';
                  if (!t.contains('@') || !t.contains('.')) {
                    return 'Not a valid email';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
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
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
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
              : const Text('Invite'),
        ),
      ],
    );
  }
}
