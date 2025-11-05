import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/theme/onboarding_theme.dart';
import '../widgets/onboarding_progress_indicator.dart';

/// 👤 TELA 05 - GENDER SELECTION
///
/// Pergunta "What's your sex?"
/// Opções: Female / Male (lado a lado como cards grandes)
/// Texto explicativo sobre cálculo preciso
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  void _onGenderSelected(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _onContinue() {
    if (_selectedGender == null) return;

    // TODO: Salvar no provider
    // provider.setGender(_selectedGender!);

    // Navegar para próxima tela (dados pessoais)
    Navigator.of(context).pushNamed('/onboarding/personal-data');
  }

  void _onSkip() {
    // Mostrar diálogo explicando importância
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Por que precisamos saber?'),
        content: Text(
          'Seu sexo biológico nos ajuda a calcular suas necessidades calóricas com mais precisão. '
          'Homens e mulheres têm metabolismos diferentes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: OnboardingTheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            const OnboardingProgressIndicator(
              currentStep: 3,
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
                      'What\'s your sex?',
                      style: OnboardingTheme.headingStyle,
                    ),

                    SizedBox(height: OnboardingTheme.spaceSM),

                    // Texto explicativo
                    Text(
                      'Since the formula for an accurate calorie calculation differs based on sex, we need this information.',
                      style: OnboardingTheme.bodyStyle.copyWith(
                        color: OnboardingTheme.textSecondary,
                      ),
                    ),

                    SizedBox(height: OnboardingTheme.spaceXL),

                    // Opções de gênero (lado a lado)
                    Row(
                      children: [
                        // Opção: Female
                        Expanded(
                          child: _buildGenderCard(
                            gender: 'female',
                            label: 'Female',
                            isSelected: _selectedGender == 'female',
                          ),
                        ),

                        SizedBox(width: OnboardingTheme.spaceMD),

                        // Opção: Male
                        Expanded(
                          child: _buildGenderCard(
                            gender: 'male',
                            label: 'Male',
                            isSelected: _selectedGender == 'male',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: OnboardingTheme.spaceXL),

                    // Link "Why do we should collect?"
                    Center(
                      child: TextButton.icon(
                        onPressed: _onSkip,
                        icon: Icon(
                          Icons.help_outline,
                          size: 18.sp,
                          color: OnboardingTheme.textSecondary,
                        ),
                        label: Text(
                          'Why do we should collect?',
                          style: OnboardingTheme.smallStyle.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

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
                  onPressed: _selectedGender != null ? _onContinue : null,
                  style: OnboardingTheme.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return OnboardingTheme.border;
                      }
                      return OnboardingTheme.primary;
                    }),
                  ),
                  child: Text(
                    'Continue',
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

  /// Card grande de seleção de gênero
  Widget _buildGenderCard({
    required String gender,
    required String label,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onGenderSelected(gender),
        borderRadius: BorderRadius.circular(OnboardingTheme.borderRadiusCard),
        child: AnimatedContainer(
          duration: OnboardingTheme.animationDuration,
          curve: OnboardingTheme.animationCurve,
          height: 25.h,
          decoration: isSelected
              ? OnboardingTheme.cardDecorationSelected
              : OnboardingTheme.cardDecoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de gênero
              Icon(
                gender == 'female' ? Icons.female : Icons.male,
                size: 48.sp,
                color: isSelected
                    ? OnboardingTheme.primary
                    : OnboardingTheme.textSecondary,
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Label
              Text(
                label,
                style: OnboardingTheme.headingStyle.copyWith(
                  fontSize: OnboardingTheme.fontSizeSubtitle,
                  fontWeight: isSelected
                      ? OnboardingTheme.fontWeightBold
                      : OnboardingTheme.fontWeightSemiBold,
                  color: isSelected
                      ? OnboardingTheme.textPrimary
                      : OnboardingTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
