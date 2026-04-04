# 🧠 B-Store (Global Store / $store)

BlaiseVue PRO resolves the "prop drilling" problem (passing data through multiple component levels) with **B-Store**: a reactive global state management system accessible from any point in the application.

---

## 🏛️ B-Store Architecture
The B-Store is implemented as a reactive **Singleton** based on **JS Proxy**. This means that any change to a store property triggers a re-render in all components that depend on that specific data.

### 🔥 Technical Advantages:
1.  **Global Reactivity**: Unlike `data:` (private), `$store` is public for all components.
2.  **Proxy Mapping**: BlaiseVue intercepts store accesses to automatically track dependencies.
3.  **SPA Persistence**: The state is maintained throughout the router's navigation, only clearing on a page refresh (F5).

---

## 🛠️ How to Use

### 1. Initializing Data in App Root (`app.bv`)
You should populate the store in the `created` hook or the `provide` block of your root component.

```pascal
{ app.bv }
<script>
  created:
    begin
       { Initialize global keys that will be used by the entire UI }
       TJSObject(this['$store'])['appVersion'] := '1.0.0';
       TJSObject(this['$store'])['user'] := 'Pascal Master 🏆';
    end;
</script>
```

### 2. Accessing in the Interface (`<template>`)
Any `.bv` component can read the store directly using the `$store` prefix:

```html
<template>
  <div class="user-info">
    <p>Welcome, 👤 <strong>{{ $store.user }}</strong></p>
    <p>Build: <code>{{ $store.appVersion }}</code></p>
  </div>
</template>
```

### 3. Modifying State via Pascal
Mutations are synchronous and instantly reflect in all components.

```pascal
methods:
  procedure updateProfile;
  begin
     { Updating the global state: other components' UI will change instantly! }
     TJSObject(this['$store'])['user'] := 'Master Blaise ⚔️';
  end;
```

---

## 💡 Best Practices
- **Centralization**: Use B-Store for shared data (user info, theme settings, authentication flags).
- **Namespacing**: If your app is large, prefer grouping data into objects, e.g., `$store.config.theme`.
- **Performance**: Avoid putting heavy objects (blobs, large buffers) in the reactive store to not overload the re-render cycle.

---
_"BlaiseVue: Global State, Local Syntax."_ 🛡️✨🏆
