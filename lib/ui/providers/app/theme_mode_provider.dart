import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider with ChangeNotifier {
  static const String _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'dark') {
      _mode = ThemeMode.dark;
    } else if (stored == 'light') {
      _mode = ThemeMode.light;
    } else if (stored == 'system') {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value ? 'dark' : 'light');
  }
}
