NutriTracker ↔ YAZIO — Handoff para próxima sessão do Codex

Contexto e objetivo
- Repositório: `nutritracker` (Flutter).
- Ambiente: WSL com Codex CLI; network enabled; filesystem danger-full-access.
- Emuladores Android já abertos no Windows: `emulator-5554` (YAZIO) e `emulator-5556` (NutriTracker).
- Meta: aproximar ao máximo as telas/UX do NutriTracker ao YAZIO, iterando por partes (home → fluxos saindo da home → demais telas). Capturar telas, comparar, ajustar tema/UX, rebuild, reinstalar e validar.

Mapeamento de dispositivos e pacotes
- `emulator-5554`: YAZIO de referência, pacote `com.yazio.android`.
- `emulator-5556`: app nosso, pacote `com.nutritracker.app`.
- ADB Windows: `C:/Users/alext/AppData/Local/Android/Sdk/platform-tools/adb.exe` (no WSL: `/mnt/c/Users/alext/AppData/Local/Android/Sdk/platform-tools/adb.exe`).

Fluxo de trabalho (resumido)
1) Confirmar dispositivos:
   - `/mnt/c/Users/alext/AppData/Local/Android/Sdk/platform-tools/adb.exe devices -l`
2) Abrir apps (monkey):
   - YAZIO: `.../adb.exe -s emulator-5554 shell monkey -p com.yazio.android -c android.intent.category.LAUNCHER 1`
   - NutriTracker: `.../adb.exe -s emulator-5556 shell monkey -p com.nutritracker.app -c android.intent.category.LAUNCHER 1`
3) Capturar telas (preferir MCP mobile):
   - `mobile_use_device(emulator-5554)` → `mobile_save_screenshot('C:/Users/alext/Downloads/nutritracker/yazio-home.png')`
   - `mobile_use_device(emulator-5556)` → `mobile_save_screenshot('C:/Users/alext/Downloads/nutritracker/nutritracker-home.png')`
4) Iterar no código e rebuild:
   - Flutter local do projeto: `.tooling/flutter/bin/flutter pub get`
   - Build (se necessário): `cd android && ./gradlew assembleDebug`
   - Instalar: `/mnt/c/.../adb.exe -s emulator-5556 install -r build/app/outputs/flutter-apk/app-debug.apk`
   - Abrir novamente via monkey e validar. Se alterar tema/cores, repetir capturas.

Screenshots já salvas
- YAZIO home: `C:/Users/alext/Downloads/nutritracker/yazio-home.png`
- NutriTracker antes: `C:/Users/alext/Downloads/nutritracker/nutritracker-home.png`
- NutriTracker depois (tema ajustado): `C:/Users/alext/Downloads/nutritracker/nutritracker-home-after.png`

Arquivos-chave para continuidade
- Tema: `lib/theme/app_theme.dart`
  - Tokens ajustados para aproximar do YAZIO (na sessão anterior):
    - `secondaryBackgroundDark`: `#F7F8FA` (superfície clara)
    - `activeBlue`: `#2D81E0`
    - `successGreen`: `#27AE60`
    - `warningAmber`: `#F2994A`
    - `premiumGold`: `#FFD54F`
    - `textPrimary`: `#263238`
    - `dividerGray`: `#E6E8EB`
  - Cartões: raio 16, elevação 1.

- Home/dashboard: `lib/presentation/daily_tracking_dashboard/daily_tracking_dashboard.dart`
  - Seções principais: cards de refeições, macros, água, banner de jejum.
  - Botões "+" das refeições, prévias de itens e progresso (kcal por refeição).
  - Ajustes já feitos: layout mais limpo no cabeçalho, macros compactas, divisores suaves e cartão de água com copos + botão `+250 ml`.

- Anel/calorias: `lib/presentation/daily_tracking_dashboard/widgets/circular_progress_chart_widget.dart`
  - Tipografia/cores alinhadas (azul primário e verde para gastos), labels laterais Eaten/Burned e número central Remaining animado.

Como rodar rapidamente após reinício
- No WSL, dentro da pasta do projeto:
  - `.tooling/flutter/bin/flutter pub get`
  - `cd android && ./gradlew assembleDebug` (se precisar rebuild)
  - `cd ..`
  - Instalar no emulador 5556: `/mnt/c/.../adb.exe -s emulator-5556 install -r build/app/outputs/flutter-apk/app-debug.apk`
  - Abrir: `/mnt/c/.../adb.exe -s emulator-5556 shell monkey -p com.nutritracker.app -c android.intent.category.LAUNCHER 1`

Próximos focos sugeridos (Home)
- Top bar: alinhar ícones e espaçamento com o YAZIO (data/hoje + ações).
- Cartões de refeição: tipografia do título/valores e balancear pesos; revisar cor do botão "+" para o tom `#2D81E0` com ícone branco.
- Prévia de itens: só exibir linhas quando houver itens (ex.: evitar linha "Arroz (total)" vazia em layouts limpos).
- Água: manter mensagem "Faltam X ml..." e progress bar mais leve; revisar contraste das gotinhas.

Próxima etapa do plano (macro)
1) Home 100%: tipografia, cores, espaçamentos e microinterações.
2) Fluxos a partir da Home: adicionar alimento, editar refeição, meta de água, calendário.
3) Outras telas (progressos/jejum/perfil) replicando visual/UX do YAZIO.

Observações
- Se `uiautomator dump` falhar no emulador para inspecionar árvore, use as capturas e a comparação visual; a MCP `mobile_list_elements_on_screen` às vezes retorna vazio em apps com surface custom.
- Caso o `flutter build apk` falhe, o `./gradlew assembleDebug` geralmente produz `build/app/outputs/flutter-apk/app-debug.apk` utilizável.

Resumo do estado atual
- Conexão ADB com os dois emuladores OK.
- Capturas base e pós-ajuste de tema salvas.
- Tema aproximado ao YAZIO aplicado e instalado no 5556.
- Pendências: polimento da home (top bar, cartões de refeição e água) e iniciar mapeamento dos fluxos a partir da home.

Atualização 2025-09-01
- Home polida:
  - Top bar: ícones compactos (20px) com espaçamento/constraints mais justos; título com peso forte (titleLarge, -0.2 letterSpacing).
  - Água: barra de progresso mais leve (4px) e contraste das gotinhas ajustado (filled usa primary ~92% e outlined usa onSurfaceVariant ~65%).
  - Refeições: botão “+” no azul `#2D81E0` com ícone branco; prévia de itens só aparece quando existir conteúdo.
- Build no WSL: houve falha do Gradle (`URISyntaxException` envolvendo caminho Windows em `flutter_assets`). Isso costuma ser mistura de caminhos Windows/WSL.
  - Alternativas:
    1) Rodar build no Windows (Android Studio/PowerShell) em `C:\Users\alext\Downloads\nutritracker\nutritracker\android`.
    2) No WSL, tentar `flutter build apk --debug`; se persistir, preferir a opção (1) nesta rodada.
  - Após gerar o APK, instalar via ADB (no WSL): `/mnt/c/.../adb.exe -s emulator-5556 install -r build/app/outputs/flutter-apk/app-debug.apk`.
