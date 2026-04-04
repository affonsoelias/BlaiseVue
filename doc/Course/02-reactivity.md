# 🧬 Module 02: The Reactive Engine
**Data that has its own life.**

BlaiseVue uses **JavaScript Proxies (vanguards)** that function as sentinels around your Pascal state. Whenever a variable is touched, the system "fires" a notification to the compiler to update what is necessary.

---

## 📝 Declaring Reactive Data
In your `.bv` component (the SFC file), you define your data like this:
```pascal
  data:
    name: string = 'Blaise';
    active: boolean = true;
    items: TJSArray = TJSArray.new;
```

## 👁️ Change Tracking
By doing:
```pascal
this['name'] := 'Pascal';
```
The Proxy notices the change and triggers the **"Reactive Trigger"**. BlaiseVue knows exactly which HTML element depends on the variable `name` and updates it in milliseconds. ✨🛡️✨

---

**Watch out!** Never use global variables in Pascal for the screen state; always define them in the `data:` section of the component so that the reactive engine can "embrace" them.

**Next Step: How to control what the user sees (Module 03)!** ⚔️
