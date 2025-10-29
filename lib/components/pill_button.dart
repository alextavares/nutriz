import 'package:flutter/material.dart';
import '../core/haptic_helper.dart';
import 'pressable_widget.dart';
import '../theme/design_tokens.dart';
import '../theme/app_colors.dart';

/// Pill-shaped button component for quick actions.
///
/// Features:
/// - Rounded pill shape (radius 20px)
/// - Minimum 44px touch target
/// - Optional icon support
/// - Customizable colors
/// - Haptic feedback on tap
/// - Hover and press states
class PillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsets? padding;

  const PillButton({
    Key? key,
    required this.label,
    this.icon,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.enabled = true,
    this.padding,
  }) : super(key: key);

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? (widget.color ?? AppColors.primary600)
        : AppColors.textTertiary;

    final backgroundColor = widget.enabled
        ? (widget.backgroundColor ?? AppColors.primary50)
        : AppColors.gray100;

    final buttonChild = AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(
          minHeight: TouchTargets.minimum,
        ),
        padding: widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: _isPressed && widget.enabled
                ? color.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        transform: _isPressed && widget.enabled
            ? (Matrix4.identity()..scale(0.96))
            : Matrix4.identity(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );

    if (!widget.enabled) return buttonChild;

    return PressableWidget(
      scale: 0.96,
      onPressed: () {
        HapticHelper.light();
        widget.onTap?.call();
      },
      child: buttonChild,
    );
  }
}

/// Pill button variants for common use cases

/// Success variant (green) - for completed actions
class SuccessPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const SuccessPillButton({
    Key? key,
    required this.label,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: label,
      icon: icon,
      onTap: onTap,
      color: AppColors.success,
      backgroundColor: AppColors.successBg,
    );
  }
}

/// Warning variant (orange) - for caution actions
class WarningPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const WarningPillButton({
    Key? key,
    required this.label,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: label,
      icon: icon,
      onTap: onTap,
      color: AppColors.warning,
      backgroundColor: AppColors.warningBg,
    );
  }
}

/// Carb macro variant (orange)
class CarbPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const CarbPillButton({
    Key? key,
    required this.label,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: label,
      icon: icon,
      onTap: onTap,
      color: AppColors.macroCarb,
      backgroundColor: AppColors.macroCarbBg,
    );
  }
}

/// Protein macro variant (green)
class ProteinPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const ProteinPillButton({
    Key? key,
    required this.label,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: label,
      icon: icon,
      onTap: onTap,
      color: AppColors.macroProtein,
      backgroundColor: AppColors.macroProteinBg,
    );
  }
}

/// Fat macro variant (blue)
class FatPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const FatPillButton({
    Key? key,
    required this.label,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PillButton(
      label: label,
      icon: icon,
      onTap: onTap,
      color: AppColors.macroFat,
      backgroundColor: AppColors.macroFatBg,
    );
  }
}
