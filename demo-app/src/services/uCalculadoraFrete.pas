unit uCalculadoraFrete;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function RegiaoPorCEP(const CEP: string): string;
function CalcularFrete(const CEP: string; PesoKg, ValorPedido: Double): Double;
function PrazoEntregaDias(const CEP: string): Integer;

implementation

function RegiaoPorCEP(const CEP: string): string;
var
  Clean: string;
  Prefix: Integer;
  i: Integer;
begin
  Clean := '';
  for i := 1 to Length(CEP) do
    if CEP[i] in ['0'..'9'] then
      Clean := Clean + CEP[i];

  if Length(Clean) < 2 then
    Exit('Desconhecida');

  Prefix := StrToIntDef(Copy(Clean, 1, 2), 0);

  { Faixas de CEP brasileiras }
  if (Prefix >= 1) and (Prefix <= 19) then
    Result := 'Sudeste - SP'
  else if (Prefix >= 20) and (Prefix <= 28) then
    Result := 'Sudeste - RJ'
  else if (Prefix >= 29) and (Prefix <= 29) then
    Result := 'Sudeste - ES'
  else if (Prefix >= 30) and (Prefix <= 39) then
    Result := 'Sudeste - MG'
  else if (Prefix >= 40) and (Prefix <= 48) then
    Result := 'Nordeste - BA'
  else if (Prefix >= 80) and (Prefix <= 87) then
    Result := 'Sul - PR'
  else if (Prefix >= 88) and (Prefix <= 89) then
    Result := 'Sul - SC'
  else if (Prefix >= 90) and (Prefix <= 99) then
    Result := 'Sul - RS'
  else
    Result := 'Demais Regioes';
end;

function CalcularFrete(const CEP: string; PesoKg, ValorPedido: Double): Double;
var
  Regiao: string;
  BaseTarifa: Double;
begin
  { Regra de Frete Gratis para compras acima de R$ 250,00 }
  if ValorPedido >= 250.0 then
    Exit(0.0);

  Regiao := RegiaoPorCEP(CEP);

  if Pos('Sudeste', Regiao) > 0 then
    BaseTarifa := 15.0
  else if Pos('Sul', Regiao) > 0 then
    BaseTarifa := 22.50
  else if Pos('Nordeste', Regiao) > 0 then
    BaseTarifa := 35.0
  else
    BaseTarifa := 45.0;

  { Adicional por peso: R$ 3,50 por kg acima de 1kg }
  if PesoKg > 1.0 then
    BaseTarifa := BaseTarifa + ((PesoKg - 1.0) * 3.50);

  Result := BaseTarifa;
end;

function PrazoEntregaDias(const CEP: string): Integer;
var
  Regiao: string;
begin
  Regiao := RegiaoPorCEP(CEP);

  if Pos('Sudeste', Regiao) > 0 then
    Result := 2
  else if Pos('Sul', Regiao) > 0 then
    Result := 4
  else if Pos('Nordeste', Regiao) > 0 then
    Result := 7
  else
    Result := 10;
end;

end.
