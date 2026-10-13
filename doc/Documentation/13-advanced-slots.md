# 13. Advanced Slots & Scoped Slots

Slots allow you to compose flexible, reusable components by defining content injection points ("holes") inside a child component that the parent component populates.

BlaiseVue supports both **Named Slots** and **Scoped Slots**.

---

## 🏛️ 1. Named Slots

When a component needs multiple insertion points (e.g. Header, Body, and Footer), you can assign a `name` attribute to each `<slot>`.

### Child Component (`Card.bv`)
```html
<template>
  <div class="card">
    <div class="card-header">
      <slot name="header">Default Header Title</slot>
    </div>
    <div class="card-body">
      <slot></slot> <!-- Default slot (unnamed) -->
    </div>
    <div class="card-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>
```

### Parent Component
In the parent template, direct content to specific slots using `<template b-slot:name>` or shorthand `<template #name>`:

```html
<card>
  <!-- Target the "header" slot -->
  <template #header>
    <h3>Project Statistics 📈</h3>
  </template>

  <!-- Content for the default slot -->
  <p>All system metrics are running within nominal parameters.</p>

  <!-- Target the "footer" slot -->
  <template #footer>
    <button class="btn btn-primary">Refresh Data</button>
  </template>
</card>
```

---

## 🧬 2. Scoped Slots

### What are Scoped Slots?
Standard slots pass content **from parent to child**. However, in components like **Data Tables**, **Lists**, or **Drop-down selectors**, the **child component owns the data** (e.g., current loop item, status, row index), but the **parent wants to control how that data looks**.

**Scoped Slots** solve this by passing data from the child back up to the parent template.

---

### Syntax

#### 1. In the Child Component
Bind data attributes directly to the `<slot>` element:

```html
<!-- src/components/DataList.bv -->
<template>
  <ul class="data-list">
    <li b-for="user in users">
      <!-- Expose 'user' and 'index' to the parent -->
      <slot name="item" :row="user" :index="user.id">
        <!-- Fallback if parent provides no custom template -->
        <span>{{ user.name }}</span>
      </slot>
    </li>
  </ul>
</template>
```

#### 2. In the Parent Component
Receive the data in the parent template using `b-slot:name="slotProps"`, `#name="slotProps"`, or legacy `slot-scope="slotProps"`:

```html
<!-- src/views/UsersView.bv -->
<template>
  <div class="users-page">
    <h2>User Directory</h2>

    <data-list :users="userList">
      <template #item="slotProps">
        <div class="custom-user-row">
          <strong>#{{ slotProps.index }}</strong> - <span>{{ slotProps.row.name }}</span>
          <span class="badge" :class="slotProps.row.active ? 'badge-success' : 'badge-danger'">
            {{ slotProps.row.active ? 'Active' : 'Offline' }}
          </span>
        </div>
      </template>
    </data-list>
  </div>
</template>
```

---

## 🔄 Slot Props Forwarding (Nested Slots)

When nesting components (for example, wrapping a generic table inside a searchable card), BlaiseVue 2.0 forwards slot props seamlessly through multiple component layers:

```html
<!-- WrapperComponent.bv -->
<template>
  <div class="table-wrapper">
    <base-table :items="items">
      <template #cell(action)="scope">
        <!-- Forwarding the slot prop to the parent of WrapperComponent -->
        <slot name="action-column" :row="scope.row"></slot>
      </template>
    </base-table>
  </div>
</template>
```

---

## 🛠️ Architectural Implementation

In [`core/BVCompiler.pas`](file:///c:/Users/Pichau/Documents/BlaiseVue/core/BVCompiler.pas):
- Inverted slot traversal ensures all cloned child elements are mounted into `sNode.parentNode` with lexical scope resolution before the reactive engine recursively traverses the node.
- The compiler dynamically creates an execution closure that binds the child's slot attributes (`:row`, `:index`) to the parent template scope variable (`slotProps`).

---

## 📋 Syntax Cheat Sheet

| Syntax | Supported | Notes |
|---|:---:|---|
| `<template b-slot:name="slotProps">` | ✅ | Full explicit syntax |
| `<template #name="slotProps">` | ✅ | Recommended modern shorthand |
| `<template slot-scope="slotProps">` | ✅ | Backward-compatible syntax |
| `<template #default="slotProps">` | ✅ | Scoped default slot |
