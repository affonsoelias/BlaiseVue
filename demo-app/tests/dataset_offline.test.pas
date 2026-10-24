program dataset_offline_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, SysUtils, BVDataSet, BVPascalDX;

begin
  Describe('BlaiseVue 4.4: Offline-First TBVDataSet & Delta Sync (Pillar 2)', procedure
    begin
      It('should track rich transactional delta metadata for insert, update and delete', procedure
        var
          ds: TBVDataSet;
          d: TJSArray;
          item0, item1, item2: TJSObject;
        begin
          ds := TBVDataSet.Create;
          try
            ds.TableName := 'customers';
            ds.AddField('id', ftInteger);
            ds.AddField('name', ftString);
            ds.AddField('city', ftString);

            Expect(ds.HasPendingChanges).ToBe(False);
            Expect(ds.ChangeCount).ToBe(0);

            // 1. Insert offline
            ds.Append;
            ds.FieldByName('name').AsString := 'Empresa Alfa';
            ds.FieldByName('city').AsString := 'São Paulo';
            ds.Post;

            Expect(ds.RecordCount).ToBe(1);
            Expect(ds.ChangeCount).ToBe(1);
            Expect(ds.HasPendingChanges).ToBe(True);

            d := ds.Delta;
            item0 := TJSObject(d[0]);
            Expect(String(item0['action'])).ToBe('insert');
            Expect(String(item0['tableName'])).ToBe('customers');
            Expect(String(item0['status'])).ToBe('pending');
            Expect(Integer(item0['timestamp']) > 0).ToBe(True);
            Expect(item0['clientId'] <> undefined).ToBe(True);

            // 2. Update offline
            ds.Edit;
            ds.FieldByName('city').AsString := 'Campinas';
            ds.Post;

            Expect(ds.ChangeCount).ToBe(2);
            item1 := TJSObject(d[1]);
            Expect(String(item1['action'])).ToBe('update');
            Expect(item1['oldRecord'] <> undefined).ToBe(True);

            // 3. Delete offline
            ds.Delete;
            Expect(ds.RecordCount).ToBe(0);
            Expect(ds.ChangeCount).ToBe(3);
            item2 := TJSObject(d[2]);
            Expect(String(item2['action'])).ToBe('delete');
          finally
            ds.Free;
          end;
        end);

      It('should reconcile delta and remap temporary client IDs from server response', procedure
        var
          ds: TBVDataSet;
          resp: TJSObject;
          ids: TJSObject;
          tempId: Integer;
        begin
          ds := TBVDataSet.Create;
          try
            ds.TableName := 'products';
            ds.AddField('id', ftInteger);
            ds.AddField('title', ftString);

            // Insert two records offline
            ds.Append;
            ds.FieldByName('id').AsInteger := -1;
            ds.FieldByName('title').AsString := 'Wireless Mouse';
            ds.Post;

            ds.Append;
            ds.FieldByName('id').AsInteger := -2;
            ds.FieldByName('title').AsString := 'Mechanical Keyboard';
            ds.Post;

            Expect(ds.RecordCount).ToBe(2);
            Expect(ds.ChangeCount).ToBe(2);
            Expect(ds.HasPendingChanges).ToBe(True);

            // Simulate server response allocating real IDs 501 and 502
            resp := TJSObject.new;
            resp['status'] := 'ok';
            resp['syncedCount'] := 2;

            ids := TJSObject.new;
            ids['-1'] := 501;
            ids['-2'] := 502;
            resp['insertedIds'] := ids;

            ds.ReconcileDelta(resp);

            Expect(ds.ChangeCount).ToBe(0);
            Expect(ds.HasPendingChanges).ToBe(False);

            ds.First;
            Expect(ds.FieldByName('id').AsInteger).ToBe(501);
            Expect(ds.FieldByName('title').AsString).ToBe('Wireless Mouse');

            ds.Next;
            Expect(ds.FieldByName('id').AsInteger).ToBe(502);
            Expect(ds.FieldByName('title').AsString).ToBe('Mechanical Keyboard');
          finally
            ds.Free;
          end;
        end);

      It('should resolve conflicts using crServerWins and crClientWins policies', procedure
        var
          dsServerWins, dsClientWins: TBVDataSet;
          resp: TJSObject;
          conflicts: TJSArray;
          confItem: TJSObject;
          sRec: TJSObject;
        begin
          // Policy 1: crServerWins
          dsServerWins := TBVDataSet.Create;
          try
            dsServerWins.ConflictResolution := crServerWins;
            dsServerWins.AddField('id', ftInteger);
            dsServerWins.AddField('name', ftString);

            dsServerWins.Append;
            dsServerWins.FieldByName('id').AsInteger := 99;
            dsServerWins.FieldByName('name').AsString := 'Client Name Edit';
            dsServerWins.Post;

            // Conflict: server modified name to 'Server Master Name'
            resp := TJSObject.new;
            conflicts := TJSArray.new;
            confItem := TJSObject.new;
            confItem['id'] := 99;
            sRec := TJSObject.new;
            sRec['id'] := 99;
            sRec['name'] := 'Server Master Name';
            confItem['serverRecord'] := sRec;
            conflicts.push(confItem);
            resp['conflicts'] := conflicts;

            dsServerWins.ReconcileDelta(resp);
            Expect(dsServerWins.FieldByName('name').AsString).ToBe('Server Master Name');
          finally
            dsServerWins.Free;
          end;

          // Policy 2: crClientWins
          dsClientWins := TBVDataSet.Create;
          try
            dsClientWins.ConflictResolution := crClientWins;
            dsClientWins.AddField('id', ftInteger);
            dsClientWins.AddField('name', ftString);

            dsClientWins.Append;
            dsClientWins.FieldByName('id').AsInteger := 99;
            dsClientWins.FieldByName('name').AsString := 'Preserved Client Name';
            dsClientWins.Post;

            resp := TJSObject.new;
            conflicts := TJSArray.new;
            confItem := TJSObject.new;
            confItem['id'] := 99;
            sRec := TJSObject.new;
            sRec['id'] := 99;
            sRec['name'] := 'Ignored Server Name';
            confItem['serverRecord'] := sRec;
            conflicts.push(confItem);
            resp['conflicts'] := conflicts;

            dsClientWins.ReconcileDelta(resp);
            Expect(dsClientWins.FieldByName('name').AsString).ToBe('Preserved Client Name');
          finally
            dsClientWins.Free;
          end;
        end);

      It('should persist and restore dataset records and deltas via TBVIndexedDBAdapter', procedure
        var
          dsSave, dsLoad: TBVDataSet;
          savedData: JSValue;
        begin
          Expect(TBVIndexedDBAdapter.IsSupported).ToBe(True);

          dsSave := TBVDataSet.Create;
          try
            dsSave.TableName := 'inventory';
            dsSave.AddField('id', ftInteger);
            dsSave.AddField('sku', ftString);
            dsSave.AddField('qty', ftInteger);

            dsSave.Append;
            dsSave.FieldByName('id').AsInteger := 10;
            dsSave.FieldByName('sku').AsString := 'SKU-ABC-1';
            dsSave.FieldByName('qty').AsInteger := 150;
            dsSave.Post;

            // Save to IndexedDB (with fallback)
            dsSave.SaveToIndexedDB('test_inventory', procedure(payload: JSValue)
              begin
                savedData := payload;
              end, nil);

            Expect(savedData <> nil).ToBe(True);
          finally
            dsSave.Free;
          end;

          // Load into a new dataset instance
          dsLoad := TBVDataSet.Create;
          try
            dsLoad.TableName := 'inventory';
            dsLoad.LoadFromIndexedDB('test_inventory', procedure(DataSet: TBVDataSet; data: JSValue)
              begin
                // Verified in onComplete callback
              end);

            Expect(dsLoad.RecordCount).ToBe(1);
            Expect(dsLoad.FieldByName('sku').AsString).ToBe('SKU-ABC-1');
            Expect(dsLoad.FieldByName('qty').AsInteger).ToBe(150);
            Expect(dsLoad.ChangeCount).ToBe(1); // Pending insert delta restored
          finally
            dsLoad.Free;
          end;
        end);

      It('should support AutoPersist mode and automatically update storage on Post and Delete', procedure
        var
          ds: TBVDataSet;
          dsVerify: TBVDataSet;
        begin
          ds := TBVDataSet.Create;
          try
            ds.SetAutoPersist(True, 'auto_sync_store');
            ds.AddField('id', ftInteger);
            ds.AddField('item', ftString);

            ds.Append;
            ds.FieldByName('id').AsInteger := 1;
            ds.FieldByName('item').AsString := 'Auto Item A';
            ds.Post;

            ds.Append;
            ds.FieldByName('id').AsInteger := 2;
            ds.FieldByName('item').AsString := 'Auto Item B';
            ds.Post;
          finally
            ds.Free;
          end;

          // Verify loaded dataset has both items automatically persisted
          dsVerify := TBVDataSet.Create;
          try
            dsVerify.LoadFromIndexedDB('auto_sync_store', nil);
            Expect(dsVerify.RecordCount).ToBe(2);
            Expect(dsVerify.ChangeCount).ToBe(2);
          finally
            dsVerify.Free;
          end;
        end);

      It('should trigger ApplyUpdates on auto-sync reconnect simulation', procedure
        var
          ds: TBVDataSet;
          applied: Boolean;
        begin
          applied := False;
          ds := TBVDataSet.Create;
          try
            ds.TableName := 'sync_test';
            ds.AddField('id', ftInteger);
            ds.AddField('val', ftString);

            ds.Append;
            ds.FieldByName('val').AsString := 'Pending Reconnect';
            ds.Post;

            Expect(ds.HasPendingChanges).ToBe(True);

            // Register after apply updates callback
            ds.AfterApplyUpdates := procedure(DataSet: TBVDataSet)
              begin
                applied := True;
              end;

            // Trigger local ApplyUpdates
            ds.ApplyUpdates;

            Expect(applied).ToBe(True);
            Expect(ds.ChangeCount).ToBe(0);
            Expect(ds.HasPendingChanges).ToBe(False);
          finally
            ds.Free;
          end;
        end);

      It('should support Zero-ASM BVPascalDX Dataset offline helper routines', procedure
        var
          dsObj: JSValue;
          hasPend: Boolean;
          cnt: Integer;
          dList: JSValue;
        begin
          dsObj := NewDataSet;
          Expect(dsObj <> nil).ToBe(True);

          DataSetSetAutoPersist(dsObj, True, 'dx_offline_store');
          DataSetSetAutoSync(dsObj, True, '/api/dataset/apply');

          Expect(DataSetHasPending(dsObj)).ToBe(False);
          Expect(DataSetChangeCount(dsObj)).ToBe(0);

          DataSetAppend(dsObj);
          DataSetSetFieldVal(dsObj, 'title', 'DX Offline Task');
          DataSetPost(dsObj);

          Expect(DataSetHasPending(dsObj)).ToBe(True);
          Expect(DataSetChangeCount(dsObj)).ToBe(1);

          dList := DataSetDeltaList(dsObj);
          Expect(dList <> nil).ToBe(True);

          // Clear delta
          DataSetClearDelta(dsObj);
          Expect(DataSetHasPending(dsObj)).ToBe(False);
          Expect(DataSetChangeCount(dsObj)).ToBe(0);
        end);
    end);
end.
