# Playbook do Agente (Codex) — NutriTracker

## Sumário
- Objetivo: evitar "reinventar o projeto" a cada edição
- Rotina de inicialização (leitura dos docs + mapeamento)
- Rotina antes de qualquer edição de código
- Templates de prompt (para você colar ao iniciar/editar)
- Checagem de saída e salvaguardas
- Observado vs. Inferência

## Objetivo
Garantir que o agente leia a documentação em `/docs` e analise o projeto antes de propor/editar código, reutilizando padrões, rotas, estado e políticas já estabelecidos.

## Rotina de inicialização (sempre que abrir o projeto)
1) Ler rapidamente os docs base (na ordem):
   - `docs/stack_layout.md` (stack + layout)
   - `docs/PRD.md` (objetivo/personas/fluxos)
   - `docs/ARCHITECTURE.md` (camadas + como rodar)
   - `docs/ROUTE_MAP.md` (rotas + parâmetros)
   - `docs/STATE_CONTRACTS.md` (chaves SharedPreferences + eventos)
   - `docs/CODE_MOD_POLICY.md` (política de mudança)
2) Fazer um resumo curto (5–8 bullets) para si e confirmar supostos impactos.
3) Construir um plano de ação incremental (2–5 passos) e pedir validação se o escopo for ambíguo.

## Rotina antes de qualquer edição de código
- Confirmar:
  - Rotas afetadas (conferir `ROUTE_MAP.md` e `lib/routes/app_routes.dart`).
  - Estado/persistência afetados (`STATE_CONTRACTS.md` + serviços em `lib/services/**`).
  - Padrões de UI/tema e componentes existentes (`COMPONENT_CATALOG.md`).
  - Políticas de mudança e proibições (`CODE_MOD_POLICY.md`).
- Propor: PLANO → DIFFS mínimos → TESTES manuais indicados → possibilidade de ROLLBACK.
- Evitar: criar novas dependências, reescrever telas inteiras, resetar `selectedDate`, filtros, histórico.

## Templates de prompt

### 1) Boot (ao iniciar a sessão)
```
Contexto: Projeto NutriTracker (Flutter). Antes de agir, faça:
- Ler docs: stack_layout.md, PRD.md, ARCHITECTURE.md, ROUTE_MAP.md, STATE_CONTRACTS.md, CODE_MOD_POLICY.md.
- Resumir em 6 bullets o que é relevante para a sessão.
- Propor um plano de 3–5 passos e aguardar meu ok antes de editar.
Restrições: mudança mínima, respeitar políticas e contratos.
```

### 2) Ordem de edição (genérica)
```
Tarefa: <descrever mudança>
Regras:
- Antes de editar, confirmar rotas/estado/serviços afetados nos docs.
- Apresentar PLANO com passos pequenos e diffs esperados.
- Implementar mudanças cirúrgicas, sem reset de estado/navegação.
- Listar testes manuais focados no que mudou.
Saída esperada: diffs + passos de teste. Não alterar segredos.
```

### 3) Hardening de escopo
```
Valide: a mudança quebra algum contrato de rota (ROUTE_MAP.md) ou chaves do SharedPreferences (STATE_CONTRACTS.md)?
Se sim, proponha migração/compatibilidade; se não, siga com diffs mínimos.
```

## Checagem de saída e salvaguardas
- Conferir diffs vs. `CODE_MOD_POLICY.md` (não reescrever telas, não adicionar deps sem motivo, etc.).
- Conferir que rotas e parâmetros estão coerentes com `ROUTE_MAP.md`.
- Conferir que chaves persistidas seguem `STATE_CONTRACTS.md` (e versões, se houver).
- Sugerir testes manuais focados (telas/fluxos tocados) e, se existirem, testes automatizados adjacentes.

## Observado vs. Inferência
- Observado: docs atuais cobrem stack, arquitetura, rotas, estado, APIs, componentes e políticas.
- Inferência: usar estes templates como "preambular" para o agente, garantindo leitura dos docs antes de qualquer ação.

## Referências
- docs/stack_layout.md:1-114
- docs/PRD.md:1-54
- docs/ARCHITECTURE.md:1-69
- docs/ROUTE_MAP.md:1-57
- docs/STATE_CONTRACTS.md:1-60
- docs/CODE_MOD_POLICY.md:1-37

