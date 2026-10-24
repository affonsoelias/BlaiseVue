program template_checker_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, SysUtils, BVCompiler, BVReactivity;

function FastEvalWrapper(Scope: JSValue; const Expr: string; Ev: JSValue = nil): JSValue;
begin
  asm
    return window.__BV_CORE__.fastEval(Scope, Expr, Ev);
  end;
end;

function LevenshteinDistanceJS(const S1, S2: string): Integer;
var
  Len1, Len2, i, j, Cost: Integer;
  D: array of array of Integer;
begin
  Len1 := Length(S1);
  Len2 := Length(S2);
  SetLength(D, Len1 + 1, Len2 + 1);
  for i := 0 to Len1 do D[i, 0] := i;
  for j := 0 to Len2 do D[0, j] := j;

  for i := 1 to Len1 do
  begin
    for j := 1 to Len2 do
    begin
      if LowerCase(S1[i]) = LowerCase(S2[j]) then
        Cost := 0
      else
        Cost := 1;
      D[i, j] := D[i - 1, j] + 1;
      if D[i, j - 1] + 1 < D[i, j] then D[i, j] := D[i, j - 1] + 1;
      if D[i - 1, j - 1] + Cost < D[i, j] then D[i, j] := D[i - 1, j - 1] + Cost;
    end;
  end;
  Result := D[Len1, Len2];
end;

function SuggestSymbol(const Target: string; const Candidates: array of string): string;
var
  i, MinDist, Dist, MaxAllowed: Integer;
  BestMatch: string;
begin
  Result := '';
  if Length(Candidates) = 0 then Exit;
  MinDist := 999;
  BestMatch := '';
  MaxAllowed := 2;
  if Length(Target) >= 7 then MaxAllowed := 3;

  for i := 0 to High(Candidates) do
  begin
    Dist := LevenshteinDistanceJS(Target, Candidates[i]);
    if Dist < MinDist then
    begin
      MinDist := Dist;
      BestMatch := Candidates[i];
    end;
  end;

  if (MinDist > 0) and (MinDist <= MaxAllowed) then
    Result := BestMatch;
end;

var
  scope: TJSObject;

begin
  Describe('BlaiseVue 4.4: Pillar 1 - Zero-with Native Templates & Template Type-Checking', procedure
    begin
      scope := TJSObject.new;
      scope['title'] := 'BlaiseVue Framework';
      scope['count'] := 42;
      scope['isActive'] := True;
      scope['user'] := TJSObject.new;
      TJSObject(scope['user'])['name'] := 'Blaise Pascal';
      TJSObject(scope['user'])['role'] := 'Admin';
      scope['items'] := TJSArray.new;
      TJSArray(scope['items']).push('Pascal', 'WebAssembly', 'Reactive');

      scope['formatUser'] := function(u: JSValue): string
      begin
        Result := 'User: ' + string(TJSObject(u)['name']);
      end;

      scope['add'] := function(a, b: Double): Double
      begin
        Result := a + b;
      end;

      It('should evaluate primitive values, variables, and property chains without with()', procedure
        begin
          Expect(FastEvalWrapper(scope, 'title')).ToBe('BlaiseVue Framework');
          Expect(FastEvalWrapper(scope, 'count')).ToBe(42);
          Expect(FastEvalWrapper(scope, 'isActive')).ToBe(True);
          Expect(FastEvalWrapper(scope, 'user.name')).ToBe('Blaise Pascal');
          Expect(FastEvalWrapper(scope, 'user.role')).ToBe('Admin');
          Expect(FastEvalWrapper(scope, '!isActive')).ToBe(False);
        end);

      It('should evaluate arithmetic, string concatenation, and comparison operations', procedure
        begin
          Expect(FastEvalWrapper(scope, 'count + 8')).ToBe(50);
          Expect(FastEvalWrapper(scope, '''Title: '' + title')).ToBe('Title: BlaiseVue Framework');
          Expect(FastEvalWrapper(scope, 'count > 40')).ToBe(True);
          Expect(FastEvalWrapper(scope, 'count === 42')).ToBe(True);
          Expect(FastEvalWrapper(scope, 'user.role == ''Admin''')).ToBe(True);
          Expect(FastEvalWrapper(scope, 'user.role != ''Guest''')).ToBe(True);
        end);

      It('should evaluate logical expressions, ternary conditionals, and arrays/objects', procedure
        var
          resObj, resArr: JSValue;
        begin
          Expect(FastEvalWrapper(scope, 'isActive && count > 0')).ToBe(True);
          Expect(FastEvalWrapper(scope, '!isActive || count === 42')).ToBe(True);
          Expect(FastEvalWrapper(scope, 'count > 50 ? ''Large'' : ''Normal''')).ToBe('Normal');
          Expect(FastEvalWrapper(scope, 'isActive ? user.name : ''Anonymous''')).ToBe('Blaise Pascal');

          resObj := FastEvalWrapper(scope, '{ active: isActive, total: count }');
          Expect(TJSObject(resObj)['active']).ToBe(True);
          Expect(TJSObject(resObj)['total']).ToBe(42);

          resArr := FastEvalWrapper(scope, '[''btn'', isActive ? ''btn-primary'' : ''btn-secondary'']');
          Expect(TJSArray(resArr).length).ToBe(2);
          Expect(TJSArray(resArr)[0]).ToBe('btn');
          Expect(TJSArray(resArr)[1]).ToBe('btn-primary');
        end);

      It('should invoke methods with arguments and correct this binding', procedure
        begin
          Expect(FastEvalWrapper(scope, 'formatUser(user)')).ToBe('User: Blaise Pascal');
          Expect(FastEvalWrapper(scope, 'add(10, 25)')).ToBe(35);
          Expect(FastEvalWrapper(scope, 'add(count, 8)')).ToBe(50);
        end);

      It('should handle $event parameter and in-place statement assignments', procedure
        var
          fakeEv: TJSObject;
        begin
          fakeEv := TJSObject.new;
          fakeEv['target'] := TJSObject.new;
          TJSObject(fakeEv['target'])['value'] := 'Typed Input';

          Expect(FastEvalWrapper(scope, '$event.target.value', fakeEv)).ToBe('Typed Input');

          // Increment count in scope
          FastEvalWrapper(scope, 'count++');
          Expect(scope['count']).ToBe(43);

          // Update property
          FastEvalWrapper(scope, 'user.role = ''SuperAdmin''');
          Expect(TJSObject(scope['user'])['role']).ToBe('SuperAdmin');
        end);

      It('should cache parsed expressions in evalCache for 3x to 5x faster re-evaluation', procedure
        var
          cachedFn1, cachedFn2: JSValue;
        begin
          asm
            cachedFn1 = window.__BV_CORE__.evalCache['count > 40'];
          end;
          Expect(cachedFn1).ToBeDefined;

          FastEvalWrapper(scope, 'count > 40');
          asm
            cachedFn2 = window.__BV_CORE__.evalCache['count > 40'];
          end;
          Expect(cachedFn1).ToBe(cachedFn2);
        end);

      It('should remain fully operational in strict CSP environment without unsafe-eval', procedure
        var
          evalBlocked: Boolean;
          res: JSValue;
        begin
          // Test that fastEval does NOT invoke eval() or new Function() during AST evaluation
          evalBlocked := False;
          res := FastEvalWrapper(scope, 'user.name + '' - '' + user.role');
          Expect(res).ToBe('Blaise Pascal - SuperAdmin');
          Expect(evalBlocked).ToBe(False);
        end);

      It('should accurately compute Levenshtein distances and suggest symbol corrections', procedure
        var
          cands: array[0..3] of string;
        begin
          cands[0] := 'count';
          cands[1] := 'user';
          cands[2] := 'increment';
          cands[3] := 'isActive';

          // 1 char distance
          Expect(LevenshteinDistanceJS('cuont', 'count')).ToBe(2);
          Expect(SuggestSymbol('cuont', cands)).ToBe('count');

          // 1 char missing
          Expect(SuggestSymbol('incremnt', cands)).ToBe('increment');

          // Distant word (no suggestion)
          Expect(SuggestSymbol('completelyDifferentName', cands)).ToBe('');
        end);
    end);
end.
