import "package:flutter/material.dart";

/// Centralizes the NutriTracker typography tokens using the Inter family.
class AppTextTheme {
  AppTextTheme._();

  static const String fontFamily = 'Inter';

  static TextTheme build(ColorScheme scheme) {
    return TextTheme(
      headlineSmall: _style(
        size: 22,
        weight: FontWeight.w600,
        color: scheme.onSurface,
        height: 1.4,
        letterSpacing: -0.5,
      ),
      titleLarge: _style(
        size: 18,
        weight: FontWeight.w500,
        color: scheme.onSurface,
        height: 1.35,
        letterSpacing: -0.3,
      ),
      bodyLarge: _style(
        size: 15,
        weight: FontWeight.w500,
        color: scheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: _style(
        size: 15,
        weight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
        height: 1.5,
      ),
      bodySmall: _style(
        size: 13,
        weight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: _style(
        size: 16,
        weight: FontWeight.w600,
        color: scheme.onPrimary,
        height: 1.2,
        letterSpacing: 0.5,
      ),
      headlineMedium: _style(
        size: 28,
        weight: FontWeight.w700,
        color: scheme.onSurface,
        height: 1.3,
        letterSpacing: -0.4,
      ),
      titleMedium: _style(
        size: 16,
        weight: FontWeight.w600,
        color: scheme.onSurface,
        height: 1.3,
      ),
      labelMedium: _style(
        size: 14,
        weight: FontWeight.w600,
        color: scheme.onSurface,
        height: 1.3,
      ),
      labelSmall: _style(
        size: 12,
        weight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
        height: 1.2,
      ),
    );
  }

  static TextStyle _style({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
