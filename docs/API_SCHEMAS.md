# Esquemas de API — NutriTracker

## Sumário
- Gemini (Google Generative Language) — multimodal
- Open Food Facts — busca e barcode
- USDA FoodDataCentral — busca
- Erros e políticas de retry
- Observado vs. Inferência

## Gemini — Multimodal (imagem + texto)
- Endpoint base: `https://generativelanguage.googleapis.com/v1`
- Recurso: `POST /models/{model}:generateContent?key={API_KEY}`
- Headers: `Content-Type: application/json`
- Models candidatos (observado): `gemini-1.5-flash-002`, `gemini-1.5-flash-latest`, `gemini-1.5-flash-8b`, `gemini-1.0-pro-vision`, `gemini-pro-vision`.
- Request (observado em `GeminiClient.createMultimodal`):
```json
{
  "contents": [{
    "role": "user",
    "parts": [
      {"text": "<prompt>"},
      {"inlineData": {"mimeType": "image/jpeg", "data": "<base64>"}}
    ]
  }],
  "generationConfig": {"maxOutputTokens": 1024}
}
```
- Response (observado):
```json
{
  "candidates": [
    {"content": {"parts": [{"text": "<texto>"}]}}
  ]
}
```
- Parsing (observado): extrai primeiro `parts[0].text` e tenta recortar JSON `{ ... }` com campo `foods` para `FoodNutritionData`.

## Open Food Facts — REST público
- Base: `https://world.openfoodfacts.org`
- Busca: `GET /cgi/search.pl?search_terms=<q>&search_simple=1&json=1&page_size=5`
- Por código: `GET /api/v0/product/{barcode}.json`
- Headers: padrão do `dio` (nenhum específico requerido)
- Mapeamento (observado):
  - `product_name` → `description`
  - `brands` (primeira) → `brand`
  - `nutriments.energy-kcal_100g` → kcal/100g; `carbohydrates_100g`, `proteins_100g`, `fat_100g`

## USDA FoodDataCentral — REST (chave opcional)
- Base: `https://api.nal.usda.gov/fdc/v1`
- Busca: `GET /foods/search?api_key=<API_KEY>&query=<q>&pageSize=5`
- Headers: padrão do `dio` (nenhum específico requerido; API key via query)
- Mapeamento (observado):
  - `labelNutrients.calories.value` → kcal
  - `labelNutrients.carbohydrates/protein/fat.value` → macros
  - Fallback: varrer `foodNutrients` por nome/`unitName` (kcal/‘carbohydrate’/‘protein’/‘fat’)

## Erros/Retry (observado/inferência)
- Gemini (observado):
  - Retentativas por modelo (até `maxRetriesPerModel=3`), troca de modelo em caso de 429/503/`RESOURCE_EXHAUSTED`/`UNAVAILABLE` com backoff exponencial + jitter.
  - Lança `GeminiException` com `statusCode` e `message` ao esgotar tentativas.
- OFF/FDC (observado): capturam exceções e retornam `[]`/`null` silenciosamente (sem retries explícitos).
- Inferência: timeouts — OFF/FDC `connect/receive: 10s`; Gemini `connect: 20s`, `receive/send: 60s` (BaseOptions).

## Observado vs. Inferência
- Observado: rotas, payloads e campos mapeados no código dos serviços.
- Inferência: contratos de resposta simplificados, ausência de paginação/erros detalhados tratados a nível de UI.

## Referências
- lib/services/gemini_client.dart:1-220
- lib/services/gemini_service.dart:1-160
- lib/services/fooddb/open_food_facts_service.dart:1-220
- lib/services/fooddb/food_data_central_service.dart:1-200
