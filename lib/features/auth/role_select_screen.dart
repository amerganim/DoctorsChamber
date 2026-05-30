import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/locale_settings.dart';
import '../../l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final signedIn = isDoctorSignedIn();
    final enrollmentAsync = ref.watch(userRoleEnrollmentProvider);
    final cached = ref.watch(cachedEnrollmentProvider);
    final locale = ref.watch(localeProvider);
    // Prefer the fresh Firestore result; fall back to the cached value so
    // returning users see the right card instantly on cold start.
    final enrollment = enrollmentAsync.value ?? cached;
    final canRenderProfessional = !signedIn || enrollment != null;
    final effectiveEnrollment = enrollment ?? UserRoleEnrollment.neither;
    final showDoctor = canRenderProfessional &&
        effectiveEnrollment != UserRoleEnrollment.admin;
    final showAdmin = canRenderProfessional &&
        effectiveEnrollment != UserRoleEnrollment.doctor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.appName,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ),
                  _LanguageChip(currentLanguageCode: locale.languageCode),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.appTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              Text(
                l10n.whoAreYou,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              RoleCard(
                icon: Icons.person_outline,
                title: l10n.rolePatient,
                subtitle: l10n.rolePatientSubtitle,
                onTap: () => _pickRole(context, UserRole.patient),
              ),
              const SizedBox(height: 12),
              if (showDoctor) ...[
                RoleCard(
                  icon: Icons.medical_services_outlined,
                  title: l10n.roleDoctor,
                  subtitle: signedIn
                      ? l10n.roleDoctorSubtitleSignedIn
                      : l10n.roleDoctorSubtitleSignedOut,
                  onTap: () => _pickRole(context, UserRole.doctor),
                ),
                const SizedBox(height: 12),
              ],
              if (showAdmin) ...[
                RoleCard(
                  icon: Icons.assignment_outlined,
                  title: l10n.roleChamberAdmin,
                  subtitle: signedIn
                      ? l10n.roleChamberAdminSubtitleSignedIn
                      : l10n.roleChamberAdminSubtitleSignedOut,
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
                    label: Text(l10n.platformAdmin),
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

class _LanguageChip extends ConsumerWidget {
  const _LanguageChip({required this.currentLanguageCode});

  final String currentLanguageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isBangla = currentLanguageCode == 'bn';
    return Tooltip(
      message: l10n.languageSwitchTooltip,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => ref.read(localeProvider.notifier).toggle(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.translate, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  isBangla
                      ? l10n.languageEnglishShort
                      : l10n.languageBanglaShort,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
