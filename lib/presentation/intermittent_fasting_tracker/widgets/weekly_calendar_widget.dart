import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeeklyCalendarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final int currentStreak;
  final Function(DateTime) onDayTap;

  const WeeklyCalendarWidget({
    Key? key,
    required this.weeklyData,
    required this.currentStreak,
    required this.onDayTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calendário Semanal',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Builder(builder: (context) {
                final w = MediaQuery.of(context).size.width;
                final double fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
                final double iSize = w < 360 ? 14 : 16;
                final double padH = w < 360 ? 8 : 10;
                final double padV = w < 360 ? 6 : 8;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'local_fire_department',
                        color: AppTheme.warningAmber,
                        size: iSize,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$currentStreak dias',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningAmber,
                          fontSize: fs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final dayData = weeklyData.firstWhere(
                (data) => _isSameDay(data["date"] as DateTime, day),
                orElse: () => {"date": day, "completed": false, "duration": 0},
              );

              final isCompleted = dayData["completed"] as bool;
              final isToday = _isSameDay(day, now);
              final duration = dayData["duration"] as int;

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: LayoutBuilder(builder: (context, constraints) {
                  final w = MediaQuery.of(context).size.width;
                  final double nameFs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
                  final double dayFs = w < 340 ? 11.sp : (w < 380 ? 12.sp : 13.sp);
                  final double iconSize = w < 360 ? 18 : 20;
                  return Column(
                  children: [
                    Text(
                      _getDayName(day.weekday),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: nameFs,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successGreen.withValues(alpha: 0.2)
                            : isToday
                                ? AppTheme.activeBlue.withValues(alpha: 0.2)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCompleted
                              ? AppTheme.successGreen
                              : isToday
                                  ? AppTheme.activeBlue
                                  : AppTheme.dividerGray,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? CustomIconWidget(
                                iconName: 'local_fire_department',
                                color: AppTheme.warningAmber,
                                size: iconSize,
                              )
                            : Text(
                                '${day.day}',
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: isToday
                                      ? AppTheme.activeBlue
                                      : AppTheme.textPrimary,
                                  fontSize: dayFs,
                                  fontWeight: isToday
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                    ),
                    ),
                    if (isCompleted && duration > 0) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        '${duration}h',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.successGreen,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                  );
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }
}
