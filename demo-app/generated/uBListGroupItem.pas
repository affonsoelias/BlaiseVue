unit uBListGroupItem;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBListGroupItem;

implementation

procedure Register_uBListGroupItem;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.list-group-item:last-child { border-bottom: none; }   .list-group-item.active { background-color: #0d6efd; color: white; border-color: #0d6efd; }   .list-group-item.active:hover { background-color: #0b5ed7; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <li class="list-group-item d-flex justify-content-between align-items-center" ' +
    '      :class="{ active: active }"' +
    '      @click="handleClick"' +
    '      style="padding: 12px 20px; border-bottom: 1px dashed #eee; transition: background 0.2s; cursor: pointer;">' +
    '    <slot></slot>' +
    '    <b-badge v-if="badge" :variant="badgeVariant">{{ badge }}</b-badge>' +
    '  </li>';


  m := TJSObject.new;
  m['handleClick'] := procedure(_this: TJSObject)

    begin
       asm this.$emit('click'); end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-list-group-item', comp);
end;

end.
