import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class WeeklyProgressWidget extends StatelessWidget {
  final int currentWeek;
  final Function(int) onWeekChanged;
  final List<int> weeklyCalories; // length 7
  final int dailyGoal;
  final void Function(int index)? onDayTap;
  final List<int> weeklyWater; // length 7
  final int waterGoalMl;

  const WeeklyProgressWidget({
    super.key,
    required this.currentWeek,
    required this.onWeekChanged,
    this.weeklyCalories = const [0, 0, 0, 0, 0, 0, 0],
    this.dailyGoal = 2000,
    this.onDayTap,
    this.weeklyWater = const [0, 0, 0, 0, 0, 0, 0],
    this.waterGoalMl = 2000,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.4.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso Semanal',
            style: textStyles.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onWeekChanged(currentWeek - 1),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back_ios',
                    color: colors.onSurfaceVariant,
                    size: 16,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  'Semana $currentWeek',
                  style: textStyles.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onWeekChanged(currentWeek + 1),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: colors.onSurfaceVariant,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildBars(context),
          SizedBox(height: 1.2.h),
          _buildWaterBars(context),
        ],
      ),
    );
  }

  Widget _buildBars(BuildContext context) {
    final labels = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final maxVal =
        [dailyGoal, ...weeklyCalories].reduce((a, b) => a > b ? a : b);
    final goalRatio = maxVal == 0 ? 0.0 : (dailyGoal / maxVal).clamp(0.0, 1.0);
    final double barHeight = 8.h;
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Column(
      children: [
        SizedBox(
          height: barHeight,
          child: Stack(
            children: [
              // Goal line across all bars
              if (goalRatio > 0)
                Positioned(
                  top: (barHeight * (1 - goalRatio)).clamp(0, barHeight - 1),
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color:
                        colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final val =
                        weeklyCalories.length > i ? weeklyCalories[i] : 0;
                    final ratio = maxVal == 0 ? 0.0 : (val / maxVal);
                    return Expanded(
                      child: GestureDetector(
                        onTap: onDayTap != null ? () => onDayTap!(i) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: (barHeight * ratio).clamp(0, barHeight),
                          margin: EdgeInsets.symmetric(horizontal: 0.6.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                colors.primary.withValues(alpha: 0.45),
                                colors.primary.withValues(alpha: 0.2),
                              ],
                            ),
                            boxShadow: const [],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.6.h),
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  labels[i],
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWaterBars(BuildContext context) {
    final labels = const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final int cap = waterGoalMl <= 0 ? 2000 : waterGoalMl;
    final double barHeight = 6.h;
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Column(
      children: [
        SizedBox(
          height: barHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final val = weeklyWater.length > i ? weeklyWater[i] : 0;
                final ratio = (val / cap).clamp(0.0, 1.0);
                return Expanded(
                  child: GestureDetector(
                    onTap: onDayTap != null ? () => onDayTap!(i) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      height: (barHeight * ratio),
                      margin: EdgeInsets.symmetric(horizontal: 0.6.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            colors.primary.withValues(alpha: 0.4),
                            colors.primary.withValues(alpha: 0.16),
                          ],
                        ),
                        boxShadow: const [],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 0.4.h),
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  labels[i],
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
