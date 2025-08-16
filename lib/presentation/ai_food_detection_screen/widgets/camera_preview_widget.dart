import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final VoidCallback onCapture;
  final VoidCallback onClose;

  const CameraPreviewWidget({
    Key? key,
    required this.controller,
    required this.onCapture,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          iconName: 'close',
                          color: AppTheme.textPrimary,
                          size: 6.w)))),

          // Bottom controls
          Positioned(
              bottom: 4.w,
              left: 0,
              right: 0,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Capture button
                GestureDetector(
                    onTap: onCapture,
                    child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                            color: AppTheme.activeBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.textPrimary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 2)),
                            ]),
                        child: CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.textPrimary,
                            size: 8.w))),
              ])),

          // Capture guidance
          Positioned(
              top: 30.h,
              left: 0,
              right: 0,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(children: [
                    Icon(Icons.center_focus_strong,
                        size: 15.w,
                        color: AppTheme.activeBlue.withValues(alpha: 0.7)),
                    SizedBox(height: 2.h),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Posicione o alimento no centro',
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textPrimary),
                            textAlign: TextAlign.center)),
                  ]))),
        ]));
  }
}
