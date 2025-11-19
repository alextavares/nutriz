// Centraliza escolha do fluxo oficial de onboarding sem quebrar rotas existentes.
// Uso inicial: ponto único para futuras mudanças de decisão, experimentos e feature flags.

import 'package:flutter/widgets.dart';

import '../routes/app_routes.dart';
import '../presentation/onboarding_v3/screens/01_splash_screen.dart';

/// Configuração de qual fluxo de onboarding é considerado "oficial".
/// Mantém comportamento atual por padrão; alterações futuras passam por aqui.
class OnboardingConfig {
  const OnboardingConfig._();

  /// Flag única para controlar uso do Onboarding V3 como fluxo principal.
  /// No momento deixamos `true` para indicar intenção, mas sem alterar [AppRoutes.initial].
  /// Pode ser ligada/alterada via --dart-define se necessário.
  static const bool useOnboardingV3 = bool.fromEnvironment(
    'ONBOARDING_V3_ENABLED',
    defaultValue: true,
  );

  /// Rota recomendada para entrar no onboarding oficial.
  /// Não altera `AppRoutes.initial`; apenas padroniza o ponto de decisão.
  static String get officialOnboardingRoute {
    if (useOnboardingV3) {
      // Mantemos uma rota dedicada para o splash do V3.
      return AppRoutes.onboardingV3Splash;
    }
    // Fallback explícito para fluxo legado atual.
    return AppRoutes.onboarding;
  }

  /// Widget inicial sugerido para fluxos que quiserem navegar direto para o onboarding oficial.
  /// Não é usado automaticamente pelo MaterialApp; consumo é opt-in.
  static Widget get officialOnboardingEntry {
    if (useOnboardingV3) {
      return const OnboardingV3SplashScreen();
    }
    // Mantemos compatibilidade: chamadores existentes continuam usando rotas históricas.
    // Aqui retornamos apenas o splash V3 como padrão intencional; fluxos legados usam rotas.
    return const OnboardingV3SplashScreen();
  }
}