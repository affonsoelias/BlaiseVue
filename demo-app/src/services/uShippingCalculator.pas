unit uShippingCalculator;

{
  =============================================================================
  📦 BlaiseVue Demo Application - Shipping & Freight Calculation Service
  =============================================================================
  Provides enterprise domain business logic for calculating shipping costs,
  freight tariffs by postal region, and estimated delivery windows in 100%
  Object Pascal.
  =============================================================================
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

{ Canonical English API }
function GetRegionByZipCode(const ZipCode: string): string;
function CalculateShipping(const ZipCode: string; WeightKg, OrderTotal: Double): Double;
function GetDeliveryDays(const ZipCode: string): Integer;

{ Backward-compatible aliases }
function RegiaoPorCEP(const CEP: string): string;
function CalcularFrete(const CEP: string; PesoKg, ValorPedido: Double): Double;
function PrazoEntregaDias(const CEP: string): Integer;

implementation

function GetRegionByZipCode(const ZipCode: string): string;
var
  Clean: string;
  Prefix: Integer;
  i: Integer;
begin
  Clean := '';
  for i := 1 to Length(ZipCode) do
    if ZipCode[i] in ['0'..'9'] then
      Clean := Clean + ZipCode[i];

  if Length(Clean) < 2 then
    Exit('Unknown Region');

  Prefix := StrToIntDef(Copy(Clean, 1, 2), 0);

  { Brazilian ZIP code ranges }
  if (Prefix >= 1) and (Prefix <= 19) then
    Result := 'Southeast - SP'
  else if (Prefix >= 20) and (Prefix <= 28) then
    Result := 'Southeast - RJ'
  else if (Prefix >= 29) and (Prefix <= 29) then
    Result := 'Southeast - ES'
  else if (Prefix >= 30) and (Prefix <= 39) then
    Result := 'Southeast - MG'
  else if (Prefix >= 40) and (Prefix <= 48) then
    Result := 'Northeast - BA'
  else if (Prefix >= 80) and (Prefix <= 87) then
    Result := 'South - PR'
  else if (Prefix >= 88) and (Prefix <= 89) then
    Result := 'South - SC'
  else if (Prefix >= 90) and (Prefix <= 99) then
    Result := 'South - RS'
  else
    Result := 'Other Regions';
end;

function CalculateShipping(const ZipCode: string; WeightKg, OrderTotal: Double): Double;
var
  Region: string;
  BaseRate: Double;
begin
  { Free Shipping promotion for orders above $250.00 }
  if OrderTotal >= 250.0 then
    Exit(0.0);

  Region := GetRegionByZipCode(ZipCode);

  if (Pos('Southeast', Region) > 0) or (Pos('Sudeste', Region) > 0) then
    BaseRate := 15.0
  else if (Pos('South', Region) > 0) or (Pos('Sul', Region) > 0) then
    BaseRate := 22.50
  else if (Pos('Northeast', Region) > 0) or (Pos('Nordeste', Region) > 0) then
    BaseRate := 35.0
  else
    BaseRate := 45.0;

  { Weight surcharge: $3.50 per kg above 1 kg }
  if WeightKg > 1.0 then
    BaseRate := BaseRate + ((WeightKg - 1.0) * 3.50);

  Result := BaseRate;
end;

function GetDeliveryDays(const ZipCode: string): Integer;
var
  Region: string;
begin
  Region := GetRegionByZipCode(ZipCode);

  if (Pos('Southeast', Region) > 0) or (Pos('Sudeste', Region) > 0) then
    Result := 2
  else if (Pos('South', Region) > 0) or (Pos('Sul', Region) > 0) then
    Result := 4
  else if (Pos('Northeast', Region) > 0) or (Pos('Nordeste', Region) > 0) then
    Result := 7
  else
    Result := 10;
end;

{ Aliases }
function RegiaoPorCEP(const CEP: string): string;
begin
  Result := GetRegionByZipCode(CEP);
  { Translate back for test expectations if legacy Portuguese names were expected }
  if Pos('Southeast - SP', Result) > 0 then Result := 'Sudeste - SP'
  else if Pos('Southeast - RJ', Result) > 0 then Result := 'Sudeste - RJ'
  else if Pos('Southeast - ES', Result) > 0 then Result := 'Sudeste - ES'
  else if Pos('Southeast - MG', Result) > 0 then Result := 'Sudeste - MG'
  else if Pos('Northeast - BA', Result) > 0 then Result := 'Nordeste - BA'
  else if Pos('South - PR', Result) > 0 then Result := 'Sul - PR'
  else if Pos('South - SC', Result) > 0 then Result := 'Sul - SC'
  else if Pos('South - RS', Result) > 0 then Result := 'Sul - RS';
end;

function CalcularFrete(const CEP: string; PesoKg, ValorPedido: Double): Double;
begin
  Result := CalculateShipping(CEP, PesoKg, ValorPedido);
end;

function PrazoEntregaDias(const CEP: string): Integer;
begin
  Result := GetDeliveryDays(CEP);
end;

end.
