{
    This file is part of the Free Component Library

    Webassembly HTTP API - demo host program 
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
program httphost;

{$mode objfpc}
{$modeswitch externalclass}

uses
  BrowserConsole, JS, Classes, SysUtils, Web, WasiEnv, WasiHostApp,
  wasm.pas2js.httpapi;

Type
  THostConfig = class external name 'Object' (TJSObject)
    wasmFilename : String;
    logHTTPAPI : Boolean;
    logWasiAPI : Boolean;
  end;

var
  HostConfig : THostConfig; external name 'hostConfig';

Type


   { THTTPHostApplication }

  THTTPHostApplication = class(TBrowserWASIHostApplication)
  Private
    FHTTPAPI : TWasmHTTPAPI;
  Public
    constructor Create(aOwner : TComponent); override;
    procedure DoRun; override;
  end;


constructor THTTPHostApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FHTTPAPI:=TWasmHTTPAPI.Create(WasiEnvironment);
  RunEntryFunction:='_initialize';
  if isDefined(hostConfig) and Assigned(hostConfig) then
    begin
    WasiEnvironment.LogAPI:=HostConfig.logWasiAPi;
    FHTTPAPI.LogAPICalls:=HostConfig.logHTTPAPI;
    end;
end;

procedure THTTPHostApplication.DoRun;

var
  wasm : String;

begin
  Terminate;
  if Assigned(HostConfig) and isString(HostConfig.wasmFilename) then
    Wasm:=HostConfig.wasmFilename
  else
    begin
    Wasm:=ParamStr(1);
    if Wasm='' then
      Wasm:='wasmhttpdemo.wasm';
    end;
  StartWebAssembly(Wasm, true);
end;

var
  Application : THTTPHostApplication;
begin
  Application:=THTTPHostApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
