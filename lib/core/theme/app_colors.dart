import 'package:flutter/material.dart';
import 'package:nutriz/theme/design_tokens.dart' as tokens;
import 'package:nutriz/theme/app_colors.dart' as legacy_colors;

/// Color accessors for the new dashboard.
///
/// This file intentionally wraps our tokenized palette in
/// `lib/theme/design_tokens.dart` so callers can use a stable
/// API while the underlying preset (e.g., YAZIO-like) can be
/// changed at runtime via Theme.
class AppColorsDS {
  AppColorsDS._();

  /// Primary brand color used for CTAs and highlights.
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Secondary accent (used sparingly for info/links).
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  /// General surfaces and cards.
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color surfaceContainer(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// Borders/dividers on light theme.
  static Color outline(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  /// Text colors
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static const Color textInverse = Colors.white;
  static Color textHint(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7);

  /// Semantic colors
  static Color success(BuildContext context) =>
      tokens.AppSemanticColors.light.success;
  static Color warning(BuildContext context) =>
      tokens.AppSemanticColors.light.warning;
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  /// Macro colors (consistent with existing palette)
  static const Color macroCarb = legacy_colors.AppColors.macroCarb;
  static const Color macroProtein = legacy_colors.AppColors.macroProtein;
  static const Color macroFat = legacy_colors.AppColors.macroFat;

  // ---------- Specific colors requested by checklist ----------
  // Section backgrounds
  static const Color bodyMetricsBackground = Color(0xFF3D4F5C); // dark slate
  static const Color activitiesBackground = Color(0xFFE8F5F0); // mint light
  static const Color waterTrackerBackground = Color(0xFFF8FBFF); // very light blue

  // Macronutrients soft fills
  static const Color carbsColor = Color(0xFFFFE5D9);
  static const Color proteinColor = Color(0xFFD4F1E8);
  static const Color fatColor = Color(0xFFFFF4E6);

  // Buttons
  static const Color primaryButton = Color(0xFF5B7FFF);
  static const Color addButtonBackground = Color(0xFF5B7FFF);

  // Borders and separators
  static const Color cardBorder = Color(0xFFEFEFEF); // subtle border ~F0F0F0
  static const Color divider = Color(0xFFF5F5F5);

  // Base surfaces
  static const Color pureWhite = Color(0xFFFFFFFF);
}
