import 'package:flutter/material.dart';
import 'package:nutriz/theme/app_text_theme.dart' as legacy;
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography shortcuts for the dashboard refactor.
///
/// Maps the plan's hierarchy (H1/H2/Body/Caption/Button) to our
/// existing Material text theme built by `AppTextTheme`.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = legacy.AppTextTheme.fontFamily;

  // Headings (refined)
  static TextStyle h1(BuildContext context) => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.4,
        color: AppColorsDS.textPrimary(context),
      );

  static TextStyle h2(BuildContext context) => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
        color: AppColorsDS.textPrimary(context),
      );

  // Large number for key metrics
  static TextStyle largeNumber(BuildContext context) => GoogleFonts.manrope(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -0.6,
        color: AppColorsDS.textPrimary(context),
      );

  // Body
  static TextStyle body1(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColorsDS.textPrimary(context),
      );

  static TextStyle body2(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColorsDS.textSecondary(context),
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColorsDS.textHint(context),
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: Colors.white,
      );
}
