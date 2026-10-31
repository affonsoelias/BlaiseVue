# 6. Data Binding

BlaiseVue supports three forms of data binding:

## 1. Text Interpolation `{{ }}`

Displays the value of a reactive variable in the HTML.

```html
<template>
  <h1>{{ title }}</h1>
  <p>Welcome, {{ name }}!</p>
</template>

<script>
  data:
    title: string = 'My App';
    name: string = 'User';
</script>
```

**Result:** The text is automatically updated when the value changes.

---

## 2. Two-Way Binding `b-model`

Links an input to reactive data in two directions:
- **Input → Data:** When the user types, the data updates.
- **Data → Input:** When the data changes by code, the input updates.

> [!NOTE]
> **Alias Support:** You can also use `v-model` (Vue compatibility). Both `b-model` and `v-model` are handled identically by the compiler.

```html
<template>
  <div>
    <input type="text" v-model="username">
    <p>Output: {{ username }}</p>
  </div>
</template>

<script>
  data:
    username: string = '';
</script>
```

**Works with:** `<input>`, `<textarea>`, `<select>`

### Practical Example

```html
<template>
  <div>
    <label>Name:</label>
    <input type="text" b-model="name">

    <label>Email:</label>
    <input type="text" b-model="email">

    <h3>Summary:</h3>
    <p>Name: {{ name }}</p>
    <p>Email: {{ email }}</p>
  </div>
</template>

<script>
  data:
    name: string = '';
    email: string = '';
</script>
```

---

## 3. One-Way Attribute Binding `:attr` or `b-bind:attr`

Links an HTML attribute to a reactive data (read-only).

```html
<template>
  <a :href="link">Visit</a>
  <div :class="activeClass">Content</div>
  <img :src="imageUrl">
</template>

<script>
  data:
    link: string = 'https://example.com';
    activeClass: string = 'highlight';
    imageUrl: string = 'photo.png';
</script>
```

**Short syntax:** `:href="field"` (equivalent to `b-bind:href="field"`)

---

## Binding Comparison

| Type | Directive | Direction | Usage |
|------|----------|---------|-----|
| Interpolation | `{{ }}` | Data → DOM | Display text |
| Two-Way | `b-model` | Data ↔ DOM | Inputs/forms |
| One-Way | `:attr` | Data → Attribute | Links, src, etc. |

---

# 7. Structural and Style Directives

BlaiseVue offers directives for flow control and dynamic DOM manipulation.

## 1. Conditionals (`b-if`, `b-else-if`, `b-else`)

Renders or removes elements from the DOM based on reactive conditions. 

BlaiseVue supports full `if / else-if / else` branching. Elements with `b-else-if` and `b-else` must immediately follow an element with `b-if` or `b-else-if` (whitespace and HTML comments between siblings are automatically ignored).

```html
<template>
  <!-- Simple If / Else -->
  <div b-if="loggedIn" class="badge">Active User</div>
  <div b-else class="badge-red">Please log in</div>

  <!-- Multi-branch If / Else-If / Else -->
  <div class="score-card">
    <p b-if="score >= 90" class="grade-a">Grade A 🏆</p>
    <p b-else-if="score >= 70" class="grade-b">Grade B 🥈</p>
    <p b-else-if="score >= 50" class="grade-c">Grade C 🥉</p>
    <p b-else class="grade-f">Retake Test ⚠️</p>
  </div>
</template>
```

> [!TIP]
> **Vue Aliases (`v-if`, `v-else-if`, `v-else`)**
> All conditional directives can be written using either the `b-` prefix (`b-if`, `b-else-if`, `b-else`) or the standard Vue `v-` prefix (`v-if`, `v-else-if`, `v-else`). Both formats are treated identically by the runtime compiler.

## 2. Visibility `b-show`

Toggles visibility via CSS `display: none`. The element remains in the DOM.

```html
<div b-show="loading">Processing...</div>
```

## 3. Lists `b-for`

Renders multiple elements from a reactive array.

```html
<template>
  <ul>
    <li b-for="item in list">
      #{{ $index }}: {{ item.name }}
      <button @click="toggleItem(item.id)">Toggle</button>
    </li>
  </ul>
</template>

<script>
  data:
    list: TJSArray = TJSArray.new;

  methods:
    procedure toggleItem(id: string);
    begin
      // Methods invoked within b-for scope have direct access to component state
    end;
</script>
```

> [!TIP]
> **Special Variable `$index`**: Each iteration injects a zero-based index variable `$index` into the loop template scope.
>
> **Scoped Proxy Set Trap**: Event listeners and methods invoked within a `b-for` loop can directly read iteration variables (`item`) and modify parent component reactive state seamlessly.
>
> **Reactive Tip:** When adding items via `.push()`, to ensure UI update, you must re-assign the array: `this['list'] := arr;`.

## 4. Dynamic Classes `:class`

Synchronizes CSS classes dynamically using objects or strings.

```html
<!-- Object: { "class-name": boolean_condition } -->
<div :class="{ 'bg-success': active, 'border-error': error }">
  Component Status
</div>
```

```pascal
// In the script
data:
  active: boolean = true;
  error: boolean = false;
```

## 5. Dynamic Styles `:style`

Binds inline styles dynamically using objects or strings.

```html
<div :style="{ width: progress + '%', backgroundColor: activeColor }">
  Dynamic Bar
</div>
```

```pascal
data:
  progress: integer = 65;
  activeColor: string = '#42b883';
```

