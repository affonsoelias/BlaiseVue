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

When nesting components (for example, wrapping a generic table inside a searchable card), BlaiseVue forwards slot props seamlessly through multiple component layers:

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

## 🏛️ 3. Architectural Pattern: Building Reusable Page Layouts (App Shells)

A common design requirement in real-world web applications is **Layout Organization**:
- **Administrative Pages**: Require a persistent top navigation bar, collapsible sidebar menu, breadcrumbs, and user avatar.
- **Authentication Pages (Login/Register)**: Require a minimalist, centered card on a clean background without navigation bars.
- **Printing / Export Views**: Require an unadorned blank layout with no menus.

Instead of introducing complex, opinionated meta-libraries or rigid magic conventions, BlaiseVue follows the fundamental Vue architecture: **"Layouts are simply components with slots"**.

This guarantees:
1. **Zero Runtime Overhead**: No extra layers, meta-resolvers, or hidden dependencies.
2. **Total Design Freedom**: You control 100% of the HTML, CSS positioning (Flexbox, CSS Grid), and Pascal state.
3. **100% Backward Compatibility**: Existing projects and single-page apps continue functioning with zero changes.

---

### 3.1. Creating a Master Layout Component (`src/layouts/AppLayout.bv`)

Create an app shell component with your topbar, sidebar, and a default `<slot></slot>` where the page content will be projected:

```html
<!-- src/layouts/AppLayout.bv -->
<template>
  <div class="app-layout">
    <!-- Top Navigation Header -->
    <header class="app-header navbar navbar-dark bg-dark px-3">
      <span class="navbar-brand">🛡️ Enterprise Dashboard</span>
      <div class="user-profile text-white">
        <span>Logged as: <strong>{{ userName }}</strong></span>
      </div>
    </header>

    <div class="app-body d-flex">
      <!-- Persistent Sidebar Navigation -->
      <aside class="app-sidebar bg-light p-3 border-end" style="width: 240px; min-height: calc(100vh - 56px);">
        <nav class="nav flex-column gap-2">
          <router-link to="/" class="nav-link">📊 Dashboard</router-link>
          <router-link to="/users" class="nav-link">👥 User Management</router-link>
          <router-link to="/settings" class="nav-link">⚙️ Settings</router-link>
        </nav>
      </aside>

      <!-- Main Content Injection Point (The Page Slot) -->
      <main class="app-content flex-grow-1 p-4">
        <slot></slot>
      </main>
    </div>
  </div>
</template>

<script>
unit uAppLayout;
interface
uses JS, Web;

var
  userName: string = 'Admin User';
end.
</script>
```

---

### 3.2. Consuming the Layout in a Route View (`src/views/DashboardView.bv`)

In your page views, simply wrap your page content inside `<app-layout>`:

```html
<!-- src/views/DashboardView.bv -->
<template>
  <app-layout>
    <div class="dashboard-page">
      <h2>System Overview</h2>
      <div class="row g-3">
        <div class="col-md-4">
          <div class="card p-3 shadow-sm">
            <h5>Total Sales</h5>
            <p class="display-6 text-primary">$124,500</p>
          </div>
        </div>
        <div class="col-md-4">
          <div class="card p-3 shadow-sm">
            <h5>Active Users</h5>
            <p class="display-6 text-success">1,420</p>
          </div>
        </div>
      </div>
    </div>
  </app-layout>
</template>
```

---

### 3.3. Multi-Layout Architecture (Switching Shells)

When your application requires different shells (such as `AuthLayout.bv` for login and `AppLayout.bv` for internal views), create each shell in `src/layouts/`:

```html
<!-- src/layouts/AuthLayout.bv -->
<template>
  <div class="auth-layout min-vh-100 d-flex align-items-center justify-content-center bg-light">
    <div class="auth-container" style="max-width: 420px; width: 100%;">
      <slot></slot>
    </div>
  </div>
</template>
```

In `src/views/LoginView.bv`:
```html
<template>
  <auth-layout>
    <div class="card shadow p-4">
      <h3 class="text-center mb-3">Sign In</h3>
      <!-- Login form here -->
    </div>
  </auth-layout>
</template>
```

---

## 📋 Syntax Cheat Sheet

| Syntax | Supported | Notes |
|---|:---:|---|
| `<template b-slot:name="slotProps">` | ✅ | Full explicit syntax |
| `<template #name="slotProps">` | ✅ | Recommended modern shorthand |
| `<template slot-scope="slotProps">` | ✅ | Backward-compatible syntax |
| `<template #default="slotProps">` | ✅ | Scoped default slot |
