# ⚡ WebAssembly Acceleration Engine (`BVWasm`)

BlaiseVue provides native support for **WebAssembly (Wasm)**, enabling high-performance computation directly in the browser with near-native binary execution speeds (2x to 10x faster than pure JavaScript).

---

## 🌟 Why WebAssembly in BlaiseVue?

While the standard Pas2JS pipeline generates clean, optimized JavaScript, certain client-side operations benefit immensely from direct binary execution:
- High-frequency mathematical computations and cryptography.
- Complex data sorting, array transformations, and large dataset filtering (100,000+ records).
- Physics simulations, canvas graphics, and image processing.

BlaiseVue bridges Object Pascal to WebAssembly via `core/BVWasm.pas` and provides the reactive `$wasm` helper across all templates and component scopes.

---

## 🚀 The `$wasm` API

The `$wasm` helper is automatically injected into all component contexts and is accessible globally via `window.__BV_CORE__.wasm`.

### 1. `TBVWasm.IsSupported: Boolean`
Checks if the current browser or runtime environment supports WebAssembly:
```pascal
if TBVWasm.IsSupported then
  WriteLn('WebAssembly is ready!');
```

### 2. `TBVWasm.Call(ModuleName, FuncName, Args): JSValue`
Executes an exported Wasm function:
```pascal
var
  Answer: Integer;
begin
  Answer := Integer(TBVWasm.Call('math', 'add', TJSArray.new(15, 27))); // 42
end;
```

In `.bv` templates:
```html
<template>
  <div class="card">
    <h3>Accelerated Fibonacci</h3>
    <p>Fib(15) = {{ $wasm.call('math', 'fib', 15) }}</p>
    <p>Is 97 Prime? {{ $wasm.call('math', 'isPrime', 97) ? 'Yes' : 'No' }}</p>
  </div>
</template>
```

### 3. `TBVWasm.Benchmark(ModuleName, FuncName, Args, Iterations): JSValue`
Runs execution timing comparisons between WebAssembly and equivalent JavaScript:
```pascal
var
  Stats: JSValue;
begin
  Stats := TBVWasm.Benchmark('math', 'fib', 18, 10000);
  {
    Returns:
    {
      module: 'math',
      func: 'fib',
      iterations: 10000,
      wasmDurationMs: 3.8,
      jsDurationMs: 18.2,
      speedup: '4.8x',
      result: 2584
    }
  }
end;
```

---

## 🛠️ CLI Benchmarking (`bv wasm`)

You can inspect and benchmark the WebAssembly subsystem directly from the CLI:

```bash
# Check Wasm target and loaded modules
bv wasm info

# Run automated speedup benchmarks
bv wasm benchmark
```

Output:
```text
=== BlaiseVue WebAssembly Engine ===
Running WebAssembly vs JavaScript benchmark...
  Module: math.fib(18)
  Iterations: 10,000
  Results:
    - JS Duration:   ~18.2 ms
    - Wasm Duration: ~3.8 ms
    - Speedup:       4.8x faster!
```
