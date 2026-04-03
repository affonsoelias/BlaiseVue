unit BVDevTools;

{
  BVDevTools - The Developer Experience Panel
  ---------------------------------------------
  Injects a debugging overlay into the application, allowing developers
  to monitor component registration, rendering, and state changes.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils;

{ Initializes the DevTools overlay and its logging subsystem }
procedure InitDevTools;

implementation

procedure InitDevTools;
begin
  asm
    console.log("%c BlaiseVue DevTools ", "background: #41b883; color: #fff; border-radius: 3px; padding: 2px 5px; font-weight: bold;", "v1.3.0-dev");
    
    // Inject the visual overlay styles
    let s = document.createElement('style');
    s.innerHTML = `
      .bv-devtools-panel { position: fixed; bottom: 10px; right: 10px; z-index: 9999; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #2c3e50; color: #ecf0f1; border-radius: 8px; padding: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); width: 220px; transition: opacity 0.3s; opacity: 0.8; }
      .bv-devtools-panel:hover { opacity: 1; }
      .bv-dt-header { font-size: 11px; font-weight: bold; border-bottom: 1px solid #34495e; padding-bottom: 5px; margin-bottom: 5px; display: flex; justify-content: space-between; }
      .bv-dt-tag { background: #41b883; color: #fff; padding: 1px 4px; border-radius: 3px; font-size: 9px; }
      .bv-dt-stat { font-size: 10px; margin-top: 3px; display: flex; justify-content: space-between; }
      .bv-dt-live-blob { width: 8px; height: 8px; background: #41b883; border-radius: 50%; display: inline-block; animation: bvdt-pulse 1s infinite; }
      @keyframes bvdt-pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.5); opacity: 0.5; } 100% { transform: scale(1); opacity: 1; } }
    `;
    document.head.appendChild(s);

    // Create the Panel UI
    let p = document.createElement('div');
    p.id = 'bv-devtools';
    p.className = 'bv-devtools-panel';
    p.innerHTML = `
       <div class="bv-dt-header">
         <span>BLAISEVUE 🛡️</span>
         <span class="bv-dt-tag">DEV MODE</span>
       </div>
       <div class="bv-dt-stat">
         <span>Status:</span>
         <span>Active <i class="bv-dt-live-blob"></i></span>
       </div>
       <div class="bv-dt-stat" id="bv-com-count">
         <span>Components:</span>
         <span>0</span>
       </div>
    `;
    document.body.appendChild(p);

    // Dynamic stats updater
    setInterval(function(){
       let count = Object.keys(window.__BV_CORE__.components || {}).length;
       let el = document.getElementById('bv-com-count');
       if (el) el.querySelector('span:last-child').innerText = count;
    }, 1000);
  end;
end;

initialization
  { Automatical initialization if the module is included in the project }
  InitDevTools;
end.
