unit BVStore;

{
  BVStore - Global State Management
  -----------------------------------
  Implements a lightweight, reactive Centralized Store (similar to Vuex/Pinia).
  Allows data sharing across components without prop-drilling.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVReactivity;

type
  { Represents the application global state container }
  TBVStore = class
  private
    FState: JSValue; { The root reactive proxy of the global state }
  public
    constructor Create(initialState: JSValue);
    property state: JSValue read FState; { Accessible state for binding }
  end;

{ Factory function to create or retrieve the singleton store }
function CreateStore(initialState: JSValue): TBVStore;

{ Retrieves the current active global store }
function GetStore: TBVStore;

implementation

var
  GStore: TBVStore = nil;

{ TBVStore Initialization }
constructor TBVStore.Create(initialState: JSValue);
begin
  { Wrapping the initial object into the Reactivity Engine }
  FState := DefineReactive(initialState);
end;

{ Singleton Pattern for Store Creation }
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
  { Ensure a default empty state is available if not manually initialized }
  if not Assigned(GStore) then
    GStore := TBVStore.Create(TJSObject.new);
    
  { Register the store in a global JS anchor for high-level compiler access }
  TJSObject(window)['__BV_PRO_STORE__'] := GStore.state;

end.
