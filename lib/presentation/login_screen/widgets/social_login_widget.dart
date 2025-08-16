import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final Function(String provider) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    required this.onSocialLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "ou" text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.dividerGray,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'ou',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.dividerGray,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Google Login Button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => onSocialLogin('google'),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.secondaryBackgroundDark,
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(
                color: AppTheme.dividerGray.withValues(alpha: 0.5),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomImageWidget(
                  imageUrl:
                      'https://developers.google.com/identity/images/g-logo.png',
                  width: 5.w,
                  height: 5.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continuar com Google',
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Apple Login Button (iOS style)
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => onSocialLogin('apple'),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.secondaryBackgroundDark,
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(
                color: AppTheme.dividerGray.withValues(alpha: 0.5),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'apple',
                  color: AppTheme.textPrimary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continuar com Apple',
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
