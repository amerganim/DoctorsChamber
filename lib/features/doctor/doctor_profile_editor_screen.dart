import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'doctor_profile.dart';
import 'doctor_profile_repository.dart';
import 'specialties.dart';

class DoctorProfileEditorScreen extends ConsumerStatefulWidget {
  const DoctorProfileEditorScreen({super.key});

  @override
  ConsumerState<DoctorProfileEditorScreen> createState() =>
      _DoctorProfileEditorScreenState();
}

class _DoctorProfileEditorScreenState
    extends ConsumerState<DoctorProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bmdcController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _bioController = TextEditingController();
  final _yearsController = TextEditingController(text: '0');

  final Set<String> _selectedSpecialties = {};
  final Set<String> _selectedLanguages = {};
  bool _saving = false;
  bool _loaded = false;
  DoctorVerificationStatus _verificationStatus =
      DoctorVerificationStatus.pending;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(doctorProfileRepositoryProvider);
    final profile = await repo.fetch(kDevDoctorId);
    if (!mounted) return;
    if (profile != null) {
      _nameController.text = profile.name;
      _bmdcController.text = profile.bmdcNumber;
      _qualificationsController.text = profile.qualifications;
      _bioController.text = profile.bio;
      _yearsController.text = profile.yearsOfExperience.toString();
      _selectedSpecialties.addAll(profile.specialties);
      _selectedLanguages.addAll(profile.languages);
      _verificationStatus = profile.verificationStatus;
    }
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bmdcController.dispose();
    _qualificationsController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one specialty')),
      );
      return;
    }
    setState(() => _saving = true);
    final profile = DoctorProfile(
      id: kDevDoctorId,
      name: _nameController.text.trim(),
      bmdcNumber: _bmdcController.text.trim(),
      qualifications: _qualificationsController.text.trim(),
      specialties: _selectedSpecialties.toList(),
      bio: _bioController.text.trim(),
      languages: _selectedLanguages.toList(),
      yearsOfExperience: int.tryParse(_yearsController.text.trim()) ?? 0,
      verificationStatus: _verificationStatus,
    );
    try {
      await ref.read(doctorProfileRepositoryProvider).save(profile);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: scheme.surfaceContainerHighest,
                      child: Icon(Icons.person,
                          size: 50, color: scheme.onSurfaceVariant),
                    ),
                    Material(
                      color: scheme.primary,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt,
                            color: scheme.onPrimary, size: 18),
                        onPressed: null,
                        tooltip: 'Photo upload coming soon',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Dr. Md. Karim Ahmed',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bmdcController,
                decoration: const InputDecoration(
                  labelText: 'BMDC registration number',
                  hintText: 'A-12345',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualificationsController,
                decoration: const InputDecoration(
                  labelText: 'Qualifications',
                  hintText: 'MBBS, FCPS (Cardiology)',
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Specialties',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kSpecialties.map((s) {
                  final selected = _selectedSpecialties.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedSpecialties.add(s);
                        } else {
                          _selectedSpecialties.remove(s);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Languages spoken',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kLanguages.map((l) {
                  final selected = _selectedLanguages.contains(l);
                  return FilterChip(
                    label: Text(l),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedLanguages.add(l);
                        } else {
                          _selectedLanguages.remove(l);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _yearsController,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'A short introduction patients will see',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
