import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/design_tokens.dart';

class FastingTimerWidget extends StatefulWidget {
  final bool isFasting;
  final Duration remainingTime; // dynamic remaining
  final Duration totalDuration; // fixed total target
  final VoidCallback onTimerComplete;
  final double? size;
  final bool showSeconds;
  final Widget Function(
      BuildContext context, Duration remaining, bool isFasting)? centerBuilder;

  const FastingTimerWidget({
    Key? key,
    required this.isFasting,
    required this.remainingTime,
    required this.totalDuration,
    required this.onTimerComplete,
    this.size,
    this.showSeconds = false,
    this.centerBuilder,
  }) : super(key: key);

  @override
  State<FastingTimerWidget> createState() => _FastingTimerWidgetState();
}

/// High-level card that wraps FastingTimerWidget to match YAZIO-like layout.
/// Shows a status line, the circular timer, a large CTA and optional schedule.
class FastingTimerCard extends StatelessWidget {
  final bool isFasting;
  final Duration remainingTime;
  final Duration totalDuration;
  final VoidCallback onTimerComplete;
  final VoidCallback onPrimaryAction;
  final String? primaryActionLabel;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? plannedStartLabel;
  final bool showSeconds;
  final double? size;

  const FastingTimerCard({
    super.key,
    required this.isFasting,
    required this.remainingTime,
    required this.totalDuration,
    required this.onTimerComplete,
    required this.onPrimaryAction,
    this.primaryActionLabel,
    this.startAt,
    this.endAt,
    this.plannedStartLabel,
    this.showSeconds = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    TimeOfDay? start = startAt != null
        ? TimeOfDay(hour: startAt!.hour, minute: startAt!.minute)
        : null;
    TimeOfDay? end = endAt != null
        ? TimeOfDay(hour: endAt!.hour, minute: endAt!.minute)
        : null;

    return Card(
      elevation: Theme.of(context).brightness == Brightness.light ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status line
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isFasting
                    ? colors.primary.withValues(alpha: 0.08)
                    : colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isFasting
                      ? colors.primary.withValues(alpha: 0.3)
                      : colors.outlineVariant,
                ),
              ),
              child: Text(
                isFasting ? 'Jejum em andamento' : 'Pronto para iniciar um jejum',
                style: text.labelSmall?.copyWith(
                  color: isFasting ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            // Circular timer
            FastingTimerWidget(
              isFasting: isFasting,
              remainingTime: remainingTime,
              totalDuration: totalDuration,
              onTimerComplete: onTimerComplete,
              showSeconds: showSeconds,
              size: size,
              centerBuilder:
                  (BuildContext context, Duration remaining, bool fastingNow) {
                String two(int v) => v.toString().padLeft(2, '0');
                Duration safe = remaining.isNegative ? Duration.zero : remaining;
                final int h = safe.inHours;
                final int m = safe.inMinutes.remainder(60);
                final int s = safe.inSeconds.remainder(60);
                final String timeLabel = showSeconds
                    ? '${two(h)}:${two(m)}:${two(s)}'
                    : '${two(h)}:${two(m)}';

                if (fastingNow) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeLabel,
                        style: text.displaySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 32.sp,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        'Tempo restante',
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                } else {
                  final String title = 'Pronto para jejum';
                  final String subtitle =
                      plannedStartLabel ?? 'Toque em "Iniciar jejum" abaixo.';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: text.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            SizedBox(height: AppSpacing.xl),

            // Schedule rows
            if (start != null || end != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (start != null) ...[
                    Icon(Icons.play_circle,
                        size: 18, color: colors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Início ${fmt(start)}',
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (start != null && end != null)
                    const SizedBox(width: AppSpacing.xl),
                  if (end != null) ...[
                    Icon(Icons.flag_circle,
                        size: 18, color: colors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Fim ${fmt(end)}',
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]
                ],
              ),

            SizedBox(height: AppSpacing.xl),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPrimaryAction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    primaryActionLabel ??
                        (isFasting ? 'Encerrar jejum' : 'Iniciar jejum'),
                    style: text.labelLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FastingTimerWidgetState extends State<FastingTimerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _timer;
  Duration _currentRemainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentRemainingTime = widget.remainingTime;

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isFasting) {
      _startTimer();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FastingTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFasting != oldWidget.isFasting) {
      if (widget.isFasting) {
        _startTimer();
        _pulseController.repeat(reverse: true);
      } else {
        _stopTimer();
        _pulseController.stop();
      }
    }
    if (widget.remainingTime != oldWidget.remainingTime) {
      _currentRemainingTime = widget.remainingTime;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentRemainingTime.inSeconds > 0) {
        setState(() {
          _currentRemainingTime =
              Duration(seconds: _currentRemainingTime.inSeconds - 1);
        });
      } else {
        _stopTimer();
        widget.onTimerComplete();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hoursRaw = duration.inHours;
    final hours = hoursRaw >= 100 ? hoursRaw.toString() : twoDigits(hoursRaw);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    if (!widget.showSeconds) {
      return '$hours:$minutes';
    }
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.isFasting
        ? (_currentRemainingTime.inSeconds / widget.totalDuration.inSeconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final double side = widget.size ?? 70.w;
    return SizedBox(
      width: side,
      height: side,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isFasting ? _pulseAnimation.value : 1.0,
            child: CustomPaint(
              painter: _CircularTimerPainter(
                progress: progress,
                isFasting: widget.isFasting,
                backgroundColor: colors.outlineVariant.withValues(alpha: 0.4),
                progressColor: colors.primary,
              ),
              child: Center(
                child: widget.centerBuilder != null
                    ? widget.centerBuilder!(
                        context, _currentRemainingTime, widget.isFasting)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.isFasting
                                ? _formatTime(_currentRemainingTime)
                                : (widget.showSeconds ? '00:00:00' : '00:00'),
                            style: textTheme.displaySmall?.copyWith(
                              color: widget.isFasting
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              fontSize: 32.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            widget.isFasting ? 'Restante' : 'Jejum Parado',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final bool isFasting;
  final Color backgroundColor;
  final Color progressColor;

  _CircularTimerPainter({
    required this.progress,
    required this.isFasting,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (isFasting && progress > 0) {
      // Progress arc
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
