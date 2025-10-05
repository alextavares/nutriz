# NutriTracker: Paridade visual com YAZIO + polimentos (Diário, Busca, Detalhe, Metas, Analytics)

## Resumo
- Implementa navegação por abas e captura/comparativo com YAZIO.
- Busca: barra fixa, histórico em chips, resultados com kcal/C/P/G por 100g, chips responsivos (Wrap) e swipe para detalhe.
- Detalhe: macros em destaque e CTA fixo “Adicionar ao diário”.
- Diário: metas por refeição (barras), estados vazios e botões “Adicionar”; espaçamentos/tipografia polidos.
- Metas: Wizard (Calorias → Macros → Confirmar) com validação e atalho no Perfil.
- Analytics: alternância Semana/Mês com capturas + vídeo.
- Design tokens, tabs map e script de paleta; comparativo visual HTML em `assets/comparison.html`; pruning de assets órfãos.

## Escopo das mudanças
- design/: tokens.schema.json, tokens.json, TABS_MAP.md, tabs.json, TODOS.md, palette_reference.json
- scripts/: adb_ui + capturas/fluxos + modos + build_install.sh
- lib/theme/app_theme.dart: cores alinhadas aos tokens
- lib/routes/app_routes.dart: rota `/goals-wizard`
- lib/presentation/
  - daily_tracking_dashboard/*: bottom sheet “Adicionar”; progresso por refeição; estados vazios; polimentos
  - food_logging_screen/*: busca fixa + histórico; chips por 100g; chips responsivos; detalhe com chips e CTA fixo
  - goals_wizard/goals_wizard.dart: wizard de metas
  - profile_screen/profile_screen.dart: atalho “Configurar metas”
- lib/services/user_preferences.dart: histórico de busca e metas por refeição
- assets/comparison.html: página comparativa lado a lado (YAZIO vs NutriTracker)

## Como validar
1) Build/Run
- `flutter pub get`
- `flutter run` (ou build debug + `adb install -r`)

2) Abas
- Diário/Buscar/Metas/Analytics — estado ativo, back e rotas corretas

3) Diário
- Ver barras por refeição (consumido/meta) e estados vazios com botão `Adicionar`
- FAB abre bottom sheet (Buscar / Favoritos / Meus / Duplicar)

4) Busca
- Barra fixa, histórico em chips; digitar “banana”
- Resultados com chips per‑100g (kcal/C/P/G)
- Swipe esquerda → detalhe; CTA fixa adiciona ao diário

5) Detalhe
- Chips de macros (kcal/C/P/G) + linhas detalhadas; CTA fixa funcional

6) Metas
- Perfil → “Configurar metas” → passos com validação (calorias>0, macros≥0; aviso 4/4/9) → salvar → Diário reflete

7) Analytics
- Alternar Semana/Mês; sem jank

8) Comparativo visual
- Abrir `assets/comparison.html` e revisar seções (onboarding/diário/busca/detalhe/metas/analytics/tema)

## QA Checklist
- Temas claro/escuro: contraste AA em chips/divisores/botões
- Acessibilidade: font_scale 1.3–1.5 sem clipping; targets >= 48dp
- Navegação: back/forward estáveis; retorno mantém estado relevante
- Desempenho: scroll suave; abrir sheets/detalhe sem quedas
- Persistência: metas e preferências refletidas após retorno

## Riscos/Observações
- Contraste pode variar conforme device (revisar dark/light)
- CTA fixo no detalhe requer altura útil — validar em telas pequenas
- Wizard distribui metas por refeição (25/35/30/10) como padrão — sujeito a ajuste do produto

## Comandos úteis
- Análise: `flutter analyze`
- Build APK debug: `flutter build apk --debug`
- Instalar: `adb install -r build/app/outputs/flutter-apk/app-debug.apk`
- Script: `bash scripts/build_install.sh` (detecta Windows/WSL)

## Versão/Changelog
- Bump para `1.1.0+2`; `CHANGELOG.md` atualizado

## Capturas rápidas
- Ver `assets/comparison.html` para screenshots e vídeos (YAZIO vs NutriTracker)
