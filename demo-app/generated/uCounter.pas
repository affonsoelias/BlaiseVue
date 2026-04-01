unit uCounter;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uCounter;

implementation

procedure Register_uCounter;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.counter-box { display: inline-block; border: 2px solid #42b883; border-radius: 12px; padding: 16px; margin: 8px; text-align: center; background: #f8fffe; }   .counter-label { font-weight: bold; color: #2c3e50; display: block; margin-bottom: 8px; }   .counter-controls { display: flex; align-items: center; gap: 12px; justify-content: center; }   .counter-value { font-size: 28px; font-weight: bold; color: #42b883; min-width: 40px; }   .counter-controls button { width: 36px; height: 36px; border-radius: 50%; border: 2px solid #42b883; background: white; color: #42b883; font-size: 18px; cursor: pointer; font-weight: bold; }   .counter-controls button:hover { background: #42b883; color: white; }   .counter-reset { margin-top: 8px; padding: 4px 12px; border: 1px solid #e74c3c; background: white; color: #e74c3c; border-radius: 4px; cursor: pointer; font-size: 12px; }   .counter-reset:hover { background: #e74c3c; color: white; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="counter-box">' +
    '    <span class="counter-label">{{ label }}</span>' +
    '    <div class="counter-controls">' +
    '      <button @click="menos">-</button>' +
    '      <span class="counter-value">{{ valor }}</span>' +
    '      <button @click="mais">+</button>' +
    '    </div>' +
    '    <button class="counter-reset" @click="zerar">Zerar</button>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['label'] := 'Contador';
    d['valor'] := 0;
    Result := d;
  end;

  m := TJSObject.new;
  m['mais'] := procedure(_this: TJSObject)

    begin
      _this['valor'] := Integer(_this['valor']) + 1;
    end;
    
  m['menos'] := procedure(_this: TJSObject)

    begin
      _this['valor'] := Integer(_this['valor']) - 1;
    end;
    
  m['zerar'] := procedure(_this: TJSObject)

    begin
      _this['valor'] := 0;
    end;

  comp['methods'] := m;


  RegisterComponent('counter', comp);
end;

end.
