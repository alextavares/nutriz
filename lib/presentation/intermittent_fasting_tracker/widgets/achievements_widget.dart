import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final int totalFastingDays;
  final int longestStreak;

  const AchievementsWidget({
    Key? key,
    required this.achievements,
    required this.totalFastingDays,
    required this.longestStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emoji_events',
                color: AppTheme.premiumGold,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Conquistas',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Statistics Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: 'calendar_today',
                  value: '$totalFastingDays',
                  label: 'Dias Total',
                  color: AppTheme.activeBlue,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  icon: 'local_fire_department',
                  value: '$longestStreak',
                  label: 'Maior Sequência',
                  color: AppTheme.warningAmber,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Achievements Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.0,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(achievement);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement["unlocked"] as bool;
    final title = achievement["title"] as String;
    // description unused here by design (card compact)
    final progress = achievement["progress"] as double;
    final target = achievement["target"] as int;

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppTheme.premiumGold.withValues(alpha: 0.1)
            : AppTheme.dividerGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.premiumGold.withValues(alpha: 0.5)
              : AppTheme.dividerGray.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isUnlocked ? 'diamond' : 'lock',
            color: isUnlocked ? AppTheme.premiumGold : AppTheme.textSecondary,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: isUnlocked ? AppTheme.premiumGold : AppTheme.textSecondary,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked) ...[
            SizedBox(height: 0.5.h),
            Text(
              '${(progress * target).toInt()}/$target',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 8.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
