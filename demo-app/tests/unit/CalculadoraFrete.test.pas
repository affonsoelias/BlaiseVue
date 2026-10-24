program calculadorafrete_unit_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCalculadoraFrete;

begin
  Describe('Unit: CalculadoraFrete (Calculos de Negocio)', procedure
    begin
       It('deve aplicar frete gratis para pedidos acima de R$ 250,00', procedure
         begin
            Expect(CalcularFrete('01001-000', 5.0, 300.0)).toBe(0.0);
            Expect(CalcularFrete('40000-000', 10.0, 250.0)).toBe(0.0);
         end);

       It('deve calcular tarifa base para Sudeste com peso ate 1kg', procedure
         begin
            Expect(CalcularFrete('01001-000', 0.5, 100.0)).toBe(15.0);
            Expect(CalcularFrete('20000-000', 1.0, 80.0)).toBe(15.0);
         end);

       It('deve calcular tarifa com adicional de peso acima de 1kg', procedure
         begin
            { SP: Base 15 + (3kg - 1kg) * 3.50 = 15 + 7 = 22.0 }
            Expect(CalcularFrete('01001-000', 3.0, 100.0)).toBe(22.0);
         end);

       It('deve identificar regiao correta e prazo de entrega a partir do CEP', procedure
         begin
            Expect(RegiaoPorCEP('01310-100')).toBe('Sudeste - SP');
            Expect(PrazoEntregaDias('01310-100')).toBe(2);

            Expect(RegiaoPorCEP('80010-000')).toBe('Sul - PR');
            Expect(PrazoEntregaDias('80010-000')).toBe(4);

            Expect(RegiaoPorCEP('40020-000')).toBe('Nordeste - BA');
            Expect(PrazoEntregaDias('40020-000')).toBe(7);
         end);
    end);
end.
