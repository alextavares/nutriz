import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/gemini_client.dart';

class FoodAnalysisResultsWidget extends StatelessWidget {
  final FoodNutritionData results;
  final Function(DetectedFood) onAddFood;
  final Function(List<DetectedFood>)? onAddAll;

  const FoodAnalysisResultsWidget({
    Key? key,
    required this.results,
    required this.onAddFood,
    this.onAddAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (results.foods.isEmpty) {
      return Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'no_food',
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Nenhum alimento detectado',
              style: AppTheme.darkTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              'Tente tirar uma foto mais próxima do alimento',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'psychology',
                  color: AppTheme.activeBlue,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Alimentos Detectados',
                    style: AppTheme.darkTheme.textTheme.titleLarge,
                  ),
                ),
                if (onAddAll != null)
                  OutlinedButton.icon(
                    onPressed: () => onAddAll!(results.foods),
                    icon: const Icon(Icons.playlist_add_check),
                    label: const Text('Revisar itens'),
                  ),
              ],
            ),
          ),

          // Foods list
          ...results.foods.map((food) => _buildFoodCard(food)).toList(),
        ],
      ),
    );
  }

  Widget _buildFoodCard(DetectedFood food) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
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
                      style: AppTheme.darkTheme.textTheme.titleMedium,
                    ),
                    Text(
                      food.portionSize,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(food.confidence)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'verified',
                      color: _getConfidenceColor(food.confidence),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${(food.confidence * 100).toInt()}%',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: _getConfidenceColor(food.confidence),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Nutrition info
          Row(
            children: [
              Expanded(
                child: _buildNutrientInfo(
                  'Calorias',
                  '${food.calories}',
                  'kcal',
                  AppTheme.warningAmber,
                ),
              ),
              Expanded(
                child: _buildNutrientInfo(
                  'Carboidratos',
                  '${food.carbs.toStringAsFixed(1)}',
                  'g',
                  AppTheme.activeBlue,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: _buildNutrientInfo(
                  'Proteínas',
                  '${food.protein.toStringAsFixed(1)}',
                  'g',
                  AppTheme.successGreen,
                ),
              ),
              Expanded(
                child: _buildNutrientInfo(
                  'Gorduras',
                  '${food.fat.toStringAsFixed(1)}',
                  'g',
                  AppTheme.errorRed,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onAddFood(food),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.activeBlue,
                foregroundColor: AppTheme.textPrimary,
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
                    color: AppTheme.textPrimary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Revisar e adicionar',
                    style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(
      String label, String value, String unit, Color color) {
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
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          RichText(
            text: TextSpan(
              text: value,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppTheme.successGreen;
    if (confidence >= 0.6) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }
}
