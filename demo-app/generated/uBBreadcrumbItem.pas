unit uBBreadcrumbItem;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBBreadcrumbItem;

implementation

procedure Register_uBBreadcrumbItem;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.breadcrumb-item + .breadcrumb-item::before { content: ""; }   .breadcrumb-item.active { font-weight: 700; color: #1e293b; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <li class="breadcrumb-item" :class="{ active: active }" :aria-current="active ? ''page'' : null" style="padding-left: .5rem;">' +
    '    <span v-if="!active" style="margin-right: .5rem; color: #6c757d;">/</span>' +
    '    <a v-if="href && !active" :href="href" @click="handleClick" style="color: #0d6efd; text-decoration: none;">' +
    '      <slot></slot>' +
    '    </a>' +
    '    <span v-else style="color: #6c757d;">' +
    '      <slot></slot>' +
    '    </span>' +
    '  </li>';


  m := TJSObject.new;
  m['handleClick'] := procedure(_this: TJSObject; ev: TJSEvent)

    begin
       asm this.$emit('click', ev); end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-breadcrumb-item', comp);
end;

end.
