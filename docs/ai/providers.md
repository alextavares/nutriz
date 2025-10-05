# Provedores e Estratégia (LLM, Visão, Voz)

Esta é uma recomendação prática com ordens de grandeza e observações — valide preços/limites nos sites oficiais, pois mudam com frequência.

## LLM (texto + function calling)
- OpenAI (GPT‑4o / 4o‑mini)
  - Prós: PT‑BR muito bom, function calling sólido, multimodal (4o), latência baixa.
  - Uso sugerido: diálogo/coaching + orquestração de ferramentas; 4o‑mini para rotinas, 4o para prompts complexos.
- Anthropic (Claude 3.5 Sonnet/Haiku)
  - Prós: respostas seguras, boas instruções longas; ferramentas bem suportadas.
  - Uso sugerido: coach seguro com contexto extenso e RAG.
- Google (Gemini 1.5 Pro/Flash)
  - Prós: ótimo multimodal; 1.5 Flash é rápido e econômico; function calling disponível.
  - Uso sugerido: POCs multimodais (foto/voz) e fluxos de baixo custo com Flash.
- Open‑source (Llama 3.x, Mistral)
  - Prós: controle, privacidade, custo previsível; on‑device/edge possível.
  - Contra: requer MLOps; qualidade/latência variam.

Latency típica alvo (com function calling):
- 0.6–2.0 s por volta com 1–2 ferramentas. Otimize cache e respostas curtas.

## Visão (foto de refeição)
- Cloud imediato: Gemini Vision (Google), GPT‑4o (OpenAI)
  - Ideal para MVP. Controle custos com limites de fotos/dia.
- Modelo próprio depois: EfficientNet/MobileNet + cabeça de classificação/segmentação
  - Treino incremental com feedback do usuário; melhora custo/latência a médio prazo.

## Voz (STT/TTS)
- Google Speech / Azure Speech / Amazon Transcribe/Polly
  - Qualidade PT‑BR consistente, preço por minuto. Habilite só no premium inicialmente.
- TTS neural (ElevenLabs, Azure)
  - Fornece “voz do coach”. Considere local/offline para baixo custo (p. ex., Coqui‑TTS) se necessário.

## Custos (guidelines, não contratuais)
- LLM médio/pequeno para rotina: baixo custo por 1k tokens; complexos (multimodal/maiores) custam mais.
- Visão cloud por imagem: custo unitário por chamada; limite diário por usuário para previsibilidade.
- STT/TTS: custo por minuto — habilite sob demanda.

## Estratégia de uso
- Camadas de modelos: mini para rotinas rápidas; maior para tarefas complexas.
- RAG + ferramentas: reduz alucinação e custo (menos tokens explicativos).
- Observabilidade (Langfuse/Helicone) e feedback in‑app para melhorar prompts e ferramentas.

## NLQ (texto livre → nutrição)
- API Ninjas — Nutrition (escolhido)
  - Prós: barato/simples; resposta direta por item; fácil integrar com `Dio`.
  - Como usar: defina `NINJAS_API_KEY` (via `--dart-define` ou `env.json`). O app detecta e usa NLQ quando a busca contém quantidades/unidades (ex.: "150g frango grelhado", "2 ovos e 1 banana").
  - Normalização: convertemos para valores por 100 g para alinhar com FDC/OFF.
- Alternativas: Nutritionix (bom NLQ, cadastro necessário), Edamam (mais caro, foco em receitas), Spoonacular (mais receitas que NLQ de alimentos).
