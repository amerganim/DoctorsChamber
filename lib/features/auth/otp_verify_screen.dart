import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'user_role.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.role,
    required this.phone,
    required this.verificationId,
  });

  final UserRole role;
  final String phone;
  final String verificationId;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _codeController = TextEditingController();
  bool _verifying = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeController.text.length != 6) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _codeController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      context.go(widget.role.homeRoute);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = switch (e.code) {
          'invalid-verification-code' => 'Wrong code. Please try again.',
          'session-expired' => 'Code expired. Request a new one.',
          _ => e.message ?? 'Verification failed.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = 'Unexpected error. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Verify number')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the 6-digit code',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to ${widget.phone}',
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                autofocus: true,
                maxLength: 6,
                textAlign: TextAlign.center,
                enabled: !_verifying,
                style: const TextStyle(fontSize: 24, letterSpacing: 12),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ''),
                onChanged: (_) => setState(() {}),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: scheme.error, fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: (_codeController.text.length == 6 && !_verifying)
                    ? _verify
                    : null,
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _verifying ? null : () => context.pop(),
                  child: const Text('Change phone number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
