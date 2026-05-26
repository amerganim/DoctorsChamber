import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const Center(
        child: Text('Doctor home — coming in Phase 2'),
      ),
    );
  }
}
