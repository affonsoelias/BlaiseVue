program pascal_dx_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, SysUtils, BVPascalDX;

begin
  Describe('BlaiseVue 4.0 Phase 8: Pure Object Pascal DX & Zero-ASM Architecture (BVPascalDX)', procedure
    begin
      It('should create and assign objects and arrays without asm blocks', procedure
        var
          obj, target, merged: JSValue;
          arr: TJSArray;
        begin
          obj := NewObject;
          Expect(obj <> nil).ToBe(True);
          SetField(obj, 'name', 'Blaise');
          SetField(obj, 'version', 4);
          SetField(obj, 'active', True);

          Expect(GetFieldStr(obj, 'name')).ToBe('Blaise');
          Expect(GetFieldInt(obj, 'version')).ToBe(4);
          Expect(GetFieldBool(obj, 'active')).ToBe(True);

          target := NewObject;
          SetField(target, 'framework', 'BlaiseVue');
          merged := ObjectAssign(target, obj);
          Expect(GetFieldStr(merged, 'framework')).ToBe('BlaiseVue');
          Expect(GetFieldStr(merged, 'name')).ToBe('Blaise');

          arr := NewArray;
          Expect(arr <> nil).ToBe(True);
          arr.push(merged);
          Expect(arr.length).ToBe(1);
        end);

      It('should serialize and parse JSON and timestamps using Pascal helpers', procedure
        var
          raw: TJSObject;
          jsonStr: string;
          parsed: JSValue;
          ts: string;
        begin
          raw := NewObject;
          raw['title'] := 'Pascal Pure';
          raw['year'] := 2026;
          
          jsonStr := JsonStringify(raw);
          Expect(Pos('Pascal Pure', jsonStr) > 0).ToBe(True);

          parsed := JsonParse(jsonStr);
          Expect(parsed <> nil).ToBe(True);
          Expect(GetFieldStr(parsed, 'title')).ToBe('Pascal Pure');
          Expect(GetFieldInt(parsed, 'year')).ToBe(2026);

          ts := NowTimestampStr;
          Expect(Length(ts) > 5).ToBe(True);
        end);

      It('should filter collections and search items by query without inline asm', procedure
        var
          items: TJSArray;
          i1, i2, i3: TJSObject;
          filtered, found, remaining: JSValue;
        begin
          items := NewArray;
          
          i1 := NewObject;
          i1['id'] := 1;
          i1['name'] := 'Alpha Product';
          i1['category'] := 'Hardware';
          items.push(i1);

          i2 := NewObject;
          i2['id'] := 2;
          i2['name'] := 'Beta Software';
          i2['category'] := 'Services';
          items.push(i2);

          i3 := NewObject;
          i3['id'] := 3;
          i3['name'] := 'Gamma Tools';
          i3['category'] := 'Hardware';
          items.push(i3);

          // Query matching 'software'
          filtered := FilterByQuery(items, 'software');
          Expect(TJSArray(filtered).length).ToBe(1);
          Expect(GetFieldStr(TJSArray(filtered)[0], 'name')).ToBe('Beta Software');

          // Query matching 'hardware'
          filtered := FilterByQuery(items, 'hardware');
          Expect(TJSArray(filtered).length).ToBe(2);

          // Find by id
          found := FindItemById(items, 2);
          Expect(found <> nil).ToBe(True);
          Expect(GetFieldStr(found, 'name')).ToBe('Beta Software');

          // Remove by id
          remaining := RemoveItemById(items, 2);
          Expect(TJSArray(remaining).length).ToBe(2);
          Expect(FindItemById(remaining, 2) = nil).ToBe(True);
        end);

      It('should invoke methods and component refs cleanly using Pascal helpers', procedure
        var
          instance: TJSObject;
          refs: TJSObject;
          modalRef: TJSObject;
          calledDirect: Boolean;
          modalOpened: Boolean;
          calcResult: JSValue;
        begin
          calledDirect := False;
          modalOpened := False;

          instance := NewObject;
          instance['doSomething'] := procedure()
            begin
              calledDirect := True;
            end;
          instance['multiply'] := function(a, b: JSValue): JSValue
            begin
              Result := Integer(a) * Integer(b);
            end;

          CallMethod(instance, 'doSomething');
          Expect(calledDirect).ToBe(True);

          calcResult := CallFunction(instance, 'multiply', [6, 7]);
          Expect(calcResult).ToBe(42);

          // Test TriggerRef
          modalRef := NewObject;
          modalRef['showModal'] := procedure()
            begin
              modalOpened := True;
            end;

          refs := NewObject;
          refs['myModal'] := modalRef;
          instance['$refs'] := refs;

          TriggerRef(instance, 'myModal', 'show');
          Expect(modalOpened).ToBe(True);
        end);

      It('should handle form validation wrappers seamlessly', procedure
        var
          formInstance: TJSObject;
          vObj: TJSObject;
          touched, resetCalled: Boolean;
          isValid: Boolean;
        begin
          touched := False;
          resetCalled := False;

          formInstance := NewObject;
          vObj := NewObject;
          vObj['$touch'] := procedure() begin touched := True; end;
          vObj['$reset'] := procedure() begin resetCalled := True; end;
          formInstance['$v'] := vObj;
          formInstance['$validate'] := function(): Boolean begin Result := True; end;

          isValid := ValidateForm(formInstance);
          Expect(isValid).ToBe(True);

          TouchValidation(formInstance);
          Expect(touched).ToBe(True);

          ResetValidation(formInstance);
          Expect(resetCalled).ToBe(True);
        end);

      It('should provide fallback UI toast and navigation helpers safely', procedure
        var
          hasConfirmed: Boolean;
        begin
          // ShowToast executes without throwing
          ShowToast('Pascal DX Toast Test', 100);

          // Confirm stub test
          asm
            var origConfirm = window.confirm;
            window.confirm = function(m) { return true; };
          end;

          hasConfirmed := Confirm('Confirm action?');
          Expect(hasConfirmed).ToBe(True);

          asm
            window.confirm = origConfirm;
          end;

          // Navigation test
          NavigateTo('/charts');
          Expect((window.location.hash = '#/charts') or (window.location.pathname = '/charts')).ToBe(True);
        end);
    end);
end.
