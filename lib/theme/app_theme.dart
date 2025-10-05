import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';
import 'presets/yazio_like.dart';

/// Central Material 3 theme configuration backed by NutriTracker design tokens.
class AppTheme {
  AppTheme._();

  // Test hook: disable Google Fonts in widget tests to avoid font loading issues.
  static bool _testNoGoogleFonts = false;
  static void enableTestFonts() => _testNoGoogleFonts = true;

  // Back-compat shim: if THEME_PRESET is provided at build time,
  // map legacy AppTheme.* static color getters to that preset as well.
  static const String _presetEnv = String.fromEnvironment('THEME_PRESET');

  static AppColorTokens _paletteFromEnv(Brightness brightness) {
    final p = _presetEnv.trim();
    if (p.isEmpty) {
      return brightness == Brightness.dark
          ? AppColorTokens.dark
          : AppColorTokens.light;
    }
    return _resolvePaletteFor(p, brightness);
  }

  static final AppColorTokens _lightPalette = _paletteFromEnv(Brightness.light);
  static final AppColorTokens _darkPalette = _paletteFromEnv(Brightness.dark);

  // Compatibility color constants (existing widgets reference these directly).
  static final Color primaryBackgroundDark = _lightPalette.scheme.surface;
  static final Color secondaryBackgroundDark = _lightPalette.surfaceContainer;
  static final Color activeBlue = _lightPalette.scheme.primary;
  static final Color successGreen = _lightPalette.semantics.success;
  static final Color warningAmber = _lightPalette.semantics.warning;
  static final Color premiumGold = _lightPalette.semantics.premium;
  static final Color textPrimary = _lightPalette.scheme.onSurface;
  static final Color textSecondary = _lightPalette.scheme.onSurfaceVariant;
  static final Color dividerGray = _lightPalette.scheme.outline;
  static final Color errorRed = _lightPalette.scheme.error;

  static final Color primaryBackgroundLight = _lightPalette.scheme.surface;
  static final Color secondaryBackgroundLight = _lightPalette.surfaceContainer;
  static final Color textPrimaryLight = _lightPalette.scheme.onSurface;
  static final Color textSecondaryLight = _lightPalette.scheme.onSurfaceVariant;
  static final Color dividerLight = _lightPalette.scheme.outline;

  static final Color shadowDark = _lightPalette.shadow;
  static final Color shadowLight = _darkPalette.shadow;

  static ThemeData get lightTheme =>
      _buildTheme(_lightPalette, Brightness.light);
  static ThemeData get darkTheme => _buildTheme(_darkPalette, Brightness.dark);

  /// Build a ThemeData for a given preset identifier.
  ///
  /// Supported presets: null/empty (default), 'yazio', 'yazio_like'.
  static ThemeData themeForPreset({
    String? preset,
    required Brightness brightness,
  }) {
    final palette = _resolvePaletteFor(preset, brightness);
    return _buildTheme(palette, brightness);
  }

  static ThemeData lightThemeForPreset(String? preset) =>
      themeForPreset(preset: preset, brightness: Brightness.light);

  static ThemeData darkThemeForPreset(String? preset) =>
      themeForPreset(preset: preset, brightness: Brightness.dark);

  static AppColorTokens _resolvePaletteFor(
      String? preset, Brightness brightness) {
    final p = (preset ?? '').trim().toLowerCase();
    if (p == 'yazio' || p == 'yazio_like') {
      return brightness == Brightness.dark
          ? YazioLikeTokens.dark
          : YazioLikeTokens.light;
    }
    return brightness == Brightness.dark ? _darkPalette : _lightPalette;
  }

  static ThemeData _buildTheme(AppColorTokens colors, Brightness brightness) {
    final colorScheme = colors.scheme;
    final useGoogleFonts = !_testNoGoogleFonts && GoogleFonts.config.allowRuntimeFetching;

    final String? fontFamily =
        useGoogleFonts ? GoogleFonts.inter().fontFamily : null;
    List<String>? fontFallbacks;
    if (useGoogleFonts) {
      final fallbacks = _safeFontFallbackFamilies();
      fontFallbacks = fallbacks.isEmpty ? null : fallbacks;
    }


    final textTheme = _buildTextTheme(brightness, colorScheme, useGoogleFonts);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallbacks,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        shadowColor: colors.shadow,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle:
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      ),
      cardTheme: CardThemeData(
        color: colors.elevatedSurface,
        elevation: brightness == Brightness.light ? 1 : 2,
        shadowColor: colors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.elevatedSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle:
            textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelSmall,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        focusElevation: 7,
        hoverElevation: 7,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          elevation: brightness == Brightness.light ? 1 : 0,
          shadowColor: colors.shadow,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          elevation: brightness == Brightness.light ? 0 : 0,
          shadowColor: colors.shadow,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.primary, width: 1.2),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor:
              colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainer,
        disabledColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary.withValues(alpha: 0.1),
        secondarySelectedColor: colorScheme.primary.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        brightness: brightness,
        shape:
            StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.elevatedSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.3);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outlineVariant;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.2),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle:
            textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.elevatedSurface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.elevatedSurface,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.elevatedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: colors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.08),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        selectedColor: colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      extensions: <ThemeExtension<dynamic>>[colors.semantics],
    );
  }

  static List<String> _safeFontFallbackFamilies() {
    // Rely on platform defaults when runtime fetching is disabled.
    return const <String>["sans-serif"];
  }

  static TextTheme _buildTextTheme(
    Brightness brightness,
    ColorScheme colorScheme,
    bool useGoogleFonts,
  ) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
    ).textTheme;

    final appliedBase = base.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    if (!useGoogleFonts) {
      return appliedBase;
    }

    final interTheme = GoogleFonts.interTextTheme(appliedBase);

    TextStyle _notoSans(TextStyle? baseStyle, double size, FontWeight weight,
        {double letterSpacing = 0, double? height}) {
      return GoogleFonts.notoSans(
        textStyle: baseStyle,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return interTheme.copyWith(
      headlineLarge: _notoSans(interTheme.headlineLarge, 32, FontWeight.w700,
          letterSpacing: -0.2, height: 1.24),
      headlineMedium: _notoSans(interTheme.headlineMedium, 28, FontWeight.w600,
          letterSpacing: -0.2, height: 1.27),
      headlineSmall: _notoSans(interTheme.headlineSmall, 24, FontWeight.w600,
          letterSpacing: -0.1, height: 1.28),
      titleLarge: _notoSans(interTheme.titleLarge, 22, FontWeight.w600,
          letterSpacing: -0.05, height: 1.3),
      titleMedium: _notoSans(interTheme.titleMedium, 16, FontWeight.w600,
          letterSpacing: 0.1, height: 1.5),
      titleSmall: _notoSans(interTheme.titleSmall, 14, FontWeight.w600,
          letterSpacing: 0.1, height: 1.4),
      bodyLarge:
          interTheme.bodyLarge?.copyWith(letterSpacing: 0.2, height: 1.5),
      bodyMedium:
          interTheme.bodyMedium?.copyWith(letterSpacing: 0.15, height: 1.43),
      bodySmall: interTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.2,
        height: 1.33,
      ),
      labelLarge: interTheme.labelLarge
          ?.copyWith(letterSpacing: 0.1, fontWeight: FontWeight.w600),
      labelMedium: interTheme.labelMedium
          ?.copyWith(letterSpacing: 0.2, fontWeight: FontWeight.w600),
      labelSmall: interTheme.labelSmall
          ?.copyWith(letterSpacing: 0.3, fontWeight: FontWeight.w600),
    );
  }
}
