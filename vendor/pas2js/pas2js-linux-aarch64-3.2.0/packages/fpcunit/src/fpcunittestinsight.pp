{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2023 by Michael Van Canneyt

    Test Insight FPCUnit test listener.
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit fpcunittestinsight;
{$ENDIF}

{$mode ObjFPC}{$H+}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Classes, System.SysUtils, System.Types, FpJson.Data, FpcUnit.Test, FpcUnit.Registry, TestInsight.Protocol, TestInsight.Client;
{$ELSE}
  Classes, SysUtils, types, fpjson, fpcunit, testregistry, testinsightprotocol, testinsightclient;
{$ENDIF}

type

  { TFPCUnitTestInsightHelper }

  TFPCUnitTestInsightHelper = Class helper for TTestInsightResult
    Procedure FromTestFailure(ATest: TTest; aFailure: TTestFailure);
  end;

  { TTestInsightListener }

  TTestInsightListener = class(ITestListener)
  private
    fClient: TAbstractTestInsightClient;
    fSelectedTests: TStringDynArray;
    FLastError : TTest;
    FStart : TDateTime;
    FRootTest : TTest;
  Public
    procedure AddFailure(ATest: TTest; aFailure: TTestFailure); override;
    procedure AddError(ATest: TTest; aError: TTestFailure); override;
    procedure StartTest(ATest: TTest); override;
    procedure EndTest(ATest: TTest); override;
    procedure StartTestSuite(ATestSuite: TTestSuite); override;
    procedure EndTestSuite(ATestSuite: TTestSuite); override;
    procedure SendTestSuite; virtual;
  public
    constructor Create(const aClient : TAbstractTestInsightClient; aRoot: TTest);
    Property RootTest : TTest Read FRootTest;
  end;


procedure RunRegisteredTests(aClient : TAbstractTestinsightClient);
procedure RunRegisteredTests(OnCreated,Onerror : TTestInsightClientEvent; const aConfig : String = ''; const baseUrl: string = DefaultUrl);
procedure IsTestinsightListening(OnCreated,Onerror : TTestInsightClientEvent; const aConfig : String = ''; const baseUrl: string = DefaultUrl) ;
Function DefaultTestConfigFileName : String;
Function TestSuiteToJSON(aSuite : TTest) : TJSONObject;
Procedure TestSuiteToJSON(aSuite : TTest; aJSON : TJSONObject);


implementation

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.DateUtils;
{$ELSE}  
  DateUtils;
{$ENDIF}

Function DefaultTestConfigFileName : String;
begin
  Result:='TestInsightSettings.json';
end;

function TestSuiteToJSON(aSuite: TTest): TJSONObject;
begin
  Result:=TJSONObject.Create;
  try
   TestSuiteToJSOn(aSuite,Result);
  except
    Result.Free;
    Raise;
  end;
end;

procedure TestSuiteToJSON(aSuite: TTest; aJSON: TJSONObject);

Var
  T : TTest;
  I : Integer;
  j : TJSONObject;

begin
  For I:=0 to aSuite.GetChildTestCount-1 do
    begin
    T:=aSuite.GetChildTest(I);
    if T is TTestSuite then
      begin
      J:=TJSONObject.Create;
      aJSON.Add(T.TestName,J);
      TestSuiteToJSON(T as TTestSuite,J);
      end
    else
      aJSON.Add(T.TestName);
    end;
end;


procedure CreateClient(OnCreated,Onerror : TTestInsightClientEvent; const aConfig : String = ''; const baseUrl: string = DefaultUrl);

Var
  aURL,Cfg : String;
  aClient : TAbstractTestInsightClient;


    Procedure DoLoad;
    begin
      TestInsightLog.Log('Configuration "%s" loaded',[Cfg]);
      OnCreated(aClient);
    end;

    Procedure DoError;
    begin
      TestInsightLog.Log('Configuration "%s" not loaded',[Cfg]);
      OnError(aClient);
    end;


begin
  Cfg:=aConfig;
  if (Cfg='') then
    Cfg:=DefaultTestConfigFileName;
  aURL:=baseURL;
  if aURL='' then
    aURL:=DefaultURL;
  aClient:=TTestInsightHTTPClient.Create(aURL);
  aClient.LoadConfig(Cfg,@DoLoad,@DoError);
end;

Procedure IsTestinsightListening(OnCreated,Onerror : TTestInsightClientEvent; const aConfig : String = ''; const baseUrl: string = DefaultUrl) ;

  Procedure DoConfig(aClient : TAbstractTestInsightClient);
  begin
    aClient.GetServerOptions._then(function(j : jsvalue) : jsvalue
      begin
      if assigned(OnCreated) then
        OnCreated(aClient);
      end
    ,function(j : jsvalue) : jsvalue
    begin
      Result:=False;
      if assigned(OnError) then
        OnError(aClient);
    end);

  end;

  Procedure DoNoConfig(aClient : TAbstractTestInsightClient);
  begin
    aClient.GetServerOptions._then(function(j : jsvalue) : jsvalue
      begin
      if assigned(OnError) then
        OnError(aClient);
      end
    ,function(j : jsvalue) : jsvalue
    begin
      Result:=False;
     if assigned(OnError) then
        OnError(aClient);
    end);
  end;

begin
  CreateClient(@DoConfig,@DoNoConfig,aConfig,BaseURL);
end;

Procedure AddSkips (aResult : TTestResult; aSuite : TTest; aAllowed : TTest);

Var
  I : Integer;
  T : TTest;

begin
  if (aSuite=aAllowed) then exit;
  for I:=0 to aSuite.GetChildTestCount-1 do
    begin
    T:=aSuite.GetChildTest(I);
    if T is TTestCase then
      aResult.AddToSkipList(T as TTestCase)
    else
      AddSkips(aResult,T,aAllowed)
    end;
end;

procedure RunRegisteredTests(aClient: TAbstractTestInsightClient);

var
  Suite: TTest;
  TestResult: TTestResult;
  Listener: TTestInsightListener;

begin
  Suite := GetTestRegistry;
  if not Assigned(Suite) then
    Exit;
  Listener:=TTestInsightListener.Create(aClient,Suite);
  if aClient.Options.ExecuteTests then
    begin
    TestResult := TTestResult.Create;
    if aClient.Options.TestSuite<>'' then
      AddSkips(TestResult,Suite,Suite.FindTest(aClient.Options.TestSuite));
    TestResult.AddListener(Listener);
    Suite.Run(TestResult);
    end
  else
    FreeAndNil(Listener);
end;

procedure RunRegisteredTests(OnCreated,Onerror : TTestInsightClientEvent; const aConfig : String = ''; const baseUrl: string = DefaultUrl);

    procedure DoCreateOK(aClient: TAbstractTestInsightClient);

    begin
      RunRegisteredTests(aClient);
      if Assigned(OnCreated) then
        OnCreated(aClient);
    end;

    procedure DoCreateError(aClient: TAbstractTestInsightClient);
    begin
      TestInsightLog.Log('Error in config, attempting execute anyway');
      if assigned(OnError) then
        OnError(aClient);
      DoCreateOK(aClient);
    end;


begin
  if not Assigned(GetTestRegistry) then
    Exit;
  CreateClient(@DoCreateOK,@DoCreateError,aConfig,BaseURL);
end;

{ TFPCUnitTestInsightHelper }

procedure TFPCUnitTestInsightHelper.FromTestFailure(ATest: TTest; aFailure: TTestFailure);

Const
  TestStepToPhase : Array[TTestStep] of TTestPhase
    = (tpSetUp, tpRunTest, spTearDown, tpNothing);


begin
  TestName:=aTest.TestSuiteName+'.'+aTest.TestName;
  TestClassName:=aTest.ClassName;
  TestUnitName:=aTest.UnitName;
  TestMethodName := aTest.TestName;
  if not Assigned(aFailure) then
    exit;
  TestExceptionMessage := aFailure.ExceptionMessage;
  TestExceptionClass:= aFailure.ExceptionClassName;
  TestIsIgnored:=aFailure.IsIgnoredTest;
  if aFailure.IsFailure then
    TestResult:=rtFailed
  else
    TestResult:=rtError;
  TestPhase:=TestStepToPhase[aFailure.TestLastStep];
  FailureLineNumber:=aFailure.LineNumber;
  FailureUnitName:=aFailure.UnitName;
  FailureMethodName:=aFailure.FailedMethodName;
  FailureSourceUnitName:=aFailure.SourceUnitName;
//  FailureLocationInfo:=aFailure.LocationInfo;
end;

{ TTestInsightTestListener }

constructor TTestInsightListener.Create(const aClient : TAbstractTestInsightClient; aRoot : TTest);

  function HaveTests (t : JSValue) : JSValue;
  begin
    fSelectedTests:=TStringDynArray(t);
  end;

begin
  inherited Create;
  fClient := aClient;
  fClient.GetTests._then(@haveTests);

  FRootTest:=aRoot;
  SendTestSuite;
end;

procedure TTestInsightListener.AddError(ATest: TTest; aError: TTestFailure);

var
  testResult: TTestInsightResult;
begin
  testResult := TTestInsightResult.Create;
  testResult.FromTestFailure(aTest,aError);
  testResult.TestResult := rtError;
  fClient.PostResult(testResult,false);
end;

procedure TTestInsightListener.AddFailure(ATest: TTest; aFailure: TTestFailure);
var
  testResult: TTestInsightResult;
begin
  testResult := TTestInsightResult.Create;
  testResult.FromTestFailure(aTest,aFailure);
  if aFailure.ExceptionMessage = SAssertNotCalled then
    testResult.TestResult := rtWarning
  else
    testResult.TestResult := rtFailed;
  fClient.PostResult(testResult,False);
  FLastError:=aTest;
end;


procedure TTestInsightListener.EndTestSuite(ATestSuite: TTestSuite);
begin
  if (aTestSuite=FRootTest) then
    fClient.FinishedTesting;
end;

procedure TTestInsightListener.StartTestSuite(ATestSuite: TTestSuite);
begin
  if (aTestSuite=FRootTest) then
    fClient.StartedTesting(FRootTest.CountTestCases);
end;

procedure TTestInsightListener.StartTest(ATest: TTest);

begin
  FStart:=Now;
end;

procedure TTestInsightListener.EndTest(ATest: TTest);

var
  testResult: TTestInsightResult;

begin
  if Not ({IsTestMethod(aTest) and} (fLastError <> Atest)) then
    exit;
  testResult := TTestInsightResult.Create;
  TestResult.TestName:=aTest.TestSuiteName+'.'+aTest.TestName;
  TestResult.TestResult:=rtPassed;
  testResult.TestDuration := MilliSecondsBetween(Now,FStart);
  testResult.TestUnitName := aTest.UnitName;
  testResult.TestClassName := ATest.ClassName;
  testResult.TestMethodName := aTest.TestName;
  fClient.PostResult(testResult,False);
end;


procedure TTestInsightListener.SendTestSuite;

Var
  aJSON : TJSONObject;

begin
  aJSON:=TestSuiteToJSON(FRootTest);
  try
    fClient.SetTestNames(aJSON);
  finally
    aJSON.Free;
  end;
end;

end.

