import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E8B57);
  static const Color primaryLight = Color(0xFF90EE90);
  static const Color background = Color(0xFF0A1A0A);
  static const Color surface = Color(0xFF0d1f0d);
  static const Color surfaceLight = Color(0xFF1e3a1e);
  static const Color accent = Color(0xFFFF6B8A);
  static const Color textPrimary = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFF81C784);
  static const Color cardBorder = Color(0xFF2E8B57);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
