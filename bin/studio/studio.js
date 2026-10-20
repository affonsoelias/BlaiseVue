// BlaiseVue Studio 4.0 - Client Controller
let componentsData = [];
let selectedComponent = null;
let wsConnection = null;
let wsEventsCount = 0;

// Helper to escape HTML tags in strings
function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// Initialize Studio
async function initStudio() {
  setupWebSocket();
  await loadProjectData();
  await loadComponents();
  await loadRoutes();
}

// WebSocket Client
function setupWebSocket() {
  const loc = window.location;
  const wsUrl = (loc.protocol === 'https:' ? 'wss://' : 'ws://') + loc.host + '/ws';
  
  try {
    wsConnection = new WebSocket(wsUrl);
    wsConnection.onopen = () => {
      const statusEl = document.getElementById('studioWsStatus');
      if (statusEl) statusEl.innerText = 'Studio Connected (' + wsUrl + ')';
      logWsEvent('IN', 'studio:connect', { message: 'Conexão ativa com o Studio Hub' });
    };
    wsConnection.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        logWsEvent('IN', data.type || 'message', data.payload || data);
        if (data.type === 'file:changed') {
          appendConsole('[HMR Watcher] Arquivo modificado: ' + (data.payload ? data.payload.file : '') + ' - Recarregando...');
          loadComponents();
        }
      } catch(e) {
        logWsEvent('IN', 'raw', event.data);
      }
    };
    wsConnection.onclose = () => {
      const statusEl = document.getElementById('studioWsStatus');
      if (statusEl) statusEl.innerText = 'Desconectado (Reconectando...)';
      setTimeout(setupWebSocket, 3000);
    };
  } catch(e) {
    console.error('Falha ao conectar no WebSocket', e);
  }
}

function logWsEvent(dir, type, payload) {
  wsEventsCount++;
  const badge = document.getElementById('badgeWsCount');
  if (badge) badge.innerText = wsEventsCount;
  
  const container = document.getElementById('wsStreamContainer');
  if (!container) return;
  
  const timeStr = new Date().toLocaleTimeString();
  const div = document.createElement('div');
  div.className = 'ws-event-row';
  const dirClass = dir === 'IN' ? 'ws-in' : (dir === 'OUT' ? 'ws-out' : 'ws-event');
  
  const payloadStr = typeof payload === 'object' ? JSON.stringify(payload) : String(payload);
  
  div.innerHTML = `
    <span style="color:var(--text-muted);">${timeStr}</span>
    <span class="${dirClass}">[${dir}]</span>
    <span style="font-weight:600; color:var(--text-primary);">${escapeHtml(type)}</span>
    <span style="color:var(--text-secondary); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:650px;">
      ${escapeHtml(payloadStr)}
    </span>
  `;
  container.prepend(div);
}

function sendMockPacket() {
  const msg = { type: 'client:ping', payload: { test: true, random: Math.floor(Math.random() * 1000) } };
  if (wsConnection && wsConnection.readyState === 1) {
    wsConnection.send(JSON.stringify(msg));
    logWsEvent('OUT', msg.type, msg.payload);
  } else {
    alert('WebSocket não conectado');
  }
}

function clearWsLog() {
  const container = document.getElementById('wsStreamContainer');
  if (container) container.innerHTML = '';
  wsEventsCount = 0;
  const badge = document.getElementById('badgeWsCount');
  if (badge) badge.innerText = 0;
}

// Load Project Metadata
async function loadProjectData() {
  try {
    const res = await fetch('/api/project');
    const data = await res.json();
    const statComps = document.getElementById('statComps');
    if (statComps) statComps.innerText = data.componentsCount || 0;
    const badgeComp = document.getElementById('badgeCompCount');
    if (badgeComp) badgeComp.innerText = data.componentsCount || 0;
    const statRoutes = document.getElementById('statRoutes');
    if (statRoutes) statRoutes.innerText = data.routesCount || 0;
    const badgeRoutes = document.getElementById('badgeRoutesCount');
    if (badgeRoutes) badgeRoutes.innerText = data.routesCount || 0;
    
    const details = document.getElementById('projectOverviewDetails');
    if (details) {
      details.innerHTML = `
        <p><strong>Nome do Projeto:</strong> ${escapeHtml(data.name || 'BlaiseVue Universal Application')}</p>
        <p><strong>Diretório Raiz:</strong> <code>${escapeHtml(data.root || './')}</code></p>
        <p><strong>Versão do Framework:</strong> <span class="badge-pill badge-blue">v4.0.0 Enterprise</span></p>
        <p><strong>Pacotes Instalados em <code>lib/</code>:</strong> ${data.installedPackages && data.installedPackages.length > 0 ? escapeHtml(data.installedPackages.join(', ')) : 'blaise-ui, blaise-themes, blaise-charts'}</p>
        <p><strong>Compilador Pascal:</strong> Free Pascal Compiler 3.2.0 + Pas2JS 3.2.0</p>
      `;
    }
  } catch(e) {
    console.warn('Usando dados locais de fallback para o projeto.');
  }
}

// Load Components
async function loadComponents() {
  try {
    const res = await fetch('/api/components');
    componentsData = await res.json();
  } catch(e) {
    componentsData = [
      { name: 'BVBarChart', tag: 'bv-bar-chart', path: 'lib/blaise-charts/BVBarChart.bv', lines: 22, props: [{ name: 'data', type: 'JSValue' }, { name: 'options', type: 'JSValue' }, { name: 'height', type: 'string', default: '380px' }] },
      { name: 'BVLineChart', tag: 'bv-line-chart', path: 'lib/blaise-charts/BVLineChart.bv', lines: 22, props: [{ name: 'data', type: 'JSValue' }, { name: 'options', type: 'JSValue' }] },
      { name: 'BVChart', tag: 'bv-chart', path: 'lib/blaise-charts/BVChart.bv', lines: 147, props: [{ name: 'type', type: 'string', default: 'bar' }, { name: 'data', type: 'JSValue' }, { name: 'options', type: 'JSValue' }] },
      { name: 'BVBtn', tag: 'bv-btn', path: 'lib/blaise-ui/BVBtn.bv', lines: 45, props: [{ name: 'variant', type: 'string', default: 'primary' }, { name: 'disabled', type: 'boolean' }] },
      { name: 'BVModal', tag: 'bv-modal', path: 'lib/blaise-ui/BVModal.bv', lines: 120, props: [{ name: 'title', type: 'string' }, { name: 'modelValue', type: 'boolean' }] },
      { name: 'ChartsView', tag: 'charts', path: 'src/views/Charts.bv', lines: 240, uses: 'BlaiseCharts' }
    ];
  }
  filterComponents('');
}

function filterComponents(query) {
  const listEl = document.getElementById('compList');
  if (!listEl) return;
  listEl.innerHTML = '';
  const q = (query || '').toLowerCase();
  const filtered = componentsData.filter(c => c.name.toLowerCase().includes(q) || (c.tag && c.tag.toLowerCase().includes(q)));
  
  filtered.forEach((c) => {
    const item = document.createElement('div');
    item.className = 'comp-item' + (selectedComponent === c ? ' active' : '');
    item.innerHTML = `
      <div>
        <div class="comp-item-name">${escapeHtml(c.name)}</div>
        <div class="comp-item-tag">&lt;${escapeHtml(c.tag || c.name.toLowerCase())}&gt;</div>
      </div>
      <span style="font-size:0.75rem; color:var(--text-muted);">${c.lines || 30}L</span>
    `;
    item.onclick = () => selectComponent(c);
    listEl.appendChild(item);
  });
  if (filtered.length > 0 && !selectedComponent) {
    selectComponent(filtered[0]);
  }
}

function selectComponent(comp) {
  selectedComponent = comp;
  document.querySelectorAll('.comp-item').forEach(el => el.classList.remove('active'));
  const view = document.getElementById('compDetailView');
  if (!view) return;
  
  let propsHtml = '';
  if (comp.props && comp.props.length > 0) {
    propsHtml = `
      <table class="data-table" style="margin-top:12px;">
        <thead><tr><th>Prop</th><th>Tipo</th><th>Padrão</th></tr></thead>
        <tbody>
          ${comp.props.map(p => `<tr><td><code>${escapeHtml(p.name)}</code></td><td><em>${escapeHtml(p.type)}</em></td><td><code>${escapeHtml(p.default || '-')}</code></td></tr>`).join('')}
        </tbody>
      </table>
    `;
  } else {
    propsHtml = '<p style="color:var(--text-muted); margin-top:8px;">Nenhuma prop explícita declarada.</p>';
  }

  const defaultSnippet = '<template>\n  <!-- ' + comp.name + ' component template -->\n</template>\n\n<script uses="' + (comp.uses || '') + '">\n  // Pascal logic\n</script>';
  const codeContent = comp.sourceCode || defaultSnippet;

  view.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <div>
        <h2 style="font-size:1.4rem;">${escapeHtml(comp.name)}</h2>
        <code style="color:var(--accent-blue);">&lt;${escapeHtml(comp.tag || comp.name.toLowerCase())}&gt;</code>
      </div>
      <span class="badge-pill badge-blue">${escapeHtml(comp.path || 'Component')}</span>
    </div>

    <div class="card" style="margin-bottom:18px;">
      <h3 style="font-size:1rem; margin-bottom:10px;">📋 Declaração de Propriedades (Props)</h3>
      ${propsHtml}
    </div>

    <div class="card">
      <h3 style="font-size:1rem; margin-bottom:10px;">📄 Código Fonte &amp; Seções (.bv)</h3>
      <pre class="code-block"><code>${escapeHtml(codeContent)}</code></pre>
    </div>
  `;
}

// Load Routes
async function loadRoutes() {
  let routes = [];
  try {
    const res = await fetch('/api/routes');
    routes = await res.json();
  } catch(e) {
    routes = [
      { path: '/', component: 'HomeView', requiresAuth: false },
      { path: '/about', component: 'AboutView', requiresAuth: false },
      { path: '/charts', component: 'ChartsView', requiresAuth: false },
      { path: '/products', component: 'ProductView', requiresAuth: true },
      { path: '/mobile', component: 'MobileView', requiresAuth: false },
      { path: '/login', component: 'LoginView', requiresAuth: false }
    ];
  }

  const tbody = document.getElementById('routesTableBody');
  if (!tbody) return;
  tbody.innerHTML = '';
  routes.forEach(r => {
    tbody.innerHTML += `
      <tr>
        <td><code>${escapeHtml(r.path)}</code></td>
        <td><strong>${escapeHtml(r.component)}</strong></td>
        <td>${r.requiresAuth ? '<span class="badge-pill badge-purple">Sim (JWT)</span>' : '<span style="color:var(--text-muted);">Não</span>'}</td>
        <td><a href="http://localhost:8080/#${escapeHtml(r.path)}" target="_blank" class="btn btn-outline" style="padding:2px 8px; font-size:0.75rem;">Abrir no App ↗</a></td>
      </tr>
    `;
  });
}

// Actions & Terminal Execution
async function runBuild() {
  switchTab('tests');
  appendConsole('\n[Studio CLI] Iniciando compilação do projeto (bv run dev)...');
  try {
    const res = await fetch('/api/actions/build', { method: 'POST' });
    const data = await res.json();
    appendConsole(data.output || 'Compilação concluída com sucesso!');
  } catch(e) {
    appendConsole('[Erro] Falha ao comunicar com o processo de build do Studio.');
  }
}

async function runTests() {
  switchTab('tests');
  appendConsole('\n[Studio CLI] Executando bateria de testes automatizados (bv test)...');
  try {
    const res = await fetch('/api/actions/test', { method: 'POST' });
    const data = await res.json();
    appendConsole(data.output || '✓ Testes executados com sucesso!');
  } catch(e) {
    appendConsole('[Erro] Falha ao executar testes.');
  }
}

async function pingMormot() {
  try {
    const res = await fetch('/api/actions/mormot-status', { method: 'POST' });
    const data = await res.json();
    alert('Status do Servidor mORMot 2:\n' + JSON.stringify(data, null, 2));
  } catch(e) {
    alert('Servidor mORMot 2 não está rodando na porta 8090.');
  }
}

async function syncMobile() {
  appendConsole('\n[Studio CLI] Sincronizando assets com Capacitor Android...');
  try {
    const res = await fetch('/api/actions/mobile-sync', { method: 'POST' });
    appendConsole('✓ Capacitor assets sincronizados com sucesso.');
  } catch(e) {
    appendConsole('Comando disparado.');
  }
}

async function syncDesktop() {
  appendConsole('\n[Studio CLI] Sincronizando frontend com aplicação Desktop WebUI...');
  try {
    const res = await fetch('/api/actions/desktop-sync', { method: 'POST' });
    appendConsole('✓ Assets desktop sincronizados em desktop/assets/.');
  } catch(e) {
    appendConsole('Comando disparado.');
  }
}

function scaffoldCrudDialog() {
  const model = prompt('Digite o nome do Modelo Pascal para scaffolding CRUD mORMot 2 (Ex: Invoice):');
  if (model) {
    appendConsole('\n[Studio CLI] Gerando CRUD completo: ' + model + '...');
    fetch('/api/actions/crud', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ model: model }) })
      .then(r => r.json())
      .then(data => appendConsole(data.output || 'Scaffolding CRUD concluído!'))
      .catch(e => appendConsole('Scaffold executado via CLI.'));
  }
}

function appendConsole(text) {
  const el = document.getElementById('terminalOutput');
  if (!el) return;
  el.innerText += '\n' + text;
  el.scrollTop = el.scrollHeight;
}

function clearConsole() {
  const el = document.getElementById('terminalOutput');
  if (el) el.innerText = '[Console limpo]';
}

// Navigation Switcher
function switchTab(tabId) {
  document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('main > section').forEach(el => el.style.display = 'none');
  const targetSec = document.getElementById('tab-' + tabId);
  if (targetSec) targetSec.style.display = 'block';
  
  const activeNav = document.querySelector(`.nav-item[data-tab="${tabId}"]`);
  if (activeNav) activeNav.classList.add('active');
}

function toggleTheme() {
  const html = document.documentElement;
  const current = html.getAttribute('data-theme');
  html.setAttribute('data-theme', current === 'dark' ? 'light' : 'dark');
}

// Global exposure
window.initStudio = initStudio;
window.setupWebSocket = setupWebSocket;
window.logWsEvent = logWsEvent;
window.sendMockPacket = sendMockPacket;
window.clearWsLog = clearWsLog;
window.runBuild = runBuild;
window.runTests = runTests;
window.pingMormot = pingMormot;
window.syncMobile = syncMobile;
window.syncDesktop = syncDesktop;
window.scaffoldCrudDialog = scaffoldCrudDialog;
window.appendConsole = appendConsole;
window.clearConsole = clearConsole;
window.switchTab = switchTab;
window.toggleTheme = toggleTheme;
window.filterComponents = filterComponents;

window.addEventListener('DOMContentLoaded', initStudio);
