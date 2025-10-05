# Catálogo de Componentes — NutriTracker

## Sumário
- Telas e props
- Widgets reutilizáveis (alto nível)
- Onde são usados
- Observado vs. Inferência

## Telas (presentation/**)
- DailyTrackingDashboard (`lib/presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart`)
  - Props observadas: `initialDate?`, `showAppBar` (bool), `showBottomNav` (bool), `showFab` (bool)
  - Uso: Tab 0 do `RootShell`; também acessível por rota. (Usado em `lib/presentation/root_shell/root_shell.dart:1-120`)
- FoodLoggingScreen (`lib/presentation/food_logging_screen/food_logging_screen.dart`)
  - Props observadas: `initialTab?`, `initialMealKey?`, `targetDate?`
  - Uso: rota nomeada e via atalhos do bottom‑sheet. (Chamado em `lib/presentation/root_shell/root_shell.dart:80-160`)
- ProgressOverviewScreen (`lib/presentation/progress_overview/progress_overview.dart`)
  - Props observadas: `showAppBar` (bool)
  - Uso: Tab 3 do `RootShell`.
- ProfileScreen (`lib/presentation/profile_screen/profile_screen.dart`)
  - Props observadas: `showAppBar` (bool)
  - Uso: Tab 4 do `RootShell`.
- RootShell (`lib/presentation/root_shell/root_shell.dart`)
  - Props: —
  - Uso: container com BottomNavigationBar e bottom‑sheet de adição.
- SplashScreen (`lib/presentation/splash_screen/splash_screen.dart`)
  - Props: —
  - Uso: inicialização, decide próxima rota. (Redireciona via `Navigator.pushReplacementNamed` em `lib/presentation/splash_screen/splash_screen.dart:94-120`)
- Demais telas (observado por caminhos): `recipe_browser`, `recipe_detail`, `intermittent_fasting_tracker`, `detailed_meal_tracking_screen`, `weekly_progress_screen`, `design_preview`, `ai_food_detection_screen`, `goals_wizard`, `login_screen` — props não evidentes aqui (inferência: básicas/sem parâmetros obrigatórios).

## Widgets reutilizáveis (amostra)
- `widgets/custom_error_widget.dart` — fallback para erros na UI.
- `widgets/custom_icon_widget.dart`, `widgets/custom_image_widget.dart` — utilitários visuais.
- FoodLogging widgets (subpastas): `search_bar_widget`, `barcode_scanner_widget`, `food_search_results_widget`, `manual_entry_widget`, etc.

## Observado vs. Inferência
- Observado: props listadas acima nas telas principais; `_PortionPicker` (interno do FoodLogging) gerencia porções, presets e callbacks.
- Inferência: demais telas seguem padrão sem props complexas (apenas const constructors/booleans).

## Referências
- lib/presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart:1-100
- lib/presentation/food_logging_screen/food_logging_screen.dart:1-60
- lib/presentation/root_shell/root_shell.dart:1-120
