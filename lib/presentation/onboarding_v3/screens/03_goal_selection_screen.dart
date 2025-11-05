import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/onboarding_theme.dart';
import '../widgets/onboarding_progress_indicator.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../provider/onboarding_provider.dart';

/// 🎯 TELA 03 - GOAL SELECTION
///
/// Pergunta "What's your main goal?"
/// Opções: Lose weight, Eat healthier, Gain weight, Build muscle, Something else
class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  List<Map<String, dynamic>> _getGoals(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'id': 'lose_weight',
        'label': l10n.onbV3GoalLoseWeight,
        'icon': Icons.trending_down,
      },
      {
        'id': 'gain_weight',
        'label': l10n.onbV3GoalGainWeight,
        'icon': Icons.trending_up,
      },
      {
        'id': 'maintain',
        'label': l10n.onbV3GoalMaintain,
        'icon': Icons.trending_flat,
      },
    ];
  }

  void _onGoalSelected(String goalId) {
    setState(() {
      _selectedGoal = goalId;
    });
  }

  Future<void> _onContinue() async {
    if (_selectedGoal == null) return;

    final provider = Provider.of<OnboardingV3Provider>(context, listen: false);

    // Salvar objetivo no provider
    provider.setGoal(_selectedGoal!);

    // Marcar onboarding como completo
    await provider.completeOnboarding();

    // Navegar para dashboard
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/daily-tracking-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.onbV3AppBarSetup,
          style: OnboardingTheme.bodyStyle.copyWith(
            fontWeight: OnboardingTheme.fontWeightSemiBold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: OnboardingTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            const OnboardingProgressIndicator(
              currentStep: 1,
              totalSteps: 15,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: OnboardingTheme.spaceLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: OnboardingTheme.spaceLG),

                    // Título da pergunta
                    Text(
                      AppLocalizations.of(context)!.onbV3GoalTitle,
                      style: OnboardingTheme.headingStyle,
                    ),

                    SizedBox(height: OnboardingTheme.spaceXL),

                    // Lista de opções
                    ..._getGoals(context).map((goal) {
                      return _buildGoalOption(
                        id: goal['id']!,
                        label: goal['label']!,
                        icon: goal['icon']!,
                        isSelected: _selectedGoal == goal['id'],
                      );
                    }).toList(),

                    SizedBox(height: OnboardingTheme.spaceXL),
                  ],
                ),
              ),
            ),

            // Botão Continue (fixo no rodapé)
            Padding(
              padding: EdgeInsets.all(OnboardingTheme.spaceLG),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedGoal != null ? _onContinue : null,
                  style: OnboardingTheme.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return OnboardingTheme.border;
                      }
                      return OnboardingTheme.primary;
                    }),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.onbV3GoalContinue,
                    style: OnboardingTheme.buttonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de opção de objetivo
  Widget _buildGoalOption({
    required String id,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: OnboardingTheme.spaceMD),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onGoalSelected(id),
          borderRadius: BorderRadius.circular(OnboardingTheme.borderRadiusCard),
          child: AnimatedContainer(
            duration: OnboardingTheme.animationDuration,
            curve: OnboardingTheme.animationCurve,
            padding: EdgeInsets.all(OnboardingTheme.spaceLG),
            decoration: isSelected
                ? OnboardingTheme.cardDecorationSelected
                : OnboardingTheme.cardDecoration,
            child: Row(
              children: [
                // Ícone do objetivo (seta)
                Icon(
                  icon,
                  size: 24.sp,
                  color: isSelected
                      ? OnboardingTheme.primary
                      : OnboardingTheme.textSecondary,
                ),

                SizedBox(width: OnboardingTheme.spaceMD),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: OnboardingTheme.bodyStyle.copyWith(
                      fontWeight: isSelected
                          ? OnboardingTheme.fontWeightSemiBold
                          : OnboardingTheme.fontWeightRegular,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
