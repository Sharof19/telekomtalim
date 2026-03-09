import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: Color(0xFF2F6BFF),
      secondary: Color(0xFF4F83FF),
      background: Color(0xFFF3F5F9),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF111827),
      onSurface: Color(0xFF111827),
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF3F5F9),
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 86,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE1E7F0),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF64748B)),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFFF59E0B),
      background: Color(0xFF0B1724),
      surface: Color(0xFF162333),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Color(0xFFE4E9F0),
      onSurface: Color(0xFFE4E9F0),
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B1724),
        foregroundColor: Color(0xFFE4E9F0),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 86,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E2C3C),
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: Color(0xFFB9C2CF)),
    );
  }
}
