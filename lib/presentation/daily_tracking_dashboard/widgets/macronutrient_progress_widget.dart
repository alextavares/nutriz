import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../theme/design_tokens.dart';

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
    String _fmtInt(int v) {
      final locale = Localizations.localeOf(context).toString();
      return NumberFormat.decimalPattern(locale).format(v);
    }

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

    final textTheme = context.textStyles;
    final colors = context.colors;

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
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
                Row(children: [
                  Text(
                    '${percentage.toInt()}%',
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${_fmtInt(widget.consumed)} / ${_fmtInt(widget.total)} g',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ],
            ),
            SizedBox(height: 0.6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    color: widget.color.withValues(alpha: 0.18),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (percentage / 100).clamp(0.0, 1.0) *
                            _animation.value,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
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
