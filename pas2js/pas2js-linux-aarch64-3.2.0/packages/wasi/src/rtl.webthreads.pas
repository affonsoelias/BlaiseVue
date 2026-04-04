{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2017-2020 by the Pas2JS development team.

    Threads API for Browser Window & Worker
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$IFNDEF FPC_DOTTEDUNITS}
unit Rtl.WebThreads;
{$ENDIF}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  JSApi.JS, System.SysUtils, Wasi.Env, BrowserApi.WebAssembly, Rtl.WorkerCommands;
{$ELSE}
  JS, SysUtils, wasienv, webassembly, Rtl.WorkerCommands;
{$ENDIF}  

Const
  // Each thread starts spawning at 1000*IndexOfWorker
  ThreadIDInterval = 1000;
  // When the thread ID reaches this limit, then it requests a new block
  ThreadIDMargin = 2;

  // lowercase !!
  cmdConsole = 'console';
  cmdException = 'exception';
  cmdCleanup = 'cleanup';
  cmdCancel = 'cancel';
  cmdLoaded = 'loaded';
  cmdKill = 'kill';
  cmdSpawn = 'spawn';
  cmdStarted = 'started';
  cmdLoad = 'load';
  cmdRun = 'run';
  cmdExecute = 'execute';
  cmdRPC = 'rpc';
  cmdRPCResult = 'rpcresult';
  cmdReady = 'ready';

  DefaultThreadWorker = 'pas2jsthreadworker.js';
  DefaultThreadCount = 2;
  DefaultMaxWorkerCount = 100;

  // Default exported thread entry point. Must have signature TThreadEntryPointFunction
  DefaultThreadEntryPoint = 'wasi_thread_start';

  // Imports to wasi env.
  sThreadSpawn = 'thread-spawn';
  sThreadDetach = 'thread_detach';
  sThreadCancel = 'thread_cancel';
  sThreadSelf = 'thread_self';



Type
  // aRunProc and aArgs are pointers inside wasm.
  TThreadEntryPointFunction = Function(ThreadId: Integer; aArgs: Integer) : Integer;

  EWasmThreads = class(Exception);

  // Commands sent between thread workers and main program.

  { Basic TWorkerCommand. Command is the actual command }

  { we do not use Pascal classes for this, to avoid transferring unnecessary metadata present in the pascal class }

  TThreadWorkerCommand = Class external name 'Object' (TCustomWorkerCommand)
    ThreadID : Integer; // Meaning depends on actual command.
    TargetID : Integer; // Forward to thread ID
  end;
  TCommandNotifyEvent = Procedure (Sender : TObject; aCommand : TThreadWorkerCommand) of object;

  { TWorkerCommandHelper }

  TWorkerCommandHelper = class helper (TCustomWorkerCommandHelper) for TThreadWorkerCommand
    Class function NewWorker(const aCommand : string; aThreadID : Integer = -1) : TThreadWorkerCommand; static;
  end;

  { TWorkerExceptionCommand }


  { TWorkerConsoleCommand }

  // Sent by worker to main: write message to console
  // Thread ID : sending console ID
  TWorkerConsoleCommand = class external name 'Object' (TConsoleOutputCommand);

  { TWorkerConsoleCommandHelper }

  TWorkerConsoleCommandHelper = class helper(TCustomWorkerCommandHelper) for TWorkerConsoleCommand
    Class function CommandName : string; static;
    Class function Create(const aMessage : string; aThreadID : Integer = -1) : TWorkerConsoleCommand; static; reintroduce;
    Class function Create(const aMessage : array of JSValue; aThreadID : Integer = -1) : TWorkerConsoleCommand; static; reintroduce;
  end;

  // Cleanup thread info: put this worker into unusued workers
  TWorkerCleanupCommand = class external name 'Object' (TThreadWorkerCommand)
    exitstatus : integer;
  end;

  { TWorkerCleanupCommandHelper }

  TWorkerCleanupCommandHelper = class helper (TWorkerCommandHelper) for TWorkerCleanupCommand
    Class function CommandName : string; static;
    class function Create(aThreadID, aExitStatus: Integer): TWorkerCleanupCommand; static; reintroduce;
  end;


  { TWorkerKillCommand }
  // Kill thread (thread ID in ThreadID)
  TWorkerKillCommand = class external name 'Object' (TThreadWorkerCommand)
  end;

  { TWorkerCleanupCommandHelper }

  TWorkerKillCommandHelper = class helper (TWorkerCommandHelper) for TWorkerKillCommand
    Class function CommandName : string; static;
    Class function Create(aThreadID : Integer): TWorkerKillCommand; static;reintroduce;
  end;

  TWorkerReadyCommand = class external name 'Object' (TThreadWorkerCommand);

  { TWorkerReadyCommandHelper }

  TWorkerReadyCommandHelper = class helper (TWorkerCommandHelper) for TWorkerReadyCommand
    Class function CommandName : string; static;
    Class function Create(): TWorkerReadyCommand; static; reintroduce;
  end;

  // Cancel thread (thread ID in ThreadID)
  TWorkerCancelCommand = class external name 'Object' (TThreadWorkerCommand)
  end;

  { TWorkerCancelCommandHelper }

  TWorkerCancelCommandHelper = class helper (TWorkerCommandHelper) for TWorkerCancelCommand
    Class function CommandName : string; static;
    Class function Create(aThreadID : Integer): TWorkerCancelCommand; static; reintroduce;
  end;

  // sent to notify main thread that the wasm module is loaded.
  TWorkerLoadedCommand = class external name 'Object' (TThreadWorkerCommand)
  end;

  { TWorkerLoadedCommandHelper }

  TWorkerLoadedCommandHelper = class helper(TWorkerCommandHelper)  for TWorkerLoadedCommand
    Class function CommandName : string; static;
    Class function Create: TWorkerLoadedCommand; static; reintroduce;
  end;



  // Sent to notify main thread that a new thread must be started.
  // Worker cannot start new thread. It allocates the ID (threadId)
  // It sends RunFunction, Attributes and Arguments received by thread_spawn call.
  TWorkerSpawnThreadCommand = class external name 'Object' (TThreadWorkerCommand)
    Arguments : Integer;
  end;

  { TWorkerSpawnThreadCommandHelper }

  TWorkerSpawnThreadCommandHelper = class helper(TWorkerCommandHelper)  for TWorkerSpawnThreadCommand
    Class function CommandName : string; static;
    class function Create(aThreadID: integer; aArgs: Integer): TWorkerSpawnThreadCommand; static; reintroduce;
  end;

  // Sent by main to worker: load wasm module
  TWorkerLoadCommand = class external name 'Object' (TThreadWorkerCommand)
  public
    Memory : TJSWebAssemblyMemory;
    Module : TJSWebAssemblyModule;
  end;

  TWorkerLoadCommandHelper = class helper (TWorkerCommandHelper)  for TWorkerLoadCommand
    Class function CommandName : string; static;
    Class function Create(aModule : TJSWebAssemblyModule; aMemory : TJSWebAssemblyMemory): TWorkerLoadCommand; static;reintroduce;
  end;

  TWorkerStartedCommand = class external name 'Object' (TThreadWorkerCommand)
    StartFunction : string;
  end;

  TWorkerStartedCommandHelper = class helper (TWorkerCommandHelper)  for TWorkerStartedCommand
    Class function CommandName : string; static;
    Class function Create(aFunction : string): TWorkerStartedCommand; static;reintroduce;
  end;

  // Sent by main to worker: run thread procedure
  TWorkerRunCommand = class external name 'Object' (TThreadWorkerCommand)
  public
    ThreadInfo : Integer;
    Attrs : Integer;
    Args : Integer;
  end;

  // Sent by main to thread controller worker: load webassembly at given URL and execute function
  TWorkerExecuteCommand = class external name 'Object' (TThreadWorkerCommand)
  public
    Url : String;
    ExecuteFunc : string;
    Env : TJSObject;
  end;

  // Sent by main to thread controller worker: run function, return result
  TWorkerRpcCommand = class external name 'Object' (TThreadWorkerCommand)
  public
    method : string;
    id : string;
    params : TJSArray;
    jsonrpc : string;
  end;

  TWorkerRPCError = class external name 'Object' (TJSObject)
    code : integer;
    message : string;
    data : JSValue;
  end;

  TWorkerRpcResultCommand = class external name 'Object' (TThreadWorkerCommand)
  public
    method : string;
    result : jsValue;
    id : string;
    error : TWorkerRPCError;
    jsonrpc : string;
  end;


  { TWorkerRunCommandHelper }

  // Sent by main to thread controller worker: load and start a webassembly
  TWorkerRunCommandHelper = class helper (TWorkerCommandHelper)  for TWorkerRunCommand
    Class function CommandName : string; static;
    Class function Create(aThreadID, aArgs : Longint): TWorkerRunCommand; static; reintroduce;
  end;

  { TWorkerRpcCommandHelper }

  TWorkerRpcCommandHelper = class helper (TWorkerCommandHelper)  for TWorkerRpcCommand
    Class function CommandName : string; static;
    Class function Create(aID : String; aMethod : String; aParams : TJSArray): TWorkerRpcCommand; static; reintroduce;
  end;

  { TWorkerRpcResultCommandHelper }

  TWorkerRpcResultCommandHelper = class helper (TWorkerCommandHelper)  for TWorkerRpcResultCommand
    Class function CommandName : string; static;
    Class function Create(aID : String; aResult : JSValue): TWorkerRpcResultCommand; static; reintroduce;
    Class function CreateError(aID : String; aCode : Integer; aMessage : string): TWorkerRpcResultCommand; static; reintroduce;
    Class function CreateError(aID : String; aCode : Integer; aMessage : string; aData : JSValue): TWorkerRpcResultCommand; static; reintroduce;
  end;


  // Sent by main to thread controller worker: load and start a webassembly

  { TWorkerExecuteCommandHelper }

  TWorkerExecuteCommandHelper = class helper (TWorkerCommandHelper)  for TWorkerExecuteCommand
    Class function CommandName : string; static;
    Class function Create(aURl,aFunc : string; aEnv : TJSObject = nil): TWorkerExecuteCommand; static; reintroduce;
  end;



  TThreadinfo = record
    OriginThreadID : longint; // Numerical thread ID
    ThreadID : longint; // Numerical thread ID
    Arguments : longint;  // Arguments (pointer)
  end;

  // This basis object has the thread support that is needed by the WASM module.
  // It relies on descendents to implement the actual calls.

  { TWasmThreadSupport }

  TWasmPointer = Longint;

  TWasmThreadController = Class;
  TWasmThreadControllerClass = class of TWasmThreadController;
  TWasmThreadControllerLogEvent = reference to procedure (const msg : string);

  { TWasmThreadController }

  TWasmThreadController = class(TObject)
  private
    class var _instanceClass: TWasmThreadControllerClass;
    class var _instance: TWasmThreadController;
  private
    FLogAPI: Boolean;
    FModule : TJSWebAssemblyModule;
    FMemory : TJSWebAssemblyMemory;
    FOnLog: TWasmThreadControllerLogEvent;
    class function GetInstance: TWasmThreadController; static;
    procedure SetLogAPI(AValue: Boolean);
  protected
    Procedure DoLog(const msg : string);
    Procedure DoLog(const Fmt : string; const args : array of const);
    procedure HaveWebassembly; virtual;abstract;
    property LogAPI : Boolean read FLogAPI write SetLogAPI;
  Public
    constructor create; virtual;
    function SpawnThread(start_arg : longint) : longint; virtual; abstract;
    function ThreadSelf : longint; virtual;
    Procedure SetWasmModuleAndMemory(aModule : TJSWebAssemblyModule; aMemory : TJSWebAssemblyMemory);
    class procedure SetInstanceClass(aClass : TWasmThreadControllerClass);
    class property Instance : TWasmThreadController read GetInstance;
    Property WasmModule : TJSWebAssemblyModule read FModule;
    Property WasmMemory : TJSWebAssemblyMemory read FMemory;
    Property OnLog : TWasmThreadControllerLogEvent Read FOnLog Write FOnLog;
  end;

  TWasmThreadSupportApi = Class (TImportExtension)
  Protected
    // Proposed WASI standard, modeled after POSIX pthreads.
    function thread_spawn(start_arg : longint) : longint;
    Function thread_self() : Integer; virtual;
    Function thread_main() : Integer; virtual;
    function ThreadController : TWasmThreadController; virtual;
  Public
    Function ImportName : String; override;
    procedure FillImportObject(aObject: TJSObject); override;
  end;

  { TThreadConsoleOutput }

  TThreadConsoleOutputEvent = reference to procedure(const Msg : string);
  TThreadConsoleOutput = Class (TObject)
  private
    class var _Instance : TThreadConsoleOutput;
  private
    FEnabled: boolean;
    FOnOutput: TThreadConsoleOutputEvent;
    procedure HandleConsoleMessage(aCommand: TCustomWorkerCommand); virtual;
  Public
    class constructor done;
    class procedure init;
    constructor Create; virtual;
    class property Instance : TThreadConsoleOutput Read _Instance;
    property Enabled : boolean Read FEnabled Write FEnabled;
    property OnOutput : TThreadConsoleOutputEvent Read FOnOutput Write FOnOutput;
  end;


function ThreadController : TWasmThreadController;

implementation

function ThreadController : TWasmThreadController;

begin
  Result:=TWasmThreadController.Instance;
end;

{ TWorkerRunCommandHelper }

class function TWorkerRunCommandHelper.CommandName: string;
begin
  Result:=cmdRun;
end;

class function TWorkerRunCommandHelper.Create(aThreadID, aArgs: integer): TWorkerRunCommand;
begin
  Result:=TWorkerRunCommand(NewWorker(CommandName));
  Result.ThreadID:=aThreadID;
  Result.Args:=aArgs;
end;

{ TWorkerRpcCommandHelper }

class function TWorkerRpcCommandHelper.CommandName: string;
begin
  Result:=cmdRpc;
end;

class function TWorkerRpcCommandHelper.Create(aID: String; aMethod: String; aParams: TJSArray): TWorkerRpcCommand;
begin
  Result:=TWorkerRpcCommand(NewWorker(CommandName));
  Result.id:=aID;
  Result.Method:=aMethod;
  Result.Params:=aParams;
end;

{ TWorkerRpcResultCommandHelper }

class function TWorkerRpcResultCommandHelper.CommandName: string;
begin
  result:=cmdRPCResult;
end;

class function TWorkerRpcResultCommandHelper.Create(aID: String; aResult: JSValue): TWorkerRpcResultCommand;
begin
  Result:=TWorkerRpcResultCommand(NewWorker(CommandName));
  Result.id:=aID;
  Result.result:=aResult;
  Result.jsonrpc:='2.0';
end;

class function TWorkerRpcResultCommandHelper.CreateError(aID: String; aCode: Integer; aMessage: string): TWorkerRpcResultCommand;
begin
  Result:=TWorkerRpcResultCommand(NewWorker(CommandName));
  Result.Id:=aID;
  Result.Error:=TWorkerRPCError.New;
  Result.Error.Code:=aCode;
  Result.Error.Message:=aMessage;
  Result.jsonrpc:='2.0';
end;

class function TWorkerRpcResultCommandHelper.CreateError(aID: String; aCode: Integer; aMessage: string; aData: JSValue
  ): TWorkerRpcResultCommand;
begin
  Result:=CreateError(aID,aCode,aMessage);
  Result.Error.Data:=aData;
end;

{ TWorkerExecuteCommandHelper }

class function TWorkerExecuteCommandHelper.CommandName: string;
begin
  result:=cmdExecute
end;

class function TWorkerExecuteCommandHelper.Create(aURl, aFunc: string; aEnv: TJSObject): TWorkerExecuteCommand;
begin
  Result:=TWorkerExecuteCommand(NewWorker(CommandName));
  Result.Url:=aURL;
  if aFunc<>'' then
    Result.ExecuteFunc:=aFunc;
  if assigned(aEnv) then
    Result.Env:=aEnv;
end;

{ TWasmThreadController }

class function TWasmThreadController.GetInstance: TWasmThreadController; static;
begin
  if _instance=Nil then
    begin
    if _instanceClass=Nil then
      Raise EWasmThreads.Create('No instance class, please include Rtl.ThreadController or Rtl.ThreadWorker unit');
    _instance:=_instanceClass.Create;
    end;
  Result:=_Instance;
end;

procedure TWasmThreadController.SetLogAPI(AValue: Boolean);
begin
  if FLogAPI=AValue then Exit;
  FLogAPI:=AValue;
end;

procedure TWasmThreadController.DoLog(const msg: string);
begin
  if FLogAPI then
    if Assigned(FOnLog) then
      FOnLog(Msg)
    else
      Writeln(msg);

end;

procedure TWasmThreadController.DoLog(const Fmt: string; const args: array of const);
begin
  DoLog(Format(Fmt,Args));
end;

constructor TWasmThreadController.create;

begin
  // Do nothing for the moment
end;

function TWasmThreadController.ThreadSelf: longint;
begin
  Result:=-1;
end;

procedure TWasmThreadController.SetWasmModuleAndMemory(aModule: TJSWebAssemblyModule; aMemory: TJSWebAssemblyMemory);
begin
  FModule:=aModule;
  FMemory:=aMemory;
  If Assigned(FModule) and Assigned(FMemory) then
    HaveWebassembly;
end;

class procedure TWasmThreadController.SetInstanceClass(aClass: TWasmThreadControllerClass);
begin
  _instanceClass:=aClass;
end;

{ TWorkerLoadCommandHelper }

class function TWorkerLoadCommandHelper.CommandName: string;
begin
  Result:=cmdLoad;
end;

class function TWorkerLoadCommandHelper.Create(aModule: TJSWebAssemblyModule; aMemory: TJSWebAssemblyMemory
  ): TWorkerLoadCommand;
begin
  Result:=TWorkerLoadCommand(NewWorker(CommandName));
  Result.Memory:=aMemory;
  Result.Module:=aModule;
end;

{ TWorkerStartedCommandHelper }

class function TWorkerStartedCommandHelper.CommandName: string;
begin
  result:=cmdStarted;
end;

class function TWorkerStartedCommandHelper.Create(aFunction: string): TWorkerStartedCommand;
begin
  Result:=TWorkerStartedCommand(NewWorker(CommandName));
  Result.StartFunction:=aFunction;
end;

{ TWorkerSpawnThreadCommandHelper }

class function TWorkerSpawnThreadCommandHelper.CommandName: string;
begin
  Result:=cmdSpawn
end;

class function TWorkerSpawnThreadCommandHelper.Create(aThreadID: integer; aArgs : Integer): TWorkerSpawnThreadCommand;
begin
  Result:=TWorkerSpawnThreadCommand(NewWorker(CommandName,aThreadID));
  Result.Arguments:=aArgs;
end;



{ TWorkerLoadedCommandHelper }

class function TWorkerLoadedCommandHelper.CommandName: string;
begin
  Result:=cmdLoaded;
end;

class function TWorkerLoadedCommandHelper.Create: TWorkerLoadedCommand;
begin
  Result:=TWorkerLoadedCommand(NewWorker(CommandName));
end;

{ TWorkerCancelCommandHelper }

class function TWorkerCancelCommandHelper.CommandName: string;
begin
  result:=cmdCancel;
end;

class function TWorkerCancelCommandHelper.Create(aThreadID: Integer
  ): TWorkerCancelCommand;
begin
  Result:=TWorkerCancelCommand(NewWorker(CommandName,aThreadID));
end;

{ TWorkerKillCommandHelper }

class function TWorkerKillCommandHelper.CommandName: string;
begin
  Result:=cmdKill
end;

class function TWorkerKillCommandHelper.Create(aThreadID : Integer): TWorkerKillCommand;
begin
  Result:=TWorkerKillCommand(NewWorker(CommandName,aThreadID));
end;

{ TWorkerReadyCommandHelper }

class function TWorkerReadyCommandHelper.CommandName: string;
begin
  Result:=cmdReady
end;

class function TWorkerReadyCommandHelper.Create(): TWorkerReadyCommand;
begin
  Result:=TWorkerReadyCommand(NewWorker(CommandName));
end;

{ TWorkerCleanupCommandHelper }

class function TWorkerCleanupCommandHelper.CommandName: string;
begin
  Result:=cmdCleanup
end;

class function TWorkerCleanupCommandHelper.Create(aThreadID, aExitStatus: Integer): TWorkerCleanupCommand;
begin
  Result:=TWorkerCleanupCommand(NewWorker(CommandName,aThreadID));
  Result.ExitStatus:=aExitStatus;
end;

{ TWorkerConsoleCommandHelper }

class function TWorkerConsoleCommandHelper.CommandName: string;
begin
  Result:=cmdConsole;
end;

class function TWorkerConsoleCommandHelper.Create(
  const aMessage: string; aThreadID : Integer = -1): TWorkerConsoleCommand;
begin
  Result:=TWorkerConsoleCommand(createCommand(CommandName,IntToStr(aThreadID)));
  Result.ConsoleMessage:=aMessage;
end;

class function TWorkerConsoleCommandHelper.Create(
  const aMessage: array of JSValue; aThreadID : Integer = -1): TWorkerConsoleCommand;
begin
  Result:=Create(TJSArray(aMessage).join(' '),aThreadID);
end;


{ TWorkerCommandHelper }

class function TWorkerCommandHelper.NewWorker(const aCommand : string; aThreadID : Integer = -1): TThreadWorkerCommand;

begin
  if aThreadID=-1 then
    Result:=TThreadWorkerCommand(createCommand(aCommand))
  else
    begin
    Result:=TThreadWorkerCommand(createCommand(aCommand,'Wasm thread '+IntToStr(aThreadID)));
    Result.ThreadID:=aThreadID;
    end;
end;


{ TWasmThreadSupport }

function TWasmThreadSupportAPi.thread_spawn(start_arg: longint): longint;
begin
  Result:=ThreadController.SpawnThread(start_arg);
end;

function TWasmThreadSupportApi.thread_self(): Integer;

Type
  TGetThreadIDFunction = Function : Longint;
var
  F : TGetThreadIDFunction;
begin
  F:=TGetThreadIDFunction(InstanceExports['GetSelfThread']);
  if Assigned(F) then
    Result:=F()
  else
    Result:=0;
end;

function TWasmThreadSupportApi.thread_main: Integer;

Type
  TGetThreadIDFunction = Function : Longint;
var
  F : TGetThreadIDFunction;
begin
  F:=TGetThreadIDFunction(InstanceExports['GetMainThread']);
  if Assigned(F) then
    Result:=F()
  else
    Result:=0;
end;

function TWasmThreadSupportApi.ThreadController: TWasmThreadController;
begin
  Result:=TWasmThreadController.Instance;
end;

function TWasmThreadSupportApi.ImportName: String;
begin
  Result:='wasi';
end;

procedure TWasmThreadSupportApi.FillImportObject(aObject: TJSObject);
begin
  aObject[sThreadSpawn]:=@Thread_Spawn;
  aObject[sThreadSelf]:=@Thread_Self;
end;

{ TThreadConsoleOutput }


procedure TThreadConsoleOutput.HandleConsoleMessage(aCommand : TCustomWorkerCommand);
var
  D : TWorkerConsoleCommand absolute aCommand;
  Msg : String;

begin
  Msg:=D.ConsoleMessage;
  if D.SenderID<>'' then
    Msg:='['+D.SenderID+'] '+Msg;
  if assigned(OnOutput) then
    OnOutPut(Msg)
  else
    Writeln(Msg);
end;

class constructor TThreadConsoleOutput.done;
begin
  FreeAndNil(_Instance);
end;

class procedure TThreadConsoleOutput.init;
begin
  _Instance:=TThreadConsoleOutput.Create;
end;

constructor TThreadConsoleOutput.Create;
begin
  TCommandDispatcher.Instance.RegisterCommandHandler(cmdConsole,@HandleConsoleMessage);
  FEnabled:=True;
end;


end.

