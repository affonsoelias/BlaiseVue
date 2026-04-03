# 🏰 Módulo 06: Componentes SFC (.bv)
**O Jogo de Lego do BlaiseVue.**

A maior força das aplicações modernas é o **Componente**. Em vez de um arquivo HTML gigante, você divide seu App em pequenos pedaços com vida própria: os arquivos **`.bv`**.

## ⚔️ A Estrutura Tripla
Cada componente BlaiseVue é dividido em 3 partes:
1.  **`<template>`**: O corpo (HTML).
2.  **`<script>`**: A mente (Pascal).
3.  **`<style>`**: A armadura (CSS).

## 👁️ Registro Automático
O compilador do BlaiseVue (`bv.exe`) encontra seus arquivos `.bv`, os transpila e gera o registro de componente para você.

```html
<!-- No seu App principal -->
<template>
  <div>
    <my-header title="Meu Título"></my-header>
    <main-content></main-content>
    <my-footer></my-footer>
  </div>
</template>
```

---

**O Segredo da Organização:**
Sempre crie componentes pequenos e focados em uma única tarefa! 🛡️✨🏆

---

**Próximo Passo: Faça o mundo ouvir seu código no Módulo 07!** ⚔️
