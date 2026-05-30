import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title,
    this.detail,
    this.onRetry,
  });

  final String? title;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title ?? l10n.somethingWentWrong,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              detail ?? l10n.tryAgainShortly,
              style: TextStyle(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Heuristic mapping of common Firebase / network error strings to friendly
  /// fragments. Returns a key-string that callers can resolve via
  /// AppLocalizations; for now we return English fallbacks so existing
  /// callers (which pass the string into `detail:`) keep working. Localized
  /// versions are looked up by [friendlyL10n] when an AppLocalizations
  /// instance is available.
  static String friendly(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('unavailable') ||
        s.contains('network') ||
        s.contains('socket') ||
        s.contains('connection')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (s.contains('permission') || s.contains('unauthorized')) {
      return 'Access denied. Please sign in again.';
    }
    if (s.contains('not-found') || s.contains('not found')) {
      return 'Not found. The item may have been removed.';
    }
    if (s.contains('failed-precondition') || s.contains('requires an index')) {
      return 'Database needs setup. Please contact support.';
    }
    return "Couldn't load. Please try again in a moment.";
  }

  static String friendlyL10n(BuildContext context, Object e) {
    final l10n = AppLocalizations.of(context);
    final s = e.toString().toLowerCase();
    if (s.contains('unavailable') ||
        s.contains('network') ||
        s.contains('socket') ||
        s.contains('connection')) {
      return l10n.noNetworkHint;
    }
    if (s.contains('permission') || s.contains('unauthorized')) {
      return l10n.permissionDeniedHint;
    }
    return l10n.tryAgainShortly;
  }
}
