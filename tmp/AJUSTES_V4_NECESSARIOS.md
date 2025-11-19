# 🔍 Ajustes Necessários - V4 Atual

**Data:** 2025-01-11
**Status:** Análise de melhorias visuais

---

## 📊 Problemas Identificados na Screenshot

### ❌ **PROBLEMAS VISUAIS:**

#### 1️⃣ **Itens de Refeição com Texto Duplicado/Estranho**
- **Problema:** Cada item mostra texto estranho depois do nome
- Exemplo: "Café da manhã >" seguido de texto incompreensível
- **Causa:** Parece ser o `subtitle` mostrando dados incorretos
- **Solução:** Remover ou ocultar subtitle quando não houver dados válidos

#### 2️⃣ **Altura dos Itens Parece Inadequada**
- **Problema:** Itens parecem "apertados" verticalmente
- Os 70px de altura podem não estar sendo aplicados corretamente
- **Solução:** Verificar se altura está sendo respeitada

#### 3️⃣ **Ícones Parecem Pequenos**
- **Problema:** Ícones ainda parecem pequenos comparado ao YAZIO
- **Solução:** Aumentar ainda mais (de 26px → 28-30px)

#### 4️⃣ **Fundo dos Itens**
- **Problema:** Fundo parece muito claro/transparente
- **Solução:** Ajustar cor do fundo para mais visível

---

## 🎯 Ajustes Propostos

### **AJUSTE 1: Remover Subtitle Problemático**
```dart
// ANTES (V4):
if (item.subtitle != null) ...[
  // Mostra subtitle sempre
]

// DEPOIS (V4.1):
// Remover completamente ou só mostrar se tiver conteúdo válido
// MELHOR: Não mostrar subtitle em layout de 2 linhas
```

### **AJUSTE 2: Garantir Altura Mínima**
```dart
// ANTES:
height: 70,

// DEPOIS:
constraints: BoxConstraints(minHeight: 75),  // Garantir altura mínima
// OU remover height fixo e deixar expandir naturalmente
```

### **AJUSTE 3: Ícones Maiores**
```dart
// ANTES:
radius: 22,
Icon(data, size: 26)

// DEPOIS:
radius: 24,  // +9% maior
Icon(data, size: 28)  // +8% maior
```

### **AJUSTE 4: Cor de Fundo Mais Visível**
```dart
// ANTES:
color: colors.surfaceContainerHigh,

// DEPOIS:
color: colors.surface,  // Branco puro
// OU
color: colors.surfaceContainerHigh.withValues(alpha: 1.0),
```

### **AJUSTE 5: Espaçamento entre Nome e Calorias**
```dart
// ANTES:
SizedBox(height: 4),

// DEPOIS:
SizedBox(height: 6),  // Um pouco mais de espaço
```

---

## 🎨 Layout Proposto (V4.1)

```
┌─────────────────────────────────────┐
│ Nutrition                    More → │
├─────────────────────────────────────┤
│                                     │
│  ⭕  Café da manhã →            ⊕  │ ← SEM subtitle estranho
│       0 / 0 kcal                    │   Mais espaço vertical
│                                     │   Ícones maiores
│  ⭕  Almoço →                   ⊕  │   Fundo mais visível
│       0 / 0 kcal                    │
│                                     │
│  ⭕  Jantar →                   ⊕  │
│       0 / 0 kcal                    │
│                                     │
└─────────────────────────────────────┘
```

---

## ✅ Prioridade de Ajustes

1. 🔴 **URGENTE:** Remover subtitle problemático
2. 🔴 **ALTA:** Ajustar cor de fundo
3. 🟡 **MÉDIA:** Aumentar ícones
4. 🟡 **MÉDIA:** Ajustar espaçamentos
5. 🟢 **BAIXA:** Ajustar altura

---

**Aplicar agora?**
