# Plano de Implementação — NutriTracker (paridade com YAZIO)

Este plano se baseia nas capturas salvas em `assets/comparison.html` e prioriza paridade visual/funcional por fluxo.

## 1) Design System (Fundação)
- Tokens: cores (claro/escuro), tipografia (escala/line-height), espaçamentos, raio, elevação.
- Saídas: `design/tokens.json` (seguir `design/tokens.schema.json`).
- Tarefas:
  - Extrair paleta principal (primária/secundária, sucesso/aviso/erro) das telas de YAZIO.
  - Definir escala tipográfica (h1/h2/h3/subtitle/body/caption) e pesos.
  - Ajustar espaçamentos e raio de canto de componentes (cards, botões, campos).
  - Aplicar tokens no tema do app (claro/escuro) e validar com capturas `dark`/`fontlg`.

## 2) Navegação e Estrutura
- Bottom Tabs: alinhar quantidade, ordem e ícones às telas de referência.
- Cabeçalhos: títulos consistentes, ações (search/settings) e estados (sticky/scroll).
- Tarefas:
  - Normalizar estado selecionado da aba (cor/ícone/label).
  - Definir rotas equivalentes a Diário, Adição, Busca, Metas/Perfil, Analytics.

## 3) Componentes
- Botão primário (CTA): cor/elevação, tamanhos (normal/large), estado disabled/loading.
- Cards/List Rows: imagem + textos + métricas (macros), estados vazios, separadores.
- FAB e Bottom Sheet: posição, raio e animações.
- Campos de busca: ícone, placeholder, clear, foco.

## 4) Fluxos
### Diário/Dashboard
- Metas de calorias/macros por refeição; totais do dia; navegação por data.
- Tarefas: componentes de meta, cards de refeição, cabeçalho com seletor de data.

### Adicionar Refeição
- Acesso via FAB e via Diário; últimas seleções e categorias; seletor de porções.
- Tarefas: lista de rápidos, detalhe do alimento (quantidade/unidade), validações.

### Busca de Alimentos
- Campo visível sempre; sugestões recentes; categorias/filtros; linha com macros.
- Tarefas: UI de resultados, estados vazio/erro, integração com detalhe do alimento.

### Metas
- Onboarding de metas (peso/atividade), ajuste de macros por refeição.
- Tarefas: formulários com stepper, validações, visualização de metas.

### Analytics
- Gráficos semanal/mensal (calorias, macros, peso), troca de período.
- Tarefas: componentes de gráfico (barras/anel), sumários.

### Configurações
- Perfil/unidades/notificações/integrações, tema claro/escuro.
- Tarefas: lista categorizada, toggles, selectores e telas de detalhe.

## 5) Qualidade e Acessibilidade
- Dark mode: contraste e cores de feedback.
- Fontes grandes: checar truncamentos, quebras de layout e hierarquia.
- Desempenho: listas virtualizadas e cache de imagens.

## 6) Entregas Incrementais (sprints)
1. Fundações (tokens + bottom tabs + CTA + cards básicos)
2. Diário (metas/macros + navegação de dia)
3. Adicionar Refeição (lista rápida + detalhe + porções)
4. Busca (campo + resultados + integração)
5. Metas (formulários + visualização)
6. Analytics (gráficos + períodos)
7. Configurações (perfil/unidades/tema) + polimento de dark/accessibilidade

