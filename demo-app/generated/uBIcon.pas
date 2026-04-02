unit uBIcon;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBIcon;

implementation

procedure Register_uBIcon;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.bi-icon-wrapper { vertical-align: middle; line-height: 1; display: inline-flex; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <span class="bi-icon-wrapper" :style="''display: inline-flex; width: '' + size + ''px; height: '' + size + ''px;''" v-html="svgContent"></span>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['name'] := 'bootstrap-fill';
    d['size'] := '16';
    Result := d;
  end;

  m := TJSObject.new;
  comp['methods'] := m;

  comp['computed'] := TJSObject.new;
  TJSObject(comp['computed'])['svgContent'] := function(_this: TJSObject): JSValue

    var
      path, n, s: string;
    begin
      path := '';
      n := string(_this['name']);
      s := string(_this['size']);
      if n = 'bootstrap-fill' then path := '<path d="M6.35 10.5c0 .73.73 1.23 1.58 1.23.83 0 1.55-.53 1.55-1.23 0-.64-.52-1.13-1.55-1.13-.85 0-1.58.49-1.58 1.13zm-.12-3.15c0 .63.74 1.12 1.6 1.12.83 0 1.53-.49 1.53-1.12 0-.67-.7-1.2-1.53-1.2-.86 0-1.6.53-1.6 1.2z"/><path d="M10.1 0H5.9C5 0 4 .5 3.3 1.3 2.5 2.1 2 3 2 3.9v8.2c0 .9.5 1.8 1.3 2.6.8.8 1.7 1.3 2.6 1.3h4.2c.9 0 1.8-.5 2.6-1.3.8-.8 1.3-1.7 1.3-2.6V3.9c0-.9-.5-1.8-1.3-2.6C12 .5 11.1 0 10.1 0zM7.9 12.6c-1.6 0-2.9-1.1-2.9-2.5 0-1 .6-1.8 1.5-2.2-.7-.4-1.2-1.1-1.2-2 0-1.3 1.1-2.4 2.6-2.4 1.5 0 2.6 1.1 2.6 2.4 0 .9-.5 1.6-1.2 2 1 .4 1.5 1.2 1.5 2.2 0 1.4-1.3 2.5-2.9 2.5z"/>'
      else if n = 'check-circle' then path := '<path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>'
      else if n = 'warning' then path := '<path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>'
      else if n = 'gear-fill' then path := '<path d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.168-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872l-.1-.34zM8 10.93a2.929 2.929 0 1 1 0-5.86 2.929 2.929 0 0 1 0 5.858z"/>'
      else if n = 'heart-fill' then path := '<path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/>'
      else if n = 'weather' then path := '<path d="M12.5 13a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zM12.5 8a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0v-1a.5.5 0 0 1 .5-.5zM12.5 16a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0v-1a.5.5 0 0 1 .5-.5zM16 12.5a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1 0-1h1a.5.5 0 0 1 .5.5zM9 12.5a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1 0-1h1a.5.5 0 0 1 .5.5z"/><path d="M14.975 10.025a.5.5 0 0 1 0 .707l-.707.708a.5.5 0 0 1-.708-.708l.707-.707a.5.5 0 0 1 .707 0zM10.732 14.268a.5.5 0 0 1 0 .707l-.707.708a.5.5 0 0 1-.708-.708l.707-.707a.5.5 0 0 1 .707 0z"/>'
      else if n = 'code-slash' then path := '<path d="M10.478 1.647a.5.5 0 1 0-.956-.294l-4 13a.5.5 0 0 0 .956.294l4-13zM4.854 4.146a.5.5 0 0 1 0 .708L1.707 8l3.147 3.146a.5.5 0 0 1-.708.708l-3.5-3.5a.5.5 0 0 1 0-.708l3.5-3.5a.5.5 0 0 1 .708 0zm6.292 0a.5.5 0 0 0 0 .708L14.293 8l-3.147 3.146a.5.5 0 0 0 .708.708l3.5-3.5a.5.5 0 0 0 0-.708l-3.5-3.5a.5.5 0 0 0-.708 0z"/>'
      else if n = 'cpu' then path := '<path d="M5 0a.5.5 0 0 1 .5.5V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 .5-.5h.5V2h1.5a.5.5 0 0 1 .5.5v11a.5.5 0 0 1-.5.5H14v1.5a.5.5 0 0 1-.5.5h-1V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-.5.5h-.5V14H2.5a.5.5 0 0 1-.5-.5V2h-1.5a.5.5 0 0 1-.5-.5h.5V1h1.5a.5.5 0 0 1 .5-.5V0zm1 10h4V6H6v4z"/>';
      Result := '<svg xmlns="http://www.w3.org/2000/svg" width="' + s + '" height="' + s + '" fill="currentColor" viewBox="0 0 16 16">' + path + '</svg>';
    end;

;

  RegisterComponent('b-icon', comp);
end;

end.
