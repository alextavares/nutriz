import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

/// Interactive "hold-to-commit" widget - Yazio-inspired
///
/// Creates psychological commitment through gesture interaction
class HoldToCommitWidget extends StatefulWidget {
  final String commitmentText;
  final VoidCallback onCommitComplete;
  final Duration holdDuration;

  const HoldToCommitWidget({
    super.key,
    required this.commitmentText,
    required this.onCommitComplete,
    this.holdDuration = const Duration(seconds: 3),
  });

  @override
  State<HoldToCommitWidget> createState() => _HoldToCommitWidgetState();
}

class _HoldToCommitWidgetState extends State<HoldToCommitWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completed) {
        setState(() => _completed = true);
        widget.onCommitComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (_completed) return;
    setState(() => _isHolding = true);
    _controller.forward();
  }

  void _onPointerUp() {
    if (_completed) return;
    setState(() => _isHolding = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Commitment text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            widget.commitmentText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  height: 1.4,
                ),
          ),
        ),

        SizedBox(height: 6.h),

        // Hold circle
        GestureDetector(
          onTapDown: (_) => _onPointerDown(),
          onTapUp: (_) => _onPointerUp(),
          onTapCancel: _onPointerUp,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.activeBlue,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.activeBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: _controller.value * 10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Progress indicator
                    if (_isHolding && !_completed)
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: _controller.value,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),

                    // Center content
                    Center(
                      child: _completed
                          ? Icon(
                              Icons.check_circle,
                              size: 20.w,
                              color: Colors.white,
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 15.w,
                                  color: Colors.white,
                                ),
                                if (_isHolding) ...[
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Keep holding!',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        SizedBox(height: 4.h),

        // Instruction text
        if (!_completed)
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.activeBlue.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: AppTheme.activeBlue,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Tap and hold the icon to commit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.activeBlue,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
