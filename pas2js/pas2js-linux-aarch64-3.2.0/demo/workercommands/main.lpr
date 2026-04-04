program main;

{$mode objfpc}
{$modeswitch externalclass}

uses
  BrowserConsole, JS, Classes, SysUtils, Web, Rtl.WorkerCommands, hello;


var
  Worker1 : TJSWorker;
  Worker2 : TJSWorker;
  Cmd : TJSHelloCommand;

begin
  Worker1:=TJSWorker.new('worker.js?name=worker1');
  CommandDispatcher.RegisterWorker(Worker1,'Worker 1');
  Worker2:=TJSWorker.new('worker.js?name=worker2');
  CommandDispatcher.RegisterWorker(Worker2,'Worker 2');
  CommandDispatcher.RegisterCommandHandler('hello',procedure (cmd : TCustomWorkerCommand)
    var
      lCmd : TJSHelloCommand absolute cmd;
    begin
      Writeln('Received hello: ',lCmd.Msg);
    end);
  Cmd:=TJSHelloCommand.Create('Hello, workers!');
  CommandDispatcher.BroadcastCommand(Cmd);
  Cmd:=TJSHelloCommand.Create('Hello, worker 1!');
  CommandDispatcher.SendCommand('Worker 1',Cmd);
  Cmd:=TJSHelloCommand.Create('Hello again, worker 1!');
  CommandDispatcher.SendCommand(Worker1,Cmd);
end.
