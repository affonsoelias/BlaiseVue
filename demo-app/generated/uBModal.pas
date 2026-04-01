unit uBModal;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBModal;

implementation

procedure Register_uBModal;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '@keyframes modalBounce {     0% { transform: scale(0.85); opacity: 0; }     100% { transform: scale(1); opacity: 1; }   }   .modal-dialog { transform: translateZ(0); }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="modal-backdrop fade show" v-if="visible" @click="close"' +
    '       style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 1050; display: flex; align-items: center; justify-content: center;">' +
    '    ' +
    '    <div class="modal-dialog" @click.stop=""' +
    '         style="background: white; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.25); min-width: 400px; max-width: 800px; overflow: hidden; animation: modalBounce 0.3s ease-out;">' +
    '      ' +
    '      <div class="modal-header d-flex justify-content-between align-items-center" ' +
    '           style="padding: 15px 25px; border-bottom: 1px solid #e9ecef; background: #f8f9fa;">' +
    '        <h5 class="modal-title" style="margin: 0; font-weight: 700;">{{ title }}</h5>' +
    '        <button type="button" class="btn-close" @click="close" style="border: none; background: none; cursor: pointer; font-size: 1.5rem;">&times;</button>' +
    '      </div>' +
    '' +
    '      <div class="modal-body" style="padding: 25px; min-height: 100px;">' +
    '        <slot></slot>' +
    '      </div>' +
    '' +
    '      <div class="modal-footer" style="padding: 15px 25px; border-top: 1px solid #e9ecef; display: flex; justify-content: flex-end; gap: 10px;">' +
    '        <button v-if="cancelLabel" type="button" class="btn btn-secondary" @click="close">{{ cancelLabel }}</button>' +
    '        <button v-if="okLabel" type="button" class="btn btn-primary" @click="onOk">{{ okLabel }}</button>' +
    '      </div>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['visible'] := false;
    Result := d;
  end;

  m := TJSObject.new;
  m['show'] := procedure(_this: TJSObject)

    begin
       asm this.visible = true; end;
    end;
    
  m['close'] := procedure(_this: TJSObject)

    begin
       asm 
          this.visible = false;
          this.$emit('hide');
       end;
    end;
    
  m['onOk'] := procedure(_this: TJSObject)

    begin
       asm 
          this.$emit('ok');
          this.close();
       end;
    end;

  comp['methods'] := m;


  RegisterComponent('b-modal', comp);
end;

end.
