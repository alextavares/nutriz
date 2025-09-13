import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class FastingControlButtonWidget extends StatefulWidget {
  final bool isFasting;
  final VoidCallback onStartFasting;
  final VoidCallback onStopFasting;
  final bool muted;
  final DateTime? muteUntil;

  const FastingControlButtonWidget({
    Key? key,
    required this.isFasting,
    required this.onStartFasting,
    required this.onStopFasting,
    this.muted = false,
    this.muteUntil,
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
    try { HapticFeedback.lightImpact(); } catch (_) {}
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
                try { HapticFeedback.mediumImpact(); } catch (_) {}
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
        final isFasting = widget.isFasting;
        final label = isFasting ? 'Parar Jejum' : 'Iniciar Jejum';
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: label,
                child: Container(
                  width: 80.w,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _handleTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFasting
                          ? AppTheme.errorRed
                          : AppTheme.successGreen,
                      foregroundColor: AppTheme.textPrimary,
                      elevation: 4,
                      shadowColor: isFasting
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
                          iconName: isFasting ? 'stop' : 'play_arrow',
                          color: AppTheme.textPrimary,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        if (!isFasting && widget.muted) ...[
                          Tooltip(
                            message: () {
                              if (widget.muteUntil == null) return 'Notificações silenciadas';
                              final u = widget.muteUntil!;
                              String two(int v) => v.toString().padLeft(2, '0');
                              return 'Silenciado até ${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
                            }(),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 16,
                              color: (Color.lerp(AppTheme.warningAmber, Colors.white, 0.2) ?? AppTheme.warningAmber),
                            ),
                          ),
                          SizedBox(width: 1.2.w),
                        ],
                        Text(
                          label,
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
              ),
              if (!widget.isFasting && widget.muted) ...[
                SizedBox(height: 0.8.h),
                Builder(builder: (context) {
                  final untilLabel = () {
                    if (widget.muteUntil == null) return '';
                    final u = widget.muteUntil!;
                    String two(int v) => v.toString().padLeft(2, '0');
                    return '${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
                  }();
                  return Text(
                    untilLabel.isNotEmpty
                        ? 'Notificações silenciadas até $untilLabel — término sem notificação'
                        : 'Notificações silenciadas — término sem notificação',
                    textAlign: TextAlign.center,
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                })
              ],
            ],
          ),
        );
      },
    );
  }
}
