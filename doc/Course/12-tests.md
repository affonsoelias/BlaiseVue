# 🎓 Module 12: Fearless Unit Testing
**The sword that never fails: validate your business logic before releasing to production.**

Have you ever tweaked a single line of code, only to accidentally break something that was previously working in an entirely different part of the application? In software engineering, this is known as a **Regression**.

To code with confidence and peace of mind, professional developers use **Automated Unit Tests**!

---

## ✈️ 1. What is a Unit Test? (The Airplane Pre-Flight Analogy)

Before any passenger jet takes off, the flight crew goes through a rigorous pre-flight checklist:
- Are the navigation lights working? *Check.*
- Are the brakes responding properly? *Check.*
- Is fuel pressure nominal? *Check.*

A **Unit Test** is that automated checklist for your software! It executes all your critical calculations, components, and workflows in seconds and alerts you immediately if any calculation produces an unexpected result.

Best of all: in BlaiseVue, **you write your tests in native Object Pascal**!

---

## 🔬 2. Anatomy of a Test in Pascal

Test files in BlaiseVue live inside the `tests/` folder with the file extension `name.test.pas`. They are structured into three intuitive blocks:

1. **`Describe`**: Declares what component or feature is under test.
2. **`It`**: Describes the specific behavior you expect to happen.
3. **`Expect`**: The final verification! *"I expect the count to be 0"*, *"I expect the text to contain 'Success'"*.

Look how clean and readable it is:

```pascal
program counter_test;
uses JS, Web, BVTestUtils, uMyCounter;

begin
  Register_uMyCounter; // Registers the component for the test harness

  Describe('My Counter Component', procedure
  begin
    
    // Test 1: Verify the initial state
    It('should start with zero points', procedure
    var
      Wrapper: TBVWrapper;
    begin
      Wrapper := Mount('my-counter'); // Mounts the component into an in-memory DOM
      Expect(Wrapper.Text).ToContain('0'); // Verifies that 0 is physically present!
    end);

  end);
end.
```

---

## 🚀 3. Step-by-Step: Running Tests with the `bv` CLI

Running your entire test suite is as simple as typing one command in your terminal:

```bash
bv test
```

### What Happens Under the Hood:
1. The CLI scans for all `.test.pas` files across your project.
2. It compiles the Pascal test sources and transpiles the required components.
3. It runs the Vitest execution engine and outputs clear green pass indicators:
   ```text
   ✓ demo-app/generated/tests/components/Counter.test.js (1 test) 8ms
   ✓ demo-app/generated/tests/views/Home.test.js (3 tests) 15ms

   Test Files  2 passed (2)
        Tests  4 passed (4)
     Duration  1.20s
   ```

If a test ever fails (e.g. if a calculation was expected to be `100` but returned `80`), the terminal reports the exact line number where the discrepancy occurred.

---

## 🎯 4. Practical Exercise: Module 12

1. Open your terminal in the BlaiseVue directory.
2. Run `bv test`.
3. Watch all the framework's unit tests run and pass (`365 passed`).
4. **Thought experiment**: Think about the free shipping feature from Module 05. How would you write a test verifying that an order of `$ 120.00` correctly displays `'FREE SHIPPING'`? Writing that test ensures no future coupon changes will ever break your shipping rules!

---

## 🏆 What You Learned Today
- Why automated tests eliminate the fear of refactoring.
- The anatomy of a Pascal test with `Describe`, `It`, and `Expect`.
- How to execute your test battery with a single command: `bv test`.

**You have reached the pinnacle of your training! It is time to assemble everything into a production-grade application in [Module 13: The Final Challenge](13-final-challenge.md)!** ⚔️🛡️✨
