# 4. Formato .bv (Single File Component)

O arquivo `.bv` é o formato SFC do BlaiseVue, inspirado nos `.vue` do Vue.js. Ele combina template, lógica e estilo em um único arquivo.

## Estrutura

```html
<template>
  <!-- HTML do componente -->
</template>

<script uses="Unit1, Unit2">
  <!-- Lógica Pascal -->
</script>

<style>
  /* CSS do componente */
</style>
```

## Seção `<template>`

Contém o HTML do componente. Suporta:

- **Interpolação:** `{{ variavel }}`
- **Two-way binding:** `<input b-model="campo">`
- **Eventos:** `<button @click="metodo">`
- **Attr binding:** `<div :class="classe">`
- **Componentes:** `<meu-componente></meu-componente>`
- **Router view:** `<router-view></router-view>`

```html
<template>
  <div>
    <h1>{{ titulo }}</h1>
    <input type="text" b-model="nome">
    <p>Ola, {{ nome }}!</p>
    <button @click="saudar">Clique</button>
    <meu-componente></meu-componente>
  </div>
</template>
```

## Seção `<script>`

Contém a lógica do componente em um formato declarativo.

### Atributo `uses`

Importa units Pascal adicionais:
```html
<script uses="BVRouting, MinhaUnit">
```

### Sub-seção `data:`

Define dados reativos. Formato: `nome: tipo = valorPadrao;`

```
data:
  nome: string = 'Mundo';
  contador: integer = 0;
  ativo: boolean = True;
```

**Tipos suportados:** `string`, `integer`, `boolean`

### Sub-seção `methods:`

Define métodos em Pascal puro. Cada método é um `procedure`. Você pode acessar os dados reativos usando a variável `this` (ou `State`):

```
methods:
  procedure saudar;
  begin
    window.alert('Ola!'); 
  end;

  procedure incrementar;
  begin
    this['contador'] := Integer(this['contador']) + 1;
  end;
```

> **Nota:** O BlaiseVue expõe objetos globais como `window`, `document` e `console` via unit `Web`, permitindo o uso nativo sem `asm`.

### Sub-seção `router:`

Define rotas SPA (apenas no `app.bv`):

```
router:
  routes:
    '/': 'home-page';
    '/about': 'about-page';
    '/user/:id': 'user-profile-page';
```

## Seção `<style>`

CSS que será injetado automaticamente no `<head>` da página:

```html
<style>
  h1 { color: #42b883; }
  .container { max-width: 800px; margin: 0 auto; }
</style>
```

## Exemplo Completo

```html
<template>
  <div class="card">
    <h2>{{ titulo }}</h2>
    <input type="text" b-model="mensagem">
    <p>Voce digitou: {{ mensagem }}</p>
    <button @click="limpar">Limpar</button>
  </div>
</template>

<script>
  data:
    titulo: string = 'Meu Componente';
    mensagem: string = '';

  methods:
    procedure limpar;
    begin
      this['mensagem'] := '';
    end;
</script>

<style>
  .card { border: 1px solid #ddd; padding: 20px; border-radius: 8px; }
</style>
```
