import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/gemini_client.dart';
import '../../../theme/design_tokens.dart';

class FoodAnalysisResultsWidget extends StatelessWidget {
  final FoodNutritionData results;
  final Function(DetectedFood) onAddFood;
  final Function(DetectedFood)? onEditFood;
  final Function(List<DetectedFood>)? onAddAll;
  final Set<int>? completedIndices; // índices marcados como concluídos (mostra overlay)
  final void Function(int)? onMarkComplete; // chamado ao tocar em adicionar
  final int overlayDurationMs; // duração do fade do check

  const FoodAnalysisResultsWidget({
    Key? key,
    required this.results,
    required this.onAddFood,
    this.onEditFood,
    this.onAddAll,
    this.completedIndices,
    this.onMarkComplete,
    this.overlayDurationMs = 350,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    if (results.foods.isEmpty) {
      return Container(
        margin: EdgeInsets.all(3.w),
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'no_food',
              color: colors.onSurfaceVariant,
              size: 12.w,
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Nenhum alimento detectado',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              'Tente tirar uma foto mais próxima do alimento',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'psychology',
                  color: colors.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Alimentos Detectados',
                    style: textTheme.titleLarge,
                  ),
                ),
                if (onAddAll != null && results.foods.length > 1)
                  OutlinedButton(
                    onPressed: () => onAddAll!(results.foods),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                      side: BorderSide(color: colors.primary, width: 1),
                      foregroundColor: colors.primary,
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'playlist_add_check',
                          color: colors.primary,
                          size: 4.5.w,
                        ),
                        SizedBox(width: 1.w),
                        Text('Selecionar e adicionar'),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Foods list with indices
          ...results.foods.asMap().entries.map((e) {
            final idx = e.key;
            final food = e.value;
            final isCompleted = completedIndices?.contains(idx) ?? false;
            return _buildFoodCard(
              context,
              idx,
              food,
              isCompleted,
              colors,
              semantics,
              textTheme,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFoodCard(
    BuildContext context,
    int index,
    DetectedFood food,
    bool isCompleted,
    ColorScheme colors,
    AppSemanticColors semantics,
    TextTheme textTheme,
  ) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Food name and confidence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: textTheme.titleMedium,
                    ),
                    Text(
                      food.portionSize,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(food.confidence, colors, semantics)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'verified',
                      color: _getConfidenceColor(
                          food.confidence, colors, semantics),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${(food.confidence * 100).toInt()}%',
                      style: textTheme.bodySmall?.copyWith(
                        color: _getConfidenceColor(
                            food.confidence, colors, semantics),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Nutrition info
          Row(
            children: [
              Expanded(
                child: _buildNutrientInfo(
                  context,
                  label: 'Calorias',
                  value: '${food.calories}',
                  unit: 'kcal',
                  color: semantics.warning,
                ),
              ),
              Expanded(
                child: _buildNutrientInfo(
                  context,
                  label: 'Carboidratos',
                  value: '${food.carbs.toStringAsFixed(1)}',
                  unit: 'g',
                  color: colors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          Row(
            children: [
              Expanded(
                child: _buildNutrientInfo(
                  context,
                  label: 'Proteínas',
                  value: '${food.protein.toStringAsFixed(1)}',
                  unit: 'g',
                  color: semantics.success,
                ),
              ),
              Expanded(
                child: _buildNutrientInfo(
                  context,
                  label: 'Gorduras',
                  value: '${food.fat.toStringAsFixed(1)}',
                  unit: 'g',
                  color: colors.error,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Primary: Confirm and register
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (onMarkComplete != null) onMarkComplete!(index);
                onAddFood(food);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 2.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: colors.onPrimary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Confirmar e registrar',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (onEditFood != null) ...[
            SizedBox(height: 1.2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onEditFood!(food),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.3.h),
                  side: BorderSide(color: colors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: colors.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'edit',
                      color: colors.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Adicionar ou editar',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
            ],
          ),
        ),
        // Overlay de confirmação rápida com animação
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: overlayDurationMs),
              curve: Curves.easeIn,
              opacity: isCompleted ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: Duration(milliseconds: overlayDurationMs),
                curve: Curves.easeOut,
                scale: isCompleted ? 1.0 : 0.98,
                child: Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: semantics.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: semantics.success.withValues(alpha: 0.3), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: semantics.success, size: 28),
                      SizedBox(width: 8),
                      Text('Adicionado!', style: textTheme.titleMedium?.copyWith(color: semantics.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientInfo(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          RichText(
            text: TextSpan(
              text: value,
              style: textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(
    double confidence,
    ColorScheme colors,
    AppSemanticColors semantics,
  ) {
    if (confidence >= 0.8) return semantics.success;
    if (confidence >= 0.6) return semantics.warning;
    return colors.error;
  }
}
