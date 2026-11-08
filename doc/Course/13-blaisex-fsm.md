# 🧩 Module 13: BlaiseX 2.0 & Finite State Machines
**Master global application state, atomic mutations, undo/redo time-travel, and mathematical state machines.**

In smaller applications, managing state inside individual components works fine. But as your enterprise web application grows to dozens of views—such as a shopping cart shared across a navbar, checkout modal, inventory tracker, and order history—passing properties back and forth becomes unmaintainable ("prop drilling").

Furthermore, business logic often suffers from **impossible states**:
- Can an order be shipped *before* payment is captured?
- Can a user click "Submit Order" twice and get charged twice?
- Can a cancelled invoice be refunded?

In BlaiseVue, we solve both challenges elegantly with **BlaiseX 2.0** (`TBVStore 2.0`) and **Finite State Machines** (`BVFSM`).

---

## 🛠️ 1. Scaffolding a Store Slice with the CLI

Instead of writing store boilerplate manually, the BlaiseVue CLI provides dedicated code generators:

```bash
# Generate a new store slice and its companion unit test
bv g store Cart

# Alias: bv new store Cart
```

This command instantly creates two files:
1. `src/stores/uCartStore.pas`: The strongly-typed store slice with state, mutations, getters, and actions.
2. `tests/stores/CartStore.test.pas`: An automated test suite ready for `bv test`.

---

## 🔬 2. Anatomy of a BlaiseX Store Slice

A store slice isolates state into a named domain (e.g., `cart`, `auth`, `billing`) to prevent cross-domain pollution.

Let's look at `src/stores/uCartStore.pas`:

```pascal
unit uCartStore;

{$mode objfpc}{$H+}

interface

uses
  JS, SysUtils, BVStore;

function InitCartStore: TBVStoreSlice;

implementation

function InitCartStore: TBVStoreSlice;
var
  InitialState: TJSObject;
begin
  // 1. Initial State Definition
  InitialState := TJSObject.new;
  InitialState['items'] := TJSArray.new;
  InitialState['count'] := 0;
  InitialState['price'] := 25.00;

  // 2. Register Store Slice with Declarative Builder
  Result := DefineStore('cart', InitialState)
    // Synchronous atomic mutations
    .Mutation('increment', procedure(AState, APayload: JSValue)
      begin
        TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) + 1;
      end)
    .Mutation('decrement', procedure(AState, APayload: JSValue)
      begin
        if Integer(TJSObject(AState)['count']) > 0 then
          TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) - 1;
      end)
    .Mutation('reset', procedure(AState, APayload: JSValue)
      begin
        TJSObject(AState)['count'] := 0;
      end)

    // Derived / Computed Getters
    .Getter('totalPrice', function(AState: JSValue): JSValue
      begin
        Result := Integer(TJSObject(AState)['count']) * Double(TJSObject(AState)['price']);
      end)

    // Asynchronous Actions & Business Workflows
    .Action('checkout', function(ACtx, APayload: JSValue): JSValue
      begin
        // Commit mutations or execute async HTTP/RPC calls here
        TBVStoreSlice(TJSObject(ACtx)['slice']).Commit('reset');
        Result := 'CHECKOUT_SUCCESS';
      end);
end;

initialization
  InitCartStore;

end.
```

### 🧠 Core Concepts:
- **State**: The reactive single source of truth for this domain.
- **Mutations**: Synchronous, atomic functions that are the *only* approved way to alter state.
- **Getters**: Pure functions that derive cached values from state (like `computed` properties, but global).
- **Actions**: Methods that handle asynchronous logic (fetching data, calling APIs) and then `Commit` mutations.

---

## ⏪ 3. Time-Travel Debugging (Undo / Redo)

Every atomic mutation executed through BlaiseX records a state snapshot in an internal circular buffer:

```pascal
var
  Cart: TBVStoreSlice;
begin
  Cart := GetStore('cart');
  Cart.Commit('increment'); // count becomes 1
  Cart.Commit('increment'); // count becomes 2

  Cart.Undo; // count safely rolls back to 1!
  Cart.Undo; // count rolls back to 0!
  Cart.Redo; // count steps forward to 1!
end;
```

In the browser console, developers can inspect and travel through state at runtime:
```javascript
window.__BLAISEX_DEVTOOLS__.getHistory('cart');
window.__BLAISEX_DEVTOOLS__.undo('cart');
window.__BLAISEX_DEVTOOLS__.redo('cart');
```

---

## 🚦 4. Finite State Machines (`BVFSM`)

Why do enterprise systems crash or behave erratically? Usually because an interface reached an **illegal state combination** (e.g., `isLoading = true` while `hasError = true` and `isSuccess = true`).

A **Finite State Machine (FSM)** mathematically guarantees that:
1. The system can only be in **exactly one state** at any given moment.
2. Transitions between states only occur when specific **Events** are sent.
3. Transitions can be protected by conditional **Guards**.

### Scaffolding an FSM:
```bash
# Generate a state machine and test
bv g fsm OrderFlow

# Alias: bv new fsm OrderFlow
```

Generated machine file (`src/machines/uOrderFlowMachine.pas`):

```pascal
unit uOrderFlowMachine;

{$mode objfpc}{$H+}

interface

uses
  JS, SysUtils, BVFSM;

function CreateOrderFlowMachine: TBVStateMachine;

implementation

function CreateOrderFlowMachine: TBVStateMachine;
begin
  Result := TBVStateMachine.Create('OrderFlow')
    .Initial('cart')
    // Define states and permissible event transitions
    .State('cart')
      .On('CHECKOUT', 'processing')
    .State('processing')
      .On('PAYMENT_CONFIRMED', 'completed')
      .On('PAYMENT_FAILED', 'failed')
    .State('completed')
      .On('RESET', 'cart')
    .State('failed')
      .On('RETRY', 'processing')
      .On('RESET', 'cart')
    .Machine;
end;

end.
```

With this machine in place, if the order is currently in `cart`, sending `PAYMENT_CONFIRMED` is completely ignored! The only valid path is `cart` ➔ `CHECKOUT` ➔ `processing` ➔ `PAYMENT_CONFIRMED` ➔ `completed`.

---

## 🔗 5. Attaching FSM to a Store Slice & Using in `.bv` Components

You can attach a state machine directly to your store slice:

```pascal
OrderSlice := DefineStore('order', InitialState)
  .AttachMachine('flow', CreateOrderFlowMachine);
```

Now, let's create a complete `.bv` view that interacts with the Store and the FSM:

```html
<template>
  <div class="checkout-container">
    <h2>🛍️ Enterprise Checkout</h2>

    <!-- Reactive Store State -->
    <div class="cart-summary">
      <p>Items in Cart: <strong>{{ $store.cart.count }}</strong></p>
      <p>Total Amount: <strong>${{ $store.cart.totalPrice }}</strong></p>
      <p>Order Flow Status: <span class="badge">{{ $store.order.flow.current }}</span></p>
    </div>

    <!-- Store Atomic Controls -->
    <div class="button-group">
      <button @click="$blaisex.Commit('cart/increment')">➕ Add Item</button>
      <button @click="$blaisex.Commit('cart/decrement')">➖ Remove Item</button>
      <button @click="$blaisex.Undo('cart')">↩️ Undo</button>
      <button @click="$blaisex.Redo('cart')">↪️ Redo</button>
    </div>

    <!-- State Machine Driven Workflow -->
    <div class="workflow-controls">
      <button 
        b-if="$store.order.flow.current = 'cart'" 
        @click="startCheckout"
        class="btn-primary">
        Proceed to Checkout
      </button>

      <div b-if="$store.order.flow.current = 'processing'" class="processing-panel">
        <p>💳 Processing Payment...</p>
        <button @click="confirmPayment" class="btn-success">Simulate Bank Approval</button>
        <button @click="failPayment" class="btn-danger">Simulate Card Declined</button>
      </div>

      <div b-if="$store.order.flow.current = 'completed'" class="alert-success">
        🎉 Order successfully paid and registered!
        <button @click="resetFlow">Start New Order</button>
      </div>

      <div b-if="$store.order.flow.current = 'failed'" class="alert-danger">
        ⚠️ Payment was declined.
        <button @click="retryPayment">Try Again</button>
        <button @click="resetFlow">Cancel</button>
      </div>
    </div>
  </div>
</template>

<script>
uses BVPascalDX;

methods:
  procedure startCheckout;
  var
    FSM: TBVStateMachine;
  begin
    FSM := UseFSM('order', 'flow');
    if Integer(StoreGet('cart/count')) > 0 then
      FSM.Send('CHECKOUT')
    else
      ShowMessage('Your cart is empty!');
  end;

  procedure confirmPayment;
  var
    FSM: TBVStateMachine;
  begin
    FSM := UseFSM('order', 'flow');
    FSM.Send('PAYMENT_CONFIRMED');
    StoreDispatch('cart/checkout');
  end;

  procedure failPayment;
  var
    FSM: TBVStateMachine;
  begin
    FSM := UseFSM('order', 'flow');
    FSM.Send('PAYMENT_FAILED');
  end;

  procedure retryPayment;
  begin
    UseFSM('order', 'flow').Send('RETRY');
  end;

  procedure resetFlow;
  begin
    UseFSM('order', 'flow').Send('RESET');
  end;
</script>

<style>
.checkout-container {
  max-width: 550px;
  margin: 30px auto;
  padding: 24px;
  border-radius: 12px;
  background: #ffffff;
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
  font-family: sans-serif;
}
.badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  background: #e0e7ff;
  color: #3730a3;
  font-weight: bold;
}
.button-group, .workflow-controls {
  margin-top: 18px;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
button {
  padding: 8px 14px;
  border: 1px solid #ccc;
  border-radius: 6px;
  cursor: pointer;
}
.btn-primary { background: #2563eb; color: #fff; border: none; font-weight: bold; }
.btn-success { background: #16a34a; color: #fff; border: none; font-weight: bold; }
.btn-danger { background: #dc2626; color: #fff; border: none; font-weight: bold; }
.alert-success { background: #dcfce7; color: #166534; padding: 12px; border-radius: 6px; width: 100%; }
.alert-danger { background: #fee2e2; color: #991b1b; padding: 12px; border-radius: 6px; width: 100%; }
</style>
```

---

## 📋 6. Inspecting, Renaming, and Cleaning Slices via CLI

The BlaiseVue CLI gives you total clarity over all state slices and machines configured in your project:

```bash
# List all registered store slices
bv list store

# List all registered finite state machines
bv list fsm

# Smart rename a store slice across files and unit tests:
bv rename store Cart ShoppingCart

# Smart rename a finite state machine across files and unit tests:
bv rename fsm OrderFlow CheckoutFlow

# Safely remove a store slice and its companion test
bv remove store ShoppingCart

# Safely remove an FSM and its companion test
bv remove fsm CheckoutFlow
```

---

## 🏋️ Practical Exercise

1. Run `bv g store UserSession` in your terminal to create a session store.
2. In `src/stores/uUserSessionStore.pas`, declare state for `currentUser` (string) and `isLoggedIn` (boolean).
3. Create a mutation `login(name)` and a mutation `logout`.
4. In your application header component, bind a login badge that displays `"Welcome, <currentUser>"` if logged in, or a `"Sign In"` button if logged out.
5. Test time-travel by calling `$blaisex.Undo('userSession')` after logging in and verify that the UI seamlessly returns to the unauthenticated view!

---

## 📖 Deeper Technical Reference

For deeper architectural details, middleware interceptors (RBAC, performance telemetry), and internal Ring-Buffer implementations:
- **[BlaiseX 2.0 & Finite State Machines Manual](../Documentation/55-blaisex-state-machines.md)**: Exhaustive manual detailing `TBVStore`, `TBVStoreSlice`, `TBVStateMachine`, middleware pipelines, and DevTools bridge.
- **[Global State Management](../Documentation/15-global-store.md)**: Architectural patterns for sharing state across large-scale Pascal web applications.

---

[⬅️ Module 12: Declarative Form Validation](12-validation.md) | [🏠 Course Index](README.md) | [Module 14: Enterprise Data Architecture & TDataSet ➡️](14-dataset.md)
