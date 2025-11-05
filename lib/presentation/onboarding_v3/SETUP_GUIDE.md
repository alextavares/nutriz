# 🚀 ONBOARDING V3 - GUIA DE SETUP E TESTES

## ✅ IMPLEMENTAÇÃO COMPLETA

O Onboarding V3 foi implementado com sucesso! Todas as 3 telas estão funcionais e integradas com:

- ✅ **Traduções i18n** (Português e Inglês)
- ✅ **Provider** para gerenciamento de estado
- ✅ **Navegação** configurada nas rotas
- ✅ **Persistência** com SharedPreferences
- ✅ **Tema centralizado** para fácil customização

---

## 📋 ESTRUTURA IMPLEMENTADA

```
lib/presentation/onboarding_v3/
├── screens/
│   ├── 01_splash_screen.dart        ✅ Splash com logo animado
│   ├── 02_welcome_screen.dart       ✅ Boas-vindas com estatísticas
│   └── 03_goal_selection_screen.dart ✅ Seleção de objetivo
├── widgets/
│   └── onboarding_progress_indicator.dart ✅ Barra de progresso
├── provider/
│   └── onboarding_provider.dart     ✅ Provider com state management
└── README.md                        📖 Documentação original
```

---

## 🧪 COMO TESTAR O ONBOARDING V3

### **Método 1: Usar a rota de teste diretamente**

```bash
# Iniciar app direto na Splash Screen do Onboarding V3
flutter run --dart-define=INITIAL_ROUTE="/onboarding/splash"
```

### **Método 2: Resetar SharedPreferences e iniciar normalmente**

1. **Abrir o arquivo que controla a lógica de inicialização**
   - Normalmente é `lib/presentation/splash_screen/splash_screen.dart`

2. **Modificar temporariamente para testar** (adicionar no `initState`):
   ```dart
   @override
   void initState() {
     super.initState();

     // 🧪 TESTE: Resetar onboarding
     _resetOnboardingForTesting();
   }

   Future<void> _resetOnboardingForTesting() async {
     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('onboarding_v3_completed');
     await prefs.remove('user_goal');
     await prefs.setBool('is_first_launch', true);

     // Navegar para onboarding
     Future.delayed(Duration(seconds: 1), () {
       Navigator.of(context).pushReplacementNamed('/onboarding/splash');
     });
   }
   ```

3. **Executar o app normalmente**:
   ```bash
   flutter run
   ```

### **Método 3: Testar cada tela individualmente**

```bash
# Testar Splash Screen
flutter run --dart-define=INITIAL_ROUTE="/onboarding/splash"

# Testar Welcome Screen
flutter run --dart-define=INITIAL_ROUTE="/onboarding/welcome"

# Testar Goal Selection
flutter run --dart-define=INITIAL_ROUTE="/onboarding/goal"
```

---

## 🔄 FLUXO COMPLETO DO ONBOARDING

```
INÍCIO
  ↓
[Tela 01] Splash Screen
  • Logo "nutriZ" animado
  • 8 ícones de comida flutuantes
  • Auto-navega após 2 segundos
  ↓
[Tela 02] Welcome Screen
  • Logo "nutriZ"
  • "85 milhões de usuários felizes"
  • "20 milhões de alimentos..."
  • Botão "Começar" / "Get Started"
  • Link "Já tenho uma conta" → /login
  ↓ (clicar "Começar")
[Tela 03] Goal Selection
  • AppBar: "Configuração" / "Setup"
  • Barra de progresso: 1/15
  • Pergunta: "Qual é o seu objetivo principal?"
  • 3 opções:
    - 📉 Perder peso
    - 📈 Ganhar peso
    - ➡️ Manter peso
  • Botão "Continuar" / "Continue"
  ↓ (clicar "Continuar")
[DASHBOARD]
  • Onboarding marcado como completo
  • Objetivo salvo no SharedPreferences
  • Usuário pode configurar resto no app
```

---

## 💾 DADOS PERSISTIDOS

Após completar o onboarding, os seguintes dados são salvos no `SharedPreferences`:

```dart
{
  "onboarding_v3_completed": true,
  "user_goal": "lose_weight" | "gain_weight" | "maintain",
  "is_first_launch": false
}
```

---

## 🌐 SUPORTE A IDIOMAS

O onboarding suporta **2 idiomas**:

### **Português (pt)**
- Splash: "nutriZ"
- Welcome: "Vamos fazer cada dia valer a pena!"
- Goal: "Qual é o seu objetivo principal?"
- Opções: "Perder peso", "Ganhar peso", "Manter peso"
- Botão: "Continuar"

### **Inglês (en)**
- Splash: "nutriZ"
- Welcome: "Let's make every day count!"
- Goal: "What's your main goal?"
- Opções: "Lose weight", "Gain weight", "Maintain weight"
- Botão: "Continue"

**Para trocar o idioma no dispositivo:**
- Android: Settings → Language → Português/English
- iOS: Settings → General → Language & Region → Português/English

---

## 🎨 CUSTOMIZAÇÃO DO TEMA

Todas as cores, fontes e espaçamentos estão centralizados em:

**`lib/core/theme/onboarding_theme.dart`**

```dart
// Exemplo: Mudar cor primária
static const Color primary = Color(0xFF00C896); // Verde atual
// Trocar para azul:
static const Color primary = Color(0xFF007AFF);

// Exemplo: Mudar fonte
static const String fontFamily = 'Inter';
// Trocar para Roboto:
static const String fontFamily = 'Roboto';
```

Após editar, **todas as 3 telas** serão atualizadas automaticamente!

---

## 🔧 PROVIDER - COMO USAR

O `OnboardingV3Provider` está disponível em qualquer tela via:

```dart
import 'package:provider/provider.dart';
import '../provider/onboarding_provider.dart';

// Obter provider
final provider = Provider.of<OnboardingV3Provider>(context);

// Obter objetivo escolhido
String? goal = provider.goalType; // "lose_weight", "gain_weight", "maintain"

// Verificar se onboarding foi completado
bool completed = await provider.isOnboardingCompleted();

// Resetar onboarding (útil para testes)
await provider.resetOnboarding();
```

---

## 📱 PRÓXIMAS ROTAS DISPONÍVEIS

Após o onboarding, o usuário pode ir para:

- **`/dashboard`** - Dashboard principal (padrão após onboarding)
- **`/login`** - Login (se clicar "Já tenho uma conta")

---

## ⚠️ TROUBLESHOOTING

### **Erro: "AppLocalizations.of(context) returned null"**

**Solução:**
```bash
# Regenerar arquivos de localização
flutter gen-l10n

# Ou rodar build runner
flutter pub run build_runner build --delete-conflicting-outputs
```

### **Erro: "Navigator operation requested with a context that does not include a MaterialApp"**

**Solução:** Verificar se as rotas estão registradas em `lib/routes/app_routes.dart`:
```dart
onboardingV3Splash: (context) => const OnboardingV3SplashScreen(),
onboardingV3Welcome: (context) => const WelcomeScreen(),
onboardingV3Goal: (context) => const GoalSelectionScreen(),
```

### **Onboarding não aparece**

**Solução:** Resetar SharedPreferences:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear(); // Limpa TUDO (cuidado!)

// Ou remover apenas flags do onboarding:
await prefs.remove('onboarding_v3_completed');
await prefs.remove('user_goal');
```

---

## 🎯 CHECKLIST DE IMPLEMENTAÇÃO

- [x] Tela 01: Splash Screen com animação
- [x] Tela 02: Welcome Screen com estatísticas
- [x] Tela 03: Goal Selection com 3 opções
- [x] Progress indicator widget
- [x] Tema centralizado (OnboardingTheme)
- [x] Provider para state management
- [x] Traduções PT e EN nos .arb
- [x] Telas usando AppLocalizations
- [x] Rotas configuradas no AppRoutes
- [x] Provider integrado no main.dart
- [x] Persistência com SharedPreferences
- [x] Navegação para dashboard após completar
- [x] Documentação completa

---

## 🚀 PRÓXIMOS PASSOS (OPCIONAL)

Se quiser expandir o onboarding no futuro:

1. **Adicionar mais perguntas** (altura, peso, idade, etc.) como telas 04, 05, 06...
2. **Cálculo de macros** baseado nos dados coletados
3. **Tela de resumo** antes de ir para o dashboard
4. **Animações de transição** entre as telas
5. **A/B testing** de mensagens e layouts
6. **Analytics** para tracking de conversão

Mas lembre-se: o design atual (3 telas) é **intencional** para maximizar conversão!

---

**Última atualização:** 2025-11-01
**Status:** ✅ Implementação Completa
**Testado:** Português e Inglês
