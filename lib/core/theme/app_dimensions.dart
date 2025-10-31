import 'package:flutter/material.dart';
import 'package:nutriz/theme/design_tokens.dart' as tokens;

/// Canonical spacing and sizing for the refreshed dashboard.
///
/// This file is a thin facade over our existing design tokens
/// in `lib/theme/design_tokens.dart` to match the new folder
/// layout agreed for the refactor plan.
class AppDimensions {
  AppDimensions._();

  // 8pt baseline scale
  static const double xxs = tokens.AppSpacing.xxs; // 4
  static const double xs = tokens.AppSpacing.xs; // 8
  static const double sm = tokens.AppSpacing.sm; // 12
  static const double md = tokens.AppSpacing.md; // 16
  static const double lg = tokens.AppSpacing.lg; // 20
  static const double xl = tokens.AppSpacing.xl; // 24
  static const double xxl = tokens.AppSpacing.xxl; // 32

  // Screen/layout paddings
  // New refined paddings (YAZIO-like)
  static const double horizontalPadding = 16.0; // left/right of screen
  static const double screenPaddingH = horizontalPadding; // prefer this going forward
  static const double sectionGap = 20.0; // space between sections

  // Card
  static const double cardPadding = 20.0; // internal padding
  static const double cardRadius = 16.0; // more rounded
  static const double cardBorderWidth = 1.0;
  static const double cardElevation = 0.0; // YAZIO uses border, not shadow

  // Radius system
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusCard = 16;
  static const double radiusButton = 12;
  static const double radiusPill = 20;
  static const double radiusInput = 8;

  // Touch targets and icon sizes
  static const double touchMin = 44.0; // WCAG minimum
  static const double touchComfort = 48.0;
  static const double touchLarge = 56.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;

  // Buttons specific
  static const double primaryButtonHeight = 48.0;
  static const double addButtonSize = 36.0;
  static const double addButtonSizeSm = 32.0;

  // Convenience gaps
  static const SizedBox gap4 = SizedBox(height: xxs);
  static const SizedBox gap8 = SizedBox(height: xs);
  static const SizedBox gap12 = SizedBox(height: sm);
  static const SizedBox gap16 = SizedBox(height: md);
  static const SizedBox gap20 = SizedBox(height: lg);
  static const SizedBox gap24 = SizedBox(height: xl);
  static const SizedBox sectionSpacing = SizedBox(height: sectionGap);
}
