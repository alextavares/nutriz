Cloudflare Worker — NutriTracker (hardened)

Arquivos:
- `server/cloudflare/worker.js`: Worker com rotas e segurança:
  - `GET /` → status
  - `GET /health`, `GET /version`
  - `POST /calcular_metas`
  - `POST /planejar_jejum`
  - `POST /vision/analyze_food` (OpenAI) e alias `POST /analisar_foto`
  - CORS allowlist via `ALLOWED_ORIGINS`; Autorização via `X-App-Token` (se `APP_TOKEN` definido)
- Exposed header: `Retry-After` (para clientes web lerem o tempo de espera em 429)

Como usar no painel da Cloudflare:
1) Crie um Worker “Start from scratch (Hello World)”.
2) Renomeie (ex.: `nutritracker-worker`) e clique em Deploy.
3) Abra o editor rápido do Worker e substitua o conteúdo por `worker.js`.
4) Em Settings → Variables, crie:
   - Secrets:
     - `OPENAI_API_KEY` (obrigatório p/ visão)
     - `APP_TOKEN` (recomendado; exige header `X-App-Token` em todas as rotas não-OPTIONS)
   - Text:
     - `ALLOWED_ORIGINS` (lista separada por vírgula, ex.: `http://localhost:3000,http://127.0.0.1:5173`)
     - `OPENAI_MODEL` (opcional, padrão `gpt-4o-mini`)
     - `VISION_PROVIDER` (por enquanto `openai`)
5) Salve e faça Deploy.

Testes (substitua pela URL gerada):

Ping (com token, pois `APP_TOKEN` pode proteger GET):
```bash
curl -H "X-App-Token: $TOKEN" https://<seu-subdominio>.workers.dev/
```

Calcular metas:
```bash
curl -s -X POST https://<seu-subdominio>.workers.dev/calcular_metas \
  -H 'content-type: application/json' \
  -H "X-App-Token: $TOKEN" \
  -d '{"sexo":"m","idade":32,"peso_kg":78,"altura_cm":178,"nivel_atividade":"moderado","objetivo":"perda"}' | jq .
```

Planejar jejum:
```bash
curl -s -X POST https://<seu-subdominio>.workers.dev/planejar_jejum \
  -H 'content-type: application/json' \
  -H "X-App-Token: $TOKEN" \
  -d '{"protocolo":"16:8","inicio_preferido":"20:00","dias":7}' | jq .
```

Pré-flight (CORS permitido):
```bash
curl -i -X OPTIONS https://<seu-subdominio>.workers.dev/calcular_metas \
  -H 'Origin: http://localhost:3000' \
  -H 'Access-Control-Request-Method: POST'
```

Pré-flight (CORS bloqueado):
```bash
curl -i -X OPTIONS https://<seu-subdominio>.workers.dev/calcular_metas \
  -H 'Origin: http://not-allowed.example' \
  -H 'Access-Control-Request-Method: POST'
```

Analisar foto (OpenAI) com base64:
```bash
IMG='https://images.unsplash.com/photo-1550547660-d9450f859349?w=256&q=60&auto=format&fit=crop'
B64=$(curl -fsSL "$IMG" | base64 -w0)
curl -s -X POST https://<seu-subdominio>.workers.dev/vision/analyze_food \
  -H 'content-type: application/json' \
  -H "X-App-Token: $TOKEN" \
  --data-binary "{\"image_base64\":\"$B64\"}" | jq .
```

Notas:
- Com `ALLOWED_ORIGINS` definido, apenas as origens listadas terão CORS permitido (solicitações sem `Origin` são aceitas normalmente).
- Com `APP_TOKEN` definido, todas as rotas não-OPTIONS exigem `X-App-Token`.
- Para provedores alternativos (Gemini/OpenRouter), amplie conforme `server/express/index.js`.


Rate limit (RATELIMIT via KV)
- Crie o namespace: Workers & Pages → Storage & Databases → KV → Create namespace → `nutritracker_ratelimit`.
- Associe no Worker: Settings → Bindings → Add binding → "KV Namespace" → Variable name `RATELIMIT` → Namespace `nutritracker_ratelimit` → Deploy.
- Variável de texto: `VISION_RATE_LIMIT` (ex.: `20`).
- Teste rápido (substitua BASE e TOKEN):
  - Espera 429 após o limite por minuto.
```
for i in $(seq 1 30); do curl -s -o /dev/null -w "%{http_code}\n" -X POST "$BASE/vision/analyze_food" \
  -H 'content-type: application/json' -H "X-App-Token: $TOKEN" \
  --data '{"image_base64":"dGVzdA=="}'; done
```
  - Para facilitar o teste, defina `VISION_RATE_LIMIT=1` e depois volte para `20`.

Turnstile (anti-bot para Web)
- Crie o widget em Security → Turnstile com Domains: localhost e 127.0.0.1 (e depois seu domínio).
- Copie as chaves:
  - Site key (pública) → usada no front para renderizar o widget e gerar token.
  - Secret key → defina no Worker como `TURNSTILE_SECRET` (Secreto).
- No Worker (Production) → Variables → Deploy:
  - `TURNSTILE_SECRET` (Secreto)
  - `TURNSTILE_REQUIRED=1` (Texto) — exige apenas quando `Origin` está presente (Web).
  - `TURNSTILE_MIN_SCORE=0.3` (opcional; 0 para ignorar score).
- No front Web, envie o token em cada chamada sensível (token é de uso curto).
  - Header: `X-Turnstile-Token: <token>` (recomendado).
  - Alternativo no body: `turnstile_token` ou `cf_turnstile_token`.
- Após usar, resete o widget para próxima chamada (SPA): `turnstile.reset(...)`.
- Mobile/native (sem `Origin`) não exige Turnstile — apenas `X-App-Token`.

Exemplo HTML rápido (localhost):
```html
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
<div id="cf"></div>
<script>
  let tk=null;
  window.onload=()=>turnstile.render(