unit pas2js.storagebridge.shared;

{$mode ObjFPC}
{$modeswitch externalclass}

interface

uses
  Types, Rtl.WorkerCommands, JS;

const
  cmdLocalStorage = 'localstorage';

  FNClear   = 'clear';
  FNLength  = 'length';
  FNSetItem = 'set_item';
  FNGetItem = 'get_item';
  FNRemoveItem = 'remove_item';
  FNKey     = 'key';

  LocalStorageBufferSize = 4*1024*1024; // 4 mb

  {
    Result data:
    Lock
    Result
    ResultLength
    [Data]
  }
  CallLock       = 0;
  CallResult     = 1;
  CallResultLen  = 2;
  CallResultData = 3;

  ESTORAGE_SUCCESS = 0;
  ESTORAGE_KIND    = -1;

  cNULLLength    = -1;

Type
  TStorageKind = (skLocal,skSession);

  TLocalStorageCommand = Class External name 'TObject' (TCustomWorkerCommand)
    Kind : integer; // Ord TStorageKind
    ID : Integer; external name 'id';
    ResultData : TJSInt32Array; external name 'atomic';
    FuncName : String; external name 'funcName';
    Args : TJSValueDynArray; external name 'args';
  end;


implementation

end.

