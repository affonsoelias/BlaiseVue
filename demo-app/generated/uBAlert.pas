unit uBAlert;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBAlert;

implementation

procedure Register_uBAlert;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="alert" ' +
    '       :class="[''alert-'' + variant, dismissible ? ''alert-dismissible fade show'' : '''']" ' +
    '       role="alert"' +
    '       b-if="visible"' +
    '       style="padding: 1rem 1.25rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: 0.375rem; position: relative;">' +
    '    <slot></slot>' +
    '    <button type="button" ' +
    '            class="btn-close" ' +
    '            b-if="dismissible" ' +
    '            @click="close" ' +
    '            aria-label="Close"' +
    '            style="position: absolute; top: 0; right: 0; z-index: 2; padding: 1.25rem 1rem; background: transparent; border: 0; cursor: pointer; float: right; font-size: 1.5rem; font-weight: 700; line-height: 1; color: #000; text-shadow: 0 1px 0 #fff; opacity: .5;">' +
    '      ×' +
    '    </button>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['visible'] := true;
    Result := d;
  end;

  comp['props'] := TJSArray.new;
  TJSArray(comp['props']).push('variant');
  TJSArray(comp['props']).push('dismissible');
  TJSArray(comp['props']).push('show');

  m := TJSObject.new;
  m['close'] := procedure(_this: TJSObject)

    begin
       _this['visible'] := false;
       asm this.$emit('close'); end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       _this['visible'] := boolean(_this['show']);
    end;

    ;

  RegisterComponent('b-alert', comp);
end;

end.
