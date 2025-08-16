import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecipeCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLongPress;

  const RecipeCardWidget({
    Key? key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = recipe['isFavorite'] ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowDark,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image with Favorite Button
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CustomImageWidget(
                      imageUrl: recipe['imageUrl'] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBackgroundDark
                              .withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: isFavorite ? 'favorite' : 'favorite_border',
                          color: isFavorite
                              ? AppTheme.errorRed
                              : AppTheme.textPrimary,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Recipe Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Recipe Name
                    Text(
                      recipe['name'] as String,
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    // Recipe Info Row
                    Row(
                      children: [
                        // Prep Time
                        Expanded(
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'access_time',
                                color: AppTheme.textSecondary,
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Flexible(
                                child: Text(
                                  '${recipe['prepTime']}min',
                                  style: AppTheme.darkTheme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Calories
                        Expanded(
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'local_fire_department',
                                color: AppTheme.warningAmber,
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Flexible(
                                child: Text(
                                  '${recipe['calories']}cal',
                                  style: AppTheme.darkTheme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
