# Política de Modificações de Código — NutriTracker

## Sumário
- Princípios (adaptar > criar)
- Fluxo recomendado
- Proibições e cautelas
- Observado vs. Inferência

## Princípios
- Adaptar > criar: priorizar reutilizar componentes/serviços existentes antes de adicionar novos.
- Mudança mínima: tocar apenas o necessário e manter estilo do código.
- Compatibilidade: preservar contratos (rotas, chaves de SharedPreferences, assinaturas públicas).

## Fluxo recomendado
1) RESUMO: descreva o problema e objetivo.
2) BASE ENCONTRADA: aponte arquivos relevantes (rotas, telas, serviços, chaves persistidas).
3) PLANO: liste passos concretos, com impacto e rollback possível.
4) DIFFS mínimos: implemente o essencial, mantendo consistência.
5) TESTES: rode fluxos específicos afetados; verifique persistência e navegação.
6) ROLLBACK: mantenha notas para reverter (git revert/branch) se necessário.

## Proibições
- Não quebrar rotas nomeadas existentes (AppRoutes) sem migração.
- Não renomear chaves de SharedPreferences sem script de migração ou fallback.
- Não introduzir dependências pesadas sem alinhamento (ex.: novo gerenciador de estado) — preferir padrões locais.
- Não vazar segredos: use `--dart-define` e evite versionar `env.json`.
- Não reescrever telas inteiras sem necessidade — prefira ajustes incrementais.
- Não resetar estado/navegação do usuário inadvertidamente (preservar `selectedDate`, filtros e histórico).

## Observado vs. Inferência
- Observado: rotas estáticas, estado local e SharedPreferences; serviços `dio` para dados.
- Inferência: adotar feature flags simples via `dart-define` para módulos opcionais (IA, FDC).

## Referências
- lib/routes/app_routes.dart:1-220
- lib/services/nutrition_storage.dart:1-220
- lib/services/user_preferences.dart:1-360
