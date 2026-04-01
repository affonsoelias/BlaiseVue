unit BVReactivity;

{$mode objfpc}

interface

uses JS, Web, SysUtils;

procedure Effect(fn: JSValue);
procedure Track(target: JSValue; key: JSValue);
procedure Trigger(target: JSValue; key: JSValue);
function DefineReactive(target: JSValue): JSValue;
procedure DefineComputed(target: JSValue; key: JSValue; getter: JSValue);
procedure NextTick(fn: JSValue);

type
  TBlaiseData = class
  public
    FRaw: JSValue;  // Original Target
    FData: JSValue; // Reactive Proxy
    constructor Create(AData: JSValue);
    function Evaluate(AExpr: string; AEvent: JSValue = nil): JSValue;
    procedure SetValue(AKey: string; AVal: JSValue);
  end;

implementation

procedure NextTick(fn: JSValue);
begin
  asm Promise.resolve().then(function() { fn(); }); end;
end;

procedure Effect(fn: JSValue);
begin
  asm window.__BV_CORE__.effect(fn); end;
end;

procedure Track(target: JSValue; key: JSValue);
begin
  asm window.__BV_CORE__.track(target, key); end;
end;

procedure Trigger(target: JSValue; key: JSValue);
begin
  asm window.__BV_CORE__.trigger(target, key); end;
end;

function DefineReactive(target: JSValue): JSValue;
begin
  asm Result = window.__BV_CORE__.defineReactive(target); end;
end;

procedure DefineComputed(target: JSValue; key: JSValue; getter: JSValue);
begin
  asm window.__BV_CORE__.defineComputed(target, key, getter); end;
end;

{ TBlaiseData }

constructor TBlaiseData.Create(AData: JSValue);
begin
  if AData = nil then AData := TJSObject.new;
  FRaw := AData;
  FData := DefineReactive(AData);
  asm 
    if (this && this.FData && window['__BV_PRO_STORE__']) {
      this.FData['$store'] = window['__BV_PRO_STORE__'];
    }
  end;
end;

function TBlaiseData.Evaluate(AExpr: string; AEvent: JSValue = nil): JSValue;
begin
  asm
    try {
      let f = new Function('data', '$event', 'with(data) { try { return ' + AExpr + '; } catch(e) { return undefined; } }');
      return f(this.FData, AEvent);
    } catch(e) { return undefined; }
  end;
end;

procedure TBlaiseData.SetValue(AKey: string; AVal: JSValue);
begin
  asm this.FData[AKey] = AVal; end;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    const bv = window.__BV_CORE__;
    
    bv.activeEffect = null;
    bv.effectStack = [];
    bv.targetMap = new WeakMap();
    bv.proxyCache = new WeakMap();
    bv.components = {};
    
    bv.effect = function(fn) {
      const e = function() {
         if (e.stopped) return;
         try {
           bv.effectStack.push(bv.activeEffect);
           bv.activeEffect = e;
           return fn();
         } finally {
           bv.activeEffect = bv.effectStack.pop();
         }
      };
      e();
      return function() { e.stopped = true; };
    };
    
    bv.track = function(target, key) {
      if (!bv.activeEffect) return;
      let deps = bv.targetMap.get(target);
      if (!deps) { deps = new Map(); bv.targetMap.set(target, deps); }
      let depSet = deps.get(key);
      if (!depSet) { depSet = new Set(); deps.set(key, depSet); }
      depSet.add(bv.activeEffect);
    };
    
    const allProxies = new WeakSet();
    const activeEffects = new Set();
    const queue = new Set();
    let waiting = false;
    let flushCount = 0;

    function flushQueue() {
      if (flushCount > 100) {
        console.error('[BlaiseVue] Infinite reactivity loop detected. Aborting flush.');
        queue.clear();
        waiting = false;
        flushCount = 0;
        return;
      }
      
      const startTime = Date.now();
      const currentQueue = Array.from(queue);
      queue.clear();
      
      for (let i = 0; i < currentQueue.length; i++) {
        const f = currentQueue[i];
        if (activeEffects.has(f)) continue;
        activeEffects.add(f);
        try { f(); } finally { activeEffects.delete(f); }
        
        // Time slicing: if this batch is taking too long (> 16ms), 
        // defer the rest to the next microtask to keep UI responsive.
        if (Date.now() - startTime > 16) {
          for (let j = i + 1; j < currentQueue.length; j++) {
            queue.add(currentQueue[j]);
          }
          break;
        }
      }

      if (queue.size > 0) {
        flushCount++;
        Promise.resolve().then(flushQueue);
      } else {
        waiting = false;
        flushCount = 0;
      }
    }

    function queueEffect(f) {
      if (activeEffects.has(f)) return;
      queue.add(f);
      if (!waiting) {
        waiting = true;
        Promise.resolve().then(flushQueue);
      }
    }

    bv.defineReactive = function(target) {
      if (!target || typeof target !== 'object' || (target instanceof Node)) return target;
      if (allProxies.has(target)) return target;
      
      if (target instanceof Map || target instanceof Set || target instanceof Date || target instanceof RegExp) return target;
      if (bv.proxyCache.has(target)) return bv.proxyCache.get(target);
      
      let p = new Proxy(target, {
        get(t, k) {
          if (k === '__bv_raw__') return t;
          bv.track(t, k);
          if (Array.isArray(t) && ['push','pop','splice','shift','unshift'].indexOf(k) !== -1) {
             return function() {
                let res = Array.prototype[k].apply(t, arguments);
                bv.trigger(t, 'length');
                return res;
             };
          }
          let r = t[k];
          if (r === undefined && typeof k === 'string' && !k.startsWith('F')) {
             let fK = 'F' + k;
             r = t[fK] || t['F' + k.charAt(0).toUpperCase() + k.slice(1)];
             if (r !== undefined) bv.track(t, fK);
          }
          if (r !== null && typeof r === 'object' && !(r instanceof Node)) {
             // Protect private/internal properties from being proxied
             if (typeof k === 'string' && k.startsWith('_')) return r;
             return bv.defineReactive(r);
          }
          return r;
        },
        set(t, k, v) {
          if (t[k] === v) return true;
          t[k] = v;
          bv.trigger(t, k);
          return true;
        }
      });
      bv.proxyCache.set(target, p);
      allProxies.add(p);
      return p;
    };

    bv.trigger = function(target, key) {
      if (!target) return;
      let deps = bv.targetMap.get(target);
      if (!deps) return;
      
      const triggerKey = function(k) {
        let depSet = deps.get(k);
        if (depSet) {
          depSet.forEach(queueEffect);
        }
      };
      
      triggerKey(key);
      if (Array.isArray(target) && key !== 'length') triggerKey('length');
    };
    
    bv.nonReactive = function(fn) {
      const oldActive = bv.activeEffect;
      bv.activeEffect = null;
      try {
        return fn();
      } finally {
        bv.activeEffect = oldActive;
      }
    };

    bv.defineComputed = function(target, key, getter) {
      let v, dirty = true;
      const cEffect = function() {
         if (!dirty) {
           dirty = true;
           bv.trigger(target, key);
         }
      };
      
      Object.defineProperty(target, key, {
        get() {
          bv.track(target, key);
          if (dirty) {
             // Link the getter dependencies to our cEffect
             bv.effectStack.push(cEffect);
             let prev = bv.activeEffect;
             bv.activeEffect = cEffect;
             try {
               v = getter.call(target, target);
             } finally {
               bv.activeEffect = prev;
               bv.effectStack.pop();
             }
             dirty = false;
          }
          return v;
        },
        enumerable: true, configurable: true
      });
    };

    bv.initApp = function(bData, methods, computed) {
      if (computed) {
        for (let ck in computed) {
          bv.defineComputed(bData.FData, ck, computed[ck]);
        }
      }
      if (methods) {
        for (let k in methods) {
          if (k !== 'constructor') {
            bData.FData[k] = methods[k].bind(bData.FData, bData.FData);
          }
        }
      }
    };
  end;

end.
