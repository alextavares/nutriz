import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Illustration
          Container(
            height: 40.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'camera_alt',
                  color: AppTheme.activeBlue,
                  size: 20.w,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Detectar Alimentos com IA',
                  style: AppTheme.darkTheme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    'Capture uma foto ou selecione da galeria para identificar automaticamente os alimentos e suas informações nutricionais',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
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
                    color: AppTheme.textPrimary,
                    size: 6.w,
                  ),
                  label: Text('Tirar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCameraInitialized
                        ? AppTheme.activeBlue
                        : AppTheme.darkTheme.colorScheme.outline,
                    foregroundColor: AppTheme.textPrimary,
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
                    color: AppTheme.activeBlue,
                    size: 6.w,
                  ),
                  label: Text('Galeria'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.activeBlue,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    side: BorderSide(color: AppTheme.activeBlue),
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
                color: AppTheme.warningAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.warningAmber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.warningAmber),
                    strokeWidth: 2,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Inicializando câmera...',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.warningAmber,
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
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: AppTheme.premiumGold,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Dicas para melhor detecção:',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.premiumGold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildTip('• Certifique-se de ter boa iluminação'),
                _buildTip('• Fotografe os alimentos de perto'),
                _buildTip('• Evite sombras no prato'),
                _buildTip('• Um alimento por vez funciona melhor'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        text,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
