import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/theme/onboarding_theme.dart';
import '../widgets/onboarding_progress_indicator.dart';

/// 📱 TELA 04 - DISCOVERY SOURCE
///
/// Pergunta "How did you hear about Yazio?"
/// Lista de fontes: Instagram, Facebook, TikTok, YouTube, etc.
class DiscoverySourceScreen extends StatefulWidget {
  const DiscoverySourceScreen({super.key});

  @override
  State<DiscoverySourceScreen> createState() => _DiscoverySourceScreenState();
}

class _DiscoverySourceScreenState extends State<DiscoverySourceScreen> {
  String? _selectedSource;

  final List<Map<String, dynamic>> _sources = [
    {'id': 'instagram', 'label': 'Instagram', 'icon': '📷'},
    {'id': 'facebook', 'label': 'Facebook', 'icon': '👥'},
    {'id': 'tiktok', 'label': 'TikTok', 'icon': '🎵'},
    {'id': 'youtube', 'label': 'YouTube', 'icon': '📺'},
    {'id': 'friends_family', 'label': 'Friends and family', 'icon': '👨‍👩‍👧‍👦'},
    {'id': 'creator_influencer', 'label': 'Creator or influencer', 'icon': '⭐'},
    {'id': 'coupon_website', 'label': 'Coupon website', 'icon': '🎟️'},
    {'id': 'search_engine', 'label': 'Search engine (e.g., Google)', 'icon': '🔍'},
    {'id': 'google_play', 'label': 'Google Play', 'icon': '📱'},
    {'id': 'app_store', 'label': 'App Store', 'icon': '🍎'},
  ];

  void _onSourceSelected(String sourceId) {
    setState(() {
      _selectedSource = sourceId;
    });
  }

  void _onContinue() {
    if (_selectedSource == null) return;

    // TODO: Salvar no provider
    // provider.setDiscoverySource(_selectedSource!);

    // Navegar para próxima tela
    Navigator.of(context).pushNamed('/onboarding/gender');
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
              currentStep: 2,
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
                      'How did you hear\nabout Yazio?',
                      style: OnboardingTheme.headingStyle,
                    ),

                    SizedBox(height: OnboardingTheme.spaceXL),

                    // Lista de fontes
                    ..._sources.map((source) {
                      return _buildSourceOption(
                        id: source['id']!,
                        label: source['label']!,
                        icon: source['icon']!,
                        isSelected: _selectedSource == source['id'],
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
                  onPressed: _selectedSource != null ? _onContinue : null,
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

  /// Card de opção de fonte de descoberta
  Widget _buildSourceOption({
    required String id,
    required String label,
    required String icon,
    required bool isSelected,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: OnboardingTheme.spaceMD),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSourceSelected(id),
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
                // Ícone (emoji)
                Text(
                  icon,
                  style: TextStyle(fontSize: 24.sp),
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

                // Ícone de seleção
                AnimatedContainer(
                  duration: OnboardingTheme.animationDuration,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? OnboardingTheme.primary
                          : OnboardingTheme.border,
                      width: 2,
                    ),
                    color: isSelected
                        ? OnboardingTheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
