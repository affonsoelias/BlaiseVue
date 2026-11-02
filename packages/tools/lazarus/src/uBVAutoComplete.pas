unit uBVAutoComplete;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, LCLProc, LCLType,
  SrcEditorIntf;

type
  { TBVSrcEditCompletion }
  TBVSrcEditCompletion = class(TSourceEditorCompletionPlugin)
  private
    FEditor: TSourceEditorInterface;
    FFilteredList: TStrings;
    FLastPrefix: string;
    FList: TStrings;
    procedure SetLastPrefix(const AValue: string);
    procedure RebuildFilteredList;
    procedure PopulateItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Cancel; override;
    function Collect(List: TStrings): boolean; override;
    procedure Complete(var Value: string; SourceValue: string; var SourceStart,
      SourceEnd: TPoint; KeyChar: TUTF8Char; Shift: TShiftState); override;
    procedure CompletePrefix(var Prefix: string); override;
    procedure IndexChanged(Position: integer); override;
    procedure Init(SrcEdit: TSourceEditorInterface; JumpToError: boolean;
      var Handled, Abort: boolean; var Prefix: string; var BoxX, BoxY: integer
      ); override;
    procedure PrefixChanged(const NewPrefix: string; var NewIndex: integer;
      var s: TStrings); override;
    property LastPrefix: string read FLastPrefix write SetLastPrefix;
  end;

procedure RegisterBVCompletionPlugin;
procedure UnregisterBVCompletionPlugin;

implementation

var
  gBVCompletionPlugin: TBVSrcEditCompletion = nil;

procedure RegisterBVCompletionPlugin;
begin
  if (SourceEditorManagerIntf <> nil) and (gBVCompletionPlugin = nil) then
  begin
    gBVCompletionPlugin := TBVSrcEditCompletion.Create(nil);
    SourceEditorManagerIntf.RegisterCompletionPlugin(gBVCompletionPlugin);
  end;
end;

procedure UnregisterBVCompletionPlugin;
begin
  if (SourceEditorManagerIntf <> nil) and (gBVCompletionPlugin <> nil) then
  begin
    SourceEditorManagerIntf.UnregisterCompletionPlugin(gBVCompletionPlugin);
    FreeAndNil(gBVCompletionPlugin);
  end;
end;

{ TBVSrcEditCompletion }

constructor TBVSrcEditCompletion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FList := TStringList.Create;
  FFilteredList := TStringList.Create;
  PopulateItems;
end;

destructor TBVSrcEditCompletion.Destroy;
begin
  if Self = gBVCompletionPlugin then
    gBVCompletionPlugin := nil;
  FreeAndNil(FFilteredList);
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TBVSrcEditCompletion.PopulateItems;
begin
  FList.Clear;

  // 1. Directives & Attributes
  FList.Add('b-model');
  FList.Add('b-for');
  FList.Add('b-if');
  FList.Add('b-else-if');
  FList.Add('b-else');
  FList.Add('b-show');
  FList.Add('b-validate');
  FList.Add('b-bind');
  FList.Add('b-on');
  FList.Add('@click');
  FList.Add('@input');
  FList.Add('@change');
  FList.Add('@submit');
  FList.Add('@keydown');
  FList.Add('@keyup');
  FList.Add('@blur');
  FList.Add('@focus');
  FList.Add(':class');
  FList.Add(':style');
  FList.Add(':key');
  FList.Add(':disabled');
  FList.Add(':value');
  FList.Add('v-model');
  FList.Add('v-for');
  FList.Add('v-if');
  FList.Add('v-show');

  // 2. BlaiseUI Components
  FList.Add('bv-alert');
  FList.Add('bv-avatar');
  FList.Add('bv-badge');
  FList.Add('bv-bar-chart');
  FList.Add('bv-breadcrumb');
  FList.Add('bv-btn');
  FList.Add('bv-btn-group');
  FList.Add('bv-card');
  FList.Add('bv-checkbox');
  FList.Add('bv-col');
  FList.Add('bv-container');
  FList.Add('bv-datagrid');
  FList.Add('bv-dialog');
  FList.Add('bv-divider');
  FList.Add('bv-doughnut-chart');
  FList.Add('bv-drawer');
  FList.Add('bv-dropdown');
  FList.Add('bv-form');
  FList.Add('bv-icon');
  FList.Add('bv-input');
  FList.Add('bv-line-chart');
  FList.Add('bv-link');
  FList.Add('bv-list');
  FList.Add('bv-list-item');
  FList.Add('bv-modal');
  FList.Add('bv-navbar');
  FList.Add('bv-pagination');
  FList.Add('bv-pie-chart');
  FList.Add('bv-progress');
  FList.Add('bv-radar-chart');
  FList.Add('bv-radio');
  FList.Add('bv-row');
  FList.Add('bv-select');
  FList.Add('bv-slider');
  FList.Add('bv-spinner');
  FList.Add('bv-switch');
  FList.Add('bv-tab');
  FList.Add('bv-tabs');
  FList.Add('bv-textarea');
  FList.Add('bv-toast');
  FList.Add('bv-tooltip');

  // 3. SFC Tags
  FList.Add('<template>');
  FList.Add('</template>');
  FList.Add('<script>');
  FList.Add('</script>');
  FList.Add('<style>');
  FList.Add('</style>');

  // 4. Component Options & Lifecycle
  FList.Add('props:');
  FList.Add('data:');
  FList.Add('computed:');
  FList.Add('watch:');
  FList.Add('methods:');
  FList.Add('created:');
  FList.Add('mounted:');
  FList.Add('updated:');
  FList.Add('unmounted:');
  FList.Add('provide:');
  FList.Add('inject:');
  FList.Add('routes:');

  // 5. Object Pascal Keywords & Runtime Helpers
  FList.Add('procedure');
  FList.Add('function');
  FList.Add('begin');
  FList.Add('end;');
  FList.Add('var');
  FList.Add('const');
  FList.Add('JSValue');
  FList.Add('TJSArray');
  FList.Add('TJSObject');
  FList.Add('TJSFunction');
  FList.Add('CallMethod');
  FList.Add('GetFieldStr');
  FList.Add('GetFieldInt');
  FList.Add('GetFieldBool');
  FList.Add('SetFieldStr');
  FList.Add('SetFieldInt');
  FList.Add('SetFieldBool');
  FList.Add('this');
  FList.Add('console.log');

  // 6. Global Plugins & Services
  FList.Add('$store');
  FList.Add('$router');
  FList.Add('$route');
  FList.Add('$i18n');
  FList.Add('$t');
  FList.Add('$theme');
  FList.Add('$errors');
  FList.Add('$v');
  FList.Add('$wasm');
  FList.Add('$mobile');
end;

procedure TBVSrcEditCompletion.SetLastPrefix(const AValue: string);
begin
  if FLastPrefix = AValue then Exit;
  FLastPrefix := AValue;
  RebuildFilteredList;
end;

procedure TBVSrcEditCompletion.RebuildFilteredList;
var
  i: Integer;
  s, LowPrefix, LowItem: string;
begin
  FFilteredList.Clear;
  LowPrefix := LowerCase(FLastPrefix);
  if LowPrefix = '' then
  begin
    FFilteredList.Assign(FList);
    Exit;
  end;

  for i := 0 to FList.Count - 1 do
  begin
    s := FList[i];
    LowItem := LowerCase(s);
    if (Pos(LowPrefix, LowItem) = 1) or
       ((Length(LowItem) > 1) and (LowItem[1] = '<') and (Pos(LowPrefix, Copy(LowItem, 2, Length(LowItem))) = 1)) or
       ((Length(LowItem) > 1) and (LowItem[1] in [':', '@', '$']) and (Pos(LowPrefix, Copy(LowItem, 2, Length(LowItem))) = 1)) or
       (Pos(LowPrefix, LowItem) > 0) then
    begin
      FFilteredList.Add(s);
    end;
  end;
end;

procedure TBVSrcEditCompletion.Cancel;
begin
  FEditor := nil;
  FFilteredList.Clear;
end;

function TBVSrcEditCompletion.Collect(List: TStrings): boolean;
begin
  List.Assign(FFilteredList);
  Result := True;
end;

procedure TBVSrcEditCompletion.Complete(var Value: string; SourceValue: string;
  var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char; Shift: TShiftState);
var
  Line: string;
  Idx: Integer;
begin
  if (FEditor <> nil) and (Value <> '') then
  begin
    try
      Line := FEditor.CurrentLineText;
      Idx := SourceStart.X - 1; // character immediately preceding token
      if (Idx >= 1) and (Idx <= Length(Line)) and (Length(Value) > 1) then
      begin
        if (Line[Idx] = Value[1]) and (Value[1] in ['@', ':', '<', '$']) then
          Dec(SourceStart.X);
      end;
    except
      // Keep defaults safely
    end;
  end;
end;

procedure TBVSrcEditCompletion.CompletePrefix(var Prefix: string);
begin
  LastPrefix := Prefix;
end;

procedure TBVSrcEditCompletion.IndexChanged(Position: integer);
begin
end;

procedure TBVSrcEditCompletion.Init(SrcEdit: TSourceEditorInterface;
  JumpToError: boolean; var Handled, Abort: boolean; var Prefix: string;
  var BoxX, BoxY: integer);
var
  Ext: string;
begin
  Abort := False;
  Handled := False;
  if SrcEdit = nil then Exit;
  Ext := LowerCase(ExtractFileExt(SrcEdit.FileName));

  if Ext <> '.bv' then Exit;

  Handled := True;
  FEditor := SrcEdit;
  FLastPrefix := Prefix;
  RebuildFilteredList;
end;

procedure TBVSrcEditCompletion.PrefixChanged(const NewPrefix: string;
  var NewIndex: integer; var s: TStrings);
begin
  NewIndex := 0;
  LastPrefix := NewPrefix;
  s.Assign(FFilteredList);
end;

initialization

finalization
  UnregisterBVCompletionPlugin;

end.