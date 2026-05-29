import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kDefaultRetentionDays = 30;

class PlatformConfig {
  const PlatformConfig({
    this.pin = '',
    this.retentionDays = kDefaultRetentionDays,
  });

  final String pin;
  final int retentionDays;

  factory PlatformConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PlatformConfig();
    final raw = map['retentionDays'];
    final days = (raw is num) ? raw.toInt() : kDefaultRetentionDays;
    return PlatformConfig(
      pin: (map['pin'] as String?)?.trim() ?? '',
      retentionDays: days <= 0 ? kDefaultRetentionDays : days,
    );
  }
}

class PlatformConfigRepository {
  PlatformConfigRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('platform').doc('config');

  Stream<PlatformConfig> watch() {
    return _doc.snapshots().map((s) => PlatformConfig.fromMap(s.data()));
  }

  Future<PlatformConfig> fetchOnce() async {
    final snap = await _doc.get();
    return PlatformConfig.fromMap(snap.data());
  }

  Future<void> setRetentionDays(int days) async {
    await _doc.set({'retentionDays': days}, SetOptions(merge: true));
  }
}

final platformConfigRepositoryProvider =
    Provider<PlatformConfigRepository>((ref) {
  return PlatformConfigRepository(FirebaseFirestore.instance);
});

final platformConfigStreamProvider = StreamProvider<PlatformConfig>((ref) {
  return ref.watch(platformConfigRepositoryProvider).watch();
});
