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

  const NutrizCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.hasBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppDimensions.sm),
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
      ),
      child: child,
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
