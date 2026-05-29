import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Picks an image, downsizes it via image_picker, and returns a data-URL
/// (`data:image/jpeg;base64,...`). The caller is responsible for persisting
/// the string on the doctor profile doc. Storage-on-Spark requires Blaze so
/// we encode the bytes into Firestore directly — pilot-scale photos sit
/// around 30–60 KB after the resize, well under the 1 MB doc cap.
class DoctorPhotoService {
  DoctorPhotoService();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAsDataUrl(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );
    if (picked == null) return null;
    final bytes = await File(picked.path).readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }
}

final doctorPhotoServiceProvider = Provider<DoctorPhotoService>((ref) {
  return DoctorPhotoService();
});

/// Returns an [ImageProvider] for the given stored photo string, whether it's
/// a `data:image/...;base64,` URL or a remote `http(s)://` URL. Returns
/// `null` when the input is null/empty so callers can fall back to a
/// placeholder.
ImageProvider? doctorPhotoProvider(String? photo) {
  if (photo == null || photo.isEmpty) return null;
  if (photo.startsWith('data:')) {
    final commaIdx = photo.indexOf(',');
    if (commaIdx < 0) return null;
    try {
      final bytes = base64Decode(photo.substring(commaIdx + 1));
      return MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(photo);
}
