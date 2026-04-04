program wasmjobhost;

{$mode objfpc}

uses
  BrowserConsole, JS, Types, Classes, SysUtils, Web, WasiEnv, WasiHostApp, job_browser;

var
  wasmFilename : string; external name 'wasmFilename';


Type

  { TMyApplication }

  TMyApplication = class(TBrowserWASIHostApplication)
  Private
    FWADomBridge : TJSObjectBridge;
  Public
    constructor Create(aOwner : TComponent); override;
    procedure DoRun; override;
  end;


constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FWADomBridge:=TJSObjectBridge.Create(WasiEnvironment);
  RunEntryFunction:='_initialize';
end;

procedure TMyApplication.DoRun;

var
  wasmmodule : string;

begin
  // Your code here
  Terminate;
  if isString(wasmFilename) then
    WasmModule:=wasmFilename
  else
    begin
    WasmModule:=ParamStr(1);
    if WasmModule='' then
      WasmModule:='demo.wasm';
    end;

  StartWebAssembly(wasmmodule,true);
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
