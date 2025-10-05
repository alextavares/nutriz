# Tabela de Paridade — NutriTracker x YAZIO

Objetivo: alinhar UX/funcionalidades do nosso app às principais telas e fluxos do YAZIO sem copiar ativos proprietários (ícones/textos/código). Sempre respeitar o estado atual do projeto e evoluir telas existentes — nada de criar telas duplicadas.

Evidências coletadas via MCP Android (emulator-5554/YAZIO):
- Diário: docs/yazio/home-initial.png
- Receitas: docs/yazio/recipes-initial.png
- Perfil: docs/yazio/profile-initial.png
- Jejum: docs/yazio/fasting-initial.png, docs/yazio/fasting-initial-2.png (UI dump pendente por limitação pontual)

Rotas atuais (Flutter) mapeadas:
- Diário → `AppRoutes.dailyTrackingDashboard` (lib/presentation/daily_tracking_dashboard)
- Jejum → `AppRoutes.intermittentFastingTracker` (lib/presentation/intermittent_fasting_tracker)
- Receitas → `AppRoutes.recipeBrowser` (lib/presentation/recipe_browser)
- Perfil/Metas → `AppRoutes.profile` + `AppRoutes.goalsWizard`
- Anotações → `AppRoutes.notes`

## Paridade Por Tela

### Diário (YAZIO: “Diário”) ↔ DailyTrackingDashboard
Status geral: forte paridade, requer polimento visual e microinterações.

Checklist:
- Resumo do dia (Consumidas/Restantes/Gastas): Presente. Melhorias: formatação numérica locale (ex.: 1.459). [PARCIAL]
- Macros (Carboidratos/Proteína/Gordura com “consumido/total g”): Presente (MacronutrientProgressWidget). Ajustar estilo das barras/labels. [PARCIAL]
- Sessões de refeições (Café/Almoço/Jantar/Lanches com metas kcal): Presente. Avaliar subtítulos e alinhamentos. [PARCIAL]
- Água com “+250 ml” e meta ajustável: Presente (add/sub, meta). Refinar CTA + feedback. [PARCIAL]
- Bottom navigation (Diário/Jejum/Receitas/Perfil): Presente e funcional. Ajustar tipografia e cores para maior contraste. [PARCIAL]
- Ações de topo (data/atalhos): Presente. Revisar ícones/tamanhos/tooltip. [PARCIAL]

Aceitação (validado via MCP):
- Após tocar “+250 ml”, label de água incrementa e snackbar confirma.
- Números do resumo exibem separador de milhar conforme locale.
- Barras de macros exibem “x / y g” com contraste AA.

### Jejum (YAZIO: “Jejum”) ↔ IntermittentFastingTracker
Status geral: cobrimos timer, métodos 16:8/20:4, lembretes e conquistas. Falta ajuste visual e estados vazios/onboarding.

Checklist:
- Timer circular com tempo restante e método: Presente. Polir tipografia e animação. [PARCIAL]
- Seleção de método e meta custom: Presente. [OK]
- Lembretes diários + horário de janela (início/fim): Presente. Exibir timezone e ‘mute until’ com cópia clara. [PARCIAL]
- Resumo semanal (barras/dias): Presente. Melhorar legenda/cores. [PARCIAL]
- Conquistas (badges): Presente. Avaliar densidade/ordem. [PARCIAL]
- Estados vazios/primeiro uso: Implementar mensagens ilustrativas suaves. [FALTA]

Aceitação (via MCP):
- Ativar jejum inicia timer e agenda notificação de fim (quando permissões ativas).
- Alternar método atualiza alvo e rótulos.

### Receitas (YAZIO: “Receitas”) ↔ RecipeBrowser
Status geral: funcional (busca, filtros, grid, favoritos). YAZIO tem destaques por faixa calórica/categorias visuais.

Checklist:
- Busca com realce dinâmico: Presente. [OK]
- Filtros (chip/bottom sheet): Presente. [OK]
- Grade de receitas com favoritos e long-press (ações rápidas): Presente. [OK]
- Descoberta por categorias e “faixas calóricas” (carrosséis/ícones): Implementar seção de destaque. [FALTA]
- CTA “Escolha a refeição” com atalhos (Café/Almoço/Jantar/Lanche): Implementar header com chips. [FALTA]

Aceitação (via MCP):
- Filtro aplicado reflete imediatamente na grade e chips ativos.
- Favoritar alterna estado e mostra snackbar.

### Perfil/Metas (YAZIO: “Perfil”) ↔ ProfileScreen + GoalsWizard
Status geral: cobrimos metas (kcal/macros/água), lembretes e metas por refeição. Melhorar cartões de progresso e resumo curto.

Checklist:
- Cabeçalho com e‑mail/plano (gratuito): Presente. [OK]
- Metas diárias (kcal/macros/água): Presente (editável). [OK]
- Lembretes de hidratação: Presente. [OK]
- Metas por refeição: Presente. [OK]
- Cartão “Meu progresso” (peso/tempo/ETA): Precisa polimento visual. [PARCIAL]
- Resumo compacto (kcal restantes, passos): Adicionar/ajustar card com placeholders para passos. [PARCIAL]

Aceitação (via MCP):
- Editar metas reflete no dashboard (água/macros) após salvar.
- Snackbar de confirmação aparece com contraste adequado.

### Anotações ↔ NotesScreen
Status geral: presente e funcional (categorias, emojis, anexos placeholder, salvar). Alinhar copy e hierarquia tipográfica.

Checklist:
- Criar/editar/excluir anotações com categoria: Presente. [OK]
- Emojis/estados de humor rápidos: Presente. [OK]
- Acesso via Dashboard → card Anotações: Presente. [OK]
- Estilo de editor (título/corpo/CTAs): Refinar espaçamento e pesos. [PARCIAL]

## Backlog Prioritário (foco em telas existentes)

1) Diário — Polimento visual do Resumo e Macros
- Formatar números com locale (ex.: 1.459 em pt-BR).
- Reestilizar barras de macros (espessura, cantos, cores) e labels “x / y g”.
- Ajustar tipografia/tamanhos/cores do bottom nav conforme tema.

2) Jejum — Estados e microcópia
- Estados vazios c/ onboarding curto (uma seção, sem novas telas).
- Exibir timezone ao lado dos horários e “Silenciar até” com rótulo claro.
- Afinar animação do timer e legibilidade dos minutos finais.

3) Receitas — Destaques
- Header com chips “Café/Almoço/Jantar/Lanche”.
- Seção de descobertas por faixa calórica (carrosséis simples reusando grid).

4) Perfil — Resumos compactos
- Card “kcal restantes” e “passos” com placeholders (sem integração de passos).
- Polir “Meu progresso” (eixos, cores, tipografia).

5) Anotações — Editor
- Hierarquia tipográfica (título 20–22 sp, body 14–16 sp).
- Feedback salvar (ícone + snackbar) e acessibilidade de foco.

## Plano de Validação com MCP Android

- Scripts de fluxo por aba (já rodamos no YAZIO); replicar no nosso app:
  - Diário: screenshot + ler labels de resumo/macros/água; acionar “+250 ml” e validar incremento.
  - Jejum: iniciar/pausar jejum, alternar método, validar rótulos/timer.
  - Receitas: aplicar filtro e favoritar; validar chips e snackbar.
  - Perfil: alterar metas e verificar reflexos no dashboard.
- Artefatos: PNG + `mobile_list_elements_on_screen` (JSON) por estado/tela.
- Comparação: inspeção visual manual + (opcional) diff de imagens fora do app.

## Notas e Limites
- Não copiar assets/ícones/strings do YAZIO; replicar apenas padrões de UX.
- Ajustar tudo dentro das telas já existentes; sem rotas novas.

---
Última atualização automática: gerada via assistente + MCP em 2025-09-01.
