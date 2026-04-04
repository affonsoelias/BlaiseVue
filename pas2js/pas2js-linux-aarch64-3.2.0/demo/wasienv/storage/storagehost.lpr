{
    This file is part of the Free Component Library

    Webassembly Storage API - Demo program
    Copyright (c) 2025 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

program storagehost;

{$mode objfpc}
{$modeswitch externalclass}

uses
  BrowserConsole, BrowserApp, WASIHostApp, JS, Classes, SysUtils, Web, wasm.pas2js.storage;

type
  THostConfig = class external name 'Object' (TJSObject)
    wasmFilename : String;
    logStorageAPI : Boolean;
    logWasiAPI : Boolean;
  end;

var
  HostConfig : THostConfig; external name 'hostConfig';

Type
  { TMyApplication }

  TMyApplication = class(TWASIHostApplication)
    cbLog:TJSHTMLInputElement;
    FStorage : TStorageAPI;
  private
    procedure HandleLogClick(Event: TJSEvent);
  protected
    procedure DoRun; override;
  public
    Constructor Create(aOwner : TComponent); override;
  end;

procedure TMyApplication.DoRun;
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
      Wasm:='storagedemo.wasm';
    end;
  StartWebAssembly(wasm);
end;

procedure TMyApplication.HandleLogClick(Event : TJSEvent);

begin
  FStorage.LogAPI:=cbLog.Checked;
  Window.localStorage.SetItem('showlog',IntToStr(Ord(cbLog.Checked)));
end;

constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FStorage:=TStorageAPI.Create(WasiEnvironment);
  if isDefined(hostConfig) and Assigned(hostConfig) then
     begin
     WasiEnvironment.LogAPI:=HostConfig.logWasiAPi;
     FStorage.LogAPI:=HostConfig.logStorageAPI;
     end;
  FStorage.LogAPI:=FStorage.LogAPI or (Window.localStorage.getItem('showlog')='1');
  cbLog:=TJSHTMLInputElement(GetHTMLElement('cbLog'));
  cbLog.Checked:=FStorage.LogAPI;
  cbLog.addEventListener('click',@HandleLogClick);
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
