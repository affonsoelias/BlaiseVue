unit uUserProfile;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uUserProfile;

implementation

procedure Register_uUserProfile;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := 'table { width: 100%; border-collapse: collapse; }   th, td { padding: 12px; border: 1px solid #efefef; text-align: left; }   th { background: #f9f9f9; width: 30%; }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div>' +
    '    <div class="section">' +
    '      <h1 class="section-title">User Profile</h1>' +
    '      <p>This page demonstrates <strong>Route Params</strong> and <strong>Query Strings</strong>.</p>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Route Data</h2>' +
    '      <table>' +
    '        <tr><th>Information</th><th>Value</th></tr>' +
    '        <tr><td>Param <code>:id</code></td><td><span class="badge badge-blue">{{ id }}</span></td></tr>' +
    '        <tr><td>Query <code>?tab</code></td><td><span class="badge badge-orange">{{ tab }}</span></td></tr>' +
    '        <tr><td>Query <code>?tema</code></td><td><span class="badge badge-gray">{{ tema }}</span></td></tr>' +
    '        <tr><td>Level (Computed)</td><td><span class="badge" :class="userLevel == ''Premium'' ? ''badge-orange'' : ''badge-gray''">{{ userLevel }}</span></td></tr>' +
    '      </table>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Edit Name (b-model)</h2>' +
    '      <input type="text" b-model="nomeUsuario">' +
    '      <p>Current Name: <strong>{{ nomeUsuario }}</strong></p>' +
    '    </div>' +
    '' +
    '    <div class="section">' +
    '      <h2 class="section-title">Test Other Routes</h2>' +
    '      <a href="#/user/1" class="btn-outline" style="text-decoration:none; display:inline-block;">User 1</a>' +
    '      <a href="#/user/100?tab=posts" class="btn-outline" style="text-decoration:none; display:inline-block;">User 100 + Posts</a>' +
    '      <a href="#/user/7?tab=config&tema=dark" class="btn-outline" style="text-decoration:none; display:inline-block;">User 7 + Multi Query</a>' +
    '      <a href="#/" class="btn-danger" style="text-decoration:none; display:inline-block;">Back Home</a>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['id'] := '?';
    d['tab'] := '(none)';
    d['tema'] := '(none)';
    d['nomeUsuario'] := 'Standard User';
    Result := d;
  end;


  m := TJSObject.new;
  comp['methods'] := m;

  comp['computed'] := TJSObject.new;
  TJSObject(comp['computed'])['userLevel'] := function(_this: TJSObject): JSValue

    begin
      if Integer(_this['id']) > 50 then Result := 'Premium'
      else Result := 'Basic';
    end;

;

  RegisterComponent('user-profile-page', comp);
end;

end.
