# 6. Data Binding

O BlaiseVue suporta três formas de data binding:

## 1. Interpolação de Texto `{{ }}`

Exibe o valor de uma variável reativa no HTML.

```html
<template>
  <h1>{{ titulo }}</h1>
  <p>Bem-vindo, {{ nome }}!</p>
</template>

<script>
  data:
    titulo: string = 'Minha App';
    nome: string = 'Usuario';
</script>
```

**Resultado:** O texto é atualizado automaticamente quando o valor muda.

---

## 2. Two-Way Binding `b-model`

Liga um input ao dado reativo em duas direções:
- **Input → Dado:** Quando o usuário digita, o dado atualiza
- **Dado → Input:** Quando o dado muda por código, o input atualiza

```html
<template>
  <input type="text" b-model="nome">
  <p>Voce digitou: {{ nome }}</p>
</template>

<script>
  data:
    nome: string = '';
</script>
```

**Funciona com:** `<input>`, `<textarea>`, `<select>`

### Exemplo Prático

```html
<template>
  <div>
    <label>Nome:</label>
    <input type="text" b-model="nome">

    <label>Email:</label>
    <input type="text" b-model="email">

    <h3>Resumo:</h3>
    <p>Nome: {{ nome }}</p>
    <p>Email: {{ email }}</p>
  </div>
</template>

<script>
  data:
    nome: string = '';
    email: string = '';
</script>
```

---

## 3. One-Way Attribute Binding `:attr` ou `b-bind:attr`

Liga um atributo HTML a um dado reativo (somente leitura).

```html
<template>
  <a :href="link">Visitar</a>
  <div :class="classeAtiva">Conteudo</div>
  <img :src="imagemUrl">
</template>

<script>
  data:
    link: string = 'https://example.com';
    classeAtiva: string = 'destaque';
    imagemUrl: string = 'foto.png';
</script>
```

**Sintaxe curta:** `:href="campo"` (equivale a `b-bind:href="campo"`)

---

## Comparação de Bindings

| Tipo | Diretiva | Direção | Uso |
|------|----------|---------|-----|
| Interpolação | `{{ }}` | Dado → DOM | Exibir textos |
| Two-Way | `b-model` | Dado ↔ DOM | Inputs/forms |
| One-Way | `:attr` | Dado → Atributo | Links, src, etc |

---

# 7. Diretivas Estruturais e de Estilo (v1.1.0)

O BlaiseVue oferece diretivas para controle de fluxo e manipulação dinâmica do DOM.

## 1. Condicional `v-if` e `v-else`

Renderiza ou remove elementos do DOM baseados em uma condição.

```html
<template>
  <div v-if="logado" class="badge">Usuário Ativo</div>
  <div v-else class="badge-red">Efetue login</div>
</template>
```

## 2. Visibilidade `v-show`

Alterna a visibilidade via CSS `display: none`. O elemento permanece no DOM.

```html
<div v-show="carregando">Processando...</div>
```

## 3. Listas `v-for`

Renderiza múltiplos elementos a partir de um array reativo.

```html
<template>
  <ul>
    <li v-for="item in lista">
      {{ item.nome }}
    </li>
  </ul>
</template>

<script>
  data:
    lista: TJSArray = TJSArray.new;
</script>
```

> **Dica Reativa:** Ao adicionar itens via `.push()`, para garantir a atualização da UI, você deve re-atribuir o array: `this['lista'] := arr;`.

## 4. Classes Dinâmicas `:class`

Sincroniza classes CSS dinamicamente usando objetos ou strings.

```html
<!-- Objeto: { "nome-da-classe": condicao_booleana } -->
<div :class="{ 'bg-success': ativo, 'border-error': erro }">
  Status do Componente
</div>
```

```pascal
// No script
data:
  ativo: boolean = true;
  erro: boolean = false;
```
