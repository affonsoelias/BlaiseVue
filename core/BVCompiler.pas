unit BVCompiler;

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVComponents, BVReactivity, BVStore;

procedure Compile(Root, Data, Methods: JSValue);
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
  end;

end.