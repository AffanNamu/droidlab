import 'package:flutter/material.dart';

abstract final class DroidLabColors {
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF101827);
  static const Color elevated = Color(0xFF172235);
  static const Color cyan = Color(0xFF38BDF8);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color primaryText = Color(0xFFF8FAFC);
  static const Color mutedText = Color(0xFF94A3B8);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
}

abstract final class DroidLabTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DroidLabColors.cyan,
      brightness: Brightness.dark,
      surface: DroidLabColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DroidLabColors.background,
      cardColor: DroidLabColors.surface,
      dividerColor: DroidLabColors.elevated,
      appBarTheme: const AppBarTheme(
        backgroundColor: DroidLabColors.background,
        foregroundColor: DroidLabColors.primaryText,
        centerTitle: false,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DroidLabColors.surface,
        indicatorColor: DroidLabColors.cyan.withValues(alpha: 0.16),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DroidLabColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
