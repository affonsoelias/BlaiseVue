unit uBTabs;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBTabs;

implementation

procedure Register_uBTabs;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.nav-link {     display: block;     padding: 10px 20px;     color: #6c757d;     text-decoration: none;     border: 1px solid transparent;     border-bottom: 2px solid transparent;     margin-bottom: -2px;     font-weight: 500;     transition: all 0.2s;   }   .nav-link:hover { color: #0d6efd; background: #f8f9fa; }   .nav-link.active {     color: #0d6efd;     border-bottom: 2px solid #0d6efd;     background: #eef6ff;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <div class="tabs-container">' +
    '    <ul class="nav nav-tabs mb-3" style="display: flex; list-style: none; border-bottom: 2px solid #dee2e6; padding: 0; gap: 10px;">' +
    '       <li class="nav-item" b-for="tab in tabs" @click="selectTab(tab.id)">' +
    '         <a class="nav-link" :class="{ active: activeTabId == tab.id }" href="#">' +
    '            {{ tab.title }}' +
    '         </a>' +
    '       </li>' +
    '    </ul>' +
    '' +
    '    <div class="tab-content" style="padding: 15px; background: white; border-radius: 4px;">' +
    '       <slot></slot>' +
    '    </div>' +
    '  </div>';

  comp['data'] := function(): TJSObject
  var d: TJSObject;
  begin
    d := TJSObject.new;
    d['tabs'] := '';
    d['activeTabId'] := '';
    Result := d;
  end;

  m := TJSObject.new;
  m['selectTab'] := procedure(_this: TJSObject; id: string)

    begin
       asm 
         this.activeTabId = id; 
         this.$emit('change', id); 
       end;
    end;

  comp['methods'] := m;

  comp['created'] := procedure(_this: TJSObject)
    begin
       _this['tabs'] := TJSArray.new;
    end;

    ;
  comp['provide'] := function(_this: TJSObject): TJSObject
        procedure registerTab(tab: JSValue);
    begin
       asm 
          this.tabs.push(tab); 
          if (this.activeTabId === '') this.activeTabId = tab.id;
       end;
    end;
    procedure unregisterTab(id: string);
    begin
    end;
    function isActive(id: string): boolean;
    begin
       asm return this.activeTabId === id; end;
    end;

    begin
       Result := TJSObject.new;
    end;
;

  RegisterComponent('b-tabs', comp);
end;

end.
