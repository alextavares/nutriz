import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class RecipeCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onLongPress;
  final bool isPremiumUser;
  final VoidCallback onUnlockPro;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onLongPress,
    required this.isPremiumUser,
    required this.onUnlockPro,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bool isFavorite = recipe['isFavorite'] ?? false;
    final bool isPremiumRecipe = recipe['isPremium'] ?? false;
    final bool locked = isPremiumRecipe && !isPremiumUser;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final semantics = context.semanticColors;

    return GestureDetector(
      onTap: locked ? onUnlockPro : onTap,
      onLongPress: locked ? onUnlockPro : onLongPress,
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.18),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: GestureDetector(
                      onTap: locked ? onUnlockPro : onFavoriteToggle,
                      child: Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: isFavorite ? 'favorite' : 'favorite_border',
                          color: isFavorite
                              ? colors.error
                              : colors.onSurface,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ),
                  if (locked)
                    Positioned(
                      top: 2.w,
                      left: 2.w,
                      child: _ProChip(),
                    ),
                  if (locked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 0.8.h),
                              Text(
                                t.proRecipe,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              SizedBox(height: 0.4.h),
                              Text(
                                t.tapToUnlock,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] as String,
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.6.h),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'access_time',
                                color: colors.onSurfaceVariant,
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Flexible(
                                child: Text(
                                  '${recipe['prepTime']}min',
                                  style: textStyles.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'local_fire_department',
                                color: semantics.warning,
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Flexible(
                                child: Text(
                                  '${recipe['calories']}cal',
                                  style: textStyles.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.6.h),
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

class _ProChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: semantics.premium.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            t.proOnly,
            style: textStyles.labelSmall?.copyWith(
              color: semantics.onPremium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
