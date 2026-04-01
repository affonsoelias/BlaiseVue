unit uBPagination;

{$mode objfpc}

interface

uses JS, Web, BVComponents, BVReactivity, BVStore, SysUtils;

procedure Register_uBPagination;

implementation

procedure Register_uBPagination;
var
  comp: TJSObject;
  m: TJSObject;
  _styleEl: TJSHTMLElement;
begin
  _styleEl := TJSHTMLElement(document.createElement('style'));
  _styleEl.textContent := '.page-link {     padding: 8px 16px;     border: 1px solid #dee2e6;     background: white;     color: #0d6efd;     cursor: pointer;     border-radius: 4px;     transition: all 0.2s;   }   .page-item.active .page-link {     background: #0d6efd;     color: white;     border-color: #0d6efd;   }   .page-item.disabled .page-link {     color: #6c757d;     pointer-events: none;     background: #f8f9fa;   }   .page-link:hover:not(.disabled) {     background: #e9ecef;   }';
  document.head.appendChild(_styleEl);
  comp := TJSObject.new;
  comp['template'] :=
    '  <nav aria-label="Page navigation" style="margin: 20px 0;">' +
    '    <ul class="pagination" style="display: flex; list-style: none; padding: 0; gap: 5px;">' +
    '       <li class="page-item" :class="{ disabled: value <= 1 }">' +
    '         <button class="page-link" @click="changePage(value - 1)">&laquo;</button>' +
    '       </li>' +
    '       ' +
    '       <li class="page-item" b-for="p in totalPages" :class="{ active: p == value }">' +
    '         <button class="page-link" @click="changePage(p)">{{ p }}</button>' +
    '       </li>' +
    '' +
    '       <li class="page-item" :class="{ disabled: value >= totalPages }">' +
    '         <button class="page-link" @click="changePage(value + 1)">&raquo;</button>' +
    '       </li>' +
    '    </ul>' +
    '  </nav>';


  m := TJSObject.new;
  m['changePage'] := procedure(_this: TJSObject; p: integer)

    begin
       if (p >= 1) and (p <= integer(_this['total'])) then
       begin
         asm this.$emit('input', p); this.$emit('change', p); end;
       end;
    end;

  comp['methods'] := m;

  comp['computed'] := TJSObject.new;

  RegisterComponent('b-pagination', comp);
end;

end.
