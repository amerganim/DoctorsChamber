import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
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
        _error = AppLocalizations.of(context).failedPrefix(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.inviteAdminTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.noAdminsHint),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                enabled: !_saving,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.adminEmailLabel,
                  hintText: l10n.adminEmailHint,
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return l10n.requiredField;
                  if (!t.contains('@') || !t.contains('.')) {
                    return l10n.requiredField;
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
              : Text(l10n.inviteAction),
        ),
      ],
    );
  }
}
