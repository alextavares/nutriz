import 'package:flutter/material.dart';

/// 🎨 ONBOARDING THEME - Sistema centralizado de design
///
/// Para mudar cores/fontes, edite APENAS este arquivo!
/// Todas as telas de onboarding usarão automaticamente.
class OnboardingTheme {
  // ==========================================
  // 🎨 CORES PRINCIPAIS
  // ==========================================

  /// Cor primária do app (verde Yazio)
  static const Color primary = Color(0xFF00C896);

  /// Cor de fundo principal (branco/claro)
  static const Color background = Color(0xFFFFFFFF);

  /// Cor de fundo secundária (cinza bem claro)
  static const Color backgroundSecondary = Color(0xFFF8F9FA);

  /// Cor do texto principal (preto)
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Cor do texto secundário (cinza)
  static const Color textSecondary = Color(0xFF6B7280);

  /// Cor do texto hint/placeholder
  static const Color textHint = Color(0xFF9CA3AF);

  /// Cor das bordas (cinza claro)
  static const Color border = Color(0xFFE5E7EB);

  /// Cor das bordas quando selecionado
  static const Color borderSelected = Color(0xFF00C896);

  /// Cor de fundo do card
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Cor de fundo do card quando hover/selected
  static const Color cardBackgroundSelected = Color(0xFFE6F9F4);

  /// Cor de sombra dos cards
  static const Color cardShadow = Color(0x0A000000);

  // ==========================================
  // 🎯 CORES ESPECÍFICAS
  // ==========================================

  /// Cor para objetivo "Perder Peso"
  static const Color goalLoseWeight = Color(0xFF3B82F6);

  /// Cor para objetivo "Ganhar Massa"
  static const Color goalGainMuscle = Color(0xFF8B5CF6);

  /// Cor para objetivo "Manter Peso"
  static const Color goalMaintain = Color(0xFFF59E0B);

  /// Cor de sucesso
  static const Color success = Color(0xFF10B981);

  /// Cor de erro
  static const Color error = Color(0xFFEF4444);

  /// Cor de aviso
  static const Color warning = Color(0xFFF59E0B);

  // ==========================================
  // 📝 TIPOGRAFIA (TAMANHOS E PESOS)
  // ==========================================

  /// Nome da fonte principal
  static const String fontFamily = 'Inter'; // Você pode trocar por: 'Roboto', 'Poppins', etc.

  /// Tamanho do título grande (ex: "Welcome to Yazio")
  static const double fontSizeTitle = 32.0;

  /// Tamanho do título médio (ex: "What's your main goal?")
  static const double fontSizeHeading = 24.0;

  /// Tamanho do subtítulo
  static const double fontSizeSubtitle = 16.0;

  /// Tamanho do corpo de texto
  static const double fontSizeBody = 14.0;

  /// Tamanho de texto pequeno
  static const double fontSizeSmall = 12.0;

  /// Tamanho de botões
  static const double fontSizeButton = 16.0;

  /// Peso da fonte para títulos
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// Peso da fonte para subtítulos
  static const FontWeight fontWeightSemiBold = FontWeight.w600;

  /// Peso da fonte para texto normal
  static const FontWeight fontWeightMedium = FontWeight.w500;

  /// Peso da fonte para texto leve
  static const FontWeight fontWeightRegular = FontWeight.w400;

  // ==========================================
  // 📐 ESPAÇAMENTOS E TAMANHOS
  // ==========================================

  /// Espaçamento extra pequeno (4px)
  static const double spaceXS = 4.0;

  /// Espaçamento pequeno (8px)
  static const double spaceSM = 8.0;

  /// Espaçamento médio (16px)
  static const double spaceMD = 16.0;

  /// Espaçamento grande (24px)
  static const double spaceLG = 24.0;

  /// Espaçamento extra grande (32px)
  static const double spaceXL = 32.0;

  /// Espaçamento extra extra grande (48px)
  static const double spaceXXL = 48.0;

  /// Raio de borda padrão para cards
  static const double borderRadiusCard = 16.0;

  /// Raio de borda para botões
  static const double borderRadiusButton = 12.0;

  /// Raio de borda pequeno
  static const double borderRadiusSmall = 8.0;

  /// Altura padrão de botões
  static const double buttonHeight = 56.0;

  /// Altura de inputs
  static const double inputHeight = 56.0;

  /// Largura da borda padrão
  static const double borderWidth = 1.0;

  /// Largura da borda quando selecionado
  static const double borderWidthSelected = 2.0;

  // ==========================================
  // 🎭 ANIMAÇÕES
  // ==========================================

  /// Duração padrão de animações
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Duração de animações rápidas
  static const Duration animationDurationFast = Duration(milliseconds: 150);

  /// Duração de animações lentas
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  /// Curva de animação padrão
  static const Curve animationCurve = Curves.easeInOut;

  // ==========================================
  // 🎨 TEXT STYLES PRONTOS
  // ==========================================

  /// Estilo para títulos grandes
  static TextStyle get titleStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeTitle,
    fontWeight: fontWeightBold,
    color: textPrimary,
    height: 1.2,
  );

  /// Estilo para cabeçalhos (headings)
  static TextStyle get headingStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeHeading,
    fontWeight: fontWeightBold,
    color: textPrimary,
    height: 1.3,
  );

  /// Estilo para subtítulos
  static TextStyle get subtitleStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSubtitle,
    fontWeight: fontWeightMedium,
    color: textSecondary,
    height: 1.5,
  );

  /// Estilo para corpo de texto
  static TextStyle get bodyStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    height: 1.5,
  );

  /// Estilo para texto pequeno
  static TextStyle get smallStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    color: textSecondary,
    height: 1.4,
  );

  /// Estilo para texto de botões
  static TextStyle get buttonTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeButton,
    fontWeight: fontWeightSemiBold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  /// Estilo para labels de input
  static TextStyle get labelStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightMedium,
    color: textPrimary,
  );

  /// Estilo para placeholder/hint
  static TextStyle get hintStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBody,
    fontWeight: fontWeightRegular,
    color: textHint,
  );

  // ==========================================
  // 🔘 BUTTON STYLES
  // ==========================================

  /// Estilo para botão primário
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, buttonHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
  );

  /// Estilo para botão secundário (outlined)
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primary,
    minimumSize: Size(double.infinity, buttonHeight),
    side: BorderSide(color: border, width: borderWidth),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
    ),
  );

  /// Estilo para botão de texto
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primary,
    minimumSize: Size(double.infinity, buttonHeight),
  );

  // ==========================================
  // 📦 DECORAÇÕES PRONTAS
  // ==========================================

  /// Decoração para cards padrão
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadiusCard),
    border: Border.all(color: border, width: borderWidth),
    boxShadow: [
      BoxShadow(
        color: cardShadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  /// Decoração para cards selecionados
  static BoxDecoration get cardDecorationSelected => BoxDecoration(
    color: cardBackgroundSelected,
    borderRadius: BorderRadius.circular(borderRadiusCard),
    border: Border.all(color: borderSelected, width: borderWidthSelected),
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.1),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Decoração para inputs
  static InputDecoration getInputDecoration({
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    suffixIcon: suffixIcon,
    labelStyle: labelStyle,
    hintStyle: hintStyle,
    filled: true,
    fillColor: backgroundSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
      borderSide: BorderSide(color: border, width: borderWidth),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
      borderSide: BorderSide(color: border, width: borderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
      borderSide: BorderSide(color: borderSelected, width: borderWidthSelected),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadiusButton),
      borderSide: BorderSide(color: error, width: borderWidth),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: spaceMD,
      vertical: spaceMD,
    ),
  );

  // ==========================================
  // 📊 PROGRESS BAR
  // ==========================================

  /// Cor da barra de progresso (fundo)
  static const Color progressBarBackground = Color(0xFFE5E7EB);

  /// Cor da barra de progresso (preenchimento)
  static const Color progressBarForeground = primary;

  /// Altura da barra de progresso
  static const double progressBarHeight = 4.0;

  /// Raio de borda da barra de progresso
  static const double progressBarRadius = 2.0;
}

/// 🎨 EXTENSION para facilitar uso
extension OnboardingThemeExtension on BuildContext {
  /// Acesso rápido ao tema de onboarding
  /// Uso: context.onboardingTheme.primary
  OnboardingTheme get onboardingTheme => OnboardingTheme();
}
