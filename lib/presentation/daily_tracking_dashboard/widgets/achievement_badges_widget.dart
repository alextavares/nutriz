import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import '../../../core/l10n_ext.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class AchievementBadgesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final Function(Map<String, dynamic>) onBadgeTap;

  const AchievementBadgesWidget({
    super.key,
    required this.achievements,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final semantics = context.semanticColors;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.achievementsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Tooltip(
                message: context.l10n.streakMilestonesTitle,
                child: CustomIconWidget(
                  iconName: 'water_drop',
                  color: colors.primary,
                  size: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 10.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return GestureDetector(
                  onTap: () => onBadgeTap(achievement),
                  child: Container(
                    width: 20.w,
                    margin: EdgeInsets.only(right: 2.w),
                    padding: EdgeInsets.symmetric(
                      vertical: 0.4.h,
                      horizontal: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getBadgeColor(
                          semantics,
                          colors,
                          achievement['type'] as String,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double iconSize =
                            (constraints.maxHeight * 0.42).clamp(14, 24);
                        final double computedFontSize =
                            (constraints.maxHeight * 0.22).clamp(10, 14);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 0.6.h,
                                horizontal: 2.w,
                              ),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(
                                  semantics,
                                  colors,
                                  achievement['type'] as String,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomIconWidget(
                                iconName: _getBadgeIcon(
                                    achievement['type'] as String),
                                color: _getBadgeColor(
                                  semantics,
                                  colors,
                                  achievement['type'] as String,
                                ),
                                size: iconSize,
                              ),
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              achievement['title'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: computedFontSize,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(
    AppSemanticColors semantic,
    ColorScheme scheme,
    String type,
  ) {
    switch (type) {
      case 'diamond':
        return semantic.premium;
      case 'flame':
        return semantic.warning;
      case 'success':
        return semantic.success;
      default:
        return scheme.primary;
    }
  }

  String _getBadgeIcon(String type) {
    switch (type) {
      case 'diamond':
        return 'diamond';
      case 'flame':
        return 'local_fire_department';
      case 'success':
        return 'check_circle';
      default:
        return 'star';
    }
  }
}
