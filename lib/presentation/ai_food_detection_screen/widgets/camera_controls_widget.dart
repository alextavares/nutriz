import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final bool isCameraInitialized;

  const CameraControlsWidget({
    Key? key,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.isCameraInitialized,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Illustration
          Container(
            height: 40.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'camera_alt',
                  color: colors.primary,
                  size: 20.w,
                ),
                SizedBox(height: 3.h),
                Text(
                  AppLocalizations.of(context)!.detectFoodHeadline,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    AppLocalizations.of(context)!.detectFoodSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Action buttons
          Row(
            children: [
              // Camera button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCameraInitialized ? onCameraPressed : null,
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: colors.onPrimary,
                    size: 6.w,
                  ),
                  label: Text(AppLocalizations.of(context)!.takePhoto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCameraInitialized
                        ? colors.primary
                        : colors.outlineVariant,
                    foregroundColor: colors.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Gallery button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGalleryPressed,
                  icon: CustomIconWidget(
                    iconName: 'photo_library',
                    color: colors.primary,
                    size: 6.w,
                  ),
                  label: Text(AppLocalizations.of(context)!.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    side: BorderSide(color: colors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Camera status
          if (!isCameraInitialized)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: semantics.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: semantics.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(semantics.warning),
                    strokeWidth: 2,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.initializingCamera,
                      style: textTheme.bodyMedium?.copyWith(
                        color: semantics.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 2.h),

          // Tips
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: semantics.premium,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      AppLocalizations.of(context)!.detectionTipsTitle,
                      style: textTheme.titleSmall?.copyWith(
                        color: semantics.premium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildTip(context, '\u2022 ' + AppLocalizations.of(context)!.detectionTip1),
                _buildTip(context, '\u2022 ' + AppLocalizations.of(context)!.detectionTip2),
                _buildTip(context, '\u2022 ' + AppLocalizations.of(context)!.detectionTip3),
                _buildTip(context, '\u2022 ' + AppLocalizations.of(context)!.detectionTip4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
      ),
    );
  }
}
