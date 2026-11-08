# 55. BlaiseX: Enterprise State Management & Finite State Machines (TBVStore 2.0)

> **Pillar 1 Milestone: BlaiseVue 5.0-alpha**  
> **Status:** Production-Ready  
> **Source Files:** `core/BVStore.pas`, `core/BVFSM.pas`, `core/BVMiddleware.pas`, `core/BVStoreHistory.pas`, `core/BVPascalDX.pas`

---

## 1. Overview & Architectural Motivation

In modern enterprise applications—particularly in financial processing, medical devices, e-commerce checkouts, and multi-step industrial dashboards—simple mutable objects are insufficient. Applications require:

1. **Modular Domain Isolation**: Slices that prevent accidental cross-domain state pollution.
2. **Deterministic State Transitions**: Finite State Machines (FSM) that mathematically forbid illegal states (e.g. attempting to capture payment from a `refunded` or `cancelled` order).
3. **Enterprise Middleware**: Automated audit logging, Role-Based Access Control (RBAC), and performance telemetry.
4. **Time-Travel Debugging**: Snapshot-based reversible states (*Undo* / *Redo* / *Time-Travel*) with zero external dependencies.
5. **Zero-ASM Pascal Developer Experience (DX)**: Clean, strongly-typed Pascal functions inside components and domain services.

**BlaiseX** merges the declarative elegance of **Pinia** and **Redux Toolkit** with the formal rigor of **XState**, written in 100% pure Object Pascal and compiled down to ultra-fast, CSP-compliant JavaScript via Pas2JS.

```
                              ┌─────────────────────────────────────────┐
                              │            TBVStore (BlaiseX)           │
                              │       window.__BLAISEX_STORE__          │
                              └───────────────────┬─────────────────────┘
                                                  │
                 ┌────────────────────────────────┼────────────────────────────────┐
                 ▼                                ▼                                ▼
   ┌───────────────────────────┐    ┌───────────────────────────┐    ┌───────────────────────────┐
   │    Cart Slice (Store)     │    │    Order Slice (Store)    │    │    Auth Slice (Store)     │
   │  - State: items, count    │    │  - Attached FSM: flow     │    │  - User, Roles, Token     │
   │  - Mutations: increment   │    │  - Middleware: Telemetry  │    │  - Middleware: AuthGuard  │
   │  - Actions: checkout      │    │  - History: Snapshots     │    │  - History: Snapshots     │
   └─────────────┬─────────────┘    └─────────────┬─────────────┘    └─────────────┬─────────────┘
                 │                                │                                │
                 └────────────────────────────────┼────────────────────────────────┘
                                                  ▼
                                    ┌───────────────────────────┐
                                    │    Reactive View Layer    │
                                    │  - {{ $store.cart.count }}│
                                    │  - $blaisex.Commit(...)   │
                                    │  - BVPascalDX Helpers     │
                                    └───────────────────────────┘
```

---

## 2. Modular Store Slices (`TBVStoreSlice`)

Store slices group state, mutations, actions, and getters into isolated, named domains.

### 2.1 Defining a Store Slice

Store slices are registered using `DefineStore(Name, InitialState)`:

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
  InitialState := TJSObject.new;
  InitialState['items'] := TJSArray.new;
  InitialState['count'] := 0;
  InitialState['price'] := 50;

  Result := DefineStore('cart', InitialState)
    { Mutations: Synchronous atomic state transitions }
    .Mutation('increment', procedure(AState, APayload: JSValue)
      begin
        TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) + 1;
      end)
    .Mutation('decrement', procedure(AState, APayload: JSValue)
      begin
        TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) - 1;
      end)
    .Mutation('reset', procedure(AState, APayload: JSValue)
      begin
        TJSObject(AState)['count'] := 0;
      end)

    { Getters: Computed state derivations }
    .Getter('totalPrice', function(AState: JSValue): JSValue
      begin
        Result := Integer(TJSObject(AState)['count']) * Integer(TJSObject(AState)['price']);
      end)

    { Actions: Business logic & asynchronous workflows }
    .Action('checkout', function(ACtx, APayload: JSValue): JSValue
      begin
        { Access slice methods via ACtx['slice'] or ACtx['commit'] }
        TBVStoreSlice(TJSObject(ACtx)['slice']).Commit('increment');
        Result := 'CHECKOUT_SUCCESS';
      end);
end;

initialization
  InitCartStore;

end.
```

### 2.2 Accessing Stores & Slices

```pascal
var
  Cart: TBVStoreSlice;
  Store: TBVStore;
begin
  { Direct slice retrieval }
  Cart := GetStore('cart');
  Cart.Commit('increment');

  { Global namespaced dispatch via root store }
  Store := GetStore;
  Store.Commit('cart/increment');
  Store.Dispatch('cart/checkout');
  WriteLn('Total: ', Store.Get('cart/totalPrice'));
end;
```

---

## 3. Finite State Machines (`TBVStateMachine`)

Finite State Machines provide formal mathematical determinism to application lifecycles.

### 3.1 Defining a Finite State Machine

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
    .State('cart')
      .On('CHECKOUT', 'processing')
    .State('processing')
      .On('SUCCESS', 'completed')
      .On('FAIL', 'failed')
    .State('completed')
      .On('RESET', 'cart')
    .State('failed')
      .On('RETRY', 'processing')
      .On('RESET', 'cart')
    .Machine;
end;

end.
```

### 3.2 Guards and Lifecycle Callbacks

Transitions can be conditional with `Guard` functions and lifecycle hooks (`OnEnter`, `OnExit`, transition actions):

```pascal
FSM := TBVStateMachine.Create('Payment')
  .Initial('unpaid')
  .State('unpaid')
    .OnExit(procedure(Ctx, EvPayload: JSValue)
      begin
        WriteLn('[FSM] Leaving unpaid state');
      end)
    .On('PAY', 'paid', 
      function(Ctx, EvPayload: JSValue): Boolean
      begin
        { Transition only succeeds if amount is positive }
        Result := Integer(TJSObject(EvPayload)['amount']) > 0;
      end)
  .State('paid')
    .OnEnter(procedure(Ctx, EvPayload: JSValue)
      begin
        WriteLn('[FSM] Payment confirmed!');
      end);
```

### 3.3 Attaching an FSM to a Store Slice

When an FSM is attached to a slice, its reactive state is automatically mounted on the slice state:

```pascal
OrderSlice := DefineStore('order', InitialState)
  .AttachMachine('flow', CreateOrderFlowMachine);
```

In `.bv` component templates, the machine's current state is instantly accessible and reactive:

```html
<span class="badge">{{ $store.order.flow.current }}</span>
```

---

## 4. Middleware & Interceptor Pipeline (`BVMiddleware`)

Every mutation and action passes through a configurable middleware pipeline.

```
 [Action / Mutation Call]
           │
           ▼
 ┌───────────────────┐
 │   Before Hook     │ ──► Logger / RBAC Check / Start Timer
 └─────────┬─────────┘
           ▼
 ┌───────────────────┐
 │ Execute Mutation  │ ──► Update State / Record Snapshot
 └─────────┬─────────┘
           ▼
 ┌───────────────────┐
 │    After Hook     │ ──► End Timer / Record Metrics / DevTools
 └───────────────────┘
```

### 4.1 Built-in Middleware

| Middleware | Purpose |
|---|---|
| `TBVLoggerMiddleware` | Formats and logs all mutations and actions with elapsed execution time. |
| `TBVAuthGuardMiddleware` | Restricts mutations/actions to users with specific roles or permissions. |
| `TBVTelemetryMiddleware` | Tracks call counts, average duration, max duration, and slow call alerts. |
| `TBVFunctionalMiddleware` | Anonymous before/after callback handlers. |

### 4.2 Registering Middleware

```pascal
{ Global middleware applied to all slices }
GetStore
  .Use(TBVLoggerMiddleware.Create)
  .Use(TBVTelemetryMiddleware.Create(100)); // Warns if execution > 100ms

{ Slice-specific RBAC guard }
CartSlice.Use(
  TBVAuthGuardMiddleware.Create
    .AllowRoles(['admin', 'cashier'])
    .RequirePermission('cart:modify')
);
```

---

## 5. Time-Travel Debugging & Snapshots (`BVStoreHistory`)

BlaiseX features an integrated snapshot engine with bounded memory overhead.

### 5.1 Programmatic Undo and Redo

```pascal
Cart.Commit('increment'); // count = 1
Cart.Commit('increment'); // count = 2

Cart.Undo; // count reverts to 1
Cart.Undo; // count reverts to 0
Cart.Redo; // count moves back to 1
```

### 5.2 Browser DevTools Bridge

BlaiseX registers `window.__BLAISEX_DEVTOOLS__`, allowing browser devtools and extension inspectors to inspect and travel through state:

```javascript
// In Browser Console:
window.__BLAISEX_DEVTOOLS__.getSlices();
window.__BLAISEX_DEVTOOLS__.getHistory('cart');
window.__BLAISEX_DEVTOOLS__.undo('cart');
window.__BLAISEX_DEVTOOLS__.redo('cart');
window.__BLAISEX_DEVTOOLS__.timeTravel('cart', 2);
```

---

## 6. Zero-ASM Pascal DX Helpers (`BVPascalDX`)

For the cleanest code possible inside your components and services, `BVPascalDX` provides zero-assembly helper functions:

```pascal
uses BVPascalDX;

procedure TMyComponent.HandleCheckout;
var
  Total: JSValue;
  FSM: TBVStateMachine;
begin
  { Commit mutation }
  StoreCommit('cart/setLoading', True);

  { Evaluate computed getter }
  Total := StoreGet('cart/totalPrice');

  { Dispatch business logic action }
  StoreDispatch('cart/processPayment', NewObject(['total', Total]));

  { Drive Finite State Machine }
  FSM := UseFSM('checkout');
  if FSM.Can('COMPLETE') then
    FSM.Send('COMPLETE');

  { Time travel }
  if ErrorOccurred then
    StoreUndo('cart');
end;
```

---

## 7. Component Integration (`.bv`)

In Single File Components (`.bv`), BlaiseX is injected seamlessly into both the template and Pascal method scopes:

```html
<template>
  <div class="checkout-card">
    <h2>Checkout Flow: {{ $store.order.flow.current }}</h2>

    <p>Items in Cart: {{ $store.cart.count }}</p>
    <p>Total: ${{ $store.cart.totalPrice }}</p>

    <div class="actions">
      <button @click="$blaisex.Commit('cart/increment')">+</button>
      <button @click="$blaisex.Commit('cart/decrement')">-</button>
      <button @click="$blaisex.Undo('cart')">Undo</button>
      <button @click="$blaisex.Redo('cart')">Redo</button>
      <button @click="handleCheckout">Pay Now</button>
    </div>
  </div>
</template>

<script>
uses BVPascalDX;

methods:
  procedure handleCheckout;
  var
    FSM: TBVStateMachine;
  begin
    FSM := UseFSM('order', 'flow');
    if FSM.Send('CHECKOUT') then
    begin
      StoreDispatch('order/submit');
      FSM.Send('SUCCESS');
    end;
  end;
</script>
```

---

## 8. CLI Scaffolding & Generators

The BlaiseVue CLI (`bv`) automates the creation of stores, state machines, and their corresponding unit tests.

### 8.1 Scaffolding a Store Slice

```bash
# Generate store slice in src/stores/ and test in tests/stores/
bv g store Cart

# Output:
# Store created: src/stores/uCartStore.pas
# Test created: tests/stores/CartStore.test.pas
```

### 8.2 Scaffolding a Finite State Machine

```bash
# Generate FSM in src/machines/ and test in tests/machines/
bv g fsm OrderFlow

# Output:
# FSM created: src/machines/uOrderFlowMachine.pas
# Test created: tests/machines/OrderFlowMachine.test.pas
```

### 8.3 List and Remove Commands

```bash
# List all registered stores and machines
bv list store
bv list fsm

# Safely delete a store slice or FSM and its associated test
bv remove store Cart
bv remove fsm OrderFlow
```

### 8.4 Running Tests

```bash
# Compiles and runs all 4-tier tests including store slices and FSMs
bv test
```

---

## 9. Summary & Benefits

| Capability | Legacy `$store` (v4.x) | BlaiseX 2.0 (v5.0-alpha) |
|---|---|---|
| **Architecture** | Single flat global object | Modular slices with domain isolation |
| **State Machine Engine** | None | Built-in `TBVStateMachine` with guards and audit trails |
| **Mutations & Actions** | Direct property mutation | Atomic mutations + typed asynchronous actions |
| **Pipeline & Interceptors** | None | Middleware for Logger, AuthGuard (RBAC), and Telemetry |
| **Time-Travel Debugging** | None | Reversible state ring buffer with undo, redo, and DevTools bridge |
| **CLI Scaffolding** | Manual file authoring | `bv g store <Name>` & `bv g fsm <Name>` with automated tests |
| **Component DX** | `$store.state.key` | `$store.<slice>.<prop>`, `$blaisex.Commit`, and `BVPascalDX` |
