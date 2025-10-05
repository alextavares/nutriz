# MCP Validation Flows — Daily Dashboard

Objetivo: validar (via MCP Android) o polimento no Diário:
- Números com separador por locale (pt-BR: 1.459)
- Barras de macros com novo estilo e rótulos “x / y g”

Pré-requisitos
- Emulador: `emulator-5556` com nosso app (`com.nutritracker.app`) instalado e aberto no Diário.
- Alternativamente, ajustar o serial conforme necessário.

Sequência — Diário
1) Selecionar dispositivo
   - mobile_use_device: device=emulator-5556, deviceType=android
2) Abrir app
   - mobile_launch_app: packageName=com.nutritracker.app
3) Capturar screenshot inicial (opcional)
   - mobile_save_screenshot: saveTo=docs/validation/dashboard-initial.png
4) Listar elementos na tela
   - mobile_list_elements_on_screen
   - Esperado: labels como “Restante”, “Consumidas”, “Gastas (Exercício)”, “Carboidratos/Proteínas/Gorduras”, e valores alinhados ao locale.
5) Validar incremento de água
   - Encontrar botão/CTA de “+250 ml” (ou card Água) no Dashboard
   - mobile_click_on_screen_at_coordinates (coordenadas do botão)
   - mobile_list_elements_on_screen → verificar aumento do total de água
6) Abrir detalhamento de calorias (se aplicável)
   - Tocar no anel ou no card de resumo
   - mobile_list_elements_on_screen
   - Verificar que números exibem separadores por locale (ex.: 1.450 → 1.450 em pt-BR)

Checks específicos
- “Restante” (centro do anel): número com separador + cor conforme excedido ou não.
- “Consumidas/Restantes/Gastas/Meta Total” (sheet): mostram “x.xxx kcal”.
- Barras de macros:
  - Espessura ~14 px, cantos arredondados (pílula)
  - Fundo com cor da macro em ~18% de opacidade
  - Rótulos “Carboidratos/Proteínas/Gorduras” + “xx%” e “a / b g” (locale-aware)

Notas
- Se a UI estiver em inglês, o separador será `,` (ex.: 1,459). Em pt-BR será `.` (ex.: 1.459).
- Se for necessário navegar pelo app até o Dashboard, use a bottom navigation.

Rotina de fallback
- Se `mobile_list_elements_on_screen` falhar, tirar screenshot (`mobile_save_screenshot`) e validá-lo manualmente.

---
Última atualização: 2025-09-01
