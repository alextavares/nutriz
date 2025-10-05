# Exemplos de Uso (Funções + Fluxos)

## 1) Onboarding curto
1. Usuário: “Quero começar no 16:8 hoje às 20h.”
2. LLM chama `planejar_jejum` com `{ protocolo: "16:8", inicio_preferido: "20:00" }`.
3. LLM responde: “Agendei sua janela 20:00–12:00. Enviar lembrete 19:30 e 20:00?”

## 2) Registrar por foto
1. Usuário envia foto.
2. LLM chama `analisar_foto` → recebe candidatos e porções.
3. LLM confirma com o usuário as escolhas e porções.
4. LLM chama `log_refeicao` com itens confirmados.
5. LLM responde: “Registrado! Total ~540 kcal. Falta 25 g de proteína hoje.”

## 3) Sugestão de almoço
1. LLM chama `obter_estatisticas_usuario` → lê macros restantes.
2. LLM chama `sugerir_refeicao` com `{ macros_restantes, restricoes/preferencias }`.
3. LLM apresenta 2–3 opções, cada uma com kcal/macros e passo a passo curto.

