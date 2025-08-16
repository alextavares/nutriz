import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onRemove;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.count,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: AppTheme.activeBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.activeBlue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.activeBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (count > 0) ...[
            SizedBox(width: 1.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.activeBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: onRemove,
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.activeBlue,
              size: 4.w,
            ),
          ),
        ],
      ),
    );
  }
}
