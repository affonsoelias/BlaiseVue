program conditional_directives_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVComponents, BVCompiler, BVReactivity;

var
  Wrapper: TWrapper;

procedure RegisterTemplate(const AName, ATemplate: string; AData: TJSObject);
var
  Comp: TJSObject;
begin
  Comp := TJSObject.new;
  Comp['template'] := ATemplate;
  Comp['data'] := function(): TJSObject
  var
    Key: string;
  begin
    Result := TJSObject.new;
    for Key in TJSObject.keys(AData) do
      Result[Key] := AData[Key];
  end;
  RegisterComponent(AName, Comp);
end;

function Exists(const ASelector: string): Boolean;
begin
  Result := Wrapper.Element.querySelector(ASelector) <> nil;
end;

function TextOf(const ASelector: string): string;
var
  El: TJSElement;
begin
  El := Wrapper.Element.querySelector(ASelector);
  if El <> nil then
    Result := TJSString(El.textContent).trim()
  else
    Result := '';
end;

procedure SetupComponents;
begin
  // 1. Basic b-if / b-else
  RegisterTemplate('test-b-if-else',
    '<div>' +
    '  <button class="toggle" @click="loggedIn = !loggedIn">Toggle</button>' +
    '  <div class="user-badge" b-if="loggedIn">Welcome User!</div>' +
    '  <div class="guest-badge" b-else>Please Sign In</div>' +
    '</div>',
    new(['loggedIn', True]));

  // 2. Basic v-if / v-else
  RegisterTemplate('test-v-if-else',
    '<div>' +
    '  <button class="toggle" @click="active = !active">Toggle</button>' +
    '  <span class="online" v-if="active">Online</span>' +
    '  <span class="offline" v-else>Offline</span>' +
    '</div>',
    new(['active', False]));

  // 3. Multi-branch b-if / b-else-if / b-else
  RegisterTemplate('test-b-grade',
    '<div>' +
    '  <button class="set-a" @click="score = 95">A</button>' +
    '  <button class="set-b" @click="score = 75">B</button>' +
    '  <button class="set-c" @click="score = 40">C</button>' +
    '  <p class="grade-a" b-if="score >= 90">Grade A</p>' +
    '  <p class="grade-b" b-else-if="score >= 70">Grade B</p>' +
    '  <p class="grade-c" b-else>Grade C</p>' +
    '</div>',
    new(['score', 95]));

  // 4. Multi-branch v-if / v-else-if / v-else
  RegisterTemplate('test-v-grade',
    '<div>' +
    '  <button class="set-first" @click="step = 1">1</button>' +
    '  <button class="set-second" @click="step = 2">2</button>' +
    '  <button class="set-third" @click="step = 3">3</button>' +
    '  <div class="step-1" v-if="step === 1">Step 1</div>' +
    '  <div class="step-2" v-else-if="step === 2">Step 2</div>' +
    '  <div class="step-other" v-else>Other Step</div>' +
    '</div>',
    new(['step', 1]));

  // 5. b-if / b-else-if without b-else
  RegisterTemplate('test-no-else',
    '<div>' +
    '  <button class="set-yes" @click="mode = ''yes''">Yes</button>' +
    '  <button class="set-maybe" @click="mode = ''maybe''">Maybe</button>' +
    '  <button class="set-no" @click="mode = ''none''">None</button>' +
    '  <span class="branch-yes" b-if="mode === ''yes''">YES</span>' +
    '  <span class="branch-maybe" b-else-if="mode === ''maybe''">MAYBE</span>' +
    '</div>',
    new(['mode', 'yes']));

  // 6. Components in conditional branches
  RegisterTemplate('comp-card',
    '<div class="custom-card"><slot></slot></div>',
    TJSObject.new);

  RegisterTemplate('test-comp-branches',
    '<div>' +
    '  <button class="toggle" @click="showFirst = !showFirst">Toggle</button>' +
    '  <comp-card class="card-first" b-if="showFirst"><strong class="title">First Card</strong></comp-card>' +
    '  <comp-card class="card-second" b-else><em class="title">Second Card</em></comp-card>' +
    '</div>',
    new(['showFirst', True]));
end;

begin
  SetupComponents;

  Describe('Conditional Directives (b-if, b-else, b-else-if, v-if, v-else, v-else-if)', procedure
    begin
       It('should render b-if and switch to b-else reactively', procedure
         begin
            Wrapper := Mount('test-b-if-else');
            Expect(Exists('.user-badge')).ToBe(True);
            Expect(Exists('.guest-badge')).ToBe(False);
            Expect(TextOf('.user-badge')).ToBe('Welcome User!');

            Wrapper.Find('.toggle').click();
            Expect(Exists('.user-badge')).ToBe(False);
            Expect(Exists('.guest-badge')).ToBe(True);
            Expect(TextOf('.guest-badge')).ToBe('Please Sign In');

            Wrapper.Find('.toggle').click();
            Expect(Exists('.user-badge')).ToBe(True);
            Expect(Exists('.guest-badge')).ToBe(False);
         end);

       It('should render v-else initially when v-if is false and switch to v-if', procedure
         begin
            Wrapper := Mount('test-v-if-else');
            Expect(Exists('.online')).ToBe(False);
            Expect(Exists('.offline')).ToBe(True);
            Expect(TextOf('.offline')).ToBe('Offline');

            Wrapper.Find('.toggle').click();
            Expect(Exists('.online')).ToBe(True);
            Expect(Exists('.offline')).ToBe(False);
            Expect(TextOf('.online')).ToBe('Online');

            Wrapper.Find('.toggle').click();
            Expect(Exists('.online')).ToBe(False);
            Expect(Exists('.offline')).ToBe(True);
         end);

       It('should support b-if, b-else-if and b-else multi-branch chains', procedure
         begin
            Wrapper := Mount('test-b-grade');
            Expect(Exists('.grade-a')).ToBe(True);
            Expect(Exists('.grade-b')).ToBe(False);
            Expect(Exists('.grade-c')).ToBe(False);

            Wrapper.Find('.set-b').click();
            Expect(Exists('.grade-a')).ToBe(False);
            Expect(Exists('.grade-b')).ToBe(True);
            Expect(Exists('.grade-c')).ToBe(False);

            Wrapper.Find('.set-c').click();
            Expect(Exists('.grade-a')).ToBe(False);
            Expect(Exists('.grade-b')).ToBe(False);
            Expect(Exists('.grade-c')).ToBe(True);

            Wrapper.Find('.set-a').click();
            Expect(Exists('.grade-a')).ToBe(True);
            Expect(Exists('.grade-b')).ToBe(False);
            Expect(Exists('.grade-c')).ToBe(False);
         end);

       It('should support v-if, v-else-if and v-else multi-branch chains', procedure
         begin
            Wrapper := Mount('test-v-grade');
            Expect(Exists('.step-1')).ToBe(True);
            Expect(Exists('.step-2')).ToBe(False);
            Expect(Exists('.step-other')).ToBe(False);

            Wrapper.Find('.set-second').click();
            Expect(Exists('.step-1')).ToBe(False);
            Expect(Exists('.step-2')).ToBe(True);
            Expect(Exists('.step-other')).ToBe(False);

            Wrapper.Find('.set-third').click();
            Expect(Exists('.step-1')).ToBe(False);
            Expect(Exists('.step-2')).ToBe(False);
            Expect(Exists('.step-other')).ToBe(True);
         end);

       It('should support b-if and b-else-if without b-else when no branch matches', procedure
         begin
            Wrapper := Mount('test-no-else');
            Expect(Exists('.branch-yes')).ToBe(True);
            Expect(Exists('.branch-maybe')).ToBe(False);

            Wrapper.Find('.set-maybe').click();
            Expect(Exists('.branch-yes')).ToBe(False);
            Expect(Exists('.branch-maybe')).ToBe(True);

            Wrapper.Find('.set-no').click();
            Expect(Exists('.branch-yes')).ToBe(False);
            Expect(Exists('.branch-maybe')).ToBe(False);

            Wrapper.Find('.set-yes').click();
            Expect(Exists('.branch-yes')).ToBe(True);
            Expect(Exists('.branch-maybe')).ToBe(False);
         end);

       It('should preserve component slots and lifecycle when switching between b-if and b-else', procedure
         begin
            Wrapper := Mount('test-comp-branches');
            Expect(Exists('.card-first')).ToBe(True);
            Expect(Exists('.card-second')).ToBe(False);
            Expect(TextOf('.card-first .title')).ToBe('First Card');

            Wrapper.Find('.toggle').click();
            Expect(Exists('.card-first')).ToBe(False);
            Expect(Exists('.card-second')).ToBe(True);
            Expect(TextOf('.card-second .title')).ToBe('Second Card');

            Wrapper.Find('.toggle').click();
            Expect(Exists('.card-first')).ToBe(True);
            Expect(Exists('.card-second')).ToBe(False);
            Expect(TextOf('.card-first .title')).ToBe('First Card');
         end);
    end);
end.
