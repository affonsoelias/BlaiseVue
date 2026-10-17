# 37. Full-Stack Pascal with mORMot 2 (bv server) - Phase 4

**Phase 4 of the BlaiseVue Universal Platform (v3.5)** brings **Full-Stack Pascal** capability by uniting the modern reactive web frontend of **BlaiseVue** with the world's fastest native Object Pascal backend framework: **Synopse mORMot 2**.

With this architecture, Pascal developers can write **both frontend components and backend microservices in 100% Pascal**:
- **Frontend**: Reactive Single File Components (`.bv`), transpile to standard JavaScript/WebAssembly via `pas2js`.
- **Backend**: Native compiled x86_64/ARM64 binary using **Free Pascal** and **mORMot 2**, handling tens of thousands of requests per second with sub-millisecond response times, asynchronous REST endpoints, bidirectional WebSockets, and zero external dependencies.

---

## 🏛️ Full-Stack Architecture Overview

```text
┌────────────────────────────────────────────────────────┐
│         BlaiseVue Reactive Frontend (.bv / SPA)        │
│    Built-in $api (REST Client) & $ws (WebSocket Client)│
└──────────────────────────┬─────────────────────────────┘
                           │ HTTP REST (JSON) & WebSocket Frames
                           │ (ws://localhost:8090/blaise-ws)
┌──────────────────────────▼─────────────────────────────┐
│          Synopse mORMot 2 Native Backend Server        │
│         (server/server.lpr, server/ServerApp.pas)      │
├────────────────────────────────────────────────────────┤
│  [+] Asynchronous Non-blocking HTTP Server Engine      │
│  [+] Real-time WebSocket Protocol (TWebSocketServer)   │
│  [+] Built-in CORS Handler for Seamless Web Dev        │
│  [+] Static SPA Host (dist/) with History Fallback     │
│  [+] Shared Records / DTOs (ServerModels.pas)          │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ CLI Commands (`bv server`)

The BlaiseVue CLI provides end-to-end tooling to scaffold, build, run, and inspect the native mORMot 2 server.

```bash
# 1. Create a full-stack project with backend from scratch:
bv create my-fullstack-app --fullstack

# 2. Or initialize the mORMot 2 backend inside an existing project:
bv server init

# 3. DEBUG Build Mode (includes debug symbols and diagnostic output):
bv server build

# 4. RELEASE Build Mode (maximum compiler optimization -O3, stripped symbols):
bv server build --release

# 5. Launch the native server:
bv server run                          # Starts on default port 8090
bv server run --port 8080              # Starts on custom port 8080
bv server run --release                # Builds (if needed) and starts release binary

# 6. Check running server status and health:
bv server status                       # Queries http://localhost:8090/api/status
bv server status --port 8080           # Queries custom port
```

---

## 📂 Directory Structure (`server/`)

Scaffolding the backend creates a clean, decoupled directory structure inside your BlaiseVue project:

```text
my-project/
├── server/
│   ├── server.lpi           # Lazarus IDE project file (with mormot2 package dependency)
│   ├── server.lpr           # Console entry point, banner, and CLI parser
│   ├── ServerApp.pas        # HTTP router, WebSocket protocol, static SPA file server
│   ├── ServerModels.pas     # Shared Pascal records and JSON DTOs
│   ├── README.md            # Backend documentation
│   ├── bin/                 # Compiled native server executable (server.exe or server)
│   └── lib/                 # Compiled FPC unit output (.ppu, .o)
├── src/                     # BlaiseVue reactive frontend components
├── dist/                    # Compiled SPA web assets (served automatically by backend)
├── app.cfg                  # BlaiseVue project config
└── package.json             # NPM dependencies & scripts
```

---

## 💻 Developing with Lazarus IDE

The mORMot 2 backend can be opened and developed natively in **Lazarus IDE**:

1. Launch **Lazarus IDE**.
2. Go to **Project -> Open Project...** and select `server/server.lpi`.
3. If not already registered, open and compile the mORMot 2 package:
   - Go to **Package -> Open Package File (.lpk)...**
   - Select `C:\ComponenteLazarus\mORMot2\packages\lazarus\mormot2.lpk`.
   - Click **Compile**, then **Use -> Add to Project** (or **Install**).
4. Choose your target build mode in **Project -> Project Options -> Build Modes** (`Debug` or `Release`).
5. Press **F9** (Run) or **Shift+F9** (Build).

> [!TIP]
> The generated `server.lpi` includes pre-configured search paths pointing to `C:\ComponenteLazarus\mORMot2\src\...` (`core`, `net`, `db`, `crypt`, `rest`, `soa`, `orm`, `misc`), allowing immediate compilation even before package installation.

---

## ⚡ High-Performance Features

### 1. Asynchronous REST Endpoints
mORMot 2 delivers industry-leading throughput with tiny memory footprints. Endpoints are dispatched with sub-millisecond overhead:

```pascal
// REST API: GET /api/status
if (Ctxt.Method = 'GET') and (Ctxt.Url = '/api/status') then
begin
  Ctxt.OutContentType := JSON_CONTENT_TYPE;
  Ctxt.OutContent :=
    '{"status":"online"' +
    ',"framework":"BlaiseVue 3.5 Full-Stack"' +
    ',"engine":"Synopse mORMot 2"' +
    ',"port":' + FPort +
    ',"uptimeSeconds":' + IntToStr(SecondsBetween(Now, FStartTime)) +
    ',"requestsServed":' + IntToStr(FRequestCount) +
    ',"activeWebSockets":' + IntToStr(FServer.WebSocketConnections) +
    ',"itemsCount":' + IntToStr(Length(FItems)) + '}';
  Result := HTTP_SUCCESS;
  Exit;
end;
```

### 2. Bidirectional Real-Time WebSockets (`blaise-ws`)
Real-time messaging between Pascal backend services and reactive frontend components:

```pascal
procedure TBlaiseServerApp.BroadcastEvent(const EventName, DataJson: RawUtf8);
var
  Frame: TWebSocketFrame;
begin
  Frame.opcode := focText;
  Frame.payload := '{"event":"' + EventName + '","data":' + DataJson + '}';
  FServer.WebSocketBroadcast(Frame);
end;
```

### 3. Automatic CORS Handling
Pre-flight `OPTIONS` and standard cross-origin headers are configured automatically to allow seamless local development (`http://localhost:5173` talking to `http://localhost:8090`):

```pascal
Ctxt.OutCustomHeaders := 'Access-Control-Allow-Origin: *'#13#10 +
                         'Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With'#13#10 +
                         'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS';
if Ctxt.Method = 'OPTIONS' then
begin
  Ctxt.OutContent := '';
  Result := HTTP_SUCCESS;
  Exit;
end;
```

### 4. Static SPA Hosting with HTML5 History Fallback
In production, the backend directly serves the compiled BlaiseVue frontend from `../dist/`. Non-file URLs automatically serve `index.html`, enabling client-side SPA routing (`/dashboard`, `/settings`, etc.) without requiring Nginx or Apache:

```pascal
if (FDistPath <> '') and DirectoryExists(FDistPath) then
begin
  LocalFile := FDistPath + DirectorySeparator + Copy(Ctxt.Url, 2, MaxInt);
  if FileExists(LocalFile) and not DirectoryExists(LocalFile) then
    Exit(Ctxt.SetOutFile(LocalFile, False));

  DistIndex := FDistPath + DirectorySeparator + 'index.html';
  if FileExists(DistIndex) then
    Exit(Ctxt.SetOutFile(DistIndex, False));
end;
```

---

## 🌐 Frontend Reactivity: `$api` & `$ws`

BlaiseVue 3.5 exposes `$api` and `$ws` directly inside all Single File Components and Object Pascal views:

### REST Client (`$api`) API Methods

| Method | Parameters | Description |
|---|---|---|
| `$api.setBaseUrl(Url)` | `Url: string` | Configures the default REST API base URL |
| `$api.setHeader(Key, Value)` | `Key, Value: string` | Adds a default HTTP header to all subsequent requests |
| `$api.setToken(Token)` | `Token: string` | Sets `Authorization: Bearer <token>` |
| `$api.clearToken` | - | Clears the authorization token |
| `$api.get(Endpoint, Callback)` | `Endpoint: string, Callback: TBVApiCallback` | Performs an HTTP GET request |
| `$api.post(Endpoint, Body, Callback)` | `Endpoint: string, Body: string, Callback: TBVApiCallback` | Performs an HTTP POST request |
| `$api.put(Endpoint, Body, Callback)` | `Endpoint: string, Body: string, Callback: TBVApiCallback` | Performs an HTTP PUT request |
| `$api.delete(Endpoint, Callback)` | `Endpoint: string, Callback: TBVApiCallback` | Performs an HTTP DELETE request |

### WebSocket Client (`$ws`) API Methods

| Method | Parameters | Description |
|---|---|---|
| `$ws.connect(Url, Protocol)` | `Url: string, Protocol: string = 'blaise-ws'` | Establishes a WebSocket connection |
| `$ws.send(Message)` | `Message: string` | Sends raw message to server |
| `$ws.emit(EventName, DataJson)` | `EventName, DataJson: string` | Emits structured JSON event `{"event":"...", "data": ...}` |
| `$ws.on(EventName, Handler)` | `EventName: string, Handler: TBVWsEventHandler` | Registers event listener for incoming server broadcasts |
| `$ws.off(EventName)` | `EventName: string` | Removes event listener |
| `$ws.close` | - | Closes active WebSocket connection |
| `$ws.isConnected` | - | Returns boolean indicating live connection status |
| `$ws.status` | - | Returns connection state (`connected`, `connecting`, `closed`) |

---

## 📝 Complete Example: Reactive Component with Backend Sync

```pascal
unit ItemsManager;

interface
uses
  BlaiseVue, BVClient;

type
  TItemsManager = class(TBVComponent)
  public
    function Template: string; override;
    procedure Mounted; override;
    procedure AddNewTask(const Title: string);
  end;

implementation

function TItemsManager.Template: string;
begin
  Result :=
    '<div class="items-card">' +
    '  <h2>Full-Stack Pascal Items (mORMot 2 Sync)</h2>' +
    '  <p>Connection: <strong>{{ $ws.status }}</strong></p>' +
    '  <ul>' +
    '    <li v-for="item in items" :key="item.id">' +
    '      {{ item.title }} - <em>{{ item.category }}</em>' +
    '    </li>' +
    '  </ul>' +
    '</div>';
end;

procedure TItemsManager.Mounted;
begin
  // Configure REST backend URL
  $api.setBaseUrl('http://localhost:8090/api');

  // Load initial dataset from native mORMot 2 server
  $api.get('/items', procedure(Resp: TBVApiResponse)
  begin
    if Resp.ok then
      Data['items'] := Resp.data;
  end);

  // Connect to real-time WebSockets
  $ws.connect('ws://localhost:8090/blaise-ws');

  // Listen for real-time broadcasts
  $ws.on('item_created', procedure(Payload: JSValue)
  begin
    // Re-fetch or update list in real time!
    Mounted;
  end);
end;

procedure TItemsManager.AddNewTask(const Title: string);
begin
  $api.post('/items', '{"title":"' + Title + '","category":"FullStack"}', procedure(Resp: TBVApiResponse)
  begin
    if Resp.ok then
      Emit('item-created', Resp.data);
  end);
end;

end.
```

---

## 🎯 Summary

With **Phase 4**, BlaiseVue delivers on the complete vision of **Full-Stack Pascal**:
- **One language**: Pascal on the client, Pascal on the server.
- **Ultra-lean**: No bulky runtimes or container layers needed.
- **Blazing speed**: Free Pascal native machine code on the server, high-performance reactive JavaScript/WebAssembly in the browser.
- **Enterprise-ready**: mORMot 2 proven asynchronous architecture, battle-tested in mission-critical environments.
