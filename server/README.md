# NutriTracker AI Coach — Servers & Examples

## FastAPI (Python)
- Path: `server/fastapi`
- Run:
  - `pip install -r server/fastapi/requirements.txt`
  - `uvicorn server.fastapi.main:app --reload --port 8001`
- Features: includes nutrition extras (`acucar`, `fibra`, `sal_g`, `sodio_mg`) and simple in-memory caching for demo endpoints.
- Env: `OFF_CACHE_TTL_MS` (default 3600000), `CACHE_MAX` (default 200).
 - Integrations:
   - Open Food Facts (search/barcode): `OFF_BASE_URL` (default `https://world.openfoodfacts.org`), `OFF_USER_AGENT`.
   - Vision provider for `/analisar_foto`:
     - Set `VISION_PROVIDER` to `openai` or `gemini`.
     - OpenAI: `OPENAI_API_KEY`, optional `OPENAI_VISION_MODEL` (default `gpt-4o-mini`).
     - Gemini: `GEMINI_API_KEY`, optional `GEMINI_VISION_MODEL` (default `gemini-1.5-flash`).
     - Image caching: `IMAGE_CACHE_TTL_MS`.

## Express (Node.js)
- Path: `server/express`
- Run:
  - `npm i`
  - Configure `.env` (copy from `.env.example`)
    - `cp server/express/.env.example server/express/.env` and fill keys
    - Required: `OPENAI_API_KEY`
    - Optional: `OPENAI_MODEL`, `VISION_PROVIDER`, `GEMINI_API_KEY`, `PORT`
    - Optional CORS allowlist for web tests: `CORS_ALLOWED_ORIGINS=http://localhost:3000`
  - `npm run dev` (default port `8002`)

Integrations:
- Open Food Facts (search/barcode): set optionally `OFF_BASE_URL` (default `https://world.openfoodfacts.org`) and `OFF_USER_AGENT`.
- Vision provider for `/analisar_foto` e `/vision/analyze_food`:
  - Configure `VISION_PROVIDER` com `openai`, `openrouter` ou `gemini`.
  - OpenAI: `OPENAI_API_KEY`, opcional `OPENAI_VISION_MODEL` (padrão `gpt-4o-mini`). Usa JSON estruturado e aceita `image_base64`.
  - OpenRouter: `OPENROUTER_API_KEY`, opcional `OPENROUTER_MODEL` (padrão `openai/gpt-4o-mini`) e cabeçalhos `OPENROUTER_SITE_URL` / `OPENROUTER_SITE_NAME` (recomendado para quota). A chave fica apenas no servidor.
  - Gemini: `GEMINI_API_KEY`, opcional `GEMINI_VISION_MODEL` (padrão `gemini-1.5-flash`). Aceita `image_base64`; se `image_url` for enviado, o servidor faz cache e converte.

Endpoints relevantes:
- `POST /analisar_foto`: retorna candidatos simples `{ nome, porcao, confianca }` (coach/chatbot).
- `POST /vision/analyze_food`: retorna `foods` com macros completos para uso no app móvel.

Caching (in-memory):
- OFF requests: `OFF_CACHE_TTL_MS` (default 3600000 ms), `CACHE_MAX` (default 200 entries).
- Image fetch (Gemini inline): `IMAGE_CACHE_TTL_MS` (default 3600000 ms).

Rate limiting & retries:
- Global rate limit: `RATE_LIMIT_WINDOW_MS` (default 60000), `RATE_LIMIT_MAX` (default 60 req/window).
- Photo analysis rate limit: `RATE_LIMIT_PHOTO_MAX` (default 10 req/window).
- OFF + image fetch use exponential backoff (3 retries).

CORS:
- Enabled by default for development.
- Set `CORS_ALLOWED_ORIGINS` to a comma-separated allowlist in production.

Endpoints implement the tools contract in `docs/ai/tools_contract.json` (stubs). Replace TODOs with real data sources (TACO/USDA/OFF) and persistence.

## LLM Tool-Calling Examples (Node)
- Path: `server/express/llm_examples`
- Env vars: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`
- Optional: `EXPRESS_BASE_URL` (default `http://localhost:8002`)
- For image analysis in examples: set `VISION_PROVIDER` (`openai|gemini`) and corresponding API key.
- Run the Express server first.
- Examples:
  - `node server/express/llm_examples/openai_tools_demo.mjs`
  - `node server/express/llm_examples/anthropic_tools_demo.mjs`
  - `node server/express/llm_examples/gemini_tools_demo.mjs`

These scripts register tools (`planejar_jejum`, `buscar_alimento`, `analisar_barcode`, `analisar_foto`, `obter_estatisticas_usuario`, `sugerir_refeicao`), let the model decide tool calls, then route tool calls to the local Express endpoints and return a final user-facing reply.

Coach chat endpoint (Express):
- `POST /coach_chat` with JSON `{ "message": "texto", "history": [{"role":"user|assistant","content":"..."}] }`
- Uses OpenAI tool-calling and calls local tools (`/buscar_alimento`, `/analisar_barcode`, etc.).
- Response: `{ "reply": "texto" }`.
 - Quick test (with OFF and Vision):
   - Search (OFF): `curl -X POST :8001/buscar_alimento -H 'Content-Type: application/json' -d '{"query":"arroz","fonte":"open_food_facts","top_k":5}'`
   - Barcode (OFF): `curl -X POST :8001/analisar_barcode -H 'Content-Type: application/json' -d '{"barcode":"7891000319310"}'`
   - Photo (Vision): `curl -X POST :8001/analisar_foto -H 'Content-Type: application/json' -d '{"image_url":"https://upload.wikimedia.org/wikipedia/commons/2/2f/Cooked_chicken.jpg"}'`
