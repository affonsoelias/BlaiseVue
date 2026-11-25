import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

import * as vitest from 'vitest';

// Mock environment
globalThis.window = globalThis;
if (typeof document !== 'undefined') globalThis.document = document;
if (typeof navigator !== 'undefined') globalThis.navigator = navigator;

// Expose vitest functions globally for Pascal pas2js test runner
globalThis.describe = vitest.describe;
globalThis.it = vitest.it;
globalThis.test = vitest.test;
globalThis.expect = vitest.expect;
globalThis.beforeAll = vitest.beforeAll;
globalThis.beforeEach = vitest.beforeEach;
globalThis.afterAll = vitest.afterAll;
globalThis.afterEach = vitest.afterEach;
globalThis.vi = vitest.vi;

// Resolve Pascal RTL
let candidates = [
  resolve(process.cwd(), 'rtl.js'),
  resolve(process.cwd(), 'demo-app', 'dist', 'js', 'rtl.js'),
  resolve(process.cwd(), 'dist', 'js', 'rtl.js'),
  resolve(process.cwd(), '..', 'demo-app', 'dist', 'js', 'rtl.js'),
  resolve(process.cwd(), 'vendor', 'pas2js', 'pas2js-win64-x86_64-3.2.0', 'packages', 'rtl', 'src', 'rtl.js'),
  resolve(process.cwd(), '..', 'vendor', 'pas2js', 'pas2js-win64-x86_64-3.2.0', 'packages', 'rtl', 'src', 'rtl.js'),
  resolve(process.cwd(), 'pas2js', 'pas2js-win64-x86_64-3.2.0', 'packages', 'rtl', 'src', 'rtl.js'),
  resolve(process.cwd(), '..', 'pas2js', 'pas2js-win64-x86_64-3.2.0', 'packages', 'rtl', 'src', 'rtl.js')
];

let foundRtl = null;
for (const p of candidates) {
  if (existsSync(p)) {
    foundRtl = p;
    break;
  }
}

if (foundRtl) {
  const rtlContent = readFileSync(foundRtl, 'utf8');
  (0, eval)(rtlContent);
}

// Mock BLAISE_VUE_CORE if not present
if (!globalThis.__BV_CORE__) globalThis.__BV_CORE__ = {};
