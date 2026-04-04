{
    This file is part of the Free Component Library

    Webassembly MessageChannel API - demo host program 
    Copyright (c) 2025 by Michael Van Canneyt michael@freepascal.org

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
  BrowserConsole, JS, Classes, SysUtils, WebOrWorker, Web, WasiEnv, WasiHostApp,
  wasm.pas2js.messagechannelapi;

Type
  THostConfig = class external name 'Object' (TJSObject)
    wasmFilename : String;
  end;

var
  HostConfig : THostConfig; external name 'hostConfig';

Type


   { TMessageHostApplication }

  TMessageHostApplication = class(TBrowserWASIHostApplication)
  Private
    edtMsg : TJSHTMLInputElement;
    btnSend : TJSHTMLButtonElement;
    btnSend2 : TJSHTMLButtonElement;
    FChannelAPI : TMessageChannelAPI;
    FChannel : TJSBroadcastChannel;
    function DoHandleMessage(aEvent: TJSEvent): boolean;
    function DoSendMessage(aEvent: TJSEvent): boolean;
    function DoWasmSendMessage(aEvent: TJSEvent): boolean;
  Public
    constructor Create(aOwner : TComponent); override;
    procedure DoRun; override;
  end;

function TMessageHostApplication.DoSendMessage(aEvent: TJSEvent): boolean;
begin
  FChannel.postMessage(edtMsg.value);
end;

function TMessageHostApplication.DoWasmSendMessage(aEvent: TJSEvent): boolean;
type
  TProcedure = procedure;
var
  proc : TProcedure;
begin
  Proc:=TProcedure(Exported['SendMessage']);
  if assigned(Proc) then
    proc;
end;


function TMessageHostApplication.DoHandleMessage(aEvent: TJSEvent): boolean;
var
  lMsg : TJSMessageEvent absolute aEvent;
begin
  Writeln(lMsg.Data);
end;


constructor TMessageHostApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FChannel:=TJSBroadcastChannel.new('some_channel');
  FChannel.AddEventListener('message',@DoHandleMessage);
  FChannelAPI:=TMessageChannelAPI.Create(WasiEnvironment);
  RunEntryFunction:='_initialize';
  edtMsg:=TJSHTMLInputElement(GetHTMLElement('edtMsg'));
  btnSend:=TJSHTMLButtonElement(GetHTMLElement('btnSend'));
  btnSend.AddEventListener('click',@DoSendMessage);
  btnSend2:=TJSHTMLButtonElement(GetHTMLElement('btnSend2'));
  btnSend2.AddEventListener('click',@DoWasmSendMessage);
end;

procedure TMessageHostApplication.DoRun;

var
  wasm : String;

begin
  Terminate;
  if (HostConfig=undefined) and Assigned(HostConfig) and isString(HostConfig.wasmFilename) then
    Wasm:=HostConfig.wasmFilename
  else
    begin
    Wasm:=ParamStr(1);
    if Wasm='' then
      Wasm:='channeldemo.wasm';
    end;
  StartWebAssembly(Wasm, true);
end;

var
  Application : TMessageHostApplication;
begin
  Application:=TMessageHostApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
