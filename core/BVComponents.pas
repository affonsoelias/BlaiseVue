unit BVComponents;

{
  BVComponents - Global Component Registry
  ----------------------------------------
  Standardizes how components are registered and retrieved by the compiler.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils;

{ Registers a component options object (data, template, methods) under a specific tag name }
procedure RegisterComponent(AName: string; AOptions: JSValue);

{ Retrieves the options object for a registered component tag }
function GetComponent(AName: string): JSValue;

implementation

procedure RegisterComponent(AName: string; AOptions: JSValue);
begin
  asm window.__BV_CORE__.components[AName.toLowerCase()] = AOptions; end;
end;

function GetComponent(AName: string): JSValue;
begin
  asm Result = window.__BV_CORE__.components[AName.toLowerCase()]; end;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.components) window.__BV_CORE__.components = {};
    window.__BV_CORE__.getComponent = (n) => window.__BV_CORE__.components[n.toLowerCase()];
  end;

end.
