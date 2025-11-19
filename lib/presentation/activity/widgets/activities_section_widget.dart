import 'package:flutter/material.dart';
import 'package:nutriz/presentation/activity/widgets/steps_connect_card_widget.dart';
import 'package:nutriz/theme/design_tokens.dart';
import 'package:nutriz/widgets/dashboard_section_header.dart';

class ActivitiesSectionWidget extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onManual;
  final int? steps;
  final double? kcal;
  final VoidCallback? onMore;

  const ActivitiesSectionWidget({
    super.key,
    required this.onConnect,
    required this.onManual,
    this.onMore,
    this.steps,
    this.kcal,
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
          DashboardSectionHeader(
            title: 'Atividades',
            actionLabel: onMore != null ? 'Mais' : null,
            onAction: onMore,
          ),
          const SizedBox(height: 8),
          StepsConnectCardWidget(
            onConnect: onConnect,
            onManual: onManual,
            steps: steps,
            kcal: kcal,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
