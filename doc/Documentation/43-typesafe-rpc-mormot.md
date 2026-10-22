# 43. End-to-End Type-Safe Pascal RPC com mORMot 2

O **BlaiseVue 4.3** introduz uma camada revolucionária de comunicação cliente-servidor: **End-to-End Type-Safe Pascal RPC**. Esta funcionalidade elimina por completo URLs REST manuais escritas como strings soltas, verbos HTTP manuais e boilerplates de requisição, unindo o backend nativo **mORMot 2 (FPC)** e o frontend reativo **BlaiseVue (Pas2JS)** em um único ecossistema 100% verificado em tempo de compilação.

---

## 1. Visão Geral e Princípios Arquiteturais

Na arquitetura tradicional baseada em REST string-based, qualquer renomeação de rota no backend ou alteração de tipo de parâmetro só é detectada em tempo de execução via erro `404 Not Found` ou `500 Internal Server Error`.

Com o **BlaiseVue 4.3 RPC**:
1. **Contratos Compartilhados (`common/Services.pas`)**: As interfaces de serviço herdam de `IInvokable` e usam DTOs estruturados (`record` e `array of T`), compartilhados entre o servidor nativo e o cliente web.
2. **Proxies Fortemente Tipados (`ClientProxies.pas`)**: Gerados automaticamente pelo comando `bv mormot rpc`, oferecendo assinaturas fortemente tipadas tanto no estilo de **Callbacks fluídos** (`reference to procedure(...)`) quanto no padrão moderno de **Promises assíncronas** (`TJSPromise`).
3. **Validação Estrita em Tempo de Compilação**: Se o servidor alterar a assinatura de um método ou um DTO, o compilador `pas2js` acusa erro imediato ao compilar o frontend (`bv run dev`), garantindo sincronia perfeita.
4. **Transporte Duplo & Alta Performance**: Suporte transparente a **HTTP POST** (`/api/rpc/:service/:method` e JSON-RPC 2.0 `/api/rpc`) e **WebSockets Bidirecionais** em tempo real (`rpc_call` / `rpc_response`), com compressão / modo pack opcional.

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

## 2. Contratos Compartilhados (`common/Services.pas`)

O arquivo `common/Services.pas` é a fonte única da verdade para serviços e modelos DTOs do sistema:

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

## 3. Gerador CLI (`bv mormot rpc`)

O comando de scaffolding `bv mormot rpc` verifica os contratos em `common/Services.pas`, assegura as pastas do projeto e gera os proxies cliente fortemente tipados em `common/ClientProxies.pas` e `generated/ClientProxies.pas`, além de atualizar `app.cfg`:

```bash
# Executa a geração automática de proxies
bv mormot rpc
```

Saída:
```
======================================================================
  BlaiseVue 4.3 End-to-End Type-Safe Pascal RPC with mORMot 2
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

## 4. Consumo nos Componentes e Views (`.bv`)

Nos componentes BlaiseVue, o desenvolvedor simplesmente inclui `uses Services, ClientProxies;` e consome os singletons tipados `CustomerService`, `ProductService` ou `SystemService`.

### Exemplo em `CustomerView.bv`:

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
  
  // Chamada tipada com callback de sucesso e tratamento de erro
  CustomerService.GetAll(
    procedure(Items: TCustomerDynArray)
    begin
      customers := Items;
      isLoading := False;
    end,
    procedure(ErrMsg: string)
    begin
      isLoading := False;
      ShowToast('Erro ao carregar clientes: ' + ErrMsg);
    end
  );
end;

procedure SaveCustomer(const Cust: TCustomer);
begin
  CustomerService.Save(Cust,
    procedure(Saved: TCustomer)
    begin
      ShowToast('Cliente salvo com sucesso!');
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
        ShowToast('Cliente removido');
        LoadCustomers;
      end;
    end
  );
end;
</script>
```

### Modo Assíncrono com Promises (`TJSPromise`):

```pascal
procedure LoadAsync;
begin
  CustomerService.GetByIdAsync(10)._then(procedure(Item: JSValue)
  begin
    ShowToast('Cliente carregado via Promise');
  end);
end;
```

---

## 5. Runtime do Cliente RPC (`core/BVRpc.pas`)

O módulo `core/BVRpc.pas` fornece a infraestrutura de comunicação subjacente:
- **`TBVRpcClient`**: Cliente mestre de RPC conectado ao ecossistema BlaiseVue via `window.__BV_CORE__.rpc`.
- **`TBVRemoteProxy`**: Classe base extensível para proxies de serviços remotos.
- **Transversalidade de Transporte**: Alternância dinâmica entre HTTP e WebSocket com failover transparente:
  ```pascal
  BVRpcClient.SetTransport('ws');      // Ou 'http'
  BVRpcClient.SetBaseUrl('/api/rpc');
  BVRpcClient.SetTimeout(10000);
  BVRpcClient.SetUsePack(True);        // Modo pack ativado
  ```
- **Injeção Automática no Escopo Reativo**: `$rpc` está disponível em todas as instâncias de componentes (`Data.$rpc`).
- **Helpers Pascal DX (`core/BVPascalDX.pas`)**:
  - `RpcCall(ServiceName, MethodName, Params, OnSuccess, OnError)`
  - `RpcCallAsync(ServiceName, MethodName, Params): TJSPromise`
  - `RpcSetBaseUrl(Url)`
  - `RpcSetToken(Token)`
  - `RpcSetTransport(Transport)`
  - `RpcSetTimeout(TimeoutMs)`
  - `RpcSetUsePack(Enable)`

---

## 6. Dispatcher de Servidor SOA mORMot 2 (`demo-app/server/RpcService.pas`)

No backend mORMot 2 nativo, o despachante SOA `TRpcDispatcher` mapeia as chamadas HTTP e frames WebSocket diretamente para a lógica de negócio dos serviços:

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
    
    // HTTP Dispatcher (/api/rpc/:service/:method ou /api/rpc JSON-RPC 2.0)
    function HandleRequest(Ctxt: THttpServerRequest): Cardinal;
    
    // WebSocket Frame Dispatcher (rpc_call -> rpc_response)
    function HandleWsFrame(const FrameData: RawUtf8; out ResponseData: RawUtf8): Boolean;
  end;
```

### Formato de Fio (Wire Protocol):
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

## 7. Cobertura de Testes Automatizados

A versão 4.3 inclui a suíte completa de testes unitários em `demo-app/tests/rpc.test.pas`:
- Verificação da ponte JS `window.__BV_CORE__.rpc`.
- Injeção reativa do `$rpc` no núcleo do BlaiseVue.
- Formatação e parsing de payload JSON-RPC 2.0.
- Execução síncrona/callback e assíncrona baseada em Promises.
- Despacho tipado via proxies `TCustomerServiceClient`, `TProductServiceClient` e `TSystemServiceClient`.
- Troca de transporte (`http` <-> `ws`) e modo compactado (`usePack`).
- Tratamento resiliente de erros com propagação de mensagens de exceção.

Para executar todos os testes da plataforma:
```bash
bv test
```
Resultando em **25 test suites passing (437+ passed tests, 0 errors)**.
