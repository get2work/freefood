import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeProvider(this._prefs) {
    _themeMode = ThemeMode.values.byName(
      _prefs.getString(_themeKey) ?? ThemeMode.dark.name,
    );
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
} 