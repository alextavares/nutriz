import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

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
    // Even with zero entries, we want to show empty meal states
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.5.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
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
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 1.6.h),
          // Render existing meal sections first
          ...grouped.entries.map((e) => _buildSection(context, e.key, e.value)),
          // Render empty states for missing meals
          ..._missingMeals(grouped.keys.toList()).map((label) => _buildEmptySection(context, label)),
        ],
      ),
    );
  }

  List<String> _missingMeals(List<String> present) {
    final all = <String>['Café da manhã', 'Almoço', 'Jantar', 'Lanches'];
    return all.where((m) => !present.contains(m)).toList();
  }

  Widget _macroBadge(String text) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: StadiumBorder(
        side: BorderSide(color: AppTheme.warningAmber.withValues(alpha: 0.6)),
      ),
      labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.warningAmber,
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

  Widget _buildSection(BuildContext context, String label, List<Map<String, dynamic>> items) {
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
              Icon(_mealIcon(label), color: AppTheme.textSecondary, size: 18),
              SizedBox(width: 1.w),
              Text(
                label,
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.foodLogging),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: AppTheme.darkTheme.textTheme.bodySmall,
                ),
              ),
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                '$totalKcal kcal • C ${totalCarb}g • P ${totalProt}g • G ${totalFat}g',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                  fontWeight: exceeded ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (exceeded) ...[
                SizedBox(width: 2.w),
                Chip(
                  label: const Text('Excedeu'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppTheme.secondaryBackgroundDark,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: AppTheme.errorRed.withValues(alpha: 0.6)),
                  ),
                  labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ] else ...[
                if (carbOver) ...[SizedBox(width: 2.w), _macroBadge('Carb+')],
                if (protOver) ...[SizedBox(width: 2.w), _macroBadge('Prot+')],
                if (fatOver) ...[SizedBox(width: 2.w), _macroBadge('Gord+')],
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
                barColor = AppTheme.errorRed;
              } else if (pct >= 0.9) {
                barColor = AppTheme.warningAmber;
              } else {
                barColor = AppTheme.activeBlue;
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
                        backgroundColor: AppTheme.dividerGray.withValues(alpha: 0.4),
                        color: barColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '$totalKcal / $goal kcal',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: exceeded ? AppTheme.errorRed : AppTheme.textSecondary,
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
                _buildItem(items[i]),
                if (i != items.length - 1)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0.4.h),
                    height: 1,
                    color: AppTheme.dividerGray.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: 1.2.h),
      ],
    );
  }

  Widget _buildEmptySection(BuildContext context, String label) {
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
              Icon(icon, color: AppTheme.textSecondary, size: 18),
              SizedBox(width: 1.w),
              Text(
                label,
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.foodLogging, arguments: label),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  textStyle: AppTheme.darkTheme.textTheme.bodySmall,
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
            color: AppTheme.darkTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.activeBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.activeBlue,
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
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Toque em + Adicionar para registrar alimentos rapidamente.',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
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

  Widget _buildItem(Map<String, dynamic> it) {
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
          color: isNew
              ? AppTheme.activeBlue.withValues(alpha: 0.08)
              : AppTheme.darkTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNew
                ? AppTheme.activeBlue
                : AppTheme.dividerGray.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowDark,
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
                    style: AppTheme.darkTheme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    '${it['calories']} kcal • C ${it['carbs']}g • P ${it['protein']}g • G ${it['fat']}g',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
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
                  backgroundColor: AppTheme.secondaryBackgroundDark,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: AppTheme.activeBlue.withValues(alpha: 0.6)),
                  ),
                  labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.activeBlue,
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
                  backgroundColor: AppTheme.secondaryBackgroundDark,
                  shape: StadiumBorder(
                    side: BorderSide(
                        color: AppTheme.dividerGray.withValues(alpha: 0.5)),
                  ),
                  labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
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
                  color: AppTheme.errorRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.errorRed,
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
