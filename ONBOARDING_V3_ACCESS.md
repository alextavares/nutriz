# 🚀 COMO ACESSAR O NOVO ONBOARDING V3

## ✅ MÉTODO MAIS FÁCIL (Recomendado)

Execute este comando no terminal:

```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding-v3-debug"
```

Isso vai abrir direto na **tela de debug** com 3 botões grandes para testar cada tela do onboarding.

---

## 📱 O QUE VOCÊ VERÁ

Uma tela linda com:

### 🎨 Botões para Navegar:
- **1️⃣ Splash Screen** - Logo "nutriZ" animado com 8 ícones de comida flutuantes
- **2️⃣ Welcome Screen** - "85 milhões de usuários felizes" + "20 milhões de alimentos"
- **3️⃣ Goal Selection** - Escolher entre "Perder peso", "Ganhar peso", "Manter peso"

### 🔧 Botões de Teste:
- **Resetar Onboarding** - Limpa SharedPreferences para testar de novo
- **Iniciar Fluxo Completo** - Testa as 3 telas em sequência

---

## 🎯 OUTROS MÉTODOS

### Método 2: Iniciar direto na Splash do Onboarding

```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding/splash"
```

### Método 3: Iniciar direto na Welcome Screen

```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding/welcome"
```

### Método 4: Iniciar direto na Goal Selection

```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding/goal"
```

---

## 🌐 TESTAR EM PORTUGUÊS E INGLÊS

### Português (padrão):
```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding-v3-debug"
```

### Inglês:
1. Mude o idioma do dispositivo/emulador para Inglês
2. Depois rode:
```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding-v3-debug"
```

**OU** rode com locale definida:
```bash
flutter run --dart-define=INITIAL_ROUTE="/onboarding-v3-debug" --dart-define=DEFAULT_LOCALE="en"
```

---

## 🔄 FLUXO COMPLETO DO ONBOARDING

Quando você clicar em **"Iniciar Fluxo Completo"** na tela de debug:

```
[Tela 1] Splash Screen
   ↓ (2 segundos)
[Tela 2] Welcome Screen
   ↓ (clicar "Começar")
[Tela 3] Goal Selection
   ↓ (escolher objetivo + "Continuar")
[Dashboard] ✅
```

---

## 📊 ROTAS DISPONÍVEIS

Todas as rotas que você pode usar com `--dart-define=INITIAL_ROUTE`:

| Rota | Descrição |
|------|-----------|
| `/onboarding-v3-debug` | 🧪 Tela de debug (RECOMENDADO) |
| `/onboarding/splash` | Splash com logo animado |
| `/onboarding/welcome` | Welcome com estatísticas |
| `/onboarding/goal` | Seleção de objetivo |

---

## 🛠️ TROUBLESHOOTING

### Erro: "No MaterialLocalizations found"

**Solução:**
```bash
flutter clean && flutter pub get && flutter run --dart-define=INITIAL_ROUTE="/onboarding-v3-debug"
```

### Erro: "Route not found"

**Verificar:** O arquivo `lib/routes/app_routes.dart` tem estas linhas?
```dart
onboardingV3Debug: (context) => const OnboardingV3DebugScreen(),
onboardingV3Splash: (context) => const OnboardingV3SplashScreen(),
onboardingV3Welcome: (context) => const WelcomeScreen(),
onboardingV3Goal: (context) => const GoalSelectionScreen(),
```

Se não tiver, rode:
```bash
flutter pub get
```

---

## 🎨 CUSTOMIZAÇÃO

Quer mudar as cores? Edite:
```
lib/core/theme/onboarding_theme.dart
```

Exemplo:
```dart
// Linha ~15-20
static const Color primary = Color(0xFF00C896); // Verde atual

// Trocar para azul:
static const Color primary = Color(0xFF007AFF);
```

---

## ✅ CHECKLIST

- [ ] Rodar `flutter clean && flutter pub get`
- [ ] Executar `flutter run --dart-define=INITIAL_ROUTE="/onboarding-v3-debug"`
- [ ] Ver a tela de debug aparecer
- [ ] Clicar nos 3 botões para testar cada tela
- [ ] Clicar em "Iniciar Fluxo Completo" para testar o fluxo todo
- [ ] Mudar idioma do dispositivo para testar em inglês
- [ ] Verificar que objetivo foi salvo no SharedPreferences

---

**Última atualização:** 2025-11-01
**Criado por:** Claude Code Assistant
**Status:** ✅ Pronto para uso
