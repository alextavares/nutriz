import 'package:flutter/material.dart';
import '../../../core/widgets/nutriz_card.dart';
import '../../../core/theme/app_text_styles.dart';

class MacrosBarWidget extends StatelessWidget {
  const MacrosBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NutrizCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Macronutrients', style: AppTextStyles.h2(context)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 0.0),
        ],
      ),
    );
  }
}

