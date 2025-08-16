import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FastingTimerWidget extends StatefulWidget {
  final bool isFasting;
  final Duration remainingTime;
  final VoidCallback onTimerComplete;

  const FastingTimerWidget({
    Key? key,
    required this.isFasting,
    required this.remainingTime,
    required this.onTimerComplete,
  }) : super(key: key);

  @override
  State<FastingTimerWidget> createState() => _FastingTimerWidgetState();
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
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.isFasting
        ? (_currentRemainingTime.inSeconds / widget.remainingTime.inSeconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: 70.w,
      height: 70.w,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isFasting ? _pulseAnimation.value : 1.0,
            child: CustomPaint(
              painter: _CircularTimerPainter(
                progress: progress,
                isFasting: widget.isFasting,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isFasting
                          ? _formatTime(_currentRemainingTime)
                          : '00:00',
                      style:
                          AppTheme.darkTheme.textTheme.displaySmall?.copyWith(
                        color: widget.isFasting
                            ? AppTheme.activeBlue
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 32.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.isFasting ? 'Restante' : 'Jejum Parado',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
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

  _CircularTimerPainter({
    required this.progress,
    required this.isFasting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppTheme.dividerGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (isFasting && progress > 0) {
      // Progress arc
      final progressPaint = Paint()
        ..color = AppTheme.activeBlue
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
