program formatters_unit_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uFormatters;

begin
  Describe('Service: Formatters (Rules and String Formatting)', procedure
    begin
       It('should format currency in Brazilian Real (BRL)', procedure
         begin
            Expect(FormatCurrency(1250.50)).toBe('R$ 1250,50');
            Expect(FormatCurrency(0.0)).toBe('R$ 0,00');
            Expect(FormatCurrency(99.99)).toBe('R$ 99,99');
         end);

       It('should format currency in US Dollars (USD)', procedure
         begin
            Expect(FormatCurrencyUSD(1250.50)).toBe('$1250.50');
            Expect(FormatCurrencyUSD(0.0)).toBe('$0.00');
            Expect(FormatCurrencyUSD(99.99)).toBe('$99.99');
         end);

       It('should format CPF identification numbers', procedure
         begin
            Expect(FormatCPF('12345678901')).toBe('123.456.789-01');
            Expect(FormatCPF('123.456.789-01')).toBe('123.456.789-01');
         end);

       It('should format Brazilian telephone numbers', procedure
         begin
            Expect(FormatPhone('11987654321')).toBe('(11) 98765-4321');
            Expect(FormatPhone('1133334444')).toBe('(11) 3333-4444');
         end);

       It('should format dates in Brazilian (DD/MM/YYYY) and ISO (YYYY-MM-DD) standards', procedure
         begin
            Expect(FormatDateBR(2026, 10, 24)).toBe('24/10/2026');
            Expect(FormatDateBR(2026, 5, 8)).toBe('08/05/2026');
            Expect(FormatDateISO(2026, 10, 24)).toBe('2026-10-24');
         end);

       It('should pad strings on the left with PadLeft', procedure
         begin
            Expect(PadLeft('42', 5, '0')).toBe('00042');
            Expect(PadLeft('123', 3, '0')).toBe('123');
         end);
    end);
end.
