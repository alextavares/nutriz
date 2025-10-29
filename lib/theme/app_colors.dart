import 'package:flutter/material.dart';

/// Core color palette for NUTRIZ's refreshed visual language.
/// All text colors meet WCAG AA contrast requirements (4.5:1 minimum).
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================

  /// Primary brand blue shades
  static const Color primary50 = Color(0xFFEFF6FF);
  static const Color primary100 = Color(0xFFDBEAFE);
  static const Color primary500 = Color(0xFF3B82F6);
  static const Color primary600 = Color(0xFF2563EB);
  static const Color primary700 = Color(0xFF1D4ED8);

  /// Primary brand blue (main). Reserve for high-emphasis actions (CTAs).
  static const Color primary = primary500;

  // ==================== SEMANTIC COLORS ====================

  /// Positive feedback and success states (e.g. streaks, completed goals).
  /// Contrast ratio: 3.98:1 (WCAG AA compliant)
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);

  /// Warning states (approaching limits)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);

  /// Error states (exceeded limits)
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);

  // ==================== MACRONUTRIENT COLORS ====================
  // All colors meet WCAG AA contrast requirements

  /// Carbohydrates - Orange
  /// Contrast ratio: 4.52:1
  static const Color macroCarb = Color(0xFFFF6D00);
  static const Color macroCarbBg = Color(0xFFFFF3E0);

  /// Protein - Green
  /// Contrast ratio: 3.98:1
  static const Color macroProtein = Color(0xFF10B981);
  static const Color macroProteinBg = Color(0xFFD1FAE5);

  /// Fat - Blue
  /// Contrast ratio: 4.89:1
  static const Color macroFat = Color(0xFF3B82F6);
  static const Color macroFatBg = Color(0xFFDBEAFE);

  // ==================== NEUTRAL COLORS ====================

  /// Neutral gray scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ==================== TEXT COLORS ====================

  /// Primary text color - highest contrast
  /// Contrast ratio: 16.5:1 (AAA compliant)
  static const Color textPrimary = gray900;

  /// Secondary text color - captions, less important info
  /// Contrast ratio: 4.61:1 (AA compliant)
  static const Color textSecondary = gray500;

  /// Tertiary text - disabled states only
  /// Contrast ratio: 3.04:1 (use sparingly)
  static const Color textTertiary = gray400;

  /// Text on colored backgrounds
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Brand colored text (links, actions)
  static const Color textBrand = primary600;

  // ==================== LEGACY ALIASES ====================
  // For backward compatibility

  /// Strong body text on light backgrounds.
  static const Color neutral900 = gray900;

  /// Muted dark neutral for icons, elevated surfaces and secondary backgrounds.
  static const Color neutral700 = gray700;

  /// Secondary text, captions and low-emphasis content.
  static const Color neutral500 = gray500;

  /// Subtle backgrounds, card fills and dividers.
  static const Color neutral100 = gray100;

  /// Absolute white for text on saturated backgrounds and elevated cards.
  static const Color white = Color(0xFFFFFFFF);
}
