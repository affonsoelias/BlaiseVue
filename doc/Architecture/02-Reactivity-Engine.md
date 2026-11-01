# 🧠 Deep Dive: The Reactivity Engine
**How BlaiseVue tracks dependencies and updates the DOM.**

At the heart of BlaiseVue is the **TBVProxy** class. It is the framework's "secret sauce" that allows Pascal variables to trigger DOM updates automatically.

---

## 1. The Power of JS Proxy
BlaiseVue uses the **JavaScript Proxy** object to wrap your `data:` section. 
When you write `this['counter'] := 1`, you are not writing to a standard object; you are interacting with a Proxy trap.

### The 'Get' Trap: Dependency Tracking
When a component is rendered, it "reads" the variables it needs. 
- During render, the `BVActiveEffect` is set.
- Every variable the render function reads records that effect as a "subscriber."
- This is called **Automatic Dependency Collection**.

### The 'Set' Trap: Triggering Updates
When you modify a variable:
1. The Proxy `set` trap is called.
2. It looks at its list of subscribers (Effects) for that specific key.
3. It pushes those Effects into the **Job Scheduler** (Core/BVReactivity.pas).

---

## 2. The Scheduler (Efficient Updates)
One major performance optimization in BlaiseVue is that updates are **Asynchronous**. 
If you update `this['counter']` 100 times in a loop, the component only re-renders **once**.

- **Mechanism**: The Scheduler uses `Promise.resolve().then()` to batch all updates into a single microtask.
- **Queue**: A `TJSSet` is used to keep the job list unique, ensuring that the same component never re-renders more than once per frame.

---

## 3. How to Contribute to Reactivity
If you want to improve the engine, look at `core/BVReactivity.pas`:
1. **`Track(Target, Key)`**: The heart of dependency collection.
2. **`Trigger(Target, Key)`**: The engine's notification system.
3. **`TBVEffect`**: The class that encapsulates reactive functions.

---
🛡️ **Next Lesson:** The Compiler Pipeline: SFC to Pascal to JS.
