import 'package:flutter/material.dart';
import 'package:nutriz/theme/design_tokens.dart' as tokens;

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

  /// Semantic colors
  static Color success(BuildContext context) =>
      tokens.AppSemanticColors.light.success;
  static Color warning(BuildContext context) =>
      tokens.AppSemanticColors.light.warning;
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  /// Macro colors (consistent with existing palette)
  static const Color macroCarb = tokens.AppColors.macroCarb;
  static const Color macroProtein = tokens.AppColors.macroProtein;
  static const Color macroFat = tokens.AppColors.macroFat;
}

