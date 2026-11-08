# ⚡ Module 18: High-Performance RPC & SOA Client Proxies
**Eliminate string-based REST fragility with end-to-end type-safe Pascal RPC and interactive Swagger documentation.**

In traditional web development, calling a backend API looks something like this:
```javascript
// Fragile string-based REST:
fetch('/api/custmers/123/calc-discounts', { method: 'POST', body: ... })
```
Did you spot the typo? `custmers` instead of `customers`! In string-based architectures, this error can only be discovered **at runtime**, resulting in a `404 Not Found` or `500 Internal Server Error`. If the backend changes a field from `integer` to `string`, the frontend silently breaks.

**BlaiseVue eliminates this problem entirely.** With **End-to-End Type-Safe Pascal RPC**, both your backend service interfaces and your frontend client proxies are written in Pascal and validated **at compile time**!

---

## 🏛️ 1. Architecture of Type-Safe Pascal RPC

```text
┌───────────────────────────────────────────────────────────────────────────┐
│                   SHARED CONTRACTS (common/Services.pas)                  │
│  ICustomerService = interface(IInvokable)                                 │
│    function GetAll: TCustomerDynArray;                                    │
│    function CalculateDiscount(Id: Integer; Rate: Double): TDiscountResult;│
│  end;                                                                     │
└─────────────────────────────────────┬─────────────────────────────────────┘
                                      │
            ┌─────────────────────────┴─────────────────────────┐
            ▼                                                   ▼
┌───────────────────────────────────────┐   ┌───────────────────────────────────────┐
│        BLAISEVUE CLIENT (Pas2JS)      │   │       mORMot 2 SERVER (Free Pascal)   │
│  generated/ClientProxies.pas          │   │  server/RpcService.pas (Dispatcher)   │
│                                       │   │                                       │
│  CustomerService.CalculateDiscount(   │   │  TRpcDispatcher.HandleRequest         │
│    123, 0.15,                         │   │    - Validates types & parameters     │
│    procedure(Res: TDiscountResult)    │   │    - Executes native Pascal service   │
│    begin                              │   │    - Returns strongly-typed JSON-RPC  │
│      this.discount := Res.Total;      │   │                                       │
│    end);                              │   │                                       │
└───────────────────────────────────────┘   └───────────────────────────────────────┘
            │                                                   ▲
            └────────────── HTTP POST /api/rpc/:service/:method ┘
            └────────────── WebSocket "rpc_call" / "rpc_response" ┘
```

---

## 📜 2. Defining Shared Service Contracts (`common/Services.pas`)

The contract defines the interface and data transfer records shared between frontend and backend:

```pascal
unit Services;

{$mode objfpc}{$H+}

interface

uses
  SysUtils
  {$IFNDEF PAS2JS}
  , mormot.core.base
  {$ENDIF}
  ;

{$IFDEF PAS2JS}
type
  RawUtf8 = string;
{$ENDIF}

type
  TCustomerDTO = record
    id: Integer;
    name: RawUtf8;
    email: RawUtf8;
    balance: Double;
  end;
  TCustomerDynArray = array of TCustomerDTO;

  TDiscountResult = record
    customerId: Integer;
    originalBalance: Double;
    discountAmount: Double;
    netBalance: Double;
  end;

  // The SOA Service Interface
  ICustomerService = interface(IInvokable)
    ['{67F47D08-2A85-4D56-8B1E-8DF3FA45E201}']
    function GetAll: TCustomerDynArray;
    function GetById(Id: Integer): TCustomerDTO;
    function CalculateDiscount(Id: Integer; Rate: Double): TDiscountResult;
    function Delete(Id: Integer): Boolean;
  end;

implementation

end.
```

---

## 🛠️ 3. Scaffolding Type-Safe Proxies with `bv mormot rpc`

Whenever you define or update your shared service interfaces in `common/Services.pas`, run:

```bash
bv mormot rpc
```

The CLI inspects your `IInvokable` interfaces and generates strongly-typed Pascal client proxies in `generated/ClientProxies.pas`!

### What Does This Guarantee?
If someone changes `function CalculateDiscount(Id: Integer; Rate: Double)` to require a third parameter (e.g. `CouponCode: string`), and you try to compile your frontend with `bv dev`, **the Pas2JS compiler fails immediately with an exact line number and error message**! 

Zero runtime surprises. Total synchronization.

---

## 💻 4. Using the RPC Proxies in `.bv` Components

You can consume RPC methods using either **Fluid Callbacks** or **Modern Promises**:

### Option A: Fluid Pascal Callback Style
```pascal
uses Services, ClientProxies;

procedure TMyComponent.LoadCustomers;
begin
  CustomerService.GetAll(
    procedure(Items: TCustomerDynArray)
    begin
      // Strongly-typed records received seamlessly!
      this.customers := Items;
      WriteLn('Loaded ', Length(Items), ' customers via Pascal RPC.');
    end,
    procedure(Err: string)
    begin
      ShowMessage('RPC Error: ' + Err);
    end
  );
end;
```

### Option B: Async Promise Style
```pascal
procedure TMyComponent.ApplyDiscount(CustomerId: Integer);
begin
  CustomerService.CalculateDiscountAsync(CustomerId, 0.15)._then(
    procedure(Val: JSValue)
    var
      Res: TDiscountResult;
    begin
      Res := TDiscountResult(Val);
      ShowMessage('New Balance: $' + FloatToStr(Res.netBalance));
    end
  );
end;
```

---

## 🌐 5. Dual Transport: HTTP POST & Bidirectional WebSockets

The generated RPC client is transport-agnostic. By default, calls use high-speed HTTP POST endpoints (`/api/rpc/:service/:method`).

However, for high-frequency trading dashboards or chat systems, you can switch transport to **WebSockets** with one line:

```pascal
RpcClient.SetTransport(rtWebSocket);
```

When WebSocket transport is active, requests and responses are framed over the persistent connection with **zero HTTP handshake overhead**!

---

## 📜 6. Interactive OpenAPI & Swagger Documentation (`bv mormot docs`)

Need to share your backend APIs with external partners, mobile teams, or third-party developers? BlaiseVue automatically generates interactive Swagger / OpenAPI 3.0 explorers:

```bash
# Generate Swagger UI and OpenAPI 3.0 schema
bv mormot docs

# Alias:
bv mormot swagger
```

Visit **`http://localhost:8090/api/docs`** in your browser to explore:
- Interactive testing console for every endpoint (`Try it out`).
- Schemas for all request and response records.
- JWT Bearer token authentication testing directly within Swagger UI!

---

## 🏋️ Practical Exercise

1. Open `common/Services.pas` and inspect the `ICustomerService` interface.
2. Add a new function to the interface:
   ```pascal
   function PingServer(const Message: RawUtf8): RawUtf8;
   ```
3. Run `bv mormot rpc` in your terminal to regenerate client proxies.
4. Call `CustomerService.PingServer('Hello from Pascal!')` inside a button click handler in `src/views/Home.bv`.
5. Run `bv mormot docs` and open `http://localhost:8090/api/docs` to test your new endpoint interactively!

---

## 📖 Deeper Technical Reference

- **[End-to-End Type-Safe Pascal RPC with mORMot 2](../Documentation/43-typesafe-rpc-mormot.md)**: Exhaustive manual on `IInvokable` reflection, binary/pack mode compression, and WebSocket dispatchers.
- **[Swagger & OpenAPI 3.0 Explorer](../Documentation/37-mormot2-backend.md)**: Customizing OpenAPI tags, descriptions, contact info, and security schemes.

---

[⬅️ Module 17: Full-Stack JWT Authentication & Route Guards](17-mormot-auth.md) | [🏠 Course Index](README.md) | [Module 19: Mobile & Multi-Platform Architecture ➡️](19-mobile-architecture.md)
