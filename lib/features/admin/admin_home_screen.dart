import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/error_state.dart';
import '../admin_invitations/invitation.dart';
import '../admin_invitations/invitation_repository.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../auth/current_user.dart';
import '../auth/user_role_enrollment.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../queue/queue.dart';
import '../queue/queue_janitor.dart';
import '../queue/queue_repository.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.signOutDialogTitle),
        content: Text(l10n.signOutDialogBodyAdmin),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.stay),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    LoadingOverlay.show(context, l10n.signingOut);
    await signOutDoctor();
    ref.invalidate(userRoleEnrollmentProvider);
    if (!context.mounted) return;
    LoadingOverlay.dismiss(context);
    if (!context.mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();
    final email = currentUserEmail();
    final signedIn = isAdminSignedIn();

    final invitationsAsync = signedIn && email != null
        ? ref.watch(emailInvitationsStreamProvider(email))
        : const AsyncValue<List<Invitation>>.data([]);
    final chambersAsync = signedIn
        ? ref.watch(chambersWhereAdminStreamProvider(currentDoctorId()))
        : ref.watch(allChambersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminAppBarTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: chambersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          detail: ErrorState.friendly(e),
          onRetry: () {
            if (signedIn) {
              ref.invalidate(
                  chambersWhereAdminStreamProvider(currentDoctorId()));
            } else {
              ref.invalidate(allChambersStreamProvider);
            }
          },
        ),
        data: (chambers) {
          final pendingInvitations = (invitationsAsync.value ?? const [])
              .where((i) => i.status == InvitationStatus.pending)
              .toList();

          if (chambers.isEmpty && pendingInvitations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        size: 64, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noChambersAssigned,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noChambersAssignedHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          return QueueJanitorRunner(
            chamberIds: chambers.map((c) => c.id).toList(),
            child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingInvitations.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: Text(
                    l10n.invitationsSection,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                ...pendingInvitations.map(
                  (inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InvitationTile(invitation: inv),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (chambers.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.todaysChambersSection,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${chambers.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...chambers.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChamberTile(chamber: c, today: today),
                  ),
                ),
              ],
            ],
            ),
          );
        },
      ),
    );
  }
}

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({required this.invitation});

  final Invitation invitation;

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final uid = currentDoctorId();
    try {
      await ref.read(invitationRepositoryProvider).accept(
            chamberId: invitation.chamberId,
            invitationId: invitation.id,
            adminUid: uid,
            adminEmail: currentUserEmail() ?? '',
            adminDisplayName: currentUserDisplayName() ?? '',
          );
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invitationJoined)),
      );
    } catch (e) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invitationFailed(e.toString()))),
      );
    }
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(invitationRepositoryProvider).decline(
            chamberId: invitation.chamberId,
            invitationId: invitation.id,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline,
                  size: 18, color: scheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                l10n.invitedHeader,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            invitation.invitedByDoctorName.isEmpty
                ? l10n.invitationBodyAnonymous
                : l10n.invitationBodyByDoctor(invitation.invitedByDoctorName),
            style: TextStyle(
                fontSize: 14, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => _accept(context, ref),
                  child: Text(l10n.accept),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _decline(context, ref),
                child: Text(l10n.decline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChamberTile extends ConsumerWidget {
  const _ChamberTile({required this.chamber, required this.today});

  final Chamber chamber;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dateKey = todayDateKey();
    final queueAsync =
        ref.watch(queueStreamProvider(QueueKey(chamber.id, dateKey)));
    final entriesAsync =
        ref.watch(queueEntriesStreamProvider(QueueKey(chamber.id, dateKey)));
    final openToday = chamber.days.contains(today);

    final queueStatus = queueAsync.value?.status ?? QueueStatus.pending;
    final entries = entriesAsync.value ?? const [];
    final waitingCount =
        entries.where((e) => e.status == QueueEntryStatus.waiting).length;
    final arrivedCount =
        entries.where((e) => e.status == QueueEntryStatus.arrived).length;
    final inConsultation = entries
        .where((e) => e.status == QueueEntryStatus.inConsultation)
        .length;
    final completed = entries.where((e) => !e.status.isActive).length;
    final inConsultationEntries = entries
        .where((e) => e.status == QueueEntryStatus.inConsultation)
        .toList();
    final currentSerial = inConsultationEntries.isEmpty
        ? 0
        : inConsultationEntries.first.serial;

    final (badgeColor, badgeFg, badgeIcon, badgeText) = switch (queueStatus) {
      QueueStatus.pending => (
          scheme.surfaceContainerHigh,
          scheme.onSurfaceVariant,
          Icons.schedule_outlined,
          l10n.queueBadgeNotOpened,
        ),
      QueueStatus.open => (
          Colors.green.shade100,
          Colors.green.shade900,
          Icons.circle,
          l10n.queueBadgeLive,
        ),
      QueueStatus.closed => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.lock_outline,
          l10n.queueBadgeClosed,
        ),
    };

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/admin/queue/${chamber.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chamber.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 11, color: badgeFg),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeFg),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                chamber.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 13, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${chamber.startTime} – ${chamber.endTime}',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  if (!openToday) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.event_busy_outlined,
                        size: 13, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      l10n.chamberClosedToday,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (queueStatus == QueueStatus.open || entries.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ChamberStat(
                          label: l10n.nowSeeing,
                          value: currentSerial > 0 ? '#$currentSerial' : '—',
                          highlight: currentSerial > 0,
                        ),
                      ),
                      _ChamberStatDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _ChamberStat(
                          label: l10n.waiting,
                          value: '${waitingCount + arrivedCount}',
                        ),
                      ),
                      _ChamberStatDivider(color: scheme.outlineVariant),
                      Expanded(
                        child: _ChamberStat(
                          label: l10n.done,
                          value: '$completed',
                        ),
                      ),
                    ],
                  ),
                ),
                if (inConsultation == 0 &&
                    (waitingCount + arrivedCount) > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 13, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.patientsWaitingPrompt,
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChamberStat extends StatelessWidget {
  const _ChamberStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: highlight ? scheme.primary : scheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ChamberStatDivider extends StatelessWidget {
  const _ChamberStatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: color);
  }
}
