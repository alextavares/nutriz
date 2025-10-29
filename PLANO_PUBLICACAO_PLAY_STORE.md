# 🚀 PLANO DE PUBLICAÇÃO - NUTRIZ na Google Play Store

**Nome do App**: NUTRIZ (anteriormente NutriTracker)
**Package**: com.nutriz.app
**Status Geral**: ~92% pronto para publicação
**Tempo estimado até publicação**: 1-3 dias (4-6h trabalho + 1-3 dias revisão Google)
**Data deste relatório**: 2025-10-24

---

## ✅ O QUE JÁ ESTÁ PRONTO (85-90%)

### 1. ✅ Internacionalização (i18n) - 95% COMPLETO

**Completamente Internacionalizadas:**
- ✅ Dashboard (100%)
- ✅ Tela de Jejum Intermitente (100%)
- ✅ Receitas (100%)
- ✅ Onboarding (100%)
- ✅ Login/Registro (100%)
- ✅ Exercícios (seções principais)
- ✅ Coach IA (principais strings)
- ✅ Splash Screen (100%)
- ✅ Progresso Semanal (100%)

**Total**: 357 chaves de tradução (PT/EN)

**Pendente (não crítico):**
- 🔶 Profile Screen - ~154 strings hardcoded
  - Prioridade: MÉDIA (não impede publicação)

### 2. ✅ Código e Arquitetura - ESTÁVEL

- ✅ Compilando sem erros
- ✅ Estrutura organizada
- ✅ Design system completo
- ✅ Responsive design
- ⚠️ 415 warnings (maioria em arquivos backup - limpar antes do release)

### 3. ✅ Funcionalidades Core - COMPLETAS

- ✅ Tracking diário de refeições
- ✅ Detecção de alimentos com IA (câmera)
- ✅ Jejum intermitente completo
- ✅ Receitas com busca e filtros
- ✅ Metas e objetivos personalizados
- ✅ Progresso semanal e estatísticas
- ✅ Gamificação (badges, streaks)
- ✅ Notificações (hidratação, jejum)
- ✅ Valores corporais (peso, gordura)
- ✅ Exercícios e atividades
- ✅ Assinatura PRO (RevenueCat)

### 4. ✅ Configuração Android - COMPLETO

- ✅ `applicationId`: com.nutriz.app (ATUALIZADO)
- ✅ `namespace`: com.nutriz.app (ATUALIZADO)
- ✅ `label`: NUTRIZ (ATUALIZADO)
- ✅ `compileSdk`: 36 (Android 15)
- ✅ `targetSdk`: 36
- ✅ `versionCode`: 2
- ✅ `versionName`: 1.1.0
- ✅ Ícone do app
- ✅ Permissões configuradas
- ✅ MultiDex habilitado
- ✅ Assinatura configurada (aguardando senha)

---

## 🔴 BLOQUEADORES CRÍTICOS (FAZER PRIMEIRO)

### 1. ✅ KEYSTORE E ASSINATURA DO APP

**Status**: ✅ COMPLETO (aguardando senha)
**Prioridade**: CRÍTICA
**Tempo**: 30 minutos → 5 minutos restantes

**O que foi feito:**

✅ Keystore criado: `android/upload-keystore.jks`
✅ Arquivo `android/key.properties` criado
✅ `android/app/build.gradle` configurado com signing
✅ `.gitignore` protegendo arquivos sensíveis

**⚠️ PRÓXIMO PASSO (5 minutos)**:

1. Abra o arquivo `android/key.properties`
2. Substitua `PLACEHOLDER_PASSWORD` pela senha que você usou ao criar o keystore
3. Salve o arquivo

**Importante:**
- ✅ Keystore já protegido no .gitignore
- ⚠️ Faça backup seguro do keystore (Google Drive criptografado)
- ⚠️ Se perder o keystore, nunca mais pode atualizar o app!

### 2. 🔴 POLÍTICA DE PRIVACIDADE

**Status**: FALTANDO
**Prioridade**: CRÍTICA
**Tempo**: 1-2 horas

**Opção 1 - Hospedar no GitHub Pages (GRÁTIS):**

```bash
# 1. Criar arquivo privacy-policy.md no repo
# 2. Ativar GitHub Pages nas settings
# 3. URL será: https://SEUUSUARIO.github.io/nutritracker/privacy-policy
```

**Opção 2 - Google Sites (GRÁTIS):**
- Criar site em sites.google.com
- Publicar política de privacidade
- Obter URL pública

**Template incluído em**: `PRIVACY_POLICY_TEMPLATE.md`

### 3. 🔴 LIMPEZA PRÉ-RELEASE

**Status**: PENDENTE
**Prioridade**: ALTA
**Tempo**: 30 minutos

```bash
# Remover arquivos backup
find lib -name "* - Copia.dart" -delete
find lib -name "*_backup_*.dart" -delete

# Limpar build anterior
flutter clean
flutter pub get

# Testar build release
flutter build appbundle --release

# Verificar tamanho (deve ser <100MB)
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

## 🟡 PREPARAÇÃO DA LOJA (3-4 HORAS)

### 1. Screenshots (6-8 imagens)

**Resolução recomendada**: 1080x1920 (9:16)

**Screenshots obrigatórios:**
1. Dashboard principal mostrando tracking de refeições
2. Detecção de alimentos com IA (câmera)
3. Jejum intermitente (timer ativo)
4. Receitas com filtros
5. Progresso semanal/gráficos
6. Gamificação (badges/streaks)
7. Metas personalizadas
8. Interface de exercícios

**Ferramentas sugeridas:**
- Emulador Android com tela grande
- Captura de tela nativa do Android
- Ou: Device Frame Generator online

### 2. Assets Gráficos

**Feature Graphic**: 1024x500px
- Banner principal da loja
- Mostrar logo + slogan
- Design atraente e profissional

**App Icon High-res**: 512x512px
- Versão alta resolução do ícone
- Sem transparência
- PNG 32-bit

**Promo Video** (opcional):
- YouTube link
- 30-120 segundos
- Demonstração das features principais

### 3. Textos da Loja

#### Título do App (até 50 caracteres):
```
NUTRIZ - Nutrição e Jejum com IA
```

#### Descrição Curta (até 80 caracteres):
```
Nutrição inteligente, jejum intermitente e tracking com IA. Alcance suas metas!
```

#### Descrição Completa (até 4000 caracteres):

```markdown
🥗 RASTREAMENTO INTELIGENTE DE NUTRIÇÃO

NUTRIZ é seu assistente pessoal de nutrição com inteligência artificial.
Rastreie calorias, macronutrientes, jejum intermitente e alcance suas metas
de saúde de forma simples e eficaz!

📸 DETECÇÃO DE ALIMENTOS COM IA
• Tire foto da sua refeição e detecte automaticamente os alimentos
• Informação nutricional precisa em segundos
• Suporte para milhares de alimentos brasileiros

⏱️ JEJUM INTERMITENTE COMPLETO
• Métodos 16:8, 18:6, 20:4 e personalizado
• Timer visual e notificações inteligentes
• Histórico semanal de jejuns
• Conquistas e streaks de motivação

🎯 METAS PERSONALIZADAS
• Configure calorias e macros ideais
• Objetivos: perder, manter ou ganhar peso
• Acompanhamento de progresso diário
• Gráficos semanais detalhados

🏆 GAMIFICAÇÃO E MOTIVAÇÃO
• Sistema de badges e conquistas
• Streaks diários de consistência
• Marcos de progresso
• Celebrações visuais

👨‍🍳 RECEITAS SAUDÁVEIS
• Biblioteca com receitas nutritivas
• Filtros por tipo de dieta e calorias
• Macros calculados automaticamente
• Favoritos e planejamento de refeições

📊 ANÁLISES COMPLETAS
• Progresso semanal detalhado
• Gráficos de macronutrientes
• Histórico de peso e medidas
• Exportação de dados CSV

💧 HIDRATAÇÃO
• Rastreamento de água diária
• Lembretes personalizados
• Meta automática baseada no peso

🏃 EXERCÍCIOS
• Registro de atividades físicas
• Calorias queimadas
• Integração com metas diárias

✨ RECURSOS PRO
• Planos de refeições personalizados
• Scanner de código de barras
• Insights avançados com IA
• Receitas exclusivas PRO
• Sem anúncios

🌍 SUPORTE MULTILÍNGUE
• Português (Brasil)
• English

📱 CARACTERÍSTICAS
• Interface moderna e intuitiva
• Design responsivo
• Modo escuro (em breve)
• Sincronização automática
• Privacidade e segurança dos dados

Comece hoje sua jornada para uma vida mais saudável com NUTRIZ!

🆓 Download grátis com recursos premium disponíveis.
```

#### Categoria:
- **Principal**: Saúde e fitness
- **Subcategoria**: Alimentação e dieta

#### Tags:
```
nutrição, dieta, calorias, macros, jejum intermitente, fitness, saúde,
perder peso, ganhar peso, IA, receitas, tracking, app brasileiro
```

---

## 📋 CHECKLIST COMPLETO

### Fase 1: Preparação Técnica ⏱️ 2-3 horas

- [ ] **Criar keystore**
  - [ ] Executar comando keytool
  - [ ] Criar key.properties
  - [ ] Atualizar build.gradle
  - [ ] Fazer backup seguro do keystore

- [ ] **Limpar warnings**
  - [ ] Deletar arquivos backup
  - [ ] Remover imports não usados
  - [ ] Executar flutter clean

- [ ] **Build de teste**
  - [ ] flutter build appbundle --release
  - [ ] Verificar tamanho do AAB
  - [ ] Testar instalação em dispositivo real

### Fase 2: Documentação Legal ⏱️ 1-2 horas

- [ ] **Política de Privacidade**
  - [ ] Escrever política baseada no template
  - [ ] Hospedar em GitHub Pages ou Google Sites
  - [ ] Obter URL pública
  - [ ] Testar acesso à URL

- [ ] **Termos de Uso** (opcional mas recomendado)
  - [ ] Escrever termos baseados no template
  - [ ] Hospedar junto com privacy policy

### Fase 3: Assets da Loja ⏱️ 3-4 horas

- [ ] **Screenshots**
  - [ ] Tirar 8 screenshots (1080x1920)
  - [ ] Dashboard
  - [ ] IA detecção de alimentos
  - [ ] Jejum intermitente
  - [ ] Receitas
  - [ ] Progresso semanal
  - [ ] Gamificação
  - [ ] Metas
  - [ ] Exercícios

- [ ] **Gráficos**
  - [ ] Feature graphic 1024x500
  - [ ] App icon 512x512
  - [ ] (Opcional) Promo video

- [ ] **Textos**
  - [ ] Título do app
  - [ ] Descrição curta
  - [ ] Descrição completa
  - [ ] Notas de versão

### Fase 4: Google Play Console ⏱️ 1-2 horas

- [ ] **Configuração inicial**
  - [ ] Criar conta Developer ($25 USD)
  - [ ] Criar novo app
  - [ ] Selecionar categoria

- [ ] **Upload do app**
  - [ ] Fazer upload do AAB
  - [ ] Configurar versão
  - [ ] Adicionar notas de release

- [ ] **Store listing**
  - [ ] Preencher todos os textos
  - [ ] Upload de screenshots
  - [ ] Upload de feature graphic
  - [ ] Upload de app icon

- [ ] **Classificação de conteúdo**
  - [ ] Preencher questionário
  - [ ] Obter classificação

- [ ] **Preço e distribuição**
  - [ ] Definir como gratuito
  - [ ] Selecionar países
  - [ ] Aceitar termos

- [ ] **Privacidade**
  - [ ] Adicionar URL da privacy policy
  - [ ] Declarar coleta de dados
  - [ ] Configurar políticas de dados

### Fase 5: Revisão e Publicação ⏱️ 1-3 dias

- [ ] **Teste interno** (recomendado)
  - [ ] Criar faixa de teste interno
  - [ ] Convidar 5-10 testadores
  - [ ] Coletar feedback
  - [ ] Corrigir bugs encontrados

- [ ] **Submissão para produção**
  - [ ] Revisar todas as informações
  - [ ] Submeter para revisão
  - [ ] Aguardar aprovação (1-3 dias)

- [ ] **Pós-aprovação**
  - [ ] Publicar na Play Store
  - [ ] Compartilhar link
  - [ ] Monitorar reviews
  - [ ] Responder feedback

---

## 💰 CUSTOS

- **Google Play Developer Account**: $25 USD (pagamento único, vitalício)
- **Hospedagem Privacy Policy**: GRÁTIS (GitHub Pages)
- **Domínio próprio** (opcional): ~$10-15/ano
- **Total mínimo**: $25 USD

---

## 🎯 PRIORIZAÇÃO

### 🔴 FAZER AGORA (Bloqueadores):
1. Criar keystore e configurar signing
2. Escrever e hospedar privacy policy
3. Fazer build release de teste

### 🟡 FAZER EM SEGUIDA (Importante):
4. Tirar screenshots
5. Criar feature graphic
6. Escrever descrições da loja
7. Criar conta Google Play Developer

### 🟢 FAZER DEPOIS (Opcional):
8. Completar i18n do Profile Screen
9. Adicionar analytics
10. Configurar crash reporting
11. Criar promo video
12. Teste A/B de store listing

---

## 📱 PRIMEIROS PASSOS

Execute na ordem:

```bash
# 1. Criar keystore
cd android/app
keytool -genkey -v -keystore ../upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Anotar as senhas em local seguro!

# 3. Criar key.properties
cd ..
cat > key.properties << EOF
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=upload
storeFile=upload-keystore.jks
EOF

# 4. Adicionar ao .gitignore
echo "key.properties" >> .gitignore
echo "*.jks" >> .gitignore

# 5. Testar build
cd ..
flutter clean
flutter pub get
flutter build appbundle --release

# 6. Verificar resultado
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

## 🔗 LINKS ÚTEIS

- **Google Play Console**: https://play.google.com/console
- **Keystore Guide**: https://developer.android.com/studio/publish/app-signing
- **Privacy Policy Generator**: https://www.privacypolicygenerator.info/
- **Screenshot Guidelines**: https://developer.android.com/distribute/marketing-tools/device-art-generator
- **Store Listing Best Practices**: https://developer.android.com/distribute/best-practices/launch

---

## 📞 SUPORTE

Para dúvidas sobre:
- Configuração técnica → Consultar documentação Flutter
- Play Store → https://support.google.com/googleplay/android-developer
- RevenueCat (pagamentos) → https://docs.revenuecat.com

---

**Última atualização**: 2025-10-24
**Versão do documento**: 1.1
**Status**: App renomeado para NUTRIZ e 92% pronto para publicação
