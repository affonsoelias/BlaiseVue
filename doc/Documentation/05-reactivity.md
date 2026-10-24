# 5. Reactivity Engine & Practical State Management

Reactivity is the heartbeat of **BlaiseVue**. It allows you to declare application state in modern Object Pascal and automatically keeps the DOM in sync whenever that state changes — with **zero Virtual DOM overhead** and **zero manual DOM manipulation**.

---

## 🚀 Quick Practical Overview

In BlaiseVue, every variable declared in your component's `data:` section is automatically wrapped in a high-performance **ES6 Proxy**. 

When you read a variable in your `<template>` (e.g. `{{ count }}`), BlaiseVue **tracks** that dependency. When you modify that variable in an Object Pascal method (e.g. `count := count + 1;`), BlaiseVue **triggers** an instant, surgical update to only the affected DOM elements.

```
       User Action (Click, Input, Timer)
                      │
                      ▼
       Object Pascal Method (`methods:`)
         `self.count := self.count + 1;`
                      │
                      ▼
         ES6 Proxy Interception (`set`)
                      │
                      ▼
   Surgical DOM Update (`{{ count }}`) ⚡
```

---

## 🛠️ Practical Example 1: Reactive State Mutation

Here is a complete, runnable Single File Component (`.bv`) demonstrating primitive state mutation:

```html
<template>
  <div class="counter-card">
    <h2>Counter: <span class="badge">{{ count }}</span></h2>
    <p>Status: <strong>{{ statusMessage }}</strong></p>

    <div class="button-group">
      <button @click="Decrement">- Decrement</button>
      <button @click="Reset">Reset</button>
      <button @click="Increment">+ Increment</button>
    </div>
  </div>
</template>

<script>
type
  TCounterComponent = class
  public
    data:
      count: Integer = 0;
      statusMessage: String = 'Ready';

    methods:
      procedure Increment;
      procedure Decrement;
      procedure Reset;
  end;

procedure TCounterComponent.Increment;
begin
  self.count := self.count + 1;
  if self.count > 10 then
    self.statusMessage := 'High activity! 🚀'
  else
    self.statusMessage := 'Incremented';
end;

procedure TCounterComponent.Decrement;
begin
  if self.count > 0 then
    self.count := self.count - 1;
  self.statusMessage := 'Decremented';
end;

procedure TCounterComponent.Reset;
begin
  self.count := 0;
  self.statusMessage := 'Reset to zero';
end;
</script>

<style>
.counter-card {
  padding: 1.5rem;
  border-radius: 8px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  max-width: 360px;
}
.badge {
  color: #2563eb;
  font-weight: bold;
}
.button-group button {
  margin-right: 0.5rem;
  padding: 0.5rem 1rem;
  cursor: pointer;
}
</style>
```

### 💡 What happens behind the scenes:
1. When `TCounterComponent` mounts, the template binds `{{ count }}` and `{{ statusMessage }}` to the reactive instance.
2. Clicking `+ Increment` executes `Increment` in pure Object Pascal.
3. Modifying `self.count := self.count + 1` notifies all dependent DOM text nodes to update immediately.
4. No need for `this.setState(...)`, `notifyListeners()`, or manual element querying!

---

## 📋 Practical Example 2: Reactive Arrays (`TJSArray`)

Arrays require special attention in reactive frameworks. In BlaiseVue, dynamic lists are represented using `TJSArray`. BlaiseVue instruments all native mutation methods so adding, removing, or reordering items automatically updates any associated `b-for` loop:

### Supported Mutator Methods:
- `push(item)`: Appends an item to the end of the array.
- `pop()`: Removes the last item.
- `splice(index, deleteCount, ...items)`: Inserts or removes items at any position.
- `shift()` / `unshift(item)`: Removes from or prepends to the front of the array.
- `sort()` / `reverse()`: Reorders items in-place.

```html
<template>
  <div class="todo-widget">
    <h3>My Task List (Total: {{ tasks.length }})</h3>

    <div class="input-row">
      <input type="text" b-model="newTaskTitle" placeholder="Enter task..." @keyup.enter="AddTask" />
      <button @click="AddTask">Add Task</button>
    </div>

    <ul>
      <li b-for="(task, index) in tasks">
        <span>{{ task.title }}</span>
        <button class="btn-remove" @click="RemoveTask(index)">✕</button>
      </li>
    </ul>

    <p b-if="tasks.length = 0" class="empty-state">No tasks pending. Enjoy your day! 🎉</p>
  </div>
</template>

<script>
type
  TTaskItem = class
  public
    title: String;
    done: Boolean;
  end;

  TTodoComponent = class
  public
    data:
      newTaskTitle: String = '';
      tasks: TJSArray;

    methods:
      procedure AddTask;
      procedure RemoveTask(AIndex: Integer);
  end;

procedure TTodoComponent.AddTask;
var
  LItem: TTaskItem;
begin
  if Trim(self.newTaskTitle) = '' then Exit;

  LItem := TTaskItem.Create;
  LItem.title := self.newTaskTitle;
  LItem.done := False;

  // Reactively appends to list and re-renders b-for
  self.tasks.push(LItem);

  // Clears the input field via two-way b-model binding
  self.newTaskTitle := '';
end;

procedure TTodoComponent.RemoveTask(AIndex: Integer);
begin
  // Reactively removes the item at AIndex
  self.tasks.splice(AIndex, 1);
end;
</script>
```

---

## 🧠 Practical Example 3: Computed Properties (`computed:`)

Computed properties are **derived values** that are cached based on their reactive dependencies. They only re-evaluate when one of their source dependencies changes.

### Why use `computed` instead of a regular method?
- **Intelligent Caching**: If you access a computed property multiple times in your template, the calculation runs **only once**.
- **Automatic Dependency Tracking**: BlaiseVue figures out exactly which data variables the computation depends on.

```html
<template>
  <div class="cart-summary">
    <h3>Shopping Cart</h3>
    <p>Subtotal: <strong>${{ subtotal }}</strong></p>
    <p>Tax (10%): <strong>${{ taxAmount }}</strong></p>
    <hr />
    <h4>Total: <strong>${{ formattedTotal }}</strong></h4>
  </div>
</template>

<script>
type
  TCartComponent = class
  public
    data:
      unitPrice: Double = 49.90;
      quantity: Integer = 2;
      taxRate: Double = 0.10;

    computed:
      function subtotal: Double;
      function taxAmount: Double;
      function formattedTotal: String;
  end;

function TCartComponent.subtotal: Double;
begin
  // Cached until unitPrice or quantity changes!
  Result := self.unitPrice * self.quantity;
end;

function TCartComponent.taxAmount: Double;
begin
  Result := self.subtotal * self.taxRate;
end;

function TCartComponent.formattedTotal: String;
var
  LTotal: Double;
begin
  LTotal := self.subtotal + self.taxAmount;
  Result := FormatFloat('0.00', LTotal);
end;
</script>
```

---

## 👁️ Practical Example 4: Watchers (`watch:`)

While `computed:` properties are best suited for calculating synchronous, derived values to display in templates, **`watch:`** is designed to react to state changes and trigger **side effects** (such as HTTP requests, timers, debounced searching, analytics logging, or hardware triggers).

### `computed` vs `watch`: When to use which?
| Feature | Primary Purpose | Caching | Asynchronous / Side Effects |
| :--- | :--- | :--- | :--- |
| **`computed:`** | Calculate derived, formatted, or aggregated data | ✅ Yes (lazy evaluation with dirty-checking) | ❌ No (should be a pure getter function) |
| **`watch:`** | React to state mutations and perform side effects | ❌ No (runs on every mutation) | ✅ Ideal for API calls, timers, storage, sound, DOM effects |

### Runnable Single File Component (`.bv`) Example:
```html
<template>
  <div class="search-widget">
    <h3>Live Autocomplete Search</h3>
    <input type="text" b-model="query" placeholder="Type to search products..." class="search-input" />
    
    <p v-if="isSearching" class="loading">🔍 Querying backend for '{{ query }}'...</p>
    <p v-else class="status">{{ searchLog }}</p>
  </div>
</template>

<script>
  data:
    query: string = '';
    isSearching: Boolean = False;
    searchLog: string = 'Ready. Type above to trigger watcher.';
    searchTimerId: Integer = 0;

  watch:
    procedure query(newVal: JSValue);
    begin
      this['searchLog'] := 'Watcher triggered: value changed to "' + String(newVal) + '"';
      this['isSearching'] := True;

      // Cancel previous timer if user is still typing (pure Pascal debounce)
      if Integer(this['searchTimerId']) <> 0 then
        StopTimeout(Integer(this['searchTimerId']));

      // Schedule the search to execute in 400ms (100% pure Pascal - zero asm!)
      this['searchTimerId'] := StartTimeout(procedure
      begin
        this['isSearching'] := False;
        this['searchLog'] := 'Search completed for: ' + String(newVal);
      end, 400);
    end;
</script>

<style>
  .search-widget { padding: 16px; background: white; border-radius: 8px; border: 1px solid #e2e8f0; }
  .search-input { width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; }
  .loading { color: #0284c7; font-weight: 600; margin-top: 8px; }
  .status { color: #64748b; font-size: 13px; margin-top: 8px; }
</style>
```

### 💡 How BlaiseVue Executes Watchers:
1. During component initialization in `BVCompiler.pas`, each watcher declared under `watch:` is wrapped in an internal reactivity `bv.effect()`.
2. When the component first mounts, the watcher is registered against its reactive dependency without firing (preventing unintended initial side effects).
3. On any subsequent mutation of the watched property (e.g., via user typing, method call, or API response), the registered Pascal procedure runs immediately and receives the new value as `newVal: JSValue`.

---

## 🔍 Deep Reactivity & Nested Objects

BlaiseVue automatically wraps nested objects and records in reactive proxies:

```pascal
data:
  user: record
    profile: record
      name: String;
      email: String;
      settings: record
        darkMode: Boolean;
      end;
    end;
  end;
```

In your template, you can bind directly to nested fields with two-way synchronization:
```html
<input type="text" b-model="user.profile.name" />
<input type="checkbox" b-model="user.profile.settings.darkMode" />
```

Any modification to `user.profile.settings.darkMode` triggers updates only on elements that depend on that specific leaf or branch.

---

## 🧬 Architectural Deep Dive: Under the Hood

For framework contributors, advanced developers, and curious minds, this section details the internal mechanics of the BlaiseVue Reactivity Kernel (`core/BVReactivity.pas`):

### 1. The Track / Trigger Paradigm

```
                   ┌────────────────────────────┐
                   │       Reactive Proxy       │
                   └──────────────┬─────────────┘
                                  │
         ┌────────────────────────┴────────────────────────┐
         │ get(target, key)                                │ set(target, key, val)
         ▼                                                 ▼
┌──────────────────┐                              ┌──────────────────┐
│   bv.track()     │                              │   bv.trigger()   │
│ Registers effect │                              │ Notifies active  │
│ in targetMap     │                              │ effects to rerun │
└──────────────────┘                              └──────────────────┘
```

#### `bv.track(target, key)`
- Invoked automatically during the Proxy's `get` trap when a property is accessed.
- Inspects whether an `activeEffect` is currently executing on top of the effect stack.
- If present, associates the effect with the specific `(target, key)` pair in `targetMap`.
- Uses a `WeakMap<Target, Map<Key, Set<Effect>>>` so unreferenced objects are garbage-collected cleanly without memory leaks.

#### `bv.trigger(target, key)`
- Invoked during the Proxy's `set` trap or array mutator method.
- Looks up all subscribers and effects registered under `(target, key)`.
- Dispatches execution synchronously or enqueues them via microtask batching to avoid redundant DOM re-renders.

### 2. Computed Lifecycle State Machine
Computed properties implement a **Lazy Evaluation** pattern:
1. **Initial Access**: The getter executes inside a dedicated computation effect.
2. **Caching**: The computed instance records the result and flags itself as `dirty = false`.
3. **Dirty Invalidation**: When any dependency referenced inside the getter changes, `trigger` flags `dirty = true` without calculating immediately.
4. **Subsequent Read**: The next time the template reads the property, if `dirty = true`, it re-computes and caches the new value. If `dirty = false`, it returns the cached result in `O(1)` time.

---

## 🎯 Best Practices for High-Performance State

1. **Prefer `computed` over Methods for Derived State**: Always use `computed:` when deriving calculations or formatting strings from existing data.
2. **Mutate Arrays in-place**: Use `.push()`, `.splice()`, etc., instead of full array reassignments whenever possible.
3. **Use Zero-ASM Helpers (`BVPascalDX`)**: When interacting with complex JavaScript objects or JSON payloads, use strongly typed routines like `GetProp`, `SetProp`, and `HasProp` provided by `BVPascalDX`.
4. **Scope Your Data**: Keep component `data:` scoped strictly to the fields required by the component's UI and business logic. 🛡️✨🏆
