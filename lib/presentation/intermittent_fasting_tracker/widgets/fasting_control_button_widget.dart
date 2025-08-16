import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FastingControlButtonWidget extends StatefulWidget {
  final bool isFasting;
  final VoidCallback onStartFasting;
  final VoidCallback onStopFasting;

  const FastingControlButtonWidget({
    Key? key,
    required this.isFasting,
    required this.onStartFasting,
    required this.onStopFasting,
  }) : super(key: key);

  @override
  State<FastingControlButtonWidget> createState() =>
      _FastingControlButtonWidgetState();
}

class _FastingControlButtonWidgetState extends State<FastingControlButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (widget.isFasting) {
      _showStopConfirmationDialog();
    } else {
      widget.onStartFasting();
    }
  }

  void _showStopConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.secondaryBackgroundDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.warningAmber,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Parar Jejum?',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Text(
            'Tem certeza que deseja interromper seu jejum atual? Seu progresso será salvo.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onStopFasting();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.textPrimary,
              ),
              child: Text(
                'Parar Jejum',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80.w,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _handleTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isFasting
                    ? AppTheme.errorRed
                    : AppTheme.successGreen,
                foregroundColor: AppTheme.textPrimary,
                elevation: 4,
                shadowColor: widget.isFasting
                    ? AppTheme.errorRed.withValues(alpha: 0.3)
                    : AppTheme.successGreen.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: widget.isFasting ? 'stop' : 'play_arrow',
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.isFasting ? 'Parar Jejum' : 'Iniciar Jejum',
                    style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
