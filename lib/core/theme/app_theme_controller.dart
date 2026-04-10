import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and broadcasts [ThemeMode] for [MaterialApp].
class AppThemeController extends ChangeNotifier {
  AppThemeController(this._prefs) : _mode = _readFromPrefs(_prefs);

  final SharedPreferences _prefs;

  static const _key = 'app.theme_mode';

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static ThemeMode _readFromPrefs(SharedPreferences p) {
    final raw = p.getString(_key);
    for (final m in ThemeMode.values) {
      if (m.name == raw) return m;
    }
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode value) async {
    if (_mode == value) return;
    _mode = value;
    await _prefs.setString(_key, value.name);
    notifyListeners();
  }
}
