import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs.dart';

const _kLocalePrefKey = 'app_locale';
const _kEnglish = Locale('en');
const _kBangla = Locale('bn');

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final code = prefs.getString(_kLocalePrefKey);
    return code == 'bn' ? _kBangla : _kEnglish;
  }

  Future<void> set(Locale locale) async {
    if (locale.languageCode == state.languageCode) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kLocalePrefKey, locale.languageCode);
    state = locale;
  }

  Future<void> toggle() async {
    await set(state.languageCode == 'bn' ? _kEnglish : _kBangla);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
