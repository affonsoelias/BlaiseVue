unit BVCompiler;

{
  BVCompiler - The Template Engine
  ---------------------------------
  This is the core compiler for BlaiseVue. It scans the DOM, compiles
  reactive templates, handles directives, and manages component life-cycles.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVComponents, BVReactivity, BVStore;

{ Mounts and compiles a specific root element with data and methods }
procedure Compile(Root, Data, Methods: JSValue);

{ Recursively visits nodes to apply directives and reactive expressions }
procedure Traverse(Node, Data, Methods: JSValue);

implementation

procedure Compile(Root, Data, Methods: JSValue);
begin
  asm window.__BV_CORE__.compile(Root, Data, Methods); end;
end;

procedure Traverse(Node, Data, Methods: JSValue);
begin
  asm window.__BV_CORE__.traverse(Node, Data, Methods); end;
end;

initialization
  asm
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    const bv = window.__BV_CORE__;
    
    // Application Entry Point: Mounts a template into the DOM
    bv.compile = function(Root, Data, Methods) {
      if (!Root || Root['bvCompiled']) return;
      Root['bvCompiled'] = true;

      // Dependency Injection: Inject Router and Global Store into the data context
      if (Data && Data.FData) {
         if (window.__BV_CORE__.router) {
            Data.FData['Router'] = window.__BV_CORE__.router;
            Data.FData['$router'] = window.__BV_CORE__.router;
         }
         if (window.__BV_PRO_STORE__) Data.FData['$store'] = window.__BV_PRO_STORE__;
      }

      console.log("[Compiler] BLAISE v2.0 ENGAGED on <" + Root.tagName + ">");
      bv.traverse(Root, Data, Methods);
      bv.trigger(Data.FData, ""); // Initial trigger for all expressions
    };

    // Safely removes an element while triggering lifecycle hooks
    bv.unmount = function(el) {
       if (!el) return;
       if (el['bvUnmount']) el['bvUnmount']();
       let children = el.querySelectorAll('*');
       for (let i = 0; i < children.length; i++) {
          if (children[i]['bvUnmount']) children[i]['bvUnmount']();
       }
       el.remove();
    };

    // Prevent redundant processing on managed nodes
    bv.markManaged = function(node) {
       if (!node) return;
       node['bvManaged'] = true;
       if (node.nodeType === 1) {
          node.querySelectorAll('*').forEach(function(c) { c['bvManaged'] = true; });
       }
    };

    // Transition Engine: Coordinates CSS animations
    bv.applyTransition = function(el, type, name, next) {
       const cls = {
         from: name + '-' + type + '-from',
         active: name + '-' + type + '-active',
         to: name + '-' + type + '-to'
       };
       el.classList.add(cls.from);
       el.classList.add(cls.active);
       
       void el.offsetHeight; // Force reflow

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
       
       setTimeout(function() {
          let s = window.getComputedStyle(el);
          let d = parseFloat(s.transitionDuration) || parseFloat(s.animationDuration);
          if (!d) onEnd();
       }, 50);
    };
    
    // Converts a reactive Proxy to a plain object
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

    // Recursive DOM Visitor: The core of the Directive Engine
    bv.traverse = function(Node, Data, Methods) {
      if (!Node || Node['bvTraversed']) return;
      
      try {
          // 1. Text Interpolation {{ expression }}
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

          // 2. Special tag: <transition>
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

          let opts = (bv.components ? bv.components[tagName] : null);
          if (tagName.indexOf('-') !== -1) {
             console.log("[Compiler] Resolving <" + tagName + ">. Found: " + !!opts);
          }

          // 3. Directive Collection
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

          // 4. Handle Refs
          if (vref && Data && Data.FData) {
              if (!Data.FData.$refs) Data.FData.$refs = {};
              Data.FData.$refs[vref] = el;
          }

          // 5. b-model directive
          if (vmodel) {
            el.removeAttribute('b-model'); el.removeAttribute('v-model');
            if (opts) {
               // Component v-model (handled logic in step 9)
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

          // 6. b-for directive
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

          // 7. b-if directive
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

          // 8. b-show directive
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

          // 9. Attribute Binding (:attr)
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

          // 10. Component Logic, Slots & Provide/Inject
          if (opts) {
            // Manage Slots
            let originalChildren = Array.from(el.childNodes);
            let root_c = document.createElement('div');
            root_c.innerHTML = opts.template;
            let rEl = root_c.firstElementChild;
            if (!rEl) { console.error("[Compiler] NO ROOT ELEMENT in template for <" + tagName + ">: " + opts.template); return; }
            rEl['bvManaged'] = true;
            console.log("[Compiler] Expanding <" + tagName + ">. Template length: " + opts.template.length);
            el.parentNode.replaceChild(rEl, el);

            let namedSlotsInChild = rEl.querySelectorAll('slot[name], b-slot[name]');
            namedSlotsInChild.forEach(function(sNode) {
               let sName = sNode.getAttribute('name');
               let foundAny = false;
               originalChildren.forEach(function(cn) {
                  if (cn.nodeType === 1 && cn.getAttribute('slot') === sName) {
                     let slotNodes = Array.from(cn.childNodes);
                     slotNodes.forEach(function(sn) {
                        bv.traverse(sn, Data, Methods); // Parent scope
                        bv.markManaged(sn);
                        sNode.parentNode.insertBefore(sn, sNode);
                        foundAny = true;
                     });
                     cn.remove();
                  }
               });
               if (!foundAny) {
                  if (sNode.innerHTML === "") sNode.remove();
               } else {
                  sNode.remove();
               }
            });

            let defaultSlot = rEl.querySelector('slot:not([name]), b-slot:not([name])');
            if (defaultSlot) {
               originalChildren.forEach(function(cn) {
                  if (cn.parentNode === el || !cn.parentNode) {
                     bv.traverse(cn, Data, Methods); // Parent scope
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
            
            // Props Initialization
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
            
            if (opts.watch) {
               Object.keys(opts.watch).forEach(function(wk) {
                  let firstRun = true;
                  bv.effect(function() {
                     let val = pRef[wk];
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
               if (opts.updated) opts.updated.call(pRef, pRef);
            });

            if (opts.mounted) opts.mounted.call(pRef, pRef);
            rEl['bvUnmount'] = function() {
               if (stopEffect && typeof stopEffect === 'function') stopEffect();
               if (opts.unmounted) opts.unmounted.call(pRef, pRef);
            };

            return;
          }

          // 11. Event Listeners (@event)
          events.forEach(function(evt) {
             (function(expr, name) {
                el.addEventListener(name, function(ev) {
                   let r = Data.Evaluate(expr, ev);
                   if (r === undefined && Methods && Methods[expr]) r = Methods[expr];
                   if (typeof r === 'function') {
                       try { r.call(Data.FData || null, Data.FData || null, ev); } 
                       catch(ex) { console.error("[Compiler] Method " + expr + " error:", ex); }
                   }
                }, false);
             })(evt.expr, evt.name);
          });

          // 12. Recursive Children
          let children = Node.childNodes;
          if (children) {
            for (let j = 0; j < children.length; j++) {
              let child = children[j];
              if (child && !child['bvManaged']) bv.traverse(child, Data, Methods);
            }
          }
          
          Node['bvTraversed'] = true;
      } catch (ex) { console.error("[Compiler] Fatal Error: ", ex); }
    };
  end;

end.