unit hello;

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
  Rtl.WorkerCommands;

Type
  TJSHelloCommand = class external name 'Object' (TCustomWorkerCommand)
    msg : string;
  end;

  { TJSHelloCommandHelper }

  TJSHelloCommandHelper = class helper (TCustomWorkerCommandHelper) for TJSHelloCommand
    class function create(aMessage : String) : TJSHelloCommand; static;
  end;



implementation

{ TJSHelloCommandHelper }

class function TJSHelloCommandHelper.create(aMessage: String): TJSHelloCommand;
begin
  Result:=TJSHelloCommand(createCommand('hello'));
  Result.msg:=aMessage;
end;

end.

