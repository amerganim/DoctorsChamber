import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/error_state.dart';
import '../doctor/doctor_profile_repository.dart';
import 'chamber.dart';
import 'chamber_repository.dart';

class ChambersListScreen extends ConsumerWidget {
  const ChambersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChambers =
        ref.watch(chambersByDoctorStreamProvider(kDevDoctorId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Chambers')),
      body: asyncChambers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          detail: ErrorState.friendly(e),
          onRetry: () => ref
              .invalidate(chambersByDoctorStreamProvider(kDevDoctorId)),
        ),
        data: (chambers) {
          if (chambers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        size: 64, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    const Text(
                      'No chambers yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a chamber so patients can find you and book serials.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: chambers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ChamberCard(chamber: chambers[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/doctor/chambers/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add chamber'),
      ),
    );
  }
}

class _ChamberCard extends ConsumerWidget {
  const _ChamberCard({required this.chamber});

  final Chamber chamber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
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
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              chamber.address,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _IconText(
                  icon: Icons.calendar_today_outlined,
                  text: chamber.days.join(', '),
                ),
                _IconText(
                  icon: Icons.access_time,
                  text: '${chamber.startTime} – ${chamber.endTime}',
                ),
                _IconText(
                  icon: Icons.payments_outlined,
                  text: '৳${chamber.consultationFee}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                chamber.bookingMode.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete chamber?'),
        content: Text(
            '"${chamber.name}" will be removed. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(chamberRepositoryProvider).delete(chamber.id);
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
