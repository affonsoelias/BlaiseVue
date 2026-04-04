# 📜 Module 03: Project 02 - An Epic Task List
**Master the b-for, b-if, and b-show directives in practice!**

In this lesson, we will move out of theory and build a real application. You will learn how BlaiseVue manages lists and conditionals automatically.

---

## 🛠️ What are we building?
A list where you can add tasks, see them on the screen, and hide the list whenever you want.

### 1. Preparing the Template
Open your `Home.bv` and add this code:
```html
<template>
  <div class="list-container">
    <h1>My Tasks 🛡️</h1>
    
    <!-- b-show: To hide the whole list -->
    <button @click="toggleVisibility">Toggle Visibility</button>

    <div b-show="visible">
      <ul>
        <!-- b-for: Where the magic happens -->
        <li b-for="task in list">
          {{ task.name }} - {{ task.status }}
        </li>
      </ul>
      
      <!-- b-if: Only appears when the list is empty -->
      <p b-if="list.length == 0">No tasks for now! ⚔️</p>
    </div>
  </div>
</template>
```

---

## 👁️ What You Learned Today:
- **`b-for`**: How to repeat elements based on a Pascal Array.
- **`b-if`**: How to show messages only when conditions are met.
- **`b-show`**: How to toggle visibility instantly without reloading! ✨✨✨

---

> [!TIP]
> **Pro Tip: Directive Aliases**
> For those coming from Vue.js, BlaiseVue also supports the `v-` prefix! 
> You can use `v-for`, `v-if`, and `v-show` instead of `b-` prefixes if it helps your workflow. The compiler handles both identically. 🚀

**Extra Challenge:** Try to add a "Remove" button inside the `b-for` using what you learned in the previous module! 🛡️✨🏆

---

**Next Step: Learn to master forms with b-model in Module 04!** ⚔️
