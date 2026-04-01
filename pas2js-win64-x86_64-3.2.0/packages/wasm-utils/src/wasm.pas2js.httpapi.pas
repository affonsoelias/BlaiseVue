{
    This file is part of the Pas2JS run time library.
    
    Provides a Webassembly module with HTTP protocol capabilities
    Copyright (c) 2024 by Michael Van Canneyt

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit wasm.pas2js.httpapi;

{$mode ObjFPC}
{$modeswitch externalclass}

{ $DEFINE NOLOGAPICALLS}

interface

uses
  {$IFDEF FPC_DOTTEDUNITS}
  System.SysUtils, JSApi.JS, BrowserApi.WebOrWorker,  {$IFDEF JOB_WORKER} BrowserApi.WebWorker {$ELSE}  BrowserApi.Web {$ENDIF}, Wasi.Env, wasm.http.shared, Rtl.WorkerCommands;
  {$ELSE}
  SysUtils, JS, WebOrWorker, {$IFDEF JOB_WORKER} WebWorker {$ELSE} Web {$ENDIF}, WasiEnv, types, wasm.http.shared, Rtl.WorkerCommands;
  {$ENDIF}

const
  cmdOpenURL = 'openUrl';

Type
  TWasmHTTPAPI = Class;
  TWasmHTTPFetch = Class;

  TOpenURLCommand = class external name 'Object' (TCustomWorkerCommand)
    URL : String;
    Flags : Integer;
  end;

  { TOpenURLCommandHelper }

  TOpenURLCommandHelper = class helper (TCustomWorkerCommandHelper) for TOpenURLCommand
    class function CreateURL(aURL : String; aFlags : Integer) : TOpenURLCommand; static;
  end;

  TWasmHTTPRequest = Record
    Url : String;
    Method : String;
    Headers : TStringDynArray;
    BodyIsString : Boolean;
    Body : TJSArrayBuffer;
    BodyAsText : string;
    Integrity : String;
    Redirect: string;
    Cache : String;
    KeepAlive : Boolean;
    Mode : String;
    Priority : String;
    Referrer : String;
    ReferrerPolicy : String;
    AbortSignal : Boolean;
    Credentials: String;
  end;

  PWasmHTTPRequest = TWasmPointer;
  PLongint = TWasmPointer;
  PByte = TWasmPointer;

  { TWasmHTTPFetch }

  TWasmHTTPFetch = Class(TObject)
  Private
    FAPI : TWasmHTTPAPI;
    FID : TWasmHTTPRequestID;
    FUserData : TWasmPointer;
    FRequestData : TWasmHTTPRequest;
    FResponse : TJSResponse;
    FheaderNames : TStringDynArray;
    FAbortController : TJSAbortController;
    FResultBody : TJSArrayBuffer;
    FRequestError : String;
    FInProgress : Boolean;
    function GetHeaderName(aIndex : Longint): String;
    function GetHeaderCount: Integer;
  Public
    Constructor Create(aAPI: TWasmHTTPAPI; aID : TWasmHTTPRequestID; aUserData : TWasmPointer; const aRequestData : TWasmHTTPRequest);
    Procedure Execute; async;
    Property ID : TWasmHTTPRequestID Read FID;
    Property UserData : TWasmPointer Read FUserData;
    Property RequestData : TWasmHTTPRequest Read FRequestData;
    Property Response : TJSResponse Read FResponse;
    Property HeaderNames[aIndex : Longint] : String Read GetHeaderName;
    Property HeaderCount : Integer Read GetHeaderCount;
    Property InProgress : Boolean Read FInProgress;
    Property RequestError : String Read FRequestError;
  end;

  { TWasmHTTPAPI }

  TWasmHTTPAPI = class(TImportExtension)
  private
    FNextRequestID : TWasmHTTPRequestID;
    FRequests : TJSOBject;
    class function ContentTypeIsString(aType: String): boolean;
    function GetLogApiCalls: Boolean;
    procedure HandleOpenURLMessage(aCommand: TOpenURLCommand);
    function ReadRequest(aRequest :PWasmHTTPRequest) : TWasmHTTPRequest;
    function RequestExecute(aRequestID: TWasmHTTPRequestID): TWasmHTTPResult;
    procedure SetLogApiCalls(AValue: Boolean);
  Protected
    Procedure LogCall(const Msg : String);
    Procedure LogCall(Const Fmt : String; const Args : Array of const);
    Procedure DoneRequest(aFetch : TWasmHTTPFetch);
    Function CreateRequestID : TWasmHTTPRequestID;
    Function FetchByID(aID : TWasmHTTPRequestID) : TWasmHTTPFetch;
    procedure DoOpenURL(aURL: String; aFlags: integer);
    function HandleOpenURL(aURL: TWasmPointer; aURLLen: Longint; aFlags: Integer): Integer;
    function RequestAllocate(aRequest : PWasmHTTPRequest; aUserData : TWasmPointer; aRequestID : PWasmHTTPRequestID) : TWasmHTTPResult;
    function RequestDeallocate(aRequestID : TWasmHTTPRequestID) : TWasmHTTPResult;
    function RequestAbort(aRequestID : TWasmHTTPRequestID) : TWasmHTTPResult;
    function ResponseGetStatus(aRequestID : TWasmHTTPRequestID; aStatus : PLongint) : TWasmHTTPResult;
    function ResponseGetStatusText(aRequestID: TWasmHTTPRequestID; aStatusText: PByte; aMaxTextLen: PLongint): TWasmHTTPResult;
    function ResponseGetHeaderCount(aRequestID : TWasmHTTPRequestID; aHeaderCount : PLongint) : TWasmHTTPResult;
    function ResponseGetHeaderName(aRequestID : TWasmHTTPRequestID; aHeaderIdx: Longint; aHeader : PByte; aMaxHeaderLen : PLongint) : TWasmHTTPResult;
    function ResponseGetHeader(aRequestID : TWasmHTTPRequestID; aHeaderName: PByte; aHeaderLen : PLongint; aHeader : PByte; aMaxHeaderLen : Longint) : TWasmHTTPResult;
    function ResponseGetBody(aRequestID : TWasmHTTPRequestID; aBody : PByte; aMaxBodyLen : PLongint) : TWasmHTTPResult;
  Public
    Constructor Create(aEnv: TPas2JSWASIEnvironment); override;
    Procedure FillImportObject(aObject: TJSObject); override;
    Function ImportName : String; override;
    property LogApiCalls : Boolean Read GetLogApiCalls Write SetLogApiCalls;
  end;

Function CacheToString(aCache : Integer) : String;

implementation

uses strutils;

Const
  CacheNames : Array[0..5] of string = ('default','no-store','reload','no-cache','force-cache','only-if-cached');
  ModeNames : Array[0..4] of string = ('cors','same-origin','no-cors','navigate','websocket');
  PriorityNames : Array[0..2] of string = ('auto','low','high');
  RedirectNames : Array[0..2] of string = ('follow','error','manual');
  CredentialNames : Array[0..2] of string = ('same-origin','omit','include');

Function CacheToString(aCache : Integer) : String;

begin
  Result:='';
  if (aCache>=0) and (aCache<=5) then
    Result:=CacheNames[aCache];
end;

Function RedirectToString(aRedirect : Integer) : String;

begin
  Result:='';
  if (aRedirect>=0) and (aRedirect<=2) then
    Result:=RedirectNames[aRedirect];
end;


function KeepAliveToBool(const aKeepAlive : Integer) : boolean;

begin
  Result:=aKeepAlive<>0;
end;

function AbortSignalToBool(const aKeepAlive : Integer) : boolean;

begin
  Result:=aKeepAlive<>0;
end;

function ModeToString(const aMode : Integer) : string;


begin
  Result:='';
  if (aMode>=0) and (aMode<=4) then
    Result:=ModeNames[aMode];
end;

function PriorityToString(const aPriority : Integer) : string;

begin
  Result:='';
  if (aPriority>=0) and (aPriority<=2) then
    Result:=PriorityNames[aPriority];
end;

function CredentialsToString(const aCredentials : Integer) : string;

begin
  Result:='';
  if (aCredentials>=0) and (aCredentials<=2) then
    Result:=CredentialNames[aCredentials];
end;

{ TWasmHTTPFetch }

function TWasmHTTPFetch.GetHeaderCount: Integer;

var
  It : TJSIterator;
  Itm : TJSIteratorValue;

begin
  if (Length(FheaderNames)=0) and Assigned(FResponse) then
    begin
    It:=FResponse.headers.Keys;
    Itm:=It.next;
    While not Itm.done do
      begin
      TJSArray(FheaderNames).Push(Itm.value);
      Itm:=It.Next;
      end;
    end;
  Result:=Length(FHeaderNames);
end;

function TWasmHTTPFetch.GetHeaderName(aIndex : Longint): String;
begin
  if (aIndex>=0) and (aIndex<Length(FHeaderNames)) then
    Result:=FHeaderNames[aIndex]
  else
    Result:='';
end;

constructor TWasmHTTPFetch.Create(aAPI: TWasmHTTPAPI; aID: TWasmHTTPRequestID; aUserData: TWasmPointer;
  const aRequestData: TWasmHTTPRequest);
begin
  FAPI:=aAPI;
  FID:=aID;
  FUserData:=aUserData;
  FRequestData:=aRequestData;
  FheaderNames:=[];
  FInProgress:=True;
end;

procedure TWasmHTTPFetch.Execute; async;

var
  lResponse : TJSResponse;
  lBuf : TJSarrayBuffer;
  lRequest : TJSRequest;
  lHeaders,lRequestInit : TJSObject;

  HNV : TStringDynArray;
  H,N,V : String;

  Procedure MaybeInit(const aName,aValue : String);

  begin
    if aValue<>'' then
      lRequestInit[aName]:=aValue;
  end;

begin
  lRequestInit:=TJSObject.New;
  if Length(FRequestData.Headers)>0 then
    begin
    lHeaders:=TJSObject.new;
    lRequestInit['headers']:=lHeaders;
    for H in FRequestData.Headers do
      begin
      HNV:=TJSString(H).split(':');
      V:='';
      N:=Trim(HNV[0]);
      if Length(HNV)>1 then
        V:=Trim(HNV[1]);
      lHeaders[N]:=V;
      end;
    end;
  With FRequestData do
    begin
    MaybeInit('mode',Mode);
    MaybeInit('method',Method);
    MaybeInit('cache',Cache);
    MaybeInit('integrity',Integrity);
    if Assigned(Body) then
      lRequestInit['body']:=Body
    else if BodyIsString and (BodyAsText<>'') then
      lRequestInit['body']:=BodyAsText;
    if KeepAlive then
    lRequestInit['keepalive']:=KeepAlive;
    MaybeInit('redirect',Redirect);
    MaybeInit('priority',Priority);
    MaybeInit('referrer',Referrer);
    MaybeInit('referrerPolicy',ReferrerPolicy);
    if AbortSignal then
      begin
      FAbortController:=TJSAbortController.New;
      lRequestInit['signal']:=FAbortController.Signal;
      end;
    end;
  lRequest:=TJSRequest.New(FRequestData.Url,lRequestInit);
  lBuf:=Nil;
  try
    {$IFDEF JOB_WORKER}
    lResponse:=aWait(TJSResponse,webworker.fetch(lRequest));
    {$ELSE}
    lResponse:=aWait(Window.Asyncfetch(lRequest));
    {$ENDIF}
    lBuf:=aWait(TJSArrayBuffer,lResponse.arrayBuffer);
    fResultBody:=lBuf;
    FResponse:=lResponse;
  except
    on E : TJSError do
      FRequestError:=e.Message;
    on O : TJSObject do
      if  O.hasOwnProperty('message') and IsString(O.Properties['message']) then
       FRequestError:=String(O.Properties['message']);
  end;
  FInProgress:=False;
  // Notify the API
  if assigned(FAPI) then
    FAPI.DoneRequest(Self);
end;

{ TOpenURLCommandHelper }

class function TOpenURLCommandHelper.CreateURL(aURL: String; aFlags: Integer): TOpenURLCommand;
begin
  Result:=TOpenURLCommand(CreateCommand(cmdOpenURL));
  TOpenURLCommand(Result).URL:=aURL;
  TOpenURLCommand(Result).Flags:=aFlags;
end;

{ TWasmHTTPAPI }

class function TWasmHTTPAPI.ContentTypeIsString(aType : String) : boolean;

begin
  Result:=False;
  aType:=LowerCase(ExtractWord(1,aType,';'));
  case LowerCase(aType) of
    'application/json',
    'text/text',
    'text/html' : Result:=True;
  end;
end;

function TWasmHTTPAPI.GetLogApiCalls: Boolean;
begin
  Result:=LogAPI;
end;

function TWasmHTTPAPI.ReadRequest(aRequest: PWasmHTTPRequest): TWasmHTTPRequest;

Var
  P : TWasmPointer;
  V : TJSDataView;
  HeaderCount : Integer;

  Function GetInt32 : longint;
  begin
    Result:=v.getInt32(P,Env.IsLittleEndian);
    Inc(P,SizeInt32);
  end;

  Function GetString : string;

  var
    Ptr,Len : Longint;

  begin
    Ptr:=v.getInt32(P,Env.IsLittleEndian);
    Inc(P,SizeInt32);
    Len:=v.getInt32(P,Env.IsLittleEndian);
    Inc(P,SizeInt32);
    Result:=Env.GetUTF8StringFromMem(Ptr,Len);
  end;

  Function GetStringFromAddr(Ptr : Longint) : string;

  var
    SPtr,Len : Longint;

  begin
    SPtr:=v.getInt32(Ptr,Env.IsLittleEndian);
    Inc(Ptr,SizeInt32);
    Len:=v.getInt32(Ptr,Env.IsLittleEndian);
    Result:=Env.GetUTF8StringFromMem(SPtr,Len);
  end;

  Function GetBuffer : TJSArrayBuffer;

  var
    Ptr,Len : Longint;

  begin
    Result:=Nil;
    Ptr:=v.getInt32(P,Env.IsLittleEndian);
    Inc(P,SizeInt32);
    Len:=v.getInt32(P,Env.IsLittleEndian);
    Inc(P,SizeInt32);
    if Len>0 then
      Result:=Env.Memory.buffer.slice(Ptr,Ptr+Len);
  end;

var
  i : Integer;
  Hdrs : Longint;
  lHeader,lHeaderName,lHeaderValue : String;
begin
  v:=getModuleMemoryDataView;
  P:=aRequest;
  // Order is important !
  Result.Url:=GetString;
  Result.Method:=GetString;
  HeaderCount:=v.getInt32(P,Env.IsLittleEndian);
  SetLength(Result.Headers,HeaderCount);
  inc(P,SizeInt32);
  // Pointer to list of strings
  Hdrs:=v.getInt32(P,Env.IsLittleEndian);
  inc(P,SizeInt32);
  for I:=0 to HeaderCount-1 do
    begin
    lHeader:=GetStringFromAddr(Hdrs);
    Result.Headers[i]:=lHeader;
    lHeaderName:=Trim(ExtractWord(1,lHeader,':'));
    lHeaderValue:=Trim(ExtractWord(2,lHeader,':'));
    if SameText(lheaderName,'Content-Type') then
      Result.BodyIsString:=ContentTypeIsString(lHeaderValue);
    inc(Hdrs,SizeInt32*2);
    end;
  if Result.BodyIsString then
    Result.BodyAsText:=GetString
  else
    Result.Body:=GetBuffer;
  Result.Integrity:=GetString;
  Result.Redirect:=RedirectToString(GetInt32);
  Result.Cache:=CacheToString(GetInt32);
  Result.KeepAlive:=KeepAliveToBool(GetInt32);
  Result.Mode:=ModeToString(GetInt32);
  Result.Priority:=PriorityToString(GetInt32);
  Result.Referrer:=GetString;
  Result.ReferrerPolicy:=GetString;
  Result.AbortSignal:=AbortSignalToBool(GetInt32);
  Result.Credentials:=CredentialsToString(GetInt32);
end;

procedure TWasmHTTPAPI.LogCall(const Msg: String);
begin
  {$IFNDEF NOLOGAPICALLS}
  if LogAPI then
    DoLog(Msg);
  {$ENDIF}
end;

procedure TWasmHTTPAPI.LogCall(const Fmt: String; const Args: array of const);
begin
  {$IFNDEF NOLOGAPICALLS}
  if LogAPI then
    DoLog(Fmt,Args);
  {$ENDIF}
end;

type
  TDoneCallback = Function(aRequestID : TWasmHTTPRequestID; aUserData : TWasmPointer; aStatus : TWasmHTTPResponseStatus) : TWasmHTTPResponseResult;

procedure TWasmHTTPAPI.DoneRequest(aFetch: TWasmHTTPFetch);

var
  Exp : JSValue;
  Callback : TDoneCallback absolute exp;
  Res,Stat : Longint;
  doDispose : Boolean;

begin
  doDispose:=True;
  Exp:=InstanceExports[httpFN_ResponseCallback];
  if aFetch.FRequestError<>'' then
    Stat:=-1
  else
    Stat:=aFetch.Response.status;
  if isFunction(Exp) then
    begin
    Res:=Callback(aFetch.ID,aFetch.UserData,Stat);
    DoDispose:=(Res=WASMHTTP_RESPONSE_DEALLOCATE);
    end
  else
    console.error('No request callback available!');
  if DoDispose then
    begin
    FRequests[IntToStr(aFetch.ID)]:=undefined;
    FreeAndNil(aFetch);
    end;
end;

function TWasmHTTPAPI.CreateRequestID: TWasmHTTPRequestID;
begin
  Inc(FNextRequestID);
  Result:=FNextRequestID;
end;

function TWasmHTTPAPI.FetchByID(aID: TWasmHTTPRequestID): TWasmHTTPFetch;

var
  Value : JSValue;

begin
  Value:=FRequests[IntToStr(aID)];
  if isObject(Value) then
    Result:=TWasmHTTPFetch(Value)
  else
    Result:=Nil;
end;

function TWasmHTTPAPI.RequestAllocate(aRequest: PWasmHTTPRequest; aUserData: TWasmPointer; aRequestID: PWasmHTTPRequestID
  ): TWasmHTTPResult;

var
  lReq : TWasmHTTPRequest;
  lID : TWasmHTTPRequestID;
  lfetch : TWasmHTTPFetch;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.RequestAllocate([%x],[%x],[%x])',[aRequest,aUserData,aRequestID]);
  {$ENDIF}
  lReq:=ReadRequest(aRequest);
  if (lReq.Url='') then
    Exit(WASMHTTP_RESULT_NO_URL);
  lID:=CreateRequestID;
  lFetch:=TWasmHTTPFetch.Create(Self,lID,aUserData,lReq);
  FRequests[IntToStr(lID)]:=lFetch;
  env.SetMemInfoInt32(aRequestID,lID);
  Result:=WASMHTTP_RESULT_SUCCESS;
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.RequestAllocate([%x],[%x]) => %d',[aRequest,aUserData,lID]);
  {$ENDIF}
end;

function TWasmHTTPAPI.RequestExecute(aRequestID: TWasmHTTPRequestID): TWasmHTTPResult;

var
  lfetch : TWasmHTTPFetch;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.RequestExecute(%d)',[aRequestID]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  lFetch.Execute;
  Result:=WASMHTTP_RESULT_SUCCESS;
end;

procedure TWasmHTTPAPI.SetLogApiCalls(AValue: Boolean);
begin
  LogAPI:=aValue;
end;

function TWasmHTTPAPI.RequestDeallocate(aRequestID: TWasmHTTPRequestID): TWasmHTTPResult;

var
  lFetch : TWasmHTTPFetch;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.RequestDeAllocate(%d)',[aRequestID]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
end;

function TWasmHTTPAPI.RequestAbort(aRequestID: TWasmHTTPRequestID): TWasmHTTPResult;

var
  lFetch : TWasmHTTPFetch;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.RequestAbort(%d)',[aRequestID]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
end;

function TWasmHTTPAPI.ResponseGetStatus(aRequestID: TWasmHTTPRequestID; aStatus: PLongint): TWasmHTTPResult;
var
  lFetch : TWasmHTTPFetch;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.ResponseGetStatus(%d,[%x])',[aRequestID,aStatus]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  if lFetch.InProgress then
    Exit(WASMHTTP_RESULT_INPROGRESS);
  Env.SetMemInfoInt32(aStatus,lFetch.Response.status);
  Result:=WASMHTTP_RESULT_SUCCESS;
end;

function TWasmHTTPAPI.ResponseGetStatusText(aRequestID: TWasmHTTPRequestID; aStatusText: PByte; aMaxTextLen: PLongint
  ): TWasmHTTPResult;
var
  lFetch : TWasmHTTPFetch;
  v : TJSDataView;
  Written,MaxLen : Longint;
  S : String;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.ResponseGetStatusText(%d,[%x],[%x])',[aRequestID,aStatusText,aMaxTextlen]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  if lFetch.InProgress then
    Exit(WASMHTTP_RESULT_INPROGRESS);
  v:=getModuleMemoryDataView;
  MaxLen:=v.getInt32(aMaxTextLen,Env.IsLittleEndian);
  S:=lFetch.Response.statusText;
  Written:=Env.SetUTF8StringInMem(aStatusText,MaxLen,S);
  Env.SetMemInfoInt32(aMaxTextLen,Abs(Written));
  if Written<0 then
    Result:=WASMHTTP_RESULT_INSUFFICIENTMEM
  else
    Result:=WASMHTTP_RESULT_SUCCESS;
end;

function TWasmHTTPAPI.ResponseGetHeaderCount(aRequestID: TWasmHTTPRequestID; aHeaderCount: PLongint): TWasmHTTPResult;

var
  lFetch : TWasmHTTPFetch;
  lCount : Longint;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.ResponseGetHeaderCount(%d,[%x])',[aRequestID,aHeaderCount]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  if lFetch.InProgress then
    Exit(WASMHTTP_RESULT_INPROGRESS);
  lCount:=lFetch.HeaderCount;
  Env.SetMemInfoInt32(aHeaderCount,lCount);
  Result:=WASMHTTP_RESULT_SUCCESS;
end;

function TWasmHTTPAPI.ResponseGetHeaderName(aRequestID: TWasmHTTPRequestID; aHeaderIdx: Longint; aHeader: PByte;
  aMaxHeaderLen: PLongint): TWasmHTTPResult;

var
  lFetch : TWasmHTTPFetch;
  S : String;
  MaxLen,Written : Longint;
  v : TJSDataView;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.RequestGetHeaderName(%d,%d,[%x],[%x])',[aRequestID,aHeaderIdx,aHeader,aMaxHeaderLen]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  if lFetch.InProgress then
    Exit(WASMHTTP_RESULT_INPROGRESS);
  V:=getModuleMemoryDataView;
  MaxLen:=v.getInt32(aMaxheaderLen,Env.IsLittleEndian);
  S:=lFetch.HeaderNames[aHeaderIdx];
  Written:=Env.SetUTF8StringInMem(aHeader,MaxLen,S);
  Env.SetMemInfoInt32(aMaxheaderLen,Abs(Written));
  if Written<0 then
    Result:=WASMHTTP_RESULT_INSUFFICIENTMEM
  else
    Result:=WASMHTTP_RESULT_SUCCESS;
end;

function TWasmHTTPAPI.ResponseGetHeader(aRequestID: TWasmHTTPRequestID; aHeaderName: PByte; aHeaderLen: PLongint; aHeader: PByte;
  aMaxHeaderLen: Longint): TWasmHTTPResult;
var
  lFetch : TWasmHTTPFetch;
  lHeader, lName : String;
  Written,Maxlen : Longint;
  v : TJSDataView;
begin
  v:=getModuleMemoryDataView;
  lName:=Env.GetUTF8StringFromMem(aHeaderName,aHeaderLen);
  MaxLen:=v.getInt32(aMaxHeaderLen,Env.IsLittleEndian);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.ResponseGetHeader(%d,"%s",[%x])',[aRequestID,lName,aHeader,aMaxHeaderLen]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  if lFetch.InProgress then
    Exit(WASMHTTP_RESULT_INPROGRESS);
  lHeader:=lfetch.Response.headers[lName];
  Written:=Env.SetUTF8StringInMem(aHeader,MaxLen,lheader);
  Env.SetMemInfoInt32(aMaxheaderLen,Abs(Written));
  if Written<0 then
    Result:=WASMHTTP_RESULT_INSUFFICIENTMEM
  else
    Result:=WASMHTTP_RESULT_SUCCESS;
end;

function TWasmHTTPAPI.ResponseGetBody(aRequestID: TWasmHTTPRequestID; aBody: PByte; aMaxBodyLen: PLongint): TWasmHTTPResult;
var
  lFetch : TWasmHTTPFetch;
  lwasmMem,lUint8Array : TJSUint8Array;
  v : TJSDataView;
  bodyLen,maxLen : longint;
begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.ResponseGetBody([%x],[%x],[%x])',[aRequestID,aBody,aMaxBodyLen]);
  {$ENDIF}
  lfetch:=FetchByID(aRequestID);
  if not Assigned(lFetch) then
    Exit(WASMHTTP_RESULT_INVALIDID);
  if lFetch.InProgress then
    Exit(WASMHTTP_RESULT_INPROGRESS);
  if Not Assigned(lFetch.FResultBody) then
    begin
    Env.SetMemInfoInt32(aMaxBodyLen,0);
    exit;
    end;
  v:=getModuleMemoryDataView;
  MaxLen:=v.getInt32(aMaxBodyLen,Env.IsLittleEndian);
  bodyLen:=lFetch.FResultBody.byteLength;
  Env.SetMemInfoInt32(aMaxBodyLen,bodyLen);
  if (MaxLen<bodyLen) then
    Exit(WASMHTTP_RESULT_INSUFFICIENTMEM);
  lUint8Array:=TJSUint8Array.new(lFetch.FResultBody);
  lwasmMem:=TJSUint8Array.New(v.buffer);
  lWasmMem._set(lUint8Array,aBody);
  Exit(WASMHTTP_RESULT_SUCCESS);
end;


constructor TWasmHTTPAPI.Create(aEnv: TPas2JSWASIEnvironment);
begin
  inherited Create(aEnv);
  FRequests:=TJSOBject.new;
  TCommandDispatcher.Instance.specialize AddCommandHandler<TOpenURLCommand>(cmdOpenURL,@HandleOpenURLMessage);
end;

procedure TWasmHTTPAPI.DoOpenURL(aURL : String; aFlags : integer);
{$IFNDEF JOB_WORKER}
var
  win: TJSWindow;
{$ENDIF}
begin
{$IFNDEF JOB_WORKER}
  win:=Window.open(aURL,'_blank');
{$ENDIF}
end;

procedure TWasmHTTPAPI.HandleOpenURLMessage(aCommand : TOpenURLCommand);

begin
  {$IFNDEF JOB_WORKER}
  Writeln('Handling open url message');
  DoOpenURL(aCommand.URL,aCommand.Flags);
  {$ELSE}
  Writeln('forwarding open url message');
  aCommand[cFldSender]:=undefined;
  TCommandDispatcher.Instance.SendCommand(aCommand);
  {$ENDIF}
end;

function TWasmHTTPAPI.HandleOpenURL(aURL : TWasmPointer; aURLLen : Longint; aFlags : Integer) : Integer;

var
  lURL : String;
begin
  lURL:=Env.GetUTF8StringFromMem(aURL,aURLLen);
  Writeln('Handling open url call ',aURL);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('HTTP.OpenURL(%s,%d)',[lURL,aFlags]);
  {$ENDIF}
  {$IFDEF JOB_WORKER}
  Writeln('sending openurl command');
  TCommandDispatcher.Instance.SendCommand(TOpenURLCommand.CreateURL(lURL,aFlags));
  {$ELSE}
  DoOpenURL(lURL,aFlags);
  {$ENDIF}
end;

procedure TWasmHTTPAPI.FillImportObject(aObject: TJSObject);
begin
  AObject[httpFN_RequestAllocate]:=@RequestAllocate;
  AObject[httpFN_RequestExecute]:=@RequestExecute;
  AObject[httpFN_RequestDeAllocate]:=@RequestDeallocate;
  AObject[httpFN_RequestAbort]:=@RequestAbort;
  AObject[httpFN_ResponseGetStatus]:=@ResponseGetStatus;
  AObject[httpFN_ResponseGetStatusText]:=@ResponseGetStatusText;
  AObject[httpFN_ResponseGetHeaderName]:=@ResponseGetHeaderName;
  AObject[httpFN_ResponseGetHeaderCount]:=@ResponseGetHeaderCount;
  AObject[httpFN_ResponseGetHeader]:=@ResponseGetHeader;
  AObject[httpFN_ResponseGetBody]:=@ResponseGetBody;
  AObject[httpFN_OpenURL]:=@HandleOpenURL;
end;

function TWasmHTTPAPI.ImportName: String;
begin
  Result:=httpExportName
end;

end.

