// NutriTracker Cloudflare Worker (hardened)
// Endpoints: GET /, GET /health, GET /version,
//            POST /calcular_metas, POST /planejar_jejum,
//            POST /vision/analyze_food (OpenAI only), alias: POST /analisar_foto
// Security:
//  - CORS allowlist via env.ALLOWED_ORIGINS (comma-separated). If set, only listed Origins are allowed.
//  - APP_TOKEN required for all non-OPTIONS requests via X-App-Token header (when set).
//  - Adds 'access-control-expose-headers: Retry-After' so web apps can read rate-limit.

// ---- Helpers: CORS / Auth / JSON / Logging ----
function newRequestId() {
  const rnd = Math.random().toString(36).slice(2, 8)
  return `${Date.now()}-${rnd}`
}

function logError(tag, reqId, details) {
  try { console.error(`[${reqId}] ${tag}`, details) } catch (_) {}
}

// ---- Helpers: CORS / Auth / JSON ----
function parseAllowedOrigins(env) {
  const raw = env && env.ALLOWED_ORIGINS ? String(env.ALLOWED_ORIGINS) : ''
  const list = raw.split(',').map(s => s.trim()).filter(Boolean)
  return new Set(list)
}

function isOriginAllowed(origin, allowed) {
  if (!origin) return true // allow mobile/native (no Origin header)
  if (!allowed || allowed.size === 0) return true // allow all when not configured
  return allowed.has(origin)
}

function baseHeaders(origin, allowed) {
  const h = {
    'content-type': 'application/json; charset=UTF-8',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
    'access-control-allow-headers': 'Content-Type, Authorization, X-App-Token',
    'access-control-expose-headers': 'Retry-After',
  }
  if (origin && isOriginAllowed(origin, allowed)) h['access-control-allow-origin'] = origin
  return h
}

function textHeaders(origin, allowed) {
  const h = {
    'content-type': 'text/plain; charset=UTF-8',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
    'access-control-allow-headers': 'Content-Type, Authorization, X-App-Token',
    'access-control-expose-headers': 'Retry-After',
  }
  if (origin && isOriginAllowed(origin, allowed)) h['access-control-allow-origin'] = origin
  return h
}

function json(data, status, origin, allowed, extra) {
  return new Response(JSON.stringify(data), {
    status: status || 200,
    headers: Object.assign(baseHeaders(origin, allowed), extra || {}),
  })
}

function ok(text, origin, allowed, extra) {
  return new Response(text || 'ok', {
    status: 200,
    headers: Object.assign(textHeaders(origin, allowed), extra || {}),
  })
}

function preflight(request, env, allowed) {
  const origin = request.headers.get('Origin')
  if (!isOriginAllowed(origin, allowed)) return json({ error: 'cors_forbidden' }, 403, undefined, allowed)
  return new Response(null, {
    status: 204,
    headers: Object.assign(baseHeaders(origin, allowed), { 'access-control-max-age': '86400' }),
  })
}

function requireToken(request, env, origin, allowed) {
  const expected = env && env.APP_TOKEN ? String(env.APP_TOKEN) : ''
  if (!expected) return null // not enforced if not set
  const got = request.headers.get('X-App-Token') || request.headers.get('x-app-token') || ''
  if (got !== expected) return json({ error: 'unauthorized' }, 401, origin, allowed)
  return null
}

// ---- Rate Limiter helpers ----
const RATE_WINDOW_MS = 60_000 // 1 minute
const __rateBuckets = new Map() // Map<ip, number[]> timestamps (ms)

function clientIp(req) {
  const h = req.headers
  const ip = h.get('cf-connecting-ip') || (h.get('x-forwarded-for') || '').split(',')[0].trim()
  return ip || 'unknown'
}


// ---- Turnstile helpers ----
function shouldEnforceTurnstile(env, origin) {
  const v = String(env?.TURNSTILE_REQUIRED || '1').toLowerCase()
  if (v === '0' || v === 'false') return false
  if (!origin) return false // skip for mobile/native
  return !!env?.TURNSTILE_SECRET
}

async function verifyTurnstile(token, secret, ip, reqId) {
  try {
    const body = new URLSearchParams({ secret, response: token })
    if (ip) body.append('remoteip', ip)
    const resp = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
      method: 'POST',
      body,
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
    })
    if (!resp.ok) {
      const t = await resp.text()
      logError('turnstile_http_error', reqId || 'no-reqid', { status: resp.status, body: t })
      return { success: false, http_status: resp.status }
    }
    return await resp.json()
  } catch (e) {
    logError('turnstile_exception', reqId || 'no-reqid', e)
    return { success: false, error: String(e) }
  }
}
async function kvHitAndCheck(env, key, limit, ttlSec, reqId) {
  try {
    if (!env || !env.RATELIMIT || !env.RATELIMIT.get) return { limited: false, used: false }
    const val = await env.RATELIMIT.get(key)
    let count = parseInt(val || '0', 10)
    if (!Number.isFinite(count)) count = 0
    if (count >= limit) return { limited: true, used: true }
    await env.RATELIMIT.put(key, String(count + 1), { expirationTtl: ttlSec })
    return { limited: false, used: true }
  } catch (e) {
    logError('kv_ratelimit_error', reqId || 'no-reqid', e)
    return { limited: false, used: false }
  }
}

// ---- Domain logic ----
function calcMetas(body) {
  const sexo = body?.sexo
  const idade = Number(body?.idade)
  const peso_kg = Number(body?.peso_kg)
  const altura_cm = Number(body?.altura_cm)
  const nivel = String(body?.nivel_atividade || 'sedentario')
  const objetivo = String(body?.objetivo || 'manutencao')

  const mults = { sedentario: 1.2, leve: 1.375, moderado: 1.55, alto: 1.725, atleta: 1.9 }
  const mult = mults[nivel] || 1.2
  const bmr = sexo === 'm' ? 10 * peso_kg + 6.25 * altura_cm - 5 * idade + 5 : 10 * peso_kg + 6.25 * altura_cm - 5 * idade - 161
  const tdee = bmr * mult
  const ajuste = objetivo === 'perda' ? -0.15 : objetivo === 'ganho' ? 0.1 : 0
  const kcal_meta = tdee * (1 + ajuste)
  const proteina = Math.round(1.8 * peso_kg)
  const gordura = Math.round(0.8 * peso_kg)
  const carbo = Math.max(0, Math.round((kcal_meta - proteina * 4 - gordura * 9) / 4))

  return { bmr: Math.round(bmr * 10) / 10, tdee: Math.round(tdee * 10) / 10, kcal_meta: Math.round(kcal_meta), macros_g: { proteina, carbo, gordura } }
}

function planejarJejum(body) {
  const protocolo = String(body?.protocolo || '16:8')
  const inicio_preferido = body?.inicio_preferido
  const dias = Number(body?.dias || 7)
  const map = { '12:12': [12, 12], '14:10': [14, 10], '16:8': [16, 8], '18:6': [18, 6], '20:4': [20, 4], 'omad': [23, 1] }
  const [fHoras] = map[protocolo] || [16, 8]

  const now = new Date()
  let start = new Date(now)
  if (inicio_preferido) {
    const [hh, mm] = String(inicio_preferido).split(':').map(Number)
    start.setHours(hh, mm || 0, 0, 0)
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
  return { janelas, lembretes: ['00:30 antes do inicio', 'Inicio'] }
}

function detectMimeFromBase64(b64) {
  const head = String(b64 || '').slice(0, 16)
  if (head.startsWith('/9j/')) return 'image/jpeg'
  if (head.startsWith('iVBORw0KGgo')) return 'image/png'
  if (head.startsWith('R0lGOD')) return 'image/gif'
  if (head.startsWith('UklGR')) return 'image/webp'
  return 'image/jpeg'
}

async function analyzeWithOpenAI({ image_url, image_base64, env, reqId }) {
  if (!env?.OPENAI_API_KEY) return { error: 'OPENAI_API_KEY ausente no Worker' }
  const model = env?.OPENAI_MODEL || 'gpt-4o-mini'
  const content = [ { type: 'text', text: 'Identifique alimentos na imagem e retorne JSON com campo foods: [{nome, porcao_g, calorias_kcal, proteina_g, carbo_g, gordura_g, confianca}].' } ]
  if (image_base64) {
    const mime = detectMimeFromBase64(image_base64)
    content.push({ type: 'image_url', image_url: { url: `data:${mime};base64,${image_base64}` } })
  } else if (image_url) {
    content.push({ type: 'image_url', image_url: { url: image_url } })
  } else {
    return { error: 'Envie image_url ou image_base64' }
  }

  const resp = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'authorization': `Bearer ${env.OPENAI_API_KEY}` },
    body: JSON.stringify({ model, response_format: { type: 'json_object' }, messages: [ { role: 'system', content: 'Voce e um nutricionista que responde apenas em JSON valido.' }, { role: 'user', content } ], temperature: 0.2 })
  })

  if (!resp.ok) {
    const txt = await resp.text()
    logError('OpenAI HTTP error', reqId || 'no-reqid', { status: resp.status, body: txt })
    return { error: `OpenAI HTTP ${resp.status}`, details: txt }
  }
  const data = await resp.json()
  const text = data?.choices?.[0]?.message?.content?.trim() || '{}'
  try {
    const parsed = JSON.parse(text)
    if (Array.isArray(parsed?.foods)) return parsed
    return { foods: parsed?.foods || [], raw: parsed }
  } catch (_err) {
    return { error: 'Falha ao parsear JSON do OpenAI', raw: text }
  }
}

export default {
  async fetch(request, env, ctx) {
    const reqId = newRequestId()
    const url = new URL(request.url)
    const path = url.pathname

    const allowed = parseAllowedOrigins(env)
    const origin = request.headers.get('Origin')

    if (request.method === 'OPTIONS') return preflight(request, env, allowed)
    if (!isOriginAllowed(origin, allowed)) return json({ error: 'cors_forbidden' }, 403, undefined, allowed)

    const unauthorized = requireToken(request, env, origin, allowed)
    if (unauthorized) return unauthorized

    // Routes
    if (request.method === 'GET' && path === '/') {
      return json({ status: 'ok', service: 'nutritracker-worker' }, 200, origin, allowed)
    }
    if (request.method === 'GET' && path === '/health') {
      return ok('ok', origin, allowed)
    }
    if (request.method === 'GET' && path === '/version') {
      return json({ name: 'nutritracker-worker', version: '2025-09-26-TS2' }, 200, origin, allowed)
    }


    // Optional debug (enable with DEBUG_KV=1)

    if (request.method === 'POST' && path === '/calcular_metas') {
      const body = await request.json().catch(() => ({}))
      const result = calcMetas(body)
      return json(result, 200, origin, allowed)
    }

    if (request.method === 'POST' && path === '/planejar_jejum') {
      const body = await request.json().catch(() => ({}))
      const result = planejarJejum(body)
      return json(result, 200, origin, allowed)
    }

    if (request.method === 'POST' && (path === '/vision/analyze_food' || path === '/analisar_foto')) {
      const body = await request.json().catch(() => ({}))
      // Turnstile (web only by default): require token when Origin exists and TURNSTILE_SECRET is set.
      try {
        if (shouldEnforceTurnstile(env, origin)) {
          const token = request.headers.get('X-Turnstile-Token') || body?.turnstile_token || body?.cf_turnstile_token;
          if (!token) {
            return json({ error: 'turnstile_missing' }, 403, origin, allowed);
          }
          const vr = await verifyTurnstile(token, String(env.TURNSTILE_SECRET), clientIp(request), reqId);
          const min = Number(env?.TURNSTILE_MIN_SCORE || 0);
          if (!vr?.success) {
            return json({ error: 'turnstile_failed', details: vr?.['error-codes'] || vr }, 403, origin, allowed);
          }
          if (min > 0 && typeof vr?.score === 'number' && vr.score < min) {
            return json({ error: 'turnstile_low_score', score: vr.score }, 403, origin, allowed);
          }
        }
      } catch (e) { logError('turnstile_guard_error', reqId || 'no-reqid', e) }

      // Rate limit: memory ALWAYS + KV best-effort. First to hit wins.
      try {
        const ip = clientIp(request)
        const now = Date.now()
        const limit = Number(env?.VISION_RATE_LIMIT || 20)

        // In-memory window 60s
        let arr = __rateBuckets.get(ip)
        if (!arr) { arr = []; __rateBuckets.set(ip, arr) }
        const cutoff = now - RATE_WINDOW_MS
        let i = 0
        while (i < arr.length && arr[i] < cutoff) i++
        if (i > 0) arr.splice(0, i)
        if (arr.length >= limit) {
          return json({ error: 'rate_limited', retry_after_seconds: 60 }, 429, origin, allowed, { 'retry-after': '60' })
        }
        arr.push(now)

        // KV minute bucket
        const minute = Math.floor(now / 60000)
        const kv = await kvHitAndCheck(env, `vision:${ip}:${minute}`, limit, 65, reqId)
        if (kv.limited) {
          return json({ error: 'rate_limited', retry_after_seconds: 60 }, 429, origin, allowed, { 'retry-after': '60' })
        }
      } catch (e) { logError('rate_limiter_error', reqId || 'no-reqid', e) }

      // Base64 size guard (~3 MB)
      try {
        const b64 = String(body?.image_base64 || '')
        if (b64) {
          const approxBytes = Math.floor((b64.length * 3) / 4)
          const max = 3 * 1024 * 1024
          if (approxBytes > max) return json({ error: 'image_too_large', max_bytes: max }, 413, origin, allowed)
        }
      } catch (_) {}

      const provider = String(env?.VISION_PROVIDER || 'openai').toLowerCase()
      if (provider !== 'openai') return json({ error: `VISION_PROVIDER=${provider} ainda nao implementado neste Worker` }, 400, origin, allowed)

      const result = await analyzeWithOpenAI({ image_url: body.image_url, image_base64: body.image_base64, env, reqId })
      if (result?.error) return json(result, 502, origin, allowed)
      return json(result, 200, origin, allowed)
    }

    return json({ error: 'not_found' }, 404, origin, allowed)
  },
}
