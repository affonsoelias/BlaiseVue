{
    This file is part of the Free Component Library

    Webassembly Message channel API - worker implementation
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit wasm.pas2js.messagechannelapi.worker;

{$mode ObjFPC}

interface

uses
  SysUtils, wasm.pas2js.messagechannelapi,wasm.messagechannel.shared, webworker;

Type
  TWasmWorkerChannel = class(TWasmChannel)
  public
    constructor create(aID: TWasmMessageChannelID);
    procedure SendMessage(Msg: JSValue); override;
  end;

  TWorkerMessageChannelAPI = Class(TMessageChannelAPI)
  Protected
    function CreateChannel(aType: TWasmChannelType; aID: TWasmMessageChannelID; aName: String): TWasmChannel; override;
  end;

implementation

{ TWasmWorkerChannel }

constructor TWasmWorkerChannel.create(aID: TWasmMessageChannelID);
begin
  inherited create(aID,ctWorker);
end;

procedure TWasmWorkerChannel.SendMessage(Msg: JSValue);
begin
  self_.postMessage(Msg);
end;

{ TWorkerMessageChannelAPI }

function TWorkerMessageChannelAPI.CreateChannel(aType: TWasmChannelType; aID: TWasmMessageChannelID; aName: String): TWasmChannel;
begin
  if aType=ctWorker then
    Result:=TWasmWorkerChannel.Create(aID)
  else
    Result:=inherited CreateChannel(aType, aID, aName);
end;

end.

