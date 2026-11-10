unit uCalculadoraFrete;

{
  =============================================================================
  ⚠️ Deprecated Compatibility Unit: uCalculadoraFrete
  =============================================================================
  This unit provides backward compatibility for legacy references.
  New code should import "uShippingCalculator" directly.
  =============================================================================
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, uShippingCalculator;

function RegiaoPorCEP(const CEP: string): string;
function CalcularFrete(const CEP: string; PesoKg, ValorPedido: Double): Double;
function PrazoEntregaDias(const CEP: string): Integer;

implementation

function RegiaoPorCEP(const CEP: string): string;
begin
  Result := uShippingCalculator.RegiaoPorCEP(CEP);
end;

function CalcularFrete(const CEP: string; PesoKg, ValorPedido: Double): Double;
begin
  Result := uShippingCalculator.CalcularFrete(CEP, PesoKg, ValorPedido);
end;

function PrazoEntregaDias(const CEP: string): Integer;
begin
  Result := uShippingCalculator.PrazoEntregaDias(CEP);
end;

end.
