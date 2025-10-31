import 'package:flutter/material.dart';
import '../../../core/widgets/nutriz_card.dart';
import '../../../core/theme/app_text_styles.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NutrizCard(
      child: Row(
        children: [
          Expanded(
            child: Text('Header', style: AppTextStyles.h2(context)),
          ),
          Text('Today', style: AppTextStyles.body2(context)),
        ],
      ),
    );
  }
}

