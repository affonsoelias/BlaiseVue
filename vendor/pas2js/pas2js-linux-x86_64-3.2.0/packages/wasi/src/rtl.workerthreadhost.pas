unit rtl.workerthreadhost;

{$mode ObjFPC}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Types, System.Classes, System.SysUtils, JSApi.JS, Fcl.CustApp, BrowserApi.WebOrWorker,
  BrowserApi.Worker, BrowserApi.WebAssembly, Wasi.Env, System.WebThreads,
  Rtl.ThreadController;
{$ELSE}
  Types, Classes, SysUtils, JS, custapp,  webworker, webassembly, wasienv,
  Rtl.WebThreads, Rtl.ThreadController, Rtl.WorkerCommands, WasiWorkerApp;
{$ENDIF}

const
  ThreadRunnerScript = 'wasm_worker_runner.js';
  ThreadCount = 4;

Type
  // Need to unify this host class with the WasiThreadedApp one...
  
  { TWASIThreadControllerHost }

  TWASIThreadControllerHost = class(TWASIHost)
  Protected
    class function NeedSharedMemory: Boolean; override;
    function GetThreadSupport: TThreadController; virtual;
    Procedure DoAfterInstantiate; override;
    Function CreateWasiEnvironment : TPas2JSWASIEnvironment; override;
  Public
    Property ThreadSupport : TThreadController Read GetThreadSupport;
  end;

  { TWorkerThreadControllerApplication }

  TWorkerThreadControllerApplication = class(TWorkerWASIHostApplication)
  Private
    FThreadSupport: TWasmThreadSupportApi;
    procedure HandleRawExecuteCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawRpcCommand(aCommand: TCustomWorkerCommand);
  Protected
    procedure DoHostCreated; override;
    procedure RegisterMessageHandlers; override;
    procedure HandleExecuteCommand(aCmd: TWorkerExecuteCommand); virtual;
    procedure HandleRpcCommand(aCmd: TWorkerRpcCommand); virtual;
  Public
    constructor create(aOwner : TComponent); override;
    destructor destroy; override;
  end;


implementation

{ TWASIThreadControllerHost }

class function TWASIThreadControllerHost.NeedSharedMemory: Boolean;
begin
  Result:=True;
end;

function TWASIThreadControllerHost.GetThreadSupport: TThreadController;
begin
  Result:=TThreadController.Instance as TThreadController;
end;

procedure TWASIThreadControllerHost.DoAfterInstantiate;
begin
  inherited DoAfterInstantiate;
  If Assigned(ThreadSupport) then
    // Will send load commands
    ThreadSupport.SetWasmModuleAndMemory(PreparedStartDescriptor.Module,PreparedStartDescriptor.Memory);
end;

function TWASIThreadControllerHost.CreateWasiEnvironment: TPas2JSWASIEnvironment;
begin
  Result:=inherited CreateWasiEnvironment;
end;

{ TWorkerThreadControllerApplication }

procedure TWorkerThreadControllerApplication.HandleRawExecuteCommand(aCommand : TCustomWorkerCommand);
var
  lCmd : TWorkerExecuteCommand absolute aCommand;
begin
  HandleExecuteCommand(lCmd);
end;

procedure TWorkerThreadControllerApplication.HandleExecuteCommand(aCmd : TWorkerExecuteCommand);
{ Load & Execute a given webassembly }
var
  lName : string;
  lVal : JSValue;
  lStringVal : String absolute lVal;

begin
  // Transfer environment, if there is any.
  if isObject(aCmd.Env) then
    begin
    WasiEnvironment.Environment.Clear;
    For lName in TJSObject.getOwnPropertyNames(aCmd.Env) do
       begin
       lVal:=aCmd.Env[lName];
       if isString(lVal) then
         WasiEnvironment.Environment.Values[lName]:=lStringVal;
       end;
    end;
  if isString(aCmd.executeFunc) then
    Host.RunEntryFunction:=aCmd.executeFunc;
  StartWebAssembly(aCmd.Url,True,Nil,Nil)
end;

procedure TWorkerThreadControllerApplication.HandleRawRpcCommand(aCommand : TCustomWorkerCommand);
var
  lCmd : TWorkerRpcCommand absolute aCommand;
begin
  HandleRpcCommand(lCmd);
end;

procedure TWorkerThreadControllerApplication.HandleRpcCommand(aCmd: TWorkerRpcCommand);

var
  res : TWorkerRpcResultCommand;
  data : JSValue;
  errClass : String;
  errMessage : String;

begin
  if aCmd.Id='' then
    Res:=TWorkerRpcResultCommand.CreateError(aCmd.id,-32600,'Invalid request: No json-rpc ID')
  else if aCmd.jsonrpc<>'2.0' then
    Res:=TWorkerRpcResultCommand.CreateError(aCmd.id,-32600,'Invalid request: no jsonrpc version')
  else if Not Assigned(Host.Exported.functions[aCmd.method]) then
    Res:=TWorkerRpcResultCommand.CreateError(aCmd.id,-32601,'Method "'+aCmd.method+'" not found')
  else
    begin
    try
      if isArray(aCmd.Params) then
        data:=Host.Exported.functions[aCmd.method].Apply(nil,TJSValueDynArray(aCmd.Params))
      else
        data:=Host.Exported.functions[aCmd.method].call(nil);
      Res:=TWorkerRpcResultCommand.Create(aCmd.id,Data);
    except
      on JE : TJSError do
        begin
        errClass:=JSClassName(JE);
        errMessage:=JE.message;
        end;
      on E : Exception do
        begin
        errClass:=E.ClassName;
        errMessage:=E.Message;
        end;
    end;
    if not assigned(Res) then
      Res:=TWorkerRpcResultCommand.CreateError(aCmd.id,-32603,'Exception '+ErrClass+' while executing "'+aCmd.method+'" : '+ErrMessage);
    end;
  Self_.postMessage(Res);
end;

constructor TWorkerThreadControllerApplication.create(aOwner: TComponent);
var
  lWorker : string;
begin
  inherited create(aOwner);
  FThreadSupport:=TWasmThreadSupportApi.Create(WasiEnvironment);
  lWorker:=GetEnvironmentVar('worker');
  if lWorker='' then
    lWorker:='worker';
  TCommandDispatcher.Instance.DefaultSenderID:=lWorker;
  globalThreadController.AllocateInitialworkers;
end;

destructor TWorkerThreadControllerApplication.destroy;
begin
  FreeAndNil(FThreadSupport);
  inherited destroy;
end;

procedure TWorkerThreadControllerApplication.RegisterMessageHandlers;

begin
  Inherited;
  TCommandDispatcher.Instance.RegisterCommandHandler(cmdExecute,@HandleRawExecuteCommand);
  TCommandDispatcher.Instance.RegisterCommandHandler(cmdRpc,@HandleRawRPCCommand);
end;

procedure TWorkerThreadControllerApplication.DoHostCreated;
var
  Mem : TJSWebAssemblyMemoryDescriptor;
begin
  Inherited;
//  Host.OnConsoleWrite:=@HandleConsoleWrite;
  Mem.Initial:=256;
  Mem.maximum:=512;
  Mem.shared:=True;
  Host.MemoryDescriptor:=Mem;
end;

initialization
  TWasmThreadController.SetInstanceClass(TThreadController);
  TWorkerWASIHostApplication.SetWasiHostClass(TWASIThreadControllerHost);
end.

