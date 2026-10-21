unit BVDataSet;

{
  BVDataSet - Reactive In-Memory Dataset (LiveBindings & TClientDataSet)
  ---------------------------------------------------------------------
  Implements an enterprise-grade reactive dataset for Object Pascal,
  providing classic Delphi/Lazarus data-aware semantics:
  - Navigation: First, Next, Prior, Last, RecNo, RecordCount, Bof, Eof
  - States: dsInactive, dsBrowse, dsEdit, dsInsert
  - Editing: Append, Insert, Edit, Post, Cancel, Delete, Locate
  - Strongly typed field access: FieldByName('Name').AsString, AsInteger, etc.
  - Filtering & Sorting: SetFilter, ClearFilter, SortBy
  - Offline Delta Tracking: ChangeCount, GetDeltaJSON, ApplyUpdates
  - Local Storage persistence: SaveToStorage, LoadFromStorage
}

{$mode objfpc}

interface

uses
  JS, Web, SysUtils, Classes, BVReactivity;

type
  TBVDataSet = class;

  TDataSetState = (dsInactive, dsBrowse, dsEdit, dsInsert);
  TFieldType = (ftUnknown, ftString, ftInteger, ftFloat, ftBoolean, ftDate, ftDateTime);

  { TBVField: Represents a single column / field in a dataset }
  TBVField = class
  private
    FDataSet: TBVDataSet;
    FFieldName: string;
    FFieldType: TFieldType;
    FRequired: Boolean;
    function GetValue: JSValue;
    procedure SetValue(AValue: JSValue);
    function GetAsString: string;
    procedure SetAsString(const AValue: string);
    function GetAsInteger: Integer;
    procedure SetAsInteger(AValue: Integer);
    function GetAsFloat: Double;
    procedure SetAsFloat(AValue: Double);
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(AValue: Boolean);
    function GetIsNull: Boolean;
  public
    constructor Create(ADataSet: TBVDataSet; const AName: string; AType: TFieldType = ftString);
    property FieldName: string read FFieldName;
    property FieldType: TFieldType read FFieldType write FFieldType;
    property Required: Boolean read FRequired write FRequired;
    property Value: JSValue read GetValue write SetValue;
    property AsString: string read GetAsString write SetAsString;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property IsNull: Boolean read GetIsNull;
    property DataSet: TBVDataSet read FDataSet;
  end;

  { TBVFields: Collection of fields in a dataset }
  TBVFields = class
  private
    FDataSet: TBVDataSet;
    FItems: TJSArray;
  public
    constructor Create(ADataSet: TBVDataSet);
    function Count: Integer;
    function FieldByName(const AName: string): TBVField;
    function FindField(const AName: string): TBVField;
    function Add(AField: TBVField): TBVField;
    function AddField(const AName: string; AType: TFieldType = ftString): TBVField;
    function Item(AIndex: Integer): TBVField;
    procedure Clear;
    function ToArray: TJSArray;
  end;

  TDataSetNotifyEvent = procedure(DataSet: TBVDataSet) of object;

  { TBVDataSet: The Reactive In-Memory Dataset / TClientDataSet for BlaiseVue }
  TBVDataSet = class
  private
    FFields: TBVFields;
    FRecords: TJSArray;
    FActiveRecords: TJSArray;
    FRecNo: Integer;
    FState: TDataSetState;
    FEditBuffer: TJSObject;
    FOriginalBuffer: TJSObject;
    FDelta: TJSArray;
    FFilter: string;
    FFiltered: Boolean;
    FSortField: string;
    FSortAscending: Boolean;
    FReactiveState: JSValue;

    FAfterScroll: TDataSetNotifyEvent;
    FBeforePost: TDataSetNotifyEvent;
    FAfterPost: TDataSetNotifyEvent;
    FBeforeDelete: TDataSetNotifyEvent;
    FAfterDelete: TDataSetNotifyEvent;

    procedure SyncReactiveState;
    procedure RebuildActiveRecords;
    function GetBof: Boolean;
    function GetEof: Boolean;
    function GetRecordCount: Integer;
    function GetIsEmpty: Boolean;
    function GetCurrent: JSValue;
    function GetStateStr: string;
    function GetChangeCount: Integer;
    function GetActiveRecord(Index0: Integer): TJSObject;
  public
    constructor Create;
    destructor Destroy; override;

    { Field Definitions }
    function FieldByName(const AName: string): TBVField;
    function FindField(const AName: string): TBVField;
    function AddField(const AName: string; AType: TFieldType = ftString): TBVField;

    { Navigation Methods }
    procedure First;
    procedure Prior;
    procedure Next;
    procedure Last;
    procedure MoveBy(Distance: Integer);

    { Editing & State Operations }
    procedure Append;
    procedure Insert;
    procedure Edit;
    procedure Post;
    procedure Cancel;
    procedure Delete;
    procedure EmptyTable;

    { Filtering & Sorting }
    procedure SetFilter(const AQuery: string);
    procedure ClearFilter;
    procedure SortBy(const AFieldName: string; Ascending: Boolean = True);
    function Locate(const AFieldName: string; AValue: JSValue): Boolean;

    { Data Ingestion & Serialization }
    procedure LoadFromData(AData: JSValue);
    procedure LoadFromJSON(const AJsonStr: string);
    function ToJSON: string;
    function GetDeltaJSON: string;
    procedure ApplyUpdates;

    { Local Storage / Offline Caching }
    procedure SaveToStorage(const AStorageKey: string);
    function LoadFromStorage(const AStorageKey: string): Boolean;

    { Properties }
    property Fields: TBVFields read FFields;
    property State: TDataSetState read FState;
    property StateStr: string read GetStateStr;
    property RecNo: Integer read FRecNo write FRecNo;
    property RecordCount: Integer read GetRecordCount;
    property Bof: Boolean read GetBof;
    property Eof: Boolean read GetEof;
    property IsEmpty: Boolean read GetIsEmpty;
    property Current: JSValue read GetCurrent;
    property Data: TJSArray read FActiveRecords;
    property ChangeCount: Integer read GetChangeCount;
    property Filter: string read FFilter write SetFilter;
    property Filtered: Boolean read FFiltered;

    { Events }
    property AfterScroll: TDataSetNotifyEvent read FAfterScroll write FAfterScroll;
    property BeforePost: TDataSetNotifyEvent read FBeforePost write FBeforePost;
    property AfterPost: TDataSetNotifyEvent read FAfterPost write FAfterPost;
    property BeforeDelete: TDataSetNotifyEvent read FBeforeDelete write FBeforeDelete;
    property AfterDelete: TDataSetNotifyEvent read FAfterDelete write FAfterDelete;
  end;

function CreateDataSet: TBVDataSet;

implementation

{ Factory function }
function CreateDataSet: TBVDataSet;
begin
  Result := TBVDataSet.Create;
end;

{ ============================================================================ }
{ TBVField Implementation                                                      }
{ ============================================================================ }

constructor TBVField.Create(ADataSet: TBVDataSet; const AName: string; AType: TFieldType);
begin
  inherited Create;
  FDataSet := ADataSet;
  FFieldName := AName;
  FFieldType := AType;
  FRequired := False;

  asm
    var self = this;
    Object.defineProperty(self, 'AsString', {
      get: function() { return self.GetAsString(); },
      set: function(v) { self.SetAsString(v); },
      configurable: true
    });
    Object.defineProperty(self, 'Value', {
      get: function() { return self.GetValue(); },
      set: function(v) { self.SetValue(v); },
      configurable: true
    });
    Object.defineProperty(self, 'AsInteger', {
      get: function() { return self.GetAsInteger(); },
      set: function(v) { self.SetAsInteger(v); },
      configurable: true
    });
    Object.defineProperty(self, 'AsFloat', {
      get: function() { return self.GetAsFloat(); },
      set: function(v) { self.SetAsFloat(v); },
      configurable: true
    });
    Object.defineProperty(self, 'AsBoolean', {
      get: function() { return self.GetAsBoolean(); },
      set: function(v) { self.SetAsBoolean(v); },
      configurable: true
    });
  end;
end;

function TBVField.GetValue: JSValue;
var
  cur: TJSObject;
begin
  if not Assigned(FDataSet) then Exit(nil);

  if (FDataSet.State in [dsEdit, dsInsert]) and Assigned(FDataSet.FEditBuffer) then
  begin
    Result := FDataSet.FEditBuffer[FFieldName];
    Exit;
  end;

  cur := TJSObject(FDataSet.Current);
  if Assigned(cur) and (cur[FFieldName] <> undefined) then
    Result := cur[FFieldName]
  else
    Result := nil;
end;

procedure TBVField.SetValue(AValue: JSValue);
begin
  if not Assigned(FDataSet) then Exit;

  if FDataSet.State = dsBrowse then
    FDataSet.Edit;

  if (FDataSet.State in [dsEdit, dsInsert]) and Assigned(FDataSet.FEditBuffer) then
  begin
    FDataSet.FEditBuffer[FFieldName] := AValue;
    FDataSet.SyncReactiveState;
  end;
end;

function TBVField.GetAsString: string;
var
  v: JSValue;
begin
  v := GetValue;
  if (v = nil) or (v = undefined) then
    Result := ''
  else
    Result := String(v);
end;

procedure TBVField.SetAsString(const AValue: string);
begin
  SetValue(AValue);
end;

function TBVField.GetAsInteger: Integer;
var
  v: JSValue;
  n: Integer;
begin
  v := GetValue;
  if (v = nil) or (v = undefined) then Exit(0);
  asm
    var parsed = parseInt(v, 10);
    n = isNaN(parsed) ? 0 : parsed;
  end;
  Result := n;
end;

procedure TBVField.SetAsInteger(AValue: Integer);
begin
  SetValue(AValue);
end;

function TBVField.GetAsFloat: Double;
var
  v: JSValue;
  d: Double;
begin
  v := GetValue;
  if (v = nil) or (v = undefined) then Exit(0.0);
  asm
    var parsed = parseFloat(v);
    d = isNaN(parsed) ? 0.0 : parsed;
  end;
  Result := d;
end;

procedure TBVField.SetAsFloat(AValue: Double);
begin
  SetValue(AValue);
end;

function TBVField.GetAsBoolean: Boolean;
var
  v: JSValue;
begin
  v := GetValue;
  if (v = nil) or (v = undefined) then Exit(False);
  asm
    Result = Boolean(v === true || v === 'true' || v === 1 || v === '1');
  end;
end;

procedure TBVField.SetAsBoolean(AValue: Boolean);
begin
  SetValue(AValue);
end;

function TBVField.GetIsNull: Boolean;
var
  v: JSValue;
begin
  v := GetValue;
  Result := (v = nil) or (v = undefined) or (String(v) = '');
end;

{ ============================================================================ }
{ TBVFields Implementation                                                     }
{ ============================================================================ }

constructor TBVFields.Create(ADataSet: TBVDataSet);
begin
  inherited Create;
  FDataSet := ADataSet;
  FItems := TJSArray.new;
end;

function TBVFields.Count: Integer;
begin
  Result := FItems.length;
end;

function TBVFields.FieldByName(const AName: string): TBVField;
var
  f: TBVField;
begin
  f := FindField(AName);
  if not Assigned(f) then
    f := AddField(AName, ftString);
  Result := f;
end;

function TBVFields.FindField(const AName: string): TBVField;
var
  i: Integer;
  target: string;
  f: TBVField;
begin
  target := LowerCase(Trim(AName));
  for i := 0 to FItems.length - 1 do
  begin
    f := TBVField(FItems[i]);
    if LowerCase(f.FieldName) = target then
      Exit(f);
  end;
  Result := nil;
end;

function TBVFields.Add(AField: TBVField): TBVField;
begin
  FItems.push(AField);
  Result := AField;
end;

function TBVFields.AddField(const AName: string; AType: TFieldType): TBVField;
var
  f: TBVField;
begin
  f := FindField(AName);
  if Assigned(f) then
  begin
    f.FieldType := AType;
    Exit(f);
  end;
  f := TBVField.Create(FDataSet, AName, AType);
  FItems.push(f);
  Result := f;
end;

function TBVFields.Item(AIndex: Integer): TBVField;
begin
  if (AIndex >= 0) and (AIndex < FItems.length) then
    Result := TBVField(FItems[AIndex])
  else
    Result := nil;
end;

procedure TBVFields.Clear;
begin
  FItems.length := 0;
end;

function TBVFields.ToArray: TJSArray;
var
  i: Integer;
  arr: TJSArray;
  f: TBVField;
  itemObj: TJSObject;
begin
  arr := TJSArray.new;
  for i := 0 to FItems.length - 1 do
  begin
    f := TBVField(FItems[i]);
    itemObj := TJSObject.new;
    itemObj['key'] := f.FieldName;
    itemObj['label'] := f.FieldName;
    arr.push(itemObj);
  end;
  Result := arr;
end;

{ ============================================================================ }
{ TBVDataSet Implementation                                                    }
{ ============================================================================ }

constructor TBVDataSet.Create;
begin
  inherited Create;
  FFields := TBVFields.Create(Self);
  FRecords := TJSArray.new;
  FActiveRecords := TJSArray.new;
  FDelta := TJSArray.new;
  FRecNo := 0;
  FState := dsInactive;
  FEditBuffer := nil;
  FOriginalBuffer := nil;
  FFilter := '';
  FFiltered := False;
  FSortField := '';
  FSortAscending := True;

  { Initialize reactive state holder }
  FReactiveState := DefineReactive(TJSObject.new);
  SyncReactiveState;

  asm
    var self = this;
    Object.defineProperty(self, 'Current', { get: function() { return self.GetCurrent(); } });
    Object.defineProperty(self, 'Data', { get: function() { return self.FActiveRecords; } });
    Object.defineProperty(self, 'StateStr', { get: function() { return self.GetStateStr(); } });
    Object.defineProperty(self, 'RecNo', { get: function() { return self.FRecNo; }, set: function(v) { self.FRecNo = v; self.SyncReactiveState(); } });
    Object.defineProperty(self, 'RecordCount', { get: function() { return self.GetRecordCount(); } });
    Object.defineProperty(self, 'Bof', { get: function() { return self.GetBof(); } });
    Object.defineProperty(self, 'Eof', { get: function() { return self.GetEof(); } });
    Object.defineProperty(self, 'ChangeCount', { get: function() { return self.GetChangeCount(); } });
  end;
end;

destructor TBVDataSet.Destroy;
begin
  FFields.Free;
  inherited Destroy;
end;

function TBVDataSet.GetActiveRecord(Index0: Integer): TJSObject;
begin
  if (Index0 >= 0) and (Index0 < FActiveRecords.length) then
    Result := TJSObject(FActiveRecords[Index0])
  else
    Result := nil;
end;

procedure TBVDataSet.SyncReactiveState;
var
  rs: TJSObject;
  curObj: TJSObject;
begin
  rs := TJSObject(FReactiveState);
  if not Assigned(rs) then Exit;

  rs['stateStr'] := GetStateStr;
  rs['recNo'] := FRecNo;
  rs['recordCount'] := GetRecordCount;
  rs['bof'] := GetBof;
  rs['eof'] := GetEof;
  rs['isEmpty'] := GetIsEmpty;
  rs['changeCount'] := FDelta.length;

  if (FState in [dsEdit, dsInsert]) and Assigned(FEditBuffer) then
    rs['current'] := FEditBuffer
  else
  begin
    curObj := GetActiveRecord(FRecNo - 1);
    rs['current'] := curObj;
  end;
end;

procedure TBVDataSet.RebuildActiveRecords;
var
  q: string;
  arr: TJSArray;
  sortK: string;
  isAsc: Boolean;
begin
  q := LowerCase(Trim(FFilter));
  arr := TJSArray.new;

  asm
    var src = this.FRecords || [];
    var filtered = [];
    var hasQuery = Boolean(q && q.length > 0);

    for (var i = 0; i < src.length; i++) {
      var item = src[i];
      if (!item) continue;
      if (!hasQuery) {
        filtered.push(item);
      } else {
        var match = false;
        var vals = Object.values(item);
        for (var j = 0; j < vals.length; j++) {
          if (String(vals[j]).toLowerCase().indexOf(q) !== -1) {
            match = true;
            break;
          }
        }
        if (match) filtered.push(item);
      }
    }

    var sk = this.FSortField;
    var asc = this.FSortAscending;
    if (sk) {
      filtered.sort(function(a, b) {
        var va = (a && a[sk] !== undefined) ? a[sk] : '';
        var vb = (b && b[sk] !== undefined) ? b[sk] : '';
        if (typeof va === 'number' && typeof vb === 'number') {
          return asc ? (va - vb) : (vb - va);
        }
        var sa = String(va).toLowerCase();
        var sb = String(vb).toLowerCase();
        if (sa < sb) return asc ? -1 : 1;
        if (sa > sb) return asc ? 1 : -1;
        return 0;
      });
    }

    arr = filtered;
  end;

  FActiveRecords := arr;

  if FActiveRecords.length = 0 then
    FRecNo := 0
  else if FRecNo > FActiveRecords.length then
    FRecNo := FActiveRecords.length
  else if FRecNo < 1 then
    FRecNo := 1;

  SyncReactiveState;
end;

function TBVDataSet.GetBof: Boolean;
begin
  Result := (FRecNo <= 1);
end;

function TBVDataSet.GetEof: Boolean;
begin
  Result := (FRecNo >= FActiveRecords.length);
end;

function TBVDataSet.GetRecordCount: Integer;
begin
  Result := FActiveRecords.length;
end;

function TBVDataSet.GetIsEmpty: Boolean;
begin
  Result := (FActiveRecords.length = 0);
end;

function TBVDataSet.GetCurrent: JSValue;
begin
  if (FState in [dsEdit, dsInsert]) and Assigned(FEditBuffer) then
    Result := FEditBuffer
  else
    Result := GetActiveRecord(FRecNo - 1);
end;

function TBVDataSet.GetStateStr: string;
begin
  case FState of
    dsInactive: Result := 'inactive';
    dsBrowse:   Result := 'browse';
    dsEdit:     Result := 'edit';
    dsInsert:   Result := 'insert';
  else
    Result := 'inactive';
  end;
end;

function TBVDataSet.GetChangeCount: Integer;
begin
  Result := FDelta.length;
end;

function TBVDataSet.FieldByName(const AName: string): TBVField;
begin
  Result := FFields.FieldByName(AName);
end;

function TBVDataSet.FindField(const AName: string): TBVField;
begin
  Result := FFields.FindField(AName);
end;

function TBVDataSet.AddField(const AName: string; AType: TFieldType): TBVField;
begin
  Result := FFields.AddField(AName, AType);
end;

procedure TBVDataSet.First;
begin
  if (FState in [dsEdit, dsInsert]) then
    Post;

  if FActiveRecords.length > 0 then
    FRecNo := 1
  else
    FRecNo := 0;

  SyncReactiveState;
  if Assigned(FAfterScroll) then FAfterScroll(Self);
end;

procedure TBVDataSet.Prior;
begin
  if (FState in [dsEdit, dsInsert]) then
    Post;

  if FRecNo > 1 then
    Dec(FRecNo);

  SyncReactiveState;
  if Assigned(FAfterScroll) then FAfterScroll(Self);
end;

procedure TBVDataSet.Next;
begin
  if (FState in [dsEdit, dsInsert]) then
    Post;

  if FRecNo < FActiveRecords.length then
    Inc(FRecNo);

  SyncReactiveState;
  if Assigned(FAfterScroll) then FAfterScroll(Self);
end;

procedure TBVDataSet.Last;
begin
  if (FState in [dsEdit, dsInsert]) then
    Post;

  if FActiveRecords.length > 0 then
    FRecNo := FActiveRecords.length
  else
    FRecNo := 0;

  SyncReactiveState;
  if Assigned(FAfterScroll) then FAfterScroll(Self);
end;

procedure TBVDataSet.MoveBy(Distance: Integer);
var
  newPos: Integer;
begin
  if (FState in [dsEdit, dsInsert]) then
    Post;

  newPos := FRecNo + Distance;
  if newPos < 1 then newPos := 1;
  if newPos > FActiveRecords.length then newPos := FActiveRecords.length;
  FRecNo := newPos;

  SyncReactiveState;
  if Assigned(FAfterScroll) then FAfterScroll(Self);
end;

procedure TBVDataSet.Append;
var
  obj: TJSObject;
  i: Integer;
  f: TBVField;
begin
  if (FState in [dsEdit, dsInsert]) then
    Post;

  obj := TJSObject.new;
  for i := 0 to FFields.Count - 1 do
  begin
    f := FFields.Item(i);
    case f.FieldType of
      ftInteger: obj[f.FieldName] := 0;
      ftFloat:   obj[f.FieldName] := 0.0;
      ftBoolean: obj[f.FieldName] := False;
    else
      obj[f.FieldName] := '';
    end;
  end;

  FEditBuffer := obj;
  FOriginalBuffer := nil;
  FState := dsInsert;
  SyncReactiveState;
end;

procedure TBVDataSet.Insert;
begin
  Append;
end;

procedure TBVDataSet.Edit;
var
  cur: TJSObject;
  clone: TJSObject;
begin
  if FState in [dsEdit, dsInsert] then Exit;
  if GetIsEmpty then
  begin
    Append;
    Exit;
  end;

  cur := GetActiveRecord(FRecNo - 1);
  if not Assigned(cur) then Exit;

  clone := TJSObject.new;
  asm
    Object.assign(clone, cur);
  end;

  FEditBuffer := clone;
  FOriginalBuffer := cur;
  FState := dsEdit;
  SyncReactiveState;
end;

procedure TBVDataSet.Post;
var
  deltaItem: TJSObject;
  targetIdx: Integer;
  curRec: TJSObject;
begin
  if not (FState in [dsEdit, dsInsert]) then Exit;

  if Assigned(FBeforePost) then FBeforePost(Self);

  deltaItem := TJSObject.new;

  if FState = dsInsert then
  begin
    { Auto-assign id if missing and field exists }
    asm
      if (!this.FEditBuffer.id) {
        var maxId = 0;
        for (var i = 0; i < this.FRecords.length; i++) {
          var rid = parseInt(this.FRecords[i].id, 10);
          if (!isNaN(rid) && rid > maxId) maxId = rid;
        }
        this.FEditBuffer.id = maxId + 1;
      }
    end;

    FRecords.push(FEditBuffer);
    deltaItem['action'] := 'insert';
    deltaItem['record'] := FEditBuffer;
    FDelta.push(deltaItem);

    RebuildActiveRecords;
    FRecNo := FActiveRecords.length;
  end
  else if FState = dsEdit then
  begin
    curRec := GetActiveRecord(FRecNo - 1);
    targetIdx := FRecords.indexOf(curRec);

    if targetIdx <> -1 then
      FRecords[targetIdx] := FEditBuffer;

    deltaItem['action'] := 'update';
    deltaItem['oldRecord'] := FOriginalBuffer;
    deltaItem['record'] := FEditBuffer;
    FDelta.push(deltaItem);

    RebuildActiveRecords;
  end;

  FEditBuffer := nil;
  FOriginalBuffer := nil;
  FState := dsBrowse;
  SyncReactiveState;

  if Assigned(FAfterPost) then FAfterPost(Self);
end;

procedure TBVDataSet.Cancel;
begin
  if not (FState in [dsEdit, dsInsert]) then Exit;

  FEditBuffer := nil;
  FOriginalBuffer := nil;
  FState := dsBrowse;
  SyncReactiveState;
end;

procedure TBVDataSet.Delete;
var
  curRec: TJSObject;
  targetIdx: Integer;
  deltaItem: TJSObject;
begin
  if GetIsEmpty then Exit;

  if Assigned(FBeforeDelete) then FBeforeDelete(Self);

  curRec := GetActiveRecord(FRecNo - 1);
  if not Assigned(curRec) then Exit;

  targetIdx := FRecords.indexOf(curRec);
  if targetIdx <> -1 then
    FRecords.splice(targetIdx, 1);

  deltaItem := TJSObject.new;
  deltaItem['action'] := 'delete';
  deltaItem['record'] := curRec;
  FDelta.push(deltaItem);

  RebuildActiveRecords;

  if FRecNo > FActiveRecords.length then
    FRecNo := FActiveRecords.length;
  if (FRecNo = 0) and (FActiveRecords.length > 0) then
    FRecNo := 1;

  FState := dsBrowse;
  SyncReactiveState;

  if Assigned(FAfterDelete) then FAfterDelete(Self);
end;

procedure TBVDataSet.EmptyTable;
begin
  FRecords.length := 0;
  FActiveRecords.length := 0;
  FDelta.length := 0;
  FRecNo := 0;
  FState := dsBrowse;
  FEditBuffer := nil;
  FOriginalBuffer := nil;
  SyncReactiveState;
end;

procedure TBVDataSet.SetFilter(const AQuery: string);
begin
  FFilter := AQuery;
  FFiltered := (Trim(AQuery) <> '');
  RebuildActiveRecords;
  First;
end;

procedure TBVDataSet.ClearFilter;
begin
  SetFilter('');
end;

procedure TBVDataSet.SortBy(const AFieldName: string; Ascending: Boolean);
begin
  FSortField := AFieldName;
  FSortAscending := Ascending;
  RebuildActiveRecords;
  First;
end;

function TBVDataSet.Locate(const AFieldName: string; AValue: JSValue): Boolean;
var
  i: Integer;
  targetVal: string;
  itemVal: string;
  item: TJSObject;
begin
  targetVal := String(AValue);
  for i := 0 to FActiveRecords.length - 1 do
  begin
    item := TJSObject(FActiveRecords[i]);
    if Assigned(item) and (item[AFieldName] <> undefined) then
    begin
      itemVal := String(item[AFieldName]);
      if itemVal = targetVal then
      begin
        FRecNo := i + 1;
        SyncReactiveState;
        if Assigned(FAfterScroll) then FAfterScroll(Self);
        Exit(True);
      end;
    end;
  end;
  Result := False;
end;

procedure TBVDataSet.LoadFromData(AData: JSValue);
var
  arr: TJSArray;
  firstObj: TJSObject;
  keys: TJSArray;
  i: Integer;
begin
  if not Assigned(AData) then Exit;

  asm
    arr = Array.isArray(AData) ? AData : ((AData && Array.isArray(AData.items)) ? AData.items : [AData]);
  end;

  FRecords := TJSArray.new;
  asm
    for (var i = 0; i < arr.length; i++) {
      this.FRecords.push(Object.assign({}, arr[i]));
    }
  end;

  { Auto-register fields if none are explicitly declared }
  if (FFields.Count = 0) and (FRecords.length > 0) then
  begin
    firstObj := TJSObject(FRecords[0]);
    asm
      keys = Object.keys(firstObj);
    end;
    for i := 0 to keys.length - 1 do
      FFields.AddField(String(keys[i]), ftString);
  end;

  FState := dsBrowse;
  RebuildActiveRecords;
  First;
end;

procedure TBVDataSet.LoadFromJSON(const AJsonStr: string);
var
  parsed: JSValue;
begin
  if Trim(AJsonStr) = '' then Exit;
  asm
    try {
      parsed = JSON.parse(AJsonStr);
    } catch(e) {
      parsed = [];
    }
  end;
  LoadFromData(parsed);
end;

function TBVDataSet.ToJSON: string;
begin
  asm
    Result = JSON.stringify(this.FRecords || []);
  end;
end;

function TBVDataSet.GetDeltaJSON: string;
begin
  asm
    Result = JSON.stringify(this.FDelta || []);
  end;
end;

procedure TBVDataSet.ApplyUpdates;
begin
  FDelta.length := 0;
  SyncReactiveState;
end;

procedure TBVDataSet.SaveToStorage(const AStorageKey: string);
var
  json: string;
begin
  if Trim(AStorageKey) = '' then Exit;
  json := ToJSON;
  asm
    try {
      if (typeof window !== 'undefined' && window.localStorage) {
        window.localStorage.setItem(AStorageKey, json);
      }
    } catch(e) {
      console.warn('[BVDataSet] Failed to save to storage:', e);
    }
  end;
end;

function TBVDataSet.LoadFromStorage(const AStorageKey: string): Boolean;
var
  json: string;
  found: Boolean;
begin
  if Trim(AStorageKey) = '' then Exit(False);
  found := False;
  asm
    try {
      if (typeof window !== 'undefined' && window.localStorage) {
        var val = window.localStorage.getItem(AStorageKey);
        if (val) {
          json = val;
          found = true;
        }
      }
    } catch(e) {
      found = false;
    }
  end;

  if found then
  begin
    LoadFromJSON(json);
    Result := True;
  end
  else
    Result := False;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    window.__BV_CORE__.dataset = {
      TBVDataSet: pas.BVDataSet ? pas.BVDataSet.TBVDataSet : null,
      TBVField: pas.BVDataSet ? pas.BVDataSet.TBVField : null,
      CreateDataSet: pas.BVDataSet ? pas.BVDataSet.CreateDataSet : null
    };
  end;

end.
