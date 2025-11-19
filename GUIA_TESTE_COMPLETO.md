# 🧪 Guia de Teste Completo - NutriTracker Early Access

**Data:** 12 de Janeiro de 2025
**Versão:** 1.0.0 (Early Access)
**Status do App:** ✅ Rodando no emulador

---

## 📊 Status de Lançamento

O app está **FUNCIONANDO** e pronto para testes finais antes da publicação! 🚀

**Avisos Normais (Podem Ignorar):**
- ⚠️ RevenueCat errors (subscriptions) - Normal para desenvolvimento
- ⚠️ Health plugin ClassCastException - Normal, não afeta funcionalidade principal
- ⚠️ Network errors para api.revenuecat.com - Normal sem internet no emulador

**O Importante:**
- ✅ App compilou sem erros
- ✅ App abriu sem crashes
- ✅ Login screen carregou
- ✅ Auto-login funcionou (DEV: auto-login ativo)

---

## 🎯 DIA 1: CHECKLIST DE TESTE FUNCIONAL

### 1️⃣ **Teste de Login/Logout**

#### **Login com Credenciais Demo:**
- [ ] Abra o app no emulador
- [ ] Se já estiver logado, faça logout primeiro
- [ ] Digite: `demo@nutritracker.com`
- [ ] Digite senha: `demo123`
- [ ] Clique em "Login"
- [ ] **ESPERADO:** Login bem-sucedido, vai para Dashboard

#### **Logout Melhorado:**
- [ ] No Dashboard, toque no ícone de perfil (canto superior direito)
- [ ] Desça até "Logout Account"
- [ ] Toque em "Logout"
- [ ] **ESPERADO:** Dialog simples com Cancel/Logout (SEM digitar "SAIR")
- [ ] Confirme o logout
- [ ] **ESPERADO:** Volta para tela de login

#### **Login Social (Google):**
- [ ] Na tela de login, toque em "Continue with Google"
- [ ] **ESPERADO:** Login imediato (mockado, sem autorização real)
- [ ] **ESPERADO:** Vai para Dashboard
- [ ] **NOTA:** É assim mesmo! Login social é mockado para Early Access

---

### 2️⃣ **Teste do Dashboard Principal**

#### **Verificar Anel de Calorias:**
- [ ] No Dashboard, observe o anel grande no topo
- [ ] **ESPERADO:** Mostra "0 / 2000 kcal" (ou sua meta personalizada)
- [ ] **ESPERADO:** Anel deve estar vazio (sem progresso)

#### **Verificar Cards de Macros:**
- [ ] Abaixo do anel, veja 3 cards: Carbs, Proteínas, Gorduras
- [ ] **ESPERADO:** Todos mostram "0g / Xg" (meta padrão)
- [ ] **ESPERADO:** Barra de progresso vazia

#### **Verificar Seção "Nutrition":**
- [ ] Desça até a seção "Nutrition"
- [ ] **ESPERADO:** 4 refeições listadas:
  - ☕ Café da manhã (marrom)
  - 📋 Almoço (laranja)
  - 🍽️ Jantar (vermelho)
  - 🥐 Lanches (dourado)
- [ ] **ESPERADO:** Cada refeição mostra "0 / 0 kcal"
- [ ] **ESPERADO:** Botão "+" à direita de cada refeição

---

### 3️⃣ **Teste de Adicionar Comida MANUALMENTE**

#### **Adicionar no Café da Manhã:**
- [ ] Toque no botão "+" ao lado de "Café da manhã"
- [ ] Toque em "Add Manually" (ou "Adicionar Manualmente")
- [ ] Digite o nome: `Pão francês`
- [ ] Digite calorias: `150`
- [ ] Digite carboidratos: `30`
- [ ] Digite proteínas: `5`
- [ ] Digite gorduras: `2`
- [ ] Toque em "Save" ou "Salvar"
- [ ] **ESPERADO:** Volta para Dashboard
- [ ] **ESPERADO:** Café da manhã agora mostra "150 / 0 kcal"
- [ ] **ESPERADO:** Anel principal atualiza para "150 / 2000 kcal"
- [ ] **ESPERADO:** Card de Carbs atualiza para "30g / Xg"

#### **Adicionar no Almoço:**
- [ ] Toque no botão "+" ao lado de "Almoço"
- [ ] Adicione manualmente: `Arroz com feijão` - 500 kcal
- [ ] **ESPERADO:** Almoço atualiza, anel atualiza para 650 kcal total

---

### 4️⃣ **Teste de IA - Detecção de Comida por CÂMERA**

#### **Tirar Foto de Comida:**
- [ ] Toque no botão "+" de qualquer refeição
- [ ] Toque em "Take Photo" ou "Tirar Foto"
- [ ] **ESPERADO:** Câmera abre
- [ ] Tire uma foto de algo (pode ser qualquer objeto por enquanto)
- [ ] **ESPERADO:** Foto aparece para confirmação
- [ ] Toque em "Analyze" ou "Analisar"
- [ ] **ESPERADO:** IA tenta detectar comida (pode falhar se não for comida real)
- [ ] **ESPERADO:** Resultados aparecem com estimativas de calorias
- [ ] Toque em "Add" para adicionar

**NOTA:** Se a IA não funcionar no emulador, tudo bem! O importante é que não dê crash.

---

### 5️⃣ **Teste de Registro de PESO**

#### **Adicionar Peso Corporal:**
- [ ] No Dashboard, procure o card "Body Metrics" ou "Métricas Corporais"
- [ ] Toque no botão "+" ou "Add Weight"
- [ ] Digite seu peso: `70` kg
- [ ] Escolha a data (hoje)
- [ ] Toque em "Save"
- [ ] **ESPERADO:** Peso aparece no card
- [ ] **ESPERADO:** Gráfico de progresso atualiza

#### **Adicionar Histórico de Peso:**
- [ ] Adicione mais alguns pesos em datas diferentes
- [ ] **ESPERADO:** Gráfico mostra linha de tendência

---

### 6️⃣ **Teste de Registro de ÁGUA**

#### **Adicionar Água:**
- [ ] No Dashboard, procure o card "Water Tracker" ou "Hidratação"
- [ ] **ESPERADO:** Mostra "0 ml / 2000 ml" (ou meta personalizada)
- [ ] Toque no botão de copo para adicionar água
- [ ] Adicione 250ml (um copo)
- [ ] **ESPERADO:** Total atualiza para "250 ml / 2000 ml"
- [ ] **ESPERADO:** Barra de progresso preenche

#### **Adicionar Mais Água:**
- [ ] Continue adicionando até atingir a meta
- [ ] **ESPERADO:** Ao atingir 100%, possível celebração ou badge

---

### 7️⃣ **Teste de JEJUM INTERMITENTE** (Opcional)

#### **Iniciar Jejum:**
- [ ] Procure a seção de "Fasting" ou "Jejum"
- [ ] Toque em "Start Fast" ou "Iniciar Jejum"
- [ ] Escolha o método (16:8, 18:6, etc.)
- [ ] **ESPERADO:** Timer de jejum inicia
- [ ] **ESPERADO:** Mostra tempo restante

#### **Finalizar Jejum:**
- [ ] Toque em "End Fast" ou "Finalizar Jejum"
- [ ] **ESPERADO:** Jejum é registrado no histórico

---

### 8️⃣ **Teste de NAVEGAÇÃO entre Telas**

#### **Verificar Todas as Telas:**
- [ ] **Dashboard:** Tela principal ✅
- [ ] **Profile:** Toque no ícone de perfil
  - [ ] **ESPERADO:** Mostra configurações, logout, etc.
- [ ] **Activity:** Toque na aba "Activity" (se houver)
  - [ ] **ESPERADO:** Mostra atividades físicas
- [ ] **Progress:** Toque na aba "Progress" (se houver)
  - [ ] **ESPERADO:** Mostra gráficos de progresso
- [ ] **Calendar:** Toque no calendário no topo
  - [ ] **ESPERADO:** Permite mudar de data
  - [ ] Escolha ontem
  - [ ] **ESPERADO:** Dashboard atualiza para dados de ontem

#### **Voltar para Hoje:**
- [ ] No calendário, toque em "Today" ou "Hoje"
- [ ] **ESPERADO:** Dashboard volta para dados de hoje

---

### 9️⃣ **Teste de PERSISTÊNCIA de Dados**

#### **Verificar Dados Salvos:**
- [ ] Adicione algumas comidas, água, peso
- [ ] **MATE O APP** (force close no emulador)
- [ ] Reabra o app
- [ ] **ESPERADO:** Login automático (se configurado)
- [ ] **ESPERADO:** TODOS os dados ainda estão lá!
- [ ] **ESPERADO:** Anel de calorias, água, peso - tudo persistido

---

### 🔟 **Teste de ERROS e CRASHES**

#### **Testes de Estresse:**
- [ ] Toque RÁPIDO várias vezes no botão "+"
  - [ ] **ESPERADO:** Não trava, não duplica
- [ ] Adicione uma comida com valores MUITO ALTOS (9999 kcal)
  - [ ] **ESPERADO:** Aceita mas avisa se exceder meta
- [ ] Tente adicionar comida sem nome
  - [ ] **ESPERADO:** Mostra erro de validação
- [ ] Navegue entre telas RAPIDAMENTE
  - [ ] **ESPERADO:** Não trava, não dá lag excessivo
- [ ] Rode TODAS as features seguidas (adicionar comida, água, peso, mudar data)
  - [ ] **ESPERADO:** Nenhum crash!

---

## ✅ CHECKLIST FINAL PARA PUBLICAÇÃO

Marque cada item SOMENTE se testou e funcionou 100%:

### **Funcionalidades Core:**
- [ ] Login com credenciais demo funciona
- [ ] Login social (Google) funciona (mockado)
- [ ] Logout melhorado funciona
- [ ] Dashboard carrega corretamente
- [ ] Anel de calorias exibe e atualiza
- [ ] Cards de macros exibem e atualizam
- [ ] Adicionar comida MANUAL funciona
- [ ] Adicionar comida por FOTO funciona (ou falha sem crash)
- [ ] Registrar peso funciona
- [ ] Registrar água funciona
- [ ] Navegação entre telas funciona
- [ ] Calendário (mudar data) funciona
- [ ] Dados persistem após fechar e reabrir
- [ ] Nenhum crash durante uso normal

### **Telas Obrigatórias:**
- [ ] Login screen funciona
- [ ] Dashboard funciona
- [ ] Food logging funciona
- [ ] Profile screen funciona

### **Avisos Aceitáveis (Não bloqueia publicação):**
- ⚠️ RevenueCat errors (normal sem configuração)
- ⚠️ Health plugin errors (normal no emulador)
- ⚠️ IA pode falhar sem internet real (normal)
- ⚠️ Alguns gráficos vazios sem dados históricos (normal)

---

## 🚨 PROBLEMAS BLOQUEANTES (NÃO PUBLIQUE SE HOUVER!)

Se qualquer um desses acontecer, **NÃO PUBLIQUE** até corrigir:

- ❌ App crasha ao abrir
- ❌ App crasha ao fazer login
- ❌ App crasha ao adicionar comida
- ❌ Dados desaparecem ao fechar o app
- ❌ Não consegue fazer logout
- ❌ Navegação entre telas trava
- ❌ Anel de calorias não atualiza NUNCA
- ❌ Botões principais não respondem

---

## 📸 PRÓXIMO PASSO: DIA 2 - SCREENSHOTS

Se TUDO acima funcionou, você está pronto para **DIA 2: Capturar Screenshots!**

### **Como Capturar Screenshots no Emulador:**

1. **Prepare o App com Dados Realistas:**
   - Adicione 3-4 comidas no dia
   - Adicione água até 50%+ da meta
   - Registre peso

2. **Capture 5-8 Telas:**
   - Screenshot 1: Dashboard completo (anel + cards)
   - Screenshot 2: Seção Nutrition com refeições
   - Screenshot 3: Tela de adicionar comida manual
   - Screenshot 4: Tela de detecção por câmera
   - Screenshot 5: Profile screen ou Progress
   - (Opcionais: Body metrics, water tracker close-up)

3. **Formato das Screenshots:**
   - Resolução: 1080x1920 ou maior
   - Formato: PNG ou JPEG
   - Local: Salve na pasta `screenshots/` do projeto

---

## 📊 RELATÓRIO DE TESTE

Após completar TODOS os testes, responda:

### **Tudo Funcionou?**
- [ ] ✅ SIM - Pronto para DIA 2 (screenshots)
- [ ] ❌ NÃO - Liste os problemas abaixo

### **Problemas Encontrados:**
```
1. [Descreva o problema]
2. [Descreva o problema]
3. [Descreva o problema]
```

### **Perguntas ou Dúvidas:**
```
1. [Sua pergunta]
2. [Sua pergunta]
```

---

## 🎉 CONCLUSÃO

Se você chegou até aqui e marcou ✅ em TODOS os itens core, **PARABÉNS!** 🎊

Você tem um **MVP funcional** pronto para Early Access! 🚀

**Próximos passos:**
1. ✅ DIA 1: Testes funcionais (VOCÊ ESTÁ AQUI)
2. ⏭️ DIA 2: Capturar screenshots profissionais
3. ⏭️ DIA 3: Política de privacidade + descrição da loja
4. ⏭️ DIA 4: Build de release assinado (AAB)
5. ⏭️ DIA 5: Upload para Play Console
6. ⏭️ DIA 6-7: Aguardar review do Google
7. ⏭️ DIA 8: **PUBLICADO! 🎉**

---

**Lembre-se:** Apps nunca são perfeitos no lançamento! O importante é que as funcionalidades **principais** funcionem sem crashes. Bugs menores podem ser corrigidos nas próximas versões! 💪

**Boa sorte nos testes!** 🧪✨
