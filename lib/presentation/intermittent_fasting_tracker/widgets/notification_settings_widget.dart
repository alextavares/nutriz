// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final bool notificationsEnabled;
  final TimeOfDay? startEatingTime;
  final TimeOfDay? stopEatingTime;
  final Function(bool) onNotificationToggle;
  final Function(TimeOfDay?) onStartTimeChanged;
  final Function(TimeOfDay?) onStopTimeChanged;

  const NotificationSettingsWidget({
    Key? key,
    required this.notificationsEnabled,
    this.startEatingTime,
    this.stopEatingTime,
    required this.onNotificationToggle,
    required this.onStartTimeChanged,
    required this.onStopTimeChanged,
  }) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (widget.startEatingTime ?? const TimeOfDay(hour: 12, minute: 0))
          : (widget.stopEatingTime ?? const TimeOfDay(hour: 20, minute: 0)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.secondaryBackgroundDark,
              hourMinuteTextColor: AppTheme.textPrimary,
              dayPeriodTextColor: AppTheme.textPrimary,
              dialHandColor: AppTheme.activeBlue,
              dialBackgroundColor: AppTheme.primaryBackgroundDark,
              hourMinuteColor: AppTheme.dividerGray.withValues(alpha: 0.3),
              dayPeriodColor: AppTheme.activeBlue.withValues(alpha: 0.2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartTime) {
        widget.onStartTimeChanged(picked);
      } else {
        widget.onStopTimeChanged(picked);
      }
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.activeBlue,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Lembretes',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Notification Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ativar Lembretes',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Receba notificações para iniciar e parar o jejum',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.notificationsEnabled,
                onChanged: widget.onNotificationToggle,
                activeColor: AppTheme.activeBlue,
                inactiveThumbColor: AppTheme.textSecondary,
                inactiveTrackColor: AppTheme.dividerGray,
              ),
            ],
          ),

          if (widget.notificationsEnabled) ...[
            SizedBox(height: 3.h),

            // Time Settings
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    title: 'Início da Alimentação',
                    time: widget.startEatingTime,
                    icon: 'restaurant',
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildTimeSelector(
                    title: 'Fim da Alimentação',
                    time: widget.stopEatingTime,
                    icon: 'no_meals',
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Notification Types
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.activeBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.activeBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Lembrete',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.activeBlue,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Horário de iniciar/parar jejum',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'trending_up',
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Progresso e conquistas',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector({
    required String title,
    required TimeOfDay? time,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryBackgroundDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.dividerGray.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              _formatTime(time),
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: time != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
