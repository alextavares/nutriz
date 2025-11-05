import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/theme/onboarding_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 🚀 TELA 01 - SPLASH SCREEN
///
/// Primeira tela do app mostrando o logo "nutriZ"
/// Auto-avança para tela de Welcome após 2 segundos
class OnboardingV3SplashScreen extends StatefulWidget {
  const OnboardingV3SplashScreen({super.key});

  @override
  State<OnboardingV3SplashScreen> createState() => _OnboardingV3SplashScreenState();
}

class _OnboardingV3SplashScreenState extends State<OnboardingV3SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animações
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Iniciar animação
    _controller.forward();

    // Auto-navegar após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/onboarding/welcome');
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
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo "nutriZ"
                      Text(
                        AppLocalizations.of(context)!.onbV3SplashTitle,
                        style: TextStyle(
                          fontFamily: OnboardingTheme.fontFamily,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w900,
                          color: OnboardingTheme.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),

                      SizedBox(height: OnboardingTheme.spaceXL),

                      // Ícones decorativos flutuantes
                      _buildFloatingIcons(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Ícones decorativos que aparecem ao redor do logo
  Widget _buildFloatingIcons() {
    return SizedBox(
      width: 80.w,
      height: 40.h,
      child: Stack(
        children: [
          // Ícone 1 - Tomate (canto superior esquerdo)
          Positioned(
            top: 10.h,
            left: 5.w,
            child: _FloatingIcon(
              icon: '🍅',
              delay: 0,
            ),
          ),

          // Ícone 2 - Cenoura (canto superior direito)
          Positioned(
            top: 5.h,
            right: 10.w,
            child: _FloatingIcon(
              icon: '🥕',
              delay: 200,
            ),
          ),

          // Ícone 3 - Berinjela (meio esquerdo)
          Positioned(
            top: 20.h,
            left: 2.w,
            child: _FloatingIcon(
              icon: '🍆',
              delay: 400,
            ),
          ),

          // Ícone 4 - Uva (meio)
          Positioned(
            top: 18.h,
            right: 15.w,
            child: _FloatingIcon(
              icon: '🍇',
              delay: 600,
            ),
          ),

          // Ícone 5 - Brócolis (parte inferior esquerda)
          Positioned(
            bottom: 5.h,
            left: 15.w,
            child: _FloatingIcon(
              icon: '🥦',
              delay: 800,
            ),

          ),

          // Ícone 6 - Presente (parte inferior direita)
          Positioned(
            bottom: 8.h,
            right: 5.w,
            child: _FloatingIcon(
              icon: '🎁',
              delay: 1000,
            ),
          ),

          // Ícone 7 - Maçã (canto inferior)
          Positioned(
            bottom: 0.h,
            left: 35.w,
            child: _FloatingIcon(
              icon: '🍎',
              delay: 1200,
            ),
          ),

          // Ícone 8 - Cenoura (canto direito)
          Positioned(
            top: 25.h,
            right: 2.w,
            child: _FloatingIcon(
              icon: '🥕',
              delay: 1400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de ícone flutuante animado
class _FloatingIcon extends StatefulWidget {
  final String icon;
  final int delay;

  const _FloatingIcon({
    required this.icon,
    required this.delay,
  });

  @override
  State<_FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<_FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Delay antes de animar
    Future.delayed(Duration(milliseconds: widget.delay), () {
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
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Text(
          widget.icon,
          style: TextStyle(fontSize: 32.sp),
        ),
      ),
    );
  }
}
