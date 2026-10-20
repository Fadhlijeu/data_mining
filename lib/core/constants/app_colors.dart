import 'package:flutter/material.dart';

/// Centralized Obsidian Slate color palette for ClusterLab (Linear / Vercel Dark Style)
class AppColors {
  // Dark Canvas & Surface Colors
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceSubtle = Color(0xFF1F2937);
  static const Color surfaceElevated = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Brand / Neon Accents
  static const Color primary = Color(0xFF6366F1); // Indigo Glow
  static const Color primaryLight = Color(0x336366F1);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Semantic Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0x2610B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0x26F59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0x26EF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Lines
  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF334155);

  // Multi-cluster neon palette for up to 10 clusters
  static const List<Color> clusterColors = [
    Color(0xFF818CF8), // Electric Indigo
    Color(0xFF34D399), // Neon Emerald
    Color(0xFFFBBF24), // Amber Gold
    Color(0xFFF472B6), // Neon Pink
    Color(0xFF22D3EE), // Neon Cyan
    Color(0xFFA78BFA), // Purple Glow
    Color(0xFFFB923C), // Bright Orange
    Color(0xFF2DD4BF), // Teal Glow
    Color(0xFFE879F9), // Fuchsia
    Color(0xFFA3E635), // Lime Glow
  ];

  static Color getClusterColor(int index) {
    return clusterColors[index % clusterColors.length];
  }
}
