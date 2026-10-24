unit ServerApp;

{
  ServerApp - High-Throughput HTTP REST & WebSocket Server (mORMot 2)
  -------------------------------------------------------------------
  Engineered for the BlaiseVue Universal Framework to provide:
  - Ultra-fast native HTTP REST API endpoints
  - Type-safe mORMot 2 SOA RPC services (/api/rpc/*)
  - Real-time bidirectional WebSockets (blaise-ws)
  - Automatic CORS handling for seamless local and remote dev
  - Static file hosting for dist/ with SPA History API fallback
}

{$I mormot.defines.inc}

interface

uses
  sysutils,
  classes,
  dateutils,
  variants,
  mormot.core.base,
  mormot.core.os,
  mormot.core.text,
  mormot.core.json,
  mormot.core.variants,
  mormot.core.rtti,
  mormot.core.data,
  mormot.net.http,
  mormot.net.server,
  mormot.net.ws.core,
  mormot.net.ws.server,
  ServerModels, CrudCustomer, CrudProduct, AuthService, SwaggerService, RpcService;

type
  { Real-time WebSocket Protocol for BlaiseVue clients }
  TBlaiseWebSocketProtocol = class(TWebSocketProtocolChat)
  private
    FRpcDispatcher: TRpcDispatcher;
  protected
    procedure OnIncoming(Sender: TWebSocketProcess; const Frame: TWebSocketFrame);
  public
    constructor CreateProtocol(ARpcDispatcher: TRpcDispatcher = nil);
    property RpcDispatcher: TRpcDispatcher read FRpcDispatcher write FRpcDispatcher;
  end;

  { Main mORMot 2 Full-Stack Server Application }
  TBlaiseServerApp = class
  private
    FPort: RawUtf8;
    FDistPath: string;
    FServer: TWebSocketServer;
    FWSProtocol: TBlaiseWebSocketProtocol;
    FStartTime: TDateTime;
    FRequestCount: Int64;
    FItems: TBlaiseItemDynArray;
    FCrudCustomer: TCrudCustomerService;
    FCrudProduct: TCrudProductService;
    FAuthService: TAuthService;
    FSwaggerService: TSwaggerService;
    FRpcDispatcher: TRpcDispatcher;
    function HandleDataSetApply(const InContent: RawUtf8): RawUtf8;
    function DoRequest(Ctxt: THttpServerRequestAbstract): cardinal;
  public
    constructor Create(const APort: RawUtf8 = '8090'; const ADistPath: string = '../dist');
    destructor Destroy; override;
    procedure AddItem(const ATitle, ACategory: RawUtf8; ADone: Boolean);
    function ItemsToJson: RawUtf8;
    procedure BroadcastEvent(const EventName, DataJson: RawUtf8);
    property Port: RawUtf8 read FPort;
    property RequestCount: Int64 read FRequestCount;
    property RpcDispatcher: TRpcDispatcher read FRpcDispatcher;
  end;

implementation

{ TBlaiseWebSocketProtocol }

constructor TBlaiseWebSocketProtocol.CreateProtocol(ARpcDispatcher: TRpcDispatcher);
begin
  inherited Create('blaise-ws', '');
  FRpcDispatcher := ARpcDispatcher;
  OnIncomingFrame := OnIncoming;
end;

procedure TBlaiseWebSocketProtocol.OnIncoming(Sender: TWebSocketProcess; const Frame: TWebSocketFrame);
begin
  case Frame.opcode of
    focText, focBinary:
      begin
        if (FRpcDispatcher <> nil) and FRpcDispatcher.HandleWebSocketFrame(Sender, Frame.payload) then
          Exit;
        // Echo back incoming frame or dispatch to connected clients
        SendFrame(Sender, Frame);
      end;
  end;
end;

{ TBlaiseServerApp }

constructor TBlaiseServerApp.Create(const APort: RawUtf8; const ADistPath: string);
begin
  inherited Create;
  FPort := APort;
  FDistPath := ADistPath;
  FStartTime := Now;
  FRequestCount := 0;

  // Initial demonstration items
  AddItem('Explore BlaiseVue Reactive Components', 'Frontend', True);
  AddItem('High-throughput REST API with mORMot 2', 'Backend', True);
  AddItem('Real-time WebSockets synchronization', 'FullStack', False);

  FCrudProduct := TCrudProductService.Create;
  FCrudProduct.OnBroadcast := BroadcastEvent;
  FAuthService := TAuthService.Create;
  FSwaggerService := TSwaggerService.Create('BlaiseVue Full-Stack mORMot 2 API', '4.0.0', FPort);
  FAuthService.OnBroadcast := BroadcastEvent;
  FCrudCustomer := TCrudCustomerService.Create;
  FCrudCustomer.OnBroadcast := BroadcastEvent;

  FRpcDispatcher := TRpcDispatcher.Create(FCrudCustomer, FCrudProduct, FAuthService);
  FRpcDispatcher.OnBroadcast := BroadcastEvent;

  FServer := TWebSocketServer.Create(FPort, nil, nil, 'blaisevue_fullstack', 4);
  FWSProtocol := TBlaiseWebSocketProtocol.CreateProtocol(FRpcDispatcher);
  FServer.WebSocketProtocols.Add(FWSProtocol);
  FServer.OnRequest := DoRequest;
end;

destructor TBlaiseServerApp.Destroy;
begin
  FRpcDispatcher.Free;
  FCrudProduct.Free;
  FAuthService.Free;
  FSwaggerService.Free;
  FCrudCustomer.Free;
  FServer.Free;
  inherited Destroy;
end;

procedure TBlaiseServerApp.AddItem(const ATitle, ACategory: RawUtf8; ADone: Boolean);
var
  Idx: Integer;
begin
  Idx := Length(FItems);
  SetLength(FItems, Idx + 1);
  FItems[Idx].ID := Idx + 1;
  FItems[Idx].Title := ATitle;
  FItems[Idx].Category := ACategory;
  FItems[Idx].Done := ADone;
  FItems[Idx].CreatedAt := DateTimeToStr(Now);
end;

function TBlaiseServerApp.ItemsToJson: RawUtf8;
var
  i: Integer;
  DoneStr: RawUtf8;
begin
  Result := '[';
  for i := 0 to High(FItems) do
  begin
    if i > 0 then Result := Result + ',';
    if FItems[i].Done then DoneStr := 'true' else DoneStr := 'false';
    Result := Result +
      '{"id":' + IntToStr(FItems[i].ID) +
      ',"title":"' + FItems[i].Title + '"' +
      ',"category":"' + FItems[i].Category + '"' +
      ',"done":' + DoneStr +
      ',"createdAt":"' + FItems[i].CreatedAt + '"}';
  end;
  Result := Result + ']';
end;

procedure TBlaiseServerApp.BroadcastEvent(const EventName, DataJson: RawUtf8);
var
  Frame: TWebSocketFrame;
  Payload: RawUtf8;
begin
  Payload := '{"event":"' + EventName + '","data":' + DataJson + '}';
  Frame.opcode := focText;
  Frame.payload := Payload;
  FServer.WebSocketBroadcast(Frame);
end;

function TBlaiseServerApp.HandleDataSetApply(const InContent: RawUtf8): RawUtf8;
var
  Doc, DeltaItemDoc: TDocVariantData;
  TableVal, ActionVal, ClientIdVal, RecJson, DummyJson: RawUtf8;
  InsertedIdsJson: RawUtf8;
  DeltaArr, RecVar: Variant;
  i, SyncedCount, NewId, TargetId: Integer;
begin
  Doc.InitJson(InContent);
  TableVal := LowerCase(Doc.GetValueOrDefault('table', ''));
  DeltaArr := Doc.GetValueOrDefault('delta', Null);
  SyncedCount := 0;
  InsertedIdsJson := '';

  if VarIsArray(DeltaArr) or (TDocVariantData(DeltaArr).Kind = dvArray) then
  begin
    for i := 0 to TDocVariantData(DeltaArr).Count - 1 do
    begin
      DeltaItemDoc.Init(TDocVariantData(DeltaArr).Values[i]);
      ActionVal := LowerCase(DeltaItemDoc.GetValueOrDefault('action', ''));
      ClientIdVal := DeltaItemDoc.GetValueOrDefault('clientId', '');
      TargetId := DeltaItemDoc.GetValueOrDefault('id', 0);
      RecVar := DeltaItemDoc.GetValueOrDefault('record', Null);

      if ActionVal = 'insert' then
      begin
        RecJson := VariantSaveJson(RecVar);
        if (TableVal = 'product') or (TableVal = 'products') then
        begin
          FCrudProduct.CreateItemFromJson(RecJson, NewId, DummyJson);
          if InsertedIdsJson <> '' then InsertedIdsJson := InsertedIdsJson + ',';
          if ClientIdVal <> '' then
            InsertedIdsJson := InsertedIdsJson + '"' + ClientIdVal + '":' + IntToStr(NewId);
          if TargetId < 0 then
          begin
            if ClientIdVal <> '' then InsertedIdsJson := InsertedIdsJson + ',';
            InsertedIdsJson := InsertedIdsJson + '"' + IntToStr(TargetId) + '":' + IntToStr(NewId);
          end;
          Inc(SyncedCount);
        end
        else
        begin
          FCrudCustomer.CreateItemFromJson(RecJson, NewId, DummyJson);
          if InsertedIdsJson <> '' then InsertedIdsJson := InsertedIdsJson + ',';
          if ClientIdVal <> '' then
            InsertedIdsJson := InsertedIdsJson + '"' + ClientIdVal + '":' + IntToStr(NewId);
          if TargetId < 0 then
          begin
            if ClientIdVal <> '' then InsertedIdsJson := InsertedIdsJson + ',';
            InsertedIdsJson := InsertedIdsJson + '"' + IntToStr(TargetId) + '":' + IntToStr(NewId);
          end;
          Inc(SyncedCount);
        end;
      end
      else if ActionVal = 'update' then
      begin
        RecJson := VariantSaveJson(RecVar);
        if (TableVal = 'product') or (TableVal = 'products') then
          FCrudProduct.UpdateItemFromJson(TargetId, RecJson, DummyJson)
        else
          FCrudCustomer.UpdateItemFromJson(TargetId, RecJson, DummyJson);
        Inc(SyncedCount);
      end
      else if ActionVal = 'delete' then
      begin
        if (TableVal = 'product') or (TableVal = 'products') then
          FCrudProduct.DeleteItem(TargetId)
        else
          FCrudCustomer.DeleteItem(TargetId);
        Inc(SyncedCount);
      end;
    end;
  end;

  Result := '{"status":"ok","syncedCount":' + IntToStr(SyncedCount) +
    ',"insertedIds":{' + InsertedIdsJson + '},"conflicts":[]}';
end;

function TBlaiseServerApp.DoRequest(Ctxt: THttpServerRequestAbstract): cardinal;
var
  LocalFile, DistIndex, Ext: string;
  Doc: TDocVariantData;
  NewTitle, NewCat: RawUtf8;
  V: Variant;
  CleanUrl: RawUtf8;
  qPos: Integer;
begin
  Inc(FRequestCount);

  // 0. Extract CleanUrl without query parameters (?v=... or #anchor)
  CleanUrl := Ctxt.Url;
  qPos := Pos('?', CleanUrl);
  if qPos > 0 then
    CleanUrl := Copy(CleanUrl, 1, qPos - 1);
  qPos := Pos('#', CleanUrl);
  if qPos > 0 then
    CleanUrl := Copy(CleanUrl, 1, qPos - 1);

  // 1. CORS Pre-flight and Headers
  Ctxt.OutCustomHeaders := 'Access-Control-Allow-Origin: *'#13#10 +
                           'Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-BlaiseVue-RPC, X-BlaiseVue-Pack'#13#10 +
                           'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS';
  if Ctxt.Method = 'OPTIONS' then
  begin
    Ctxt.OutContent := '';
    Result := HTTP_SUCCESS;
    Exit;
  end;

  // 2. REST API: GET /api/status
  if (Ctxt.Method = 'GET') and (CleanUrl = '/api/status') then
  begin
    Ctxt.OutContentType := JSON_CONTENT_TYPE;
    Ctxt.OutContent :=
      '{"status":"online"' +
      ',"framework":"BlaiseVue 4.3 Full-Stack"' +
      ',"engine":"Synopse mORMot 2"' +
      ',"port":' + FPort +
      ',"uptimeSeconds":' + IntToStr(SecondsBetween(Now, FStartTime)) +
      ',"requestsServed":' + IntToStr(FRequestCount) +
      ',"activeWebSockets":' + IntToStr(FServer.WebSocketConnections) +
      ',"itemsCount":' + IntToStr(Length(FItems)) + '}';
    Result := HTTP_SUCCESS;
    Exit;
  end;

  // 3. REST API: GET /api/items
  if (Ctxt.Method = 'GET') and (CleanUrl = '/api/items') then
  begin
    Ctxt.OutContentType := JSON_CONTENT_TYPE;
    Ctxt.OutContent := ItemsToJson;
    Result := HTTP_SUCCESS;
    Exit;
  end;

  // 4. REST API: POST /api/items
  if (Ctxt.Method = 'POST') and (CleanUrl = '/api/items') then
  begin
    NewTitle := 'New Task';
    NewCat := 'General';
    Doc.InitJson(Ctxt.InContent);
    try
      V := Doc.GetValueOrDefault('title', 'New Task');
      NewTitle := VariantToUtf8(V);
      V := Doc.GetValueOrDefault('category', 'General');
      NewCat := VariantToUtf8(V);
    finally
      Doc.Clear;
    end;

    AddItem(NewTitle, NewCat, False);
    Ctxt.OutContentType := JSON_CONTENT_TYPE;
    Ctxt.OutContent := '{"success":true,"id":' + IntToStr(Length(FItems)) + '}';

    // Broadcast to real-time clients!
    BroadcastEvent('item_created', Ctxt.OutContent);

    Result := HTTP_SUCCESS;
    Exit;
  end;

  // Interactive OpenAPI 3.0 & Swagger UI: /api/docs, /api/openapi.json
  if FSwaggerService.HandleRequest(Ctxt, CleanUrl, Result) then
    Exit;

  // Type-Safe mORMot 2 SOA RPC API: /api/rpc/*
  if FRpcDispatcher.HandleRequest(Ctxt, CleanUrl, Result) then
    Exit;

  // Product CRUD REST API: /api/products
  if FCrudProduct.HandleRequest(Ctxt, CleanUrl, Result) then
    Exit;

  // Authentication REST API: /api/auth/*
  if FAuthService.HandleRequest(Ctxt, CleanUrl, Result) then
    Exit;

  // Offline-First Dataset Delta Synchronization: POST /api/dataset/apply
  if (Ctxt.Method = 'POST') and ((CleanUrl = '/api/dataset/apply') or (CleanUrl = '/api/customers/apply') or (CleanUrl = '/api/products/apply')) then
  begin
    Ctxt.OutContentType := JSON_CONTENT_TYPE;
    Ctxt.OutContent := HandleDataSetApply(Ctxt.InContent);
    Result := HTTP_SUCCESS;
    Exit;
  end;

  // Customer CRUD REST API: /api/customers
  if FCrudCustomer.HandleRequest(Ctxt, CleanUrl, Result) then
    Exit;

  // 5. Static File Server & SPA History Fallback
  if (FDistPath <> '') and DirectoryExists(FDistPath) then
  begin
    if (CleanUrl <> '') and (CleanUrl <> '/') then
    begin
      LocalFile := FDistPath + DirectorySeparator + StringReplace(Copy(CleanUrl, 2, MaxInt), '/', DirectorySeparator, [rfReplaceAll]);
      if FileExists(LocalFile) and not DirectoryExists(LocalFile) then
      begin
        Exit(Ctxt.SetOutFile(LocalFile, False));
      end;

      // If a specific file asset (.js, .css, .png, etc.) was requested but not found on disk,
      // return 404 instead of returning index.html (which would cause JavaScript syntax errors).
      Ext := LowerCase(ExtractFileExt(LocalFile));
      if (Ext = '.js') or (Ext = '.css') or (Ext = '.png') or (Ext = '.jpg') or (Ext = '.jpeg') or
         (Ext = '.svg') or (Ext = '.ico') or (Ext = '.woff') or (Ext = '.woff2') or (Ext = '.ttf') or
         (Ext = '.eot') or (Ext = '.map') or (Ext = '.json') or (Ext = '.wasm') then
      begin
        // Outdated bundle fallback: if an older main.<hash>.js was requested, gracefully fallback to main.js!
        if (Ext = '.js') and (Pos('main.', LowerCase(ExtractFileName(LocalFile))) = 1) and
           FileExists(FDistPath + DirectorySeparator + 'js' + DirectorySeparator + 'main.js') then
        begin
          Exit(Ctxt.SetOutFile(FDistPath + DirectorySeparator + 'js' + DirectorySeparator + 'main.js', False));
        end;

        Ctxt.OutContentType := TEXT_CONTENT_TYPE;
        Ctxt.OutContent := '404 File Not Found: ' + CleanUrl;
        Result := HTTP_NOTFOUND;
        Exit;
      end;
    end;

    // SPA History API fallback: returns index.html for client-side routes
    DistIndex := FDistPath + DirectorySeparator + 'index.html';
    if FileExists(DistIndex) then
    begin
      Exit(Ctxt.SetOutFile(DistIndex, False));
    end;
  end;

  // 6. Root Fallback
  Ctxt.OutContentType := TEXT_CONTENT_TYPE;
  Ctxt.OutContent := 'BlaiseVue 4.3 + mORMot 2 Full-Stack Server Online (port ' + FPort + ')';
  Result := HTTP_SUCCESS;
end;

end.