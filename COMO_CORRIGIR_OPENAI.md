# 🔧 Como Corrigir a Chave OpenAI - NutriTracker

**Data:** 13 de Janeiro de 2025
**Status:** Chave OpenAI está INVÁLIDA ❌

---

## 📋 Problema Identificado:

Sua chave OpenAI em `env.json` está **expirada ou revogada**.

**Erro ao testar:**
```json
{
  "error": {
    "message": "Incorrect API key provided",
    "type": "invalid_request_error",
    "code": "invalid_api_key"
  }
}
```

---

## ✅ Boa Notícia: Gemini Está FUNCIONANDO!

O código Gemini já está **correto** e usando os modelos atualizados:
- Modelo padrão: `gemini-1.5-flash-002` ✅
- Fallbacks: `gemini-1.5-pro-latest`, `gemini-1.5-flash-latest`, etc. ✅
- API key válida ✅
- Timeout aumentado para 30s ✅

**Você pode usar APENAS Gemini e ignorar OpenAI!**

---

## 🎯 Opção 1: Usar APENAS Gemini (RECOMENDADO) ⭐

**Vantagens:**
- ✅ Gemini API key já funciona
- ✅ Grátis (60 requisições/minuto)
- ✅ Modelos atualizados e funcionais
- ✅ Zero configuração adicional
- ✅ Sem custos

**Como fazer:**

### 1️⃣ Desabilitar OpenAI no Cloudflare Worker

Acesse: https://dash.cloudflare.com/

```
Workers & Pages → nutritracker-worker → Settings → Variables → Environment Variables
```

**Adicione ou modifique:**
```
VISION_PROVIDER = gemini
```

Isso fará o Worker usar **apenas Gemini** para análise de imagens.

### 2️⃣ Adicionar Gemini API Key no Worker (se ainda não tiver)

```
Workers & Pages → nutritracker-worker → Settings → Variables → Secrets
```

**Adicione:**
```
GEMINI_API_KEY = AIzaSyCrbP-KtZBAfwlF5iSTZhuTvudZTDvmo-Y
```

(Use a mesma chave que está em `env.json`)

### 3️⃣ Deploy o Worker

Clique em **"Deploy"** no painel do Cloudflare.

### 4️⃣ Testar

```bash
# Teste o Worker com Gemini
powershell -ExecutionPolicy Bypass -File test_worker_vision.ps1
```

**Pronto!** Agora o app usará apenas Gemini (grátis e funcional)! 🎉

---

## 🔄 Opção 2: Gerar Nova Chave OpenAI (Se Quiser Usar OpenAI)

**Por que usar OpenAI:**
- GPT-4o-mini pode ser mais preciso em alguns casos
- Você já configurou o Worker para usar OpenAI

**Custos:**
- $0.002 por requisição (aproximadamente)
- Primeiros $5 grátis no primeiro mês

**Passos:**

### 1️⃣ Gerar Nova Chave OpenAI

1. Acesse: https://platform.openai.com/api-keys
2. Faça login com sua conta OpenAI
3. Clique em **"Create new secret key"**
4. Dê um nome: `nutritracker-app`
5. Copie a chave (começa com `sk-proj-...`)

**⚠️ ATENÇÃO:** A chave só será mostrada UMA VEZ! Copie e guarde!

### 2️⃣ Atualizar env.json

Abra `c:\Users\alext\Downloads\nutritracker\nutritracker\env.json`

Substitua a chave antiga:
```json
{
  "OPENAI_API_KEY": "sk-proj-NOVA-CHAVE-AQUI"
}
```

### 3️⃣ Atualizar Cloudflare Worker

Acesse: https://dash.cloudflare.com/

```
Workers & Pages → nutritracker-worker → Settings → Variables → Secrets
```

**Edite:**
```
OPENAI_API_KEY = sk-proj-NOVA-CHAVE-AQUI
```

**E certifique-se que:**
```
VISION_PROVIDER = openai
```

### 4️⃣ Deploy o Worker

Clique em **"Deploy"** no painel do Cloudflare.

### 5️⃣ Testar

```bash
# Teste o Worker com OpenAI
powershell -ExecutionPolicy Bypass -File test_worker_vision.ps1
```

---

## 🚀 Minha Recomendação: OPÇÃO 1 (Gemini)

**Por quê?**
- ✅ **Grátis:** Zero custos vs OpenAI ($0.002/req)
- ✅ **Já funciona:** API key válida e modelos corretos
- ✅ **Rápido:** Não precisa gerar nova chave
- ✅ **Confiável:** Google Gemini é poderoso e preciso
- ✅ **Limite generoso:** 60 req/min grátis

**Para publicar no Early Access:**
1. Configure Worker para usar Gemini (VISION_PROVIDER=gemini)
2. Deploy do Worker
3. Teste no app
4. Publique! 🎉

---

## 📊 Comparação: OpenAI vs Gemini

| Feature | OpenAI GPT-4o-mini | Google Gemini 1.5 Flash |
|---------|-------------------|------------------------|
| **Custo** | $0.002/req | **GRÁTIS** ✅ |
| **Limite** | Por crédito | 60 req/min |
| **Status da API** | ❌ Key inválida | ✅ Funcionando |
| **Qualidade** | Excelente | Excelente |
| **Velocidade** | Rápido | **Muito rápido** ✅ |
| **Multimodal** | Sim | Sim |

---

## 🧪 Como Testar Após Corrigir

### Teste 1: Worker Health
```bash
$TOKEN = "443e32b61ffceba50a8e415de89fd77b4e30d33dd4b61ad609070df507ce983e"
$BASE_URL = "https://nutritracker-worker.alexandretmoraes110.workers.dev"

Invoke-WebRequest -Uri "$BASE_URL/health" -Headers @{"X-App-Token"=$TOKEN}
```

**Esperado:** 200 OK

### Teste 2: Vision Endpoint
```bash
powershell -ExecutionPolicy Bypass -File test_worker_vision.ps1
```

**Esperado:** Resposta em 10-30 segundos com alimentos detectados

### Teste 3: No App
1. Abra o app no emulador
2. Vá em "Detect Food with AI"
3. Tire foto de uma banana ou maçã
4. Aguarde 10-30 segundos
5. Deve mostrar alimentos detectados! ✅

---

## ❓ FAQ

### P: Preciso pagar para usar OpenAI?
R: Sim, após os primeiros $5 grátis. **Recomendo usar Gemini (grátis).**

### P: Gemini é tão bom quanto OpenAI?
R: Sim! Gemini 1.5 Flash é muito rápido e preciso para análise de imagens de comida.

### P: Posso trocar depois?
R: Sim! Basta mudar `VISION_PROVIDER` no Worker de `gemini` para `openai` ou vice-versa.

### P: E se eu já tiver créditos OpenAI?
R: Então use OpenAI! Siga a Opção 2 acima.

### P: O Worker funciona sem OpenAI?
R: **SIM!** Basta configurar `VISION_PROVIDER=gemini` e adicionar `GEMINI_API_KEY`.

---

## ✅ Checklist de Ação

**Para usar Gemini (RECOMENDADO):**
- [ ] Acesse Cloudflare Dashboard
- [ ] Workers → nutritracker-worker → Settings → Variables
- [ ] Adicione `VISION_PROVIDER=gemini`
- [ ] Adicione `GEMINI_API_KEY=AIzaSyCrbP-KtZBAfwlF5iSTZhuTvudZTDvmo-Y`
- [ ] Deploy
- [ ] Teste com `test_worker_vision.ps1`
- [ ] Teste no app
- [ ] Publique! 🎉

**Para usar OpenAI:**
- [ ] Acesse https://platform.openai.com/api-keys
- [ ] Gere nova chave
- [ ] Atualize `env.json`
- [ ] Atualize Worker secrets
- [ ] Certifique-se `VISION_PROVIDER=openai`
- [ ] Deploy
- [ ] Teste com `test_worker_vision.ps1`
- [ ] Teste no app

---

## 🎯 Próximo Passo

**Escolha uma opção:**
1. ⭐ **Opção 1 (RECOMENDADO):** Configure Worker para usar Gemini
2. Opção 2: Gere nova chave OpenAI

Depois de configurar, teste e publique o app! 🚀

---

**Dúvidas?** Consulte:
- [RELATORIO_API_KEYS.md](RELATORIO_API_KEYS.md) - Diagnóstico completo
- [DIAGNOSTICO_WORKER.md](DIAGNOSTICO_WORKER.md) - Debug do Worker
- [docs/sessao-2025-09-27.md](docs/sessao-2025-09-27.md) - Config original do Worker
