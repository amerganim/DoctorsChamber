import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';

class _PlatformUnlocked extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
}

final platformUnlockedProvider =
    NotifierProvider<_PlatformUnlocked, bool>(_PlatformUnlocked.new);

class PlatformLockGate {
  PlatformLockGate._();

  static Future<bool> ensureUnlocked(
      BuildContext context, WidgetRef ref) async {
    if (ref.read(platformUnlockedProvider)) return true;

    final doc = await FirebaseFirestore.instance
        .collection('platform')
        .doc('config')
        .get();
    final storedPin = (doc.data()?['pin'] as String?)?.trim() ?? '';

    if (!context.mounted) return false;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PlatformPinDialog(storedPin: storedPin),
    );

    if (ok == true) {
      ref.read(platformUnlockedProvider.notifier).unlock();
      return true;
    }
    return false;
  }
}

class _PlatformPinDialog extends StatefulWidget {
  const _PlatformPinDialog({required this.storedPin});

  final String storedPin;

  @override
  State<_PlatformPinDialog> createState() => _PlatformPinDialogState();
}

class _PlatformPinDialogState extends State<_PlatformPinDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _error;

  bool get _isSettingNewPin => widget.storedPin.isEmpty;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final pin = _pinController.text.trim();
    if (_isSettingNewPin) {
      if (pin.length < 4) {
        setState(() => _error = l10n.pinTooShort);
        return;
      }
      if (pin != _confirmController.text.trim()) {
        setState(() => _error = l10n.pinsDontMatch);
        return;
      }
      setState(() {
        _saving = true;
        _error = null;
      });
      try {
        await FirebaseFirestore.instance
            .collection('platform')
            .doc('config')
            .set({'pin': pin}, SetOptions(merge: true));
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = l10n.saveToPrefsFailed(e.toString());
        });
      }
    } else {
      if (pin == widget.storedPin) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _error = l10n.wrongPin;
          _pinController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(_isSettingNewPin ? l10n.setPinTitle : l10n.enterPinTitle),
      content: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isSettingNewPin ? l10n.setPinHint : l10n.restrictedAreaText,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            decoration: InputDecoration(
              labelText: l10n.pinLabel,
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_isSettingNewPin) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(
                labelText: l10n.confirmPinLabel,
                counterText: '',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
        ],
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
              : Text(_isSettingNewPin ? l10n.setPinAction : l10n.unlockAction),
        ),
      ],
    );
  }
}
