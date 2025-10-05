# Mapa de UX — NutriTracker

## Sumário
- Mapa de rotas/telas
- Matriz De→Para (fluxos principais)
- Invariantes de UX
- Observado vs. Inferência

## Mapa de rotas/telas
- Observado (AppRoutes):
  - `/` → SplashScreen
  - `/splash-screen` → SplashScreen
  - `/food-logging-screen` → FoodLoggingScreen
  - `/login-screen` → LoginScreen
  - `/daily-tracking-dashboard` → DailyTrackingDashboard
  - `/recipe-browser` → RecipeBrowser
  - `/recipe-detail` → RecipeDetailScreen
  - `/intermittent-fasting-tracker` → IntermittentFastingTracker
  - `/detailed-meal-tracking-screen` → DetailedMealTrackingScreen
  - `/ai-food-detection-screen` → AiFoodDetectionScreen
  - `/profile-screen` → ProfileScreen
  - `/weekly-progress-screen` → WeeklyProgressScreen
  - `/design-preview` → DesignPreviewScreen
  - `/progress-overview` → ProgressOverviewScreen
  - `/goals-wizard` → GoalsWizardScreen
  - `/root-shell` → RootShell

## Matriz De→Para (exemplos)
- Observado
  - Splash → (rota decidida por InitializationService) → normalmente `root-shell`.
  - RootShell (tab) → bottom‑sheet “Adicionar”: ações levam a FoodLogging, AI, Recipes; ou adicionam água direto.
  - RootShell → FoodLogging (via pushNamed com argumentos `{ activeTab, meal, date }`).
  - RootShell → ProgressOverview/Profile (tabs).
- Inferência
  - RecipeBrowser → RecipeDetail → (Adicionar alimento)
  - GoalsWizard → RootShell (após concluir configuração de metas)

## Invariantes de UX
- Observado
  - Manter data selecionada no Diário ao navegar entre abas (RootShell armazena em `ValueNotifier<DateTime>`).
  - Parâmetros de rota aceitos e interpretados (ex.: `FoodLoggingScreen` lê `ModalRoute.settings.arguments`).
  - Ação central (aba 2) é sempre atalhos de adição (não muda de tela por si só, abre bottom‑sheet).
- Inferência
  - Não resetar filtros de busca e histórico entre navegações (persistência em `UserPreferences`).
  - Splash deve garantir experiência fluida (tempo mínimo + fallback de retry).

## Observado vs. Inferência
- Observado: rotas estáticas; sem deep links; um modal bottom‑sheet (RootShell) para adicionar.
- Inferência: caminhos “detalhe de receita” e “wizard de metas” encadeiam navegação condicional baseada no estado do usuário.

## Referências
- lib/routes/app_routes.dart:1-220
- lib/presentation/root_shell/root_shell.dart:1-240
- lib/presentation/splash_screen/splash_screen.dart:1-220
- lib/presentation/food_logging_screen/food_logging_screen.dart:1-180
