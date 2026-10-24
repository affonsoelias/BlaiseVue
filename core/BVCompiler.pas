unit BVCompiler;

{
  BVCompiler - The Template Engine
  ---------------------------------
  This is the core compiler for BlaiseVue. It scans the DOM, compiles
  reactive templates, handles directives, and manages component life-cycles.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVComponents, BVReactivity, BVStore, BVValidation, BVI18n, BVTheme, BVWasm, BVClient, BVAuth;

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
    
    if (!bv.setDeepValue) {
      bv.setDeepValue = function(target, path, val) {
        if (!target || !path) return;
        if (typeof path === 'string' && path.indexOf('.') > -1) {
          let parts = path.split('.');
          let curr = target;
          for (let i = 0; i < parts.length - 1; i++) {
            let part = parts[i];
            if (!curr[part] || typeof curr[part] !== 'object') {
              curr[part] = {};
            }
            curr = curr[part];
          }
          curr[parts[parts.length - 1]] = val;
        } else {
          target[path] = val;
        }
      };
    }


    if (!bv.getDeepValue) {
      bv.getDeepValue = function(target, path) {
        if (target == null || !path) return undefined;
        if (typeof path === 'string' && path.indexOf('.') > -1) {
          let parts = path.split('.');
          let curr = target;
          for (let i = 0; i < parts.length; i++) {
            if (curr == null) return undefined;
            curr = curr[parts[i]];
          }
          return curr;
        }
        return target[path];
      };
    }

    if (!bv.evalCache) bv.evalCache = Object.create(null);

    // =========================================================================
    //  BLAISEVUE 4.4: ZERO-WITH NATIVE FAST EXPRESSION EVALUATOR & CSP ENGINE
    // =========================================================================
    if (!bv.fastEval) {
      function bvTokenize(str) {
        let tokens = [];
        let i = 0;
        let len = str.length;

        while (i < len) {
          let ch = str[i];
          if (ch <= ' ') { i++; continue; }

          if (ch === '/' && str[i + 1] === '/') {
            i += 2;
            while (i < len && str[i] !== '\n') i++;
            continue;
          }

          if ((ch >= '0' && ch <= '9') || (ch === '.' && str[i + 1] >= '0' && str[i + 1] <= '9')) {
            let start = i;
            while (i < len && ((str[i] >= '0' && str[i] <= '9') || str[i] === '.' || str[i] === 'e' || str[i] === 'E' || (str[i] === '-' && (str[i-1] === 'e' || str[i-1] === 'E')))) {
              i++;
            }
            tokens.push({ type: 'num', value: parseFloat(str.slice(start, i)) });
            continue;
          }

          if (ch === '\'' || ch === '"' || ch === '`') {
            let quote = ch;
            let val = '';
            i++;
            while (i < len && str[i] !== quote) {
              if (str[i] === '\\' && i + 1 < len) {
                let next = str[++i];
                if (next === 'n') val += '\n';
                else if (next === 't') val += '\t';
                else if (next === 'r') val += '\r';
                else val += next;
              } else {
                val += str[i];
              }
              i++;
            }
            i++;
            tokens.push({ type: 'str', value: val });
            continue;
          }

          let op3 = str.slice(i, i + 3);
          if (op3 === '===' || op3 === '!==' || op3 === '>>>') {
            tokens.push({ type: 'op', value: op3 });
            i += 3;
            continue;
          }

          let op2 = str.slice(i, i + 2);
          if (['==', '!=', '<=', '>=', '&&', '||', '??', '++', '--', '+=', '-=', '*=', '/='].indexOf(op2) !== -1) {
            tokens.push({ type: 'op', value: op2 });
            i += 2;
            continue;
          }

          if ('+-*/%<>=!&|^~?:,;()[]{}'.indexOf(ch) !== -1) {
            tokens.push({ type: 'op', value: ch });
            i++;
            continue;
          }

          if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch === '_' || ch === '$') {
            let start = i;
            while (i < len && ((str[i] >= 'a' && str[i] <= 'z') || (str[i] >= 'A' && str[i] <= 'Z') || (str[i] >= '0' && str[i] <= '9') || str[i] === '_' || str[i] === '$')) {
              i++;
            }
            let word = str.slice(start, i);
            if (word === 'true') tokens.push({ type: 'lit', value: true });
            else if (word === 'false') tokens.push({ type: 'lit', value: false });
            else if (word === 'null') tokens.push({ type: 'lit', value: null });
            else if (word === 'undefined') tokens.push({ type: 'lit', value: undefined });
            else if (word === 'typeof' || word === 'instanceof' || word === 'in') tokens.push({ type: 'op', value: word });
            else tokens.push({ type: 'id', value: word });
            continue;
          }

          if (ch === '.') {
            tokens.push({ type: 'op', value: '.' });
            i++;
            continue;
          }

          i++;
        }

        tokens.push({ type: 'eof', value: '' });
        return tokens;
      }

      function bvParseTokens(tokens) {
        let idx = 0;
        function peek() { return tokens[idx] || { type: 'eof', value: '' }; }
        function next() { return tokens[idx++]; }
        function match(val) {
          if (peek().value === val) return next();
          return null;
        }

        function parseSequence() {
          let expr = parseAssignment();
          while (match(';')) {
            let nextExpr = parseAssignment();
            let prevExpr = expr;
            expr = function(scope, ev) {
              if (prevExpr) prevExpr(scope, ev);
              return nextExpr ? nextExpr(scope, ev) : undefined;
            };
          }
          return expr;
        }

        function parseAssignment() {
          let left = parseTernary();
          if (!left) return null;

          let op = peek();
          if (op.type === 'op' && (op.value === '=' || op.value === '+=' || op.value === '-=')) {
            next();
            let right = parseAssignment();
            if (left.isIdentifier) {
              let idName = left.idName;
              return function(scope, ev) {
                let rVal = right ? right(scope, ev) : undefined;
                let target = (scope && scope.FData) ? scope.FData : scope;
                if (op.value === '=') target[idName] = rVal;
                else if (op.value === '+=') target[idName] = (target[idName] || 0) + rVal;
                else if (op.value === '-=') target[idName] = (target[idName] || 0) - rVal;
                return target[idName];
              };
            } else if (left.isMember) {
              let objFn = left.objFn;
              let propFn = left.propFn;
              return function(scope, ev) {
                let obj = objFn(scope, ev);
                let prop = propFn(scope, ev);
                let rVal = right ? right(scope, ev) : undefined;
                if (obj != null) {
                  if (op.value === '=') obj[prop] = rVal;
                  else if (op.value === '+=') obj[prop] = (obj[prop] || 0) + rVal;
                  else if (op.value === '-=') obj[prop] = (obj[prop] || 0) - rVal;
                  return obj[prop];
                }
                return undefined;
              };
            }
          }
          return left;
        }

        function parseTernary() {
          let cond = parseLogicalOr();
          if (match('?')) {
            let trueBranch = parseAssignment();
            match(':');
            let falseBranch = parseAssignment();
            return function(scope, ev) {
              return cond(scope, ev) ? (trueBranch ? trueBranch(scope, ev) : undefined) : (falseBranch ? falseBranch(scope, ev) : undefined);
            };
          }
          return cond;
        }

        function parseLogicalOr() {
          let left = parseLogicalAnd();
          while (peek().value === '||' || peek().value === '??') {
            let op = next().value;
            let right = parseLogicalAnd();
            let prevLeft = left;
            if (op === '||') {
              left = function(scope, ev) { return prevLeft(scope, ev) || right(scope, ev); };
            } else {
              left = function(scope, ev) {
                let val = prevLeft(scope, ev);
                return (val !== null && val !== undefined) ? val : right(scope, ev);
              };
            }
          }
          return left;
        }

        function parseLogicalAnd() {
          let left = parseEquality();
          while (peek().value === '&&') {
            next();
            let right = parseEquality();
            let prevLeft = left;
            left = function(scope, ev) { return prevLeft(scope, ev) && right(scope, ev); };
          }
          return left;
        }

        function parseEquality() {
          let left = parseRelational();
          while (['===', '!==', '==', '!='].indexOf(peek().value) !== -1) {
            let op = next().value;
            let right = parseRelational();
            let prevLeft = left;
            if (op === '===') left = function(scope, ev) { return prevLeft(scope, ev) === right(scope, ev); };
            else if (op === '!==') left = function(scope, ev) { return prevLeft(scope, ev) !== right(scope, ev); };
            else if (op === '==') left = function(scope, ev) { return prevLeft(scope, ev) == right(scope, ev); };
            else if (op === '!=') left = function(scope, ev) { return prevLeft(scope, ev) != right(scope, ev); };
          }
          return left;
        }

        function parseRelational() {
          let left = parseAdditive();
          while (['<', '>', '<=', '>=', 'instanceof', 'in'].indexOf(peek().value) !== -1) {
            let op = next().value;
            let right = parseAdditive();
            let prevLeft = left;
            if (op === '<') left = function(scope, ev) { return prevLeft(scope, ev) < right(scope, ev); };
            else if (op === '>') left = function(scope, ev) { return prevLeft(scope, ev) > right(scope, ev); };
            else if (op === '<=') left = function(scope, ev) { return prevLeft(scope, ev) <= right(scope, ev); };
            else if (op === '>=') left = function(scope, ev) { return prevLeft(scope, ev) >= right(scope, ev); };
            else if (op === 'instanceof') left = function(scope, ev) { return prevLeft(scope, ev) instanceof right(scope, ev); };
            else if (op === 'in') left = function(scope, ev) { return prevLeft(scope, ev) in right(scope, ev); };
          }
          return left;
        }

        function parseAdditive() {
          let left = parseMultiplicative();
          while (peek().value === '+' || peek().value === '-') {
            let op = next().value;
            let right = parseMultiplicative();
            let prevLeft = left;
            if (op === '+') left = function(scope, ev) { return prevLeft(scope, ev) + right(scope, ev); };
            else left = function(scope, ev) { return prevLeft(scope, ev) - right(scope, ev); };
          }
          return left;
        }

        function parseMultiplicative() {
          let left = parseUnary();
          while (peek().value === '*' || peek().value === '/' || peek().value === '%') {
            let op = next().value;
            let right = parseUnary();
            let prevLeft = left;
            if (op === '*') left = function(scope, ev) { return prevLeft(scope, ev) * right(scope, ev); };
            else if (op === '/') left = function(scope, ev) { return prevLeft(scope, ev) / right(scope, ev); };
            else left = function(scope, ev) { return prevLeft(scope, ev) % right(scope, ev); };
          }
          return left;
        }

        function parseUnary() {
          let op = peek();
          if (op.type === 'op' && (op.value === '!' || op.value === '+' || op.value === '-' || op.value === 'typeof' || op.value === '~' || op.value === '++' || op.value === '--')) {
            next();
            let sub = parseUnary();
            if (op.value === '!') return function(scope, ev) { return !sub(scope, ev); };
            if (op.value === '+') return function(scope, ev) { return +sub(scope, ev); };
            if (op.value === '-') return function(scope, ev) { return -sub(scope, ev); };
            if (op.value === 'typeof') return function(scope, ev) { return typeof sub(scope, ev); };
            if (op.value === '~') return function(scope, ev) { return ~sub(scope, ev); };
            if (op.value === '++' || op.value === '--') {
              if (sub && sub.isIdentifier) {
                let idName = sub.idName;
                return function(scope, ev) {
                  let target = (scope && scope.FData) ? scope.FData : scope;
                  return (op.value === '++') ? ++target[idName] : --target[idName];
                };
              }
            }
          }
          return parsePostfix();
        }

        function parsePostfix() {
          let base = parsePrimary();
          while (true) {
            if (match('.')) {
              let propTok = next();
              let propName = (propTok && (propTok.type === 'id' || propTok.type === 'lit')) ? propTok.value : '';
              let prevBase = base;
              base = function(scope, ev) {
                let obj = prevBase(scope, ev);
                return (obj != null) ? obj[propName] : undefined;
              };
              base.isMember = true;
              base.objFn = prevBase;
              base.propFn = function() { return propName; };
            } else if (match('[')) {
              let indexExpr = parseAssignment();
              match(']');
              let prevBase = base;
              base = function(scope, ev) {
                let obj = prevBase(scope, ev);
                let idx = indexExpr ? indexExpr(scope, ev) : undefined;
                return (obj != null) ? obj[idx] : undefined;
              };
              base.isMember = true;
              base.objFn = prevBase;
              base.propFn = indexExpr;
            } else if (match('(')) {
              let args = [];
              if (peek().value !== ')') {
                while (true) {
                  args.push(parseAssignment());
                  if (!match(',')) break;
                }
              }
              match(')');
              let prevBase = base;
              base = function(scope, ev) {
                let fn = prevBase(scope, ev);
                let evaluatedArgs = args.map(function(a) { return a ? a(scope, ev) : undefined; });
                if (typeof fn === 'function') {
                  let ctx = prevBase.isMember ? prevBase.objFn(scope, ev) : ((scope && scope.FData) ? scope.FData : scope);
                  return fn.apply(ctx, evaluatedArgs);
                }
                return undefined;
              };
            } else if (peek().value === '++' || peek().value === '--') {
              let op = next().value;
              let prevBase = base;
              if (prevBase && prevBase.isIdentifier) {
                let idName = prevBase.idName;
                base = function(scope, ev) {
                  let target = (scope && scope.FData) ? scope.FData : scope;
                  let oldVal = target[idName];
                  if (op === '++') target[idName] = (oldVal || 0) + 1;
                  else target[idName] = (oldVal || 0) - 1;
                  return oldVal;
                };
              }
            } else {
              break;
            }
          }
          return base;
        }

        function parsePrimary() {
          let t = peek();
          if (!t || t.type === 'eof') return function() { return undefined; };

          if (t.type === 'num' || t.type === 'str' || t.type === 'lit') {
            next();
            let val = t.value;
            return function() { return val; };
          }

          if (t.type === 'id') {
            next();
            let name = t.value;
            let fn = function(scope, ev) {
              let d = (scope && scope.FData) ? scope.FData : scope;
              if (name === '$event') return ev;
              if (name === 'this') return d;
              if (d != null && (name in d)) return d[name];
              if (typeof window !== 'undefined' && (name in window)) return window[name];
              if (typeof globalThis !== 'undefined' && (name in globalThis)) return globalThis[name];
              return undefined;
            };
            fn.isIdentifier = true;
            fn.idName = name;
            return fn;
          }

          if (match('(')) {
            let inside = parseSequence();
            match(')');
            return inside;
          }

          if (match('[')) {
            let elements = [];
            if (peek().value !== ']') {
              while (true) {
                elements.push(parseAssignment());
                if (!match(',')) break;
              }
            }
            match(']');
            return function(scope, ev) {
              return elements.map(function(e) { return e ? e(scope, ev) : undefined; });
            };
          }

          if (match('{')) {
            let props = [];
            if (peek().value !== '}') {
              while (true) {
                let keyTok = next();
                let keyName = (keyTok && (keyTok.type === 'id' || keyTok.type === 'str')) ? keyTok.value : String(keyTok ? keyTok.value : '');
                let valFn;
                if (match(':')) {
                  valFn = parseAssignment();
                } else {
                  valFn = function(scope, ev) {
                    let d = (scope && scope.FData) ? scope.FData : scope;
                    return d ? d[keyName] : undefined;
                  };
                }
                props.push({ key: keyName, fn: valFn });
                if (!match(',')) break;
              }
            }
            match('}');
            return function(scope, ev) {
              let res = {};
              for (let i = 0; i < props.length; i++) {
                res[props[i].key] = props[i].fn ? props[i].fn(scope, ev) : undefined;
              }
              return res;
            };
          }

          next();
          return function() { return undefined; };
        }

        return parseSequence();
      }

      bv.fastEval = function(scope, expr, ev) {
        if (!expr || typeof expr !== 'string') return undefined;
        let trimmed = expr.trim();
        if (!trimmed) return undefined;

        let d = (scope && scope.FData) ? scope.FData : scope;

        // Immediate fast paths for primitive tokens
        if (trimmed === '$event') return ev;
        if (trimmed.indexOf('$event.') === 0) return bv.getDeepValue(ev, trimmed.slice(7));
        if (trimmed === 'true') return true;
        if (trimmed === 'false') return false;
        if (trimmed === 'null') return null;
        if (trimmed === 'undefined') return undefined;

        // Single root identifier: count, user, $t
        if (/^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(trimmed)) {
          if (d != null && (trimmed in d)) return d[trimmed];
          if (typeof window !== 'undefined' && (trimmed in window)) return window[trimmed];
          if (typeof globalThis !== 'undefined' && (trimmed in globalThis)) return globalThis[trimmed];
          return undefined;
        }

        // Numeric constant
        if (/^-?\d+(\.\d+)?$/.test(trimmed)) {
          return parseFloat(trimmed);
        }

        // Simple dot path: user.name, $theme.isDark
        if (/^[a-zA-Z_$][a-zA-Z0-9_$]*(\.[a-zA-Z_$][a-zA-Z0-9_$]*)+$/.test(trimmed)) {
          return bv.getDeepValue(d, trimmed);
        }

        // Simple logical negation: !isActive, !user.admin
        if (/^![a-zA-Z_$][a-zA-Z0-9_$.]*$/.test(trimmed)) {
          return !bv.getDeepValue(d, trimmed.slice(1));
        }

        // Cached AST evaluator lookup
        let fn = bv.evalCache[trimmed];
        if (!fn) {
          try {
            let tokens = bvTokenize(trimmed);
            fn = bvParseTokens(tokens);
            bv.evalCache[trimmed] = fn;
          } catch(err) {
            return undefined;
          }
        }

        return fn(scope, ev);
      };
    }
    
    
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
         if (window.__BV_CORE__.i18n && !Data.FData['$t']) {
            Data.FData['$t'] = function(k, p) { return window.__BV_CORE__.t(k, p); };
            Data.FData['$i18n'] = window.__BV_CORE__.i18n;
            Data.FData['$setLocale'] = function(loc) { window.__BV_CORE__.i18n.setLocale(loc); };
         }
         if (window.__BV_CORE__.theme && !Data.FData['$theme']) {
            Data.FData['$theme'] = window.__BV_CORE__.theme;
         }
         if (window.__BV_CORE__.wasm && !Data.FData['$wasm']) {
            Data.FData['$wasm'] = window.__BV_CORE__.wasm;
         }
         if (window.__BV_CORE__.mobile && !Data.FData['$mobile']) {
            Data.FData['$mobile'] = window.__BV_CORE__.mobile;
         }
         if (window.__BV_CORE__.api && !Data.FData['$api']) {
            Data.FData['$api'] = window.__BV_CORE__.api;
         }
         if (window.__BV_CORE__.ws && !Data.FData['$ws']) {
            Data.FData['$ws'] = window.__BV_CORE__.ws;
         }
         if (window.__BV_CORE__.auth && !Data.FData['$auth']) {
            Data.FData['$auth'] = window.__BV_CORE__.auth;
         }
         if (window.__BV_CORE__.ionic && !Data.FData['$ionic']) {
            Data.FData['$ionic'] = window.__BV_CORE__.ionic;
         }
      }

      if (Data && !Data.Evaluate) {
        Data.Evaluate = function(expr, ev) {
          return bv.fastEval(Data, expr, ev);
        };
      }
      if (Data && !Data.SetValue) {
        Data.SetValue = function(k, val) {
          let d = (Data && Data.FData) ? Data.FData : Data;
          bv.setDeepValue(d, k, val);
        };
      }

      console.log("[Compiler] BLAISE v3.0 ENGAGED on <" + Root.tagName + ">");
      bv.traverse(Root, Data, Methods);
      bv.trigger(Data.FData, ""); // Initial trigger for all expressions
    };

    // Safely removes an element while triggering lifecycle hooks
    bv.unmount = function(el) {
       if (!el) return;
       if (el['bvUnmount']) el['bvUnmount']();
       if (el.nodeType === 1 && el.querySelectorAll) {
          let children = el.querySelectorAll('*');
          for (let i = 0; i < children.length; i++) {
             if (children[i]['bvUnmount']) children[i]['bvUnmount']();
          }
       }
       if (el.remove) el.remove();
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
          if (typeof window === 'undefined' || !window.getComputedStyle) return;
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

    // Merges two options objects (used for Mixins)
    bv.mergeOptions = function(to, from) {
       if (!from) return to;
       const res = Object.assign({}, to);
       
       if (from.data) {
          const toData = to.data;
          const fromData = from.data;
          res.data = function() {
             const d1 = typeof toData === 'function' ? toData.call(this, this) : (toData || {});
             const d2 = typeof fromData === 'function' ? fromData.call(this, this) : (fromData || {});
             return Object.assign({}, d2, d1); // Component data (d1) overrides mixin (d2)
          };
       }

       ['methods', 'computed', 'watch', 'inject'].forEach(k => {
          if (from[k]) res[k] = Object.assign({}, from[k], to[k] || {}); // to overrides from
       });

       ['created', 'mounted', 'updated', 'unmounted'].forEach(k => {
          if (from[k]) {
             const toHook = to[k];
             const fromHook = from[k];
             res[k] = function() {
                fromHook.apply(this, arguments);
                if (toHook) toHook.apply(this, arguments);
             };
          }
       });

       if (from.template && !to.template) res.template = from.template;
       if (from.provide) {
          const toProv = to.provide;
          const fromProv = from.provide;
          res.provide = function() {
             const p1 = typeof toProv === 'function' ? toProv.call(this, this) : (toProv || {});
             const p2 = typeof fromProv === 'function' ? fromProv.call(this, this) : (fromProv || {});
             return Object.assign({}, p2, p1);
          };
       }
       return res;
    };

    // Static Hoisting & Compiler Pruning: identifies static trees
    bv.isStatic = function(node) {
       if (!node) return true;
       if (node.nodeType === 3) {
          return (node.nodeValue.indexOf('{{') === -1);
       }
       if (node.nodeType === 1) {
          let tag = node.tagName.toLowerCase();
          if (tag.indexOf('-') !== -1 || (bv.components && bv.components[tag])) return false;
          if (tag === 'router-view' || tag === 'transition' || tag === 'transition-group' || tag === 'b-transition-group' || tag === 'teleport' || tag === 'b-teleport' || tag === 'suspense' || tag === 'b-suspense' || tag === 'slot' || tag === 'b-slot') return false;
          if (node.attributes) {
             for (let i = 0; i < node.attributes.length; i++) {
                let n = node.attributes[i].name.toLowerCase();
                if (n.startsWith('@') || n.startsWith(':') || n.startsWith('b-') || n.startsWith('v-') || n === 'ref' || n === 'slot' || n === 'slot-scope') return false;
             }
          }
          let children = node.childNodes;
          for (let j = 0; j < children.length; j++) {
             if (!bv.isStatic(children[j])) return false;
          }
          return true;
       }
       return true;
    };

    // Hot Module Replacement (HMR): patches live component instances preserving reactive state
    bv.patchComponent = function(tagName, newOptions) {
       if (!tagName) return;
       tagName = tagName.toLowerCase();
       console.log("[HMR] Patching component <" + tagName + ">...");
       if (!bv.components) bv.components = {};
       bv.components[tagName] = newOptions;

       let instances = Array.from(document.querySelectorAll('[data-bv-component="' + tagName + '"]'));
       if (instances.length === 0) {
          instances = Array.from(document.querySelectorAll('*')).filter(function(el) {
             return el['__bv_component_tag__'] === tagName;
          });
       }

       instances.forEach(function(instEl) {
          let existingData = instEl['__bv_instance_data__'];
          let parentData = instEl['__bv_parent_data__'];
          let parentMethods = instEl['__bv_parent_methods__'];
          if (existingData && newOptions.template) {
             let temp = document.createElement('div');
             temp.innerHTML = newOptions.template;
             let newEl = temp.firstElementChild;
             if (newEl) {
                newEl['bvManaged'] = true;
                newEl.setAttribute('data-bv-component', tagName);
                newEl['__bv_component_tag__'] = tagName;
                newEl['__bv_instance_data__'] = existingData;
                newEl['__bv_instance_opts__'] = newOptions;
                newEl['__bv_parent_data__'] = parentData;
                newEl['__bv_parent_methods__'] = parentMethods;

                if (newOptions.methods) {
                   Object.keys(newOptions.methods).forEach(function(k) {
                      existingData[k] = function() { return newOptions.methods[k].apply(this, [this, ...arguments]); };
                   });
                }
                if (newOptions.computed) {
                   Object.keys(newOptions.computed).forEach(function(ck) {
                      bv.defineComputed(existingData, ck, newOptions.computed[ck]);
                   });
                }

                let cD = {
                   FData: existingData,
                   Evaluate: function(expr, ev) {
                      try {
                         let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(e) { return undefined; } }');
                         return f(this.FData, ev);
                      } catch(ex) { return undefined; }
                   },
                   SetValue: function(k, val) { bv.setDeepValue(this.FData, k, val); }
                };

                instEl.parentNode.replaceChild(newEl, instEl);
                bv.traverse(newEl, cD, newOptions.methods);
                if (newOptions.updated) newOptions.updated.call(existingData, existingData);
                console.log("[HMR] Component <" + tagName + "> patched in-place!");
             }
          }
       });

       if (window.__BV_DEVTOOLS_HOOK__) {
          window.__BV_DEVTOOLS_HOOK__.emit('component:hmr', { tag: tagName });
       }
    };

    // HMR WebSocket Client Bridge
    bv.initHMR = function(wsPort) {
       try {
          let port = wsPort || 8081;
          let host = window.location.hostname || 'localhost';
          let proto = (window.location.protocol === 'https:') ? 'wss://' : 'ws://';
          let ws = new WebSocket(proto + host + ':' + port);
          ws.onopen = function() {
             console.log("%c[BlaiseVue HMR] Connected to live reload server", "color: #42b883; font-weight: bold;");
          };
          ws.onmessage = function(ev) {
             try {
                let msg = JSON.parse(ev.data);
                if (msg.type === 'patch' && msg.component && msg.options) {
                   bv.patchComponent(msg.component, msg.options);
                } else if (msg.type === 'reload') {
                   console.log("[HMR] Triggering page reload...");
                   window.location.reload();
                }
             } catch(err) { console.warn("[HMR] Message processing error:", err); }
          };
       } catch(e) { console.warn("[HMR] Unable to connect:", e); }
    };

    // Transition Group FLIP Animation Handler
    bv.setupTransitionGroup = function(wrapperEl, tName) {
       if (!wrapperEl || wrapperEl['__bv_transition_group_init__']) return;
       wrapperEl['__bv_transition_group_init__'] = true;
       let prefix = tName || 'v';
       let prevPositions = new Map();

       function getPositions() {
          let posMap = new Map();
          if (wrapperEl.children) {
             Array.from(wrapperEl.children).forEach(function(c) {
                if (c && c.getBoundingClientRect) {
                   posMap.set(c, c.getBoundingClientRect());
                }
             });
          }
          return posMap;
       }

       prevPositions = getPositions();

       if (typeof MutationObserver !== 'undefined') {
          let observer = new MutationObserver(function(mutations) {
             let newPositions = getPositions();
             Array.from(wrapperEl.children).forEach(function(child) {
                if (!child || !child.getBoundingClientRect) return;
                let first = prevPositions.get(child);
                let last = newPositions.get(child);
                if (first && last) {
                   let dx = first.left - last.left;
                   let dy = first.top - last.top;
                   if (dx !== 0 || dy !== 0) {
                      child.style.transform = 'translate(' + dx + 'px, ' + dy + 'px)';
                      child.style.transition = 'transform 0s';
                      child.classList.add(prefix + '-move');

                      if (typeof requestAnimationFrame !== 'undefined') {
                         requestAnimationFrame(function() {
                            child.style.transform = '';
                            child.style.transition = '';
                            let onEnd = function(e) {
                               if (e.target === child) {
                                  child.classList.remove(prefix + '-move');
                                  child.removeEventListener('transitionend', onEnd);
                               }
                            };
                            child.addEventListener('transitionend', onEnd);
                         });
                      }
                   }
                } else if (!first && last) {
                   child.classList.add(prefix + '-enter-from', prefix + '-enter-active');
                   if (typeof requestAnimationFrame !== 'undefined') {
                      requestAnimationFrame(function() {
                         child.classList.remove(prefix + '-enter-from');
                         let onEnterEnd = function(e) {
                            if (e.target === child) {
                               child.classList.remove(prefix + '-enter-active');
                               child.removeEventListener('transitionend', onEnterEnd);
                            }
                         };
                         child.addEventListener('transitionend', onEnterEnd);
                      });
                   }
                }
             });
             prevPositions = newPositions;
          });
          observer.observe(wrapperEl, { childList: true });
          wrapperEl['__bv_transition_observer__'] = observer;
       }
    };

    // Recursive DOM Visitor: The core of the Directive Engine
    bv.traverse = function(Node, Data, Methods) {
      if (!Node || Node['bvTraversed'] || Node['bvStatic']) return;
      
      try {
          // Static Hoisting: hoist pure static elements out of reactivity cycle
          if (Node.nodeType === 1 && !Node['bvStaticChecked']) {
             Node['bvStaticChecked'] = true;
             if (bv.isStatic(Node)) {
                Node['bvStatic'] = true;
                Node['bvTraversed'] = true;
                bv.hoistedCount = (bv.hoistedCount || 0) + 1;
                return;
             }
          }

          // 1. Text Interpolation {{ expression }}
          if (Node.nodeType === 3) {
            let t = Node['b-orig-tpl'] || Node.nodeValue;
            if (t && t.indexOf('{{') !== -1) {
              if (!Node['b-orig-tpl']) Node['b-orig-tpl'] = t;
              Node['bvTraversed'] = true; 
              bv.effect(function() {
                let d = (Data && Data.FData) ? Data.FData : Data || {};
                if (window.__BV_CORE__.i18n && !d.$t) {
                   d.$t = function(k, p) { return window.__BV_CORE__.t(k, p); };
                   d.$i18n = window.__BV_CORE__.i18n;
                   d.$setLocale = function(loc) { window.__BV_CORE__.i18n.setLocale(loc); };
                }
                if (window.__BV_CORE__.theme && !d.$theme) {
                   d.$theme = window.__BV_CORE__.theme;
                }
                if (window.__BV_CORE__.wasm && !d.$wasm) {
                   d.$wasm = window.__BV_CORE__.wasm;
                }
                if (window.__BV_CORE__.mobile && !d.$mobile) {
                   d.$mobile = window.__BV_CORE__.mobile;
                }
                if (window.__BV_CORE__.api && !d.$api) {
                   d.$api = window.__BV_CORE__.api;
                }
                if (window.__BV_CORE__.ws && !d.$ws) {
                   d.$ws = window.__BV_CORE__.ws;
                }
                 if (window.__BV_CORE__.ionic && !d.$ionic) {
                    d.$ionic = window.__BV_CORE__.ionic;
                 }
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

          // 2. Special tags: <transition>, <teleport>, <suspense>
          if (tagName === 'transition') {
            let tName = el.getAttribute('name') || 'v';
            let child = el.firstElementChild;
            if (child) {
               child.setAttribute('bv-transition', tName);
               if (el.parentNode) el.parentNode.replaceChild(child, el);
               bv.traverse(child, Data, Methods);
               return;
            }
          }

          if (tagName === 'transition-group' || tagName === 'b-transition-group') {
            let wrapperTag = el.getAttribute('tag') || 'div';
            let tName = el.getAttribute('name') || 'v';
            let wrapperEl = document.createElement(wrapperTag);
            for (let i = 0; i < el.attributes.length; i++) {
               let a = el.attributes[i];
               if (a.name !== 'tag' && a.name !== 'name') {
                  wrapperEl.setAttribute(a.name, a.value);
               }
            }
            wrapperEl.classList.add('bv-transition-group');
            while (el.firstChild) {
               wrapperEl.appendChild(el.firstChild);
            }
            if (el.parentNode) {
               el.parentNode.replaceChild(wrapperEl, el);
            }
            bv.setupTransitionGroup(wrapperEl, tName);
            bv.traverse(wrapperEl, Data, Methods);
            return;
          }

          if (tagName === 'teleport' || tagName === 'b-teleport') {
            let toTarget = el.getAttribute('to') || 'body';
            let targetEl = (toTarget === 'body') ? document.body : document.querySelector(toTarget);
            let anchor = document.createElement('span');
            anchor.style.display = 'none';
            anchor.setAttribute('data-teleport-anchor', toTarget);
            if (el.parentNode) el.parentNode.replaceChild(anchor, el);
            let fragment = document.createDocumentFragment();
            let teleportedNodes = Array.from(el.childNodes);
            teleportedNodes.forEach(function(cNode) { fragment.appendChild(cNode); });
            targetEl.appendChild(fragment);
            teleportedNodes.forEach(function(cNode) { bv.traverse(cNode, Data, Methods); });
            anchor['bvUnmount'] = function() {
               teleportedNodes.forEach(function(cNode) { bv.unmount(cNode); });
            };
            return;
          }

          if (tagName === 'suspense' || tagName === 'b-suspense') {
            let fallbackTpl = el.querySelector('[slot="fallback"], template[#fallback], template[slot="fallback"]');
            let fallbackEl = null;
            if (fallbackTpl) {
               fallbackEl = (fallbackTpl.tagName.toLowerCase() === 'template') ?
                  (fallbackTpl.content ? fallbackTpl.content.cloneNode(true) : fallbackTpl.cloneNode(true)) :
                  fallbackTpl.cloneNode(true);
               fallbackTpl.remove();
            }
            let anchor = document.createComment('suspense-anchor');
            el.parentNode.insertBefore(anchor, el);
            let pending = (Data && Data.FData && Data.FData.$pendingPromises && Data.FData.$pendingPromises.length > 0);
            if (pending && fallbackEl) {
               let fbNode = fallbackEl.firstElementChild || fallbackEl;
               anchor.parentNode.insertBefore(fbNode, anchor.nextSibling);
               el.style.display = 'none';
               Promise.all(Data.FData.$pendingPromises).then(function() {
                  if (fbNode.parentNode) fbNode.remove();
                  el.style.display = '';
                  bv.traverse(el, Data, Methods);
               });
            } else {
               bv.traverse(el, Data, Methods);
            }
            return;
          }

          let opts = (bv.components ? bv.components[tagName] : null);
          if (tagName.indexOf('-') !== -1) {
             console.log("[Compiler] Resolving <" + tagName + ">. Found: " + !!opts);
          }

          // 3. Directive Collection
          let vmodel = null, vfor = null, vif = null, vshow = null, vref = null, vvalidate = null, vvalidateField = null, vfield = null;
          let binds = [];
          let events = [];
          if (el.attributes) {
            for (let i = 0; i < el.attributes.length; i++) {
               let a = el.attributes[i];
               let n = a.name.toLowerCase();
               if (n === 'b-model' || n === 'v-model') vmodel = a.value;
               else if (n === 'b-field' || n === 'v-field') vfield = a.value;
               else if (n === 'b-validate' || n === 'v-validate') vvalidate = a.value;
               else if (n.startsWith('b-validate:') || n.startsWith('v-validate:')) {
                  vvalidateField = n.startsWith('b-validate:') ? n.substring(11) : n.substring(11);
                  vvalidate = a.value;
               }
               else if (n === 'b-for' || n === 'v-for') vfor = a.value;
               else if (n === 'b-if' || n === 'v-if') vif = a.value;
               else if (n === 'b-show' || n === 'v-show') vshow = a.value;
               else if (n === 'b-ref' || n === 'ref') vref = a.value; 
               else if (n.startsWith('@') || n.startsWith('v-on:') || n.startsWith('b-on:')) {
                  let rawName = n.startsWith('@') ? n.substring(1) : (n.startsWith('v-on:') ? n.substring(5) : n.substring(5));
                  let parts = rawName.split('.');
                  let evName = parts[0];
                  let mods = parts.slice(1);
                  events.push({ name: evName, expr: a.value, modifiers: mods });
               }
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
               const isCheck = (el.type === 'checkbox');
               if (isCheck) {
                 el.checked = Boolean(Data.Evaluate(vmodel));
               } else {
                 el.value = Data.Evaluate(vmodel) || '';
               }
               const sync = function() {
                 const val = isCheck ? this.checked : this.value;
                 Data.SetValue(vmodel, val);
               };
               el.oninput = sync; el.onchange = sync; 
               bv.effect(function() {
                 let v = Data.Evaluate(vmodel);
                 if (isCheck) {
                   if (el.checked !== Boolean(v)) el.checked = Boolean(v);
                 } else {
                   if (document.activeElement !== el && el.value !== v) el.value = (v === undefined || v === null) ? '' : v;
                 }
               });
            }
          }

          // 5.1. b-field directive (Native LiveBindings with TBVDataSet)
          if (vfield) {
            el.removeAttribute('b-field'); el.removeAttribute('v-field');
            if (!opts) {
               let parts = vfield.split('.');
               let dsExpr = parts[0];
               let fieldName = parts.slice(1).join('.');

               const getNativeFieldVal = function() {
                 let ds = Data.Evaluate(dsExpr);
                 if (!ds) return '';
                 if (typeof ds.FieldByName === 'function') {
                   return ds.FieldByName(fieldName).AsString;
                 } else if (ds.Current) {
                   return ds.Current[fieldName] !== undefined ? ds.Current[fieldName] : '';
                 }
                 return '';
               };

               const setNativeFieldVal = function(val) {
                 let ds = Data.Evaluate(dsExpr);
                 if (!ds) return;
                 if (typeof ds.FieldByName === 'function') {
                   if (ds.StateStr === 'browse') ds.Edit();
                   ds.FieldByName(fieldName).AsString = val;
                 } else if (ds.Current) {
                   ds.Current[fieldName] = val;
                 }
               };

               el.value = getNativeFieldVal() || '';
               const syncField = function() { setNativeFieldVal(this.value); };
               el.oninput = syncField; el.onchange = syncField;

               bv.effect(function() {
                 let v = getNativeFieldVal();
                 if (document.activeElement !== el && el.value !== v) el.value = (v === undefined || v === null) ? '' : v;
               });
            }
          }

          // 5.5. b-validate directive (native elements)
          if (vvalidate && !opts) {
            el.removeAttribute('b-validate'); el.removeAttribute('v-validate');
            if (vvalidateField) el.removeAttribute('b-validate:' + vvalidateField);
            let targetField = vvalidateField || vmodel || el.getAttribute('name') || el.id || '';
            if (targetField && Data && Data.FData && window.__BV_CORE__.validation) {
               window.__BV_CORE__.validation.setupField(Data.FData, targetField, vvalidate);
               
               let runValidation = function() {
                  let fObj = Data.FData.$v && Data.FData.$v.$fields && Data.FData.$v.$fields[targetField];
                  if (fObj) {
                     fObj.$touch();
                     if (fObj.$invalid) {
                        el.classList.add('is-invalid');
                        el.classList.add('bv-invalid');
                        el.classList.remove('is-valid');
                        el.classList.remove('bv-valid');
                     } else {
                        el.classList.add('is-valid');
                        el.classList.add('bv-valid');
                        el.classList.remove('is-invalid');
                        el.classList.remove('bv-invalid');
                     }
                  }
               };

               el.addEventListener('blur', function() {
                  runValidation();
               });

               el.addEventListener('input', function() {
                  let fObj = Data.FData.$v && Data.FData.$v.$fields && Data.FData.$v.$fields[targetField];
                  if (fObj && fObj.$dirty) {
                     runValidation();
                  }
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
                      has(t, k) { return (k === itN || k === '$index' || k in pData); },
                      set(t, k, v) {
                        if (k === itN) { item = v; return true; }
                        pData[k] = v;
                        return true;
                      }
                    });
                    let ld = {
                      FData: scp,
                      Evaluate: function(expr, ev) {
                        return bv.fastEval(this.FData, expr, ev);
                      },
                      SetValue: function(k, val) { bv.setDeepValue(this.FData, k, val); }
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
            let firstRun = true;
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
                 if (tName && !firstRun) bv.applyTransition(el, 'leave', tName, function() { bv.unmount(el); });
                 else bv.unmount(el); 
                 active = false; 
              }
              firstRun = false;
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
                  if (el['_bv_static_class'] === undefined) el['_bv_static_class'] = el.getAttribute('class') || '';
                  if (typeof v === 'object' && !Array.isArray(v)) {
                    el.className = el['_bv_static_class'];
                    Object.keys(v).forEach(function(ck) { if (v[ck]) el.classList.add(ck); else el.classList.remove(ck); });
                  } else {
                    let dyn = Array.isArray(v) ? v.filter(Boolean).join(' ') : (v || '');
                    el.className = (el['_bv_static_class'] ? (el['_bv_static_class'] + ' ' + dyn) : dyn).trim();
                  }
                } else if (b.name === 'style') {
                  if (el['_bv_static_style'] === undefined) el['_bv_static_style'] = el.getAttribute('style') || '';
                  if (typeof v === 'object') {
                    if (el['_bv_static_style']) el.style.cssText = el['_bv_static_style'];
                    Object.assign(el.style, v);
                  } else {
                    el.style.cssText = (el['_bv_static_style'] ? (el['_bv_static_style'] + '; ' + v) : String(v));
                  }
                } else {
                   let isBoolAttr = ['disabled', 'readonly', 'checked', 'required', 'hidden', 'selected', 'multiple', 'autofocus'].indexOf(b.name) !== -1;
                   if (isBoolAttr) {
                      let isTrue = (v === true || v === 'true' || v === '');
                      if (isTrue) {
                         el.setAttribute(b.name, '');
                         try { el[b.name] = true; } catch(e) {}
                      } else {
                         el.removeAttribute(b.name);
                         try { el[b.name] = false; } catch(e) {}
                      }
                   } else {
                      if (v === null || v === undefined || v === false) {
                         el.removeAttribute(b.name);
                      } else if (typeof v !== 'object') {
                         el.setAttribute(b.name, v);
                      }
                   }
                }
             });
          });

          // 10. Component Logic, Slots & Provide/Inject
          if (opts) {
            if (window.__BV_CORE__.mixins && window.__BV_CORE__.mixins.length > 0) {
               let merged = opts;
               window.__BV_CORE__.mixins.forEach(m => {
                  merged = bv.mergeOptions(merged, m);
               });
               opts = merged;
            }

            let dRaw = opts.data ? opts.data.call(null) : {};
            if (opts.defaultProps) {
               Object.keys(opts.defaultProps).forEach(function(k) {
                  if (dRaw[k] === undefined) dRaw[k] = opts.defaultProps[k];
               });
            }
            let pRef = bv.defineReactive(dRaw);
            
            if (window.__BV_CORE__.router) {
               pRef['Router'] = window.__BV_CORE__.router;
               pRef['$router'] = window.__BV_CORE__.router;
            }
            if (window['__BV_PRO_STORE__']) pRef['$store'] = window['__BV_PRO_STORE__'];
            if (window.__BV_CORE__.i18n) {
               pRef['$t'] = function(k, p) { return window.__BV_CORE__.t(k, p); };
               pRef['$i18n'] = window.__BV_CORE__.i18n;
               pRef['$setLocale'] = function(loc) { window.__BV_CORE__.i18n.setLocale(loc); };
            }
            if (window.__BV_CORE__.theme) {
               pRef['$theme'] = window.__BV_CORE__.theme;
            }
            if (window.__BV_CORE__.wasm) {
               pRef['$wasm'] = window.__BV_CORE__.wasm;
            }
            if (window.__BV_CORE__.mobile) {
               pRef['$mobile'] = window.__BV_CORE__.mobile;
            }
            if (window.__BV_CORE__.desktop) {
               pRef['$desktop'] = window.__BV_CORE__.desktop;
            }
            if (window.__BV_CORE__.api) {
               pRef['$api'] = window.__BV_CORE__.api;
            }
            if (window.__BV_CORE__.ws) {
               pRef['$ws'] = window.__BV_CORE__.ws;
            }
            if (window.__BV_CORE__.auth) {
               pRef['$auth'] = window.__BV_CORE__.auth;
            }
             if (window.__BV_CORE__.ionic) {
                pRef['$ionic'] = window.__BV_CORE__.ionic;
             }
            if (window.__BV_CORE__.validation) {
               window.__BV_CORE__.validation.initDataValidation(pRef);
            }
            
            // Props Initialization
            if (el.attributes) {
               for (let i = 0; i < el.attributes.length; i++) {
                  let a = el.attributes[i];
                  let n = a.name;
                  if (n.startsWith(':') || n.startsWith('b-bind:')) {
                     let pn = n.replace('b-bind:', '').replace(':', '');
                     let targetProp = pn;
                     if (opts.props && Array.isArray(opts.props)) {
                        let found = opts.props.find(p => p.toLowerCase() === pn.toLowerCase() || p.toLowerCase() === pn.replace(/-/g, '').toLowerCase());
                        if (found) targetProp = found;
                     }
                     bv.effect(function() {
                        let val = Data.Evaluate(a.value);
                        pRef[targetProp] = val;
                        if (targetProp !== pn) pRef[pn] = val;
                     });
                  } else if (!n.startsWith('@') && !n.startsWith('b-') && !n.startsWith('v-')) {
                     let targetProp = n;
                     if (opts.props && Array.isArray(opts.props)) {
                        let found = opts.props.find(p => p.toLowerCase() === n.toLowerCase() || p.toLowerCase() === n.replace(/-/g, '').toLowerCase());
                        if (found) targetProp = found;
                     }
                     pRef[targetProp] = a.value;
                     if (targetProp !== n) pRef[n] = a.value;
                  }
               }
            }

            // Manage Slots (Standard & Scoped Slots)
            let originalChildren = Array.from(el.childNodes);
            let root_c = document.createElement('div');
            root_c.innerHTML = opts.template;
            let rEl = root_c.firstElementChild;
            if (!rEl) { console.error("[Compiler] NO ROOT ELEMENT in template for <" + tagName + ">: " + opts.template); return; }
            if (el.getAttribute('class')) {
               let origClass = el.getAttribute('class');
               let rClass = rEl.getAttribute('class') || '';
               rEl.setAttribute('class', (rClass ? rClass + ' ' : '') + origClass);
            }
            if (el.getAttribute('style')) {
               let origStyle = el.getAttribute('style');
               let rStyle = rEl.getAttribute('style') || '';
               rEl.setAttribute('style', (rStyle ? rStyle + '; ' : '') + origStyle);
            }
            if (el.getAttribute('id') && !rEl.getAttribute('id')) {
               rEl.setAttribute('id', el.getAttribute('id'));
            }
            rEl['bvManaged'] = true;
            rEl.setAttribute('data-bv-component', tagName);
            rEl['__bv_component_tag__'] = tagName;
            rEl['__bv_instance_data__'] = pRef;
            rEl['__bv_instance_opts__'] = opts;
            rEl['__bv_parent_data__'] = Data;
            rEl['__bv_parent_methods__'] = Methods;
            console.log("[Compiler] Expanding <" + tagName + ">. Template length: " + opts.template.length);
            if (el.parentNode) {
               el.parentNode.replaceChild(rEl, el);
            }
            el['__bv_replacement__'] = rEl;

            function isNamedSlotNode(node) {
               if (!node || node.nodeType !== 1) return false;
               if (node.getAttribute && node.getAttribute('slot')) return true;
               if (node.attributes) {
                  for (let i = 0; i < node.attributes.length; i++) {
                     let an = node.attributes[i].name;
                     if (an.startsWith('#') && an !== '#default') return true;
                     if (an.startsWith('v-slot:') && an !== 'v-slot:default') return true;
                     if (an.startsWith('b-slot:') && an !== 'b-slot:default') return true;
                  }
               }
               return false;
            }

            let slotElements = Array.from(rEl.querySelectorAll('slot, b-slot'));
            slotElements.forEach(function(sNode) {
               let sName = sNode.getAttribute('name') || 'default';
               
               // Collect slot props bound on sNode (Scoped Slots child -> parent)
               let slotProps = {};
               if (sNode.attributes) {
                  for (let i = 0; i < sNode.attributes.length; i++) {
                     let attr = sNode.attributes[i];
                     let an = attr.name;
                     if (an === 'name') continue;
                     if (an.startsWith(':') || an.startsWith('b-bind:')) {
                        let propKey = an.replace('b-bind:', '').replace(':', '');
                        try {
                           slotProps[propKey] = bv.fastEval(pRef, attr.value);
                        } catch(ex) { slotProps[propKey] = undefined; }
                     } else {
                        slotProps[an] = attr.value;
                     }
                  }
               }

               // Match parent template/node for this slot
               let matchedParentNode = null;
               let scopeVarName = null;
               for (let i = 0; i < originalChildren.length; i++) {
                  let cn = originalChildren[i];
                  if (cn.nodeType !== 1) continue;
                  let cnSlot = cn.getAttribute('slot');
                  if (!cnSlot) {
                     if (cn.hasAttribute('#' + sName)) cnSlot = sName;
                     else if (cn.hasAttribute('v-slot:' + sName)) cnSlot = sName;
                     else if (cn.hasAttribute('b-slot:' + sName)) cnSlot = sName;
                  }
                  if (sName === 'default' && !cnSlot) {
                     if (cn.hasAttribute('slot-scope') || cn.hasAttribute('v-slot') || cn.hasAttribute('b-slot') || cn.tagName.toLowerCase() === 'template') {
                        cnSlot = 'default';
                     }
                  }
                  if (cnSlot === sName) {
                     matchedParentNode = cn;
                     scopeVarName = cn.getAttribute('slot-scope') || cn.getAttribute('b-slot-scope') || cn.getAttribute('v-slot-scope');
                     if (!scopeVarName) {
                        if (cn.getAttribute('#' + sName)) scopeVarName = cn.getAttribute('#' + sName);
                        else if (cn.getAttribute('v-slot:' + sName)) scopeVarName = cn.getAttribute('v-slot:' + sName);
                        else if (cn.getAttribute('v-slot')) scopeVarName = cn.getAttribute('v-slot');
                        else if (cn.getAttribute('b-slot')) scopeVarName = cn.getAttribute('b-slot');
                     }
                     break;
                  }
               }

               if (matchedParentNode) {
                  let parentData = (Data && Data.FData) ? Data.FData : {};
                  let scopedProxy = new Proxy(slotProps, {
                     get(t, k) {
                        if (scopeVarName && k === scopeVarName) return slotProps;
                        if (k in t) return t[k];
                        return parentData[k];
                     },
                     has(t, k) {
                        return (scopeVarName && k === scopeVarName) || (k in t) || (k in parentData);
                     }
                  });
                  let scopedData = {
                     FData: scopedProxy,
                     Evaluate: function(expr, ev) {
                        return bv.fastEval(this.FData, expr, ev);
                     },
                     SetValue: function(k, val) {
                        if (scopeVarName && k === scopeVarName) Object.assign(slotProps, val);
                        else if (k in slotProps) slotProps[k] = val;
                        else Data.SetValue(k, val);
                     }
                  };

                  let nodesToInsert = [];
                  if (matchedParentNode.tagName.toLowerCase() === 'template') {
                     let tplChildren = (matchedParentNode.content) ? matchedParentNode.content.childNodes : matchedParentNode.childNodes;
                     Array.from(tplChildren).forEach(function(tc) { nodesToInsert.push(tc.cloneNode(true)); });
                  } else {
                     nodesToInsert.push(matchedParentNode.cloneNode(true));
                  }

                  nodesToInsert.forEach(function(inNode) {
                     if (sNode.parentNode) sNode.parentNode.insertBefore(inNode, sNode);
                     bv.traverse(inNode, scopedData, Methods);
                     let finalInNode = inNode['__bv_replacement__'] || inNode;
                     bv.markManaged(finalInNode);
                  });
                  if (sNode.parentNode) sNode.remove();
               } else if (sName === 'default') {
                  let hasBareNodes = false;
                  originalChildren.forEach(function(cn) {
                     if (!isNamedSlotNode(cn)) {
                        let targetNode = cn;
                        if (sNode.parentNode) sNode.parentNode.insertBefore(targetNode, sNode);
                        bv.traverse(targetNode, Data, Methods);
                        let finalNode = targetNode['__bv_replacement__'] || targetNode;
                        bv.markManaged(finalNode);
                        hasBareNodes = true;
                     }
                  });
                  if (hasBareNodes && sNode.parentNode) sNode.remove();
               } else {
                  if (sNode.innerHTML === '' && sNode.parentNode) sNode.remove();
               }
            });

             if (vmodel) {
                bv.effect(function() { pRef['value'] = Data.Evaluate(vmodel); });
                pRef['$onInput'] = function(val) { 
                   Data.SetValue(vmodel, val); 
                   if (vvalidate && Data && Data.FData && window.__BV_CORE__.validation) {
                      let fObj = Data.FData.$v && Data.FData.$v.$fields && Data.FData.$v.$fields[vmodel];
                      if (fObj && fObj.$dirty) fObj.$touch();
                   }
                };
             }

                          if (vfield) {
                let parts = vfield.split('.');
                let dsExpr = parts[0];
                let fieldName = parts.slice(1).join('.');

                const getCompFieldVal = function() {
                  let ds = Data.Evaluate(dsExpr);
                  if (!ds) return '';
                  if (typeof ds.FieldByName === 'function') {
                    return ds.FieldByName(fieldName).AsString;
                  } else if (ds.Current) {
                    return ds.Current[fieldName] !== undefined ? ds.Current[fieldName] : '';
                  }
                  return '';
                };

                bv.effect(function() {
                  pRef['value'] = getCompFieldVal();
                });

                pRef['$onInput'] = function(val) {
                  let ds = Data.Evaluate(dsExpr);
                  if (!ds) return;
                  if (typeof ds.FieldByName === 'function') {
                    if (ds.StateStr === 'browse') ds.Edit();
                    ds.FieldByName(fieldName).AsString = val;
                  } else if (ds.Current) {
                    ds.Current[fieldName] = val;
                  }
                };
             }

             if (vvalidate && Data && Data.FData && window.__BV_CORE__.validation) {
                let targetField = vvalidateField || vmodel || el.getAttribute('name') || el.id || '';
                if (targetField) {
                   window.__BV_CORE__.validation.setupField(Data.FData, targetField, vvalidate);
                }
             }

             if (vref && Data && Data.FData) {
                if (!Data.FData.$refs) Data.FData.$refs = {};
                Data.FData.$refs[vref] = pRef;
             }
            
            if (opts.inject) {
               opts.inject.forEach(function(k) {
                  let val = (Data && Data.FData && Data.FData.$provided) ? Data.FData.$provided[k] : null;
                  if (!val && rEl && rEl.parentElement) {
                     let curr = rEl.parentElement;
                     while (curr && !val) {
                        if (curr['__bv_instance_data__'] && curr['__bv_instance_data__']['$provided'] && curr['__bv_instance_data__']['$provided'][k]) {
                           val = curr['__bv_instance_data__']['$provided'][k];
                           break;
                        }
                        curr = curr.parentElement;
                     }
                  }
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
                 dRaw[k] = function() { 
                   if (arguments.length > 0 && arguments[0] === this) {
                     return rM.apply(this, arguments);
                   }
                   return rM.apply(this, [this, ...arguments]); 
                 }; 
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
               if (!pRef['__emitted__']) pRef['__emitted__'] = {};
               if (!pRef['__emitted__'][ev]) pRef['__emitted__'][ev] = [];
               pRef['__emitted__'][ev].push(arg);
               if (rEl) {
                  if (!rEl['__emitted__']) rEl['__emitted__'] = {};
                  if (!rEl['__emitted__'][ev]) rEl['__emitted__'][ev] = [];
                  rEl['__emitted__'][ev].push(arg);
               }
               if (ev === 'input' || ev === 'change') {
                  if (pRef['$onInput']) pRef['$onInput'](arg);
               }
               let targetEv = (ev || '').toLowerCase();
               events.forEach(function(evt) {
                  if (evt.name.toLowerCase() === targetEv) {
                     if (evt.modifiers && arg && typeof arg === 'object') {
                        if (evt.modifiers.indexOf('stop') !== -1 && arg.stopPropagation) arg.stopPropagation();
                        if (evt.modifiers.indexOf('prevent') !== -1 && arg.preventDefault) arg.preventDefault();
                     }
                     let expr = evt.expr;
                     if (expr) {
                        let r = Data.Evaluate(expr, arg);
                        if (typeof r === 'function') {
                           try { r.call(Data.FData, Data.FData, arg); }
                           catch(e) { console.error("[Compiler] Event handler error:", e); }
                        } else if (Methods && typeof Methods[expr] === 'function') {
                           try { Methods[expr].call(Data.FData, Data.FData, arg); }
                           catch(e) { console.error("[Compiler] Method " + expr + " error:", e); }
                        }
                     }
                  }
               });
               if (window.__BV_DEVTOOLS_HOOK__) {
                  window.__BV_DEVTOOLS_HOOK__.emit('component:emit', { tag: tagName, event: ev, payload: arg });
               }
            };

            let cD = {
              FData: pRef,
              Evaluate: function(expr, ev) { 
                return bv.fastEval(this.FData, expr, ev);
              },
              SetValue: function(k, val) { bv.setDeepValue(this.FData, k, val); }
            };
            
            bv.traverse(rEl, cD, opts.methods);
            let stopEffect = bv.effect(function() {
               if (opts.updated) opts.updated.call(pRef, pRef);
            });

            if (opts.mounted) opts.mounted.call(pRef, pRef);
            if (window.__BV_DEVTOOLS_HOOK__) {
               window.__BV_DEVTOOLS_HOOK__.emit('component:mount', { tag: tagName, instance: pRef });
            }
            rEl['bvUnmount'] = function() {
               if (stopEffect && typeof stopEffect === 'function') stopEffect();
               if (opts.unmounted) opts.unmounted.call(pRef, pRef);
               if (window.__BV_DEVTOOLS_HOOK__) {
                  window.__BV_DEVTOOLS_HOOK__.emit('component:unmount', { tag: tagName, instance: pRef });
               }
            };

            return;
          }

          // 11. Event Listeners (@event)
          events.forEach(function(evt) {
             (function(expr, name, mods) {
                el.addEventListener(name, function(ev) {
                   if (mods) {
                      if (mods.indexOf('stop') !== -1 && ev.stopPropagation) ev.stopPropagation();
                      if (mods.indexOf('prevent') !== -1 && ev.preventDefault) ev.preventDefault();
                   }
                   let r = Data.Evaluate(expr, ev);
                   if (r === undefined && Methods && Methods[expr]) {
                      try { Methods[expr].call(Data.FData || null, Data.FData || null, ev); }
                      catch(ex) { console.error("[Compiler] Method " + expr + " error:", ex); }
                   } else if (typeof r === 'function') {
                      try { r.call(Data.FData || null, ev); }
                      catch(ex) { console.error("[Compiler] Method " + expr + " error:", ex); }
                   }
                }, false);
             })(evt.expr, evt.name, evt.modifiers);
          });

          // 12. Recursive Children
          let children = Array.from(Node.childNodes || []);
          for (let j = 0; j < children.length; j++) {
            let child = children[j];
            if (child && !child['bvManaged'] && !child['bvTraversed']) bv.traverse(child, Data, Methods);
          }
          
          Node['bvTraversed'] = true;
      } catch (ex) { console.error("[Compiler] Fatal Error: ", ex); }
    };
  end;

end.