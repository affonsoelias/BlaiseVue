# 🛡️ Module 11: Pro Features (Master Architecture)
**Learn the advanced architectural techniques used in enterprise-grade applications.**

Congratulations on reaching this milestone! You now have a firm grasp of reactivity, directives, form binding, components, and routing. Now let's explore the architectural patterns that keep large-scale software organized, elegant, and maintainable.

---

## 🖼️ 1. Flexible Composition with `<slot>` (The Picture Frame)

In previous modules, we passed data into components using `props:` (such as strings or numbers). But what if you want a component to accept **custom blocks of HTML** from its caller?

Think of a **picture frame**: the frame provides the borders, styling, and glass, but you choose what photo goes inside! In BlaiseVue, we use the **`<slot>`** tag to reserve that content placeholder:

### The Frame Component (`src/components/CardFrame.bv`):
```html
<template>
  <div class="card-frame">
    <div class="frame-header">
      <!-- Named slot for the header section -->
      <slot name="header"></slot>
    </div>

    <div class="frame-body">
      <!-- Default slot for any content passed inside -->
      <slot></slot>
    </div>
  </div>
</template>
```

### Using the Frame in Your View:
```html
<card-frame>
  <!-- Injected into slot name="header": -->
  <template #header>
    <h3>🔒 Restricted Access</h3>
  </template>

  <!-- Injected into the default slot: -->
  <p>Please enter your administrative credentials to continue.</p>
  <button class="btn btn-primary">Authenticate</button>
</card-frame>
```

### 💡 The App Shell (Layout) Pattern
Have you ever wondered how to avoid copying and pasting your navigation bar, sidebar, and footer into every single page of your application? 

You don't need a separate, heavy layout library! In BlaiseVue, **a layout is simply a component with a `<slot>`**:

1. **Create your shell (`src/layouts/MainLayout.bv` or `src/components/MainLayout.bv`)**:
   ```html
   <template>
     <div class="main-layout">
       <nav class="navbar bg-primary text-white p-3 shadow-sm">
         <h4>🛡️ My Enterprise App</h4>
       </nav>
       <div class="content-container p-4">
         <slot></slot> <!-- The active page will appear here! -->
       </div>
       <footer class="footer text-center p-3 text-muted border-top">
         &copy; 2026 BlaiseVue Enterprise
       </footer>
     </div>
   </template>
   ```

2. **Reuse it across any page (`src/views/Home.bv`)**:
   ```html
   <template>
     <main-layout>
       <h1>Welcome to Home Page!</h1>
       <p>Look how clean this view is — no duplicated navigation bars or footers!</p>
     </main-layout>
   </template>
   ```

---

## 🧠 2. Shared Global State ($store / B-Store)

Imagine an application with a **Shopping Cart**:
- The top navigation bar needs to display total items in the cart.
- The product catalog needs an "Add to Cart" button.
- The checkout page needs to list items and calculate shipping.

Passing cart data up and down through 10 levels of components would be cumbersome (*prop drilling*).

Instead, think of a **central water reservoir**: the tank sits at the top of the house and all rooms draw water directly from it! In BlaiseVue, that central reactive repository is the **`$store`**:

```pascal
// Any component view can read the shared store:
totalItems := Integer(this['$store']['cartCount']);

// And any button can mutate the shared state:
procedure addToCart;
begin
  this['$store']['cartCount'] := Integer(this['$store']['cartCount']) + 1;
end;
```

---

## ✨ 3. Smooth Transitions (`<transition>`)

User interfaces that snap in and out abruptly can feel jarring. With the **`<transition>`** component, BlaiseVue injects smooth fade or slide CSS transitions automatically:

```html
<template>
  <div>
    <button @click="toggleAlert">Toggle Notification</button>

    <!-- Wrap your b-if or b-show block with the transition tag -->
    <transition name="fade">
      <div b-if="showAlert" class="alert-box">
        🛡️ System Notice: Your daily cloud backup completed successfully!
      </div>
    </transition>
  </div>
</template>

<style>
  /* BlaiseVue manages these transition lifecycle classes: */
  .fade-enter-active, .fade-leave-active {
    transition: opacity 0.4s ease, transform 0.4s ease;
  }
  .fade-enter, .fade-leave-to {
    opacity: 0;
    transform: translateY(-8px);
  }
</style>
```

---

## 💉 4. Dependency Injection (Provide / Inject)

When a root component (such as `App.bv`) needs to provide a global configuration (e.g. active locale `'en-US'` or an API service client) to deeply nested child components without manually piping props down every layer, use **`provide`** and **`inject`**:

```pascal
// In the Root Component (App.bv):
provide:
  activeTheme: 'darkly';
  apiVersion: 'v4.4.0';

// In any descendant child component:
inject:
  activeTheme: string;
```

---

## 🎯 5. Practical Exercise: Module 11

1. Build a `ModalDialog.bv` component using `<slot>` for the dialog title and modal body.
2. Wrap the modal container with `<transition name="fade">`.
3. Add a button to open and close the modal dialog to experience how smooth transitions elevate perceived app quality!

---

## 🏆 What You Learned Today
- How to build flexible layouts using `<slot>` and named slots.
- How to share global reactive state across screens using the B-Store (`$store`).
- How to polish visual interfaces with `<transition>`.
- How to pass configuration data down deep component hierarchies cleanly with `provide` / `inject`.

**Want to guarantee that your code will never break unexpectedly? Let's master [Module 12: Fearless Unit Testing](12-tests.md)!** ⚔️🛡️✨
