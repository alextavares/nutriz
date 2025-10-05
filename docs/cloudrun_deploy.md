# NutriTracker Coach — Deploy no Google Cloud Run

Passo a passo para publicar o backend Express (`server/express`) no Google Cloud Run mantendo as chaves do OpenRouter em segurança.

## 1. Pré-requisitos

- Projeto GCP com faturamento habilitado.
- CLI do Google Cloud instalada e atualizada (`gcloud components update`).
- Autenticação configurada (`gcloud auth login`, `gcloud auth configure-docker`).
- Defina projeto e região default:
  ```bash
  gcloud config set project SEU_PROJETO
  gcloud config set run/region us-central1  # ajuste conforme necessidade
  ```

## 2. Preparar o código

1. Criar `server/express/.dockerignore` para evitar copiar arquivos desnecessários:
   ```
   node_modules
   npm-debug.log
   llm_examples
   *.md
   ```
2. Criar `server/express/Dockerfile`:
   ```dockerfile
   FROM node:20-alpine

   WORKDIR /usr/src/app

   COPY package*.json ./
   RUN npm ci --omit=dev

   COPY . .

   ENV NODE_ENV=production \
       PORT=8080

   EXPOSE 8080
   CMD ["node", "index.js"]
   ```

> Cloud Run espera que o container escute na porta `8080`; o Express já respeita `process.env.PORT`.

## 3. Build com Cloud Build

Enviar a pasta `server/express` direto para o Cloud Build:

```bash
gcloud builds submit --pack image=gcr.io/SEU_PROJETO/nutritracker-coach --source=server/express
```

> Alternativa com Dockerfile explícito: `gcloud builds submit --tag gcr.io/SEU_PROJETO/nutritracker-coach server/express`.

## 4. Guardar segredos no Secret Manager

Criar segredos para cada chave sensível:

```bash
printf 'sk-or-...' | gcloud secrets create openrouter-api-key --data-file=-
printf 'https://seuapp.com' | gcloud secrets create openrouter-site-url --data-file=-    # opcional
printf 'NutriTracker' | gcloud secrets create openrouter-site-name --data-file=-         # opcional
```

Repita para outros provedores (Gemini, OFF etc.).

## 5. Deploy no Cloud Run

Executar o deploy referenciando as secrets:

```bash
gcloud run deploy nutritracker-coach \
  --image gcr.io/SEU_PROJETO/nutritracker-coach \
  --region us-central1 \
  --platform managed \
  --no-allow-unauthenticated \  # avalie liberar ou proteger com auth
  --update-env-vars VISION_PROVIDER=openrouter \
  --update-secrets OPENROUTER_API_KEY=openrouter-api-key:latest \
  --update-secrets OPENROUTER_SITE_URL=openrouter-site-url:latest,OPENROUTER_SITE_NAME=openrouter-site-name:latest
```

- Para outros env vars (`CORS_ALLOWED_ORIGINS`, `OFF_BASE_URL` etc.), adicione em `--update-env-vars`.
- Se decidir expor publicamente, troque por `--allow-unauthenticated`, mas considere autenticação e rate limits adicionais.

## 6. Testar

Pegue a URL do serviço:

```bash
gcloud run services describe nutritracker-coach --region us-central1 --format='value(status.url)'
```

Teste o endpoint de visão:

```bash
curl -X POST "https://URL/vision/analyze_food" \
  -H "Content-Type: application/json" \
  -d '{"image_url":"https://exemplo.com/foto.jpg"}'
```

Deve retornar `{ "foods": [...] }` com os dados do provedor configurado.

## 7. Integrar com o app Flutter

- Configure `COACH_API_BASE_URL` (via `env.json` em dev ou `--dart-define` em CI/CD) apontando para a URL do Cloud Run, por exemplo `https://nutritracker-coach-xxxxx.a.run.app`.
- Em build de produção, não inclua chaves no bundle; apenas a URL do backend.

## 8. Endurecer produção

- Avalie autenticação (Firebase Auth, Identity-Aware Proxy) se o serviço for público.
- Ajuste `RATE_LIMIT_*` para tráfego real.
- Configure alertas no Cloud Logging para falhas em `/vision/analyze_food`.

## 9. Próximos passos opcionais

- Automatizar deploy com Cloud Build Trigger ou GitHub Actions.
- Criar versão FastAPI/Lambda se preferir outro runtime.
- Incorporar monitoramento adicional (Cloud Armor, Cloud Trace).
