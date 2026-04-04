{
  JOB - JS Object Bridge for Webassembly

  Browser side.
}
{$IFNDEF FPC_DOTTEDUNITS}
unit JOB_Browser;
{$ENDIF}

{$mode objfpc}
{$modeswitch externalclass}

{off $DEFINE VerboseJOB}
{off $define VerboseJOBCallback}

interface

uses 
{$IFDEF FPC_DOTTEDUNITS}
  System.SysUtils, System.Types, JSApi.JS, BrowserApi.WebOrWorker, BrowserApi.Web, Wasi.Env, JOB.Shared;
{$ELSE}
  sysutils, types, js, weborworker, {$IFNDEF JOB_WORKER} web, {$ELSE} webworker, {$ENDIF} wasienv, JOB_Shared;
{$ENDIF}

Type
  EJOBBridge = class(Exception);
  TWasmNativeInt = Longword;
  TJOBCallback = function(aCall, aData, aCode, Args: TWasmNativeInt): TWasmNativeInt;
  TJSObjectFactory = Function(const aName : String; aArgs : TJSValueDynArray) : TJSObject of object;
  TObjectFactory = Function(const aName : String; aArgs : TJSValueDynArray) : TObject of object;

  TAbstractObjectFactoryReg = Class(TObject)
    Function CreateObj(const aName : String; aArgs : TJSValueDynArray) : JSValue; virtual; abstract;
  end;

  { TJSObjectFactoryReg }

  TJSObjectFactoryReg = Class(TAbstractObjectFactoryReg)
  Private
    FFunc : TJSObjectFactory;
  Public
    Constructor Create(aFunc : TJSObjectFactory);
    Function CreateObj(const aName : string; aArgs : TJSValueDynArray) : JSValue; override;
    Property Func : TJSObjectFactory Read FFunc;
  end;

  { TObjectFactoryReg }

  TObjectFactoryReg = Class(TAbstractObjectFactoryReg)
  Private
    FFunc : TObjectFactory;
  Public
    Constructor Create(aFunc : TObjectFactory);
    Function CreateObj(const aName : string; aArgs : TJSValueDynArray) : JSValue; override;
    Property Func : TObjectFactory Read FFunc;
  end;

  TCallbackErrorJSEventHandler = reference to procedure(Sender : TObject; Error : TJSError; Args : TJSFunctionArguments; var ReRaise : Boolean);
  TCallbackErrorPasEventHandler = reference to procedure(Sender : TObject; Error : Exception; Args : TJSFunctionArguments; var ReRaise : Boolean);
  TWasmPointer = integer;

  { TJSObjectBridge }
  TJSObjectBridgeStats = record
    LastAllocatedID : NativeInt;
    LiveObjectCount : NativeInt;
    GlobalObjectCount : NativeInt;
    FreeIDCount : Integer;
  end;

  TJSObjectBridge = class(TImportExtension)
  Private
    FLastAllocatedID : NativeInt;
    FCallbackHandler: TJOBCallback;
    FGlobalObjects: TJSArray; // id to TJSObject
    FGlobalNames: TJSObject; // name to id
    FLocalObjects: TJSArray;
    FOnCallBackJSError: TCallbackErrorJSEventHandler;
    FOnCallBackPasError: TCallbackErrorPasEventHandler;
    FStringResult: string;
    FFactories : TJSObject;
    FDecoderUTF16 : TJSTextDecoder;
    FDecoderUTF8 : TJSTextDecoder;
    function GetObjectConstructor(aObjectName: String): TJSFunction;
    procedure SetArrayFromMem(ObjId: TJOBObjectID; Mem: TWasmPointer; aMaxLen: NativeInt);
    procedure SetMemFromArray(ObjId: TJOBObjectID; Mem: TWasmPointer; aMaxLen: NativeInt);
  Protected
    procedure RegisterGlobalObjects; virtual;
    procedure SetInstanceExports(const AValue: TWasiExports); override;
    // IDs
    function GetObjectID: TJOBObjectID;
    procedure ReleaseJobID(aID: TJOBObjectID);
    function DecodeUTF16Buffer(Arr : TJSUint16Array) : String;
    function DecodeUTF8Buffer(Arr : TJSUint8Array) : String;
    function Invoke_JSResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP: NativeInt; out JSResult: JSValue): TJOBResult; virtual;
    function GetInvokeArguments(View: TJSDataView; ArgsP: NativeInt): TJSValueDynArray; virtual;
    function CreateCallbackArgs(View: TJSDataView; const Args: TJSFunctionArguments; TempObjIds: TJOBObjectIDArray): TWasmNativeInt; virtual;
    function EatCallbackResult(View: TJSDataView; ResultP: TWasmNativeInt): jsvalue; virtual;
    // exports
    function Get_GlobalID(NameP, NameLen: NativeInt): TJOBObjectID; virtual;
    function Invoke_NoResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP: NativeInt): TJOBResult; virtual;
    function Invoke_BooleanResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult; virtual;
    function Invoke_DoubleResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult; virtual;
    function Invoke_StringResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult; virtual;
    function Invoke_ObjectResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult; virtual;
    function Create_JSObject(NameP, NameLen,ArgsP : NativeInt): TJOBObjectID; virtual;
    function Create_JSObjectAt(NameP, NameLen,ArgsP : NativeInt; aObjID : TJOBObjectID): Longint; virtual;
    function Invoke_JSValueResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult; virtual;
    function Invoke_ArrayStringResult(ObjId: TJOBObjectID; NameP, NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult; virtual;
    function ReleaseObject(ObjId: TJOBObjectID): TJOBResult; virtual;
    function GetStringResult(ResultP: NativeInt): TJOBResult; virtual;
    function DebugObject(ObjId: TJOBObjectID; aMessage: TWasmPointer; aMessageLen: Integer; aFlags: Longint): TJOBResult;
    function ReleaseStringResult: TJOBResult; virtual;
  Public
    Constructor Create(aEnv: TPas2JSWASIEnvironment); override;
    Procedure FillImportObject(aObject: TJSObject); override;
    Function ImportName: String; override;
    function FindObject(ObjId: TJOBObjectID): TJSObject; virtual;
    function FindGlobalObject(const aName: string): TJOBObjectID; virtual; // 0=not found
    function RegisterLocalObjectAt(Obj: TJSObject; aObjectID : TJOBObjectID) : Boolean; virtual;
    function RegisterLocalObject(Obj: TJSObject): TJOBObjectID; virtual;
    Function RegisterGlobalObject(Obj: JSValue; const aName: string): TJOBObjectID; virtual;
    Procedure RegisterObjectFactory(const aName : string; aFunc : TObjectFactory); overload;
    Procedure RegisterJSObjectFactory(const aName : string; aFunc : TJSObjectFactory); overload;
    Function GetJOBResult(v: jsvalue): TJOBResult;
    Function GetStats : TJSObjectBridgeStats;
    Procedure DumpLiveObjects(S : String = '');
    property CallbackHandler: TJOBCallback read FCallbackHandler write FCallbackHandler;
    property OnCallBackJSError : TCallbackErrorJSEventHandler read FOnCallBackJSError Write FOnCallBackJSError;
    property OnCallBackPasError : TCallbackErrorPasEventHandler read FOnCallBackPasError Write FOnCallBackPasError;
  end;

Implementation


function NewObj(const fn: TJSFunction; const Args: TJSValueDynArray): TJSFunction; assembler;
asm
  if (Args == null){
    return new fn();
  }
  var l = Args.length;
  if (l==0){
    return new fn();
  } else if (l==1){
    return new fn(Args[0]);
  } else if (l==2){
    return new fn(Args[0],Args[1]);
  } else if (l==3){
    return new fn(Args[0],Args[1],Args[2]);
  } else if (l==4){
    return new fn(Args[0],Args[1],Args[2],Args[3]);
  } else if (l==5){
    return new fn(Args[0],Args[1],Args[2],Args[3],Args[4]);
  } else if (l==6){
    return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5]);
  } else if (l==7){
    return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6]);
  } else if (l==8){
    return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6],Args[7]);
  } else if (l==9){
    return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6],Args[7],Args[8]);
  } else if (l==10){
    return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6],Args[7],Args[8],Args[9]);
  } else {
    return null;
  }
end;

{ TJSObjectFactoryReg }


constructor TJSObjectFactoryReg.Create(aFunc: TJSObjectFactory);
begin
  FFunc:=aFunc;
end;

function TJSObjectFactoryReg.CreateObj(const aName : string; aArgs: TJSValueDynArray): JSValue;
begin
  Result:=FFunc(aName,aArgs);
end;

{ TObjectFactoryReg }

constructor TObjectFactoryReg.Create(aFunc: TObjectFactory);
begin
  FFunc:=aFunc;
end;

function TObjectFactoryReg.CreateObj(const aName: string; aArgs: TJSValueDynArray): JSValue;
begin
  Result:=FFunc(aName,aArgs);
end;

var
  {$IFDEF JOB_WORKER}
  Self_ : TJSDedicatedWorkerGlobalScope; external name 'self';
  {$ELSE}
  CSS : TJSObject; external name 'CSS';
  {$ENDIF}

procedure TJSObjectBridge.RegisterGlobalObjects;

begin
  {$IFNDEF JOB_WORKER}
  RegisterGlobalObject(document,'document');
  RegisterGlobalObject(window,'window');
  RegisterGlobalObject(CSS,'CSS');
  RegisterGlobalObject(caches,'caches');
  {$ELSE}
  RegisterGlobalObject(Self_,'self');
  {$ENDIF}
  RegisterGlobalObject(console,'console');
  RegisterGlobalObject(TJSObject,'Object');
  RegisterGlobalObject(TJSFunction,'Function');
  RegisterGlobalObject(TJSDate,'Date');
  RegisterGlobalObject(TJSString,'String');
  RegisterGlobalObject(TJSArray,'Array');
  RegisterGlobalObject(TJSArrayBuffer,'ArrayBuffer');
  RegisterGlobalObject(TJSInt8Array,'Int8Array');
  RegisterGlobalObject(TJSUint8Array,'Uint8Array');
  RegisterGlobalObject(TJSUint8ClampedArray,'Uint8ClampedArray');
  RegisterGlobalObject(TJSInt16Array,'Int16Array');
  RegisterGlobalObject(TJSUint16Array,'Uint16Array');
  RegisterGlobalObject(TJSUint32Array,'Uint32Array');
  RegisterGlobalObject(TJSFloat32Array,'Float32Array');
  RegisterGlobalObject(TJSFloat64Array,'Float64Array');
  RegisterGlobalObject(TJSJSON,'JSON');
  RegisterGlobalObject(TJSPromise,'Promise');
  RegisterGlobalObject(TJSAtomics,'Atomics');

end;

constructor TJSObjectBridge.Create(aEnv: TPas2JSWASIEnvironment);
begin
  Inherited Create(aEnv);
  FGlobalObjects:=TJSArray.new;
  FGlobalObjects.push(nil); // allocate FGlobalObjects[0]
  FGlobalNames:=TJSObject.new;
  RegisterGlobalObjects;
  FLocalObjects:=TJSArray.new;
  FLocalObjects.push(nil); // allocate FLocalObjects[0]
  FFactories:=TJSObject.New;
end;

function TJSObjectBridge.ImportName: String;
begin
  Result:=JOBExportName;
end;

function TJSObjectBridge.RegisterGlobalObject(Obj: JSValue; const aName: string
  ): TJOBObjectID;
begin
  if FGlobalNames.hasOwnProperty(aName) then
    raise EJOBBridge.Create('duplicate "'+aName+'"');
  Result:=-(FGlobalObjects.push(Obj)-1);
  {$IFDEF VERBOSEJOB}
  Writeln('Registered ',aName,' with ID ',Result);
  {$ENDIF}
  FGlobalNames[aName]:=Result;
end;

procedure TJSObjectBridge.RegisterObjectFactory(const aName: string; aFunc: TObjectFactory);
begin
  if FFactories.hasOwnProperty(aName) then
    Raise Exception.CreateFmt('Duplicate object name for factory: %s',[aName]);
  FFactories[aName]:=TObjectFactoryReg.Create(aFunc);
end;

procedure TJSObjectBridge.RegisterJSObjectFactory(const aName: string; aFunc: TJSObjectFactory);
begin
  if FFactories.hasOwnProperty(aName) then
    Raise Exception.CreateFmt('Duplicate JS object name for factory: %s',[aName]);
  FFactories[aName]:=TJSObjectFactoryReg.Create(aFunc);
end;

procedure TJSObjectBridge.FillImportObject(aObject: TJSObject);
begin
  aObject[JOBFn_GetGlobal]:=@Get_GlobalID;
  aObject[JOBFn_InvokeNoResult]:=@Invoke_NoResult;
  aObject[JOBFn_InvokeBooleanResult]:=@Invoke_BooleanResult;
  aObject[JOBFn_InvokeDoubleResult]:=@Invoke_DoubleResult;
  aObject[JOBFn_InvokeStringResult]:=@Invoke_StringResult;
  aObject[JOBFn_GetStringResult]:=@GetStringResult;
  aObject[JOBFn_ReleaseStringResult]:=@ReleaseStringResult;
  aObject[JOBFn_InvokeObjectResult]:=@Invoke_ObjectResult;
  aObject[JOBFn_ReleaseObject]:=@ReleaseObject;
  aObject[JOBFn_InvokeJSValueResult]:=@Invoke_JSValueResult;
  aObject[JOBFn_InvokeArrayStringResult]:=@Invoke_ArrayStringResult;
  aObject[JOBFn_CreateObject]:=@Create_JSObject;
  aObject[JOBFn_CreateObjectAt]:=@Create_JSObjectAt;
  aObject[JOBFn_SetMemFromArray]:=@SetMemFromArray;
  aObject[JOBFn_SetArrayFromMem]:=@SetArrayFromMem;
  aObject[JOBFn_DebugObject]:=@DebugObject;
end;

function TJSObjectBridge.FindObject(ObjId: TJOBObjectID): TJSObject;
begin
  if ObjId<0 then
    Result:=TJSObject(FGlobalObjects[-ObjId])
  else
    Result:=TJSObject(FLocalObjects[ObjId]);
  if isUndefined(Result) then
    begin
    {$IFDEF VerboseJOB}
    writeln('TJSObjectBridge.FindObject(',ObjId,') returns Nil');
    {$ENDIF}
    Result:=nil;
    end;
end;

function TJSObjectBridge.FindGlobalObject(const aName: string): TJOBObjectID;
begin
  // these two are special, it needs to be re-registered every time
  if aName='InstanceMemory' then
    Exit(RegisterLocalObject(TJSUint8Array.New(getModuleMemoryDataView.buffer)))
  else if aName='InstanceBuffer' then
    Exit(RegisterLocalObject(getModuleMemoryDataView.buffer))
  else
    begin
    if not FGlobalNames.hasOwnProperty(aName) then
      exit(0);
    Result:=NativeInt(FGlobalNames[aName]);
    end;
end;

function TJSObjectBridge.RegisterLocalObjectAt(Obj: TJSObject; aObjectID: TJOBObjectID): Boolean;
var
  lExisting : TJSObject;
begin
  lExisting:=TJSObject(FLocalObjects[aObjectID]);
  Result:=Not assigned(lExisting);
  if Result then
    FLocalObjects[aObjectID]:=Obj
  else
    Result:=(Obj=lExisting); // It's OK if it is the same object
end;

function TJSObjectBridge.RegisterLocalObject(Obj: TJSObject): TJOBObjectID;

begin
  Result:=GetObjectID;
  RegisterLocalObjectAt(Obj,Result);
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.RegisterLocalObject ',Result);
  {$ENDIF}
end;

procedure TJSObjectBridge.SetInstanceExports(const AValue: TWasiExports);
begin
  Inherited;
  if Avalue<>nil then
    CallbackHandler:=TJOBCallback(aValue.functions[JOBFn_CallbackHandler])
  else
    CallbackHandler:=nil;
end;

function TJSObjectBridge.DecodeUTF16Buffer(Arr: TJSUint16Array): String;

var
  enc : string;

begin
  if FDecoderUTF16=Nil then
    begin
    if Env.IsLittleEndian then
      enc:='utf-16le'
    else
      enc:='utf-16be';
    FDecoderUTF16:=TJSTextDecoder.New(enc);
    end;
  Result:=FDecoderUTF16.decode(SharedToNonShared(Arr,True));
end;

function TJSObjectBridge.DecodeUTF8Buffer(Arr: TJSUint8Array): String;

begin
  if FDecoderUTF8=Nil then
    FDecoderUTF8:=TJSTextDecoder.New('utf8');
  Result:=FDecoderUTF8.decode(SharedToNonShared(Arr));
end;

procedure TJSObjectBridge.SetArrayFromMem(ObjId: TJOBObjectID; Mem : TWasmPointer; aMaxLen : NativeInt);
{
  JOB allocates memory do make a call.
  As such, it is dangerous to call _set in the global memory,
  since the memory object can have changed between the call to get
  the globabl memory object and the call to set.
  Using SetArrayFromMem will always use the correct webassembly memory.
}
var
  obj : TJSObject;
  Buf : TJSArrayBuffer;
  Src,Dest : TJSUint8Array;
begin
  Obj:=FindObject(ObjId);
  if obj is TJSArrayBuffer then
    Buf:=TJSArrayBuffer(Obj)
  else
    Buf:=TJSTypedArray(Obj).buffer;
  Dest:=TJSUint8Array.New(Buf);
  Src:=TJSUint8Array.New(getModuleMemoryDataView.buffer,Mem,aMaxLen);
  Dest._set(Src,0);
end;

procedure TJSObjectBridge.SetMemFromArray(ObjId: TJOBObjectID; Mem : TWasmPointer; aMaxLen : NativeInt);
{
  JOB allocates memory do make a call.
  As such, it is dangerous to call _set in the global memory,
  since the memory object can have changed between the call to get
  the globabl memory object and the call to set.
  Using SetMemFromArray will always use the correct webassembly memory
}

var
  obj : TJSObject;
  Buf : TJSArrayBuffer;
  Src,Dest : TJSUint8Array;

begin
  Obj:=FindObject(ObjId);
  // Get the actual buffer
  if obj is TJSArrayBuffer then
    Buf:=TJSArrayBuffer(Obj)
  else
    Buf:=TJSTypedArray(Obj).buffer;
  // Create typed buffer
  if aMaxLen=0 then
    Src:=TJSUint8Array.new(Buf)
  else
    Src:=TJSUint8Array.new(Buf,0,aMaxLen);
  // Copy
  Dest:=TJSUint8Array.New(getModuleMemoryDataView.buffer);
  Dest._set(Src,Mem);
end;

function TJSObjectBridge.Invoke_JSResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP: NativeInt; out JSResult: JSValue): TJOBResult;
var
  View: TJSDataView;
  aBytes: TJSUint8Array;
  PropName: String;
  Args: TJSValueDynArray;
  Obj: TJSObject;
  fn: JSValue;
begin
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.Invoke_JSResult ObjId=',ObjId,' FuncNameP=',NameP,' FuncNameLen=',NameLen,' ArgsP=',ArgsP,' Invoke=',Invoke);
  {$ENDIF}

  Obj:=FindObject(ObjId);
  if Obj=nil then
    exit(JOBResult_UnknownObjId);

  View:=getModuleMemoryDataView();
  aBytes:=TJSUint8Array.New(View.buffer, NameP, NameLen);
  //writeln('TJSObjectBridge.Invoke_JSResult aBytes=',aBytes);
  PropName:=DecodeUTF8Buffer(aBytes);
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.Invoke_JSResult PropName="',PropName,'"');
  {$ENDIF}

  case Invoke of
  JOBInvokeCall:
    begin
      fn:=Obj[PropName];
      if jstypeof(fn)<>'function' then
        exit(JOBResult_NotAFunction);

      if ArgsP=0 then
        JSResult:=TJSFunction(fn).call(Obj)
      else begin
        Args:=GetInvokeArguments(View,ArgsP);
        JSResult:=TJSFunction(fn).apply(Obj,Args);
      end;
    end;
  JOBInvokeNew:
    begin
      if PropName<>'' then
        fn:=Obj[PropName]
      else
        fn:=Obj;
      if jstypeof(fn)<>'function' then
        exit(JOBResult_NotAFunction);

      if ArgsP=0 then
        JSResult:=NewObj(TJSFunction(fn),nil)
      else begin
        Args:=GetInvokeArguments(View,ArgsP);
        JSResult:=NewObj(TJSFunction(fn),Args)
      end;
    end;
  JOBInvokeGet,JOBInvokeGetTypeOf:
    begin
      if ArgsP>0 then
        exit(JOBResult_WrongArgs);
      JSResult:=Obj[PropName];
      if Invoke=JOBInvokeGetTypeOf then
      begin
        Result:=GetJOBResult(jsTypeOf(JSResult));
        exit;
      end;
    end;
  JOBInvokeSet:
    begin
      JSResult:=Undefined;
      if ArgsP=0 then
        exit(JOBResult_WrongArgs);
      Args:=GetInvokeArguments(View,ArgsP);
      if length(Args)<>1 then
        exit(JOBResult_WrongArgs);
      Obj[PropName]:=Args[0];
    end
  else
    exit(JOBResult_NotAFunction);
  end;

  Result:=JOBResult_Success;
end;

function TJSObjectBridge.Invoke_NoResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP: NativeInt): TJOBResult;
var
  JSResult: JSValue;
begin
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
end;

function TJSObjectBridge.Invoke_BooleanResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP, ResultP: NativeInt): TJOBResult;
var
  JSResult: JSValue;
  b: byte;
begin
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
  if Result<>JOBResult_Success then
    exit;
  // check result type
  if jstypeof(JSResult)<>'boolean' then
    exit(GetJOBResult(JSResult));
  if JSResult then
    b:=1
  else
    b:=0;
  // set result
  getModuleMemoryDataView().setUint8(ResultP, b);
  Result:=JOBResult_Boolean;
end;

function TJSObjectBridge.Invoke_DoubleResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP, ResultP: NativeInt): TJOBResult;
var
  JSResult: JSValue;
begin
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
  if Result<>JOBResult_Success then
    exit;
  // check result type
  if jstypeof(JSResult)<>'number' then
    exit(GetJOBResult(JSResult));
  // set result
  getModuleMemoryDataView().setFloat64(ResultP, double(JSResult), env.IsLittleEndian);
  Result:=JOBResult_Double;
end;

function TJSObjectBridge.Invoke_StringResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP, ResultP: NativeInt): TJOBResult;
var
  JSResult: JSValue;
begin
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
  if Result<>JOBResult_Success then
    exit;
  // check result type
  if jstypeof(JSResult)<>'string' then
    exit(GetJOBResult(JSResult));
  Result:=JOBResult_String;
  FStringResult:=String(JSResult);
  //writeln('TJSObjectBridge.Invoke_StringResult FStringResult="',FStringResult,'"');

  // set result length
  getModuleMemoryDataView().setInt32(ResultP, length(FStringResult), env.IsLittleEndian);
end;

function TJSObjectBridge.Invoke_ObjectResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP, ResultP: NativeInt): TJOBResult;
var
  t: String;
  JSResult: JSValue;
  NewId: TJOBObjectID;
begin
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
  if Result<>JOBResult_Success then
    exit;
  // check result type
  t:=jstypeof(JSResult);
  if (t<>'object') and (t<>'function') then
    exit(GetJOBResult(JSResult));
  if JSResult=nil then
    exit(JOBResult_Null);

  // set result
  NewId:=RegisterLocalObject(TJSObject(JSResult));
  getModuleMemoryDataView().setUint32(ResultP, longword(NewId), env.IsLittleEndian);
  Result:=JOBResult_Object;
end;

function TJSObjectBridge.GetObjectConstructor(aObjectName : String): TJSFunction;

var
  fn : JSValue;

begin
  Result:=Nil;
  if aObjectName<>'' then
    {$IFDEF JOB_WORKER}
    fn:=self_[aObjectName];
    {$ELSE}
    fn:=Window[aObjectName];
    {$ENDIF}
  if jstypeof(fn)<>'function' then
    exit;
  Result:=TJSFunction(fn);
end;

procedure TJSObjectBridge.ReleaseJobID(aID : TJOBObjectID);

Type
  TReleaseObjectIDProc = procedure(aID : TJOBObjectID);

var
  lProc : TReleaseObjectIDProc;

begin
  lProc:=TReleaseObjectIDProc(InstanceExports.functions['AllocateJobObjectID']);
  if Not assigned(lProc) then
    Raise EJOBBridge.Create('No function to release job ID');
  lProc(aID);
end;

function TJSObjectBridge.GetObjectID : TJOBObjectID;

Type
  TAllocateObjectIDFunc = Function : TJOBObjectID;

var
  lFunc : TAllocateObjectIDFunc;

begin
  lFunc:=TAllocateObjectIDFunc(InstanceExports.functions['AllocateJobObjectID']);
  if Not assigned(lFunc) then
    Raise EJOBBridge.Create('No function to allocate job ID');
  Result:=lFunc();
end;

function TJSObjectBridge.Create_JSObject(NameP, NameLen, ArgsP: NativeInt): TJOBObjectID;

begin
  Result:=GetObjectID;
  if Create_JSObjectAt(NameP,NameLen,ArgsP,Result)<>JOBResult_Success then
    Result:=0;
end;

function TJSObjectBridge.Create_JSObjectAt(NameP, NameLen, ArgsP: NativeInt; aObjID: TJOBObjectID): Longint;

var
  ObjName : String;
  Args: TJSValueDynArray;
  fn: TJSFunction;
  JSResult : JSValue;
  View: TJSDataView;
  aWords: TJSUint16Array;

begin
  View:=getModuleMemoryDataView();
  aWords:=TJSUint16Array.New(View.buffer, NameP, NameLen);
  //writeln('TJSObjectBridge.Invoke_JSResult aBytes=',aBytes);
  ObjName:=DecodeUTF16Buffer(aWords);
  {$IFDEF VerboseJOB}
  writeln('Create_JSObject ObjName="',ObjName,'"');
  {$ENDIF}
  if FFactories.hasOwnProperty(ObjName) then
    begin
    Args:=GetInvokeArguments(View,ArgsP);
    JSResult:=TAbstractObjectFactoryReg(FFactories[ObjName]).CreateObj(ObjName,Args);
    end
  else
    begin
    fn:=GetObjectConstructor(ObjName);
    if not Assigned(fn) then
      exit(JOBResult_None);
    if ArgsP=0 then
      JSResult:=NewObj(fn,nil)
    else
      begin
      Args:=GetInvokeArguments(View,ArgsP);
      JSResult:=NewObj(fn,Args);
      end;
    end;
  if not (jsTypeOf(JSResult)='object') then
    Result:=JOBResult_None
  else
    begin
    RegisterLocalObjectAt(TJSObject(JSResult),aObjID);
    Result:=JOBResult_Success;
    end;
  {$IFDEF VerboseJOB}
  writeln('Create_JSObject ObjName="',ObjName,'" result: ',Result);
  {$ENDIF}
end;

function TJSObjectBridge.Invoke_JSValueResult(ObjId: TJOBObjectID; NameP, NameLen,
  Invoke, ArgsP, ResultP: NativeInt): TJOBResult;
var
  JSResult: JSValue;
  b: byte;
  NewId: TJOBObjectID;
begin
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.Invoke_JSValueResult START');
  {$ENDIF}
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.Invoke_JSValueResult JSResult=',JSResult);
  {$ENDIF}
  if Result<>JOBResult_Success then
    exit;
  Result:=GetJOBResult(JSResult);
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.Invoke_JSValueResult Type=',Result);
  {$ENDIF}
  // set result
  case Result of
  JOBResult_Boolean:
    begin
      if JSResult then
        b:=1
      else
        b:=0;
      getModuleMemoryDataView().setUint8(ResultP, b);
    end;
  JOBResult_Double:
    getModuleMemoryDataView().setFloat64(ResultP, double(JSResult), env.IsLittleEndian);
  JOBResult_String:
    begin
    FStringResult:=String(JSResult);
    getModuleMemoryDataView().setInt32(ResultP, length(FStringResult), env.IsLittleEndian);
    end;
  JOBResult_Function,
  JOBResult_Object:
    begin
      NewId:=RegisterLocalObject(TJSObject(JSResult));
      getModuleMemoryDataView().setUint32(ResultP, longword(NewId), env.IsLittleEndian);
    end;
  else
    // no args
  end;
end;

function TJSObjectBridge.Invoke_ArrayStringResult(ObjId: TJOBObjectID; NameP,
  NameLen, Invoke, ArgsP, ResultP: NativeInt): TJOBResult;
var
  JSResult: JSValue;
begin
  // invoke
  Result:=Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,JSResult);
  if Result<>JOBResult_Success then
    exit;
  raise EJOBBridge.Create('TJSObjectBridge.Invoke_ArrayStringResult not yet implemented');
  // check result type
  //exit(GetJOBResult(JSResult));
  Result:=JOBResult_String;
  if ResultP=0 then ;
end;

function TJSObjectBridge.ReleaseObject(ObjId: TJOBObjectID): TJOBResult;

begin
  {$IFDEF VerboseJOB}
  writeln('TJSObjectBridge.ReleaseObject ',ObjId);
  {$ENDIF}
  if ObjId<0 then
    raise EJOBBridge.Create('cannot release a global object');
  if ObjId>=FLocalObjects.Length then
    raise EJOBBridge.Create('cannot release unknown object');
  if FLocalObjects[ObjId]=nil then
    raise EJOBBridge.Create('object already released');
  FLocalObjects[ObjId]:=nil;
  ReleaseJobID(ObjID);

  Result:=JOBResult_Success;
end;

function TJSObjectBridge.GetStringResult(ResultP: NativeInt): TJOBResult;
var
  View: TJSDataView;
  l, i: SizeInt;
begin
  Result:=JOBResult_Success;
  l:=length(FStringResult);
  if l=0 then exit;
  View:=getModuleMemoryDataView();
  for i:=0 to l-1 do
    View.setUint16(ResultP+2*i,ord(FStringResult[i+1]),env.IsLittleEndian);
  FStringResult:='';
end;

function TJSObjectBridge.DebugObject(ObjId: TJOBObjectID; aMessage : TWasmPointer; aMessageLen : Integer; aFlags: Longint): TJOBResult;

var
  Obj : TJSObject;
  S : String;

begin
  S:=Env.GetUTF8StringFromMem(aMessage,aMessageLen);
  if ObjID=-1 then
    begin
    DumpLiveObjects(S);
    Result:=JOBResult_Success;
    end
  else
    begin
    Obj:=FindObject(ObjId);
    if not assigned(Obj) then
      begin
      Result:=JOBResult_UnknownObjId;
      console.warn('Cannot find object ',ObjId);
      end
    else
      begin
      console.debug(S,' dumping object ',ObjID,' : ',Obj);
      Result:=JOBResult_Success;
      end;
    end;
  if aFlags=0 then ;
end;

function TJSObjectBridge.ReleaseStringResult: TJOBResult;
begin
  Result:=JOBResult_Success;
  FStringResult:='';
end;

function TJSObjectBridge.GetInvokeArguments(View: TJSDataView; ArgsP: NativeInt
  ): TJSValueDynArray;
type
  TProxyFunc = reference to function: jsvalue;
var
  p: NativeInt;

  function ReadWasmNativeInt: TWasmNativeInt;

  begin
    Result:=View.getInt32(p,env.IsLittleEndian);
    inc(p,4);
  end;


  function ReadArgMethod: TProxyFunc;

  var
    aCall, aData, aCode: TWasmNativeInt;
    ReRaise : Boolean;

    function MethodCallBack: jsvalue;
      var
        i, Args, ResultP: TWasmNativeInt;
        TempObjIds: TJOBObjectIDArray;
      begin
        {$IFDEF VerboseJOBCallback}
        writeln('TJSObjectBridge Callback: JS Method Call=',aCall,' Data=',aData,' Code=',aCode,' Args=',JSArguments.length,' converting args for wasm...');
        {$ENDIF}
        Args:=CreateCallbackArgs(View,JSArguments,TempObjIds);
        try
          {$IFDEF VerboseJOBCallback}
          writeln('TJSObjectBridge Callback: calling Wasm with');
          {$ENDIF}
          try
            ResultP:=CallbackHandler(aCall,aData,aCode,Args); // this frees Args, and may detach View
          except
            on JE : TJSError do
              begin
              ReRaise:=True;
              if Assigned(OnCallBackJSError) then
                OnCallBackJSError(Self,JE,JSArguments,ReRaise);
              if ReRaise then
                Raise;
              end;
            on E : Exception do
              begin
              ReRaise:=True;
              if Assigned(OnCallBackPasError) then
                OnCallBackPasError(Self,E,JSArguments,ReRaise);
              if ReRaise then
                Raise;
              end;
          end;

          View:=getModuleMemoryDataView();
          {$IFDEF VerboseJOBCallback}
          writeln('TJSObjectBridge Callback: called Wasm Call=',aCall,' Data=',aData,' Code=',aCode,' ResultP=',ResultP,' getting Result...');
          {$ENDIF}
          Result:=EatCallbackResult(View,ResultP); // this frees ResultP
          {$IFDEF VerboseJOBCallback}
          writeln('TJSObjectBridge Callback: Result=',Result);
          {$ENDIF}
        finally
          {$IFDEF VerboseJOBCallback}
          writeln('TJSObjectBridge Callback: cleaning up TempObjIds=',length(TempObjIds),' ',TempObjIds);
          {$ENDIF}
          for i:=0 to length(TempObjIds)-1 do
            ReleaseObject(TempObjIds[i]);
        end;
      end;

  begin
    aCall:=ReadWasmNativeInt;
    aData:=ReadWasmNativeInt;
    aCode:=ReadWasmNativeInt;

    Result:=@MethodCallBack;
  end;

  function ReadString: String;
  var
    Len: TWasmNativeInt;
    aWords: TJSUint16Array;
  begin
    Len:=ReadWasmNativeInt;
    aWords:=TJSUint16Array.New(View.buffer, p,Len);
    inc(p,Len*2);
    Result:=DecodeUTF16Buffer(aWords);
    {$IFDEF VERBOSEJOB}
    Writeln('ReadString : ',Result);
    {$ENDIF}
  end;

  function ReadUnicodeString: String;
  var
    Len, Ptr: TWasmNativeInt;
    aWords: TJSUint16Array;
    aRawBytes,
    aBytes: TJSUint8Array;
  begin
    Len:=ReadWasmNativeInt;
    Ptr:=ReadWasmNativeInt;
    if (Ptr mod 2)=0 then
      begin
      // Aligned, we can directly use the memory
      aWords:=TJSUint16Array.New(View.buffer, Ptr,Len);
      end
    else
      begin
      // Unaligned, We cannot directly use the memory
      // So create a uint8 buffer and copy using from.
     aRawBytes:=TJSUint8Array.new(View.buffer, Ptr,Len*2);
      // Hopefully aligned
      aBytes:=TJSUint8Array.New(aRawBytes.Buffer);
      // Reinterpret
      aWords:=TJSUint16Array.New(aBytes.buffer);
      end;
     Result:=DecodeUTF16Buffer(aWords);
    {$IFDEF VERBOSEJOB}
    Writeln('ReadUnicodeString : ',Result);
    {$ENDIF}
  end;

  function ReadValue: JSValue; forward;

  function ReadArgDictionary: JSValue;
  var
    Cnt: TWasmNativeInt;
    CurName: String;
    i: Integer;
    aType: Byte;
  begin
    Cnt:=ReadWasmNativeInt;
    Result:=TJSObject.new;
    for i:=0 to Cnt-1 do
    begin
      aType:=View.getUInt8(p);
      inc(p);
      if aType<>JOBArgUnicodeString then
        raise EJOBBridge.Create('20220825000909: dictionary name must be unicodestring, but was '+IntToStr(aType));
      CurName:=ReadUnicodeString;
      TJSObject(Result)[CurName]:=ReadValue;
    end;
  end;

  function ReadArgArrayOfJSValue: JSValue;
  var
    Cnt: TWasmNativeInt;
    i: Integer;
  begin
    Cnt:=ReadWasmNativeInt;
    Result:=TJSArray.new;
    for i:=0 to Cnt-1 do
      TJSArray(Result)[i]:=ReadValue;
  end;

  function ReadArgArrayOfDouble: JSValue;
  var
    Cnt, El: TWasmNativeInt;
    i: Integer;
  begin
    Cnt:=ReadWasmNativeInt;
    El:=ReadWasmNativeInt;
    Result:=TJSArray.new;
    for i:=0 to Cnt-1 do
      TJSArray(Result)[i]:=View.getFloat64(El+i*8,env.IsLittleEndian);
  end;

  function ReadArgArrayOfByte: JSValue;
  var
    Cnt, El: TWasmNativeInt;

  begin
    Cnt:=ReadWasmNativeInt;
    El:=ReadWasmNativeInt;
    Result:=TJSUint8Array.New(Env.Memory.buffer,El,Cnt);
  end;

  function ReadValue: JSValue;
  var
    aType: Byte;
    ObjID: LongInt;
    Obj: TJSObject;
  begin
    aType:=View.getUInt8(p);
    //writeln('TJSObjectBridge.GetInvokeArguments.ReadValue aType=',aType,' p=',p);
    inc(p);
    case aType of
    JOBArgUndefined:
      Result:=Undefined;
    JOBArgLongint:
      begin
        Result:=View.getInt32(p,env.IsLittleEndian);
        inc(p,4);
      end;
    JOBArgDouble:
      begin
        Result:=View.getFloat64(p,env.IsLittleEndian);
        inc(p,8);
      end;
    JOBArgTrue:
      Result:=true;
    JOBArgFalse:
      Result:=false;
    JOBArgChar:
      begin
        Result:=chr(View.getUint16(p,env.IsLittleEndian));
        inc(p,2);
      end;
    JOBArgString:
      Result:=ReadString;
    JOBArgUnicodeString:
      Result:=ReadUnicodeString;
    JOBArgNil:
      Result:=nil;
    JOBArgPointer:
      Result:=ReadWasmNativeInt;
    JOBArgObject:
      begin
        ObjID:=ReadWasmNativeInt;
        if ObjID=0 then
          Obj:=Nil
        else
          begin
          Obj:=FindObject(ObjID);
          if Obj=nil then
            raise EJOBBridge.Create('20220825000904: invalid JSObject '+IntToStr(ObjID));
          end;
        Result:=Obj;
      end;
    JOBArgMethod:
      Result:=ReadArgMethod;
    JOBArgDictionary:
      Result:=ReadArgDictionary;
    JOBArgArrayOfJSValue:
      Result:=ReadArgArrayOfJSValue;
    JOBArgArrayOfDouble:
      Result:=ReadArgArrayOfDouble;
    JOBArgArrayOfByte:
      Result:=ReadArgArrayOfByte;
    else
      raise EJOBBridge.Create('20220825000852: unknown arg type '+IntToStr(aType));
    end;
  end;

var
  Cnt: Byte;
  i: Integer;
begin
  p:=ArgsP;
  Cnt:=View.getUInt8(p);
  //writeln('TJSObjectBridge.GetInvokeArguments Cnt=',Cnt);
  inc(p);
  for i:=0 to Cnt-1 do
  begin
    Result[i]:=ReadValue;
    //writeln('TJSObjectBridge.GetInvokeArguments ',i,'/',Cnt,' = ',Result[i]);
  end;
end;

function TJSObjectBridge.CreateCallbackArgs(View: TJSDataView;
  const Args: TJSFunctionArguments; TempObjIds: TJOBObjectIDArray
  ): TWasmNativeInt;
var
  i, Len, j: Integer;
  Arg: JSValue;
  r: TJOBResult;
  s: String;
  NewId: TJOBObjectID;
  p: LongWord;

begin
  Result:=0;
  if Args.Length=0 then exit;
  if Args.Length>255 then
    raise EJOBBridge.Create('too many arguments');

  // compute needed wasm memory
  Len:=1;
  for i:=0 to Args.Length-1 do
  begin
    Arg:=Args[i];
    r:=GetJOBResult(Arg);
    inc(Len);
    case r of
    JOBResult_Boolean: ;
    JOBResult_Double: inc(Len,8);
    JOBResult_String: inc(Len,4+2*TJSString(Arg).length);
    JOBResult_Function,
    JOBResult_Object: inc(Len,4);
    end;
  end;

  // allocate wasm memory
  Result:=InstanceExports.AllocMem(Len);
  // Need to reget the memory buffer, since it can have changed by the allocmem.
  view:=getModuleMemoryDataView();
  // write
  p:=Result;
  View.setUint8(p,Args.Length);
  inc(p);
  for i:=0 to Args.Length-1 do
  begin
    Arg:=Args[i];
    r:=GetJOBResult(Arg);
    {$IFDEF VERBOSEJOB}
    writeln('TJSObjectBridge.CreateCallbackArgs ',i,'/',Args.Length,' r=',r);
    {$ENDIF}
    case r of
    JOBResult_Null:
      begin
        View.setUint8(p,JOBArgNil);
        inc(p);
      end;
    JOBResult_Boolean:
      begin
      if Arg then
        View.setUint8(p,JOBArgTrue)
      else
        View.setUint8(p,JOBArgFalse);
      inc(p);
      end;
    JOBResult_Double:
      begin
        View.setUint8(p,JOBArgDouble);
        inc(p);
        View.setFloat64(p,double(Arg),env.IsLittleEndian);
        inc(p,8);
      end;
    JOBResult_String:
      begin
        View.setUint8(p,JOBArgUnicodeString);
        inc(p);
        s:=String(Arg);
        View.setUint32(p,length(s),env.IsLittleEndian);
        inc(p,4);
        for j:=0 to length(s)-1 do
        begin
          View.setUint16(p,ord(s[j+1]),env.IsLittleEndian);
          inc(p,2);
        end;
      end;
    JOBResult_Function,
    JOBResult_Object:
      begin
        View.setUint8(p,JOBArgObject);
        inc(p);
        NewId:=RegisterLocalObject(TJSObject(Arg));
        // Do not free these objects after the call, as they may be saved by the webassembly
        // TJSArray(TempObjIds).push(NewId);
        {$IFDEF VERBOSEJOB}
        writeln('TJSObjectBridge.CreateCallbackArgs Object ID=',NewID);
        {$ENDIF}
        View.setInt32(p, NewId, env.IsLittleEndian);
        inc(p,4);
      end;
    else
      View.setUint8(p,JOBArgUndefined);
      inc(p);
    end;
  end;
end;

function TJSObjectBridge.EatCallbackResult(View: TJSDataView;
  ResultP: TWasmNativeInt): jsvalue;
var
  p: TWasmNativeInt;

  function EatString: JSValue;
  var
    Len: LongWord;
    i: Integer;
    a: TWordDynArray;
  begin
    Len:=View.getUInt32(p,env.IsLittleEndian);
    inc(p,4);
    SetLength(a,Len);
    for i:=0 to Len-1 do begin
      a[i]:=View.getUint16(p,env.IsLittleEndian);
      inc(p,2);
    end;
    Result:=TJSFunction(@TJSString.fromCharCode).apply(nil,a);
  end;

var
  aType: Byte;
  ObjId: LongInt;
begin
  if ResultP=0 then
    exit(Undefined);
  p:=ResultP;
  try
    aType:=View.getUint8(p);
    //writeln('TJSObjectBridge.EatCallbackResult aType=',aType);
    inc(p);
    case aType of
    JOBArgTrue: Result:=true;
    JOBArgFalse: Result:=false;
    JOBArgLongint: Result:=View.getInt32(p,env.IsLittleEndian);
    JOBArgDouble: Result:=View.getFloat64(p,env.IsLittleEndian);
    JOBArgUnicodeString: Result:=EatString;
    JOBArgNil: Result:=nil;
    JOBArgObject:
      begin
        ObjId:=View.getInt32(p,env.IsLittleEndian);
        Result:=FindObject(ObjId);
        {$IFDEF VERBOSEJOB}
        writeln('TJSObjectBridge.EatCallbackResult ObjID=',ObjId,' Result=',Result<>nil);
        {$ENDIF}
      end;
    else
      Result:=Undefined;
    end;
  finally
    //writeln('TJSObjectBridge.EatCallbackResult freeing result...');
    InstanceExports.freeMem(ResultP);
  end;
end;

function TJSObjectBridge.Get_GlobalID(NameP, NameLen: NativeInt
  ): TJOBObjectID;
var
  View: TJSDataView;
  aWords: TJSUint16Array;
  aName: String;
begin
  View:=getModuleMemoryDataView();
  aWords:=TJSUint16Array.New(View.buffer, NameP, NameLen);
  aName:=DecodeUTF16Buffer(aWords);
  Result:=FindGlobalObject(aName);
  {$IFDEF VERBOSEJOB}
  Writeln('Get_GlobalID (',aName,'): ', Result);
  {$ENDIF}
end;

function TJSObjectBridge.GetJOBResult(v: jsvalue): TJOBResult;
begin
  case jstypeof(v) of
  'undefined': Result:=JOBResult_Undefined;
  'boolean': Result:=JOBResult_Boolean;
  'number': Result:=JOBResult_Double;
  'string': Result:=JOBResult_String;
  'symbol': Result:=JOBResult_Symbol;
  'bigint': Result:=JOBResult_BigInt;
  'function': Result:=JOBResult_Function;
  'object': if v=nil then Result:=JOBResult_Null else Result:=JOBResult_Object;
  else Result:=JOBResult_None;
  end;
end;

function TJSObjectBridge.GetStats: TJSObjectBridgeStats;
begin
  Result.LastAllocatedID:=FLastAllocatedID;
  Result.LiveObjectCount:=FLocalObjects.Length;
  Result.GlobalObjectCount:=FGlobalObjects.Length;
end;

procedure TJSObjectBridge.DumpLiveObjects(S: String);
begin
  Console.Log(S,'Local objects:');
  Console.debug(FLocalObjects);
  Console.Log(S,'Global objects:');
  Console.debug(FGlobalObjects);
end;


end.  
