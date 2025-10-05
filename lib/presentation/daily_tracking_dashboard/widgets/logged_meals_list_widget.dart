import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class LoggedMealsListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final void Function(Map<String, dynamic> entry) onRemove;
  final void Function(Map<String, dynamic> entry)? onEdit;
  final Duration highlightDuration;
  // metas por refeição para sinalizar excesso na lista
  final Map<String, Map<String, int>>?
      mealTotalsByKey; // chave: mealKey -> {kcal, carbs, proteins, fats}
  final Map<String, int>? mealKcalGoals; // mealKey -> kcal meta
  final Map<String, Map<String, int>>?
      mealMacroGoalsByKey; // mealKey -> {carbs, proteins, fats}

  const LoggedMealsListWidget({
    super.key,
    required this.entries,
    required this.onRemove,
    this.onEdit,
    this.highlightDuration = const Duration(minutes: 5),
    this.mealTotalsByKey,
    this.mealKcalGoals,
    this.mealMacroGoalsByKey,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByMeal(entries);
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    // Even with zero entries, we want to show empty meal states
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.5.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refeições de hoje',
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 1.6.h),
          // Render existing meal sections first
          ...grouped.entries.map((e) => _buildSection(
              context, e.key, e.value, colors, semantics, textTheme)),
          // Render empty states for missing meals
          ..._missingMeals(grouped.keys.toList()).map(
              (label) => _buildEmptySection(context, label, colors, textTheme)),
        ],
      ),
    );
  }

  List<String> _missingMeals(List<String> present) {
    final all = <String>['Café da manhã', 'Almoço', 'Jantar', 'Lanches'];
    return all.where((m) => !present.contains(m)).toList();
  }

  Widget _macroBadge(
    String text,
    ColorScheme colors,
    AppSemanticColors semantics,
    TextTheme textTheme,
  ) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      backgroundColor: colors.surfaceContainerHigh,
      shape: StadiumBorder(
        side: BorderSide(color: semantics.warning.withValues(alpha: 0.6)),
      ),
      labelStyle: textTheme.bodySmall?.copyWith(
        color: semantics.warning,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  IconData _mealIcon(String label) {
    if (label.contains('Café')) return Icons.wb_sunny_outlined;
    if (label.contains('Almoço')) return Icons.restaurant_outlined;
    if (label.contains('Jantar')) return Icons.nightlight_outlined;
    return Icons.fastfood_outlined;
  }

  Widget _buildSection(
    BuildContext context,
    String label,
    List<Map<String, dynamic>> items,
    ColorScheme colors,
    AppSemanticColors semantics,
    TextTheme textTheme,
  ) {
    final totalKcal = items.fold<int>(
        0, (sum, it) => sum + ((it['calories'] as num?)?.toInt() ?? 0));
    final totalCarb = items.fold<int>(
        0, (s, it) => s + ((it['carbs'] as num?)?.toInt() ?? 0));
    final totalProt = items.fold<int>(
        0, (s, it) => s + ((it['protein'] as num?)?.toInt() ?? 0));
    final totalFat =
        items.fold<int>(0, (s, it) => s + ((it['fat'] as num?)?.toInt() ?? 0));
    // Detecta key da refeição
    String mealKey;
    if (label.contains('Café'))
      mealKey = 'breakfast';
    else if (label.contains('Almoço'))
      mealKey = 'lunch';
    else if (label.contains('Jantar'))
      mealKey = 'dinner';
    else
      mealKey = 'snack';
    final int? goal = mealKcalGoals?[mealKey];
    final bool exceeded = goal != null && goal > 0 && totalKcal > goal;
    final macroGoals = mealMacroGoalsByKey?[mealKey] ?? const {};
    final bool carbOver = (macroGoals['carbs'] ?? 0) > 0 &&
        totalCarb > (macroGoals['carbs'] ?? 0);
    final bool protOver = (macroGoals['proteins'] ?? 0) > 0 &&
        totalProt > (macroGoals['proteins'] ?? 0);
    final bool fatOver =
        (macroGoals['fats'] ?? 0) > 0 && totalFat > (macroGoals['fats'] ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Icon(_mealIcon(label), color: colors.onSurfaceVariant, size: 18),
              SizedBox(width: 1.w),
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.addFoodEntry,
                  arguments: {
                    'mealKey': mealKey,
                  },
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: textTheme.bodySmall,
                ),
              ),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                '$totalKcal kcal • C ${totalCarb}g • P ${totalProt}g • G ${totalFat}g',
                style: textTheme.bodyMedium?.copyWith(
                  color: exceeded ? colors.error : colors.primary,
                  fontWeight: exceeded ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (exceeded) ...[
                SizedBox(width: 2.w),
                Chip(
                  label: const Text('Excedeu'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colors.surfaceContainerHigh,
                  shape: StadiumBorder(
                    side:
                        BorderSide(color: colors.error.withValues(alpha: 0.6)),
                  ),
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ] else ...[
                if (carbOver) ...[
                  SizedBox(width: 2.w),
                  _macroBadge('Carb+', colors, semantics, textTheme)
                ],
                if (protOver) ...[
                  SizedBox(width: 2.w),
                  _macroBadge('Prot+', colors, semantics, textTheme)
                ],
                if (fatOver) ...[
                  SizedBox(width: 2.w),
                  _macroBadge('Gord+', colors, semantics, textTheme)
                ],
              ]
            ]),
          ],
        ),
        // Kcal progress vs meta (se disponível)
        if (goal != null && goal > 0) ...[
          SizedBox(height: 0.6.h),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final double pct = (totalKcal / goal).clamp(0.0, 1.0);
              Color barColor;
              if (exceeded) {
                barColor = colors.error;
              } else if (pct >= 0.9) {
                barColor = semantics.warning;
              } else {
                barColor = colors.primary;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 10,
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor:
                            colors.outlineVariant.withValues(alpha: 0.32),
                        color: barColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$totalKcal / $goal kcal',
                    style: textTheme.bodySmall?.copyWith(
                      color: exceeded ? colors.error : colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        SizedBox(height: 0.6.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Column(
            key: ValueKey<String>(_calcItemsKey(items)),
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _buildItem(context, items[i], colors, textTheme, semantics),
                if (i != items.length - 1)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0.4.h),
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 1.2.h),
      ],
    );
  }

  Widget _buildEmptySection(
    BuildContext context,
    String label,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    IconData icon = Icons.fastfood_outlined;
    if (label.contains('Café')) icon = Icons.wb_sunny_outlined;
    if (label.contains('Almoço')) icon = Icons.restaurant_outlined;
    if (label.contains('Jantar')) icon = Icons.nightlight_outlined;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(icon, color: colors.onSurfaceVariant, size: 18),
              SizedBox(width: 1.w),
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.addFoodEntry,
                  arguments: {
                    'mealName': label,
                  },
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: textTheme.bodySmall,
                ),
              ),
            ]),
          ],
        ),
        SizedBox(height: 0.6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'add',
                  color: colors.primary,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sem itens nesta refeição',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Toque em + Adicionar para registrar alimentos rapidamente.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.2.h),
      ],
    );
  }

  String _calcItemsKey(List<Map<String, dynamic>> items) {
    final ids = items.map((e) => (e['id'] ?? e.hashCode).toString()).join('|');
    return ids;
  }

  Widget _buildItem(
    BuildContext context,
    Map<String, dynamic> it,
    ColorScheme colors,
    TextTheme textTheme,
    AppSemanticColors semantics,
  ) {
    final createdAtStr = it['createdAt'] as String?;
    DateTime? createdAt;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {}
    }
    final bool isNew = createdAt != null &&
        DateTime.now().difference(createdAt) <= highlightDuration;
    return GestureDetector(
      onTap: onEdit != null ? () => onEdit!(it) : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 0.8.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color:
              isNew ? colors.primary.withValues(alpha: 0.08) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNew
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (it['name'] as String?) ?? '-',
                    style:
                        textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    '${it['calories']} kcal • C ${it['carbs']}g • P ${it['protein']}g • G ${it['fat']}g',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isNew)
              Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Chip(
                  label: const Text('novo'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colors.surfaceContainerHigh,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.6)),
                  ),
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if ((it['source'] as String?)?.startsWith('AI/') == true)
              Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: Chip(
                  label: Text((it['source'] as String?) ?? 'AI'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colors.surfaceContainerHigh,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  labelStyle: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onRemove(it);
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'delete',
                  color: colors.error,
                  size: 5.w,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupByMeal(
      List<Map<String, dynamic>> entries) {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Café da manhã': [],
      'Almoço': [],
      'Jantar': [],
      'Lanches': [],
    };
    for (final e in entries) {
      final meal = (e['mealTime'] as String?) ?? 'snack';
      if (meal == 'breakfast')
        grouped['Café da manhã']!.add(e);
      else if (meal == 'lunch')
        grouped['Almoço']!.add(e);
      else if (meal == 'dinner')
        grouped['Jantar']!.add(e);
      else
        grouped['Lanches']!.add(e);
    }
    // remove vazias
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }
}
