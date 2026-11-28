// BlaiseVue HMR & Development Server (zero-dependency Node.js native WebSocket)
import http from 'http';
import crypto from 'crypto';
import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const PORT = parseInt(process.env.PORT || '8080', 10);
const WS_PORT = parseInt(process.env.WS_PORT || '8081', 10);
const ROOT_DIR = process.cwd();
let DIST_DIR = path.resolve(ROOT_DIR, 'dist');
let SRC_DIR = path.resolve(ROOT_DIR, 'src');

process.on('SIGINT', () => {
  process.exit(0);
});
process.on('SIGTERM', () => {
  process.exit(0);
});

if (!fs.existsSync(DIST_DIR) && fs.existsSync(path.resolve(ROOT_DIR, 'demo-app', 'dist'))) {
  DIST_DIR = path.resolve(ROOT_DIR, 'demo-app', 'dist');
  SRC_DIR = path.resolve(ROOT_DIR, 'demo-app', 'src');
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.wasm': 'application/wasm'
};

// 1. Static HTTP Server
const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];
  if (reqPath === '/' || reqPath === '') reqPath = '/index.html';
  let filePath = path.join(DIST_DIR, reqPath);

  // Security check
  if (!filePath.startsWith(DIST_DIR)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  // If path is a directory, check for index.html inside it (e.g. /docs -> /docs/index.html)
  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }

  // Fallback for SPA routing (only for path requests without file extensions)
  if (!fs.existsSync(filePath) && !path.extname(reqPath)) {
    filePath = path.join(DIST_DIR, 'index.html');
  }

  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';
    let content = fs.readFileSync(filePath);

    // Auto-inject HMR script in index.html during development
    if (ext === '.html') {
      let htmlStr = content.toString('utf8');
      if (!htmlStr.includes('__BV_HMR_CLIENT__')) {
        const hmrScript = `
        <script id="__BV_HMR_CLIENT__">
          (function() {
            if (window.__BV_CORE__ && window.__BV_CORE__.initHMR) {
              window.__BV_CORE__.initHMR(${currentWsPort});
            } else {
              try {
                let ws = new WebSocket('ws://' + window.location.hostname + ':${currentWsPort}');
                ws.onmessage = function(e) {
                  let d = JSON.parse(e.data);
                  if (d.type === 'reload') window.location.reload();
                  else if (d.type === 'patch' && window.__BV_CORE__ && window.__BV_CORE__.patchComponent) {
                    window.__BV_CORE__.patchComponent(d.component, d.options);
                  }
                };
              } catch(err) {}
            }
          })();
        </script>
        `;
        htmlStr = htmlStr.replace('</body>', hmrScript + '</body>');
        content = Buffer.from(htmlStr, 'utf8');
      }
    }

    res.writeHead(200, { 'Content-Type': contentType });
    res.end(content);
  } else {
    // If a source map file was requested by browser devtools but is not present, return empty map instead of 404
    if (filePath.endsWith('.map')) {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ version: 3, sources: [], mappings: "" }));
      return;
    }
    res.writeHead(404);
    res.end('Not Found');
  }
});

let currentHttpPort = PORT;
let currentWsPort = WS_PORT;
let wss = null;

function startHttp(port) {
  server.removeAllListeners('error');
  server.removeAllListeners('listening');
  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.log(`\x1b[33m[!] HTTP Port ${port} is busy. Switching to port ${port + 1}...\x1b[0m`);
      startHttp(port + 1);
    } else {
      console.error(err);
      process.exit(1);
    }
  });
  server.listen(port, () => {
    currentHttpPort = port;
    console.log(`\x1b[32m🛡️  BlaiseVue Dev Server running at http://localhost:${port}/\x1b[0m`);
    const nextWsPort = (port === PORT) ? WS_PORT : port + 1;
    startWs(nextWsPort);
  });
}

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

function createNativeWsServer(port) {
  const clients = new Set();
  const wsHttp = http.createServer((req, res) => {
    res.writeHead(426, { 'Content-Type': 'text/plain' });
    res.end('Upgrade Required');
  });

  wsHttp.on('upgrade', (req, socket) => {
    const key = req.headers['sec-websocket-key'];
    if (!key) {
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
      },
      close() {
        try { socket.end(encodeWsFrame(0x8, Buffer.alloc(0))); } catch {}
      }
    };
    clients.add(client);

    socket.on('data', (buf) => {
      if (buf.length < 2) return;
      const opcode = buf[0] & 0x0f;
      if (opcode === 0x8) {
        clients.delete(client);
        try { socket.end(encodeWsFrame(0x8, Buffer.alloc(0))); } catch {}
      } else if (opcode === 0x9) {
        if (!socket.destroyed && socket.writable) {
          socket.write(encodeWsFrame(0xA, Buffer.alloc(0)));
        }
      }
    });
    socket.on('close', () => clients.delete(client));
    socket.on('error', () => {
      clients.delete(client);
      try { socket.destroy(); } catch {}
    });
  });

  wsHttp.clients = clients;
  wsHttp.listen(port);
  return wsHttp;
}

function startWs(port) {
  if (port === currentHttpPort) {
    startWs(port + 1);
    return;
  }
  try {
    const wsServer = createNativeWsServer(port);
    wsServer.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        console.log(`\x1b[33m[!] WebSocket Port ${port} is busy. Switching to port ${port + 1}...\x1b[0m`);
        try { wsServer.close(); } catch {}
        startWs(port + 1);
      } else {
        console.error(`[HMR WebSocket Error]`, err);
      }
    });
    wsServer.on('listening', () => {
      wss = wsServer;
      currentWsPort = port;
      console.log(`\x1b[36m⚡ HMR WebSocket service listening on port ${port}\x1b[0m`);
    });
  } catch (e) {
    startWs(port + 1);
  }
}

startHttp(PORT);

function broadcast(msg) {
  if (!wss) return;
  const data = JSON.stringify(msg);
  wss.clients.forEach(client => {
    if (client.readyState === 1) client.send(data);
  });
}

let isBuilding = false;
let debounceTimer = null;
function watchDir(dir) {
  if (!fs.existsSync(dir)) return;
  const onWatchEvent = (eventType, filename) => {
    if (!filename || filename.includes('node_modules') || filename.includes('dist') || filename.includes('generated')) return;
    
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      console.log(`\x1b[33m[Watcher] File modified: ${filename}\x1b[0m`);
      const ext = path.extname(filename).toLowerCase();
      
      if (ext === '.bv') {
        const basename = path.basename(filename, '.bv');
        const tag = basename.toLowerCase();
        console.log(`\x1b[36m[HMR] Triggering recompilation for <${tag}>...\x1b[0m`);
        if (isBuilding) {
          console.log(`[HMR] Build already in progress, skipping duplicate trigger.`);
          return;
        }
        isBuilding = true;
        try {
          const isWindows = process.platform === 'win32';
          const binName = isWindows ? 'bv.exe' : 'bv';
          const selfDir = path.dirname(path.resolve(process.argv[1] || ROOT_DIR));
          const candidateExes = [
            path.resolve(selfDir, binName),
            path.resolve(ROOT_DIR, 'bin', binName),
            path.resolve(ROOT_DIR, binName),
            path.resolve(ROOT_DIR, '..', 'bin', binName),
            path.resolve(ROOT_DIR, '..', binName),
            path.resolve(ROOT_DIR, 'bin', 'bv.exe'),
            path.resolve(ROOT_DIR, 'bin', 'bv')
          ];
          const bvExe = candidateExes.find(p => fs.existsSync(p));
          const appDir = fs.existsSync(path.resolve(ROOT_DIR, 'demo-app')) ? path.resolve(ROOT_DIR, 'demo-app') : ROOT_DIR;
          if (bvExe) {
            execSync(`"${bvExe}" build`, { cwd: appDir, stdio: 'pipe' });
            console.log(`\x1b[32m[HMR] Dev build refreshed. Broadcasting update...\x1b[0m`);
            broadcast({ type: 'reload' });
          } else {
            broadcast({ type: 'reload' });
          }
        } catch(e) {
          console.error(`[HMR] Build error:`, e.message);
        } finally {
          isBuilding = false;
        }
      } else {
        broadcast({ type: 'reload' });
      }
    }, 200);
  };
  try {
    fs.watch(dir, { recursive: true }, onWatchEvent);
  } catch {
    try { fs.watch(dir, onWatchEvent); } catch {}
  }
}

watchDir(SRC_DIR);
if (fs.existsSync(path.resolve(ROOT_DIR, 'lib'))) {
  watchDir(path.resolve(ROOT_DIR, 'lib'));
}
