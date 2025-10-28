import 'package:flutter/material.dart';

class AppTheme {
  // Cyborg theme colors (Bootstrap 5 dark)
  static const Color primary = Color(0xFF2a9fd6);
  static const Color secondary = Color(0xFF555555);
  static const Color success = Color(0xFF77b300);
  static const Color info = Color(0xFF5bc0de);
  static const Color warning = Color(0xFFf0ad4e);
  static const Color danger = Color(0xFFd9534f);

  static const Color bodyBg = Color(0xFF060606);
  static const Color bodyColor = Color(0xFFe6e6e6);
  static const Color cardBg = Color(0xFF222222);
  static const Color borderColor = Color(0xFF555555);

  static ThemeData get darkTheme {
    final baseScheme = ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      error: danger,
      surface: cardBg,
    );

    // Ensure error text is readable on dark backgrounds
    final colorScheme = baseScheme.copyWith(
      error: const Color(0xFFB3261E), // M3 error color
      onError: Colors.white, // readable white text on error background
      errorContainer: const Color(0xFF8C1D18), // container variant
      onErrorContainer: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bodyBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        iconTheme: IconThemeData(color: bodyColor),
        titleTextStyle: TextStyle(
          color: bodyColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: const CardThemeData(color: cardBg, elevation: 2),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: primary),
          ),
        ),
      ),
    );
  }
}
