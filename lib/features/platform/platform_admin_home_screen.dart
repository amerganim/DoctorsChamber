import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'platform_config.dart';

class PlatformAdminHomeScreen extends StatelessWidget {
  const PlatformAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Platform admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel(text: 'Operations'),
          const SizedBox(height: 8),
          Material(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              leading: Icon(Icons.verified_user_outlined,
                  color: scheme.primary),
              title: const Text('Verification queue'),
              subtitle: const Text('Review BMDC numbers and approve doctors'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/platform/verification'),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel(text: 'Data retention'),
          const SizedBox(height: 8),
          const _RetentionCard(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RetentionCard extends ConsumerStatefulWidget {
  const _RetentionCard();

  @override
  ConsumerState<_RetentionCard> createState() => _RetentionCardState();
}

class _RetentionCardState extends ConsumerState<_RetentionCard> {
  final TextEditingController _controller =
      TextEditingController(text: '$kDefaultRetentionDays');
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    try {
      final config =
          await ref.read(platformConfigRepositoryProvider).fetchOnce();
      if (!mounted) return;
      setState(() {
        _controller.text = config.retentionDays.toString();
        _loaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _controller.text.trim();
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed <= 0) {
      setState(() => _error = 'Enter a positive number of days.');
      return;
    }
    if (parsed > 3650) {
      setState(() => _error = 'Use 3650 days or fewer.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(platformConfigRepositoryProvider)
          .setRetentionDays(parsed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Retention set to $parsed days')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Queue auto-delete window',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'New queues and entries expire after this many days. The app '
            'sweeps expired data when a doctor or admin opens their home '
            'screen. Existing docs keep their original expiry.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _controller,
                  enabled: _loaded && !_saving,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    suffixText: 'days',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: (_loaded && !_saving) ? _save : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          if (!_loaded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading current setting…',
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: scheme.error, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
