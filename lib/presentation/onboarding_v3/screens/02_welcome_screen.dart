import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/theme/onboarding_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 🎉 TELA 02 - WELCOME SCREEN
///
/// Tela de boas-vindas com estatísticas do app
/// Mostra "85 million happy users" e "20 million foods for calorie tracking"
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: OnboardingTheme.spaceLG,
          ),
          child: Column(
            children: [
              // Logo no topo
              SizedBox(height: OnboardingTheme.spaceXL),
              Text(
                AppLocalizations.of(context)!.onbV3WelcomeTitle,
                style: TextStyle(
                  fontFamily: OnboardingTheme.fontFamily,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: OnboardingTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),

              const Spacer(),

              // Estatística 1 - Happy Users
              _buildStatCard(
                context: context,
                text: AppLocalizations.of(context)!.onbV3Welcome85Million,
                color: OnboardingTheme.primary,
              ),

              SizedBox(height: OnboardingTheme.spaceLG),

              // Estatística 2 - Foods for Tracking
              _buildStatCard(
                context: context,
                text: AppLocalizations.of(context)!.onbV3Welcome20Million,
                color: OnboardingTheme.goalGainMuscle,
              ),

              const Spacer(),

              // Texto motivacional
              Text(
                AppLocalizations.of(context)!.onbV3WelcomeSubtitle,
                textAlign: TextAlign.center,
                style: OnboardingTheme.headingStyle.copyWith(
                  height: 1.3,
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceXL),

              // Botão "Get Started"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/onboarding/goal');
                  },
                  style: OnboardingTheme.primaryButtonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.onbV3WelcomeGetStarted,
                    style: OnboardingTheme.buttonTextStyle,
                  ),
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Link "I Already Have an Account"
              TextButton(
                onPressed: () {
                  // Navegar para login (fora do onboarding)
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: OnboardingTheme.textButtonStyle,
                child: Text(
                  AppLocalizations.of(context)!.onbV3WelcomeAlreadyHaveAccount,
                  style: OnboardingTheme.bodyStyle.copyWith(
                    color: OnboardingTheme.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  /// Card de estatística com texto completo
  Widget _buildStatCard({
    required BuildContext context,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: OnboardingTheme.spaceXL,
        vertical: OnboardingTheme.spaceLG,
      ),
      decoration: BoxDecoration(
        color: OnboardingTheme.background,
        borderRadius: BorderRadius.circular(OnboardingTheme.borderRadiusCard),
        border: Border.all(
          color: OnboardingTheme.border,
          width: OnboardingTheme.borderWidth,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLaurelBranch(isLeft: true, color: color),
          SizedBox(width: OnboardingTheme.spaceMD),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: OnboardingTheme.bodyStyle.copyWith(
                fontWeight: OnboardingTheme.fontWeightSemiBold,
                color: OnboardingTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(width: OnboardingTheme.spaceMD),
          _buildLaurelBranch(isLeft: false, color: color),
        ],
      ),
    );
  }

  /// Ramo de louros decorativo
  Widget _buildLaurelBranch({
    required bool isLeft,
    required Color color,
  }) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(isLeft ? -1.0 : 1.0, 1.0), // Espelhar se for o ramo esquerdo
      alignment: Alignment.center,
      child: Icon(
        Icons.eco_outlined,
        color: color,
        size: 24.sp,
      ),
    );
  }
}
