import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.restaurant,
        label: 'Adicionar\nRefeição',
        color: AppTheme.activeBlue,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.addFoodEntry);
        },
      ),
      _QuickAction(
        icon: Icons.local_drink,
        label: 'Registrar\nÁgua',
        color: AppTheme.activeBlue,
        onTap: () {
          // TODO: Navigate to water logging
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade em desenvolvimento'),
              backgroundColor: AppTheme.activeBlue,
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.fitness_center,
        label: 'Exercício',
        color: AppTheme.successGreen,
        onTap: () {
          // TODO: Navigate to exercise logging
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidade em desenvolvimento'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        },
      ),
      _QuickAction(
        icon: Icons.show_chart,
        label: 'Progresso',
        color: AppTheme.warningAmber,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.progressOverview);
        },
      ),
      _QuickAction(
        icon: Icons.restaurant_menu,
        label: 'Receitas',
        color: AppTheme.premiumGold,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.recipeBrowser);
        },
      ),
      _QuickAction(
        icon: Icons.settings,
        label: 'Configurar\nMetas',
        color: AppTheme.textSecondary,
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackgroundDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.dividerGray.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
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
