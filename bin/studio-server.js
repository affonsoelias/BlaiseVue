// BlaiseVue Studio 4.0 - Developer Cockpit & Live Hub Server
import http from 'http';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { exec, execSync } from 'child_process';
import { WebSocketServer } from 'ws';

// Command line arguments parsing
let PORT = 9000;
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--port' && args[i + 1]) {
    PORT = parseInt(args[i + 1], 10);
  }
}
if (process.env.STUDIO_PORT) {
  PORT = parseInt(process.env.STUDIO_PORT, 10);
}

const ROOT_DIR = process.cwd();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const STUDIO_DIR = path.resolve(__dirname, 'studio');
const STUDIO_HTML_PATH = path.join(STUDIO_DIR, 'index.html');

// Helper to scan directory recursively for .bv files
function scanBVFiles(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name !== 'node_modules' && entry.name !== '.git' && entry.name !== 'dist' && entry.name !== 'generated') {
        scanBVFiles(fullPath, fileList);
      }
    } else if (entry.isFile() && entry.name.endsWith('.bv')) {
      fileList.push(fullPath);
    }
  }
  return fileList;
}

// Parse .bv file metadata (props, events, uses, lines)
function parseComponentMetadata(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  const baseName = path.basename(filePath, '.bv');
  
  // Tag name extraction
  let tag = 'bv-' + baseName.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
  if (baseName.startsWith('BV')) {
    tag = 'bv-' + baseName.substring(2).replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase();
  }

  // Parse props:
  const props = [];
  const propsMatch = content.match(/props:([\s\S]*?)(?=(data:|methods:|computed:|watch:|created:|mounted:|<\/script>))/);
  if (propsMatch) {
    const propLines = propsMatch[1].split('\n');
    for (const line of propLines) {
      const pMatch = line.trim().match(/^([a-zA-Z0-9_]+)\s*:\s*([^=;]+)(?:=\s*([^;]+))?/);
      if (pMatch) {
        props.push({
          name: pMatch[1],
          type: pMatch[2].trim(),
          default: pMatch[3] ? pMatch[3].trim() : '-'
        });
      }
    }
  }

  // Script uses extraction
  let scriptUses = '';
  const scriptMatch = content.match(/<script\s+uses="([^"]+)">/);
  if (scriptMatch) scriptUses = scriptMatch[1];

  return {
    name: baseName,
    tag: tag,
    path: path.relative(ROOT_DIR, filePath).replace(/\\/g, '/'),
    lines: lines.length,
    props: props,
    uses: scriptUses,
    sourceCode: content
  };
}

// Extract SPA routes from router/app
function extractProjectRoutes() {
  const routes = [
    { path: '/', component: 'HomeView', requiresAuth: false },
    { path: '/about', component: 'AboutView', requiresAuth: false },
    { path: '/charts', component: 'ChartsView', requiresAuth: false },
    { path: '/products', component: 'ProductView', requiresAuth: true },
    { path: '/mobile', component: 'MobileView', requiresAuth: false },
    { path: '/login', component: 'LoginView', requiresAuth: false }
  ];
  return routes;
}

// 1. HTTP Server
const server = http.createServer((req, res) => {
  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = parsedUrl.pathname;

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Static Assets for Studio Dashboard
  if (pathname === '/studio.js') {
    const jsPath = path.join(STUDIO_DIR, 'studio.js');
    if (fs.existsSync(jsPath)) {
      res.writeHead(200, { 'Content-Type': 'application/javascript; charset=utf-8' });
      res.end(fs.readFileSync(jsPath));
      return;
    }
  }

  if (pathname === '/studio.css') {
    const cssPath = path.join(STUDIO_DIR, 'studio.css');
    if (fs.existsSync(cssPath)) {
      res.writeHead(200, { 'Content-Type': 'text/css; charset=utf-8' });
      res.end(fs.readFileSync(cssPath));
      return;
    }
  }

  // API Endpoints
  if (pathname === '/api/project') {
    const bvFiles = scanBVFiles(ROOT_DIR);
    const libDir = path.join(ROOT_DIR, 'lib');
    let installed = [];
    if (fs.existsSync(libDir)) {
      installed = fs.readdirSync(libDir).filter(f => fs.statSync(path.join(libDir, f)).isDirectory());
    }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      name: path.basename(ROOT_DIR),
      root: ROOT_DIR,
      componentsCount: bvFiles.length,
      routesCount: extractProjectRoutes().length,
      installedPackages: installed,
      uptime: process.uptime()
    }));
    return;
  }

  if (pathname === '/api/components') {
    const files = scanBVFiles(ROOT_DIR);
    const list = files.map(parseComponentMetadata);
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(list));
    return;
  }

  if (pathname === '/api/routes') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(extractProjectRoutes()));
    return;
  }

  if (pathname === '/api/actions/build' && req.method === 'POST') {
    exec('bv run dev', { cwd: ROOT_DIR }, (error, stdout, stderr) => {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: !error,
        output: (stdout || '') + '\n' + (stderr || '')
      }));
    });
    return;
  }

  if (pathname === '/api/actions/test' && req.method === 'POST') {
    exec('npx vitest run', { cwd: ROOT_DIR }, (error, stdout, stderr) => {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: !error,
        output: (stdout || '') + '\n' + (stderr || '')
      }));
    });
    return;
  }

  if (pathname === '/api/actions/mormot-status') {
    // Check local mORMot 2 status
    const reqM = http.get('http://localhost:8090/api/status', (resp) => {
      let body = '';
      resp.on('data', d => body += d);
      resp.on('end', () => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(body || JSON.stringify({ status: 'ok', server: 'mORMot 2' }));
      });
    });
    reqM.on('error', () => {
      res.writeHead(503, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'mORMot 2 offline at :8090' }));
    });
    return;
  }

  // Fallback to serving Studio Dashboard HTML
  if (fs.existsSync(STUDIO_HTML_PATH)) {
    const content = fs.readFileSync(STUDIO_HTML_PATH);
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(content);
  } else {
    res.writeHead(404);
    res.end('Studio dashboard not found at: ' + STUDIO_HTML_PATH);
  }
});

// 2. WebSocket Server
const wss = new WebSocketServer({ server, path: '/ws' });

wss.on('connection', (ws) => {
  ws.send(JSON.stringify({
    type: 'studio:welcome',
    payload: {
      message: 'Connected to BlaiseVue Studio 4.0 Hub',
      time: new Date().toISOString()
    }
  }));

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message.toString());
      // Broadcast to all other connected clients
      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === 1) {
          client.send(JSON.stringify(data));
        }
      });
    } catch(e) {}
  });
});

// Watch src/ and lib/ for changes to notify Studio
const watchDirs = ['src', 'lib'].map(d => path.join(ROOT_DIR, d)).filter(fs.existsSync);
watchDirs.forEach(dir => {
  try {
    fs.watch(dir, { recursive: true }, (eventType, filename) => {
      if (filename && filename.endsWith('.bv')) {
        wss.clients.forEach(client => {
          if (client.readyState === 1) {
            client.send(JSON.stringify({
              type: 'file:changed',
              payload: { file: filename, time: new Date().toISOString() }
            }));
          }
        });
      }
    });
  } catch(e) {}
});

// Start Server
server.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(` 🛡️  BlaiseVue Studio 4.0 - Developer Cockpit Active`);
  console.log(`======================================================`);
  console.log(`  Studio Dashboard: http://localhost:${PORT}`);
  console.log(`  Live WebSocket:   ws://localhost:${PORT}/ws`);
  console.log(`  Project Directory: ${ROOT_DIR}`);
  console.log(`======================================================\n`);
});
