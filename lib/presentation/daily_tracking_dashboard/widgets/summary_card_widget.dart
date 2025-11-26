import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../theme/design_tokens.dart';

/// Summary Card Widget - Estilo Yazio
/// Combina círculo de calorias + barras de macros horizontais
class SummaryCardWidget extends StatefulWidget {
  final int consumedCalories;
  final int totalCalories;
  final int burnedCalories;
  final int carbsConsumed;
  final int carbsGoal;
  final int proteinConsumed;
  final int proteinGoal;
  final int fatConsumed;
  final int fatGoal;
  final VoidCallback? onTap;
  final VoidCallback? onDetailsTap;

  const SummaryCardWidget({
    super.key,
    required this.consumedCalories,
    required this.totalCalories,
    this.burnedCalories = 0,
    required this.carbsConsumed,
    required this.carbsGoal,
    required this.proteinConsumed,
    required this.proteinGoal,
    required this.fatConsumed,
    required this.fatGoal,
    this.onTap,
    this.onDetailsTap,
  });

  @override
  State<SummaryCardWidget> createState() => _SummaryCardWidgetState();
}

class _SummaryCardWidgetState extends State<SummaryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Cores dos macros (estilo Yazio)
  static const Color _carbsColor = Color(0xFFFFB74D);   // Laranja
  static const Color _proteinColor = Color(0xFF81C784); // Verde
  static const Color _fatColor = Color(0xFFE57373);     // Vermelho/Rosa

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final remaining = widget.totalCalories - widget.consumedCalories + widget.burnedCalories;
    final progress = widget.totalCalories > 0
        ? (widget.consumedCalories / widget.totalCalories).clamp(0.0, 1.0)
        : 0.0;
    final exceeded = remaining < 0;

    final trackColor = isDark
        ? colors.surfaceContainerHighest
        : const Color(0xFFE8E8E8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: isDark ? null : const [AppShadows.card],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Header: Summary + Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDetailsTap,
                      child: Text(
                        'Details',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),

                // Linha principal: Eaten - Circle - Burned
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Eaten (Comido)
                    _buildSideStat(
                      value: widget.consumedCalories,
                      label: 'Eaten',
                      colors: colors,
                    ),

                    // Círculo central
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return _buildCaloriesCircle(
                          remaining: remaining,
                          progress: progress * _animation.value,
                          exceeded: exceeded,
                          trackColor: trackColor,
                          colors: colors,
                        );
                      },
                    ),

                    // Burned (Queimado)
                    _buildSideStat(
                      value: widget.burnedCalories,
                      label: 'Burned',
                      colors: colors,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Macros com barras horizontais (estilo Yazio)
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroBar(
                        label: 'Carbs',
                        current: widget.carbsConsumed,
                        goal: widget.carbsGoal,
                        color: _carbsColor,
                        trackColor: trackColor,
                        colors: colors,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildMacroBar(
                        label: 'Protein',
                        current: widget.proteinConsumed,
                        goal: widget.proteinGoal,
                        color: _proteinColor,
                        trackColor: trackColor,
                        colors: colors,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildMacroBar(
                        label: 'Fat',
                        current: widget.fatConsumed,
                        goal: widget.fatGoal,
                        color: _fatColor,
                        trackColor: trackColor,
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideStat({
    required int value,
    required String label,
    required ColorScheme colors,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesCircle({
    required int remaining,
    required double progress,
    required bool exceeded,
    required Color trackColor,
    required ColorScheme colors,
  }) {
    final displayValue = exceeded ? -remaining : remaining;
    final progressColor = exceeded ? colors.error : colors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: _CaloriesRingPainter(
          progress: progress,
          trackColor: trackColor,
          progressColor: progressColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exceeded ? '-$displayValue' : '$displayValue',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: exceeded ? colors.error : colors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Remaining',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBar({
    required String label,
    required int current,
    required int goal,
    required Color color,
    required Color trackColor,
    required ColorScheme colors,
  }) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // Barra de progresso
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Progresso
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Bolinha indicadora (estilo Yazio)
                  Positioned(
                    left: (constraints.maxWidth * progress - 4).clamp(0, constraints.maxWidth - 8),
                    top: -1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        // Valores
        Text(
          '$current / ${goal}g',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Painter para o anel de calorias
class _CaloriesRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _CaloriesRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    
    // Track (fundo)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progresso
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = progress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Começa do topo
      sweepAngle,
      false,
      progressPaint,
    );

    // Bolinha na ponta do progresso
    if (progress > 0) {
      final angle = -math.pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final dotPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CaloriesRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
