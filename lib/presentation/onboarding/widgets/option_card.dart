import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Single-select option card (Yazio-inspired)
///
/// Used for list-based questions with multiple options
class OptionCard extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading; // Optional emoji or icon

  const OptionCard({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.5.h),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: 3.w),
                ],
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
