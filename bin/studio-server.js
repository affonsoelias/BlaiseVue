// BlaiseVue Studio - Developer Cockpit & Live Hub Server (zero-dependency WebSocket)
import http from 'http';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { exec } from 'child_process';

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

function resolveSdkVersion() {
  try {
    const pkgPath = path.resolve(__dirname, '..', 'package.json');
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
      if (pkg && pkg.version) return String(pkg.version).replace(/^v/i, '');
    }
  } catch {}
  return '';
}
const BV_VERSION = resolveSdkVersion();
const STUDIO_TITLE = BV_VERSION ? `BlaiseVue Studio v${BV_VERSION}` : 'BlaiseVue Studio';

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
    exec('bv build', { cwd: ROOT_DIR }, (error, stdout, stderr) => {
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

// 2. Native WebSocket Server (RFC 6455, zero external deps)
function encodeWsFrame(opcode, payloadBuf) {
  const len = payloadBuf.length;
  let header;
  if (len < 126) {
    header = Buffer.allocUnsafe(2);
    header[0] = 0x80 | opcode;
    header[1] = len;
  } else if (len < 65536) {
    header = Buffer.allocUnsafe(4);
    header[0] = 0x80 | opcode;
    header[1] = 126;
    header.writeUInt16BE(len, 2);
  } else {
    header = Buffer.allocUnsafe(10);
    header[0] = 0x80 | opcode;
    header[1] = 127;
    header.writeBigUInt64BE(BigInt(len), 2);
  }
  return Buffer.concat([header, payloadBuf]);
}

const wsClients = new Set();
const wss = { clients: wsClients };

server.on('upgrade', (req, socket) => {
  const reqPath = (req.url || '').split('?')[0];
  const key = req.headers['sec-websocket-key'];
  if (reqPath !== '/ws' || !key) {
    socket.destroy();
    return;
  }

  const accept = crypto
    .createHash('sha1')
    .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
    .digest('base64');

  socket.write(
    'HTTP/1.1 101 Switching Protocols\r\n' +
    'Upgrade: websocket\r\n' +
    'Connection: Upgrade\r\n' +
    `Sec-WebSocket-Accept: ${accept}\r\n\r\n`
  );

  const client = {
    get readyState() { return (!socket.destroyed && socket.writable) ? 1 : 3; },
    send(data) {
      if (!socket.destroyed && socket.writable) {
        socket.write(encodeWsFrame(0x1, Buffer.from(String(data), 'utf8')));
      }
    }
  };
  wsClients.add(client);

  client.send(JSON.stringify({
    type: 'studio:welcome',
    payload: {
      message: `Connected to ${STUDIO_TITLE} Hub`,
      time: new Date().toISOString()
    }
  }));

  let rxBuf = Buffer.alloc(0);
  socket.on('data', (chunk) => {
    rxBuf = Buffer.concat([rxBuf, chunk]);
    while (rxBuf.length >= 2) {
      const opcode = rxBuf[0] & 0x0f;
      const masked = (rxBuf[1] & 0x80) !== 0;
      let len = rxBuf[1] & 0x7f;
      let offset = 2;
      if (len === 126) {
        if (rxBuf.length < offset + 2) return;
        len = rxBuf.readUInt16BE(offset);
        offset += 2;
      } else if (len === 127) {
        if (rxBuf.length < offset + 8) return;
        len = Number(rxBuf.readBigUInt64BE(offset));
        offset += 8;
      }
      const maskLen = masked ? 4 : 0;
      if (rxBuf.length < offset + maskLen + len) return;

      const payload = Buffer.allocUnsafe(len);
      if (masked) {
        const maskKey = rxBuf.subarray(offset, offset + 4);
        offset += 4;
        for (let i = 0; i < len; i++) {
          payload[i] = rxBuf[offset + i] ^ maskKey[i % 4];
        }
      } else {
        rxBuf.copy(payload, 0, offset, offset + len);
      }
      rxBuf = rxBuf.subarray(offset + len);

      if (opcode === 0x8) {
        wsClients.delete(client);
        try { socket.end(encodeWsFrame(0x8, Buffer.alloc(0))); } catch {}
        return;
      } else if (opcode === 0x9) {
        if (!socket.destroyed && socket.writable) {
          socket.write(encodeWsFrame(0xA, payload));
        }
      } else if (opcode === 0x1) {
        try {
          const data = JSON.parse(payload.toString('utf8'));
          wsClients.forEach((other) => {
            if (other !== client && other.readyState === 1) {
              other.send(JSON.stringify(data));
            }
          });
        } catch {}
      }
    }
  });

  socket.on('close', () => wsClients.delete(client));
  socket.on('error', () => {
    wsClients.delete(client);
    try { socket.destroy(); } catch {}
  });
});

// Watch src/ and lib/ for changes to notify Studio
const watchDirs = ['src', 'lib'].map(d => path.join(ROOT_DIR, d)).filter(fs.existsSync);
watchDirs.forEach(dir => {
  const notifyChange = (eventType, filename) => {
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
  };
  try {
    fs.watch(dir, { recursive: true }, notifyChange);
  } catch {
    try { fs.watch(dir, notifyChange); } catch {}
  }
});

// Start Server
server.listen(PORT, () => {
  console.log(`\n======================================================`);
  console.log(` 🛡️  ${STUDIO_TITLE} - Developer Cockpit Active`);
  console.log(`======================================================`);
  console.log(`  Studio Dashboard: http://localhost:${PORT}`);
  console.log(`  Live WebSocket:   ws://localhost:${PORT}/ws`);
  console.log(`  Project Directory: ${ROOT_DIR}`);
  console.log(`======================================================\n`);
});
