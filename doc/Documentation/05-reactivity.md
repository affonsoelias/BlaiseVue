# 🛡️ Technical Specification: Reactivity Engine

BlaiseVue implements a **Dependency-Tracking** reactivity system based on ES6 Proxies, eliminating the need for a Virtual DOM for simple state updates.

---

## 🧬 The Track/Trigger Paradigm

### 1. `bv.track(target, key)`
Invoked during the Proxy's `get` trap.
- Checks if there is an `activeEffect` at the top of the stack.
- If so, registers the effect in the `targetMap` associated with the `target/key` pair.
- Uses a `WeakMap` to avoid memory leaks from destroyed objects.

### 2. `bv.trigger(target, key)`
Invoked during the Proxy's `set` trap or array mutation.
- Locates all effects (Subscribers) registered for that `target/key`.
- Executes the effects synchronously (or via Batching if enabled).

---

## 🧪 Internal Data Structure (pseudo-JS)
```javascript
targetMap = new WeakMap<Target, Map<Key, Set<Effect>>>();
```

## 🧠 Computed Lifecycle
Computed properties in BlaiseVue are "Lazy" and "Cached":
1. On the first access, the `getter` is executed inside a special `effect`.
2. The `effect` marks the property as `dirty = false`.
3. Any change in the `getter` dependencies triggers the `trigger`, which only marks the property as `dirty = true` (without recalculating immediately).
4. The next access to the `getter` notices the `dirty` state and performs the recalculation.

---

## ⚡ Array Mutation
BlaiseVue overrides native mutator methods (`push`, `pop`, `splice`, etc.) to fire the `trigger` on the `length` property, forcing the re-rendering of `b-for` directives. 🛡️✨🏆
