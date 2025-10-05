# Flutter

[![Flutter CI](https://github.com/alextavares/nutritracker/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/alextavares/nutritracker/actions/workflows/flutter-ci.yml)
[![Flutter Tests](https://github.com/alextavares/nutritracker/actions/workflows/flutter-tests.yml/badge.svg)](https://github.com/alextavares/nutritracker/actions/workflows/flutter-tests.yml)
[![Coverage](https://github.com/alextavares/nutritracker/actions/workflows/codecov.yml/badge.svg)](https://github.com/alextavares/nutritracker/actions/workflows/codecov.yml)
[![Release](https://github.com/alextavares/nutritracker/actions/workflows/release.yml/badge.svg)](https://github.com/alextavares/nutritracker/actions/workflows/release.yml)

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:
1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
 ```

## 📁 Project Structure

```

## 🔒 OpenRouter Vision via Backend

- Copie `server/express/.env.example` para `.env` e configure:
  - `VISION_PROVIDER=openrouter`
  - `OPENROUTER_API_KEY=sk-or-...`
  - Opcional: `OPENROUTER_MODEL=openai/gpt-4o-mini`, `OPENROUTER_SITE_URL=https://seuapp.com`, `OPENROUTER_SITE_NAME=NutriTracker`
- Execute o servidor Express:
  ```bash
  cd server/express
  npm install
  npm run dev
  ```
- No app Flutter, garanta que `COACH_API_BASE_URL` (via `env.json` ou `--dart-define`) aponte para esse servidor (ex.: `https://api.seuapp.com` ou `http://10.0.2.2:8002` no emulador Android).
- A análise de fotos passa a usar `POST /vision/analyze_food`, mantendo a chave do OpenRouter protegida no backend. Se o backend estiver indisponível, o app tenta fallback para Gemini (se configurado).
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new

## 🖼️ Visual Comparison & Captures

- Open the side-by-side visual comparison: `assets/comparison.html` (screenshots and videos for YAZIO vs NutriTracker).
- Automated capture scripts are under `scripts/` (ADB driven):
  - `scripts/flows_nutritracker.py`, `scripts/flows_yazio.py` capture key flows (diary/search/detail/settings/analytics).
  - `scripts/capture_modes.py` toggles dark mode and font scale for accessibility captures.

Quick ADB tips (emulator):
```bash
# List devices
adb devices -l

# Screenshot
adb exec-out screencap -p > screenshot.png

# Short screen recording (10s)
adb shell screenrecord --time-limit 10 /sdcard/demo.mp4
adb pull /sdcard/demo.mp4 .
```

## 🎯 Goals Wizard

- Configure daily goals via the in-app wizard: route `AppRoutes.goalsWizard` or Profile → "Configurar metas".
- Goals are persisted in `UserPreferences` and per‑meal goals are derived to feed diary progress bars.

## 📓 Changelog

- See `CHANGELOG.md` for release notes (current: 1.1.0).

## 🧪 Build & Install (ADB)

- Script: `scripts/build_install.sh`
  - Debug: `bash scripts/build_install.sh`
  - Release: `bash scripts/build_install.sh --release`
  - Target a device: `ADB_SERIAL=emulator-5554 bash scripts/build_install.sh`

- Makefile (optional):
```bash
# Build and install (debug)
make build-and-install

# Analyze
make analyze

# With specific device
make build-and-install ADB_SERIAL=emulator-5554
```

### Android SDK — Variáveis de Ambiente (Windows/WSL/Linux)

- Conflitos comuns: `ANDROID_HOME` vs `ANDROID_SDK_ROOT` e `android/local.properties (sdk.dir)`.
- Solução recomendada neste repo:
  - Use o script `scripts/build_install.sh`, que força o SDK local do projeto em `.tooling/android-sdk` e injeta isso em `android/local.properties` apenas durante o build (restaura depois).
  - Não defina ambos `ANDROID_HOME` e `ANDROID_SDK_ROOT` apontando para SDKs diferentes.

Manual (se preferir configurar ambiente):
- Linux/macOS (bash):
  ```bash
  export ANDROID_HOME="$PWD/.tooling/android-sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  sed -i.bak "s#^sdk.dir=.*#sdk.dir=$ANDROID_HOME#g" android/local.properties
  sed -i.bak "s#^flutter.sdk=.*#flutter.sdk=$PWD/.tooling/flutter#g" android/local.properties
  ```
- Windows PowerShell:
  ```powershell
  setx ANDROID_HOME "$PWD\.tooling\android-sdk"
  setx ANDROID_SDK_ROOT "$PWD\.tooling\android-sdk"
  (Get-Content android/local.properties) -replace '^sdk.dir=.*', "sdk.dir=$PWD\.tooling\android-sdk" `
    -replace '^flutter.sdk=.*', "flutter.sdk=$PWD\.tooling\flutter" | Set-Content android/local.properties
  ```

Se o erro persistir, verifique o caminho em `android/local.properties` e remova variáveis duplicadas em seu shell/ambiente.

## 🚦 CI & Releases

- CI (GitHub Actions): `.github/workflows/flutter-ci.yml`
  - Executa em PRs/push para `main` e `feature/**`
  - Passos: `flutter analyze` + build APK (debug) + artifact

- Release (GitHub Actions): `.github/workflows/release.yml`
  - Dispara ao criar tag `v*` (ex.: `v1.1.0`)
  - Build APK (release) e cria Draft Release com o APK anexado

- Como criar tag e disparar release:
  - `bash scripts/tag_release.sh v1.1.0` (ou `git tag -a v1.1.0 -m "Release v1.1.0" && git push origin v1.1.0`)
  - Edite o draft release e cole as notas de `.github/release-notes.md`

### Cobertura (Codecov)

- Workflow: `.github/workflows/codecov.yml`
- Requer `CODECOV_TOKEN` (secreto do repositório) para uploads estáveis
- Executa `flutter test --coverage` e envia `coverage/lcov.info` para Codecov
