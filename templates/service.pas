unit u{{SERVICE_NAME}};

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  { T{{SERVICE_NAME}} - Domain Service }
  T{{SERVICE_NAME}} = class
  public
    function Execute(const Input: string): string;
  end;

function {{SERVICE_NAME}}Helper(AValue: Integer): Integer;

implementation

{ T{{SERVICE_NAME}} }

function T{{SERVICE_NAME}}.Execute(const Input: string): string;
begin
  Result := 'Processed: ' + Input;
end;

function {{SERVICE_NAME}}Helper(AValue: Integer): Integer;
begin
  Result := AValue * 2;
end;

end.
