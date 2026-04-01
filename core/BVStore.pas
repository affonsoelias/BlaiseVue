unit BVStore;

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  TBVStore = class
  private
    FState: JSValue;
  public
    constructor Create(initialState: JSValue);
    property state: JSValue read FState;
  end;

function CreateStore(initialState: JSValue): TBVStore;
function GetStore: TBVStore;

implementation

var
  GStore: TBVStore = nil;

constructor TBVStore.Create(initialState: JSValue);
begin
  FState := DefineReactive(initialState);
end;

function CreateStore(initialState: JSValue): TBVStore;
begin
  if not Assigned(GStore) then
    GStore := TBVStore.Create(initialState);
  Result := GStore;
end;

function GetStore: TBVStore;
begin
  Result := GStore;
end;

initialization
  // Por padrão, garantimos que exista um estado inicial se o usuário não chamar
  if not Assigned(GStore) then
    GStore := TBVStore.Create(TJSObject.new);
    
  // Canal VIP para o estado global
  TJSObject(window)['__BV_PRO_STORE__'] := GStore.state;

end.
