# 🏛️ Slots Avançados (Named Slots)

O BlaiseVue 2.0 introduz o suporte a **Slots Nomeados**, permitindo que você defina múltiplos pontos de inserção de conteúdo em um único componente.

## O que são Slots?
Imagine um componente de "Layout" ou "Card". Você quer que a estrutura seja a mesma, mas o título, o corpo e o rodapé mudem dependendo de onde ele é usado. Os slots permitem "abrir buracos" no componente filho que o pai preenche.

### 1. Definindo Slots no Filho
No seu arquivo `.bv`, use a tag `<slot>` (ou `<b-slot>`):

```html
<!-- Card.bv -->
<template>
  <div class="card">
    <div class="header">
       <slot name="header">Título Padrão (Fallback)</slot>
    </div>
    <div class="body">
       <slot></slot> <!-- Slot Padrão (sem nome) -->
    </div>
    <div class="footer">
       <slot name="footer"></slot>
    </div>
  </div>
</template>
```

### 2. Preenchendo Slots no Pai
Ao usar o componente, utilize a tag `<template slot="nome">` para direcionar o conteúdo:

```html
<card>
  <!-- Conteúdo para o slot "header" -->
  <template slot="header">
    <h3>Minha Viagem ✈️</h3>
  </template>

  <!-- Conteúdo sem slot vai para o slot padrão -->
  <p>Fotos da viagem para a França.</p>

  <!-- Conteúdo para o slot "footer" -->
  <template slot="footer">
    <button>Compartilhar</button>
  </template>
</card>
```

## Benefícios
- **Composição de Componentes**: Crie componentes layouts genéricos e reutilizáveis.
- **Isolamento de Estilo**: O CSS do componente filho gerencia a moldura, enquanto o pai gerencia o conteúdo.
- **Contexto de Dados**: O conteúdo injetado no slot **mantém o acesso aos métodos e dados do pai**, permitindo interações complexas de forma natural.
