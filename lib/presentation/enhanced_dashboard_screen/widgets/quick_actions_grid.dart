import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:nutritracker/routes/app_routes.dart';
import 'package:nutritracker/theme/design_tokens.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.semanticColors;

    final actions = [
      _QuickAction(
        icon: Icons.restaurant,
        label: 'Adicionar\nRefeição',
        color: colors.primary,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.addFoodEntry);
        },
      ),
      _QuickAction(
        icon: Icons.local_drink,
        label: 'Registrar\nÁgua',
        color: colors.primary,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Funcionalidade em desenvolvimento'),
              backgroundColor: colors.primary,
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.fitness_center,
        label: 'Exercício',
        color: semantics.success,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Funcionalidade em desenvolvimento'),
              backgroundColor: semantics.success,
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.show_chart,
        label: 'Progresso',
        color: semantics.warning,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.progressOverview);
        },
      ),
      _QuickAction(
        icon: Icons.restaurant_menu,
        label: 'Receitas',
        color: semantics.premium,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.recipeBrowser);
        },
      ),
      _QuickAction(
        icon: Icons.settings,
        label: 'Configurar\nMetas',
        color: colors.onSurfaceVariant,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.goalsWizard);
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return actions[index];
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 6.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textStyles.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
