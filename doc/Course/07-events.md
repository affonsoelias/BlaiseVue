# 🛰️ Module 07: Communication and Events ($emit)
**Making Your Component Be Heard.**

In BlaiseVue, child components talk to their parents through **Custom Events**.

## ⚔️ The Methods Block
Define your Pascal procedures that will be called by clicks or inputs:
```pascal
  methods:
    procedure notifyParent;
    begin
      // The Child's Cry
      TJSFunction(this['$emit']).apply(this, ['important-event', 'Hi Dad!']);
    end;
```

## 👁️ Listening to the Event
In the parent component, you listen to the event with @:
```html
<child-component @important-event="onChildNotified"></child-component>
```

---

**The Rule of the Voice:**
Component communication should always be:
- **Props:** From Parent to Child.
- **Events ($emit):** From Child to Parent. ✨🛡️✨

---

**Next Step: Become a page explorer in Module 08!** ⚔️
