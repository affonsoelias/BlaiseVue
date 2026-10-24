unit uFormatters;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function PadLeft(const S: string; Len: Integer; C: Char = '0'): string;
function FormatCurrency(AValue: Double): string;
function FormatCPF(const AValue: string): string;
function FormatPhone(const AValue: string): string;
function FormatDateBR(AYear, AMonth, ADay: Integer): string;

implementation

function PadLeft(const S: string; Len: Integer; C: Char): string;
begin
  Result := S;
  while Length(Result) < Len do
    Result := C + Result;
end;

function FormatCurrency(AValue: Double): string;
var
  S, IntPart, DecPart: string;
  DotPos: Integer;
begin
  S := FloatToStrF(AValue, ffFixed, 15, 2);
  DotPos := Pos('.', S);
  if DotPos = 0 then
    DotPos := Pos(',', S);

  if DotPos > 0 then
  begin
    IntPart := Copy(S, 1, DotPos - 1);
    DecPart := Copy(S, DotPos + 1, Length(S));
  end
  else
  begin
    IntPart := S;
    DecPart := '00';
  end;

  while Length(DecPart) < 2 do DecPart := DecPart + '0';
  if Length(DecPart) > 2 then DecPart := Copy(DecPart, 1, 2);

  Result := 'R$ ' + IntPart + ',' + DecPart;
end;

function FormatCPF(const AValue: string): string;
var
  Clean: string;
  i: Integer;
begin
  Clean := '';
  for i := 1 to Length(AValue) do
    if AValue[i] in ['0'..'9'] then
      Clean := Clean + AValue[i];

  if Length(Clean) <> 11 then
    Exit(AValue);

  Result := Copy(Clean, 1, 3) + '.' +
            Copy(Clean, 4, 3) + '.' +
            Copy(Clean, 7, 3) + '-' +
            Copy(Clean, 10, 2);
end;

function FormatPhone(const AValue: string): string;
var
  Clean: string;
  i: Integer;
begin
  Clean := '';
  for i := 1 to Length(AValue) do
    if AValue[i] in ['0'..'9'] then
      Clean := Clean + AValue[i];

  if Length(Clean) = 11 then
    Result := '(' + Copy(Clean, 1, 2) + ') ' + Copy(Clean, 3, 5) + '-' + Copy(Clean, 8, 4)
  else if Length(Clean) = 10 then
    Result := '(' + Copy(Clean, 1, 2) + ') ' + Copy(Clean, 3, 4) + '-' + Copy(Clean, 7, 4)
  else
    Result := AValue;
end;

function FormatDateBR(AYear, AMonth, ADay: Integer): string;
begin
  Result := PadLeft(IntToStr(ADay), 2) + '/' +
            PadLeft(IntToStr(AMonth), 2) + '/' +
            PadLeft(IntToStr(AYear), 4);
end;

end.
