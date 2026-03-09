import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FaceVerificationProvider with ChangeNotifier {
  bool _isVerified = false;

  bool get isVerified => _isVerified;

  Future<void> loadVerification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isVerified = prefs.getBool('isFaceVerified') ?? false;
    notifyListeners();
  }

  Future<void> setVerified(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFaceVerified', value);
    _isVerified = value;
    notifyListeners();
  }
}

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

class LocaleProvider with ChangeNotifier {
  static const String _key = 'app_locale';
  static String currentCode = 'uz';
  Locale _locale = const Locale('uz');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      currentCode = code;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    currentCode = locale.languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}
