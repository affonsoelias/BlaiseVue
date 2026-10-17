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
    console.log("%c BlaiseVue DevTools 3.0 ", "background: #41b883; color: #fff; border-radius: 3px; padding: 2px 5px; font-weight: bold;", "v3.0-enterprise");

    // Initialize global DevTools Hook for browser extensions and external inspectors
    if (!window.__BV_DEVTOOLS_HOOK__) {
      window.__BV_DEVTOOLS_HOOK__ = {
        version: "3.0.0",
        listeners: {},
        events: [],
        snapshots: [],
        on: function(event, fn) {
          if (!this.listeners[event]) this.listeners[event] = [];
          this.listeners[event].push(fn);
        },
        emit: function(event, data) {
          let entry = { time: new Date().toLocaleTimeString(), type: event, data: data };
          this.events.push(entry);
          if (this.events.length > 200) this.events.shift();
          if (this.listeners[event]) {
            this.listeners[event].forEach(function(fn) { try { fn(entry); } catch(e){} });
          }
          if (this.listeners['*']) {
            this.listeners['*'].forEach(function(fn) { try { fn(entry); } catch(e){} });
          }
        },
        getComponentTree: function() {
          let roots = [];
          let els = document.querySelectorAll('[data-bv-component]');
          els.forEach(function(el) {
            roots.push({
              tag: el.getAttribute('data-bv-component'),
              state: el['__bv_instance_data__'] ? Object.assign({}, el['__bv_instance_data__']) : {}
            });
          });
          return roots;
        },
        recordSnapshot: function(label) {
          let snap = { label: label || ('Snapshot ' + (this.snapshots.length + 1)), time: Date.now(), tree: this.getComponentTree() };
          this.snapshots.push(snap);
          return snap;
        }
      };
    }
    
    // Inject the visual overlay styles
    let s = document.createElement('style');
    s.innerHTML = `
      .bv-devtools-panel {
        position: fixed;
        bottom: 45px;
        right: 20px;
        z-index: 9999;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background: #1e293b;
        color: #f8fafc;
        border-radius: 10px;
        padding: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.4);
        width: 260px;
        font-size: 12px;
        border: 1px solid #334155;
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        user-select: none;
      }
      @media (max-width: 768px) {
        .bv-devtools-panel {
          bottom: 74px;
          right: 12px;
          max-width: calc(100vw - 24px);
          width: 250px;
        }
      }
      .bv-devtools-panel.bv-dt-collapsed {
        width: auto !important;
        padding: 6px 12px !important;
        border-radius: 20px !important;
        cursor: pointer;
        background: rgba(30, 41, 59, 0.95);
        backdrop-filter: blur(8px);
        box-shadow: 0 4px 15px rgba(0,0,0,0.3);
      }
      .bv-devtools-panel.bv-dt-collapsed .bv-dt-body {
        display: none !important;
      }
      .bv-devtools-panel.bv-dt-collapsed .bv-dt-header {
        border-bottom: none !important;
        padding-bottom: 0 !important;
        margin-bottom: 0 !important;
        gap: 8px;
      }
      .bv-devtools-panel.bv-dt-collapsed .bv-dt-collapse-btn {
        display: none;
      }
      .bv-dt-header {
        font-weight: bold;
        border-bottom: 1px solid #334155;
        padding-bottom: 8px;
        margin-bottom: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
      }
      .bv-dt-header-left {
        display: flex;
        align-items: center;
        gap: 6px;
      }
      .bv-dt-header-actions {
        display: flex;
        align-items: center;
        gap: 6px;
      }
      .bv-dt-tag { background: #10b981; color: #fff; padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 600; }
      .bv-dt-collapse-btn {
        background: transparent;
        border: none;
        color: #94a3b8;
        cursor: pointer;
        font-size: 13px;
        padding: 0 4px;
        line-height: 1;
        border-radius: 3px;
      }
      .bv-dt-collapse-btn:hover { color: #fff; background: rgba(255,255,255,0.1); }
      .bv-dt-stat { margin-top: 5px; display: flex; justify-content: space-between; color: #cbd5e1; }
      .bv-dt-live-blob { width: 8px; height: 8px; background: #10b981; border-radius: 50%; display: inline-block; animation: bvdt-pulse 1s infinite; vertical-align: middle; }
      .bv-dt-timeline { max-height: 80px; overflow-y: auto; margin-top: 8px; border-top: 1px solid #334155; padding-top: 5px; font-family: monospace; font-size: 10px; color: #94a3b8; }
      @keyframes bvdt-pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.4); opacity: 0.5; } 100% { transform: scale(1); opacity: 1; } }
    `;
    document.head.appendChild(s);

    // Create the Panel UI
    let p = document.createElement('div');
    p.id = 'bv-devtools';
    p.className = 'bv-devtools-panel';
    p.innerHTML = `
       <div class="bv-dt-header" id="bv-dt-toggle" title="Clique para minimizar ou expandir o DevTools">
         <div class="bv-dt-header-left">
           <span>BlaiseVue 🛡️</span>
           <i class="bv-dt-live-blob"></i>
         </div>
         <div class="bv-dt-header-actions">
           <span class="bv-dt-tag">v3.0</span>
           <button class="bv-dt-collapse-btn" id="bv-dt-btn" title="Minimizar">—</button>
         </div>
       </div>
       <div class="bv-dt-body" id="bv-dt-body">
         <div class="bv-dt-stat">
           <span>Reactivity:</span>
           <span>Active <i class="bv-dt-live-blob"></i></span>
         </div>
         <div class="bv-dt-stat" id="bv-com-count">
           <span>Components:</span>
           <span>0</span>
         </div>
         <div class="bv-dt-stat" id="bv-hoisted-count">
           <span>Static Hoisted:</span>
           <span>0</span>
         </div>
         <div class="bv-dt-timeline" id="bv-dt-events">
           <div>[Ready] DevTools hook listening</div>
         </div>
       </div>
    `;
    document.body.appendChild(p);

    let isMobile = (window.innerWidth || (document.documentElement && document.documentElement.clientWidth) || 800) <= 768;
    let savedState = null;
    try { savedState = sessionStorage.getItem('bv_dt_collapsed'); } catch(e){}
    let isCollapsed = savedState !== null ? (savedState === 'true') : isMobile;

    function updatePanelState() {
      let b = document.getElementById('bv-dt-btn');
      if (isCollapsed) {
        p.classList.add('bv-dt-collapsed');
        if (b) b.innerText = '▲';
      } else {
        p.classList.remove('bv-dt-collapsed');
        if (b) b.innerText = '—';
      }
      try { sessionStorage.setItem('bv_dt_collapsed', isCollapsed ? 'true' : 'false'); } catch(e){}
    }
    updatePanelState();

    let toggleHeader = document.getElementById('bv-dt-toggle');
    if (toggleHeader) {
      toggleHeader.addEventListener('click', function(e) {
        isCollapsed = !isCollapsed;
        updatePanelState();
      });
    }

    // Dynamic stats updater
    setInterval(function(){
       let count = Object.keys(window.__BV_CORE__.components || {}).length;
       let el = document.getElementById('bv-com-count');
       if (el) el.querySelector('span:last-child').innerText = count;
       let hEl = document.getElementById('bv-hoisted-count');
       if (hEl) hEl.querySelector('span:last-child').innerText = window.__BV_CORE__.hoistedCount || 0;
    }, 1000);

    // Timeline event logger
    window.__BV_DEVTOOLS_HOOK__.on('*', function(ev) {
       let list = document.getElementById('bv-dt-events');
       if (list) {
          let line = document.createElement('div');
          line.innerText = '[' + ev.time.split(' ')[0] + '] ' + ev.type;
          list.prepend(line);
          while (list.children.length > 8) list.removeChild(list.lastChild);
       }
    });
  end;
end;

initialization
  { Automatical initialization if the module is included in the project }
  InitDevTools;
end.
