import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TodaysMealsList extends StatelessWidget {
  final List<Map<String, dynamic>> meals;

  const TodaysMealsList({
    super.key,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _buildMealCard(context, meal);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant,
            color: AppTheme.textSecondary,
            size: 8.w,
          ),

          SizedBox(height: 2.h),

          Text(
            'Nenhuma refeição registrada',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            'Adicione sua primeira refeição do dia',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.foodLogging);
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Refeição'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.activeBlue,
              foregroundColor: AppTheme.textPrimary,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final theme = Theme.of(context);
    final isCompleted = meal['completed'] ?? false;
    final mealType = meal['type'] as String;
    final mealTitle = meal['title'] as String;
    final calories = meal['calories'] as int;
    final time = meal['time'] as String;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Meal Icon
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _getMealTypeColor(mealType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMealTypeIcon(mealType),
              color: _getMealTypeColor(mealType),
              size: 6.w,
            ),
          ),

          SizedBox(width: 4.w),

          // Meal Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getMealTypeLabel(mealType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 0.5.h),

                Text(
                  mealTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 0.5.h),

                Text(
                  '$calories kcal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warningAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 3.w),

          // Completion Status
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.successGreen
                  : AppTheme.dividerGray.withValues(alpha: 0.3),
              border: Border.all(
                color: isCompleted
                    ? AppTheme.successGreen
                    : AppTheme.dividerGray,
                width: 2,
              ),
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    color: AppTheme.textPrimary,
                    size: 4.w,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MdiIcons.coffee;
      case 'lunch':
        return MdiIcons.foodForkDrink;
      case 'dinner':
        return MdiIcons.food;
      case 'snack':
        return MdiIcons.cookie;
      default:
        return MdiIcons.food;
    }
  }

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return AppTheme.warningAmber;
      case 'lunch':
        return AppTheme.activeBlue;
      case 'dinner':
        return AppTheme.premiumGold;
      case 'snack':
        return AppTheme.successGreen;
      default:
        return AppTheme.activeBlue;
    }
  }

  String _getMealTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return 'Café da Manhã';
      case 'lunch':
        return 'Almoço';
      case 'dinner':
        return 'Jantar';
      case 'snack':
        return 'Lanche';
      default:
        return 'Refeição';
    }
  }
}
