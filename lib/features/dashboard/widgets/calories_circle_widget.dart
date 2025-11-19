import 'package:flutter/material.dart';
import '../../../core/widgets/nutriz_card.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import 'package:nutriz/components/calorie_ring.dart';

class CaloriesCircleWidget extends StatelessWidget {
  const CaloriesCircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: connect with real daily totals from state
    const double goal = 2000;
    const double eaten = 0;
    const double burned = 0;

    return NutrizCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calories', style: AppTextStyles.h2(context)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColorsDS.primary(context),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 0),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Details'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _metric(context, label: 'Eaten', value: '$eaten kcal', color: Colors.orange),
              ),
              const CalorieRing(goal: goal, eaten: eaten, burned: burned, size: 180, thickness: 16),
              Expanded(
                child: _metric(context, label: 'Burned', value: '$burned kcal', color: Colors.blueAccent, alignEnd: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _metric(BuildContext context, {required String label, required String value, required Color color, bool alignEnd = false}) {
  final textColor = AppColorsDS.textPrimary(context);
  final hint = AppColorsDS.textHint(context);
  final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  return Column(
    crossAxisAlignment: align,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: TextStyle(color: hint, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Row(
        mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    ],
  );
}
