unit uBVToolsMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, Process,
  MenuIntf, SrcEditorIntf, IDEMsgIntf, IDEExternToolIntf, LazIDEIntf,
  SynEdit, SynCompletion,
  uBVFormatter, uBVAutoComplete;

type
  { TBVToolsManager }
  TBVToolsManager = class(TComponent)
  public
    procedure DoCheckActiveComponent(Sender: TObject);
    procedure DoFormatActiveComponent(Sender: TObject);
    procedure DoTriggerAutoComplete(Sender: TObject);
    procedure DoListSearchPaths(Sender: TObject);
    procedure DoRunTestSuite(Sender: TObject);
    procedure DoSyncLazarusProject(Sender: TObject);
  end;

procedure RegisterToolsMenu;

implementation

var
  gBVToolsManager: TBVToolsManager = nil;

function GetBVToolsManager: TBVToolsManager;
begin
  if gBVToolsManager = nil then
    gBVToolsManager := TBVToolsManager.Create(nil);
  Result := gBVToolsManager;
end;

function FindBVExecutable(const StartDir: string): string;
var
  Candidate: string;
  CurDir: string;
begin
  Result := '';
  CurDir := StartDir;

  // 1. Traverse up searching for bin/bv.exe or bin/bv
  while (CurDir <> '') and (Length(CurDir) > 3) do
  begin
    {$IFDEF WINDOWS}
    Candidate := IncludeTrailingPathDelimiter(CurDir) + 'bin' + DirectorySeparator + 'bv.exe';
    {$ELSE}
    Candidate := IncludeTrailingPathDelimiter(CurDir) + 'bin' + DirectorySeparator + 'bv';
    {$ENDIF}

    if FileExists(Candidate) then
      Exit(Candidate);

    CurDir := ExtractFileDir(CurDir);
  end;

  // 2. Fallback to system PATH
  {$IFDEF WINDOWS}
  Result := 'bv.exe';
  {$ELSE}
  Result := 'bv';
  {$ENDIF}
end;

function RunProcessCapture(const ExePath: string; const Args: array of string; const WorkingDir: string; out Output: string): Integer;
var
  Proc: TProcess;
  Buffer: array[0..4095] of Char;
  BytesRead: Integer;
  StrStream: TStringStream;
  i: Integer;
begin
  Output := '';
  FillChar(Buffer, SizeOf(Buffer), 0);
  Proc := TProcess.Create(nil);
  StrStream := TStringStream.Create('');
  try
    Proc.Executable := ExePath;
    for i := Low(Args) to High(Args) do
      Proc.Parameters.Add(Args[i]);

    if WorkingDir <> '' then
      Proc.CurrentDirectory := WorkingDir;
    Proc.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    Proc.Execute;

    while Proc.Running do
    begin
      while Proc.Output.NumBytesAvailable > 0 do
      begin
        BytesRead := Proc.Output.Read(Buffer, SizeOf(Buffer) - 1);
        if BytesRead > 0 then
        begin
          Buffer[BytesRead] := #0;
          StrStream.Write(Buffer, BytesRead);
        end;
      end;
      Sleep(10);
    end;

    // Read remaining bytes
    while Proc.Output.NumBytesAvailable > 0 do
    begin
      BytesRead := Proc.Output.Read(Buffer, SizeOf(Buffer) - 1);
      if BytesRead > 0 then
      begin
        Buffer[BytesRead] := #0;
        StrStream.Write(Buffer, BytesRead);
      end;
    end;

    Result := Proc.ExitStatus;
    Output := StrStream.DataString;
  finally
    StrStream.Free;
    Proc.Free;
  end;
end;

{ TBVToolsManager }

procedure TBVToolsManager.DoCheckActiveComponent({%H-}Sender: TObject);
var
  ActiveEd: TSourceEditorInterface;
  FileName: string;
  ProjectDir: string;
  BVExe: string;
  OutputStr: string;
  ExitCode: Integer;
  Lines: TStringList;
  i: Integer;
begin
  if SourceEditorManagerIntf = nil then Exit;
  ActiveEd := SourceEditorManagerIntf.ActiveEditor;
  if ActiveEd = nil then
  begin
    ShowMessage('Nenhum arquivo ativo no editor do Lazarus.');
    Exit;
  end;

  FileName := ActiveEd.FileName;
  if LowerCase(ExtractFileExt(FileName)) <> '.bv' then
  begin
    ShowMessage('O arquivo ativo (' + ExtractFileName(FileName) + ') não é um componente BlaiseVue (.bv).');
    Exit;
  end;

  ProjectDir := ExtractFileDir(FileName);
  BVExe := FindBVExecutable(ProjectDir);

  IDEMessagesWindow.Clear;
  IDEMessagesWindow.AddCustomMessage(mluImportant, '=== [BlaiseVue AST Check] Verificando: ' + ExtractFileName(FileName) + ' ===', FileName, 0, 0);

  ExitCode := RunProcessCapture(BVExe, ['check', FileName], ProjectDir, OutputStr);

  Lines := TStringList.Create;
  try
    Lines.Text := OutputStr;
    for i := 0 to Lines.Count - 1 do
    begin
      if ExitCode = 0 then
        IDEMessagesWindow.AddCustomMessage(mluNone, Lines[i], FileName, 0, 0)
      else
        IDEMessagesWindow.AddCustomMessage(mluError, Lines[i], FileName, 0, 0);
    end;
  finally
    Lines.Free;
  end;

  if ExitCode = 0 then
    IDEMessagesWindow.AddCustomMessage(mluImportant, '✔ Sucesso: Sintaxe e AST do componente estão íntegras!', FileName, 0, 0)
  else
    IDEMessagesWindow.AddCustomMessage(mluError, '✘ Falha: Encontrados erros de validação no componente.', FileName, 0, 0);
end;

procedure TBVToolsManager.DoFormatActiveComponent({%H-}Sender: TObject);
var
  ActiveEd: TSourceEditorInterface;
  FileName: string;
  OldText, NewText: string;
begin
  if SourceEditorManagerIntf = nil then Exit;
  ActiveEd := SourceEditorManagerIntf.ActiveEditor;
  if ActiveEd = nil then
  begin
    ShowMessage('Nenhum arquivo ativo no editor do Lazarus.');
    Exit;
  end;

  FileName := ActiveEd.FileName;
  if LowerCase(ExtractFileExt(FileName)) <> '.bv' then
  begin
    ShowMessage('O arquivo ativo (' + ExtractFileName(FileName) + ') não é um componente BlaiseVue (.bv).');
    Exit;
  end;

  OldText := ActiveEd.SourceText;
  NewText := FormatBVContent(OldText);
  if OldText <> NewText then
  begin
    ActiveEd.BeginUndoBlock;
    try
      ActiveEd.ReplaceLines(1, ActiveEd.Lines.Count, NewText);
    finally
      ActiveEd.EndUndoBlock;
    end;
    IDEMessagesWindow.AddCustomMessage(mluImportant, '✔ Componente formatado com sucesso: ' + ExtractFileName(FileName), FileName, 0, 0);
  end
  else
  begin
    IDEMessagesWindow.AddCustomMessage(mluNone, 'Componente já está devidamente formatado: ' + ExtractFileName(FileName), FileName, 0, 0);
  end;
end;

procedure TBVToolsManager.DoTriggerAutoComplete({%H-}Sender: TObject);
var
  ActiveEd: TSourceEditorInterface;
  SynEd: TCustomSynEdit;
  Comp: TSynCompletion;
begin
  if SourceEditorManagerIntf = nil then Exit;
  ActiveEd := SourceEditorManagerIntf.ActiveEditor;
  if ActiveEd = nil then Exit;

  if ActiveEd.EditorControl is TCustomSynEdit then
  begin
    SynEd := TCustomSynEdit(ActiveEd.EditorControl);
    Comp := AttachBVCompletion(SynEd);
    if Comp <> nil then
      Comp.Execute('', SynEd.CaretX, SynEd.CaretY);
  end;
end;

procedure TBVToolsManager.DoListSearchPaths({%H-}Sender: TObject);
var
  ProjectDir: string;
  BVExe: string;
  OutputStr: string;
  Lines: TStringList;
  i: Integer;
begin
  ProjectDir := GetCurrentDir;
  if (SourceEditorManagerIntf <> nil) and (SourceEditorManagerIntf.ActiveEditor <> nil) then
    ProjectDir := ExtractFileDir(SourceEditorManagerIntf.ActiveEditor.FileName);

  BVExe := FindBVExecutable(ProjectDir);

  IDEMessagesWindow.Clear;
  IDEMessagesWindow.AddCustomMessage(mluImportant, '=== [BlaiseVue Path] Unidades Mapeadas no Compilador ===', '', 0, 0);

  RunProcessCapture(BVExe, ['path'], ProjectDir, OutputStr);

  Lines := TStringList.Create;
  try
    Lines.Text := OutputStr;
    for i := 0 to Lines.Count - 1 do
      IDEMessagesWindow.AddCustomMessage(mluNone, Lines[i], '', 0, 0);
  finally
    Lines.Free;
  end;
end;

procedure TBVToolsManager.DoRunTestSuite({%H-}Sender: TObject);
var
  ProjectDir: string;
  BVExe: string;
  OutputStr: string;
  ExitCode: Integer;
  Lines: TStringList;
  i: Integer;
begin
  ProjectDir := GetCurrentDir;
  if (SourceEditorManagerIntf <> nil) and (SourceEditorManagerIntf.ActiveEditor <> nil) then
    ProjectDir := ExtractFileDir(SourceEditorManagerIntf.ActiveEditor.FileName);

  BVExe := FindBVExecutable(ProjectDir);

  IDEMessagesWindow.Clear;
  IDEMessagesWindow.AddCustomMessage(mluImportant, '=== [BlaiseVue Test] Executando Suíte de Testes ===', '', 0, 0);

  ExitCode := RunProcessCapture(BVExe, ['test'], ProjectDir, OutputStr);

  Lines := TStringList.Create;
  try
    Lines.Text := OutputStr;
    for i := 0 to Lines.Count - 1 do
    begin
      if ExitCode = 0 then
        IDEMessagesWindow.AddCustomMessage(mluNone, Lines[i], '', 0, 0)
      else
        IDEMessagesWindow.AddCustomMessage(mluError, Lines[i], '', 0, 0);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TBVToolsManager.DoSyncLazarusProject({%H-}Sender: TObject);
var
  ProjectDir: string;
  BVExe: string;
  OutputStr: string;
  Lines: TStringList;
  i: Integer;
begin
  ProjectDir := GetCurrentDir;
  if (SourceEditorManagerIntf <> nil) and (SourceEditorManagerIntf.ActiveEditor <> nil) then
    ProjectDir := ExtractFileDir(SourceEditorManagerIntf.ActiveEditor.FileName);

  BVExe := FindBVExecutable(ProjectDir);

  IDEMessagesWindow.Clear;
  IDEMessagesWindow.AddCustomMessage(mluImportant, '=== [BlaiseVue Lazarus] Sincronizando Projeto (.lpi) ===', '', 0, 0);

  RunProcessCapture(BVExe, ['lazarus', 'init'], ProjectDir, OutputStr);

  Lines := TStringList.Create;
  try
    Lines.Text := OutputStr;
    for i := 0 to Lines.Count - 1 do
      IDEMessagesWindow.AddCustomMessage(mluNone, Lines[i], '', 0, 0);
  finally
    Lines.Free;
  end;
end;

procedure RegisterToolsMenu;
var
  BVSubMenu: TIDEMenuSection;
  Mgr: TBVToolsManager;
begin
  Mgr := GetBVToolsManager;

  // Register submenu under standard Lazarus Tools menu
  BVSubMenu := RegisterIDESubMenu(itmSecondaryTools, 'BlaiseVueSubMenu', 'BlaiseVue');

  RegisterIDEMenuCommand(BVSubMenu, 'BVCheckComponent', 'Verificar Componente Ativo (.bv)', @Mgr.DoCheckActiveComponent);
  RegisterIDEMenuCommand(BVSubMenu, 'BVFormatComponent', 'Formatar Componente Ativo (.bv) (Ctrl+Shift+F)', @Mgr.DoFormatActiveComponent);
  RegisterIDEMenuCommand(BVSubMenu, 'BVAutoComplete', 'Autocomplete BlaiseVue (Ctrl+Espaço)', @Mgr.DoTriggerAutoComplete);
  RegisterIDEMenuCommand(BVSubMenu, 'BVLazarusSync', 'Sincronizar Projeto Lazarus (.lpi)', @Mgr.DoSyncLazarusProject);
  RegisterIDEMenuCommand(BVSubMenu, 'BVListPaths', 'Listar Search Paths do Compilador (bv path)', @Mgr.DoListSearchPaths);
  RegisterIDEMenuCommand(BVSubMenu, 'BVRunTests', 'Executar Suíte de Testes (bv test)', @Mgr.DoRunTestSuite);
end;

initialization

finalization
  if Assigned(gBVToolsManager) then
    FreeAndNil(gBVToolsManager);

end.
