# PRD — NutriTracker

## Sumário
- Objetivo do produto (observado + inferência)
- Personas e principais necessidades (inferência)
- Fluxos críticos (observado + inferência)
- KPIs (inferência)
- Escopo do MVP vs. não‑escopo (inferência)
- Regras de UX (observado + inferência)

## Objetivo
- Observado: Aplicativo Flutter (Yazio‑like) para registro alimentar diário, metas e macronutrientes, hidratação, progresso semanal, favoritos e "meus alimentos", notificações locais e exploração de receitas. Integrações REST com Open Food Facts (busca/código de barras) e (opcional) USDA FDC. Módulo de IA para detecção de alimentos via câmera (Gemini) e resumo nutricional.
- Inferência: Ajudar o usuário a manter hábitos alimentares saudáveis, atingir metas diárias e visualizar progresso com UX rápida, offline‑friendly (SharedPreferences) e foco em ações recorrentes.

## Personas
- Inferência
  - Iniciante em controle calórico: quer registrar refeições básicas e ver calorias restantes.
  - Atento a macros: precisa acompanhar carb/proteína/gordura por refeição e no dia.
  - Usuário com rotina: usa favoritos, presets de porção, e duplicação de itens.
  - Explorador/IA: quer capturar alimentos por câmera e buscar por código de barras.

## Fluxos críticos
- Observado
  - Splash → inicialização → rota seguinte via `SplashScreen._navigateToNextScreen(route)` (pushReplacementNamed).
  - Shell com abas: Diário (dashboard), Buscar/Log (FoodLogging), Progresso, Perfil; ação central abre bottom‑sheet de atalho para adicionar.
  - Food logging: busca (OFF), presets de porção, favoritos e meus alimentos; grava em SharedPreferences (diário).
  - Exportar/Importar diário e compartilhar (web/nativo + share_plus) — a partir do dashboard.
  - Notificações locais de hidratação (config em UserPreferences).
- Inferência
  - Onboarding de metas (Goals Wizard) antes de uso pleno do diário.
  - Fluxo de receita → detalhe → adicionar aos registros.
  - IA (Gemini): captura imagem → parse JSON nutricional → sugerir itens para adicionar.

## KPIs
- Inferência: retenção D7/D30, % dias com log (por usuário), DAU/WAU/MAU, % dias com meta atingida, média de entradas/dia, taxa de uso de lembretes de hidratação, latência média de busca/IA, crashes.

## MVP (escopo)
- Observado: registro manual + busca OFF; dashboard diário/semanal; metas + preferências; favoritos/“meus alimentos”; notificações locais; sem Firebase; sem internacionalização; Navigator 1.0; armazenamento local; AI Gemini opcional por chave.
- Não‑escopo (neste ciclo): contas/login persistentes em backend; sincronização multi‑dispositivo; i18n; deep links; GraphQL; analytics de telemetria.

## Regras de UX
- Observado: não perder contexto ao navegar (RootShell mantém estado da tab, data via ValueNotifier; parâmetros por `ModalRoute.settings.arguments`).
- Observado: splash garante tempo mínimo e fallback de erro com retry; bottom‑sheet para ações rápidas.
- Inferência: não resetar filtros e histórico de busca; preservar data selecionada no diário ao voltar; feedback imediato (SnackBar) em ações de hidratação; evitar bloqueios longos na IA (mostrar progresso/cancelar).

## Referências
- lib/routes/app_routes.dart:1-220
- lib/presentation/root_shell/root_shell.dart:1-240
- lib/presentation/food_logging_screen/food_logging_screen.dart:1-300
- lib/presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart:1-220
- lib/services/user_preferences.dart:1-320
- lib/services/nutrition_storage.dart:1-220
- lib/services/notifications_service.dart:1-200
- lib/services/gemini_client.dart:1-200
