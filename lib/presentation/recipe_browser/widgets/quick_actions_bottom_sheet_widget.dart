import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';

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
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
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
              color: colors.outlineVariant,
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
                        style: textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${recipe['prepTime']}min • ${recipe['calories']}cal',
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
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
            context: context,
            icon: 'calendar_today',
            title: AppLocalizations.of(context)?.qaAddToMealPlan ??
                'Add to Meal Plan',
            subtitle: AppLocalizations.of(context)?.qaScheduleThisRecipe ??
                'Schedule this recipe for a meal',
            onTap: () {
              Navigator.pop(context);
              onAddToMealPlan();
            },
          ),
          _buildActionItem(
            context: context,
            icon: 'share',
            title:
                AppLocalizations.of(context)?.qaShareRecipe ?? 'Share Recipe',
            subtitle: AppLocalizations.of(context)?.qaShareWithFriends ??
                'Share with friends and family',
            onTap: () {
              Navigator.pop(context);
              onShareRecipe();
            },
          ),
          _buildActionItem(
            context: context,
            icon: 'restaurant',
            title: AppLocalizations.of(context)?.qaSimilarRecipes ??
                'Similar Recipes',
            subtitle: AppLocalizations.of(context)?.qaFindSimilar ??
                'Find similar recipes',
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
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: colors.primary,
          size: 6.w,
        ),
      ),
      title: Text(
        title,
        style: textStyles.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textStyles.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: colors.onSurfaceVariant,
        size: 5.w,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    );
  }
}
