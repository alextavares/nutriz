import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the application.
/// Implements Contemporary Dark Minimalism design system for health and nutrition tracking.
class AppTheme {
  AppTheme._();

  // Design System Colors - Focused Dark Spectrum
  static const Color primaryBackgroundDark = Color(0xFF0F1113);
  static const Color secondaryBackgroundDark = Color(0xFF14171A);
  static const Color activeBlue = Color(0xFF3D91DA); // tokens.light.primary
  static const Color successGreen = Color(0xFF2E7D32); // tokens.light.success
  static const Color warningAmber = Color(0xFFF57C00); // tokens.light.warning
  static const Color premiumGold = Color(0xFFFFD60A);
  static const Color textPrimary = Color(0xFFF5F6F8);
  static const Color textSecondary = Color(0xFFA1A1A6);
  static const Color dividerGray = Color(0xFF2C2C2E);
  static const Color errorRed = Color(0xFFD32F2F); // tokens.light.error

  // Light theme colors (minimal usage for system compatibility)
  static const Color primaryBackgroundLight = Color(0xFFFFFFFF);
  static const Color secondaryBackgroundLight = Color(0xFFF9FAFB);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // Shadow colors optimized for dark theme
  static const Color shadowDark = Color(0x33000000);
  static const Color shadowLight = Color(0x1A000000);

  /// Dark theme - Primary theme for health and nutrition tracking
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    fontFamilyFallback: [
      // Symbols, Emoji and CJK fallbacks
      GoogleFonts.notoSansSymbols().fontFamily!,
      GoogleFonts.notoColorEmoji().fontFamily!,
      GoogleFonts.notoSansJp().fontFamily!,
      GoogleFonts.notoSansKr().fontFamily!,
      GoogleFonts.notoSansSc().fontFamily!,
      GoogleFonts.notoSansTc().fontFamily!,
    ],
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: activeBlue,
      onPrimary: textPrimary,
      primaryContainer: activeBlue.withValues(alpha: 0.2),
      onPrimaryContainer: textPrimary,
      secondary: successGreen,
      onSecondary: primaryBackgroundDark,
      secondaryContainer: successGreen.withValues(alpha: 0.2),
      onSecondaryContainer: textPrimary,
      tertiary: premiumGold,
      onTertiary: primaryBackgroundDark,
      tertiaryContainer: premiumGold.withValues(alpha: 0.2),
      onTertiaryContainer: textPrimary,
      error: errorRed,
      onError: textPrimary,
      surface: secondaryBackgroundDark,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: dividerGray,
      outlineVariant: dividerGray.withValues(alpha: 0.5),
      shadow: shadowDark,
      scrim: primaryBackgroundDark.withValues(alpha: 0.8),
      inverseSurface: primaryBackgroundLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: activeBlue,
    ),
    scaffoldBackgroundColor: primaryBackgroundDark,
    cardColor: secondaryBackgroundDark,
    dividerColor: dividerGray,

    // AppBar theme for contextual navigation
    appBarTheme: AppBarTheme(
      backgroundColor: primaryBackgroundDark,
      foregroundColor: textPrimary,
      elevation: 0,
      shadowColor: shadowDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    ),

    // Card theme for meal logging and progress tracking
    cardTheme: CardThemeData(
      color: secondaryBackgroundDark,
      elevation: 2,
      shadowColor: shadowDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation for persistent state management
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: secondaryBackgroundDark,
      selectedItemColor: activeBlue,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    ),

    // Floating action button for contextual actions
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: activeBlue,
      foregroundColor: textPrimary,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: CircleBorder(),
    ),

    // Button themes for consistent interaction patterns
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textPrimary,
        backgroundColor: activeBlue,
        disabledForegroundColor: textSecondary,
        disabledBackgroundColor: dividerGray,
        elevation: 2,
        shadowColor: shadowDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: activeBlue,
        disabledForegroundColor: textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: activeBlue, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: activeBlue,
        disabledForegroundColor: textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Typography system using Inter font family
    textTheme: _buildDarkTextTheme(),

    // Chip style for badges
    chipTheme: ChipThemeData(
      backgroundColor: secondaryBackgroundDark,
      disabledColor: dividerGray,
      selectedColor: activeBlue.withValues(alpha: 0.15),
      secondarySelectedColor: activeBlue.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      labelStyle: GoogleFonts.notoSans(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: GoogleFonts.notoSans(
        color: activeBlue,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      brightness: Brightness.dark,
      shape: StadiumBorder(side: BorderSide(color: dividerGray.withValues(alpha: 0.6))),
      side: BorderSide(color: dividerGray.withValues(alpha: 0.6)),
    ),

    // Input decoration for meal logging forms
    inputDecorationTheme: InputDecorationTheme(
      fillColor: secondaryBackgroundDark,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: dividerGray.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: dividerGray.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: activeBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.notoSans(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.notoSans(
        color: textSecondary.withValues(alpha: 0.7),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Switch theme for settings and preferences
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return activeBlue;
        }
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return activeBlue.withValues(alpha: 0.3);
        }
        return dividerGray;
      }),
    ),

    // Checkbox theme for meal selection
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return activeBlue;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(textPrimary),
      side: const BorderSide(color: dividerGray, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Radio theme for option selection
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return activeBlue;
        }
        return dividerGray;
      }),
    ),

    // Progress indicator for calorie tracking
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: activeBlue,
      linearTrackColor: dividerGray,
      circularTrackColor: dividerGray,
    ),

    // Slider theme for portion sizes
    sliderTheme: SliderThemeData(
      activeTrackColor: activeBlue,
      thumbColor: activeBlue,
      overlayColor: activeBlue.withValues(alpha: 0.2),
      inactiveTrackColor: dividerGray,
      valueIndicatorColor: activeBlue,
      valueIndicatorTextStyle: GoogleFonts.notoSans(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Tab bar theme for navigation sections
    tabBarTheme: TabBarThemeData(
      labelColor: activeBlue,
      unselectedLabelColor: textSecondary,
      indicatorColor: activeBlue,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    ),

    // Tooltip theme for helpful information
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryBackgroundDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: GoogleFonts.notoSans(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Snackbar theme for feedback messages
    snackBarTheme: SnackBarThemeData(
      backgroundColor: secondaryBackgroundDark,
      contentTextStyle: GoogleFonts.notoSans(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: activeBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
    ),

    // Dialog theme for confirmations and alerts
    dialogTheme: DialogThemeData(
      backgroundColor: secondaryBackgroundDark,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: GoogleFonts.notoSans(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      contentTextStyle: GoogleFonts.notoSans(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
    ),

    // List tile theme for menu items
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: activeBlue.withValues(alpha: 0.1),
      iconColor: textSecondary,
      textColor: textPrimary,
      selectedColor: activeBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),

    // Divider theme for content separation
    dividerTheme: const DividerThemeData(
      color: dividerGray,
      thickness: 1,
      space: 1,
    ),
  );

  /// Light theme - Minimal implementation for system compatibility
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    fontFamilyFallback: [
      GoogleFonts.notoSansSymbols().fontFamily!,
      GoogleFonts.notoColorEmoji().fontFamily!,
      GoogleFonts.notoSansJp().fontFamily!,
      GoogleFonts.notoSansKr().fontFamily!,
      GoogleFonts.notoSansSc().fontFamily!,
      GoogleFonts.notoSansTc().fontFamily!,
    ],
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: activeBlue,
      onPrimary: textPrimary,
      primaryContainer: activeBlue.withValues(alpha: 0.1),
      onPrimaryContainer: activeBlue,
      secondary: successGreen,
      onSecondary: textPrimary,
      secondaryContainer: successGreen.withValues(alpha: 0.1),
      onSecondaryContainer: successGreen,
      tertiary: premiumGold,
      onTertiary: primaryBackgroundDark,
      tertiaryContainer: premiumGold.withValues(alpha: 0.1),
      onTertiaryContainer: premiumGold,
      error: errorRed,
      onError: textPrimary,
      surface: primaryBackgroundLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight.withValues(alpha: 0.5),
      shadow: shadowLight,
      scrim: primaryBackgroundDark.withValues(alpha: 0.5),
      inverseSurface: primaryBackgroundDark,
      onInverseSurface: textPrimary,
      inversePrimary: activeBlue,
    ),
    scaffoldBackgroundColor: primaryBackgroundLight,
    cardColor: secondaryBackgroundLight,
    dividerColor: dividerLight,
    textTheme: _buildLightTextTheme(),
    dialogTheme: DialogThemeData(backgroundColor: primaryBackgroundLight),
  );

  /// Build dark theme typography using Inter font family
  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      // Display styles for large headings
      displayLarge: GoogleFonts.notoSans(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.notoSans(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.notoSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles for section headers
      headlineLarge: GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.notoSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.notoSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.28,
      ),

      // Title styles for cards and dialogs
      titleLarge: GoogleFonts.notoSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.24,
      ),
      titleMedium: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.40,
      ),

      // Body styles for content text
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.2,
        height: 1.33,
      ),

      // Label styles for buttons and captions
      labelLarge: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.notoSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Build light theme typography (minimal implementation)
  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      headlineLarge: GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.25,
      ),
      titleLarge: GoogleFonts.notoSans(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0,
        height: 1.27,
      ),
      bodyLarge: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimaryLight,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      labelLarge: GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryLight,
        letterSpacing: 0.1,
        height: 1.43,
      ),
    );
  }
}
