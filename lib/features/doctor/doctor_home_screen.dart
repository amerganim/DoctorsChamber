import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'doctor_profile_repository.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync =
        ref.watch(doctorProfileStreamProvider(kDevDoctorId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load profile:\n$e',
                textAlign: TextAlign.center),
          ),
        ),
        data: (profile) {
          final hasProfile = profile != null && profile.name.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasProfile) ...[
                  const Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up your profile so patients can find you.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ] else ...[
                  Text(
                    profile.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  if (profile.qualifications.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(profile.qualifications,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                  if (profile.specialties.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.specialties.join(' • '),
                      style: TextStyle(
                          color: scheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (profile.yearsOfExperience > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile.yearsOfExperience} years of experience',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(hasProfile ? 'Edit profile' : 'Create profile'),
                  onPressed: () => context.push('/doctor/profile'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: const Text('Manage chambers'),
                  onPressed: () => context.push('/doctor/chambers'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Queue and admin invites coming next.',
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
