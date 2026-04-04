program storagemain;

{$mode objfpc}

uses
  Classes, BrowserConsole, BrowserApp, web, Rtl.WorkerCommands, pas2js.storagebridge.main;

Type

  { TApplication }

  TApplication = class(TBrowserApplication)
  private
    procedure HandleConsoleCommand(aCmd: TConsoleOutputCommand);
  protected
    FWorker: TJSWorker;
  Public
    procedure DoRun; override;
  end;

{ TApplication }

procedure TApplication.HandleConsoleCommand(aCmd : TConsoleOutputCommand);
begin
  Writeln('[Worker] ',aCmd.ConsoleMessage);
end;

procedure TApplication.DoRun;
begin
  Terminate;
  FWorker:=TJSWorker.New('storagehost.js');
  TCommandDispatcher.instance.RegisterWorker(FWorker,'storage');
  TCommandDispatcher.instance.specialize AddCommandHandler<TConsoleOutputCommand>(cmdConsole,@HandleConsoleCommand);
end;

begin
  With TApplication.Create(Nil) do
    begin
    Initialize;
    Run;
    end;
end.
