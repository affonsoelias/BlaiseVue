// BlaiseVue DevTools 2.0 Panel Script
(function() {
  let selectedComponent = null;
  let cachedTree = [];

  // Tab switching
  const tabs = document.querySelectorAll('.bv-dt-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.bv-dt-view').forEach(v => v.classList.remove('active'));
      tab.classList.add('active');
      const targetId = 'tab-' + tab.getAttribute('data-tab');
      const targetEl = document.getElementById(targetId);
      if (targetEl) targetEl.classList.add('active');
    });
  });

  // Safe eval on inspected window with fallback
  function evalInInspected(code, cb) {
    if (typeof chrome !== 'undefined' && chrome.devtools && chrome.devtools.inspectedWindow) {
      chrome.devtools.inspectedWindow.eval(code, (res, err) => {
        if (cb) cb(res, err);
      });
    } else {
      // Direct window fallback for testing
      try {
        const res = (0, eval)(code);
        if (cb) cb(res, null);
      } catch(err) {
        if (cb) cb(null, err);
      }
    }
  }

  // Refresh component tree
  function refreshTree() {
    evalInInspected(`(function() {
      if (window.__BV_DEVTOOLS_HOOK__) {
        return window.__BV_DEVTOOLS_HOOK__.getComponentTree();
      }
      return [];
    })()`, (tree, err) => {
      if (err || !tree) return;
      cachedTree = tree;
      renderTree(tree);
      if (selectedComponent) {
        const updated = tree.find(c => c.tag === selectedComponent.tag);
        if (updated) renderState(updated);
      }
    });
  }

  function renderTree(tree) {
    const list = document.getElementById('tree-list');
    if (!list) return;
    if (!tree || tree.length === 0) {
      list.innerHTML = '<div class="bv-dt-empty">No active components detected.</div>';
      return;
    }

    list.innerHTML = '';
    tree.forEach(comp => {
      const item = document.createElement('div');
      item.className = 'bv-dt-tree-item' + (selectedComponent && selectedComponent.tag === comp.tag ? ' selected' : '');
      item.innerHTML = `<span>🧩</span> <span>&lt;${comp.tag}&gt;</span>`;
      item.addEventListener('click', () => {
        document.querySelectorAll('.bv-dt-tree-item').forEach(i => i.classList.remove('selected'));
        item.classList.add('selected');
        selectedComponent = comp;
        renderState(comp);
      });
      list.appendChild(item);
    });
  }

  function renderState(comp) {
    const title = document.getElementById('selected-comp-name');
    const editor = document.getElementById('state-editor');
    if (title) title.innerText = '<' + comp.tag + '>';
    if (!editor) return;

    const state = comp.state || {};
    const keys = Object.keys(state).filter(k => !k.startsWith('$') && !k.startsWith('F'));

    if (keys.length === 0) {
      editor.innerHTML = '<div class="bv-dt-empty">Component has no observable state properties.</div>';
      return;
    }

    editor.innerHTML = '';
    keys.forEach(key => {
      const row = document.createElement('div');
      row.className = 'bv-dt-state-row';
      const keySpan = document.createElement('span');
      keySpan.className = 'bv-dt-state-key';
      keySpan.innerText = key;

      const valInput = document.createElement('input');
      valInput.className = 'bv-dt-state-val';
      valInput.value = typeof state[key] === 'object' ? JSON.stringify(state[key]) : String(state[key]);

      valInput.addEventListener('change', () => {
        let newVal = valInput.value;
        try { newVal = JSON.parse(newVal); } catch(e) {}
        // Live state modification in inspected app
        evalInInspected(`(function() {
          let el = document.querySelector('[data-bv-component="${comp.tag}"]');
          if (el && el['__bv_instance_data__']) {
            el['__bv_instance_data__']['${key}'] = ${JSON.stringify(newVal)};
          }
        })()`, () => {
          refreshTree();
        });
      });

      row.appendChild(keySpan);
      row.appendChild(valInput);
      editor.appendChild(row);
    });
  }

  // Timeline events polling
  function refreshTimeline() {
    evalInInspected(`(function() {
      if (window.__BV_DEVTOOLS_HOOK__) {
        return window.__BV_DEVTOOLS_HOOK__.events || [];
      }
      return [];
    })()`, (events) => {
      const list = document.getElementById('timeline-list');
      if (!list || !events) return;
      if (events.length === 0) {
        list.innerHTML = '<div class="bv-dt-empty">No events captured yet.</div>';
        return;
      }
      list.innerHTML = '';
      events.slice().reverse().forEach(ev => {
        const item = document.createElement('div');
        item.className = 'bv-dt-timeline-item';
        item.innerHTML = `<span>[${ev.time}] ${ev.type}</span> <span>${typeof ev.data === 'object' ? JSON.stringify(ev.data) : (ev.data || '')}</span>`;
        list.appendChild(item);
      });
    });
  }

  // Snapshots (Time Travel Debugging)
  function setupSnapshots() {
    const btn = document.getElementById('btn-take-snapshot');
    if (btn) {
      btn.addEventListener('click', () => {
        evalInInspected(`(function() {
          if (window.__BV_DEVTOOLS_HOOK__) {
            return window.__BV_DEVTOOLS_HOOK__.recordSnapshot();
          }
        })()`, () => {
          refreshSnapshots();
        });
      });
    }
  }

  function refreshSnapshots() {
    evalInInspected(`(function() {
      if (window.__BV_DEVTOOLS_HOOK__) {
        return window.__BV_DEVTOOLS_HOOK__.snapshots || [];
      }
      return [];
    })()`, (snapshots) => {
      const list = document.getElementById('snapshots-list');
      if (!list || !snapshots) return;
      if (snapshots.length === 0) {
        list.innerHTML = '<div class="bv-dt-empty">No snapshots captured. Take a snapshot to enable Time Travel.</div>';
        return;
      }
      list.innerHTML = '';
      snapshots.forEach((snap, idx) => {
        const item = document.createElement('div');
        item.className = 'bv-dt-snapshot-item';
        item.innerHTML = `<span>📸 ${snap.label} (${new Date(snap.time).toLocaleTimeString()})</span> <button class="btn-restore" data-idx="${idx}">Restore State</button>`;
        item.querySelector('.btn-restore').addEventListener('click', () => {
          // Restore snapshot state
          evalInInspected(`(function() {
            let snap = (window.__BV_DEVTOOLS_HOOK__ && window.__BV_DEVTOOLS_HOOK__.snapshots) ? window.__BV_DEVTOOLS_HOOK__.snapshots[${idx}] : null;
            if (snap && snap.tree) {
              snap.tree.forEach(sItem => {
                let el = document.querySelector('[data-bv-component="' + sItem.tag + '"]');
                if (el && el['__bv_instance_data__']) {
                  Object.assign(el['__bv_instance_data__'], sItem.state);
                }
              });
            }
          })()`, () => {
            refreshTree();
          });
        });
        list.appendChild(item);
      });
    });
  }

  // Button handlers
  const btnRefresh = document.getElementById('btn-refresh');
  if (btnRefresh) btnRefresh.addEventListener('click', () => { refreshTree(); refreshTimeline(); refreshSnapshots(); });

  const btnClearTimeline = document.getElementById('btn-clear-timeline');
  if (btnClearTimeline) {
    btnClearTimeline.addEventListener('click', () => {
      evalInInspected(`if (window.__BV_DEVTOOLS_HOOK__) window.__BV_DEVTOOLS_HOOK__.events = [];`, () => {
        refreshTimeline();
      });
    });
  }

  // Initial load & polling interval
  refreshTree();
  refreshTimeline();
  setupSnapshots();
  setInterval(() => {
    refreshTree();
    refreshTimeline();
  }, 2000);
})();
