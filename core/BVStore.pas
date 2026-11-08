unit BVStore;

{
  BVStore - BlaiseX Advanced Global State Management (TBVStore 2.0)
  -------------------------------------------------------------------
  Enterprise-grade reactive state management for BlaiseVue 5.0 (Pillar 1).
  Inspired by Pinia, Redux Toolkit, and Vuex, written in pure Object Pascal.

  Features:
  - Backward compatibility with lightweight v4.x single-store ($store.state)
  - Modular Slices & Namespaces: Define isolated stores (DefineStore / DefineSlice)
  - Mutations (atomic synchronous state changes) & Actions (business logic / async)
  - Computed Getters with live reactive state bindings
  - Direct integration with Finite State Machines (BVFSM / AttachMachine)
  - Atomic State Patching (Patch) and Snapshot Restores (Reset)
  - Observer subscriptions for middleware, logging, and DevTools
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity, BVFSM;

type
  TBVStore = class;
  TBVStoreSlice = class;

  { Callback Signatures }
  TBVMutationProc = reference to procedure(AState: JSValue; APayload: JSValue);
  TBVActionProc = reference to function(AContext: JSValue; APayload: JSValue): JSValue;
  TBVGetterFunc = reference to function(AState: JSValue): JSValue;
  TBVStoreSubscriberProc = reference to procedure(Slice: TBVStoreSlice; const AMutation: string; AState: JSValue; APayload: JSValue);

  { Represents an isolated modular store slice (Pinia / Redux Toolkit style) }
  TBVStoreSlice = class
  private
    FStore: TBVStore;
    FName: string;
    FState: JSValue;            { Reactive proxy of current state }
    FInitialStateRaw: string;   { JSON string of initial state for Reset }
    FMutations: TJSObject;      { Registry of mutation procedures }
    FActions: TJSObject;         { Registry of action functions }
    FGetters: TJSObject;        { Registry of computed getter functions }
    FMachines: TJSObject;       { Registry of attached TBVStateMachine instances }
    FSubscribers: TJSArray;     { Array of TBVStoreSubscriberProc }
    function BuildActionContext: TJSObject;
  public
    constructor Create(AStore: TBVStore; const AName: string; AInitialState: JSValue);
    destructor Destroy; override;

    { Declarative Configuration }
    function Mutation(const AName: string; AProc: TBVMutationProc): TBVStoreSlice;
    function Action(const AName: string; AProc: TBVActionProc): TBVStoreSlice;
    function Getter(const AName: string; AFunc: TBVGetterFunc): TBVStoreSlice;
    function AttachMachine(const AName: string; AMachine: TBVStateMachine): TBVStoreSlice;

    { Execution & Queries }
    procedure Commit(const AMutationName: string; APayload: JSValue = nil);
    function Dispatch(const AActionName: string; APayload: JSValue = nil): JSValue; reintroduce;
    function Get(const AGetterName: string): JSValue;
    function FSM(const AMachineName: string): TBVStateMachine;

    { State Manipulation }
    procedure Patch(AChanges: JSValue);
    procedure Reset;

    { Observer Pattern }
    function Subscribe(ACallback: TBVStoreSubscriberProc): Integer;
    procedure Unsubscribe(AId: Integer);

    { Properties }
    property Name: string read FName;
    property State: JSValue read FState;
    property Store: TBVStore read FStore;
  end;

  { Root State Store Container }
  TBVStore = class
  private
    FState: JSValue;      { Legacy/Default root reactive state }
    FSlices: TJSObject;   { Map of named slices: Name -> TBVStoreSlice }
  public
    constructor Create(AInitialState: JSValue = nil);
    destructor Destroy; override;

    { Slice Management }
    function DefineSlice(const AName: string; AInitialState: JSValue): TBVStoreSlice;
    function Slice(const AName: string): TBVStoreSlice;
    function HasSlice(const AName: string): Boolean;

    { Global Namespaced Dispatches ('sliceName/mutation' or 'sliceName/action') }
    procedure Commit(const ATarget: string; APayload: JSValue = nil);
    function Dispatch(const ATarget: string; APayload: JSValue = nil): JSValue; reintroduce;

    property State: JSValue read FState; { Accessible default state for legacy bindings }
    property Slices: TJSObject read FSlices;
  end;

{ Factory functions }
function CreateStore(AInitialState: JSValue = nil): TBVStore;
function GetStore: TBVStore; overload;
function GetStore(const ASliceName: string): TBVStoreSlice; overload;
function DefineStore(const ASliceName: string; AInitialState: JSValue): TBVStoreSlice;

implementation

var
  GStore: TBVStore = nil;

{ ============================================================================ }
{ Helper JSON snapshot clone                                                   }
{ ============================================================================ }

function SnapshotToJSON(AObj: JSValue): string;
begin
  if AObj = nil then Exit('{}');
  asm
    try {
      return JSON.stringify(AObj);
    } catch(e) {
      return '{}';
    }
  end;
end;

function JSONToSnapshot(const AJson: string): JSValue;
begin
  asm
    try {
      return JSON.parse(AJson);
    } catch(e) {
      return {};
    }
  end;
end;

{ ============================================================================ }
{ TBVStoreSlice Implementation                                                 }
{ ============================================================================ }

constructor TBVStoreSlice.Create(AStore: TBVStore; const AName: string; AInitialState: JSValue);
var
  InitVal: JSValue;
begin
  inherited Create;
  FStore := AStore;
  FName := Trim(AName);
  FMutations := TJSObject.new;
  FActions := TJSObject.new;
  FGetters := TJSObject.new;
  FMachines := TJSObject.new;
  FSubscribers := TJSArray.new;

  if AInitialState <> nil then
    InitVal := AInitialState
  else
    InitVal := TJSObject.new;

  FInitialStateRaw := SnapshotToJSON(InitVal);
  FState := DefineReactive(InitVal);
end;

destructor TBVStoreSlice.Destroy;
begin
  inherited Destroy;
end;

function TBVStoreSlice.Mutation(const AName: string; AProc: TBVMutationProc): TBVStoreSlice;
begin
  FMutations[Trim(AName)] := AProc;
  Result := Self;
end;

function TBVStoreSlice.Action(const AName: string; AProc: TBVActionProc): TBVStoreSlice;
begin
  FActions[Trim(AName)] := AProc;
  Result := Self;
end;

function TBVStoreSlice.Getter(const AName: string; AFunc: TBVGetterFunc): TBVStoreSlice;
begin
  FGetters[Trim(AName)] := AFunc;
  Result := Self;
end;

function TBVStoreSlice.AttachMachine(const AName: string; AMachine: TBVStateMachine): TBVStoreSlice;
begin
  FMachines[Trim(AName)] := AMachine;
  Result := Self;
end;

function TBVStoreSlice.FSM(const AMachineName: string): TBVStateMachine;
var
  M: JSValue;
begin
  M := FMachines[Trim(AMachineName)];
  if M <> nil then
    Result := TBVStateMachine(M)
  else
    Result := nil;
end;

function TBVStoreSlice.BuildActionContext: TJSObject;
var
  Ctx: TJSObject;
  SelfSlice: TBVStoreSlice;
begin
  SelfSlice := Self;
  Ctx := TJSObject.new;
  Ctx['state'] := FState;
  Ctx['slice'] := Self;
  if FStore <> nil then
    Ctx['rootState'] := FStore.State
  else
    Ctx['rootState'] := FState;

  { Inject JS commit closure bound to this slice }
  asm
    Ctx.commit = function(mutName, payload) {
      SelfSlice.Commit(mutName, payload);
    };
    Ctx.dispatch = function(actName, payload) {
      return SelfSlice.Dispatch(actName, payload);
    };
  end;

  Result := Ctx;
end;

procedure TBVStoreSlice.Commit(const AMutationName: string; APayload: JSValue);
var
  CleanName: string;
  MutProc: TBVMutationProc;
  i: Integer;
  SubItem: TJSObject;
  SubCb: TBVStoreSubscriberProc;
begin
  CleanName := Trim(AMutationName);
  if not Boolean(FMutations.hasOwnProperty(CleanName)) then
    raise Exception.Create('[BlaiseX: ' + FName + '] Unknown mutation "' + CleanName + '".');

  MutProc := TBVMutationProc(FMutations[CleanName]);
  if Assigned(MutProc) then
    MutProc(FState, APayload);

  { Notify all slice observers }
  for i := 0 to Integer(FSubscribers.length) - 1 do
  begin
    SubItem := TJSObject(FSubscribers[i]);
    SubCb := TBVStoreSubscriberProc(SubItem['cb']);
    if Assigned(SubCb) then
    begin
      try
        SubCb(Self, CleanName, FState, APayload);
      except
        // Prevent observer faults from interrupting state flow
      end;
    end;
  end;
end;

function TBVStoreSlice.Dispatch(const AActionName: string; APayload: JSValue): JSValue;
var
  CleanName: string;
  ActProc: TBVActionProc;
  ActionCtx: TJSObject;
begin
  CleanName := Trim(AActionName);
  if not Boolean(FActions.hasOwnProperty(CleanName)) then
    raise Exception.Create('[BlaiseX: ' + FName + '] Unknown action "' + CleanName + '".');

  ActProc := TBVActionProc(FActions[CleanName]);
  ActionCtx := BuildActionContext;

  if Assigned(ActProc) then
    Result := ActProc(ActionCtx, APayload)
  else
    Result := nil;
end;

function TBVStoreSlice.Get(const AGetterName: string): JSValue;
var
  CleanName: string;
  GtrFunc: TBVGetterFunc;
begin
  CleanName := Trim(AGetterName);
  if not Boolean(FGetters.hasOwnProperty(CleanName)) then
    raise Exception.Create('[BlaiseX: ' + FName + '] Unknown getter "' + CleanName + '".');

  GtrFunc := TBVGetterFunc(FGetters[CleanName]);
  if Assigned(GtrFunc) then
    Result := GtrFunc(FState)
  else
    Result := nil;
end;

procedure TBVStoreSlice.Patch(AChanges: JSValue);
var
  Keys: TJSStringDynArray;
  i: Integer;
  K: string;
begin
  if (AChanges = nil) or (FState = nil) then Exit;
  Keys := TJSObject.keys(TJSObject(AChanges));
  for i := 0 to Length(Keys) - 1 do
  begin
    K := Keys[i];
    TJSObject(FState)[K] := TJSObject(AChanges)[K];
  end;
end;

procedure TBVStoreSlice.Reset;
var
  FreshState: JSValue;
begin
  FreshState := JSONToSnapshot(FInitialStateRaw);
  Patch(FreshState);
end;

function TBVStoreSlice.Subscribe(ACallback: TBVStoreSubscriberProc): Integer;
var
  Item: TJSObject;
begin
  Item := TJSObject.new;
  Item['id'] := Integer(FSubscribers.length) + 1;
  Item['cb'] := ACallback;
  FSubscribers.push(Item);
  Result := Integer(Item['id']);
end;

procedure TBVStoreSlice.Unsubscribe(AId: Integer);
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

{ ============================================================================ }
{ TBVStore Implementation                                                      }
{ ============================================================================ }

constructor TBVStore.Create(AInitialState: JSValue);
var
  InitVal: JSValue;
begin
  inherited Create;
  FSlices := TJSObject.new;

  if AInitialState <> nil then
    InitVal := AInitialState
  else
    InitVal := TJSObject.new;

  FState := DefineReactive(InitVal);
end;

destructor TBVStore.Destroy;
var
  Keys: TJSStringDynArray;
  i: Integer;
  SliceObj: TBVStoreSlice;
begin
  Keys := TJSObject.keys(FSlices);
  for i := 0 to Length(Keys) - 1 do
  begin
    SliceObj := TBVStoreSlice(FSlices[Keys[i]]);
    SliceObj.Free;
  end;
  inherited Destroy;
end;

function TBVStore.DefineSlice(const AName: string; AInitialState: JSValue): TBVStoreSlice;
var
  CleanName: string;
begin
  CleanName := Trim(AName);
  if Boolean(FSlices.hasOwnProperty(CleanName)) then
    raise Exception.Create('[BlaiseX] Slice "' + CleanName + '" is already registered.');

  Result := TBVStoreSlice.Create(Self, CleanName, AInitialState);
  FSlices[CleanName] := Result;

  { Mount slice state on root state for universal visibility }
  TJSObject(FState)[CleanName] := Result.State;
end;

function TBVStore.Slice(const AName: string): TBVStoreSlice;
var
  CleanName: string;
begin
  CleanName := Trim(AName);
  if Boolean(FSlices.hasOwnProperty(CleanName)) then
    Result := TBVStoreSlice(FSlices[CleanName])
  else
    Result := nil;
end;

function TBVStore.HasSlice(const AName: string): Boolean;
begin
  Result := Boolean(FSlices.hasOwnProperty(Trim(AName)));
end;

procedure TBVStore.Commit(const ATarget: string; APayload: JSValue);
var
  Idx: Integer;
  SliceName, MutName: string;
  Sl: TBVStoreSlice;
begin
  Idx := Pos('/', ATarget);
  if Idx <= 0 then
    raise Exception.Create('[BlaiseX] Commit requires "sliceName/mutationName" format, got "' + ATarget + '".');

  SliceName := Trim(Copy(ATarget, 1, Idx - 1));
  MutName := Trim(Copy(ATarget, Idx + 1, Length(ATarget)));
  Sl := Slice(SliceName);
  if Sl = nil then
    raise Exception.Create('[BlaiseX] Unknown store slice "' + SliceName + '".');

  Sl.Commit(MutName, APayload);
end;

function TBVStore.Dispatch(const ATarget: string; APayload: JSValue): JSValue;
var
  Idx: Integer;
  SliceName, ActName: string;
  Sl: TBVStoreSlice;
begin
  Idx := Pos('/', ATarget);
  if Idx <= 0 then
    raise Exception.Create('[BlaiseX] Dispatch requires "sliceName/actionName" format, got "' + ATarget + '".');

  SliceName := Trim(Copy(ATarget, 1, Idx - 1));
  ActName := Trim(Copy(ATarget, Idx + 1, Length(ATarget)));
  Sl := Slice(SliceName);
  if Sl = nil then
    raise Exception.Create('[BlaiseX] Unknown store slice "' + SliceName + '".');

  Result := Sl.Dispatch(ActName, APayload);
end;

{ ============================================================================ }
{ Factory Helper Functions                                                     }
{ ============================================================================ }

function CreateStore(AInitialState: JSValue): TBVStore;
begin
  if not Assigned(GStore) then
    GStore := TBVStore.Create(AInitialState)
  else if AInitialState <> nil then
  begin
    GStore.Free;
    GStore := TBVStore.Create(AInitialState);
  end;
  Result := GStore;
end;

function GetStore: TBVStore;
begin
  if not Assigned(GStore) then
    GStore := TBVStore.Create(TJSObject.new);
  Result := GStore;
end;

function GetStore(const ASliceName: string): TBVStoreSlice;
begin
  Result := GetStore.Slice(ASliceName);
end;

function DefineStore(const ASliceName: string; AInitialState: JSValue): TBVStoreSlice;
begin
  Result := GetStore.DefineSlice(ASliceName, AInitialState);
end;

initialization
  if not Assigned(GStore) then
    GStore := TBVStore.Create(TJSObject.new);

  { Register BlaiseX store in global browser window anchor }
  if (JS.isObject(window)) then
  begin
    TJSObject(window)['__BV_PRO_STORE__'] := GStore.State;
    TJSObject(window)['__BLAISEX_STORE__'] := GStore;
  end;

end.
