# 📦 Gerenciamento de Bibliotecas (/lib)

O BlaiseVue PRO (v2.1+) traz um sistema de **Gerenciamento de Bibliotecas Externas** que permite criar, instalar e compartilhar pacotes de componentes e estilos sem configurações manuais.

## Como funciona a pasta `/lib`
A pasta `/lib` na raiz do seu projeto é monitorada pelo CLI `bv.exe`.  Cada subpasta dentro dela é considerada uma **Biblioteca BlaiseVue**.

### Estrutura Sugerida:
```text
/lib
  /minha-biblioteca-bv
    - Button.bv (Componente BlaiseVue)
    - Card.bv
    - style.css (Opcional: CSS Global da Lib)
```

## Poderes Automáticos (Zero Config)

### 1. Auto-Registro de Componentes
Qualquer arquivo `.bv` encontrado dentro de `/lib` é transpilado e registrado **globalmente**. Se você criar um componente `Button.bv` na lib, poderá usá-lo em qualquer página do projeto como:
```html
<button-page>Conteúdo</button-page>
```

### 2. Auto-Link de CSS
Se a sua biblioteca contiver um arquivo `.css`, o BlaiseVue irá:
1. Copiá-lo automaticamente para `dist/css/lib/`.
2. Injetar a tag `<link rel="stylesheet">` no seu `index.html` durante o build.

Isso é ideal para integrar frameworks como **Bootstrap**, **Tailwind** ou bibliotecas de UI personalizadas.

## Comandos do CLI

### Listar Bibliotecas
```bash
bv lib list
```

### Instalar uma Biblioteca (via ZIP URL)
```bash
bv lib install https://github.com/usuario/minha-lib/archive/refs/heads/main.zip
```
O CLI fará o download, extrairá na pasta `/lib` e deletará o arquivo `.zip` automaticamente.

### Remover uma Biblioteca
```bash
bv lib remove nome-da-pasta
```

## Exemplo: Criando uma Lib de Bootstrap
Para criar uma integração de Bootstrap, você pode:
1. Criar a pasta `lib/bootstrap-bv/`.
2. Colar o `bootstrap.min.css` lá dentro.
3. Criar um componente `BBtn.bv`:
```html
<template>
  <button class="btn btn-primary" @click="click">
    <slot></slot>
  </button>
</template>
<script>
  methods:
    procedure click;
    begin
       asm this.$emit('click'); end;
    end;
</script>
```
4. **Resultado**: O seu app agora tem o Bootstrap injetado e você pode usar o componente `<b-btn-page>` sem nenhum import!

---
**BlaiseVue: Simplicidade e Escala.** 🛡️🚀🏆
