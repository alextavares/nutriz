# Session Notes

## 2025-01-31

- Refactored the "Horários de jejum" panel (`lib/presentation/intermittent_fasting_tracker/intermittent_fasting_tracker.dart`) to eliminate overflow and provide placeholder bars when data is unavailable.
- Added helper utilities (`_buildJourneyBarColumn`, `_buildMethodBadge`, `_weekdayLabel`, `_formatTimeOfDay`) and re-introduced the fasting schedule layout for easier future styling.
- Analyzer currently flags the pre-existing `_remainingTime` unused warning at line 34 in the intermittent fasting tracker file; no change made yet.
- Discussed next steps for improving overall visual design: establish tokens/ThemeData, identify reference screenshots, and create a golden-screen workflow before propagating new styling.
- Awaiting decisions on design direction (palette, typography, dark/light mode) before generating the Flutter theme and component kit.

- Limpeza em andamento das telas herdadas (activity, AI detection/coach, streaks, profile, progress/recipe) para eliminar `AppTheme` estático e `const` inválidas antes da próxima rodada de goldens.
- Novo plano de captura documentado em `docs/golden_refresh_plan.md` cobrindo AI detection/coach, activity/streak e dashboards após a migração total para tokens.

Next session: choose visual direction, generate Material 3 theme with tokens, refactor core components, then apply to key screens (Daily Dashboard and Fasting).

## 2025-09-19

- Defined the first batch of design tokens (colors, radii, spacing, semantic accents) in `lib/theme/design_tokens.dart` to codify the new Material 3 direction.
- Refactored `AppTheme` to consume the tokens, enable Material 3 components, and expose a semantic color extension while keeping legacy static color constants intact for existing widgets.
- Migrated the shared celebration overlay and dashboard widgets (badges, action CTA, macronutrient + circular progress) to the new token helpers so they respect `ColorScheme`/`AppSemanticColors`.
- Refactored streak chips via a reusable builder and restyled the fasting “Horários de jejum” panel using token-driven surfaces/labels to match the refreshed palette.
- Analyzer now runs with `/home/alext/development/flutter/bin/flutter analyze`, but legacy backup files (`tmp_head_if.dart`, etc.) still break it; waiting to prune them before golden updates.
- Movemos backups herdados para `docs/archive/backups/` e renomeamos para evitar que o analisador escaneie código obsoleto; `flutter analyze` agora acusa apenas consts legacy que serão tratados na próxima rodada.
- Migramos seções-chave do dashboard/jejum (`meal_plan_section_widget`, `logged_meals_list_widget`, controles de jejum) para usar `context.colors` + tokens, deixando registrado o plano de atualizar goldens em `docs/golden_refresh_plan.md`.

- Limpeza em andamento das telas herdadas (activity, AI detection/coach, streaks, profile, progress/recipe) para eliminar `AppTheme` estático e `const` inválidas antes da próxima rodada de goldens.
- Novo plano de captura documentado em `docs/golden_refresh_plan.md` cobrindo AI detection/coach, activity/streak e dashboards após a migração total para tokens.

Next session: finish migrating remaining dashboard/fasting sub-widgets to semantic tokens, remove the stale backup/demo Dart files so analyzer passes, and refresh goldens once the build is clean.

## 2025-09-20

- Tokenizamos o `ProgressOverviewScreen`: gráficos semanais/mensais, breakdown de macros, cartões premium e tooltips agora usam `context.colors`/`context.semanticColors`, eliminando dependências de `AppTheme` e `withOpacity` nesse fluxo.
- Atualizamos o `WeeklyProgressWidget` para reutilizar os tokens (águas, calorias, gradientes) e alinhamos o cartão de hidratação com o novo esquema.
- Migramos o Recipe Browser completo (`recipe_browser.dart` + widgets auxiliares) para as cores semânticas, incluindo search bar, filtros, upsell PRO e cards de receita.
- Ajustamos o diálogo de edição rápida no dashboard diário para tokens + `DropdownButtonFormField.initialValue`, removendo o último `withOpacity` que tocamos.
- Garantimos que a detecção por IA inicializa Gemini/normalizer também para contas não PRO, evitando crashes ao abrir a galeria e mantendo o upgrade apenas como bloqueio de recursos.
- Migramos a experiência de login (logo, formulário, opções sociais) para usar tokens, eliminando `AppTheme`/consts quebradas e alinhando botões/feedback às cores semânticas.
- `flutter analyze` segue acusando erros herdados (consts legadas, widgets não usados, deprecações); a limpeza geral permanece na fila após estabilizarmos os fluxos principais.

Próxima sessão: atacar os warnings herdados (elementos/variáveis não usados, controles deprecatados), seguir com a tokenização das telas faltantes (activity/profile) e executar o refresh de goldens descrito em `docs/golden_refresh_plan.md`.
- Tokenizamos o fluxo completo de jejum intermitente (`lib/presentation/intermittent_fasting_tracker/`) para consumir `context.colors/context.semanticColors`, retirando os acessos diretos a `AppTheme` e alinhando badges, calendário e seletor de métodos aos novos tokens.
- `flutter analyze` segue apontando os avisos herdados (imports/elementos não usados, `withOpacity` em widgets antigos); nenhuma ocorrência nova após o refactor do jejum.
- Substituímos os usos restantes de `withOpacity` (streak coachmark, overlay de celebração, gráficos e CTA do dashboard, visual do scanner) por `withValues`, garantindo compatibilidade com o novo pipeline de cores.
- `flutter analyze` permanece vermelho pelos avisos herdados das telas principais, mas as infos deprecatadas de `withOpacity` e imports não usados sumiram após essa rodada.
- Atualizamos `lib/presentation/dashboard/reference_dashboard_mock.dart` para usar `context.colors/context.textStyles`, removendo `AppTheme` hardcoded e os `const` inválidos que quebravam o analyzer.
- Migramos o grid de ações rápidas e os chips de streak do dashboard aprimorado para os tokens (`context.colors/context.semanticColors`), eliminando `AppTheme` fixos e os `??` redundantes que geravam warnings.
- Removemos imports/variáveis não usadas nos fluxos de registro (alimento/exercício) e simplificamos os chips de streak para evitar null-aware redundantes, reduzindo o ruído do analyzer.
