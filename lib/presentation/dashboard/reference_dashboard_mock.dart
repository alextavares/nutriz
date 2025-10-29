import 'package:flutter/material.dart';
import 'package:nutriz/presentation/activity/widgets/activities_section_widget.dart';
import 'package:nutriz/presentation/daily_tracking_dashboard/widgets/meal_plan_section_widget.dart';
import 'package:nutriz/theme/design_tokens.dart';

class ReferenceDashboardMock extends StatelessWidget {
  const ReferenceDashboardMock({super.key});

  @override
  Widget build(BuildContext context) {
    const meals = [
      MealPlanItem(
        title: 'Almoço',
        consumedKcal: 410,
        goalKcal: 934,
        subtitle: 'Assado de batata com ...',
        ai: true,
      ),
      MealPlanItem(
        title: 'Jantar',
        consumedKcal: 0,
        goalKcal: 934,
      ),
      MealPlanItem(
        title: 'Lanches',
        consumedKcal: 0,
        goalKcal: 0,
        enabled: false,
      ),
    ];

    final colors = context.colors;
    final textStyles = context.textStyles;

    return Material(
      color: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'sáb.',
                    style: textStyles.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.water_drop_outlined,
                          size: 18, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '0',
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite_outline,
                          size: 18, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '2',
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.settings_outlined,
                          size: 18, color: colors.onSurfaceVariant),
                    ],
                  )
                ],
              ),
            ),
            Divider(height: 1, color: colors.outline),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const MealPlanSectionWidget(items: meals),
                    const SizedBox(height: 4),
                    ActivitiesSectionWidget(
                      onConnect: () {},
                      onManual: () {},
                      onMore: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _NavItem(
                      icon: Icons.home_filled, label: 'Diário', active: true),
                  _NavItem(icon: Icons.hourglass_top, label: 'Jejum'),
                  _NavItem(icon: Icons.receipt_long, label: 'Receitas'),
                  _NavItem(icon: Icons.person_outline, label: 'Perfil'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem(
      {required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final Color foreground = active ? colors.primary : colors.onSurfaceVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: foreground),
        const SizedBox(height: 2),
        Text(
          label,
          style: textStyles.labelSmall?.copyWith(
            color: foreground,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        )
      ],
    );
  }
}
