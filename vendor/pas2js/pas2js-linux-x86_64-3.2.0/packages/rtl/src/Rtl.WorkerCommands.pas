unit Rtl.WorkerCommands;

{$mode ObjFPC}
{$modeswitch externalclass}

// Define this if you want to see lots and lots of traces...
{ $define DEBUGCOMMANDDISPATCHER}

interface

uses
  SysUtils, JS, WebOrWorker;

const
  cmdConsole = 'console';
  cmdException = 'exception';
  cmdForward = 'forward';
  channelConsole = 'console_output';

  cFldCanceled = 'canceled';
  cFldCommand = 'command';
  cFldSender = '_sender';
  cFldSenderId = 'senderId';


Type
  EWorkerCommand = Class(Exception);

  { TCustomWorkerCommand }

  TCustomWorkerCommand = class external name 'Object' (TJSObject)
  private
    FCanceled : Boolean; external name 'canceled';
    FCommand : string; external name 'command';
    FSender: TJSObject; external name '_sender';
    FSenderID : string; external name 'senderId';
  Public
    property Command : string read FCommand;
    property Canceled : Boolean read FCanceled;
    property SenderID : String read FSenderID;
    // May be empty
    property Sender : TJSObject Read FSender;
  end;

  { TCustomWorkerCommandHelper }

  TCustomWorkerCommandHelper = class helper for TCustomWorkerCommand
    Procedure Cancel;
    class function createCommand(aCommand : string; aSenderID : String = '') : TCustomWorkerCommand; static;
  end;

  TForwardCommand = class external name 'Object' (TCustomWorkerCommand)
    DestinationWorker : string;
    Payload : TCustomWorkerCommand;
  end;

  { TForwardCommandHelper }

  TForwardCommandHelper = class helper (TCustomWorkerCommandHelper) for TForwardCommand
    class function create(const aDestinationWorker : string; aCommand :TCustomWorkerCommand) : TForwardCommand; static; reintroduce;
  end;

  TConsoleOutputCommand = class external name 'Object' (TCustomWorkerCommand)
    ConsoleMessage : string;
  end;

  { TConsoleOutputCommandHelper }

  TConsoleOutputCommandHelper = class helper (TCustomWorkerCommandHelper) for TConsoleOutputCommand
    class function create(const aMessage: string): TConsoleOutputCommand; static;reintroduce;
  end;

  // When an unexpected error occurred.
  TWorkerExceptionCommand = class external name 'Object' (TCustomWorkerCommand)
  public
    ExceptionClass: String;
    ExceptionMessage: String;
  end;

  { TWorkerExceptionCommandHelper }

  TWorkerExceptionCommandHelper = class helper(TCustomWorkerCommandHelper) for TWorkerExceptionCommand
    Class function Create(const aExceptionClass,aExceptionMessage : string; aThreadID : Integer = -1) : TWorkerExceptionCommand; static;reintroduce;
  end;



  TCommandDispatcher = class;
  TCommandDispatcherClass = class of TCommandDispatcher;

  TCommandHandler = Reference to procedure(aCommand : TCustomWorkerCommand);
  generic TTypedCommandHandler<T : TCustomWorkerCommand> = Reference to procedure(aCommand : T);

  { TCommandDispatcher }

  TCommandDispatcher = class(TObject)
  private
    Type
      TCommandHandlerArray = array of TCommandHandler;
      TCommandHandlerReg = record
        Handlers : TCommandHandlerArray;
        SingleHandler : Boolean;
      end;
      TJSWorkerReg = record
        Worker : TJSWorker;
        Name : string;
      end;
    class var _Instance : TCommandDispatcher;
    class var _DispatcherClass : TCommandDispatcherClass;
    class function GetInstance: TCommandDispatcher; static;
  private
    FDefaultSenderID: String;
    FMap : TJSMap; // Key is command. Value is TCommandHandlerReg.
    FWorkers : Array of TJSWorkerReg;
    FConsoleChannel : TJSBroadcastChannel;
  protected
    class function IsCommandEvent(aEvent: TJSEvent): Boolean;
    procedure CheckSenderID(aCommand: TCustomWorkerCommand); virtual;
    function IndexOfWorker(aWorker: TJSWorker): Integer;
    function IndexOfWorker(const aName: String): Integer;
    Procedure HandleIncomingMessage(aEvent : TJSEvent); virtual;
    procedure HandleCommand(aCommand: TCustomWorkerCommand); virtual;
  Public
    constructor create; virtual;
    destructor destroy; override;
    // Send command to worker
    procedure SendCommand(aWorker : TJSWorker; aCommand : TCustomWorkerCommand); virtual;
    // Send command on channel
    procedure SendCommand(aChannel : TJSBroadcastChannel; aCommand : TCustomWorkerCommand); virtual;
    // Send command to worker
    procedure SendCommand(const aName : string; aCommand : TCustomWorkerCommand);
    // Send command to thread that started this worker. Cannot be used in main thread
    procedure SendCommand(aCommand : TCustomWorkerCommand); virtual;
    // Send command to thread that started this worker. Cannot be used in main thread
    procedure SendCommand(aCommand : TCustomWorkerCommand; aTransfer : Array of JSValue); virtual;
    // Send command to thread that started this worker. Cannot be used in main thread
    procedure SendConsoleCommand(aCommand : TConsoleOutputCommand); virtual;
    // Send command to all registered workers
    procedure BroadcastCommand(aCommand : TCustomWorkerCommand);
    // Register a command handler for command aCommand
    Procedure RegisterCommandHandler(const aCommand : string; aHandler : TCommandHandler; IsSingle : Boolean = false);
    // Remove the given command handler for command aCommand
    Procedure UnRegisterCommandHandler(const aCommand : string; aHandler : TCommandHandler);
    // Register a command handler for command aCommand
    Generic Procedure AddCommandHandler<T : TCustomWorkerCommand>(const aCommand : string; aHandler : specialize TTypedCommandHandler<T>; IsSingle : boolean = false);
    // Register a worker for broadcast
    Procedure RegisterWorker(aWorker : TJSWorker; const aName : string);
    // Remove a worker from broadcast list
    Procedure UnRegisterWorker(aWorker : TJSWorker);
    // Remove a worker from broadcast list by name
    Procedure UnRegisterWorker(const aName : string);
    // Listen for commands on this channel
    Procedure ListenOnChannel(aChannel : TJSBroadcastChannel);
    Property DefaultSenderID : String Read FDefaultSenderID Write FDefaultSenderID;
    Class function SetDispatcherClass(aClass : TCommandDispatcherClass) : TCommandDispatcherClass;
    Class property instance : TCommandDispatcher read GetInstance;

  end;

function CommandDispatcher : TCommandDispatcher;

implementation

function CommandDispatcher : TCommandDispatcher;
begin
  Result:=TCommandDispatcher.Instance;
end;

{ TCustomWorkerCommandHelper }

procedure TCustomWorkerCommandHelper.Cancel;
begin
  FCanceled:=True;
end;

class function TCustomWorkerCommandHelper.createCommand(aCommand: string; aSenderID : String): TCustomWorkerCommand;
begin
  Result:=TCustomWorkerCommand.New;
  Result.FCanceled:=False;
  Result.FCommand:=aCommand;
  Result.FSenderID:=aSenderID;
end;

{ TConsoleOutputCommandHelper }

class function TConsoleOutputCommandHelper.create(const aMessage : string): TConsoleOutputCommand;
begin
  Result:=TConsoleOutputCommand(CreateCommand(cmdConsole));
  Result.ConsoleMessage:=aMessage;
end;

{ TWorwardCommandHelper }

class function TForwardCommandHelper.create(const aDestinationWorker: string; aCommand: TCustomWorkerCommand
  ): TForwardCommand;
begin
  Result:=TForwardCommand(CreateCommand(cmdForward));
  Result.DestinationWorker:=aDestinationWorker;
  Result.Payload:=aCommand;
end;

{ TWorkerExceptionCommandHelper }

class function TWorkerExceptionCommandHelper.Create(const aExceptionClass,aExceptionMessage: string; aThreadID : Integer = -1  ): TWorkerExceptionCommand;
begin
  Result:=TWorkerExceptionCommand(CreateCommand(cmdException,IntToStr(aThreadID)));
  Result.ExceptionClass:=aExceptionClass;
  Result.ExceptionMessage:=aExceptionMessage;
end;


{ TCommandDispatcher }

class function TCommandDispatcher.GetInstance: TCommandDispatcher; static;
var
  C : TCommandDispatcherClass;
begin
  if Not Assigned(_Instance) then
    begin
    C:=_DispatcherClass;
    if (C=Nil) then
      C:=TCommandDispatcher;
    _Instance:=C.Create;
    end;
  Result:=_Instance;

end;

class function TCommandDispatcher.IsCommandEvent(aEvent: TJSEvent): Boolean;
var
  lMessageEvent : TJSMessageEvent absolute aEvent;
  Obj : TJSObject;
begin
  Result:=assigned(aEvent) and isObject(lMessageEvent.Data);
  if Result then
    begin
    Obj:=TJSObject(lMessageEvent.Data);
    Result:=Obj.hasOwnProperty(cFldcommand) and isString(Obj[cFldcommand]);
    end;
end;

procedure TCommandDispatcher.HandleCommand(aCommand : TCustomWorkerCommand);
var
  lCmd : String;
  lValue : JSValue;
  lReg : TCommandHandlerReg absolute lValue;
  lHandler : TCommandHandler;
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  lCount: Integer;
  {$ENDIF}
begin
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  lCount:=0;
  {$ENDIF}
  lCmd:=aCommand.Command;
  lValue:=FMap.get(lCmd);
  if assigned(lValue) then
    For lHandler in lReg.Handlers do
      begin
      {$IFDEF DEBUGCOMMANDDISPATCHER}
      inc(lCount);
      {$ENDIF}
      LHandler(aCommand);
      if aCommand.Canceled then
        break;
      end;
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Incoming message sent to ',lCount,' handlers ',TJSJSON.stringify(aCommand));
  {$ENDIF}
end;

procedure TCommandDispatcher.HandleIncomingMessage(aEvent: TJSEvent);
var
  lMessageEvent : TJSMessageEvent absolute aEvent;
  lCommand : TCustomWorkerCommand;
begin
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Incoming message: ',TJSJSON.stringify(lMessageEvent.data));
  {$ENDIF}
  if IsCommandEvent(aEvent) then
    begin
    lCommand:=TCustomWorkerCommand(lMessageEvent.data);
    lCommand.FSender:=aEvent.target;
    HandleCommand(lCommand);
    end;
end;

constructor TCommandDispatcher.create;
begin
  FMap:=TJSMap.new();
  FConsoleChannel:=TJSBroadcastChannel.new(channelConsole);
  if isMainBrowserThread then
    FConsoleChannel.addEventListener('message',@HandleIncomingMessage)
  else
    Self_.addEventListener('message',@HandleIncomingMessage)
end;

destructor TCommandDispatcher.destroy;
begin
  FConsoleChannel.close;
  FConsoleChannel:=nil;
  inherited destroy;
end;

procedure TCommandDispatcher.CheckSenderID(aCommand: TCustomWorkerCommand);
begin
  if (aCommand.FSenderID='') then
    aCommand.FSenderID:=DefaultSenderID;
  aCommand[cFldSender]:=undefined;
end;

procedure TCommandDispatcher.SendCommand(aWorker: TJSWorker; aCommand: TCustomWorkerCommand);
begin
  CheckSenderID(aCommand);
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Sending message to worker: ',TJSJSON.stringify(aCommand));
  {$ENDIF}
  aWorker.postMessage(aCommand);
end;

procedure TCommandDispatcher.SendCommand(aChannel: TJSBroadcastChannel; aCommand: TCustomWorkerCommand);
begin
  CheckSenderID(aCommand);
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Sending message to channel ',aChannel.Name,': ',TJSJSON.stringify(aCommand));
  {$ENDIF}
  aChannel.postMessage(aCommand);
end;

procedure TCommandDispatcher.SendCommand(const aName: string; aCommand: TCustomWorkerCommand);
var
  Idx : integer;
begin
  CheckSenderID(aCommand);
  Idx:=IndexOfWorker(aName);
  if Idx<0 then
    begin
    // let the main dispatcher forward it.
    if (isWebWorker or IsServiceWorker) then
      SendCommand(TForwardCommand.create(aName,aCommand))
    else
      Raise EWorkerCommand.CreateFmt('Unknown worker: %s',[aName]);
    end;
  SendCommand(FWorkers[Idx].Worker,aCommand);
end;

procedure TCommandDispatcher.SendCommand(aCommand: TCustomWorkerCommand);
begin
  if not (isWebWorker or IsServiceWorker) then
    Raise EWorkerCommand.Create('Cannot send to starting thread from main page');
  CheckSenderID(aCommand);
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Sending message to worker controller: ',TJSJSON.stringify(aCommand));
  {$ENDIF}
  asm
  self.postMessage(aCommand);
  end;
end;

procedure TCommandDispatcher.SendCommand(aCommand: TCustomWorkerCommand; aTransfer: array of JSValue);

begin
  if not (isWebWorker or IsServiceWorker) then
    Raise EWorkerCommand.Create('Cannot send to starting thread from main page');
  CheckSenderID(aCommand);
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Sending message to worker controller: ',TJSJSON.stringify(aCommand));
  {$ENDIF}
  asm
  self.postMessage(aCommand,aTransfer);
  end;
  if length(aTransfer)=0 then ;
end;

procedure TCommandDispatcher.SendConsoleCommand(aCommand: TConsoleOutputCommand);

begin
  if not (isWebWorker or IsServiceWorker) then
    Raise EWorkerCommand.Create('Cannot send to starting thread from main page');
  {$IFDEF DEBUGCOMMANDDISPATCHER}
  Writeln('Sending console message on console channel: ',TJSJSON.stringify(aCommand));
  {$ENDIF}
  CheckSenderID(aCommand);
  FConsoleChannel.postMessage(aCommand);
end;

procedure TCommandDispatcher.BroadcastCommand(aCommand: TCustomWorkerCommand);
var
  lWorker : TJSWorkerReg;
begin
  CheckSenderID(aCommand);
  For lWorker in FWorkers do
    SendCommand(lWorker.Worker,aCommand);
end;

procedure TCommandDispatcher.RegisterCommandHandler(const aCommand: string; aHandler: TCommandHandler; IsSingle : Boolean = false);
var
  lValue : JSValue;
  lReg : TCommandHandlerReg absolute lValue;
  lNewReg : TCommandHandlerReg;
begin
  lValue:=FMap.get(aCommand);
  if Assigned(lValue) then
    begin
    if not (lReg.SingleHandler or isSingle) then
      TJSArray(lReg.Handlers).Push(aHandler)
    else
      begin
      if (Length(lReg.Handlers)>0) then
        Raise EWorkerCommand.CreateFmt('There is already a handler for command %s',[aCommand]);
      lReg.Handlers:=[aHandler];
      lReg.SingleHandler:=isSingle;
      end
    end
  else
    begin
    lNewReg:=Default(TCommandHandlerReg);
    LNewReg.Handlers:=[aHandler];
    LNewReg.SingleHandler:=IsSingle;
    FMap.&set(aCommand,lNewReg);
    end;
end;

procedure TCommandDispatcher.UnRegisterCommandHandler(const aCommand: string; aHandler: TCommandHandler);
var
  lValue : JSValue;
  lReg : TCommandHandlerReg absolute lValue;
  Idx : integer;
begin
  lValue:=FMap.get(aCommand);
  if Assigned(lValue) then
    begin
    Idx:=TJSArray(LReg.Handlers).IndexOf(aHandler);
    if Idx>=0 then
      Delete(LReg.Handlers,Idx,1);
    end;
end;

generic procedure TCommandDispatcher.AddCommandHandler<T>(const aCommand: string; aHandler: specialize
  TTypedCommandHandler<T>; IsSingle: boolean);
begin
  RegisterCommandHandler(aCommand,procedure (aCmd : TCustomWorkerCommand)
    begin
      aHandler(T(aCmd));
    end,IsSingle);
end;

procedure TCommandDispatcher.RegisterWorker(aWorker: TJSWorker; const aName: string);
var
  lReg : TJSWorkerReg;
begin
  if IndexOfWorker(aName)>=0 then
    Raise EWorkerCommand.CreateFmt('Duplicate worker name: %s',[aName]);
  if IndexOfWorker(aWorker)>=0 then
    Raise EWorkerCommand.Create('Duplicate worker instance');
  lReg.Worker:=aWorker;
  lReg.Name:=aName;
  FWorkers:=Concat(FWorkers,[lReg]);
  aWorker.addEventListener('message',@HandleIncomingMessage);
end;

function TCommandDispatcher.IndexOfWorker(aWorker: TJSWorker) : Integer;

begin
  Result:=Length(FWorkers)-1;
  While (Result>=0) and (FWorkers[Result].Worker<>aWorker) do
    Dec(Result);
end;
function TCommandDispatcher.IndexOfWorker(const aName : String) : Integer;

begin
  Result:=Length(FWorkers)-1;
  While (Result>=0) and (FWorkers[Result].Name<>aName) do
    Dec(Result);
end;

procedure TCommandDispatcher.UnRegisterWorker(aWorker: TJSWorker);
var
  Idx : Integer;
begin
  Idx:=IndexOfWorker(aWorker);
  if Idx>=0 then
    Delete(FWorkers,Idx,1);
end;

procedure TCommandDispatcher.UnRegisterWorker(const aName: string);
var
  Idx : Integer;
begin
  Idx:=IndexOfWorker(aName);
  if Idx>=0 then
    Delete(FWorkers,Idx,1);
end;

procedure TCommandDispatcher.ListenOnChannel(aChannel: TJSBroadcastChannel);
begin
  aChannel.addEventListener('message',@HandleIncomingMessage);
end;

class function TCommandDispatcher.SetDispatcherClass(aClass: TCommandDispatcherClass): TCommandDispatcherClass;
begin
  Result:=_DispatcherClass;
  _DispatcherClass:=aClass;
end;

end.

