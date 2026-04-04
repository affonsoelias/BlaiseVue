unit wasm.pas2js.websocket.worker;

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
  JS, Rtl.WebThreads, Rtl.WorkerCommands, weborworker, wasienv, wasm.pas2js.websocketapi, wasm.websocket.shared;


type
  // When an unexpected error occurred.
  TWebsocketSetMemCommand  = class external name 'Object' (TCustomWorkerCommand)
  public
    Buffer : TJSSharedArrayBuffer;
  end;

  TWebsocketSetMemCommandHelper = class helper for TWebsocketSetMemCommand
    Class function CommandName : string; static;
    Class function CreateNew(aBuffer : TJSSharedArrayBuffer; aThreadID : Integer = -1) : TWebsocketSetMemCommand; static;
  end;

  // When an unexpected error occurred.
  TWebsocketHandlerOKCommand  = class external name 'Object' (TCustomWorkerCommand)
  end;

  { TWebsocketHandlerOKCommandHelper }

  TWebsocketHandlerOKCommandHelper = class helper for TWebsocketHandlerOKCommand
    Class function CommandName : string; static;
    Class function CreateNew(aBuffer : TJSSharedArrayBuffer; aThreadID : Integer = -1) : TWebsocketHandlerOKCommand; static;
  end;


  {
    This class implements an API where the websocket commands are actually transferred to a worker thread.
    The worker thread is by default websocket_worker.js (see project websocket_worker.lpr)
  }
  { TWorkerWebSocketAPI }

  TWorkerWebSocketAPI = class(TWasmBaseWebSocketAPI)
  const
    SizeInt32 = 4; // Size in bytes
  private
    FSharedMem: TJSSharedArrayBuffer;
    FArray32 : TJSInt32Array;
    FArray8 : TJSUInt8Array;
    FView : TJSDataView;
  protected
    procedure SetSharedMem(AValue: TJSSharedArrayBuffer); virtual;
    function AwaitResult: TWasmWebsocketResult;
  Public
    function LockMem : boolean;
    procedure UnlockMem;
    function WebsocketAllocate(aURL : PByte; aUrlLen : Longint; aProtocols : PByte; aProtocolLen : Longint; aUserData : TWasmPointer; aWebsocketID : PWasmWebSocketID) : TWasmWebsocketResult; override;
    function WebsocketDeAllocate(aWebsocketID : TWasmWebSocketID) : TWasmWebsocketResult; override;
    function WebsocketClose(aWebsocketID : TWasmWebSocketID; aCode : Longint; aReason : PByte; aReasonLen : Longint) : TWasmWebsocketResult; override;
    function WebsocketSend(aWebsocketID : TWasmWebSocketID; aData : PByte; aDataLen : Longint; aType : Longint) : TWasmWebsocketResult; override;
    property SharedMem : TJSSharedArrayBuffer Read FSharedMem Write SetSharedMem;
  end;

  { TLoaderWorkerWebSocketAPI }

  TLoaderWorkerWebSocketAPI = class(TWorkerWebSocketAPI)
  Private
    FWebsocketWorker : TJSWorker;
    FWorkerOK : Boolean;
    procedure HandleWebsoketHandlerOK(aCommand: TWebsocketHandlerOKCommand);
  Protected
    procedure SetSharedMem(AValue: TJSSharedArrayBuffer); override;
    procedure SendSharedMemToWorker;
  Public
    procedure SendSharedMemToWorker(aWorker : TJSWorker);
    procedure StartWebsocketHandler(const aScriptName : string = '');
    property WebsocketWorker : TJSWorker Read FWebsocketWorker;
  end;

  { TRunnerWorkerWebSocketAPI }

  TRunnerWorkerWebSocketAPI = class(TWorkerWebSocketAPI)
    procedure ListenForSharedMemory;
  private
    procedure HandleWebSocketMemMessage(aCommand: TWebsocketSetMemCommand);
  Public
    constructor Create(aEnv: TPas2JSWASIEnvironment); override;
  end;



implementation

uses sysutils;

{ TWebsocketSetMemCommandHelper }

class function TWebsocketSetMemCommandHelper.CommandName: string;

begin
  Result:=cmdWebsocketSharedMem;
end;

class function TWebsocketSetMemCommandHelper.CreateNew(aBuffer : TJSSharedArrayBuffer; aThreadID: Integer): TWebsocketSetMemCommand;
begin
  Result:= TWebsocketSetMemCommand(createCommand(CommandName,IntToStr(aThreadID)));
  Result.Buffer:=aBuffer;
end;

{ TWebsocketHandlerOKCommandHelper }

class function TWebsocketHandlerOKCommandHelper.CommandName: string;
begin
  Result:='websockethandlerok';
end;

class function TWebsocketHandlerOKCommandHelper.CreateNew(aBuffer: TJSSharedArrayBuffer; aThreadID: Integer
  ): TWebsocketHandlerOKCommand;
begin
  Result:= TWebsocketHandlerOKCommand(createCommand(CommandName,IntToStr(aThreadID)));
end;


{ TWorkerWebSocketAPI }

procedure TWorkerWebSocketAPI.SetSharedMem(AValue: TJSSharedArrayBuffer);
begin
  if FSharedMem=AValue then Exit;
  FSharedMem:=AValue;
  if Assigned(aValue) then
    begin
    FArray32:=TJSInt32Array.New(FSharedMem);
    FArray8:=TJSUInt8Array.New(FSharedMem);
    FView:=TJSDataView.New(FSharedMem);
    end
  else
    begin
    FArray32:=Nil;
    FArray8:=Nil;
    FView:=Nil;
    end;
end;

function TWorkerWebSocketAPI.LockMem: boolean;


begin
  // Wait while it is set.
  Result:=Assigned(FView);
  if Result then
    TJSAtomics.wait(FArray32,WASM_SHMSG_SEMAPHORE div sizeInt32,WASM_SEM_SET);
  // Now, when here we definitely have value WASM_SEM_NOT_SET
end;

function TWorkerWebSocketAPI.AwaitResult : TWasmWebsocketResult;

var
  S : String;

begin
  if not Assigned(FView) then
    Result:=WASMWS_RESULT_FAILEDLOCK
  else
    begin
    S:=TJSAtomics.wait(FArray32,WASM_SHMSG_SEMAPHORE div SizeInt32,WASM_SEM_SET);
    if s='ok' then
      Result:=TJSAtomics.load(FArray32,WASM_SHMSG_RESULT div SizeInt32) // get a result
    else // no result
      Result:=WASMWS_RESULT_FAILEDLOCK;
    end;
end;


procedure TWorkerWebSocketAPI.UnlockMem;
begin
  // Set and notify.
  if not Assigned(FView) then
    exit;
  TJSAtomics.store(FArray32, WASM_SHMSG_SEMAPHORE div SizeInt32, WASM_SEM_SET);
  TJSAtomics.notify(FArray32, WASM_SHMSG_SEMAPHORE div SizeInt32, 1);
end;


function TWorkerWebSocketAPI.WebsocketAllocate(aURL: PByte; aUrlLen: Longint; aProtocols: PByte; aProtocolLen: Longint;
  aUserData: TWasmPointer; aWebsocketID: PWasmWebSocketID): TWasmWebsocketResult;


var
  lID : TWasmWebsocketID;
  lTmp : TJSUint8Array;
  lProtocolOffset : Longint;

begin
  lID:=GetNextID;
  if not Assigned(FArray8) then
    Exit(WASMWS_RESULT_NOSHAREDMEM);
  if (aURLLen+aProtocolLen)>(FArray8.byteLength-WASM_SHMSG_FIXED_LEN) then
     Exit(WASMWS_RESULT_INVALIDSIZE);
  if (aURLLen<=0) then
    Exit(WASMWS_RESULT_INVALIDSIZE);
  if (aProtocolLen<0) then
    Exit(WASMWS_RESULT_INVALIDSIZE);
  if Not LockMem then
    Exit(WASMWS_RESULT_FAILEDLOCK);
  try
    FView.setInt32(WASM_SHMSG_WEBSOCKETID,lID,Env.IsLittleEndian);
    FView.setInt8(WASM_SHMSG_OPERATION,WASM_WSOPERATION_CREATE);
    FView.setInt32(WASM_SHMSG_CREATE_USERDATA,aUserData,Env.IsLittleEndian);
    FView.setInt32(WASM_SHMSG_CREATE_URL_LENGTH,aUrlLen,Env.IsLittleEndian);
    FView.setInt32(WASM_SHMSG_CREATE_PROTOCOL_LENGTH,aProtocolLen,Env.IsLittleEndian);
    // Write URL to shared buffer (it may no longer exist when the message is treated)
    lTmp:=TJSUInt8Array.New(Env.Memory.buffer,aURL,aUrlLen);
    FArray8._set(lTmp,WASM_SHMSG_CREATE_URL_DATA);
    // Write protocols if they are present.
    if aProtocolLen>0 then
      begin
      lTmp:=TJSUInt8Array.New(Env.Memory.buffer,aProtocols,aProtocolLen);
      lProtocolOffset:=WASM_SHMSG_CREATE_PROTOCOL_DATA_OFFSET+aURLLen;
      FArray8._set(lTmp,lProtocolOffset);
      end;
  finally
    UnlockMem;
  end;
  Result:=AwaitResult;
  getModuleMemoryDataView.setInt32(aWebsocketID,lID);
  Result:=WASMWS_RESULT_SUCCESS;
end;

function TWorkerWebSocketAPI.WebsocketDeAllocate(aWebsocketID: TWasmWebSocketID): TWasmWebsocketResult;

begin
  if Not LockMem then
    Exit(WASMWS_RESULT_FAILEDLOCK);
  try
    FView.setInt32(WASM_SHMSG_WEBSOCKETID,aWebsocketID,Env.IsLittleEndian);
    FView.setInt8(WASM_SHMSG_OPERATION,WASM_WSOPERATION_FREE);
    // Result:=AwaitResult;
  finally
    UnlockMem;
  end;
  Result:=WASMWS_RESULT_SUCCESS;
end;

function TWorkerWebSocketAPI.WebsocketClose(aWebsocketID: TWasmWebSocketID; aCode: Longint; aReason: PByte; aReasonLen: Longint): TWasmWebsocketResult;

var
  lTmp : TJSUint8Array;

begin
  if Not LockMem then
    Exit(WASMWS_RESULT_FAILEDLOCK);
  try
    FView.setInt32(WASM_SHMSG_WEBSOCKETID,aWebsocketID,Env.IsLittleEndian);
    FView.setInt8(WASM_SHMSG_OPERATION,WASM_WSOPERATION_CLOSE);
    FView.setInt32(WASM_SHMSG_CLOSE_CODE,aCode,Env.IsLittleEndian);
    FView.setInt32(WASM_SHMSG_CLOSE_REASON_LENGTH,aReasonLen,Env.IsLittleEndian);
    if aReasonLen>0 then
      begin
      lTmp:=TJSUInt8Array.New(FSharedMem,aReason,aReasonLen);
      FArray8._set(lTmp,WASM_SHMSG_CLOSE_REASON_DATA);
      end;
    // Result:=AwaitResult;
  finally
    UnlockMem;
  end;
  Result:=WASMWS_RESULT_SUCCESS;
end;


function TWorkerWebSocketAPI.WebsocketSend(aWebsocketID: TWasmWebSocketID; aData: PByte; aDataLen: Longint; aType: Longint
  ): TWasmWebsocketResult;

begin
  if Not LockMem then
    Exit(WASMWS_RESULT_FAILEDLOCK);
  try
    FView.setInt32(WASM_SHMSG_WEBSOCKETID,aWebsocketID,Env.IsLittleEndian);
    FView.setInt8(WASM_SHMSG_OPERATION,WASM_WSOPERATION_SEND);
    FView.setInt32(WASM_SHMSG_SEND_DATA_LENGTH,aDataLen,Env.IsLittleEndian);
    FView.setInt32(WASM_SHMSG_SEND_DATA_TYPE,aType,Env.IsLittleEndian);
    FView.setInt32(WASM_SHMSG_SEND_DATA_ADDRESS,aData,Env.IsLittleEndian);
    // Result:=AwaitResult;
  finally
    UnlockMem;
  end;
end;

{ TLoaderWorkerWebSocketAPI }

procedure TLoaderWorkerWebSocketAPI.SendSharedMemToWorker;


begin
  SendSharedMemToWorker(FWebsocketWorker);
end;

procedure TLoaderWorkerWebSocketAPI.SendSharedMemToWorker(aWorker: TJSWorker);
var
  Obj : TWebsocketSetMemCommand;
begin
  Obj:=TWebsocketSetMemCommand.CreateNew(FSharedMem,-1);
  aWorker.postMessage(Obj);
end;

procedure TLoaderWorkerWebSocketAPI.SetSharedMem(AValue: TJSSharedArrayBuffer);
begin
  inherited SetSharedMem(AValue);
  if Assigned(FSharedMem) and FWorkerOK then
    SendSharedMemToWorker;
end;

procedure TLoaderWorkerWebSocketAPI.HandleWebsoketHandlerOK(aCommand : TWebsocketHandlerOKCommand);

begin
  FWorkerOK:=True;
  if Assigned(FSharedMem) then
    SendSharedMemToWorker;
end;

procedure TLoaderWorkerWebSocketAPI.StartWebsocketHandler(const aScriptName: string);
var
  lScript : string;
begin
  lScript:=aScriptName;
  if lScript='' then
    lScript:='websocket_worker.js';
  FWebsocketWorker:=TJSWorker.new(lScript);
  TCommandDispatcher.Instance.RegisterWorker(FWebsocketWorker,'websockethandler');
  TCommandDispatcher.Instance.specialize AddCommandHandler<TWebsocketHandlerOKCommand>(TWebsocketHandlerOKCommand.CommandName, @HandleWebsoketHandlerOK);

end;

{ TRunnerWorkerWebSocketAPI }

procedure TRunnerWorkerWebSocketAPI.HandleWebSocketMemMessage(aCommand :TWebsocketSetMemCommand);
begin
  Writeln('Worker, accepting websocket shared memory');
  SharedMem:=aCommand.Buffer;
end;

procedure TRunnerWorkerWebSocketAPI.ListenForSharedMemory;
begin
  CommandDispatcher.specialize AddCommandHandler<TWebsocketSetMemCommand>(TWebsocketSetMemCommand.CommandName,@HandleWebSocketMemMessage);
end;

constructor TRunnerWorkerWebSocketAPI.Create(aEnv: TPas2JSWASIEnvironment);
begin
  inherited Create(aEnv);
  ListenForSharedMemory;
end;


end.

