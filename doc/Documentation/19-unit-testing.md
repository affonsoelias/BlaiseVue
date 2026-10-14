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
| `Mount(TagName, Props = nil)` | Creates the component in JSDOM, compiles reactive bindings, and returns a `TWrapper`. |
| `Wrapper.Find(Selector)` | Returns the matching `TJSHTMLElement` (or child node) matching the CSS selector. |
| `Wrapper.Element` | Returns the underlying root `TJSHTMLElement` of the mounted component. |
| `Wrapper.HTML` | Returns the `innerHTML` string of the component. |
| `Wrapper.Text` | Returns the `textContent` string of the component. |

### ⌨️ Interaction
| Method | Description |
|--------|-----------|
| `Wrapper.Click` | Simulates a native mouse click on the wrapper element. |
| `Wrapper.Find(sel).click()` | Triggers a native click on a queried sub-element. |
| `Wrapper.SetValue(Val)` | Sets an input's `value` and dispatches the reactive `'input'` DOM event. |
| `Wrapper.Trigger(EventName)` | Dispatches a custom DOM event (`'click'`, `'change'`, `'blur'`, etc.) on the element. |
| `WaitTick` | Pauses test execution until the microtask reactivity queue processes pending jobs. |

### ⚖️ Assertions (Expect)
| Assertion | Description |
|----------|-----------|
| `.ToBe(val)` | Strict equality assertion (`expect(a).toBe(b)`). |
| `.ToEqual(val)` | Deep value equality assertion (`expect(a).toEqual(b)`). |
| `.ToContain(str)` | Checks if the string, array, or HTML contains the fragment. |
| `.ToHaveLength(len)` | Validates string or array length. |
| `.ToBeTruthy` | Asserts value is truthy. |
| `.ToBeFalsy` | Asserts value is falsy. |
| `.ToBeDefined` | Asserts value is defined. |
| `.ToBeUndefined` | Asserts value is undefined. |
| `.ToBeNull` | Asserts value is null. |

---

## 🚀 Useful Commands
- **`bv new t MyTest`**: Creates the initial template in `tests/MyTest.test.pas`.
- **`bv test`**: Executes all tests in the `tests/` folder.
- **`bv test --watch`**: Keeps tests running and re-executes on every code change.

---
🛡️ **"Code is cheap, tests are gold."** ✨🧪🏆
