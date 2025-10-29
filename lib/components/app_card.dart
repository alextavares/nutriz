import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Card padronizado do NutriTracker com suporte a modo destacado.
///
/// Características:
/// - Border radius: 20dp (moderno)
/// - Padding: 20dp (confortável)
/// - Sombra visível (opacity 0.08)
/// - Modo normal: fundo branco
/// - Modo destacado: fundo neutral700 com texto branco
class AppCard extends StatelessWidget {
  /// Conteúdo do card
  final Widget child;

  /// Se true, usa fundo escuro (neutral700) com texto branco
  final bool isHighlighted;

  /// Padding customizado (padrão: 20dp)
  final EdgeInsetsGeometry? padding;

  /// Margin customizada (padrão: nenhuma)
  final EdgeInsetsGeometry? margin;

  /// Border radius customizado (padrão: 20dp)
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.isHighlighted = false,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? AppSpacing.cardRadius;
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppSpacing.cardPadding);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        // Fundo: neutral700 se destacado, branco caso contrário
        color: isHighlighted ? AppColors.neutral700 : AppColors.white,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        // Sombra visível (opacity 0.08, blur 16, offset y: 4)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: effectivePadding,
      child: DefaultTextStyle(
        // Se card destacado, texto branco por padrão
        style: TextStyle(
          color: isHighlighted ? AppColors.white : AppColors.neutral900,
        ),
        child: IconTheme(
          // Ícones também ficam brancos se destacado
          data: IconThemeData(
            color: isHighlighted ? AppColors.white : AppColors.neutral700,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Variante compacta do AppCard com menos padding
class AppCardCompact extends StatelessWidget {
  final Widget child;
  final bool isHighlighted;
  final EdgeInsetsGeometry? margin;

  const AppCardCompact({
    super.key,
    required this.child,
    this.isHighlighted = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isHighlighted: isHighlighted,
      margin: margin,
      padding: const EdgeInsets.all(AppSpacing.md), // 16dp em vez de 20dp
      child: child,
    );
  }
}
