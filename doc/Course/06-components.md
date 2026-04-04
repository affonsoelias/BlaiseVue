# 🏰 Module 06: SFC Components (.bv)
**The Lego Game of BlaiseVue.**

The greatest strength of modern applications is the **Component**. Instead of a giant HTML file, you split your App into small pieces with their own life: the **`.bv`** files.

## ⚔️ The Triple Structure
Each BlaiseVue component is split into 3 parts:
1.  **`<template>`**: The body (HTML).
2.  **`<script>`**: The mind (Pascal).
3.  **`<style>`**: The armor (CSS).

## 👁️ Automatic Registration
The BlaiseVue compiler (`bv.exe`) finds your `.bv` files, transpiles them, and generates the component registration for you.

```html
<!-- In your main App -->
<template>
  <div>
    <my-header title="My Title"></my-header>
    <main-content></main-content>
    <my-footer></my-footer>
  </div>
</template>
```

---

**The Secret of Organization:**
Always create small components focused on a single task! 🛡️✨🏆

---

**Next Step: Make the world hear your code in Module 07!** ⚔️
