import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo Container with gradient background
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.activeBlue, AppTheme.successGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.activeBlue.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'restaurant_menu',
              color: AppTheme.textPrimary,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App Name
        Text(
          'NutriTracker',
          style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 0.5.h),

        // App Tagline
        Text(
          'Sua jornada nutricional',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
