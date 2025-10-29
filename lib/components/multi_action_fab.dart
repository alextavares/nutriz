import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Multi-Action Floating Action Button
///
/// FAB que expande para mostrar múltiplas ações rápidas:
/// - Adicionar Refeição
/// - Adicionar Água
/// - Adicionar Atividade
class MultiActionFab extends StatefulWidget {
  final VoidCallback? onAddMeal;
  final VoidCallback? onAddWater;
  final VoidCallback? onAddActivity;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MultiActionFab({
    Key? key,
    this.onAddMeal,
    this.onAddWater,
    this.onAddActivity,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<MultiActionFab> createState() => _MultiActionFabState();
}

class _MultiActionFabState extends State<MultiActionFab>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
    ]).animate(_bounceController);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _bounceController.forward();
    });
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xFF3B82F6);
    final fgColor = widget.foregroundColor ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Backdrop quando expandido
        if (_isExpanded)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: 300,
            ),
          ),

        // Options (aparecem quando expandido)
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildOption(
                      icon: Icons.restaurant,
                      label: 'Adicionar Refeição',
                      color: const Color(0xFFFF6D00),
                      backgroundColor: const Color(0xFFFFF3E0),
                      onTap: () {
                        widget.onAddMeal?.call();
                        _toggle();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOption(
                      icon: Icons.water_drop,
                      label: 'Adicionar Água',
                      color: const Color(0xFF3B82F6),
                      backgroundColor: const Color(0xFFDBEAFE),
                      onTap: () {
                        widget.onAddWater?.call();
                        _toggle();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOption(
                      icon: Icons.directions_run,
                      label: 'Adicionar Atividade',
                      color: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFFD1FAE5),
                      onTap: () {
                        widget.onAddActivity?.call();
                        _toggle();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // Main FAB
        ScaleTransition(
          scale: _bounceAnimation,
          child: FloatingActionButton(
            onPressed: () {
              _bounceController
                ..reset()
                ..forward();
              _toggle();
            },
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            elevation: 4,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _expandAnimation,
              color: fgColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_expandAnimation),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Material(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              shadowColor: Colors.black.withOpacity(0.2),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Icon Button
            FloatingActionButton.small(
              onPressed: onTap,
              backgroundColor: backgroundColor,
              foregroundColor: color,
              heroTag: label,
              elevation: 4,
              child: Icon(icon, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }
}

