import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsBottomSheetWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onAddToMealPlan;
  final VoidCallback onShareRecipe;
  final VoidCallback onSimilarRecipes;

  const QuickActionsBottomSheetWidget({
    Key? key,
    required this.recipe,
    required this.onAddToMealPlan,
    required this.onShareRecipe,
    required this.onSimilarRecipes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.dividerGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Recipe Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: recipe['imageUrl'] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'] as String,
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${recipe['prepTime']}min • ${recipe['calories']}cal',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Items
          _buildActionItem(
            icon: 'calendar_today',
            title: 'Adicionar ao Plano de Refeições',
            subtitle: 'Agendar esta receita para uma refeição',
            onTap: () {
              Navigator.pop(context);
              onAddToMealPlan();
            },
          ),
          _buildActionItem(
            icon: 'share',
            title: 'Compartilhar Receita',
            subtitle: 'Enviar para amigos e família',
            onTap: () {
              Navigator.pop(context);
              onShareRecipe();
            },
          ),
          _buildActionItem(
            icon: 'restaurant',
            title: 'Receitas Similares',
            subtitle: 'Encontrar receitas parecidas',
            onTap: () {
              Navigator.pop(context);
              onSimilarRecipes();
            },
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.activeBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.activeBlue,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.textSecondary,
        size: 5.w,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    );
  }
}
