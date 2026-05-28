import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../doctor/doctor_profile.dart';
import '../doctor/doctor_profile_repository.dart';

class VerificationQueueScreen extends ConsumerStatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  ConsumerState<VerificationQueueScreen> createState() =>
      _VerificationQueueScreenState();
}

enum _Filter { all, pending, verified, rejected }

class _VerificationQueueScreenState
    extends ConsumerState<VerificationQueueScreen> {
  _Filter _filter = _Filter.pending;

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(allDoctorsStreamProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification queue')),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed: $e', textAlign: TextAlign.center),
          ),
        ),
        data: (doctors) {
          final filtered = doctors.where((d) {
            return switch (_filter) {
              _Filter.all => true,
              _Filter.pending =>
                d.verificationStatus == DoctorVerificationStatus.pending,
              _Filter.verified =>
                d.verificationStatus == DoctorVerificationStatus.verified,
              _Filter.rejected =>
                d.verificationStatus == DoctorVerificationStatus.rejected,
            };
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<_Filter>(
                        segments: const [
                          ButtonSegment(
                              value: _Filter.pending,
                              label: Text('Pending')),
                          ButtonSegment(
                              value: _Filter.verified,
                              label: Text('Verified')),
                          ButtonSegment(
                              value: _Filter.rejected,
                              label: Text('Rejected')),
                          ButtonSegment(
                              value: _Filter.all, label: Text('All')),
                        ],
                        selected: {_filter},
                        onSelectionChanged: (s) =>
                            setState(() => _filter = s.first),
                      ),
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined,
                              size: 64, color: scheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            switch (_filter) {
                              _Filter.pending => 'No doctors awaiting review',
                              _Filter.verified => 'No verified doctors yet',
                              _Filter.rejected => 'No rejected doctors',
                              _Filter.all => 'No doctors in the system',
                            },
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _DoctorRow(doctor: filtered[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DoctorRow extends ConsumerWidget {
  const _DoctorRow({required this.doctor});

  final DoctorProfile doctor;

  Future<void> _setStatus(
      BuildContext context, WidgetRef ref, DoctorVerificationStatus s) async {
    try {
      await ref
          .read(doctorProfileRepositoryProvider)
          .setVerificationStatus(doctorId: doctor.id, status: s);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked as ${s.displayName}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isPending =
        doctor.verificationStatus == DoctorVerificationStatus.pending;
    final isVerified =
        doctor.verificationStatus == DoctorVerificationStatus.verified;
    final isRejected =
        doctor.verificationStatus == DoctorVerificationStatus.rejected;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.person,
                    color: scheme.onPrimaryContainer, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name.isEmpty ? '(no name)' : doctor.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    if (doctor.qualifications.isNotEmpty)
                      Text(
                        doctor.qualifications,
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(doctor.verificationStatus.icon,
                  size: 18,
                  color: isVerified
                      ? Colors.green.shade700
                      : isRejected
                          ? scheme.error
                          : Colors.amber.shade800),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.badge_outlined,
                    size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    doctor.bmdcNumber.isEmpty
                        ? 'No BMDC number provided'
                        : 'BMDC: ${doctor.bmdcNumber}',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                if (doctor.bmdcNumber.isNotEmpty)
                  IconButton(
                    tooltip: 'Copy BMDC number',
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: doctor.bmdcNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('BMDC number copied')),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (doctor.specialties.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              doctor.specialties.join(' • '),
              style: TextStyle(
                  fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isVerified)
                FilledButton.tonal(
                  onPressed: () => _setStatus(
                      context, ref, DoctorVerificationStatus.verified),
                  child: const Text('Mark verified'),
                ),
              if (!isRejected)
                OutlinedButton(
                  onPressed: () => _setStatus(
                      context, ref, DoctorVerificationStatus.rejected),
                  child: const Text('Reject'),
                ),
              if (!isPending)
                TextButton(
                  onPressed: () => _setStatus(
                      context, ref, DoctorVerificationStatus.pending),
                  child: const Text('Reset to pending'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
