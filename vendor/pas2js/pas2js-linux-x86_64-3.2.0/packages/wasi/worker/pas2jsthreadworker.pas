program pas2jsthreadworker;

{$mode objfpc}

uses
  Classes, rtl.threadrunner;

type
  { TApplication }

  TApplication = class(TWorkerThreadRunnerApplication)
  end;

{ TApplication }

var
  App: TApplication;

begin
  App:=TApplication.Create(nil);
  App.Run;
end.
