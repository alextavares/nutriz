import 'package:flutter/material.dart';
import '../../../core/widgets/nutriz_card.dart';
import '../../../core/widgets/section_header.dart';

class NutritionSectionWidget extends StatelessWidget {
  const NutritionSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionHeader(title: 'Nutrition', trailingText: 'More'),
        NutrizCard(child: Text('Meals placeholder')), 
      ],
    );
  }
}

