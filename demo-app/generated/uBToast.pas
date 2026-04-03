unit uBToast;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBToast;

implementation

procedure Register_uBToast;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.toast-info { border-left-color: #0dcaf0; }   .toast-success { border-left-color: #198754; }   .toast-danger { border-left-color: #dc3545; }   .toast-warning { border-left-color: #ffc107; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1060; right: 20px; bottom: 20px;">' +
    '    <div class="toast show" v-if="visible" :class="''toast-'' + variant" ' +
    '         style="min-width: 250px; background: white; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.15); border-left: 5px solid transparent;">' +
    '       <div class="toast-header" style="padding: 10px 15px; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center;">' +
    '          <strong class="me-auto">{{ title }}</strong>' +
    '          <small class="text-muted">{{ time }}</small>' +
    '          <button type="button" class="btn-close" @click="hide" style="border: none; background: none; cursor: pointer; font-weight: bold;">&times;</button>' +
    '       </div>' +
    '       <div class="toast-body" style="padding: 15px;">' +
    '          <slot></slot>' +
    '       </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['visible'] := false;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('title');
  TJSArray(comp['props']).push('time');
  TJSArray(comp['props']).push('variant');
  TJSArray(comp['props']).push('duration');

  m := TJSObject.new;
  m['show'] := procedure(_this: TJSObject)

    begin
       _this['visible'] := true;
       if integer(_this['duration']) > 0 then
       begin
         asm setTimeout(() => { this.visible = false; }, parseInt(this.duration)); end;
       end;
    end;
    
  m['hide'] := procedure(_this: TJSObject)

    begin
       TJSObject(_this)['visible'] := false;
    end;

  comp['methods'] := m;


  RegisterComponent('b-toast', comp);
end;

end.
