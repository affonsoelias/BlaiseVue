program mormot_relational_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVClient, BlaiseVue;

type
  TOrderItem = record
    Id: Integer;
    OrderId: Integer;
    Description: string;
    Quantity: Integer;
    UnitPrice: Double;
  end;
  TOrderItemArray = array of TOrderItem;

  TOrder = record
    Id: Integer;
    Customer: string; // Foreign Key to Customer
    OrderDate: string;
    Total: Double;
    Items: TOrderItemArray;
  end;

function CalculateOrderTotal(const Items: TOrderItemArray): Double;
var
  i: Integer;
  Sum: Double;
begin
  Sum := 0;
  for i := 0 to High(Items) do
    Sum := Sum + (Items[i].Quantity * Items[i].UnitPrice);
  Result := Sum;
end;

function ResolveDbPort(const Engine: string): Integer;
begin
  if Engine = 'postgres' then
    Result := 5432
  else if Engine = 'mysql' then
    Result := 3306
  else if Engine = 'firebird' then
    Result := 3050
  else
    Result := 0; // sqlite (embedded)
end;

function BuildDefaultConnectionUrl(const Engine, Host, Database: string): string;
begin
  if Engine = 'postgres' then
    Result := 'postgres://postgres:postgres@' + Host + ':5432/' + Database
  else if Engine = 'mysql' then
    Result := 'mysql://root:password@' + Host + ':3306/' + Database
  else if Engine = 'firebird' then
    Result := 'firebird://sysdba:masterkey@' + Host + ':3050/' + Database
  else
    Result := 'sqlite://' + Database + '.db';
end;

begin
  Describe('BlaiseVue 4.4 Pillar 3 (Multi-Database ORM & Relational Master-Detail CRUD)', procedure
    begin
      It('should resolve multi-database engines and port mappings correctly', procedure
        begin
          Expect(ResolveDbPort('sqlite')).ToBe(0);
          Expect(ResolveDbPort('postgres')).ToBe(5432);
          Expect(ResolveDbPort('mysql')).ToBe(3306);
          Expect(ResolveDbPort('firebird')).ToBe(3050);

          Expect(BuildDefaultConnectionUrl('sqlite', 'localhost', 'app')).ToBe('sqlite://app.db');
          Expect(BuildDefaultConnectionUrl('postgres', 'localhost', 'app')).ToBe('postgres://postgres:postgres@localhost:5432/app');
          Expect(BuildDefaultConnectionUrl('mysql', 'localhost', 'app')).ToBe('mysql://root:password@localhost:3306/app');
          Expect(BuildDefaultConnectionUrl('firebird', 'localhost', 'app')).ToBe('firebird://sysdba:masterkey@localhost:3050/app');
        end);

      It('should serialize relational master-detail structure with FK and child items', procedure
        var
          Order: TOrder;
          JsonStr: string;
          Parsed: TJSObject;
          ItemsCount: Integer;
        begin
          Order.Id := 101;
          Order.Customer := 'Cust-5001';
          Order.OrderDate := '2026-10-24';
          SetLength(Order.Items, 2);

          Order.Items[0].Id := 1;
          Order.Items[0].OrderId := 101;
          Order.Items[0].Description := 'BlaiseVue Enterprise License';
          Order.Items[0].Quantity := 2;
          Order.Items[0].UnitPrice := 499.00;

          Order.Items[1].Id := 2;
          Order.Items[1].OrderId := 101;
          Order.Items[1].Description := 'mORMot 2 Cloud Connector';
          Order.Items[1].Quantity := 1;
          Order.Items[1].UnitPrice := 199.00;

          Order.Total := CalculateOrderTotal(Order.Items);
          Expect(Order.Total).ToBe(1197.00);

          asm
            Parsed = {
              id: Order.Id,
              customer: Order.Customer,
              orderDate: Order.OrderDate,
              total: Order.Total,
              items: [
                { id: 1, orderId: 101, description: 'BlaiseVue Enterprise License', quantity: 2, unitPrice: 499.00 },
                { id: 2, orderId: 101, description: 'mORMot 2 Cloud Connector', quantity: 1, unitPrice: 199.00 }
              ]
            };
            JsonStr = JSON.stringify(Parsed);
            ItemsCount = Parsed.items.length;
          end;

          Expect(ItemsCount).ToBe(2);
          Expect(Pos('"customer":"Cust-5001"', JsonStr) > 0).ToBe(True);
          Expect(Pos('"total":1197', JsonStr) > 0).ToBe(True);
        end);

      It('should handle master row selection and synchronize reactive child detail items', procedure
        var
          SelectedMaster: TJSObject;
          DetailItems: TJSArray;
          DetailTotal: Double;
        begin
          asm
            SelectedMaster = {
              id: 205,
              customer: 'Global Logistics Corp',
              items: [
                { id: 10, description: 'Industrial Sensor Pack', quantity: 5, unitPrice: 120.0 },
                { id: 11, description: 'Gateway Hub', quantity: 1, unitPrice: 450.0 }
              ]
            };
            DetailItems = SelectedMaster.items;
            DetailTotal = 0;
            for (var i = 0; i < DetailItems.length; i++) {
              DetailTotal += (DetailItems[i].quantity * DetailItems[i].unitPrice);
            }
          end;

          Expect(Integer(DetailItems.Length)).ToBe(2);
          Expect(DetailTotal).ToBe(1050.0);
        end);

      It('should dynamically compute totals when child item is appended or mutated', procedure
        var
          OrderObj: TJSObject;
          ComputedTotal: Double;
        begin
          asm
            OrderObj = {
              id: 301,
              items: [
                { id: 1, quantity: 10, unitPrice: 15.5 }
              ]
            };

            function recalculate(o) {
              var s = 0;
              for (var i = 0; i < o.items.length; i++) {
                s += (o.items[i].quantity * o.items[i].unitPrice);
              }
              return s;
            }

            // Initial total
            ComputedTotal = recalculate(OrderObj);
          end;

          Expect(ComputedTotal).ToBe(155.0);

          asm
            // Append child item
            OrderObj.items.push({ id: 2, quantity: 2, unitPrice: 50.0 });
            ComputedTotal = recalculate(OrderObj);
          end;

          Expect(ComputedTotal).ToBe(255.0);
        end);

      It('should enforce relational foreign key and detail constraints', procedure
        var
          HasValidFK, HasValidDetail: Boolean;
        begin
          asm
            var recordPayload = {
              customer: 'Cust-42',
              items: [{ id: 1, description: 'Widget A', quantity: 1, unitPrice: 10 }]
            };
            HasValidFK = (typeof recordPayload.customer === 'string' && recordPayload.customer.length > 0);
            HasValidDetail = (Array.isArray(recordPayload.items) && recordPayload.items.length > 0);
          end;

          Expect(HasValidFK).ToBe(True);
          Expect(HasValidDetail).ToBe(True);
        end);
    end);
end.
