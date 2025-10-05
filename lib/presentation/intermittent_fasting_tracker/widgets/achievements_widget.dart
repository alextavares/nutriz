import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

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
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emoji_events',
                color: context.semanticColors.premium,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Conquistas',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurface,
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
                  context: context,
                  icon: 'calendar_today',
                  value: '$totalFastingDays',
                  label: 'Dias Total',
                  color: context.colors.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: 'local_fire_department',
                  value: '$longestStreak',
                  label: 'Maior Sequência',
                  color: context.semanticColors.warning,
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
              return _buildAchievementCard(context, achievement);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final w = MediaQuery.of(context).size.width;
    final double fsValue = w < 340 ? 13.sp : (w < 380 ? 15.sp : 16.sp);
    final double fsLabel = w < 340 ? 8.sp : (w < 380 ? 9.sp : 10.sp);
    final double iconSize = w < 360 ? 18 : 20;
    final double pad = w < 360 ? 10 : 12;
    return Container(
      padding: EdgeInsets.all(pad),
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
            size: iconSize,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: context.textStyles.titleMedium?.copyWith(
              color: color,
              fontSize: fsValue,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontSize: fsLabel,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
      BuildContext context, Map<String, dynamic> achievement) {
    final isUnlocked = achievement["unlocked"] as bool;
    final title = achievement["title"] as String;
    // description unused here by design (card compact)
    final progress = achievement["progress"] as double;
    final target = achievement["target"] as int;
    final w = MediaQuery.of(context).size.width;
    final double iconSize = w < 360 ? 18 : 20;
    final double titleFs = w < 340 ? 8.sp : (w < 380 ? 9.sp : 10.sp);
    final double progFs = w < 340 ? 7.sp : (w < 380 ? 8.sp : 9.sp);
    final double pad = w < 360 ? 8 : 10;

    return Container(
      padding: EdgeInsets.all(pad.toDouble()),
      decoration: BoxDecoration(
        color: isUnlocked
            ? context.semanticColors.premium.withValues(alpha: 0.1)
            : context.colors.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked
              ? context.semanticColors.premium.withValues(alpha: 0.5)
              : context.colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isUnlocked ? 'diamond' : 'lock',
            color: isUnlocked
                ? context.semanticColors.premium
                : context.colors.onSurfaceVariant,
            size: iconSize,
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: context.textStyles.bodySmall?.copyWith(
              color: isUnlocked
                  ? context.semanticColors.premium
                  : context.colors.onSurfaceVariant,
              fontSize: titleFs,
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
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontSize: progFs,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
