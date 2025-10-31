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
  static const double screenPaddingH = tokens.AppSpacing.screenHorizontal; // 24
  static const double sectionGap = tokens.AppSpacing.betweenSections; // 24

  // Card
  static const double cardPadding = tokens.AppSpacing.cardPadding; // 20
  static const double cardRadius = tokens.AppSpacing.cardRadius; // 20

  // Radius system
  static const double radiusSm = tokens.AppRadii.sm; // 8
  static const double radiusMd = tokens.AppRadii.md; // 12
  static const double radiusLg = tokens.AppRadii.lg; // 16
  static const double radiusXl = tokens.AppRadii.xl; // 24
  static const double radiusCard = tokens.AppRadii.card; // 12
  static const double radiusButton = tokens.AppRadii.button; // 12
  static const double radiusPill = tokens.AppRadii.pill; // 20
  static const double radiusInput = tokens.AppRadii.input; // 8

  // Touch targets and icon sizes
  static const double touchMin = tokens.TouchTargets.minimum; // 44
  static const double touchComfort = tokens.TouchTargets.comfortable; // 48
  static const double touchLarge = tokens.TouchTargets.large; // 56
  static const double iconSm = tokens.TouchTargets.iconSm; // 20
  static const double iconMd = tokens.TouchTargets.iconMd; // 24

  // Convenience gaps
  static const SizedBox gap4 = SizedBox(height: xxs);
  static const SizedBox gap8 = SizedBox(height: xs);
  static const SizedBox gap12 = SizedBox(height: sm);
  static const SizedBox gap16 = SizedBox(height: md);
  static const SizedBox gap20 = SizedBox(height: lg);
  static const SizedBox gap24 = SizedBox(height: xl);
  static const SizedBox sectionSpacing = SizedBox(height: sectionGap);
}

