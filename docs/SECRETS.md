# Guia de Segredos — NutriTracker

Objetivo: endurecer a gestão de segredos (API keys) no desenvolvimento local e CI, evitando vazamentos acidentais de chaves.

## Princípios

- Não versionar arquivos com segredos (ex.: `env.json`).
- Preferir `--dart-define` (ou `--dart-define-from-file`) para injeção de chaves.
- Em CI, usar variáveis de ambiente/secrets do provedor (GitHub Actions, etc.).

## Como fornecer segredos

1) Via linha de comando (recomendado)

Exemplos de execução local com `--dart-define`:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=seu_token

flutter build apk \
  --release \
  --dart-define=GEMINI_API_KEY=seu_token
```

2) Via arquivo (dev apenas)

Caso prefira agrupar várias chaves num arquivo local não versionado:

```bash
flutter run --dart-define-from-file=env.json
flutter build apk --release --dart-define-from-file=env.json
```

Observações:
- `env.json` deve existir apenas na sua máquina e está no `.gitignore`.
- Se o repositório já contiver `env.json` com chaves reais, remova do histórico e rode rotação das chaves.

## Onde as chaves são lidas no código

- `GeminiService` lê primeiro de `String.fromEnvironment('GEMINI_API_KEY')` e, se ausente, tenta `assets/env.json` (em dev).
- Serviços de bancos de alimentos:
  - Open Food Facts: não requer chave (REST público).
  - USDA FoodDataCentral: aceita `apiKey` (wire não ativo por padrão; passe chave ao instanciar).

Não há outras leituras de chaves hardcoded detectadas no código-fonte (fora de `env.json`).

## GitHub Actions (exemplo)

Defina `GEMINI_API_KEY` nos Secrets do repositório e injete no passo de build:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.2'
      - name: Pub get
        run: flutter pub get
      - name: Build APK (release)
        run: flutter build apk --release --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}
```

Alternativa com arquivo gerado on-the-fly (se preferir agrupar várias chaves):

```yaml
      - name: Generate env.json (not committed)
        run: |
          cat > env.json <<'JSON'
          { "GEMINI_API_KEY": "${{ secrets.GEMINI_API_KEY }}" }
          JSON
      - name: Build with dart-define-from-file
        run: flutter build apk --release --dart-define-from-file=env.json
```

## Checklist de endurecimento

- `.gitignore` ignora `env.json`, `google-services.json`, `GoogleService-Info.plist`.
- Validar que nenhum token aparece hardcoded no repositório.
- Usar `--dart-define` local/CI e evitar subir `env.json`.
- Rotacionar chaves se algo tiver vazado historicamente.

## Passos de teste

1) Rodar sem arquivo local (apenas `--dart-define`):

```bash
flutter run --dart-define=GEMINI_API_KEY=dummy_key
```

Resultado esperado: app inicia; recursos que exigem Gemini usam a chave fornecida via define.

2) Rodar com arquivo local (substituição por arquivo):

```bash
cat > env.json <<'JSON'
{ "GEMINI_API_KEY": "dummy_key_file" }
JSON
flutter run --dart-define-from-file=env.json
```

Resultado esperado: app inicia; `GeminiService` encontra a chave via arquivo. Remova `env.json` ao final (está no `.gitignore`).

