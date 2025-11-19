import 'package:flutter/material.dart';

class RippleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? rippleColor;

  const RippleButton({
    Key? key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.rippleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        splashColor: (rippleColor ?? Theme.of(context).primaryColor)
            .withValues(alpha: 0.3),
        highlightColor: (rippleColor ?? Theme.of(context).primaryColor)
            .withValues(alpha: 0.1),
        child: child,
      ),
    );
  }
}

