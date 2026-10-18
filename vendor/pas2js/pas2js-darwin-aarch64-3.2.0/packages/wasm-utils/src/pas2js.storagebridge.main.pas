unit pas2js.storagebridge.main;

{$mode ObjFPC}

interface

uses
  JS, Rtl.WorkerCommands, pas2js.storagebridge.shared, web;

Type
  { TMainStorageBridge }

  TMainStorageBridge = class (TObject)
  Private
    class var _instance : TMainStorageBridge;
  private
    function GetStorage(aKind: Integer): TJSStorage;
  protected
    procedure HandleLocalStorageCommand(aCmd: TLocalStorageCommand); virtual;
    procedure RegisterMessageHandlers; virtual;

  public
    constructor create;
    class procedure Init;
    class property Instance : TMainStorageBridge Read _Instance;
  end;

implementation

{ TMainStorageBridge }
function TMainStorageBridge.GetStorage(aKind : Integer) : TJSStorage;
begin
  Case aKind of
    Ord(skLocal) : Result:=Window.localStorage;
    Ord(skSession) : Result:=Window.sessionStorage;
  else
    Result:=nil;
  end;
end;

procedure TMainStorageBridge.HandleLocalStorageCommand(aCmd : TLocalStorageCommand);

var
  lStorage : TJSStorage;
  i, lError, lResultLen : Integer;
  lResult : string;
  lArr : TJSUint16Array;

begin
  lResult:='';
  lResultLen:=0;
  lStorage:=GetStorage(aCmd.Kind);
  lError:=ESTORAGE_SUCCESS;
  if lStorage=Nil then
    lError:=ESTORAGE_KIND
  else
    case aCmd.FuncName of
      FNClear :
        lStorage.Clear;
      FNLength :
        lResultLen:=lStorage.Length;
      FNKey :
        begin
        lResult:=lStorage.Key(Integer(aCmd.Args[0]));
        if isNull(lResult) then
          begin
          lResultLen:=cNULLLength;
          lResult:='';
          end
        else
          lResultLen:=Length(lResult);
        end;
      FNRemoveItem :
        lStorage.removeItem(String(aCmd.Args[0]));
      FNGetItem :
        begin
        lResult:=lStorage.getItem(String(aCmd.Args[0]));
        if isNull(lResult) then
          begin
          lResultLen:=cNULLLength;
          lResult:='';
          end
        else
          lResultLen:=Length(lResult);
        end;
      FNSetItem :
        begin
        lStorage.setItem(String(aCmd.Args[0]),String(aCmd.Args[1]));
        end;
    end;
  aCmd.ResultData[CallResult]:=lError;
  aCmd.ResultData[CallResultLen]:=lResultLen;
  if lResult<>'' then
    begin
    lArr:=TJSUint16Array.New(aCmd.ResultData.buffer,CallResultData*4);
    for I:=0 to Length(lResult)-1 do
      lArr[i]:=TJSString(lResult).charCodeAt(i);
    end;
  aCmd.ResultData[CallLock]:=1;
  TJSAtomics.notify(aCmd.ResultData,CallLock);
end;

procedure TMainStorageBridge.RegisterMessageHandlers;
begin
  TCommandDispatcher.Instance.specialize AddCommandHandler<TLocalStorageCommand>(cmdLocalStorage,@HandleLocalStorageCommand);
end;

constructor TMainStorageBridge.create;
begin
  RegisterMessageHandlers;
end;

class procedure TMainStorageBridge.Init;
begin
  _Instance:=TMainStorageBridge.Create;
end;

initialization
  TMainStorageBridge.Init;

end.

