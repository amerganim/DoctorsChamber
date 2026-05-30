import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/generated/app_localizations.dart';
import '../auth/current_user.dart';
import 'doctor_photo_service.dart';
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
  bool _uploadingPhoto = false;
  String? _photoUrl;
  DoctorVerificationStatus _verificationStatus =
      DoctorVerificationStatus.pending;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(doctorProfileRepositoryProvider);
    final profile = await repo.fetch(currentDoctorId());
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
      _photoUrl = profile.photoUrl;
    }
    setState(() => _loaded = true);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _uploadingPhoto = true);
    try {
      final dataUrl =
          await ref.read(doctorPhotoServiceProvider).pickAsDataUrl(source);
      if (!mounted) return;
      if (dataUrl == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }
      setState(() {
        _photoUrl = dataUrl;
        _uploadingPhoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).photoUpdatedSnack)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .couldNotLoadImageSnack(e.toString()))),
      );
    }
  }

  void _removePhoto() {
    setState(() => _photoUrl = null);
  }

  Future<void> _showPhotoSheet() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takeAPhoto),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGallery),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_PhotoAction.gallery),
            ),
            if (_photoUrl != null)
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(sheetContext).colorScheme.error),
                title: Text(l10n.removePhoto,
                    style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.error)),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoAction.remove),
              ),
          ],
        ),
      ),
    );
    if (source == null) return;
    switch (source) {
      case _PhotoAction.camera:
        await _pickPhoto(ImageSource.camera);
      case _PhotoAction.gallery:
        await _pickPhoto(ImageSource.gallery);
      case _PhotoAction.remove:
        _removePhoto();
    }
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
        SnackBar(
            content: Text(
                AppLocalizations.of(context).selectAtLeastOneSpecialty)),
      );
      return;
    }
    setState(() => _saving = true);
    final profile = DoctorProfile(
      id: currentDoctorId(),
      name: _nameController.text.trim(),
      bmdcNumber: _bmdcController.text.trim(),
      qualifications: _qualificationsController.text.trim(),
      specialties: _selectedSpecialties.toList(),
      bio: _bioController.text.trim(),
      languages: _selectedLanguages.toList(),
      yearsOfExperience: int.tryParse(_yearsController.text.trim()) ?? 0,
      photoUrl: _photoUrl,
      verificationStatus: _verificationStatus,
    );
    try {
      await ref.read(doctorProfileRepositoryProvider).save(profile);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).profileSavedSnack)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).saveFailedSnack(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editProfileTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfileTitle)),
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
                      backgroundImage: doctorPhotoProvider(_photoUrl),
                      child: _uploadingPhoto
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : (_photoUrl == null
                              ? Icon(Icons.person,
                                  size: 50, color: scheme.onSurfaceVariant)
                              : null),
                    ),
                    Material(
                      color: scheme.primary,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt,
                            color: scheme.onPrimary, size: 18),
                        onPressed: _uploadingPhoto ? null : _showPhotoSheet,
                        tooltip: l10n.updatePhotoTooltip,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullNameLabel,
                  hintText: l10n.fullNameHint,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bmdcController,
                decoration: InputDecoration(
                  labelText: l10n.bmdcRegistrationLabel,
                  hintText: l10n.bmdcRegistrationHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualificationsController,
                decoration: InputDecoration(
                  labelText: l10n.qualificationsLabel,
                  hintText: l10n.qualificationsHint,
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 24),
              Text(l10n.specialtiesSection,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
              Text(l10n.languagesSpokenSection,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
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
                decoration: InputDecoration(
                  labelText: l10n.yearsOfExperienceLabel,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: l10n.bioLabel,
                  hintText: l10n.bioHint,
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
                    : Text(l10n.saveProfileButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }
