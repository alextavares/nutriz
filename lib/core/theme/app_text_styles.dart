import 'package:flutter/material.dart';
import 'package:nutriz/theme/app_text_theme.dart' as legacy;

/// Typography shortcuts for the dashboard refactor.
///
/// Maps the plan's hierarchy (H1/H2/Body/Caption/Button) to our
/// existing Material text theme built by `AppTextTheme`.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = legacy.AppTextTheme.fontFamily;

  // Headings
  static TextStyle h1(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!; // 28 / bold

  static TextStyle h2(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!; // 18 / medium

  // Body
  static TextStyle body1(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!; // 15 / medium

  static TextStyle body2(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!; // 15 / regular

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!; // 13 / regular

  static TextStyle button(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!; // 16 / semibold
}

