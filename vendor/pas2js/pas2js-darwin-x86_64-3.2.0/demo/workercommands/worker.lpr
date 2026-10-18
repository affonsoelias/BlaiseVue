program worker;

{$mode objfpc}

uses
  Rtl.WorkerCommands, hello;

procedure echo (cmd : TCustomWorkerCommand);

var
  lCmd : TJSHelloCommand absolute cmd;
  lResponse : TJSHelloCommand;

begin
  Writeln('Worker got command ',lCmd.msg);
  Writeln('Sending reply');
  lResponse:=TJSHelloCommand.Create('Reply to : '+lCmd.Msg);
  CommandDispatcher.SendCommand(lResponse);
end;

begin
  CommandDispatcher.RegisterCommandHandler('hello',@Echo);
end.
