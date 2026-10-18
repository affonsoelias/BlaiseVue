# BlaiseVue Full-Stack mORMot 2 Server Template

High-performance native Pascal backend server powered by **Synopse mORMot 2**, engineered for seamless integration with **BlaiseVue** reactive frontend applications.

---

## Features

- **Asynchronous HTTP/1.1 Engine**: Sub-millisecond response latency, capable of handling tens of thousands of concurrent requests.
- **Real-Time WebSockets (`blaise-ws`)**: Bidirectional event synchronization between Pascal backend and BlaiseVue components.
- **RESTful Endpoints**: Clean JSON data contracts using records and `TDocVariantData`.
- **Automatic CORS**: Pre-configured headers for development (`http://localhost:5173`) and production.
- **Static SPA Hosting**: Serves the compiled BlaiseVue frontend from `../dist/` with HTML5 History API fallback routing.
- **Full Lazarus & CLI Compatibility**: Open and compile in Lazarus IDE or build headlessly via `bv mormot build`.

---

## Project Structure

```
server/
├── server.lpi           # Lazarus project definition (includes mormot2 package dependency)
├── server.lpr           # Console entry point and command-line parser
├── ServerApp.pas        # HTTP router, WebSocket protocol, static file server
├── ServerModels.pas     # Shared Pascal records and JSON DTOs
├── README.md            # Backend documentation
└── bin/                 # Compiled native server binary output
```

---

## Developing with Lazarus IDE

1. Start **Lazarus IDE**.
2. Open `server/server.lpi` (**Project -> Open Project**).
3. If not already installed, make sure the `mormot2` package is registered in Lazarus:
   - Go to **Package -> Open Package File (.lpk)**.
   - Select `<BlaiseVue-Root>\vendor\mormot2\packages\lazarus\mormot2.lpk` (or your local mORMot 2 installation).
   - Click **Compile** and optionally **Use -> Install**.
4. Set your build mode to **Debug** or **Release** in **Project Options**.
5. Press **F9** (Run) or **Shift+F9** (Build).

> [!TIP]
> BlaiseVue bundles mORMot 2.4 directly in `vendor/mormot2/`, enabling zero-configuration builds out of the box!

---

## Developing with BlaiseVue CLI

The BlaiseVue CLI (`bv`) provides convenient commands to build and run the native server directly from your terminal:

```bash
# Build debug binary (bin/server.exe)
bv mormot build

# Build optimized production binary (-O3, stripped symbols)
bv mormot build --release

# Run the native server (port 8090)
bv mormot run

# Run on a custom port
bv mormot run --port 8080

# Check backend health and status
bv mormot status

# Package standalone production bundle
bv mormot deploy
bv mormot deploy --zip
```

> [!NOTE]
> The legacy `bv server` command is preserved as a backward-compatible alias.

---

## API Endpoints

| Method | URL | Description |
|---|---|---|
| `GET` | `/api/status` | Returns server health, uptime, active WebSocket connections, and served request count |
| `GET` | `/api/items` | Returns list of tasks/items in JSON format |
| `POST` | `/api/items` | Creates a new task and broadcasts `item_created` via WebSocket to all connected clients |
| `WS` | `/blaise-ws` | Bidirectional real-time WebSocket protocol |
| `GET` | `/*` | Static file server with SPA HTML5 History fallback (`index.html`) |

---

## Frontend Integration (`$api` & `$ws`)

BlaiseVue components have built-in access to `$api` and `$ws` in their reactive scope:

```pascal
unit TodoView;

interface
uses BlaiseVue, BVClient;

type
  TTodoView = class(TBVComponent)
  public
    function Template: string; override;
    procedure Mounted; override;
    procedure CreateTask(const Title: string);
  end;

implementation

procedure TTodoView.Mounted;
begin
  // Set base URL for REST API
  $api.setBaseUrl('http://localhost:8090/api');

  // Load items from mORMot 2 backend
  $api.get('/items', procedure(Resp: TBVApiResponse)
  begin
    if Resp.ok then
      Data['items'] := Resp.data;
  end);

  // Connect to real-time WebSockets
  $ws.connect('ws://localhost:8090/blaise-ws');
  $ws.on('item_created', procedure(Data: JSValue)
  begin
    // Refresh or append newly created item in real-time!
    Mounted;
  end);
end;

procedure TTodoView.CreateTask(const Title: string);
begin
  $api.post('/items', '{"title":"' + Title + '","category":"Work"}', procedure(Resp: TBVApiResponse)
  begin
    if Resp.ok then
      Emit('item-added', Resp.data);
  end);
end;

end.
```
