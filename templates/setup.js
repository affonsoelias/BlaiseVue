import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

// Mock environment
globalThis.window = globalThis;
if (typeof document !== 'undefined') globalThis.document = document;
if (typeof navigator !== 'undefined') globalThis.navigator = navigator;

// Find Pascal RTL
let rtlPath = resolve(process.cwd(), 'rtl.js');
if (!existsSync(rtlPath)) rtlPath = resolve(process.cwd(), 'dist', 'js', 'rtl.js');
if (!existsSync(rtlPath)) rtlPath = resolve(process.cwd(), '..', 'demo-app', 'dist', 'js', 'rtl.js');
if (!existsSync(rtlPath)) rtlPath = resolve(process.cwd(), '..', 'vendor', 'pas2js', 'pas2js-win64-x86_64-3.2.0', 'packages', 'rtl', 'src', 'rtl.js');
if (!existsSync(rtlPath)) rtlPath = resolve(process.cwd(), '..', 'pas2js', 'pas2js-win64-x86_64-3.2.0', 'packages', 'rtl', 'src', 'rtl.js');

if (existsSync(rtlPath)) {
  const rtlContent = readFileSync(rtlPath, 'utf8');
  (0, eval)(rtlContent);
}

// Mock BLAISE_VUE_CORE if not present
if (!globalThis.__BV_CORE__) globalThis.__BV_CORE__ = {};
