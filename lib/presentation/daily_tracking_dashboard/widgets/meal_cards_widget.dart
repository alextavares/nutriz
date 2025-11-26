import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/app_export.dart';

/// Representa uma entrada de alimento
class MealEntry {
  final String id;
  final String name;
  final int calories;
  final String? createdAt;

  const MealEntry({
    required this.id,
    required this.name,
    required this.calories,
    this.createdAt,
  });

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] as String?,
    );
  }
}

/// Dados de uma refeição
class MealData {
  final String key;
  final String title;
  final int currentKcal;
  final int goalKcal;
  final List<MealEntry> entries;

  const MealData({
    required this.key,
    required this.title,
    required this.currentKcal,
    required this.goalKcal,
    this.entries = const [],
  });
}

/// Widget de cards de refeições - extraído do DailyTrackingDashboard
class MealCardsWidget extends StatefulWidget {
  final List<MealData> meals;
  final Set<String> expandedMealKeys;
  final void Function(String mealKey) onAddFood;
  final void Function(String mealKey) onMealTap;
  final void Function(MealEntry entry) onEntryTap;
  final void Function(String mealKey, bool expanded) onToggleExpand;

  const MealCardsWidget({
    super.key,
    required this.meals,
    this.expandedMealKeys = const {},
    required this.onAddFood,
    required this.onMealTap,
    required this.onEntryTap,
    required this.onToggleExpand,
  });

  @override
  State<MealCardsWidget> createState() => _MealCardsWidgetState();
}

class _MealCardsWidgetState extends State<MealCardsWidget> {
  
  Color _barColorFor(String meal) {
    switch (meal) {
      case 'breakfast':
        return AppTheme.warningAmber;
      case 'lunch':
        return AppTheme.successGreen;
      case 'dinner':
        return AppTheme.activeBlue;
      default:
        return AppTheme.premiumGold;
    }
  }

  IconData _mealIconFor(String mealKey) {
    switch (mealKey) {
      case 'breakfast':
        return MdiIcons.coffee;
      case 'lunch':
        return MdiIcons.foodForkDrink;
      case 'dinner':
        return MdiIcons.food;
      default:
        return MdiIcons.cookie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Nutrition', trailingText: 'More'),
        const SizedBox(height: AppDimensions.sm),
        NutrizCard(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...widget.meals.asMap().entries.expand((entry) {
                final index = entry.key;
                final meal = entry.value;
                final isLast = index == widget.meals.length - 1;
                
                return [
                  _buildMealRow(meal, colors),
                  if (!isLast)
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: AppColorsDS.divider,
                      indent: 64,
                    ),
                ];
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealRow(MealData meal, ColorScheme colors) {
    final ratio = meal.goalKcal <= 0 
        ? 0.0 
        : (meal.currentKcal / meal.goalKcal).clamp(0.0, 1.0);
    final color = _barColorFor(meal.key);
    final isExpanded = widget.expandedMealKeys.contains(meal.key);
    final isOver = meal.goalKcal > 0 && meal.currentKcal > meal.goalKcal;

    // Preview: primeiras 2 entradas
    final previewEntries = isExpanded 
        ? meal.entries 
        : meal.entries.take(2).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => widget.onMealTap(meal.key),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da refeição
            Row(
              children: [
                // Ícone circular
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColorsDS.divider,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _mealIconFor(meal.key),
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Título
                Expanded(
                  child: Text(
                    meal.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Calorias
                Text(
                  '${meal.currentKcal}/${meal.goalKcal} kcal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isOver ? AppTheme.errorRed : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Botão adicionar
                AddButton(
                  onPressed: () => widget.onAddFood(meal.key),
                  size: AppDimensions.addButtonSize,
                  color: AppTheme.activeBlue,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Barra de progresso
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 3,
                backgroundColor: colors.outlineVariant.withValues(alpha: 0.35),
                color: color,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Preview de entradas
            if (previewEntries.isNotEmpty) ...[
              ...previewEntries.map((entry) => _buildEntryRow(entry, colors)),
              
              // Botão "Ver todos" / "Mostrar menos"
              if (meal.entries.length > 2)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => widget.onToggleExpand(meal.key, !isExpanded),
                    child: Text(isExpanded ? 'Mostrar menos' : 'Ver todos'),
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntryRow(MealEntry entry, ColorScheme colors) {
    return InkWell(
      onTap: () => widget.onEntryTap(entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                entry.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${entry.calories} kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
