import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import 'widgets/onboarding_progress_bar.dart';
import 'widgets/option_card.dart';
import 'widgets/binary_choice_card.dart';
import 'widgets/numeric_input_widget.dart';
import 'widgets/hold_to_commit_widget.dart';

/// New comprehensive onboarding flow (Yazio-inspired, improved)
///
/// 18 screens total with personalization, education, and gamification
class NewOnboardingV2 extends StatefulWidget {
  const NewOnboardingV2({super.key});

  @override
  State<NewOnboardingV2> createState() => _NewOnboardingV2State();
}

class _NewOnboardingV2State extends State<NewOnboardingV2> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 18;

  // User data collection
  String? _motivation;
  String? _goal; // lose, gain, maintain
  final TextEditingController _currentWeightCtrl = TextEditingController(text: '70');
  final TextEditingController _goalWeightCtrl = TextEditingController(text: '65');
  bool _useKg = true;

  final TextEditingController _heightCtrl = TextEditingController(text: '170');
  bool _heightInCm = true;
  String? _sex;
  final TextEditingController _ageCtrl = TextEditingController(text: '30');

  String? _activityLevel;
  bool? _isVegetarian;
  bool? _usesIntermittentFasting;
  String? _fastingProtocol;

  int? _streakChallenge; // 7, 14, 30 days
  bool _commitmentComplete = false;

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    // Save all collected data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed_v2', true);
    await prefs.setBool('is_first_launch', false);

    // Save user data to UserPreferences
    final currentWeight = double.tryParse(_currentWeightCtrl.text) ?? 70.0;
    final goalWeight = double.tryParse(_goalWeightCtrl.text) ?? 65.0;
    final height = double.tryParse(_heightCtrl.text) ?? 170.0;
    final age = int.tryParse(_ageCtrl.text) ?? 30;

    // Convert to kg if needed
    final weightInKg = _useKg ? currentWeight : currentWeight * 0.453592;
    final goalWeightInKg = _useKg ? goalWeight : goalWeight * 0.453592;
    final heightInCm = _heightInCm ? height : height * 2.54;

    // Calculate BMR and TDEE based on collected data
    // This is a simplified Mifflin-St Jeor equation
    double bmr;
    if (_sex == 'male') {
      bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) - 161;
    }

    // Activity multiplier
    double activityMultiplier = 1.2; // sedentary default
    switch (_activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'very_active':
        activityMultiplier = 1.725;
        break;
      case 'extra_active':
        activityMultiplier = 1.9;
        break;
    }

    final tdee = bmr * activityMultiplier;

    // Adjust for goal
    double calorieGoal = tdee;
    if (_goal == 'lose') {
      calorieGoal = tdee - 500; // 500 calorie deficit
    } else if (_goal == 'gain') {
      calorieGoal = tdee + 300; // 300 calorie surplus
    }

    // Save goals (this would integrate with existing goals system)
    await prefs.setDouble('daily_calorie_goal', calorieGoal);
    await prefs.setString('goal_type', _goal ?? 'maintain');
    await prefs.setDouble('current_weight_kg', weightInKg);
    await prefs.setDouble('goal_weight_kg', goalWeightInKg);
    await prefs.setBool('uses_intermittent_fasting', _usesIntermittentFasting ?? false);
    if (_fastingProtocol != null) {
      await prefs.setString('fasting_protocol', _fastingProtocol!);
    }
    await prefs.setInt('streak_challenge_days', _streakChallenge ?? 7);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
        title: const Text('Configuração'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            OnboardingProgressBar(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                children: [
                  _buildWelcomeScreen(),
                  _buildMotivationScreen(),
                  _buildGoalScreen(),
                  _buildCurrentWeightScreen(),
                  _buildGoalWeightScreen(),
                  _buildHeightScreen(),
                  _buildSexScreen(),
                  _buildAgeScreen(),
                  _buildActivityLevelScreen(),
                  _buildDietPreferencesScreen(),
                  _buildIntermittentFastingScreen(),
                  _buildFastingProtocolScreen(),
                  _buildEducationalScreen1(),
                  _buildEducationalScreen2(),
                  _buildStreakChallengeScreen(),
                  _buildCommitmentScreen(),
                  _buildPremiumScreen(),
                  _buildReadyScreen(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    bool canProceed = _canProceed();

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canProceed ? _next : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.activeBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _currentStep == _totalSteps - 1 ? 'Começar!' : 'Continuar',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return _motivation != null;
      case 2:
        return _goal != null;
      case 3:
        return _currentWeightCtrl.text.isNotEmpty;
      case 4:
        return _goalWeightCtrl.text.isNotEmpty;
      case 5:
        return _heightCtrl.text.isNotEmpty;
      case 6:
        return _sex != null;
      case 7:
        return _ageCtrl.text.isNotEmpty;
      case 8:
        return _activityLevel != null;
      case 9:
        return _isVegetarian != null;
      case 10:
        return _usesIntermittentFasting != null;
      case 11:
        return _usesIntermittentFasting == false || _fastingProtocol != null;
      case 14:
        return _streakChallenge != null;
      case 15:
        return _commitmentComplete;
      default:
        return true;
    }
  }

  // SCREEN 0: Welcome
  Widget _buildWelcomeScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for illustration
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.activeBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 30.w,
              color: AppTheme.activeBlue,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Bem-vindo ao NutriTracker!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Vamos personalizar sua jornada nutricional em alguns passos simples.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  // SCREEN 1: Motivation
  Widget _buildMotivationScreen() {
    final options = [
      {'text': 'Quero construir hábitos mais saudáveis', 'value': 'habits'},
      {'text': 'Tenho nova motivação para começar', 'value': 'motivation'},
      {'text': 'Quero me sentir mais confiante', 'value': 'confidence'},
      {'text': 'Estou insatisfeito com meu peso atual', 'value': 'weight'},
      {'text': 'Vi uma foto que não gostei', 'value': 'photo'},
      {'text': 'Tenho uma razão diferente', 'value': 'other'},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'O que te traz aqui?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 3.h),
          ...options.map<Widget>((option) {
            final String value = option['value'] as String;
            return OptionCard(
              text: option['text'] as String,
              selected: _motivation == value,
              onTap: () {
                setState(() => _motivation = value);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  // SCREEN 2: Goal (lose/gain/maintain)
  Widget _buildGoalScreen() {
    final options = [
      {'text': 'Perder peso', 'value': 'lose', 'icon': Icons.trending_down},
      {'text': 'Ganhar peso', 'value': 'gain', 'icon': Icons.trending_up},
      {'text': 'Manter peso', 'value': 'maintain', 'icon': Icons.trending_flat},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'Qual é o seu objetivo principal?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 3.h),
          ...options.map<Widget>((option) {
            final String value = option['value'] as String;
            final IconData iconData = option['icon'] as IconData;
            return OptionCard(
              text: option['text'] as String,
              selected: _goal == value,
              onTap: () {
                setState(() => _goal = value);
              },
              leading: Icon(
                iconData,
                color: _goal == value
                    ? AppTheme.activeBlue
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // SCREEN 3: Current Weight
  Widget _buildCurrentWeightScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Qual é o seu peso atual?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Não precisa ser exato. Você pode ajustar depois.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 6.h),
          NumericInputWidget(
            controller: _currentWeightCtrl,
            unit1: 'kg',
            unit2: 'lb',
            selectedUnit1: _useKg,
            onUnitChange: (value) {
              setState(() => _useKg = value);
            },
          ),
        ],
      ),
    );
  }

  // SCREEN 4: Goal Weight
  Widget _buildGoalWeightScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Vamos definir a meta que você vai alcançar!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          NumericInputWidget(
            controller: _goalWeightCtrl,
            unit1: 'kg',
            unit2: 'lb',
            selectedUnit1: _useKg,
            onUnitChange: (value) {
              setState(() => _useKg = value);
            },
          ),
        ],
      ),
    );
  }

  // SCREEN 5: Height
  Widget _buildHeightScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Qual é a sua altura?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          NumericInputWidget(
            controller: _heightCtrl,
            unit1: 'cm',
            unit2: 'in',
            selectedUnit1: _heightInCm,
            onUnitChange: (value) {
              setState(() => _heightInCm = value);
            },
          ),
        ],
      ),
    );
  }

  // SCREEN 6: Sex
  Widget _buildSexScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Qual é o seu sexo biológico?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Isso nos ajuda a calcular suas necessidades calóricas com mais precisão.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 6.h),
          BinaryChoiceCard(
            leftText: 'Masculino',
            rightText: 'Feminino',
            selected: _sex == 'male' ? true : (_sex == 'female' ? false : null),
            onSelect: (value) {
              setState(() => _sex = value ? 'male' : 'female');
            },
          ),
        ],
      ),
    );
  }

  // SCREEN 7: Age
  Widget _buildAgeScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Qual é a sua idade?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          NumericInputWidget(
            controller: _ageCtrl,
            hint: '25',
          ),
        ],
      ),
    );
  }

  // SCREEN 8: Activity Level
  Widget _buildActivityLevelScreen() {
    final options = [
      {
        'text': 'Sedentário',
        'subtitle': 'Pouco ou nenhum exercício',
        'value': 'sedentary'
      },
      {
        'text': 'Levemente ativo',
        'subtitle': 'Exercício leve 1-3 dias/semana',
        'value': 'light'
      },
      {
        'text': 'Moderadamente ativo',
        'subtitle': 'Exercício moderado 3-5 dias/semana',
        'value': 'moderate'
      },
      {
        'text': 'Muito ativo',
        'subtitle': 'Exercício intenso 6-7 dias/semana',
        'value': 'very_active'
      },
      {
        'text': 'Extremamente ativo',
        'subtitle': 'Exercício muito intenso, trabalho físico',
        'value': 'extra_active'
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'Qual é o seu nível de atividade física?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 3.h),
          ...options.map((option) {
            final isSelected = _activityLevel == option['value'];
            return Padding(
              padding: EdgeInsets.only(bottom: 2.w),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _activityLevel = option['value'] as String);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
                          : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['text']!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          option['subtitle']!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // SCREEN 9: Diet Preferences
  Widget _buildDietPreferencesScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Você segue alguma dieta especial?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Vamos começar com vegetarianismo. Podemos adicionar mais depois.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 6.h),
          BinaryChoiceCard(
            leftText: 'Sim, sou vegetariano',
            rightText: 'Não',
            selected: _isVegetarian,
            onSelect: (value) {
              setState(() => _isVegetarian = value);
            },
          ),
        ],
      ),
    );
  }

  // SCREEN 10: Intermittent Fasting
  Widget _buildIntermittentFastingScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              size: 30.w,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Você pratica jejum intermitente?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'O jejum intermitente pode ser uma ferramenta poderosa para alcançar seus objetivos.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 6.h),
          BinaryChoiceCard(
            leftText: 'Sim',
            rightText: 'Não',
            selected: _usesIntermittentFasting,
            onSelect: (value) {
              setState(() => _usesIntermittentFasting = value);
            },
          ),
        ],
      ),
    );
  }

  // SCREEN 11: Fasting Protocol (conditional)
  Widget _buildFastingProtocolScreen() {
    if (_usesIntermittentFasting == false) {
      return _buildEducationalIfScreen();
    }

    final options = [
      {'text': '16/8 (16h jejum, 8h alimentação)', 'value': '16_8'},
      {'text': '18/6 (18h jejum, 6h alimentação)', 'value': '18_6'},
      {'text': '20/4 (20h jejum, 4h alimentação)', 'value': '20_4'},
      {'text': '24h (uma refeição por dia)', 'value': 'omad'},
      {'text': 'Outro protocolo', 'value': 'other'},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'Qual protocolo você usa?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 3.h),
          ...options.map<Widget>((option) {
            final String value = option['value'] as String;
            return OptionCard(
              text: option['text'] as String,
              selected: _fastingProtocol == value,
              onTap: () {
                setState(() => _fastingProtocol = value);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEducationalIfScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 30.w,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Você sabia?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'O jejum intermitente pode ajudar na perda de peso, melhorar a sensibilidade à insulina e promover a autofagia celular.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Você pode explorar o jejum intermitente a qualquer momento no app!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.activeBlue,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  // SCREEN 12 & 13: Educational screens (to be continued...)
  Widget _buildEducationalScreen1() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.activeBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_down,
              size: 30.w,
              color: AppTheme.activeBlue,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Diga olá à perda de peso sustentável!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Com o NutriTracker, você pode comer o que quiser. Sem mais restrições ou regras complexas.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successGreen, size: 8.w),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Ajudamos você a alcançar perda de peso sustentável de uma forma que se adapta ao seu estilo de vida.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalScreen2() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.activeBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop,
              size: 30.w,
              color: AppTheme.activeBlue,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Hidratação é fundamental!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Beber água adequadamente pode aumentar seu metabolismo em até 30% e ajudar na sensação de saciedade.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.activeBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 8.w),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Vamos te lembrar de beber água regularmente ao longo do dia!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 14: Streak Challenge
  Widget _buildStreakChallengeScreen() {
    final options = [
      {'text': '30 dias seguidos (Incrível!)', 'value': 30, 'emoji': '🚀'},
      {'text': '14 dias seguidos (Ótimo)', 'value': 14, 'emoji': '🚴'},
      {'text': '7 dias seguidos (Bom)', 'value': 7, 'emoji': '🏃'},
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            'Hora do desafio!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Quantos dias seguidos você consegue rastrear?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 3.h),
          ...options.map<Widget>((option) {
            final int value = option['value'] as int;
            final isSelected = _streakChallenge == value;
            return OptionCard(
              text: option['text'] as String,
              selected: isSelected,
              onTap: () {
                setState(() => _streakChallenge = value);
              },
              leading: Text(
                option['emoji'] as String,
                style: TextStyle(fontSize: 24.sp),
              ),
            );
          }).toList(),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange, size: 6.w),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Sequências te ajudam a manter consistência e alcançar suas metas!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 15: Hold-to-Commit
  Widget _buildCommitmentScreen() {
    return HoldToCommitWidget(
      commitmentText:
          'Eu vou usar o NutriTracker para entender e melhorar meus hábitos alimentares e alcançar minhas metas com sucesso!',
      onCommitComplete: () {
        setState(() => _commitmentComplete = true);
      },
    );
  }

  // SCREEN 16: Premium Features
  Widget _buildPremiumScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber,
                  Colors.orange,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              size: 30.w,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Alguns recursos são PRO',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 3.h),
          _buildPremiumFeature(
            Icons.track_changes,
            'Acompanhamento avançado de macronutrientes',
          ),
          _buildPremiumFeature(
            Icons.restaurant,
            'Acesso a mais de 2.500 receitas',
          ),
          _buildPremiumFeature(
            Icons.insights,
            'Insights e relatórios detalhados',
          ),
          _buildPremiumFeature(
            Icons.local_fire_department,
            'Recursos avançados de jejum intermitente',
          ),
          SizedBox(height: 2.h),
          Text(
            'Você pode experimentar o app gratuitamente e fazer upgrade quando quiser!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber[700], size: 6.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 17: Ready to Start
  Widget _buildReadyScreen() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 30.w,
              color: AppTheme.successGreen,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Pronto para começar sua jornada!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Tudo está configurado! Vamos começar a rastrear sua nutrição e alcançar suas metas juntos.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.activeBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.activeBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.celebration, color: AppTheme.activeBlue, size: 10.w),
                SizedBox(height: 1.h),
                Text(
                  'Você está no caminho certo para uma vida mais saudável!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.activeBlue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
