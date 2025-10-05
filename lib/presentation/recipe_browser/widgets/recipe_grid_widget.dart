import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';
import './recipe_card_widget.dart';

class RecipeGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  final Function(Map<String, dynamic>) onRecipeTap;
  final Function(Map<String, dynamic>) onFavoriteToggle;
  final Function(Map<String, dynamic>) onRecipeLongPress;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool isPremiumUser;
  final VoidCallback onUnlockPro;

  const RecipeGridWidget({
    Key? key,
    required this.recipes,
    required this.onRecipeTap,
    required this.onFavoriteToggle,
    required this.onRecipeLongPress,
    this.isLoading = false,
    this.onLoadMore,
    required this.isPremiumUser,
    required this.onUnlockPro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            onLoadMore != null &&
            !isLoading) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.72,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 2.h,
        ),
        itemCount: recipes.length + (isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= recipes.length) {
            return _buildSkeletonCard(context);
          }

          final recipe = recipes[index];
          return RecipeCardWidget(
            recipe: recipe,
            onTap: () => onRecipeTap(recipe),
            onFavoriteToggle: () => onFavoriteToggle(recipe),
            onLongPress: () => onRecipeLongPress(recipe),
            isPremiumUser: isPremiumUser,
            onUnlockPro: onUnlockPro,
          );
        },
      ),
    );
  }

  int _getCrossAxisCount() {
    if (100.w > 600) {
      return 3; // Tablet
    }
    return 2; // Phone
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: colors.outlineVariant.withValues(alpha: 0.25),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'image',
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 8.w,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    width: 60.w,
                    height: 1.5.h,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 15.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color:
                              colors.outlineVariant.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 15.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color:
                              colors.outlineVariant.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
