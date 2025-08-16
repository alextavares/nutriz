import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onActionTap;
  final bool showClearFilters;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onActionTap,
    this.showClearFilters = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackgroundDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName:
                      showClearFilters ? 'filter_alt_off' : 'restaurant_menu',
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  size: 20.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Title
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            // Subtitle
            Text(
              subtitle,
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            // Action Button
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: showClearFilters
                    ? AppTheme.warningAmber
                    : AppTheme.activeBlue,
                foregroundColor: AppTheme.textPrimary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: showClearFilters ? 'clear_all' : 'refresh',
                    color: AppTheme.textPrimary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    actionText,
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
