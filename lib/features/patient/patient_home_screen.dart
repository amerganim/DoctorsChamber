import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Patient home — coming in Phase 3'),
      ),
    );
  }
}
