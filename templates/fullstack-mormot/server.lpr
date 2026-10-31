program server;

{
  BlaiseVue Full-Stack mORMot 2 Native Server
  -------------------------------------------
  High-performance HTTP REST, WebSocket, and Static SPA Server
  powered by Synopse mORMot 2 for BlaiseVue Universal Pascal apps.
}

{$I mormot.defines.inc}

{$ifdef OSWINDOWS}
  {$APPTYPE CONSOLE}
{$endif OSWINDOWS}

uses
  {$ifdef UNIX}
  cthreads,
  BaseUnix,
  {$endif UNIX}
  {$ifdef OSWINDOWS}
  windows,
  {$endif OSWINDOWS}
  sysutils,
  classes,
  mormot.core.base,
  mormot.core.os,
  ServerModels,
  ServerApp;

var
  App: TBlaiseServerApp;
  Port: RawUtf8;
  DistPath, EnvPath, EnvLine, EnvKey, EnvVal: string;
  EnvLines: TStringList;
  eqPos, i: Integer;
  TermChar: Char;
  ReadLen: Integer;

{$ifdef OSWINDOWS}
function ConsoleCtrlHandler(dwCtrlType: DWORD): BOOL; stdcall;
begin
  case dwCtrlType of
    CTRL_C_EVENT, CTRL_BREAK_EVENT, CTRL_CLOSE_EVENT, CTRL_SHUTDOWN_EVENT:
    begin
      WriteLn('');
      WriteLn('[+] Signal received (Ctrl+C). Gracefully closing mORMot 2 server...');
      if Assigned(App) then
      begin
        try
          App.Free;
          App := nil;
        except
        end;
      end;
      WriteLn('[+] mORMot 2 server stopped cleanly. Ports released.');
      ExitProcess(0);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
{$endif OSWINDOWS}

{$ifdef UNIX}
procedure UnixSigIntHandler(Sig: LongInt); cdecl;
begin
  WriteLn('');
  WriteLn('[+] Signal received (Ctrl+C). Gracefully closing mORMot 2 server...');
  if Assigned(App) then
  begin
    try
      App.Free;
      App := nil;
    except
    end;
  end;
  WriteLn('[+] mORMot 2 server stopped cleanly. Ports released.');
  Halt(0);
end;
{$endif UNIX}

begin
  {$ifdef OSWINDOWS}
  SetConsoleCtrlHandler(@ConsoleCtrlHandler, True);
  {$endif OSWINDOWS}
  {$ifdef UNIX}
  fpSignal(SIGINT, @UnixSigIntHandler);
  fpSignal(SIGTERM, @UnixSigIntHandler);
  {$endif UNIX}
  Port := '8090';

  // Read .env configuration if present
  EnvPath := ExtractFilePath(ParamStr(0)) + '.env';
  if not FileExists(EnvPath) then
    EnvPath := ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + '.env';
  if not FileExists(EnvPath) and FileExists('.env') then
    EnvPath := ExpandFileName('.env');
  if not FileExists(EnvPath) and FileExists('..' + DirectorySeparator + '.env') then
    EnvPath := ExpandFileName('..' + DirectorySeparator + '.env');

  if FileExists(EnvPath) then
  begin
    EnvLines := TStringList.Create;
    try
      EnvLines.LoadFromFile(EnvPath);
      for i := 0 to EnvLines.Count - 1 do
      begin
        EnvLine := Trim(EnvLines[i]);
        if (EnvLine = '') or (EnvLine[1] = '#') then Continue;
        eqPos := Pos('=', EnvLine);
        if eqPos > 1 then
        begin
          EnvKey := UpperCase(Trim(Copy(EnvLine, 1, eqPos - 1)));
          EnvVal := Trim(Copy(EnvLine, eqPos + 1, MaxInt));
          if EnvKey = 'PORT' then
            Port := EnvVal;
        end;
      end;
    finally
      EnvLines.Free;
    end;
  end;

  // Intelligent resolution of dist/ folder
  DistPath := '..' + DirectorySeparator + 'dist';
  if DirectoryExists(ExtractFilePath(ParamStr(0)) + 'dist') then
    DistPath := ExpandFileName(ExtractFilePath(ParamStr(0)) + 'dist')
  else if DirectoryExists('dist') then
    DistPath := ExpandFileName('dist')
  else if DirectoryExists('..' + DirectorySeparator + 'dist') then
    DistPath := ExpandFileName('..' + DirectorySeparator + 'dist')
  else if DirectoryExists(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + '..' + DirectorySeparator + 'dist') then
    DistPath := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + '..' + DirectorySeparator + 'dist')
  else if DirectoryExists(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + 'dist') then
    DistPath := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + 'dist');

  // Parse command line arguments
  i := 1;
  while i <= ParamCount do
  begin
    if (ParamStr(i) = '--port') or (ParamStr(i) = '-p') then
    begin
      Inc(i);
      if i <= ParamCount then
        Port := ParamStr(i);
    end
    else if (ParamStr(i) = '--dist') or (ParamStr(i) = '-d') then
    begin
      Inc(i);
      if i <= ParamCount then
        DistPath := ParamStr(i);
    end
    else if (ParamStr(i) = '--help') or (ParamStr(i) = '-h') then
    begin
      WriteLn('BlaiseVue Full-Stack mORMot 2 Server');
      WriteLn('Usage: server [options]');
      WriteLn('  -p, --port <port>   HTTP & WebSocket listening port (default: 8090)');
      WriteLn('  -d, --dist <dir>    Path to compiled BlaiseVue dist folder (default: ../dist)');
      WriteLn('  -h, --help          Show this help message');
      Halt(0);
    end;
    Inc(i);
  end;

  // Environment variable override
  if GetEnvironmentVariable('PORT') <> '' then
    Port := GetEnvironmentVariable('PORT');

  WriteLn('======================================================');
  WriteLn('   BlaiseVue 3.5 Full-Stack - mORMot 2 Native Server  ');
  WriteLn('======================================================');
  WriteLn('[+] Engine:    Synopse mORMot 2 (Asynchronous HTTP/WS)');
  WriteLn('[+] Port:      ', Port);
  if DirectoryExists(DistPath) then
    WriteLn('[+] Static:    ', DistPath, ' (SPA History fallback active)')
  else
    WriteLn('[!] Static:    ', DistPath, ' (Directory not found yet, run: bv build)');
  WriteLn('[+] REST API:  http://localhost:', Port, '/api/status');
  WriteLn('               http://localhost:', Port, '/api/items');
  WriteLn('[+] WebSocket: ws://localhost:', Port, '/blaise-ws');
  WriteLn('------------------------------------------------------');
  WriteLn('Press [Enter] or Ctrl+C to terminate server...');

  try
    App := TBlaiseServerApp.Create(Port, DistPath);
    try
      {$ifdef OSWINDOWS}
      try
        ReadLn;
      except
      end;
      {$else}
      while True do
      begin
        TermChar := #0;
        ReadLen := fpRead(0, TermChar, 1);
        if ReadLen <= 0 then
        begin
          // When stdin is not a TTY or running in background, keep server alive until signal (SIGINT/SIGTERM)
          Sleep(1000);
          Continue;
        end;
        if (TermChar = #10) or (TermChar = #13) then
          Break;
      end;
      {$endif}
    finally
      WriteLn(#10'[+] Shutting down mORMot 2 server...');
      App.Free;
      WriteLn('[+] Server stopped successfully.');
    end;
  except
    on E: Exception do
      WriteLn('[!] Server Fatal Error: ', E.Message);
  end;
end.
