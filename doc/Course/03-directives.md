# 📜 Module 03: Essential Directives (b-if, b-for, and b-show)
**Teach your user interface to make decisions and render dynamic lists automatically.**

Imagine building an online store:
- If a user is logged in, you want to show a **"Log Out"** button.
- If they are not logged in, you want to show a **"Sign In"** button.
- If their cart has 10 items, you certainly do not want to write 10 repetitive HTML blocks by hand!

To handle these tasks cleanly, we use **Directives**!

---

## 🧭 1. What is a Directive?

A directive is a special HTML attribute (prefixed with `b-` in BlaiseVue) that adds reactive superpowers to an HTML element.

> [!TIP]
> **Vue.js Compatibility:**  
> If you are coming from Vue.js or looking at Vue tutorials, BlaiseVue supports the `v-` prefix as a direct alias! You can write `b-if` or `v-if`, `b-for` or `v-for`, with identical runtime behavior.

---

## 🔀 2. Conditional Rendering: `b-if`, `b-else-if`, and `b-else`

Just like in everyday logic (*"If it rains, take an umbrella; otherwise, wear sunglasses"*), in BlaiseVue we use `b-if`:

```html
<!-- If isLoggedIn is true, render the greeting: -->
<p b-if="isLoggedIn">Welcome back, adventurer! 🛡️</p>

<!-- If false, render the login button: -->
<p b-else>Please sign in to access your dashboard. ⚔️</p>
```

You can also chain multiple conditions with `b-else-if`:
```html
<span b-if="points >= 100" class="badge gold">Gold Tier 🏆</span>
<span b-else-if="points >= 50" class="badge silver">Silver Tier 🥈</span>
<span b-else class="badge bronze">Bronze Tier 🥉</span>
```

---

## 👁️ 3. What is the Difference Between `b-if` and `b-show`?

Both `b-if` and `b-show` toggle element visibility, but they operate differently under the hood:

| Directive | How It Works | When to Use It |
| :--- | :--- | :--- |
| **`b-if`** | Physically creates or destroys the element in the DOM tree. | When the condition rarely changes (e.g. administrator vs. regular user permission). |
| **`b-show`** | The element remains in the DOM, but is toggled using CSS (`display: none`). | When an element opens and closes frequently (e.g. dropdown menus, modal popups). |

---

## 🔁 4. Repeating Lists with Ease: `b-for`

Instead of writing repetitive HTML tags, we store items in a Pascal array and let `b-for` render them systematically:

```html
<ul>
  <!-- For each 'fruit' in the 'basket' array, render an <li> item -->
  <li b-for="fruit in basket">
    🍎 {{ fruit }}
  </li>
</ul>
```

---

## 🚀 5. Full Step-by-Step Example: An Interactive Task List

Let's build a complete task manager application where we:
1. Render tasks dynamically with `b-for`.
2. Display an empty state alert using `b-if` when there are no tasks.
3. Toggle list visibility smoothly with `b-show`.
4. Allow users to toggle completion status with a button click.

Copy and paste this code into your view file (e.g. `src/views/Home.bv`):

```html
<template>
  <div class="tasks-card">
    <h2>My Task Manager 🛡️</h2>

    <!-- Button to toggle the entire task container visibility -->
    <button class="btn-toggle" @click="toggleVisibility">
      {{ isVisible ? 'Hide Tasks' : 'Show Tasks' }}
    </button>

    <!-- b-show: Toggles visibility smoothly without re-creating DOM nodes -->
    <div b-show="isVisible" class="tasks-content">
      
      <!-- b-if: Shown only when the task list is completely empty -->
      <div b-if="tasks.length == 0" class="empty-state">
        🎉 Great job! You have no pending tasks right now.
      </div>

      <!-- b-else: Renders the active list of tasks -->
      <ul b-else class="task-list">
        <li b-for="item in tasks" class="task-item">
          <span :class="{ 'completed': item.done }">
            {{ item.title }}
          </span>
          <button class="btn-action" @click="toggleTask(item)">
            {{ item.done ? 'Undo' : 'Complete' }}
          </button>
        </li>
      </ul>

    </div>
  </div>
</template>

<script>
  data:
    isVisible: boolean = true;
    tasks: TJSArray;

  methods:
    // Toggles visibility between true and false
    procedure toggleVisibility;
    begin
      this['isVisible'] := not Boolean(this['isVisible']);
    end;

    // Toggles the completed status of the clicked task
    procedure toggleTask(item: TJSObject);
    begin
      item['done'] := not Boolean(item['done']);
    end;

  mounted:
    // When the component mounts, populate with 3 starter tasks:
    procedure;
    var
      t1, t2, t3: TJSObject;
    begin
      this['tasks'] := TJSArray.new;
      
      t1 := TJSObject.new;
      t1['title'] := 'Run bv doctor to check dependencies';
      t1['done'] := true;
      TJSArray(this['tasks']).push(t1);

      t2 := TJSObject.new;
      t2['title'] := 'Master reactive variables in Module 02';
      t2['done'] := true;
      TJSArray(this['tasks']).push(t2);

      t3 := TJSObject.new;
      t3['title'] := 'Build dynamic lists with b-for in Module 03';
      t3['done'] := false;
      TJSArray(this['tasks']).push(t3);
    end;
</script>

<style>
  .tasks-card {
    max-width: 480px;
    margin: 30px auto;
    background: #ffffff;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.08);
    font-family: sans-serif;
  }
  .btn-toggle {
    background: #3182ce;
    color: white;
    border: none;
    padding: 8px 14px;
    border-radius: 6px;
    cursor: pointer;
    margin-bottom: 16px;
    font-weight: bold;
  }
  .task-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  .task-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px;
    border-bottom: 1px solid #edf2f7;
  }
  .completed {
    text-decoration: line-through;
    color: #a0aec0;
  }
  .btn-action {
    background: #edf2f7;
    border: 1px solid #cbd5e0;
    padding: 4px 10px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
  }
  .btn-action:hover {
    background: #e2e8f0;
  }
  .empty-state {
    padding: 20px;
    background: #f0fff4;
    color: #276749;
    border-radius: 8px;
    text-align: center;
    font-weight: bold;
  }
</style>
```

---

## 🎯 6. Practical Exercise: Module 03

1. Add a **"Clear All Tasks"** button next to the toggle button.
2. In the `methods:` section, create the procedure:
   ```pascal
   procedure clearAll;
   begin
     this['tasks'] := TJSArray.new;
   end;
   ```
3. Test in the browser: when you click "Clear All", the list disappears and the green celebration alert renders instantly via `b-if="tasks.length == 0"`!

---

## 🏆 What You Learned Today
- How directives simplify DOM manipulation.
- How to make conditional UI branches with `b-if`, `b-else-if`, and `b-else`.
- When to use `b-show` for elements that toggle frequently.
- How to iterate and render arrays dynamically with `b-for`.


---

## 📖 Deeper Technical Reference
To explore compiler AST generation and conditional directive performance:
- **[Chapter 02: Template Syntax & Data Binding](../Documentation/02-templates.md)** — Comprehensive specification of expressions, text interpolation, and attribute binding.
- **[Chapter 39: Conditional Directives (b-if, b-else-if, b-else, v-if)](../Documentation/39-conditional-directives.md)** — Architectural design of conditional comment boundary markers, AST branch optimization, and DOM node recycling.

---

**Want to capture user input from forms and text boxes? Proceed to [Module 04: Synchronization with b-model](04-synchronization.md)!** ⚔️🛡️✨
