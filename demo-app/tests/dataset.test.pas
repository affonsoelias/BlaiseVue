program dataset_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, SysUtils, BVDataSet, BVPascalDX;

begin
  Describe('BlaiseVue 4.2: LiveBindings & Reactive TBVDataSet Engine', procedure
    begin
      It('should create TBVDataSet and manage fields with typed getters and setters', procedure
        var
          ds: TBVDataSet;
        begin
          ds := TBVDataSet.Create;
          try
            ds.AddField('id', ftInteger);
            ds.AddField('name', ftString);
            ds.AddField('price', ftFloat);
            ds.AddField('inStock', ftBoolean);

            Expect(ds.Fields.Count).ToBe(4);
            Expect(ds.FieldByName('name').FieldName).ToBe('name');

            ds.Append;
            Expect(ds.StateStr).ToBe('insert');

            ds.FieldByName('id').AsInteger := 101;
            ds.FieldByName('name').AsString := 'Mechanical Keyboard';
            ds.FieldByName('price').AsFloat := 99.5;
            ds.FieldByName('inStock').AsBoolean := True;

            Expect(ds.FieldByName('id').AsInteger).ToBe(101);
            Expect(ds.FieldByName('name').AsString).ToBe('Mechanical Keyboard');
            Expect(ds.FieldByName('price').AsFloat).ToBe(99.5);
            Expect(ds.FieldByName('inStock').AsBoolean).ToBe(True);

            ds.Post;
            Expect(ds.StateStr).ToBe('browse');
            Expect(ds.RecordCount).ToBe(1);
            Expect(ds.RecNo).ToBe(1);
          finally
            ds.Free;
          end;
        end);

      It('should support navigation: First, Next, Prior, Last, MoveBy, Bof, Eof', procedure
        var
          ds: TBVDataSet;
          jsonStr: string;
        begin
          ds := TBVDataSet.Create;
          try
            jsonStr := '[{"id": 1, "name": "Item A"}, {"id": 2, "name": "Item B"}, {"id": 3, "name": "Item C"}]';
            ds.LoadFromJSON(jsonStr);

            Expect(ds.RecordCount).ToBe(3);
            Expect(ds.RecNo).ToBe(1);
            Expect(ds.Bof).ToBe(True);
            Expect(ds.Eof).ToBe(False);
            Expect(ds.FieldByName('name').AsString).ToBe('Item A');

            ds.Next;
            Expect(ds.RecNo).ToBe(2);
            Expect(ds.FieldByName('name').AsString).ToBe('Item B');
            Expect(ds.Bof).ToBe(False);
            Expect(ds.Eof).ToBe(False);

            ds.Next;
            Expect(ds.RecNo).ToBe(3);
            Expect(ds.FieldByName('name').AsString).ToBe('Item C');
            Expect(ds.Eof).ToBe(True);

            ds.Prior;
            Expect(ds.RecNo).ToBe(2);
            Expect(ds.FieldByName('name').AsString).ToBe('Item B');

            ds.First;
            Expect(ds.RecNo).ToBe(1);
            Expect(ds.Bof).ToBe(True);

            ds.Last;
            Expect(ds.RecNo).ToBe(3);
            Expect(ds.Eof).ToBe(True);

            ds.MoveBy(-2);
            Expect(ds.RecNo).ToBe(1);
          finally
            ds.Free;
          end;
        end);

      It('should handle CRUD operations: Append, Edit, Cancel, Delete and Delta tracking', procedure
        var
          ds: TBVDataSet;
          deltaStr: string;
        begin
          ds := TBVDataSet.Create;
          try
            ds.AddField('id', ftInteger);
            ds.AddField('title', ftString);

            // 1. Insert Record
            ds.Append;
            ds.FieldByName('title').AsString := 'Initial Task';
            ds.Post;

            Expect(ds.RecordCount).ToBe(1);
            Expect(ds.ChangeCount).ToBe(1);

            // 2. Edit Record
            ds.Edit;
            Expect(ds.StateStr).ToBe('edit');
            ds.FieldByName('title').AsString := 'Updated Task';
            ds.Post;

            Expect(ds.FieldByName('title').AsString).ToBe('Updated Task');
            Expect(ds.ChangeCount).ToBe(2);

            // 3. Edit and Cancel
            ds.Edit;
            ds.FieldByName('title').AsString := 'Cancelled Task';
            ds.Cancel;
            Expect(ds.FieldByName('title').AsString).ToBe('Updated Task');
            Expect(ds.ChangeCount).ToBe(2);

            // 4. Verify Delta JSON
            deltaStr := ds.GetDeltaJSON;
            Expect(Pos('insert', deltaStr) > 0).ToBe(True);
            Expect(Pos('update', deltaStr) > 0).ToBe(True);

            // 5. Apply Updates clears delta
            ds.ApplyUpdates;
            Expect(ds.ChangeCount).ToBe(0);

            // 6. Delete
            ds.Delete;
            Expect(ds.RecordCount).ToBe(0);
            Expect(ds.IsEmpty).ToBe(True);
            Expect(ds.ChangeCount).ToBe(1);
          finally
            ds.Free;
          end;
        end);

      It('should support Filtering, Sorting and Locate', procedure
        var
          ds: TBVDataSet;
          jsonStr: string;
          found: Boolean;
        begin
          ds := TBVDataSet.Create;
          try
            jsonStr := '[{"id": 1, "name": "Apple", "category": "Fruit"},' +
                       ' {"id": 2, "name": "Carrot", "category": "Vegetable"},' +
                       ' {"id": 3, "name": "Banana", "category": "Fruit"}]';
            ds.LoadFromJSON(jsonStr);

            Expect(ds.RecordCount).ToBe(3);

            // Locate
            found := ds.Locate('name', 'Banana');
            Expect(found).ToBe(True);
            Expect(ds.FieldByName('name').AsString).ToBe('Banana');
            Expect(ds.FieldByName('id').AsInteger).ToBe(3);

            // Filter
            ds.SetFilter('Fruit');
            Expect(ds.RecordCount).ToBe(2);
            Expect(ds.FieldByName('name').AsString).ToBe('Apple');

            // Sort ascending by name
            ds.SortBy('name', True);
            Expect(ds.FieldByName('name').AsString).ToBe('Apple');
            ds.Next;
            Expect(ds.FieldByName('name').AsString).ToBe('Banana');

            // Clear filter
            ds.ClearFilter;
            Expect(ds.RecordCount).ToBe(3);
          finally
            ds.Free;
          end;
        end);

      It('should support BVPascalDX Dataset helper routines for Zero-ASM DX', procedure
        var
          dsObj: JSValue;
          located: Boolean;
        begin
          dsObj := NewDataSet;
          Expect(dsObj <> nil).ToBe(True);

          DataSetAppend(dsObj);
          DataSetSetFieldVal(dsObj, 'name', 'Zero ASM DX');
          DataSetSetFieldVal(dsObj, 'code', '4.2');
          DataSetPost(dsObj);

          Expect(String(DataSetFieldVal(dsObj, 'name'))).ToBe('Zero ASM DX');

          DataSetAppend(dsObj);
          DataSetSetFieldVal(dsObj, 'name', 'LiveBindings');
          DataSetSetFieldVal(dsObj, 'code', 'LB-01');
          DataSetPost(dsObj);

          DataSetFirst(dsObj);
          Expect(String(DataSetFieldVal(dsObj, 'name'))).ToBe('Zero ASM DX');

          DataSetNext(dsObj);
          Expect(String(DataSetFieldVal(dsObj, 'name'))).ToBe('LiveBindings');

          located := DataSetLocate(dsObj, 'name', 'Zero ASM DX');
          Expect(located).ToBe(True);
          Expect(String(DataSetFieldVal(dsObj, 'code'))).ToBe('4.2');

          DataSetFilter(dsObj, 'LiveBindings');
          Expect(String(DataSetFieldVal(dsObj, 'name'))).ToBe('LiveBindings');

          DataSetFilter(dsObj, '');
          DataSetSort(dsObj, 'name', True);
          DataSetFirst(dsObj);
          Expect(String(DataSetFieldVal(dsObj, 'name'))).ToBe('LiveBindings');
        end);
    end);
end.
