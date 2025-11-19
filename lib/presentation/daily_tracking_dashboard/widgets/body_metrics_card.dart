import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/app_export.dart';
import '../../../core/haptic_helper.dart';
import '../../../services/analytics_service.dart';
import '../../../l10n/generated/app_localizations.dart';

class BodyMetricsCard extends StatelessWidget {
  final VoidCallback onAddMetrics;
  final double? currentWeight;
  final double? goalWeight;
  final double? lastWeight;
  final String weightUnit;
  final bool hasEntry;
  final List<double>? weeklyWeights; // ordered oldest -> newest
  final double? weeklyChange; // last - first over the week
  final void Function(double delta)? onAdjustWeight;
  final int? bpSys;
  final int? bpDia;
  final int? glucoseMgDl;
  final VoidCallback? onEditBloodPressure;
  final VoidCallback? onEditGlucose;
  final List<double>? bpSysSeries7;
  final List<double>? glucoseSeries7;

  const BodyMetricsCard({
    super.key,
    required this.onAddMetrics,
    this.currentWeight,
    this.goalWeight,
    this.lastWeight,
    this.weightUnit = 'kg',
    this.hasEntry = false,
    this.weeklyWeights,
    this.weeklyChange,
    this.onAdjustWeight,
    this.bpSys,
    this.bpDia,
    this.glucoseMgDl,
    this.onEditBloodPressure,
    this.onEditGlucose,
    this.bpSysSeries7,
    this.glucoseSeries7,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.bodyMetricsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: cs.onSurface,
                    ),
              ),
              TextButton(
                onPressed: () async {
                  await HapticHelper.light();
                  AnalyticsService.track('body_metrics_view_all_click');
                  onAddMetrics();
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  minimumSize: const Size(0, 0),
                ),
                child: Text(
                  AppLocalizations.of(context)!.bodyMetricsViewAll,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          // Card principal de peso (branco estilo YAZIO)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: hasEntry ? _buildWeightTracker(context) : _buildEmptyState(context),
          ),

          // Grid de outras métricas corporais (sempre visível)
          const SizedBox(height: 16),
          _buildAdditionalMetricsGrid(context),
        ],
      ),
    );
  }

  Widget _buildAdditionalMetricsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          context,
          icon: Icons.favorite_outline,
          iconColor: const Color(0xFFE91E63),
          backgroundColor: const Color(0xFFFCE4EC),
          title: AppLocalizations.of(context)!.bodyMetricsBloodPressure,
          value: bpSys != null && bpDia != null ? '${bpSys}x${bpDia}' : '--x--',
          unit: 'mmHg',
          spark: bpSysSeries7,
          sparkColor: const Color(0xFFE91E63),
          onTap: () {
            AnalyticsService.track('body_metrics_blood_pressure_click');
            (onEditBloodPressure ?? onAddMetrics).call();
          },
        ),
        _buildMetricCard(
          context,
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF2196F3),
          backgroundColor: const Color(0xFFE3F2FD),
          title: AppLocalizations.of(context)!.bodyMetricsBloodGlucose,
          value: glucoseMgDl != null ? '$glucoseMgDl' : '--',
          unit: 'mg/dL',
          spark: glucoseSeries7,
          sparkColor: const Color(0xFF2196F3),
          onTap: () {
            AnalyticsService.track('body_metrics_blood_glucose_click');
            (onEditGlucose ?? onAddMetrics).call();
          },
        ),
        _buildMetricCard(
          context,
          icon: Icons.percent_outlined,
          iconColor: const Color(0xFFFF9800),
          backgroundColor: const Color(0xFFFFF3E0),
          title: AppLocalizations.of(context)!.bodyMetricsBodyFat,
          value: '--',
          unit: '%',
          onTap: () {
            AnalyticsService.track('body_metrics_body_fat_click');
            onAddMetrics();
          },
        ),
        _buildMetricCard(
          context,
          icon: Icons.fitness_center_outlined,
          iconColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
          title: AppLocalizations.of(context)!.bodyMetricsMuscleMass,
          value: '--',
          unit: 'kg',
          onTap: () {
            AnalyticsService.track('body_metrics_muscle_mass_click');
            onAddMetrics();
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String value,
    required String unit,
    required VoidCallback onTap,
    List<double>? spark,
    Color? sparkColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        await HapticHelper.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: cs.onSurface,
                      ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            if (spark != null && spark.length >= 2) ...[
              const SizedBox(height: 6),
              SizedBox(height: 18, child: _MiniSparkline(points: spark, color: sparkColor ?? Theme.of(context).colorScheme.primary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTracker(BuildContext context) {
    final change = weeklyChange;
    final isDown = (change ?? 0) < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Weight display with +/- buttons - YAZIO style
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              context: context,
              icon: Icons.remove,
              onPressed: () async {
                await HapticHelper.medium();
                AnalyticsService.track('body_metrics_decrease_weight');
                onAdjustWeight?.call(-0.1);
              },
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                Text(
                  '${(currentWeight ?? 0).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  weightUnit,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            _buildControlButton(
              context: context,
              icon: Icons.add,
              onPressed: () async {
                await HapticHelper.medium();
                AnalyticsService.track('body_metrics_increase_weight');
                onAdjustWeight?.call(0.1);
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Goal display
        if (goalWeight != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.bodyMetricsGoal}: ${goalWeight!.toStringAsFixed(1)} $weightUnit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Weekly change indicator
        if (change != null && lastWeight != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDown ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDown ? Icons.trending_down : Icons.trending_up,
                  size: 18,
                  color: isDown ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                ),
                const SizedBox(width: 6),
                Text(
                  '${change.abs().toStringAsFixed(1)} $weightUnit ${AppLocalizations.of(context)!.bodyMetricsThisWeek}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDown ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  ),
                ),
                if (isDown) const Text(' 💪', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),

        // Mini chart if available
        if (weeklyWeights != null && weeklyWeights!.length > 1) ...[
          const SizedBox(height: 16),
          Container(
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyWeights!
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.monitor_weight_outlined,
            size: 40,
            color: cs.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.bodyMetricsEmptyTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.bodyMetricsEmptySubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: () async {
            await HapticHelper.medium();
            AnalyticsService.track('body_metrics_add_weight_click');
            onAddMetrics();
          },
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            AppLocalizations.of(context)!.bodyMetricsAddWeight,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Icon(
            icon,
            color: cs.primary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final List<double> points;
  final Color color;
  const _MiniSparkline({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniSparkPainter(points, color),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class _MiniSparkPainter extends CustomPainter {
  final List<double> pts;
  final Color color;
  _MiniSparkPainter(this.pts, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    final maxV = pts.reduce((a, b) => a > b ? a : b);
    final minV = pts.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = size.width * (i / (pts.length - 1));
      final norm = (pts[i] - minV) / range;
      final y = size.height - (norm * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparkPainter oldDelegate) {
    return oldDelegate.pts != pts || oldDelegate.color != color;
  }
}
