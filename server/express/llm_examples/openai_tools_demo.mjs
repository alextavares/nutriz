import OpenAI from 'openai'
import { callTool } from './_orchestrator.mjs'

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

const system = `Você é “Nutri”, coach de nutrição e jejum do app. 
Use ferramentas para cálculos/registro. Seja objetivo, empático e seguro.`

const tools = [
  {
    type: 'function',
    function: {
      name: 'planejar_jejum',
      description: 'Gera janelas de jejum e lembretes',
      parameters: {
        type: 'object',
        properties: {
          protocolo: { type: 'string', enum: ['12:12','14:10','16:8','18:6','20:4','omad'] },
          inicio_preferido: { type: 'string', description: 'HH:MM' },
          dias: { type: 'number' }
        },
        required: ['protocolo']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'buscar_alimento',
      description: 'Busca alimentos (Open Food Facts)',
      parameters: {
        type: 'object',
        properties: {
          query: { type: 'string' },
          top_k: { type: 'number' }
        },
        required: ['query']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'analisar_barcode',
      description: 'Analisa produto por código de barras (OFF)',
      parameters: {
        type: 'object',
        properties: {
          barcode: { type: 'string' }
        },
        required: ['barcode']
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'analisar_foto',
      description: 'Analisa imagem de refeição (OpenAI/Gemini Vision)',
      parameters: {
        type: 'object',
        properties: {
          image_url: { type: 'string' },
          image_base64: { type: 'string' }
        }
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'obter_estatisticas_usuario',
      description: 'Resumo diário/semana (macros restantes, adesão)'
    }
  },
  {
    type: 'function',
    function: {
      name: 'sugerir_refeicao',
      description: 'Sugere refeições alinhadas a macros',
      parameters: {
        type: 'object',
        properties: {
          macros_restantes: { type: 'object' },
          restricoes: { type: 'array', items: { type: 'string' } },
          preferencias: { type: 'array', items: { type: 'string' } }
        }
      }
    }
  }
]

async function run() {
  const messages = [
    { role: 'system', content: system },
    { role: 'user', content: 'Quero começar jejum 16:8 hoje às 20h. Também tenho um código de barras 7891000319310 para escanear e uma foto desta refeição https://upload.wikimedia.org/wikipedia/commons/2/2f/Cooked_chicken.jpg. Diga o que é, uma porção aproximada e sugira um jantar ~600 kcal. Se precisar, use buscar_alimento/analisar_barcode/analisar_foto.' }
  ]

  // Passo 1: chama o modelo com ferramentas registradas
  let resp = await openai.chat.completions.create({
    model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
    messages,
    tools,
    temperature: 0.3
  })
  let msg = resp.choices[0].message

  // Passo 2: executa tools chamadas pelo modelo
  if (msg.tool_calls && msg.tool_calls.length) {
    messages.push(msg) // push assistant message containing tool_calls once
    for (const tc of msg.tool_calls) {
      const args = JSON.parse(tc.function.arguments || '{}')
      const result = await callTool(tc.function.name, args)
      messages.push({ role: 'tool', tool_call_id: tc.id, content: JSON.stringify(result) })
    }
    // Passo 3: segunda rodada para obter a resposta final do assistente
    resp = await openai.chat.completions.create({
      model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
      messages,
      tools,
      temperature: 0.3
    })
    msg = resp.choices[0].message
  }

  console.log('\n--- Resposta do Coach (OpenAI) ---\n')
  console.log(msg.content)
}

run().catch(err => {
  console.error(err)
  process.exit(1)
})
