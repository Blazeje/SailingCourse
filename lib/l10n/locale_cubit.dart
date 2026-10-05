import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Holds the user-selected [Locale] and persists it across launches.
///
/// A `null` state means "follow the system locale".
class LocaleCubit extends Cubit<Locale?> {
  static const _prefsKey = 'app_locale';

  LocaleCubit() : super(null);

  /// Loads the previously saved locale (if any).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && _isSupported(code)) {
      emit(Locale(code));
    }
  }

  /// Selects a locale and remembers the choice. Passing `null` clears it
  /// and reverts to following the system locale.
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
    emit(locale);
  }

  bool _isSupported(String code) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == code);
}
