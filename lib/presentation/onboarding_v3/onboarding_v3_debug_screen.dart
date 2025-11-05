import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../../core/theme/onboarding_theme.dart';
import 'provider/onboarding_provider.dart';

/// 🧪 DEBUG SCREEN - ONBOARDING V3
///
/// Tela para testar e visualizar o novo onboarding
/// Acesso rápido a todas as 3 telas
class OnboardingV3DebugScreen extends StatelessWidget {
  const OnboardingV3DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingV3Provider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('🧪 Onboarding V3 - Debug'),
        backgroundColor: OnboardingTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(OnboardingTheme.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                'Teste o Novo Onboarding',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: OnboardingTheme.textPrimary,
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Info sobre estado atual
              _buildInfoCard(
                title: 'Estado Atual',
                content: provider.goalType != null
                    ? 'Objetivo: ${provider.goalType}'
                    : 'Nenhum objetivo selecionado ainda',
                icon: Icons.info_outline,
                color: Colors.blue,
              ),

              SizedBox(height: OnboardingTheme.spaceLG),

              // Botões de navegação
              Text(
                'Navegar para:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: OnboardingTheme.textSecondary,
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Botão 1: Splash Screen
              _buildNavigationButton(
                context: context,
                title: '1️⃣ Splash Screen',
                subtitle: 'Logo animado com 8 ícones de comida',
                route: '/onboarding/splash',
                color: OnboardingTheme.primary,
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Botão 2: Welcome Screen
              _buildNavigationButton(
                context: context,
                title: '2️⃣ Welcome Screen',
                subtitle: '85M usuários + 20M alimentos',
                route: '/onboarding/welcome',
                color: OnboardingTheme.goalGainMuscle,
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Botão 3: Goal Selection
              _buildNavigationButton(
                context: context,
                title: '3️⃣ Goal Selection',
                subtitle: 'Escolher objetivo principal',
                route: '/onboarding/goal',
                color: OnboardingTheme.goalLoseWeight,
              ),

              SizedBox(height: OnboardingTheme.spaceXL),

              // Divider
              const Divider(thickness: 2),

              SizedBox(height: OnboardingTheme.spaceLG),

              // Ações de teste
              Text(
                'Ações de Teste:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: OnboardingTheme.textSecondary,
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceMD),

              // Botão: Resetar onboarding
              ElevatedButton.icon(
                onPressed: () async {
                  await provider.resetOnboarding();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Onboarding resetado!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Resetar Onboarding'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: OnboardingTheme.spaceMD,
                  ),
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceSM),

              // Botão: Iniciar fluxo completo
              ElevatedButton.icon(
                onPressed: () async {
                  await provider.resetOnboarding();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushReplacementNamed('/onboarding/splash');
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Fluxo Completo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: OnboardingTheme.spaceMD,
                  ),
                ),
              ),

              SizedBox(height: OnboardingTheme.spaceXL),

              // Info sobre rotas
              _buildInfoCard(
                title: 'Rotas Disponíveis',
                content:
                    '• /onboarding/splash\n• /onboarding/welcome\n• /onboarding/goal',
                icon: Icons.route,
                color: Colors.purple,
              ),

              SizedBox(height: OnboardingTheme.spaceLG),

              // Info sobre tema
              _buildInfoCard(
                title: 'Tema Centralizado',
                content:
                    'Cores e fontes em:\nlib/core/theme/onboarding_theme.dart',
                icon: Icons.palette,
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed(route);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.all(OnboardingTheme.spaceLG),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OnboardingTheme.borderRadiusCard),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: OnboardingTheme.spaceXS),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(OnboardingTheme.spaceLG),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(OnboardingTheme.borderRadiusCard),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(width: OnboardingTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: OnboardingTheme.spaceXS),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: OnboardingTheme.textSecondary,
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
