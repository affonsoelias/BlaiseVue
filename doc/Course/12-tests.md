# 🎓 Module 12: Martial Quality (Unit Testing)
**The Sword that Never Fails: Your Logic Validated.**

In this module, you will learn how to ensure your BlaiseVue code works even before you open the browser. A true Ninja doesn't just trust their eyes; they trust their tests!

---

### 🛡️ Why test in Pascal?
Unlike other frameworks, in BlaiseVue you write tests in the backend language itself: **Object Pascal**. 

This ensures that when validating the behavior of a `.bv` component, you are testing the exact transpiled logic that will be sent to the end user.

---

### 🔥 The Sacred Command
To run your tests, use:
```bash
bv test
```

This command:
1.  **Observes**: Finds all `.test.pas` files in the `tests/` folder.
2.  **Transpiles**: Ensures the components used in the tests are updated.
3.  **Executes**: Invokes Vitest and shows passes and failures in the terminal.

---

### 📝 Structure of a Ninja Test

```pascal
program my_test;
uses JS, Web, BVTestUtils, uMyComponent;

begin
  Register_uMyComponent; // Important!

  Describe('My Component', procedure
    begin
       It('should start with a clean state', procedure
         begin
            var Wrapper := Mount('my-component');
            Expect(Wrapper.Text).ToContain('Empty');
         end);
    end);
end.
```

---

### ⚔️ Quality Challenge
1.  Create a `TodoList` component.
2.  Write a test that simulates adding an item.
3.  Verify the item appears in the DOM list using `Wrapper.Text`.

🛡️ **Be persistent. Tests save lives (and sleepless nights)!**  
✨🚀🏆
