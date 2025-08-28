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
          SizedBox(height: 1.2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: mealTimes.map((meal) {
              final isSelected = selectedMealTime == meal['id'];
              return ChoiceChip(
                selected: isSelected,
                onSelected: (_) => onMealTimeChanged(meal['id'] as String),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(meal['emoji'] as String, style: TextStyle(fontSize: 14)),
                    SizedBox(width: 1.w),
                    Text(meal['name'] as String),
                  ],
                ),
                labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppTheme.activeBlue : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: AppTheme.secondaryBackgroundDark,
                selectedColor: AppTheme.activeBlue.withValues(alpha: 0.12),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: (isSelected
                            ? AppTheme.activeBlue
                            : AppTheme.dividerGray)
                        .withValues(alpha: 0.6),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
