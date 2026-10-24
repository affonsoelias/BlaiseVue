program formatters_unit_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uFormatters;

begin
  Describe('Unit: Formatters (Regras e Formatadores)', procedure
    begin
       It('deve formatar valor monetario em Real (BRL)', procedure
         begin
            Expect(FormatCurrency(1250.50)).toBe('R$ 1250,50');
            Expect(FormatCurrency(0.0)).toBe('R$ 0,00');
            Expect(FormatCurrency(99.99)).toBe('R$ 99,99');
         end);

       It('deve formatar CPF com mascara valida', procedure
         begin
            Expect(FormatCPF('12345678901')).toBe('123.456.789-01');
            Expect(FormatCPF('123.456.789-01')).toBe('123.456.789-01');
         end);

       It('deve formatar telefone celular e fixo brasileiro', procedure
         begin
            Expect(FormatPhone('11987654321')).toBe('(11) 98765-4321');
            Expect(FormatPhone('1133334444')).toBe('(11) 3333-4444');
         end);

       It('deve formatar data no padrao DD/MM/AAAA', procedure
         begin
            Expect(FormatDateBR(2026, 10, 24)).toBe('24/10/2026');
            Expect(FormatDateBR(2026, 5, 8)).toBe('08/05/2026');
         end);

       It('deve preencher caracteres a esquerda com PadLeft', procedure
         begin
            Expect(PadLeft('42', 5, '0')).toBe('00042');
            Expect(PadLeft('123', 3, '0')).toBe('123');
         end);
    end);
end.
