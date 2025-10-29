import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrapper que adiciona animação de escala e feedback tátil a qualquer widget clicável.
///
/// Quando pressionado, o widget diminui ligeiramente (scale: 0.95) e fornece
/// feedback háptico, criando uma sensação tátil satisfatória.
///
/// Uso:
/// ```dart
/// AnimatedScaleButton(
///   onTap: () { ... },
///   child: ElevatedButton(...),
/// )
/// ```
class AnimatedScaleButton extends StatefulWidget {
  /// Widget filho que receberá a animação
  final Widget child;

  /// Callback executado ao tocar
  final VoidCallback? onTap;

  /// Callback executado ao pressionar e segurar
  final VoidCallback? onLongPress;

  /// Escala quando pressionado (padrão: 0.95 = 95% do tamanho original)
  final double scaleOnTap;

  /// Duração da animação de escala (padrão: 100ms)
  final Duration duration;

  /// Se deve fornecer feedback háptico (padrão: true)
  final bool enableHaptic;

  /// Tipo de feedback háptico (padrão: light)
  final HapticFeedbackType hapticType;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleOnTap = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      _performHaptic();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _performHaptic() {
    switch (widget.hapticType) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Tipos de feedback háptico disponíveis
enum HapticFeedbackType {
  /// Impacto leve - para toques comuns
  light,

  /// Impacto médio - para ações importantes
  medium,

  /// Impacto pesado - para ações críticas
  heavy,

  /// Click de seleção - para mudanças de estado
  selection,
}

/// Widget que adiciona fade-in animation quando aparece na tela
///
/// Uso:
/// ```dart
/// FadeInWidget(
///   child: Card(...),
/// )
/// ```
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // Slide up 5%
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
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
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Extension para adicionar animação facilmente a qualquer widget
extension AnimatedWidgetExtension on Widget {
  /// Adiciona animação de escala ao tocar
  Widget withScaleAnimation({
    VoidCallback? onTap,
    double scale = 0.95,
    bool enableHaptic = true,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      scaleOnTap: scale,
      enableHaptic: enableHaptic,
      child: this,
    );
  }

  /// Adiciona animação de fade-in ao aparecer
  Widget withFadeIn({
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
  }) {
    return FadeInWidget(
      duration: duration,
      delay: delay,
      child: this,
    );
  }
}
