program clienttest;

{$mode objfpc}{$H+}

uses
  Classes, fpjsonjs, browserconsole, consoletestrunner, tcTests, testinsightclient, fpcunittestinsight;

type
  TMyTestRunner = class(TTestRunner)
  protected
  // override the protected methods of TTestRunner to customize its behavior
  end;

Procedure DoRunTests(aClient : TAbstractTestInsightClient);

begin
  RunRegisteredTests(aClient)
end;


Procedure DoRunText(aClient : TAbstractTestInsightClient);

var
  Application: TMyTestRunner;

begin
  Application := TMyTestRunner.Create(nil);
  Application.Initialize;
  Application.Title := 'FPCUnit Console test runner';
  Application.Run;
  Application.Free;
end;


begin
  IsTestInsightListening(@DoRunTests,@DoRunText,'','');
end.
