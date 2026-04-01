unit uBAccordion;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBAccordion;

implementation

procedure Register_uBAccordion;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.accordion-button.collapsed { color: #212529; background: #fff; }   .accordion-button:not(.collapsed) { background-color: #e7f1ff; color: #0c63e4; }   .accordion-button::after {     content: "▼";     float: right;     transition: transform 0.2s;   }   .accordion-button:not(.collapsed)::after { transform: rotate(180deg); }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="accordion" id="accordionExample">' +
    '    <div class="accordion-item" b-for="item in items" style="margin-bottom: 5px; border: 1px solid #dee2e6; border-radius: 4px; overflow: hidden;">' +
    '      <h2 class="accordion-header" style="margin: 0;">' +
    '        <button class="accordion-button" type="button" @click="toggle(item.id)" ' +
    '                :class="{ collapsed: activeId != item.id }"' +
    '                style="width: 100%; text-align: left; padding: 12px 20px; border: none; background: #f8f9fa; cursor: pointer; font-weight: 500; font-size: 1rem;">' +
    '          {{ item.title }}' +
    '        </button>' +
    '      </h2>' +
    '      <div class="accordion-collapse collapse" b-show="activeId == item.id" style="padding: 20px; background: white; border-top: 1px solid #dee2e6;">' +
    '        <div class="accordion-body">{{ item.content }}</div>' +
    '      </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['activeId'] := '';
    Result := d;
  end;

  m := TJSObject.new;
  m['toggle'] := procedure(_this: TJSObject; id: string)

    begin
       if _this['activeId'] = id then _this['activeId'] := '' else _this['activeId'] := id;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       _this['activeId'] := string(_this['initialActiveId']);
    end;

    ;

  RegisterComponent('b-accordion', comp);
end;

end.
