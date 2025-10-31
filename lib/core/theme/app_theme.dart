import 'package:flutter/material.dart';
import 'package:nutriz/theme/app_theme.dart' as legacy;
import 'app_dimensions.dart';

/// High-level ThemeData builder for the new dashboard.
///
/// Delegates to our tokenized theme in `lib/theme/app_theme.dart`
/// so there is a single source of truth, but exposes this file
/// in the new `core/theme` location required by the plan.
class AppThemeDS {
  AppThemeDS._();

  static ThemeData light() => legacy.AppTheme.lightTheme;
  static ThemeData dark() => legacy.AppTheme.darkTheme;

  /// Example helper for section padding used across widgets.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: AppDimensions.screenPaddingH,
  );
}

