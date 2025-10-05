import 'package:flutter/material.dart';

import '../design_tokens.dart';

/// YAZIO-like color presets derived from captured reference screens.
///
/// Notes:
/// - Primary leans towards a fresh cyan/teal used broadly for actions and
///   selection states in YAZIO.
/// - Secondary uses a soft pink/rose often seen in highlights and PRO upsells.
/// - Tertiary provides a purple accent for occasional emphasis.
/// - Surface and container values aim for clean, bright cards with soft shadows.
class YazioLikeTokens {
  YazioLikeTokens._();

  static const AppColorTokens light = AppColorTokens(
    scheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF00C2CC), // cyan/teal primary
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE0F7FA),
      onPrimaryContainer: Color(0xFF00474C),
      secondary: Color(0xFFFF6B6B), // rose/pink highlight
      onSecondary: Color(0xFF4B0009),
      secondaryContainer: Color(0xFFFFE1E6),
      onSecondaryContainer: Color(0xFF3F0010),
      tertiary: Color(0xFF7C4DFF), // purple accent
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFE9DDFF),
      onTertiaryContainer: Color(0xFF2A0066),
      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFECACA),
      onErrorContainer: Color(0xFF410E0B),
      surface: Color(0xFFFEFFFF),
      onSurface: Color(0xFF0E1726),
      surfaceContainerHighest: Color(0xFFEAF2F6),
      onSurfaceVariant: Color(0xFF536173),
      outline: Color(0xFFD2DCE6),
      outlineVariant: Color(0xFFE5ECF2),
      shadow: Color(0x1A0B1A2B),
      scrim: Color(0x330B1A2B),
      inverseSurface: Color(0xFF101828),
      onInverseSurface: Color(0xFFE2E8F0),
      inversePrimary: Color(0xFF7CE8EE),
    ),
    semantics: AppSemanticColors.light,
    surfaceBright: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFF2F7FA),
    surfaceContainer: Color(0xFFF6FAFC),
    elevatedSurface: Color(0xFFFFFFFF),
    shadow: Color(0x1A0B1A2B),
  );

  static const AppColorTokens dark = AppColorTokens(
    scheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7CE8EE),
      onPrimary: Color(0xFF00363A),
      primaryContainer: Color(0xFF00565D),
      onPrimaryContainer: Color(0xFFB9F8FC),
      secondary: Color(0xFFFFB3B8),
      onSecondary: Color(0xFF4A0A13),
      secondaryContainer: Color(0xFF661B24),
      onSecondaryContainer: Color(0xFFFFD9DE),
      tertiary: Color(0xFFC9B6FF),
      onTertiary: Color(0xFF2D0E86),
      tertiaryContainer: Color(0xFF4421A6),
      onTertiaryContainer: Color(0xFFEBDCFF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF101723),
      onSurface: Color(0xFFE0E6F0),
      surfaceContainerHighest: Color(0xFF1C2633),
      onSurfaceVariant: Color(0xFF95A0B1),
      outline: Color(0xFF465165),
      outlineVariant: Color(0xFF2E394A),
      shadow: Color(0x99000000),
      scrim: Color(0x99000000),
      inverseSurface: Color(0xFFE2E8F0),
      onInverseSurface: Color(0xFF0F172A),
      inversePrimary: Color(0xFF00C2CC),
    ),
    semantics: AppSemanticColors.dark,
    surfaceBright: Color(0xFF172136),
    surfaceDim: Color(0xFF0C1420),
    surfaceContainer: Color(0xFF142030),
    elevatedSurface: Color(0xFF162436),
    shadow: Color(0x66000000),
  );
}

