import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';
import 'animated_card.dart';

/// A polished calorie ring similar to Yazio.
///
/// It visualizes the net progress (eaten - burned) against a goal with
/// a smooth, rounded ring, optional ticks, and a center label for
/// remaining calories.
class CalorieRing extends StatelessWidget {
  final double goal;
  final double eaten;
  final double burned;

  /// Size of the square canvas for the ring.
  final double size;

  /// Thickness of the main ring stroke.
  final double thickness;

  /// Degrees removed from the circle to create a top gap (visual polish).
  final double gapDegrees;

  /// Whether to animate the ring progress.
  final bool animate;

  /// Duration of the progress animation.
  final Duration duration;

  /// Show subtle tick marks along the track.
  final bool showTicks;

  /// How many ticks to draw (spread across the sweep excluding the gap).
  final int tickCount;

  const CalorieRing({
    super.key,
    required this.goal,
    required this.eaten,
    required this.burned,
    this.size = 160,
    this.thickness = 14,
    this.gapDegrees = 42,
    this.animate = true,
    this.duration = const Duration(milliseconds: 900),
    this.showTicks = true,
    this.tickCount = 24,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final goalSafe = goal <= 0 ? 1.0 : goal;
    final net = math.max(0.0, eaten - burned);
    final remaining = (goal - net).clamp(0.0, double.infinity);
    final progress = (net / goalSafe);
    final progressClamped = progress.clamp(0.0, 1.0).toDouble();
    final over = math.max(0.0, progress - 1.0);

    final ring = _AnimatedRing(
      size: size,
      thickness: thickness,
      gapDegrees: gapDegrees,
      progress: progressClamped,
      overProgress: over,
      duration: duration,
      animate: animate,
      showTicks: showTicks,
      tickCount: tickCount,
      trackColor: cs.surfaceContainerHighest,
      progressStart: cs.primary,
      progressEnd: cs.primary.withValues(alpha: 0.75),
      overColor: cs.error,
    );

    final nf = NumberFormat.decimalPattern();
    final remainingStr = nf.format(remaining.round());

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring,
          // Center labels - V3: texto mais marcante
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remainingStr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,  // Mais bold (era w700)
                      color: cs.onSurface,
                      fontSize: 28,  // Maior e mais marcante
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 2),  // Menor espaçamento
              Text(
                'Restante',  // Traduzido para português
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,  // Mais bold (era w600)
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedRing extends StatefulWidget {
  final double size;
  final double thickness;
  final double gapDegrees;
  final double progress; // 0..1
  final double overProgress; // >0 when over goal (0..inf)
  final Duration duration;
  final bool animate;
  final bool showTicks;
  final int tickCount;
  final Color trackColor;
  final Color progressStart;
  final Color progressEnd;
  final Color overColor;

  const _AnimatedRing({
    required this.size,
    required this.thickness,
    required this.gapDegrees,
    required this.progress,
    required this.overProgress,
    required this.duration,
    required this.animate,
    required this.showTicks,
    required this.tickCount,
    required this.trackColor,
    required this.progressStart,
    required this.progressEnd,
    required this.overColor,
  });

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _tween = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation after first frame so MediaQuery is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final media = MediaQuery.maybeOf(context);
      final reduceMotion = media?.accessibleNavigation ?? false;
      if (widget.animate && !reduceMotion) {
        _controller.forward();
      } else {
        _controller.value = 1.0;
        _tween = AlwaysStoppedAnimation(widget.progress);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _tween = Tween<double>(begin: _tween.value, end: widget.progress)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      if (widget.animate) {
        _controller
          ..duration = widget.duration
          ..forward(from: 0);
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = _tween.value.clamp(0.0, 1.0);
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(
            progress: p,
            overProgress: widget.overProgress,
            thickness: widget.thickness,
            gapRadians: widget.gapDegrees * math.pi / 180,
            trackColor: widget.trackColor,
            progressStart: widget.progressStart,
            progressEnd: widget.progressEnd,
            overColor: widget.overColor,
            showTicks: widget.showTicks,
            tickCount: widget.tickCount,
            tickColor: widget.trackColor.withValues(alpha: 0.7),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final double overProgress; // 0..inf
  final double thickness;
  final double gapRadians;
  final Color trackColor;
  final Color progressStart;
  final Color progressEnd;
  final Color overColor;
  final bool showTicks;
  final int tickCount;
  final Color tickColor;

  _RingPainter({
    required this.progress,
    required this.overProgress,
    required this.thickness,
    required this.gapRadians,
    required this.trackColor,
    required this.progressStart,
    required this.progressEnd,
    required this.overColor,
    required this.showTicks,
    required this.tickCount,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    // Open gap at the bottom: start from bottom + half-gap
    final start = math.pi / 2 + gapRadians / 2;
    final sweep = 2 * math.pi - gapRadians;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    // Track arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      trackPaint,
    );

    // Progress arc with gradient
    if (progress > 0) {
      final progPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [progressStart, progressEnd],
          transform: GradientRotation(start),
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * progress.clamp(0.0, 1.0),
        false,
        progPaint,
      );
    }

    // Over-goal arc (continues from the end), thin overlay in error color
    if (overProgress > 0) {
      final overPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = overColor.withValues(alpha: 0.9);

      final overSweep = sweep * math.min(overProgress, 1.0);
      final overStart = start + sweep * 1.0; // begins at end of track
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        overStart,
        overSweep,
        false,
        overPaint,
      );
    }

    // Start dot at the beginning of the ring (YAZIO-like)
    final startDot = Offset(
      center.dx + radius * math.cos(start),
      center.dy + radius * math.sin(start),
    );
    final Paint startDotPaint = Paint()
      ..color = progressStart
      ..style = PaintingStyle.fill;
    final double startDotR = math.max(2.0, thickness * 0.18);
    canvas.drawCircle(startDot, startDotR, startDotPaint);

    // Ticks (subtle) along the track
    if (showTicks && tickCount > 0) {
      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i <= tickCount; i++) {
        final t = i / tickCount;
        final a = start + sweep * t;
        final inner = Offset(
          center.dx + (radius - thickness * 0.35) * math.cos(a),
          center.dy + (radius - thickness * 0.35) * math.sin(a),
        );
        final outer = Offset(
          center.dx + (radius - thickness * 0.15) * math.cos(a),
          center.dy + (radius - thickness * 0.15) * math.sin(a),
        );
        canvas.drawLine(inner, outer, tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.overProgress != overProgress ||
        oldDelegate.thickness != thickness ||
        oldDelegate.gapRadians != gapRadians ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressStart != progressStart ||
        oldDelegate.progressEnd != progressEnd ||
        oldDelegate.overColor != overColor ||
        oldDelegate.showTicks != showTicks ||
        oldDelegate.tickCount != tickCount ||
        oldDelegate.tickColor != tickColor;
  }
}

/// A ready-to-use summary card that mirrors the Yazio top card
/// with Eaten (left), Remaining (center in ring), Burned (right).
class CalorieSummaryCard extends StatelessWidget {
  final double goal;
  final double eaten;
  final double burned;
  final VoidCallback? onTapDetails;

  const CalorieSummaryCard({
    super.key,
    required this.goal,
    required this.eaten,
    required this.burned,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final nf = NumberFormat.decimalPattern();
    return AnimatedCard(
      delay: 40,
      initialScale: 0.98,
      child: Card(
        elevation: Theme.of(context).brightness == Brightness.light ? 1 : 2,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Eaten • Remaining • Burned captions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metric(cs, label: 'Eaten', value: '${nf.format(eaten.round())} kcal', dotColor: Colors.orange),
                  GestureDetector(
                    onTap: onTapDetails,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Details',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  _metric(cs, label: 'Burned', value: '${nf.format(burned.round())} kcal', dotColor: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Ring
              CalorieRing(goal: goal, eaten: eaten, burned: burned, size: 180, thickness: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(ColorScheme cs, {required String label, required String value, required Color dotColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
