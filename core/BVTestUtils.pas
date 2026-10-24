unit BVTestUtils;

{
  BVTestUtils - Unit Testing Framework for BlaiseVue
  --------------------------------------------------
  Integrates Vitest with Pascal, providing a familiar API for
  mounting components, triggering events, and asserting values.
}

{$mode objfpc}

interface

uses JS, Web, BVReactivity, BVCompiler;

type
  { Wrapper around a DOM element for test inspections }
  TWrapper = class
  private
    FEl: TJSHTMLElement;
    function GetElement: TJSHTMLElement;
  public
    constructor Create(AEl: TJSHTMLElement);
    function HTML: string; { Returns innerHTML of the component }
    function Text: string; { Returns textContent of the component }
    function Find(Selector: string): TJSHTMLElement; { Queries a sub-element }
    function FindAll(Selector: string): TJSArray; { Queries all matching sub-elements as an array }
    function Emitted(EventName: string): Boolean; { Checks if an event was emitted by the component }
    function Element: TJSHTMLElement; { Returns the underlying DOM element }
    procedure Click; { Simulates a mouse click }
    procedure SetValue(AVal: string); { Simulates an input change + event dispatch }
    procedure Trigger(EventName: string); { Dispatches a custom JS event }
  end;

  { Assertion proxy that calls Vitest 'expect' functions }
  TExpectProxy = class
  private
    FVal: JSValue;
  public
    constructor Create(AVal: JSValue);
    procedure ToBe(AExpected: JSValue);
    procedure ToEqual(AExpected: JSValue);
    procedure ToContain(AExpected: JSValue);
    procedure NotToContain(AExpected: JSValue);
    procedure ToHaveLength(ALen: Integer);
    procedure ToBeTruthy;
    procedure ToBeFalsy;
    procedure ToBeDefined;
    procedure ToBeUndefined;
    procedure ToBeNull;
  end;

{ Groups related tests together }
procedure Describe(const Msg: string; Fn: JSValue);

{ Defines a single test case }
procedure It(const Msg: string; Fn: JSValue);

{ Creates an assertion for a specific value }
function Expect(Val: JSValue): TExpectProxy;

{ Mounts a component by tag name into the test document body }
function Mount(const TagName: string; Props: TJSObject = nil): TWrapper;

implementation

{ TWrapper Implementation }
constructor TWrapper.Create(AEl: TJSHTMLElement);
begin
  FEl := AEl;
end;

function TWrapper.GetElement: TJSHTMLElement;
begin
  Result := FEl;
  asm
    while (Result && Result['__bv_replacement__']) {
      Result = Result['__bv_replacement__'];
    }
  end;
end;

function TWrapper.HTML: string;
var
  El: TJSHTMLElement;
begin
  El := GetElement;
  if El <> nil then
    Result := string(El.innerHTML)
  else
    Result := '';
end;

function TWrapper.Text: string;
var
  El: TJSHTMLElement;
begin
  El := GetElement;
  if El <> nil then
    Result := string(El.textContent)
  else
    Result := '';
end;

function TWrapper.Find(Selector: string): TJSHTMLElement;
var
  El: TJSHTMLElement;
begin
  El := GetElement;
  if El <> nil then
  begin
    asm
      if (El.matches && El.matches(Selector)) {
        return El;
      }
    end;
    Result := TJSHTMLElement(El.querySelector(Selector));
  end
  else
    Result := nil;
end;

function TWrapper.FindAll(Selector: string): TJSArray;
var
  El: TJSHTMLElement;
begin
  El := GetElement;
  Result := TJSArray.new;
  if El <> nil then
  begin
    asm
      Result = Array.from(El.querySelectorAll(Selector));
    end;
  end;
end;

function TWrapper.Emitted(EventName: string): Boolean;
var
  El: TJSHTMLElement;
begin
  El := GetElement;
  Result := False;
  asm
    let target = El;
    if (target) {
      let inst = target['__bv_instance_data__'];
      let emitted = (inst && inst['__emitted__']) || target['__emitted__'];
      if (emitted && emitted[EventName] && emitted[EventName].length > 0) {
        Result = true;
      }
    }
  end;
end;

function TWrapper.Element: TJSHTMLElement;
begin
  Result := GetElement;
end;

procedure TWrapper.Click;
var
  El: TJSHTMLElement;
begin
  El := GetElement;
  if El <> nil then
    El.click();
end;

procedure TWrapper.SetValue(AVal: string);
begin
  asm
    let el = this.GetElement();
    if (el) {
      el.value = AVal;
      el.dispatchEvent(new Event('input'));
    }
  end;
end;

procedure TWrapper.Trigger(EventName: string);
begin
  asm
    let el = this.GetElement();
    if (el) {
      el.dispatchEvent(new Event(EventName));
    }
  end;
end;

{ TExpectProxy Implementation }
constructor TExpectProxy.Create(AVal: JSValue);
begin
  FVal := AVal;
end;

procedure TExpectProxy.ToBe(AExpected: JSValue);
begin
  asm expect(this.FVal).toBe(AExpected); end;
end;

procedure TExpectProxy.ToEqual(AExpected: JSValue);
begin
  asm expect(this.FVal).toEqual(AExpected); end;
end;

procedure TExpectProxy.ToContain(AExpected: JSValue);
begin
  asm expect(this.FVal).toContain(AExpected); end;
end;

procedure TExpectProxy.NotToContain(AExpected: JSValue);
begin
  asm expect(this.FVal).not.toContain(AExpected); end;
end;

procedure TExpectProxy.ToHaveLength(ALen: Integer);
begin
  asm expect(this.FVal).toHaveLength(ALen); end;
end;

procedure TExpectProxy.ToBeTruthy;
begin
  asm expect(this.FVal).toBeTruthy(); end;
end;

procedure TExpectProxy.ToBeFalsy;
begin
  asm expect(this.FVal).toBeFalsy(); end;
end;

procedure TExpectProxy.ToBeDefined;
begin
  asm expect(this.FVal).toBeDefined(); end;
end;

procedure TExpectProxy.ToBeUndefined;
begin
  asm expect(this.FVal).toBeUndefined(); end;
end;

procedure TExpectProxy.ToBeNull;
begin
  asm expect(this.FVal).toBeNull(); end;
end;

{ Higher-level test functions calling global JS test context }

procedure Describe(const Msg: string; Fn: JSValue);
begin
  asm describe(Msg, Fn); end;
end;

procedure It(const Msg: string; Fn: JSValue);
begin
  asm it(Msg, Fn); end;
end;

function Expect(Val: JSValue): TExpectProxy;
begin
  Result := TExpectProxy.Create(Val);
end;

{ Mocks a component environment for testing }
function Mount(const TagName: string; Props: TJSObject = nil): TWrapper;
var
  El, TargetEl: TJSHTMLElement;
  Data: TBlaiseData;
begin
  El := TJSHTMLElement(document.createElement(TagName));
  asm
    if (Props) {
      Object.keys(Props).forEach(k => {
         El.setAttribute(':' + k, k);
      });
    }
  end;
  
  document.body.appendChild(El);
  
  { Initialize reactive data for the test context }
  Data := TBlaiseData.Create(Props);
  
  { Trigger compilation on the target element }
  Compile(El, Data, TJSObject.new);
  
  TargetEl := El;
  asm
    while (TargetEl && TargetEl['__bv_replacement__']) {
      TargetEl = TargetEl['__bv_replacement__'];
    }
  end;
  
  Result := TWrapper.Create(TargetEl);
end;

procedure ForceInclude;
var d: TBlaiseData;
begin
  { Ensures compiler doesn't strip important reactivity units during optimization }
  d := nil;
end;

initialization
  ForceInclude;
end.
