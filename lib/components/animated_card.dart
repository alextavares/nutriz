import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  /// Delay before the animation starts, in milliseconds.
  final int delay;

  /// Total duration of the entrance animation.
  final Duration duration;

  /// Where the slide should begin from.
  ///
  /// Use small values (e.g. `Offset(0, .08)`) for subtle motion.
  final Offset beginOffset;

  /// Starting opacity. Defaults to 0 (fully transparent).
  final double fadeBegin;

  /// Curve for the slide animation.
  final Curve slideCurve;

  /// Curve for the fade animation.
  final Curve fadeCurve;

  /// Optional subtle scale from [initialScale] -> 1.0. Defaults to 1 (disabled).
  final double initialScale;

  /// Optional tap handler to provide ripple feedback without extra wrapping.
  final VoidCallback? onTap;

  /// Optional border radius for the tap ripple. Falls back to AppRadii.card.
  final BorderRadius? borderRadius;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 600),
    this.beginOffset = const Offset(0, 0.08),
    this.fadeBegin = 0.0,
    this.slideCurve = Curves.easeOut,
    this.fadeCurve = Curves.easeIn,
    this.initialScale = 1.0,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: widget.slideCurve));
    _fade = Tween<double>(begin: widget.fadeBegin, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: widget.fadeCurve));
    _scale = Tween<double>(begin: widget.initialScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Respect accessibility reduced motion preferences by skipping animation.
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      final media = MediaQuery.maybeOf(context);
      final reduceMotion = media?.accessibleNavigation ?? false;
      if (reduceMotion) {
        _controller.value = 1.0;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    // Optional ripple if onTap provided (keeps layout intact when null).
    if (widget.onTap != null) {
      final radius = widget.borderRadius ?? BorderRadius.circular(AppRadii.card);
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    // Short-circuit if user requests reduced motion.
    final media = MediaQuery.maybeOf(context);
    final reduceMotion = media?.accessibleNavigation ?? false;
    if (reduceMotion) return content;

    // Compose animations: fade + slide (+ optional scale).
    Widget animated = SlideTransition(position: _slide, child: content);
    if (widget.initialScale != 1.0) {
      animated = ScaleTransition(scale: _scale, child: animated);
    }
    return FadeTransition(opacity: _fade, child: animated);
  }
}
