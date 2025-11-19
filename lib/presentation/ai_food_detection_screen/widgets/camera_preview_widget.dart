import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final VoidCallback onCapture;
  final VoidCallback onClose;
  final VoidCallback? onGallery;

  const CameraPreviewWidget({
    Key? key,
    required this.controller,
    required this.onCapture,
    required this.onClose,
    this.onGallery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
        margin: EdgeInsets.all(4.w),
        height: 60.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Stack(children: [
          // Camera preview
          Positioned.fill(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(controller))),

          // Overlay with controls
          Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ])))),

          // Top controls
          Positioned(
              top: 4.w,
              right: 4.w,
              child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20)),
                      child: CustomIconWidget(
                          iconName: 'close', color: Colors.white, size: 6.w)))),

          // Bottom controls
          Positioned(
            bottom: 4.w,
            left: 0,
            right: 0,
            child: Builder(
              builder: (_) {
                final double captureSize = 23.w; // ~15% larger than 20.w
                const double gapW = 18.0; // w units gap to the left of capture
                return Stack(
                  children: [
                    // Capture centered
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: onCapture,
                        child: Container(
                          width: captureSize,
                          height: captureSize,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CustomIconWidget(
                            iconName: 'camera_alt',
                            color: Colors.white,
                            size: 9.w,
                          ),
                        ),
                      ),
                    ),
                    // Gallery left of capture, vertically centered
                    if (onGallery != null)
                      Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: Offset(-(captureSize / 2 + gapW.w), 0),
                          child: GestureDetector(
                            onTap: onGallery,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'photo_library',
                                  color: Colors.white,
                                  size: 9.5.w,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppLocalizations.of(context)!.gallery,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ]));
  }
}
