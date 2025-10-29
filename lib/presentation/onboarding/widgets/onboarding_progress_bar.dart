import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

/// Animated progress bar for onboarding flow (Yazio-inspired)
///
/// Shows smooth progress animation with percentage completion
class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          tween: Tween(begin: 0.0, end: progress),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.activeBlue),
            );
          },
        ),
      ),
    );
  }
}
