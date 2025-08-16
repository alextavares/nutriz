import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CircularProgressChartWidget extends StatefulWidget {
  final int consumedCalories;
  final int remainingCalories;
  final int spentCalories;
  final int totalCalories;
  final VoidCallback? onTap;
  final int? waterMl;

  const CircularProgressChartWidget({
    super.key,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.spentCalories,
    required this.totalCalories,
    this.onTap,
    this.waterMl,
  });

  @override
  State<CircularProgressChartWidget> createState() =>
      _CircularProgressChartWidgetState();
}

class _CircularProgressChartWidgetState
    extends State<CircularProgressChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 64.w,
        height: 64.w,
        padding: EdgeInsets.all(4.w),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: CircularProgressPainter(
                consumedCalories: widget.consumedCalories,
                totalCalories: widget.totalCalories,
                animationValue: _animation.value,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Consumed calories animated
                    Text(
                      '${(widget.consumedCalories * _animation.value).toInt()}',
                      style:
                          AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Consumidas',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Remaining vs exceeded with color cue
                    Builder(builder: (context) {
                      final exceeded = widget.remainingCalories <= 0;
                      final value = widget.remainingCalories;
                      return Column(
                        children: [
                          Text(
                            '$value',
                            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                              color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            exceeded ? 'Excedeu' : 'Restantes',
                            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }),
                    if (widget.waterMl != null) ...[
                      SizedBox(height: 0.6.h),
                      Text(
                        'Água: ${widget.waterMl}ml',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.activeBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final int consumedCalories;
  final int totalCalories;
  final double animationValue;

  CircularProgressPainter({
    required this.consumedCalories,
    required this.totalCalories,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = 16.0;
    final radius = size.width / 2 - stroke;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppTheme.dividerGray.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final raw = (totalCalories <= 0) ? 0.0 : (consumedCalories / totalCalories);
    final exceeded = raw > 1.0;
    final progress = raw.clamp(0.0, 1.0);
    final baseColor = exceeded
        ? AppTheme.errorRed
        : (Color.lerp(AppTheme.activeBlue, AppTheme.successGreen, progress) ?? AppTheme.activeBlue);
    progressPaint.color = baseColor;
    final sweepAngle = progress * 2 * math.pi * animationValue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // End-cap dot for nicer finish
    if (sweepAngle > 0) {
      final endAngle = -math.pi / 2 + sweepAngle;
      final end = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );
      final dot = Paint()
        ..color = baseColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(end, 6, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
