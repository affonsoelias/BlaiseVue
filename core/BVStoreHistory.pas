unit BVStoreHistory;

{
  BVStoreHistory - Time-Travel Debugging & State Snapshots (Pillar 1 Step 4)
  ----------------------------------------------------------------------------
  Provides historical state snapshot tracking, Undo/Redo capability,
  state travel, audit log exports, and browser DevTools integration for BlaiseX.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils;

type
  TBVStoreSnapshot = class
  public
    Index: Integer;
    Mutation: string;
    Payload: JSValue;
    Timestamp: Double;
    StateJSON: string;
    constructor Create(AIndex: Integer; const AMutation: string; APayload: JSValue; const AStateJSON: string);
  end;

  TBVStateRestoreProc = reference to procedure(const AStateJSON: string);

  TBVStoreHistory = class
  private
    FMaxSnapshots: Integer;
    FSnapshots: TJSArray; { Array of TBVStoreSnapshot }
    FCursor: Integer;     { Current snapshot index }
    FOnRestore: TBVStateRestoreProc;
    FIsRestoring: Boolean;
    FEnabled: Boolean;
    function GetCount: Integer;
    function GetSnapshot(Index: Integer): TBVStoreSnapshot;
  public
    constructor Create(AMaxSnapshots: Integer = 50; ARestoreProc: TBVStateRestoreProc = nil);
    destructor Destroy; override;

    { Snapshot recording }
    procedure RecordSnapshot(const AMutation: string; APayload: JSValue; const ACurrentStateJSON: string);

    { Time-travel controls }
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    function Undo: Boolean;
    function Redo: Boolean;
    function JumpTo(Index: Integer): Boolean;
    procedure Clear(const AInitialStateJSON: string = '{}');

    { Import / Export }
    function ExportJSON: string;
    function ImportJSON(const AJsonStr: string): Boolean;

    property MaxSnapshots: Integer read FMaxSnapshots write FMaxSnapshots;
    property Count: Integer read GetCount;
    property Cursor: Integer read FCursor;
    property Snapshots[Index: Integer]: TBVStoreSnapshot read GetSnapshot;
    property IsRestoring: Boolean read FIsRestoring;
    property Enabled: Boolean read FEnabled write FEnabled;
    property OnRestore: TBVStateRestoreProc read FOnRestore write FOnRestore;
  end;

implementation

{ ============================================================================ }
{ TBVStoreSnapshot                                                             }
{ ============================================================================ }

constructor TBVStoreSnapshot.Create(AIndex: Integer; const AMutation: string; APayload: JSValue; const AStateJSON: string);
begin
  inherited Create;
  Index := AIndex;
  Mutation := AMutation;
  Payload := APayload;
  Timestamp := TJSDate.now;
  StateJSON := AStateJSON;
end;

{ ============================================================================ }
{ TBVStoreHistory                                                              }
{ ============================================================================ }

constructor TBVStoreHistory.Create(AMaxSnapshots: Integer; ARestoreProc: TBVStateRestoreProc);
begin
  inherited Create;
  FMaxSnapshots := AMaxSnapshots;
  FSnapshots := TJSArray.new;
  FCursor := -1;
  FOnRestore := ARestoreProc;
  FIsRestoring := False;
  FEnabled := True;
end;

destructor TBVStoreHistory.Destroy;
var
  i: Integer;
  Sn: TBVStoreSnapshot;
begin
  for i := 0 to Integer(FSnapshots.length) - 1 do
  begin
    Sn := TBVStoreSnapshot(FSnapshots[i]);
    Sn.Free;
  end;
  inherited Destroy;
end;

function TBVStoreHistory.GetCount: Integer;
begin
  Result := Integer(FSnapshots.length);
end;

function TBVStoreHistory.GetSnapshot(Index: Integer): TBVStoreSnapshot;
begin
  if (Index >= 0) and (Index < Integer(FSnapshots.length)) then
    Result := TBVStoreSnapshot(FSnapshots[Index])
  else
    Result := nil;
end;

procedure TBVStoreHistory.RecordSnapshot(const AMutation: string; APayload: JSValue; const ACurrentStateJSON: string);
var
  Sn: TBVStoreSnapshot;
  i: Integer;
  OldSn: TBVStoreSnapshot;
begin
  if (not FEnabled) or FIsRestoring then Exit;

  { If we are in the middle of history after an Undo, prune future snapshots }
  if (FCursor >= 0) and (FCursor < Integer(FSnapshots.length) - 1) then
  begin
    for i := FCursor + 1 to Integer(FSnapshots.length) - 1 do
    begin
      OldSn := TBVStoreSnapshot(FSnapshots[i]);
      OldSn.Free;
    end;
    FSnapshots.splice(FCursor + 1, Integer(FSnapshots.length) - (FCursor + 1));
  end;

  { If buffer exceeds max capacity, drop oldest }
  if Integer(FSnapshots.length) >= FMaxSnapshots then
  begin
    OldSn := TBVStoreSnapshot(FSnapshots[0]);
    OldSn.Free;
    FSnapshots.splice(0, 1);
    if FCursor > 0 then
      Dec(FCursor);
  end;

  Sn := TBVStoreSnapshot.Create(Integer(FSnapshots.length), AMutation, APayload, ACurrentStateJSON);
  FSnapshots.push(Sn);
  FCursor := Integer(FSnapshots.length) - 1;
end;

function TBVStoreHistory.CanUndo: Boolean;
begin
  Result := (FCursor > 0);
end;

function TBVStoreHistory.CanRedo: Boolean;
begin
  Result := (FCursor >= 0) and (FCursor < Integer(FSnapshots.length) - 1);
end;

function TBVStoreHistory.Undo: Boolean;
begin
  if not CanUndo then Exit(False);
  Dec(FCursor);
  Result := JumpTo(FCursor);
end;

function TBVStoreHistory.Redo: Boolean;
begin
  if not CanRedo then Exit(False);
  Inc(FCursor);
  Result := JumpTo(FCursor);
end;

function TBVStoreHistory.JumpTo(Index: Integer): Boolean;
var
  TargetSn: TBVStoreSnapshot;
begin
  Result := False;
  if (Index < 0) or (Index >= Integer(FSnapshots.length)) then Exit;

  TargetSn := TBVStoreSnapshot(FSnapshots[Index]);
  if TargetSn = nil then Exit;

  FCursor := Index;

  if Assigned(FOnRestore) then
  begin
    FIsRestoring := True;
    try
      FOnRestore(TargetSn.StateJSON);
      Result := True;
    finally
      FIsRestoring := False;
    end;
  end;
end;

procedure TBVStoreHistory.Clear(const AInitialStateJSON: string);
var
  i: Integer;
  Sn: TBVStoreSnapshot;
begin
  for i := 0 to Integer(FSnapshots.length) - 1 do
  begin
    Sn := TBVStoreSnapshot(FSnapshots[i]);
    Sn.Free;
  end;
  FSnapshots := TJSArray.new;
  FCursor := -1;

  if AInitialStateJSON <> '' then
  begin
    Sn := TBVStoreSnapshot.Create(0, '@@INIT', nil, AInitialStateJSON);
    FSnapshots.push(Sn);
    FCursor := 0;
  end;
end;

function TBVStoreHistory.ExportJSON: string;
var
  Arr: TJSArray;
  i: Integer;
  Sn: TBVStoreSnapshot;
  Obj: TJSObject;
begin
  Arr := TJSArray.new;
  for i := 0 to Integer(FSnapshots.length) - 1 do
  begin
    Sn := TBVStoreSnapshot(FSnapshots[i]);
    Obj := TJSObject.new;
    Obj['index'] := Sn.Index;
    Obj['mutation'] := Sn.Mutation;
    Obj['payload'] := Sn.Payload;
    Obj['timestamp'] := Sn.Timestamp;
    Obj['stateJSON'] := Sn.StateJSON;
    Arr.push(Obj);
  end;

  asm
    try {
      Result = JSON.stringify({
        cursor: this.FCursor,
        count: Arr.length,
        snapshots: Arr
      }, null, 2);
    } catch(e) {
      Result = '{}';
    }
  end;
end;

function TBVStoreHistory.ImportJSON(const AJsonStr: string): Boolean;
var
  ParsedData, SnapsArr, ItemObj: TJSObject;
  i: Integer;
  Sn: TBVStoreSnapshot;
begin
  Result := False;
  asm
    try {
      ParsedData = JSON.parse(AJsonStr);
    } catch(e) {
      return false;
    }
  end;

  if (ParsedData = nil) or not Boolean(ParsedData.hasOwnProperty('snapshots')) then
    Exit(False);

  Clear('');
  SnapsArr := TJSObject(ParsedData['snapshots']);
  for i := 0 to Integer(TJSArray(SnapsArr).length) - 1 do
  begin
    ItemObj := TJSObject(TJSArray(SnapsArr)[i]);
    Sn := TBVStoreSnapshot.Create(
      Integer(ItemObj['index']),
      string(ItemObj['mutation']),
      ItemObj['payload'],
      string(ItemObj['stateJSON'])
    );
    Sn.Timestamp := Double(ItemObj['timestamp']);
    FSnapshots.push(Sn);
  end;

  if Boolean(ParsedData.hasOwnProperty('cursor')) then
    FCursor := Integer(ParsedData['cursor'])
  else
    FCursor := Integer(FSnapshots.length) - 1;

  if FCursor >= 0 then
    JumpTo(FCursor);

  Result := True;
end;

end.
