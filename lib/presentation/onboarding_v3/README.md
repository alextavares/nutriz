# 🚀 ONBOARDING V3 - FLUXO SIMPLIFICADO (Yazio Style)

## 📋 FLUXO REAL IMPLEMENTADO

Baseado nas screenshots reais do Yazio, o onboarding é **super simples**:

```
01. Splash Screen (logo + ícones flutuantes)
    ↓ (2 segundos)
02. Welcome Screen (estatísticas + botão Get Started)
    ↓ (clicar em "Get Started")
03. Goal Selection (Perder/Ganhar/Manter peso)
    ↓ (selecionar objetivo + clicar "Continuar")
DASHBOARD (app principal)
```

**Total: 3 telas apenas!** ✅

---

## 🎯 O QUE MUDOU DO PLANEJAMENTO INICIAL?

### ❌ **Planejamento Inicial (ERRADO):**
- 15 telas no onboarding
- Coleta de dados pessoais (altura, peso, idade, etc.)
- Perguntas sobre atividade física
- Perguntas sobre dieta
- Cálculos de macros
- etc...

### ✅ **Implementação Real (CORRETO):**
- **3 telas apenas** no onboarding inicial
- Coleta **apenas o objetivo** do usuário
- Resto dos dados é configurado **DENTRO DO APP** depois

---

## 📁 ESTRUTURA DE ARQUIVOS

```
lib/presentation/onboarding_v3/
├── screens/
│   ├── 01_splash_screen.dart          ✅ Logo + animação
│   ├── 02_welcome_screen.dart         ✅ Estatísticas + botão
│   ├── 03_goal_selection_screen.dart  ✅ Perder/Ganhar/Manter
│   ├── 04_discovery_source_screen.dart    ❌ NÃO USADO (movido para settings)
│   └── 05_gender_selection_screen.dart     ❌ NÃO USADO (movido para settings)
├── widgets/
│   └── onboarding_progress_indicator.dart  ✅ Barra de progresso
└── README.md (este arquivo)
```

---

## 🎨 TELA 01 - SPLASH SCREEN

**Arquivo:** `01_splash_screen.dart`

**Conteúdo:**
- Logo "nutriZ" centralizado (48sp, bold)
- 8 ícones de comida flutuantes animados:
  - 🍅 Tomate
  - 🥕 Cenoura
  - 🍆 Berinjela
  - 🍇 Uva
  - 🥦 Brócolis
  - 🎁 Presente
  - 🍎 Maçã
  - 🥕 Cenoura

**Comportamento:**
- Auto-navega para Tela 02 após **2 segundos**
- Animações de fade + scale

---

## 🎉 TELA 02 - WELCOME SCREEN

**Arquivo:** `02_welcome_screen.dart`

**Conteúdo:**
- Logo "nutriZ" no topo
- Card: "85 million happy users" (com ramos decorativos)
- Card: "20 million foods for calorie tracking"
- Texto: "Let's make every day count!"
- Botão primário: **"Get Started"**
- Link: "I Already Have an Account"

**Navegação:**
- [Get Started] → Tela 03
- [I Already Have an Account] → Login (fora do onboarding)

---

## 🎯 TELA 03 - GOAL SELECTION

**Arquivo:** `03_goal_selection_screen.dart`

**Conteúdo:**
- AppBar: "Configuração" + botão voltar
- Progress bar: 1/15 (verde)
- Pergunta: "Qual é o seu objetivo principal?"
- 3 opções com ícones:
  1. 📉 **Perder peso** (trending_down)
  2. 📈 **Ganhar peso** (trending_up)
  3. ➡️ **Manter peso** (trending_flat)
- Botão: **"Continuar"** (desabilitado até selecionar)

**Comportamento:**
- Ao clicar em opção, card fica verde claro + ícone muda de cor
- Ao clicar "Continuar", salva objetivo e **vai direto para Dashboard**

**Navegação:**
```dart
Navigator.of(context).pushReplacementNamed('/dashboard');
```

---

## 📊 DASHBOARD (DESTINO FINAL)

Após completar as 3 telas, o usuário vai para o **Dashboard principal** do app.

Lá dentro ele pode configurar:
- Dados pessoais (idade, peso, altura)
- Nível de atividade
- Preferências alimentares
- etc...

**Tudo acontece DENTRO DO APP, não no onboarding!**

---

## 🔧 ONDE FORAM AS TELAS 04 E 05?

As telas que criei inicialmente:
- **04_discovery_source_screen.dart** ("How did you hear about us?")
- **05_gender_selection_screen.dart** ("What's your sex?")

Foram **movidas para o fluxo de settings/configuração** dentro do app.

Elas **NÃO fazem parte do onboarding inicial**.

---

## 🎨 SISTEMA DE TEMA

**Arquivo:** `lib/core/theme/onboarding_theme.dart`

Todas as 3 telas usam o tema centralizado:

```dart
// Cores
OnboardingTheme.primary           // #00C896 (verde)
OnboardingTheme.background         // #FFFFFF (branco)
OnboardingTheme.textPrimary       // #1A1A1A (preto)
OnboardingTheme.textSecondary     // #6B7280 (cinza)

// Tipografia
OnboardingTheme.fontFamily        // 'Inter'
OnboardingTheme.fontSizeHeading   // 24.0
OnboardingTheme.fontSizeBody      // 14.0

// Espaçamentos
OnboardingTheme.spaceMD           // 16.0
OnboardingTheme.spaceLG           // 24.0
OnboardingTheme.spaceXL           // 32.0

// Botões
OnboardingTheme.primaryButtonStyle
OnboardingTheme.buttonTextStyle

// Cards
OnboardingTheme.cardDecoration
OnboardingTheme.cardDecorationSelected
```

---

## 💾 DADOS SALVOS

Após completar o onboarding (3 telas), salvar:

```dart
SharedPreferences prefs = await SharedPreferences.getInstance();

// Marcar onboarding como completo
await prefs.setBool('onboarding_completed', true);

// Salvar objetivo escolhido
await prefs.setString('user_goal', goalType); // "lose_weight", "gain_weight", "maintain"

// Primeira vez?
await prefs.setBool('is_first_launch', false);
```

---

## 🧪 COMO TESTAR

### **1. Executar o onboarding completo:**

```dart
// No main.dart ou routing:
MaterialApp(
  initialRoute: '/splash',
  routes: {
    '/splash': (context) => SplashScreen(),
    '/welcome': (context) => WelcomeScreen(),
    '/onboarding/goal': (context) => GoalSelectionScreen(),
    '/dashboard': (context) => DashboardScreen(), // Sua tela principal
    '/login': (context) => LoginScreen(),
  },
);
```

### **2. Testar navegação:**

```
Splash (2s auto) → Welcome (clicar "Get Started") → Goal Selection (selecionar + continuar) → Dashboard
```

### **3. Resetar onboarding:**

```dart
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.clear(); // Limpa tudo
// Agora o app vai mostrar o onboarding novamente
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### **Telas:**
- [x] 01 - Splash Screen
- [x] 02 - Welcome Screen
- [x] 03 - Goal Selection
- [x] Widgets de suporte (progress bar)
- [x] Sistema de tema centralizado

### **Navegação:**
- [ ] Setup de rotas no `main.dart`
- [ ] Provider para gerenciar estado
- [ ] Persistência com SharedPreferences
- [ ] Integração com dashboard existente

### **Melhorias futuras:**
- [ ] Animações de transição entre telas
- [ ] Tracking/analytics de escolhas
- [ ] A/B testing de mensagens
- [ ] Suporte a localização (PT/EN)

---

## 🚀 PRÓXIMOS PASSOS

1. **Criar OnboardingProvider** para gerenciar estado
2. **Setup das rotas** no main.dart
3. **Integrar com dashboard** existente
4. **Testar fluxo completo**
5. **Mover telas 04 e 05** para área de settings

---

## 📝 NOTAS IMPORTANTES

- ✅ **Simplicidade é chave!** 3 telas são suficientes
- ✅ **Dados pessoais DEPOIS** do onboarding
- ✅ **Tema centralizado** facilita mudanças
- ✅ **Fluxo rápido** = melhor conversão

---

**Última atualização:** 2025-01-01
**Baseado em:** Screenshots reais do Yazio
