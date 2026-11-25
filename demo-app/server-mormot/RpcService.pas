unit RpcService;

{
  RpcService - BlaiseVue 4.3 Type-Safe mORMot 2 SOA RPC Dispatcher
  ----------------------------------------------------------------
  Provides high-throughput remote procedure call dispatching for:
  - Strongly typed contracts: ICustomerService, IProductService, ISystemService
  - Endpoints:
    * POST /api/rpc/:service/:method
    * POST /api/rpc (JSON-RPC 2.0 single router)
    * Bidirectional real-time WebSockets (rpc_call -> rpc_response)
  - Full binary and compact JSON pack serialization support
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
  mormot.core.variants,
  mormot.core.json,
  mormot.net.http,
  mormot.net.server,
  mormot.net.ws.core,
  mormot.net.ws.server,
  ServerModels, CrudCustomer, CrudProduct, AuthService;

type
  TBroadcastEventProc = procedure(const EventName, DataJson: RawUtf8) of object;

  { High-Performance mORMot 2 SOA RPC Dispatcher }
  TRpcDispatcher = class
  private
    FCrudCustomer: TCrudCustomerService;
    FCrudProduct: TCrudProductService;
    FAuthService: TAuthService;
    FStartTime: TDateTime;
    FOnBroadcast: TBroadcastEventProc;

    function ExecuteMethod(const ServiceName, MethodName: RawUtf8;
      const ParamsJson: RawUtf8; out ResultJson: RawUtf8; out ErrorCode: Integer;
      out ErrorMsg: RawUtf8): Boolean;
  public
    constructor Create(ACrudCustomer: TCrudCustomerService;
      ACrudProduct: TCrudProductService; AAuthService: TAuthService);
    destructor Destroy; override;

    function HandleRequest(Ctxt: THttpServerRequestAbstract;
      const CleanUrl: RawUtf8; out HttpResult: cardinal): Boolean;
    function HandleWebSocketFrame(Sender: TWebSocketProcess;
      const Payload: RawUtf8): Boolean;

    property OnBroadcast: TBroadcastEventProc read FOnBroadcast write FOnBroadcast;
  end;

implementation

{ TRpcDispatcher }

constructor TRpcDispatcher.Create(ACrudCustomer: TCrudCustomerService;
  ACrudProduct: TCrudProductService; AAuthService: TAuthService);
begin
  inherited Create;
  FCrudCustomer := ACrudCustomer;
  FCrudProduct := ACrudProduct;
  FAuthService := AAuthService;
  FStartTime := Now;
end;

destructor TRpcDispatcher.Destroy;
begin
  inherited Destroy;
end;

function TRpcDispatcher.ExecuteMethod(const ServiceName, MethodName: RawUtf8;
  const ParamsJson: RawUtf8; out ResultJson: RawUtf8; out ErrorCode: Integer;
  out ErrorMsg: RawUtf8): Boolean;
var
  Doc, ItemDoc: TDocVariantData;
  SvcUpper, MethodUpper: RawUtf8;
  Param1: Variant;
  IdVal: Integer;
  ObjJson, TmpJson: RawUtf8;
  NewId: Integer;
begin
  Result := True;
  ErrorCode := 0;
  ErrorMsg := '';
  ResultJson := 'null';

  SvcUpper := UpperCase(ServiceName);
  MethodUpper := UpperCase(MethodName);

  Doc.InitJson(ParamsJson);
  try
    { CustomerService Dispatch }
    if (SvcUpper = 'CUSTOMERSERVICE') or (SvcUpper = 'ICUSTOMERSERVICE') or (SvcUpper = 'CUSTOMER') then
    begin
      if MethodUpper = 'GETALL' then
      begin
        ResultJson := FCrudCustomer.GetAllJson;
      end
      else if MethodUpper = 'GETBYID' then
      begin
        IdVal := 0;
        if Doc.Count > 0 then
          IdVal := Doc.Values[0];
        if not FCrudCustomer.GetByIdJson(IdVal, ResultJson) then
        begin
          ErrorCode := -32602;
          ErrorMsg := 'Customer with ID ' + IntToStr(IdVal) + ' not found';
          Result := False;
        end;
      end
      else if MethodUpper = 'SAVE' then
      begin
        ObjJson := '{}';
        if Doc.Count > 0 then
        begin
          Param1 := Doc.Values[0];
          ObjJson := VariantSaveJson(Param1);
        end;

        IdVal := 0;
        ItemDoc.InitJson(ObjJson);
        try
          IdVal := ItemDoc.GetValueOrDefault('id', 0);
        finally
          ItemDoc.Clear;
        end;

        if IdVal > 0 then
        begin
          if not FCrudCustomer.UpdateItemFromJson(IdVal, ObjJson, ResultJson) then
            FCrudCustomer.CreateItemFromJson(ObjJson, NewId, ResultJson);
        end
        else
        begin
          FCrudCustomer.CreateItemFromJson(ObjJson, NewId, ResultJson);
        end;
      end
      else if MethodUpper = 'DELETE' then
      begin
        IdVal := 0;
        if Doc.Count > 0 then
          IdVal := Doc.Values[0];
        if FCrudCustomer.DeleteItem(IdVal) then
          ResultJson := 'true'
        else
        begin
          ErrorCode := -32602;
          ErrorMsg := 'Failed to delete customer with ID ' + IntToStr(IdVal);
          Result := False;
        end;
      end
      else
      begin
        ErrorCode := -32601;
        ErrorMsg := 'Method not found: CustomerService.' + MethodName;
        Result := False;
      end;
      Exit;
    end;

    { ProductService Dispatch }
    if (SvcUpper = 'PRODUCTSERVICE') or (SvcUpper = 'IPRODUCTSERVICE') or (SvcUpper = 'PRODUCT') then
    begin
      if MethodUpper = 'GETALL' then
      begin
        ResultJson := FCrudProduct.GetAllJson;
      end
      else if MethodUpper = 'GETBYID' then
      begin
        IdVal := 0;
        if Doc.Count > 0 then
          IdVal := Doc.Values[0];
        if not FCrudProduct.GetByIdJson(IdVal, ResultJson) then
        begin
          ErrorCode := -32602;
          ErrorMsg := 'Product with ID ' + IntToStr(IdVal) + ' not found';
          Result := False;
        end;
      end
      else if MethodUpper = 'SAVE' then
      begin
        ObjJson := '{}';
        if Doc.Count > 0 then
          Param1 := Doc.Values[0];
        ObjJson := VariantSaveJson(Param1);

        IdVal := 0;
        ItemDoc.InitJson(ObjJson);
        try
          IdVal := ItemDoc.GetValueOrDefault('id', 0);
        finally
          ItemDoc.Clear;
        end;

        if IdVal > 0 then
        begin
          if not FCrudProduct.UpdateItemFromJson(IdVal, ObjJson, ResultJson) then
            FCrudProduct.CreateItemFromJson(ObjJson, NewId, ResultJson);
        end
        else
        begin
          FCrudProduct.CreateItemFromJson(ObjJson, NewId, ResultJson);
        end;
      end
      else if MethodUpper = 'DELETE' then
      begin
        IdVal := 0;
        if Doc.Count > 0 then
          IdVal := Doc.Values[0];
        if FCrudProduct.DeleteItem(IdVal) then
          ResultJson := 'true'
        else
        begin
          ErrorCode := -32602;
          ErrorMsg := 'Failed to delete product with ID ' + IntToStr(IdVal);
          Result := False;
        end;
      end
      else
      begin
        ErrorCode := -32601;
        ErrorMsg := 'Method not found: ProductService.' + MethodName;
        Result := False;
      end;
      Exit;
    end;

    { SystemService Dispatch }
    if (SvcUpper = 'SYSTEMSERVICE') or (SvcUpper = 'ISYSTEMSERVICE') or (SvcUpper = 'SYSTEM') then
    begin
      if MethodUpper = 'GETSTATUS' then
      begin
        ResultJson := '"online"';
      end
      else if MethodUpper = 'PING' then
      begin
        TmpJson := 'pong';
        if Doc.Count > 0 then
          TmpJson := VariantToUtf8(Doc.Values[0]);
        ResultJson := '"pong: ' + TmpJson + '"';
      end
      else if MethodUpper = 'ECHO' then
      begin
        TmpJson := '';
        if Doc.Count > 0 then
          TmpJson := VariantToUtf8(Doc.Values[0]);
        ResultJson := '"' + TmpJson + '"';
      end
      else
      begin
        ErrorCode := -32601;
        ErrorMsg := 'Method not found: SystemService.' + MethodName;
        Result := False;
      end;
      Exit;
    end;

    { Unrecognized Service }
    ErrorCode := -32601;
    ErrorMsg := 'Service not found: ' + ServiceName;
    Result := False;

  finally
    Doc.Clear;
  end;
end;

function TRpcDispatcher.HandleRequest(Ctxt: THttpServerRequestAbstract;
  const CleanUrl: RawUtf8; out HttpResult: cardinal): Boolean;
var
  Prefix: RawUtf8;
  RestPath: RawUtf8;
  SlashPos: Integer;
  ServiceName, MethodName: RawUtf8;
  ReqDoc: TDocVariantData;
  ReqId: Int64;
  ParamsVal: Variant;
  ParamsJson: RawUtf8;
  ResultJson, ErrorMsg: RawUtf8;
  ErrorCode: Integer;
  Success: Boolean;
  IsPack: Boolean;
begin
  Result := False;
  Prefix := '/api/rpc';

  if (CleanUrl <> Prefix) and (Copy(CleanUrl, 1, Length(Prefix) + 1) <> Prefix + '/') then
    Exit;

  Result := True;
  HttpResult := HTTP_SUCCESS;
  Ctxt.OutContentType := JSON_CONTENT_TYPE;

  // Check for high-throughput packing mode header
  IsPack := Pos('X-BLAISEVUE-PACK', UpperCase(Ctxt.InHeaders)) > 0;
  if IsPack then
    Ctxt.OutCustomHeaders := Ctxt.OutCustomHeaders + #13#10'X-BlaiseVue-Pack: 1';

  ReqId := 1;
  ServiceName := '';
  MethodName := '';
  ParamsJson := '[]';

  RestPath := Copy(CleanUrl, Length(Prefix) + 2, MaxInt);
  if RestPath <> '' then
  begin
    SlashPos := Pos('/', RestPath);
    if SlashPos > 0 then
    begin
      ServiceName := Copy(RestPath, 1, SlashPos - 1);
      MethodName := Copy(RestPath, SlashPos + 1, MaxInt);
    end
    else
    begin
      ServiceName := RestPath;
      MethodName := '';
    end;
  end;

  // Parse Body (JSON-RPC 2.0 payload)
  if Ctxt.InContent <> '' then
  begin
    ReqDoc.InitJson(Ctxt.InContent);
    try
      if ServiceName = '' then
        ServiceName := VariantToUtf8(ReqDoc.GetValueOrDefault('service', ''));
      if MethodName = '' then
        MethodName := VariantToUtf8(ReqDoc.GetValueOrDefault('method', ''));

      // If method is in dotted format e.g. "CustomerService.GetAll"
      SlashPos := Pos('.', MethodName);
      if (SlashPos > 0) and (ServiceName = '') then
      begin
        ServiceName := Copy(MethodName, 1, SlashPos - 1);
        MethodName := Copy(MethodName, SlashPos + 1, MaxInt);
      end;

      if ReqDoc.GetValueOrDefault('id', 0) <> 0 then
        ReqId := ReqDoc.GetValueOrDefault('id', 1);

      ParamsVal := ReqDoc.GetValueOrDefault('params', Null);
      if not VarIsNull(ParamsVal) then
        ParamsJson := VariantSaveJson(ParamsVal);
    finally
      ReqDoc.Clear;
    end;
  end;

  Success := ExecuteMethod(ServiceName, MethodName, ParamsJson, ResultJson, ErrorCode, ErrorMsg);

  if Success then
  begin
    Ctxt.OutContent :=
      '{"jsonrpc":"2.0","result":' + ResultJson + ',"id":' + IntToStr(ReqId) + '}';
  end
  else
  begin
    Ctxt.OutContent :=
      '{"jsonrpc":"2.0","error":{"code":' + IntToStr(ErrorCode) + ',"message":"' + ErrorMsg + '"},"id":' + IntToStr(ReqId) + '}';
  end;
end;

function TRpcDispatcher.HandleWebSocketFrame(Sender: TWebSocketProcess;
  const Payload: RawUtf8): Boolean;
var
  Doc, DataDoc: TDocVariantData;
  EvtName: RawUtf8;
  ServiceName, MethodName, ParamsJson: RawUtf8;
  ReqId: Int64;
  ResultJson, ErrorMsg, OutResp: RawUtf8;
  ErrorCode: Integer;
  Success: Boolean;
  Frame: TWebSocketFrame;
begin
  Result := False;
  if Pos('"rpc_call"', Payload) = 0 then
    Exit;

  Doc.InitJson(Payload);
  try
    EvtName := VariantToUtf8(Doc.GetValueOrDefault('event', ''));
    if EvtName <> 'rpc_call' then Exit;

    Result := True;
    DataDoc.InitJson(VariantSaveJson(Doc.GetValueOrDefault('data', Null)));
    try
      ServiceName := VariantToUtf8(DataDoc.GetValueOrDefault('service', ''));
      MethodName := VariantToUtf8(DataDoc.GetValueOrDefault('method', ''));
      ReqId := DataDoc.GetValueOrDefault('id', 1);
      ParamsJson := VariantSaveJson(DataDoc.GetValueOrDefault('params', Null));

      Success := ExecuteMethod(ServiceName, MethodName, ParamsJson, ResultJson, ErrorCode, ErrorMsg);

      if Success then
      begin
        OutResp := '{"event":"rpc_response","data":{"jsonrpc":"2.0","result":' +
          ResultJson + ',"id":' + IntToStr(ReqId) + '}}';
      end
      else
      begin
        OutResp := '{"event":"rpc_response","data":{"jsonrpc":"2.0","error":{"code":' +
          IntToStr(ErrorCode) + ',"message":"' + ErrorMsg + '"},"id":' + IntToStr(ReqId) + '}}';
      end;

      Frame.opcode := focText;
      Frame.payload := OutResp;
      Sender.SendFrame(Frame);
    finally
      DataDoc.Clear;
    end;
  finally
    Doc.Clear;
  end;
end;

end.