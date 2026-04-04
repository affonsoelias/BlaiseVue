program filesystemhost;

{$mode objfpc}

uses
  BrowserConsole, BrowserApp, WASIHostApp, JS, Classes, SysUtils, Web, wasitypes, wasizenfs, libzenfs, libzenfsdom;

type
  TMyApplication = class(TWASIHostApplication)
  protected
    FS :TWASIZenFS;
    procedure RunWasm ; async;
    procedure DoRun; override;
  public
  end;

procedure TMyApplication.DoRun;

begin
  RunWasm;
end;

procedure TMyApplication.RunWasm;

begin
//  Writeln('Enabling logging');
//  WasiEnvironment.LogAPI:=True;
  await(tjsobject,  ZenFS.configure(
    new(
      ['mounts', new([
        '/', DomBackends.WebStorage
       ])
      ])
    )
  );
  if not ZenFS.existsSync('/tmp') then
    begin
    ZenFS.mkdirSync('/tmp',777);
    end;
  FS:=TWASIZenFS.Create;
  WasiEnvironment.FS:=FS;
  StartWebAssembly('fsdemo.wasm');
end;

var
  Application : TMyApplication;

begin
  ConsoleStyle:=DefaultCRTConsoleStyle;
  HookConsole;
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
