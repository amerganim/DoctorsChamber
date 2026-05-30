import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/weekday.dart';
import '../../l10n/generated/app_localizations.dart';
import 'queue_repository.dart';

class ScanRegisterScreen extends ConsumerStatefulWidget {
  const ScanRegisterScreen({super.key, required this.chamberId});

  final String chamberId;

  @override
  ConsumerState<ScanRegisterScreen> createState() =>
      _ScanRegisterScreenState();
}

class _ScanRegisterScreenState extends ConsumerState<ScanRegisterScreen> {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer();
  final List<_RowController> _rows = [];

  bool _processing = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _textRecognizer.close();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    setState(() {
      _processing = true;
      _error = null;
    });
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 95);
      if (picked == null) {
        if (!mounted) return;
        setState(() => _processing = false);
        return;
      }
      final inputImage = InputImage.fromFilePath(picked.path);
      final result = await _textRecognizer.processImage(inputImage);
      final parsed = _parseRows(result);
      if (!mounted) return;
      setState(() {
        for (final r in _rows) {
          r.dispose();
        }
        _rows
          ..clear()
          ..addAll(parsed);
        _processing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = 'Scan failed: $e';
      });
    }
  }

  List<_RowController> _parseRows(RecognizedText result) {
    final allLines = <({Rect box, String text})>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final t = line.text.trim();
        if (t.isEmpty) continue;
        allLines.add((box: line.boundingBox, text: t));
      }
    }
    if (allLines.isEmpty) return [];

    allLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    final groups = <List<({Rect box, String text})>>[];
    for (final line in allLines) {
      if (groups.isEmpty) {
        groups.add([line]);
        continue;
      }
      final last = groups.last;
      final lastCenter = last
              .map((l) => (l.box.top + l.box.bottom) / 2)
              .reduce((a, b) => a + b) /
          last.length;
      final lineCenter = (line.box.top + line.box.bottom) / 2;
      final tolerance = line.box.height * 0.6;
      if ((lineCenter - lastCenter).abs() < tolerance) {
        last.add(line);
      } else {
        groups.add([line]);
      }
    }

    for (final group in groups) {
      group.sort((a, b) => a.box.left.compareTo(b.box.left));
    }

    final stripLeading = RegExp(r'^[\d.\)\-\s]+');
    final headerKeywords = RegExp(
        r"\b(list|patients|patient|name|phone|serial|no|date|today|status|sl)\b",
        caseSensitive: false);
    final rows = <_RowController>[];

    for (final group in groups) {
      final combined = group.map((l) => l.text).join('  ');
      final phoneMatch = _findPhone(combined);
      String phone = '';
      String name = combined;
      if (phoneMatch != null) {
        phone = phoneMatch.normalized;
        name = combined.replaceAll(phoneMatch.originalText, ' ').trim();
      }
      name = name
          .replaceAll(stripLeading, '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (name.isEmpty && phone.isEmpty) continue;

      if (phone.isEmpty) {
        if (headerKeywords.hasMatch(name)) continue;
        final words = name.split(RegExp(r'\s+'));
        if (words.length > 1) {
          final tinyWords = words.where((w) => w.length <= 1).length;
          if (tinyWords / words.length >= 0.5) continue;
        }
      }

      rows.add(_RowController()..set(name, phone));
    }
    return rows;
  }

  ({String originalText, String normalized})? _findPhone(String text) {
    final candidates =
        RegExp(r'[\dOoIl|SsBbZzGg\s\-]{10,18}').allMatches(text);
    for (final m in candidates) {
      final original = m.group(0)!;
      final normalized = original
          .replaceAll(RegExp(r'[Oo]'), '0')
          .replaceAll(RegExp(r'[Il|]'), '1')
          .replaceAll(RegExp(r'[Zz]'), '2')
          .replaceAll(RegExp(r'[Ss]'), '5')
          .replaceAll(RegExp(r'[Bb]'), '8')
          .replaceAll(RegExp(r'[Gg]'), '6')
          .replaceAll(RegExp(r'[\s\-]'), '');
      if (RegExp(r'^\d{10,11}$').hasMatch(normalized)) {
        return (originalText: original, normalized: normalized);
      }
    }
    return null;
  }

  void _addEmptyRow() {
    setState(() => _rows.add(_RowController()));
  }

  void _deleteRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final patients = <({String name, String phone})>[];
    for (final r in _rows) {
      final n = r.nameController.text.trim();
      final p = r.phoneController.text.trim();
      if (n.isEmpty && p.isEmpty) continue;
      patients.add((name: n, phone: p));
    }
    if (patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).noEntriesToAdd)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final assigned = await ref.read(queueRepositoryProvider).bulkAddEntries(
            chamberId: widget.chamberId,
            date: todayDateKey(),
            patients: patients,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).bulkAddSuccess(assigned.length))),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).bulkAddFailed(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasRows = _rows.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanRegisterTitle),
        actions: [
          if (hasRows)
            IconButton(
              tooltip: l10n.rescanTooltip,
              icon: const Icon(Icons.refresh),
              onPressed:
                  _processing || _saving ? null : () => _scan(ImageSource.camera),
            ),
        ],
      ),
      body: SafeArea(
        child: _processing
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.readingRegister),
                  ],
                ),
              )
            : !hasRows
                ? _Intro(
                    error: _error,
                    onCamera: () => _scan(ImageSource.camera),
                    onGallery: () => _scan(ImageSource.gallery),
                  )
                : _RowsList(
                    rows: _rows,
                    onAddRow: _addEmptyRow,
                    onDeleteRow: _deleteRow,
                  ),
      ),
      floatingActionButton: hasRows
          ? FloatingActionButton.extended(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: scheme.onPrimary),
                    )
                  : const Icon(Icons.playlist_add_check),
              label: Text(l10n.addNToQueue(_rows.length)),
            )
          : null,
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({
    required this.error,
    required this.onCamera,
    required this.onGallery,
  });

  final String? error;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner_outlined,
              size: 80, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).scanIntroTitle,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).scanIntroHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: Text(AppLocalizations.of(context).takePhotoButton),
            onPressed: onCamera,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(AppLocalizations.of(context).chooseGalleryButton),
            onPressed: onGallery,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error!,
              style: TextStyle(color: scheme.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _RowsList extends StatelessWidget {
  const _RowsList({
    required this.rows,
    required this.onAddRow,
    required this.onDeleteRow,
  });

  final List<_RowController> rows;
  final VoidCallback onAddRow;
  final void Function(int) onDeleteRow;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: rows.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == rows.length) {
          return Center(
            child: TextButton.icon(
              onPressed: onAddRow,
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLocalizations.of(context).addRowManually),
            ),
          );
        }
        return _RowCard(
          row: rows[i],
          index: i,
          onDelete: () => onDeleteRow(i),
        );
      },
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.row,
    required this.index,
    required this.onDelete,
  });

  final _RowController row;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Text(
              '${index + 1}',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: row.nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).nameLabel,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: row.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).phoneLabel,
                    isDense: true,
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: AppLocalizations.of(context).deleteRowTooltip,
          ),
        ],
      ),
    );
  }
}

class _RowController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  void set(String name, String phone) {
    nameController.text = name;
    phoneController.text = phone;
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
  }
}
