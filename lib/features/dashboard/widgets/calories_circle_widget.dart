import 'package:flutter/material.dart';
import '../../../core/widgets/nutriz_card.dart';
import '../../../core/theme/app_text_styles.dart';

class CaloriesCircleWidget extends StatelessWidget {
  const CaloriesCircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NutrizCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: AppTextStyles.h2(context)),
          const SizedBox(height: 12),
          const SizedBox(height: 120, child: Center(child: Text('Circle'))),
        ],
      ),
    );
  }
}

