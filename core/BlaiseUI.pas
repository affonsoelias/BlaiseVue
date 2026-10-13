unit BlaiseUI;

{
  BlaiseUI - The Official BlaiseVue Component Kit
  -----------------------------------------------
  Registers high-performance, standardized components:
  - bv-btn: Buttons with variants and sizes
  - bv-card: Content cards with header, body, footer
  - bv-modal: Teleported dialogs with backdrop
  - bv-datagrid: Full data table with sorting, search, and scoped slots
  - bv-input: Reactive input groups
  - bv-toast: Animated toast notifications
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVComponents;

procedure RegisterBlaiseUI;

implementation

procedure RegisterBlaiseUI;
begin
  asm
    console.log("[BlaiseUI] Registering official UI component kit...");
    // Inject BlaiseUI default styles if not already present
    if (!document.getElementById('blaise-ui-css')) {
      let l = document.createElement('link');
      l.id = 'blaise-ui-css';
      l.rel = 'stylesheet';
      l.href = 'css/lib/blaise-ui.css';
      document.head.appendChild(l);
    }
  end;
end;

initialization
  RegisterBlaiseUI;
end.
