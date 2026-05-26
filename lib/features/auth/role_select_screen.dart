import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/role_card.dart';
import 'user_role.dart';

// Set to false once Firebase is on the Blaze plan and real phone auth works.
const _devSkipLogin = true;

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _pickRole(BuildContext context, UserRole role) {
    if (_devSkipLogin) {
      context.push(role.homeRoute);
    } else {
      context.push('/login', extra: role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              RoleCard(
                icon: Icons.medical_services_outlined,
                title: 'Doctor',
                subtitle: 'Manage your chambers, see today\'s queue',
                onTap: () => _pickRole(context, UserRole.doctor),
              ),
              const SizedBox(height: 12),
              RoleCard(
                icon: Icons.assignment_outlined,
                title: 'Chamber Admin',
                subtitle: 'Run the daily queue for a doctor',
                onTap: () => _pickRole(context, UserRole.admin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
