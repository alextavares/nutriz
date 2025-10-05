import 'package:flutter/material.dart';
import 'package:nutritracker/presentation/activity/widgets/steps_connect_card_widget.dart';
import 'package:nutritracker/theme/design_tokens.dart';

class ActivitiesSectionWidget extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onManual;
  final VoidCallback? onMore;

  const ActivitiesSectionWidget({
    super.key,
    required this.onConnect,
    required this.onManual,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atividades',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onMore,
                  child: const Text('Mais'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          StepsConnectCardWidget(onConnect: onConnect, onManual: onManual),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
