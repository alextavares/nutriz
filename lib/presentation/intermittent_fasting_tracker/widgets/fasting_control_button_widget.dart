import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../theme/design_tokens.dart';

class FastingControlButtonWidget extends StatefulWidget {
  final bool isFasting;
  final VoidCallback onStartFasting;
  final VoidCallback onStopFasting;
  final bool muted;
  final DateTime? muteUntil;
  final double? width;
  final double? height;

  const FastingControlButtonWidget({
    Key? key,
    required this.isFasting,
    required this.onStartFasting,
    required this.onStopFasting,
    this.muted = false,
    this.muteUntil,
    this.width,
    this.height,
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
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
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
        final colors = context.colors;
        final textTheme = Theme.of(context).textTheme;
        final semantics = context.semanticColors;
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: semantics.warning,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Parar Jejum?',
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Text(
            'Tem certeza que deseja interromper seu jejum atual? Seu progresso será salvo.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                try {
                  HapticFeedback.mediumImpact();
                } catch (_) {}
                widget.onStopFasting();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
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
        final colors = context.colors;
        final semantics = context.semanticColors;
        final textTheme = Theme.of(context).textTheme;
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: label,
                child: SizedBox(
                  width: widget.width ?? 80.w,
                  height: widget.height ?? 6.h,
                  child: ElevatedButton(
                    onPressed: _handleTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFasting ? colors.error : semantics.success,
                      foregroundColor:
                          isFasting ? colors.onError : colors.onPrimary,
                      elevation: 4,
                      shadowColor: isFasting
                          ? colors.error.withValues(alpha: 0.3)
                          : semantics.success.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: isFasting ? 'stop' : 'play_arrow',
                          color: isFasting ? colors.onError : colors.onPrimary,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        if (!isFasting && widget.muted) ...[
                          Tooltip(
                            message: () {
                              if (widget.muteUntil == null)
                                return 'Notificações silenciadas';
                              final u = widget.muteUntil!;
                              String two(int v) => v.toString().padLeft(2, '0');
                              return 'Silenciado até ${two(u.day)}/${two(u.month)} ${two(u.hour)}:${two(u.minute)}';
                            }(),
                            child: Icon(
                              Icons.notifications_off_outlined,
                              size: 16,
                              color: Color.lerp(
                                    semantics.warning,
                                    colors.onSurface,
                                    0.2,
                                  ) ??
                                  semantics.warning,
                            ),
                          ),
                          SizedBox(width: 1.2.w),
                        ],
                        Text(
                          label,
                          style: textTheme.labelLarge?.copyWith(
                            color:
                                isFasting ? colors.onError : colors.onPrimary,
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
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
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
