import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../shared/widgets/loading_overlay.dart';
import '../../shared/widgets/role_card.dart';
import '../platform/platform_lock.dart';
import '../platform/platform_owner.dart';
import 'current_user.dart';
import 'user_role.dart';
import 'user_role_enrollment.dart';

// Set to false once Firebase is on the Blaze plan and real phone auth works.
const _devSkipLogin = true;

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  Future<void> _pickRole(BuildContext context, UserRole role) async {
    if (role == UserRole.doctor || role == UserRole.admin) {
      await _signInWithGoogle(context, role);
      return;
    }
    if (_devSkipLogin) {
      context.push(role.homeRoute);
    } else {
      context.push('/login', extra: role);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context, UserRole role) async {
    if (isDoctorSignedIn()) {
      context.push(role.homeRoute);
      return;
    }
    LoadingOverlay.show(context, 'Signing you in…');
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '789245868214-36quh56t7i68mgul6rb7h5k4ngqkupqj.apps.googleusercontent.com',
      );
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      final credential =
          GoogleAuthProvider.credential(idToken: auth.idToken);
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.isAnonymous) {
        try {
          await firebaseUser.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            await FirebaseAuth.instance.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      ref.invalidate(userRoleEnrollmentProvider);
      if (!context.mounted) return;
      LoadingOverlay.dismiss(context);
      if (!context.mounted) return;
      context.push(role.homeRoute);
    } on GoogleSignInException catch (e) {
      LoadingOverlay.dismiss(context);
      if (e.code != GoogleSignInExceptionCode.canceled && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.code.name}')),
        );
      }
    } catch (e) {
      LoadingOverlay.dismiss(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    }
  }

  Future<void> _openPlatformAdmin(
      BuildContext context, WidgetRef ref) async {
    final ok = await PlatformLockGate.ensureUnlocked(context, ref);
    if (!ok || !context.mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!context.mounted) return;
    context.push('/platform');
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final enrollment =
        ref.watch(userRoleEnrollmentProvider).value ??
            UserRoleEnrollment.neither;
    final showDoctor = enrollment != UserRoleEnrollment.admin;
    final showAdmin = enrollment != UserRoleEnrollment.doctor;
    final signedIn = isDoctorSignedIn();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'DoctorsChamber',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find doctors, book serials, manage chambers.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Who are you?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              RoleCard(
                icon: Icons.person_outline,
                title: 'Patient',
                subtitle: 'Find doctors, book serials, see live queues',
                onTap: () => _pickRole(context, UserRole.patient),
              ),
              const SizedBox(height: 12),
              if (showDoctor) ...[
                RoleCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Doctor',
                  subtitle: signedIn
                      ? 'Manage chambers and queue'
                      : 'Sign in with Google · manage chambers and queue',
                  onTap: () => _pickRole(context, UserRole.doctor),
                ),
                const SizedBox(height: 12),
              ],
              if (showAdmin) ...[
                RoleCard(
                  icon: Icons.assignment_outlined,
                  title: 'Chamber Admin',
                  subtitle: signedIn
                      ? 'Run the daily queue for a doctor'
                      : 'Sign in with Google · run the daily queue for a doctor',
                  onTap: () => _pickRole(context, UserRole.admin),
                ),
                const SizedBox(height: 12),
              ],
              const Spacer(),
              if (isPlatformOwner())
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    icon: const Icon(Icons.verified_user_outlined, size: 16),
                    label: const Text('Platform admin'),
                    onPressed: () => _openPlatformAdmin(context, ref),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
