{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2023 by Michael Van Canneyt

    Test Insight client component.
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS} 
unit testinsightclient;
{$ENDIF}

{$mode ObjFPC}{$H+}

interface

uses
{$IFDEF FPC_DOTTEDUNITS} 
  System.Classes, System.SysUtils, System.Types, TestInsight.Protocol, FpWeb.Http.Client, FpJson.Data, System.Contnrs, System.IniFiles, JSAPi.JS;
{$ELSE}
  Classes, SysUtils, types, testinsightprotocol, weborworker, fpjson, contnrs, js;
{$ENDIF}

Type

  { TAbstractTestInsightClient }
  TLoadedProcedure = reference to procedure;

  TAbstractTestInsightClient = class (TObject)
  private
    FOptions : TTestInsightOptions;
    FPendingResultCount: Integer;
    FRequestTimeOut: cardinal;
    FResults : TFPObjectList;
    FBaseURL : String;
    procedure SetOptions(const value: TTestInsightOptions);
  protected
    function JSONToTests(const aJSON: string): TStringDynArray;
    // URL is Relative to base URL
    function ServerPost(const aURL: string; const aContent: string = ''): Boolean; async; virtual; abstract;
    function ServerGet(const aURL: string) : string; async; virtual; abstract;
    function ServerDelete(const aURL: string) : boolean; async; virtual; abstract;
    Function ConcatURL(const aURL : String) : String; virtual;
  Public
    const
      DefaultRequestTimeOut = 5000;
  public
    constructor Create(const aBaseURL : String); virtual;
    destructor Destroy; override;
    procedure LoadConfig(const aUrl : String; OnLoaded,OnError : TLoadedProcedure);
    procedure LoadConfig(aConfig: TJSObject);
    function GetServerOptions : TJSPromise;
    // The client will free the result.
    procedure PostResult(const testResult: TTestInsightResult; forceSend: Boolean);
    // The client will free the results.
    procedure PostResults(const testResults: array of TTestInsightResult; forceSend: Boolean);
    procedure StartedTesting(const totalCount: Integer);
    procedure FinishedTesting;
    procedure ClearTests;
    Procedure SetTestNames(aJSON : TJSONObject);
    function GetTests: TJSPromise;
    property Options: TTestInsightOptions read FOptions write SetOptions;
    Property BaseURL : String Read FBaseURL;
    Property PendingResultCount : Integer Read FPendingResultCount;
    Property RequestTimeout: cardinal Read FRequestTimeOut Write FRequestTimeout;
  end;

  TTestInsightClientEvent = reference to Procedure(aClient : TAbstractTestInsightClient);
  TTestInsightClientErrorEvent = reference to function(aClient : TAbstractTestInsightClient) : Boolean;

  { TTestInsightHTTPClient }

  TFetchConfigEvent = Procedure (Sender : TObject; aConfig : TJSObject) of object;

  TTestInsightHTTPClient = class(TAbstractTestInsightClient)
  private
    FOnCreateFetchOptions: TFetchConfigEvent;
  protected
    function CreateFetchOptions(const aMethod: String): TJSObject; virtual;
    function ServerPost(const aURL: string; const aContent: string = '') : boolean; async; override;
    Function ServerGet(const aURL: string) : string; async; override;
    function ServerDelete(const aURL: string) : boolean; async; override;
  public
    Constructor Create(Const aBaseURL : String); override;
    Destructor Destroy; override;
    Property OnCreateFetchOptions : TFetchConfigEvent Read FOnCreateFetchOptions Write FOnCreateFetchOptions;
  end;

  { TTestInsightLogger }

  TTestInsightLogger = class(TObject)
    Procedure Log(const Msg : string); virtual;
    Procedure Log(const Fmt : string; args : array of const);
    Procedure Debug(const value : JSValue); virtual;
  end;

var
  TestInsightLog : TTestInsightLogger;

implementation

{ TTestInsightHTTPClient }

Procedure WriteLog(const Msg : string);
begin
  if assigned(TestInsightLog) then
    TestInsightLog.Log(Msg)
end;

Procedure DebugLog(const value : JSValue);

begin
  if assigned(TestInsightLog) then
    TestInsightLog.Debug(Value)
end;


function TTestInsightHTTPClient.CreateFetchOptions(const aMethod : String) : TJSObject;

begin
  Result:=New(
    ['method',aMethod,
     'mode','cors',
     'signal',TJSAbortSignal.timeout(FRequestTimeout),
     'headers', new([
       'Content-Type','application/json'
     ])
    ]);
  If Assigned(FOnCreateFetchOptions) then
    FOnCreateFetchOptions(Self,Result);
end;

function TTestInsightHTTPClient.ServerPost(const aURL: string; const aContent: string = '') : boolean;

var
  opts : TJSObject;
  response: TJSResponse;

begin
  opts:=CreateFetchOptions('POST');
  opts['body']:=aContent;
  response:=await(TJSResponse,fetch(ConcatUrl(aURL),opts));
  result:=(response.status div 100)=2;
end;

function TTestInsightHTTPClient.ServerGet(const aURL: string): string;

var
  opts : TJSObject;
  response: TJSResponse;

begin
  opts:=CreateFetchOptions('GET');
  try
    response:=await(TJSResponse,fetch(ConcatUrl(aURL),opts));
    if (response.status div 100)=2 then
      Result:=await(Response.text)
    else
      Result:='';

  except
    on E : Exception do
      Writeln('Exception : ',E.Message);
    on JE : TJSError do
      Writeln('Exception : ',JE.Message);
  end;
end;

function TTestInsightHTTPClient.ServerDelete(const aURL: string) : boolean;

var
  opts : TJSObject;
  response: TJSResponse;

begin
  opts:=CreateFetchOptions('GET');
  response:=await(TJSResponse,fetch(ConcatUrl(aURL),opts));
  Result:=(response.status div 100)=2;
end;

constructor TTestInsightHTTPClient.Create(const aBaseURL: String);
begin
  inherited Create(aBaseURL);
end;

destructor TTestInsightHTTPClient.Destroy;
begin
  inherited Destroy;
end;


{ TAbstractTestInsightClient }

procedure TAbstractTestInsightClient.SetOptions(const value: TTestInsightOptions
  );
begin
  FOptions.Assign(Value);
end;


function TAbstractTestInsightClient.JSONToTests(const aJSON: string): TStringDynArray;

Var
  D : TJSONData;
  A : TJSONArray;
  I : Integer;

begin
  Result:=[];
  D:=GetJSON(aJSON);
  try
    if D=Nil then exit;
    if D.JSONType=jtArray then
      A:=D as TJSONArray
    else if (D.Count=1) and (D.Items[0].JSONType=jtArray) then
      A:=D.Items[0] as TJSONArray
    else
      A:=nil;
    if A<>Nil then
      begin
      SetLength(Result,a.Count);
      For I:=0 to Length(Result)-1 do
        Result[i]:=A.Strings[i];
      end;
  finally
    D.Free;
  end;
end;

function TAbstractTestInsightClient.ConcatURL(const aURL: String): String;
begin
  Result:=fBaseURL;
  if (Result<>'') and (aURL<>'') and (Result[Length(Result)]<>'/') then
    Result:=Result+'/';
  Result:=Result+aURL;
end;

constructor TAbstractTestInsightClient.Create(const aBaseURL: String);
begin
  FBaseURL:=aBaseURL;
  FOptions:=TTestInsightOptions.Create;
  FResults:=TFPObjectList.Create(False);
  FRequestTimeOut:=DefaultRequestTimeOut;
end;

destructor TAbstractTestInsightClient.Destroy;
begin
  FResults.Clear;
  FreeAndNil(FResults);
  FreeAndNil(FOptions);
  inherited Destroy;
end;

procedure TAbstractTestInsightClient.LoadConfig(const aUrl: String; OnLoaded, OnError: TLoadedProcedure);

  function doerror(resp : jsvalue) : jsvalue;

  begin
    if assigned(OnError) then
      OnError
    else
      begin
      console.log('Error loading testinsight client config:');
      console.debug(resp);
      end;
  end;

  function jsonok(resp : jsvalue) : jsvalue;

  var
    V : TJSObject absolute resp;

  begin
    LoadConfig(V);
    if assigned(OnLoaded) then
      OnLoaded();
  end;

  function loadok(resp : jsvalue) : jsvalue;

  var
    Response : TJSResponse absolute resp;

  begin
    if Response.status=200 then
      Response.json._then(@jsonok,@doError)
    else
      DoError(TJSError.New(Response.statusText));
  end;


var
  Opts : TJSObject;

begin
  Opts:=New([
    'method','GET',
    'mode','cors',
    'signal',TJSAbortSignal.timeout(FRequestTimeout)
  ]);
  Fetch(aUrl,Opts)._then(@LoadOK,@doError)
end;

procedure TAbstractTestInsightClient.LoadConfig(aConfig: TJSObject);

begin
  if aConfig.hasOwnProperty(KeyBaseURL) and isString(aConfig[KeyBaseURL]) then
    FBaseURL:=string(aConfig[KeyBaseURL]);
  if aConfig.hasOwnProperty(keyShowProgress) and isBoolean(aConfig[keyShowProgress]) then
    Options.ShowProgress:=Boolean(aConfig[keyShowProgress]);
  if aConfig.hasOwnProperty(KeyExecuteTests) and isBoolean(aConfig[KeyExecuteTests]) then
    Options.ExecuteTests:=Boolean(aConfig[KeyExecuteTests]);
  if aConfig.hasOwnProperty(KeySuite) and isString(aConfig[KeySuite]) then
    Options.TestSuite:=String(aConfig[KeySuite]);
end;

function TAbstractTestInsightClient.GetServerOptions : TJSPromise;

  procedure DoOptions(resolve, reject: TJSPromiseResolver); async;

  var
    S : String;

  begin
    try
      S:=Await(ServerGet(PathOptions));
      Options.FromJSON(S);
      resolve(Options);
    except
      on E : Exception do
        Reject(E);
      on JE : TJSError do
        Reject(JE);
    end;
  end;

begin
  Result:=TJSPromise.new(@DoOptions);
end;

procedure TAbstractTestInsightClient.PostResult(
  const testResult: TTestInsightResult; forceSend: Boolean);
begin
  PostResults([testResult],forceSend);
end;

procedure TAbstractTestInsightClient.PostResults(
  const testResults: array of TTestInsightResult; forceSend: Boolean);

Var
  Res : TTestInsightResult;
  J : TJSONArray;
  O : TJSONOBject;


begin
  if ForceSend or (Options.ShowProgress and Options.ExecuteTests) then
    begin
    J:=TJSONArray.Create;
    try
      For Res in testResults do
        begin
        O:=TJSONObject.Create;
        J.Add(O);
        Res.ToJSON(O);
        Res.Free;
        end;
      ServerPost(pathResults,J.AsJSON);
    finally
      J.Free;
    end;
    end
  else
    For Res in TestResults do
      FResults.Add(res);
end;

procedure TAbstractTestInsightClient.StartedTesting(const totalCount: Integer);
begin
  ServerPost(Format('%s?%s=%d', [pathStarted,qryTotalCount,Totalcount]),'');
end;

procedure TAbstractTestInsightClient.FinishedTesting;

Var
  A : Array of TTestInsightResult;
  Len,I : Integer;

begin
  A:=[];
  Len:=FResults.Count;
  if (Len>0) then
    begin
    Setlength(A,Len);
    For I:=0 to Len-1 do
      A[I]:=TTestInsightResult(FResults[i]);
    try
      PostResults(A,True);
    finally
      FResults.Clear;
    end;
    end;
  ServerPost(pathFinished,'');
end;

procedure TAbstractTestInsightClient.ClearTests;
begin
  ServerDelete(pathResults);
end;

procedure TAbstractTestInsightClient.SetTestNames(aJSON : TJSONObject);

begin
  ServerPost('',aJSON.AsJSON);
end;

function TAbstractTestInsightClient.GetTests: TJSPromise;

  procedure DoGetTests(resolve, reject: TJSPromiseResolver); async;

  begin
    try
      resolve(JSONToTests(await(ServerGet(''))));
    except
      on E : Exception do
        Reject(E);
      on JE : TJSError do
        Reject(JE);
    end;
  end;

begin
  Result:=TJSPromise.New(@DoGetTests);
end;


{ TTestInsightLogger }

procedure TTestInsightLogger.Log(const Msg: string);
begin
  console.log(Msg);
end;


procedure TTestInsightLogger.Log(const Fmt: string; args: array of const);
begin
  Log(Format(Fmt,Args));
end;

procedure TTestInsightLogger.Debug(const value: JSValue);
begin
  console.debug(Value);
end;


initialization
  TestInsightLog:=TTestInsightLogger.Create;
end.

