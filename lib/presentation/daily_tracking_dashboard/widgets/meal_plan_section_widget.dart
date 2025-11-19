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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lista de refeições (sem header interno; o título fica na tela pai)
        for (final item in items) _MealRow(item: item),
      ],
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

    // V4.1: Layout de 2 linhas estilo YAZIO (ajustado)
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _leadingIcon(context, item.title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color:
                          colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  kcal,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _PlusButton(enabled: item.enabled, onPressed: item.onAdd),
        ],
      ),
    );
  }

  Widget _leadingIcon(BuildContext context, String title) {
    final colors = context.colors;
    IconData data;
    Color iconColor;
    Color bgColor;

    switch (title.toLowerCase()) {
      case 'caf\u00e9 da manh\u00e3':
        data = Icons.coffee_rounded;
        iconColor = const Color(0xFFD4A574);
        bgColor = const Color(0xFFD4A574).withValues(alpha: 0.15);
        break;
      case 'almo\u00e7o':
        data = Icons.restaurant_menu_rounded;
        iconColor = const Color(0xFFFF7043);
        bgColor = const Color(0xFFFF7043).withValues(alpha: 0.15);
        break;
      case 'jantar':
        data = Icons.dinner_dining_rounded;
        iconColor = const Color(0xFFE57373);
        bgColor = const Color(0xFFE57373).withValues(alpha: 0.15);
        break;
      case 'lanches':
        data = Icons.bakery_dining_rounded;
        iconColor = const Color(0xFFFFB74D);
        bgColor = const Color(0xFFFFB74D).withValues(alpha: 0.15);
        break;
      default:
        data = Icons.restaurant_rounded;
        iconColor = colors.primary;
        bgColor = colors.surfaceContainerHighest;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        data,
        size: 26,
        color: iconColor,
      ),
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
        enabled ? colors.primary : colors.outlineVariant.withValues(alpha: 0.3);
    final Color fg = enabled
        ? colors.onPrimary
        : colors.onSurfaceVariant.withValues(alpha: 0.5);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: 20,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
