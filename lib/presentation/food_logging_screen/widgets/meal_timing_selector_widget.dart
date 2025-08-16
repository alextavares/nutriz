import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MealTimingSelectorWidget extends StatelessWidget {
  final String selectedMealTime;
  final Function(String) onMealTimeChanged;
  final Widget? trailing; // optional trailing widget (e.g., summary)

  const MealTimingSelectorWidget({
    Key? key,
    required this.selectedMealTime,
    required this.onMealTimeChanged,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealTimes = [
      {
        'id': 'breakfast',
        'name': 'Café da Manhã',
        'icon': 'coffee',
        'emoji': '☕'
      },
      {'id': 'lunch', 'name': 'Almoço', 'icon': 'restaurant', 'emoji': '🍽️'},
      {
        'id': 'dinner',
        'name': 'Jantar',
        'icon': 'dinner_dining',
        'emoji': '🍽️'
      },
      {'id': 'snack', 'name': 'Lanche', 'icon': 'cookie', 'emoji': '🍪'},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Refeição',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profile,
                      arguments: {'scrollTo': 'ui_prefs'});
                },
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Chips'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.activeBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: mealTimes.map((meal) {
                final isSelected = selectedMealTime == meal['id'];
                return GestureDetector(
                  onTap: () => onMealTimeChanged(meal['id'] as String),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.activeBlue.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.activeBlue.withValues(alpha: 0.2)
                                : AppTheme.darkTheme.colorScheme.outline
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              meal['emoji'] as String,
                              style: TextStyle(fontSize: 6.w),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            meal['name'] as String,
                            style: AppTheme.darkTheme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.activeBlue
                                  : AppTheme.darkTheme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.activeBlue,
                            size: 5.w,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
