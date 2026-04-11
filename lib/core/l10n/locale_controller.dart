import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сохраняет и транслирует язык приложения ([Locale]) для [MaterialApp].
class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) : _locale = _readLocale(_prefs);

  final SharedPreferences _prefs;

  static const prefsKey = 'app_language_code';

  /// Порядок: первый — язык по умолчанию (русский, как в ТЗ).
  static const List<Locale> supportedLocales = [Locale('ru'), Locale('en')];

  Locale _locale;

  Locale get locale => _locale;

  static Locale _readLocale(SharedPreferences p) {
    final raw = p.getString(prefsKey)?.toLowerCase();
    return switch (raw) {
      'en' => const Locale('en'),
      _ => const Locale('ru'),
    };
  }

  /// Код языка для UI: `ru` | `en`.
  String get languageCode => _locale.languageCode;

  Future<void> setLanguageCode(String code) async {
    final next = switch (code.toLowerCase()) {
      'en' => const Locale('en'),
      _ => const Locale('ru'),
    };
    if (next == _locale) return;
    _locale = next;
    await _prefs.setString(prefsKey, next.languageCode);
    notifyListeners();
  }
}
