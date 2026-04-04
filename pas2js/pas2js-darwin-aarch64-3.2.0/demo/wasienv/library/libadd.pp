
// ppcrosswasm32 -Twasi -oadd.wasm add.pas
library libadd;

{$mode objfpc}

type
   TConnection = class
   private
     n : Integer;
   public
     constructor Create;
     function DoAdd(a1,a2 : integer) : Integer;
   end;

constructor TConnection.Create;
begin
   n := 4711;
end;

function TConnection.Doadd( a1, a2 : Integer ) : Integer;

begin
  result:=a1+a2+n;
end;

function add( a1, a2 : Integer ) : Integer;
var
   connection : TConnection;
begin
   connection := TConnection.Create;
   Result := connection.DoAdd(a1,a2);
   connection.free;
end;

exports
   add name 'add';
end.
