import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamber Admin'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Admin home — coming in Phase 4'),
      ),
    );
  }
}
