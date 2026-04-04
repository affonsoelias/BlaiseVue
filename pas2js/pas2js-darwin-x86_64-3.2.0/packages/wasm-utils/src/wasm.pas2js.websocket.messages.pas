unit wasm.pas2js.websocket.messages;

{$mode ObjFPC}
{$modeswitch typehelpers}
{$modeswitch externalclass}

interface

uses
  JS, Rtl.WorkerCommands, wasm.websocket.shared;

Type
  TWebsocketSetMemCommand = class external name 'Object' (TCustomWorkerCommand)
    Buffer : TJSSharedArrayBuffer;
  end;

  TWebsocketSetMemCommandHelper = class helper for TWebsocketSetMemCommand
    Class function CommandName : string; static;
    Class function CreateNew(aBuffer : TJSSharedArrayBuffer; aThreadID : Integer = -1) : TWebsocketSetMemCommand; static;
  end;


  // When an unexpected error occurred.
  TWebsocketHandlerOKCommand  = class external name 'Object' (TCustomWorkerCommand)
  end;

  { TWebsocketHandlerOKCommandHelper }

  TWebsocketHandlerOKCommandHelper = class helper for TWebsocketHandlerOKCommand
    Class function CommandName : string; static;
    Class function CreateNew() : TWebsocketHandlerOKCommand; static;
  end;


implementation

uses SysUtils;

{ TWebsocketSetMemCommandHelper }

class function TWebsocketSetMemCommandHelper.CommandName: string;

begin
  Result:=cmdWebsocketSharedMem;
end;

class function TWebsocketSetMemCommandHelper.CreateNew(aBuffer : TJSSharedArrayBuffer; aThreadID: Integer): TWebsocketSetMemCommand;
begin
  Result:= TWebsocketSetMemCommand(createCommand(CommandName,IntToStr(aThreadID)));
  Result.Buffer:=aBuffer;
end;


class function TWebsocketHandlerOKCommandHelper.CommandName: string;
begin
  Result:='websockethandlerok';
end;

class function TWebsocketHandlerOKCommandHelper.CreateNew : TWebsocketHandlerOKCommand;
begin
  Result:= TWebsocketHandlerOKCommand(createCommand(CommandName,'websockethandler'));
end;


end.

