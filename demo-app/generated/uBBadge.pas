unit uBBadge;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBBadge;

implementation

procedure Register_uBBadge;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: white; display: inline-block; vertical-align: middle; }   .badge-primary { background: #0d6efd; }   .badge-success { background: #198754; }   .badge-danger { background: #dc3545; }   .badge-warning { background: #ffc107; color: #000; }   .badge-info { background: #0dcaf0; color: #000; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <span class="badge" :class="''badge-'' + (variant || type || ''primary'')">' +
    '    <slot></slot>' +
    '  </span>';


  m := TJSObject.new;
  comp['methods'] := m;


  RegisterComponent('b-badge', comp);
end;

end.
