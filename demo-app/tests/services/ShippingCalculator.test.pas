program shipping_calculator_unit_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uShippingCalculator;

begin
  Describe('Service: ShippingCalculator (Canonical English API)', procedure
    begin
       It('should apply free shipping for orders exceeding $250.00', procedure
         begin
            Expect(CalculateShipping('01001-000', 5.0, 300.0)).toBe(0.0);
            Expect(CalculateShipping('40000-000', 10.0, 250.0)).toBe(0.0);
         end);

       It('should calculate base rate for Southeast region under 1kg', procedure
         begin
            Expect(CalculateShipping('01001-000', 0.5, 100.0)).toBe(15.0);
            Expect(CalculateShipping('20000-000', 1.0, 80.0)).toBe(15.0);
         end);

       It('should calculate weight surcharges for packages above 1kg', procedure
         begin
            { Base 15 + (3kg - 1kg) * 3.50 = 15 + 7 = 22.0 }
            Expect(CalculateShipping('01001-000', 3.0, 100.0)).toBe(22.0);
         end);

       It('should resolve region and delivery days by ZIP code', procedure
         begin
            Expect(GetRegionByZipCode('01310-100')).toBe('Southeast - SP');
            Expect(GetDeliveryDays('01310-100')).toBe(2);

            Expect(GetRegionByZipCode('80010-000')).toBe('South - PR');
            Expect(GetDeliveryDays('80010-000')).toBe(4);

            Expect(GetRegionByZipCode('40020-000')).toBe('Northeast - BA');
            Expect(GetDeliveryDays('40020-000')).toBe(7);
         end);
    end);
end.
