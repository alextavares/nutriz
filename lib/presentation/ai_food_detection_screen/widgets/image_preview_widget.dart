import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ImagePreviewWidget extends StatelessWidget {
  final File imageFile;
  final bool isAnalyzing;
  final VoidCallback onRetake;

  const ImagePreviewWidget({
    Key? key,
    required this.imageFile,
    required this.isAnalyzing,
    required this.onRetake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Image preview
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Image
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Analysis overlay
                if (isAnalyzing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.activeBlue,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Analisando alimentos...',
                            style: AppTheme.darkTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Aguarde alguns segundos',
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Retake button
              ElevatedButton.icon(
                onPressed: isAnalyzing ? null : onRetake,
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.textPrimary,
                  size: 5.w,
                ),
                label: Text('Nova Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                  foregroundColor: AppTheme.textPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
