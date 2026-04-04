unit pas2js.storagebridge.worker;

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
  types, js, weborworker, webworker, rtl.WorkerCommands, pas2js.storagebridge.shared;

Type
  TMainThreadCallFunc = reference to function: Integer;

  { TStorageBridge }

  { TWorkerStorageBridge }

  TWorkerStorageBridge = class (TObject)
  Private
    FCallID : Integer;
    FKind : TStorageKind;
    FDecoder : TJSTextDecoder;
  Protected
    function DoMainThreadBlockingCall(const aFuncName: String; aArgs: array of JSValue): Integer;
  public
    class var _LocalStorage : TWorkerStorageBridge;
    class var _SessionStorage : TWorkerStorageBridge;
    // there can be only one call at a time, so a single global buffer is sufficient.
    class var _AtomicBuffer : TJSSharedArrayBuffer;
    class var FResultData : TJSInt32Array;
  public
    constructor create(aKind : TStorageKind);
    class procedure init;
    function Key(aKey : Integer) : JSValue;
    function GetItem(aKey : String) : JSValue;
    procedure SetItem(aKey,aValue : String);
    procedure RemoveItem(aKey : String);
    function count : Integer;
    procedure clear;
  end;

implementation

function Array_prototype_slice(val : JSValue) : TJSValueDynArray; external name 'Array.prototype.slice.call';

function TWorkerStorageBridge.DoMainThreadBlockingCall(const aFuncName: String; aArgs: array of JSValue): Integer;

var
  lCmd : TLocalStorageCommand;
begin
  Inc(FCallID);
  lCmd:=TLocalStorageCommand(TCustomWorkerCommand.createCommand(cmdLocalStorage));
  lCmd.Kind:=Ord(FKind);
  lCmd.ID := FCallID;
  lCmd.FuncName := aFuncName;
  lCmd.Args := aArgs;
  lCmd.ResultData := FResultData;
  TJSAtomics.store(FResultData, CallLock, 0);
  TCommandDispatcher.Instance.SendCommand(lCmd);
  TJSAtomics.wait(FResultData, CallLock, 0);
  Result := TJSAtomics.load(FResultData, CallResult);
  if Result<0 then
    Writeln(ClassName,': Could not execute function "',aFuncName,'"');
end;

constructor TWorkerStorageBridge.create(aKind: TStorageKind);
begin
  FKind:=aKind;
  FResultData:=TJSInt32Array.New(_AtomicBuffer);
  FDecoder:=TJSTextDecoder.New('utf-16');
end;

procedure TWorkerStorageBridge.clear;
begin
  DoMainThreadBlockingCall(FNClear,[]);
end;

function TWorkerStorageBridge.count: Integer;
begin
  if DoMainThreadBlockingCall(FNlength,[])<>0 then
    Result:=0
  else
    Result:=Self.FResultData[CallResultLen];
end;

procedure TWorkerStorageBridge.SetItem(aKey, aValue: String);
begin
  DoMainThreadBlockingCall(FNSetItem,[aKey,aValue]);
end;

procedure TWorkerStorageBridge.RemoveItem(aKey: String);
begin
  DoMainThreadBlockingCall(FNRemoveItem,[aKey]);
end;

function TWorkerStorageBridge.Key(aKey: Integer): JSValue;
var
  lResultLen : integer;
  lStringArray :TJSUint16Array;
begin
  if DoMainThreadBlockingCall(FNKey,[aKey])<>0 then
    Exit(null);
  lResultLen:=Self.FResultData[CallResultLen];
  if lResultLen<=0 then
    Exit(null);
  if lResultLen<=0 then
    Exit('');

  lStringArray:=TJSUint16Array.new(_AtomicBuffer, CallResultData*4, lResultLen);
  Result := FDecoder.Decode(lStringArray);
end;

function TWorkerStorageBridge.GetItem(aKey: String): JSValue;
var
  lResultLen : integer;
  lNew,lStringArray :TJSUint16Array;
  lBuf : TJSArrayBuffer;

begin
  if DoMainThreadBlockingCall(FNGetItem,[aKey])<>0 then
    Exit(null);
  lResultLen:=Self.FResultData[CallResultLen];
  if lResultLen=-1 then
    Exit(null);
  if lResultLen=0 then
    Exit('');

  lStringArray:=TJSUint16Array.new(_AtomicBuffer, CallResultData*4, lResultLen);
  lBuf:=TJSArrayBuffer.new(lResultLen*2);
  lNew:=TJSUint16Array.new(lbuf);
  lnew._set(lStringArray);
  Result := FDecoder.Decode(lNew);
end;

class procedure TWorkerStorageBridge.init;

  function createStorageImpl(aBridge : TWorkerStorageBridge) : TJSObject;
  begin
    Result:=New([
      'getItem',@aBridge.GetItem,
      'setItem',@aBridge.SetItem,
      'key',@aBridge.Key,
      'removeItem',@aBridge.RemoveItem,
      'clear',@aBridge.Clear]);
    // length is a property, so we must use defineProperty, as count is a function
    TJSObject.defineProperty(Result,'length',new(['get',@ABridge.count]));
  end;

begin
  _AtomicBuffer:=TJSSharedArrayBuffer.New(LocalStorageBufferSize);
  _LocalStorage:=TWorkerStorageBridge.Create(skLocal);
  _SessionStorage:=TWorkerStorageBridge.Create(skSession);
  // Create stubs
  self_['localStorage']:=CreateStorageImpl(_LocalStorage);
  self_['sessionStorage']:=CreateStorageImpl(_LocalStorage);
  // Keep ZenFS happy.
  self_['Storage']:=TJSObject;
end;

initialization
  TWorkerStorageBridge.Init;
end.

