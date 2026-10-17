unit ServerApp;

{
  ServerApp - High-Throughput HTTP REST & WebSocket Server (mORMot 2)
  -------------------------------------------------------------------
  Engineered for the BlaiseVue Universal Framework to provide:
  - Ultra-fast native HTTP REST API endpoints
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
  ServerModels;

type
  { Real-time WebSocket Protocol for BlaiseVue clients }
  TBlaiseWebSocketProtocol = class(TWebSocketProtocolChat)
  protected
    procedure OnIncoming(Sender: TWebSocketProcess; const Frame: TWebSocketFrame);
  public
    constructor CreateProtocol;
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
    function DoRequest(Ctxt: THttpServerRequestAbstract): cardinal;
  public
    constructor Create(const APort: RawUtf8 = '8090'; const ADistPath: string = '../dist');
    destructor Destroy; override;
    procedure AddItem(const ATitle, ACategory: RawUtf8; ADone: Boolean);
    function ItemsToJson: RawUtf8;
    procedure BroadcastEvent(const EventName, DataJson: RawUtf8);
    property Port: RawUtf8 read FPort;
    property RequestCount: Int64 read FRequestCount;
  end;

implementation

{ TBlaiseWebSocketProtocol }

constructor TBlaiseWebSocketProtocol.CreateProtocol;
begin
  inherited Create('blaise-ws', '');
  OnIncomingFrame := OnIncoming;
end;

procedure TBlaiseWebSocketProtocol.OnIncoming(Sender: TWebSocketProcess; const Frame: TWebSocketFrame);
begin
  case Frame.opcode of
    focText, focBinary:
      begin
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

  FServer := TWebSocketServer.Create(FPort, nil, nil, 'blaisevue_fullstack', 4);
  FWSProtocol := TBlaiseWebSocketProtocol.CreateProtocol;
  FServer.WebSocketProtocols.Add(FWSProtocol);
  FServer.OnRequest := DoRequest;
end;

destructor TBlaiseServerApp.Destroy;
begin
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

function TBlaiseServerApp.DoRequest(Ctxt: THttpServerRequestAbstract): cardinal;
var
  LocalFile, DistIndex: string;
  Doc: TDocVariantData;
  NewTitle, NewCat: RawUtf8;
  V: Variant;
begin
  Inc(FRequestCount);

  // 1. CORS Pre-flight and Headers
  Ctxt.OutCustomHeaders := 'Access-Control-Allow-Origin: *'#13#10 +
                           'Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With'#13#10 +
                           'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS';
  if Ctxt.Method = 'OPTIONS' then
  begin
    Ctxt.OutContent := '';
    Result := HTTP_SUCCESS;
    Exit;
  end;

  // 2. REST API: GET /api/status
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

  // 3. REST API: GET /api/items
  if (Ctxt.Method = 'GET') and (Ctxt.Url = '/api/items') then
  begin
    Ctxt.OutContentType := JSON_CONTENT_TYPE;
    Ctxt.OutContent := ItemsToJson;
    Result := HTTP_SUCCESS;
    Exit;
  end;

  // 4. REST API: POST /api/items
  if (Ctxt.Method = 'POST') and (Ctxt.Url = '/api/items') then
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

  // 5. Static File Server & SPA History Fallback
  if (FDistPath <> '') and DirectoryExists(FDistPath) then
  begin
    if (Ctxt.Url <> '') and (Ctxt.Url <> '/') then
    begin
      LocalFile := FDistPath + DirectorySeparator + StringReplace(Copy(Ctxt.Url, 2, MaxInt), '/', DirectorySeparator, [rfReplaceAll]);
      if FileExists(LocalFile) and not DirectoryExists(LocalFile) then
      begin
        Exit(Ctxt.SetOutFile(LocalFile, False));
      end;
    end;

    DistIndex := FDistPath + DirectorySeparator + 'index.html';
    if FileExists(DistIndex) then
    begin
      Exit(Ctxt.SetOutFile(DistIndex, False));
    end;
  end;

  // 6. Root Fallback
  Ctxt.OutContentType := TEXT_CONTENT_TYPE;
  Ctxt.OutContent := 'BlaiseVue 3.5 + mORMot 2 Full-Stack Server Online (port ' + FPort + ')';
  Result := HTTP_SUCCESS;
end;

end.
