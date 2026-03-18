import 'package:flutter/material.dart';

class AppTheme {
  // Vibrant Colors
  static const Color indigo = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFFE0E7FF);
  static const Color rose = Color(0xFFE11D48);
  static const Color roseLight = Color(0xFFFFE4E6);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFFD1FAE5);
  static const Color skyBlue = Color(0xFF38BDF8);
  static const Color skyBlueLight = Color(0xFFE0F2FE);
  
  // Light Mode Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Dark Mode Neutrals
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: background,
        surface: surface,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        border: border,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: backgroundDark,
        surface: surfaceDark,
        textPrimary: textPrimaryDark,
        textSecondary: textSecondaryDark,
        border: borderDark,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    return ThemeData(
      brightness: brightness,
      primaryColor: indigo,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: indigo,
        onPrimary: Colors.white,
        secondary: emerald,
        onSecondary: Colors.white,
        error: rose,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 24),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }
}
