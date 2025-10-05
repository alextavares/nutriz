import 'package:flutter/material.dart';

import '../../../theme/design_tokens.dart';

class MealPlanItem {
  final String title;
  final int consumedKcal;
  final int goalKcal;
  final String? subtitle; // e.g., last item name
  final bool ai; // show small AI badge before subtitle
  final bool enabled; // enable + button
  final VoidCallback? onAdd;

  const MealPlanItem({
    required this.title,
    required this.consumedKcal,
    required this.goalKcal,
    this.subtitle,
    this.ai = false,
    this.enabled = true,
    this.onAdd,
  });
}

class MealPlanSectionWidget extends StatelessWidget {
  final List<MealPlanItem> items;
  const MealPlanSectionWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          for (final item in items) _MealRow(item: item),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealPlanItem item;
  const _MealRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final kcal = '${item.consumedKcal} / ${item.goalKcal} kcal';
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _leadingIcon(context, item.title),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      kcal,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (item.ai)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'AI',
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      if (item.ai) const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 8),
          _PlusButton(enabled: item.enabled, onPressed: item.onAdd),
        ],
      ),
    );
  }

  Widget _leadingIcon(BuildContext context, String title) {
    final colors = context.colors;
    IconData data;
    switch (title.toLowerCase()) {
      case 'almoço':
        data = Icons.ramen_dining_rounded;
        break;
      case 'jantar':
        data = Icons.dinner_dining_rounded;
        break;
      case 'lanches':
        data = Icons.emoji_food_beverage_rounded;
        break;
      default:
        data = Icons.restaurant_rounded;
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: colors.surfaceContainerHighest,
      child: Icon(data, color: colors.primary),
    );
  }
}

class _PlusButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  const _PlusButton({required this.enabled, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color bg =
        enabled ? colors.primary : colors.outlineVariant.withValues(alpha: 0.6);
    final Color fg = enabled
        ? colors.onPrimary
        : colors.onSurfaceVariant.withValues(alpha: 0.7);
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(Icons.add, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}
