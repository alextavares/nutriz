import express from 'express'
import fetch from 'node-fetch'
import OpenAI from 'openai'
import { GoogleGenerativeAI } from '@google/generative-ai'
import rateLimit from 'express-rate-limit'
import cors from 'cors'
import dotenv from 'dotenv'

// Load environment variables from .env (allow .env to override existing envs)
dotenv.config({ override: true })

// --- Config ---
const OFF_BASE_URL = process.env.OFF_BASE_URL || 'https://world.openfoodfacts.org'
const OFF_USER_AGENT = process.env.OFF_USER_AGENT || 'nutritracker-ai-coach/0.1 (+https://example.com)'
const OFF_CACHE_TTL_MS = Number(process.env.OFF_CACHE_TTL_MS || 60 * 60 * 1000) // 1h
const IMAGE_CACHE_TTL_MS = Number(process.env.IMAGE_CACHE_TTL_MS || 60 * 60 * 1000) // 1h
const CACHE_MAX = Number(process.env.CACHE_MAX || 200)
const VISION_PROVIDER = (process.env.VISION_PROVIDER || '').toLowerCase() // 'openai' | 'gemini' | 'openrouter'
const OPENAI_API_KEY = process.env.OPENAI_API_KEY
const GEMINI_API_KEY = process.env.GEMINI_API_KEY
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY
const OPENROUTER_BASE_URL = process.env.OPENROUTER_BASE_URL || 'https://openrouter.ai/api/v1'
const OPENROUTER_MODEL = process.env.OPENROUTER_VISION_MODEL || process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini'
const OPENROUTER_SITE_URL = process.env.OPENROUTER_SITE_URL || ''
const OPENROUTER_SITE_NAME = process.env.OPENROUTER_SITE_NAME || ''

const app = express()

// CORS (dev-friendly). Configure CORS_ALLOWED_ORIGINS for an allowlist.
const RAW_ALLOWED = (process.env.CORS_ALLOWED_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean)
const hasAllowlist = RAW_ALLOWED.length > 0
const corsOptions = hasAllowlist
  ? {
      origin: (origin, cb) => {
        if (!origin) return cb(null, true)
        const ok = RAW_ALLOWED.some((o) => origin.startsWith(o))
        cb(ok ? null : new Error('CORS not allowed'), ok)
      },
      credentials: true,
    }
  : { origin: true, credentials: false }
app.use(cors(corsOptions))

app.use(express.json({ limit: '2mb' }))

// Rate limiting
const RL_WINDOW_MS = Number(process.env.RATE_LIMIT_WINDOW_MS || 60_000)
const RL_MAX_DEFAULT = Number(process.env.RATE_LIMIT_MAX || 60)
const RL_MAX_PHOTO = Number(process.env.RATE_LIMIT_PHOTO_MAX || 10)

const defaultLimiter = rateLimit({ windowMs: RL_WINDOW_MS, max: RL_MAX_DEFAULT, standardHeaders: 'draft-7', legacyHeaders: false })
const photoLimiter = rateLimit({ windowMs: RL_WINDOW_MS, max: RL_MAX_PHOTO, standardHeaders: 'draft-7', legacyHeaders: false })
app.use(defaultLimiter)

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'nutritracker-ai-coach-express' })
})

// Fetch with retry/backoff
async function fetchWithRetry(url, options = {}, retries = 3, backoffMs = 300) {
  let lastErr
  for (let i = 0; i <= retries; i++) {
    try {
      const resp = await fetch(url, options)
      if (resp.ok) return resp
      lastErr = new Error(`HTTP ${resp.status}`)
    } catch (e) {
      lastErr = e
    }
    if (i < retries) await new Promise(r => setTimeout(r, backoffMs * Math.pow(2, i)))
  }
  throw lastErr
}

// calcular_metas
app.post('/calcular_metas', (req, res) => {
  const { sexo, idade, peso_kg, altura_cm, nivel_atividade, objetivo } = req.body
  const mult = { sedentario: 1.2, leve: 1.375, moderado: 1.55, alto: 1.725, atleta: 1.9 }[nivel_atividade]
  const bmr = (sexo === 'm'
    ? 10 * peso_kg + 6.25 * altura_cm - 5 * idade + 5
    : 10 * peso_kg + 6.25 * altura_cm - 5 * idade - 161)
  const tdee = bmr * (mult || 1.2)
  const ajuste = objetivo === 'perda' ? -0.15 : objetivo === 'ganho' ? 0.1 : 0
  const kcal_meta = tdee * (1 + ajuste)
  const proteina = Math.round(Math.max(1.6, 1.8) * peso_kg)
  const gordura = Math.round(0.8 * peso_kg)
  const carbo = Math.max(0, Math.round((kcal_meta - proteina * 4 - gordura * 9) / 4))
  res.json({
    bmr: Math.round(bmr * 10) / 10,
    tdee: Math.round(tdee * 10) / 10,
    kcal_meta: Math.round(kcal_meta),
    macros_g: { proteina, carbo, gordura }
  })
})

// planejar_jejum
app.post('/planejar_jejum', (req, res) => {
  const { protocolo = '16:8', inicio_preferido, dias = 7 } = req.body
  const map = { '12:12': [12, 12], '14:10': [14, 10], '16:8': [16, 8], '18:6': [18, 6], '20:4': [20, 4], 'omad': [23, 1] }
  const [fHoras] = map[protocolo] || [16, 8]
  const now = new Date()
  let start = new Date(now)
  if (inicio_preferido) {
    const [hh, mm] = inicio_preferido.split(':').map(Number)
    start.setHours(hh, mm, 0, 0)
    if (start < now) start.setDate(start.getDate() + 1)
  }
  const janelas = []
  let cur = new Date(start)
  for (let i = 0; i < dias; i++) {
    const inicio = cur.toISOString()
    const fim = new Date(cur.getTime() + fHoras * 3600 * 1000).toISOString()
    janelas.push({ inicio, fim })
    cur = new Date(cur)
    cur.setDate(cur.getDate() + 1)
    cur.setHours(start.getHours(), start.getMinutes(), 0, 0)
  }
  res.json({ janelas, lembretes: ['00:30 antes do início', 'Início'] })
})

// --- Simple in-memory cache with TTL ---
function createCache(max = 200, ttlMs = 3600000) {
  const map = new Map()
  function set(key, value) {
    if (map.size >= max) {
      const firstKey = map.keys().next().value
      if (firstKey !== undefined) map.delete(firstKey)
    }
    map.set(key, { value, ts: Date.now() })
  }
  function get(key) {
    const entry = map.get(key)
    if (!entry) return undefined
    if (Date.now() - entry.ts > ttlMs) {
      map.delete(key)
      return undefined
    }
    return entry.value
  }
  return { get, set }
}

const offCache = createCache(CACHE_MAX, OFF_CACHE_TTL_MS)
const imageCache = createCache(Math.max(50, Math.floor(CACHE_MAX / 2)), IMAGE_CACHE_TTL_MS)

function openRouterHeaders() {
  const headers = {}
  if (OPENROUTER_SITE_URL) headers['HTTP-Referer'] = OPENROUTER_SITE_URL
  if (OPENROUTER_SITE_NAME) headers['X-Title'] = OPENROUTER_SITE_NAME
  return headers
}

function safeJsonParse(raw) {
  if (!raw || typeof raw !== 'string') return null
  try {
    return JSON.parse(raw)
  } catch (err) {
    return null
  }
}

function aggregateMessageContent(content) {
  if (!content) return ''
  if (typeof content === 'string') return content
  if (Array.isArray(content)) {
    return content
      .map((part) => {
        if (!part) return ''
        if (typeof part === 'string') return part
        if (typeof part === 'object') {
          if ('text' in part && typeof part.text === 'string') return part.text
          if ('content' in part && typeof part.content === 'string') return part.content
        }
        return ''
      })
      .filter(Boolean)
      .join('\n')
  }
  if (typeof content === 'object' && typeof content.text === 'string') {
    return content.text
  }
  return String(content || '')
}

async function fetchImageAsBase64(imageUrl) {
  const cacheKey = `img:${imageUrl}`
  const cached = imageCache.get(cacheKey)
  if (cached) return cached
  const resp = await fetchWithRetry(String(imageUrl))
  if (!resp.ok) throw new Error(`fetch_image_failed: ${resp.status}`)
  const arr = await resp.arrayBuffer()
  const data = Buffer.from(arr).toString('base64')
  const contentType = resp.headers.get('content-type') || ''
  const mimeType = contentType ? contentType.split(';')[0] : 'image/jpeg'
  const entry = { data, mimeType }
  imageCache.set(cacheKey, entry)
  return entry
}

async function resolveImageData(image_base64, image_url) {
  let base64Data = image_base64
  let mimeType = 'image/jpeg'
  if (!base64Data && image_url) {
    const fetched = await fetchImageAsBase64(image_url)
    base64Data = fetched.data
    mimeType = fetched.mimeType || mimeType
  }
  if (!base64Data) throw new Error('missing_image_data')
  return { base64Data, mimeType }
}

const FOOD_ANALYSIS_PROMPT = `
Você é um nutricionista analisando uma foto de comida. Retorne um JSON no formato abaixo, priorizando UMA entrada AGREGADA do prato inteiro como o primeiro item, e opcionalmente uma lista de componentes depois.

Formato obrigatório:
{
  "foods": [
    {
      "name": "Nome do prato (total)",
      "calories": 450,
      "carbs": 50.0,
      "protein": 12.0,
      "fat": 22.0,
      "fiber": 6.0,
      "sugar": 8.0,
      "portion_size": "350 g",
      "confidence": 0.85
    },
    {
      "name": "Componente 1 (opcional)",
      "calories": 120,
      "carbs": 10.0,
      "protein": 2.0,
      "fat": 8.0,
      "fiber": 1.0,
      "sugar": 2.0,
      "portion_size": "80 g",
      "confidence": 0.8
    }
  ]
}

Regras importantes:
- Sempre que houver uma tigela/prato com mistura (ex.: salada, bowl, refogado, sopa), crie o PRIMEIRO item como o prato inteiro (agregado) com totais de kcal/macros e uma porção coerente em gramas (ex.: "320 g"). Só depois, opcionalmente, liste componentes. Se houver dúvida, retorne apenas o agregado.
- Em pratos separados (ex.: carne + arroz com divisórias), pode listar cada item separadamente, mas ainda é recomendado incluir um agregado como primeiro item "Prato (total)".
- Converta a porção para gramas sempre que possível: use estimativas típicas de densidade (folhas: ~15 g por punhado; tomate/cenoura cru: 80–120 g por xíc.; azeite: 1 colher de sopa ≈ 10 g; molhos cremosos: 1 colher de sopa ≈ 15 g).
- Inclua gorduras de temperos/azeites/molhos na soma do agregado.
- O campo "name" do agregado deve conter o tipo do prato, por exemplo: "Salada (total)", "Bowl (total)", "Prato (total)", "Sopa (total)".
- "confidence" deve estar entre 0 e 1.
- Se a imagem não mostrar comida de forma clara, retorne {"foods": []}.
`

// --- Open Food Facts helpers ---
function tryNum(v) {
  const n = Number(v)
  return Number.isFinite(n) ? n : undefined
}

function nutrimentOf(nutr, keys) {
  for (const k of keys) {
    if (k in (nutr || {})) {
      const val = tryNum(nutr[k])
      if (val !== undefined) return val
    }
  }
  return undefined
}

function extractKcal100g(nutrients) {
  const kcal = nutrimentOf(nutrients, ['energy-kcal_100g', 'energy-kcal_value_100g'])
  if (kcal !== undefined) return kcal
  const kj = nutrimentOf(nutrients, ['energy-kj_100g', 'energy_100g'])
  if (kj !== undefined) return Math.round((kj / 4.184) * 10) / 10
  return undefined
}

function round1(x) { return x !== undefined ? Math.round(x * 10) / 10 : undefined }
function round0(x) { return x !== undefined ? Math.round(x) : undefined }

function deriveSaltSodium({ salt_g, sodium_g }) {
  // salt (NaCl) is ~39.3% sodium by mass
  const ratio = 0.393
  let outSalt = salt_g
  let outSodium = sodium_g
  if (outSalt === undefined && outSodium !== undefined) outSalt = outSodium / ratio
  if (outSodium === undefined && outSalt !== undefined) outSodium = outSalt * ratio
  return { salt_g: outSalt, sodium_g: outSodium }
}

function extrasFromNutriments(nutr, scope = '100g') {
  // scope: '100g' or 'serving'
  const suffix = scope === 'serving' ? '_serving' : '_100g'
  const sugars = nutrimentOf(nutr, ['sugars' + suffix])
  const fiber = nutrimentOf(nutr, ['fiber' + suffix])
  let salt = nutrimentOf(nutr, ['salt' + suffix])
  let sodium = nutrimentOf(nutr, ['sodium' + suffix])
  const { salt_g, sodium_g } = deriveSaltSodium({ salt_g: salt, sodium_g: sodium })
  salt = salt_g
  sodium = sodium_g
  return {
    acucar: sugars !== undefined ? round1(sugars) : undefined,
    fibra: fiber !== undefined ? round1(fiber) : undefined,
    sal_g: salt !== undefined ? round1(salt) : undefined,
    sodio_mg: sodium !== undefined ? round0(sodium * 1000) : undefined
  }
}

function pickOFFName(product) {
  const c = (v) => (v && String(v).trim()) || null
  return (
    c(product?.product_name_pt) ||
    c(product?.product_name) ||
    c(product?.generic_name_pt) ||
    c(product?.generic_name) ||
    c(product?.product_name_en) ||
    c(product?.generic_name_en) ||
    c(product?.brands) ||
    c(product?.code) ||
    'Produto'
  )
}

function normalizeOFFProductTo100g(product) {
  const nutr = product?.nutriments || {}
  const kcal = extractKcal100g(nutr)
  const proteina = nutrimentOf(nutr, ['proteins_100g'])
  const carbo = nutrimentOf(nutr, ['carbohydrates_100g'])
  const gordura = nutrimentOf(nutr, ['fat_100g'])
  const nome = pickOFFName(product)
  const id = product?.code || product?._id || `${nome}`
  const base = {
    id,
    nome,
    porcao_padrao: '100 g',
    nutricao_por_100g: {
      kcal: kcal !== undefined ? Math.round(kcal) : undefined,
      proteina: proteina !== undefined ? Math.round(proteina * 10) / 10 : undefined,
      carbo: carbo !== undefined ? Math.round(carbo * 10) / 10 : undefined,
      gordura: gordura !== undefined ? Math.round(gordura * 10) / 10 : undefined
    }
  }
  const extras = extrasFromNutriments(nutr, '100g')
  base.nutricao_por_100g = { ...base.nutricao_por_100g, ...extras }
  return base
}

function parseServingSizeToGrams(servingSize) {
  if (!servingSize) return undefined
  const txt = String(servingSize).toLowerCase()
  // Parenthetical like "1 porção (30 g)"
  const paren = txt.match(/\(([0-9]+(?:\.[0-9]+)?)\s*(mg|g|kg|ml|l|oz)\)/)
  if (paren) {
    const val = Number(paren[1]); const unit = paren[2]
    if (Number.isFinite(val)) return convertToGrams(val, unit)
  }
  // Direct like "30 g", "1 oz", "0.5 l"
  const direct = txt.match(/(^|\s)([0-9]+(?:\.[0-9]+)?)\s*(mg|g|kg|ml|l|oz)(\s|$)/)
  if (direct) {
    const val = Number(direct[2]); const unit = direct[3]
    if (Number.isFinite(val)) return convertToGrams(val, unit)
  }
  return undefined
}

function convertToGrams(val, unit) {
  switch (unit) {
    case 'mg': return val / 1000
    case 'g': return val
    case 'kg': return val * 1000
    case 'ml': return val // assume density ~1
    case 'l': return val * 1000
    case 'oz': return val * 28.3495
    default: return undefined
  }
}

function normalizeOFFProductServing(product) {
  const nutr = product?.nutriments || {}
  const kcal = nutrimentOf(nutr, ['energy-kcal_serving'])
  const proteina = nutrimentOf(nutr, ['proteins_serving'])
  const carbo = nutrimentOf(nutr, ['carbohydrates_serving'])
  const gordura = nutrimentOf(nutr, ['fat_serving'])
  let porcao = product?.serving_size || null
  let out = { kcal, proteina, carbo, gordura, ...extrasFromNutriments(nutr, 'serving') }

  // If serving-based values missing, derive from 100g and serving_size grams
  if ([kcal, proteina, carbo, gordura].every(v => v === undefined)) {
    const grams = parseServingSizeToGrams(product?.serving_size)
    const per100 = normalizeOFFProductTo100g(product).nutricao_por_100g
    if (grams && per100) {
      const ratio = grams / 100
      out = {
        kcal: per100.kcal !== undefined ? Math.round(per100.kcal * ratio) : undefined,
        proteina: per100.proteina !== undefined ? Math.round(per100.proteina * ratio * 10) / 10 : undefined,
        carbo: per100.carbo !== undefined ? Math.round(per100.carbo * ratio * 10) / 10 : undefined,
        gordura: per100.gordura !== undefined ? Math.round(per100.gordura * ratio * 10) / 10 : undefined,
        acucar: per100.acucar !== undefined ? round1(per100.acucar * ratio) : undefined,
        fibra: per100.fibra !== undefined ? round1(per100.fibra * ratio) : undefined,
        sal_g: per100.sal_g !== undefined ? round1(per100.sal_g * ratio) : undefined,
        sodio_mg: per100.sodio_mg !== undefined ? round0(per100.sodio_mg * ratio) : undefined
      }
      if (!porcao) porcao = `${grams} g`
    }
  }

  return {
    porcao: porcao || '1 porção',
    nutricao_por_porcao: {
      kcal: out.kcal !== undefined ? Math.round(out.kcal) : undefined,
      proteina: out.proteina !== undefined ? Math.round(out.proteina * 10) / 10 : undefined,
      carbo: out.carbo !== undefined ? Math.round(out.carbo * 10) / 10 : undefined,
      gordura: out.gordura !== undefined ? Math.round(out.gordura * 10) / 10 : undefined,
      acucar: out.acucar !== undefined ? round1(out.acucar) : undefined,
      fibra: out.fibra !== undefined ? round1(out.fibra) : undefined,
      sal_g: out.sal_g !== undefined ? round1(out.sal_g) : undefined,
      sodio_mg: out.sodio_mg !== undefined ? round0(out.sodio_mg) : undefined
    }
  }
}

async function offSearch(query, topK = 10) {
  const url = new URL(`${OFF_BASE_URL}/api/v2/search`)
  url.searchParams.set('page_size', String(topK))
  if (query) url.searchParams.set('query', String(query))
  url.searchParams.set('fields', 'code,product_name,product_name_pt,generic_name,generic_name_pt,brands,serving_size,nutriments')
  const key = `search:${query}:${topK}`
  const cached = offCache.get(key)
  if (cached) return cached
  const r = await fetchWithRetry(url.toString(), { headers: { 'User-Agent': OFF_USER_AGENT } }, 3, 300)
  if (!r.ok) throw new Error(`OFF search failed: ${r.status}`)
  const j = await r.json()
  const products = (j?.products || []).filter(Boolean)
  offCache.set(key, products)
  return products
}

async function offByBarcode(barcode) {
  const key = `barcode:${barcode}`
  const cached = offCache.get(key)
  if (cached) return cached
  const url = `${OFF_BASE_URL}/api/v2/product/${encodeURIComponent(barcode)}.json`
  const r = await fetchWithRetry(url, { headers: { 'User-Agent': OFF_USER_AGENT } }, 3, 300)
  if (!r.ok) throw new Error(`OFF product failed: ${r.status}`)
  const j = await r.json()
  const product = j?.product
  if (product) offCache.set(key, product)
  return product
}

// buscar_alimento => Open Food Facts search
app.post('/buscar_alimento', async (req, res) => {
  try {
    const { query = '', top_k = 10 } = req.body || {}
    const products = await offSearch(query, Math.min(Number(top_k) || 10, 50))
    const itens = products
      .map(p => normalizeOFFProductTo100g(p))
      .filter(i => i?.nutricao_por_100g && (i.nutricao_por_100g.kcal !== undefined))
    res.json({ itens })
  } catch (err) {
    const { query = '', top_k = 10 } = req.body || {}
    const demo = [
      {
        id: 'demo-frango-grelhado', nome: 'Frango grelhado', porcao_padrao: '100 g',
        nutricao_por_100g: { kcal: 165, proteina: 31, carbo: 0, gordura: 3.6, acucar: 0, fibra: 0, sal_g: 0.1, sodio_mg: 40 }
      },
      {
        id: 'demo-arroz-cozido', nome: 'Arroz branco cozido', porcao_padrao: '100 g',
        nutricao_por_100g: { kcal: 130, proteina: 2.4, carbo: 28, gordura: 0.3, acucar: 0.1, fibra: 0.2, sal_g: 0, sodio_mg: 1 }
      }
    ]
    const itens = demo.filter(i => i.nome.toLowerCase().includes(String(query).toLowerCase())).slice(0, Math.min(Number(top_k)||10, 50))
    res.json({ itens, fallback: true, error: 'open_food_facts_search_failed', detail: String(err?.message || err) })
  }
})

// analisar_barcode => Open Food Facts product by code
app.post('/analisar_barcode', async (req, res) => {
  try {
    const { barcode } = req.body || {}
    if (!barcode) return res.status(400).json({ error: 'missing_barcode' })
    const product = await offByBarcode(String(barcode))
    if (!product) return res.status(404).json({ error: 'not_found' })
    const base = normalizeOFFProductTo100g(product)
    const serving = normalizeOFFProductServing(product)
    res.json({ item: { id: base.id, nome: base.nome, ...serving, origem: 'open_food_facts' } })
  } catch (err) {
    res.status(500).json({ error: 'open_food_facts_product_failed', detail: String(err?.message || err) })
  }
})

// analisar_foto => Vision provider (OpenAI or Gemini)
app.post('/analisar_foto', photoLimiter, async (req, res) => {
  try {
    const { image_base64, image_url } = req.body || {}
    if (!image_base64 && !image_url) {
      return res.status(400).json({ error: 'missing_image' })
    }
    const system = 'Você é um assistente de nutrição. A partir da imagem de uma refeição, identifique até 3 candidatos de alimentos presentes. Para cada candidato, retorne nome comum em pt-BR, uma estimativa simples de porção (ex.: "120 g", "1 xícara"), e uma confiança entre 0 e 1. Responda somente no JSON solicitado.'
    const jsonInstruction = 'Responda somente como JSON com a forma: { "candidatos": [ { "nome": string, "porcao": string, "confianca": number } ] }.'

    if (VISION_PROVIDER === 'openai') {
      if (!OPENAI_API_KEY) return res.status(500).json({ error: 'missing_openai_api_key' })
      const openai = new OpenAI({ apiKey: OPENAI_API_KEY })
      const { base64Data, mimeType } = await resolveImageData(image_base64, image_url)
      const img = { url: `data:${mimeType};base64,${base64Data}` }
      const completion = await openai.chat.completions.create({
        model: process.env.OPENAI_VISION_MODEL || 'gpt-4o-mini',
        response_format: { type: 'json_object' },
        temperature: 0.2,
        messages: [
          { role: 'system', content: system },
          {
            role: 'user',
            content: [
              { type: 'text', text: jsonInstruction },
              { type: 'image_url', image_url: img }
            ]
          }
        ]
      })
      const raw = aggregateMessageContent(completion?.choices?.[0]?.message?.content)?.trim() || '{}'
      const parsed = safeJsonParse(raw) || { candidatos: [] }
      return res.json({ ...parsed, provider: 'openai' })
    }

    if (VISION_PROVIDER === 'openrouter') {
      if (!OPENROUTER_API_KEY) return res.status(500).json({ error: 'missing_openrouter_api_key' })
      const client = new OpenAI({
        apiKey: OPENROUTER_API_KEY,
        baseURL: OPENROUTER_BASE_URL,
        defaultHeaders: openRouterHeaders(),
      })
      const { base64Data, mimeType } = await resolveImageData(image_base64, image_url)
      const img = { url: `data:${mimeType};base64,${base64Data}` }
      const completion = await client.chat.completions.create({
        model: OPENROUTER_MODEL,
        response_format: { type: 'json_object' },
        temperature: 0.2,
        messages: [
          { role: 'system', content: system },
          {
            role: 'user',
            content: [
              { type: 'text', text: jsonInstruction },
              { type: 'image_url', image_url: img }
            ]
          }
        ]
      })
      const raw = aggregateMessageContent(completion?.choices?.[0]?.message?.content)?.trim() || '{}'
      const parsed = safeJsonParse(raw) || { candidatos: [] }
      return res.json({ ...parsed, provider: 'openrouter' })
    }

    if (VISION_PROVIDER === 'gemini') {
      if (!GEMINI_API_KEY) return res.status(500).json({ error: 'missing_gemini_api_key' })
      const genAI = new GoogleGenerativeAI(GEMINI_API_KEY)
      const model = genAI.getGenerativeModel({
        model: process.env.GEMINI_VISION_MODEL || 'gemini-1.5-flash',
        generationConfig: { responseMimeType: 'application/json' }
      })

      const { base64Data, mimeType } = await resolveImageData(image_base64, image_url)

      const result = await model.generateContent({
        contents: [
          { role: 'user', parts: [
            { text: `${system}\n\n${jsonInstruction}` },
            { inlineData: { data: base64Data, mimeType } }
          ]}
        ]
      })
      const text = result?.response?.text?.() || '{}'
      const parsed = JSON.parse(text)
      return res.json({ ...parsed, provider: 'gemini' })
    }

    // If no provider configured, return a helpful error with stub fallback
    return res.status(500).json({
      error: 'vision_provider_not_configured',
      detail: 'Defina VISION_PROVIDER=openai|gemini e a respectiva API key.'
    })
  } catch (err) {
    // On parsing or API issues, return structured error and a small fallback
    return res.status(500).json({
      error: 'vision_analysis_failed',
      detail: String(err?.message || err),
      candidatos: [
        { nome: 'frango grelhado', porcao: '120 g', confianca: 0.6 },
        { nome: 'arroz branco', porcao: '150 g', confianca: 0.55 }
      ]
    })
  }
})

// Detalha alimento com macros completos (utiliza mesmo provedor de visão)
app.post('/vision/analyze_food', photoLimiter, async (req, res) => {
  try {
    const { image_base64, image_url } = req.body || {}
    if (!image_base64 && !image_url) {
      return res.status(400).json({ error: 'missing_image' })
    }
    const { base64Data, mimeType } = await resolveImageData(image_base64, image_url)

    if (VISION_PROVIDER === 'openai') {
      if (!OPENAI_API_KEY) {
        return res.status(500).json({ error: 'missing_openai_api_key' })
      }
      const client = new OpenAI({ apiKey: OPENAI_API_KEY })
      const completion = await client.chat.completions.create({
        model: process.env.OPENAI_VISION_MODEL || 'gpt-4o-mini',
        response_format: { type: 'json_object' },
        temperature: 0.2,
        messages: [
          { role: 'system', content: FOOD_ANALYSIS_PROMPT },
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Retorne somente o JSON do formato especificado.' },
              { type: 'image_url', image_url: { url: `data:${mimeType};base64,${base64Data}` } }
            ],
          },
        ],
      })
      const raw = aggregateMessageContent(completion?.choices?.[0]?.message?.content)?.trim() || '{}'
      const parsed = safeJsonParse(raw)
      if (!parsed) throw new Error('invalid_json_response')
      return res.json({ ...parsed, provider: 'openai' })
    }

    if (VISION_PROVIDER === 'openrouter') {
      if (!OPENROUTER_API_KEY) {
        return res.status(500).json({ error: 'missing_openrouter_api_key' })
      }
      const client = new OpenAI({
        apiKey: OPENROUTER_API_KEY,
        baseURL: OPENROUTER_BASE_URL,
        defaultHeaders: openRouterHeaders(),
      })
      const completion = await client.chat.completions.create({
        model: OPENROUTER_MODEL,
        response_format: { type: 'json_object' },
        temperature: 0.2,
        messages: [
          { role: 'system', content: FOOD_ANALYSIS_PROMPT },
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Retorne somente o JSON do formato especificado.' },
              { type: 'image_url', image_url: { url: `data:${mimeType};base64,${base64Data}` } }
            ],
          },
        ],
      })
      const raw = aggregateMessageContent(completion?.choices?.[0]?.message?.content)?.trim() || '{}'
      const parsed = safeJsonParse(raw)
      if (!parsed) throw new Error('invalid_json_response')
      return res.json({ ...parsed, provider: 'openrouter' })
    }

    if (VISION_PROVIDER === 'gemini') {
      if (!GEMINI_API_KEY) {
        return res.status(500).json({ error: 'missing_gemini_api_key' })
      }
      const genAI = new GoogleGenerativeAI(GEMINI_API_KEY)
      const model = genAI.getGenerativeModel({
        model: process.env.GEMINI_VISION_MODEL || 'gemini-1.5-flash',
        generationConfig: { responseMimeType: 'application/json' },
      })
      const result = await model.generateContent({
        contents: [
          {
            role: 'user',
            parts: [
              { text: FOOD_ANALYSIS_PROMPT },
              { inlineData: { data: base64Data, mimeType } },
            ],
          },
        ],
      })
      const text = result?.response?.text?.() || '{}'
      const parsed = safeJsonParse(text)
      if (!parsed) throw new Error('invalid_json_response')
      return res.json({ ...parsed, provider: 'gemini' })
    }

    return res.status(500).json({
      error: 'vision_provider_not_configured',
      detail: 'Defina VISION_PROVIDER=openai|openrouter|gemini e as chaves correspondentes.',
    })
  } catch (err) {
    return res.status(500).json({
      error: 'vision_analysis_failed',
      detail: String(err?.message || err),
      foods: [],
    })
  }
})

// log_refeicao (stub simples)
app.post('/log_refeicao', (req, res) => {
  const { itens = [] } = req.body || {}
  const kcal = itens.reduce((acc, it) => acc + (it.unidade === 'g' || it.unidade === 'ml' ? Number(it.quantidade) : Number(it.quantidade) * 100), 0)
  res.json({ total: { kcal: Math.round(kcal * 10) / 10, proteina: 0, carbo: 0, gordura: 0 }, itens })
})

// sugerir_refeicao (stub)
app.post('/sugerir_refeicao', (req, res) => {
  res.json({ sugestoes: [
    { nome: 'Bowl frango + arroz + salada', kcal: 550, macros_g: { proteina: 40, carbo: 60, gordura: 15 }, passos: ['Grelhar frango', 'Cozinhar arroz', 'Montar bowl'] },
    { nome: 'Omelete de claras + aveia', kcal: 430, macros_g: { proteina: 35, carbo: 40, gordura: 12 }, passos: ['Bater claras', 'Refogar', 'Servir com aveia e fruta'] },
    { nome: 'Iogurte grego + frutas + granola', kcal: 380, macros_g: { proteina: 25, carbo: 45, gordura: 10 }, passos: ['Montar pote', 'Adicionar frutas e granola'] }
  ] })
})

// sugerir_log_refeicao: gera sugestão simples para registro com confirmação no cliente
app.post('/sugerir_log_refeicao', async (req, res) => {
  try {
    const { alvo_kcal, mealTime, query, preferencias = [], restricoes = [] } = req.body || {}
    const kcal = clampInt(alvo_kcal || 500, 200, 1200)

    // Try to use OFF via our own /buscar_alimento endpoint
    const SELF_BASE = `http://127.0.0.1:${process.env.PORT || 8002}`
    const effectiveQuery = pickQuery(query, preferencias, restricoes)
    try {
      const resp = await fetchWithRetry(`${SELF_BASE}/buscar_alimento`, {
        method: 'POST', headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ query: effectiveQuery, top_k: 5 })
      })
      if (resp.ok) {
        const data = await resp.json()
        const itens = Array.isArray(data?.itens) ? data.itens : []
        if (itens.length > 0) {
          const first = itens[0]
          const per100 = first?.nutricao_por_100g || {}
          const k100 = Number(per100.kcal || 0)
          if (k100 > 0) {
            const grams = clampInt((kcal / k100) * 100, 30, 1000)
            const ratio = grams / 100
            const carbs = Math.round(Number(per100.carbo || 0) * ratio)
            const protein = Math.round(Number(per100.proteina || 0) * ratio)
            const fat = Math.round(Number(per100.gordura || 0) * ratio)
            return res.json({
              sugestao: {
                nome: String(first?.nome || effectiveQuery),
                porcao: `${grams} g`,
                kcal: Math.round(k100 * ratio),
                macros_g: { carbo: carbs, proteina: protein, gordura: fat },
                mealTime
              }
            })
          }
        }
      }
    } catch (_) {}

    // Fallback to simple macro split if OFF failed
    const cK = Math.round(kcal * 0.4)
    const pK = Math.round(kcal * 0.3)
    const fK = kcal - cK - pK
    const carbs = Math.round(cK / 4)
    const protein = Math.round(pK / 4)
    const fat = Math.round(fK / 9)
    const nome = effectiveQuery
    const porcao = '1 porção'
    return res.json({ sugestao: { nome, porcao, kcal, macros_g: { carbo: carbs, proteina: protein, gordura: fat }, mealTime } })
  } catch (err) {
    return res.status(500).json({ error: 'sugerir_log_refeicao_failed', detail: String(err?.message || err) })
  }
})

function clampInt(n, lo, hi) {
  const v = Math.round(Number(n) || 0)
  return Math.max(lo, Math.min(hi, v))
}

function pickQuery(q, prefs = [], restr = []) {
  if (typeof q === 'string' && q.trim()) return q.trim()
  const r = (Array.isArray(restr) ? restr : []).map(s => String(s).toLowerCase())
  if (r.some(s => s.includes('veg'))) return 'tofu grelhado'
  if (r.some(s => s.includes('lactose'))) return 'frango grelhado'
  if (Array.isArray(prefs) && prefs.length) return String(prefs[0])
  return 'frango grelhado'
}

// registrar_checkin
app.post('/registrar_checkin', (req, res) => {
  res.json({ ok: true })
})

// obter_estatisticas_usuario
app.post('/obter_estatisticas_usuario', (req, res) => {
  res.json({ resumo: {
    semana: { dias_com_log: 4, janelas_concluidas: 3, peso_atual: 72.3 },
    hoje: { kcal_restantes: 820, macros_restantes: { proteina: 60, carbo: 110, gordura: 25 } }
  } })
})

// atualizar_preferencias
app.post('/atualizar_preferencias', (req, res) => {
  res.json({ ok: true })
})

const port = process.env.PORT || 8002
app.listen(port, () => console.log(`Express AI Coach listening on :${port}`))

// --- Simple coach chat endpoint using OpenAI tool calling ---
// Body: { message: string, history?: [{role:'user'|'assistant', content:string}] }
app.post('/coach_chat', async (req, res) => {
  try {
    if (!OPENAI_API_KEY) return res.status(500).json({ error: 'missing_openai_api_key' })
    const { message, history = [], context } = req.body || {}
    if (!message || typeof message !== 'string') return res.status(400).json({ error: 'missing_message' })

    const openai = new OpenAI({ apiKey: OPENAI_API_KEY })
    const system = 'Você é “Nutri”, coach de nutrição e jejum do app. Use ferramentas para cálculos/registro (busca OFF, barcode, foto, jejum). Para preparar um registro, use sugerir_log_refeicao (o cliente confirmará antes de gravar). Seja objetivo, empático e seguro. Oriente com passos e confirmação antes de registrar.'

    // tool dispatch via local HTTP endpoints
    const SELF_BASE = process.env.EXPRESS_BASE_URL || `http://127.0.0.1:${process.env.PORT || 8002}`
    async function callTool(name, args) {
      const url = `${SELF_BASE}/${name}`
      const resp = await fetchWithRetry(url, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(args || {})
      }, 3, 300)
      if (!resp.ok) throw new Error(`tool ${name} failed: ${resp.status}`)
      return await resp.json()
    }

    const tools = [
      { type: 'function', function: { name: 'planejar_jejum', description: 'Gera janelas de jejum e lembretes', parameters: { type: 'object', properties: { protocolo: { type: 'string', enum: ['12:12','14:10','16:8','18:6','20:4','omad'] }, inicio_preferido: { type: 'string', description: 'HH:MM' }, dias: { type: 'number' } }, required: ['protocolo'] } } },
      { type: 'function', function: { name: 'buscar_alimento', description: 'Busca alimentos (Open Food Facts)', parameters: { type: 'object', properties: { query: { type: 'string' }, top_k: { type: 'number' } }, required: ['query'] } } },
      { type: 'function', function: { name: 'analisar_barcode', description: 'Analisa produto por código de barras (OFF)', parameters: { type: 'object', properties: { barcode: { type: 'string' } }, required: ['barcode'] } } },
      { type: 'function', function: { name: 'analisar_foto', description: 'Analisa imagem de refeição (OpenAI/Gemini Vision)', parameters: { type: 'object', properties: { image_url: { type: 'string' }, image_base64: { type: 'string' } } } } },
      { type: 'function', function: { name: 'obter_estatisticas_usuario', description: 'Resumo diário/semana (macros restantes, adesão)' } },
      { type: 'function', function: { name: 'sugerir_refeicao', description: 'Sugere refeições alinhadas a macros', parameters: { type: 'object', properties: { macros_restantes: { type: 'object' }, restricoes: { type: 'array', items: { type: 'string' } }, preferencias: { type: 'array', items: { type: 'string' } } } } } },
      { type: 'function', function: { name: 'sugerir_log_refeicao', description: 'Propor item pronto para registro (cliente confirmará antes de gravar)', parameters: { type: 'object', properties: { alvo_kcal: { type: 'number' }, mealTime: { type: 'string', enum: ['breakfast','lunch','dinner','snack'] }, query: { type: 'string' }, preferencias: { type: 'array', items: { type: 'string' } }, restricoes: { type: 'array', items: { type: 'string' } } } } } },
    ]

    const msgs = [{ role: 'system', content: system }]
    if (context && typeof context === 'object') {
      // Provide structured day context to help personalization
      const ctxBrief = summarizeContext(context)
      msgs.push({ role: 'system', content: ctxBrief })
    }
    const trimmed = Array.isArray(history) ? history.slice(-10) : []
    for (const m of trimmed) {
      if (m && (m.role === 'user' || m.role === 'assistant') && typeof m.content === 'string') {
        msgs.push({ role: m.role, content: m.content })
      }
    }
    msgs.push({ role: 'user', content: message })

    let resp = await openai.chat.completions.create({
      model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
      messages: msgs,
      tools,
      temperature: 0.3,
    })
    let msg = resp.choices?.[0]?.message
    const events = []

    if (msg?.tool_calls?.length) {
      msgs.push(msg)
      for (const tc of msg.tool_calls) {
        const args = JSON.parse(tc.function?.arguments || '{}')
        let result
        let ok = true
        try {
          result = await callTool(tc.function.name, args)
        } catch (e) {
          ok = false
          result = { error: String(e?.message || e) }
        }
        events.push({ tool: tc.function.name, args, ok, result })
        msgs.push({ role: 'tool', tool_call_id: tc.id, content: JSON.stringify(result) })
      }
      resp = await openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
        messages: msgs,
        tools,
        temperature: 0.3,
      })
      msg = resp.choices?.[0]?.message
    }

    return res.json({ reply: msg?.content || '', tool_events: events, raw: msg })
  } catch (err) {
    return res.status(500).json({ error: 'coach_chat_failed', detail: String(err?.message || err) })
  }
})

// Build a short Portuguese context string the model can use easily
function summarizeContext(ctx) {
  try {
    const d = ctx?.date || ''
    const g = ctx?.goals || {}
    const c = ctx?.consumed || {}
    const r = ctx?.remaining || {}
    const parts = []
    if (d) parts.push(`Dia: ${d}`)
    parts.push(`Meta: ${num(g.calories)} kcal • C ${num(g.carbs_g)}g • P ${num(g.protein_g)}g • G ${num(g.fat_g)}g • Água ${num(g.water_ml)} ml`)
    parts.push(`Consumido: ${num(c.calories)} kcal • C ${num(c.carbs_g)}g • P ${num(c.protein_g)}g • G ${num(c.fat_g)}g • Água ${num(c.water_ml)} ml`)
    if (r) parts.push(`Restante: ${num(r.calories)} kcal • C ${num(r.carbs_g)}g • P ${num(r.protein_g)}g • G ${num(r.fat_g)}g • Água ${num(r.water_ml)} ml`)
    parts.push('Instrução: personalize a orientação usando esse contexto e confirme antes de registrar qualquer item.')
    return parts.join('\n')
  } catch {
    return `Contexto do dia (JSON): ${safeJson(ctx)}`
  }
}

function num(v) {
  if (v === null || v === undefined || Number.isNaN(Number(v))) return 0
  const n = Number(v)
  return Number.isInteger(n) ? n : Math.round(n * 10) / 10
}

function safeJson(x) {
  try { return JSON.stringify(x).slice(0, 2000) } catch { return '' }
}
