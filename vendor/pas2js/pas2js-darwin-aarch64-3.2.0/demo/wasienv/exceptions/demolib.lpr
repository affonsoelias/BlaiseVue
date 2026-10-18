library WorkW3DClient;

{$mode objfpc}
{$h+}

uses
   {$IFDEF FPC_DOTTEDUNITS}
   System.SysUtils, 
   {$ELSE}
   SysUtils,
   {$ENDIF}
   wasm.exceptions;

Type
  EMyException = class(Exception);
  EMyOtherException = class(TObject)
    function toString : RTLString; override;
  end;

function EMyOtherException.toString : RTLString;
begin
  Result:='Some nice error';
end;   

procedure DoTest;

begin
  raise EMyException.Create('My Exception message');
end;

procedure DoTest2;

begin
  raise EMyOtherException.Create;
end;

exports DoTest,DoTest2;

begin
end.
