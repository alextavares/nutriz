import fetch from 'node-fetch'

const BASE = process.env.EXPRESS_BASE_URL || 'http://localhost:8002'

export async function callTool(name, args = {}) {
  const url = `${BASE}/${name}`
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(args)
  })
  if (!res.ok) {
    const text = await res.text()
    throw new Error(`Tool ${name} failed: ${res.status} ${text}`)
  }
  return await res.json()
}

