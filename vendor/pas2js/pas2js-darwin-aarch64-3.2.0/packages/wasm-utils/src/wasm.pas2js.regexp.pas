{
    This file is part of the Free Component Library

    Webassembly RegExp API - Provide API to webassembly program
    Copyright (c) 2024 by Michael Van Canneyt michael@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit wasm.pas2js.regexp;

{$mode ObjFPC}
{ $define NOLOGAPICALLS}
interface

uses
  sysutils, js, wasienv, wasm.regexp.shared, types;

Type
  PByte = TWasmPointer;
  PLongint = TWasmPointer;
  TIndexArray = Array[0..1] of Longint;

  { TWasmRegexp }

  TWasmRegexp = Class(TObject)
  private
    FID: TWasmRegexpID;
    FRegExp: TJSRegExp;
    FRes: TJSObject;
    FGroupNames : TStringDynArray;
    procedure GetGroupNames;
  Public
    Constructor Create(aRegex : TJSRegexp; aID : TWasmRegexpID);
    Procedure Exec(S : String);
    Function Test(S : String) : Boolean;
    Function HaveResult : Boolean;
    Function ResultIndex : Integer;
    Function ResultMatchCount : Integer;
    Function GetMatch(aIndex: Integer) : String;
    Function GetMatchIndexes(aIndex: Integer) : TIndexArray;
    Function GetGroupIndexes(aName: String) : TIndexArray;
    Function GetGroupCount : Integer;
    Function GetGroupName(aIndex : Integer) : String;
    Function GetGroupValue(const aName : String) : String;
    Property RegExp : TJSRegExp Read FRegExp;
    Property Res : TJSObject Read FRes;
    Property ID : TWasmRegexpID Read FID;
  end;
  { TWasmRegExpAPI }

  TWasmRegExpAPI = class(TImportExtension)
  Private
    FNextID : TWasmRegexpID;
    FRegExps : TJSObject;
    function GetLogAPICalls: Boolean;
    procedure SetLogAPICalls(AValue: Boolean);
  protected
    Procedure LogCall(const Msg : String);
    Procedure LogCall(Const Fmt : String; const Args : Array of const);
    Function GetNextID : TWasmRegExpID;
    Function FindRegExp(aID : TWasmRegExpID) : TWasmRegExp;
    function RegExpAllocate(aExpr : PByte; aExprLen : longint; aFlags : Longint; aID : PWasmRegExpID) : TWasmRegexpResult;
    function RegExpDeallocate(aExprID : TWasmRegExpID) : TWasmRegexpResult;
    function RegExpExec(aExprID : TWasmRegExpID; aString : PByte; aStringLen :Longint; aIndex : PLongint; aResultCount : PLongint) : TWasmRegexpResult;
    function RegExpTest(aExprID : TWasmRegExpID; aString : PByte; aStringLen :Longint; aResult : PLongint) : TWasmRegexpResult;
    function RegExpGetFlags(aExprID : TWasmRegExpID; aFlags : PLongint) : TWasmRegexpResult;
    function RegExpGetExpression(aExprID : TWasmRegExpID; aExp : PByte; aExpLen : PLongint) : TWasmRegexpResult;
    function RegExpGetLastIndex(aExprID : TWasmRegExpID; aLastIndex : PLongint) : TWasmRegexpResult;
    function RegExpSetLastIndex(aExprID : TWasmRegExpID; aLastIndex : Longint) : TWasmRegexpResult;
    function RegExpGetResultMatch(aExprID : TWasmRegExpID; aIndex : Longint; Res : PByte; ResLen : PLongint) : TWasmRegexpResult;
    function RegExpGetGroupCount(aExprID : TWasmRegExpID; aCount: PLongint) : TWasmRegexpResult;
    function RegExpGetGroupName(aExprID : TWasmRegExpID; aIndex : Longint; aName : PByte; aNameLen : PLongint) : TWasmRegexpResult;
    function RegExpGetNamedGroup(aExprID : TWasmRegExpID; aName : PByte; aNameLen : Longint; aValue : PByte; aValueLen: PLongint) : TWasmRegexpResult;
    function RegExpGetIndexes(aExprID : TWasmRegExpID; aIndex : Longint; aStartIndex : PLongint; aStopIndex: PLongint) : TWasmRegexpResult; ;
    function RegExpGetNamedGroupIndexes(aExprID : TWasmRegExpID; aName : PByte; aNameLen : Integer; aStartIndex : PLongint; aStopIndex: PLongint) : TWasmRegexpResult;
  Public
    constructor Create(aEnv: TPas2JSWASIEnvironment); override;
    procedure FillImportObject(aObject: TJSObject); override;
    function ImportName: String; override;
    class function RegisterName : string; override;
    Property LogAPICalls : Boolean Read GetLogAPICalls Write SetLogAPICalls;
  end;

implementation

{ TWasmRegexp }

constructor TWasmRegexp.Create(aRegex: TJSRegexp; aID: TWasmRegexpID);
begin
  FRegExp:=aRegex;
  FID:=aID;
end;

procedure TWasmRegexp.Exec(S: String);
begin
  FRes:=FRegExp.ExecFull(S);
end;

function TWasmRegexp.Test(S: String): Boolean;
begin
  Result:=FRegexp.test(S);
end;

function TWasmRegexp.HaveResult: Boolean;
begin
  Result:=Assigned(FRes);
end;

function TWasmRegexp.ResultIndex: Integer;

var
  Tmp : JSValue;

begin
  Result:=-1;
  if Not HaveResult then
    exit;
  Tmp:=FRes['index'];
  If isNumber(Tmp) then
    Result:=Integer(Tmp);
end;

function TWasmRegexp.ResultMatchCount: Integer;

var
  Tmp : JSValue;

begin
  Result:=0;
  if Not HaveResult then
    exit;
  Tmp:=FRes['length'];
  If isNumber(Tmp) then
    Result:=Integer(Tmp);
end;

function TWasmRegexp.GetMatch(aIndex: Integer): String;

begin
  Result:='';
  if Not HaveResult then
    exit;
  if (aIndex>=0) and (aIndex<ResultMatchCount) then
    Result:=String(FRes[IntToStr(aIndex)])
  else
    Raise Exception.CreateFmt('Index %d out of bounds [0..%d[',[aIndex,ResultMatchCount]);
end;

function TWasmRegexp.GetMatchIndexes(aIndex: Integer): TIndexArray;

var
  Tmp : JSValue;
  Arr : TJSArray absolute tmp;
  Tmp2 : JSValue;
  Arr2 : TJSArray absolute tmp2;


begin
  Result[0]:=-1;
  Result[1]:=-1;
  if Not HaveResult then
    Exit;
  if pos('d',RegExp.Flags)=0 then
    Exit;
  if (aIndex<0) or (aIndex>=ResultMatchCount) then
    Exit;
  Tmp:=FRes['indices'];
  if not isArray(Tmp) then
    exit;
  if (aIndex<0) or (aIndex>=Arr.length) then
    Raise Exception.CreateFmt('Index %d out of bounds [0..%d[',[aIndex,ResultMatchCount]);
  Tmp2:=Arr[aIndex];
  if not isArray(Tmp2) then
    exit;
  Result[0]:=Integer(Arr2[0]);
  Result[1]:=Integer(Arr2[1]);
end;

function TWasmRegexp.GetGroupIndexes(aName: String): TIndexArray;

var
  Tmp : JSValue;
  Obj : TJSObject absolute tmp;
  Tmp2 : JSValue;
  lGroups : TJSObject absolute tmp2;
  Res: JSValue;
  Arr2 : TJSArray absolute Res;

begin
  Result[0]:=-1;
  Result[1]:=-1;
  if Not HaveResult then
    Exit;
  if pos('d',RegExp.Flags)=0 then
    Exit;
  Tmp:=FRes['indices'];
  if not isArray(Tmp) then
    exit;
  Tmp2:=Obj['groups'];
  if Not isObject(Tmp) then
    exit;
  Res:=lGroups[aName];
  if Not isArray(Res) then
    exit;
  Result[0]:=Integer(Arr2[0]);
  Result[1]:=Integer(Arr2[1]);
end;

procedure TWasmRegexp.GetGroupNames;


var
  Tmp : JSValue;

begin
  if Not HaveResult then
    Exit;
  Tmp:=FRes['groups'];
  if Not isObject(Tmp) then
    exit;
  FGroupNames:=TJSObject.getOwnPropertyNames(TJSObject(Tmp));
end;

function TWasmRegexp.GetGroupCount : Integer;
begin
  Result:=0;
  if Not HaveResult then
    Exit;
  If Length(FGroupNames)=0 then
    GetGroupNames;
  Result:=Length(FGroupNames);
end;

function TWasmRegexp.GetGroupName(aIndex: Integer): String;
begin
  if (aIndex>=0) and (aIndex<Length(FGroupNames)) then
    Result:=FGroupNames[aIndex]
  else
    Result:='';
end;

function TWasmRegexp.GetGroupValue(const aName: String): String;
var
  Tmp : JSValue;
  lGroups : TJSObject absolute Tmp;
  Res : JSValue;

begin
  Result:='';
  Tmp:=FRes['groups'];
  if isObject(Tmp) then
    begin
    Res:=lGroups[aName];
    if isString(Res) then
      Result:=String(Res);
    end;
end;

{ TWasmRegExpAPI }

function TWasmRegExpAPI.RegExpAllocate(aExpr: PByte; aExprLen: longint; aFlags: Longint; aID: PWasmRegExpID): TWasmRegexpResult;
var
  lRegexp,lFlags : String;
  Regex : TJSRegexp;
  lID : TWasmRegexpID;

begin
  lRegExp:=env.GetUTF8StringFromMem(aExpr,aExprLen);
  lFlags:=RegexpFlagsToString(aFlags);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Allocate("%s","%s",[%x])',[lRegExp,lFlags,aID]);
  {$ENDIF}
  if (lRegexp='') then
    Exit(WASMRE_RESULT_NO_REGEXP);
  lID:=GetNextID;
  try
    Regex:=TJSRegExp.New(lRegExp,lFlags);
  except
    Exit(WASMRE_RESULT_ERROR);
  end;
  FRegexps[IntToStr(lID)]:=TWasmRegexp.Create(Regex,lID);
  env.SetMemInfoInt32(aID,lID);
  Result:=WASMRE_RESULT_SUCCESS;
{$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Allocate("%s","%s",[%x]) => %d',[lRegexp,lFlags,aID,lID]);
{$ENDIF}

end;

function TWasmRegExpAPI.RegExpDeallocate(aExprID: TWasmRegExpID): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Deallocate(%d)',[aExprID]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID)
end;

function TWasmRegExpAPI.RegExpExec(aExprID: TWasmRegExpID; aString: PByte; aStringLen: Longint; aIndex: PLongint;
  aResultCount: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  S : String;

begin
  S:=Env.GetUTF8StringFromMem(aString,aStringLen);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Exec(%d,"%s",[%x],[%x])',[aExprID,S,aIndex,aResultCount]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  try
    lRegExp.Exec(S);
  except
    Exit(WASMRE_RESULT_ERROR);
  end;
  Env.SetMemInfoInt32(aIndex,lRegexp.ResultIndex);
  Env.SetMemInfoInt32(aResultCount,lRegexp.ResultMatchCount);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpTest(aExprID: TWasmRegExpID; aString: PByte; aStringLen: Longint; aResult: PLongint
  ): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  B : Boolean;
  S : String;

begin
  S:=Env.GetUTF8StringFromMem(aString,aStringLen);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Exec(%d,"%s",[%x])',[aExprID,S,aResult]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  try
    B:=lRegExp.Test(S);
  except
    Exit(WASMRE_RESULT_ERROR);
  end;
  Env.SetMemInfoInt32(aResult,Ord(B));
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetFlags(aExprID: TWasmRegExpID; aFlags: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  lFlags : Longint;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetFlags(%d,[%x])',[aExprID,aFlags]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  lFlags:=StringToRegexpFlags(lRegexp.RegExp.Flags);
  Env.SetMemInfoInt32(aFlags,lFLags);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetExpression(aExprID: TWasmRegExpID; aExp: PByte; aExpLen: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  lOldLen,lLen : Integer;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetExpression(%d,[%x],[%x])',[aExprID,aExp,aExpLen]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  lOldLen:=Env.GetMemInfoInt32(aExpLen);
  lLen:=Env.SetUTF8StringInMem(aExp,lOldLen,lRegexp.RegExp.Source);
  Env.SetMemInfoInt32(aExpLen,abs(lLen));
  if lLen<0 then
    Exit(WASMRE_RESULT_NO_MEM);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetLastIndex(aExprID: TWasmRegExpID; aLastIndex: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Deallocate(%d)',[aExprID]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  Env.SetMemInfoInt32(aLastIndex,lRegexp.RegExp.lastIndex);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpSetLastIndex(aExprID: TWasmRegExpID; aLastIndex: Longint): TWasmRegexpResult;
var
  lRegExp : TWasmRegExp;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.Deallocate(%d)',[aExprID]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  lRegexp.RegExp.lastIndex:=aLastIndex;
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetResultMatch(aExprID: TWasmRegExpID; aIndex: Longint; Res: PByte; ResLen: PLongint
  ): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  S : String;
  lOldLen,lLen : Integer;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetResultMatch(%d,%d,[%x],[%x])',[aExprID,aIndex,Res,ResLen]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  if (aIndex<0) or (aIndex>=lRegExp.ResultMatchCount) then
    Exit(WASMRE_RESULT_INVALIDIDX);
  S:=lRegExp.GetMatch(aIndex);
  lOldLen:=Env.GetMemInfoInt32(ResLen);
  lLen:=Env.SetUTF8StringInMem(Res,lOldLen,S);
  Env.SetMemInfoInt32(ResLen,abs(lLen));
  if lLen<0 then
    Exit(WASMRE_RESULT_NO_MEM);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetGroupCount(aExprID: TWasmRegExpID; aCount: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetGroupCount(%d,[%x])',[aExprID,aCount]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  Env.SetMemInfoInt32(aCount,lRegexp.GetGroupCount);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetGroupName(aExprID: TWasmRegExpID; aIndex: Longint; aName: PByte; aNameLen: PLongint
  ): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  S : String;
  lOldLen,lLen : Integer;

begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetGroupName(%d,%d,[%x],[%x])',[aExprID,aIndex,aName,aNameLen]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  if (aIndex<0) or (aIndex>=lRegExp.GetGroupCount) then
    Exit(WASMRE_RESULT_INVALIDIDX);
  S:=lRegExp.GetGroupName(aIndex);
  lOldLen:=Env.GetMemInfoInt32(aNameLen);
  lLen:=Env.SetUTF8StringInMem(aName,lOldLen,S);
  Env.SetMemInfoInt32(aNameLen,abs(lLen));
  if lLen<0 then
    Exit(WASMRE_RESULT_NO_MEM);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetNamedGroup(aExprID: TWasmRegExpID; aName: PByte; aNameLen: Longint; aValue: PByte;
  aValueLen: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  lName,S : String;
  lOldLen,lLen : Integer;

begin
  lName:=Env.GetUTF8StringFromMem(aName,aNameLen);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetNamedGroup(%d,"%s",[%x],[%x])',[aExprID,lName,aValue,aValueLen]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  S:=lRegExp.GetGroupValue(lName);
  lOldLen:=Env.GetMemInfoInt32(aValueLen);
  lLen:=Env.SetUTF8StringInMem(aValue,lOldLen,S);
  Env.SetMemInfoInt32(aValueLen,abs(lLen));
  if lLen<0 then
    Exit(WASMRE_RESULT_NO_MEM);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetIndexes(aExprID: TWasmRegExpID; aIndex: Longint; aStartIndex: PLongint; aStopIndex: PLongint
  ): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  Indexes : TIndexArray;
begin
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.GetIndexes(%d,%d,[%x],[%x])',[aExprID,aIndex,aStartIndex,AStopIndex]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  if pos('d',lRegExp.RegExp.Flags)=0 then
    Exit(WASMRE_RESULT_NOINDEXES);
  if (aIndex<0) or (aIndex>=lRegExp.ResultMatchCount) then
    Exit(WASMRE_RESULT_INVALIDIDX);
  Indexes:=lRegExp.GetMatchIndexes(aIndex);
  Env.SetMemInfoInt32(aStartIndex,Indexes[0]);
  Env.SetMemInfoInt32(aStopIndex,Indexes[1]);
  Result:=WASMRE_RESULT_SUCCESS;
end;

function TWasmRegExpAPI.RegExpGetNamedGroupIndexes(aExprID: TWasmRegExpID; aName: PByte; aNameLen: Integer; aStartIndex: PLongint;
  aStopIndex: PLongint): TWasmRegexpResult;

var
  lRegExp : TWasmRegExp;
  Indexes : TIndexArray;
  lName : String;

begin
  lName:=Env.GetUTF8StringFromMem(aName,aNameLen);
  {$IFNDEF NOLOGAPICALLS}
  If LogAPICalls then
    LogCall('RegExp.RegExp.GetIndexes(%d,"%s",[%x],[%x])',[aExprID,lName,aStartIndex,AStopIndex]);
  {$ENDIF}
  lRegExp:=FindRegExp(aExprID);
  if lRegExp=Nil then
    Exit(WASMRE_RESULT_INVALIDID);
  Indexes:=lRegExp.GetGroupIndexes(lName);
  Env.SetMemInfoInt32(aStartIndex,Indexes[0]);
  Env.SetMemInfoInt32(aStopIndex,Indexes[1]);
  Result:=WASMRE_RESULT_SUCCESS;
end;

constructor TWasmRegExpAPI.Create(aEnv: TPas2JSWASIEnvironment);
begin
  inherited Create(aEnv);
  FRegExps:=TJSObject.new;
end;

function TWasmRegExpAPI.GetLogAPICalls: Boolean;
begin
  Result:=LogAPI;
end;

procedure TWasmRegExpAPI.SetLogAPICalls(AValue: Boolean);
begin
  LogAPI:=aValue;
end;


procedure TWasmRegExpAPI.LogCall(const Msg: String);
begin
  {$IFNDEF NOLOGAPICALLS}
  if LogAPI then
    DoLog(Msg);
  {$ENDIF}
end;

procedure TWasmRegExpAPI.LogCall(const Fmt: String; const Args: array of const);
begin
  {$IFNDEF NOLOGAPICALLS}
  if LogAPI then
    DoLog(Fmt,Args);
  {$ENDIF}
end;

function TWasmRegExpAPI.GetNextID: TWasmRegExpID;
begin
  Inc(FNextID);
  Result:=FNextID;
end;

function TWasmRegExpAPI.FindRegExp(aID: TWasmRegExpID): TWasmRegExp;
var
  Value : JSValue;

begin
  Value:=FRegExps[IntToStr(aID)];
  if isObject(Value) then
    Result:=TWasmRegexp(Value)
  else
    Result:=Nil;
end;

procedure TWasmRegExpAPI.FillImportObject(aObject: TJSObject);
begin
  AObject[regexpFN_Allocate]:=@RegExpAllocate;
  AObject[regexpFN_DeAllocate]:=@RegExpDeallocate;
  AObject[regexpFN_Exec]:=@RegExpExec;
  AObject[regexpFN_Test]:=@RegExpTest;
  AObject[regexpFN_GetFlags]:=@RegExpGetFlags;
  AObject[regexpFN_GetExpression]:=@RegExpGetExpression;
  AObject[regexpFN_GetLastIndex]:=@RegExpGetLastIndex;
  AObject[regexpFN_SetLastIndex]:=@RegExpSetLastIndex;
  AObject[regexpFN_GetResultMatch]:=@RegExpGetResultMatch;
  AObject[regexpFN_GetGroupCount]:=@RegExpGetGroupCount;
  AObject[regexpFN_GetGroupName]:=@RegExpGetGroupName;
  AObject[regexpFN_GetNamedGroup]:=@RegExpGetNamedGroup;
  AObject[regexpFN_GetIndexes]:=@RegExpGetIndexes;
  AObject[regexpFN_GetNamedGroupIndexes]:=@RegExpGetNamedGroupIndexes;

end;

function TWasmRegExpAPI.ImportName: String;
begin
  Result:=regexpExportName;
end;

class function TWasmRegExpAPI.RegisterName: string;
begin
  Result:='RegExp';
end;

initialization
  TWasmRegExpAPI.Register;
end.

