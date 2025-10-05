// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

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
    final theme = Theme.of(context);
    final colors = context.colors;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (widget.startEatingTime ?? const TimeOfDay(hour: 12, minute: 0))
          : (widget.stopEatingTime ?? const TimeOfDay(hour: 20, minute: 0)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme.copyWith(
            timePickerTheme: theme.timePickerTheme.copyWith(
              backgroundColor: colors.surfaceContainerHigh,
              hourMinuteTextColor: colors.onSurface,
              dayPeriodTextColor: colors.onSurface,
              dialHandColor: colors.primary,
              dialBackgroundColor: colors.surfaceContainerHighest,
              hourMinuteColor: colors.outlineVariant.withValues(alpha: 0.3),
              dayPeriodColor: colors.primary.withValues(alpha: 0.2),
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
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: colors.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Lembretes',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
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
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Receba notificações para iniciar e parar o jejum',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.notificationsEnabled,
                onChanged: widget.onNotificationToggle,
                activeColor: colors.primary,
                inactiveThumbColor: colors.onSurfaceVariant,
                inactiveTrackColor: colors.outlineVariant,
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
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildTimeSelector(
                    title: 'Fim da Alimentação',
                    time: widget.stopEatingTime,
                    icon: 'no_meals',
                    onTap: () => _selectTime(context, false),
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Scheduled summary hint (includes mute warning inside)
            _scheduledHint(colors, textTheme),

            // Mute controls
            _muteControls(colors, semantics, textTheme),

            // Notification Types
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de Lembrete',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: colors.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Horário de iniciar/parar jejum',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
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
                        color: colors.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Progresso e conquistas',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
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
    required ColorScheme colors,
    required TextTheme textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: colors.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: LayoutBuilder(builder: (context, c) {
                    final w = c.maxWidth;
                    // Em telas muito estreitas, use rótulos compactos para evitar truncar
                    String compact(String t) {
                      final lower = t.toLowerCase();
                      if (w < 120) {
                        if (lower.startsWith('início')) return 'Início';
                        if (lower.startsWith('fim')) return 'Fim';
                      }
                      return t;
                    }

                    return Text(
                      compact(title),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                      maxLines: w < 140 ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              _formatTime(time),
              style: textTheme.titleMedium?.copyWith(
                color:
                    time != null ? colors.onSurface : colors.onSurfaceVariant,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduledHint(
    ColorScheme colors,
    TextTheme textTheme,
  ) {
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
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: colors.primary,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Agendado diariamente',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
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
                  'Romper: $start • Iniciar: $stop' +
                      (tz.isNotEmpty ? '  •  Fuso: $tz' : ''),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
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

  Widget _muteControls(
    ColorScheme colors,
    AppSemanticColors semantics,
    TextTheme textTheme,
  ) {
    final muted =
        widget.muteUntil != null && DateTime.now().isBefore(widget.muteUntil!);
    String untilLabel = '';
    if (muted) {
      final u = widget.muteUntil!;
      String two(int v) => v.toString().padLeft(2, '0');
      untilLabel =
          '${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
    }
    return Row(
      children: [
        if (!muted) ...[
          ElevatedButton.icon(
            onPressed: widget.onMute24h,
            icon: const Icon(Icons.notifications_off_outlined, size: 16),
            label: const Text('Silenciar 24h'),
            style: ElevatedButton.styleFrom(
              backgroundColor: semantics.warning,
              foregroundColor: semantics.onWarning,
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
              foregroundColor: colors.onSurfaceVariant,
              side: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.6)),
            ),
          ),
        ] else ...[
          Expanded(
            child: Text(
              'Silenciado até $untilLabel',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
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
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary.withValues(alpha: 0.6)),
            ),
          ),
        ]
      ],
    );
  }
}






