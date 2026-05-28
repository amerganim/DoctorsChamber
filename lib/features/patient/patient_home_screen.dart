import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/weekday.dart';
import '../../shared/widgets/error_state.dart';
import '../chambers/chamber.dart';
import '../chambers/chamber_repository.dart';
import '../doctor/doctor_day_status.dart';
import '../doctor/doctor_day_status_repository.dart';
import '../doctor/doctor_profile.dart';
import '../doctor/doctor_profile_repository.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  bool _availableTodayOnly = false;
  String? _specialtyFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(allDoctorsStreamProvider);
    final chambersAsync = ref.watch(allChambersStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final today = todayWeekday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a doctor'),
        actions: [
          IconButton(
            tooltip: 'My Bookings',
            icon: const Icon(Icons.event_outlined),
            onPressed: () => context.push('/patient/bookings'),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by doctor, specialty, or chamber',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                        ),
                ),
                onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: _FilterRow(
                  availableToday: _availableTodayOnly,
                  specialty: _specialtyFilter,
                  doctors: doctorsAsync.value ?? const [],
                  onToggleAvailable: () => setState(
                      () => _availableTodayOnly = !_availableTodayOnly),
                  onSpecialtyChanged: (s) =>
                      setState(() => _specialtyFilter = s),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: doctorsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorState(
                  detail: ErrorState.friendly(e),
                  onRetry: () => ref.invalidate(allDoctorsStreamProvider),
                ),
                data: (allDoctors) {
                  final chambers = chambersAsync.value ?? const <Chamber>[];
                  final chambersByDoctor = <String, List<Chamber>>{};
                  for (final c in chambers) {
                    chambersByDoctor.putIfAbsent(c.doctorId, () => []).add(c);
                  }

                  final filtered = allDoctors.where((d) {
                    final docChambers =
                        chambersByDoctor[d.id] ?? const <Chamber>[];

                    if (_search.isNotEmpty) {
                      final haystack = [
                        d.name,
                        d.qualifications,
                        ...d.specialties,
                        ...docChambers.map((c) => c.name),
                        ...docChambers.map((c) => c.address),
                      ].join(' ').toLowerCase();
                      if (!haystack.contains(_search)) return false;
                    }
                    if (_specialtyFilter != null &&
                        !d.specialties.contains(_specialtyFilter)) {
                      return false;
                    }
                    if (_availableTodayOnly &&
                        !docChambers.any((c) => c.days.contains(today))) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              allDoctors.isEmpty
                                  ? 'No doctors yet'
                                  : 'No doctors match your search',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              allDoctors.isEmpty
                                  ? 'Doctors will appear here as they sign up.'
                                  : 'Try a different keyword or clear filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final doctor = filtered[i];
                      final docChambers =
                          chambersByDoctor[doctor.id] ?? const <Chamber>[];
                      return _DoctorCard(
                        doctor: doctor,
                        chambers: docChambers,
                        today: today,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.availableToday,
    required this.specialty,
    required this.doctors,
    required this.onToggleAvailable,
    required this.onSpecialtyChanged,
  });

  final bool availableToday;
  final String? specialty;
  final List<DoctorProfile> doctors;
  final VoidCallback onToggleAvailable;
  final ValueChanged<String?> onSpecialtyChanged;

  @override
  Widget build(BuildContext context) {
    final specialties = {
      for (final d in doctors) ...d.specialties,
    }.toList()
      ..sort();

    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        FilterChip(
          label: const Text('Available today'),
          selected: availableToday,
          onSelected: (_) => onToggleAvailable(),
        ),
        const SizedBox(width: 8),
        for (final s in specialties) ...[
          FilterChip(
            label: Text(s),
            selected: specialty == s,
            onSelected: (v) => onSpecialtyChanged(v ? s : null),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _DoctorCard extends ConsumerWidget {
  const _DoctorCard({
    required this.doctor,
    required this.chambers,
    required this.today,
  });

  final DoctorProfile doctor;
  final List<Chamber> chambers;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final todayChambers =
        chambers.where((c) => c.days.contains(today)).toList();
    final otherChambers =
        chambers.where((c) => !c.days.contains(today)).toList();
    final dayStatus = ref
        .watch(doctorDayStatusProvider(
            DoctorDayStatusKey(doctor.id, todayDateKey())))
        .value;
    final hasOverride = dayStatus != null && !dayStatus.isAvailable;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/patient/doctor/${doctor.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.person,
                    size: 28, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (doctor.verificationStatus ==
                            DoctorVerificationStatus.verified) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.verified,
                              size: 16, color: Colors.blue.shade700),
                        ],
                      ],
                    ),
                    if (doctor.qualifications.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        doctor.qualifications,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: scheme.onSurfaceVariant),
                      ),
                    ],
                    if (doctor.specialties.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialties.join(' • '),
                        style: TextStyle(
                            fontSize: 13,
                            color: scheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                    if (hasOverride) ...[
                      const SizedBox(height: 10),
                      _DayStatusBadge(status: dayStatus),
                    ] else if (todayChambers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TODAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            for (final c in todayChambers)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 6,
                                        color: Colors.green.shade700),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${c.name} · ${c.startTime}–${c.endTime}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ] else if (otherChambers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              otherChambers.length > 1
                                  ? '${otherChambers.first.name} +${otherChambers.length - 1} more'
                                  : otherChambers.first.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayStatusBadge extends StatelessWidget {
  const _DayStatusBadge({required this.status});

  final DoctorDayStatusDoc status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status.status) {
      DoctorDayStatus.available =>
        (Colors.green.shade50, Colors.green.shade900),
      DoctorDayStatus.onLeave =>
        (scheme.errorContainer, scheme.onErrorContainer),
      DoctorDayStatus.atHospital =>
        (Colors.amber.shade50, Colors.amber.shade900),
    };
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.status.icon, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.status.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: 0.6,
                  ),
                ),
                if (status.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    status.note,
                    style: TextStyle(fontSize: 12, color: fg),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
