// Zero-dependency smoke & integration test for BlaiseVue CLI and native WebSocket servers.
// Run: node tests/cli/cli_smoke.mjs

import assert from 'node:assert/strict';
import { execFileSync, spawn } from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import http from 'node:http';
import net from 'node:net';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, '..', '..');

const pkg = JSON.parse(fs.readFileSync(path.join(REPO_ROOT, 'package.json'), 'utf8'));
const EXPECTED_VER = String(pkg.version || '').replace(/^v/i, '');
assert.ok(EXPECTED_VER.length > 0, 'package.json must define version');

const BV_BIN = path.join(REPO_ROOT, 'bin', process.platform === 'win32' ? 'bv.exe' : 'bv');
assert.ok(fs.existsSync(BV_BIN), `CLI binary not found at ${BV_BIN}`);

function runBv(args, cwd = REPO_ROOT) {
  return execFileSync(BV_BIN, args, {
    cwd,
    encoding: 'utf8',
    timeout: 60000,
    stdio: ['ignore', 'pipe', 'pipe']
  });
}

function getFreePort() {
  return new Promise((resolve, reject) => {
    const srv = net.createServer();
    srv.unref();
    srv.on('error', reject);
    srv.listen(0, '127.0.0.1', () => {
      const { port } = srv.address();
      srv.close(() => resolve(port));
    });
  });
}

function httpGet(urlStr) {
  return new Promise((resolve, reject) => {
    const req = http.get(urlStr, (res) => {
      let body = '';
      res.setEncoding('utf8');
      res.on('data', (d) => { body += d; });
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', reject);
    req.setTimeout(5000, () => req.destroy(new Error(`HTTP timeout for ${urlStr}`)));
  });
}

async function waitForHttp(urlStr, timeoutMs = 8000) {
  const deadline = Date.now() + timeoutMs;
  let lastErr;
  while (Date.now() < deadline) {
    try {
      return await httpGet(urlStr);
    } catch (err) {
      lastErr = err;
      await new Promise((r) => setTimeout(r, 120));
    }
  }
  throw lastErr || new Error(`Timed out waiting for ${urlStr}`);
}

function encodeMaskedWsFrame(opcode, payloadBuf = Buffer.alloc(0)) {
  const len = payloadBuf.length;
  assert.ok(len < 126, 'Helper supports small frames only');
  const mask = crypto.randomBytes(4);
  const frame = Buffer.allocUnsafe(2 + 4 + len);
  frame[0] = 0x80 | opcode;
  frame[1] = 0x80 | len;
  mask.copy(frame, 2);
  for (let i = 0; i < len; i++) {
    frame[6 + i] = payloadBuf[i] ^ mask[i % 4];
  }
  return frame;
}

function connectRawWs(port, reqPath = '/') {
  return new Promise((resolve, reject) => {
    const key = crypto.randomBytes(16).toString('base64');
    const expectedAccept = crypto
      .createHash('sha1')
      .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
      .digest('base64');

    const socket = net.createConnection({ host: '127.0.0.1', port }, () => {
      socket.write(
        `GET ${reqPath} HTTP/1.1\r\n` +
        `Host: 127.0.0.1:${port}\r\n` +
        'Upgrade: websocket\r\n' +
        'Connection: Upgrade\r\n' +
        `Sec-WebSocket-Key: ${key}\r\n` +
        'Sec-WebSocket-Version: 13\r\n\r\n'
      );
    });

    let buf = Buffer.alloc(0);
    let upgraded = false;
    const frames = [];

    const timer = setTimeout(() => {
      socket.destroy();
      reject(new Error(`WebSocket handshake timeout on port ${port}${reqPath}`));
    }, 5000);

    function parseFrames() {
      while (buf.length >= 2) {
        const opcode = buf[0] & 0x0f;
        const lenByte = buf[1] & 0x7f;
        let offset = 2;
        let len = lenByte;
        if (lenByte === 126) {
          if (buf.length < offset + 2) break;
          len = buf.readUInt16BE(offset);
          offset += 2;
        } else if (lenByte === 127) {
          if (buf.length < offset + 8) break;
          len = Number(buf.readBigUInt64BE(offset));
          offset += 8;
        }
        if (buf.length < offset + len) break;
        const payload = buf.subarray(offset, offset + len);
        buf = buf.subarray(offset + len);
        frames.push({ opcode, payload });
        socket.emit('ws-frame', { opcode, payload });
      }
    }

    socket.on('data', (chunk) => {
      buf = Buffer.concat([buf, chunk]);
      if (!upgraded) {
        const hdrEnd = buf.indexOf('\r\n\r\n');
        if (hdrEnd === -1) return;
        const hdr = buf.subarray(0, hdrEnd).toString('utf8');
        buf = buf.subarray(hdrEnd + 4);
        assert.match(hdr, /^HTTP\/1\.1 101 Switching Protocols/i, `Unexpected WS status:\n${hdr}`);
        assert.ok(hdr.includes(`Sec-WebSocket-Accept: ${expectedAccept}`), 'Invalid Sec-WebSocket-Accept');
        upgraded = true;
        clearTimeout(timer);
        parseFrames();
        resolve({
          socket,
          frames,
          waitForFrame(predicate, waitMs = 3000) {
            const hit = frames.find(predicate);
            if (hit) return Promise.resolve(hit);
            return new Promise((resF, rejF) => {
              const t = setTimeout(() => rejF(new Error('Timed out waiting for WS frame')), waitMs);
              const onFrame = (f) => {
                if (predicate(f)) {
                  clearTimeout(t);
                  socket.off('ws-frame', onFrame);
                  resF(f);
                }
              };
              socket.on('ws-frame', onFrame);
            });
          },
          sendPing() {
            socket.write(encodeMaskedWsFrame(0x9));
          },
          close() {
            try { socket.end(encodeMaskedWsFrame(0x8)); } catch {}
            socket.destroy();
          }
        });
      } else {
        parseFrames();
      }
    });

    socket.on('error', (err) => {
      clearTimeout(timer);
      reject(err);
    });
  });
}

async function stopChild(child) {
  if (!child || child.killed || child.exitCode !== null) return;
  try { child.kill('SIGTERM'); } catch {}
  await new Promise((r) => setTimeout(r, 250));
  if (child.exitCode === null) {
    try { child.kill('SIGKILL'); } catch {}
  }
}

async function main() {
  const tmpBase = fs.mkdtempSync(path.join(os.tmpdir(), 'bv-cli-smoke-'));
  const appDir = path.join(tmpBase, 'smoke_app');
  const children = [];

  try {
    // 1. CLI --version
    const verOut = runBv(['--version']);
    assert.ok(
      verOut.includes(`BlaiseVue CLI v${EXPECTED_VER}`),
      `Expected CLI v${EXPECTED_VER}, got: ${verOut.trim()}`
    );
    console.log(`[PASS] 1/5 bv --version -> BlaiseVue CLI v${EXPECTED_VER}`);

    // 2. CLI channel
    const chOut = runBv(['channel']);
    assert.match(chOut, /(stable|nightly)/i, `Unexpected bv channel output: ${chOut}`);
    console.log('[PASS] 2/5 bv channel');

    // 3. Clean project scaffold + dev build + release build
    runBv(['create', 'smoke_app'], tmpBase);
    const appPkg = JSON.parse(fs.readFileSync(path.join(appDir, 'package.json'), 'utf8'));
    assert.equal(appPkg.version, '0.1.0', 'New clean project package.json version must default to 0.1.0');

    const aboutBv = fs.readFileSync(path.join(appDir, 'src', 'views', 'About.bv'), 'utf8');
    assert.ok(aboutBv.includes(`BlaiseVue v${EXPECTED_VER}.`), `About.bv missing v${EXPECTED_VER}: ${aboutBv}`);
    assert.ok(!aboutBv.includes('2.0 PRO'), 'About.bv still contains stale 2.0 PRO string');

    const appChangelog = fs.readFileSync(path.join(appDir, 'CHANGELOG.md'), 'utf8');
    assert.ok(appChangelog.includes('smoke_app'), 'Clean project CHANGELOG.md missing project name');
    assert.ok(appChangelog.includes('## [0.1.0]'), 'Clean project CHANGELOG.md missing [0.1.0] section');
    assert.ok(appChangelog.includes(`BlaiseVue v${EXPECTED_VER}`), 'Clean project CHANGELOG.md missing framework version');

    runBv(['build'], appDir);
    const devHtml = fs.readFileSync(path.join(appDir, 'dist', 'index.html'), 'utf8');
    assert.ok(
      devHtml.includes(`window.__BV_FRAMEWORK_VERSION__ = "${EXPECTED_VER}";`),
      'dist/index.html missing __BV_FRAMEWORK_VERSION__'
    );
    assert.ok(
      devHtml.includes('window.__BV_APP_VERSION__ = "0.1.0";'),
      'dist/index.html missing __BV_APP_VERSION__'
    );
    assert.ok(
      devHtml.indexOf('__BV_FRAMEWORK_VERSION__') < devHtml.indexOf('</head>'),
      'Version script must be injected inside <head> before rtl.run()'
    );
    const devMainJs = fs.readFileSync(path.join(appDir, 'dist', 'js', 'main.js'), 'utf8');
    assert.ok(devMainJs.includes('bv-app-version'), 'dist/js/main.js missing BVDevTools bv-app-version');
    assert.ok(devMainJs.includes('frameworkVersion'), 'dist/js/main.js missing frameworkVersion hook');
    assert.ok(fs.existsSync(path.join(appDir, 'dist', 'docs', 'index.html')), 'dist/docs/index.html not generated');

    runBv(['build', '--release'], appDir);
    const relHtml = fs.readFileSync(path.join(appDir, 'dist', 'index.html'), 'utf8');
    assert.ok(
      relHtml.includes(`window.__BV_FRAMEWORK_VERSION__ = "${EXPECTED_VER}";`) &&
      relHtml.includes('window.__BV_APP_VERSION__ = "0.1.0";'),
      'Release dist/index.html missing injected version globals'
    );
    assert.match(relHtml, /js\/main\.[a-f0-9]+\.js/i, 'Release dist/index.html missing hashed main.<hash>.js');
    // Rebuild dev mode so dev-server serves BVDevTools bundle cleanly
    runBv(['build'], appDir);
    console.log('[PASS] 3/5 Clean bv create + bv build + bv build --release');

    // 4. Native dev-server.js HTTP + RFC 6455 WebSocket
    const httpPort = await getFreePort();
    const wsPort = await getFreePort();
    const devSrv = spawn(process.execPath, [path.join(REPO_ROOT, 'bin', 'dev-server.js')], {
      cwd: appDir,
      env: { ...process.env, PORT: String(httpPort), WS_PORT: String(wsPort) },
      stdio: ['ignore', 'pipe', 'pipe']
    });
    children.push(devSrv);

    const devRes = await waitForHttp(`http://127.0.0.1:${httpPort}/`);
    assert.equal(devRes.status, 200, 'dev-server GET / must return 200');
    assert.ok(devRes.body.includes('__BV_HMR_CLIENT__'), 'dev-server did not inject HMR script');
    assert.ok(devRes.body.includes('__BV_FRAMEWORK_VERSION__'), 'dev-server page missing framework version');

    const devWs = await connectRawWs(wsPort, '/');
    devWs.sendPing();
    const pong = await devWs.waitForFrame((f) => f.opcode === 0xA);
    assert.equal(pong.opcode, 0xA, 'dev-server WebSocket did not answer Ping with Pong');
    devWs.close();
    await stopChild(devSrv);
    console.log('[PASS] 4/5 bin/dev-server.js HTTP + native WebSocket');

    // 5. Native studio-server.js HTTP + RFC 6455 WebSocket welcome
    const studioPort = await getFreePort();
    const studioSrv = spawn(process.execPath, [path.join(REPO_ROOT, 'bin', 'studio-server.js'), '--port', String(studioPort)], {
      cwd: appDir,
      stdio: ['ignore', 'pipe', 'pipe']
    });
    children.push(studioSrv);

    const routesRes = await waitForHttp(`http://127.0.0.1:${studioPort}/api/routes`);
    assert.equal(routesRes.status, 200, 'studio-server /api/routes must return 200');
    assert.ok(Array.isArray(JSON.parse(routesRes.body)), 'studio-server /api/routes must return JSON array');

    const studioWs = await connectRawWs(studioPort, '/ws');
    const welcomeFrame = await studioWs.waitForFrame((f) => f.opcode === 0x1);
    const welcomeJson = JSON.parse(welcomeFrame.payload.toString('utf8'));
    assert.equal(welcomeJson.type, 'studio:welcome');
    assert.ok(
      welcomeJson.payload.message.includes(`BlaiseVue Studio v${EXPECTED_VER}`),
      `Unexpected Studio welcome version: ${welcomeJson.payload.message}`
    );
    studioWs.close();
    await stopChild(studioSrv);
    console.log(`[PASS] 5/5 bin/studio-server.js HTTP + native WebSocket (v${EXPECTED_VER})`);
  } finally {
    await Promise.all(children.map(stopChild));
    fs.rmSync(tmpBase, { recursive: true, force: true });
  }
}

main().catch((err) => {
  console.error('[FAIL]', err);
  process.exit(1);
});
