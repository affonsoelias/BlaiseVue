{
  Thread runner support
}
unit rtl.threadrunner;

{$mode ObjFPC}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Classes, System.SysUtils, JSApi.JS,
  BrowserApi.WebAssembly, Wasi.Env, System.WebThreads,
  Rtl.ThreadController, Rtl.WorkerCommands, WasiWorkerApp;
{$ELSE}
  Classes, SysUtils, JS, webassembly, wasienv,
  Rtl.WebThreads, Rtl.ThreadController, Rtl.WorkerCommands, WasiWorkerApp;
{$ENDIF}

Type
  // This object has the thread support that is needed by the worker that runs a thread.
  { TWorkerThreadSupport }
  TRunThreadCallback = procedure (OnRun : TRunWebassemblyProc) of object;

  { TWorkerThreadRunner }

  TWorkerThreadRunner = class(TWasmThreadController)
  Private
    Type
      TWorkerState = (wsNeutral, wsLoading, wsLoaded, wsRunWaiting, wsRunning);
  Private
    FOnRunThread: TRunThreadCallback;
    FState: TWorkerState;
    FCurrentThreadInfo : TThreadinfo;
    FThreadEntryPoint: String;
    FLastSenderID : string;
    procedure RawRunWasmModule(aCommand : TCustomWorkerCommand);
    procedure RawCancelWasmModule(aCommand: TCustomWorkerCommand);
  Protected
    procedure RegisterCommands;
    procedure HaveWebassembly; override;
    // Incoming messages
    procedure CallRunWebAssemblyThread; virtual;
    procedure DoRunThread(aExports: TWASIExports); virtual;
    procedure RunWasmModule(aCommand: TWorkerRunCommand); virtual;
    procedure CancelWasmModule(aCommand: TWorkerCancelCommand); virtual;
    procedure SendLoaded; virtual;
    Procedure SendConsoleMessage(aMessage : String); overload;
    Procedure SendConsoleMessage(aFmt : String; const aArgs : array of const); overload;
    Procedure SendConsoleMessage(const aArgs : array of JSValue); overload;
    procedure SendException(aError: Exception); overload;
    procedure SendException(aError: TJSError); overload;
    procedure Reset;
    procedure Loading;
  Public
    constructor create; override;
    function spawnthread(start_arg : longint) : longint; override;
    // Thread entry point name for the WASI Host.
    Property ThreadEntryPoint : String Read FThreadEntryPoint Write FThreadEntryPoint;
    // Current thread info.
    Property CurrentThreadInfo : TThreadInfo Read FCurrentThreadInfo;
    Property OnRunThread : TRunThreadCallback Read FOnRunThread Write FOnRunThread;
  end;


  { TWorkerThreadRunnerApplication }

  TWorkerThreadRunnerApplication = class(TWorkerWASIHostApplication)
  private
    procedure RawLoadWasmModule(aCommand: TCustomWorkerCommand);
  protected
    function GetThreadSupport: TWorkerThreadRunner; virtual;
    procedure LoadWasmModule(aCommand: TWorkerLoadCommand); virtual;
  Public
    constructor Create(aOwner : TComponent); override;
    Property ThreadSupport : TWorkerThreadRunner Read GetThreadSupport;
  end;

  { TWASIThreadRunnerHost }

  TWASIThreadRunnerHost = class(TWASIHost)
  Protected
    function  GetThreadSupport : TWorkerThreadRunner; virtual;
    Procedure RunWebAssemblyThread(aProc : TRunWebassemblyProc); virtual;
    procedure DoStdWrite(Sender: TObject; const aOutput: String); override;
    procedure DoAfterInstantiate; override;
    function CreateWasiEnvironment: TPas2JSWASIEnvironment; override;
  Public
    // our thread support
    Property ThreadSupport : TWorkerThreadRunner Read GetThreadSupport;
  end;

Function GlobalWorkerThreadRunner : TWorkerThreadRunner;

implementation

Function GlobalWorkerThreadRunner : TWorkerThreadRunner;

begin
  Result:=TWasmThreadController.Instance as TWorkerThreadRunner
end;

{ TWorkerThreadRunnerApplication }

(*
function TWorkerThreadRunnerApplication.CreateHost: TWASIHost;

var
  TH : TWasiThreadHost;

begin
  TH:=TWASIThreadHost.Create(Self);
  TH.OnConsoleWrite:=@HandleConsoleWrite;
  FThreadSupport:=CreateWorkerThreadSupport(TH.WasiEnvironment);
  FThreadSupport.OnSendCommand:=@DoOnSendCommand;
  TH.ThreadSupport:=FThreadSupport; // Sets FThreadSupport.host
  Result:=TH;
end;
*)

procedure TWorkerThreadRunnerApplication.RawLoadWasmModule(aCommand: TCustomWorkerCommand);

var
  lCmd: TWorkerLoadCommand absolute aCommand;

begin
  LoadWasmModule(lCmd);
end;

procedure TWorkerThreadRunnerApplication.LoadWasmModule(aCommand: TWorkerLoadCommand);


Var
  WASD : TWebAssemblyStartDescriptor;
  aTable : TJSWebAssemblyTable;

  function doOK(aValue: JSValue): JSValue;
  // We are using the overload that takes a compiled module.
  // In that case the promise resolves to a WebAssembly.Instance, not to a InstantiateResult !
  Var
    aInstance : TJSWebAssemblyInstance absolute aValue;

  begin
    Result:=True;
    WASD.Instance:=aInstance;
    WASD.Exported:=TWASIExports(TJSObject(aInstance.exports_));
    WASD.CallRun:=Nil;
    Host.PrepareWebAssemblyInstance(WASD);
  end;

  function DoFail(aValue: JSValue): JSValue;

  var
    E: Exception;

  begin
    ThreadSupport.Reset;
    Result:=True;
    E:=Exception.Create('Failed to create webassembly. Reason: '+TJSJSON.Stringify(aValue));
    ThreadSupport.SendException(E);
    E.Free;
  end;


begin
  ThreadSupport.Loading;
  try
    aTable:=TJSWebAssemblyTable.New(Host.TableDescriptor);
    WASD:=Host.InitStartDescriptor(aCommand.Memory,aTable,Nil);
    WASD.Module:=aCommand.Module;
    TJSWebAssembly.Instantiate(aCommand.Module,WASD.Imports)._then(@DoOK,@DoFail).Catch(@DoFail);
  except
    on E : Exception do
      ThreadSupport.SendException(E);
    on JE : TJSError do
      ThreadSupport.SendException(JE);
  end;
end;

function TWorkerThreadRunnerApplication.GetThreadSupport: TWorkerThreadRunner;
begin
  Result:=GlobalWorkerThreadRunner;
end;

//procedure TWorkerThreadRunnerApplication.LoadWasmModule(aCommand: TWorkerLoadCommand);

constructor TWorkerThreadRunnerApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  TCommandDispatcher.Instance.RegisterCommandHandler(cmdLoad,@RawLoadWasmModule);
  TCommandDispatcher.Instance.SendCommand(TWorkerReadyCommand.Create());
end;

{ TWASIThreadRunnerHost }

function TWASIThreadRunnerHost.GetThreadSupport: TWorkerThreadRunner;
begin
  Result:=GlobalWorkerThreadRunner;
end;

procedure TWASIThreadRunnerHost.RunWebAssemblyThread(aProc: TRunWebassemblyProc);
begin
  RunWebAssemblyInstance(Nil,Nil,aProc);
end;

procedure TWASIThreadRunnerHost.DoStdWrite(Sender: TObject; const aOutput: String);
begin
  ThreadSupport.SendConsoleMessage(aOutput);
end;

procedure TWASIThreadRunnerHost.DoAfterInstantiate;
begin
  Inherited;
  ThreadSupport.OnRunThread:=@RunWebAssemblyThread;
  ThreadSupport.SetWasmModuleAndMemory(PreparedStartDescriptor.Module,PreparedStartDescriptor.Memory);
  ThreadSupport.SendLoaded;
end;

function TWASIThreadRunnerHost.CreateWasiEnvironment: TPas2JSWASIEnvironment;
begin
  Result:=inherited CreateWasiEnvironment;
  TWasmThreadSupportApi.Create(Result);
end;

{ TWorkerThreadRunner }

procedure TWorkerThreadRunner.HaveWebassembly;
begin
  if FState=wsRunWaiting then
    CallRunWebassemblyThread
  else
    FState:=wsLoaded;
end;

procedure TWorkerThreadRunner.CallRunWebAssemblyThread;

begin
  If Assigned(FOnRunThread) then
    FOnRunThread(@DoRunThread);
  TCommandDispatcher.Instance.DefaultSenderID:=FLastSenderID;
end;

function TWorkerThreadRunner.spawnthread(start_arg: longint): longint;

Var
  P : TWorkerSpawnThreadCommand;

begin
  P:=TWorkerSpawnThreadCommand.Create(start_arg,start_arg);
  TCommandDispatcher.Instance.SendCommand(P);
  Result:=start_arg;
end;

constructor TWorkerThreadRunner.create;
begin
  inherited create;
  FThreadEntryPoint:=DefaultThreadEntryPoint;
  RegisterCommands;
end;

procedure TWorkerThreadRunner.SendLoaded;

Var
  L : TWorkerLoadedCommand;

begin
  L:=TWorkerLoadedCommand.Create();
  TCommandDispatcher.Instance.SendCommand(L);
end;

procedure TWorkerThreadRunner.SendConsoleMessage(aMessage: String);

Var
  L : TConsoleOutputCommand;

begin
  L:=TConsoleOutputCommand.Create(aMessage);
  TCommandDispatcher.Instance.SendConsoleCommand(L);
end;

procedure TWorkerThreadRunner.SendConsoleMessage(aFmt: String;
  const aArgs: array of const);
begin
  SendConsoleMessage(Format(aFmt,aArgs));
end;

procedure TWorkerThreadRunner.SendConsoleMessage(const aArgs: array of JSValue);

Var
  L : TWorkerConsoleCommand;

begin
  L:=TWorkerConsoleCommand.Create(aArgs,FCurrentThreadInfo.ThreadId);
  TCommandDispatcher.Instance.SendCommand(L);
end;

procedure TWorkerThreadRunner.CancelWasmModule(aCommand : TWorkerCancelCommand);

begin
  if (aCommand<>Nil) then ;
  // todo
end;


procedure TWorkerThreadRunner.SendException(aError : Exception);

Var
  E : TWorkerExceptionCommand;

begin
  E:=TWorkerExceptionCommand.Create(aError.ClassName,aError.Message,FCurrentThreadInfo.ThreadId);
  TCommandDispatcher.Instance.SendCommand(E);
end;

procedure TWorkerThreadRunner.SendException(aError: TJSError);

Var
  aMessage,aClass : String;
  E : TWorkerExceptionCommand;

begin
  aClass:='Error';
  aMessage:=aError.Message;
  E:=TWorkerExceptionCommand.Create(aClass,aMessage,FCurrentThreadInfo.ThreadId);
  TCommandDispatcher.Instance.SendCommand(E);
end;

procedure TWorkerThreadRunner.Reset;
begin
  FState:=wsNeutral;
end;

procedure TWorkerThreadRunner.Loading;
begin
  Fstate:=wsLoading;
end;

procedure TWorkerThreadRunner.DoRunThread(aExports: TWASIExports);

Var
  aResult : Integer;

begin
  try
    FState:=wsRunning;
    // Writeln('About to run webassembly entry point (',Host.ThreadEntryPoint,') for thread ID ',aCommand.ThreadID);
    aResult:=TThreadEntryPointFunction(aExports[ThreadEntryPoint])(FCurrentThreadInfo.ThreadID,FCurrentThreadInfo.Arguments);
    FState:=wsLoaded;
    if aResult>0 then
      SendConsoleMessage('Thread run function result= %d ',[aResult]);
    TCommandDispatcher.Instance.SendCommand(TWorkerCleanupCommand.Create(Self.FCurrentThreadInfo.ThreadID,aResult));
  except
    on E : Exception do
      SendException(E);
    on JE : TJSError do
      SendException(JE);
    on JE : TJSError do
      SendException(JE)
  end;
end;

procedure TWorkerThreadRunner.RunWasmModule(aCommand : TWorkerRunCommand);

begin
  if (FState=wsNeutral) then
    begin
    {$IFNDEF NOLOGAPICALLS}
    DoLog('No webassembly loaded');
    {$ENDIF}
    exit; // Todo: send error back
    end;
  if (FState in [wsRunning,wsRunWaiting]) then
    begin
    {$IFNDEF NOLOGAPICALLS}
    DoLog('Webassembly already running');
    {$ENDIF}
    exit; // Todo: send error back
    end;
  // Writeln('Entering TWorkerThreadRunner.RunWasmModule '+TJSJSON.Stringify(aCommand));
  // initialize current thread info
  FCurrentThreadInfo.ThreadID:=aCommand.ThreadID;
  FCurrentThreadInfo.Arguments:=aCommand.Args;
  FLastSenderID:=TCommandDispatcher.Instance.DefaultSenderID;
  TCommandDispatcher.Instance.DefaultSenderID:='Wasm thread '+IntToStr(FCurrentThreadInfo.ThreadID);
  if FState=wsLoaded then
    CallRunWebAssemblyThread
  else
    FState:=wsRunWaiting;
end;

procedure TWorkerThreadRunner.RawRunWasmModule(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerRunCommand absolute aCommand;
begin
  RunWasmModule(lCmd);
end;

procedure TWorkerThreadRunner.RawCancelWasmModule(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerCancelCommand absolute aCommand;
begin
  CancelWasmModule(lCmd);
end;

procedure TWorkerThreadRunner.RegisterCommands;

begin
  TCommandDispatcher.Instance.RegisterCommandHandler(cmdRun,@RawRunWasmModule);
  TCommandDispatcher.Instance.RegisterCommandHandler(cmdCancel,@RawCancelWasmModule);
end;

initialization
  TWorkerWASIHostApplication.SetWasiHostClass(TWASIThreadRunnerHost);
  TWasmThreadController.SetInstanceClass(TWorkerThreadRunner);
end.

