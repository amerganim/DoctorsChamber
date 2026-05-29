import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QueueJanitor {
  QueueJanitor(this._firestore);

  final FirebaseFirestore _firestore;

  static final Set<String> _sweptThisSession = <String>{};

  Future<void> sweepChamber(String chamberId) async {
    if (_sweptThisSession.contains(chamberId)) return;
    _sweptThisSession.add(chamberId);

    try {
      final now = Timestamp.now();
      final expired = await _firestore
          .collection('chambers')
          .doc(chamberId)
          .collection('queues')
          .where('deleteAt', isLessThan: now)
          .limit(20)
          .get();

      for (final queueDoc in expired.docs) {
        final entries = await queueDoc.reference.collection('entries').get();
        var batch = _firestore.batch();
        var ops = 0;
        for (final entry in entries.docs) {
          batch.delete(entry.reference);
          ops++;
          if (ops >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            ops = 0;
          }
        }
        if (ops > 0) {
          await batch.commit();
        }
        await queueDoc.reference.delete();
      }
    } catch (_) {
      _sweptThisSession.remove(chamberId);
    }
  }

  Future<void> sweepChambers(Iterable<String> chamberIds) async {
    for (final id in chamberIds) {
      await sweepChamber(id);
    }
  }
}

final queueJanitorProvider = Provider<QueueJanitor>((ref) {
  return QueueJanitor(FirebaseFirestore.instance);
});

class QueueJanitorRunner extends ConsumerStatefulWidget {
  const QueueJanitorRunner({
    super.key,
    required this.chamberIds,
    required this.child,
  });

  final List<String> chamberIds;
  final Widget child;

  @override
  ConsumerState<QueueJanitorRunner> createState() => _QueueJanitorRunnerState();
}

class _QueueJanitorRunnerState extends ConsumerState<QueueJanitorRunner> {
  @override
  void initState() {
    super.initState();
    _schedule(widget.chamberIds);
  }

  @override
  void didUpdateWidget(covariant QueueJanitorRunner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final added = widget.chamberIds
        .where((id) => !oldWidget.chamberIds.contains(id))
        .toList();
    if (added.isNotEmpty) _schedule(added);
  }

  void _schedule(List<String> ids) {
    if (ids.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(queueJanitorProvider).sweepChambers(ids);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
