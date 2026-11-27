
Unit ServerApp;




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

Interface

Uses 
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
ServerModels, CrudCustomer, CrudProduct, AuthService, SwaggerService, RpcService
;

Type 
  { Real-time WebSocket Protocol for BlaiseVue clients }
  TBlaiseWebSocketProtocol = Class(TWebSocketProtocolChat)
    Private 
      FRpcDispatcher: TRpcDispatcher;
    Protected 
      Procedure OnIncoming(Sender: TWebSocketProcess; Const Frame:
                           TWebSocketFrame);
    Public 
      constructor CreateProtocol(ARpcDispatcher: TRpcDispatcher = Nil);
      property RpcDispatcher: TRpcDispatcher read FRpcDispatcher write
                              FRpcDispatcher;
  End;

  { Main mORMot 2 Full-Stack Server Application }
  TBlaiseServerApp = Class
    Private 
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
      Function HandleDataSetApply(Const InContent: RawUtf8): RawUtf8;
      Function DoRequest(Ctxt: THttpServerRequestAbstract): cardinal;
    Public 
      constructor Create(Const APort: RawUtf8 = '8090'; Const ADistPath: String
                         = '../dist');
      destructor Destroy;
      override;
      Procedure AddItem(Const ATitle, ACategory: RawUtf8; ADone: Boolean);
      Function ItemsToJson: RawUtf8;
      Procedure BroadcastEvent(Const EventName, DataJson: RawUtf8);
      property Port: RawUtf8 read FPort;
      property RequestCount: Int64 read FRequestCount;
      property RpcDispatcher: TRpcDispatcher read FRpcDispatcher;
  End;

Implementation

{ TBlaiseWebSocketProtocol }

constructor TBlaiseWebSocketProtocol.CreateProtocol(ARpcDispatcher:
                                                    TRpcDispatcher);
Begin
  inherited Create('blaise-ws', '');
  FRpcDispatcher := ARpcDispatcher;
  OnIncomingFrame := OnIncoming;
End;

Procedure TBlaiseWebSocketProtocol.OnIncoming(Sender: TWebSocketProcess; Const
                                              Frame: TWebSocketFrame);
Begin
  Case Frame.opcode Of 
    focText, focBinary:
                        Begin
                          If (FRpcDispatcher <> Nil) And FRpcDispatcher.
                             HandleWebSocketFrame(Sender, Frame.payload) Then
                            Exit;



                    // Echo back incoming frame or dispatch to connected clients
                          SendFrame(Sender, Frame);
                        End;
  End;
End;

{ TBlaiseServerApp }

constructor TBlaiseServerApp.Create(Const APort: RawUtf8; Const ADistPath:
                                    String);
Begin
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
  FSwaggerService := TSwaggerService.Create('BlaiseVue Full-Stack mORMot 2 API',
                     '4.0.0', FPort);
  FAuthService.OnBroadcast := BroadcastEvent;
  FCrudCustomer := TCrudCustomerService.Create;
  FCrudCustomer.OnBroadcast := BroadcastEvent;

  FRpcDispatcher := TRpcDispatcher.Create(FCrudCustomer, FCrudProduct,
                    FAuthService);
  FRpcDispatcher.OnBroadcast := BroadcastEvent;

  FServer := TWebSocketServer.Create(FPort, Nil, Nil, 'blaisevue_fullstack', 4);
  FWSProtocol := TBlaiseWebSocketProtocol.CreateProtocol(FRpcDispatcher);
  FServer.WebSocketProtocols.Add(FWSProtocol);
  FServer.OnRequest := DoRequest;
End;

destructor TBlaiseServerApp.Destroy;
Begin
  FRpcDispatcher.Free;
  FCrudProduct.Free;
  FAuthService.Free;
  FSwaggerService.Free;
  FCrudCustomer.Free;
  FServer.Free;
  inherited Destroy;
End;

Procedure TBlaiseServerApp.AddItem(Const ATitle, ACategory: RawUtf8; ADone:
                                   Boolean);

Var 
  Idx: Integer;
Begin
  Idx := Length(FItems);
  SetLength(FItems, Idx + 1);
  FItems[Idx].ID := Idx + 1;
  FItems[Idx].Title := ATitle;
  FItems[Idx].Category := ACategory;
  FItems[Idx].Done := ADone;
  FItems[Idx].CreatedAt := DateTimeToStr(Now);
End;

Function TBlaiseServerApp.ItemsToJson: RawUtf8;

Var 
  i: Integer;
  DoneStr: RawUtf8;
Begin
  Result := '[';
  For i := 0 To High(FItems) Do
    Begin
      If i > 0 Then Result := Result + ',';
      If FItems[i].Done Then DoneStr := 'true'
      Else DoneStr := 'false';
      Result := Result +
                '{"id":' + IntToStr(FItems[i].ID) +
                ',"title":"' + FItems[i].Title + '"' +
                ',"category":"' + FItems[i].Category + '"' +
                ',"done":' + DoneStr +
                ',"createdAt":"' + FItems[i].CreatedAt + '"}';
    End;
  Result := Result + ']';
End;

Procedure TBlaiseServerApp.BroadcastEvent(Const EventName, DataJson: RawUtf8);

Var 
  Frame: TWebSocketFrame;
  Payload: RawUtf8;
Begin
  Payload := '{"event":"' + EventName + '","data":' + DataJson + '}';
  Frame.opcode := focText;
  Frame.payload := Payload;
  FServer.WebSocketBroadcast(Frame);
End;

Function TBlaiseServerApp.HandleDataSetApply(Const InContent: RawUtf8): RawUtf8;

Var 
  Doc, DeltaItemDoc: TDocVariantData;
  TableVal, ActionVal, ClientIdVal, RecJson, DummyJson: RawUtf8;
  InsertedIdsJson: RawUtf8;
  DeltaArr, RecVar: Variant;
  i, SyncedCount, NewId, TargetId: Integer;
Begin
  Doc.InitJson(InContent);
  TableVal := LowerCase(Doc.GetValueOrDefault('table', ''));
  DeltaArr := Doc.GetValueOrDefault('delta', Null);
  SyncedCount := 0;
  InsertedIdsJson := '';

  If VarIsArray(DeltaArr) Or (TDocVariantData(DeltaArr).Kind = dvArray) Then
    Begin
      For i := 0 To TDocVariantData(DeltaArr).Count - 1 Do
        Begin
          DeltaItemDoc.Init(TDocVariantData(DeltaArr).Values[i]);
          ActionVal := LowerCase(DeltaItemDoc.GetValueOrDefault('action', ''));
          ClientIdVal := DeltaItemDoc.GetValueOrDefault('clientId', '');
          TargetId := DeltaItemDoc.GetValueOrDefault('id', 0);
          RecVar := DeltaItemDoc.GetValueOrDefault('record', Null);

          If ActionVal = 'insert' Then
            Begin
              RecJson := VariantSaveJson(RecVar);
              If (TableVal = 'product') Or (TableVal = 'products') Then
                Begin
                  FCrudProduct.CreateItemFromJson(RecJson, NewId, DummyJson);
                  If InsertedIdsJson <> '' Then InsertedIdsJson := 


                                                                 InsertedIdsJson
                                                                   + ',';
                  If ClientIdVal <> '' Then
                    InsertedIdsJson := InsertedIdsJson + '"' + ClientIdVal +
                                       '":' + IntToStr(NewId);
                  If TargetId < 0 Then
                    Begin
                      If ClientIdVal <> '' Then InsertedIdsJson := 


                                                                 InsertedIdsJson
                                                                   + ',';
                      InsertedIdsJson := InsertedIdsJson + '"' + IntToStr(
                                         TargetId) + '":' + IntToStr(NewId);
                    End;
                  Inc(SyncedCount);
                End
              Else
                Begin
                  FCrudCustomer.CreateItemFromJson(RecJson, NewId, DummyJson);
                  If InsertedIdsJson <> '' Then InsertedIdsJson := 


                                                                 InsertedIdsJson
                                                                   + ',';
                  If ClientIdVal <> '' Then
                    InsertedIdsJson := InsertedIdsJson + '"' + ClientIdVal +
                                       '":' + IntToStr(NewId);
                  If TargetId < 0 Then
                    Begin
                      If ClientIdVal <> '' Then InsertedIdsJson := 


                                                                 InsertedIdsJson
                                                                   + ',';
                      InsertedIdsJson := InsertedIdsJson + '"' + IntToStr(
                                         TargetId) + '":' + IntToStr(NewId);
                    End;
                  Inc(SyncedCount);
                End;
            End
          Else If ActionVal = 'update' Then
                 Begin
                   RecJson := VariantSaveJson(RecVar);
                   If (TableVal = 'product') Or (TableVal = 'products') Then
                     FCrudProduct.UpdateItemFromJson(TargetId, RecJson,
                                                     DummyJson)
                   Else
                     FCrudCustomer.UpdateItemFromJson(TargetId, RecJson,
                                                      DummyJson);
                   Inc(SyncedCount);
                 End
          Else If ActionVal = 'delete' Then
                 Begin
                   If (TableVal = 'product') Or (TableVal = 'products') Then
                     FCrudProduct.DeleteItem(TargetId)
                   Else
                     FCrudCustomer.DeleteItem(TargetId);
                   Inc(SyncedCount);
                 End;
        End;
    End;

  Result := '{"status":"ok","syncedCount":' + IntToStr(SyncedCount) +
            ',"insertedIds":{' + InsertedIdsJson + '},"conflicts":[]}';
End;

Function TBlaiseServerApp.DoRequest(Ctxt: THttpServerRequestAbstract): cardinal;

Var 
  LocalFile, DistIndex, Ext: string;
  Doc: TDocVariantData;
  NewTitle, NewCat: RawUtf8;
  V: Variant;
  CleanUrl: RawUtf8;
  qPos: Integer;
Begin
  Inc(FRequestCount);

  // 0. Extract CleanUrl without query parameters (?v=... or #anchor)
  CleanUrl := Ctxt.Url;
  qPos := Pos('?', CleanUrl);
  If qPos > 0 Then
    CleanUrl := Copy(CleanUrl, 1, qPos - 1);
  qPos := Pos('#', CleanUrl);
  If qPos > 0 Then
    CleanUrl := Copy(CleanUrl, 1, qPos - 1);

  // 1. CORS Pre-flight and Headers
  Ctxt.OutCustomHeaders := 'Access-Control-Allow-Origin: *'#13#10 +



'Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-BlaiseVue-RPC, X-BlaiseVue-Pack'
                           #13#10 +



                 'Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS'
  ;
  If Ctxt.Method = 'OPTIONS' Then
    Begin
      Ctxt.OutContent := '';
      Result := HTTP_SUCCESS;
      Exit;
    End;

  // 2. REST API: GET /api/status
  If (Ctxt.Method = 'GET') And (CleanUrl = '/api/status') Then
    Begin
      Ctxt.OutContentType := JSON_CONTENT_TYPE;
      Ctxt.OutContent := 
                         '{"status":"online"' +
                         ',"framework":"BlaiseVue Full-Stack"' +
                         ',"engine":"Synopse mORMot 2"' +
                         ',"port":' + FPort +
                         ',"uptimeSeconds":' + IntToStr(SecondsBetween(Now,
                         FStartTime)) +
                         ',"requestsServed":' + IntToStr(FRequestCount) +
                         ',"activeWebSockets":' + IntToStr(FServer.
                         WebSocketConnections) +
                         ',"itemsCount":' + IntToStr(Length(FItems)) + '}';
      Result := HTTP_SUCCESS;
      Exit;
    End;

  // 3. REST API: GET /api/items
  If (Ctxt.Method = 'GET') And (CleanUrl = '/api/items') Then
    Begin
      Ctxt.OutContentType := JSON_CONTENT_TYPE;
      Ctxt.OutContent := ItemsToJson;
      Result := HTTP_SUCCESS;
      Exit;
    End;

  // 4. REST API: POST /api/items
  If (Ctxt.Method = 'POST') And (CleanUrl = '/api/items') Then
    Begin
      NewTitle := 'New Task';
      NewCat := 'General';
      Doc.InitJson(Ctxt.InContent);
      Try
        V := Doc.GetValueOrDefault('title', 'New Task');
        NewTitle := VariantToUtf8(V);
        V := Doc.GetValueOrDefault('category', 'General');
        NewCat := VariantToUtf8(V);
      Finally
        Doc.Clear;
    End;

  AddItem(NewTitle, NewCat, False);
  Ctxt.OutContentType := JSON_CONTENT_TYPE;
  Ctxt.OutContent := '{"success":true,"id":' + IntToStr(Length(FItems)) + '}';

  // Broadcast to real-time clients!
  BroadcastEvent('item_created', Ctxt.OutContent);

  Result := HTTP_SUCCESS;
  Exit;
End;

// Interactive OpenAPI 3.0 & Swagger UI: /api/docs, /api/openapi.json
If FSwaggerService.HandleRequest(Ctxt, CleanUrl, Result) Then
  Exit;

// Type-Safe mORMot 2 SOA RPC API: /api/rpc/*
If FRpcDispatcher.HandleRequest(Ctxt, CleanUrl, Result) Then
  Exit;

// Product CRUD REST API: /api/products
If FCrudProduct.HandleRequest(Ctxt, CleanUrl, Result) Then
  Exit;

// Authentication REST API: /api/auth/*
If FAuthService.HandleRequest(Ctxt, CleanUrl, Result) Then
  Exit;

// Offline-First Dataset Delta Synchronization: POST /api/dataset/apply
If (Ctxt.Method = 'POST') And ((CleanUrl = '/api/dataset/apply') Or (CleanUrl =
   '/api/customers/apply') Or (CleanUrl = '/api/products/apply')) Then
  Begin
    Ctxt.OutContentType := JSON_CONTENT_TYPE;
    Ctxt.OutContent := HandleDataSetApply(Ctxt.InContent);
    Result := HTTP_SUCCESS;
    Exit;
  End;

// Customer CRUD REST API: /api/customers
If FCrudCustomer.HandleRequest(Ctxt, CleanUrl, Result) Then
  Exit;

// 5. Static File Server & SPA History Fallback
If (FDistPath <> '') And DirectoryExists(FDistPath) Then
  Begin
    If (CleanUrl <> '') And (CleanUrl <> '/') Then
      Begin
        LocalFile := FDistPath + DirectorySeparator + StringReplace(Copy(
                     CleanUrl, 2, MaxInt), '/', DirectorySeparator, [
                     rfReplaceAll]);
        If FileExists(LocalFile) And Not DirectoryExists(LocalFile) Then
          Begin
            Exit(Ctxt.SetOutFile(LocalFile, False));
          End;




// If a specific file asset (.js, .css, .png, etc.) was requested but not found on disk,



// return 404 instead of returning index.html (which would cause JavaScript syntax errors).
        Ext := LowerCase(ExtractFileExt(LocalFile));
        If (Ext = '.js') Or (Ext = '.css') Or (Ext = '.png') Or (Ext = '.jpg')
           Or (Ext = '.jpeg') Or
           (Ext = '.svg') Or (Ext = '.ico') Or (Ext = '.woff') Or (Ext =
           '.woff2') Or (Ext = '.ttf') Or
           (Ext = '.eot') Or (Ext = '.map') Or (Ext = '.json') Or (Ext = '.wasm'
           ) Then
          Begin



// Outdated bundle fallback: if an older main.<hash>.js was requested, gracefully fallback to main.js!
            If (Ext = '.js') And (Pos('main.', LowerCase(ExtractFileName(
               LocalFile))) = 1) And
               FileExists(FDistPath + DirectorySeparator + 'js' +
               DirectorySeparator + 'main.js') Then
              Begin
                Exit(Ctxt.SetOutFile(FDistPath + DirectorySeparator + 'js' +
                     DirectorySeparator + 'main.js', False));
              End;

            Ctxt.OutContentType := TEXT_CONTENT_TYPE;
            Ctxt.OutContent := '404 File Not Found: ' + CleanUrl;
            Result := HTTP_NOTFOUND;
            Exit;
          End;
      End;

    // SPA History API fallback: returns index.html for client-side routes
    DistIndex := FDistPath + DirectorySeparator + 'index.html';
    If FileExists(DistIndex) Then
      Begin
        Exit(Ctxt.SetOutFile(DistIndex, False));
      End;
  End;

// 6. Root Fallback
Ctxt.OutContentType := TEXT_CONTENT_TYPE;
Ctxt.OutContent := 'BlaiseVue + mORMot 2 Full-Stack Server Online (port ' +
                   FPort + ')';
Result := HTTP_SUCCESS;
End;

End.
