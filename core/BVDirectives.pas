unit BVDirectives;

{$mode objfpc}

interface

uses JS, Web, BVReactivity, SysUtils, BVDevTools;

procedure BindModel(Input: TJSHTMLInputElement; Data: TBlaiseData);
procedure BindEvents(Element: TJSHTMLElement; Data: TBlaiseData; Methods: TJSObject);
procedure BindAttributes(Element: TJSHTMLElement; Data: TBlaiseData);
procedure BindShow(Element: TJSHTMLElement; Data: TBlaiseData);
procedure BindClass(Element: TJSHTMLElement; Data: TBlaiseData);

implementation

procedure BindModel(Input: TJSHTMLInputElement; Data: TBlaiseData);
var
  key: string;
begin
  key := Input.getAttribute('b-model');
  if key = '' then key := Input.getAttribute('v-model');
  if key = '' then Exit;

  Effect(
    procedure()
    begin
      Input.value := string(Data.GetValue(key));
    end
  );

  Input.addEventListener('input',
    TJSRawEventHandler(
      procedure(Event: TJSEvent)
      begin
        Data.SetValue(key, Input.value);
      end
    )
  );
end;

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
          // Suporte a métodos simples (ex: "doSomething") e expressões (ex: "clicks++" ou "del(id)")
          asm
            if (!expr) return;
            // Se for apenas o nome do método, chama injetando o evento como argumento
            if (/^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(expr)) {
              let fn = Data.FData[expr];
              if (typeof fn === 'function') {
                fn.call(Data.FData, Event); // Contexto é o Proxy
                return;
              }
            }
          end;
          // Caso contrário, avalia como expressão completa (ex: removeTask(index))
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

// ... Rest of BindShow and BindClass as before ...

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