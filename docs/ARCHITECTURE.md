# Arquitetura — NutriTracker

## Sumário
- Diagrama ASCII de camadas
- Componentes e responsabilidades
- Fluxo de dados e estado
- Como rodar/buildar
- Observado vs. Inferência

## Diagrama

```
[ UI (presentation/*) ]
       |
       v
[ Rotas (MaterialApp.routes) ]  <-- lib/routes/app_routes.dart
       |
       v
[ Estado Local (StatefulWidget) ]
       |
       +--> [ SharedPreferences ] --(persistência)--> diário, metas, preferências, favoritos
       |
       +--> [ Serviços dio ] --(REST)--> OFF / USDA FDC / Gemini
                      |
                      +--> Open Food Facts (público)
                      +--> USDA FDC (api_key opcional)
                      +--> Gemini (GEMINI_API_KEY via --dart-define)
```

## Componentes
- UI: `lib/presentation/**` (Diário, Logging, Progresso, Perfil, etc.).
- Rotas: `lib/routes/app_routes.dart` (Navigator 1.0 com rotas nomeadas).
- Tema/Design: `lib/theme/app_theme.dart` (Sizer, Google Fonts, SVG).
- Serviços: `lib/services/**` (dio + SharedPreferences).
- Widgets: `lib/widgets/**` (componentes reutilizáveis e fallback de erro).

## Fluxo de dados/estado
- Observado
  - Estado por tela: `StatefulWidget` (ex.: `RootShell`, `DailyTrackingDashboard`, `FoodLoggingScreen`).
  - Persistência: `NutritionStorage`, `UserPreferences`, `FavoritesStorage` (SharedPreferences, chaves nomeadas).
  - Serviços REST: `OpenFoodFactsService`, `FoodDataCentralService`, `GeminiService`/`GeminiClient`.
- Inferência
  - Fluxo IA: imagem → `GeminiClient.createMultimodal` → JSON nutricional → itens candidatos → adição ao diário.

## Como rodar/buildar
```
flutter pub get
flutter run --dart-define-from-file=env.json
# ou
flutter run --dart-define=GEMINI_API_KEY=SEU_TOKEN

# Build
flutter build apk --release --dart-define-from-file=env.json
```

## Observado vs. Inferência
- Observado: ausência de provider/bloc; apenas estado local e SharedPreferences.
- Inferência: estratégia offline‑first para diário e favoritos.

## Referências
- lib/routes/app_routes.dart:1-220
- lib/presentation/root_shell/root_shell.dart:1-240
- lib/presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart:1-220
- lib/presentation/food_logging_screen/food_logging_screen.dart:1-300
- lib/services/nutrition_storage.dart:1-220
- lib/services/user_preferences.dart:1-340
- lib/services/fooddb/open_food_facts_service.dart:1-220
- lib/services/fooddb/food_data_central_service.dart:1-200
- lib/services/gemini_client.dart:1-220
