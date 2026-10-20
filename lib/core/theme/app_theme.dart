import 'package:flutter/material.dart';

class AppTheme {
  // Premium Clean White Theme (Apple / Stripe / Vercel Light Style)
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      surface: Color(0xFFF8FAFC), // Off-white canvas
      surfaceContainer: Color(0xFFFFFFFF), // Pure white cards & containers
      surfaceContainerHigh: Color(0xFFF1F5F9), // Subtle grey container
      onSurface: Color(0xFF0F172A), // Slate 900 primary text
      onSurfaceVariant: Color(0xFF64748B), // Slate 500 secondary text
      outlineVariant: Color(0xFFE2E8F0), // Slate 200 border
      outline: Color(0xFFCBD5E1), // Slate 300 active border
      primary: Color(0xFF4F46E5), // Indigo 600
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFEEF2FF), // Indigo 50 light bg
      onPrimaryContainer: Color(0xFF3730A3), // Indigo 800
      error: Color(0xFFEF4444),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData get darkTheme => lightTheme;

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
