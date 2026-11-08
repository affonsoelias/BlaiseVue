unit BVFSM;

{
  BVFSM - Finite State Machine Engine for BlaiseVue (BlaiseX)
  -------------------------------------------------------------
  Implements enterprise-grade deterministic Finite State Machines (FSM)
  in pure Object Pascal for BlaiseVue 5.0.

  Features:
  - Declarative states, events, and transitions
  - Pre-transition validation guards (guards prevent invalid jumps)
  - Action callbacks and state lifecycle hooks (OnEnter, OnExit)
  - Full transition history and audit logging
  - Subscription observer pattern for telemetry and middleware
  - Reactive bridge: integrates with BVReactivity so component templates
    automatically re-render on state changes (:disabled="fsm.matches('loading')")
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  TBVStateMachine = class;
  TBVFSMState = class;
  TBVFSMTransition = class;

  { Function and Procedure types }
  TBVFSMGuardFunc = reference to function(Context: JSValue; Payload: JSValue): Boolean;
  TBVFSMActionProc = reference to procedure(Context: JSValue; Payload: JSValue);
  TBVFSMStateProc = reference to procedure(Context: JSValue; Payload: JSValue);
  TBVFSMTransitionProc = reference to procedure(Machine: TBVStateMachine; const FromState, ToState, EventName: string; Context: JSValue; Payload: JSValue);
  TBVFSMSubscriberProc = reference to procedure(Machine: TBVStateMachine; const NewState, OldState, EventName: string; Context: JSValue);

  { Represents a single directed transition between states }
  TBVFSMTransition = class
  private
    FEvent: string;
    FTarget: string;
    FGuard: TBVFSMGuardFunc;
    FAction: TBVFSMActionProc;
  public
    constructor Create(const AEvent, ATarget: string); overload;
    constructor Create(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc); overload;
    constructor Create(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc; AAction: TBVFSMActionProc); overload;

    function When(AGuard: TBVFSMGuardFunc): TBVFSMTransition;
    function DoAction(AAction: TBVFSMActionProc): TBVFSMTransition;

    property EventName: string read FEvent;
    property TargetState: string read FTarget;
    property Guard: TBVFSMGuardFunc read FGuard;
    property Action: TBVFSMActionProc read FAction;
  end;

  { Represents a state definition containing valid transitions and hooks }
  TBVFSMState = class
  private
    FMachine: TBVStateMachine;
    FName: string;
    FTransitions: TJSArray; { Array of TBVFSMTransition }
    FOnEnter: TBVFSMStateProc;
    FOnExit: TBVFSMStateProc;
  public
    constructor Create(AMachine: TBVStateMachine; const AName: string);
    destructor Destroy; override;

    { Fluent transition declaration }
    function On(const AEvent, ATarget: string): TBVFSMState; overload;
    function On(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc): TBVFSMState; overload;
    function On(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc; AAction: TBVFSMActionProc): TBVFSMState; overload;
    function AddTransition(ATransition: TBVFSMTransition): TBVFSMState;

    { Entry and exit hooks }
    function Enter(AProc: TBVFSMStateProc): TBVFSMState;
    function ExitState(AProc: TBVFSMStateProc): TBVFSMState;

    { Fluent back-references to parent machine }
    function State(const AName: string): TBVFSMState; overload;
    function State(const AName: string; const ATransitions: array of TBVFSMTransition): TBVStateMachine; overload;
    function Initial(const AState: string): TBVStateMachine;
    function Machine: TBVStateMachine;

    function FindTransition(const AEvent: string): TBVFSMTransition;
    function GetTransitions: TJSArray;

    property Name: string read FName;
    property OnEnterProc: TBVFSMStateProc read FOnEnter write FOnEnter;
    property OnExitProc: TBVFSMStateProc read FOnExit write FOnExit;
  end;

  { The Finite State Machine Container }
  TBVStateMachine = class
  private
    FName: string;
    FInitialState: string;
    FCurrentState: string;
    FPreviousState: string;
    FContext: JSValue;
    FStates: TJSArray;        { Array of TBVFSMState }
    FHistory: TJSArray;       { Array of transition log objects }
    FSubscribers: TJSArray;   { Array of TBVFSMSubscriberProc wrappers }
    FOnTransition: TBVFSMTransitionProc;
    FStrict: Boolean;         { When True, invalid events throw Exception; when False, return False }
    FReactiveProxy: JSValue;  { Reactive proxy for template and watch binding }
    function GetHistoryCount: Integer;
    function GetHistoryItem(Index: Integer): JSValue;
    procedure NotifySubscribers(const NewState, OldState, EventName: string);
    procedure UpdateReactiveState;
    function FindState(const AName: string): TBVFSMState;
  public
    constructor Create(const AName: string; AContext: JSValue = nil);
    destructor Destroy; override;

    { Fluent builder methods }
    function Initial(const AState: string): TBVStateMachine;
    function ContextData(AContext: JSValue): TBVStateMachine;
    function State(const AName: string): TBVFSMState; overload;
    function State(const AName: string; const ATransitions: array of TBVFSMTransition): TBVStateMachine; overload;
    function OnTransition(AProc: TBVFSMTransitionProc): TBVStateMachine;
    function StrictMode(AStrict: Boolean): TBVStateMachine;

    { State Query & Execution }
    function Send(const AEvent: string; APayload: JSValue = nil): Boolean;
    function Matches(const AState: string): Boolean;
    function Can(const AEvent: string; APayload: JSValue = nil): Boolean;
    function GetAllowedEvents: TJSArray;
    procedure Reset;

    { Subscriptions }
    function Subscribe(ACallback: TBVFSMSubscriberProc): Integer;
    procedure Unsubscribe(AId: Integer);

    { Properties }
    property Name: string read FName;
    property Current: string read FCurrentState;
    property Previous: string read FPreviousState;
    property Context: JSValue read FContext write FContext;
    property Strict: Boolean read FStrict write FStrict;
    property HistoryCount: Integer read GetHistoryCount;
    property History[Index: Integer]: JSValue read GetHistoryItem;
    property Reactive: JSValue read FReactiveProxy;
  end;

{ Factory helper functions for concise fluent declarations }
function Transition(const AEvent, ATarget: string): TBVFSMTransition; overload;
function Transition(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc): TBVFSMTransition; overload;
function Transition(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc; AAction: TBVFSMActionProc): TBVFSMTransition; overload;

implementation

{ ============================================================================ }
{ Standalone Transition Factory Helpers                                        }
{ ============================================================================ }

function Transition(const AEvent, ATarget: string): TBVFSMTransition;
begin
  Result := TBVFSMTransition.Create(AEvent, ATarget);
end;

function Transition(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc): TBVFSMTransition;
begin
  Result := TBVFSMTransition.Create(AEvent, ATarget, AGuard);
end;

function Transition(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc; AAction: TBVFSMActionProc): TBVFSMTransition;
begin
  Result := TBVFSMTransition.Create(AEvent, ATarget, AGuard, AAction);
end;

{ ============================================================================ }
{ TBVFSMTransition Implementation                                              }
{ ============================================================================ }

constructor TBVFSMTransition.Create(const AEvent, ATarget: string);
begin
  inherited Create;
  FEvent := UpperCase(Trim(AEvent));
  FTarget := Trim(ATarget);
  FGuard := nil;
  FAction := nil;
end;

constructor TBVFSMTransition.Create(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc);
begin
  Create(AEvent, ATarget);
  FGuard := AGuard;
end;

constructor TBVFSMTransition.Create(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc; AAction: TBVFSMActionProc);
begin
  Create(AEvent, ATarget, AGuard);
  FAction := AAction;
end;

function TBVFSMTransition.When(AGuard: TBVFSMGuardFunc): TBVFSMTransition;
begin
  FGuard := AGuard;
  Result := Self;
end;

function TBVFSMTransition.DoAction(AAction: TBVFSMActionProc): TBVFSMTransition;
begin
  FAction := AAction;
  Result := Self;
end;

{ ============================================================================ }
{ TBVFSMState Implementation                                                   }
{ ============================================================================ }

constructor TBVFSMState.Create(AMachine: TBVStateMachine; const AName: string);
begin
  inherited Create;
  FMachine := AMachine;
  FName := Trim(AName);
  FTransitions := TJSArray.new;
  FOnEnter := nil;
  FOnExit := nil;
end;

destructor TBVFSMState.Destroy;
var
  i: Integer;
  Tr: TBVFSMTransition;
begin
  for i := 0 to Integer(FTransitions.length) - 1 do
  begin
    Tr := TBVFSMTransition(FTransitions[i]);
    Tr.Free;
  end;
  inherited Destroy;
end;

function TBVFSMState.On(const AEvent, ATarget: string): TBVFSMState;
begin
  AddTransition(TBVFSMTransition.Create(AEvent, ATarget));
  Result := Self;
end;

function TBVFSMState.On(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc): TBVFSMState;
begin
  AddTransition(TBVFSMTransition.Create(AEvent, ATarget, AGuard));
  Result := Self;
end;

function TBVFSMState.On(const AEvent, ATarget: string; AGuard: TBVFSMGuardFunc; AAction: TBVFSMActionProc): TBVFSMState;
begin
  AddTransition(TBVFSMTransition.Create(AEvent, ATarget, AGuard, AAction));
  Result := Self;
end;

function TBVFSMState.AddTransition(ATransition: TBVFSMTransition): TBVFSMState;
begin
  FTransitions.push(ATransition);
  Result := Self;
end;

function TBVFSMState.Enter(AProc: TBVFSMStateProc): TBVFSMState;
begin
  FOnEnter := AProc;
  Result := Self;
end;

function TBVFSMState.ExitState(AProc: TBVFSMStateProc): TBVFSMState;
begin
  FOnExit := AProc;
  Result := Self;
end;

function TBVFSMState.State(const AName: string): TBVFSMState;
begin
  Result := FMachine.State(AName);
end;

function TBVFSMState.State(const AName: string; const ATransitions: array of TBVFSMTransition): TBVStateMachine;
begin
  Result := FMachine.State(AName, ATransitions);
end;

function TBVFSMState.Initial(const AState: string): TBVStateMachine;
begin
  Result := FMachine.Initial(AState);
end;

function TBVFSMState.Machine: TBVStateMachine;
begin
  Result := FMachine;
end;

function TBVFSMState.FindTransition(const AEvent: string): TBVFSMTransition;
var
  EvUpper: string;
  i: Integer;
  Tr: TBVFSMTransition;
begin
  Result := nil;
  EvUpper := UpperCase(Trim(AEvent));
  for i := 0 to Integer(FTransitions.length) - 1 do
  begin
    Tr := TBVFSMTransition(FTransitions[i]);
    if Tr.EventName = EvUpper then
      Exit(Tr);
  end;
end;

function TBVFSMState.GetTransitions: TJSArray;
begin
  Result := FTransitions;
end;

{ ============================================================================ }
{ TBVStateMachine Implementation                                               }
{ ============================================================================ }

constructor TBVStateMachine.Create(const AName: string; AContext: JSValue);
var
  RawProxy: TJSObject;
begin
  inherited Create;
  FName := Trim(AName);
  FInitialState := '';
  FCurrentState := '';
  FPreviousState := '';
  FStrict := True;
  FOnTransition := nil;
  FStates := TJSArray.new;
  FHistory := TJSArray.new;
  FSubscribers := TJSArray.new;

  if AContext <> nil then
    FContext := AContext
  else
    FContext := TJSObject.new;

  { Create reactive proxy container for live template bindings }
  RawProxy := TJSObject.new;
  RawProxy['name'] := FName;
  RawProxy['current'] := '';
  RawProxy['previous'] := '';
  RawProxy['context'] := FContext;
  FReactiveProxy := DefineReactive(RawProxy);
end;

destructor TBVStateMachine.Destroy;
var
  i: Integer;
  St: TBVFSMState;
begin
  for i := 0 to Integer(FStates.length) - 1 do
  begin
    St := TBVFSMState(FStates[i]);
    St.Free;
  end;
  inherited Destroy;
end;

function TBVStateMachine.FindState(const AName: string): TBVFSMState;
var
  i: Integer;
  St: TBVFSMState;
begin
  Result := nil;
  for i := 0 to Integer(FStates.length) - 1 do
  begin
    St := TBVFSMState(FStates[i]);
    if St.Name = AName then
      Exit(St);
  end;
end;

function TBVStateMachine.Initial(const AState: string): TBVStateMachine;
begin
  FInitialState := Trim(AState);
  if FCurrentState = '' then
  begin
    FCurrentState := FInitialState;
    UpdateReactiveState;
  end;
  Result := Self;
end;

function TBVStateMachine.ContextData(AContext: JSValue): TBVStateMachine;
begin
  FContext := AContext;
  TJSObject(FReactiveProxy)['context'] := FContext;
  Result := Self;
end;

function TBVStateMachine.State(const AName: string): TBVFSMState;
var
  Existing: TBVFSMState;
begin
  Existing := FindState(AName);
  if Existing <> nil then
    Result := Existing
  else
  begin
    Result := TBVFSMState.Create(Self, AName);
    FStates.push(Result);
  end;
end;

function TBVStateMachine.State(const AName: string; const ATransitions: array of TBVFSMTransition): TBVStateMachine;
var
  St: TBVFSMState;
  i: Integer;
begin
  St := State(AName);
  for i := Low(ATransitions) to High(ATransitions) do
    St.AddTransition(ATransitions[i]);
  Result := Self;
end;

function TBVStateMachine.OnTransition(AProc: TBVFSMTransitionProc): TBVStateMachine;
begin
  FOnTransition := AProc;
  Result := Self;
end;

function TBVStateMachine.StrictMode(AStrict: Boolean): TBVStateMachine;
begin
  FStrict := AStrict;
  Result := Self;
end;

function TBVStateMachine.Matches(const AState: string): Boolean;
begin
  Result := (FCurrentState = AState);
end;

function TBVStateMachine.Can(const AEvent: string; APayload: JSValue): Boolean;
var
  CurrSt: TBVFSMState;
  Tr: TBVFSMTransition;
begin
  Result := False;
  if FCurrentState = '' then Exit;

  CurrSt := FindState(FCurrentState);
  if CurrSt = nil then Exit;

  Tr := CurrSt.FindTransition(AEvent);
  if Tr = nil then Exit;

  { Evaluate guard if present }
  if Assigned(Tr.Guard) then
  begin
    try
      if not Tr.Guard(FContext, APayload) then
        Exit(False);
    except
      Exit(False);
    end;
  end;

  Result := True;
end;

function TBVStateMachine.GetAllowedEvents: TJSArray;
var
  CurrSt: TBVFSMState;
  Tr: TBVFSMTransition;
  i: Integer;
begin
  Result := TJSArray.new;
  if FCurrentState = '' then Exit;

  CurrSt := FindState(FCurrentState);
  if CurrSt = nil then Exit;

  for i := 0 to Integer(CurrSt.FTransitions.length) - 1 do
  begin
    Tr := TBVFSMTransition(CurrSt.FTransitions[i]);
    Result.push(Tr.EventName);
  end;
end;

function TBVStateMachine.Send(const AEvent: string; APayload: JSValue): Boolean;
var
  EvUpper: string;
  CurrSt, NextSt: TBVFSMState;
  Tr: TBVFSMTransition;
  OldState, NewState: string;
  LogEntry: TJSObject;
begin
  EvUpper := UpperCase(Trim(AEvent));
  OldState := FCurrentState;

  if FCurrentState = '' then
  begin
    if FStrict then
      raise Exception.Create('[BVFSM: ' + FName + '] Cannot send event "' + AEvent + '": Machine has no active initial state.')
    else
      Exit(False);
  end;

  CurrSt := FindState(FCurrentState);
  if CurrSt = nil then
  begin
    if FStrict then
      raise Exception.Create('[BVFSM: ' + FName + '] Current state "' + FCurrentState + '" is not registered.')
    else
      Exit(False);
  end;

  Tr := CurrSt.FindTransition(EvUpper);
  if Tr = nil then
  begin
    if FStrict then
      raise Exception.Create('[BVFSM: ' + FName + '] Invalid transition: Event "' + AEvent + '" is not allowed in state "' + FCurrentState + '".')
    else
      Exit(False);
  end;

  { Guard check }
  if Assigned(Tr.Guard) then
  begin
    if not Tr.Guard(FContext, APayload) then
    begin
      { Transition prevented by guard }
      Exit(False);
    end;
  end;

  NewState := Tr.TargetState;
  NextSt := FindState(NewState);
  if NextSt = nil then
  begin
    if FStrict then
      raise Exception.Create('[BVFSM: ' + FName + '] Target state "' + NewState + '" is not registered.')
    else
      Exit(False);
  end;

  { 1. Invoke current state exit hook }
  if Assigned(CurrSt.OnExitProc) then
  begin
    try
      CurrSt.OnExitProc(FContext, APayload);
    except
      on E: Exception do
        if FStrict then raise;
    end;
  end;

  { 2. Invoke transition action if assigned }
  if Assigned(Tr.Action) then
  begin
    try
      Tr.Action(FContext, APayload);
    except
      on E: Exception do
        if FStrict then raise;
    end;
  end;

  { 3. Update machine state and history }
  FPreviousState := OldState;
  FCurrentState := NewState;

  LogEntry := TJSObject.new;
  LogEntry['from'] := OldState;
  LogEntry['to'] := NewState;
  LogEntry['event'] := EvUpper;
  LogEntry['payload'] := APayload;
  LogEntry['timestamp'] := TJSDate.now;
  FHistory.push(LogEntry);

  { 4. Invoke target state enter hook }
  if Assigned(NextSt.OnEnterProc) then
  begin
    try
      NextSt.OnEnterProc(FContext, APayload);
    except
      on E: Exception do
        if FStrict then raise;
    end;
  end;

  { 5. Invoke global onTransition callback }
  if Assigned(FOnTransition) then
  begin
    try
      FOnTransition(Self, OldState, NewState, EvUpper, FContext, APayload);
    except
      on E: Exception do
        if FStrict then raise;
    end;
  end;

  { 6. Update reactive proxy to trigger UI reactivity }
  UpdateReactiveState;

  { 7. Notify registered external observers }
  NotifySubscribers(NewState, OldState, EvUpper);

  Result := True;
end;

procedure TBVStateMachine.Reset;
var
  TargetSt: TBVFSMState;
begin
  if FInitialState <> '' then
  begin
    FPreviousState := FCurrentState;
    FCurrentState := FInitialState;

    TargetSt := FindState(FCurrentState);
    if (TargetSt <> nil) and Assigned(TargetSt.OnEnterProc) then
      TargetSt.OnEnterProc(FContext, nil);

    UpdateReactiveState;
    NotifySubscribers(FCurrentState, FPreviousState, '@@RESET');
  end;
end;

procedure TBVStateMachine.UpdateReactiveState;
begin
  if FReactiveProxy <> nil then
  begin
    TJSObject(FReactiveProxy)['current'] := FCurrentState;
    TJSObject(FReactiveProxy)['previous'] := FPreviousState;
  end;
end;

function TBVStateMachine.Subscribe(ACallback: TBVFSMSubscriberProc): Integer;
var
  Wrapper: TJSObject;
begin
  Wrapper := TJSObject.new;
  Wrapper['id'] := Integer(FSubscribers.length) + 1;
  Wrapper['callback'] := ACallback;
  FSubscribers.push(Wrapper);
  Result := Integer(Wrapper['id']);
end;

procedure TBVStateMachine.Unsubscribe(AId: Integer);
var
  i: Integer;
  Item: TJSObject;
begin
  for i := Integer(FSubscribers.length) - 1 downto 0 do
  begin
    Item := TJSObject(FSubscribers[i]);
    if Integer(Item['id']) = AId then
    begin
      FSubscribers.splice(i, 1);
      Break;
    end;
  end;
end;

procedure TBVStateMachine.NotifySubscribers(const NewState, OldState, EventName: string);
var
  i: Integer;
  Item: TJSObject;
  Cb: TBVFSMSubscriberProc;
begin
  for i := 0 to Integer(FSubscribers.length) - 1 do
  begin
    Item := TJSObject(FSubscribers[i]);
    Cb := TBVFSMSubscriberProc(Item['callback']);
    if Assigned(Cb) then
    begin
      try
        Cb(Self, NewState, OldState, EventName, FContext);
      except
        // Prevent observer exceptions from interrupting core state machine
      end;
    end;
  end;
end;

function TBVStateMachine.GetHistoryCount: Integer;
begin
  Result := Integer(FHistory.length);
end;

function TBVStateMachine.GetHistoryItem(Index: Integer): JSValue;
begin
  if (Index >= 0) and (Index < Integer(FHistory.length)) then
    Result := FHistory[Index]
  else
    Result := nil;
end;

end.
