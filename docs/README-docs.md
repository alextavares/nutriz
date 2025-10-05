# Documentação — Índice e Rotina

## Sumário
- Índice de documentos
- Rotina de atualização
- Observado vs. Inferência

## Índice
- `PRD.md`: objetivo, personas, fluxos, KPIs, UX.
- `ARCHITECTURE.md`: camadas, diagrama ASCII, como rodar/buildar.
- `UX_MAP.md`: rotas/telas, matriz De→Para, invariantes.
- `STATE_CONTRACTS.md`: estados locais, chaves do SharedPreferences, eventos.
- `API_SCHEMAS.md`: endpoints/payloads (Gemini/OFF/USDA), erros/retries.
- `COMPONENT_CATALOG.md`: telas/componentes, props, onde usados.
- `ROUTE_MAP.md`: árvore de rotas e parâmetros.
- `CODE_MOD_POLICY.md`: política de mudanças e fluxo de trabalho.
- `AGENT_PLAYBOOK.md`: rotina do agente (Codex) para ler docs, planejar e só então editar.
- `SECRETS.md`: gestão de segredos (— já criado).
- `stack_layout.md`: stack & layout descobertos (— já criado).

## Rotina de atualização
1) Antes de mudanças profundas, sincronize docs:
   - Atualize `ROUTE_MAP.md` ao alterar `AppRoutes`.
   - Atualize `STATE_CONTRACTS.md` ao mudar chaves/formatos do SharedPreferences.
   - Atualize `API_SCHEMAS.md` ao mudar serviços/contratos da API.
   - Atualize `COMPONENT_CATALOG.md` ao criar/alterar telas/props.
2) Ao abrir PR, inclua diffs dos `.md` relevantes em `/docs`.
3) Após merge, verifique que os exemplos de execução em `ARCHITECTURE.md` e `SECRETS.md` continuam válidos.
4) Sempre iniciar sessões colando o template de boot de `AGENT_PLAYBOOK.md`.

## Observado vs. Inferência
- Observado: rotas/telas e serviços atuais conforme referências.
- Inferência: rotina de docs integrada ao fluxo de PRs.

## Referências
- lib/routes/app_routes.dart:1-220
- lib/presentation/ai_food_detection_screen/ai_food_detection_screen.dart:200-569
- lib/services/gemini_client.dart:1-220
- lib/services/nutrition_storage.dart:1-220
