import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../queue/queue.dart';
import '../queue/queue_repository.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync =
        ref.watch(patientBookingsStreamProvider(kDevPatientId));
    final chambersAsync = ref.watch(allChambersStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final today = todayDateKey();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load:\n$e', textAlign: TextAlign.center),
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_outlined,
                        size: 64, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    const Text(
                      'No bookings yet',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find a doctor and book a serial to see it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          final chambers = chambersAsync.value ?? const <Chamber>[];
          final chambersById = {for (final c in chambers) c.id: c};

          final upcoming = bookings
              .where((b) => b.date == today && b.status.isActive)
              .toList();
          final past = bookings
              .where((b) => b.date != today || !b.status.isActive)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionHeader('Today'),
                ...upcoming.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(
                        booking: b,
                        chamber: chambersById[b.chamberId],
                        isUpcoming: true,
                      ),
                    )),
                const SizedBox(height: 16),
              ],
              if (past.isNotEmpty) ...[
                _SectionHeader('Past'),
                ...past.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(
                        booking: b,
                        chamber: chambersById[b.chamberId],
                        isUpcoming: false,
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.chamber,
    required this.isUpcoming,
  });

  final QueueEntry booking;
  final Chamber? chamber;
  final bool isUpcoming;

  String _formatDate(String yyyymmdd) {
    if (yyyymmdd.length != 8) return yyyymmdd;
    return '${yyyymmdd.substring(0, 4)}-${yyyymmdd.substring(4, 6)}-${yyyymmdd.substring(6, 8)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: chamber == null
            ? null
            : () => context.push('/patient/chamber/${chamber!.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isUpcoming ? scheme.primaryContainer : scheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(
                  '#${booking.serial}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isUpcoming
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chamber?.name ?? 'Chamber',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.patientName} · ${_formatDate(booking.date)}',
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (chamber != null)
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
