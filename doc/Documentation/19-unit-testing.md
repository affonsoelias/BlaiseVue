# 🧪 PRO Unit Testing Module

BlaiseVue 1.0 PRO includes a native testing engine written in Pascal, integrated with **Vitest** and **JSDOM**, allowing for the validation of SFC components with the same ease as modern frameworks like Vue/React.

---

## 🏗️ Test Lifecycle (Pascal TDD)

1.  **Creation**: Use the command `bv new t MyComponent`.
2.  **Transpilation**: The CLI transpiles `.bv` -> `.pas` in `generated/`.
3.  **Execution**: The `bv test` command compiles the test Pascal to JS and runs it in Node.js.

---

## 📝 Reactive Test Example

Tests in BlaiseVue are asynchronous by nature due to the reactivity cycle. Use `WaitTick` to ensure the DOM has been updated after a state change.

```pascal
program counter_test;

uses JS, Web, BVTestUtils, uCounter;

begin
  { 1. Register the component so the compiler recognizes it in the Virtual DOM }
  Register_uCounter;

  Describe('Feature: Reactive Counter', procedure
    var
      Wrapper: TWrapper;
    begin
       It('should increment the value and update the DOM', procedure
         begin
            { 2. Mount the component on the 'u-counter' tag }
            Wrapper := Mount('u-counter');

            { 3. Simulate interaction: Find the button and click it }
            Wrapper.Find('button').click();

            { 4. IMPORTANT: Wait for the reactivity cycle (Tick) }
            WaitTick;

            { 5. Final assertion on the updated DOM }
            Expect(Wrapper.Text).ToContain('Value: 1');
         end);
    end);
end.
```

---

## 🛠️ Testing API (BVTestUtils)

### 🧩 Mounting and Selection
| Method | Description |
|--------|-----------|
| `Mount(TagName)` | Creates the component in JSDOM and returns a `TWrapper`. |
| `Wrapper.Find(Selector)` | Returns the first `TJSHTMLElement` matching the selector. |
| `Wrapper.FindAll(Selector)` | Returns an array of elements. |

### ⌨️ Interaction
| Method | Description |
|--------|-----------|
| `Wrapper.Click(Selector)` | Shortcut to trigger the click event on an element. |
| `Wrapper.Fill(Selector, Val)` | Fills an input and triggers the reactive `input` event. |
| `WaitTick` | Pauses test execution until the reactivity engine processes pending jobs. |

### ⚖️ Assertions (Expect)
| Assertion | Description |
|----------|-----------|
| `.ToEqual(val)` | Strict equality (JS ===). |
| `.ToContain(str)` | Checks if the string or HTML contains the fragment. |
| `.ToBeTrue / .ToBeFalse` | Fast boolean validations. |

---

## 🚀 Useful Commands
- **`bv new t MyTest`**: Creates the initial template in `tests/MyTest.test.pas`.
- **`bv test`**: Executes all tests in the `tests/` folder.
- **`bv test --watch`**: Keeps tests running and re-executes on every code change.

---
🛡️ **"Code is cheap, tests are gold."** ✨🧪🏆
