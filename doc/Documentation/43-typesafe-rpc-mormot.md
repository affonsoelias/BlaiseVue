# 43. End-to-End Type-Safe Pascal RPC with mORMot 2

**BlaiseVue** features a revolutionary client-server communication layer: **End-to-End Type-Safe Pascal RPC**. This capability completely eliminates manual REST string URLs, manual HTTP verbs, and boilerplate fetch requests, unifying the native **mORMot 2 (FPC)** backend and the reactive **BlaiseVue (Pas2JS)** frontend into a single compile-time verified ecosystem.

---

## 1. Overview & Architectural Principles

In traditional string-based REST architectures, any route rename or parameter type modification on the backend is only discovered at runtime via `404 Not Found` or `500 Internal Server Error` responses.

With **BlaiseVue Type-Safe RPC**:
1. **Shared Service Contracts (`common/Services.pas`)**: Service interfaces inherit from `IInvokable` and utilize structured DTOs (`record` and `array of T`), shared seamlessly between the native server and the web client.
2. **Strongly Typed Client Proxies (`ClientProxies.pas`)**: Generated automatically by the `bv mormot rpc` command, offering strongly typed signatures in both **fluent callback** style (`reference to procedure(...)`) and modern **asynchronous Promise** patterns (`TJSPromise`).
3. **Strict Compile-Time Validation**: If the backend alters a method signature or DTO field, the `pas2js` compiler immediately catches the error during frontend compilation (`bv run dev` / `bv build`), guaranteeing perfect synchrony.
4. **Dual Transport & High Performance**: Transparent support for **HTTP POST** (`/api/rpc/:service/:method` and JSON-RPC 2.0 `/api/rpc`) and real-time **Bidirectional WebSockets** (`rpc_call` / `rpc_response`), with optional data compression / pack mode.

```
+-----------------------------------------------------------------------------------+
|                        SHARED CONTRACTS (common/Services.pas)                     |
|  ICustomerService = interface(IInvokable)                                         |
|    function GetAll: TCustomerDynArray;                                            |
|    function GetById(Id: Integer): TCustomer;                                      |
|    function Save(const Customer: TCustomer): TCustomer;                           |
|    function Delete(Id: Integer): Boolean;                                         |
|  end;                                                                             |
+-----------------------------------------+-----------------------------------------+
                                          |
            ┌─────────────────────────────┴─────────────────────────────┐
            ▼                                                           ▼
+────────────────────────────────-------+   +────────────────────────────────-------+
|        BLAISEVUE CLIENT (Pas2JS)      |   |       mORMot 2 SERVER (Free Pascal)   |
|  generated/ClientProxies.pas          |   |  server/RpcService.pas (Dispatcher)   |
|                                       |   |                                       |
|  CustomerService.GetAll(              |   |  TRpcDispatcher.HandleRequest         |
|    procedure(Items: TCustomerDynArray)|   |    - Unpack JSON params / DTO         |
|    begin                              |   |    - Execute Service Implementation   |
|      this.customers := Items;         |   |    - Pack Return DTO / JSON-RPC 2.0   |
|    end);                              |   |                                       |
+────────────────────────────────-------+   +────────────────────────────────-------+
            │                                                           ▲
            └────────────── HTTP POST /api/rpc/:service/:method ────────┘
            └────────────── WebSocket "rpc_call" / "rpc_response" ──────┘
```

---

## 2. Shared Contracts (`common/Services.pas`)

The `common/Services.pas` file serves as the single source of truth for services and DTO models across the system:

```pascal
unit Services;

{$mode objfpc}

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
  { Customer Data Transfer Object }
  TCustomer = record
    ID: Integer;
    Name: RawUtf8;
    Email: RawUtf8;
    Phone: RawUtf8;
    Active: Boolean;
    CreatedAt: RawUtf8;
  end;
  TCustomerDynArray = array of TCustomer;

  { Product Data Transfer Object }
  TProduct = record
    ID: Integer;
    Name: RawUtf8;
    Price: Double;
    Stock: Integer;
    Category: RawUtf8;
    CreatedAt: RawUtf8;
  end;
  TProductDynArray = array of TProduct;

  { System Info DTO }
  TSystemInfo = record
    Status: RawUtf8;
    Framework: RawUtf8;
    Engine: RawUtf8;
    Version: RawUtf8;
    UptimeSeconds: Int64;
    ItemsCount: Integer;
  end;

  { Service Interfaces inheriting from IInvokable }
  ICustomerService = interface(IInvokable)
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetAll: TCustomerDynArray;
    function GetById(Id: Integer): TCustomer;
    function Save(const Customer: TCustomer): TCustomer;
    function Delete(Id: Integer): Boolean;
  end;

  IProductService = interface(IInvokable)
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function GetAll: TProductDynArray;
    function GetById(Id: Integer): TProduct;
    function Save(const Product: TProduct): TProduct;
    function Delete(Id: Integer): Boolean;
  end;

  ISystemService = interface(IInvokable)
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    function GetStatus: string;
    function Ping(const Msg: string): string;
    function Echo(const Text: string): string;
  end;

implementation

end.
```

---

## 3. CLI Scaffolding (`bv mormot rpc`)

The `bv mormot rpc` scaffolding command verifies contracts in `common/Services.pas`, ensures project directory structure, generates strongly typed client proxies in `common/ClientProxies.pas` and `generated/ClientProxies.pas`, and updates search paths in `app.cfg`:

```bash
# Execute automated proxy generation
bv mormot rpc
```

Output:
```
======================================================================
  BlaiseVue End-to-End Type-Safe Pascal RPC with mORMot 2
  (bv mormot rpc)
======================================================================
  Specification: Compile-Time Verified mORMot 2 SOA Client Proxies
  Protocol:      JSON-RPC 2.0 & mORMot SOA Wire Format over HTTP & WS
  Validation:    100% Strict Type Safety (No REST String URLs)
----------------------------------------------------------------------
[1/3] Checking shared service contracts in common/Services.pas...
  [+] Service contracts found: common/Services.pas
[2/3] Generating strongly typed client proxies in ClientProxies.pas...
  [+] Generated common/ClientProxies.pas
  [+] Generated generated/ClientProxies.pas
[3/3] Checking project compiler search paths in app.cfg...
  [+] Search path -Fucommon already active in app.cfg

======================================================================
  [SUCCESS] End-to-End Type-Safe RPC proxies generated successfully!
======================================================================
```

---

## 4. Consuming in Components and Views (`.bv`)

Inside BlaiseVue components, simply add `uses Services, ClientProxies;` and consume the typed singletons `CustomerService`, `ProductService`, or `SystemService`.

### Example in `CustomerView.bv`:

```pascal
<script>
uses
  SysUtils, JS, Web, Services, ClientProxies;

var
  customers: TCustomerDynArray;
  isLoading: Boolean;

procedure LoadCustomers;
begin
  isLoading := True;
  
  // Typed call with success callback and error handling
  CustomerService.GetAll(
    procedure(Items: TCustomerDynArray)
    begin
      customers := Items;
      isLoading := False;
    end,
    procedure(ErrMsg: string)
    begin
      isLoading := False;
      ShowToast('Error loading customers: ' + ErrMsg);
    end
  );
end;

procedure SaveCustomer(const Cust: TCustomer);
begin
  CustomerService.Save(Cust,
    procedure(Saved: TCustomer)
    begin
      ShowToast('Customer saved successfully!');
      LoadCustomers;
    end
  );
end;

procedure DeleteCustomer(Id: Integer);
begin
  CustomerService.Delete(Id,
    procedure(Ok: Boolean)
    begin
      if Ok then
      begin
        ShowToast('Customer removed');
        LoadCustomers;
      end;
    end
  );
end;
</script>
```

### Asynchronous Mode with Promises (`TJSPromise`):

```pascal
procedure LoadAsync;
begin
  CustomerService.GetByIdAsync(10)._then(procedure(Item: JSValue)
  begin
    ShowToast('Customer loaded via Promise');
  end);
end;
```

---

## 5. RPC Client Runtime (`core/BVRpc.pas`)

The `core/BVRpc.pas` module provides the underlying communication infrastructure:
- **`TBVRpcClient`**: Master RPC client connected to the BlaiseVue ecosystem via `window.__BV_CORE__.rpc`.
- **`TBVRemoteProxy`**: Extensible base class for remote service proxies.
- **Transport Flexibility**: Dynamic switching between HTTP and WebSocket with transparent failover:
  ```pascal
  BVRpcClient.SetTransport('ws');      // Or 'http'
  BVRpcClient.SetBaseUrl('/api/rpc');
  BVRpcClient.SetTimeout(10000);
  BVRpcClient.SetUsePack(True);        // Pack mode enabled
  ```
- **Automatic Reactive Injection**: `$rpc` is available on all component instances (`Data.$rpc`).
- **Pascal DX Helpers (`core/BVPascalDX.pas`)**:
  - `RpcCall(ServiceName, MethodName, Params, OnSuccess, OnError)`
  - `RpcCallAsync(ServiceName, MethodName, Params): TJSPromise`
  - `RpcSetBaseUrl(Url)`
  - `RpcSetToken(Token)`
  - `RpcSetTransport(Transport)`
  - `RpcSetTimeout(TimeoutMs)`
  - `RpcSetUsePack(Enable)`

---

## 6. SOA mORMot 2 Server Dispatcher (`demo-app/server/RpcService.pas`)

In the native mORMot 2 backend, the `TRpcDispatcher` SOA dispatcher maps HTTP requests and WebSocket frames directly to service business logic:

```pascal
unit RpcService;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  mormot.core.base,
  mormot.core.json,
  mormot.core.os,
  mormot.net.http,
  Services;

type
  TRpcDispatcher = class
  private
    FCustomerService: ICustomerService;
    FProductService: IProductService;
    FSystemService: ISystemService;
  public
    constructor Create;
    destructor Destroy; override;
    
    // HTTP Dispatcher (/api/rpc/:service/:method or /api/rpc JSON-RPC 2.0)
    function HandleRequest(Ctxt: THttpServerRequest): Cardinal;
    
    // WebSocket Frame Dispatcher (rpc_call -> rpc_response)
    function HandleWsFrame(const FrameData: RawUtf8; out ResponseData: RawUtf8): Boolean;
  end;
```

### Wire Protocol:
- **HTTP REST SOA**: `POST /api/rpc/CustomerService/GetAll`
- **JSON-RPC 2.0**:
  ```json
  {
    "jsonrpc": "2.0",
    "method": "CustomerService.GetById",
    "params": [42],
    "id": 1
  }
  ```
- **WebSocket Frame**:
  ```json
  {
    "type": "rpc_call",
    "service": "CustomerService",
    "method": "GetAll",
    "params": [],
    "id": 101
  }
  ```

---

## 7. Automated Test Coverage

BlaiseVue includes an extensive unit test suite in `demo-app/tests/rpc.test.pas`:
- Validation of JS bridge `window.__BV_CORE__.rpc`.
- Reactive injection of `$rpc` into BlaiseVue core.
- JSON-RPC 2.0 payload formatting and parsing.
- Synchronous callback and Promise-based asynchronous execution.
- Typed dispatch through `TCustomerServiceClient`, `TProductServiceClient`, and `TSystemServiceClient` proxies.
- Transport switching (`http` <-> `ws`) and compressed mode (`usePack`).
- Resilient error handling with exception message propagation.

To execute all platform tests:
```bash
bv test
```
Resulting in **68 test files passing (364/364 passed tests, 0 errors)**.
