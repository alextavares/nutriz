# NutriTracker — Fase 1: Descoberta do Stack e do Layout

Este documento consolida a descoberta automática do stack, tooling e layout do código. É "documentação viva" gerada a partir do repositório atual.

## Stack & Layout

| Categoria | Tecnologia/Lib | Versão | Caminhos/Observações |
|---|---|---|---|
| Framework front | Flutter (mobile/web) | Flutter 3.29.x (README), Dart SDK ^3.6.0 (pubspec) | `lib/`, `android/`, `ios/`, `web/` |
| Gerenciador de pacotes | Pub (Flutter/Dart) | — | `pubspec.yaml`, `pubspec.lock` |
| Build/Execução | Flutter CLI, Makefile | — | `flutter run`, `flutter build`; Make: `make analyze`, `make apk-debug`, `make apk-release` (arquivo `Makefile`) |
| Sistema de rotas | Navigator 1.0 (`MaterialApp.routes`) | — | Definições em `lib/routes/app_routes.dart`; telas em `lib/presentation/**` |
| Estado global | StatefulWidget + serviços + SharedPreferences | — | Sem lib dedicada (Provider/Riverpod/BLoC/GetX não encontrados). Preferências/diário em `lib/services/**` |
| Camada de dados | REST via `dio`; storage local | dio ^5.8.0 | APIs: Gemini (Google Generative Language), Open Food Facts, USDA FDC. Storage: `shared_preferences` |
| Formulários/validação | Nativo (Flutter) | — | Nenhuma lib de formulários/validação detectada |
| Design system | Tema custom (`AppTheme`), Sizer, Google Fonts, SVG | sizer ^2.0.15, google_fonts ^6.1.0, flutter_svg ^2.0.9 | Tema: `lib/theme/app_theme.dart`; responsivo: `Sizer` |
| Testes | flutter_test (dev) | — | `dev_dependencies:flutter_test`; pasta `test/` não encontrada; `.codecov.yml` presente |
| Notificações | flutter_local_notifications | ^17.2.2 | `lib/services/notifications_service.dart` |
| Plataformas | Android, iOS, Web | — | Pastas de plataforma: `android/`, `ios/`, `web/` |

## Pastas‑chave

- `lib/main.dart`: entrypoint do app; configura `MaterialApp`, tema e `initialRoute` (suporte a `--dart-define=INITIAL_ROUTE`).
- `lib/routes/app_routes.dart`: mapa de rotas (`MaterialApp.routes`) e rota inicial.
- `lib/presentation/`: telas/fluxos principais do app (UI):
  - `splash_screen/`
  - `daily_tracking_dashboard/`
  - `food_logging_screen/`
  - `recipe_browser/` e `recipe_detail.dart`
  - `intermittent_fasting_tracker/`
  - `detailed_meal_tracking_screen/`
  - `ai_food_detection_screen/`
  - `profile_screen/`, `weekly_progress_screen/`, `progress_overview/`, `goals_wizard/`, `root_shell/`, `design_preview/`
- `lib/services/`: camada de dados/serviços e persistência local:
  - `gemini_service.dart`, `gemini_client.dart` (REST Gemini via `dio`)
  - `fooddb/` (Open Food Facts e USDA FoodDataCentral via `dio`)
  - `nutrition_storage.dart`, `favorites_storage.dart`, `user_preferences.dart` (SharedPreferences)
  - `notifications_service.dart`
- `lib/theme/app_theme.dart`: design system (cores, tipografia, componentes).
- `lib/widgets/`: componentes reutilizáveis (ex.: `custom_error_widget.dart`).
- `lib/util/`: implementações condicionais web/nativo (upload/download).
- `assets/`, `assets/images/`, `env.json`: assets e configurações (API keys via dart-define/file).
- `scripts/`: automações (build/install ADB, capturas).
- `Makefile`: alvos de build/analise.

## Features principais aparentes

- Diário alimentar: registrar e listar refeições por dia (`NutritionStorage`, `DailyTrackingDashboard`).
- Busca de alimentos: Open Food Facts (`open_food_facts_service.dart`) e USDA FDC (`food_data_central_service.dart`).
- Favoritos e “meus alimentos”: `FavoritesStorage` (persistência local).
- Metas/calorias e macronutrientes: progresso diário/semanal, derivação por refeição; wizard de metas (`goals_wizard`).
- Gráficos/analytics: `fl_chart` em dashboards de progresso.
- Jejum intermitente: tela dedicada (`intermittent_fasting_tracker`).
- Perfil e preferências: `profile_screen` + `UserPreferences`.
- Detecção de alimentos por IA (imagem): câmera + `GeminiService` (`ai_food_detection_screen`).
- Notificações locais: lembretes (`flutter_local_notifications`).
- Exportar/importar e compartilhamento do diário: utilitários web/nativo + `share_plus`.

## Observações de detecção

- Não há dependências de gerenciamento de estado global (Provider/Riverpod/BLoC/GetX). Estado é predominantemente local (StatefulWidget) e persistido via `SharedPreferences`.
- Rotas usam o `MaterialApp.routes` (Navigator 1.0). As telas vivem sob `lib/presentation/**` com 1:1 em `AppRoutes`.
- Camada de dados exclusivamente REST (`dio`) e serviços locais; não há GraphQL.
- Testes: há `flutter_test` em `dev_dependencies`, mas não há pasta `test/` no workspace. `.codecov.yml` sugere intenção de cobertura futura.
- Execução com variáveis: recomenda‑se `--dart-define-from-file=env.json` (vide `README.md`). `GEMINI_API_KEY` é esperado.

## Como rodar localmente (referência)

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
# ou definir individualmente: --dart-define=GEMINI_API_KEY=...
```

## Fontes

- `pubspec.yaml` (deps, SDK)
- `README.md` (versão Flutter sugerida 3.29.x e comandos)
- `lib/**` (rotas, telas, serviços, tema)


## Confirmações detalhadas (Android/iOS, configs e segurança)

- Pubspec.yaml
  - Versões: uso de `^` (intervalos semver), não “travadas” em número exato.
  - Assets: `env.json`, `assets/`, `assets/images/`. Sem seção de fontes locais (usa Google Fonts).
  - Plugins de tooling: não há `flutter_launcher_icons` nem `flutter_native_splash` configurados.

- Android
  - Manifest (`android/app/src/main/AndroidManifest.xml`): permissões `INTERNET`, `CAMERA`, `READ_MEDIA_IMAGES` (Android 13+), `READ_EXTERNAL_STORAGE` (maxSdk 32). `usesCleartextTraffic="true"`. Sem intent‑filters de deep link (apenas MAIN/LAUNCHER).
  - Gradle app (`android/app/build.gradle`): `compileSdk=36`, `targetSdkVersion=34`, `minSdkVersion=flutter.minSdkVersion` (herdado do plugin Flutter). Sem `productFlavors`. `namespace=com.nutritracker.app`.

- iOS
  - Info.plist (`ios/Runner/Info.plist`): `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription` presentes; ATS permite `NSAllowsArbitraryLoads=true`. Sem `CFBundleURLTypes`/schemes declarados.
  - Podfile (`ios/Podfile`): `platform` comentado (não fixa min iOS), `use_frameworks!` habilitado. Sem pods extras manuais.
  - Firebase: não há `GoogleService-Info.plist` (iOS) nem `google-services.json` (Android).

- Localização
  - Não há `l10n.yaml` e nenhum arquivo `.arb` detectado.

- Segurança (chaves/API)
  - Gemini: carregamento por `--dart-define=GEMINI_API_KEY` OU via `assets/env.json` (ver `lib/services/gemini_service.dart`).
  - `env.json` contém placeholders e um valor de `GEMINI_API_KEY` no repositório — risco de exposição; ideal mover para `--dart-define` ou segredos externos.
  - Open Food Facts: sem chave (usa endpoint público via `dio`).
  - USDA FoodDataCentral: `FoodDataCentralService` aceita `apiKey` mas não foi encontrada ligação direta com `env.json` — sem wiring aparente (feature possivelmente desativada sem chave).

- Rotas e navegação
  - Rotas: estáticas em `AppRoutes.routes` (Navigator 1.0). Não há `onGenerateRoute`/`onUnknownRoute`.
  - Parâmetros de rota: telas leem `ModalRoute.of(context)?.settings.arguments` (ex.: `FoodLoggingScreen`).
  - Deep links: não configurados (Android/iOS).
  - Modal navigation: não foram encontrados usos de `showModalBottomSheet`/`showDialog` no código atual.

- Estado
  - Sem gerenciador externo; não há `ValueNotifier`/`ChangeNotifier`/`InheritedWidget` “caseiros” detectados. Padrão é `StatefulWidget` + serviços (`SharedPreferences`).
