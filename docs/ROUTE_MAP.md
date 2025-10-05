# Mapa de Rotas — NutriTracker

## Sumário
- Árvore de rotas nomeadas
- Parâmetros aceitos
- Padrões de navegação
- Observado vs. Inferência

## Árvore de Rotas
```
/ (initial) → SplashScreen
  └─ (decide) → /root-shell (principal)

/root-shell → RootShell (BottomNavigationBar)
  ├─ Tab 0: DailyTrackingDashboard (date control via ValueNotifier)
  ├─ Tab 1: FoodLoggingScreen
  ├─ Tab 2: Add Sheet (modal)
  ├─ Tab 3: ProgressOverviewScreen
  └─ Tab 4: ProfileScreen

/food-logging-screen → FoodLoggingScreen
/daily-tracking-dashboard → DailyTrackingDashboard
/recipe-browser → RecipeBrowser
/recipe-detail → RecipeDetailScreen
/intermittent-fasting-tracker → IntermittentFastingTracker
/detailed-meal-tracking-screen → DetailedMealTrackingScreen
/ai-food-detection-screen → AiFoodDetectionScreen
/profile-screen → ProfileScreen
/weekly-progress-screen → WeeklyProgressScreen
/design-preview → DesignPreviewScreen
/progress-overview → ProgressOverviewScreen
/goals-wizard → GoalsWizardScreen
/login-screen → LoginScreen
```

## Parâmetros
- Observado
  - `RootShell`: `arguments: { date?: ISO|DateTime, tab?: 'diary'|'search'|'progress'|'profile' }`
  - `FoodLoggingScreen`: `arguments: { activeTab?: 'recent'|'favorites'|'mine', meal?: 'breakfast'|'lunch'|'dinner'|'snack', date?: ISO|DateTime }`
- Inferência
  - `RecipeDetailScreen`: pode aceitar `recipeId`.
  - `GoalsWizardScreen`: pode aceitar `returnTo`.

## Padrões de navegação
- Observado
  - Navegação principal via `Navigator.pushNamed`/`pushReplacementNamed` com rotas definidas em `AppRoutes.routes`.
  - Modal: `showModalBottomSheet` no RootShell para atalhos de adição.
  - Sem `onGenerateRoute`/`deep links` definidos.

## Observado vs. Inferência
- Observado: rotas listadas em `AppRoutes.routes` e parâmetros lidos via `ModalRoute.settings.arguments`.
- Inferência: parâmetros adicionais em telas de detalhe/wizard.

## Referências
- lib/routes/app_routes.dart:1-220
- lib/presentation/root_shell/root_shell.dart:1-240
- lib/presentation/food_logging_screen/food_logging_screen.dart:1-120
