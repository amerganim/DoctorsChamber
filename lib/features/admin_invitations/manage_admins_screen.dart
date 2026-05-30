import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'chamber_admin.dart';
import 'invitation.dart';
import 'invitation_repository.dart';
import 'invite_admin_dialog.dart';

class ManageAdminsScreen extends ConsumerWidget {
  const ManageAdminsScreen({super.key, required this.chamberId});

  final String chamberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final adminsAsync = ref.watch(chamberAdminsStreamProvider(chamberId));
    final invitationsAsync =
        ref.watch(chamberInvitationsStreamProvider(chamberId));
    final scheme = Theme.of(context).colorScheme;

    final admins = adminsAsync.value ?? const <ChamberAdmin>[];
    final pendingInvitations = (invitationsAsync.value ?? const <Invitation>[])
        .where((i) => i.status == InvitationStatus.pending)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chamberAdminsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (admins.isEmpty && pendingInvitations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.group_outlined,
                      size: 64, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noAdminsYet,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noAdminsHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          if (admins.isNotEmpty) ...[
            Text(
              l10n.currentAdminsHeader(admins.length),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            ...admins.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AdminTile(chamberId: chamberId, admin: a),
                )),
            const SizedBox(height: 16),
          ],
          if (pendingInvitations.isNotEmpty) ...[
            Text(
              l10n.pendingInvitationsHeader(pendingInvitations.length),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingInvitations.map((inv) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _InvitationTile(invitation: inv),
                )),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _invite(context),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(l10n.inviteAdminFab),
      ),
    );
  }

  Future<void> _invite(BuildContext context) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => InviteAdminDialog(chamberId: chamberId),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).invitationSentSnack)),
      );
    }
  }
}

class _AdminTile extends ConsumerWidget {
  const _AdminTile({required this.chamberId, required this.admin});

  final String chamberId;
  final ChamberAdmin admin;

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.removeAdminTitle),
        content: Text(l10n.removeAdminBody(admin.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.removeAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(invitationRepositoryProvider).removeAdmin(
            chamberId: chamberId,
            adminUid: admin.uid,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.removedSnack(admin.label))),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedShort(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.person,
                color: scheme.onPrimaryContainer, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.displayName.isEmpty
                      ? admin.email.isEmpty
                          ? admin.uid
                          : admin.email
                      : admin.displayName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                if (admin.email.isNotEmpty && admin.displayName.isNotEmpty)
                  Text(
                    admin.email,
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).removeAction,
            icon: const Icon(Icons.person_remove_outlined),
            onPressed: () => _confirmRemove(context, ref),
          ),
        ],
      ),
    );
  }
}

class _InvitationTile extends ConsumerWidget {
  const _InvitationTile({required this.invitation});

  final Invitation invitation;

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(invitationRepositoryProvider).revoke(
            chamberId: invitation.chamberId,
            invitationId: invitation.id,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).invitationRevokedSnack)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).failedShort(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline,
              size: 18, color: Colors.amber.shade900),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              invitation.email,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).revokeTooltip,
            icon: const Icon(Icons.close),
            onPressed: () => _revoke(context, ref),
          ),
        ],
      ),
    );
  }
}
