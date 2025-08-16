# Backlog de Implementação — NutriTracker (paridade com YAZIO)

Formato das tarefas
- Título: objetivo específico por fluxo/componente
- Prioridade: P1 (alta), P2 (média), P3 (baixa)
- Critérios de aceitação: lista objetiva de checks
- Referências: caminhos de imagens/vídeos no repositório

## Design System (Tokens, Tipografia, Espaçamentos)
- [ ] P1: Consolidar tokens de cor (light/dark) no tema
  - Critérios de aceitação:
    - `activeBlue=#3D91DA`, `successGreen=#2E7D32`, `warningAmber=#F57C00`, `errorRed=#D32F2F` aplicados
    - Background/Surface no dark: `#0F1113`/`#14171A` em telas principais
    - Textos prim./sec. com contraste adequado (AA)
  - Referências: `design/tokens.json`, `assets/comparison.html`
- [ ] P2: Ajustar escala tipográfica e line-height
  - Critérios de aceitação:
    - Títulos/subtítulos/corpo alinhados ao `tokens.json`
    - Nenhum corte/truncamento em `font_scale=1.3`
  - Referências: `assets/reference_yazio/*`, `assets/nutritracker/nt_fontlg_home.png`
- [ ] P2: Espaçamentos e raio de canto
  - Critérios de aceitação:
    - Cards com radius 12–16 e respiro consistente (md–lg)
    - List rows com altura mínima e separadores sutis
  - Referências: `assets/reference_yazio/yazio_diary.png`

## Navegação (Bottom Tabs + AppBar)
- [ ] P1: Padronizar abas (labels/ícones/estado ativo)
  - Critérios de aceitação:
    - Abas: Diário (`today`), Buscar (`search`), Metas (`flag`), Analytics (`insights`)
    - Estado ativo usa `primary` + label visível
    - Navegação entre rotas configurada (routes existentes)
  - Referências: `design/tabs.json`, `assets/nutritracker/nt_tabs_post_build_*.mp4`
- [ ] P2: AppBar com acesso a Configurações
  - Critérios de aceitação:
    - Ícone `settings` visível onde aplicável
    - Navegação para tela de perfil/configs
  - Referências: `assets/reference_yazio/yazio_settings.png`, `assets/nutritracker/nt_settings_post.png`

## Diário/Dashboard
- [ ] P1: Componentizar cards de refeição + metas
  - Critérios de aceitação:
    - Cards por refeição com metas (kcal/macros) e progresso
    - Seletor de data (ontem/hoje/amanhã)
    - Estado vazio com mensagem/ilustração
  - Referências: `assets/reference_yazio/yazio_diary.png`, `assets/nutritracker/nt_diary_post.png`

## Adicionar Refeição
- [ ] P1: Bottom sheet de Adicionar com atalhos
  - Critérios de aceitação:
    - Atalhos: recentes e favoritos visíveis
    - Acesso via FAB e via diário
  - Referências: `assets/nutritracker/nt_add_post_build_*.mp4`
- [ ] P1: Seletor de porções unificado
  - Critérios de aceitação:
    - Unidades (g/unidade/colher/xícara) com presets
    - Preview de macros por porção e total
  - Referências: `assets/reference_yazio/yazio_food_detail.png`, `assets/nutritracker/nt_food_detail_post.png`

## Busca de Alimentos
- [ ] P1: Barra de busca fixa + histórico/sugestões
  - Critérios de aceitação:
    - Campo sempre visível com botão clear
    - Sugestões recentes e categorias/filtros básicos
  - Referências: `assets/reference_yazio/yazio_search*.png`, `assets/nutritracker/nt_search_banana_post.png`
- [ ] P1: Resultado com macros e navegação para detalhe
  - Critérios de aceitação:
    - Linha exibe kcal/carb/prot/gord
    - Toque abre detalhe do alimento
  - Referências: `assets/nutritracker/nt_search_post_build_*.mp4`

## Detalhe de Alimento
- [ ] P1: Header + macros em destaque + CTA
  - Critérios de aceitação:
    - Título e macros (kcal/macros) claramente visíveis
    - CTA principal (Adicionar) com cor/elevação do token
  - Referências: `assets/reference_yazio/yazio_food_detail.png`, `assets/nutritracker/nt_food_detail_post.png`

## Metas/Perfil
- [ ] P2: Wizard de metas e edição
  - Critérios de aceitação:
    - Passos (peso/atividade/calorias/macros)
    - Metas por refeição com validação
  - Referências: `assets/reference_yazio/yazio_settings.png`, perfil existente em `lib/presentation/profile_screen`

## Analytics
- [ ] P2: Gráficos semanal/mensal + controles de período
  - Critérios de aceitação:
    - Alternância semana/mês com sumários
    - Paleta de gráficos consistente e legível em dark/light
  - Referências: `assets/nutritracker/nt_post_build_overview_*.mp4`

## Configurações
- [ ] P2: Organização por seções + aparência
  - Critérios de aceitação:
    - Seções: Perfil, Notificações, Integrações, Aparência
    - Alternância de tema e persistência
  - Referências: `assets/reference_yazio/yazio_settings.png`, `assets/nutritracker/nt_settings_post.png`

## Acessibilidade e Tema
- [ ] P1: Verificação com `font_scale` alto e dark mode
  - Critérios de aceitação:
    - Nenhum corte/truncamento relevante com fonte grande
    - Contraste AA em dark/light nas principais telas
  - Referências: `assets/nutritracker/nt_dark_home.png`, `nt_fontlg_home.png`, `scripts/capture_modes.py`

---

Notas
- Comparação visual consolidada em `assets/comparison.html`.
- Tokens disponíveis em `design/tokens.json` (ajustar cores de feedback se necessário após QA visual).
- Ícones/labels das abas centralizados em `design/tabs.json`.

