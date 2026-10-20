import 'dart:ui';
import 'package:flutter/material.dart';

/// High-End Editorial Design Tokens (Supporting Light & Dark Mode)
class S {
  static const double x05 = 4.0;
  static const double x1 = 8.0;
  static const double x2 = 16.0;
  static const double x3 = 24.0;
  static const double x4 = 32.0;
  static const double x5 = 40.0;
  static const double x6 = 48.0;
  static const double x7 = 56.0;
}

class M {
  static const fast = Duration(milliseconds: 200);
  static const base = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const curve = Cubic(0.2, 0.8, 0.2, 1);
}

class T {
  static const String serifFont = 'serif';
  static const String sansFont = 'sans-serif'; // System default sans

  // Editorial Display (Serif)
  static const display = TextStyle(
    fontFamily: serifFont,
    fontSize: 44,
    height: 1.1,
    letterSpacing: -1.0,
    fontWeight: FontWeight.w400,
  );

  // Large Numbers (Sans-serif Tabular)
  static const figure = TextStyle(
    fontFamily: sansFont,
    fontSize: 56,
    height: 1.0,
    letterSpacing: -1.5,
    fontWeight: FontWeight.w300,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Screen/Section Titles (Sans-serif)
  static const headline = TextStyle(
    fontFamily: sansFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  // Component Titles (Sans-serif)
  static const title = TextStyle(
    fontFamily: sansFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  // Standard Body (Sans-serif)
  static const body = TextStyle(
    fontFamily: sansFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Metadata / Secondary info (Sans-serif)
  static const meta = TextStyle(
    fontFamily: sansFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  // Small Caps / Overline Labels (Sans-serif)
  static const label = TextStyle(
    fontFamily: sansFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}

/// Helper to get theme-aware colors easily
extension ContextColorExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Color get bg => colorScheme.surface;
  Color get surface => colorScheme.surfaceContainer;
  Color get line => colorScheme.outlineVariant;
  Color get text => colorScheme.onSurface;
  Color get text2 => colorScheme.onSurfaceVariant;
  Color get primary => colorScheme.primary;
  
  Color get cluster1 => const Color(0xFF6366F1); // Indigo
  Color get cluster2 => const Color(0xFF10B981); // Emerald
  Color get cluster3 => const Color(0xFFF59E0B); // Amber
  Color get cluster4 => const Color(0xFFEC4899); // Rose
  Color get cluster5 => const Color(0xFF06B6D4); // Cyan

  Color getClusterColor(int index) {
    switch (index % 5) {
      case 0: return cluster1;
      case 1: return cluster2;
      case 2: return cluster3;
      case 3: return cluster4;
      default: return cluster5;
    }
  }
}
