# 💳 Configuração do Sistema de Pagamentos - RevenueCat

Este guia explica como configurar o sistema de assinaturas e pagamentos in-app no NutriTracker usando RevenueCat.

---

## 📋 Índice

1. [Visão Geral](#-visão-geral)
2. [Pré-requisitos](#-pré-requisitos)
3. [Configuração RevenueCat](#-configuração-revenuecat)
4. [Configuração Google Play](#-configuração-google-play-android)
5. [Configuração App Store](#-configuração-app-store-ios)
6. [Configurar API Keys](#-configurar-api-keys)
7. [Testar Pagamentos](#-testar-pagamentos)
8. [Restaurar Compras](#-restaurar-compras)
9. [Troubleshooting](#-troubleshooting)

---

## 🎯 Visão Geral

O NutriTracker usa **RevenueCat** para gerenciar assinaturas e pagamentos in-app. RevenueCat é uma plataforma que simplifica a integração com Google Play Billing e App Store StoreKit.

### Benefícios do RevenueCat:

✅ **Cross-platform**: Suporta iOS e Android com um único código
✅ **Gerenciamento simplificado**: Dashboard web para gerenciar produtos e assinaturas
✅ **Analytics**: Métricas de receita, churn, e MRR (Monthly Recurring Revenue)
✅ **Webhooks**: Notificações de eventos de assinatura
✅ **Plano gratuito**: Até $10k/ano de receita

---

## 📌 Pré-requisitos

Antes de começar, você precisa:

- [ ] Conta no [Google Play Console](https://play.google.com/console) (Android)
- [ ] Conta no [App Store Connect](https://appstoreconnect.apple.com) (iOS)
- [ ] Conta no [RevenueCat](https://www.revenuecat.com) (gratuita)
- [ ] App publicado (ou em teste) nas lojas

---

## 🚀 Configuração RevenueCat

### Passo 1: Criar conta no RevenueCat

1. Acesse [https://www.revenuecat.com](https://www.revenuecat.com)
2. Clique em **"Sign Up"** e crie uma conta gratuita
3. Confirme seu email

### Passo 2: Criar um projeto

1. No dashboard, clique em **"Create new project"**
2. Nome do projeto: `NutriTracker`
3. Clique em **"Create"**

### Passo 3: Configurar Apps

#### Android:

1. Clique em **"Apps"** → **"+ New"**
2. Selecione **"Google Play Store"**
3. **App name**: `NutriTracker Android`
4. **Bundle ID**: `com.nutritracker.app` (deve ser o mesmo do seu `applicationId` no `build.gradle`)
5. Clique em **"Save"**

#### iOS:

1. Clique em **"Apps"** → **"+ New"**
2. Selecione **"Apple App Store"**
3. **App name**: `NutriTracker iOS`
4. **Bundle ID**: `com.nutritracker.app` (deve ser o mesmo do seu Xcode)
5. Clique em **"Save"**

### Passo 4: Criar Entitlements

Entitlements são os recursos premium que o usuário desbloqueia ao assinar.

1. Vá em **"Entitlements"**
2. Clique em **"+ New"**
3. **Identifier**: `pro` (⚠️ IMPORTANTE: use exatamente esse nome!)
4. **Display name**: `NutriTracker PRO`
5. Clique em **"Save"**

### Passo 5: Criar Produtos

Produtos são os planos de assinatura que você vai vender.

1. Vá em **"Products"**
2. Clique em **"+ New"**
3. Configure 3 produtos:

**Produto 1: Anual (Recomendado)**
- **Identifier**: `nutritracker_annual`
- **Type**: `Auto-renewing subscription`
- **Entitlement**: `pro`
- **Duration**: `1 year`

**Produto 2: Trimestral**
- **Identifier**: `nutritracker_3months`
- **Type**: `Auto-renewing subscription`
- **Entitlement**: `pro`
- **Duration**: `3 months`

**Produto 3: Mensal**
- **Identifier**: `nutritracker_monthly`
- **Type**: `Auto-renewing subscription`
- **Entitlement**: `pro`
- **Duration**: `1 month`

### Passo 6: Criar Offerings

Offerings são coleções de produtos que você exibe na UI.

1. Vá em **"Offerings"**
2. Clique em **"+ New"**
3. **Identifier**: `default`
4. **Display name**: `Planos NutriTracker PRO`
5. Adicione os 3 produtos criados acima:
   - Anual → Package type: `Annual`
   - Trimestral → Package type: `Three Month`
   - Mensal → Package type: `Monthly`
6. Marque o plano **Anual** como **"Default package"**
7. Clique em **"Save"**

---

## 🤖 Configuração Google Play (Android)

### Passo 1: Criar produtos no Google Play Console

1. Acesse [Google Play Console](https://play.google.com/console)
2. Selecione seu app
3. Vá em **Monetização** → **Produtos** → **Assinaturas**
4. Clique em **"Criar assinatura"**

Configure 3 assinaturas:

**Assinatura 1: Anual**
- **ID do produto**: `nutritracker_annual` (⚠️ DEVE ser EXATAMENTE igual ao RevenueCat!)
- **Nome**: `NutriTracker PRO - Anual`
- **Descrição**: `Acesso completo por 1 ano`
- **Período de assinatura**: `12 meses`
- **Preço**: `R$ 179,90` (ou ajuste conforme sua estratégia)

**Assinatura 2: Trimestral**
- **ID do produto**: `nutritracker_3months`
- **Nome**: `NutriTracker PRO - 3 meses`
- **Descrição**: `Acesso completo por 3 meses`
- **Período de assinatura**: `3 meses`
- **Preço**: `R$ 89,99`

**Assinatura 3: Mensal**
- **ID do produto**: `nutritracker_monthly`
- **Nome**: `NutriTracker PRO - Mensal`
- **Descrição**: `Acesso completo por 1 mês`
- **Período de assinatura**: `1 mês`
- **Preço**: `R$ 39,90`

### Passo 2: Conectar Google Play ao RevenueCat

1. No Google Play Console, vá em **Configurações** → **Acesso à API**
2. Clique em **"Criar nova conta de serviço"**
3. Siga as instruções para criar uma conta de serviço no Google Cloud
4. Baixe o arquivo JSON da conta de serviço
5. No RevenueCat Dashboard, vá em **Project Settings** → **Integrations** → **Google Play**
6. Faça upload do arquivo JSON
7. Clique em **"Save"**

### Passo 3: Configurar testers

1. No Google Play Console, vá em **Configurações** → **Teste de licença**
2. Adicione emails de teste (seu email e da equipe)
3. Configure respostas de teste: **"Sempre aprovado"**

---

## 🍎 Configuração App Store (iOS)

### Passo 1: Criar produtos no App Store Connect

1. Acesse [App Store Connect](https://appstoreconnect.apple.com)
2. Selecione seu app
3. Vá em **Features** → **In-App Purchases**
4. Clique em **"+" (Criar)**

Configure 3 assinaturas auto-renováveis:

**Assinatura 1: Anual**
- **Reference Name**: `NutriTracker PRO Annual`
- **Product ID**: `nutritracker_annual` (⚠️ DEVE ser EXATAMENTE igual!)
- **Subscription Group**: Crie um grupo chamado `NutriTracker PRO`
- **Subscription Duration**: `1 Year`
- **Price**: `$17.99` (ou equivalente em R$)

**Assinatura 2: Trimestral**
- **Reference Name**: `NutriTracker PRO 3 Months`
- **Product ID**: `nutritracker_3months`
- **Subscription Group**: `NutriTracker PRO`
- **Subscription Duration**: `3 Months`
- **Price**: `$8.99`

**Assinatura 3: Mensal**
- **Reference Name**: `NutriTracker PRO Monthly`
- **Product ID**: `nutritracker_monthly`
- **Subscription Group**: `NutriTracker PRO`
- **Subscription Duration**: `1 Month`
- **Price**: `$3.99`

### Passo 2: Conectar App Store ao RevenueCat

1. No App Store Connect, vá em **Users and Access** → **Keys**
2. Clique em **"+" → "App Store Connect API"**
3. **Name**: `RevenueCat`
4. **Access**: `Admin`
5. Clique em **"Generate"** e baixe o arquivo `.p8`
6. No RevenueCat Dashboard, vá em **Project Settings** → **Integrations** → **Apple App Store**
7. Faça upload do arquivo `.p8`
8. Preencha:
   - **Issuer ID** (encontrado em App Store Connect → Keys)
   - **Key ID** (encontrado na chave criada)
9. Clique em **"Save"**

### Passo 3: Configurar testers

1. No App Store Connect, vá em **TestFlight** → **Sandbox Testers**
2. Clique em **"+"** e adicione emails de teste
3. Use esses emails para testar compras

---

## ✅ Sistema Integrado no App

O sistema de pagamentos **já está integrado e funcionando** no código do NutriTracker:

### 🚀 O que já foi implementado:

1. **Inicialização automática**: O `PurchaseService` é inicializado automaticamente no startup do app
   - Veja: `lib/presentation/splash_screen/widgets/initialization_service.dart` (linha 42)
   - Sincroniza status da assinatura assim que o app abre

2. **Tela de assinatura**: Carrega produtos reais do RevenueCat
   - Veja: `lib/presentation/pro_subscription/pro_subscription_screen.dart`
   - Exibe preços reais das lojas (Google Play / App Store)

3. **Botão "Restaurar Compras"**: Disponível na tela de Perfil
   - Veja: `lib/presentation/profile_screen/profile_screen.dart` (linha 548)
   - Permite que usuários recuperem assinaturas após reinstalar o app

4. **Sincronização contínua**: O app verifica o status da assinatura em tempo real
   - Evita fraudes e acesso indevido
   - Detecta cancelamentos e expirações automaticamente

### 📋 O que você precisa fazer agora:

Apenas configurar as **API Keys** (próxima seção) para conectar com suas contas nas lojas.

---

## 🔑 Configurar API Keys

Agora você precisa adicionar as chaves da API do RevenueCat no código.

### Passo 1: Obter as API Keys

1. No RevenueCat Dashboard, vá em **Project Settings** → **API Keys**
2. Copie as chaves:
   - **Android**: `rcb_...`
   - **iOS**: `rcb_...`

### Passo 2: Adicionar no código

Abra o arquivo `lib/services/purchase_service.dart` e substitua as chaves:

```dart
class PurchaseService {
  static const String _revenueCatApiKeyAndroid = 'rcb_XXXXXXXXXXXXXXXXXXX'; // ← Cole aqui
  static const String _revenueCatApiKeyIos = 'rcb_XXXXXXXXXXXXXXXXXXX';     // ← Cole aqui
```

⚠️ **IMPORTANTE**:
- **NÃO** comite essas chaves em repositórios públicos!
- Para produção, use variáveis de ambiente ou arquivos de configuração privados
- Considere usar `flutter_dotenv` ou similar

---

## 🧪 Testar Pagamentos

### Android (Google Play)

1. Adicione seu email em **Google Play Console** → **Teste de licença**
2. Instale o app via **Internal Testing** ou **Closed Testing**
3. Faça login com o email de teste
4. Tente fazer uma compra - ela será aprovada automaticamente
5. Verifique no RevenueCat Dashboard se a transação apareceu

### iOS (App Store)

1. Crie um Sandbox Tester em **App Store Connect**
2. No iPhone/Simulator, vá em **Configurações** → **App Store** → **Sandbox Account**
3. Faça login com o email do Sandbox Tester
4. Instale o app via TestFlight
5. Tente fazer uma compra
6. Verifique no RevenueCat Dashboard

### Modo de Desenvolvimento

O código atual tem um sistema de "mock" para desenvolvimento local:

```dart
// Se não conseguir conectar com RevenueCat, você pode usar o mock temporariamente
await UserPreferences.setPremiumStatus(true); // Ativa premium localmente
```

---

## 🔄 Restaurar Compras

O botão "Restaurar Compras" **já está implementado e funcionando** na tela de Perfil.

### 📍 Localização:

- **Arquivo**: `lib/presentation/profile_screen/profile_screen.dart` (linha 548)
- **Onde aparece**: No banner PRO (quando o usuário já é assinante)
- **Aparência**: Botão outlined neutral com ícone de restore

### Como funciona:

1. Usuário clica em "Restaurar Compras"
2. App mostra loading indicator
3. App chama `PurchaseService.restorePurchases()`
4. RevenueCat consulta Google Play / App Store
5. Se houver assinatura ativa:
   - ✅ Status é restaurado localmente
   - ✅ Mostra mensagem de sucesso (verde)
   - ✅ Recarrega perfil com status PRO
6. Se NÃO houver assinatura:
   - ℹ️ Mostra mensagem "Nenhuma assinatura ativa encontrada" (azul)

### Quando usar:

- Após reinstalar o app
- Ao trocar de dispositivo
- Se o status PRO foi perdido por algum erro de sincronização

### Testar:

1. Faça uma compra de teste
2. Desinstale e reinstale o app
3. Faça login novamente
4. Vá para Perfil
5. Clique em "Restaurar Compras"
6. O status PRO deve ser restaurado automaticamente

---

## 🐛 Troubleshooting

### Problema: "No offerings available"

**Causa**: RevenueCat não conseguiu carregar os produtos
**Solução**:
1. Verifique se os produtos foram criados no Google Play/App Store
2. Confirme que os IDs dos produtos são exatamente iguais
3. Aguarde até 24h para sincronização inicial
4. Verifique as API Keys no código

### Problema: "Product not found"

**Causa**: IDs dos produtos não coincidem
**Solução**:
1. Compare os IDs no RevenueCat, Google Play e App Store
2. Eles devem ser EXATAMENTE iguais (case-sensitive)

### Problema: "Purchase cancelled"

**Causa**: Usuário cancelou ou falha no pagamento
**Solução**:
- Se for teste: verifique se está usando conta de teste
- Se for produção: verifique método de pagamento

### Problema: Assinatura não sincroniza

**Causa**: Conexão com RevenueCat falhou
**Solução**:
```dart
await PurchaseService.syncSubscriptionStatus(); // Forçar sincronização
```

### Logs úteis:

No Android Studio / Xcode, procure por:
- `✅ PurchaseService initialized`
- `❌ Purchase error:` (erros)
- `ℹ️ Subscription expired` (expirações)

---

## 📊 Analytics e Monitoramento

### RevenueCat Dashboard

Acesse [https://app.revenuecat.com](https://app.revenuecat.com) para ver:

- **Overview**: MRR, receita total, churn
- **Customers**: Lista de assinantes
- **Charts**: Gráficos de crescimento
- **Events**: Log de transações

### Métricas importantes:

- **MRR** (Monthly Recurring Revenue): Receita mensal recorrente
- **Churn**: Taxa de cancelamento
- **LTV** (Lifetime Value): Valor vitalício do cliente

---

## 🎉 Conclusão

Após seguir todos os passos, você terá:

✅ Sistema de pagamentos real funcionando
✅ Assinaturas gerenciadas pelo RevenueCat
✅ Suporte para Android e iOS
✅ Restauração de compras
✅ Analytics de receita

### Próximos passos:

1. Configurar webhooks para eventos (opcional)
2. Implementar ofertas promocionais
3. Adicionar trials gratuitos
4. Configurar push notifications para assinantes

---

## 📚 Recursos Adicionais

- [Documentação RevenueCat](https://docs.revenuecat.com)
- [Flutter SDK Guide](https://docs.revenuecat.com/docs/flutter)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [App Store StoreKit](https://developer.apple.com/storekit/)

---

**Desenvolvido para NutriTracker** 🥗
Última atualização: 2025-01-15
