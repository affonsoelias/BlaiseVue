program wasmjobhost;

{$mode objfpc}

uses
  BrowserConsole, JS, Types, Classes, SysUtils, Web, WasiEnv, WasiHostApp, JOB_Browser, JOB_Shared;

var
  wasmFilename : string; external name 'wasmFilename';


Type

  { TMyApplication }

  TMyApplication = class(TBrowserWASIHostApplication)
  Private
    FBridge : TJSObjectBridge;
  Public
    constructor Create(aOwner : TComponent); override;
    procedure DoRun; override;
  end;


constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FBridge:=TJSObjectBridge.Create(WasiEnvironment);
  RunEntryFunction:='_initialize';
end;

procedure TMyApplication.DoRun;

  function DoError(aValue: JSValue): JSValue;
  begin
    if isObject(aValue) then
      if TJSObject(aValue) is TJSError then
        Writeln('Failed to start webassembly: ',TJSError(aValue).message)
      else if TObject(aValue) is Exception then
        Writeln('Failed to start webassembly: ',Exception(aValue).message);
  end;

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
  try
    StartWebAssembly(wasmmodule,true).catch(@DoError);
  except
    on E : exception do
  end;
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
