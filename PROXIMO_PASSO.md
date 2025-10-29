# ⚠️ PRÓXIMO PASSO CRÍTICO - Configure a Senha do Keystore

## ✅ O que foi concluído:

### 1. Renomeação Completa para NUTRIZ
- [x] Nome do app: `nutriz`
- [x] Package: `com.nutriz.app`
- [x] Namespace: `com.nutriz.app`
- [x] Label Android: `NUTRIZ`
- [x] Imports corrigidos: 105 arquivos atualizados de `package:nutritracker/` para `package:nutriz/`
- [x] Compilação sem erros: **0 erros** ✅

### 2. Keystore e Assinatura
- [x] Keystore criado: `android/upload-keystore.jks`
- [x] Build.gradle configurado com signing
- [x] Arquivo `android/key.properties` criado

### 3. Documentação
- [x] Privacy Policy atualizada
- [x] Plano de Publicação atualizado
- [x] Resumo da renomeação criado

---

## 🔴 AÇÃO NECESSÁRIA AGORA (5 MINUTOS)

### Passo 1: Edite o arquivo `key.properties`

**Abra o arquivo:**
```
c:\Users\alext\Downloads\nutritracker\nutritracker\android\key.properties
```

**Conteúdo atual:**
```properties
storePassword=PLACEHOLDER_PASSWORD
keyPassword=PLACEHOLDER_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**Altere para:**
```properties
storePassword=SUA_SENHA_DO_KEYSTORE
keyPassword=SUA_SENHA_DO_KEYSTORE
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ IMPORTANTE**: Use a MESMA senha que você digitou quando executou o comando `keytool` para criar o keystore.

---

## 🚀 Após Configurar a Senha

### Teste o Build de Release

Execute este comando:

```bash
cd c:\Users\alext\Downloads\nutritracker\nutritracker
flutter build appbundle --release
```

**O que esperar:**
- Compilação levará ~2-5 minutos
- Você deve ver: `✓ Built build\app\outputs\bundle\release\app-release.aab`
- Tamanho esperado: ~30-50 MB

**Se der erro de senha:**
- Verifique se a senha em `key.properties` está correta
- Confirme que é a mesma senha usada ao criar o keystore

---

## 📋 Próximos Passos Após o Build

### 1. Hospedar Privacy Policy (1 hora)
- Use o arquivo `PRIVACY_POLICY_TEMPLATE.md`
- Opções gratuitas:
  - GitHub Pages
  - Google Sites
  - Vercel

### 2. Tirar Screenshots (2-3 horas)
- 6-8 screenshots em 1080x1920
- Dashboard, IA detecção, Jejum, Receitas, etc.

### 3. Criar Conta Google Play Developer
- Custo: $25 USD (único, vitalício)
- Tempo de ativação: ~48 horas

### 4. Submeter à Play Store
- Seguir checklist em `PLANO_PUBLICACAO_PLAY_STORE.md`

---

## 📊 Status Atual

| Item | Status |
|------|--------|
| Nome do app | ✅ NUTRIZ |
| Package renomeado | ✅ com.nutriz.app |
| Compilação | ✅ 0 erros |
| Keystore | ✅ Criado |
| Signing Config | ⚠️ Aguardando senha |
| Build Release | ⏳ Próximo passo |
| Privacy Policy | ✅ Escrita (aguardando hospedagem) |
| Screenshots | ⏳ Pendente |
| Google Play Console | ⏳ Pendente |

**Progresso**: 🟢 93%

---

## 🎯 Resumo

**Você está a 3 passos da Play Store:**
1. ⚠️ Configure a senha no `key.properties` (5 minutos)
2. 🚀 Gere o build release (2-5 minutos)
3. 📸 Tire screenshots e publique (4-6 horas)

---

**Data**: 2025-10-24
**App**: NUTRIZ
**Versão**: 1.1.0+2
