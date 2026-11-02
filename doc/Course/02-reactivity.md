# 🧬 Module 02: The Reactive Engine
**Discover how data gains a dynamic life of its own on the screen.**

In the previous module, we saw that Pascal acts as the "brain" of the application. Now let's explore the most fundamental concept of any modern web framework: **Reactivity**.

---

## 📦 1. What is a Variable? (For Beginners)

If you have never programmed before, imagine a variable as a **labeled storage box**:
- The **label** is the name you give it (e.g. `username`, `score`, `isActive`).
- The **content** is the value stored inside the box (e.g. the text `'Alice'`, the number `25`).
- The **type** defines what fits inside the box. Pascal is strongly typed, ensuring safety and precision!

Here are the most common types you will use:

| Type in Pascal | What Does It Store? | Example |
| :--- | :--- | :--- |
| `string` | Text and words (always enclosed in single quotes `'...'`) | `'Alice Johnson'`, `'San Francisco'` |
| `integer` | Whole numbers (positive or negative, without decimals) | `0`, `42`, `100`, `-5` |
| `real` | Numbers with decimal places (prices, percentages) | `19.99`, `3.1415` |
| `boolean` | True or False states | `true`, `false` |

---

## ⚡ 2. What Does "Reactivity" Mean? (The Spreadsheet Analogy)

Think of a spreadsheet in Microsoft Excel:
- In cell **A1**, you enter the price of a book: `$ 20.00`.
- In cell **A2**, you enter the quantity: `3`.
- In cell **A3**, you enter a multiplication formula: `=A1 * A2`. Excel displays `$ 60.00`.

If you change cell **A2** from `3` to `5`, what happens to cell **A3**?  
**It recalculates and updates instantly!**

**BlaiseVue works the exact same way**. When you update a variable in Pascal code, BlaiseVue detects which parts of the HTML rely on that variable and updates the screen in milliseconds without flickering.

---

## 🛠️ 3. Where Do We Declare Variables? (The `data:` Section)

Inside the `<script>` block of a `.bv` component, we have a section called `data:`. This is where all reactive state is declared:

```pascal
<script>
  data:
    // A string box for the user's name:
    userName: string = 'Alice';
    
    // An integer box for counting clicks:
    clickCount: integer = 0;
    
    // A boolean flag to toggle a message:
    showMessage: boolean = true;
</script>
```

In the `<template>`, we display these values using double curly braces:
```html
<template>
  <div>
    <h1>Hello, {{ userName }}!</h1>
    <p>Current click count: {{ clickCount }}</p>
  </div>
</template>
```

---

## 🚀 4. Full Step-by-Step Example: An Interactive Counter

Let's build a complete interactive counter with buttons to increment, decrement, and reset the score.

Replace the contents of your view component (e.g. `src/views/Home.bv`) with:

```html
<template>
  <div class="counter-card">
    <h2>My Reactive Counter 🛡️</h2>
    
    <!-- Renders the current value of the 'score' variable -->
    <div class="score-display">
      {{ score }}
    </div>

    <div class="button-group">
      <!-- @click listens for mouse clicks and triggers Pascal methods -->
      <button class="btn btn-green" @click="increment">Increment (+1)</button>
      <button class="btn btn-red" @click="decrement">Decrement (-1)</button>
      <button class="btn btn-gray" @click="resetScore">Reset</button>
    </div>
  </div>
</template>

<script>
  data:
    score: integer = 0;

  methods:
    // Action 1: Add 1 point
    procedure increment;
    begin
      this['score'] := Integer(this['score']) + 1;
    end;

    // Action 2: Subtract 1 point
    procedure decrement;
    begin
      this['score'] := Integer(this['score']) - 1;
    end;

    // Action 3: Reset back to zero
    procedure resetScore;
    begin
      this['score'] := 0;
    end;
</script>

<style>
  .counter-card {
    max-width: 360px;
    margin: 40px auto;
    padding: 24px;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
    text-align: center;
    font-family: sans-serif;
  }
  .score-display {
    font-size: 56px;
    font-weight: bold;
    color: #2b6cb0;
    margin: 20px 0;
  }
  .button-group {
    display: flex;
    gap: 8px;
    justify-content: center;
  }
  .btn {
    padding: 10px 14px;
    border: none;
    border-radius: 6px;
    font-size: 13px;
    font-weight: bold;
    cursor: pointer;
    color: white;
  }
  .btn-green { background-color: #38a169; }
  .btn-red { background-color: #e53e3e; }
  .btn-gray { background-color: #718096; }
  .btn:hover { opacity: 0.9; }
</style>
```

### Understanding the Pascal Logic:
- `data: score: integer = 0;`: Initializes the variable `score` with zero.
- `this['score']`: Accesses the reactive data property of the current component instance.
- `Integer(this['score']) + 1`: Evaluates the current value, adds 1, and assigns it back.
- BlaiseVue's reactive proxy automatically intercepts the assignment and updates the DOM in real time!

---

## 🎯 5. Practical Exercise: Module 02

Now it's your turn to experiment:

1. Add a fourth button labeled **"Double (x2)"**.
2. In the `methods:` section, write the procedure:
   ```pascal
   procedure doubleScore;
   begin
     this['score'] := Integer(this['score']) * 2;
   end;
   ```
3. Test it in the browser: click "Increment" until you reach 5, then click "Double". The display instantly turns into 10!

---

## 🏆 What You Learned Today
- How variables work and the basic data types in Pascal (`string`, `integer`, `boolean`, `real`).
- How reactivity updates the user interface automatically when state changes.
- How to declare reactive variables in `data:` and actions in `methods:`.
- How to connect button clicks to Pascal methods using `@click`.

**Next up: teaching our screen to make smart decisions with Directives! Proceed to [Module 03: Essential Directives](03-directives.md)!** ⚔️🛡️✨
