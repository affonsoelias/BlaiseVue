# 👁️ Module 09: $refs and Lifecycle
**Grabbing Everything on Screen.**

In BlaiseVue, the engine handles most screen changes, but if you need to touch an element directly (like focusing on an input or talking to a child component), you use **`$refs`**.

## ⚔️ The b-ref Directive
Add the directive to the HTML:
```html
<input type="text" b-ref="myInput">
<main-header b-ref="theHeader"></main-header>
```

## 👁️ Master Touch in Script
Access them in your Pascal code like this:
```pascal
procedure focus;
begin
  TJSObject(this['$refs'])['myInput'].focus();
end;
```

---

**The Sacred Times (Lifecycle):**
- **`created`**: Data already exists in Pascal, but the screen is still a secret.
- **`mounted`**: The screen shines and your code can now talk to the HTML! ✨🛡️✨

---

**Next Step: The Final Command in Module 10!** ⚔️
