import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = '+880${_phoneController.text}';
    setState(() {
      _sending = true;
      _error = null;
    });

    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          await auth.signInWithCredential(credential);
          if (!mounted) return;
          context.go(widget.role.homeRoute);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _sending = false;
            _error = 'Auto sign-in failed. Try again.';
          });
        }
      },
      verificationFailed: (e) {
        if (!mounted) return;
        setState(() {
          _sending = false;
          _error = switch (e.code) {
            'invalid-phone-number' => 'Invalid phone number.',
            'too-many-requests' => 'Too many attempts. Try again later.',
            'app-not-authorized' =>
              'App not authorized. SHA fingerprint may be missing in Firebase.',
            _ => e.message ?? 'Verification failed.',
          };
        });
      },
      codeSent: (verificationId, _) {
        if (!mounted) return;
        setState(() => _sending = false);
        context.push('/login/verify', extra: {
          'role': widget.role,
          'phone': phone,
          'verificationId': verificationId,
        });
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your phone number';
    if (trimmed.length != 10) return 'Phone number must be 10 digits';
    if (!trimmed.startsWith('1')) return 'Bangladesh numbers start with 1';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue as ${widget.role.displayName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your phone number',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  maxLength: 10,
                  enabled: !_sending,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    prefixText: '+880  ',
                    hintText: '1XXXXXXXXX',
                    counterText: '',
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ll send a 6-digit code to verify this number.',
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: scheme.error, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _sending ? null : _sendCode,
                  child: _sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
