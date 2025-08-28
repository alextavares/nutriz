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
  final String? timezoneName;
  final DateTime? muteUntil;
  final VoidCallback? onMute24h;
  final VoidCallback? onUnmuteNow;
  final DateTime? fastEndAt;
  final VoidCallback? onMuteTomorrow;

  const NotificationSettingsWidget({
    Key? key,
    required this.notificationsEnabled,
    this.startEatingTime,
    this.stopEatingTime,
    required this.onNotificationToggle,
    required this.onStartTimeChanged,
    required this.onStopTimeChanged,
    this.timezoneName,
    this.muteUntil,
    this.onMute24h,
    this.onUnmuteNow,
    this.fastEndAt,
    this.onMuteTomorrow,
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

            // Scheduled summary hint (includes mute warning inside)
            _scheduledHint(),

            // Mute controls
            _muteControls(),

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

  Widget _scheduledHint() {
    final tz = widget.timezoneName ?? '';
    final start = _formatTime(widget.startEatingTime);
    final stop = _formatTime(widget.stopEatingTime);
    // endAt will be shown by parent below timer; keep daily here
    final endAt = widget.fastEndAt;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.activeBlue,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Agendado diariamente',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.6.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(builder: (context) {
                final w = MediaQuery.of(context).size.width;
                final double fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
                return Text(
                  'Romper: $start • Iniciar: $stop' + (tz.isNotEmpty ? '  •  Fuso: $tz' : ''),
                  style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: fs,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
              }),
              if (endAt != null) ...[
                SizedBox(height: 0.4.h),
                Builder(builder: (context) {
                  final w = MediaQuery.of(context).size.width;
                  final double fs = w < 340 ? 9.sp : (w < 380 ? 10.sp : 11.sp);
                  return Text(
                    () {
                      String two(int v) => v.toString().padLeft(2, '0');
                      final hh = two(endAt.hour);
                      final mm = two(endAt.minute);
                      return 'Término (notificação): $hh:$mm';
                    }(),
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: fs,
                    ),
                  );
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // (Mute warning moved inside _scheduledHint())

  Widget _muteControls() {
    final muted = widget.muteUntil != null && DateTime.now().isBefore(widget.muteUntil!);
    String untilLabel = '';
    if (muted) {
      final u = widget.muteUntil!;
      String two(int v) => v.toString().padLeft(2, '0');
      untilLabel = '${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
    }
    return Row(
      children: [
        if (!muted) ...[
          ElevatedButton.icon(
            onPressed: widget.onMute24h,
            icon: const Icon(Icons.notifications_off_outlined, size: 16),
            label: const Text('Silenciar 24h'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningAmber,
              foregroundColor: AppTheme.textPrimary,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: widget.onMuteTomorrow,
            icon: const Icon(Icons.snooze, size: 14),
            label: const Text('Até amanhã 08:00'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.dividerGray.withValues(alpha: 0.6)),
            ),
          ),
        ] else ...[
          Expanded(
            child: Text(
              'Silenciado até $untilLabel',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: widget.onUnmuteNow,
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Restaurar agora'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: AppTheme.activeBlue,
              side: BorderSide(color: AppTheme.activeBlue.withValues(alpha: 0.6)),
            ),
          ),
        ]
      ],
    );
  }

  void _onMuteUntilTomorrow() {
    // Bubble up via onMute24h with a special intent? We don't have a dedicated callback,
    // so reusing onMute24h would be confusing. Instead, emit a custom notification event
    // by using the provided onMute24h but with tomorrow 08:00 behavior handled by parent.
    // Since we can't pass parameters, we use an Inherited pattern or, simpler, Navigator pop and message.
    // For simplicity, show a local event using context's inherited widget is not available.
    // Thus, we'll use a method channel via scaffold messenger. Instead, we will call onMute24h
    // only if provided; parent will detect this via different button? Not possible.
    // So to implement, we transform this button to call a global static handler via NotificationService? Not ideal.
    // Simpler: we will use an event through a SnackBar? Can't pass data up.
    // Conclusion: Convert this widget to accept a separate callback onMuteTomorrow.
  }
}
