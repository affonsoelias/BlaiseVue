unit uBlaiseVueIDEReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls,
  SynEdit, SynEditHighlighter,
  SrcEditorIntf, LazIDEIntf,
  uBVSynMultiSyn, uBVFileDescriptor, uBVToolsMenu;

type
  { TBVIDEHook }
  TBVIDEHook = class(TComponent)
  private
    procedure OnEditorCreated(Sender: TObject);
    procedure OnEditorActivated(Sender: TObject);
    procedure ApplyBVHighlighter(AEditor: TSourceEditorInterface);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure Register;

implementation

var
  gBVHook: TBVIDEHook = nil;

{ TBVIDEHook }

constructor TBVIDEHook.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if SourceEditorManagerIntf <> nil then
  begin
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorCreate, @OnEditorCreated);
    SourceEditorManagerIntf.RegisterChangeEvent(semEditorActivate, @OnEditorActivated);
  end;
end;

destructor TBVIDEHook.Destroy;
begin
  if SourceEditorManagerIntf <> nil then
  begin
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorCreate, @OnEditorCreated);
    SourceEditorManagerIntf.UnRegisterChangeEvent(semEditorActivate, @OnEditorActivated);
  end;
  inherited Destroy;
end;

procedure TBVIDEHook.OnEditorCreated({%H-}Sender: TObject);
begin
  if SourceEditorManagerIntf <> nil then
    ApplyBVHighlighter(SourceEditorManagerIntf.ActiveEditor);
end;

procedure TBVIDEHook.OnEditorActivated({%H-}Sender: TObject);
begin
  if SourceEditorManagerIntf <> nil then
    ApplyBVHighlighter(SourceEditorManagerIntf.ActiveEditor);
end;

procedure TBVIDEHook.ApplyBVHighlighter(AEditor: TSourceEditorInterface);
var
  Ext: string;
begin
  if AEditor = nil then Exit;
  Ext := LowerCase(ExtractFileExt(AEditor.FileName));

  if Ext = '.bv' then
  begin
    GetBVSharedHighlighter.RefreshHighlighterSettings;
    if (AEditor.EditorControl is TCustomSynEdit) then
    begin
      if TCustomSynEdit(AEditor.EditorControl).Highlighter <> GetBVSharedHighlighter then
        TCustomSynEdit(AEditor.EditorControl).Highlighter := GetBVSharedHighlighter;
    end;
  end;
end;

procedure Register;
begin
  // 1. Register component on SynEdit Highlighters palette tab
  RegisterComponents('SynEdit Highlighters', [TBVSynMultiSyn]);

  // 2. Register File Descriptors for File -> New... dialog
  RegisterFileDescriptors;

  // 3. Register BlaiseVue IDE Tools menu items
  RegisterToolsMenu;

  // 4. Initialize global IDE editor change hook for automatic .bv highlighter assignment
  if gBVHook = nil then
    gBVHook := TBVIDEHook.Create(nil);
end;

initialization

finalization
  if Assigned(gBVHook) then
    FreeAndNil(gBVHook);

end.
