import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../components/calorie_ring.dart';

class NutritionSummaryCard extends StatelessWidget {
  final int consumedCalories;
  final int totalCalories;
  final Map<String, dynamic> carbs;
  final Map<String, dynamic> proteins;
  final Map<String, dynamic> fats;

  // Keep animations aligned across ring and numbers
  static const Duration _kAnimDuration = Duration(milliseconds: 900);
  static const Curve _kAnimCurve = Curves.easeOut;
  static const double _kDelayLeft = 0.03;   // ~27ms
  static const double _kDelayCenter = 0.06; // ~54ms
  static const double _kDelayRight = 0.09;  // ~81ms

  const NutritionSummaryCard({
    super.key,
    required this.consumedCalories,
    required this.totalCalories,
    required this.carbs,
    required this.proteins,
    required this.fats,
  });

  int get remainingCalories => totalCalories - consumedCalories;
  double get caloriesProgress =>
      totalCalories > 0 ? consumedCalories / totalCalories : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const burnedCalories = 0; // Placeholder

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            const double gap = 12; // espaçamento fixo
            final totalW = constraints.maxWidth;
            final double ringTarget = totalW * 0.42; // ~42% do card
            const double minRing = 110.0;
            double maxRing = (totalW - (gap * 2) - (64.0 * 2)).clamp(90.0, totalW);
            double ringW = ringTarget.clamp(minRing, maxRing);
            double sideW = ((totalW - ringW) / 2) - gap;
            if (sideW < 64.0) {
              sideW = 64.0;
              ringW = (totalW - (sideW * 2) - (gap * 2)).clamp(90.0, totalW);
            }

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
                      child: _buildCalorieInfo(theme,
                          label: 'Consumidas', value: consumedCalories, delayFrac: _kDelayLeft),
                    ),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: ringW,
                    height: ringW,
                    child: _buildRemainingRing(theme, size: ringW),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: sideW,
                    // allow height to grow with larger text scale
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildCalorieInfo(theme,
                          label: 'Queimadas', value: burnedCalories, delayFrac: _kDelayRight),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 2.h),
          Divider(
            color: AppTheme.dividerGray.withValues(alpha: 0.3),
            thickness: 1,
            height: 1,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMacroInfo(theme,
                    label: 'Carboidratos',
                    consumed: carbs['consumed'],
                    total: carbs['total']),
              ),
              Expanded(
                child: _buildMacroInfo(theme,
                    label: 'Proteína',
                    consumed: proteins['consumed'],
                    total: proteins['total']),
              ),
              Expanded(
                child: _buildMacroInfo(theme,
                    label: 'Gordura',
                    consumed: fats['consumed'],
                    total: fats['total']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieInfo(ThemeData theme,
      {required String label, required int value, double delayFrac = 0.0}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
      children: [
        TweenAnimationBuilder<double>(
          key: ValueKey(value),
          tween: Tween<double>(begin: 0, end: value.toDouble()),
          duration: _kAnimDuration,
          curve: Curves.linear,
          builder: (context, v, _) {
            if (value <= 0) {
              return Text(
                '0',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            }
            final p = (v / value).clamp(0.0, 1.0);
            final delayed = p <= delayFrac ? 0.0 : (p - delayFrac) / (1.0 - delayFrac);
            final eased = _kAnimCurve.transform(delayed);
            final shown = (value * eased).toInt();
            return Text(
              shown.toString(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            );
          },
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRemainingRing(ThemeData theme, {double? size}) {
    final double w = size ?? 28.w;
    return SizedBox(
      width: w,
      height: w,
      child: CalorieRing(
        goal: totalCalories.toDouble(),
        eaten: consumedCalories.toDouble(),
        burned: 0,
        size: w,
        thickness: (w * 0.10).clamp(10.0, 18.0),
        showTicks: false,
        gapDegrees: 40,
      ),
    );
  }

  Widget _buildMacroInfo(ThemeData theme,
      {required String label, required int consumed, required int total}) {
    double ratio = total > 0 ? (consumed / total).clamp(0.0, 1.0) : 0.0;
    Color barColor;
    final l = label.toLowerCase();
    if (l.contains('carb') || l.contains('carbo')) {
      barColor = AppTheme.warningAmber;
    } else if (l.contains('prot')) {
      barColor = AppTheme.successGreen;
    } else if (l.contains('gord') || l.contains('fat')) {
      barColor = AppTheme.activeBlue;
    } else {
      barColor = theme.colorScheme.primary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 4,
                color: AppTheme.dividerGray.withValues(alpha: 0.35),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio,
                child: Container(height: 4, color: barColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$consumed / ${total}g',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
