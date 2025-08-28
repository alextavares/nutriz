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
  static const Duration _kAnimDuration = Duration(milliseconds: 900);
  static const Curve _kAnimCurve = Curves.easeOut;
  // Stagger fractions for subtle cascade
  static const double _kDelayLeft = 0.03;   // ~27ms
  static const double _kDelayCenter = 0.06; // ~54ms
  static const double _kDelayRight = 0.09;  // ~81ms

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: _kAnimCurve),
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
    String _tConsumed() {
      final lang = Localizations.localeOf(context).languageCode.toLowerCase();
      return lang == 'pt' ? 'Consumidas' : 'Eaten';
    }
    String _tBurned() {
      final lang = Localizations.localeOf(context).languageCode.toLowerCase();
      return lang == 'pt' ? 'Queimadas' : 'Burned';
    }
    String _tRemaining(bool exceeded) {
      final lang = Localizations.localeOf(context).languageCode.toLowerCase();
      if (lang == 'pt') return exceeded ? 'Excedeu' : 'Restantes';
      return exceeded ? 'Exceeded' : 'Remaining';
    }

    Widget sideStat({
      required String label,
      required int value,
      required Color color,
      required TextAlign align,
      double delayFrac = 0.0,
    }) {
      final cs = Theme.of(context).colorScheme;
      final w = MediaQuery.of(context).size.width;
      // Responsive number size similar to YAZIO side stats
      final double numFs = w < 360 ? 14.0 : 16.0;
      final double labFs = w < 360 ? 10.0 : 12.0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align == TextAlign.right
            ? CrossAxisAlignment.end
            : (align == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start),
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(value),
            // Animate smoothly from 0 to the current value.
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: _kAnimDuration,
            // Use linear here; apply easing after delay mapping
            curve: Curves.linear,
            builder: (context, val, _) {
              if (value <= 0) {
                return Text(
                  '0',
                  textAlign: align,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: numFs,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }
              final p = (val / value).clamp(0.0, 1.0);
              final delayed = p <= delayFrac ? 0.0 : (p - delayFrac) / (1.0 - delayFrac);
              final eased = _kAnimCurve.transform(delayed);
              final shown = (value * eased).toInt();
              return Text(
                '$shown',
                textAlign: align,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: numFs,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: align,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: labFs,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        // Remove extra horizontal padding so side labels align to card edges
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1.w),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Ring animates via _animation; side numbers animate independently via TweenAnimationBuilder
            // Net remaining can be negative; display absolute when exceeded
            final exceeded = widget.remainingCalories <= 0;
            final int baseRemaining = exceeded
                ? -widget.remainingCalories
                : widget.remainingCalories;
            final cs = Theme.of(context).colorScheme;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Garantir altura consistente entre colunas laterais e anel sem IntrinsicHeight
                LayoutBuilder(builder: (context, rowConstraints) {
                    final totalW = rowConstraints.maxWidth;
                    const gap = 12.0; // espaçamento fixo entre colunas e anel
                    // Dimensão alvo do anel central como fração do total, responsivo
                    final double ringTarget = totalW * 0.44; // ajuste sutil para balancear
                    const double minRing = 110.0;
                    // limite superior inicialmente assume sides mínimos de 64px cada
                    double maxRing = (totalW - (gap * 2) - (64.0 * 2)).clamp(90.0, totalW);
                    double ringW = ringTarget.clamp(minRing, maxRing);
                    double sideW = ((totalW - ringW) / 2) - gap;
                    // Garantir largura mínima das colunas laterais
                    if (sideW < 64.0) {
                      sideW = 64.0;
                      ringW = (totalW - (sideW * 2) - (gap * 2)).clamp(90.0, totalW);
                    }

                    Widget ringBox = SizedBox(
                      width: ringW,
                      height: ringW,
                      child: CustomPaint(
                        painter: CircularProgressPainter(
                          consumedCalories: widget.consumedCalories,
                          totalCalories: widget.totalCalories,
                          animationValue: _animation.value,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TweenAnimationBuilder<double>(
                                key: ValueKey(baseRemaining),
                                tween: Tween<double>(begin: 0, end: baseRemaining.toDouble()),
                                duration: _kAnimDuration,
                                curve: Curves.linear,
                                builder: (context, val, _) {
                                  if (baseRemaining <= 0) {
                                    return Text(
                                      exceeded ? '-0' : '0',
                                      style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                                        color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16.sp,
                                        letterSpacing: -0.5,
                                      ),
                                    );
                                  }
                                  final p = (val / baseRemaining).clamp(0.0, 1.0);
                                  final delayed = p <= _kDelayCenter
                                      ? 0.0
                                      : (p - _kDelayCenter) / (1.0 - _kDelayCenter);
                                  final eased = _kAnimCurve.transform(delayed);
                                  final shown = (baseRemaining * eased).toInt();
                                  return Text(
                                    exceeded ? '-$shown' : '$shown',
                                    style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                                      color: exceeded ? AppTheme.errorRed : AppTheme.activeBlue,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16.sp,
                                      letterSpacing: -0.5,
                                    ),
                                  );
                                },
                                  ),
                                  const SizedBox(width: 6),
                                  Builder(builder: (context) {
                                    final cs = Theme.of(context).colorScheme;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        'kcal',
                                        style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              Builder(builder: (context) {
                                final cs = Theme.of(context).colorScheme;
                                return Text(
                                  _tRemaining(exceeded),
                                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                    fontSize: 11.0,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );

                    return ConstrainedBox(
                      constraints: BoxConstraints(minHeight: ringW),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: sideW,
                            // allow height to grow with larger text scale
                            child: Align(
                              alignment: Alignment.center,
                              child: sideStat(
                                label: _tConsumed(),
                                value: widget.consumedCalories,
                                color: AppTheme.warningAmber,
                                align: TextAlign.center,
                                delayFrac: _kDelayLeft,
                              ),
                            ),
                          ),
                          const SizedBox(width: gap),
                          Center(child: ringBox),
                          const SizedBox(width: gap),
                          SizedBox(
                            width: sideW,
                            // allow height to grow with larger text scale
                            child: Align(
                              alignment: Alignment.center,
                              child: sideStat(
                                label: _tBurned(),
                                value: widget.spentCalories,
                                color: AppTheme.successGreen,
                                align: TextAlign.center,
                                delayFrac: _kDelayRight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                SizedBox(height: 0.6.h),
                // Removed Total goal chip to avoid repetition under the ring
              ],
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
    final stroke = (size.width * 0.085).clamp(8.0, 16.0);
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
    // Gradient sweep resembling YAZIO's ring feel
    if (exceeded) {
      progressPaint.color = AppTheme.errorRed;
    } else {
      final rect = Rect.fromCircle(center: center, radius: radius);
      progressPaint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: [
          AppTheme.activeBlue,
          Color.lerp(AppTheme.activeBlue, AppTheme.successGreen, 0.5) ?? AppTheme.activeBlue,
          AppTheme.successGreen,
        ],
        stops: const [0.0, 0.6, 1.0],
        tileMode: TileMode.clamp,
      ).createShader(rect);
    }
    final sweepAngle = progress * 2 * math.pi * animationValue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Subtle tick marks at 25%, 50%, 75%
    final tickPaint = Paint()
      ..color = AppTheme.dividerGray.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, stroke * 0.18)
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (int i = 1; i <= 3; i++) {
      final ang = -math.pi / 2 + (2 * math.pi) * (i / 4.0);
      // tiny arc segment centered at ang
      const seg = 0.015; // ~0.86°
      canvas.drawArc(rect, ang - seg / 2, seg, false, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
