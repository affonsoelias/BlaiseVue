{
    This file is part of the Free Component Library

    Webassembly Websocket API demo.
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

program wasmwebsocket;

{$mode objfpc}
{$modeswitch externalclass}

uses
  BrowserConsole, BrowserApp, WASIHostApp, JS, Classes, SysUtils, WebOrWorker, Web, wasm.pas2js.websocketapi;

type
  THostConfig = class external name 'Object' (TJSObject)
    wasmFilename : String;
    logWebsocketAPI : Boolean;
    logWasiAPI : Boolean;
  end;

  { TMyApplication }

  TMyApplication = class(TWASIHostApplication)
  private
    FWS: TWasmWebSocketAPI;
    cbLog,
    edtFrom,
    edtTo,
    edtMessage : TJSHTMLInputElement;
    btnSend : TJSHTMLButtonElement;
    procedure HandleLogClick(aEvent: TJSEvent);
    procedure HandleSendClick(aEvent: TJSEvent);
  protected
    procedure SendMessageToWasm(aMsg : string);
    procedure DoRun; override;
  public
    constructor Create(aOwner: TComponent); override;
  end;

var
  HostConfig : THostConfig; external name 'hostConfig';

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
      Wasm:='wasmwebsocketdemo.wasm';
    end;
  StartWebAssembly(wasm);
end;

procedure TMyApplication.HandleLogClick(aEvent : TJSEvent);

begin
  FWS.LogApiCalls:=cbLog.Checked;
end;

procedure TMyApplication.HandleSendClick(aEvent : TJSEvent);

begin
  SendMessageToWasm(edtMessage.Value);
  edtMessage.Value:='';
  edtTo.Value:='';
end;

procedure TMyApplication.SendMessageToWasm(aMsg: string);

type
  TSendProcedure = procedure (Buf : Longint; BufLen : Longint);

var
  CB : JSValue;
  CallBack : TSendProcedure absolute CB;
  Bfr : TJSUint8Array;
  Enc : TJSTextEncoder;
  Loc,lLen : Longint;
  payload : string;

begin
  CB:=WasiEnvironment.Instance.exports_['sendmessage'];
  if isFunction(CB) then
    begin
    PayLoad:=TJSJSON.StringIfy(New(['msg',aMsg,'from',edtFrom.value,'recip',edtTo.value]));
    Enc:=TJSTextEncoder.new;
    Bfr:=Enc.encode(PayLoad);
    lLen:=Bfr.byteLength;
    Loc:=FWS.InstanceExports.AllocMem(lLen);
    WasiEnvironment.SetUTF8StringInMem(Loc,lLen,Bfr);
    CallBack(Loc,llen);
    FWS.InstanceExports.freeMem(Loc);
    end;
end;

constructor TMyApplication.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FWS:=TWasmWebSocketAPI.Create(WasiEnvironment);
  if isDefined(hostConfig) and Assigned(hostConfig) then
     begin
     WasiEnvironment.LogAPI:=HostConfig.logWasiAPi;
     FWS.LogAPICalls:=HostConfig.logWebsocketAPI;
     end;
  edtMessage:=TJSHTMLInputElement(GetHTMLElement('edtMessage'));
  edtFrom:=TJSHTMLInputElement(GetHTMLElement('edtFrom'));
  edtTo:=TJSHTMLInputElement(GetHTMLElement('edtTo'));
  cbLog:=TJSHTMLInputElement(GetHTMLElement('cbLog'));
  cbLog.addEventListener('click',@HandleLogClick);
  cbLog.Checked:=FWS.LogAPICalls;
  btnSend:=TJSHTMLButtonElement(GetHTMLElement('btnSend'));
  btnSend.addEventListener('click',@HandleSendClick);
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
