rtl.module("System",[],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TObject",null,function () {
    this.$init = function () {
    };
    this.$final = function () {
    };
    this.AfterConstruction = function () {
    };
    this.BeforeDestruction = function () {
    };
  });
  this.Copy = function (S, Index, Size) {
    if (Index<1) Index = 1;
    return (Size>0) ? S.substring(Index-1,Index+Size-1) : "";
  };
  this.Pos = function (Search, InString) {
    return InString.indexOf(Search)+1;
  };
  this.Assigned = function (V) {
    return (V!=undefined) && (V!=null) && (!rtl.isArray(V) || (V.length > 0));
  };
  $mod.$init = function () {
    rtl.exitcode = 0;
  };
});
rtl.module("Types",["System"],function () {
  "use strict";
  var $mod = this;
},[]);
rtl.module("JS",["System","Types"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("weborworker",["System","JS","Types"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("Web",["System","Types","JS","weborworker"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("SysUtils",["System","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"Exception",pas.System.TObject,function () {
  });
  rtl.createClass(this,"EExternal",this.Exception,function () {
  });
  rtl.createClass(this,"EInvalidCast",this.Exception,function () {
  });
  rtl.createClass(this,"EIntError",this.EExternal,function () {
  });
  rtl.createClass(this,"ERangeError",this.EIntError,function () {
  });
  rtl.createClass(this,"EAbstractError",this.Exception,function () {
  });
  this.IntToStr = function (Value) {
    var Result = "";
    Result = "" + Value;
    return Result;
  };
  this.ShortMonthNames = rtl.arraySetLength(null,"",12);
  this.LongMonthNames = rtl.arraySetLength(null,"",12);
  this.ShortDayNames = rtl.arraySetLength(null,"",7);
  this.LongDayNames = rtl.arraySetLength(null,"",7);
  $mod.$implcode = function () {
    $impl.DefaultShortMonthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    $impl.DefaultLongMonthNames = ["January","February","March","April","May","June","July","August","September","October","November","December"];
    $impl.DefaultShortDayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    $impl.DefaultLongDayNames = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    $impl.DoClassRef = function (C) {
      if (C === null) ;
    };
  };
  $mod.$init = function () {
    $impl.DoClassRef($mod.EInvalidCast);
    $impl.DoClassRef($mod.EAbstractError);
    $impl.DoClassRef($mod.ERangeError);
    $mod.ShortMonthNames = $impl.DefaultShortMonthNames.slice(0);
    $mod.LongMonthNames = $impl.DefaultLongMonthNames.slice(0);
    $mod.ShortDayNames = $impl.DefaultShortDayNames.slice(0);
    $mod.LongDayNames = $impl.DefaultLongDayNames.slice(0);
  };
},[]);
rtl.module("BVReactivity",["System","JS","Web","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.DefineReactive = function (target) {
    var Result = undefined;
    Result = window.__BV_CORE__.defineReactive(target);
    return Result;
  };
  rtl.createClass(this,"TBlaiseData",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FRaw = undefined;
      this.FData = undefined;
    };
    this.Create$1 = function (AData) {
      if (AData == null) AData = new Object();
      this.FRaw = AData;
      this.FData = $mod.DefineReactive(AData);
      if (this && this.FData && window['__BV_PRO_STORE__']) {
        this.FData['$store'] = window['__BV_PRO_STORE__'];
      };
      return this;
    };
  });
  $mod.$init = function () {
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
  };
});
rtl.module("BVComponents",["System","JS","Web","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.RegisterComponent = function (Name, Options) {
    let core = window.__BV_CORE__;
    if (!core.components) core.components = {};
    core.components[Name.toLowerCase()] = Options;
  };
  this.GetComponent = function (Name) {
    var Result = null;
    let core = window.__BV_CORE__;
    if (!core.components) return null;
    Result = core.components[Name.toLowerCase()] || null;
    return Result;
  };
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    window.__BV_CORE__.getComponent = function(n) {
      let core = window.__BV_CORE__;
      return (core.components && core.components[n.toLowerCase()]) || null;
    };
  };
});
rtl.module("BVStore",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"TBVStore",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FState = undefined;
    };
    this.Create$1 = function (initialState) {
      this.FState = pas.BVReactivity.DefineReactive(initialState);
      return this;
    };
  });
  $mod.$implcode = function () {
    $impl.GStore = null;
  };
  $mod.$init = function () {
    if (!($impl.GStore != null)) $impl.GStore = $mod.TBVStore.$create("Create$1",[new Object()]);
    window["__BV_PRO_STORE__"] = $impl.GStore.FState;
  };
},[]);
rtl.module("BVCompiler",["System","JS","Web","SysUtils","BVComponents","BVReactivity","BVStore"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
        const bv = window.__BV_CORE__;
        
        bv.compile = function(Root, Data, Methods) {
          if (!Root || Root['bvCompiled']) return;
          Root['bvCompiled'] = true;
    
          // Injetar Roteador e Store no contexto do App/Pagina
          if (Data && Data.FData) {
             if (window.__BV_CORE__.router) {
                Data.FData['Router'] = window.__BV_CORE__.router;
                Data.FData['$router'] = window.__BV_CORE__.router;
             }
             if (window.__BV_PRO_STORE__) Data.FData['$store'] = window.__BV_PRO_STORE__;
          }
    
          console.log("[Compiler] BLAISE v2.0 ENGAGED on <" + Root.tagName + ">");
          bv.traverse(Root, Data, Methods);
          bv.trigger(Data.FData, ""); 
        };
    
        bv.unmount = function(el) {
           if (!el) return;
           if (el['bvUnmount']) el['bvUnmount']();
           // Recursivamente limpar filhos que possam ser componentes
           let children = el.querySelectorAll('*');
           for (let i = 0; i < children.length; i++) {
              if (children[i]['bvUnmount']) children[i]['bvUnmount']();
           }
           el.remove();
        };
    
        bv.markManaged = function(node) {
           if (!node) return;
           node['bvManaged'] = true;
           if (node.nodeType === 1) {
              node.querySelectorAll('*').forEach(function(c) { c['bvManaged'] = true; });
           }
        };
    
        bv.applyTransition = function(el, type, name, next) {
           const cls = {
             from: name + '-' + type + '-from',
             active: name + '-' + type + '-active',
             to: name + '-' + type + '-to'
           };
           el.classList.add(cls.from);
           el.classList.add(cls.active);
           
           void el.offsetHeight; // force reflow
    
           const onEnd = function(e) {
              if (e && e.target !== el) return;
              el.classList.remove(cls.to);
              el.classList.remove(cls.active);
              el.removeEventListener('transitionend', onEnd);
              el.removeEventListener('animationend', onEnd);
              if (next) next();
           };
           el.addEventListener('transitionend', onEnd);
           el.addEventListener('animationend', onEnd);
    
           requestAnimationFrame(function() {
              el.classList.remove(cls.from);
              el.classList.add(cls.to);
           });
           // Fallback for no transition
           setTimeout(function() {
              let s = window.getComputedStyle(el);
              let d = parseFloat(s.transitionDuration) || parseFloat(s.animationDuration);
              if (!d) onEnd();
           }, 50);
        };
        
        bv.unproxy = function(obj, seen = new WeakMap()) {
           if (!obj || typeof obj !== 'object' || (obj instanceof Node)) return obj;
           let target = obj['__bv_raw__'] || obj;
           if (seen.has(target)) return seen.get(target);
    
           return bv.nonReactive(function() {
              if (Array.isArray(target)) {
                 const res = [];
                 seen.set(target, res);
                 for (let i = 0; i < target.length; i++) {
                    res.push(bv.unproxy(target[i], seen));
                 }
                 return res;
              }
    
              // Handle built-ins
              if (target instanceof Date) return new Date(target);
              if (target instanceof RegExp) return new RegExp(target);
              if (target instanceof Map) return new Map(target);
              if (target instanceof Set) return new Set(target);
    
              const res = {};
              seen.set(target, res);
              for (let k in target) {
                 if (k.startsWith('$') || k.startsWith('F') || k === 'Router' || k === 'FRouter') continue;
                 const val = target[k];
                 if (val && typeof val === 'object' && !(val instanceof Node)) {
                    res[k] = bv.unproxy(val, seen);
                 } else {
                    res[k] = val;
                 }
              }
              return res;
           });
        };
    
        bv.traverse = function(Node, Data, Methods) {
          if (!Node || Node['bvTraversed']) return;
          
          try {
              // 1. Text Interpolation
              if (Node.nodeType === 3) {
                let t = Node['b-orig-tpl'] || Node.nodeValue;
                if (t && t.indexOf('{{') !== -1) {
                  if (!Node['b-orig-tpl']) Node['b-orig-tpl'] = t;
                  Node['bvTraversed'] = true; 
                  bv.effect(function() {
                    let d = (Data && Data.FData) ? Data.FData : {};
                    let res = String(Node['b-orig-tpl']).replace(/\{\{([\s\S]+?)\}\}/g, function(m, e) {
                       try {
                         let expr = e.trim();
                         let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(ex) { return undefined; } }');
                         let v = f(d);
                         return (v === undefined || v === null) ? '' : v;
                       } catch(ex) { return m; }
                    });
                    if (Node.nodeValue !== res) Node.nodeValue = res;
                  });
                }
                return;
              }
              
              if (Node.nodeType !== 1) return;
              let el = Node;
              let tagName = el.tagName.toLowerCase();
              if (tagName === 'script' || tagName === 'style') return;
    
              // 1.5. Special Wrapper: <transition>
              if (tagName === 'transition') {
                let tName = el.getAttribute('name') || 'v';
                let child = el.firstElementChild;
                if (child) {
                   child.setAttribute('bv-transition', tName);
                   el.parentNode.replaceChild(child, el);
                   bv.traverse(child, Data, Methods);
                   return;
                }
              }
    
              // 1.8. Component Discovery
              let opts = (bv.getComponent ? bv.getComponent(tagName) : null);
    
              // 2. Discover Directives
              let vmodel = null, vfor = null, vif = null, vshow = null, vref = null;
              let binds = [];
              let events = [];
              if (el.attributes) {
                for (let i = 0; i < el.attributes.length; i++) {
                   let a = el.attributes[i];
                   let n = a.name.toLowerCase();
                   if (n === 'b-model' || n === 'v-model') vmodel = a.value;
                   else if (n === 'b-for' || n === 'v-for') vfor = a.value;
                   else if (n === 'b-if' || n === 'v-if') vif = a.value;
                   else if (n === 'b-show' || n === 'v-show') vshow = a.value;
                   else if (n === 'b-ref' || n === 'ref') vref = a.value; 
                   else if (n.startsWith('@')) events.push({ name: n.substring(1), expr: a.value });
                   else if (n.startsWith(':') || n.startsWith('b-bind:')) {
                      binds.push({ name: n.replace('b-bind:', '').replace(':', ''), expr: a.value });
                   }
                }
              }
    
              // 3. Handle Refs (Safe check for Data)
              if (vref && Data && Data.FData) {
                  if (!Data.FData.$refs) Data.FData.$refs = {};
                  Data.FData.$refs[vref] = el;
              }
    
              // 4. b-model
              if (vmodel) {
                el.removeAttribute('b-model'); el.removeAttribute('v-model');
                if (opts) {
                   // Component v-model sugar: handle later during component init
                } else {
                   el.value = Data.Evaluate(vmodel) || '';
                   const sync = function() { Data.SetValue(vmodel, this.value); };
                   el.oninput = sync; el.onchange = sync; 
                   bv.effect(function() {
                     let v = Data.Evaluate(vmodel);
                     if (el.value !== v) el.value = (v === undefined || v === null) ? '' : v;
                   });
                }
              }
    
              // 5. b-for
              if (vfor) {
                el.removeAttribute('b-for'); el.removeAttribute('v-for');
                let ps = vfor.split(' in ');
                if (ps.length === 2) {
                  let itN = ps[0].trim();
                  let lExp = ps[1].trim();
                  let s = document.createElement('script'); s.type = 'text/for-start'; s['bvManaged'] = true;
                  let e = document.createElement('script'); e.type = 'text/for-end'; e['bvManaged'] = true;
                  el.parentNode.insertBefore(s, el);
                  el.parentNode.insertBefore(e, el.nextSibling);
                  el.parentNode.removeChild(el);
    
                  bv.effect(function() {
                    let n = s.nextSibling;
                    while(n && n !== e) { 
                       let res_n = n; 
                       n = n.nextSibling; 
                       bv.unmount(res_n);
                    }
                    let lst = Data.Evaluate(lExp);
                    if (Array.isArray(lst)) {
                       let dummy = lst.length;
                       lst.forEach(function(item, idx) {
                        let cl = el.cloneNode(true);
                        cl['bvManaged'] = true;
                        e.parentNode.insertBefore(cl, e);
                        let pData = Data.FData;
                        let scp = new Proxy({}, {
                          get(t, k) { if (k === itN) return item; if (k === '$index') return idx; return pData[k]; },
                          has(t, k) { return (k === itN || k === '$index' || k in pData); }
                        });
                        let ld = {
                          FData: scp,
                          Evaluate: function(expr, ev) { try { let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(e) { return undefined; } }'); return f(this.FData, ev); } catch(ex) { return undefined; } },
                          SetValue: function(k, val) { this.FData[k] = val; }
                        };
                        bv.traverse(cl, ld, Methods);
                      });
                    }
                  });
                }
                return;
              }
    
              // 6. b-if
              if (vif) {
                el.removeAttribute('b-if'); el.removeAttribute('v-if');
                let m = document.createElement('script'); m.type = 'text/if-marker'; m['bvManaged'] = true;
                el.parentNode.insertBefore(m, el);
                let active = true;
                let tName = el.getAttribute('bv-transition');
                bv.effect(function() {
                  let res = !!Data.Evaluate(vif);
                  if (res && !active) { 
                     m.parentNode.insertBefore(el, m.nextSibling); 
                     active = true; 
                     bv.traverse(el, Data, Methods); 
                     if (tName) bv.applyTransition(el, 'enter', tName);
                  }
                  else if (!res && active) { 
                     if (tName) bv.applyTransition(el, 'leave', tName, function() { bv.unmount(el); });
                     else bv.unmount(el); 
                     active = false; 
                  }
                });
                if (!active) return;
              }
    
              // 7. b-show
              if (vshow) {
                el.removeAttribute('b-show'); el.removeAttribute('v-show');
                let tName = el.getAttribute('bv-transition');
                bv.effect(function() {
                  let res = !!Data.Evaluate(vshow);
                  if (res) {
                     if (el.style.display === 'none') {
                        el.style.display = '';
                        bv.traverse(el, Data, Methods);
                        if (tName) bv.applyTransition(el, 'enter', tName);
                     }
                  } else {
                     if (el.style.display !== 'none') {
                        if (tName) bv.applyTransition(el, 'leave', tName, function() { el.style.display = 'none'; });
                        else el.style.display = 'none';
                     }
                  }
                });
              }
    
              // 8. Dynamic Binding
              binds.forEach(function(b) {
                 bv.effect(function() {
                    let v = Data.Evaluate(b.expr);
                    if (b.name === 'class') {
                      if (typeof v === 'object' && !Array.isArray(v)) {
                        Object.keys(v).forEach(function(ck) { if (v[ck]) el.classList.add(ck); else el.classList.remove(ck); });
                      } else el.className = (Array.isArray(v) ? v.join(' ') : String(v));
                    } else if (b.name === 'style') {
                      if (typeof v === 'object') Object.assign(el.style, v); else el.style.cssText = String(v);
                    } else {
                       if (v !== null && typeof v !== 'object') el.setAttribute(b.name, v);
                    }
                 });
              });
    
              // 9. Components & Slots & Provide/Inject
              if (opts) {
                // Handle Slots (Named and Default)
                let originalChildren = Array.from(el.childNodes);
                
                let root_c = document.createElement('div');
                root_c.innerHTML = opts.template;
                let rEl = root_c.firstElementChild;
                rEl['bvManaged'] = true;
                el.parentNode.replaceChild(rEl, el);
    
                let namedSlotsInChild = rEl.querySelectorAll('slot[name], b-slot[name]');
                namedSlotsInChild.forEach(function(sNode) {
                   let sName = sNode.getAttribute('name');
                   let foundAny = false;
                   originalChildren.forEach(function(cn) {
                      if (cn.nodeType === 1 && cn.getAttribute('slot') === sName) {
                         let slotNodes = Array.from(cn.childNodes);
                         slotNodes.forEach(function(sn) {
                            bv.traverse(sn, Data, Methods); // Parent context
                            bv.markManaged(sn);
                            sNode.parentNode.insertBefore(sn, sNode);
                            foundAny = true;
                         });
                         cn.remove(); // Remove the wrapper <div slot="...">
                      }
                   });
                   if (!foundAny) {
                      if (sNode.innerHTML === "") sNode.remove();
                   } else {
                      sNode.remove();
                   }
                });
    
                // Handle Default Slot (remaining content)
                let defaultSlot = rEl.querySelector('slot:not([name]), b-slot:not([name])');
                if (defaultSlot) {
                   originalChildren.forEach(function(cn) {
                      if (cn.parentNode === el || !cn.parentNode) { // Still unmanaged or original
                         bv.traverse(cn, Data, Methods); // Parent context
                         bv.markManaged(cn);
                         defaultSlot.parentNode.insertBefore(cn, defaultSlot);
                      }
                   });
                   defaultSlot.remove();
                }
    
                let dRaw = opts.data ? opts.data.call(null) : {};
                let pRef = bv.defineReactive(dRaw);
                
                if (window.__BV_CORE__.router) {
                   pRef['Router'] = window.__BV_CORE__.router;
                   pRef['$router'] = window.__BV_CORE__.router;
                }
                if (window['__BV_PRO_STORE__']) pRef['$store'] = window['__BV_PRO_STORE__'];
                
                // Collect Props from attributes
                if (el.attributes) {
                   for (let i = 0; i < el.attributes.length; i++) {
                      let a = el.attributes[i];
                      let n = a.name;
                      if (n.startsWith(':') || n.startsWith('b-bind:')) {
                         let pn = n.replace('b-bind:', '').replace(':', '');
                         bv.effect(function() { pRef[pn] = Data.Evaluate(a.value); });
                      } else if (!n.startsWith('@') && !n.startsWith('b-') && !n.startsWith('v-')) {
                         pRef[n] = a.value;
                      }
                   }
                }
                 // Component v-model implementation
                 if (vmodel) {
                    bv.effect(function() { pRef['value'] = Data.Evaluate(vmodel); });
                    pRef['$onInput'] = function(val) { Data.SetValue(vmodel, val); };
                 }
    
                 if (vref && Data && Data.FData) { Data.FData.$refs[vref] = pRef; }
                
                if (opts.inject) {
                   opts.inject.forEach(function(k) {
                      let val = (Data && Data.FData && Data.FData.$provided) ? Data.FData.$provided[k] : null;
                      if (val) pRef[k] = val;
                   });
                }
                if (opts.provide) {
                   pRef['$provided'] = Object.assign({}, (Data && Data.FData && Data.FData.$provided) || {}, opts.provide.call(pRef, pRef));
                }
    
                if (opts.computed) { Object.keys(opts.computed).forEach(function(ck) { bv.defineComputed(pRef, ck, opts.computed[ck]); }); }
                if (opts.methods) { 
                   Object.keys(opts.methods).forEach(function(k) { 
                     let rM = opts.methods[k];
                     dRaw[k] = function() { return rM.apply(this, [this, ...arguments]); }; 
                   }); 
                }
                
                // Watchers
                if (opts.watch) {
                   Object.keys(opts.watch).forEach(function(wk) {
                      let firstRun = true;
                      bv.effect(function() {
                         let val = pRef[wk]; // Track
                         if (firstRun) { firstRun = false; return; }
                         opts.watch[wk].call(pRef, pRef, val);
                      });
                   });
                }
                
                if (opts.created) opts.created.call(pRef, pRef);
                
                pRef['$emit'] = function(ev, arg) { 
                   if (ev === 'input' || ev === 'change') {
                      if (pRef['$onInput']) pRef['$onInput'](arg);
                   }
                   if (el.hasAttribute('@' + ev)) {
                      let expr = el.getAttribute('@' + ev);
                      let r = Data.Evaluate(expr, arg);
                      if (typeof r === 'function') r.call(Data.FData, Data.FData, arg);
                      else if (Methods && typeof Methods[expr] === 'function') Methods[expr].call(Data.FData, Data.FData, arg);
                   }
                };
                let cD = {
                  FData: pRef,
                  Evaluate: function(expr, ev) { 
                    try { 
                      let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(e) { return undefined; } }'); 
                      return f(this.FData, ev); 
                    } catch(ex) { return undefined; } 
                  },
                  SetValue: function(k, val) { this.FData[k] = val; }
                };
                
                bv.traverse(rEl, cD, opts.methods);
                let stopEffect = bv.effect(function() {
                   // Removed previous unproxy call that caused infinite loops
                   if (opts.updated) opts.updated.call(pRef, pRef);
                });
    
                if (opts.mounted) opts.mounted.call(pRef, pRef);
                rEl['bvUnmount'] = function() {
                   if (stopEffect && typeof stopEffect === 'function') stopEffect();
                   if (opts.unmounted) opts.unmounted.call(pRef, pRef);
                };
    
                return;
              }
    
              // 10. Events
              events.forEach(function(evt) {
                 (function(expr, name) {
                    el.addEventListener(name, function(ev) {
                       console.log("[Compiler] Event triggered: " + name + " -> " + expr, ev);
                       let r = Data.Evaluate(expr, ev);
                       if (r === undefined && Methods && Methods[expr]) r = Methods[expr];
                       if (typeof r === 'function') {
                           try { 
                             console.log("[Compiler] Executing method: " + expr);
                             r.call(Data.FData || null, Data.FData || null, ev); 
                           } catch(ex) { console.error("[Compiler] Method " + expr + " error:", ex); }
                       } else {
                          console.warn("[Compiler] Method not found or not a function: " + expr, r);
                       }
                    }, false);
                 })(evt.expr, evt.name);
              });
    
              // 11. Recursive Children Loop 
              let children = Node.childNodes;
              if (children) {
                for (let j = 0; j < children.length; j++) {
                  let child = children[j];
                  if (child && !child['bvManaged']) bv.traverse(child, Data, Methods);
                }
              }
              
              Node['bvTraversed'] = true;
          } catch (ex) { console.error("[Compiler] Error: ", ex); }
        };
  };
});
rtl.module("BVRouting",["System","JS","Web","SysUtils","BVComponents","BVCompiler"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBVRoute",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.Path = "";
      this.Component = "";
      this.BeforeEnter = undefined;
    };
    this.Create$1 = function () {
      return this;
    };
  });
  rtl.createClass(this,"TBVRouteInfo",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FullPath = "";
      this.HashPath = "";
      this.Params = undefined;
      this.Query = undefined;
      this.Name = "";
    };
    this.Create$1 = function () {
      return this;
    };
  });
  rtl.createClass(this,"TBVRouter",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FRoutes = undefined;
      this.FBeforeEach = undefined;
      this.FAppRoot = null;
      this.FRouterViewEl = null;
      this.FCurrentRoute = null;
    };
    this.$final = function () {
      this.FAppRoot = undefined;
      this.FRouterViewEl = undefined;
      this.FCurrentRoute = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.HandleHashChange = function (Event) {
      this.RenderCurrent();
    };
    this.MatchRoute = function (APath) {
      var Result = null;
      var counter = 0;
      var rItem = null;
      var rsPat = "";
      var reObj = null;
      Result = null;
      for (var $l = 0, $end = this.FRoutes.length - 1; $l <= $end; $l++) {
        counter = $l;
        rItem = rtl.getObject(this.FRoutes[counter]);
        rsPat = "^" + rItem.Path.replace(new RegExp(":[a-zA-Z_]+","g"),"([^/]+)") + "$";
        reObj = new RegExp(rsPat);
        if (reObj.test(APath)) {
          Result = rItem;
          return Result;
        };
      };
      return Result;
    };
    this.ParseParams = function (Pattern, Actual) {
      var Result = undefined;
      var finalRes = null;
      finalRes = new Object();
      let names = [];
      let nRE = /:([a-zA-Z_]+)/g;
      let m;
      while ((m = nRE.exec(Pattern)) !== null) { names.push(m[1]); }
      if (names.length > 0) {
        let vRS = '^' + Pattern.replace(/:[a-zA-Z_]+/g, '([^/]+)') + '$';
        let vRE = new RegExp(vRS);
        let vM = vRE.exec(Actual);
        if (vM) {
          for (let i=0; i<names.length; i++) {
            finalRes[names[i]] = decodeURIComponent(vM[i+1]);
          }
        }
      };
      Result = finalRes;
      return Result;
    };
    this.ParseQuery = function (AHash) {
      var Result = undefined;
      var resObj = null;
      resObj = new Object();
      let qp = AHash.indexOf('?');
      if (qp !== -1) {
        let qs = AHash.substring(qp + 1);
        qs.split('&').forEach(function(p) {
          let pts = p.split('=');
          if (pts.length > 0) resObj[decodeURIComponent(pts[0])] = decodeURIComponent(pts[1] || '');
        });
      };
      Result = resObj;
      return Result;
    };
    this.ExtractPath = function (AHash) {
      var Result = "";
      var qIdx = 0;
      qIdx = pas.System.Pos("?",AHash);
      if (qIdx > 0) {
        Result = pas.System.Copy(AHash,1,qIdx - 1)}
       else Result = AHash;
      return Result;
    };
    this.Create$1 = function (Options) {
      var routesList = null;
      var idx = 0;
      var itemObj = undefined;
      var newRoute = null;
      this.FRoutes = new Array();
      routesList = Options["routes"];
      if (routesList != null) {
        for (var $l = 0, $end = routesList.length - 1; $l <= $end; $l++) {
          idx = $l;
          itemObj = routesList[idx];
          newRoute = $mod.TBVRoute.$create("Create$1");
          newRoute.Path = "" + itemObj["path"];
          newRoute.Component = "" + itemObj["component"];
          if (itemObj.hasOwnProperty("beforeEnter")) {
            newRoute.BeforeEnter = itemObj["beforeEnter"]}
           else newRoute.BeforeEnter = null;
          this.FRoutes.push(newRoute);
        };
      };
      if (Options.hasOwnProperty("beforeEach")) {
        this.FBeforeEach = Options["beforeEach"]}
       else this.FBeforeEach = null;
      this.FCurrentRoute = $mod.TBVRouteInfo.$create("Create$1");
      window.addEventListener("hashchange",rtl.createSafeCallback(this,"HandleHashChange"));
      return this;
    };
    this.Install = function (AppRoot) {
      this.FAppRoot = AppRoot;
      this.FRouterViewEl = AppRoot.querySelector("router-view");
      if ((window.location.hash === "") || (window.location.hash === "#")) window.location.hash = "#/";
      this.RenderCurrent();
    };
    this.RenderCurrent = function () {
      var fullHash = "";
      var cleanP = "";
      var matchedRoute = null;
      var compOptions = undefined;
      var pageData = undefined;
      var pParams = undefined;
      var navEl = null;
      var rootPageEl = null;
      if (!(this.FRouterViewEl != null)) return;
      fullHash = window.location.hash;
      if (fullHash !== "") {
        fullHash = pas.System.Copy(fullHash,2,fullHash.length)}
       else fullHash = "/";
      cleanP = this.ExtractPath(fullHash);
      matchedRoute = this.MatchRoute(cleanP);
      if (!(matchedRoute != null)) {
        this.FRouterViewEl.innerHTML = "404 - Not Found";
        return;
      };
      this.FCurrentRoute.FullPath = fullHash;
      this.FCurrentRoute.HashPath = cleanP;
      this.FCurrentRoute.Params = this.ParseParams(matchedRoute.Path,cleanP);
      this.FCurrentRoute.Query = this.ParseQuery(fullHash);
      this.FCurrentRoute.Name = matchedRoute.Component;
      compOptions = pas.BVComponents.GetComponent(matchedRoute.Component);
      if (!pas.System.Assigned(compOptions)) return;
      navEl = document.createElement("div");
      navEl.innerHTML = "" + compOptions["template"];
      rootPageEl = navEl.firstElementChild;
      rootPageEl['bvManaged'] = true;
      this.FRouterViewEl.innerHTML = "";
      this.FRouterViewEl.appendChild(rootPageEl);
      if (compOptions.hasOwnProperty("data")) {
        pageData = compOptions["data"].apply(null,[])}
       else pageData = new Object();
      pParams = this.FCurrentRoute.Params;
      Object.keys(pParams).forEach(function(k) { pageData[k] = pParams[k]; });
      let q = this.FCurrentRoute.Query;
      Object.keys(q).forEach(function(k) { pageData[k] = q[k]; });
      let pRef = window.__BV_CORE__.defineReactive(pageData);
          
          // Inject $store
          if (window['__BV_PRO_STORE__']) pRef['$store'] = window['__BV_PRO_STORE__'];
          
          // Inject from Parent (App)
          if (compOptions.inject) {
             compOptions.inject.forEach(function(k) {
                let val = (window.__BV_CORE__.rootData && window.__BV_CORE__.rootData.$provided) ? window.__BV_CORE__.rootData.$provided[k] : null;
                if (val) pRef[k] = val;
             });
          }
      
          if (compOptions.computed) { 
             Object.keys(compOptions.computed).forEach(function(ck) { 
               window.__BV_CORE__.defineComputed(pRef, ck, compOptions.computed[ck]); 
             }); 
          }
          
          if (compOptions.methods) { 
             Object.keys(compOptions.methods).forEach(function(k) { 
               let rM = compOptions.methods[k];
               pageData[k] = function() { return rM.apply(this, [this, ...arguments]); }; 
             }); 
          }
      
          if (compOptions.created) compOptions.created.call(pRef);
          
          let cD = {
            FData: pRef,
            Evaluate: function(expr, ev) {
              try {
                let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(e) { return undefined; } }');
                return f(pRef, ev);
              } catch(ex) { return undefined; }
            },
            SetValue: function(k, val) { pRef[k] = val; }
          };
          
          window.__BV_CORE__.compile(rootPageEl, cD, compOptions.methods);
      
          // Lifecycle: updated
          let stopEffect = window.__BV_CORE__.effect(function() {
             let dummy = JSON.stringify(pRef);
             if (compOptions.updated) compOptions.updated.call(pRef);
          });
      
          if (compOptions.mounted) compOptions.mounted.call(pRef);
      
          // Handle Unmount cleanup for routes
          rootPageEl['bvUnmount'] = function() {
             if (stopEffect && typeof stopEffect === 'function') stopEffect();
             if (compOptions.unmounted) compOptions.unmounted.call(pRef);
          };
    };
  });
});
rtl.module("BlaiseVue",["System","JS","Web","SysUtils","BVReactivity","BVCompiler","BVRouting","BVComponents"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBlaiseVue",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FRoot = null;
      this.FData = null;
      this.FMethods = undefined;
      this.FRouter = null;
    };
    this.$final = function () {
      this.FRoot = undefined;
      this.FData = undefined;
      this.FRouter = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.InjectStyles = function () {
      console.log("[Init] injecting styles...");
      let s = document.createElement('style');
      s.innerHTML = `
        .bv-fade-enter-active { transition: opacity .5s; }
        .bv-fade-enter { opacity: 0; }
      `;
      document.head.appendChild(s);
    };
    this.Create$1 = function (AEl, AData, AMethods, AOptions) {
      var opts = undefined;
      opts = AOptions || {};
      opts.el = AEl;
      opts.data = AData;
      opts.methods = AMethods;
      this.Create$2(opts);
      return this;
    };
    this.Create$2 = function (Options) {
      var AData = undefined;
      var AMethods = undefined;
      var AComputed = undefined;
      var JS_rootID = undefined;
      var rootID = "";
      var d = undefined;
      var m = undefined;
      var c = undefined;
      console.log("[Init] Initing App...");
      this.InjectStyles();
      JS_rootID = Options.el || '#app';
      AData = Options.data || {};
      AMethods = Options.methods || null;
      AComputed = Options.computed || null;
      rootID = "" + JS_rootID;
      this.FRoot = document.querySelector(rootID);
      this.FData = pas.BVReactivity.TBlaiseData.$create("Create$1",[AData]);
      this.FMethods = AMethods;
      d = this.FData;
      m = AMethods;
      c = AComputed;
      window.__BV_CORE__.initApp(d, m, c);
      window.__BV_CORE__.rootData = d.FData;
      if (window.__BV_PRO_STORE__) d.FData.$store = window.__BV_PRO_STORE__;
      if (Options.provide) {
        d.FData.$provided = Options.provide.call(d.FData, d.FData);
      }
      if (Options.created) {
        Options.created.call(d.FData, d.FData);
      };
      console.log("[Create] Instance ready.");
      return this;
    };
    this.UseRouter = function (ARouter) {
      this.FRouter = ARouter;
      console.log("[UserRouter] Installing router..."); 
      window.__BV_CORE__.router = ARouter;
      this.FRouter.Install(this.FRoot);
      console.log("[UserRouter] Compiling template...");
      this.Compile(this.FRoot,this.FData,this.FMethods);
    };
    this.Compile = function (ARoot, AData, AMethods) {
      window.__BV_CORE__.compile(ARoot, AData, AMethods);
    };
  });
});
rtl.module("BVDevTools",["System","JS","Web","SysUtils"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    console.log('%c BlaiseVue DevTools %c v1.3.0-dev %c', 
      'background: #35495e; color: #fff; padding: 1px; border-radius: 3px 0 0 3px;', 
      'background: #41b883; color: #fff; padding: 1px; border-radius: 0 3px 3px 0;', 
      'background: transparent');
    window.__BLAISE_VUE_DEVTOOLS__ = true;
  };
});
rtl.module("uCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCard = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bv-card { border-radius: 12px; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1); margin-bottom: 20px; overflow: hidden; border: 1px solid #eee; }   .bv-card-header { background: #f8f9fa; padding: 12px 20px; border-bottom: 1px solid #eee; color: #2c3e50; font-size: 16px; }   .bv-card-body { padding: 20px; color: #444; }   .bv-card-footer { background: #fdfdfd; padding: 10px 20px; font-size: 12px; color: #95a5a6; border-top: 1px solid #f0f0f0; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="bv-card">' + '    <div class="bv-card-header">' + '       <slot name="header"><strong>{{ titulo }}</strong></slot>' + "    </div>" + '    <div class="bv-card-body">' + "       <!-- SLOT: O buraco mágico para conteúdo externo -->" + "       <slot></slot>" + "    </div>" + '    <div class="bv-card-footer">' + '       <slot name="footer"></slot>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["titulo"] = "Título do Card";
      d["temFooter"] = false;
      d["footerTexto"] = "Rodapé Padrão";
      Result = d;
      return Result;
    };
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("card",comp);
  };
});
rtl.module("uCounter",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCounter = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".counter-box { display: inline-block; border: 2px solid #42b883; border-radius: 12px; padding: 16px; margin: 8px; text-align: center; background: #f8fffe; }   .counter-label { font-weight: bold; color: #2c3e50; display: block; margin-bottom: 8px; }   .counter-controls { display: flex; align-items: center; gap: 12px; justify-content: center; }   .counter-value { font-size: 28px; font-weight: bold; color: #42b883; min-width: 40px; }   .counter-controls button { width: 36px; height: 36px; border-radius: 50%; border: 2px solid #42b883; background: white; color: #42b883; font-size: 18px; cursor: pointer; font-weight: bold; }   .counter-controls button:hover { background: #42b883; color: white; }   .counter-reset { margin-top: 8px; padding: 4px 12px; border: 1px solid #e74c3c; background: white; color: #e74c3c; border-radius: 4px; cursor: pointer; font-size: 12px; }   .counter-reset:hover { background: #e74c3c; color: white; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="counter-box">' + '    <span class="counter-label">{{ label }}</span>' + '    <div class="counter-controls">' + '      <button @click="menos">-</button>' + '      <span class="counter-value">{{ valor }}</span>' + '      <button @click="mais">+</button>' + "    </div>" + '    <button class="counter-reset" @click="zerar">Zerar</button>' + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["label"] = "Contador";
      d["valor"] = 0;
      Result = d;
      return Result;
    };
    m = new Object();
    m["mais"] = function (_this) {
      _this["valor"] = rtl.trunc(_this["valor"]) + 1;
    };
    m["menos"] = function (_this) {
      _this["valor"] = rtl.trunc(_this["valor"]) - 1;
    };
    m["zerar"] = function (_this) {
      _this["valor"] = 0;
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("counter",comp);
  };
});
rtl.module("uFormHeader",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uFormHeader = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".form-header { margin-bottom: 24px; padding: 12px; border-left: 4px solid #42b883; background-color: rgba(66, 184, 131, 0.05); border-radius: 0 8px 8px 0; cursor: pointer; transition: background 0.3s; }   .form-header:hover { background-color: rgba(66, 184, 131, 0.1); }   .form-header-title { color: inherit !important; margin: 0; font-size: 1.5rem; }   .form-header-subtitle { color: inherit !important; opacity: 0.8; margin: 4px 0 0 0; font-size: 0.9rem; }   .form-header-line { height: 2px; background: rgba(128,128,128,0.2); margin-top: 12px; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="form-header">' + '    <h2 class="form-header-title" @click="headerClick">{{ title }}</h2>' + '    <p class="form-header-subtitle">{{ subtitle }}</p>' + '    <div class="form-header-line"></div>' + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["title"] = "Formulario do Sistema";
      d["subtitle"] = "Preencha os campos abaixo para atualizar o estado reativo.";
      Result = d;
      return Result;
    };
    m = new Object();
    m["headerClick"] = function (_this) {
      _this["$emit"].call(_this,"header-clicked","Ola do Header!");
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("form-header",comp);
  };
});
rtl.module("uInfoCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uInfoCard = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".info-card { display: flex; align-items: flex-start; gap: 12px; border-left: 4px solid #3498db; background: #eaf2f8; padding: 12px 16px; border-radius: 0 8px 8px 0; margin: 10px 0; }   .info-icon { background: #3498db; color: white; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; flex-shrink: 0; }   .info-body strong { color: #2c3e50; }   .info-body p { margin: 4px 0 0; color: #555; font-size: 14px; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="info-card">' + '    <div class="info-icon">' + '       <slot name="icon">i</slot>' + "    </div>" + '    <div class="info-body">' + '       <strong><slot name="title">{{ titulo }}</slot></strong>' + "       <p><slot>{{ texto }}</slot></p>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["titulo"] = "Informacao";
      d["texto"] = "Este e um componente info-card reutilizavel.";
      Result = d;
      return Result;
    };
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("info-card",comp);
  };
});
rtl.module("uAbout",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uAbout = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".main-intro { text-align: center; background: #f8fafc; border-bottom: 2px solid #e2e8f0; }   .action-bar { margin-top: 20px; display: flex; gap: 10px; justify-content: center; }      .resource-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px; margin-top: 15px; }   .resource-item { padding: 15px; background: white; border: 1px solid #e2e8f0; border-radius: 8px; text-align: center; }   .resource-item p { font-size: 12px; margin-top: 8px; color: #64748b; }    .tech-card-pair { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }   .tech-card { padding: 20px; border-radius: 12px; color: white; display: flex; flex-direction: column; align-items: center; }   .fpc { background: linear-gradient(135deg, #1e293b 0%, #334155 100%); }   .pas2js { background: linear-gradient(135deg, #42b883 0%, #35495e 100%); }   .card-icon { font-size: 40px; margin-bottom: 10px; }    .lab-container { margin-top: 30px; border-top: 4px dashed #cbd5e1; padding-top: 20px; }   .lab-section { background: white; border-radius: 15px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); margin-bottom: 20px; }    .resource-list { list-style: none; padding: 0; margin-top: 15px; }   .resource-li { padding: 12px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; gap: 10px; }   .li-tag { font-size: 11px; padding: 2px 8px; background: #f1f5f9; border-radius: 10px; color: #64748b; margin-left: auto; }    .form-horizontal { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }   .form-control { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; }   .result-box { padding: 15px; background: #f0fdf4; border-left: 4px solid #42b883; border-radius: 4px; }   .res-text { color: #166534; font-weight: bold; margin-left: 10px; }    .alert { padding: 15px; border-radius: 8px; margin-top: 15px; font-weight: 500; }   .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }   .alert-warning { background: #fef9c3; color: #854d0e; border: 1px solid #fef08a; }    .btn-sm { padding: 6px 12px; font-size: 12px; }    @media (max-width: 600px) {     .tech-card-pair, .form-horizontal { grid-template-columns: 1fr; }   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = "  <div>" + '    <div class="section main-intro">' + '      <h1 class="section-title">Sobre o BlaiseVue Professional</h1>' + '      <p><strong>Status do Sistema:</strong> <span class="badge badge-green">Rodando via Pascal Power ⚔️</span></p>' + "      <p>Abaixo você encontra o laboratório analítico de todos os recursos implementados no framework.</p>" + "      " + '      <div class="action-bar">' + '        <button class="btn-primary" @click="toggleDemos">' + "          {{ showDemos ? '🔐 Fechar Laboratório' : '🔓 Abrir Laboratório de Recursos' }}" + "        </button>" + '        <button class="btn-outline" @click="alertaTecnologia">Versão: {{ versao }}</button>' + "      </div>" + "    </div>" + "" + "    <!-- Tabela de Recursos (Sempre Visível) -->" + '    <div class="section">' + '      <h2 class="section-title">🛡️ Arsenal Technológico</h2>' + '      <div class="resource-grid">' + '        <div class="resource-item">' + '          <span class="badge badge-blue">Reatividade</span>' + "          <p>Dependency Tracking via Proxy JS</p>" + "        </div>" + '        <div class="resource-item">' + '          <span class="badge badge-green">Compilação</span>' + "          <p>AOT Pascal para JS Otimizado</p>" + "        </div>" + '        <div class="resource-item">' + '          <span class="badge badge-orange">Routing</span>' + "          <p>SPA Router com History/Hash</p>" + "        </div>" + '        <div class="resource-item">' + '          <span class="badge badge-gray">Store</span>' + "          <p>Global State Management (TBVStore)</p>" + "        </div>" + "      </div>" + "    </div>" + "" + "    <!-- Tecnologia VIP Cards -->" + '    <div class="section engine-section">' + '       <h2 class="section-title">⚙️ Motor de Alta Performance</h2>' + '       <div class="tech-card-pair">' + '          <div class="tech-card fpc">' + '             <div class="card-icon">🏰</div>' + "             <h3>Free Pascal</h3>" + "             <p>A segurança da tipagem forte.</p>" + "          </div>" + '          <div class="tech-card pas2js">' + '             <div class="card-icon">⚡</div>' + "             <h3>Pas2JS</h3>" + "             <p>A agilidade do ecossistema Web.</p>" + "          </div>" + "       </div>" + "    </div>" + "" + "    <!-- O LABORATÓRIO (Onde a mágica acontece) -->" + '    <transition name="fade">' + '      <div v-if="showDemos" class="lab-container">' + "          <!-- 1. Iteração Reativa (b-for) -->" + '          <div class="section lab-section">' + '            <h2 class="section-title">🔬 Laboratório 01: Iteração Dinâmica (b-for)</h2>' + "            <p>Os itens abaixo são injetados diretamente do Pascal em uma <code>TJSArray</code> reativa.</p>" + '            <ul class="resource-list">' + '              <li v-for="item in tecnologias" class="resource-li">' + '                <span class="li-icon">🔹</span>' + "                <strong>{{ item.nome }}</strong> " + '                <span class="li-tag">{{ item.tipo }}</span>' + "              </li>" + "            </ul>" + '            <div style="margin-top: 15px;">' + '              <button class="btn-primary btn-sm" @click="addTec">➕ Injetar Nova Tecnologia</button>' + '              <button class="btn-danger btn-sm" @click="limparTecs">🗑️ Limpar Tudo</button>' + "            </div>" + "          </div>" + "" + "          <!-- 2. Two-Way e Computed -->" + '          <div class="section lab-section">' + '            <h2 class="section-title">📊 Laboratório 02: Computed & Two-Way</h2>' + '            <div class="form-horizontal">' + '              <div class="form-group">' + "                <label>Primeiro Nome:</label>" + '                <input type="text" b-model="firstName" class="form-control">' + "              </div>" + '              <div class="form-group">' + "                <label>Último Nome:</label>" + '                <input type="text" b-model="lastName" class="form-control">' + "              </div>" + "            </div>" + '            <div class="result-box">' + "              <strong>Resultado Computado:</strong> " + '              <span class="res-text">{{ perfilInfo }}</span>' + "            </div>" + "          </div>" + "" + "          <!-- 3. Condicional e Estado -->" + '          <div class="section lab-section">' + '            <h2 class="section-title">🎭 Laboratório 03: Estado Condicional (b-if)</h2>' + '            <div class="toggle-control">' + '              <button class="btn-outline" @click="toggleLogin">' + "                {{ logado ? '🔓 Deslogar' : '🔐 Simular Login' }}" + "              </button>" + "            </div>" + '            <div v-if="logado" class="alert alert-success">' + "               ✅ Usuário autenticado via Pascal State!" + "            </div>" + '            <div v-if="!logado" class="alert alert-warning">' + "               ⚠️ Aguardando autenticação..." + "            </div>" + "          </div>" + "      </div>" + "    </transition>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["versao"] = "2.1.0-PRO";
      d["showDemos"] = false;
      d["logado"] = false;
      d["tecnologias"] = new Array();
      d["firstName"] = "Blaise";
      d["lastName"] = "Pascal";
      Result = d;
      return Result;
    };
    m = new Object();
    m["toggleDemos"] = function (_this) {
      var o1 = null;
      var o2 = null;
      _this["showDemos"] = !!(_this["showDemos"] == false);
      if (_this["tecnologias"].length === 0) {
        o1 = new Object();
        o1["nome"] = "Object Pascal";
        o1["tipo"] = "Linguagem";
        _this["tecnologias"].push(o1);
        o2 = new Object();
        o2["nome"] = "Reatividade Proxy";
        o2["tipo"] = "Core Engine";
        _this["tecnologias"].push(o2);
      };
    };
    m["toggleLogin"] = function (_this) {
      this.logado = !this.logado; 
      console.log("[Method] logado toggle: ", this.logado);
    };
    m["addTec"] = function (_this) {
      var o = null;
      o = new Object();
      o["nome"] = "Recurso " + pas.SysUtils.IntToStr(_this["tecnologias"].length + 1);
      o["tipo"] = "Gerado Dinamicamente";
      _this["tecnologias"].push(o);
    };
    m["limparTecs"] = function (_this) {
      _this["tecnologias"].length = 0;
    };
    m["alertaTecnologia"] = function (_this) {
      window.alert("BlaiseVue v2.1.0 \\nOtimizado para alto desempenho!");
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["perfilInfo"] = function (_this) {
      var Result = undefined;
      Result = "Mestre " + ("" + _this["firstName"]) + " " + ("" + _this["lastName"]);
      return Result;
    };
    pas.BVComponents.RegisterComponent("about-page",comp);
  };
});
rtl.module("uCharts",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCharts = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".chart-dashboard {     padding: 20px;     background: #f8f9fa;     min-height: 100vh;   }   .header-card {     background: white;     padding: 30px;     border-radius: 12px;     box-shadow: 0 4px 6px rgba(0,0,0,0.05);     margin-bottom: 30px;     text-align: center;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(450px, 1fr));     gap: 20px;   }   .chart-item {     background: white;     padding: 20px;     border-radius: 12px;     box-shadow: 0 2px 8px rgba(0,0,0,0.05);     display: flex;     flex-direction: column;     align-items: center;   }   .chart-item h3 {     margin-bottom: 20px;     color: #333;     width: 100%;     border-bottom: 1px solid #eee;     padding-bottom: 10px;   }   .btn-primary {     margin-top: 15px;     background: #007bff;     color: white;     border: none;     padding: 8px 16px;     border-radius: 6px;     cursor: pointer;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="chart-dashboard">' + '    <div class="header-card">' + "      <h1>Dashboard de Gráficos (Chart.js)</h1>" + "      <p>Todos os componentes abaixo são wrappers BlaiseVue para a biblioteca Chart.js.</p>" + "    </div>" + "" + '    <div class="chart-grid">' + "      <!-- 1. Barras -->" + '      <div class="chart-item">' + "        <h3>Gráfico de Barras</h3>" + '        <c-bar :data="barData" :options="chartOptions"></c-bar>' + '        <button class="btn-primary" @click="randomizeData">Randomizar Dados</button>' + "      </div>" + "" + "      <!-- 2. Linhas -->" + '      <div class="chart-item">' + "        <h3>Gráfico de Linha</h3>" + '        <c-line :data="lineData" :options="chartOptions"></c-line>' + "      </div>" + "" + "      <!-- 3. Pizza -->" + '      <div class="chart-item">' + "        <h3>Gráfico de Pizza</h3>" + '        <c-pie :data="pieData" :options="pieOptions"></c-pie>' + "      </div>" + "" + "      <!-- 4. Rosca -->" + '      <div class="chart-item">' + "        <h3>Gráfico de Rosca (Doughnut)</h3>" + '        <c-doughnut :data="pieData" :options="pieOptions"></c-doughnut>' + "      </div>" + "" + "      <!-- 5. Área Polar -->" + '      <div class="chart-item">' + "        <h3>Área Polar</h3>" + '        <c-polar-area :data="pieData" :options="pieOptions"></c-polar-area>' + "      </div>" + "" + "      <!-- 6. Radar -->" + '      <div class="chart-item">' + "        <h3>Gráfico Radar</h3>" + '        <c-radar :data="radarData" :options="chartOptions"></c-radar>' + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["chartOptions"] = null;
      d["pieOptions"] = null;
      d["barData"] = null;
      d["lineData"] = null;
      d["pieData"] = null;
      d["radarData"] = null;
      Result = d;
      return Result;
    };
    m = new Object();
    m["initData"] = function (_this) {
      this.chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'top' },
          tooltip: { enabled: true }
        }
      };
      this.pieOptions = {
        responsive: true,
        maintainAspectRatio: false
      };
      // Dados de Exemplo
      this.barData = {
        labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
        datasets: [{
          label: 'Vendas 2025',
          data: [12, 19, 3, 5, 2, 3],
          backgroundColor: 'rgba(54, 162, 235, 0.5)',
          borderColor: 'rgb(54, 162, 235)',
          borderWidth: 1
        }]
      };
      this.lineData = {
        labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
        datasets: [{
          label: 'Usuários Ativos',
          data: [65, 59, 80, 81, 56, 55],
          fill: true,
          borderColor: 'rgb(75, 192, 192)',
          tension: 0.1
        }]
      };
      this.pieData = {
        labels: ['Red', 'Blue', 'Yellow'],
        datasets: [{
          data: [300, 50, 100],
          backgroundColor: ['rgb(255, 99, 132)', 'rgb(54, 162, 235)', 'rgb(255, 205, 86)']
        }]
      };
      this.radarData = {
        labels: ['Eating', 'Drinking', 'Sleeping', 'Designing', 'Coding', 'Cycling', 'Running'],
        datasets: [{
          label: 'Dev A',
          data: [65, 59, 90, 81, 56, 55, 40],
          fill: true,
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgb(255, 99, 132)'
        }]
      };
    };
    m["randomizeData"] = function (_this) {
      const newValues = Array.from({length: 6}, () => Math.floor(Math.random() * 20));
      this.barData = {
        ...this.barData,
        datasets: [{ ...this.barData.datasets[0], data: newValues }]
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      this.initData();
    };
    pas.BVComponents.RegisterComponent("charts-page",comp);
  };
});
rtl.module("uFormulario",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uFormulario = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = "label { display: block; margin-top: 12px; margin-bottom: 4px; color: #555; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = "  <div>" + '    <div class="section">' + "      <!-- 1. Passando props e escutando eventos -->" + "      <form-header " + '        ref="headerComp"' + '        title="Formulario Especial" ' + '        :subtitle="meuSub"' + '        @header-clicked="onHeaderClick">' + "      </form-header>" + "      " + "      <p>Este formulario demonstra o <code>b-model</code> (two-way data binding), <code>props</code>, <code>$refs</code> e <code>$emit</code>.</p>" + "      <p>Todos os campos abaixo atualizam em tempo real.</p>" + '      <button class="btn-outline" @click="mudarHeaderRef">Usar $refs no Header</button>' + "      <p>Mensagem do Header: <strong>{{ msgHeader }}</strong></p>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Dados Pessoais</h2>' + "      <label><strong>Nome:</strong></label>" + '      <input type="text" b-model="nome">' + "" + "      <label><strong>Email:</strong></label>" + '      <input type="text" b-model="email">' + "" + "      <label><strong>Cidade:</strong></label>" + '      <input type="text" b-model="cidade">' + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Preview dos Dados</h2>' + "      <table>" + "        <tr><th>Campo</th><th>Valor</th></tr>" + "        <tr><td>Nome</td><td><strong>{{ nome }}</strong></td></tr>" + "        <tr><td>Email</td><td><strong>{{ email }}</strong></td></tr>" + "        <tr><td>Cidade</td><td><strong>{{ cidade }}</strong></td></tr>" + "      </table>" + "      <hr>" + '      <button class="btn-primary" @click="preencher">Preencher Exemplo</button>' + '      <button class="btn-danger" @click="limpar">Limpar Tudo</button>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["nome"] = "";
      d["email"] = "";
      d["cidade"] = "";
      d["meuSub"] = "Este subtitulo e reativo do pai!";
      d["msgHeader"] = "(clique no titulo do header)";
      Result = d;
      return Result;
    };
    m = new Object();
    m["onHeaderClick"] = function (_this, arg) {
      _this["msgHeader"] = arg;
      _this["meuSub"] = "O subtitulo mudou reativamente via props!";
    };
    m["mudarHeaderRef"] = function (_this) {
      var refs = null;
      var header = null;
      refs = _this["$refs"];
      if (refs != null) {
        header = refs["headerComp"];
        if (header != null) header["title"] = "Titulo alterado via $refs!";
      };
    };
    m["preencher"] = function (_this) {
      _this["nome"] = "Blaise Pascal";
      _this["email"] = "blaise@pascal.dev";
      _this["cidade"] = "Clermont-Ferrand";
    };
    m["limpar"] = function (_this) {
      _this["nome"] = "";
      _this["email"] = "";
      _this["cidade"] = "";
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("formulario-page",comp);
  };
});
rtl.module("uHome",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uHome = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".home-page { padding: 20px; }   .section { margin-top: 24px; padding: 20px; border-left: 4px solid #42b883; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }   .alert-box { margin-top: 10px; padding: 15px; background: #42b883; color: white; border-radius: 8px; }      .fade-enter-active, .fade-leave-active { transition: opacity 0.5s ease; }   .fade-enter-from, .fade-leave-to { opacity: 0; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="home-page">' + "    <h2>🏠 Home: Painel de Controle (Recursos BlaiseVue)</h2>" + "    <p>{{ descricao }}</p>" + "" + "    <!-- 1. Slots & Composição -->" + "    <card>" + '      <template slot="header">🎨 Composição via Slots</template>' + "      <p>Este componente 'Card' usa slots nomeados para o cabeçalho e slots padrão para o corpo.</p>" + "    </card>" + "" + "    <!-- 2. Reatividade em Formulário -->" + '    <div class="section">' + "      <h3>✍️ Sincronização de Dados (B-Model)</h3>" + '      <input type="text" b-model="userName" placeholder="Seu nome...">' + "      <p>Bem-vindo, <b>{{ userName }}</b>!</p>" + "    </div>" + "" + "    <!-- 3. Store Global -->" + '    <div class="section">' + "      <h3>🌍 Global Store (B-Store)</h3>" + "      <p>Versão do Framework: <badge-blue>{{ $store.appVersion }}</badge-blue></p>" + "      <p>Usuário Atual: <b>{{ $store.user }}</b></p>" + "    </div>" + "" + "    <!-- 4. Transições -->" + '    <div class="section">' + "      <h3>✨ Animações & Transições</h3>" + '      <button @click="toggleVisible">Alternar Visibilidade</button>' + '      <transition name="fade">' + '        <div v-show="isVisible" class="alert-box">' + "           Efeito Fade Ativo! 👻" + "        </div>" + "      </transition>" + "    </div>" + "" + "    <!-- 5. Provide e Inject -->" + "    <info-card>" + '       <template slot="title">Injeção de Dependências (Provide/Inject)</template>' + "       O recurso de <b>Provide/Inject</b> permite que este componente receba dados de ancestrais distantes sem precisar de propriedades manuais em cada nível." + "    </info-card>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["descricao"] = "Bem-vindo ao centro de testes do Framework. Abaixo estão as funcionalidades principais.";
      d["userName"] = "Desenvolvedor Pascal";
      d["isVisible"] = true;
      Result = d;
      return Result;
    };
    m = new Object();
    m["toggleVisible"] = function (_this) {
      _this["isVisible"] = !!(_this["isVisible"] == false);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("home-page",comp);
  };
});
rtl.module("uLibBootstrap",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVRouting"],function () {
  "use strict";
  var $mod = this;
  this.Register_uLibBootstrap = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".mt-4 { margin-top: 20px; }   .mb-2 { margin-bottom: 8px; }   .mt-3 { margin-top: 15px; }   .container-fluid { padding: 0 15px; }   .lib-bootstrap-page { background: #f8fafc; padding: 25px; min-height: 100vh; }   .navbar-dark { background: #1e293b; }   .row { display: flex; flex-wrap: wrap; margin-right: -15px; margin-left: -15px; }   .col-4 { flex: 0 0 33.333333%; max-width: 33.333333%; padding: 0 15px; }   .col-8 { flex: 0 0 66.666667%; max-width: 66.666667%; padding: 0 15px; }   .col-6 { flex: 0 0 50%; max-width: 50%; padding: 0 15px; }   .gap-2 { gap: 10px; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="lib-bootstrap-page">' + "    <!-- NAVBAR INTERNA (DEMO) -->" + '    <b-navbar variant="dark" sticky="true" style="margin-bottom: 25px; border-radius: 8px;">' + '       <b-nav-item href="#/" active="true">Home</b-nav-item>' + '       <b-nav-item href="#/charts">Charts</b-nav-item>' + '       <b-nav-item href="#/pro">Pro Features</b-nav-item>' + '       <b-nav-item href="#" @click="clickNotif(\'Settings Global\')">⚙️ Configurações</b-nav-item>' + "    </b-navbar>" + "" + "    <!-- CONTENT -->" + '    <div class="container-fluid p-0">' + '      <div class="row mb-5">' + '         <div class="col-8">' + '            <h1 class="mb-2">🚀 BlaiseVue Pro UI Kit</h1>' + '            <p class="text-muted mb-4">Demonstração de 45+ componentes reativos construídos 100% em Pascal.</p>' + "            " + "            <b-breadcrumb>" + '               <b-breadcrumb-item href="#/">Home</b-breadcrumb-item>' + '               <b-breadcrumb-item href="#">Componentes</b-breadcrumb-item>' + '               <b-breadcrumb-item active="true">Bootstrap-BV</b-breadcrumb-item>' + "            </b-breadcrumb>" + "         </div>" + '         <div class="col-4 d-flex align-items-end justify-content-end p-2 gap-2">' + '            <b-btn label="Abrir Modal" variant="primary" size="lg" @click="showModal"></b-btn>' + '            <b-btn label="Toast Info" variant="info" size="lg" @click="clickNotif(\'Manual Toast Trigger\')"></b-btn>' + "         </div>" + "      </div>" + "" + '      <div class="row">' + "         <!-- LEFT COL: Feedbacks e Status -->" + '         <div class="col-4">' + '            <b-card title="📊 Status do Sistema">' + '               <div class="mb-3">' + "                  <small>Carga do Motor (Reatividade)</small>" + '                  <b-progress :value="count" variant="success" animated="true"></b-progress>' + "               </div>" + '               <div class="mb-3">' + "                  <small>Uso de Memória ($Store)</small>" + '                  <b-progress :value="35" variant="info"></b-progress>' + "               </div>" + '               <div class="d-flex gap-2">' + '                  <b-btn label="Pulsar (Count++)" variant="outline-primary" @click="count = (count + 10) % 105"></b-btn>' + '                  <b-spinner variant="primary" small="true" v-if="count > 80"></b-spinner>' + "               </div>" + "            </b-card>" + "" + '            <b-card title="📋 Centro de Notificações" class="mt-4">' + "               <b-list-group>" + '                  <b-list-group-item badge="5" badgeVariant="danger" @click="clickNotif(\'Novos E-mails\')">📨 Mensagens Entrada</b-list-group-item>' + '                  <b-list-group-item active="true" @click="clickNotif(\'Destaque\')">🌟 Destaque Semanal</b-list-group-item>' + '                  <b-list-group-item badge="OFFLINE" badgeVariant="secondary" @click="clickNotif(\'Legacy Sys\')">💾 Legado v1.0</b-list-group-item>' + '                  <b-list-group-item @click="clickNotif(\'Cloud Sync\')">☁️ Cloud Synchronization</b-list-group-item>' + "               </b-list-group>" + "            </b-card>" + "         </div>" + "" + "         <!-- RIGHT COL: Tabs / Forms / Charts -->" + '         <div class="col-8">' + '            <b-card no-body style="height: 100%;">' + '               <b-tabs @change="tabChanged">' + '                  <b-tab id="forms" title="📝 Formulários" active="true">' + '                     <div class="p-4">' + "                        <h4>Controle de Entrada</h4>" + '                        <div class="row mt-4">' + '                           <div class="col-6">' + '                              <b-input label="Identificador da UI" b-model="libName" placeholder="Ex: Turbo_Node"></b-input>' + '                              <b-form-select label="Prioridade" b-model="category" :options="catOptions"></b-form-select>' + "                           </div>" + '                           <div class="col-6">' + '                              <b-input-group label="Custo da Operação" prepend="$" append=".00" b-model="count"></b-input-group>' + '                              <b-input-group label="API Key" append="Regenerar">' + '                                 <b-input b-model="libName" readonly="true"></b-input>' + "                              </b-input-group>" + "                           </div>" + "                        </div>" + '                        <div class="alert alert-info mt-3" style="border-radius: 8px;">' + "                           <strong>Observação:</strong> Todos os campos acima usam <code>b-model</code> vinculado diretamente ao estado reativo do Pascal." + "                        </div>" + "                     </div>" + "                  </b-tab>" + "" + '                  <b-tab id="nav" title="📍 Paginação">' + '                     <div class="p-4 text-center">' + '                        <h5 class="mb-4">Navegação de Dados Atômica</h5>' + '                        <b-pagination :value="currentPage" :total="10" @input="updatePage"></b-pagination>' + '                        <p class="mt-3">Atualmente visualizando o segmento <strong>#{{ currentPage }}</strong></p>' + '                        <b-alert variant="warning" dismissible="true" class="mt-4">' + "                           Atenção: Segmento 7 contém instabilidades de rede simuladas." + "                        </b-alert>" + "                     </div>" + "                  </b-tab>" + "" + '                  <b-tab id="extras" title="🔥 Accordions">' + '                     <div class="p-4">' + '                        <b-accordion :items="faqItems" initialActiveId="q1"></b-accordion>' + "                     </div>" + "                  </b-tab>" + "               </b-tabs>" + "            </b-card>" + "         </div>" + "      </div>" + "    </div>" + "" + "    <!-- OVERLAYS -->" + '    <b-modal b-ref="mainModal" title="🔥 Confirmação System" okLabel="Processar" cancelLabel="Fechar" @ok="modalConfirm">' + "       <p>Você está prestes a processar uma atualização de estado via Pascal.</p>" + '       <div class="p-3 bg-light rounded text-center">' + "          <p>Valores Atuais:</p>" + '          <b-badge variant="info">{{ libName }}</b-badge>' + '          <b-badge variant="success">{{ count }}%</b-badge>' + "       </div>" + "    </b-modal>" + "" + '    <b-toast b-ref="mainToast" title="Notificação Global" variant="success" duration="4000">' + "       Ação executada: <strong>{{ lastAction }}</strong>" + "    </b-toast>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["count"] = 45;
      d["libName"] = "Blaise_Demo_2026";
      d["category"] = "high";
      d["currentPage"] = 1;
      d["lastAction"] = "Sistema Pronto";
      d["faqItems"] = "";
      d["catOptions"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    m["clickNotif"] = function (_this, info) {
      this.lastAction = info;
      this.$refs.mainToast.show();
    };
    m["showModal"] = function (_this) {
      this.$refs.mainModal.show();
    };
    m["modalConfirm"] = function (_this) {
      this.libName = 'SYNC_' + Date.now();
      this.lastAction = 'Modal Confirmado';
      this.$refs.mainToast.show();
    };
    m["updatePage"] = function (_this, p) {
      this.currentPage = p;
    };
    m["tabChanged"] = function (_this, id) {
      console.log("Aba alterada para: ", id);
    };
    m["voltar"] = function (_this) {
      window.location.hash = '#/';
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      this.faqItems = [
        { id: 'q1', title: 'Como funciona o Shared State?', content: 'O BlaiseVue utiliza o B-Store para gerenciar estado global de forma reativa e centralizada em Pascal.' },
        { id: 'q2', title: 'Integração Bootstrap?', content: 'Nossa biblioteca de componentes encapsula o CSS nativo em diretivas reativas amigáveis ao desenvolvedor Pascal.' },
        { id: 'q3', title: 'Otimização JIT?', content: 'O compilador gera bundles JavaScript minimalistas, resultando em tempos de carregamento instantâneos.' }
      ];
      this.catOptions = [
        { value: 'low', text: 'Prioridade Baixa' },
        { value: 'med', text: 'Prioridade Média' },
        { value: 'high', text: 'Prioridade Alta (Critical)' }
      ];
    };
    pas.BVComponents.RegisterComponent("lib-bootstrap-page",comp);
  };
});
rtl.module("uProFeatures",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uProFeatures = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".pro-features { animation: fadeIn 0.5s ease-in; }   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }    /* Transition Classes */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s, transform 0.5s; }   .fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }   .fade-enter-to, .fade-leave-from { opacity: 1; transform: translateY(0); }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="pro-features">' + '    <h2 class="section-title">🛡️ BlaiseVue 2.0 Pro: Novas Fronteiras</h2>' + "    " + "    <!-- 1. Teste de Slots -->" + '    <card titulo="Demonstração de Slot">' + '      <template slot="header">Título Customizado via Slot 🎨</template>' + "      <p>Este texto está vindo <strong>DA PÁGINA PAI</strong> e sendo injetado dentro do componente Card!</p>" + '      <button class="btn-primary" @click="testarSlot">Clique para Ver o Log</button>' + '      <template slot="footer">Rodapé customizado via Slot 🔗</template>' + "    </card>" + "" + "    <!-- 2. Teste de Global Store -->" + '    <div class="section">' + "       <h3>🧠 Memória Central ($store)</h3>" + '       <p>Versão do App: <span class="badge badge-green">{{ $store.appVersion }}</span></p>' + "       <p>Usuário Logado: <strong>{{ $store.user }}</strong></p>" + '       <button class="btn-outline" @click="mudarVersao">Atualizar Versão Global</button>' + "    </div>" + "" + "    <!-- 3. Teste de Provide/Inject -->" + '    <div class="section">' + "       <h3>🔗 Elo Sagrado (Inject)</h3>" + "       <p>Dados injetados do App Root:</p>" + "       <ul>" + "          <li>Ambiente: <strong>{{ getAmbiente().status }}</strong></li>" + "          <li>ID Interno: <strong>{{ getAmbiente().id }}</strong></li>" + "       </ul>" + "    </div>" + "" + "    <!-- 4. Teste de Lifecycle Updated -->" + '    <div class="section">' + "       <h3>🔄 Batida do Motor (Updated)</h3>" + "       <p>Contador de Reatividade: <strong>{{ contador }}</strong></p>" + '       <button class="btn-primary" @click="incrementar">Pulsar Motor</button>' + "       <p><small>(Veja o log no console para o hook 'updated')</small></p>" + "    </div>" + "" + "    <!-- 5. Teste de Transições -->" + '    <div class="section">' + "       <h3>✨ Magia Visual (Transitions)</h3>" + '       <button class="btn-outline" @click="toggleShow">Alternar Elemento</button>' + '       <transition name="fade">' + '          <div v-show="showElement" class="badge badge-orange" style="padding: 20px; display: block; margin-top: 10px;">' + "             Surpresa! Eu apareço com suavidade. 🎭" + "          </div>" + "       </transition>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["contador"] = 0;
      d["showElement"] = true;
      Result = d;
      return Result;
    };
    m = new Object();
    m["testarSlot"] = function (_this) {
      console.log("[Slot Test] O pai está falando!");
    };
    m["mudarVersao"] = function (_this) {
      _this["$store"]["appVersion"] = "2.1.0-ULTRA-PRO";
      _this["$store"]["user"] = "Pascal King 👑";
    };
    m["incrementar"] = function (_this) {
      _this["contador"] = rtl.trunc(_this["contador"]) + 1;
    };
    m["toggleShow"] = function (_this) {
      _this["showElement"] = !!(_this["showElement"] == false);
    };
    comp["methods"] = m;
    comp["updated"] = function (_this) {
      console.log("[Lifecycle] Componente UPDATED! Pulso detectado.");
    };
    comp["inject"] = new Array();
    comp["inject"].push("getAmbiente");
    pas.BVComponents.RegisterComponent("pro-features-page",comp);
  };
});
rtl.module("uShowcase",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uShowcase = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".showcase-container { max-width: 1000px; margin: 20px auto; padding: 30px; border-radius: 12px; border-left: 5px solid #2ecc71 !important; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }   .showcase-header { border-bottom: 2px solid #2ecc71; margin-bottom: 25px; padding-bottom: 10px; }   .section-card { background-color: rgba(128,128,128,0.08); padding: 20px; border-radius: 10px; margin-bottom: 30px; border-left: 4px solid #3498db; }   .icon-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 15px; margin-top: 15px; }   .icon-box { background-color: rgba(128,128,128,0.05); padding: 15px; border-radius: 8px; text-align: center; border: 1px solid rgba(128,128,128,0.1); }   .text-primary { color: #0d6efd !important; }   .text-success { color: #198754 !important; }   .text-warning { color: #ffc107 !important; }   .text-danger { color: #dc3545 !important; }   .text-info { color: #0dcaf0 !important; }   .text-secondary { color: #6c757d !important; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="showcase-container">' + '    <div class="showcase-header">' + "      <h1>Showcase: Local Assets 🛡️</h1>" + "      <p>Fonte atual: <strong>Inter & Outfit</strong> (100% Local)</p>" + "    </div>" + "" + "    <!-- Galeria de Ícones -->" + '    <div class="section-card">' + "      <h3>Galeria de Ícones (Inline Local SVGs)</h3>" + '      <div class="icon-grid">' + '        <div class="icon-box">' + '          <uBIcon name="bootstrap-fill" size="32" class="text-primary" />' + '          <div class="small mt-1">bootstrap-fill</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="check-circle" size="32" class="text-success" />' + '          <div class="small mt-1">check-circle</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="warning" size="32" class="text-warning" />' + '          <div class="small mt-1">warning</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="gear-fill" size="32" class="text-secondary" />' + '          <div class="small mt-1">gear-fill</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="heart-fill" size="32" class="text-danger" />' + '          <div class="small mt-1">heart-fill</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="weather" size="32" class="text-info" />' + '          <div class="small mt-1">weather</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="code-slash" size="32" class="text-dark" />' + '          <div class="small mt-1">code-slash</div>' + "        </div>" + '        <div class="icon-box">' + '          <uBIcon name="cpu" size="32" class="text-primary" />' + '          <div class="small mt-1">cpu</div>' + "        </div>" + "      </div>" + "    </div>" + "" + "    <!-- Seletor de Temas -->" + '    <div class="section-card">' + "      <h3>Seletor de Temas (Dynamic CSS)</h3>" + '      <div class="theme-buttons d-flex gap-2 flex-wrap">' + '        <button class="btn btn-outline-secondary" @click="handleTheme(\'default\')">Padrão</button>' + '        <button class="btn btn-primary" @click="handleTheme(\'darkly\')">Darkly</button>' + '        <button class="btn btn-success" @click="handleTheme(\'flatly\')">Flatly</button>' + '        <button class="btn btn-info" @click="handleTheme(\'cosmo\')">Cosmo</button>' + "      </div>" + '      <div class="mt-3">' + '         Tema Selecionado: <span class="badge bg-secondary">{{ currentThemeName }}</span>' + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["currentThemeName"] = "default";
      Result = d;
      return Result;
    };
    m = new Object();
    m["handleTheme"] = function (_this, ATheme) {
      var link = document.getElementById('theme-link');
      if (link) {
         if (ATheme === 'default') {
           link.href = 'css/lib/bootstrap.css';
         } else {
           link.href = 'assets/themes/' + ATheme + '.min.css';
         }
         document.body.className = 'theme-' + ATheme;
         document.head.appendChild(link);
         console.log('BlaiseVue: Tema ' + ATheme + ' aplicado.');
      };
      _this["currentThemeName"] = ATheme;
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("showcase-page",comp);
  };
});
rtl.module("uUserProfile",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uUserProfile = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = "  <div>" + '    <div class="section">' + '      <h1 class="section-title">Perfil do Usuario</h1>' + "      <p>Esta pagina demonstra <strong>Route Params</strong> e <strong>Query Strings</strong>.</p>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Dados da Rota</h2>' + "      <table>" + "        <tr><th>Informacao</th><th>Valor</th></tr>" + '        <tr><td>Param <code>:id</code></td><td><span class="badge badge-blue">{{ id }}</span></td></tr>' + '        <tr><td>Query <code>?tab</code></td><td><span class="badge badge-orange">{{ tab }}</span></td></tr>' + '        <tr><td>Query <code>?tema</code></td><td><span class="badge badge-gray">{{ tema }}</span></td></tr>' + '        <tr><td>Nível (Computed)</td><td><span class="badge" :class="userLevel == \'Premium\' ? \'badge-orange\' : \'badge-gray\'">{{ userLevel }}</span></td></tr>' + "      </table>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Editar Nome (b-model)</h2>' + '      <input type="text" b-model="nomeUsuario">' + "      <p>Nome atual: <strong>{{ nomeUsuario }}</strong></p>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Testar Outras Rotas</h2>' + '      <a href="#/user/1" class="btn-outline" style="text-decoration:none; display:inline-block;">User 1</a>' + '      <a href="#/user/100?tab=posts" class="btn-outline" style="text-decoration:none; display:inline-block;">User 100 + Posts</a>' + '      <a href="#/user/7?tab=config&tema=dark" class="btn-outline" style="text-decoration:none; display:inline-block;">User 7 + Multi Query</a>' + '      <a href="#/" class="btn-danger" style="text-decoration:none; display:inline-block;">Voltar ao Home</a>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["id"] = "?";
      d["tab"] = "(nenhum)";
      d["tema"] = "(nenhum)";
      d["nomeUsuario"] = "Usuario Padrao";
      Result = d;
      return Result;
    };
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["userLevel"] = function (_this) {
      var Result = undefined;
      if (rtl.trunc(_this["id"]) > 50) {
        Result = "Premium"}
       else Result = "Basico";
      return Result;
    };
    pas.BVComponents.RegisterComponent("user-profile-page",comp);
  };
});
rtl.module("uBAccordion",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBAccordion = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = '.accordion-button.collapsed { color: #212529; background: #fff; }   .accordion-button:not(.collapsed) { background-color: #e7f1ff; color: #0c63e4; }   .accordion-button::after {     content: "▼";     float: right;     transition: transform 0.2s;   }   .accordion-button:not(.collapsed)::after { transform: rotate(180deg); }';
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="accordion" id="accordionExample">' + '    <div class="accordion-item" b-for="item in items" style="margin-bottom: 5px; border: 1px solid #dee2e6; border-radius: 4px; overflow: hidden;">' + '      <h2 class="accordion-header" style="margin: 0;">' + '        <button class="accordion-button" type="button" @click="toggle(item.id)" ' + '                :class="{ collapsed: activeId != item.id }"' + '                style="width: 100%; text-align: left; padding: 12px 20px; border: none; background: #f8f9fa; cursor: pointer; font-weight: 500; font-size: 1rem;">' + "          {{ item.title }}" + "        </button>" + "      </h2>" + '      <div class="accordion-collapse collapse" b-show="activeId == item.id" style="padding: 20px; background: white; border-top: 1px solid #dee2e6;">' + '        <div class="accordion-body">{{ item.content }}</div>' + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["activeId"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    m["toggle"] = function (_this, id) {
      if (_this["activeId"] == id) {
        _this["activeId"] = ""}
       else _this["activeId"] = id;
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      _this["activeId"] = "" + _this["initialActiveId"];
    };
    pas.BVComponents.RegisterComponent("b-accordion",comp);
  };
});
rtl.module("uBAlert",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBAlert = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".alert { padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 5px solid transparent; }   .alert-primary { background: #cfe2ff; color: #084298; border-color: #084298; }   .alert-success { background: #d1e7dd; color: #0f5132; border-color: #0f5132; }   .alert-danger { background: #f8d7da; color: #842029; border-color: #842029; }   .alert-info { background: #cff4fc; color: #055160; border-color: #055160; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="alert" :class="\'alert-\' + variant" v-if="visible">' + '    <div class="flex justify-between align-center" style="display:flex; justify-content:space-between; align-items:center;">' + "       <div><slot></slot></div>" + '       <button v-if="dismissible" type="button" class="btn-close" @click="close" style="background:none; border:none; cursor:pointer; font-weight:bold; font-size:1.5rem; line-height:1;">&times;</button>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["visible"] = true;
      Result = d;
      return Result;
    };
    m = new Object();
    m["close"] = function (_this) {
      _this["visible"] = false;
      this.$emit('close');
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-alert",comp);
  };
});
rtl.module("uBBadge",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBBadge = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; color: white; display: inline-block; vertical-align: middle; }   .badge-primary { background: #0d6efd; }   .badge-success { background: #198754; }   .badge-danger { background: #dc3545; }   .badge-warning { background: #ffc107; color: #000; }   .badge-info { background: #0dcaf0; color: #000; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <span class="badge" :class="\'badge-\' + (variant || type || \'primary\')">' + "    <slot></slot>" + "  </span>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-badge",comp);
  };
});
rtl.module("uBBreadcrumb",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBBreadcrumb = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav aria-label="breadcrumb">' + '    <ol class="breadcrumb" style="display: flex; flex-wrap: wrap; list-style: none; padding: 0; margin-bottom: 1rem; border-radius: .25rem; background: transparent;">' + "      <slot></slot>" + "    </ol>" + "  </nav>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-breadcrumb",comp);
  };
});
rtl.module("uBBreadcrumbItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBBreadcrumbItem = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = '.breadcrumb-item + .breadcrumb-item::before { content: ""; }   .breadcrumb-item.active { font-weight: 700; color: #1e293b; }';
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <li class="breadcrumb-item" :class="{ active: active }" :aria-current="active ? \'page\' : null" style="padding-left: .5rem;">' + '    <span v-if="!active" style="margin-right: .5rem; color: #6c757d;">/</span>' + '    <a v-if="href && !active" :href="href" @click="handleClick" style="color: #0d6efd; text-decoration: none;">' + "      <slot></slot>" + "    </a>" + '    <span v-else style="color: #6c757d;">' + "      <slot></slot>" + "    </span>" + "  </li>";
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-breadcrumb-item",comp);
  };
});
rtl.module("uBBtn",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBBtn = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <button class="btn" :class="\'btn-\' + variant" @click="handleClick" style="min-width: 100px; padding: 10px 20px; font-weight: 600;">' + '    <span v-if="label">{{ label }}</span>' + '    <slot v-if="!label"></slot>' + "  </button>";
    m = new Object();
    m["handleClick"] = function (_this) {
      this.$emit('click');
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-btn",comp);
  };
});
rtl.module("uBCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBCard = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="card">' + '    <div class="card-header" b-if="title">' + '      <slot name="header">{{ title }}</slot>' + "    </div>" + '    <div class="card-body">' + "      <slot></slot>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["title"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-card",comp);
  };
});
rtl.module("uBFormSelect",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBFormSelect = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".form-select:focus { border-color: #0d6efd; box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25); outline: 0; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="mb-3">' + '    <label class="form-label" v-if="label" style="font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">{{ label }}</label>' + '    <select class="form-select" :value="value" @change="onChange" ' + '            style="width: 100%; padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; cursor: pointer; transition: border-color 0.2s; background-color: #fff;">' + '       <option b-for="opt in options" :value="opt.value">{{ opt.text }}</option>' + "    </select>" + "  </div>";
    m = new Object();
    m["onChange"] = function (_this, ev) {
      this.$emit('input', ev.target.value); this.$emit('change', ev.target.value);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-form-select",comp);
  };
});
rtl.module("uBIcon",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBIcon = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bi-icon-wrapper { vertical-align: middle; line-height: 1; display: inline-flex; }   .bi-icon-wrapper svg { display: block; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <span class="bi-icon-wrapper" :style="\'display: inline-flex; width: \' + size + \'px; height: \' + size + \'px;\'" v-html="svgContent"></span>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["name"] = "bootstrap-fill";
      d["size"] = "16";
      Result = d;
      return Result;
    };
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["svgContent"] = function (_this) {
      var Result = undefined;
      var n = this.name || 'bootstrap-fill';
      var s = this.size || '16';
      var path = '';
      if (n === 'bootstrap-fill') path = '<path d="M6.35 10.5c0 .73.73 1.23 1.58 1.23.83 0 1.55-.53 1.55-1.23 0-.64-.52-1.13-1.55-1.13-.85 0-1.58.49-1.58 1.13zm-.12-3.15c0 .63.74 1.12 1.6 1.12.83 0 1.53-.49 1.53-1.12 0-.67-.7-1.2-1.53-1.2-.86 0-1.6.53-1.6 1.2z"/><path d="M10.1 0H5.9C5 0 4 .5 3.3 1.3 2.5 2.1 2 3 2 3.9v8.2c0 .9.5 1.8 1.3 2.6.8.8 1.7 1.3 2.6 1.3h4.2c.9 0 1.8-.5 2.6-1.3.8-.8 1.3-1.7 1.3-2.6V3.9c0-.9-.5-1.8-1.3-2.6C12 .5 11.1 0 10.1 0zM7.9 12.6c-1.6 0-2.9-1.1-2.9-2.5 0-1 .6-1.8 1.5-2.2-.7-.4-1.2-1.1-1.2-2 0-1.3 1.1-2.4 2.6-2.4 1.5 0 2.6 1.1 2.6 2.4 0 .9-.5 1.6-1.2 2 1 .4 1.5 1.2 1.5 2.2 0 1.4-1.3 2.5-2.9 2.5z"/>';
      else if (n === 'check-circle') path = '<path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>';
      else if (n === 'warning') path = '<path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>';
      else if (n === 'gear-fill') path = '<path d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.168-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872l-.1-.34zM8 10.93a2.929 2.929 0 1 1 0-5.86 2.929 2.929 0 0 1 0 5.858z"/>';
      else if (n === 'heart-fill') path = '<path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/>';
      else if (n === 'weather') path = '<path d="M8 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0zM11 8a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1 0-1h1a.5.5 0 0 1 .5.5zm-4.5 0a.5.5 0 0 1 .5.5h1a.5.5 0 0 1 0-1h-1a.5.5 0 0 1-.5.5zm.586 3.586a.5.5 0 0 1 .707 0l.708.707a.5.5 0 0 1-.708.708l-.707-.708a.5.5 0 0 1 0-.707zm3.586-3.586a.5.5 0 0 1 0 .707l-.707.708a.5.5 0 0 1-.708-.708l.708-.707a.5.5 0 0 1 .707 0z"/>';
      else if (n === 'code-slash') path = '<path d="M10.478 1.647a.5.5 0 1 0-.956-.294l-4 13a.5.5 0 0 0 .956.294l4-13zM4.854 4.146a.5.5 0 0 1 0 .708L1.707 8l3.147 3.146a.5.5 0 0 1-.708.708l-3.5-3.5a.5.5 0 0 1 0-.708l3.5-3.5a.5.5 0 0 1 .708 0zm6.292 0a.5.5 0 0 0 0 .708L14.293 8l-3.147 3.146a.5.5 0 0 0 .708.708l3.5-3.5a.5.5 0 0 0 0-.708l-3.5-3.5a.5.5 0 0 0-.708 0z"/>';
      else if (n === 'cpu') path = '<path d="M5 0a.5.5 0 0 1 .5.5V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 .5-.5h.5V2h1.5a.5.5 0 0 1 .5.5v11a.5.5 0 0 1-.5.5H14v1.5a.5.5 0 0 1-.5.5h-1V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-.5.5h-.5V14H2.5a.5.5 0 0 1-.5-.5V2h-1.5a.5.5 0 0 1-.5-.5h.5V1h1.5a.5.5 0 0 1 .5-.5V0zm1 10h4V6H6v4z"/>';
      this.$Result = '<svg xmlns="http://www.w3.org/2000/svg" width="'+s+'" height="'+s+'" fill="currentColor" viewBox="0 0 16 16">' + path + '</svg>';
      return Result;
    };
    pas.BVComponents.RegisterComponent("b-icon",comp);
  };
});
rtl.module("uBInput",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBInput = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".form-control:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="mb-3">' + '    <label class="form-label" v-if="label" style="font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">{{ label }}</label>' + "    <input " + '      type="text" ' + '      class="form-control" ' + '      :placeholder="placeholder" ' + '      :value="value"' + '      @input="onInput"' + '      style="padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; width: 100%; transition: border-color 0.2s;"' + "    >" + "  </div>";
    m = new Object();
    m["onInput"] = function (_this, ev) {
      this.$emit('input', ev.target.value);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-input",comp);
  };
});
rtl.module("uBInputGroup",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBInputGroup = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="row mb-3">' + '    <label class="form-label" v-if="label" style="font-weight: 600; color: #475569; display: block; margin-bottom: 8px;">{{ label }}</label>' + '    <div class="input-group" style="display: flex; align-items: stretch; width: 100%; border: 2px solid #e2e8f0; border-radius: 8px; overflow: hidden; transition: border-color 0.2s;">' + '       <span class="input-group-text" v-if="prepend" style="padding: 10px 15px; background: #f1f5f9; border-right: 1px solid #e2e8f0; color: #64748b; font-weight: 500;">{{ prepend }}</span>' + "       <input " + '         type="text" ' + '         class="form-control flex-grow-1" ' + '         :placeholder="placeholder" ' + '         :value="value"' + '         @input="onInput"' + '         style="padding: 12px; border: none; outline: none; width: 100%;"' + "       >" + '       <span class="input-group-text" v-if="append" style="padding: 10px 15px; background: #f1f5f9; border-left: 1px solid #e2e8f0; color: #64748b; font-weight: 500;">{{ append }}</span>' + "    </div>" + "  </div>";
    m = new Object();
    m["onInput"] = function (_this, ev) {
      this.$emit('input', ev.target.value);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-input-group",comp);
  };
});
rtl.module("uBListGroup",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBListGroup = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <ul class="list-group" style="list-style: none; padding: 0; border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden;">' + "    <slot></slot>" + "  </ul>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-list-group",comp);
  };
});
rtl.module("uBListGroupItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBListGroupItem = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".list-group-item:last-child { border-bottom: none; }   .list-group-item.active { background-color: #0d6efd; color: white; border-color: #0d6efd; }   .list-group-item.active:hover { background-color: #0b5ed7; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <li class="list-group-item d-flex justify-content-between align-items-center" ' + '      :class="{ active: active }"' + '      @click="handleClick"' + '      style="padding: 12px 20px; border-bottom: 1px dashed #eee; transition: background 0.2s; cursor: pointer;">' + "    <slot></slot>" + '    <b-badge v-if="badge" :variant="badgeVariant">{{ badge }}</b-badge>' + "  </li>";
    m = new Object();
    m["handleClick"] = function (_this) {
      this.$emit('click');
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-list-group-item",comp);
  };
});
rtl.module("uBModal",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBModal = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = "@keyframes modalBounce {     0% { transform: scale(0.85); opacity: 0; }     100% { transform: scale(1); opacity: 1; }   }   .modal-dialog { transform: translateZ(0); }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="modal-backdrop fade show" v-if="visible" @click="close"' + '       style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); z-index: 1050; display: flex; align-items: center; justify-content: center;">' + "    " + '    <div class="modal-dialog" @click.stop=""' + '         style="background: white; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.25); min-width: 400px; max-width: 800px; overflow: hidden; animation: modalBounce 0.3s ease-out;">' + "      " + '      <div class="modal-header d-flex justify-content-between align-items-center" ' + '           style="padding: 15px 25px; border-bottom: 1px solid #e9ecef; background: #f8f9fa;">' + '        <h5 class="modal-title" style="margin: 0; font-weight: 700;">{{ title }}</h5>' + '        <button type="button" class="btn-close" @click="close" style="border: none; background: none; cursor: pointer; font-size: 1.5rem;">&times;</button>' + "      </div>" + "" + '      <div class="modal-body" style="padding: 25px; min-height: 100px;">' + "        <slot></slot>" + "      </div>" + "" + '      <div class="modal-footer" style="padding: 15px 25px; border-top: 1px solid #e9ecef; display: flex; justify-content: flex-end; gap: 10px;">' + '        <button v-if="cancelLabel" type="button" class="btn btn-secondary" @click="close">{{ cancelLabel }}</button>' + '        <button v-if="okLabel" type="button" class="btn btn-primary" @click="onOk">{{ okLabel }}</button>' + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["visible"] = false;
      Result = d;
      return Result;
    };
    m = new Object();
    m["show"] = function (_this) {
      this.visible = true;
    };
    m["close"] = function (_this) {
      this.visible = false;
      this.$emit('hide');
    };
    m["onOk"] = function (_this) {
      this.$emit('ok');
      this.close();
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-modal",comp);
  };
});
rtl.module("uBNavbar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBNavbar = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav class="navbar navbar-expand-lg navbar-dark bg-dark rounded-3 mb-4">' + '    <div class="container-fluid">' + '      <a class="navbar-brand" href="#">{{ brand }}</a>' + '      <div class="collapse navbar-collapse d-flex">' + '        <ul class="navbar-nav me-auto mb-2 mb-lg-0 flex-row gap-3">' + "          <slot></slot>" + "        </ul>" + "      </div>" + "    </div>" + "  </nav>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-navbar",comp);
  };
});
rtl.module("uBNavItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBNavItem = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <li class="nav-item">' + '     <a class="nav-link" style="color: inherit; text-decoration: none;" href="#" @click="$emit(\'click\')">' + "        {{ label }}" + "     </a>" + "  </li>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-nav-item",comp);
  };
});
rtl.module("uBPagination",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBPagination = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".page-link {     padding: 8px 16px;     border: 1px solid #dee2e6;     background: white;     color: #0d6efd;     cursor: pointer;     border-radius: 4px;     transition: all 0.2s;   }   .page-item.active .page-link {     background: #0d6efd;     color: white;     border-color: #0d6efd;   }   .page-item.disabled .page-link {     color: #6c757d;     pointer-events: none;     background: #f8f9fa;   }   .page-link:hover:not(.disabled) {     background: #e9ecef;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <nav aria-label="Page navigation" style="margin: 20px 0;">' + '    <ul class="pagination" style="display: flex; list-style: none; padding: 0; gap: 5px;">' + '       <li class="page-item" :class="{ disabled: value <= 1 }">' + '         <button class="page-link" @click="changePage(value - 1)">&laquo;</button>' + "       </li>" + "       " + '       <li class="page-item" b-for="p in totalPages" :class="{ active: p == value }">' + '         <button class="page-link" @click="changePage(p)">{{ p }}</button>' + "       </li>" + "" + '       <li class="page-item" :class="{ disabled: value >= totalPages }">' + '         <button class="page-link" @click="changePage(value + 1)">&raquo;</button>' + "       </li>" + "    </ul>" + "  </nav>";
    m = new Object();
    m["changePage"] = function (_this, p) {
      if ((p >= 1) && (p <= rtl.trunc(_this["total"]))) {
        this.$emit('input', p); this.$emit('change', p);
      };
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    pas.BVComponents.RegisterComponent("b-pagination",comp);
  };
});
rtl.module("uBProgress",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBProgress = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="progress" style="margin-top: 15px; margin-bottom: 20px; background: #e2e8f0; border-radius: 8px; height: 1.5rem; overflow: hidden;">' + '    <div class="progress-bar-fill" ' + '         :style="{ width: value + \'%\', backgroundColor: (variant == \'success\' ? \'#10b981\' : \'#3b82f6\') }"' + '         style="height: 100%; display: flex; align-items: center; justify-content: center; color: white; transition: width 0.4s ease-in-out; font-weight: 600; font-size: 0.8rem;">' + "       {{ value }}%" + "    </div>" + "  </div>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-progress",comp);
  };
});
rtl.module("uBSpinner",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBSpinner = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="spinner-border" :class="\'text-\' + variant" role="status" style="width: 2rem; height: 2rem;">' + '    <span class="visually-hidden">Loading...</span>' + "  </div>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-spinner",comp);
  };
});
rtl.module("uBTab",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBTab = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="tab-pane" b-show="active" v-if="render">' + "     <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["render"] = true;
      Result = d;
      return Result;
    };
    m = new Object();
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (pas.System.Assigned(_this["registerTab"])) {
        const t = { id: this.id, title: this.title };
        this.registerTab(t);
      };
    };
    comp["computed"] = new Object();
    comp["inject"] = new Array();
    comp["inject"].push("registerTab:");
    comp["inject"].push("pointer");
    comp["inject"].push("isActive:");
    comp["inject"].push("pointer");
    pas.BVComponents.RegisterComponent("b-tab",comp);
  };
});
rtl.module("uBTabs",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBTabs = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".nav-link {     display: block;     padding: 10px 20px;     color: #6c757d;     text-decoration: none;     border: 1px solid transparent;     border-bottom: 2px solid transparent;     margin-bottom: -2px;     font-weight: 500;     transition: all 0.2s;   }   .nav-link:hover { color: #0d6efd; background: #f8f9fa; }   .nav-link.active {     color: #0d6efd;     border-bottom: 2px solid #0d6efd;     background: #eef6ff;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="tabs-container">' + '    <ul class="nav nav-tabs mb-3" style="display: flex; list-style: none; border-bottom: 2px solid #dee2e6; padding: 0; gap: 10px;">' + '       <li class="nav-item" b-for="tab in tabs" @click="selectTab(tab.id)">' + '         <a class="nav-link" :class="{ active: activeTabId == tab.id }" href="#">' + "            {{ tab.title }}" + "         </a>" + "       </li>" + "    </ul>" + "" + '    <div class="tab-content" style="padding: 15px; background: white; border-radius: 4px;">' + "       <slot></slot>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["tabs"] = "";
      d["activeTabId"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    m["selectTab"] = function (_this, id) {
      this.activeTabId = id; 
      this.$emit('change', id);
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      _this["tabs"] = new Array();
    };
    comp["provide"] = function (_this) {
      var Result = null;
      Result = new Object();
      return Result;
    };
    pas.BVComponents.RegisterComponent("b-tabs",comp);
  };
});
rtl.module("uBToast",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBToast = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".toast-info { border-left-color: #0dcaf0; }   .toast-success { border-left-color: #198754; }   .toast-danger { border-left-color: #dc3545; }   .toast-warning { border-left-color: #ffc107; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1060; right: 20px; bottom: 20px;">' + '    <div class="toast show" v-if="visible" :class="\'toast-\' + variant" ' + '         style="min-width: 250px; background: white; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.15); border-left: 5px solid transparent;">' + '       <div class="toast-header" style="padding: 10px 15px; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center;">' + '          <strong class="me-auto">{{ title }}</strong>' + '          <small class="text-muted">{{ time }}</small>' + '          <button type="button" class="btn-close" @click="hide" style="border: none; background: none; cursor: pointer; font-weight: bold;">&times;</button>' + "       </div>" + '       <div class="toast-body" style="padding: 15px;">' + "          <slot></slot>" + "       </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["visible"] = false;
      Result = d;
      return Result;
    };
    m = new Object();
    m["show"] = function (_this) {
      _this["visible"] = true;
      if (rtl.trunc(_this["duration"]) > 0) {
        setTimeout(() => { this.visible = false; }, parseInt(this.duration));
      };
    };
    m["hide"] = function (_this) {
      _this["visible"] = false;
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("b-toast",comp);
  };
});
rtl.module("uCArea",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCArea = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="area" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-area",comp);
  };
});
rtl.module("uCBar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCBar = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="bar" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-bar",comp);
  };
});
rtl.module("uCBaseChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCBaseChart = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".chart-wrapper {     position: relative;     margin-bottom: 20px;     background: white;     padding: 15px;     border-radius: 8px;     box-shadow: 0 2px 10px rgba(0,0,0,0.05);   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="chart-wrapper" :style="{ width: width, height: height }">' + '    <canvas b-ref="chartCanvas"></canvas>' + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["_dummy"] = 0;
      Result = d;
      return Result;
    };
    m = new Object();
    m["initChart"] = function (_this) {
      if (this._initPending) return;
      this._initPending = true;
      requestAnimationFrame(() => {
        const canvas = this.$refs.chartCanvas;
        if (!canvas) { this._initPending = false; return; }
        const existingChart = Chart.getChart(canvas);
        if (existingChart) {
          try { existingChart.destroy(); } catch(e) {}
        }
        this._chart = null;
        if (!this.data || !this.data.datasets) { this._initPending = false; return; }
        const ctx = canvas.getContext('2d');
        if (!ctx) { this._initPending = false; return; }
        try {
          const chartData = window.__BV_CORE__.unproxy(this.data);
          const chartOptions = this.options ? window.__BV_CORE__.unproxy(this.options) : {
            responsive: true,
            maintainAspectRatio: false
          };
          this._chart = new Chart(ctx, {
            type: this.type,
            data: chartData,
            options: chartOptions
          });
        } catch (e) {
          console.error('[CBaseChart] Failed to initialize chart:', e);
        } finally {
          this._initPending = false;
        }
      });
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      this._chart = null; this._pendingData = null; this._initPending = false; this._updatePending = false;
    };
    comp["mounted"] = function (_this) {
      this.initChart();
    };
    comp["watch"] = new Object();
    comp["watch"]["data"] = function (_this, newVal) {
      this._pendingData = newVal;
      if (this._updatePending) return;
      this._updatePending = true;
      const delay = 50 + Math.random() * 150;
      setTimeout(() => {
        this._updatePending = false;
        const dataToUse = this._pendingData;
        if (this._chart && dataToUse && dataToUse.datasets) {
          try {
            const rawNewData = window.__BV_CORE__.unproxy(dataToUse);
            // Performance Optimization: Instead of replacing the whole .data object
            // we surgically update the dataset values. This allows Chart.js to 
            // perform highly optimized incremental updates and animations.
            if (this._chart.data && this._chart.data.datasets && this._chart.data.datasets[0] && rawNewData.datasets[0]) {
               this._chart.data.datasets[0].data = rawNewData.datasets[0].data;
               if (rawNewData.labels) this._chart.data.labels = rawNewData.labels;
               this._chart.update();
            } else {
               // Fallback for structure changes
               this._chart.data = rawNewData;
               this._chart.update('none');
            }
          } catch (e) {
            console.warn('[CBaseChart] Hot update failed, falling back to full re-init:', e);
            this.initChart();
          }
        } else {
          this.initChart();
        }
      }, delay);
    };
    comp["watch"]["type"] = function (_this, newVal) {
      this.initChart();
    };
    pas.BVComponents.RegisterComponent("c-base-chart",comp);
  };
});
rtl.module("uCBubble",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCBubble = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="bubble" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-bubble",comp);
  };
});
rtl.module("uCDoughnut",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCDoughnut = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="doughnut" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-doughnut",comp);
  };
});
rtl.module("uCLine",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCLine = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="line" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-line",comp);
  };
});
rtl.module("uCMixed",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCMixed = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="mixed" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-mixed",comp);
  };
});
rtl.module("uCPie",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCPie = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="pie" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-pie",comp);
  };
});
rtl.module("uCPolarArea",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCPolarArea = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="polarArea" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-polar-area",comp);
  };
});
rtl.module("uCRadar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCRadar = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="radar" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-radar",comp);
  };
});
rtl.module("uCScatter",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCScatter = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="scatter" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-scatter",comp);
  };
});
rtl.module("uCStacked",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCStacked = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <c-base-chart type="stacked" :data="data" :options="options" :width="width" :height="height"></c-base-chart>';
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("c-stacked",comp);
  };
});
rtl.module("uApp",["System","JS","Web","BlaiseVue","BVComponents","BVStore","BVCompiler","BVDevTools","BVRouting","uCard","uCounter","uFormHeader","uInfoCard","uAbout","uCharts","uFormulario","uHome","uLibBootstrap","uProFeatures","uShowcase","uUserProfile","uBAccordion","uBAlert","uBBadge","uBBreadcrumb","uBBreadcrumbItem","uBBtn","uBCard","uBFormSelect","uBIcon","uBInput","uBInputGroup","uBListGroup","uBListGroupItem","uBModal","uBNavbar","uBNavItem","uBPagination","uBProgress","uBSpinner","uBTab","uBTabs","uBToast","uCArea","uCBar","uCBaseChart","uCBubble","uCDoughnut","uCLine","uCMixed","uCPie","uCPolarArea","uCRadar","uCScatter","uCStacked"],function () {
  "use strict";
  var $mod = this;
  this.Init_App = function () {
    var data = null;
    var methods = null;
    var opts = null;
    var app = null;
    var comp = null;
    var _styleEl = null;
    var routerOpts = null;
    var routesArr = null;
    var r = null;
    var router = null;
    console.log("[Init] Initing App...");
    window.onerror = function(msg, url, line, col, error) {
      document.body.innerHTML = '<div style="background:red; color:white; padding:20px; font-family:monospace; position:fixed; top:0; left:0; width:100%; height:100%; z-index:10000;">'
        + '<h1>[BlaiseVue] ERROR</h1>'
        + '<p><b>Msg:</b> ' + msg + '</p>'
        + '<p><b>Line:</b> ' + line + ' <b>Col:</b> ' + col + '</p>'
        + '<p><b>Stack:</b><br><pre>' + (error ? error.stack : 'N/A') + '</pre></p></div>';
    };
    console.log("[Init] Injecting Styles...");
    _styleEl = document.createElement("style");
    _styleEl.textContent = '* { box-sizing: border-box; margin: 0; padding: 0; }   body { font-family: \'Segoe UI\', Arial, sans-serif; background: #f0f2f5; color: #2c3e50; }   .navbar { background: #2c3e50; padding: 12px 24px; display: flex; align-items: center; gap: 20px; flex-wrap: wrap; }   .brand { color: #42b883; font-size: 20px; }   .nav-links { display: flex; gap: 16px; }   .nav-links a { color: #ecf0f1; text-decoration: none; font-size: 14px; padding: 4px 8px; border-radius: 4px; }   .nav-links a:hover { background: rgba(255,255,255,0.1); color: #42b883; }   .nav-msg { margin-left: auto; color: #7f8c8d; font-size: 13px; }   .container { max-width: 900px; margin: 24px auto; padding: 0 20px; }   .footer-status { position: fixed; bottom: 0; left: 0; width: 100%; background: #2c3e50; color: #42b883; font-size: 11px; padding: 4px 10px; text-align: right; }   h1, h2, h3 { margin-bottom: 12px; }   .section { background: white; border-radius: 12px; padding: 24px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }   .section-title { color: #42b883; border-bottom: 2px solid #42b883; padding-bottom: 8px; margin-bottom: 16px; }   button { padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; margin: 4px; }   .btn-primary { background: #42b883; color: white; }   .btn-primary:hover { background: #38a373; }   .btn-danger { background: #e74c3c; color: white; }   .btn-outline { background: white; border: 2px solid #42b883; color: #42b883; }   .btn-outline:hover { background: #42b883; color: white; }   input[type="text"] { width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px; margin: 6px 0; }   input[type="text"]:focus { border-color: #42b883; outline: none; }   table { width: 100%; border-collapse: collapse; margin: 12px 0; }   th, td { padding: 10px 14px; border: 1px solid #eee; text-align: left; }   th { background: #f8f9fa; font-weight: 600; }   .badge { display: inline-block; padding: 3px 10px; border-radius: 12px; color: white; font-weight: bold; font-size: 13px; }   .badge-green { background: #42b883; }   .badge-blue { background: #3498db; }   .badge-orange { background: #e67e22; }   .badge-gray { background: #95a5a6; }   code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-family: \'Consolas\', monospace; font-size: 13px; }   hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }';
    document.head.appendChild(_styleEl);
    console.log("[Init] Registering uCard...");
    pas.uCard.Register_uCard();
    console.log("[Init] Registering uCounter...");
    pas.uCounter.Register_uCounter();
    console.log("[Init] Registering uFormHeader...");
    pas.uFormHeader.Register_uFormHeader();
    console.log("[Init] Registering uInfoCard...");
    pas.uInfoCard.Register_uInfoCard();
    console.log("[Init] Registering uAbout...");
    pas.uAbout.Register_uAbout();
    console.log("[Init] Registering uCharts...");
    pas.uCharts.Register_uCharts();
    console.log("[Init] Registering uFormulario...");
    pas.uFormulario.Register_uFormulario();
    console.log("[Init] Registering uHome...");
    pas.uHome.Register_uHome();
    console.log("[Init] Registering uLibBootstrap...");
    pas.uLibBootstrap.Register_uLibBootstrap();
    console.log("[Init] Registering uProFeatures...");
    pas.uProFeatures.Register_uProFeatures();
    console.log("[Init] Registering uShowcase...");
    pas.uShowcase.Register_uShowcase();
    console.log("[Init] Registering uUserProfile...");
    pas.uUserProfile.Register_uUserProfile();
    console.log("[Init] Registering uBAccordion...");
    pas.uBAccordion.Register_uBAccordion();
    console.log("[Init] Registering uBAlert...");
    pas.uBAlert.Register_uBAlert();
    console.log("[Init] Registering uBBadge...");
    pas.uBBadge.Register_uBBadge();
    console.log("[Init] Registering uBBreadcrumb...");
    pas.uBBreadcrumb.Register_uBBreadcrumb();
    console.log("[Init] Registering uBBreadcrumbItem...");
    pas.uBBreadcrumbItem.Register_uBBreadcrumbItem();
    console.log("[Init] Registering uBBtn...");
    pas.uBBtn.Register_uBBtn();
    console.log("[Init] Registering uBCard...");
    pas.uBCard.Register_uBCard();
    console.log("[Init] Registering uBFormSelect...");
    pas.uBFormSelect.Register_uBFormSelect();
    console.log("[Init] Registering uBIcon...");
    pas.uBIcon.Register_uBIcon();
    console.log("[Init] Registering uBInput...");
    pas.uBInput.Register_uBInput();
    console.log("[Init] Registering uBInputGroup...");
    pas.uBInputGroup.Register_uBInputGroup();
    console.log("[Init] Registering uBListGroup...");
    pas.uBListGroup.Register_uBListGroup();
    console.log("[Init] Registering uBListGroupItem...");
    pas.uBListGroupItem.Register_uBListGroupItem();
    console.log("[Init] Registering uBModal...");
    pas.uBModal.Register_uBModal();
    console.log("[Init] Registering uBNavbar...");
    pas.uBNavbar.Register_uBNavbar();
    console.log("[Init] Registering uBNavItem...");
    pas.uBNavItem.Register_uBNavItem();
    console.log("[Init] Registering uBPagination...");
    pas.uBPagination.Register_uBPagination();
    console.log("[Init] Registering uBProgress...");
    pas.uBProgress.Register_uBProgress();
    console.log("[Init] Registering uBSpinner...");
    pas.uBSpinner.Register_uBSpinner();
    console.log("[Init] Registering uBTab...");
    pas.uBTab.Register_uBTab();
    console.log("[Init] Registering uBTabs...");
    pas.uBTabs.Register_uBTabs();
    console.log("[Init] Registering uBToast...");
    pas.uBToast.Register_uBToast();
    console.log("[Init] Registering uCArea...");
    pas.uCArea.Register_uCArea();
    console.log("[Init] Registering uCBar...");
    pas.uCBar.Register_uCBar();
    console.log("[Init] Registering uCBaseChart...");
    pas.uCBaseChart.Register_uCBaseChart();
    console.log("[Init] Registering uCBubble...");
    pas.uCBubble.Register_uCBubble();
    console.log("[Init] Registering uCDoughnut...");
    pas.uCDoughnut.Register_uCDoughnut();
    console.log("[Init] Registering uCLine...");
    pas.uCLine.Register_uCLine();
    console.log("[Init] Registering uCMixed...");
    pas.uCMixed.Register_uCMixed();
    console.log("[Init] Registering uCPie...");
    pas.uCPie.Register_uCPie();
    console.log("[Init] Registering uCPolarArea...");
    pas.uCPolarArea.Register_uCPolarArea();
    console.log("[Init] Registering uCRadar...");
    pas.uCRadar.Register_uCRadar();
    console.log("[Init] Registering uCScatter...");
    pas.uCScatter.Register_uCScatter();
    console.log("[Init] Registering uCStacked...");
    pas.uCStacked.Register_uCStacked();
    console.log("[Init] Setting #app template...");
    document.querySelector("#app").innerHTML = "  <div>" + '    <nav class="navbar">' + '      <strong class="brand">BlaiseVue Demo 2.0</strong>' + '      <div class="nav-links">' + '        <a href="#/">Home</a>' + '        <a href="#/about">Sobre</a>' + '        <a href="#/pro">Pro Features 🛡️</a>' + '        <a href="#/form">Formulario</a>' + '        <a href="#/bootstrap">Bootstrap Lib 📦</a>' + '        <a href="#/charts" style="background: #42b883; color: white;">Charts 📊</a>' + '        <a href="#/showcase" style="background: #3498db; color: white;">Showcase ✨</a>' + "      </div>" + '      <span class="nav-msg">{{ mensagem }}</span>' + "    </nav>" + '    <div class="container">' + "      <router-view></router-view>" + "    </div>" + '    <div class="footer-status">' + "       Global Store: {{ $store.appVersion }} | Dev: {{ $store.user }}" + "    </div>" + "  </div>";
    data = new Object();
    data["mensagem"] = "BlaiseVue SPA v2.0 PRO";
    methods = new Object();
    opts = new Object();
    comp = opts;
    comp["created"] = function (_this) {
      _this["$store"]["appVersion"] = "2.0.0-PRO";
      _this["$store"]["user"] = "DevMaster 🏆";
    };
    comp["provide"] = function (_this) {
      var Result = null;
      Result = new Object();
      Result["getAmbiente"] = function () {
        var Result = null;
        Result = new Object();
        Result["id"] = 42;
        Result["status"] = "Produção 🛡️";
        return Result;
      };
      return Result;
    };
    routerOpts = new Object();
    routesArr = new Array();
    r = new Object();
    r["path"] = "/";
    r["component"] = "home-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/about";
    r["component"] = "about-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/form";
    r["component"] = "formulario-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/user/:id";
    r["component"] = "user-profile-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/pro";
    r["component"] = "pro-features-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/bootstrap";
    r["component"] = "lib-bootstrap-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/charts";
    r["component"] = "charts-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/showcase";
    r["component"] = "showcase-page";
    routesArr.push(r);
    routerOpts["routes"] = routesArr;
    router = pas.BVRouting.TBVRouter.$create("Create$1",[routerOpts]);
    app = pas.BlaiseVue.TBlaiseVue.$create("Create$1",["#app",data,methods,opts]);
    app.UseRouter(router);
  };
});
rtl.module("program",["System","uApp"],function () {
  "use strict";
  var $mod = this;
  $mod.$main = function () {
    pas.uApp.Init_App();
  };
});
