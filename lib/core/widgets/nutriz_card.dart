import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Standard card container used across dashboard sections.
class NutrizCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool hasBorder;
  final VoidCallback? onTap;
  final double elevation;

  const NutrizCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.hasBorder = true,
    this.onTap,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColorsDS.pureWhite,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: hasBorder
            ? Border.all(
                color: AppColorsDS.cardBorder,
                width: AppDimensions.cardBorderWidth,
              )
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: cardContent,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: card,
      ),
    );
  }
}
