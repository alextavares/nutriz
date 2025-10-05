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
      { 'id': 'breakfast', 'name': 'Café da manhã', 'icon': 'breakfast_dining' },
      { 'id': 'lunch',     'name': 'Almoço',          'icon': 'restaurant'       },
      { 'id': 'snack',     'name': 'Lanche',          'icon': 'lunch_dining'     },
      { 'id': 'dinner',    'name': 'Jantar',          'icon': 'dinner_dining'    },
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
                label: const Text('Preferências'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.activeBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),

          LayoutBuilder(
            builder: (context, constraints) {
              final totalW = constraints.maxWidth;
              const columns = 2;
              final segW = totalW / columns;
              final bool compact = segW < 170;
              final segH = (totalW / columns) < 170 ? 44.0 : 48.0;
              final controlH = segH * 2 + 8.0; // includes pill margins
              final idx = mealTimes.indexWhere((m) => m['id'] == selectedMealTime);
              final selectedIndex = idx >= 0 ? idx : 0;
              final row = selectedIndex ~/ columns;
              final col = selectedIndex % columns;
              const duration = Duration(milliseconds: 180);
              return Container(
                height: controlH,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackgroundDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      left: col * segW,
                      top: row * segH,
                      width: segW,
                      height: segH,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.activeBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                for (final i in [0, 1])
                                  Expanded(
                                    child: _MealSeg(
                                      meal: mealTimes[i],
                                      isSelected: selectedIndex == i,
                                      onTap: () => onMealTimeChanged(mealTimes[i]['id'] as String),
                                      compact: compact,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                for (final i in [2, 3])
                                  Expanded(
                                    child: _MealSeg(
                                      meal: mealTimes[i],
                                      isSelected: selectedIndex == i,
                                      onTap: () => onMealTimeChanged(mealTimes[i]['id'] as String),
                                      compact: compact,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _MealSeg extends StatelessWidget {
  final Map<String, Object?> meal;
  final bool isSelected;
  final bool compact;
  final VoidCallback onTap;
  const _MealSeg({required this.meal, required this.isSelected, required this.onTap, required this.compact});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomIconWidget(
              iconName: meal['icon'] as String,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: compact ? 16 : 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                meal['name'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 12 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
