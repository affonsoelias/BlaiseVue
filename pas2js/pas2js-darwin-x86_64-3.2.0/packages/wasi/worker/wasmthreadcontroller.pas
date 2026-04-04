program wasmthreadcontroller;

{$mode objfpc}

uses
  Classes, Rtl.threadcontroller, Rtl.workerthreadhost;

type
  { TApplication }

  TApplication = class(TWorkerThreadControllerApplication)
  end;

{ TApplication }

var
  App: TApplication;

begin
  globalThreadController.HandleConsoleMessages:=true;
  App:=TApplication.Create(nil);
  App.Run;
end.
