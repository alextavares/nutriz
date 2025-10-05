import Anthropic from '@anthropic-ai/sdk'
import { callTool } from './_orchestrator.mjs'

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY })

const system = `Você é “Nutri”, coach de nutrição e jejum do app. 
Use ferramentas para cálculos/registro. Seja objetivo, empático e seguro.`

const tools = [
  {
    name: 'planejar_jejum',
    description: 'Gera janelas de jejum e lembretes',
    input_schema: {
      type: 'object',
      properties: {
        protocolo: { type: 'string', enum: ['12:12','14:10','16:8','18:6','20:4','omad'] },
        inicio_preferido: { type: 'string' },
        dias: { type: 'number' }
      },
      required: ['protocolo']
    }
  },
  {
    name: 'buscar_alimento',
    description: 'Busca alimentos (Open Food Facts)',
    input_schema: {
      type: 'object',
      properties: { query: { type: 'string' }, top_k: { type: 'number' } },
      required: ['query']
    }
  },
  {
    name: 'analisar_barcode',
    description: 'Analisa produto por código de barras (OFF)',
    input_schema: { type: 'object', properties: { barcode: { type: 'string' } }, required: ['barcode'] }
  },
  {
    name: 'analisar_foto',
    description: 'Analisa imagem de refeição (OpenAI/Gemini Vision)',
    input_schema: { type: 'object', properties: { image_url: { type: 'string' }, image_base64: { type: 'string' } } }
  },
  { name: 'obter_estatisticas_usuario', description: 'Resumo diário/semana (macros restantes, adesão)', input_schema: { type: 'object', properties: {} } },
  { name: 'sugerir_refeicao', description: 'Sugere refeições alinhadas a macros', input_schema: { type: 'object', properties: { macros_restantes: { type: 'object' } } } }
]

async function run() {
  const resp = await anthropic.messages.create({
    model: process.env.ANTHROPIC_MODEL || 'claude-3-5-sonnet-20240620',
    system,
    tools,
    temperature: 0.3,
    max_tokens: 800,
    messages: [
      { role: 'user', content: 'Quero começar jejum 16:8 hoje às 20h. Tenho um código de barras 7891000319310 e esta foto para analisar: https://upload.wikimedia.org/wikipedia/commons/2/2f/Cooked_chicken.jpg. Use buscar_alimento/analisar_barcode/analisar_foto se fizer sentido e sugira jantar ~600 kcal.' }
    ]
  })

  // Orquestra ferramentas
  let content = resp.content
  const toolUses = content.filter(p => p.type === 'tool_use')
  const toolResults = []
  for (const tu of toolUses) {
    const result = await callTool(tu.name, tu.input)
    toolResults.push({
      type: 'tool_result',
      tool_use_id: tu.id,
      content: JSON.stringify(result)
    })
  }

  let final
  if (toolResults.length) {
    const second = await anthropic.messages.create({
      model: process.env.ANTHROPIC_MODEL || 'claude-3-5-sonnet-20240620',
      system,
      tools,
      temperature: 0.3,
      max_tokens: 800,
      messages: [
        { role: 'user', content: 'Quero começar jejum 16:8 hoje às 20h e sugestões para jantar ~600 kcal.' },
        { role: 'assistant', content },
        { role: 'user', content: toolResults }
      ]
    })
    final = second
  } else {
    final = resp
  }

  const text = final.content.map(p => (p.type === 'text' ? p.text : '')).join('\n')
  console.log('\n--- Resposta do Coach (Anthropic) ---\n')
  console.log(text)
}

run().catch(err => {
  console.error(err)
  process.exit(1)
})
