import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Large numeric input with unit toggle (kg/lb) - Yazio-inspired
///
/// Used for weight, height, and other numeric inputs
class NumericInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? unit1; // e.g., "kg"
  final String? unit2; // e.g., "lb"
  final bool? selectedUnit1; // true = unit1, false = unit2, null = no toggle
  final ValueChanged<bool>? onUnitChange;
  final String? hint;

  const NumericInputWidget({
    super.key,
    required this.controller,
    this.unit1,
    this.unit2,
    this.selectedUnit1,
    this.onUnitChange,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasUnits = unit1 != null && unit2 != null;

    return Column(
      children: [
        // Large numeric input
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint ?? '0',
            hintStyle: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colors.primary,
                width: 2,
              ),
            ),
          ),
        ),

        if (hasUnits) ...[
          SizedBox(height: 3.h),
          // Unit toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _UnitButton(
                text: unit1!,
                selected: selectedUnit1 == true,
                onTap: () => onUnitChange?.call(true),
                colors: colors,
              ),
              SizedBox(width: 2.w),
              _UnitButton(
                text: unit2!,
                selected: selectedUnit1 == false,
                onTap: () => onUnitChange?.call(false),
                colors: colors,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _UnitButton({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ),
      ),
    );
  }
}
