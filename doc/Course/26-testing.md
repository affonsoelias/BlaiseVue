# 🧪 Module 26: Unit & E2E Testing Automation
**Code with supreme confidence: automated Pascal unit tests and headless browser end-to-end testing.**

Have you ever made a small tweak to a calculation or button handler, only to accidentally break a critical business workflow somewhere else in your application? In software engineering, this is known as a **Regression**.

To eliminate regressions and ship with total peace of mind, professional developers write **Automated Tests**.

In BlaiseVue, you don't need to learn a foreign testing framework. You write your unit tests in **native Object Pascal**, execute them in seconds with **`bv test`**, and run full browser integration flows with **`bv test e2e`**!

---

## 🔬 1. Anatomy of a Pascal Unit Test

Test files live in the `tests/` directory with the extension `*.test.pas`. They are structured using the intuitive BDD (Behavior-Driven Development) pattern:

1. **`Describe`**: Declares what unit or feature is under test.
2. **`It`**: Describes the expected behavior in plain English.
3. **`Expect`**: The final verification assertion (`ToEqual`, `ToBeGreaterThan`, `ToContain`, `IsTrue`).

```pascal
program order_calculator_test;

uses JS, SysUtils, BVTestUtils;

// A simple Pascal business function
function CalculateTax(Subtotal: Double; TaxRate: Double): Double;
begin
  Result := Subtotal * TaxRate;
end;

begin
  Describe('Order Tax Engine', procedure
  begin
    It('should calculate 10% tax accurately', procedure
    var
      Tax: Double;
    begin
      Tax := CalculateTax(100.00, 0.10);
      Expect(Tax).ToEqual(10.00);
    end);

    It('should handle zero tax rate without errors', procedure
    var
      Tax: Double;
    begin
      Tax := CalculateTax(500.00, 0.0);
      Expect(Tax).ToEqual(0.0);
    end);
  end);
end.
```

---

## 🖥️ 2. Component Testing with `Mount` & `TBVWrapper`

How do you test a visual `.bv` Single File Component without opening a browser?

BlaiseVue mounts components into an ultra-fast, in-memory DOM (**JSDOM**):

```pascal
program counter_component_test;

uses JS, Web, BVTestUtils, uMyCounter;

begin
  Register_uMyCounter;

  Describe('My Counter Component', procedure
  begin
    It('starts with zero points', procedure
    var
      Wrapper: TBVWrapper;
    begin
      Wrapper := Mount('my-counter');
      Expect(Wrapper.Text).ToContain('Points: 0');
    end);

    It('increments counter on button click', procedure
    var
      Wrapper: TBVWrapper;
    begin
      Wrapper := Mount('my-counter');
      
      // Simulate physical button click
      Wrapper.Find('button.btn-increment').Trigger('click');
      
      // Assert reactive update
      Expect(Wrapper.Text).ToContain('Points: 1');
    end);
  end);
end.
```

---

## 🏃 3. Running Unit Tests with `bv test`

Execute your entire test hierarchy with a single command:

```bash
bv test
```

The CLI compiles all `tests/**/*.test.pas` files and reports instant results:

```text
=== BlaiseVue Automated Testing Engine ===
Compiling and executing 4-tier Pascal test suites...

 ✓ tests/services/order_calculator.test.pas (2 tests) 14ms
 ✓ tests/components/counter_component.test.pas (2 tests) 28ms
 ✓ tests/stores/CartStore.test.pas (3 tests) 21ms

 Test Files  3 passed (3)
      Tests  7 passed (7)
   Duration  63ms
```

---

## 🌐 4. Headless End-to-End Testing (`bv test e2e`)

While unit tests verify isolated functions and components, **End-to-End (E2E) Tests** simulate real user journeys across the entire application:
- Clicking navigation links through the HTML5 History router.
- Filling out multi-step forms and submitting them.
- Validating error badges when `b-validate` detects invalid input.
- Verifying that theme choices survive page refreshes.

To execute the headless browser integration suite, run:

```bash
bv test e2e
```

Output:
```text
=== BlaiseVue Headless E2E Test Suite ===
Executing end-to-end user journeys (Routing, Forms, Themes, Hydration)...

  ✓ Navigation: navigates between Home and Products without reload
  ✓ Form Validation: displays error on invalid email and enables submit on valid input
  ✓ Auth Guard: intercepts /admin route and redirects unauthenticated user to /login
  ✓ Reactive Hydration: engages zero-flicker client hydration over pre-rendered SSG

  Test Files  1 passed (1)
       Tests  4 passed (4)
```

---

## 📂 5. The 4-Tier Enterprise Testing Structure

Every BlaiseVue project organizes tests into four clean tiers:

```text
my-app/
├── src/                     <- Application source code
└── tests/
    ├── services/            <- Pure Pascal business rules, tax logic & DTOs
    ├── components/          <- Isolated visual components (props, slots, events)
    ├── views/               <- Full page user journeys (forms, CRUD modals)
    └── framework/           <- Core runtime verification (Reactivity, Routing, FSM)
```

---

## 🏋️ Practical Exercise

1. Create a service file `src/services/DiscountCalculator.pas` with a function `CalculateDiscount(Total: Double; IsVIP: Boolean): Double`. VIPs get 20% off; non-VIPs get 5% off for orders over \$100.
2. In `tests/services/DiscountCalculator.test.pas`, write three `It()` blocks testing VIP discounts, regular customer discounts, and small orders.
3. Run `bv test` in your terminal and verify that all three tests pass with green checkmarks!
4. Intentionally introduce a bug in your calculation function, run `bv test` again, and observe how the test harness catches the error immediately with exact lines!
5. Revert the bug and run `bv test e2e` to verify full integration health.

---

## 📖 Deeper Technical Reference

- **[Automated Testing Engine Manual](../Documentation/19-unit-testing.md)**: Exhaustive manual on `TBVWrapper`, DOM query selectors, mock HTTP responses, and async testing patterns.
- **[Headless End-to-End Test Suite Manual](../Documentation/33-e2e-testing.md)**: Configuring headless Chromium runners, network interception, and CI/CD test automation.

---

[⬅️ Module 25: Visual Development with Blaise Studio](25-studio.md) | [🏠 Course Index](README.md) | [Module 27: Micro-Containers, CI/CD & Deployment ➡️](27-deployment.md)
