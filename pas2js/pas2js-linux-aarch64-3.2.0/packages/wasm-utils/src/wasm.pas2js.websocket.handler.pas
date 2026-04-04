unit wasm.pas2js.websocket.handler;

{$mode ObjFPC}

interface

{$mode objfpc}
{$modeswitch externalclass}

uses
  JS
  , SysUtils
  , Rtl.WorkerCommands
  , Rtl.WebThreads
  , wasm.websocket.shared
  , wasm.pas2js.websocketapi
//  , W3D.Api.WasmHost
  ;


type
  { TApplication }

  TWebSocketCommand = record
    Operation : Integer;
    WebsocketID : integer;
    IntData : Integer;
    Data1 : TJSUInt8Array;
    Data2 : TJSUInt8Array;
  end;

  { TWasmWebSocketAPIHandler }

  TWasmWebSocketAPIHandler = class(TWasmWebSocketAPI)
  const
    SizeInt32 = 4; // Size in bytes
  private
    FSharedMem: TJSSharedArrayBuffer;
    FArray32: TJSInt32Array;
    FArray8: TJSUInt8Array;
    FView : TJSDataView;
    function HandleCloseCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;
    function HandleCreateCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;
    function HandleFreeCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;
    function HandleSendCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;
    function ProcessCommand(aValue: JSValue): JSValue;
    procedure SetSharedMem(AValue: TJSSharedArrayBuffer);
    procedure WatchSemaphore;
  protected
    procedure ReleasePacket(aWebSocketID : TWasmWebsocketID; aPointer : TWasmPointer);

  published
    Property SharedMem : TJSSharedArrayBuffer Read FSharedMem Write SetSharedMem;
  end;

  TSetSharedMemWorkerCommand = class external name 'Object' (TCustomWorkerCommand)
    Buffer : TJSSharedArrayBuffer;
  end;

implementation

function TWasmWebSocketAPIHandler.HandleCreateCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;

var
  lURL,lProtocols : String;
  lData : TJSUint8Array;
  lSock : TWasmWebsocket;

begin
  // Decoder does not like shared mem
  if assigned(aCmd.Data1) then
    begin
    lData:=TJSUint8Array(aCmd.Data1.slice(0));
    lURL:=Decoder.Decode(LData);
    end;
  if Assigned(aCmd.Data2) then
    begin
    lData:=TJSUint8Array(aCmd.Data2.slice(0));
    lProtocols:=Decoder.Decode(LData);
    end;
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.HandleCreateCmd("%s","%s",%d,%d)',[lURL,lProtocols,aCmd.IntData,aCmd.WebsocketID]);
  {$ENDIF}
  lSock:=CreateWebSocket(aCmd.WebsocketID,aCmd.IntData,lURL,lProtocols);
  if lSock=Nil then
    Result:=WASMWS_RESULT_ERROR
  else
    Result:=WASMWS_RESULT_SUCCESS;
  // No need to do anything
end;

function TWasmWebSocketAPIHandler.HandleFreeCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;
begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.HandleFreeCmd(%d)',[aCmd.WebsocketID]);
  {$ENDIF}
  if FreeWebSocket(aCmd.WebsocketID) then
    Result:=WASMWS_RESULT_SUCCESS
  else
    Result:=WASMWS_RESULT_INVALIDID;
end;

function TWasmWebSocketAPIHandler.HandleCloseCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;

var
  lSock : TWasmWebsocket;
  lData : TJSUint8Array;
  lReason : String;

begin
  lSock:=GetWebsocket(aCmd.WebsocketID);
  if not assigned(lSock) then
    Result:=WASMWS_RESULT_INVALIDID
  else
    begin
    lData:=TJSUint8Array(aCmd.Data1.slice(0));
    lReason:=Decoder.Decode(lData);
    lSock.Close(acmd.IntData,lReason);
    Result:=WASMWS_RESULT_SUCCESS;
    end;
end;

function TWasmWebSocketAPIHandler.HandleSendCmd(aCmd: TWebSocketCommand): TWasmWebsocketResult;
var
  lSock : TWasmWebsocket;
  lData: TJSUint8Array;
  lText : String;

begin
  lSock:=GetWebsocket(aCmd.WebsocketID);
  if Not assigned(lSock) then
    result:=WASMWS_RESULT_INVALIDID
  else
    begin
    // Neither SendBinarry nor Decoder like shared mem, need to copy...
    lData:=TJSUint8Array(aCmd.Data1.slice(0));
    if aCmd.IntData=WASMWS_MESSAGE_TYPE_BINARY then
      lSock.SendBinary(lData.buffer)
    else
      begin
      lText:=Decoder.Decode(lData);
      lSock.SendText(lText);
      end;
    Result:=WASMWS_RESULT_SUCCESS;
    end;
end;

function TWasmWebSocketAPIHandler.ProcessCommand(aValue: JSValue): JSValue;
var
  Cmd : TWebSocketCommand;
  lOffset,lLength : Integer;
  lResult:TWasmWebsocketResult;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('TWasmWebSocketAPIHandler Processing command');
  {$ENDIF}
  Result:=null;
  if not (String(aValue)='ok') then exit;
  Cmd:=Default(TWebSocketCommand);
  Cmd.WebsocketID:=FView.getInt32(WASM_SHMSG_WEBSOCKETID,Env.IsLittleEndian);
  Cmd.Operation:=FView.getUInt8(WASM_SHMSG_OPERATION);
  lResult:=WASMWS_RESULT_SUCCESS;
  case Cmd.Operation of
   WASM_WSOPERATION_CREATE:
     begin
     {$IFNDEF NOLOGAPICALLS}
     If LogAPICalls then
       LogCall('TWasmWebSocketAPIHandler Processing CREATE command');
     {$ENDIF}
     lLength:=FView.getInt32(WASM_SHMSG_CREATE_URL_LENGTH,Env.IsLittleEndian);
     if lLength>0 then
       Cmd.Data1:=TJSUint8Array.New(FSharedMem,WASM_SHMSG_CREATE_URL_DATA,lLength);
     lOffset:=WASM_SHMSG_CREATE_PROTOCOL_DATA_OFFSET+lLength;
     lLength:=FView.getInt32(WASM_SHMSG_CREATE_PROTOCOL_LENGTH,Env.IsLittleEndian);
     if lLength>0 then
       Cmd.Data2:=TJSUint8Array.New(FSharedMem,lOffset,lLength);
     Cmd.IntData:=FView.getInt32(WASM_SHMSG_CREATE_USERDATA,Env.IsLittleEndian);
     lResult:=HandleCreateCmd(Cmd);
     {$IFNDEF NOLOGAPICALLS}
     If LogAPICalls then
       LogCall('TWasmWebSocketAPIHandler Processed CREATE command. Result: %d',[lResult]);
     {$ENDIF}
     end;
   WASM_WSOPERATION_FREE:
     lResult:=HandleFreeCmd(Cmd);
   WASM_WSOPERATION_SEND:
     begin
     {$IFNDEF NOLOGAPICALLS}
     If LogAPICalls then
       LogCall('TWasmWebSocketAPIHandler Processing SEND command');
     {$ENDIF}
     lLength:=FView.getInt32(WASM_SHMSG_SEND_DATA_LENGTH,Env.IsLittleEndian);
     lOffset:=FView.getInt32(WASM_SHMSG_SEND_DATA_ADDRESS,Env.IsLittleEndian);
     Cmd.Data1:=TJSUint8Array.New(Self.getModuleMemoryDataView.buffer,lOffset,lLength);
     Cmd.IntData:=FView.getInt32(WASM_SHMSG_SEND_DATA_TYPE,Env.IsLittleEndian);
     {$IFNDEF NOLOGAPICALLS}
     If LogAPICalls then
       LogCall('TWasmWebSocketAPIHandler Processing send command. Data type: %d',[Cmd.IntData]);
     {$ENDIF}
     lResult:=HandleSendCmd(Cmd);
     ReleasePacket(cmd.WebsocketID,lOffset);
     end;
   WASM_WSOPERATION_CLOSE:
     begin
     {$IFNDEF NOLOGAPICALLS}
     If LogAPICalls then
       LogCall('TWasmWebSocketAPIHandler Processing CLOSE command');
     {$ENDIF}
     Cmd.IntData:=FView.getInt32(WASM_SHMSG_CLOSE_CODE,Env.IsLittleEndian);
     lOffset:=FView.getInt32(WASM_SHMSG_CLOSE_REASON_DATA,Env.IsLittleEndian);
     lLength:=FView.getInt32(WASM_SHMSG_CLOSE_REASON_LENGTH,Env.IsLittleEndian);
     Cmd.Data1:=TJSUint8Array.New(FSharedMem,lOffset,lLength);
     lResult:=HandleCloseCmd(Cmd);
     end
  else
    lResult:=WASMWS_RESULT_ERROR;
  end;
  // Store result
  TJSAtomics.store(FArray32,WASM_SHMSG_RESULT,lResult);
  // Set semaphore
  TJSAtomics.store(FArray32,WASM_SHMSG_SEMAPHORE,WASM_SEM_NOT_SET);
  // Notify
  TJSAtomics.notify(FArray32, WASM_SHMSG_SEMAPHORE, 4);
  // Restart watch...
  WatchSemaphore;
end;

procedure TWasmWebSocketAPIHandler.SetSharedMem(AValue: TJSSharedArrayBuffer);
begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('TWasmWebSocketAPIHandler, setting shared mem.');
  {$ENDIF}
  if FSharedMem=AValue then Exit;
  FSharedMem:=AValue;
  if assigned(FSharedMem) then
    begin
    FArray32:=TJSInt32Array.New(FSharedMem);
    FArray8:=TJSUInt8Array.New(FSharedMem);
    FView:=TJSDataView.New(FSharedMem);
    WatchSemaphore;
    end
  else
    begin
    FArray8:=Nil;
    FArray32:=Nil;
    FView:=Nil;
    end;
end;


procedure TWasmWebSocketAPIHandler.WatchSemaphore;

var
  lResult : TJSAtomicWaitResult;

begin
  lResult:=TJSAtomics.waitAsync(FArray32,WASM_SHMSG_SEMAPHORE,WASM_SEM_NOT_SET);
  if lResult.async then
    lResult.valueAsPromise._then(@ProcessCommand)
  else if lResult.valueAsString='ok' then
    ProcessCommand('ok');
end;

procedure TWasmWebSocketAPIHandler.ReleasePacket(aWebSocketID : TWasmWebsocketID; aPointer: TWasmPointer);

Type
  TReleasePacketFunc = function(aWebSocketID : Longint; aUserData : TWasmPointer; aPointer: TWasmPointer) : Integer;

var
  lRes : Boolean;
  lFunc : TReleasePacketFunc;
  lSock : TWasmWebsocket;
begin
  lSock:=GetWebsocket(aWebsocketID);
  if not Assigned(lSock) then exit;
  lFunc:=TReleasePacketFunc(InstanceExports['__wasm_websocket_release_packet']);
  lRes:=Assigned(lFunc);
  if lRes then
    lRes:=lFunc(aWebSocketID,lSock.UserData,aPointer)=0;
end;


end.

