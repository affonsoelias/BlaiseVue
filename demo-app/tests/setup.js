import { readFileSync } from 'fs';
import { resolve } from 'path';

// Mock environment
globalThis.window = globalThis;
if (typeof document !== 'undefined') globalThis.document = document;
if (typeof navigator !== 'undefined') globalThis.navigator = navigator;

// Load Pascal RTL
const rtlContent = readFileSync(resolve(process.cwd(), 'rtl.js'), 'utf8');
// Use global eval to let 'var pas' and 'var rtl' become globals
(0, eval)(rtlContent);

// Mock BLAISE_VUE_CORE if not present
if (!globalThis.__BV_CORE__) globalThis.__BV_CORE__ = {};
