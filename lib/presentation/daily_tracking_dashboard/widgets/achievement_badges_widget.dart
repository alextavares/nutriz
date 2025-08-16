import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Conquistas Recentes',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              Tooltip(
                message:
                    'Beba a meta de água por 3/5/7 dias seguidos para ganhar faixas',
                child: CustomIconWidget(
                  iconName: 'water_drop',
                  color: AppTheme.activeBlue,
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
                      color: AppTheme.secondaryBackgroundDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getBadgeColor(achievement['type'] as String)
                            .withValues(alpha: 0.3),
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
                                        achievement['type'] as String)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomIconWidget(
                                iconName: _getBadgeIcon(
                                    achievement['type'] as String),
                                color: _getBadgeColor(
                                    achievement['type'] as String),
                                size: iconSize,
                              ),
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              achievement['title'] as String,
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textPrimary,
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

  Color _getBadgeColor(String type) {
    switch (type) {
      case 'diamond':
        return AppTheme.premiumGold;
      case 'flame':
        return AppTheme.warningAmber;
      case 'success':
        return AppTheme.successGreen;
      default:
        return AppTheme.activeBlue;
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
