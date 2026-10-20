import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Glassmorphic styling utilities inspired by troona-music
class GlassTheme {
  static BoxDecoration glassDecoration({
    double borderRadius = 16.0,
    Color backgroundColor = const Color(0xCCFFFFFF), // 80% opacity white
    Color borderColor = const Color(0x33FFFFFF),
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F0F172A), // Subtle shadow
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration subtleHighlightDecoration({
    double borderRadius = 16.0,
  }) {
    return BoxDecoration(
      color: AppColors.primaryLight.withOpacity(0.6),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.primary.withOpacity(0.2),
        width: 1.0,
      ),
    );
  }
}
