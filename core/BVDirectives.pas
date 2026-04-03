unit BVDirectives;

{
  BVDirectives - Simplified Directive Bindings
  -------------------------------------------
  Provides helper procedures to bind specific DOM qualities 
  (attributes, events, visibility) to reactive data sources.
}

{$mode objfpc}

interface

uses JS, Web, BVReactivity, SysUtils, BVDevTools;

{ Binds a form input value to a reactive key (two-way binding) }
procedure BindModel(Input: TJSHTMLInputElement; Data: TBlaiseData);

{ Attaches DOM event listeners based on @event or v-on: directives }
procedure BindEvents(Element: TJSHTMLElement; Data: TBlaiseData; Methods: TJSObject);

{ Synchronizes DOM attributes with reactive expressions (v-bind:attr or :attr) }
procedure BindAttributes(Element: TJSHTMLElement; Data: TBlaiseData);

{ Controls display:none based on a reactive expression (v-show or b-show) }
procedure BindShow(Element: TJSHTMLElement; Data: TBlaiseData);

{ Dynamically updates the class attribute based on a reactive expression or object }
procedure BindClass(Element: TJSHTMLElement; Data: TBlaiseData);

implementation

{ Implementation of two-way Model binding }
procedure BindModel(Input: TJSHTMLInputElement; Data: TBlaiseData);
var
  key: string;
begin
  key := Input.getAttribute('b-model');
  if key = '' then key := Input.getAttribute('v-model');
  if key = '' then Exit;

  { Effect: Sync Proxy -> Input value }
  Effect(
    procedure()
    begin
      Input.value := string(Data.GetValue(key));
    end
  );

  { Event: Sync Input value -> Proxy }
  Input.addEventListener('input',
    TJSRawEventHandler(
      procedure(Event: TJSEvent)
      begin
        Data.SetValue(key, Input.value);
      end
    )
  );
end;

{ Implementation of Event binding }
procedure BindEvents(Element: TJSHTMLElement; Data: TBlaiseData; Methods: TJSObject);
var
  i: Integer;
  attr: TJSNode;
  attrName, attrValue, eventName: string;
  
  procedure DoBind(const eName, mName: string);
  begin
    Element.addEventListener(eName,
      TJSRawEventHandler(
        procedure(Event: TJSEvent)
        var
          expr: string;
        begin
          expr := Trim(mName);
          { Smart matching: check if expression is just a method name or a complex code snippet }
          asm
            if (!expr) return;
            // Native method name check: execute with Proxy context
            if (/^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(expr)) {
              let fn = Data.FData[expr];
              if (typeof fn === 'function') {
                fn.call(Data.FData, Event);
                return;
              }
            }
          end;
          { Fallback: Evaluate as expression }
          Data.Evaluate(expr, Event);
        end
      )
    );
  end;

begin
  if (Element = nil) or (isUndefined(Element.attributes)) then Exit;
  
  for i := 0 to Integer(Element.attributes.length) - 1 do
  begin
    attr := Element.attributes.item(i);
    attrName := String(TJSAttr(attr).name);
    attrValue := String(TJSAttr(attr).value);

    eventName := '';
    if Pos('@', attrName) = 1 then
      eventName := Copy(attrName, 2, 255)
    else if Pos('v-on:', attrName) = 1 then
      eventName := Copy(attrName, 6, 255);

    if eventName <> '' then
      DoBind(eventName, attrValue);
  end;
end;

{ Implementation of Attribute binding }
procedure BindAttributes(Element: TJSHTMLElement; Data: TBlaiseData);
var
  i: Integer;
  attr: TJSNode;
  attrName, attrValue, targetProp: string;
  
  procedure DoBindAttr(const pName, expr: string);
  begin
    Effect(
      procedure()
      var
        val: JSValue;
      begin
        val := Data.Evaluate(expr);
        { Handle conditional removal of attributes (e.g. :disabled="false") }
        if isUndefined(val) or (val = False) or (val = Null) then
          Element.removeAttribute(pName)
        else
        begin
          if (val = True) then
            Element.setAttribute(pName, '')
          else
            Element.setAttribute(pName, String(val));
        end;
      end
    );
  end;

begin
  if (Element = nil) or (isUndefined(Element.attributes)) then Exit;

  for i := 0 to Integer(Element.attributes.length) - 1 do
  begin
    attr := Element.attributes.item(i);
    attrName := String(TJSAttr(attr).name);
    attrValue := String(TJSAttr(attr).value);
    targetProp := '';

    if (attrName = 'v-bind:class') or (attrName = ':class') then Continue;

    if Pos('v-bind:', attrName) = 1 then
      targetProp := Copy(attrName, 8, 255)
    else if Pos(':', attrName) = 1 then
      targetProp := Copy(attrName, 2, 255);

    if targetProp <> '' then
      DoBindAttr(targetProp, attrValue);
  end;
end;

{ Implementation of Visibility binding (v-show) }
procedure BindShow(Element: TJSHTMLElement; Data: TBlaiseData);
var
  attr: JSValue;
  key: string;
begin
  attr := Element.getAttribute('v-show');
  if isUndefined(attr) or (attr = null) then Exit;
  key := String(attr);
  if key = '' then Exit;

  Effect(
    procedure()
    begin
      if Boolean(Data.Evaluate(key)) then
        Element.style.setProperty('display', '')
      else
        Element.style.setProperty('display', 'none');
    end
  );
end;

{ Implementation of Dynamic Class binding }
procedure BindClass(Element: TJSHTMLElement; Data: TBlaiseData);
var
  attr: JSValue;
  key, baseClass: string;
begin
  attr := Element.getAttribute('v-bind:class');
  if isUndefined(attr) or (attr = null) then attr := Element.getAttribute(':class');
  if isUndefined(attr) or (attr = null) then Exit;
  key := String(attr);
  if key = '' then Exit;

  baseClass := Element.className;

  Effect(
    procedure()
    var
      val: JSValue;
      obj: TJSObject;
      kArr: TJSStringDynArray;
      idx: Integer;
      finalClass: string;
    begin
      val := Data.Evaluate(key);
      finalClass := baseClass;
      
      { Supports Object-based class binding ({ 'active': isActive }) }
      if (JSTypeOf(val) = 'object') and (val <> null) then
      begin
        obj := TJSObject(val);
        kArr := TJSObject.keys(obj);
        for idx := 0 to Length(kArr)-1 do
        begin
          if Boolean(obj[kArr[idx]]) then
            finalClass := finalClass + ' ' + kArr[idx];
        end;
      end
      else if not isUndefined(val) and (val <> null) then
        finalClass := finalClass + ' ' + String(val);

      Element.className := Trim(finalClass);
    end
  );
end;

end.