unit rtl.threadcontroller;

{$mode ObjFPC}
{$modeswitch externalclass}
{$modeswitch typehelpers}

{ $define NOLOGAPICALLS}

interface

uses
  {$IFDEF FPC_DOTTEDUNITS}
    JSApi.JS, System.SysUtils, Rtl.WorkerCommands, System.WebThreads, BrowserApi.WebOrWorker;
  {$ELSE}
    JS, SysUtils, Rtl.WorkerCommands,  Rtl.WebThreads, weborworker;
  {$ENDIF}

Type
  { TWasmThread }
  TWasmThread = TJSWorker;

  { TWasmThreadHelper }
  TThreadWorkerState = (twsInit,      // Worker is started
                        twsReady,     // Worker is ready to listen to commands
                        twsLoadSent,  // We sent a load command
                        twsIdle,      // The worker has a webassembly loaded and is ready to execute a thread
                        twsExecuting  // The worker is executing a thread
                        );
  TWasmThreadHelper = Class helper for TWasmThread
  private
    function GetThreadID: Integer;
    function GetThreadInfo: TThreadinfo;
    function GetWorkerState: TThreadWorkerState;
    procedure SetThreadID(AValue: Integer);
    procedure SetThreadInfo(AValue: TThreadinfo);
    procedure SetWorkerState(AValue: TThreadWorkerState);
  Public
    Class function Create(aScript : String) : TWasmThread; reintroduce; static;
    Procedure SendCommand(aCommand : TThreadWorkerCommand);
    Property WorkerState : TThreadWorkerState read GetWorkerState Write SetWorkerState;
    Property ThreadInfo : TThreadinfo Read GetThreadInfo Write SetThreadInfo;
    Property ThreadID : Integer Read GetThreadID Write SetThreadID;
  end;



  TThreadHash = class external name 'Object' (TJSObject)
  Private
    function GetThreadData(aIndex: NativeInt): TWasmThread; external name '[]';
    procedure SetThreadData(aIndex: NativeInt; const AValue: TWasmThread); external name '[]';
  Public
    Property ThreadData[aIndex : NativeInt] : TWasmThread Read GetThreadData Write SetThreadData; default;
  end;


  // This object has the thread support that is needed  by the 'main' program

  { TThreadController }
  TWasmThreadEvent = procedure (Sender : TObject; aWorker : TWasmThread) of object;
  TWasmThreadArray = array of TWasmThread;
  TWasmThreadEnumProc = reference to procedure(aWorker : TWasmThread);
  TConsoleWriteEvent = procedure (Sender : TObject; Const Msg : String) of object;

  TThreadController = class(TWasmThreadController)
  private
    FHandleConsoleMessages: Boolean;
    FLogAPI: Boolean;
    FOnConsoleWrite: TConsoleWriteEvent;
    FWorkerCount : Integer;
    FInitialWorkerCount: Integer;
    FMaxWorkerCount: Integer;
    FOnAllocateWorker: TWasmThreadEvent;
    FOnUnknownMessage: TJSRawEventHandler;
    FWorkerScript: String;
    procedure HandleRawCleanupCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawReadyCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawSpawnCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawLoadedCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawConsoleCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawKillCommand(aCommand: TCustomWorkerCommand);
    procedure HandleRawCancelCommand(aCommand: TCustomWorkerCommand);
  Protected
    procedure HaveWebassembly; override;
    Procedure DoError(const msg : string);
    procedure RunTimeOut(aInfo: TThreadInfo; aInterval: Integer); virtual;
    property logAPI : Boolean Read FLogAPI;
  Protected
    FIdleWorkers : TWasmThreadArray;
    FBusyWorkers : TWasmThreadArray;
    FThreads : TThreadHash; // ThreadID is key,
    // Create & set up new worker
    Function AllocateNewWorker(Const aWorkerScript : string) : TWasmThread; virtual;
    // Send a load command
    procedure SendLoadCommand(aThreadWorker: TWasmThread); virtual;
    // Get new worker from pool, create new if needed.
    Function GetNewWorker : TWasmThread;
    // Spawn & prepare to run a new thread.
    Function SpawnThread(aInfo : TThreadInfo) : Integer; overload;
    // Actually send run command.
    Procedure SendRunCommand(aThreadWorker: TWasmThread);
    //
    // Handle Various commands sent from worker threads.
    //
    // Allocate a new worker for a thread and run the thread if the worker is loaded.
    procedure HandleSpawnCommand(aWorker: TWasmThread; aCommand: TWorkerSpawnThreadCommand); virtual;
    // A new worker was started and is ready to handle commands (message handler is set).
    procedure HandleReadyCommand(aWorker: TWasmThread; aCommand: TWorkerReadyCommand); virtual;
    // Cancel command: stop the thread
    procedure HandleCancelCommand(aWorker: TWasmThread; aCommand: TWorkerCancelCommand); virtual;
    // Cleanup thread : after join (or stopped if detached), free worker.
    procedure HandleCleanupCommand(aWorker: TWasmThread; aCommand: TWorkerCleanupCommand); virtual;
    // forward KILL signal to thread.
    procedure HandleKillCommand(aWorker: TWasmThread; aCommand: TWorkerKillCommand); virtual;
    // Worker script is loaded, has loaded webassembly and is ready to run.
    procedure HandleLoadedCommand(aWorker: TWasmThread; aCommand: TWorkerLoadedCommand); overload;
    // Console output from worker.
    procedure HandleConsoleCommand(aWorker: TWasmThread;  aCommand: TWorkerConsoleCommand);
    // Register callbacks
    procedure InitMessageCallBacks;
  Public
    Constructor Create; override;
    Constructor Create(aWorkerScript : String; aSpawnWorkerCount : integer); virtual; overload;
    // Spawn initial workers; Best called manually, but will be called at the end.
    procedure AllocateInitialworkers;
    // Find thread based on thread ID
    function FindThreadWorker(aThreadID: integer): TWasmThread;
    // the interface needed by wasmP1
    function SpawnThread(start_arg : longint) : longint; override;
    // Send load commands to all workers that still need it.
    procedure SendLoadCommands;
    // Send a command to all workers
    procedure SendCommandToAllWorkers(aCommand : TThreadWorkerCommand);
    // Send a command to a specific thread. TWorkerCommand has the thread ID.
    procedure SendCommandToThread(aCommand : TThreadWorkerCommand);
    // Get a list of all thread workers
    Function GetWebWorkers : TWasmThreadArray;
    // Enumerate workers
    Procedure EnumerateWebWorkers(aCallback : TWasmThreadEnumProc);
    // Name of worker script
    Property WorkerScript : String Read FWorkerScript Write FWorkerScript;
    // Initial number of threads, can be set by constructor
    Property InitialWorkerCount : Integer Read FInitialWorkerCount Write FInitialWorkerCount;
    // Maximum number of workers. If more workers are requested, the GetNewWorker will return Nil.
    Property MaxWorkerCount : Integer Read FMaxWorkerCount Write FMaxWorkerCount;
    Property OnUnknownMessage : TJSRawEventHandler Read FOnUnknownMessage Write FOnUnknownMessage;
    Property OnAllocateWorker : TWasmThreadEvent Read FOnAllocateWorker Write FonAllocateWorker;
    Property HandleConsoleMessages : Boolean Read FHandleConsoleMessages Write FHandleConsoleMessages;
    property OnConsoleWrite : TConsoleWriteEvent Read FOnConsoleWrite Write FOnConsoleWrite;
  end;

Function globalThreadController : TThreadController;

implementation

Resourcestring
  SErrMaxWorkersReached = 'Cannot create thread worker, Maximum number of workers (%d) reached.';

Function globalThreadController : TThreadController;

begin
  Result:=TWasmThreadController.Instance as TThreadController;
end;

{ TWasmThread }

class function TWasmThreadHelper.Create(aScript: String): TWasmThread;
begin
  Result:=TJSWorker.new(aScript);
  Result.ThreadID:=-1;
  Result.WorkerState:=twsInit;
  Result.ThreadInfo:=Default(TThreadInfo);
end;

function TWasmThreadHelper.GetThreadID: Integer;
begin
  Result:=ThreadInfo.ThreadID;
end;


function TWasmThreadHelper.GetThreadInfo: TThreadinfo;
Var
  S : JSValue;
begin
  S:=Properties['FThreadInfo'];
  if isObject(S) then
    Result:=TThreadinfo(S)
  else
    Result:=Default(TThreadInfo);
end;

function TWasmThreadHelper.GetWorkerState: TThreadWorkerState;
var
  S : JSValue;
begin
  S:=Properties['FState'];
  if isNumber(S) then
    Result:=TThreadWorkerState(Integer(S))
  else
    Result:=twsInit;
end;

procedure TWasmThreadHelper.SetThreadID(AValue: Integer);
begin
  ThreadInfo.ThreadID:=aValue;
end;


procedure TWasmThreadHelper.SetThreadInfo(AValue: TThreadinfo);
begin
  Properties['FThreadInfo']:=aValue
end;

procedure TWasmThreadHelper.SetWorkerState(AValue: TThreadWorkerState);
begin
  Properties['FState']:=aValue;
end;


procedure TWasmThreadHelper.SendCommand(aCommand: TThreadWorkerCommand);
begin
  TCommandDispatcher.Instance.SendCommand(Self,aCommand);
end;

function TThreadController.AllocateNewWorker(const aWorkerScript: string): TWasmThread;

var
  lWorkerUrl : String;
begin
  {$IFNDEF NOLOGAPICALLS}
  DoLog('Allocating new worker for: '+aWorkerScript);
  {$ENDIF}
  Inc(FWorkerCount);
  lWorkerUrl:=aWorkerScript;
  if Pos('?',lWorkerUrl)>0 then
    lWorkerUrl:=lWorkerUrl+'&'
  else
    lWorkerUrl:=lWorkerUrl+'?';
  lWorkerUrl:=lWorkerUrl+'worker='+IntToStr(FWorkerCount);
  Result:=TWasmThread.Create(lWorkerUrl);
  TCommandDispatcher.Instance.RegisterWorker(Result,'threadworker'+inttostr(FWorkerCount));
  if LogAPI then
    {$IFNDEF NOLOGAPICALLS}
    DoLog('Host not set, delaying sending load command to: '+aWorkerScript)
    {$ENDIF}
    ;
  If Assigned(OnAllocateWorker) then
    OnAllocateWorker(Self,Result);
end;

procedure TThreadController.SendLoadCommand(aThreadWorker: TWasmThread);

Var
  WLC: TWorkerLoadCommand;

begin
  Writeln('Sending load command to worker.');
  WLC:=TWorkerLoadCommand.Create(WasmModule, WasmMemory);
  aThreadWorker.SendCommand(WLC);
  aThreadWorker.WorkerState:=twsLoadSent;
end;

function TThreadController.GetNewWorker: TWasmThread;

Var
  WT : TWasmThread;

begin
  if Length(FIdleWorkers)=0 then
    begin
    if LogAPI then
      DoLog('No idle workers, creating new one');
    if Length(FBusyWorkers)<MaxWorkerCount then
      WT:=AllocateNewWorker(FWorkerScript)
    else
      Raise EWasmThreads.Create(SErrMaxWorkersReached);
    end
  else
    begin
    WT:=TWasmThread(TJSArray(FIdleWorkers).pop);
    end;
  TJSArray(FBusyWorkers).Push(WT);
  Result:=WT;
end;


procedure TThreadController.SendRunCommand(aThreadWorker: TWasmThread);

Var
  WRC : TWorkerRunCommand;

begin
  With aThreadWorker.ThreadInfo do
    WRC:=TWorkerRunCommand.Create(ThreadID,Arguments);
  aThreadWorker.SendCommand(Wrc);
end;


procedure TThreadController.DoError(const msg: string);
begin
  DoLog('Error: '+Msg);
end;


function TThreadController.SpawnThread(start_arg : longint) : longint;

var
  aInfo : TThreadInfo;

begin
  aInfo.ThreadID:=start_arg;
  aInfo.Arguments:=start_arg;
  aInfo.OriginThreadID:=0;
  Result:=SpawnThread(aInfo);
end;

procedure TThreadController.SendLoadCommands;

Var
  WT : TWasmThread;

begin
  Writeln('Send load commands');
  {$IFNDEF NOLOGAPICALLS}
  DoLog('Sending load command to all workers');
  {$ENDIF}
  For WT in FIdleWorkers do
    if WT.WorkerState=twsReady then
      SendLoadCommand(WT);
end;

procedure TThreadController.SendCommandToAllWorkers(aCommand: TThreadWorkerCommand);

Var
  WT : TWasmThread;

begin
  For WT in FIdleWorkers do
    WT.postMessage(aCommand);
  For WT in FBusyWorkers do
    WT.postMessage(aCommand);
end;

procedure TThreadController.SendCommandToThread(aCommand: TThreadWorkerCommand);
var
  W : TJSWorker;
begin
  W:=TJSWorker(FThreads[aCommand.ThreadID]);
  if Assigned(W) then
    W.postMessage(aCommand);
end;

function TThreadController.GetWebWorkers: TWasmThreadArray;
begin
  Result:=Concat(FBusyWorkers,FIdleWorkers);
end;

procedure TThreadController.EnumerateWebWorkers(aCallback: TWasmThreadEnumProc);

var
  aThread : TWasmThread;

begin
  if Not assigned(aCallback) then
    exit;
  For aThread in GetWebWorkers do
    aCallBack(aThread);
end;


procedure TThreadController.RunTimeOut(aInfo: TThreadInfo; aInterval: Integer);

var
  Msg : String;

begin
  Msg:=Format('Failed to run thread %d spawned from thread %d: load timed out after %d ms.',[aInfo.ThreadID,aInfo.OriginThreadID,aInterval]);
  DoLog(msg);
end;

function TThreadController.SpawnThread(aInfo: TThreadInfo): Integer;

Var
  WT : TWasmThread;


begin
  if FWorkerCount=0 then
    AllocateInitialworkers;
  {$IFNDEF NOLOGAPICALLS}
  DoLog('Enter SpawnThread for ID %d',[aInfo.ThreadID]);
  {$ENDIF}
  WT:=GetNewWorker;
  if WT=nil then
    begin
    DoError('Error: no worker !');
    exit(-1)
    end;
  WT.ThreadInfo:=aInfo;
  FThreads[aInfo.ThreadID]:=WT;
  SendRunCommand(WT);
  Result:=aInfo.ThreadID;
  {$IFNDEF NOLOGAPICALLS}
  DoLog('Exit: SpawnThread for ID %d',[WT.ThreadID]);
  {$ENDIF}
end;


constructor TThreadController.Create;
begin
  Create(DefaultThreadWorker,DefaultThreadCount)
end;

constructor TThreadController.Create(aWorkerScript: String; aSpawnWorkerCount: integer);

begin
  Inherited Create;
  InitMessageCallBacks;
  FThreads:=TThreadHash.new;
  FWorkerScript:=aWorkerScript;
  FInitialWorkerCount:=aSpawnWorkerCount;
  FMaxWorkerCount:=DefaultMaxWorkerCount;
end;

function TThreadController.FindThreadWorker(aThreadID : integer) : TWasmThread;

begin
  Result:=FThreads[aThreadID];
end;

procedure TThreadController.HandleRawSpawnCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerSpawnThreadCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  lWorker:=TWasmThread(aCommand.Sender);
  HandleSpawnCommand(lWorker,lCmd);
end;


procedure TThreadController.HandleSpawnCommand(aWorker : TWasmThread; aCommand: TWorkerSpawnThreadCommand);

Var
  aInfo: TThreadInfo;

begin
  aInfo.OriginThreadID:=aWorker.ThreadID;
  aInfo.ThreadID:=aCommand.ThreadID;
  aInfo.Arguments:=aCommand.Arguments;
  SpawnThread(aInfo);
end;


procedure TThreadController.HandleRawKillCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerKillCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  lWorker:=TWasmThread(aCommand.Sender);
  HandleKillCommand(lWorker,lCmd);
end;

procedure TThreadController.HandleKillCommand(aWorker : TWasmThread; aCommand: TWorkerKillCommand);

begin
  if (aWorker<>Nil) and (aCommand<>Nil) then ;
  // todo
end;

procedure TThreadController.HandleRawCancelCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerCancelCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  lWorker:=TWasmThread(aCommand.Sender);
  HandleCancelCommand(lWorker,lCmd);
end;

procedure TThreadController.HaveWebassembly;
begin
  SendLoadCommands;
end;


procedure TThreadController.HandleCancelCommand(aWorker : TWasmThread; aCommand: TWorkerCancelCommand);

begin
  if (aWorker<>Nil) and (aCommand<>Nil) then ;
  // todo
end;

procedure TThreadController.HandleRawLoadedCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerLoadedCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  Writeln('Receiving loaded command');
  lWorker:=TWasmThread(aCommand.Sender);
  HandleLoadedCommand(lWorker,lCmd);
end;

procedure TThreadController.HandleLoadedCommand(aWorker : TWasmThread; aCommand: TWorkerLoadedCommand);

begin
  {$IFNDEF NOLOGAPICALLS}
  DoLog('Entering TThreadController.HandleLoadedCommand');
  {$ENDIF}
  aWorker.WorkerState:=twsIdle;
  // if a thread is scheduled to run in this thread, run it.
  if aWorker.ThreadID>0 then
    SendRunCommand(aWorker);
  {$IFNDEF NOLOGAPICALLS}
  DoLog('Host: exiting TThreadController.HandleLoadedCommand');
  {$ENDIF}
  if (aCommand<>Nil) then ;
end;

procedure TThreadController.HandleRawCleanupCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerCleanupCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  lWorker:=TWasmThread(aCommand.Sender);
  HandleCleanupCommand(lWorker,lCmd);
end;

procedure TThreadController.HandleRawReadyCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerReadyCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  lWorker:=TWasmThread(aCommand.Sender);
  HandleReadyCommand(lWorker,lCmd);
end;

procedure TThreadController.HandleReadyCommand(aWorker : TWasmThread; aCommand: TWorkerReadyCommand);

begin
  // Send load command to worker
  aWorker.WorkerState:=twsReady;
  if Assigned(WasmMemory) and Assigned(WasmModule) then
    SendLoadCommand(aWorker);
  if (aCommand=Nil) then ; // Silence compiler warning

end;

procedure TThreadController.HandleCleanupCommand(aWorker : TWasmThread; aCommand: TWorkerCleanupCommand);

Var
  Idx : Integer;

begin
  aWorker.ThreadInfo:=Default(TThreadInfo);
  aWorker.WorkerState:=twsIdle;
  Idx:=TJSarray(FBusyWorkers).indexOf(aWorker);
  if Idx<>-1 then
    Delete(FBusyWorkers,Idx,1);
  Idx:=TJSarray(FIdleWorkers).indexOf(aWorker);
  if Idx=-1 then
    FIdleWorkers:=Concat(FIdleWorkers,[aWorker]);
  if (aCommand<>Nil) then ;
end;

procedure TThreadController.HandleRawConsoleCommand(aCommand: TCustomWorkerCommand);
var
  lCmd : TWorkerConsoleCommand absolute aCommand;
  lWorker : TWasmThread;
begin
  lWorker:=TWasmThread(aCommand.Sender);
  HandleConsoleCommand(lWorker,lCmd);
end;


procedure TThreadController.HandleConsoleCommand(aWorker : TWasmThread; aCommand: TWorkerConsoleCommand);

Var
  Prefix : string;

begin
  if Not HandleConsoleMessages then
    exit;
  Prefix:=aCommand.SenderID;
  if Prefix='' then
    Prefix:=Format('[Wasm thread %d]: ',[aWorker.ThreadID])
  else
    Prefix:='['+Prefix+']: ';
  if Assigned(OnConsoleWrite) then
    OnConsoleWrite(Self,Prefix+aCommand.ConsoleMessage)
  else
    Writeln(Prefix+aCommand.ConsoleMessage);
end;

procedure TThreadController.InitMessageCallBacks;
begin
  With TCommandDispatcher.Instance do
    begin
    RegisterCommandHandler(cmdSpawn,@HandleRawSpawnCommand);
    RegisterCommandHandler(cmdCleanup,@HandleRawCleanupCommand);
    RegisterCommandHandler(cmdKill,@HandleRawKillCommand);
    RegisterCommandHandler(cmdCancel,@HandleRawCancelCommand);
    RegisterCommandHandler(cmdLoaded,@HandleRawLoadedCommand);
    RegisterCommandHandler(cmdConsole,@HandleRawConsoleCommand);
    RegisterCommandHandler(cmdReady,@HandleRawReadyCommand);
    end;
end;

procedure TThreadController.AllocateInitialworkers;
var
  I : Integer;
begin
  For I:=1 to InitialWorkerCount do
    TJSArray(FIdleWorkers).Push(AllocateNewWorker(FWorkerScript));
end;

begin
  TWasmThreadController.SetInstanceClass(TThreadController);
end.

