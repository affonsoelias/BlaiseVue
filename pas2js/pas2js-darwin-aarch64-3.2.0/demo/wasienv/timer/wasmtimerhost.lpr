program wasmtimerhost;

{$mode objfpc}

uses
  BrowserConsole, BrowserApp, WASIHostApp, JS, Classes, SysUtils, Web, wasm.pas2js.timer;

type

  { TMyApplication }

  TMyApplication = class(TWASIHostApplication)
  protected
    FTimerAPI : TWasmTimerAPI;
    procedure DoRun; override;
  public
    constructor Create(aOwner : TComponent); override;
  end;

procedure TMyApplication.DoRun;
begin
  StartWebAssembly('timerdemo.wasm');
end;

constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FTimerAPI:=TWasmTimerAPI.Create(WasiEnvironment);
  FTimerAPI.LogAPICalls:=True;
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
