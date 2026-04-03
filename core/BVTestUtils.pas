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
  public
    constructor Create(AEl: TJSHTMLElement);
    function HTML: string; { Returns innerHTML of the component }
    function Text: string; { Returns textContent of the component }
    function Find(Selector: string): TJSHTMLElement; { Queries a sub-element }
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

function TWrapper.HTML: string;
begin
  Result := string(FEl.innerHTML);
end;

function TWrapper.Text: string;
begin
  Result := string(FEl.textContent);
end;

function TWrapper.Find(Selector: string): TJSHTMLElement;
begin
  Result := TJSHTMLElement(FEl.querySelector(Selector));
end;

procedure TWrapper.Click;
begin
  FEl.click();
end;

procedure TWrapper.SetValue(AVal: string);
begin
  asm
    this.FEl.value = AVal;
    this.FEl.dispatchEvent(new Event('input'));
  end;
end;

procedure TWrapper.Trigger(EventName: string);
begin
  asm
    this.FEl.dispatchEvent(new Event(EventName));
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
  El: TJSHTMLElement;
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
  
  Result := TWrapper.Create(El);
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
