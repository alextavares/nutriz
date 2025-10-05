import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/design_tokens.dart';

class ActionButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback? onWater;
  final VoidCallback? onExercise;
  final VoidCallback? onAi;

  const ActionButtonWidget({
    super.key,
    required this.onPressed,
    this.onWater,
    this.onExercise,
    this.onAi,
  });

  @override
  State<ActionButtonWidget> createState() => _ActionButtonWidgetState();
}

class _ActionButtonWidgetState extends State<ActionButtonWidget>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textStyles;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTapDown: (_) => _animationController.forward(),
                  onTapUp: (_) {
                    _animationController.reverse();
                    widget.onPressed();
                  },
                  onTapCancel: () => _animationController.reverse(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🍽️',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Agora: Comer',
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 1.h),
          QuickActionsRow(
            onWater: widget.onWater,
            onExercise: widget.onExercise,
            onAi: widget.onAi,
          ),
        ],
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onWater;
  final VoidCallback? onExercise;
  final VoidCallback? onAi;

  const QuickActionsRow({super.key, this.onWater, this.onExercise, this.onAi});

  @override
  Widget build(BuildContext context) {
    if (onWater == null && onExercise == null && onAi == null)
      return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onAi != null)
            TextButton.icon(
              onPressed: onAi,
              icon: const Text('🧠'),
              label: const Text('IA'),
            ),
          if (onWater != null)
            TextButton.icon(
              onPressed: onWater,
              icon: const Text('💧'),
              label: const Text('+250ml'),
            ),
          if (onExercise != null)
            TextButton.icon(
              onPressed: onExercise,
              icon: const Text('🏃'),
              label: const Text('+100 kcal'),
            ),
        ],
      ),
    );
  }
}
