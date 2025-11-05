import 'package:flutter/material.dart';
import '../../../core/theme/onboarding_theme.dart';

/// 📊 ONBOARDING PROGRESS INDICATOR
///
/// Barra de progresso animada no topo das telas de onboarding
/// Mostra quantos passos foram completados de X total
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: OnboardingTheme.spaceLG,
        vertical: OnboardingTheme.spaceSM,
      ),
      child: Column(
        children: [
          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(
              OnboardingTheme.progressBarRadius,
            ),
            child: TweenAnimationBuilder<double>(
              duration: OnboardingTheme.animationDuration,
              curve: OnboardingTheme.animationCurve,
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: OnboardingTheme.progressBarHeight,
                  backgroundColor: OnboardingTheme.progressBarBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    OnboardingTheme.progressBarForeground,
                  ),
                );
              },
            ),
          ),

          // Texto opcional mostrando "X de Y" (comentado por padrão)
          // SizedBox(height: OnboardingTheme.spaceXS),
          // Text(
          //   '$currentStep de $totalSteps',
          //   style: OnboardingTheme.smallStyle,
          // ),
        ],
      ),
    );
  }
}
