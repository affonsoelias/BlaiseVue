# 🔄 Module 04: Synchronization and b-model
**The Dialogue between Input and Pascal.**

The **`b-model`** directive is like a "two-way mirror" between what the user types on the screen and the variable in your Pascal code.

## ⚔️ b-model: Total Synchrony
Whenever the user types in an input with `b-model`, the corresponding Pascal variable will be updated.

```html
<label>Your Name:</label>
<input type="text" b-model="userName">
<div class="alert">
  Hi master, {{ userName }}! (Instant change!)
</div>
```

---

**The Rule of Synchrony:**
The `b-model` is not magic; it is a reactive bridge. It handles both the initial value and continuous updates, allowing you to validate data in real-time in Pascal! 🛡️✨🏆

---

**Next Step: Save effort with reactive formulas in Module 05!** 🧠✨
