import 'package:flutter/material.dart';

/// Spacing scale derived from the refreshed visual language.
@immutable
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radius tokens for rounded components.
@immutable
class AppRadii {
  const AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Semantic colors exposed as a theme extension for quick lookups.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color premium;
  final Color onPremium;
  final Color premiumContainer;
  final Color onPremiumContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.premium,
    required this.onPremium,
    required this.premiumContainer,
    required this.onPremiumContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  static const AppSemanticColors light = AppSemanticColors(
    success: Color(0xFF22C55E),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFD1FAE5),
    onSuccessContainer: Color(0xFF042F12),
    warning: Color(0xFFF97316),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFE0B8),
    onWarningContainer: Color(0xFF4B1D00),
    premium: Color(0xFFFFD54F),
    onPremium: Color(0xFF3C2F00),
    premiumContainer: Color(0xFFFFF3C5),
    onPremiumContainer: Color(0xFF221A00),
    info: Color(0xFF0EA5E9),
    onInfo: Color(0xFF002E3F),
    infoContainer: Color(0xFFCFE7FF),
    onInfoContainer: Color(0xFF00344A),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF003913),
    successContainer: Color(0xFF065F2B),
    onSuccessContainer: Color(0xFFB1F4C6),
    warning: Color(0xFFFFB16A),
    onWarning: Color(0xFF492000),
    warningContainer: Color(0xFF693100),
    onWarningContainer: Color(0xFFFFDCC2),
    premium: Color(0xFFE6C65C),
    onPremium: Color(0xFF2B2000),
    premiumContainer: Color(0xFF4A3E00),
    onPremiumContainer: Color(0xFFFAE38C),
    info: Color(0xFF80CFFF),
    onInfo: Color(0xFF00344D),
    infoContainer: Color(0xFF004C6D),
    onInfoContainer: Color(0xFFBCE3FF),
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? premium,
    Color? onPremium,
    Color? premiumContainer,
    Color? onPremiumContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      premium: premium ?? this.premium,
      onPremium: onPremium ?? this.onPremium,
      premiumContainer: premiumContainer ?? this.premiumContainer,
      onPremiumContainer: onPremiumContainer ?? this.onPremiumContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      premium: Color.lerp(premium, other.premium, t)!,
      onPremium: Color.lerp(onPremium, other.onPremium, t)!,
      premiumContainer:
          Color.lerp(premiumContainer, other.premiumContainer, t)!,
      onPremiumContainer:
          Color.lerp(onPremiumContainer, other.onPremiumContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }
}

/// Complete set of color tokens for light and dark modes.
@immutable
class AppColorTokens {
  final ColorScheme scheme;
  final AppSemanticColors semantics;
  final Color surfaceBright;
  final Color surfaceDim;
  final Color surfaceContainer;
  final Color elevatedSurface;
  final Color shadow;

  const AppColorTokens({
    required this.scheme,
    required this.semantics,
    required this.surfaceBright,
    required this.surfaceDim,
    required this.surfaceContainer,
    required this.elevatedSurface,
    required this.shadow,
  });

  static const AppColorTokens light = AppColorTokens(
    scheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2563EB),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFDBE6FF),
      onPrimaryContainer: Color(0xFF062C7A),
      secondary: Color(0xFF0EA5E9),
      onSecondary: Color(0xFF002733),
      secondaryContainer: Color(0xFFCFF4FF),
      onSecondaryContainer: Color(0xFF003542),
      tertiary: Color(0xFFFF8C42),
      onTertiary: Color(0xFF3A1700),
      tertiaryContainer: Color(0xFFFFE1C6),
      onTertiaryContainer: Color(0xFF522400),
      error: Color(0xFFDC2626),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFECACA),
      onErrorContainer: Color(0xFF410E0B),
      surface: Color(0xFFFBFCFF),
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFE2E8F0),
      onSurfaceVariant: Color(0xFF475569),
      outline: Color(0xFFCBD5E1),
      outlineVariant: Color(0xFFD8E0EF),
      shadow: Color(0x1A0F172A),
      scrim: Color(0x330F172A),
      inverseSurface: Color(0xFF101828),
      onInverseSurface: Color(0xFFE2E8F0),
      inversePrimary: Color(0xFFABC8FF),
    ),
    semantics: AppSemanticColors.light,
    surfaceBright: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFE9EEF7),
    surfaceContainer: Color(0xFFF1F5FB),
    elevatedSurface: Color(0xFFFFFFFF),
    shadow: Color(0x1A0F172A),
  );

  static const AppColorTokens dark = AppColorTokens(
    scheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFABC8FF),
      onPrimary: Color(0xFF002E6D),
      primaryContainer: Color(0xFF0F4FB3),
      onPrimaryContainer: Color(0xFFD8E2FF),
      secondary: Color(0xFF7CD8F5),
      onSecondary: Color(0xFF003544),
      secondaryContainer: Color(0xFF004C60),
      onSecondaryContainer: Color(0xFFBAEFFF),
      tertiary: Color(0xFFFFB784),
      onTertiary: Color(0xFF4B1B00),
      tertiaryContainer: Color(0xFF6A2C00),
      onTertiaryContainer: Color(0xFFFFDCC5),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF0F172A),
      onSurface: Color(0xFFE2E8F0),
      surfaceContainerHighest: Color(0xFF1F2A3B),
      onSurfaceVariant: Color(0xFF9AA4B5),
      outline: Color(0xFF485366),
      outlineVariant: Color(0xFF303B4A),
      shadow: Color(0xB3000000),
      scrim: Color(0x99000000),
      inverseSurface: Color(0xFFE2E8F0),
      onInverseSurface: Color(0xFF0F172A),
      inversePrimary: Color(0xFF2563EB),
    ),
    semantics: AppSemanticColors.dark,
    surfaceBright: Color(0xFF172136),
    surfaceDim: Color(0xFF0B1220),
    surfaceContainer: Color(0xFF152035),
    elevatedSurface: Color(0xFF16263F),
    shadow: Color(0x66000000),
  );
}

extension AppThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  AppSemanticColors get semanticColors =>
      theme.extension<AppSemanticColors>() ??
      (theme.brightness == Brightness.dark
          ? AppSemanticColors.dark
          : AppSemanticColors.light);

  TextTheme get textStyles => theme.textTheme;
}
