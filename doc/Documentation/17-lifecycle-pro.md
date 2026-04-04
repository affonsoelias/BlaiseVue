# 🔄 Advanced Lifecycle (Pro Lifecycle)

BlaiseVue PRO offers full control over a component's existence, from birth (initialization) to death (destruction), through synchronous and asynchronous lifecycle hooks.

---

## 🏛️ The Engine Beat (Hooks in Order)

| Hook | When It Occurs? | DOM State | Typical Usage |
| :--- | :--- | :--- | :--- |
| **`created`** | Data and reactivity injected. | ❌ Non-existent | Set up B-Store, format initial arrays. |
| **`mounted`** | Component inserted into the document. | ✅ Ready | Initialize Chart.js, Maps, or access `$refs`. |
| **`updated`** | After the DOM is altered by data. | ✅ Updated | Record audit logs or synchronize complex states. |
| **`unmounted`** | Component removed via `b-if` or Route. | ❌ Destroyed | Clear `setInterval`, remove `window` listeners. |

---

## ⚙️ Hook Details

### 1. `created` Hook: The First Breath
At this stage, the compiler has already hydrated the `data:` object, but the HTML has not yet been generated. **Never try to access the DOM here!**

```pascal
created:
  begin
     { Perfect for fetching initial data or configuring the Store }
     TJSObject(this['$store'])['lastVisit'] := Date.now();
  end;
```

### 2. `mounted` Hook: Full DOM Access
When this hook is called, the component is already rendered. It is the safe moment to interact with the real HTML element through references (`$refs`).

```pascal
mounted:
  begin
     { Access the native element behind the b-ref }
     asm 
       const ctx = this.$refs.canvasElement.getContext('2d');
       // Initialize your favorite JS library here!
     end;
  end;
```

### 3. `updated` Hook: Reactivity in Action
Called whenever the reactivity engine detects a change and finishes the visual update on the screen.

```pascal
updated:
  begin
     asm console.log("[Lifecycle] UI reflected the new state change."); end;
  end;
```

### 4. `unmounted` Hook: Cleanup and Farewell
BlaiseVue PRO automatically destroys all reactivity watchers (`Effects`) and removes the component from the tree. **Use this hook to avoid memory leaks.**

```pascal
unmounted:
  begin
     { Stop timers created by the component }
     asm clearInterval(this.myTimerId); end;
     asm console.log("[Lifecycle] Component unmounted successfully."); end;
  end;
```

---

## 🛡️ BlaiseVue PRO Automatic Management
Unlike the Standard version, the **Pro Engine** performs a Deep Cleanup when unmounting:
- **Leak Detection**: Stops orphaned reactive effects.
- **Auto-Reference Wipe**: Clears the `$refs` dictionary to free up RAM in the browser.

---
_"BlaiseVue: Robustness from spawn to despawn."_ 🛡️✨🔄🏆
