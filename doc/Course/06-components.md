# 🏰 Module 06: Components (.bv) - Building with LEGO Bricks
**Break your application into small, reusable, and easy-to-maintain pieces.**

Imagine building a castle out of LEGO bricks. Instead of carving an entire fortress out of a single monolithic stone, you assemble individual blocks: bricks, windows, doors, and towers. If one window needs a different color, you only swap that window!

In modern web development, each of those modular blocks is called a **Component**!

---

## 🧱 1. Why Use Components?

When you start an application without components, a single file quickly balloons into 1,000+ lines of messy, tangled code.

With BlaiseVue Single File Components (`.bv`):
1. **Reusability**: You build a `<product-card>` once and reuse it 10, 50, or 100 times across different pages.
2. **Organization**: Each component lives in its own dedicated file inside `src/components/`.
3. **Maintainability**: If you ever need to change how a button or badge looks, you only touch that single file!

---

## 🏷️ 2. How Does BlaiseVue Name Components?

BlaiseVue features an intelligent compiler. You do not need to write dozens of manual `import` or `require` statements!

Simply create your component file inside `src/components/`:
- `ProductCard.bv` ➔ Creates the HTML tag `<product-card>`
- `UserBadge.bv` ➔ Creates the HTML tag `<user-badge>`
- `AppHeader.bv` ➔ Creates the HTML tag `<app-header>`

---

## 🎁 3. What are `props:` (Passing Data from Parent to Child)?

Think of an employee ID badge. The plastic card has a standard physical template, but the **name** and **photo** printed on it differ for each person.

In BlaiseVue, the input parameters passed from a parent component into a child are declared in the **`props:`** section:

```pascal
<script>
  // Props: Data passed into this component from its parent caller
  props:
    title: string;
    price: real;
    isFeatured: boolean;
</script>
```

---

## 🚀 4. Full Step-by-Step Example: Creating and Using a Product Card

Let's build a modular product showcase!

### Step 1: Create the Child Component (`src/components/ProductCard.bv`)

Create a new file named `ProductCard.bv` inside `demo-app/src/components/`:

```html
<template>
  <div class="product-card" :class="{ 'featured': isFeatured }">
    <div class="product-icon">{{ icon }}</div>
    <h3 class="product-name">{{ name }}</h3>
    <p class="product-desc">{{ description }}</p>
    
    <div class="product-footer">
      <span class="price-tag">$ {{ price.toFixed(2) }}</span>
      <button class="btn-buy" @click="notifyClick">Purchase</button>
    </div>
  </div>
</template>

<script>
  props:
    icon: string = '📦';
    name: string = 'Standard Product';
    description: string = '';
    price: real = 0.0;
    isFeatured: boolean = false;

  methods:
    procedure notifyClick;
    begin
      TJSFunction(this['$emit']).apply(this, ['selected', this['name']]);
    end;
</script>

<style>
  .product-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    padding: 16px;
    width: 220px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    text-align: center;
    font-family: sans-serif;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .featured {
    border: 2px solid #3182ce;
    background: #ebf8ff;
  }
  .product-icon {
    font-size: 40px;
    margin-bottom: 8px;
  }
  .product-name {
    margin: 4px 0;
    font-size: 16px;
    color: #2d3748;
  }
  .product-desc {
    font-size: 12px;
    color: #718096;
    margin-bottom: 12px;
  }
  .product-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .price-tag {
    font-weight: bold;
    color: #2b6cb0;
    font-size: 15px;
  }
  .btn-buy {
    background: #38a169;
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: 6px;
    cursor: pointer;
    font-weight: bold;
  }
  .btn-buy:hover { background: #2f855a; }
</style>
```

---

### Step 2: Use the Component in a Parent View (`src/views/Home.bv`)

Now open `src/views/Home.bv` and consume your `<product-card>`:

```html
<template>
  <div class="store-showcase">
    <h2>🏪 Pascal Training Showcase</h2>

    <div class="products-grid">
      <!-- Using the exact same component multiple times with different props! -->
      <product-card 
        icon="🛡️" 
        name="Pascal Fundamentals" 
        description="Learn the cleanest, most structured syntax in computing." 
        :price="49.00"
        :is-featured="false">
      </product-card>

      <product-card 
        icon="⚡" 
        name="BlaiseVue Ninja" 
        description="Build ultra-fast reactive SPAs for Web and Mobile." 
        :price="99.00"
        :is-featured="true">
      </product-card>

      <product-card 
        icon="🚀" 
        name="mORMot 2 Backend" 
        description="High-throughput Pascal microservices and SOA servers." 
        :price="129.00"
        :is-featured="false">
      </product-card>
    </div>

  </div>
</template>

<style>
  .store-showcase {
    max-width: 820px;
    margin: 30px auto;
    font-family: sans-serif;
  }
  .products-grid {
    display: flex;
    gap: 20px;
    justify-content: center;
    flex-wrap: wrap;
  }
</style>
```

> [!TIP]
> **Why is there a colon `:` before `:price`?**  
> When you write `name="Pascal"`, you are passing a static raw string. When you want to pass a numeric value or a Pascal variable expression, prepend a colon: `:price="99.00"`. This instructs BlaiseVue to evaluate the attribute as a reactive Pascal expression!

---

## 🎯 5. Practical Exercise: Module 06

1. Add a fourth product card to the showcase (e.g. `"Database Systems with Pascal"`, price `79.00`, icon `💾`).
2. Set `:is-featured="true"` on the new card and observe the blue border and highlight background activate automatically!

---

## 🏆 What You Learned Today
- How to divide applications into clean, modular, reusable components.
- How the BlaiseVue compiler registers `.bv` files into HTML tags automatically.
- How to pass data from parent to child components using `props:`.
- How the bound attribute prefix `:` evaluates expressions and numbers.
- How BlaiseVue natively supports Multi-Root Fragments without requiring unnecessary wrapping `<div>` elements.

---

## 📖 Deeper Technical Reference
For advanced component mechanics, slots composition, and fragment compilation:
- **[Chapter 01: Component Architecture & Props](../Documentation/01-components.md)** — Exhaustive props type system (`string`, `integer`, `real`, `boolean`, `TJSObject`), default values, and validator functions.
- **[Chapter 16: Scoped Slots & Composition](../Documentation/16-scoped-slots.md)** — Passing template fragments and child slot properties back to parent containers.
- **[Chapter 48: Vue 3-Style Component Fragments](../Documentation/48-vue3-fragments.md)** — Multi-root template architecture, comment anchor boundaries, and automatic attribute fallthrough.

**Now that components know how to look good, how do they talk to each other? Let's find out in [Module 07: Communication & Events ($emit)](07-events.md)!** ⚔️🛡️✨
