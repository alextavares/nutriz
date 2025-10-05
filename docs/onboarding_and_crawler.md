Onboarding (NutriTracker)
-------------------------

- Nova rota: `/onboarding` (arquivo `lib/presentation/onboarding/onboarding_flow.dart`).
- Splash decide enviar para onboarding quando for o primeiro uso ou quando a
  flag `onboarding_completed_v1` ainda não estiver marcada.
- Passos atuais:
  1) Info (mensagem de equilíbrio).
  2) Compromisso (marca o streak `commitment` para hoje e exibe os últimos 7 dias; cria conquistas simples via GamificationEngine).
  3) Metas (abre o `GoalsWizard`).
  4) Lembretes/Notificações (ativar lembretes de hidratação e solicitar permissão).
- Ao concluir: grava `onboarding_completed_v1=true` e `is_first_launch=false` e
  navega para `/login-screen`.


Crawler ADB (YAZIO)
-------------------

Script: `scripts/yazio_flowmap.py`

Requisitos:
- `adb` no PATH
- Emulador com YAZIO instalado (ex.: `emulator-5556`)

Uso:
```
python scripts/yazio_flowmap.py --device emulator-5556 --pkg de.yazio.android \
       --out data/yazio_flow --max-steps 25 --max-depth 3 --top-k 3 \
       --prefer "continue,next,skip,allow" --avoid "buy,subscribe,trial,share"
```

Saídas:
- `data/yazio_flow/nodes/*_tree.xml` (UIAutomator XML por tela)
- `data/yazio_flow/nodes/*_screenshot.png` (screenshot por tela)
- `data/yazio_flow/flow.json` (grafo: nodes/edges)

Observações/limites:
- Foco em “heurísticas de onboarding”: prioriza botões `Continuar/Next/Skip/OK/Allow`.
- Não copia textos nem ativos do app; o material serve apenas como referência de
  fluxo de navegação para inspirar a implementação.
- Pode parar ao detectar loop; rode novamente ajustando `--max-steps` ou use o
  emulador manualmente para reposicionar a navegação.

Visualização do grafo
---------------------

- Gerar DOT/PNG (Graphviz opcional):
```
python scripts/flow_to_dot.py --in data/yazio_flow/flow.json --out data/yazio_flow/flow
# Se tiver graphviz instalado, cria PNG; sempre cria .dot
```

- Gerar HTML interativo (Viz.js via CDN, sem instalar nada):
```
python scripts/flow_to_html.py --in data/yazio_flow/flow.json --out data/yazio_flow/flow.html
```
Abra o HTML no navegador para visualizar o grafo.


Comparar fluxos (YAZIO vs NutriTracker)
---------------------------------------

Gerar um relatório HTML com métricas e labels de ações em comum/únicas:

```
python scripts/compare_flows.py \
  --a data/yazio_flow/flow.json \
  --b data/nutritracker_flow/flow.json \
  --out data/flow_compare/report.html
```
