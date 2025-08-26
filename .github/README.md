# GitHub Actions Workflows

Este repositório possui workflows automatizados para CI/CD do projeto Flutter NutriTracker.

## Workflows Disponíveis

### 1. Flutter (`flutter.yml`) - RECOMENDADO
**Executado em:** Push, Pull Request, Manual
**Objetivo:** Pipeline completo e simples do Flutter

**Funcionalidades:**
- ✅ Testes em Ubuntu (rápido)
- ✅ Análise de código estático
- ✅ Testes com cobertura
- ✅ Testes específicos de jejum e banner
- ✅ Relatório HTML de cobertura
- ✅ Build APK
- ✅ Upload de artefatos

**Como executar manualmente:**
1. Vá para a aba "Actions" no GitHub
2. Selecione "**Flutter**"
3. Clique em "Run workflow"

### 2. Flutter CI (`ci.yml`)
**Executado em:** Push, Pull Request, Manual
**Objetivo:** CI completo com múltiplas plataformas

**Funcionalidades:**
- ✅ Testes em Ubuntu, macOS e Windows
- ✅ Análise de código
- ✅ Testes com cobertura
- ✅ Testes específicos
- ✅ Build APK
- ✅ Opções manuais configuráveis

### 3. Flutter Tests (`flutter-tests.yml`)
**Executado em:** Push, Pull Request, Manual
**Objetivo:** Foco em testes com múltiplas plataformas

**Funcionalidades:**
- ✅ Testes em múltiplas plataformas
- ✅ Análise de código
- ✅ Cobertura completa
- ✅ Testes específicos
- ✅ Integração Codecov
- ✅ Opções manuais avançadas

### 2. Flutter CI (`flutter-ci.yml`)
**Executado em:** Push para main/feature/*, Pull Request
**Objetivo:** Build e análise básica

**Funcionalidades:**
- ✅ Análise de código
- ✅ Testes com cobertura (se existirem)
- ✅ Build APK debug
- ✅ Upload de APK como artefato

### 3. Coverage (`codecov.yml`)
**Executado em:** Push para main/feature/*, Pull Request
**Objetivo:** Upload de cobertura para Codecov

**Funcionalidades:**
- ✅ Upload automático para Codecov
- ✅ Relatórios de cobertura online

### 4. Release (`release.yml`)
**Executado em:** Release criada no GitHub
**Objetivo:** Build e release da aplicação

## Configuração Necessária

### Codecov Token (Opcional)
Para relatórios de cobertura online:

1. Acesse [codecov.io](https://codecov.io)
2. Conecte com sua conta GitHub
3. Configure o repositório
4. Adicione o token como segredo `CODECOV_TOKEN` no GitHub

### Segredos do Repositório
```
CODECOV_TOKEN=your_codecov_token_here
```

## Como Usar

### Desenvolvimento Local
```bash
# Executar testes localmente
flutter test --coverage

# Verificar análise de código
flutter analyze

# Build APK
flutter build apk --debug
```

### GitHub Actions - Como Usar

#### 🚀 Execução Manual (Recomendado)
1. Vá para a aba **"Actions"** no GitHub
2. Selecione **"Flutter"** (o primeiro da lista)
3. Clique em **"Run workflow"**
4. Aguarde a execução completa

#### 🔄 Execução Automática
- **Push**: Todos os workflows são executados automaticamente
- **Pull Request**: Workflows de teste e CI são executados
- **Schedule**: Configurado para executar periodicamente

#### 📊 Ver Resultados
- **Artefatos**: Baixe APK e relatórios de cobertura
- **Logs**: Verifique detalhes de cada step
- **Status**: Monitore progresso em tempo real

## Artefatos Gerados

- `coverage-lcov`: Arquivo de cobertura LCOV
- `coverage-html`: Relatório HTML de cobertura (Ubuntu)
- `app-debug-apk`: APK de debug para teste

## Status dos Workflows

Os workflows estão configurados para:
- ✅ Executar em paralelo em múltiplas plataformas
- ✅ Cancelar execuções anteriores se houver novas
- ✅ Manter artefatos por 7 dias
- ✅ Continuar em caso de falhas não críticas

## Solução de Problemas

### Workflow não aparece como "Flutter" no GitHub Actions
Se você não encontra "Flutter" na lista de workflows:
1. **Atualize a página** do GitHub Actions
2. **Aguarde alguns minutos** para o GitHub processar os novos arquivos
3. **Verifique se os arquivos foram commitados** no repositório
4. **Use "Flutter CI"** como alternativa temporária

### Testes falhando no CI mas passando localmente
- Verifique se todas as dependências estão no `pubspec.yaml`
- Execute `flutter clean && flutter pub get` localmente
- Certifique-se de que os arquivos de teste existem

### Cobertura não sendo gerada
- Certifique-se de que os testes existem na pasta `test/`
- Verifique se os testes estão passando
- Execute `flutter test --coverage` localmente primeiro

### Build falhando
- Execute `flutter doctor` localmente
- Verifique se o Java 17 está configurado corretamente
- Teste o build localmente: `flutter build apk --debug`

### Problemas de Permissões
- Certifique-se de que o repositório tem Actions habilitadas
- Verifique se você tem permissões para executar workflows