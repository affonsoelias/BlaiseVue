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
  sysutils,
  classes,
  mormot.core.base,
  mormot.core.os,
  ServerModels,
  ServerApp;

var
  App: TBlaiseServerApp;
  Port: RawUtf8;
  DistPath: string;
  i: Integer;
begin
  Port := '8090';

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
      try
        ReadLn;
      except
        while True do
          Sleep(1000);
      end;
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
