unit uBVToolsMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Dialogs, Process, ExtCtrls, LCLIntf,
  MenuIntf, SrcEditorIntf, IDEMsgIntf, IDEExternToolIntf, LazIDEIntf,
  uBVFormatter, uBVStrings;

type
  { TBVToolsManager }
  TBVToolsManager = class(TComponent)
  private
    // Live preview: one "bv dev" per IDE session, its output read by a timer
    FDevProc: TProcess;
    FDevTimer: TTimer;
    FDevRoot: string;
    FDevPartial: string;
    FDevURL: string;        // http://localhost:<port>/ once the server says so
    FPendingHash: string;   // route to open as soon as the server is up
    FPendingOpen: Boolean;
    procedure DevTimerTick(Sender: TObject);
    procedure DevHandleLine(const ALine: string);
    procedure OpenPreview(const AHash: string);
  public
    destructor Destroy; override;
    procedure StopDevServer;
    procedure DoCheckActiveComponent(Sender: TObject);
    procedure DoFormatActiveComponent(Sender: TObject);
    procedure DoListSearchPaths(Sender: TObject);
    procedure DoRunTestSuite(Sender: TObject);
    procedure DoSyncLazarusProject(Sender: TObject);
    procedure DoPreviewInBrowser(Sender: TObject);
    procedure DoStopPreview(Sender: TObject);
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
    ShowMessage(rsBVNoActiveFile);
    Exit;
  end;

  FileName := ActiveEd.FileName;
  if LowerCase(ExtractFileExt(FileName)) <> '.bv' then
  begin
    ShowMessage(Format(rsBVNotBVFile, [ExtractFileName(FileName)]));
    Exit;
  end;

  ProjectDir := ExtractFileDir(FileName);
  BVExe := FindBVExecutable(ProjectDir);

  IDEMessagesWindow.Clear;
  IDEMessagesWindow.AddCustomMessage(mluImportant, Format(rsBVCheckHeader, [ExtractFileName(FileName)]), FileName, 0, 0);

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
    IDEMessagesWindow.AddCustomMessage(mluImportant, '✔ ' + rsBVCheckOK, FileName, 0, 0)
  else
    IDEMessagesWindow.AddCustomMessage(mluError, '✘ ' + rsBVCheckFailed, FileName, 0, 0);
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
    ShowMessage(rsBVNoActiveFile);
    Exit;
  end;

  FileName := ActiveEd.FileName;
  if LowerCase(ExtractFileExt(FileName)) <> '.bv' then
  begin
    ShowMessage(Format(rsBVNotBVFile, [ExtractFileName(FileName)]));
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
    IDEMessagesWindow.AddCustomMessage(mluImportant, '✔ ' + Format(rsBVFormatDone, [ExtractFileName(FileName)]), FileName, 0, 0);
  end
  else
  begin
    IDEMessagesWindow.AddCustomMessage(mluNone, Format(rsBVFormatUnchanged, [ExtractFileName(FileName)]), FileName, 0, 0);
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
  IDEMessagesWindow.AddCustomMessage(mluImportant, rsBVPathsHeader, '', 0, 0);

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
  IDEMessagesWindow.AddCustomMessage(mluImportant, rsBVTestsHeader, '', 0, 0);

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
  IDEMessagesWindow.AddCustomMessage(mluImportant, rsBVSyncHeader, '', 0, 0);

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

{ Live preview in the browser }

// The folder of the BlaiseVue app: the nearest one above the file with src/app.bv
function FindBVProjectRoot(const AFileName: string): string;
var
  CurDir, ParentDir: string;
begin
  CurDir := ExtractFileDir(ExpandFileName(AFileName));
  while CurDir <> '' do
  begin
    if FileExists(IncludeTrailingPathDelimiter(CurDir) + 'src' + DirectorySeparator + 'app.bv') then
      Exit(CurDir);
    ParentDir := ExtractFileDir(CurDir);
    if ParentDir = CurDir then Break;
    CurDir := ParentDir;
  end;
  Result := '';
end;

// Same rule as bv.pas PascalToKebab: ContactEdit -> contact-edit
function BVPascalToKebab(const S: string): string;
var
  i: Integer;
begin
  if Copy(S, 1, 2) = 'BV' then
  begin
    Result := 'bv';
    for i := 3 to Length(S) do
    begin
      if S[i] in ['A'..'Z'] then Result := Result + '-';
      Result := Result + LowerCase(S[i]);
    end;
    Exit;
  end;
  Result := '';
  for i := 1 to Length(S) do
  begin
    if (i > 1) and (S[i] in ['A'..'Z']) then Result := Result + '-';
    Result := Result + LowerCase(S[i]);
  end;
end;

// The hash route of a view: views/Documents.bv is <documents-page>, which the
// router: routes: block of src/app.bv maps from '/documents'. '' when not routed.
function FindBVRouteForFile(const ARoot, AFileName: string): string;
var
  AppLines: TStringList;
  Tag, Line, Path, Target: string;
  i, p1, p2, p3, p4: Integer;
begin
  Result := '';
  if Pos(DirectorySeparator + 'src' + DirectorySeparator + 'views' + DirectorySeparator,
         ExpandFileName(AFileName)) = 0 then
    Exit;
  Tag := BVPascalToKebab(ChangeFileExt(ExtractFileName(AFileName), '')) + '-page';
  AppLines := TStringList.Create;
  try
    AppLines.LoadFromFile(IncludeTrailingPathDelimiter(ARoot) + 'src' + DirectorySeparator + 'app.bv');
    for i := 0 to AppLines.Count - 1 do
    begin
      // '/path': 'tag-page';
      Line := Trim(AppLines[i]);
      if (Line = '') or (Line[1] <> '''') then Continue;
      p1 := 1;
      p2 := Pos('''', Copy(Line, p1 + 1, MaxInt)) + p1;
      if p2 <= p1 then Continue;
      Path := Copy(Line, p1 + 1, p2 - p1 - 1);
      p3 := Pos('''', Copy(Line, p2 + 1, MaxInt)) + p2;
      if p3 <= p2 then Continue;
      p4 := Pos('''', Copy(Line, p3 + 1, MaxInt)) + p3;
      if p4 <= p3 then Continue;
      Target := Copy(Line, p3 + 1, p4 - p3 - 1);
      if (Path <> '') and (Path[1] = '/') and SameText(Target, Tag) then
        Exit(Path);
    end;
  finally
    AppLines.Free;
  end;
end;

function StripAnsi(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  i := 1;
  while i <= Length(S) do
  begin
    if (S[i] = #27) and (i < Length(S)) and (S[i + 1] = '[') then
    begin
      Inc(i, 2);
      while (i <= Length(S)) and not (S[i] in ['A'..'Z', 'a'..'z']) do Inc(i);
      Inc(i);
    end
    else
    begin
      if S[i] <> #13 then Result := Result + S[i];
      Inc(i);
    end;
  end;
end;

destructor TBVToolsManager.Destroy;
begin
  StopDevServer;
  inherited Destroy;
end;

procedure TBVToolsManager.StopDevServer;
var
  Killer: TProcess;
begin
  if Assigned(FDevTimer) then
    FDevTimer.Enabled := False;
  if Assigned(FDevProc) then
  begin
    if FDevProc.Running then
    begin
      {$IFDEF WINDOWS}
      // bv dev starts node through cmd: end the whole tree, or node keeps the port
      Killer := TProcess.Create(nil);
      try
        Killer.Executable := 'taskkill';
        Killer.Parameters.Add('/T');
        Killer.Parameters.Add('/F');
        Killer.Parameters.Add('/PID');
        Killer.Parameters.Add(IntToStr(FDevProc.ProcessID));
        Killer.Options := [poNoConsole, poWaitOnExit];
        try
          Killer.Execute;
        except
        end;
      finally
        Killer.Free;
      end;
      {$ELSE}
      Killer := nil;
      {$ENDIF}
      if FDevProc.Running then
        FDevProc.Terminate(0);
    end;
    FreeAndNil(FDevProc);
  end;
  FDevURL := '';
  FDevRoot := '';
  FDevPartial := '';
  FPendingOpen := False;
end;

procedure TBVToolsManager.OpenPreview(const AHash: string);
begin
  if AHash <> '' then
    OpenURL(FDevURL + '#' + AHash)
  else
    OpenURL(FDevURL);
end;

procedure TBVToolsManager.DevHandleLine(const ALine: string);
var
  Line: string;
  p, q: Integer;
begin
  Line := StripAnsi(ALine);
  if Trim(Line) = '' then Exit;
  if (Pos('rror', Line) > 0) or (Pos('[ERROR]', Line) > 0) then
    IDEMessagesWindow.AddCustomMessage(mluError, '[bv dev] ' + Line, '', 0, 0)
  else
    IDEMessagesWindow.AddCustomMessage(mluNone, '[bv dev] ' + Line, '', 0, 0);

  // "Dev Server running at http://localhost:8080/" (the port moves up when busy)
  p := Pos('http://localhost:', Line);
  if (FDevURL = '') and (Pos('running at', Line) > 0) and (p > 0) then
  begin
    q := p + Length('http://localhost:');
    while (q <= Length(Line)) and (Line[q] in ['0'..'9']) do Inc(q);
    FDevURL := Copy(Line, p, q - p) + '/';
    if FPendingOpen then
    begin
      FPendingOpen := False;
      OpenPreview(FPendingHash);
    end;
  end;
end;

procedure TBVToolsManager.DevTimerTick(Sender: TObject);
var
  Buffer: array[0..4095] of Char;
  Chunk: string;
  BytesRead, p: Integer;
begin
  if FDevProc = nil then Exit;
  // keep the pipe drained, or node blocks on a full stdout
  while FDevProc.Output.NumBytesAvailable > 0 do
  begin
    BytesRead := FDevProc.Output.Read(Buffer, SizeOf(Buffer));
    if BytesRead <= 0 then Break;
    SetString(Chunk, PChar(@Buffer[0]), BytesRead);
    FDevPartial := FDevPartial + Chunk;
  end;
  p := Pos(#10, FDevPartial);
  while p > 0 do
  begin
    DevHandleLine(Copy(FDevPartial, 1, p - 1));
    Delete(FDevPartial, 1, p);
    p := Pos(#10, FDevPartial);
  end;
  if not FDevProc.Running then
  begin
    if FDevPartial <> '' then DevHandleLine(FDevPartial);
    IDEMessagesWindow.AddCustomMessage(mluImportant,
      '[bv dev] ' + Format(rsBVDevEnded, [FDevProc.ExitStatus]), '', 0, 0);
    FDevTimer.Enabled := False;
    FreeAndNil(FDevProc);
    FDevURL := '';
    FDevRoot := '';
    FDevPartial := '';
    FPendingOpen := False;
  end;
end;

procedure TBVToolsManager.DoPreviewInBrowser({%H-}Sender: TObject);
var
  ActiveEd: TSourceEditorInterface;
  FileName, Root, Hash: string;
begin
  if SourceEditorManagerIntf = nil then Exit;
  ActiveEd := SourceEditorManagerIntf.ActiveEditor;
  if ActiveEd = nil then
  begin
    ShowMessage(rsBVNoActiveFile);
    Exit;
  end;
  FileName := ActiveEd.FileName;
  if LowerCase(ExtractFileExt(FileName)) <> '.bv' then
  begin
    ShowMessage(Format(rsBVNotBVFile, [ExtractFileName(FileName)]));
    Exit;
  end;
  Root := FindBVProjectRoot(FileName);
  if Root = '' then
  begin
    ShowMessage(Format(rsBVNoProjectRoot, [ExtractFileName(FileName)]));
    Exit;
  end;

  // the dev server rebuilds from the files on disk
  if ActiveEd.Modified then
    LazarusIDE.DoSaveEditorFile(ActiveEd, []);

  Hash := FindBVRouteForFile(Root, FileName);
  if Hash = '' then
    IDEMessagesWindow.AddCustomMessage(mluHint, '[bv dev] ' + Format(rsBVNoRoute, [ExtractFileName(FileName)]), FileName, 0, 0);

  // a server of another app is replaced
  if Assigned(FDevProc) and not SameFileName(FDevRoot, Root) then
    StopDevServer;

  if Assigned(FDevProc) then
  begin
    if FDevURL <> '' then
      OpenPreview(Hash)
    else
    begin
      FPendingHash := Hash;
      FPendingOpen := True;
    end;
    Exit;
  end;

  IDEMessagesWindow.Clear;
  IDEMessagesWindow.AddCustomMessage(mluImportant,
    Format(rsBVDevStarting, [Root]), '', 0, 0);
  FDevProc := TProcess.Create(nil);
  FDevProc.Executable := FindBVExecutable(Root);
  FDevProc.Parameters.Add('dev');
  FDevProc.CurrentDirectory := Root;
  FDevProc.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
  try
    FDevProc.Execute;
  except
    on E: Exception do
    begin
      IDEMessagesWindow.AddCustomMessage(mluError, '[bv dev] ' + E.Message, '', 0, 0);
      FreeAndNil(FDevProc);
      Exit;
    end;
  end;
  FDevRoot := Root;
  FDevURL := '';
  FDevPartial := '';
  FPendingHash := Hash;
  FPendingOpen := True;
  if FDevTimer = nil then
  begin
    FDevTimer := TTimer.Create(Self);
    FDevTimer.Interval := 200;
    FDevTimer.OnTimer := @DevTimerTick;
  end;
  FDevTimer.Enabled := True;
end;

procedure TBVToolsManager.DoStopPreview({%H-}Sender: TObject);
begin
  if FDevProc = nil then
  begin
    IDEMessagesWindow.AddCustomMessage(mluNone, '[bv dev] ' + rsBVNoDevServer, '', 0, 0);
    Exit;
  end;
  StopDevServer;
  IDEMessagesWindow.AddCustomMessage(mluImportant, '[bv dev] ' + rsBVDevStopped, '', 0, 0);
end;

procedure RegisterToolsMenu;
var
  BVSubMenu: TIDEMenuSection;
  Mgr: TBVToolsManager;
begin
  Mgr := GetBVToolsManager;

  // Register submenu under standard Lazarus Tools menu
  BVSubMenu := RegisterIDESubMenu(itmSecondaryTools, 'BlaiseVueSubMenu', 'BlaiseVue');

  RegisterIDEMenuCommand(BVSubMenu, 'BVCheckComponent', rsBVCheckComponent, @Mgr.DoCheckActiveComponent);
  RegisterIDEMenuCommand(BVSubMenu, 'BVFormatComponent', rsBVFormatComponent, @Mgr.DoFormatActiveComponent);
  RegisterIDEMenuCommand(BVSubMenu, 'BVLazarusSync', rsBVSyncProject, @Mgr.DoSyncLazarusProject);
  RegisterIDEMenuCommand(BVSubMenu, 'BVListPaths', rsBVListPaths, @Mgr.DoListSearchPaths);
  RegisterIDEMenuCommand(BVSubMenu, 'BVRunTests', rsBVRunTests, @Mgr.DoRunTestSuite);
  RegisterIDEMenuCommand(BVSubMenu, 'BVPreview', rsBVPreview, @Mgr.DoPreviewInBrowser);
  RegisterIDEMenuCommand(BVSubMenu, 'BVStopPreview', rsBVStopPreview, @Mgr.DoStopPreview);
end;

initialization

finalization
  if Assigned(gBVToolsManager) then
    FreeAndNil(gBVToolsManager);

end.
