program BlaiseVue_Desktop;

{$mode objfpc}{$H+}
{$IFDEF RELEASE}
  {$APPTYPE GUI}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  SysUtils, Classes, Process, webui, uDesktopBridge;

const
  APP_TITLE = 'BlaiseVue Desktop';
  DEFAULT_WIDTH = 1280;
  DEFAULT_HEIGHT = 800;

var
  MainWindow: Size_t;
  IndexPath: string;
  AssetsDir: string;

function FindAppModeBrowser(const TargetURL: string; out BrowserCmd: string): Boolean;
var
  EdgePath, ChromePath, BravePath: string;
begin
  Result := False;
  BrowserCmd := '';

  {$IFDEF MSWINDOWS}
  EdgePath := GetEnvironmentVariable('ProgramFiles(x86)') + '\Microsoft\Edge\Application\msedge.exe';
  if not FileExists(EdgePath) then
    EdgePath := GetEnvironmentVariable('ProgramFiles') + '\Microsoft\Edge\Application\msedge.exe';

  ChromePath := GetEnvironmentVariable('ProgramFiles') + '\Google\Chrome\Application\chrome.exe';
  if not FileExists(ChromePath) then
    ChromePath := GetEnvironmentVariable('ProgramFiles(x86)') + '\Google\Chrome\Application\chrome.exe';
  if not FileExists(ChromePath) then
    ChromePath := GetEnvironmentVariable('LocalAppData') + '\Google\Chrome\Application\chrome.exe';

  BravePath := GetEnvironmentVariable('ProgramFiles') + '\BraveSoftware\Brave-Browser\Application\brave.exe';

  if FileExists(EdgePath) then
  begin
    BrowserCmd := EdgePath;
    Exit(True);
  end;

  if FileExists(ChromePath) then
  begin
    BrowserCmd := ChromePath;
    Exit(True);
  end;

  if FileExists(BravePath) then
  begin
    BrowserCmd := BravePath;
    Exit(True);
  end;

  BrowserCmd := 'cmd.exe';
  Result := True;
  {$ELSE}
  BrowserCmd := 'xdg-open';
  Result := True;
  {$ENDIF}
end;

procedure LaunchNativeBrowserApp(const TargetURL: string);
var
  BCmd: string;
  Proc: TProcess;
  ProfileDir: string;
begin
  WriteLn('[BlaiseVue Desktop] Launching native Browser App mode...');
  if FindAppModeBrowser(TargetURL, BCmd) then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := BCmd;
      if BCmd = 'cmd.exe' then
      begin
        Proc.Parameters.Add('/c');
        Proc.Parameters.Add('start');
        Proc.Parameters.Add('''');
        Proc.Parameters.Add(TargetURL);
      end
      else
      begin
        ProfileDir := GetTempDir(False) + 'bv_desktop_profile';
        ForceDirectories(ProfileDir);
        Proc.Parameters.Add('--app=' + TargetURL);
        Proc.Parameters.Add('--window-size=' + IntToStr(DEFAULT_WIDTH) + ',' + IntToStr(DEFAULT_HEIGHT));
        Proc.Parameters.Add('--user-data-dir=' + ProfileDir);
        Proc.Parameters.Add('--no-first-run');
      end;
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
    finally
      Proc.Free;
    end;
  end;
end;

begin
  {$IFDEF MSWINDOWS}
  if not IsConsole then
  begin
    try
      AssignFile(Output, 'NUL');
      Rewrite(Output);
      AssignFile(ErrOutput, 'NUL');
      Rewrite(ErrOutput);
    except
    end;
  end;
  {$ENDIF}

  WriteLn('====================================================');
  WriteLn('  ' + APP_TITLE + ' - BlaiseVue 3.5 Desktop');
  WriteLn('====================================================');

  // 1. Packaged directly alongside executable (standalone bundle/dist)
  AssetsDir := ExtractFilePath(ParamStr(0)) + 'assets';

  // 2. Platform bin subdirectory: desktop/bin/<platform>/ -> desktop/assets
  if not DirectoryExists(AssetsDir) then
    AssetsDir := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + '..' + DirectorySeparator + 'assets');

  // 3. Flat bin directory: desktop/bin/ -> desktop/assets
  if not DirectoryExists(AssetsDir) then
    AssetsDir := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + 'assets');

  // 4. Current working directory
  if not DirectoryExists(AssetsDir) then
    AssetsDir := GetCurrentDir + DirectorySeparator + 'assets';
  if not DirectoryExists(AssetsDir) then
    AssetsDir := GetCurrentDir + DirectorySeparator + 'desktop' + DirectorySeparator + 'assets';

  IndexPath := AssetsDir + DirectorySeparator + 'index.html';
  if not FileExists(IndexPath) then
  begin
    {$IFDEF MSWINDOWS}
    if not IsConsole then
      MessageBoxA(0, PChar('Assets not found: ' + IndexPath + #13#10 + 'Please run "bv desktop sync" first.'), PChar(APP_TITLE), MB_ICONERROR or MB_OK)
    else
    {$ENDIF}
      WriteLn('[ERROR] Assets not found: ', IndexPath);
    Halt(1);
  end;

  WriteLn('[i] Assets found: ', IndexPath);

  if InitWebUI then
  begin
    WriteLn('[+] Initialized WebUI runtime successfully!');
    MainWindow := webui_new_window();
    RegisterDesktopBridge(MainWindow);
    webui_set_title(MainWindow, PChar(APP_TITLE));
    webui_set_size(MainWindow, DEFAULT_WIDTH, DEFAULT_HEIGHT);

    WriteLn('[+] Opening desktop window via WebUI...');
    webui_show(MainWindow, PChar(IndexPath));
    webui_wait();
    WriteLn('[i] Desktop window closed.');
  end
  else
  begin
    WriteLn('[i] WebUI library (webui-2.dll) not found in binary folder.');
    WriteLn('[i] Gracefully falling back to native Browser App Mode (Edge/Chrome/Chromium)...');
    LaunchNativeBrowserApp('file:///' + StringReplace(ExpandFileName(IndexPath), '\', '/', [rfReplaceAll]));
  end;
end.
