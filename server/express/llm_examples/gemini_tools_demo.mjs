import { GoogleGenerativeAI } from '@google/generative-ai'
import { callTool } from './_orchestrator.mjs'

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY)

const system = `Você é “Nutri”, coach de nutrição e jejum do app. 
Use ferramentas para cálculos/registro. Seja objetivo, empático e seguro.`

const toolDefs = [{
  name: 'planejar_jejum',
  description: 'Gera janelas de jejum e lembretes',
  parameters: {
    type: 'OBJECT',
    properties: {
      protocolo: { type: 'STRING' },
      inicio_preferido: { type: 'STRING' },
      dias: { type: 'NUMBER' }
    },
    required: ['protocolo']
  }
}, {
  name: 'buscar_alimento',
  description: 'Busca alimentos (Open Food Facts)',
  parameters: {
    type: 'OBJECT',
    properties: { query: { type: 'STRING' }, top_k: { type: 'NUMBER' } },
    required: ['query']
  }
}, {
  name: 'analisar_barcode',
  description: 'Analisa produto por código de barras (OFF)',
  parameters: { type: 'OBJECT', properties: { barcode: { type: 'STRING' } }, required: ['barcode'] }
}, {
  name: 'analisar_foto',
  description: 'Analisa imagem de refeição (OpenAI/Gemini Vision)',
  parameters: { type: 'OBJECT', properties: { image_url: { type: 'STRING' }, image_base64: { type: 'STRING' } } }
}, {
  name: 'obter_estatisticas_usuario',
  description: 'Resumo diário/semana',
  parameters: { type: 'OBJECT' }
}, {
  name: 'sugerir_refeicao',
  description: 'Sugere refeições alinhadas a macros',
  parameters: { type: 'OBJECT' }
}]

async function run() {
  const model = genAI.getGenerativeModel({
    model: process.env.GEMINI_MODEL || 'gemini-1.5-pro',
    systemInstruction: system,
    tools: [{ functionDeclarations: toolDefs }]
  })

  const chat = model.startChat()
  const user = 'Quero começar jejum 16:8 hoje às 20h. Tenho um código de barras 7891000319310 e esta imagem: https://upload.wikimedia.org/wikipedia/commons/2/2f/Cooked_chicken.jpg. Se fizer sentido, use buscar_alimento/analisar_barcode/analisar_foto e depois sugira jantar ~600 kcal.'
  let resp = await chat.sendMessage(user)
  let out = resp.response

  // Verifica chamadas de função
  while (true) {
    const parts = out.candidates?.[0]?.content?.parts || []
    const calls = parts.filter(p => p.functionCall)
    if (!calls.length) break
    const toolMsgs = []
    for (const c of calls) {
      const name = c.functionCall.name
      const args = c.functionCall.args || {}
      const result = await callTool(name, args)
      toolMsgs.push({ functionResponse: { name, response: { result } } })
    }
    resp = await chat.sendMessage(toolMsgs)
    out = resp.response
  }

  console.log('\n--- Resposta do Coach (Gemini) ---\n')
  console.log(out.text())
}

run().catch(err => {
  console.error(err)
  process.exit(1)
})
