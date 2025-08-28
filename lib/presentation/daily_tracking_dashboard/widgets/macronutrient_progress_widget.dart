import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MacronutrientProgressWidget extends StatefulWidget {
  final String name;
  final int consumed;
  final int total;
  final Color color;
  final VoidCallback? onLongPress;

  const MacronutrientProgressWidget({
    super.key,
    required this.name,
    required this.consumed,
    required this.total,
    required this.color,
    this.onLongPress,
  });

  @override
  State<MacronutrientProgressWidget> createState() =>
      _MacronutrientProgressWidgetState();
}

class _MacronutrientProgressWidgetState
    extends State<MacronutrientProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage =
        widget.total > 0 ? (widget.consumed / widget.total) * 100 : 0.0;
    IconData icon;
    if (widget.name.toLowerCase().contains('carb')) {
      icon = Icons.bakery_dining;
    } else if (widget.name.toLowerCase().contains('prot')) {
      icon = Icons.set_meal;
    } else if (widget.name.toLowerCase().contains('gord') ||
        widget.name.toLowerCase().contains('fat')) {
      icon = Icons.local_pizza;
    } else {
      icon = Icons.circle;
    }

    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(icon, color: widget.color, size: 18),
                  SizedBox(width: 6),
                  Text(
                    widget.name,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
                Row(children: [
                  Text(
                    '${percentage.toInt()}%',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${widget.consumed}g / ${widget.total}g',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ],
            ),
            SizedBox(height: 0.6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    color: AppTheme.dividerGray.withValues(alpha: 0.6),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (percentage / 100) * _animation.value,
                        child: Container(height: 12, color: widget.color),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
