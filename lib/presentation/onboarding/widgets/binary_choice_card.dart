import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Binary choice cards (Yes/No) - Yazio-inspired
///
/// Used for simple yes/no questions with 50-50 split layout
class BinaryChoiceCard extends StatelessWidget {
  final String leftText;
  final String rightText;
  final bool? selected; // null = none, true = left, false = right
  final ValueChanged<bool> onSelect;

  const BinaryChoiceCard({
    super.key,
    this.leftText = 'Yes',
    this.rightText = 'No',
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _ChoiceCard(
            text: leftText,
            selected: selected == true,
            onTap: () => onSelect(true),
            colors: colors,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _ChoiceCard(
            text: rightText,
            selected: selected == false,
            onTap: () => onSelect(false),
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colors;

  const _ChoiceCard({
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.08)
                : colors.surfaceContainerHighest.withValues(alpha: 0.4),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
