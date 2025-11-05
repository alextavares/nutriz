import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

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
  static const double _kDelayLeft = 0.03; // ~27ms
  static const double _kDelayCenter = 0.06; // ~54ms
  static const double _kDelayRight = 0.09; // ~81ms

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
    String _fmtInt(int v) {
      final locale = Localizations.localeOf(context).toString();
      return NumberFormat.decimalPattern(locale).format(v);
    }

    String _tConsumed() {
      return AppLocalizations.of(context)!.eaten;
    }

    String _tBurned() {
      return AppLocalizations.of(context)!.burned;
    }

    String _tRemaining(bool exceeded) {
      if (exceeded) return AppLocalizations.of(context)!.overGoal;
      return AppLocalizations.of(context)!.remaining;
    }

    final colorScheme = context.colors;
    final textTheme = context.textStyles;

    Widget sideStat({
      required String label,
      required int value,
      required Color color,
      required TextAlign align,
      double delayFrac = 0.0,
    }) {
      final w = MediaQuery.of(context).size.width;
      // Responsive number size similar to YAZIO side stats
      final double numFs = w < 360 ? 14.0 : 16.0;
      final double labFs = w < 360 ? 12.0 : 13.0;
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
                  _fmtInt(0),
                  textAlign: align,
                  style: textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: numFs,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }
              final p = (val / value).clamp(0.0, 1.0);
              final delayed =
                  p <= delayFrac ? 0.0 : (p - delayFrac) / (1.0 - delayFrac);
              final eased = _kAnimCurve.transform(delayed);
              final shown = (value * eased).toInt();
              return Text(
                _fmtInt(shown),
                textAlign: align,
                style: textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
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
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: labFs + 3.0,
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
            final int baseRemaining =
                exceeded ? -widget.remainingCalories : widget.remainingCalories;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Garantir altura consistente entre colunas laterais e anel sem IntrinsicHeight
                LayoutBuilder(builder: (context, rowConstraints) {
                  final totalW = rowConstraints.maxWidth;
                  const gap = 16.0; // espaçamento fixo entre colunas e anel
                  // Dimensão alvo do anel central como fração do total, responsivo
                  // YAZIO-like: anel central um pouco maior no cartão
                  final double ringTarget = totalW * 0.52; // antes 0.50
                  const double minRing = 110.0;
                  // limite superior inicialmente assume sides mínimos de 64px cada
                  double maxRing =
                      (totalW - (gap * 2) - (64.0 * 2)).clamp(90.0, totalW);
                  double ringW = ringTarget.clamp(minRing, maxRing);
                  double sideW = ((totalW - ringW) / 2) - gap;
                  // Garantir largura mínima das colunas laterais
                  if (sideW < 64.0) {
                    sideW = 64.0;
                    ringW =
                        (totalW - (sideW * 2) - (gap * 2)).clamp(90.0, totalW);
                  }

                  Widget ringBox = SizedBox(
                    width: ringW,
                    height: ringW,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        consumedCalories: widget.consumedCalories,
                        totalCalories: widget.totalCalories,
                        animationValue: _animation.value,
                        backgroundColor:
                            colorScheme.outlineVariant.withValues(alpha: 0.40),
                        progressColor: colorScheme.primary,
                        exceededColor: colorScheme.error,
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
                                  tween: Tween<double>(
                                      begin: 0, end: baseRemaining.toDouble()),
                                  duration: _kAnimDuration,
                                  curve: Curves.linear,
                                  builder: (context, val, _) {
                                    if (baseRemaining <= 0) {
                                      return Text(
                                        exceeded
                                            ? '-${_fmtInt(0)}'
                                            : _fmtInt(0),
                                        style: GoogleFonts.manrope(
                                          color: exceeded
                                              ? colorScheme.error
                                              : AppColorsDS.primaryButton,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 40,
                                          letterSpacing: -0.6,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      );
                                    }
                                    final p =
                                        (val / baseRemaining).clamp(0.0, 1.0);
                                    final delayed = p <= _kDelayCenter
                                        ? 0.0
                                        : (p - _kDelayCenter) /
                                            (1.0 - _kDelayCenter);
                                    final eased =
                                        _kAnimCurve.transform(delayed);
                                    final shown =
                                        (baseRemaining * eased).toInt();
                                    return Text(
                                      exceeded
                                          ? '-${_fmtInt(shown)}'
                                          : _fmtInt(shown),
                                      style: GoogleFonts.manrope(
                                        color: exceeded
                                            ? colorScheme.error
                                            : AppColorsDS.primaryButton,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 40,
                                        letterSpacing: -0.6,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                // YAZIO não exibe a unidade ao lado do número central
                              ],
                            ),
                            Builder(builder: (context) {
                              return Text(
                                _tRemaining(exceeded),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  fontSize: 15.0,
                                  height: 1.0,
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
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: sideStat(
                              label: _tConsumed(),
                              value: widget.consumedCalories,
                              color: colorScheme.onSurface,
                              align: TextAlign.center,
                              delayFrac: _kDelayLeft,
                            ),
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: ringW,
                          height: ringW,
                          child: ringBox,
                        ),
                        const SizedBox(width: gap),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: sideStat(
                              label: _tBurned(),
                              value: widget.spentCalories,
                              color: colorScheme.onSurface,
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
  final Color backgroundColor;
  final Color progressColor;
  final Color exceededColor;

  CircularProgressPainter({
    required this.consumedCalories,
    required this.totalCalories,
    required this.animationValue,
    required this.backgroundColor,
    required this.progressColor,
    required this.exceededColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Separar espessuras: fundo fino (2px) e arco mais espesso (YAZIO-like)
    final double bgStroke = 6.0;
    final double ringStroke = (size.width * 0.14).clamp(12.0, 26.0);
    final radius = size.width / 2 - ringStroke;

    // Background circle (fino)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = bgStroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc (espesso)
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..strokeCap = StrokeCap.round;

    final raw = (totalCalories <= 0) ? 0.0 : (consumedCalories / totalCalories);
    final exceeded = raw > 1.0;
    final progress = raw.clamp(0.0, 1.0);
    // YAZIO-like: arco em cor única (primária). Vermelho apenas quando excedido
    progressPaint.color = exceeded ? exceededColor : progressColor;
    final sweepAngle = progress * 2 * math.pi * animationValue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2, // Start from bottom
      sweepAngle,
      false,
      progressPaint,
    );

    // Marcador (bolinha) na ponta do progresso — típico do YAZIO
    final double headAngle =
        (math.pi / 2) + (sweepAngle <= 0 ? 0.0001 : sweepAngle);
    final Offset head = Offset(
      center.dx + radius * math.cos(headAngle),
      center.dy + radius * math.sin(headAngle),
    );
    final double dotR = math.max(2.0, ringStroke * 0.20);
    final Paint dotPaint = Paint()
      ..color = exceeded ? exceededColor : progressColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(head, dotR, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
