import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- Core Palette ---
  /// Coral Vibrante: Usada para botões primários, links e elementos de destaque.
  /// Transmite energia e motivação.
  static const Color primary = Color(0xFFFF6B6B);

  /// Off-White: Fundo principal da aplicação para evitar o branco puro e dar profundidade.
  static const Color background = Color(0xFFF4F6F8);

  /// Branco Puro: Usado na superfície de cards para criar contraste com o fundo.
  static const Color surface = Color(0xFFFFFFFF);

  /// Cor de texto principal, com alto contraste.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Cor de texto secundária, para descrições e textos de menor importância.
  static const Color textSecondary = Color(0xFF6B6B6B);

  // --- Status & Feedback ---
  /// Verde Suave: Para mensagens de sucesso, confirmações e indicadores positivos.
  static const Color success = Color(0xFF28A745);

  /// Vermelho Suave: Para alertas de erro, avisos e indicadores de exclusão.
  static const Color error = Color(0xFFDC3545);

  /// Cor de preenchimento para campos de texto.
  static const Color inputFill = Color(0xFFFAFAFA);
}

// Função para obter o tema de texto base com a fonte Inter.
TextTheme getBaseTextTheme() {
  // O pubspec.yaml já define 'Inter' como uma fonte local,
  // então podemos nos referir a ela diretamente.
  return const TextTheme(
    displayLarge: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    displayMedium: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    displaySmall: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    headlineLarge: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    headlineMedium: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    headlineSmall: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    titleLarge: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    titleMedium: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    titleSmall: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    bodyLarge: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    bodySmall: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
    labelLarge: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    labelMedium: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
    labelSmall: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
  );
}

// Função principal para obter o tema completo do aplicativo.
ThemeData getAppTheme() {
  final baseTextTheme = getBaseTextTheme();
  final poppinsTextTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);
  const borderRadius = 24.0;

  return ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
    ),
    textTheme: poppinsTextTheme.copyWith(
      // Aplicando Poppins Bold especificamente para os títulos, como solicitado.
      headlineLarge: poppinsTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      headlineMedium: poppinsTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      headlineSmall: poppinsTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      titleLarge: poppinsTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      titleMedium: poppinsTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      titleSmall: poppinsTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),

      // Garantindo que o corpo do texto permaneça com Inter.
      bodyLarge: baseTextTheme.bodyLarge,
      bodyMedium: baseTextTheme.bodyMedium,
      bodySmall: baseTextTheme.bodySmall,
    ),

    // --- Estilização de Componentes ---

    // Card Theme com sombra colorida e bordas arredondadas.
    cardTheme: CardTheme(
      elevation: 8.0,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),

    // ElevatedButton Theme com visual moderno e amigável.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: poppinsTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),

    // InputDecoration Theme para campos de texto limpos.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}
