var pas = { $libimports: {}};

var rtl = {

  version: 20301,

  quiet: false,
  debug_load_units: false,
  debug_rtti: false,

  $res : {},

  debug: function(){
    if (rtl.quiet || !console || !console.log) return;
    console.log(arguments);
  },

  error: function(s){
    rtl.debug('Error: ',s);
    throw s;
  },

  warn: function(s){
    rtl.debug('Warn: ',s);
  },

  checkVersion: function(v){
    if (rtl.version != v) throw "expected rtl version "+v+", but found "+rtl.version;
  },

  hiInt: Math.pow(2,53),

  hasString: function(s){
    return rtl.isString(s) && (s.length>0);
  },

  isArray: function(a) {
    return Array.isArray(a);
  },

  isFunction: function(f){
    return typeof(f)==="function";
  },

  isModule: function(m){
    return rtl.isObject(m) && rtl.hasString(m.$name) && (pas[m.$name]===m);
  },

  isImplementation: function(m){
    return rtl.isObject(m) && rtl.isModule(m.$module) && (m.$module.$impl===m);
  },

  isNumber: function(n){
    return typeof(n)==="number";
  },

  isObject: function(o){
    var s=typeof(o);
    return (typeof(o)==="object") && (o!=null);
  },

  isString: function(s){
    return typeof(s)==="string";
  },

  getNumber: function(n){
    return typeof(n)==="number"?n:NaN;
  },

  getChar: function(c){
    return ((typeof(c)==="string") && (c.length===1)) ? c : "";
  },

  getObject: function(o){
    return ((typeof(o)==="object") || (typeof(o)==='function')) ? o : null;
  },

  isTRecord: function(type){
    return (rtl.isObject(type) && type.hasOwnProperty('$new') && (typeof(type.$new)==='function'));
  },

  isPasClass: function(type){
    return (rtl.isObject(type) && type.hasOwnProperty('$classname') && rtl.isObject(type.$module));
  },

  isPasClassInstance: function(type){
    return (rtl.isObject(type) && rtl.isPasClass(type.$class));
  },

  hexStr: function(n,digits){
    return ("000000000000000"+n.toString(16).toUpperCase()).slice(-digits);
  },

  m_loading: 0,
  m_loading_intf: 1,
  m_intf_loaded: 2,
  m_loading_impl: 3, // loading all used unit
  m_initializing: 4, // running initialization
  m_initialized: 5,

  module: function(module_name, intfuseslist, intfcode, impluseslist){
    if (rtl.debug_load_units) rtl.debug('rtl.module name="'+module_name+'" intfuses='+intfuseslist+' impluses='+impluseslist);
    if (!rtl.hasString(module_name)) rtl.error('invalid module name "'+module_name+'"');
    if (!rtl.isArray(intfuseslist)) rtl.error('invalid interface useslist of "'+module_name+'"');
    if (!rtl.isFunction(intfcode)) rtl.error('invalid interface code of "'+module_name+'"');
    if (!(impluseslist==undefined) && !rtl.isArray(impluseslist)) rtl.error('invalid implementation useslist of "'+module_name+'"');

    if (pas[module_name])
      rtl.error('module "'+module_name+'" is already registered');

    var r = Object.create(rtl.tSectionRTTI);
    var module = r.$module = pas[module_name] = {
      $name: module_name,
      $intfuseslist: intfuseslist,
      $impluseslist: impluseslist,
      $state: rtl.m_loading,
      $intfcode: intfcode,
      $implcode: null,
      $impl: null,
      $rtti: r
    };
    if (impluseslist) module.$impl = {
          $module: module,
          $rtti: r
        };
  },

  exitcode: 0,

  run: function(module_name){
    try {
      if (!rtl.hasString(module_name)) module_name='program';
      if (rtl.debug_load_units) rtl.debug('rtl.run module="'+module_name+'"');
      rtl.initRTTI();
      var module = pas[module_name];
      if (!module) rtl.error('rtl.run module "'+module_name+'" missing');
      rtl.loadintf(module);
      rtl.loadimpl(module);
      if ((module_name=='program') || (module_name=='library')){
        if (rtl.debug_load_units) rtl.debug('running $main');
        var r = pas[module_name].$main();
        if (rtl.isNumber(r)) rtl.exitcode = r;
      }
    } catch(re) {
      if (!rtl.showUncaughtExceptions) {
        throw re
      } else {  
        if (!rtl.handleUncaughtException(re)) {
          rtl.showException(re);
          rtl.exitcode = 216;
        }  
      }
    } 
    return rtl.exitcode;
  },
  
  showException : function (re) {
    var errMsg = rtl.hasString(re.$classname) ? re.$classname : '';
    errMsg +=  ((errMsg) ? ': ' : '') + (re.hasOwnProperty('fMessage') ? re.fMessage : re);
    alert('Uncaught Exception : '+errMsg);
  },

  handleUncaughtException: function (e) {
    if (rtl.onUncaughtException) {
      try {
        rtl.onUncaughtException(e);
        return true;
      } catch (ee) {
        return false; 
      }
    } else {
      return false;
    }
  },

  loadintf: function(module){
    if (module.$state>rtl.m_loading_intf) return; // already finished
    if (rtl.debug_load_units) rtl.debug('loadintf: "'+module.$name+'"');
    if (module.$state===rtl.m_loading_intf)
      rtl.error('unit cycle detected "'+module.$name+'"');
    module.$state=rtl.m_loading_intf;
    // load interfaces of interface useslist
    rtl.loaduseslist(module,module.$intfuseslist,rtl.loadintf);
    // run interface
    if (rtl.debug_load_units) rtl.debug('loadintf: run intf of "'+module.$name+'"');
    module.$intfcode(module.$intfuseslist);
    // success
    module.$state=rtl.m_intf_loaded;
    // Note: units only used in implementations are not yet loaded (not even their interfaces)
  },

  loaduseslist: function(module,useslist,f){
    if (useslist==undefined) return;
    var len = useslist.length;
    for (var i = 0; i<len; i++) {
      var unitname=useslist[i];
      if (rtl.debug_load_units) rtl.debug('loaduseslist of "'+module.$name+'" uses="'+unitname+'"');
      if (pas[unitname]==undefined)
        rtl.error('module "'+module.$name+'" misses "'+unitname+'"');
      f(pas[unitname]);
    }
  },

  loadimpl: function(module){
    if (module.$state>=rtl.m_loading_impl) return; // already processing
    if (module.$state<rtl.m_intf_loaded) rtl.error('loadimpl: interface not loaded of "'+module.$name+'"');
    if (rtl.debug_load_units) rtl.debug('loadimpl: load uses of "'+module.$name+'"');
    module.$state=rtl.m_loading_impl;
    // load interfaces of implementation useslist
    rtl.loaduseslist(module,module.$impluseslist,rtl.loadintf);
    // load implementation of interfaces useslist
    rtl.loaduseslist(module,module.$intfuseslist,rtl.loadimpl);
    // load implementation of implementation useslist
    rtl.loaduseslist(module,module.$impluseslist,rtl.loadimpl);
    // Note: At this point all interfaces used by this unit are loaded. If
    //   there are implementation uses cycles some used units might not yet be
    //   initialized. This is by design.
    // run implementation
    if (rtl.debug_load_units) rtl.debug('loadimpl: run impl of "'+module.$name+'"');
    if (rtl.isFunction(module.$implcode)) module.$implcode(module.$impluseslist);
    // run initialization
    if (rtl.debug_load_units) rtl.debug('loadimpl: run init of "'+module.$name+'"');
    module.$state=rtl.m_initializing;
    if (rtl.isFunction(module.$init)) module.$init();
    // unit initialized
    module.$state=rtl.m_initialized;
  },

  createCallback: function(scope, fn){
    var cb;
    if (typeof(fn)==='string'){
      if (!scope.hasOwnProperty('$events')) scope.$events = {};
      cb = scope.$events[fn];
      if (cb) return cb;
      scope.$events[fn] = cb = function(){
        return scope[fn].apply(scope,arguments);
      };
    } else {
      cb = function(){
        return fn.apply(scope,arguments);
      };
    };
    cb.scope = scope;
    cb.fn = fn;
    return cb;
  },

  createSafeCallback: function(scope, fn){
    var cb;
    if (typeof(fn)==='string'){
      if (!scope.hasOwnProperty('$events')) scope.$events = {};
      cb = scope.$events[fn];
      if (cb) return cb;
      scope.$events[fn] = cb = function(){
        try{
          return scope[fn].apply(scope,arguments);
        } catch (err) {
          if (!rtl.handleUncaughtException(err)) throw err;
        }
      };
    } else {
      cb = function(){
        try{
          return fn.apply(scope,arguments);
        } catch (err) {
          if (!rtl.handleUncaughtException(err)) throw err;
        }
      };
    };
    cb.scope = scope;
    cb.fn = fn;
    return cb;
  },

  eqCallback: function(a,b){
    // can be a function or a function wrapper
    if (a===b){
      return true;
    } else {
      return (a!=null) && (b!=null) && (a.fn) && (a.scope===b.scope) && (a.fn===b.fn);
    }
  },

  initStruct: function(c,parent,name){
    if ((parent.$module) && (parent.$module.$impl===parent)) parent=parent.$module;
    c.$parent = parent;
    if (rtl.isModule(parent)){
      c.$module = parent;
      c.$name = name;
    } else {
      c.$module = parent.$module;
      c.$name = parent.$name+'.'+name;
    };
    return parent;
  },

  initClass: function(c,parent,name,initfn,rttiname){
    parent[name] = c;
    c.$class = c; // Note: o.$class === Object.getPrototypeOf(o)
    c.$classname = rttiname?rttiname:name;
    parent = rtl.initStruct(c,parent,name);
    c.$fullname = parent.$name+'.'+name;
    // rtti
    if (rtl.debug_rtti) rtl.debug('initClass '+c.$fullname);
    var t = c.$module.$rtti.$Class(c.$classname,{ "class": c });
    c.$rtti = t;
    if (rtl.isObject(c.$ancestor)) t.ancestor = c.$ancestor.$rtti;
    if (!t.ancestor) t.ancestor = null;
    // init members
    initfn.call(c);
  },

  createClass: function(parent,name,ancestor,initfn,rttiname){
    // create a normal class,
    // ancestor must be null or a normal class,
    // the root ancestor can be an external class
    var c = null;
    if (ancestor != null){
      c = Object.create(ancestor);
      c.$ancestor = ancestor;
      // Note:
      // if root is an "object" then c.$ancestor === Object.getPrototypeOf(c)
      // if root is a "function" then c.$ancestor === c.__proto__, Object.getPrototypeOf(c) returns the root
    } else {
      c = { $ancestor: null };
      c.$create = function(fn,args){
        if (args == undefined) args = [];
        var o = Object.create(this);
        o.$init();
        try{
          if (typeof(fn)==="string"){
            o[fn].apply(o,args);
          } else {
            fn.apply(o,args);
          };
          o.AfterConstruction();
        } catch($e){
          // do not call BeforeDestruction
          if (o.Destroy) o.Destroy();
          o.$final();
          throw $e;
        }
        return o;
      };
      c.$destroy = function(fnname){
        this.BeforeDestruction();
        if (this[fnname]) this[fnname]();
        this.$final();
      };
    };
    rtl.initClass(c,parent,name,initfn,rttiname);
  },

  createClassExt: function(parent,name,ancestor,newinstancefnname,initfn,rttiname){
    // Create a class using an external ancestor.
    // If newinstancefnname is given, use that function to create the new object.
    // If exist call BeforeDestruction and AfterConstruction.
    var isFunc = rtl.isFunction(ancestor);
    var c = null;
    if (isFunc){
      // create pascal class descendent from JS function
      c = Object.create(ancestor.prototype);
      c.$ancestorfunc = ancestor;
      c.$ancestor = null; // no pascal ancestor
    } else if (ancestor.$func){
      // create pascal class descendent from a pascal class descendent of a JS function
      isFunc = true;
      c = Object.create(ancestor);
      c.$ancestor = ancestor;
    } else {
      c = Object.create(ancestor);
      c.$ancestor = null; // no pascal ancestor
    }
    c.$create = function(fn,args){
      if (args == undefined) args = [];
      var o = null;
      if (newinstancefnname.length>0){
        o = this[newinstancefnname](fn,args);
      } else if(isFunc) {
        o = new this.$func(args);
      } else {
        o = Object.create(c);
      }
      if (o.$init) o.$init();
      try{
        if (typeof(fn)==="string"){
          this[fn].apply(o,args);
        } else {
          fn.apply(o,args);
        };
        if (o.AfterConstruction) o.AfterConstruction();
      } catch($e){
        // do not call BeforeDestruction
        if (o.Destroy) o.Destroy();
        if (o.$final) o.$final();
        throw $e;
      }
      return o;
    };
    c.$destroy = function(fnname){
      if (this.BeforeDestruction) this.BeforeDestruction();
      if (this[fnname]) this[fnname]();
      if (this.$final) this.$final();
    };
    rtl.initClass(c,parent,name,initfn,rttiname);
    if (isFunc){
      function f(){}
      f.prototype = c;
      c.$func = f;
    }
  },

  createHelper: function(parent,name,ancestor,initfn,rttiname){
    // create a helper,
    // ancestor must be null or a helper,
    var c = null;
    if (ancestor != null){
      c = Object.create(ancestor);
      c.$ancestor = ancestor;
      // c.$ancestor === Object.getPrototypeOf(c)
    } else {
      c = { $ancestor: null };
    };
    parent[name] = c;
    c.$class = c; // Note: o.$class === Object.getPrototypeOf(o)
    c.$classname = rttiname?rttiname:name;
    parent = rtl.initStruct(c,parent,name);
    c.$fullname = parent.$name+'.'+name;
    // rtti
    var t = c.$module.$rtti.$Helper(c.$classname,{ "helper": c });
    c.$rtti = t;
    if (rtl.isObject(ancestor)) t.ancestor = ancestor.$rtti;
    if (!t.ancestor) t.ancestor = null;
    // init members
    initfn.call(c);
  },

  tObjectDestroy: "Destroy",

  free: function(obj,name){
    if (obj[name]==null) return null;
    obj[name].$destroy(rtl.tObjectDestroy);
    obj[name]=null;
  },

  freeLoc: function(obj){
    if (obj==null) return null;
    obj.$destroy(rtl.tObjectDestroy);
    return null;
  },

  hideProp: function(o,p,v){
    Object.defineProperty(o,p, {
      enumerable: false,
      configurable: true,
      writable: true
    });
    if(arguments.length>2){ o[p]=v; }
  },

  recNewT: function(parent,name,initfn,full){
    // create new record type
    var t = {};
    if (parent) parent[name] = t;
    var h = rtl.hideProp;
    if (full){
      rtl.initStruct(t,parent,name);
      t.$record = t;
      h(t,'$record');
      h(t,'$name');
      h(t,'$parent');
      h(t,'$module');
      h(t,'$initSpec');
    }
    initfn.call(t);
    if (!t.$new){
      t.$new = function(){ return Object.create(t); };
    }
    t.$clone = function(r){ return t.$new().$assign(r); };
    h(t,'$new');
    h(t,'$clone');
    h(t,'$eq');
    h(t,'$assign');
    return t;
  },

  is: function(instance,type){
    return type.isPrototypeOf(instance) || (instance===type);
  },

  isExt: function(instance,type,mode){
    // mode===1 means instance must be a Pascal class instance
    // mode===2 means instance must be a Pascal class
    // Notes:
    // isPrototypeOf and instanceof return false on equal
    // isPrototypeOf does not work for Date.isPrototypeOf(new Date())
    //   so if isPrototypeOf is false test with instanceof
    // instanceof needs a function on right side
    if (instance == null) return false; // Note: ==null checks for undefined too
    if ((typeof(type) !== 'object') && (typeof(type) !== 'function')) return false;
    if (instance === type){
      if (mode===1) return false;
      if (mode===2) return rtl.isPasClass(instance);
      return true;
    }
    if (type.isPrototypeOf && type.isPrototypeOf(instance)){
      if (mode===1) return rtl.isPasClassInstance(instance);
      if (mode===2) return rtl.isPasClass(instance);
      return true;
    }
    if ((typeof type == 'function') && (instance instanceof type)) return true;
    return false;
  },

  Exception: null,
  EInvalidCast: null,
  EAbstractError: null,
  ERangeError: null,
  EIntOverflow: null,
  EPropWriteOnly: null,

  raiseE: function(typename){
    var t = rtl[typename];
    if (t==null){
      var mod = pas.SysUtils;
      if (!mod) mod = pas.sysutils;
      if (mod){
        t = mod[typename];
        if (!t) t = mod[typename.toLowerCase()];
        if (!t) t = mod['Exception'];
        if (!t) t = mod['exception'];
      }
    }
    if (t){
      if (t.Create){
        throw t.$create("Create");
      } else if (t.create){
        throw t.$create("create");
      }
    }
    if (typename === "EInvalidCast") throw "invalid type cast";
    if (typename === "EAbstractError") throw "Abstract method called";
    if (typename === "ERangeError") throw "range error";
    throw typename;
  },

  as: function(instance,type){
    if((instance === null) || rtl.is(instance,type)) return instance;
    rtl.raiseE("EInvalidCast");
  },

  asExt: function(instance,type,mode){
    if((instance === null) || rtl.isExt(instance,type,mode)) return instance;
    rtl.raiseE("EInvalidCast");
  },

  createInterface: function(module, name, guid, fnnames, ancestor, initfn, rttiname){
    //console.log('createInterface name="'+name+'" guid="'+guid+'" names='+fnnames);
    var i = ancestor?Object.create(ancestor):{};
    module[name] = i;
    i.$module = module;
    i.$name = rttiname?rttiname:name;
    i.$fullname = module.$name+'.'+i.$name;
    i.$guid = guid;
    i.$guidr = null;
    i.$names = fnnames?fnnames:[];
    if (rtl.isFunction(initfn)){
      // rtti
      if (rtl.debug_rtti) rtl.debug('createInterface '+i.$fullname);
      var t = i.$module.$rtti.$Interface(i.$name,{ "interface": i, module: module });
      i.$rtti = t;
      if (ancestor) t.ancestor = ancestor.$rtti;
      if (!t.ancestor) t.ancestor = null;
      initfn.call(i);
    }
    return i;
  },

  strToGUIDR: function(s,g){
    var p = 0;
    function n(l){
      var h = s.substr(p,l);
      p+=l;
      return parseInt(h,16);
    }
    p+=1; // skip {
    g.D1 = n(8);
    p+=1; // skip -
    g.D2 = n(4);
    p+=1; // skip -
    g.D3 = n(4);
    p+=1; // skip -
    if (!g.D4) g.D4=[];
    g.D4[0] = n(2);
    g.D4[1] = n(2);
    p+=1; // skip -
    for(var i=2; i<8; i++) g.D4[i] = n(2);
    return g;
  },

  guidrToStr: function(g){
    if (g.$intf) return g.$intf.$guid;
    var h = rtl.hexStr;
    var s='{'+h(g.D1,8)+'-'+h(g.D2,4)+'-'+h(g.D3,4)+'-'+h(g.D4[0],2)+h(g.D4[1],2)+'-';
    for (var i=2; i<8; i++) s+=h(g.D4[i],2);
    s+='}';
    return s;
  },

  createTGUID: function(guid){
    var TGuid = (pas.System)?pas.System.TGuid:pas.system.tguid;
    var g = rtl.strToGUIDR(guid,TGuid.$new());
    return g;
  },

  getIntfGUIDR: function(intfTypeOrVar){
    if (!intfTypeOrVar) return null;
    if (!intfTypeOrVar.$guidr){
      var g = rtl.createTGUID(intfTypeOrVar.$guid);
      if (!intfTypeOrVar.hasOwnProperty('$guid')) intfTypeOrVar = Object.getPrototypeOf(intfTypeOrVar);
      g.$intf = intfTypeOrVar;
      intfTypeOrVar.$guidr = g;
    }
    return intfTypeOrVar.$guidr;
  },

  addIntf: function (aclass, intf, map){
    function jmp(fn){
      if (typeof(fn)==="function"){
        return function(){ return fn.apply(this.$o,arguments); };
      } else {
        return function(){ rtl.raiseE('EAbstractError'); };
      }
    }
    if(!map) map = {};
    var t = intf;
    var item = Object.create(t);
    if (!aclass.hasOwnProperty('$intfmaps')) aclass.$intfmaps = {};
    aclass.$intfmaps[intf.$guid] = item;
    do{
      var names = t.$names;
      if (!names) break;
      for (var i=0; i<names.length; i++){
        var intfname = names[i];
        var fnname = map[intfname];
        if (!fnname) fnname = intfname;
        //console.log('addIntf: intftype='+t.$name+' index='+i+' intfname="'+intfname+'" fnname="'+fnname+'" old='+typeof(item[intfname]));
        item[intfname] = jmp(aclass[fnname]);
      }
      t = Object.getPrototypeOf(t);
    }while(t!=null);
  },

  getIntfG: function (obj, guid, query){
    if (!obj) return null;
    //console.log('getIntfG: obj='+obj.$classname+' guid='+guid+' query='+query);
    // search
    var maps = obj.$intfmaps;
    if (!maps) return null;
    var item = maps[guid];
    if (!item) return null;
    // check delegation
    //console.log('getIntfG: obj='+obj.$classname+' guid='+guid+' query='+query+' item='+typeof(item));
    if (typeof item === 'function') return item.call(obj); // delegate. Note: COM contains _AddRef
    // check cache
    var intf = null;
    if (obj.$interfaces){
      intf = obj.$interfaces[guid];
      //console.log('getIntfG: obj='+obj.$classname+' guid='+guid+' cache='+typeof(intf));
    }
    if (!intf){ // intf can be undefined!
      intf = Object.create(item);
      intf.$o = obj;
      if (!obj.$interfaces) obj.$interfaces = {};
      obj.$interfaces[guid] = intf;
    }
    if (typeof(query)==='object'){
      // called by queryIntfT
      var o = null;
      if (intf.QueryInterface(rtl.getIntfGUIDR(query),
          {get:function(){ return o; }, set:function(v){ o=v; }}) === 0){
        return o;
      } else {
        return null;
      }
    } else if(query===2){
      // called by TObject.GetInterfaceByStr
      if (intf.$kind === 'com') intf._AddRef();
    }
    return intf;
  },

  getIntfT: function(obj,intftype){
    return rtl.getIntfG(obj,intftype.$guid);
  },

  queryIntfT: function(obj,intftype){
    // query COM intf, called _AddRef
    return rtl.getIntfG(obj,intftype.$guid,intftype);
  },

  queryIntfR: function(obj,intftype){
    // query COM intf, immediate release
    return rtl._Release(rtl.getIntfG(obj,intftype.$guid,intftype));
  },

  queryIntfIsT: function(obj,intftype){
    var i = rtl.getIntfG(obj,intftype.$guid);
    if (!i) return false;
    if (i.$kind === 'com') i._Release();
    return true;
  },

  asIntfT: function (obj,intftype){
    var i = rtl.getIntfG(obj,intftype.$guid);
    if (i!==null) return i;
    rtl.raiseEInvalidCast();
  },

  intfIsIntfT: function(intf,intftype){
    return (intf!==null) && rtl.queryIntfIsT(intf.$o,intftype);
  },

  intfAsIntfT: function (intf,intftype){
    if (!intf) return null;
    var i = rtl.getIntfG(intf.$o,intftype.$guid);
    if (i) return i;
    rtl.raiseEInvalidCast();
  },

  intfIsClass: function(intf,classtype){
    return (intf!=null) && (rtl.is(intf.$o,classtype));
  },

  intfAsClass: function(intf,classtype){
    if (intf==null) return null;
    return rtl.as(intf.$o,classtype);
  },

  intfToClass: function(intf,classtype){
    if ((intf!==null) && rtl.is(intf.$o,classtype)) return intf.$o;
    return null;
  },

  // interface reference counting
  intfRefs: { // base object for temporary interface variables
    ref: function(id,intf){
      // called for temporary interface references needing delayed release
      var old = this[id];
      //console.log('rtl.intfRefs.ref: id='+id+' old="'+(old?old.$name:'null')+'" intf="'+(intf?intf.$name:'null')+' $o='+(intf?intf.$o:'null'));
      if (old){
        // called again, e.g. in a loop
        delete this[id];
        old._Release(); // may fail
      }
      if(intf) {
        this[id]=intf;
      }
      return intf;
    },
    free: function(){
      //console.log('rtl.intfRefs.free...');
      for (var id in this){
        if (this.hasOwnProperty(id)){
          var intf = this[id];
          if (intf){
            //console.log('rtl.intfRefs.free: id='+id+' '+intf.$name+' $o='+intf.$o.$classname);
            intf._Release();
          }
        }
      }
    }
  },

  createIntfRefs: function(){
    //console.log('rtl.createIntfRefs');
    return Object.create(rtl.intfRefs);
  },

  setIntfP: function(path,name,value,skipAddRef){
    var old = path[name];
    //console.log('rtl.setIntfP path='+path+' name='+name+' old="'+(old?old.$name:'null')+'" value="'+(value?value.$name:'null')+'"');
    if (old === value) return;
    if (old !== null){
      path[name]=null;
      old._Release();
    }
    if (value !== null){
      if (!skipAddRef) value._AddRef();
      path[name]=value;
    }
  },

  setIntfL: function(old,value,skipAddRef){
    //console.log('rtl.setIntfL old="'+(old?old.$name:'null')+'" value="'+(value?value.$name:'null')+'"');
    if (old !== value){
      if (value!==null){
        if (!skipAddRef) value._AddRef();
      }
      if (old!==null){
        old._Release();  // Release after AddRef, to avoid double Release if Release creates an exception
      }
    } else if (skipAddRef){
      if (old!==null){
        old._Release();  // value has an AddRef
      }
    }
    return value;
  },

  _AddRef: function(intf){
    //if (intf) console.log('rtl._AddRef intf="'+(intf?intf.$name:'null')+'"');
    if (intf) intf._AddRef();
    return intf;
  },

  _Release: function(intf){
    //if (intf) console.log('rtl._Release intf="'+(intf?intf.$name:'null')+'"');
    if (intf) intf._Release();
    return intf;
  },

  _ReleaseArray: function(a,dim){
    if (!a) return null;
    for (var i=0; i<a.length; i++){
      if (dim<=1){
        if (a[i]) a[i]._Release();
      } else {
        rtl._ReleaseArray(a[i],dim-1);
      }
    }
    return null;
  },

  trunc: function(a){
    return a<0 ? Math.ceil(a) : Math.floor(a);
  },

  checkMethodCall: function(obj,type){
    if (rtl.isObject(obj) && rtl.is(obj,type)) return;
    rtl.raiseE("EInvalidCast");
  },

  oc: function(i){
    // overflow check integer
    if ((Math.floor(i)===i) && (i>=-0x1fffffffffffff) && (i<=0x1fffffffffffff)) return i;
    rtl.raiseE('EIntOverflow');
  },

  rc: function(i,minval,maxval){
    // range check integer
    if ((Math.floor(i)===i) && (i>=minval) && (i<=maxval)) return i;
    rtl.raiseE('ERangeError');
  },

  rcc: function(c,minval,maxval){
    // range check char
    if ((typeof(c)==='string') && (c.length===1)){
      var i = c.charCodeAt(0);
      if ((i>=minval) && (i<=maxval)) return c;
    }
    rtl.raiseE('ERangeError');
  },

  rcSetCharAt: function(s,index,c){
    // range check setCharAt
    if ((typeof(s)!=='string') || (index<0) || (index>=s.length)) rtl.raiseE('ERangeError');
    return rtl.setCharAt(s,index,c);
  },

  rcCharAt: function(s,index){
    // range check charAt
    if ((typeof(s)!=='string') || (index<0) || (index>=s.length)) rtl.raiseE('ERangeError');
    return s.charAt(index);
  },

  rcArrR: function(arr,index){
    // range check read array
    if (Array.isArray(arr) && (typeof(index)==='number') && (index>=0) && (index<arr.length)){
      if (arguments.length>2){
        // arr,index1,index2,...
        arr=arr[index];
        for (var i=2; i<arguments.length; i++) arr=rtl.rcArrR(arr,arguments[i]);
        return arr;
      }
      return arr[index];
    }
    rtl.raiseE('ERangeError');
  },

  rcArrW: function(arr,index,value){
    // range check write array
    // arr,index1,index2,...,value
    for (var i=3; i<arguments.length; i++){
      arr=rtl.rcArrR(arr,index);
      index=arguments[i-1];
      value=arguments[i];
    }
    if (Array.isArray(arr) && (typeof(index)==='number') && (index>=0) && (index<arr.length)){
      return arr[index]=value;
    }
    rtl.raiseE('ERangeError');
  },

  length: function(arr){
    return (arr == null) ? 0 : arr.length;
  },

  arrayRef: function(a){
    if (a!=null) rtl.hideProp(a,'$pas2jsrefcnt',1);
    return a;
  },

  arraySetLength: function(arr,defaultvalue,newlength){
    var stack = [];
    var s = 9999;
    for (var i=2; i<arguments.length; i++){
      var j = arguments[i];
      if (j==='s'){ s = i-2; }
      else {
        stack.push({ dim:j+0, a:null, i:0, src:null });
      }
    }
    var dimmax = stack.length-1;
    var depth = 0;
    var lastlen = 0;
    var item = null;
    var a = null;
    var src = arr;
    var srclen = 0, oldlen = 0;
    do{
      if (depth>0){
        item=stack[depth-1];
        src = (item.src && item.src.length>item.i)?item.src[item.i]:null;
      }
      if (!src){
        a = [];
        srclen = 0;
        oldlen = 0;
      } else if (src.$pas2jsrefcnt>0 || depth>=s){
        a = [];
        srclen = src.length;
        oldlen = srclen;
      } else {
        a = src;
        srclen = 0;
        oldlen = a.length;
      }
      lastlen = stack[depth].dim;
      a.length = lastlen;
      if (depth>0){
        item.a[item.i]=a;
        item.i++;
        if ((lastlen===0) && (item.i<item.a.length)) continue;
      }
      if (lastlen>0){
        if (depth<dimmax){
          item = stack[depth];
          item.a = a;
          item.i = 0;
          item.src = src;
          depth++;
          continue;
        } else {
          if (srclen>lastlen) srclen=lastlen;
          if (rtl.isArray(defaultvalue)){
            // array of dyn array
            for (var i=0; i<srclen; i++) a[i]=src[i];
            for (var i=oldlen; i<lastlen; i++) a[i]=[];
          } else if (rtl.isObject(defaultvalue)) {
            if (rtl.isTRecord(defaultvalue)){
              // array of record
              for (var i=0; i<srclen; i++) a[i]=defaultvalue.$clone(src[i]);
              for (var i=oldlen; i<lastlen; i++) a[i]=defaultvalue.$new();
            } else {
              // array of set
              for (var i=0; i<srclen; i++) a[i]=rtl.refSet(src[i]);
              for (var i=oldlen; i<lastlen; i++) a[i]={};
            }
          } else {
            for (var i=0; i<srclen; i++) a[i]=src[i];
            for (var i=oldlen; i<lastlen; i++) a[i]=defaultvalue;
          }
        }
      }
      // backtrack
      while ((depth>0) && (stack[depth-1].i>=stack[depth-1].dim)){
        depth--;
      };
      if (depth===0){
        if (dimmax===0) return a;
        return stack[0].a;
      }
    }while (true);
  },

  arrayEq: function(a,b){
    if (a===null) return b===null;
    if (b===null) return false;
    if (a.length!==b.length) return false;
    for (var i=0; i<a.length; i++) if (a[i]!==b[i]) return false;
    return true;
  },

  arrayClone: function(type,src,srcpos,endpos,dst,dstpos){
    // type: 0 for references, "refset" for calling refSet(), a function for new type()
    // src must not be null
    // This function does not range check.
    if(type === 'refSet') {
      for (; srcpos<endpos; srcpos++) dst[dstpos++] = rtl.refSet(src[srcpos]); // ref set
    } else if (type === 'slice'){
      for (; srcpos<endpos; srcpos++) dst[dstpos++] = src[srcpos].slice(0); // clone static array of simple types
    } else if (typeof(type)==='function'){
      for (; srcpos<endpos; srcpos++) dst[dstpos++] = type(src[srcpos]); // clone function
    } else if (rtl.isTRecord(type)){
      for (; srcpos<endpos; srcpos++) dst[dstpos++] = type.$clone(src[srcpos]); // clone record
    }  else {
      for (; srcpos<endpos; srcpos++) dst[dstpos++] = src[srcpos]; // reference
    };
  },

  arrayConcat: function(type){
    // type: see rtl.arrayClone
    var a = [];
    var l = 0;
    for (var i=1; i<arguments.length; i++){
      var src = arguments[i];
      if (src !== null) l+=src.length;
    };
    a.length = l;
    l=0;
    for (var i=1; i<arguments.length; i++){
      var src = arguments[i];
      if (src === null) continue;
      rtl.arrayClone(type,src,0,src.length,a,l);
      l+=src.length;
    };
    return a;
  },

  arrayConcatN: function(){
    var a = null;
    for (var i=0; i<arguments.length; i++){
      var src = arguments[i];
      if (src === null) continue;
      if (a===null){
        a=rtl.arrayRef(src); // Note: concat(a) does not clone
      } else if (a['$pas2jsrefcnt']){
        a=a.concat(src); // clone a and append src
      } else {
        for (var i=0; i<src.length; i++){
          a.push(src[i]);
        }
      }
    };
    return a;
  },

  arrayPush: function(type,a){
    if(a===null){
      a=[];
    } else if (a['$pas2jsrefcnt']){
      a=rtl.arrayCopy(type,a,0,a.length);
    }
    rtl.arrayClone(type,arguments,2,arguments.length,a,a.length);
    return a;
  },

  arrayPushN: function(a){
    if(a===null){
      a=[];
    } else if (a['$pas2jsrefcnt']){
      a=a.concat();
    }
    for (var i=1; i<arguments.length; i++){
      a.push(arguments[i]);
    }
    return a;
  },

  arrayCopy: function(type, srcarray, index, count){
    // type: see rtl.arrayClone
    // if count is missing, use srcarray.length
    if (srcarray === null) return [];
    if (index < 0) index = 0;
    if (count === undefined) count=srcarray.length;
    var end = index+count;
    if (end>srcarray.length) end = srcarray.length;
    if (index>=end) return [];
    if (type===0){
      return srcarray.slice(index,end);
    } else {
      var a = [];
      a.length = end-index;
      rtl.arrayClone(type,srcarray,index,end,a,0);
      return a;
    }
  },

  arrayInsert: function(item, arr, index){
    if (arr){
      arr.splice(index,0,item);
      return arr;
    } else {
      return [item];
    }
  },

  setCharAt: function(s,index,c){
    return s.substr(0,index)+c+s.substr(index+1);
  },

  getResStr: function(mod,name){
    var rs = mod.$resourcestrings[name];
    return rs.current?rs.current:rs.org;
  },

  createSet: function(){
    var s = {};
    for (var i=0; i<arguments.length; i++){
      if (arguments[i]!=null){
        s[arguments[i]]=true;
      } else {
        var first=arguments[i+=1];
        var last=arguments[i+=1];
        for(var j=first; j<=last; j++) s[j]=true;
      }
    }
    return s;
  },

  cloneSet: function(s){
    var r = {};
    for (var key in s) r[key]=true;
    return r;
  },

  refSet: function(s){
    rtl.hideProp(s,'$shared',true);
    return s;
  },

  includeSet: function(s,enumvalue){
    if (s.$shared) s = rtl.cloneSet(s);
    s[enumvalue] = true;
    return s;
  },

  excludeSet: function(s,enumvalue){
    if (s.$shared) s = rtl.cloneSet(s);
    delete s[enumvalue];
    return s;
  },

  diffSet: function(s,t){
    var r = {};
    for (var key in s) if (!t[key]) r[key]=true;
    return r;
  },

  unionSet: function(s,t){
    var r = {};
    for (var key in s) r[key]=true;
    for (var key in t) r[key]=true;
    return r;
  },

  intersectSet: function(s,t){
    var r = {};
    for (var key in s) if (t[key]) r[key]=true;
    return r;
  },

  symDiffSet: function(s,t){
    var r = {};
    for (var key in s) if (!t[key]) r[key]=true;
    for (var key in t) if (!s[key]) r[key]=true;
    return r;
  },

  eqSet: function(s,t){
    for (var key in s) if (!t[key]) return false;
    for (var key in t) if (!s[key]) return false;
    return true;
  },

  neSet: function(s,t){
    return !rtl.eqSet(s,t);
  },

  leSet: function(s,t){
    for (var key in s) if (!t[key]) return false;
    return true;
  },

  geSet: function(s,t){
    for (var key in t) if (!s[key]) return false;
    return true;
  },

  strSetLength: function(s,newlen){
    var oldlen = s.length;
    if (oldlen > newlen){
      return s.substring(0,newlen);
    } else if (s.repeat){
      // Note: repeat needs ECMAScript6!
      return s+' '.repeat(newlen-oldlen);
    } else {
       while (oldlen<newlen){
         s+=' ';
         oldlen++;
       };
       return s;
    }
  },

  spaceLeft: function(s,width){
    var l=s.length;
    if (l>=width) return s;
    if (s.repeat){
      // Note: repeat needs ECMAScript6!
      return ' '.repeat(width-l) + s;
    } else {
      while (l<width){
        s=' '+s;
        l++;
      };
      return s;
    };
  },

  floatToStr: function(d,w,p){
    // input 1-3 arguments: double, width, precision
    if (arguments.length>2){
      return rtl.spaceLeft(d.toFixed(p),w);
    } else {
	  // exponent width
	  var pad = "";
	  var ad = Math.abs(d);
	  if (((ad>1) && (ad<1.0e+10)) ||  ((ad>1.e-10) && (ad<1))) {
		pad='00';
	  } else if ((ad>1) && (ad<1.0e+100) || (ad<1.e-10)) {
		pad='0';
      }  	
	  if (arguments.length<2) {
	    w=24;		
      } else if (w<9) {
		w=9;
      }		  
      var p = w-8;
      var s=(d>0 ? " " : "" ) + d.toExponential(p);
      s=s.replace(/e(.)/,'E$1'+pad);
      return rtl.spaceLeft(s,w);
    }
  },

  valEnum: function(s, enumType, setCodeFn){
    s = s.toLowerCase();
    for (var key in enumType){
      if((typeof(key)==='string') && (key.toLowerCase()===s)){
        setCodeFn(0);
        return enumType[key];
      }
    }
    setCodeFn(1);
    return 0;
  },

  lw: function(l){
    // fix longword bitwise operation
    return l<0?l+0x100000000:l;
  },

  and: function(a,b){
    var hi = 0x80000000;
    var low = 0x7fffffff;
    var h = (a / hi) & (b / hi);
    var l = (a & low) & (b & low);
    return h*hi + l;
  },

  or: function(a,b){
    var hi = 0x80000000;
    var low = 0x7fffffff;
    var h = (a / hi) | (b / hi);
    var l = (a & low) | (b & low);
    return h*hi + l;
  },

  xor: function(a,b){
    var hi = 0x80000000;
    var low = 0x7fffffff;
    var h = (a / hi) ^ (b / hi);
    var l = (a & low) ^ (b & low);
    return h*hi + l;
  },

  shr: function(a,b){
    if (a<0) a += rtl.hiInt;
    if (a<0x80000000) return a >> b;
    if (b<=0) return a;
    if (b>54) return 0;
    return Math.floor(a / Math.pow(2,b));
  },

  shl: function(a,b){
    if (a<0) a += rtl.hiInt;
    if (b<=0) return a;
    if (b>54) return 0;
    var r = a * Math.pow(2,b);
    if (r <= rtl.hiInt) return r;
    return r % rtl.hiInt;
  },

  initRTTI: function(){
    if (rtl.debug_rtti) rtl.debug('initRTTI');

    // base types
    rtl.tTypeInfo = { name: "tTypeInfo", kind: 0, $module: null, attr: null };
    function newBaseTI(name,kind,ancestor){
      if (!ancestor) ancestor = rtl.tTypeInfo;
      if (rtl.debug_rtti) rtl.debug('initRTTI.newBaseTI "'+name+'" '+kind+' ("'+ancestor.name+'")');
      var t = Object.create(ancestor);
      t.name = name;
      t.kind = kind;
      rtl[name] = t;
      return t;
    };
    function newBaseInt(name,minvalue,maxvalue,ordtype){
      var t = newBaseTI(name,1 /* tkInteger */,rtl.tTypeInfoInteger);
      t.minvalue = minvalue;
      t.maxvalue = maxvalue;
      t.ordtype = ordtype;
      return t;
    };
    newBaseTI("tTypeInfoInteger",1 /* tkInteger */);
    newBaseInt("shortint",-0x80,0x7f,0);
    newBaseInt("byte",0,0xff,1);
    newBaseInt("smallint",-0x8000,0x7fff,2);
    newBaseInt("word",0,0xffff,3);
    newBaseInt("longint",-0x80000000,0x7fffffff,4);
    newBaseInt("longword",0,0xffffffff,5);
    newBaseInt("nativeint",-0x10000000000000,0xfffffffffffff,6);
    newBaseInt("nativeuint",0,0xfffffffffffff,7);
    newBaseTI("char",2 /* tkChar */);
    newBaseTI("string",3 /* tkString */);
    newBaseTI("tTypeInfoEnum",4 /* tkEnumeration */,rtl.tTypeInfoInteger);
    newBaseTI("tTypeInfoSet",5 /* tkSet */);
    newBaseTI("double",6 /* tkDouble */);
    newBaseTI("boolean",7 /* tkBool */);
    newBaseTI("tTypeInfoProcVar",8 /* tkProcVar */);
    newBaseTI("tTypeInfoMethodVar",9 /* tkMethod */,rtl.tTypeInfoProcVar);
    newBaseTI("tTypeInfoArray",10 /* tkArray */);
    newBaseTI("tTypeInfoDynArray",11 /* tkDynArray */);
    newBaseTI("tTypeInfoPointer",15 /* tkPointer */);
    var t = newBaseTI("pointer",15 /* tkPointer */,rtl.tTypeInfoPointer);
    t.reftype = null;
    newBaseTI("jsvalue",16 /* tkJSValue */);
    newBaseTI("tTypeInfoRefToProcVar",17 /* tkRefToProcVar */,rtl.tTypeInfoProcVar);

    // member kinds
    rtl.tTypeMember = { attr: null };
    function newMember(name,kind){
      var m = Object.create(rtl.tTypeMember);
      m.name = name;
      m.kind = kind;
      rtl[name] = m;
    };
    newMember("tTypeMemberField",1); // tmkField
    newMember("tTypeMemberMethod",2); // tmkMethod
    newMember("tTypeMemberProperty",3); // tmkProperty

    // base object for storing members: a simple object
    rtl.tTypeMembers = {};

    // tTypeInfoStruct - base object for tTypeInfoClass, tTypeInfoRecord, tTypeInfoInterface
    var tis = newBaseTI("tTypeInfoStruct",0);
    tis.$addMember = function(name,ancestor,options){
      if (rtl.debug_rtti){
        if (!rtl.hasString(name) || (name.charAt()==='$')) throw 'invalid member "'+name+'", this="'+this.name+'"';
        if (!rtl.is(ancestor,rtl.tTypeMember)) throw 'invalid ancestor "'+ancestor+':'+ancestor.name+'", "'+this.name+'.'+name+'"';
        if ((options!=undefined) && (typeof(options)!='object')) throw 'invalid options "'+options+'", "'+this.name+'.'+name+'"';
      };
      var t = Object.create(ancestor);
      t.name = name;
      this.members[name] = t;
      this.names.push(name);
      if (rtl.isObject(options)){
        for (var key in options) if (options.hasOwnProperty(key)) t[key] = options[key];
      };
      return t;
    };
    tis.addField = function(name,type,options){
      var t = this.$addMember(name,rtl.tTypeMemberField,options);
      if (rtl.debug_rtti){
        if (!rtl.is(type,rtl.tTypeInfo)) throw 'invalid type "'+type+'", "'+this.name+'.'+name+'"';
      };
      t.typeinfo = type;
      this.fields.push(name);
      return t;
    };
    tis.addFields = function(){
      var i=0;
      while(i<arguments.length){
        var name = arguments[i++];
        var type = arguments[i++];
        if ((i<arguments.length) && (typeof(arguments[i])==='object')){
          this.addField(name,type,arguments[i++]);
        } else {
          this.addField(name,type);
        };
      };
    };
    tis.addMethod = function(name,methodkind,params,result,flags,options){
      var t = this.$addMember(name,rtl.tTypeMemberMethod,options);
      t.methodkind = methodkind;
      t.procsig = rtl.newTIProcSig(params,result,flags);
      this.methods.push(name);
      return t;
    };
    tis.addProperty = function(name,flags,result,getter,setter,options){
      var t = this.$addMember(name,rtl.tTypeMemberProperty,options);
      t.flags = flags;
      t.typeinfo = result;
      t.getter = getter;
      t.setter = setter;
      // Note: in options: params, stored, defaultvalue
      t.params = rtl.isArray(t.params) ? rtl.newTIParams(t.params) : null;
      this.properties.push(name);
      if (!rtl.isString(t.stored)) t.stored = "";
      return t;
    };
    tis.getField = function(index){
      return this.members[this.fields[index]];
    };
    tis.getMethod = function(index){
      return this.members[this.methods[index]];
    };
    tis.getProperty = function(index){
      return this.members[this.properties[index]];
    };

    newBaseTI("tTypeInfoRecord",12 /* tkRecord */,rtl.tTypeInfoStruct);
    newBaseTI("tTypeInfoClass",13 /* tkClass */,rtl.tTypeInfoStruct);
    newBaseTI("tTypeInfoClassRef",14 /* tkClassRef */);
    newBaseTI("tTypeInfoInterface",18 /* tkInterface */,rtl.tTypeInfoStruct);
    newBaseTI("tTypeInfoHelper",19 /* tkHelper */,rtl.tTypeInfoStruct);
    newBaseTI("tTypeInfoExtClass",20 /* tkExtClass */,rtl.tTypeInfoClass);
  },

  tSectionRTTI: {
    $module: null,
    $inherited: function(name,ancestor,o){
      if (rtl.debug_rtti){
        rtl.debug('tSectionRTTI.newTI "'+(this.$module?this.$module.$name:"(no module)")
          +'"."'+name+'" ('+ancestor.name+') '+(o?'init':'forward'));
      };
      var t = this[name];
      if (t){
        if (!t.$forward) throw 'duplicate type "'+name+'"';
        if (!ancestor.isPrototypeOf(t)) throw 'typeinfo ancestor mismatch "'+name+'" ancestor="'+ancestor.name+'" t.name="'+t.name+'"';
      } else {
        t = Object.create(ancestor);
        t.name = name;
        t.$module = this.$module;
        this[name] = t;
      }
      if (o){
        delete t.$forward;
        for (var key in o) if (o.hasOwnProperty(key)) t[key]=o[key];
      } else {
        t.$forward = true;
      }
      return t;
    },
    $Scope: function(name,ancestor,o){
      var t=this.$inherited(name,ancestor,o);
      t.members = {};
      t.names = [];
      t.fields = [];
      t.methods = [];
      t.properties = [];
      return t;
    },
    $TI: function(name,kind,o){ var t=this.$inherited(name,rtl.tTypeInfo,o); t.kind = kind; return t; },
    $Int: function(name,o){ return this.$inherited(name,rtl.tTypeInfoInteger,o); },
    $Enum: function(name,o){ return this.$inherited(name,rtl.tTypeInfoEnum,o); },
    $Set: function(name,o){ return this.$inherited(name,rtl.tTypeInfoSet,o); },
    $StaticArray: function(name,o){ return this.$inherited(name,rtl.tTypeInfoArray,o); },
    $DynArray: function(name,o){ return this.$inherited(name,rtl.tTypeInfoDynArray,o); },
    $ProcVar: function(name,o){ return this.$inherited(name,rtl.tTypeInfoProcVar,o); },
    $RefToProcVar: function(name,o){ return this.$inherited(name,rtl.tTypeInfoRefToProcVar,o); },
    $MethodVar: function(name,o){ return this.$inherited(name,rtl.tTypeInfoMethodVar,o); },
    $Record: function(name,o){ return this.$Scope(name,rtl.tTypeInfoRecord,o); },
    $Class: function(name,o){ return this.$Scope(name,rtl.tTypeInfoClass,o); },
    $ClassRef: function(name,o){ return this.$inherited(name,rtl.tTypeInfoClassRef,o); },
    $Pointer: function(name,o){ return this.$inherited(name,rtl.tTypeInfoPointer,o); },
    $Interface: function(name,o){ return this.$Scope(name,rtl.tTypeInfoInterface,o); },
    $Helper: function(name,o){ return this.$Scope(name,rtl.tTypeInfoHelper,o); },
    $ExtClass: function(name,o){ return this.$Scope(name,rtl.tTypeInfoExtClass,o); }
  },

  newTIParam: function(param){
    // param is an array, 0=name, 1=type, 2=optional flags
    var t = {
      name: param[0],
      typeinfo: param[1],
      flags: (rtl.isNumber(param[2]) ? param[2] : 0)
    };
    return t;
  },

  newTIParams: function(list){
    // list: optional array of [paramname,typeinfo,optional flags]
    var params = [];
    if (rtl.isArray(list)){
      for (var i=0; i<list.length; i++) params.push(rtl.newTIParam(list[i]));
    };
    return params;
  },

  newTIProcSig: function(params,result,flags){
    var s = {
      params: rtl.newTIParams(params),
      resulttype: result?result:null,
      flags: flags?flags:0
    };
    return s;
  },

  addResource: function(aRes){
    rtl.$res[aRes.name]=aRes;
  },

  getResource: function(aName){
    var res = rtl.$res[aName];
    if (res !== undefined) {
      return res;
    } else {
      return null;
    }
  },

  getResourceList: function(){
    return Object.keys(rtl.$res);
  }
}

rtl.module("System",[],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"TObject",null,function () {
    this.$init = function () {
    };
    this.$final = function () {
    };
    this.Create = function () {
      return this;
    };
    this.Destroy = function () {
    };
    this.Free = function () {
      this.$destroy("Destroy");
    };
    this.FieldAddress = function (aName) {
      var Result = null;
      Result = null;
      if (aName === "") return Result;
      var aClass = this.$class;
      var ClassTI = null;
      var myName = aName.toLowerCase();
      var MemberTI = null;
      while (aClass !== null) {
        ClassTI = aClass.$rtti;
        for (var i = 0, $end2 = ClassTI.fields.length - 1; i <= $end2; i++) {
          MemberTI = ClassTI.getField(i);
          if (MemberTI.name.toLowerCase() === myName) {
             return MemberTI;
          };
        };
        aClass = aClass.$ancestor ? aClass.$ancestor : null;
      };
      return Result;
    };
    this.AfterConstruction = function () {
    };
    this.BeforeDestruction = function () {
    };
  });
  this.vtInteger = 0;
  this.vtExtended = 3;
  this.vtWideChar = 9;
  this.vtCurrency = 12;
  this.vtUnicodeString = 18;
  this.vtNativeInt = 19;
  rtl.recNewT(this,"TVarRec",function () {
    this.VType = 0;
    this.VJSValue = undefined;
    this.$eq = function (b) {
      return (this.VType === b.VType) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue) && (this.VJSValue === b.VJSValue);
    };
    this.$assign = function (s) {
      this.VType = s.VType;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      this.VJSValue = s.VJSValue;
      return this;
    };
  });
  this.VarRecs = function () {
    var Result = [];
    var i = 0;
    var v = null;
    Result = [];
    while (i < arguments.length) {
      v = $mod.TVarRec.$new();
      v.VType = rtl.trunc(arguments[i]);
      i += 1;
      v.VJSValue = arguments[i];
      i += 1;
      Result.push($mod.TVarRec.$clone(v));
    };
    return Result;
  };
  this.IsConsole = false;
  this.OnParamCount = null;
  this.OnParamStr = null;
  this.Trunc = function (A) {
    if (!Math.trunc) {
      Math.trunc = function(v) {
        v = +v;
        if (!isFinite(v)) return v;
        return (v - v % 1) || (v < 0 ? -0 : v === 0 ? v : 0);
      };
    }
    $mod.Trunc = Math.trunc;
    return Math.trunc(A);
  };
  this.Int = function (A) {
    var Result = 0.0;
    Result = $mod.Trunc(A);
    return Result;
  };
  this.Copy = function (S, Index, Size) {
    if (Index<1) Index = 1;
    return (Size>0) ? S.substring(Index-1,Index+Size-1) : "";
  };
  this.Copy$1 = function (S, Index) {
    if (Index<1) Index = 1;
    return S.substr(Index-1);
  };
  this.Delete = function (S, Index, Size) {
    var h = "";
    if ((Index < 1) || (Index > S.get().length) || (Size <= 0)) return;
    h = S.get();
    S.set($mod.Copy(h,1,Index - 1) + $mod.Copy$1(h,Index + Size));
  };
  this.Pos = function (Search, InString) {
    return InString.indexOf(Search)+1;
  };
  this.Insert = function (Insertion, Target, Index) {
    var t = "";
    if (Insertion === "") return;
    t = Target.get();
    if (Index < 1) {
      Target.set(Insertion + t)}
     else if (Index > t.length) {
      Target.set(t + Insertion)}
     else Target.set($mod.Copy(t,1,Index - 1) + Insertion + $mod.Copy(t,Index,t.length));
  };
  this.upcase = function (c) {
    return c.toUpperCase();
  };
  this.val = function (S, NI, Code) {
    NI.set($impl.valint(S,-9007199254740991,9007199254740991,Code));
  };
  this.StringOfChar = function (c, l) {
    var Result = "";
    var i = 0;
    if ((l>0) && c.repeat) return c.repeat(l);
    Result = "";
    for (var $l = 1, $end = l; $l <= $end; $l++) {
      i = $l;
      Result = Result + c;
    };
    return Result;
  };
  this.Writeln = function () {
    var i = 0;
    var l = 0;
    var s = "";
    l = arguments.length - 1;
    if ($impl.WriteCallBack != null) {
      for (var $l = 0, $end = l; $l <= $end; $l++) {
        i = $l;
        $impl.WriteCallBack(arguments[i],i === l);
      };
    } else {
      s = $impl.WriteBuf;
      for (var $l1 = 0, $end1 = l; $l1 <= $end1; $l1++) {
        i = $l1;
        s = s + ("" + arguments[i]);
      };
      console.log(s);
      $impl.WriteBuf = "";
    };
  };
  this.SetWriteCallBack = function (H) {
    var Result = null;
    Result = $impl.WriteCallBack;
    $impl.WriteCallBack = H;
    return Result;
  };
  this.Assigned = function (V) {
    return (V!=undefined) && (V!=null) && (!rtl.isArray(V) || (V.length > 0));
  };
  $mod.$implcode = function () {
    $impl.WriteBuf = "";
    $impl.WriteCallBack = null;
    $impl.valint = function (S, MinVal, MaxVal, Code) {
      var Result = 0;
      var x = 0.0;
      if (S === "") {
        Code.set(1);
        return Result;
      };
      x = Number(S);
      if (isNaN(x)) {
        var $tmp = $mod.Copy(S,1,1);
        if ($tmp === "$") {
          x = Number("0x" + $mod.Copy$1(S,2))}
         else if ($tmp === "&") {
          x = Number("0o" + $mod.Copy$1(S,2))}
         else if ($tmp === "%") {
          x = Number("0b" + $mod.Copy$1(S,2))}
         else {
          Code.set(1);
          return Result;
        };
      };
      if (isNaN(x) || (x !== $mod.Int(x))) {
        Code.set(1)}
       else if ((x < MinVal) || (x > MaxVal)) {
        Code.set(2)}
       else {
        Result = $mod.Trunc(x);
        Code.set(0);
      };
      return Result;
    };
  };
  $mod.$init = function () {
    rtl.exitcode = 0;
  };
},[]);
rtl.module("Types",["System"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("JS",["System","Types"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"EJS",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FMessage = "";
    };
    this.Create$1 = function (Msg) {
      this.FMessage = Msg;
      return this;
    };
  });
  this.New = function (aElements) {
    var Result = null;
    var L = 0;
    var I = 0;
    var S = "";
    L = rtl.length(aElements);
    if ((L % 2) === 1) throw $mod.EJS.$create("Create$1",["Number of arguments must be even"]);
    I = 0;
    while (I < L) {
      if (!rtl.isString(aElements[I])) {
        S = String(I);
        throw $mod.EJS.$create("Create$1",["Argument " + S + " must be a string."]);
      };
      I += 2;
    };
    I = 0;
    Result = new Object();
    while (I < L) {
      S = "" + aElements[I];
      Result[S] = aElements[I + 1];
      I += 2;
    };
    return Result;
  };
  this.isUndefined = function (v) {
    return v == undefined;
  };
});
rtl.module("weborworker",["System","JS","Types"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("Web",["System","Types","JS","weborworker"],function () {
  "use strict";
  var $mod = this;
});
rtl.module("RTLConsts",["System"],function () {
  "use strict";
  var $mod = this;
  $mod.$resourcestrings = {SArgumentMissing: {org: 'Missing argument in format "%s"'}, SInvalidFormat: {org: 'Invalid format specifier : "%s"'}, SInvalidArgIndex: {org: 'Invalid argument index in format: "%s"'}, SListCapacityError: {org: "List capacity (%s) exceeded."}, SListCountError: {org: "List count (%s) out of bounds."}, SListIndexError: {org: "List index (%s) out of bounds"}, SInvalidName: {org: 'Invalid component name: "%s"'}, SDuplicateName: {org: 'Duplicate component name: "%s"'}};
});
rtl.module("SysUtils",["System","RTLConsts","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.FreeAndNil = function (Obj) {
    var o = null;
    o = Obj.get();
    if (o === null) return;
    Obj.set(null);
    o.$destroy("Destroy");
  };
  rtl.recNewT(this,"TFormatSettings",function () {
    this.CurrencyDecimals = 0;
    this.CurrencyFormat = 0;
    this.CurrencyString = "";
    this.DateSeparator = "";
    this.DecimalSeparator = "";
    this.LongDateFormat = "";
    this.LongTimeFormat = "";
    this.NegCurrFormat = 0;
    this.ShortDateFormat = "";
    this.ShortTimeFormat = "";
    this.ThousandSeparator = "";
    this.TimeAMString = "";
    this.TimePMString = "";
    this.TimeSeparator = "";
    this.TwoDigitYearCenturyWindow = 0;
    this.InitLocaleHandler = null;
    this.$new = function () {
      var r = Object.create(this);
      r.DateTimeToStrFormat = rtl.arraySetLength(null,"",2);
      r.LongDayNames = rtl.arraySetLength(null,"",7);
      r.LongMonthNames = rtl.arraySetLength(null,"",12);
      r.ShortDayNames = rtl.arraySetLength(null,"",7);
      r.ShortMonthNames = rtl.arraySetLength(null,"",12);
      return r;
    };
    this.$eq = function (b) {
      return (this.CurrencyDecimals === b.CurrencyDecimals) && (this.CurrencyFormat === b.CurrencyFormat) && (this.CurrencyString === b.CurrencyString) && (this.DateSeparator === b.DateSeparator) && rtl.arrayEq(this.DateTimeToStrFormat,b.DateTimeToStrFormat) && (this.DecimalSeparator === b.DecimalSeparator) && (this.LongDateFormat === b.LongDateFormat) && rtl.arrayEq(this.LongDayNames,b.LongDayNames) && rtl.arrayEq(this.LongMonthNames,b.LongMonthNames) && (this.LongTimeFormat === b.LongTimeFormat) && (this.NegCurrFormat === b.NegCurrFormat) && (this.ShortDateFormat === b.ShortDateFormat) && rtl.arrayEq(this.ShortDayNames,b.ShortDayNames) && rtl.arrayEq(this.ShortMonthNames,b.ShortMonthNames) && (this.ShortTimeFormat === b.ShortTimeFormat) && (this.ThousandSeparator === b.ThousandSeparator) && (this.TimeAMString === b.TimeAMString) && (this.TimePMString === b.TimePMString) && (this.TimeSeparator === b.TimeSeparator) && (this.TwoDigitYearCenturyWindow === b.TwoDigitYearCenturyWindow);
    };
    this.$assign = function (s) {
      this.CurrencyDecimals = s.CurrencyDecimals;
      this.CurrencyFormat = s.CurrencyFormat;
      this.CurrencyString = s.CurrencyString;
      this.DateSeparator = s.DateSeparator;
      this.DateTimeToStrFormat = s.DateTimeToStrFormat.slice(0);
      this.DecimalSeparator = s.DecimalSeparator;
      this.LongDateFormat = s.LongDateFormat;
      this.LongDayNames = s.LongDayNames.slice(0);
      this.LongMonthNames = s.LongMonthNames.slice(0);
      this.LongTimeFormat = s.LongTimeFormat;
      this.NegCurrFormat = s.NegCurrFormat;
      this.ShortDateFormat = s.ShortDateFormat;
      this.ShortDayNames = s.ShortDayNames.slice(0);
      this.ShortMonthNames = s.ShortMonthNames.slice(0);
      this.ShortTimeFormat = s.ShortTimeFormat;
      this.ThousandSeparator = s.ThousandSeparator;
      this.TimeAMString = s.TimeAMString;
      this.TimePMString = s.TimePMString;
      this.TimeSeparator = s.TimeSeparator;
      this.TwoDigitYearCenturyWindow = s.TwoDigitYearCenturyWindow;
      return this;
    };
    this.GetJSLocale = function () {
      return Intl.DateTimeFormat().resolvedOptions().locale;
    };
    this.Create = function () {
      var Result = $mod.TFormatSettings.$new();
      Result.$assign($mod.TFormatSettings.Create$1($mod.TFormatSettings.GetJSLocale()));
      return Result;
    };
    this.Create$1 = function (ALocale) {
      var Result = $mod.TFormatSettings.$new();
      Result.LongDayNames = $impl.DefaultLongDayNames.slice(0);
      Result.ShortDayNames = $impl.DefaultShortDayNames.slice(0);
      Result.ShortMonthNames = $impl.DefaultShortMonthNames.slice(0);
      Result.LongMonthNames = $impl.DefaultLongMonthNames.slice(0);
      Result.DateTimeToStrFormat[0] = "c";
      Result.DateTimeToStrFormat[1] = "f";
      Result.DateSeparator = "-";
      Result.TimeSeparator = ":";
      Result.ShortDateFormat = "yyyy-mm-dd";
      Result.LongDateFormat = "ddd, yyyy-mm-dd";
      Result.ShortTimeFormat = "hh:nn";
      Result.LongTimeFormat = "hh:nn:ss";
      Result.DecimalSeparator = ".";
      Result.ThousandSeparator = ",";
      Result.TimeAMString = "AM";
      Result.TimePMString = "PM";
      Result.TwoDigitYearCenturyWindow = 50;
      Result.CurrencyFormat = 0;
      Result.NegCurrFormat = 0;
      Result.CurrencyDecimals = 2;
      Result.CurrencyString = "$";
      if ($mod.TFormatSettings.InitLocaleHandler != null) $mod.TFormatSettings.InitLocaleHandler($mod.UpperCase(ALocale),$mod.TFormatSettings.$clone(Result));
      return Result;
    };
  },true);
  rtl.createClass(this,"Exception",pas.System.TObject,function () {
    this.LogMessageOnCreate = false;
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.fMessage = "";
    };
    this.Create$1 = function (Msg) {
      this.fMessage = Msg;
      if (this.LogMessageOnCreate) pas.System.Writeln("Created exception ",this.$classname," with message: ",Msg);
      return this;
    };
    this.CreateFmt = function (Msg, Args) {
      this.Create$1($mod.Format(Msg,Args));
      return this;
    };
  });
  rtl.createClass(this,"EExternal",this.Exception,function () {
  });
  rtl.createClass(this,"EConvertError",this.Exception,function () {
  });
  rtl.createClass(this,"EExternalException",this.EExternal,function () {
  });
  this.TrimLeft = function (S) {
    return S.replace(/^[\s\uFEFF\xA0\x00-\x1f]+/,'');
  };
  this.UpperCase = function (s) {
    return s.toUpperCase();
  };
  this.LowerCase = function (s) {
    return s.toLowerCase();
  };
  this.CompareText = function (s1, s2) {
    var l1 = s1.toLowerCase();
    var l2 = s2.toLowerCase();
    if (l1>l2){ return 1;
    } else if (l1<l2){ return -1;
    } else { return 0; };
  };
  this.Format = function (Fmt, Args) {
    var Result = "";
    Result = $mod.Format$1(Fmt,Args,$mod.FormatSettings);
    return Result;
  };
  this.Format$1 = function (Fmt, Args, aSettings) {
    var Result = "";
    var ChPos = 0;
    var OldPos = 0;
    var ArgPos = 0;
    var DoArg = 0;
    var Len = 0;
    var Hs = "";
    var ToAdd = "";
    var Index = 0;
    var Width = 0;
    var Prec = 0;
    var Left = false;
    var Fchar = "";
    var vq = 0;
    function ReadFormat() {
      var Result = "";
      var Value = 0;
      function ReadInteger() {
        var Code = 0;
        var ArgN = 0;
        if (Value !== -1) return;
        OldPos = ChPos;
        while ((ChPos <= Len) && (Fmt.charAt(ChPos - 1) <= "9") && (Fmt.charAt(ChPos - 1) >= "0")) ChPos += 1;
        if (ChPos > Len) $impl.DoFormatError(1,Fmt);
        if (Fmt.charAt(ChPos - 1) === "*") {
          if (Index === 255) {
            ArgN = ArgPos}
           else {
            ArgN = Index;
            Index += 1;
          };
          if ((ChPos > OldPos) || (ArgN > (rtl.length(Args) - 1))) $impl.DoFormatError(1,Fmt);
          ArgPos = ArgN + 1;
          var $tmp = Args[ArgN].VType;
          if ($tmp === 0) {
            Value = Args[ArgN].VJSValue}
           else if ($tmp === 19) {
            Value = Args[ArgN].VJSValue}
           else {
            $impl.DoFormatError(1,Fmt);
          };
          ChPos += 1;
        } else {
          if (OldPos < ChPos) {
            pas.System.val(pas.System.Copy(Fmt,OldPos,ChPos - OldPos),{get: function () {
                return Value;
              }, set: function (v) {
                Value = v;
              }},{get: function () {
                return Code;
              }, set: function (v) {
                Code = v;
              }});
            if (Code > 0) $impl.DoFormatError(1,Fmt);
          } else Value = -1;
        };
      };
      function ReadIndex() {
        if (Fmt.charAt(ChPos - 1) !== ":") {
          ReadInteger()}
         else Value = 0;
        if (Fmt.charAt(ChPos - 1) === ":") {
          if (Value === -1) $impl.DoFormatError(2,Fmt);
          Index = Value;
          Value = -1;
          ChPos += 1;
        };
      };
      function ReadLeft() {
        if (Fmt.charAt(ChPos - 1) === "-") {
          Left = true;
          ChPos += 1;
        } else Left = false;
      };
      function ReadWidth() {
        ReadInteger();
        if (Value !== -1) {
          Width = Value;
          Value = -1;
        };
      };
      function ReadPrec() {
        if (Fmt.charAt(ChPos - 1) === ".") {
          ChPos += 1;
          ReadInteger();
          if (Value === -1) Value = 0;
          Prec = Value;
        };
      };
      Index = 255;
      Width = -1;
      Prec = -1;
      Value = -1;
      ChPos += 1;
      if (Fmt.charAt(ChPos - 1) === "%") {
        Result = "%";
        return Result;
      };
      ReadIndex();
      ReadLeft();
      ReadWidth();
      ReadPrec();
      Result = pas.System.upcase(Fmt.charAt(ChPos - 1));
      return Result;
    };
    function Checkarg(AT, err) {
      var Result = false;
      Result = false;
      if (Index === 255) {
        DoArg = ArgPos}
       else DoArg = Index;
      ArgPos = DoArg + 1;
      if ((DoArg > (rtl.length(Args) - 1)) || (Args[DoArg].VType !== AT)) {
        if (err) $impl.DoFormatError(3,Fmt);
        ArgPos -= 1;
        return Result;
      };
      Result = true;
      return Result;
    };
    Result = "";
    Len = Fmt.length;
    ChPos = 1;
    OldPos = 1;
    ArgPos = 0;
    while (ChPos <= Len) {
      while ((ChPos <= Len) && (Fmt.charAt(ChPos - 1) !== "%")) ChPos += 1;
      if (ChPos > OldPos) Result = Result + pas.System.Copy(Fmt,OldPos,ChPos - OldPos);
      if (ChPos < Len) {
        Fchar = ReadFormat();
        var $tmp = Fchar;
        if ($tmp === "D") {
          if (Checkarg(0,false)) {
            ToAdd = $mod.IntToStr(Args[DoArg].VJSValue)}
           else if (Checkarg(19,true)) ToAdd = $mod.IntToStr(Args[DoArg].VJSValue);
          Width = Math.abs(Width);
          Index = Prec - ToAdd.length;
          if (ToAdd.charAt(0) !== "-") {
            ToAdd = pas.System.StringOfChar("0",Index) + ToAdd}
           else pas.System.Insert(pas.System.StringOfChar("0",Index + 1),{get: function () {
              return ToAdd;
            }, set: function (v) {
              ToAdd = v;
            }},2);
        } else if ($tmp === "U") {
          if (Checkarg(0,false)) {
            ToAdd = $mod.IntToStr(Args[DoArg].VJSValue >>> 0)}
           else if (Checkarg(19,true)) ToAdd = $mod.IntToStr(Args[DoArg].VJSValue);
          Width = Math.abs(Width);
          Index = Prec - ToAdd.length;
          ToAdd = pas.System.StringOfChar("0",Index) + ToAdd;
        } else if ($tmp === "E") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,2,3,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,2,3,Prec,aSettings);
        } else if ($tmp === "F") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,0,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,0,9999,Prec,aSettings);
        } else if ($tmp === "G") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,1,Prec,3,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,1,Prec,3,aSettings);
        } else if ($tmp === "N") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,3,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,3,9999,Prec,aSettings);
        } else if ($tmp === "M") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,4,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,4,9999,Prec,aSettings);
        } else if ($tmp === "S") {
          if (Checkarg(18,false)) {
            Hs = Args[DoArg].VJSValue}
           else if (Checkarg(9,true)) Hs = Args[DoArg].VJSValue;
          Index = Hs.length;
          if ((Prec !== -1) && (Index > Prec)) Index = Prec;
          ToAdd = pas.System.Copy(Hs,1,Index);
        } else if ($tmp === "P") {
          if (Checkarg(0,false)) {
            ToAdd = $mod.IntToHex(Args[DoArg].VJSValue,8)}
           else if (Checkarg(0,true)) ToAdd = $mod.IntToHex(Args[DoArg].VJSValue,16);
        } else if ($tmp === "X") {
          if (Checkarg(0,false)) {
            vq = Args[DoArg].VJSValue;
            Index = 16;
          } else if (Checkarg(19,true)) {
            vq = Args[DoArg].VJSValue;
            Index = 31;
          };
          if (Prec > Index) {
            ToAdd = $mod.IntToHex(vq,Index)}
           else {
            Index = 1;
            while ((rtl.shl(1,Index * 4) <= vq) && (Index < 16)) Index += 1;
            if (Index > Prec) Prec = Index;
            ToAdd = $mod.IntToHex(vq,Prec);
          };
        } else if ($tmp === "%") ToAdd = "%";
        if (Width !== -1) if (ToAdd.length < Width) if (!Left) {
          ToAdd = pas.System.StringOfChar(" ",Width - ToAdd.length) + ToAdd}
         else ToAdd = ToAdd + pas.System.StringOfChar(" ",Width - ToAdd.length);
        Result = Result + ToAdd;
      };
      ChPos += 1;
      OldPos = ChPos;
    };
    return Result;
  };
  var Alpha = rtl.createSet(null,65,90,null,97,122,95);
  var AlphaNum = rtl.unionSet(Alpha,rtl.createSet(null,48,57));
  var Dot = ".";
  this.IsValidIdent = function (Ident, AllowDots, StrictDots) {
    var Result = false;
    var First = false;
    var I = 0;
    var Len = 0;
    Len = Ident.length;
    if (Len < 1) return false;
    First = true;
    Result = false;
    I = 1;
    while (I <= Len) {
      if (First) {
        if (!(Ident.charCodeAt(I - 1) in Alpha)) return Result;
        First = false;
      } else if (AllowDots && (Ident.charAt(I - 1) === Dot)) {
        if (StrictDots) {
          if (I >= Len) return Result;
          First = true;
        };
      } else if (!(Ident.charCodeAt(I - 1) in AlphaNum)) return Result;
      I = I + 1;
    };
    Result = true;
    return Result;
  };
  this.TStringReplaceFlag = {"0": "rfReplaceAll", rfReplaceAll: 0, "1": "rfIgnoreCase", rfIgnoreCase: 1};
  this.StringReplace = function (aOriginal, aSearch, aReplace, Flags) {
    var Result = "";
    var REFlags = "";
    var REString = "";
    REFlags = "";
    if (0 in Flags) REFlags = "g";
    if (1 in Flags) REFlags = REFlags + "i";
    REString = aSearch.replace(new RegExp($impl.RESpecials,"g"),"\\$1");
    Result = aOriginal.replace(new RegExp(REString,REFlags),aReplace);
    return Result;
  };
  this.IntToStr = function (Value) {
    var Result = "";
    Result = "" + Value;
    return Result;
  };
  this.IntToHex = function (Value, Digits) {
    var Result = "";
    Result = "";
    if (Value < 0) if (Value<0) Value = 0xFFFFFFFF + Value + 1;
    Result=Value.toString(16);
    Result = $mod.UpperCase(Result);
    while (Result.length < Digits) Result = "0" + Result;
    return Result;
  };
  this.TFloatFormat = {"0": "ffFixed", ffFixed: 0, "1": "ffGeneral", ffGeneral: 1, "2": "ffExponent", ffExponent: 2, "3": "ffNumber", ffNumber: 3, "4": "ffCurrency", ffCurrency: 4};
  this.FloatToStrF$1 = function (Value, format, Precision, Digits, aSettings) {
    var Result = "";
    var TS = "";
    var DS = "";
    DS = aSettings.DecimalSeparator;
    TS = aSettings.ThousandSeparator;
    var $tmp = format;
    if ($tmp === 1) {
      Result = $impl.FormatGeneralFloat(Value,Precision,DS)}
     else if ($tmp === 2) {
      Result = $impl.FormatExponentFloat(Value,Precision,Digits,DS)}
     else if ($tmp === 0) {
      Result = $impl.FormatFixedFloat(Value,Digits,DS)}
     else if ($tmp === 3) {
      Result = $impl.FormatNumberFloat(Value,Digits,DS,TS)}
     else if ($tmp === 4) Result = $impl.FormatNumberCurrency(Value * 10000,Digits,aSettings);
    if ((format !== 4) && (Result.length > 1) && (Result.charAt(0) === "-")) $impl.RemoveLeadingNegativeSign({get: function () {
        return Result;
      }, set: function (v) {
        Result = v;
      }},DS,TS);
    return Result;
  };
  this.OnGetEnvironmentVariable = null;
  this.OnGetEnvironmentString = null;
  this.OnGetEnvironmentVariableCount = null;
  this.TimeSeparator = "";
  this.DateSeparator = "";
  this.ShortDateFormat = "";
  this.LongDateFormat = "";
  this.ShortTimeFormat = "";
  this.LongTimeFormat = "";
  this.DecimalSeparator = "";
  this.ThousandSeparator = "";
  this.TimeAMString = "";
  this.TimePMString = "";
  this.ShortMonthNames = rtl.arraySetLength(null,"",12);
  this.LongMonthNames = rtl.arraySetLength(null,"",12);
  this.ShortDayNames = rtl.arraySetLength(null,"",7);
  this.LongDayNames = rtl.arraySetLength(null,"",7);
  this.FormatSettings = this.TFormatSettings.$new();
  this.CurrencyFormat = 0;
  this.NegCurrFormat = 0;
  this.CurrencyDecimals = 0;
  this.CurrencyString = "";
  this.TStringSplitOptions = {"0": "None", None: 0, "1": "ExcludeEmpty", ExcludeEmpty: 1};
  rtl.createHelper(this,"TStringHelper",null,function () {
    this.GetLength = function () {
      var Result = 0;
      Result = this.get().length;
      return Result;
    };
    this.IndexOfAny$3 = function (AnyOf, StartIndex) {
      var Result = 0;
      Result = $mod.TStringHelper.IndexOfAny$5.call(this,AnyOf,StartIndex,$mod.TStringHelper.GetLength.call(this));
      return Result;
    };
    this.IndexOfAny$5 = function (AnyOf, StartIndex, ACount) {
      var Result = 0;
      var i = 0;
      var L = 0;
      i = StartIndex + 1;
      L = (i + ACount) - 1;
      if (L > $mod.TStringHelper.GetLength.call(this)) L = $mod.TStringHelper.GetLength.call(this);
      Result = -1;
      while ((Result === -1) && (i <= L)) {
        if ($impl.HaveChar(this.get().charAt(i - 1),AnyOf)) Result = i - 1;
        i += 1;
      };
      return Result;
    };
    this.IndexOfAnyUnquoted$1 = function (AnyOf, StartQuote, EndQuote, StartIndex) {
      var Result = 0;
      Result = $mod.TStringHelper.IndexOfAnyUnquoted$2.call(this,AnyOf,StartQuote,EndQuote,StartIndex,$mod.TStringHelper.GetLength.call(this));
      return Result;
    };
    this.IndexOfAnyUnquoted$2 = function (AnyOf, StartQuote, EndQuote, StartIndex, ACount) {
      var Result = 0;
      var I = 0;
      var L = 0;
      var Q = 0;
      Result = -1;
      L = (StartIndex + ACount) - 1;
      if (L > $mod.TStringHelper.GetLength.call(this)) L = $mod.TStringHelper.GetLength.call(this);
      I = StartIndex + 1;
      Q = 0;
      if (StartQuote === EndQuote) {
        while ((Result === -1) && (I <= L)) {
          if (this.get().charAt(I - 1) === StartQuote) Q = 1 - Q;
          if ((Q === 0) && $impl.HaveChar(this.get().charAt(I - 1),AnyOf)) Result = I - 1;
          I += 1;
        };
      } else {
        while ((Result === -1) && (I <= L)) {
          if (this.get().charAt(I - 1) === StartQuote) {
            Q += 1}
           else if ((this.get().charAt(I - 1) === EndQuote) && (Q > 0)) Q -= 1;
          if ((Q === 0) && $impl.HaveChar(this.get().charAt(I - 1),AnyOf)) Result = I - 1;
          I += 1;
        };
      };
      return Result;
    };
    this.Split$1 = function (Separators) {
      var Result = [];
      Result = $mod.TStringHelper.Split$21.call(this,Separators,"\x00","\x00",$mod.TStringHelper.GetLength.call(this) + 1,0);
      return Result;
    };
    var BlockSize = 10;
    this.Split$21 = function (Separators, AQuoteStart, AQuoteEnd, ACount, Options) {
      var $Self = this;
      var Result = [];
      var S = "";
      function NextSep(StartIndex) {
        var Result = 0;
        if (AQuoteStart !== "\x00") {
          Result = $mod.TStringHelper.IndexOfAnyUnquoted$1.call({get: function () {
              return S;
            }, set: function (v) {
              S = v;
            }},Separators,AQuoteStart,AQuoteEnd,StartIndex)}
         else Result = $mod.TStringHelper.IndexOfAny$3.call({get: function () {
            return S;
          }, set: function (v) {
            S = v;
          }},Separators,StartIndex);
        return Result;
      };
      function MaybeGrow(Curlen) {
        if (rtl.length(Result) <= Curlen) Result = rtl.arraySetLength(Result,"",rtl.length(Result) + 10);
      };
      var Sep = 0;
      var LastSep = 0;
      var Len = 0;
      var T = "";
      S = $Self.get();
      Result = rtl.arraySetLength(Result,"",10);
      Len = 0;
      LastSep = 0;
      Sep = NextSep(0);
      while ((Sep !== -1) && ((ACount === 0) || (Len < ACount))) {
        T = $mod.TStringHelper.Substring$1.call($Self,LastSep,Sep - LastSep);
        if ((T !== "") || !(1 === Options)) {
          MaybeGrow(Len);
          Result[Len] = T;
          Len += 1;
        };
        LastSep = Sep + 1;
        Sep = NextSep(LastSep);
      };
      if ((LastSep <= $mod.TStringHelper.GetLength.call($Self)) && ((ACount === 0) || (Len < ACount))) {
        T = $mod.TStringHelper.Substring.call($Self,LastSep);
        if ((T !== "") || !(1 === Options)) {
          MaybeGrow(Len);
          Result[Len] = T;
          Len += 1;
        };
      };
      Result = rtl.arraySetLength(Result,"",Len);
      return Result;
    };
    this.Substring = function (AStartIndex) {
      var Result = "";
      Result = $mod.TStringHelper.Substring$1.call(this,AStartIndex,$mod.TStringHelper.GetLength.call(this) - AStartIndex);
      return Result;
    };
    this.Substring$1 = function (AStartIndex, ALen) {
      var Result = "";
      Result = pas.System.Copy(this.get(),AStartIndex + 1,ALen);
      return Result;
    };
  });
  $mod.$implcode = function () {
    $impl.DefaultShortMonthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    $impl.DefaultLongMonthNames = ["January","February","March","April","May","June","July","August","September","October","November","December"];
    $impl.DefaultShortDayNames = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    $impl.DefaultLongDayNames = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    $impl.feInvalidFormat = 1;
    $impl.feMissingArgument = 2;
    $impl.feInvalidArgIndex = 3;
    $impl.DoFormatError = function (ErrCode, fmt) {
      var $tmp = ErrCode;
      if ($tmp === 1) {
        throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SInvalidFormat"),pas.System.VarRecs(18,fmt)])}
       else if ($tmp === 2) {
        throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SArgumentMissing"),pas.System.VarRecs(18,fmt)])}
       else if ($tmp === 3) throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SInvalidArgIndex"),pas.System.VarRecs(18,fmt)]);
    };
    $impl.maxdigits = 15;
    $impl.ReplaceDecimalSep = function (S, DS) {
      var Result = "";
      var P = 0;
      P = pas.System.Pos(".",S);
      if (P > 0) {
        Result = pas.System.Copy(S,1,P - 1) + DS + pas.System.Copy(S,P + 1,S.length - P)}
       else Result = S;
      return Result;
    };
    $impl.FormatGeneralFloat = function (Value, Precision, DS) {
      var Result = "";
      var P = 0;
      var PE = 0;
      var Q = 0;
      var Exponent = 0;
      if ((Precision === -1) || (Precision > 15)) Precision = 15;
      Result = rtl.floatToStr(Value,Precision + 7);
      Result = $mod.TrimLeft(Result);
      P = pas.System.Pos(".",Result);
      if (P === 0) return Result;
      PE = pas.System.Pos("E",Result);
      if (PE === 0) {
        Result = $impl.ReplaceDecimalSep(Result,DS);
        return Result;
      };
      Q = PE + 2;
      Exponent = 0;
      while (Q <= Result.length) {
        Exponent = ((Exponent * 10) + Result.charCodeAt(Q - 1)) - 48;
        Q += 1;
      };
      if (Result.charAt((PE + 1) - 1) === "-") Exponent = -Exponent;
      if (((P + Exponent) < PE) && (Exponent > -6)) {
        Result = rtl.strSetLength(Result,PE - 1);
        if (Exponent >= 0) {
          for (var $l = 0, $end = Exponent - 1; $l <= $end; $l++) {
            Q = $l;
            Result = rtl.setCharAt(Result,P - 1,Result.charAt((P + 1) - 1));
            P += 1;
          };
          Result = rtl.setCharAt(Result,P - 1,".");
          P = 1;
          if (Result.charAt(P - 1) === "-") P += 1;
          while ((Result.charAt(P - 1) === "0") && (P < Result.length) && (pas.System.Copy(Result,P + 1,DS.length) !== DS)) pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P,1);
        } else {
          pas.System.Insert(pas.System.Copy("00000",1,-Exponent),{get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P - 1);
          Result = rtl.setCharAt(Result,P - Exponent - 1,Result.charAt(P - Exponent - 1 - 1));
          Result = rtl.setCharAt(Result,P - 1,".");
          if (Exponent !== -1) Result = rtl.setCharAt(Result,P - Exponent - 1 - 1,"0");
        };
        Q = Result.length;
        while ((Q > 0) && (Result.charAt(Q - 1) === "0")) Q -= 1;
        if (Result.charAt(Q - 1) === ".") Q -= 1;
        if ((Q === 0) || ((Q === 1) && (Result.charAt(0) === "-"))) {
          Result = "0"}
         else Result = rtl.strSetLength(Result,Q);
      } else {
        while (Result.charAt(PE - 1 - 1) === "0") {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},PE - 1,1);
          PE -= 1;
        };
        if (Result.charAt(PE - 1 - 1) === DS) {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},PE - 1,1);
          PE -= 1;
        };
        if (Result.charAt((PE + 1) - 1) === "+") {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},PE + 1,1)}
         else PE += 1;
        while (Result.charAt((PE + 1) - 1) === "0") pas.System.Delete({get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},PE + 1,1);
      };
      Result = $impl.ReplaceDecimalSep(Result,DS);
      return Result;
    };
    $impl.FormatExponentFloat = function (Value, Precision, Digits, DS) {
      var Result = "";
      var P = 0;
      DS = $mod.FormatSettings.DecimalSeparator;
      if ((Precision === -1) || (Precision > 15)) Precision = 15;
      Result = rtl.floatToStr(Value,Precision + 7);
      while (Result.charAt(0) === " ") pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      P = pas.System.Pos("E",Result);
      if (P === 0) {
        Result = $impl.ReplaceDecimalSep(Result,DS);
        return Result;
      };
      P += 2;
      if (Digits > 4) Digits = 4;
      Digits = (Result.length - P - Digits) + 1;
      if (Digits < 0) {
        pas.System.Insert(pas.System.Copy("0000",1,-Digits),{get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},P)}
       else while ((Digits > 0) && (Result.charAt(P - 1) === "0")) {
        pas.System.Delete({get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},P,1);
        if (P > Result.length) {
          pas.System.Delete({get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P - 2,2);
          break;
        };
        Digits -= 1;
      };
      Result = $impl.ReplaceDecimalSep(Result,DS);
      return Result;
    };
    $impl.FormatFixedFloat = function (Value, Digits, DS) {
      var Result = "";
      if (Digits === -1) {
        Digits = 2}
       else if (Digits > 18) Digits = 18;
      Result = rtl.floatToStr(Value,0,Digits);
      if ((Result !== "") && (Result.charAt(0) === " ")) pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      Result = $impl.ReplaceDecimalSep(Result,DS);
      return Result;
    };
    $impl.FormatNumberFloat = function (Value, Digits, DS, TS) {
      var Result = "";
      var P = 0;
      if (Digits === -1) {
        Digits = 2}
       else if (Digits > 15) Digits = 15;
      Result = rtl.floatToStr(Value,0,Digits);
      if ((Result !== "") && (Result.charAt(0) === " ")) pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      P = pas.System.Pos(".",Result);
      if (P <= 0) P = Result.length + 1;
      Result = $impl.ReplaceDecimalSep(Result,DS);
      P -= 3;
      if ((TS !== "") && (TS !== "\x00")) while (P > 1) {
        if (Result.charAt(P - 1 - 1) !== "-") pas.System.Insert(TS,{get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }},P);
        P -= 3;
      };
      return Result;
    };
    $impl.RemoveLeadingNegativeSign = function (AValue, DS, aThousandSeparator) {
      var Result = false;
      var i = 0;
      var TS = "";
      var StartPos = 0;
      Result = false;
      StartPos = 2;
      TS = aThousandSeparator;
      for (var $l = StartPos, $end = AValue.get().length; $l <= $end; $l++) {
        i = $l;
        Result = (AValue.get().charCodeAt(i - 1) in rtl.createSet(48,DS.charCodeAt(),69,43)) || (AValue.get().charAt(i - 1) === TS);
        if (!Result) break;
      };
      if (Result && (AValue.get().charAt(0) === "-")) pas.System.Delete(AValue,1,1);
      return Result;
    };
    $impl.FormatNumberCurrency = function (Value, Digits, aSettings) {
      var Result = "";
      var Negative = false;
      var P = 0;
      var CS = "";
      var DS = "";
      var TS = "";
      DS = aSettings.DecimalSeparator;
      TS = aSettings.ThousandSeparator;
      CS = aSettings.CurrencyString;
      if (Digits === -1) {
        Digits = aSettings.CurrencyDecimals}
       else if (Digits > 18) Digits = 18;
      Result = rtl.floatToStr(Value / 10000,0,Digits);
      Negative = Result.charAt(0) === "-";
      if (Negative) pas.System.Delete({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},1,1);
      P = pas.System.Pos(".",Result);
      if (TS !== "") {
        if (P !== 0) {
          Result = $impl.ReplaceDecimalSep(Result,DS)}
         else P = Result.length + 1;
        P -= 3;
        while (P > 1) {
          pas.System.Insert(TS,{get: function () {
              return Result;
            }, set: function (v) {
              Result = v;
            }},P);
          P -= 3;
        };
      };
      if (Negative) $impl.RemoveLeadingNegativeSign({get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }},DS,TS);
      if (!Negative) {
        var $tmp = aSettings.CurrencyFormat;
        if ($tmp === 0) {
          Result = CS + Result}
         else if ($tmp === 1) {
          Result = Result + CS}
         else if ($tmp === 2) {
          Result = CS + " " + Result}
         else if ($tmp === 3) Result = Result + " " + CS;
      } else {
        var $tmp1 = aSettings.NegCurrFormat;
        if ($tmp1 === 0) {
          Result = "(" + CS + Result + ")"}
         else if ($tmp1 === 1) {
          Result = "-" + CS + Result}
         else if ($tmp1 === 2) {
          Result = CS + "-" + Result}
         else if ($tmp1 === 3) {
          Result = CS + Result + "-"}
         else if ($tmp1 === 4) {
          Result = "(" + Result + CS + ")"}
         else if ($tmp1 === 5) {
          Result = "-" + Result + CS}
         else if ($tmp1 === 6) {
          Result = Result + "-" + CS}
         else if ($tmp1 === 7) {
          Result = Result + CS + "-"}
         else if ($tmp1 === 8) {
          Result = "-" + Result + " " + CS}
         else if ($tmp1 === 9) {
          Result = "-" + CS + " " + Result}
         else if ($tmp1 === 10) {
          Result = Result + " " + CS + "-"}
         else if ($tmp1 === 11) {
          Result = CS + " " + Result + "-"}
         else if ($tmp1 === 12) {
          Result = CS + " " + "-" + Result}
         else if ($tmp1 === 13) {
          Result = Result + "-" + " " + CS}
         else if ($tmp1 === 14) {
          Result = "(" + CS + " " + Result + ")"}
         else if ($tmp1 === 15) Result = "(" + Result + " " + CS + ")";
      };
      return Result;
    };
    $impl.RESpecials = "([\\$\\+\\[\\]\\(\\)\\\\\\.\\*\\^\\?\\|])";
    $impl.InitGlobalFormatSettings = function () {
      $mod.FormatSettings.$assign($mod.TFormatSettings.Create());
      $mod.TimeSeparator = $mod.FormatSettings.TimeSeparator;
      $mod.DateSeparator = $mod.FormatSettings.DateSeparator;
      $mod.ShortDateFormat = $mod.FormatSettings.ShortDateFormat;
      $mod.LongDateFormat = $mod.FormatSettings.LongDateFormat;
      $mod.ShortTimeFormat = $mod.FormatSettings.ShortTimeFormat;
      $mod.LongTimeFormat = $mod.FormatSettings.LongTimeFormat;
      $mod.DecimalSeparator = $mod.FormatSettings.DecimalSeparator;
      $mod.ThousandSeparator = $mod.FormatSettings.ThousandSeparator;
      $mod.TimeAMString = $mod.FormatSettings.TimeAMString;
      $mod.TimePMString = $mod.FormatSettings.TimePMString;
      $mod.CurrencyFormat = $mod.FormatSettings.CurrencyFormat;
      $mod.NegCurrFormat = $mod.FormatSettings.NegCurrFormat;
      $mod.CurrencyDecimals = $mod.FormatSettings.CurrencyDecimals;
      $mod.CurrencyString = $mod.FormatSettings.CurrencyString;
    };
    $impl.HaveChar = function (AChar, AList) {
      var Result = false;
      var I = 0;
      I = 0;
      Result = false;
      while (!Result && (I < rtl.length(AList))) {
        Result = AList[I] === AChar;
        I += 1;
      };
      return Result;
    };
  };
  $mod.$init = function () {
    (function () {
      $impl.InitGlobalFormatSettings();
    })();
    $mod.ShortMonthNames = $impl.DefaultShortMonthNames.slice(0);
    $mod.LongMonthNames = $impl.DefaultLongMonthNames.slice(0);
    $mod.ShortDayNames = $impl.DefaultShortDayNames.slice(0);
    $mod.LongDayNames = $impl.DefaultLongDayNames.slice(0);
  };
},[]);
rtl.module("Classes",["System","RTLConsts","Types","SysUtils","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"EListError",pas.SysUtils.Exception,function () {
  });
  rtl.createClass(this,"EStringListError",this.EListError,function () {
  });
  rtl.createClass(this,"EComponentError",pas.SysUtils.Exception,function () {
  });
  rtl.createClass(this,"TFPList",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FList = [];
      this.FCount = 0;
      this.FCapacity = 0;
    };
    this.$final = function () {
      this.FList = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Get = function (Index) {
      var Result = undefined;
      if ((Index < 0) || (Index >= this.FCount)) this.RaiseIndexError(Index);
      Result = this.FList[Index];
      return Result;
    };
    this.SetCapacity = function (NewCapacity) {
      if (NewCapacity < this.FCount) this.$class.Error(rtl.getResStr(pas.RTLConsts,"SListCapacityError"),"" + NewCapacity);
      if (NewCapacity === this.FCapacity) return;
      this.FList = rtl.arraySetLength(this.FList,undefined,NewCapacity);
      this.FCapacity = NewCapacity;
    };
    this.SetCount = function (NewCount) {
      if (NewCount < 0) this.$class.Error(rtl.getResStr(pas.RTLConsts,"SListCountError"),"" + NewCount);
      if (NewCount > this.FCount) {
        if (NewCount > this.FCapacity) this.SetCapacity(NewCount);
      };
      this.FCount = NewCount;
    };
    this.RaiseIndexError = function (Index) {
      this.$class.Error(rtl.getResStr(pas.RTLConsts,"SListIndexError"),"" + Index);
    };
    this.Destroy = function () {
      this.Clear();
      pas.System.TObject.Destroy.call(this);
    };
    this.Add = function (Item) {
      var Result = 0;
      if (this.FCount === this.FCapacity) this.Expand();
      this.FList[this.FCount] = Item;
      Result = this.FCount;
      this.FCount += 1;
      return Result;
    };
    this.Clear = function () {
      if (rtl.length(this.FList) > 0) {
        this.SetCount(0);
        this.SetCapacity(0);
      };
    };
    this.Delete = function (Index) {
      if ((Index < 0) || (Index >= this.FCount)) this.$class.Error(rtl.getResStr(pas.RTLConsts,"SListIndexError"),"" + Index);
      this.FCount = this.FCount - 1;
      this.FList.splice(Index,1);
      this.FCapacity -= 1;
    };
    this.Error = function (Msg, Data) {
      throw $mod.EListError.$create("CreateFmt",[Msg,pas.System.VarRecs(18,Data)]);
    };
    this.Expand = function () {
      var Result = null;
      var IncSize = 0;
      if (this.FCount < this.FCapacity) return this;
      IncSize = 4;
      if (this.FCapacity > 3) IncSize = IncSize + 4;
      if (this.FCapacity > 8) IncSize = IncSize + 8;
      if (this.FCapacity > 127) IncSize += this.FCapacity >>> 2;
      this.SetCapacity(this.FCapacity + IncSize);
      Result = this;
      return Result;
    };
    this.IndexOf = function (Item) {
      var Result = 0;
      var C = 0;
      Result = 0;
      C = this.FCount;
      while ((Result < C) && (this.FList[Result] != Item)) Result += 1;
      if (Result >= C) Result = -1;
      return Result;
    };
    this.Last = function () {
      var Result = undefined;
      if (this.FCount === 0) {
        Result = null}
       else Result = this.Get(this.FCount - 1);
      return Result;
    };
    this.Remove = function (Item) {
      var Result = 0;
      Result = this.IndexOf(Item);
      if (Result !== -1) this.Delete(Result);
      return Result;
    };
  });
  rtl.createClass(this,"TPersistent",pas.System.TObject,function () {
  });
  rtl.createClass(this,"TStrings",this.TPersistent,function () {
    this.$init = function () {
      $mod.TPersistent.$init.call(this);
      this.FAlwaysQuote = false;
    };
    this.Error = function (Msg, Data) {
      throw $mod.EStringListError.$create("CreateFmt",[Msg,pas.System.VarRecs(18,pas.SysUtils.IntToStr(Data))]);
    };
    this.GetCapacity = function () {
      var Result = 0;
      Result = this.GetCount();
      return Result;
    };
    this.Create$1 = function () {
      pas.System.TObject.Create.call(this);
      this.FAlwaysQuote = false;
      return this;
    };
    this.Destroy = function () {
      pas.System.TObject.Destroy.call(this);
    };
  });
  rtl.recNewT(this,"TStringItem",function () {
    this.FString = "";
    this.FObject = null;
    this.$eq = function (b) {
      return (this.FString === b.FString) && (this.FObject === b.FObject);
    };
    this.$assign = function (s) {
      this.FString = s.FString;
      this.FObject = s.FObject;
      return this;
    };
  });
  rtl.createClass(this,"TStringList",this.TStrings,function () {
    this.$init = function () {
      $mod.TStrings.$init.call(this);
      this.FList = [];
      this.FCount = 0;
      this.FOwnsObjects = false;
    };
    this.$final = function () {
      this.FList = undefined;
      $mod.TStrings.$final.call(this);
    };
    this.InternalClear = function (FromIndex, ClearOnly) {
      var I = 0;
      if (FromIndex < this.FCount) {
        if (this.FOwnsObjects) {
          for (var $l = FromIndex, $end = this.FCount - 1; $l <= $end; $l++) {
            I = $l;
            this.FList[I].FString = "";
            pas.SysUtils.FreeAndNil({p: this.FList[I], get: function () {
                return this.p.FObject;
              }, set: function (v) {
                this.p.FObject = v;
              }});
          };
        } else {
          for (var $l1 = FromIndex, $end1 = this.FCount - 1; $l1 <= $end1; $l1++) {
            I = $l1;
            this.FList[I].FString = "";
          };
        };
        this.FCount = FromIndex;
      };
      if (!ClearOnly) this.SetCapacity(0);
    };
    this.CheckIndex = function (AIndex) {
      if ((AIndex < 0) || (AIndex >= this.FCount)) this.Error(rtl.getResStr(pas.RTLConsts,"SListIndexError"),AIndex);
    };
    this.Get = function (Index) {
      var Result = "";
      this.CheckIndex(Index);
      Result = this.FList[Index].FString;
      return Result;
    };
    this.GetCapacity = function () {
      var Result = 0;
      Result = rtl.length(this.FList);
      return Result;
    };
    this.GetCount = function () {
      var Result = 0;
      Result = this.FCount;
      return Result;
    };
    this.SetCapacity = function (NewCapacity) {
      if (NewCapacity < 0) this.Error(rtl.getResStr(pas.RTLConsts,"SListCapacityError"),NewCapacity);
      if (NewCapacity !== this.GetCapacity()) this.FList = rtl.arraySetLength(this.FList,$mod.TStringItem,NewCapacity);
    };
    this.Destroy = function () {
      this.InternalClear(0,false);
      $mod.TStrings.Destroy.call(this);
    };
  });
  this.TOperation = {"0": "opInsert", opInsert: 0, "1": "opRemove", opRemove: 1};
  this.TComponentStateItem = {"0": "csLoading", csLoading: 0, "1": "csReading", csReading: 1, "2": "csWriting", csWriting: 2, "3": "csDestroying", csDestroying: 3, "4": "csDesigning", csDesigning: 4, "5": "csAncestor", csAncestor: 5, "6": "csUpdating", csUpdating: 6, "7": "csFixups", csFixups: 7, "8": "csFreeNotification", csFreeNotification: 8, "9": "csInline", csInline: 9, "10": "csDesignInstance", csDesignInstance: 10};
  this.TComponentStyleItem = {"0": "csInheritable", csInheritable: 0, "1": "csCheckPropAvail", csCheckPropAvail: 1, "2": "csSubComponent", csSubComponent: 2, "3": "csTransient", csTransient: 3};
  rtl.createClass(this,"TComponent",this.TPersistent,function () {
    this.$init = function () {
      $mod.TPersistent.$init.call(this);
      this.FOwner = null;
      this.FName = "";
      this.FTag = 0;
      this.FComponents = null;
      this.FFreeNotifies = null;
      this.FComponentState = {};
      this.FComponentStyle = {};
    };
    this.$final = function () {
      this.FOwner = undefined;
      this.FComponents = undefined;
      this.FFreeNotifies = undefined;
      this.FComponentState = undefined;
      this.FComponentStyle = undefined;
      $mod.TPersistent.$final.call(this);
    };
    this.Insert = function (AComponent) {
      if (!(this.FComponents != null)) this.FComponents = $mod.TFPList.$create("Create");
      this.FComponents.Add(AComponent);
      AComponent.FOwner = this;
    };
    this.Remove = function (AComponent) {
      AComponent.FOwner = null;
      if (this.FComponents != null) {
        this.FComponents.Remove(AComponent);
        if (this.FComponents.FCount === 0) {
          this.FComponents.$destroy("Destroy");
          this.FComponents = null;
        };
      };
    };
    this.RemoveNotification = function (AComponent) {
      if (this.FFreeNotifies !== null) {
        this.FFreeNotifies.Remove(AComponent);
        if (this.FFreeNotifies.FCount === 0) {
          this.FFreeNotifies.$destroy("Destroy");
          this.FFreeNotifies = null;
          this.FComponentState = rtl.excludeSet(this.FComponentState,8);
        };
      };
    };
    this.SetReference = function (Enable) {
      var aField = null;
      var aValue = null;
      var aOwner = null;
      if (this.FName === "") return;
      if (this.FOwner != null) {
        aOwner = this.FOwner;
        aField = this.FOwner.$class.FieldAddress(this.FName);
        if (aField != null) {
          if (Enable) {
            aValue = this}
           else aValue = null;
          aOwner["" + aField["name"]] = aValue;
        };
      };
    };
    this.ChangeName = function (NewName) {
      this.FName = NewName;
    };
    this.Notification = function (AComponent, Operation) {
      var C = 0;
      if (Operation === 1) this.RemoveFreeNotification(AComponent);
      if (!(this.FComponents != null)) return;
      C = this.FComponents.FCount - 1;
      while (C >= 0) {
        rtl.getObject(this.FComponents.Get(C)).Notification(AComponent,Operation);
        C -= 1;
        if (C >= this.FComponents.FCount) C = this.FComponents.FCount - 1;
      };
    };
    this.SetDesigning = function (Value, SetChildren) {
      var Runner = 0;
      if (Value) {
        this.FComponentState = rtl.includeSet(this.FComponentState,4)}
       else this.FComponentState = rtl.excludeSet(this.FComponentState,4);
      if ((this.FComponents != null) && SetChildren) for (var $l = 0, $end = this.FComponents.FCount - 1; $l <= $end; $l++) {
        Runner = $l;
        rtl.getObject(this.FComponents.Get(Runner)).SetDesigning(Value,true);
      };
    };
    this.SetName = function (NewName) {
      if (this.FName === NewName) return;
      if ((NewName !== "") && !pas.SysUtils.IsValidIdent(NewName,false,false)) throw $mod.EComponentError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SInvalidName"),pas.System.VarRecs(18,NewName)]);
      if (this.FOwner != null) {
        this.FOwner.ValidateRename(this,this.FName,NewName)}
       else this.ValidateRename(null,this.FName,NewName);
      this.SetReference(false);
      this.ChangeName(NewName);
      this.SetReference(true);
    };
    this.ValidateRename = function (AComponent, CurName, NewName) {
      if ((AComponent !== null) && (pas.SysUtils.CompareText(CurName,NewName) !== 0) && (AComponent.FOwner === this) && (this.FindComponent(NewName) !== null)) throw $mod.EComponentError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SDuplicateName"),pas.System.VarRecs(18,NewName)]);
      if ((4 in this.FComponentState) && (this.FOwner !== null)) this.FOwner.ValidateRename(AComponent,CurName,NewName);
    };
    this.ValidateContainer = function (AComponent) {
      AComponent.ValidateInsert(this);
    };
    this.ValidateInsert = function (AComponent) {
      if (AComponent === null) ;
    };
    this.Create$1 = function (AOwner) {
      this.FComponentStyle = rtl.createSet(0);
      if (AOwner != null) AOwner.InsertComponent(this);
      return this;
    };
    this.Destroy = function () {
      var I = 0;
      var C = null;
      this.Destroying();
      if (this.FFreeNotifies != null) {
        I = this.FFreeNotifies.FCount - 1;
        while (I >= 0) {
          C = rtl.getObject(this.FFreeNotifies.Get(I));
          this.FFreeNotifies.Delete(I);
          C.Notification(this,1);
          if (this.FFreeNotifies === null) {
            I = 0}
           else if (I > this.FFreeNotifies.FCount) I = this.FFreeNotifies.FCount;
          I -= 1;
        };
        pas.SysUtils.FreeAndNil({p: this, get: function () {
            return this.p.FFreeNotifies;
          }, set: function (v) {
            this.p.FFreeNotifies = v;
          }});
      };
      this.DestroyComponents();
      if (this.FOwner !== null) this.FOwner.RemoveComponent(this);
      pas.System.TObject.Destroy.call(this);
    };
    this.BeforeDestruction = function () {
      if (!(3 in this.FComponentState)) this.Destroying();
    };
    this.DestroyComponents = function () {
      var acomponent = null;
      while (this.FComponents != null) {
        acomponent = rtl.getObject(this.FComponents.Last());
        this.Remove(acomponent);
        acomponent.$destroy("Destroy");
      };
    };
    this.Destroying = function () {
      var Runner = 0;
      if (3 in this.FComponentState) return;
      this.FComponentState = rtl.includeSet(this.FComponentState,3);
      if (this.FComponents != null) for (var $l = 0, $end = this.FComponents.FCount - 1; $l <= $end; $l++) {
        Runner = $l;
        rtl.getObject(this.FComponents.Get(Runner)).Destroying();
      };
    };
    this.FindComponent = function (AName) {
      var Result = null;
      var I = 0;
      Result = null;
      if ((AName === "") || !(this.FComponents != null)) return Result;
      for (var $l = 0, $end = this.FComponents.FCount - 1; $l <= $end; $l++) {
        I = $l;
        if (pas.SysUtils.CompareText(rtl.getObject(this.FComponents.Get(I)).FName,AName) === 0) {
          Result = rtl.getObject(this.FComponents.Get(I));
          return Result;
        };
      };
      return Result;
    };
    this.RemoveFreeNotification = function (AComponent) {
      this.RemoveNotification(AComponent);
      AComponent.RemoveNotification(this);
    };
    this.InsertComponent = function (AComponent) {
      AComponent.ValidateContainer(this);
      this.ValidateRename(AComponent,"",AComponent.FName);
      if (AComponent.FOwner !== null) AComponent.FOwner.RemoveComponent(AComponent);
      this.Insert(AComponent);
      if (4 in this.FComponentState) AComponent.SetDesigning(true,true);
      this.Notification(AComponent,0);
    };
    this.RemoveComponent = function (AComponent) {
      this.Notification(AComponent,1);
      this.Remove(AComponent);
      AComponent.SetDesigning(false,true);
      this.ValidateRename(AComponent,AComponent.FName,"");
    };
    var $r = this.$rtti;
    $r.addProperty("Name",6,rtl.string,"FName","SetName");
    $r.addProperty("Tag",0,rtl.nativeint,"FTag","FTag",{Default: 0});
  });
  rtl.createClass(this,"TLoadHelper",pas.System.TObject,function () {
  });
  this.RegisterFindGlobalComponentProc = function (AFindGlobalComponent) {
    if (!($impl.FindGlobalComponentList != null)) $impl.FindGlobalComponentList = $mod.TFPList.$create("Create");
    if ($impl.FindGlobalComponentList.IndexOf(AFindGlobalComponent) < 0) $impl.FindGlobalComponentList.Add(AFindGlobalComponent);
  };
  this.SetLoadHelperClass = function (aClass) {
    var Result = null;
    Result = $impl.GlobalLoadHelper;
    $impl.GlobalLoadHelper = aClass;
    return Result;
  };
  $mod.$implcode = function () {
    $impl.GlobalLoadHelper = null;
    $impl.ClassList = null;
    $impl.FindGlobalComponentList = null;
  };
  $mod.$init = function () {
    $impl.ClassList = new Object();
  };
},[]);
rtl.module("Rtl.BrowserLoadHelper",["System","Classes","SysUtils","JS","Web"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBrowserLoadHelper",pas.Classes.TLoadHelper,function () {
  });
  $mod.$init = function () {
    pas.Classes.SetLoadHelperClass($mod.TBrowserLoadHelper);
  };
});
rtl.module("browserconsole",["System","JS","Web","Rtl.BrowserLoadHelper","SysUtils"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.BrowserLineBreak = "\n";
  this.DefaultMaxConsoleLines = 25;
  this.DefaultConsoleStyle = ".pasconsole { " + this.BrowserLineBreak + "font-family: courier;" + this.BrowserLineBreak + "font-size: 14px;" + this.BrowserLineBreak + "background: #FFFFFF;" + this.BrowserLineBreak + "color: #000000;" + this.BrowserLineBreak + "display: block;" + this.BrowserLineBreak + "}";
  this.ConsoleElementID = "";
  this.ConsoleStyle = "";
  this.MaxConsoleLines = 0;
  this.ConsoleLinesToBrowserLog = false;
  this.ResetConsole = function () {
    if ($impl.LinesParent === null) return;
    while ($impl.LinesParent.firstElementChild !== null) $impl.LinesParent.removeChild($impl.LinesParent.firstElementChild);
    $impl.AppendLine();
  };
  this.InitConsole = function () {
    if ($impl.ConsoleElement === null) return;
    if ($impl.ConsoleElement.nodeName.toLowerCase() !== "body") {
      while ($impl.ConsoleElement.firstElementChild !== null) $impl.ConsoleElement.removeChild($impl.ConsoleElement.firstElementChild);
    };
    $impl.StyleElement = document.createElement("style");
    $impl.StyleElement.innerText = $mod.ConsoleStyle;
    $impl.ConsoleElement.appendChild($impl.StyleElement);
    $impl.LinesParent = document.createElement("div");
    $impl.ConsoleElement.appendChild($impl.LinesParent);
  };
  this.HookConsole = function () {
    $impl.ConsoleElement = null;
    if ($mod.ConsoleElementID !== "") $impl.ConsoleElement = document.getElementById($mod.ConsoleElementID);
    if ($impl.ConsoleElement === null) $impl.ConsoleElement = document.body;
    if ($impl.ConsoleElement === null) return;
    $mod.InitConsole();
    $mod.ResetConsole();
    pas.System.SetWriteCallBack($impl.WriteConsole);
  };
  $mod.$implcode = function () {
    $impl.LastLine = null;
    $impl.StyleElement = null;
    $impl.LinesParent = null;
    $impl.ConsoleElement = null;
    $impl.AppendLine = function () {
      var CurrentCount = 0;
      var S = null;
      CurrentCount = 0;
      S = $impl.LinesParent.firstChild;
      while (S != null) {
        CurrentCount += 1;
        S = S.nextSibling;
      };
      while (CurrentCount > $mod.MaxConsoleLines) {
        CurrentCount -= 1;
        $impl.LinesParent.removeChild($impl.LinesParent.firstChild);
      };
      $impl.LastLine = document.createElement("div");
      $impl.LastLine.className = "pasconsole";
      $impl.LinesParent.appendChild($impl.LastLine);
    };
    $impl.EscapeString = function (S) {
      var Result = "";
      var CL = "";
      CL = pas.SysUtils.StringReplace(S,"<","&lt;",rtl.createSet(0));
      CL = pas.SysUtils.StringReplace(CL,">","&gt;",rtl.createSet(0));
      CL = pas.SysUtils.StringReplace(CL," ","&nbsp;",rtl.createSet(0));
      CL = pas.SysUtils.StringReplace(CL,"\r\n","<br>",rtl.createSet(0));
      CL = pas.SysUtils.StringReplace(CL,"\n","<br>",rtl.createSet(0));
      CL = pas.SysUtils.StringReplace(CL,"\r","<br>",rtl.createSet(0));
      Result = CL;
      return Result;
    };
    $impl.WriteConsole = function (S, NewLine) {
      var CL = "";
      CL = $impl.LastLine.innerHTML;
      CL = CL + $impl.EscapeString("" + S);
      $impl.LastLine.innerHTML = CL;
      if (NewLine) {
        if ($mod.ConsoleLinesToBrowserLog) window.console.log($impl.LastLine.innerText);
        $impl.AppendLine();
      };
    };
  };
  $mod.$init = function () {
    $mod.ConsoleLinesToBrowserLog = true;
    $mod.ConsoleElementID = "pasjsconsole";
    $mod.ConsoleStyle = $mod.DefaultConsoleStyle;
    $mod.MaxConsoleLines = 25;
    $mod.HookConsole();
  };
},[]);
rtl.module("webassembly",["System","JS"],function () {
  "use strict";
  var $mod = this;
  rtl.recNewT(this,"TJSWebAssemblyMemoryDescriptor",function () {
    this.initial = 0;
    this.maximum = 0;
    this.shared = false;
    this.$eq = function (b) {
      return (this.initial === b.initial) && (this.maximum === b.maximum) && (this.shared === b.shared);
    };
    this.$assign = function (s) {
      this.initial = s.initial;
      this.maximum = s.maximum;
      this.shared = s.shared;
      return this;
    };
  });
  rtl.recNewT(this,"TJSWebAssemblyTableDescriptor",function () {
    this.element = "";
    this.initial = 0;
    this.maximum = 0;
    this.$eq = function (b) {
      return (this.element === b.element) && (this.initial === b.initial) && (this.maximum === b.maximum);
    };
    this.$assign = function (s) {
      this.element = s.element;
      this.initial = s.initial;
      this.maximum = s.maximum;
      return this;
    };
  });
});
rtl.module("wasienv",["System","SysUtils","Classes","JS","webassembly","Types"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.WASI_ESUCCESS = 0;
  this.WASI_EBADF = 8;
  this.WASI_EINVAL = 28;
  this.WASI_ENOSYS = 52;
  this.WASI_CLOCK_MONOTONIC = 0;
  this.WASI_CLOCK_PROCESS_CPUTIME_ID = 1;
  this.WASI_CLOCK_REALTIME = 2;
  this.WASI_CLOCK_THREAD_CPUTIME_ID = 3;
  this.WASI_STDIN_FILENO = 0;
  this.WASI_STDOUT_FILENO = 1;
  this.WASI_STDERR_FILENO = 2;
  rtl.createClass(this,"TPas2JSWASIEnvironment",pas.System.TObject,function () {
    this.UTF8TextDecoder = null;
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FExitCode = 0;
      this.FImportObject = null;
      this.Finstance = null;
      this.FIsLittleEndian = false;
      this.FModuleInstanceExports = null;
      this.FOnGetConsoleInputBuffer = null;
      this.FOnGetConsoleInputString = null;
      this.FOnStdErrorWrite = null;
      this.FOnStdOutputWrite = null;
      this.FImportExtensions = null;
      this.FWASIImportName = "";
      this.FMemory = null;
    };
    this.$final = function () {
      this.FImportObject = undefined;
      this.Finstance = undefined;
      this.FModuleInstanceExports = undefined;
      this.FOnGetConsoleInputBuffer = undefined;
      this.FOnGetConsoleInputString = undefined;
      this.FOnStdErrorWrite = undefined;
      this.FOnStdOutputWrite = undefined;
      this.FImportExtensions = undefined;
      this.FMemory = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.GetConsoleInputBuffer = function () {
      var Result = null;
      var S = "";
      Result = null;
      if (this.FOnGetConsoleInputBuffer != null) {
        this.FOnGetConsoleInputBuffer(this,{get: function () {
            return Result;
          }, set: function (v) {
            Result = v;
          }})}
       else if (this.FOnGetConsoleInputString != null) {
        S = "";
        this.FOnGetConsoleInputString(this,{get: function () {
            return S;
          }, set: function (v) {
            S = v;
          }});
        Result = $impl.toUTF8Array(S);
      } else Result = new Uint8Array(0);
      return Result;
    };
    this.GetFileBuffer = function (FD) {
      var Result = null;
      Result = new Uint8Array(0);
      return Result;
    };
    this.GetImportObject = function () {
      var Result = null;
      if (!(this.FImportObject != null)) {
        this.FImportObject = new Object();
        this.GetImports(this.FImportObject);
      };
      Result = this.FImportObject;
      return Result;
    };
    this.getiovs = function (view, iovs, iovsLen) {
      var Result = null;
      var I = 0;
      var ArrayBuf = null;
      var Ptr = 0;
      var Buf = 0;
      var BufLen = 0;
      Result = new Array();
      for (var $l = 0, $end = iovsLen - 1; $l <= $end; $l++) {
        I = $l;
        Ptr = iovs + (I * 8);
        Buf = view.getUint32(Ptr,this.FIsLittleEndian);
        BufLen = view.getUint32(Ptr + 4,this.FIsLittleEndian);
        ArrayBuf = new Uint8Array(this.GetMemory().buffer,Buf,BufLen);
        Result.push(ArrayBuf);
      };
      return Result;
    };
    this.GetMemory = function () {
      var Result = null;
      if (this.FMemory != null) {
        Result = this.FMemory}
       else Result = this.FModuleInstanceExports.memory;
      return Result;
    };
    this.SetInstance = function (AValue) {
      if (this.Finstance === AValue) return;
      this.Finstance = AValue;
      this.FModuleInstanceExports = this.Finstance.exports;
      if (!(this.FMemory != null) && (this.FModuleInstanceExports.memory != null)) this.FMemory = this.FModuleInstanceExports.memory;
    };
    this.setBigUint64 = function (View, byteOffset, value, littleEndian) {
      var LowWord = 0;
      var HighWord = 0;
      LowWord = value;
      HighWord = Math.floor(value / 4294967296);
      if (littleEndian) {
        View.setUint32(byteOffset + 0,LowWord,littleEndian);
        View.setUint32(byteOffset + 4,HighWord,littleEndian);
      } else {
        View.setUint32(byteOffset + 4,LowWord,littleEndian);
        View.setUint32(byteOffset + 0,HighWord,littleEndian);
      };
    };
    this.DoConsoleWrite = function (IsStdErr, aBytes) {
      var S = "";
      // Result=String.fromCharCode.apply(null, new Uint16Array(a));
      S=String.fromCharCode.apply(null, aBytes);
      if (IsStdErr) {
        if (this.FOnStdErrorWrite != null) this.FOnStdErrorWrite(this,S);
      } else {
        if (this.FOnStdOutputWrite != null) this.FOnStdOutputWrite(this,S);
      };
    };
    this.GetImports = function (aImports) {
      aImports["args_get"] = rtl.createCallback(this,"args_get");
      aImports["args_sizes_get"] = rtl.createCallback(this,"args_sizes_get");
      aImports["clock_res_get"] = rtl.createCallback(this,"clock_res_get");
      aImports["clock_time_get"] = rtl.createCallback(this,"clock_time_get");
      aImports["environ_get"] = rtl.createCallback(this,"environ_get");
      aImports["environ_sizes_get"] = rtl.createCallback(this,"environ_sizes_get");
      aImports["fd_advise"] = rtl.createCallback(this,"fd_advise");
      aImports["fd_allocate"] = rtl.createCallback(this,"fd_allocate");
      aImports["fd_close"] = rtl.createCallback(this,"fd_close");
      aImports["fd_datasync"] = rtl.createCallback(this,"fd_datasync");
      aImports["fd_fdstat_get"] = rtl.createCallback(this,"fd_fdstat_get");
      aImports["fd_fdstat_set_flags"] = rtl.createCallback(this,"fd_fdstat_set_flags");
      aImports["fd_fdstat_set_rights"] = rtl.createCallback(this,"fd_fdstat_set_rights");
      aImports["fd_filestat_get"] = rtl.createCallback(this,"fd_filestat_get");
      aImports["fd_filestat_set_size"] = rtl.createCallback(this,"fd_filestat_set_size");
      aImports["fd_filestat_set_times"] = rtl.createCallback(this,"fd_filestat_set_times");
      aImports["fd_pread"] = rtl.createCallback(this,"fd_pread");
      aImports["fd_prestat_dir_name"] = rtl.createCallback(this,"fd_prestat_dir_name");
      aImports["fd_prestat_get"] = rtl.createCallback(this,"fd_prestat_get");
      aImports["fd_pwrite"] = rtl.createCallback(this,"fd_pwrite");
      aImports["fd_read"] = rtl.createCallback(this,"fd_read");
      aImports["fd_readdir"] = rtl.createCallback(this,"fd_readdir");
      aImports["fd_renumber"] = rtl.createCallback(this,"fd_renumber");
      aImports["fd_seek"] = rtl.createCallback(this,"fd_seek");
      aImports["fd_sync"] = rtl.createCallback(this,"fd_sync");
      aImports["fd_tell"] = rtl.createCallback(this,"fd_tell");
      aImports["fd_write"] = rtl.createCallback(this,"fd_write");
      aImports["path_create_directory"] = rtl.createCallback(this,"path_create_directory");
      aImports["path_filestat_get"] = rtl.createCallback(this,"path_filestat_get");
      aImports["path_filestat_set_times"] = rtl.createCallback(this,"path_filestat_set_times");
      aImports["path_link"] = rtl.createCallback(this,"path_link");
      aImports["path_open"] = rtl.createCallback(this,"path_open");
      aImports["path_readlink"] = rtl.createCallback(this,"path_readlink");
      aImports["path_remove_directory"] = rtl.createCallback(this,"path_remove_directory");
      aImports["path_rename"] = rtl.createCallback(this,"path_rename");
      aImports["path_symlink"] = rtl.createCallback(this,"path_symlink");
      aImports["path_unlink_file"] = rtl.createCallback(this,"path_unlink_file");
      aImports["poll_oneoff"] = rtl.createCallback(this,"poll_oneoff");
      aImports["proc_exit"] = rtl.createCallback(this,"proc_exit");
      aImports["proc_raise"] = rtl.createCallback(this,"proc_raise");
      aImports["random_get"] = rtl.createCallback(this,"random_get");
      aImports["sched_yield"] = rtl.createCallback(this,"sched_yield");
      aImports["sock_recv"] = rtl.createCallback(this,"sock_recv");
      aImports["sock_send"] = rtl.createCallback(this,"sock_send");
      aImports["sock_shutdown"] = rtl.createCallback(this,"sock_shutdown");
    };
    this.GetTime = function (aClockID) {
      var Result = 0;
      Result = -1;
      var $tmp = aClockID;
      if ($tmp === 0) {
        Result = Date.now()}
       else if ($tmp === 2) {
        Result = Date.now()}
       else if (($tmp === 1) || ($tmp === 3)) Result = Date.now();
      Result = Result * 1000000;
      return Result;
    };
    this.getModuleMemoryDataView = function () {
      var Result = null;
      Result = new DataView(this.GetMemory().buffer);
      return Result;
    };
    this.AddExtension = function (aExtension) {
      if (!(this.FImportExtensions != null)) this.FImportExtensions = pas.Classes.TFPList.$create("Create");
      this.FImportExtensions.Add(aExtension);
    };
    this.RemoveExtension = function (aExtension) {
      if (this.FImportExtensions != null) this.FImportExtensions.Remove(aExtension);
    };
    this.args_get = function (argv, argvBuf) {
      var Result = 0;
      Result = 0;
      return Result;
    };
    this.args_sizes_get = function (argc, argvBufSize) {
      var Result = 0;
      var View = null;
      View = this.getModuleMemoryDataView();
      View.setUint32(argc,0,this.FIsLittleEndian);
      View.setUint32(argvBufSize,0,this.FIsLittleEndian);
      Result = 0;
      return Result;
    };
    this.clock_res_get = function (clockId, resolution) {
      var Result = 0;
      var view = null;
      view = this.getModuleMemoryDataView();
      this.$class.setBigUint64(view,resolution,0,this.FIsLittleEndian);
      Result = 0;
      return Result;
    };
    this.clock_time_get = function (clockId, precision, time) {
      var Result = 0;
      var view = null;
      var n = 0;
      view = this.getModuleMemoryDataView();
      n = this.GetTime(clockId);
      if (n === -1) {
        Result = 28}
       else {
        this.$class.setBigUint64(view,time,n,this.FIsLittleEndian);
        Result = 0;
      };
      return Result;
    };
    this.environ_get = function (environ, environBuf) {
      var Result = 0;
      Result = 0;
      return Result;
    };
    this.environ_sizes_get = function (environCount, environBufSize) {
      var Result = 0;
      var View = null;
      View = this.getModuleMemoryDataView();
      View.setUint32(environCount,0,this.FIsLittleEndian);
      View.setUint32(environBufSize,0,this.FIsLittleEndian);
      Result = 0;
      return Result;
    };
    this.fd_advise = function (fd, offset, len, advice) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_advise");
      Result = 52;
      return Result;
    };
    this.fd_allocate = function (fd, offset, len) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_allocate");
      Result = 52;
      return Result;
    };
    this.fd_close = function (fd) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_close");
      Result = 52;
      return Result;
    };
    this.fd_datasync = function (fd) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_datasync");
      Result = 52;
      return Result;
    };
    this.fd_fdstat_get = function (fd, bufPtr) {
      var Result = 0;
      var View = null;
      View = this.getModuleMemoryDataView();
      View.setUint8(bufPtr,fd);
      View.setUint16(bufPtr + 2,0,this.FIsLittleEndian);
      View.setUint16(bufPtr + 4,0,this.FIsLittleEndian);
      this.$class.setBigUint64(View,bufPtr + 8,0,this.FIsLittleEndian);
      this.$class.setBigUint64(View,bufPtr + 8 + 8,0,this.FIsLittleEndian);
      Result = 0;
      return Result;
    };
    this.fd_fdstat_set_flags = function (fd, flags) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_fdstat_set_flags");
      Result = 52;
      return Result;
    };
    this.fd_fdstat_set_rights = function (fd, fsRightsBase, fsRightsInheriting) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_fdstat_set_rights");
      Result = 52;
      return Result;
    };
    this.fd_filestat_get = function (fd, bufPtr) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_filestat_get");
      Result = 52;
      return Result;
    };
    this.fd_filestat_set_size = function (fd, stSize) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_filestat_set_size");
      Result = 52;
      return Result;
    };
    this.fd_filestat_set_times = function (fd, stAtim, stMtim, fstflags) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_filestat_set_times");
      Result = 52;
      return Result;
    };
    this.fd_pread = function (fd, iovs, iovsLen, offset, nread) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_pread");
      Result = 52;
      return Result;
    };
    this.fd_prestat_dir_name = function (fd, pathPtr, pathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_prestat_dir_name");
      Result = 52;
      return Result;
    };
    this.fd_prestat_get = function (fd, bufPtr) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_prestat_get");
      Result = 8;
      return Result;
    };
    this.fd_pwrite = function (fd, iovs, iovsLen, offset, nwritten) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_pwrite");
      Result = 52;
      return Result;
    };
    this.fd_read = function (fd, iovs, iovsLen, nread) {
      var $Self = this;
      var Result = 0;
      var view = null;
      var bytesRead = 0;
      var bufferBytes = null;
      var Buffers = null;
      function readv(element, index, anArray) {
        var Result = false;
        var b = 0;
        b = 0;
        while ((b < element.byteLength) && (bytesRead < bufferBytes.length)) {
          element[b] = bufferBytes[bytesRead];
          b += 1;
          bytesRead += 1;
        };
        Result = true;
        return Result;
      };
      bytesRead = 0;
      view = this.getModuleMemoryDataView();
      if (fd === 0) {
        bufferBytes = this.GetConsoleInputBuffer();
      } else bufferBytes = this.GetFileBuffer(fd);
      if (bufferBytes.length > 0) {
        Buffers = this.getiovs(view,iovs,iovsLen);
        Buffers.forEach(readv);
      };
      view.setUint32(nread,bytesRead,this.FIsLittleEndian);
      Result = 0;
      return Result;
    };
    this.fd_readdir = function (fd, bufPtr, bufLen, cookie, bufusedPtr) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_readdir");
      Result = 52;
      return Result;
    };
    this.fd_renumber = function (afrom, ato) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_renumber");
      Result = 52;
      return Result;
    };
    this.fd_seek = function (fd, offset, whence, newOffsetPtr) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_seek");
      Result = 52;
      return Result;
    };
    this.fd_sync = function (fd) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_sync");
      Result = 52;
      return Result;
    };
    this.fd_tell = function (fd, offsetPtr) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.fd_tell");
      Result = 52;
      return Result;
    };
    this.fd_write = function (fd, iovs, iovsLen, nwritten) {
      var $Self = this;
      var Result = 0;
      var view = null;
      var written = 0;
      var bufferBytes = null;
      var Buffers = null;
      function writev(element, index, anArray) {
        var Result = false;
        var b = 0;
        for (var $l = 0, $end = element.byteLength - 1; $l <= $end; $l++) {
          b = $l;
          bufferBytes.push(element[b]);
        };
        written += element.byteLength;
        Result = true;
        return Result;
      };
      bufferBytes = new Array();
      view = this.getModuleMemoryDataView();
      written = 0;
      Buffers = this.getiovs(view,iovs,iovsLen);
      Buffers.forEach(writev);
      if ((fd === 1) || (fd === 2)) this.DoConsoleWrite(fd === 2,bufferBytes);
      view.setUint32(nwritten,written,this.FIsLittleEndian);
      Result = 0;
      return Result;
    };
    this.path_create_directory = function (fd, pathPtr, pathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_create_directory");
      Result = 52;
      return Result;
    };
    this.path_filestat_get = function (fd, flags, pathPtr, pathLen, bufPtr) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_filestat_get");
      Result = 52;
      return Result;
    };
    this.path_filestat_set_times = function (fd, fstflags, pathPtr, pathLen, stAtim, stMtim) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_filestat_set_times");
      Result = 52;
      return Result;
    };
    this.path_link = function (oldFd, oldFlags, oldPath, oldPathLen, newFd, newPath, newPathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_link");
      Result = 52;
      return Result;
    };
    this.path_open = function (dirfd, dirflags, pathPtr, pathLen, oflags, fsRightsBase, fsRightsInheriting, fsFlags, fd) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_open");
      Result = 52;
      return Result;
    };
    this.path_readlink = function (fd, pathPtr, pathLen, buf, bufLen, bufused) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_readlink");
      Result = 52;
      return Result;
    };
    this.path_remove_directory = function (fd, pathPtr, pathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_remove_directory");
      Result = 52;
      return Result;
    };
    this.path_rename = function (oldFd, oldPath, oldPathLen, newFd, newPath, newPathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_rename");
      Result = 52;
      return Result;
    };
    this.path_symlink = function (oldPath, oldPathLen, fd, newPath, newPathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_symlink");
      Result = 52;
      return Result;
    };
    this.path_unlink_file = function (fd, pathPtr, pathLen) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.path_unlink_file");
      Result = 52;
      return Result;
    };
    this.poll_oneoff = function (sin, sout, nsubscriptions, nevents) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.poll_oneoff");
      Result = 52;
      return Result;
    };
    this.proc_exit = function (rval) {
      var Result = 0;
      this.FExitCode = rval;
      Result = 0;
      return Result;
    };
    this.proc_raise = function (sig) {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.proc_raise");
      Result = 52;
      return Result;
    };
    this.random_get = function (bufPtr, bufLen) {
      var Result = 0;
      var arr = null;
      var I = 0;
      var View = null;
      arr = new Uint8Array(bufLen);
      crypto.getRandomValues(arr);
      View = this.getModuleMemoryDataView();
      for (var $l = 0, $end = arr.length - 1; $l <= $end; $l++) {
        I = $l;
        View.setInt8(bufPtr + I,arr[I]);
      };
      Result = 0;
      return Result;
    };
    this.sched_yield = function () {
      var Result = 0;
      Result = 0;
      return Result;
    };
    this.sock_recv = function () {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.sock_recv");
      Result = 52;
      return Result;
    };
    this.sock_send = function () {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.sock_recv");
      Result = 52;
      return Result;
    };
    this.sock_shutdown = function () {
      var Result = 0;
      console.log("Unimplemented: TPas2JSWASIEnvironment.sock_shutdown");
      Result = 52;
      return Result;
    };
    this.SetMemory = function (aMemory) {
      this.FMemory = aMemory;
    };
    this.Create$1 = function () {
      this.FIsLittleEndian = true;
      this.FWASIImportName = "wasi_snapshot_preview1";
      return this;
    };
    this.Destroy = function () {
      pas.SysUtils.FreeAndNil({p: this, get: function () {
          return this.p.FImportExtensions;
        }, set: function (v) {
          this.p.FImportExtensions = v;
        }});
      pas.System.TObject.Destroy.call(this);
    };
    this.AddImports = function (aObject) {
      var Ext = null;
      var I = 0;
      var O = null;
      aObject[this.FWASIImportName] = this.GetImportObject();
      if (this.FImportExtensions != null) for (var $l = 0, $end = this.FImportExtensions.FCount - 1; $l <= $end; $l++) {
        I = $l;
        Ext = rtl.getObject(this.FImportExtensions.Get(I));
        O = new Object();
        Ext.FillImportObject(O);
        aObject[Ext.ImportName()] = O;
      };
    };
  });
  rtl.createClass(this,"TImportExtension",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FEnv = null;
    };
    this.$final = function () {
      this.FEnv = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.getModuleMemoryDataView = function () {
      var Result = null;
      Result = this.FEnv.getModuleMemoryDataView();
      return Result;
    };
    this.Create$1 = function (aEnv) {
      this.FEnv = aEnv;
      if (this.FEnv != null) this.FEnv.AddExtension(this);
      return this;
    };
    this.Destroy = function () {
      if (this.FEnv != null) this.FEnv.RemoveExtension(this);
      pas.System.TObject.Destroy.call(this);
    };
  });
  rtl.recNewT(this,"TWebAssemblyStartDescriptor",function () {
    this.Module = null;
    this.Memory = null;
    this.Table = null;
    this.Exported = null;
    this.Imports = null;
    this.Instance = null;
    this.CallRun = null;
    this.RunExceptionClass = "";
    this.RunExceptionMessage = "";
    this.$eq = function (b) {
      return (this.Module === b.Module) && (this.Memory === b.Memory) && (this.Table === b.Table) && (this.Exported === b.Exported) && (this.Imports === b.Imports) && (this.Instance === b.Instance) && rtl.eqCallback(this.CallRun,b.CallRun) && (this.RunExceptionClass === b.RunExceptionClass) && (this.RunExceptionMessage === b.RunExceptionMessage);
    };
    this.$assign = function (s) {
      this.Module = s.Module;
      this.Memory = s.Memory;
      this.Table = s.Table;
      this.Exported = s.Exported;
      this.Imports = s.Imports;
      this.Instance = s.Instance;
      this.CallRun = s.CallRun;
      this.RunExceptionClass = s.RunExceptionClass;
      this.RunExceptionMessage = s.RunExceptionMessage;
      return this;
    };
  });
  rtl.createClass(this,"TWASIHost",pas.Classes.TComponent,function () {
    this.$init = function () {
      pas.Classes.TComponent.$init.call(this);
      this.FAfterInstantation = null;
      this.FAfterStart = null;
      this.FBeforeInstantation = null;
      this.FBeforeStart = null;
      this.FEnv = null;
      this.FExported = null;
      this.FOnInstantiateFail = null;
      this.FOnLoadFail = null;
      this.FPreparedStartDescriptor = $mod.TWebAssemblyStartDescriptor.$new();
      this.FMemoryDescriptor = pas.webassembly.TJSWebAssemblyMemoryDescriptor.$new();
      this.FOnConsoleRead = null;
      this.FOnConsoleWrite = null;
      this.FPredefinedConsoleInput = null;
      this.FReadLineCount = 0;
      this.FRunEntryFunction = "";
      this.FTableDescriptor = pas.webassembly.TJSWebAssemblyTableDescriptor.$new();
    };
    this.$final = function () {
      this.FAfterInstantation = undefined;
      this.FAfterStart = undefined;
      this.FBeforeInstantation = undefined;
      this.FBeforeStart = undefined;
      this.FEnv = undefined;
      this.FExported = undefined;
      this.FOnInstantiateFail = undefined;
      this.FOnLoadFail = undefined;
      this.FPreparedStartDescriptor = undefined;
      this.FMemoryDescriptor = undefined;
      this.FOnConsoleRead = undefined;
      this.FOnConsoleWrite = undefined;
      this.FPredefinedConsoleInput = undefined;
      this.FTableDescriptor = undefined;
      pas.Classes.TComponent.$final.call(this);
    };
    this.DoAfterInstantiate = function () {
      if (this.FAfterInstantation != null) this.FAfterInstantation(this);
    };
    this.DoBeforeInstantiate = function () {
      if (this.FBeforeInstantation != null) this.FBeforeInstantation(this);
    };
    this.DoLoadFail = function (aError) {
      if (this.FOnLoadFail != null) this.FOnLoadFail(this,aError);
    };
    this.DoInstantiateFail = function (aError) {
      if (this.FOnInstantiateFail != null) this.FOnInstantiateFail(this,aError);
    };
    this.PrepareWebAssemblyInstance = function (aDescr) {
      this.FPreparedStartDescriptor.$assign(aDescr);
      this.FExported = aDescr.Exported;
      this.FEnv.SetInstance(aDescr.Instance);
      this.FEnv.SetMemory(aDescr.Memory);
      this.DoAfterInstantiate();
    };
    this.RunWebAssemblyInstance = function (aBeforeStart, aAfterStart, aRun) {
      var Result = false;
      Result = true;
      if (aBeforeStart != null) Result = aBeforeStart(this,$mod.TWebAssemblyStartDescriptor.$clone(this.FPreparedStartDescriptor));
      if (this.FBeforeStart != null) this.FBeforeStart(this,$mod.TWebAssemblyStartDescriptor.$clone(this.FPreparedStartDescriptor),{get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }});
      if (!Result) return Result;
      try {
        if (aRun === null) aRun = this.FPreparedStartDescriptor.CallRun;
        aRun(this.FPreparedStartDescriptor.Exported);
        if (aAfterStart != null) aAfterStart(this,$mod.TWebAssemblyStartDescriptor.$clone(this.FPreparedStartDescriptor));
        if (this.FAfterStart != null) this.FAfterStart(this,$mod.TWebAssemblyStartDescriptor.$clone(this.FPreparedStartDescriptor));
      } catch ($e) {
        if (pas.SysUtils.Exception.isPrototypeOf($e)) {
          var E = $e;
          this.FPreparedStartDescriptor.RunExceptionClass = E.$classname;
          this.FPreparedStartDescriptor.RunExceptionMessage = E.fMessage;
        } else if (rtl.isExt($e,Error)) {
          var JE = $e;
          this.FPreparedStartDescriptor.RunExceptionClass = typeof(JE);
          this.FPreparedStartDescriptor.RunExceptionMessage = JE.message;
        } else if (rtl.isExt($e,Object)) {
          var OE = $e;
          this.FPreparedStartDescriptor.RunExceptionClass = typeof(OE);
          this.FPreparedStartDescriptor.RunExceptionMessage = JSON.stringify(OE);
        } else throw $e
      };
      return Result;
    };
    this.DoStdRead = function (Sender, AInput) {
      var S = "";
      S = "";
      if (this.FOnConsoleRead != null) {
        this.FOnConsoleRead(this,{get: function () {
            return S;
          }, set: function (v) {
            S = v;
          }})}
       else {
        if (this.FReadLineCount < this.FPredefinedConsoleInput.GetCount()) {
          S = this.FPredefinedConsoleInput.Get(this.FReadLineCount);
          this.FReadLineCount += 1;
        };
      };
      AInput.set(S);
    };
    this.DoStdWrite = function (Sender, aOutput) {
      this.WriteOutput(aOutput);
    };
    this.CreateWebAssembly = function (aPath, aImportObject) {
      var $Self = this;
      var Result = null;
      function InstantiateOK(Res) {
        var Result = undefined;
        Result = Res;
        return Result;
      };
      function InstantiateFail(Res) {
        var Result = undefined;
        Result = false;
        $Self.DoInstantiateFail(Res);
        return Result;
      };
      function ArrayOK(res2) {
        var Result = undefined;
        $Self.DoBeforeInstantiate();
        Result = WebAssembly.instantiate(res2,aImportObject).then(InstantiateOK,InstantiateFail);
        return Result;
      };
      function fetchOK(res) {
        var Result = undefined;
        Result = res.arrayBuffer().then(ArrayOK,null);
        return Result;
      };
      function DoFail(res) {
        var Result = undefined;
        Result = false;
        $Self.DoLoadFail(res);
        return Result;
      };
      Result = fetch(aPath).then(fetchOK,DoFail).catch(DoFail);
      return Result;
    };
    this.CreateWasiEnvironment = function () {
      var Result = null;
      Result = $mod.TPas2JSWASIEnvironment.$create("Create$1");
      return Result;
    };
    this.GetTable = function () {
      var Result = null;
      Result = new WebAssembly.Table(pas.webassembly.TJSWebAssemblyTableDescriptor.$clone(this.FTableDescriptor));
      return Result;
    };
    this.GetMemory = function () {
      var Result = null;
      Result = new WebAssembly.Memory(pas.webassembly.TJSWebAssemblyMemoryDescriptor.$clone(this.FMemoryDescriptor));
      return Result;
    };
    this.Create$1 = function (aOwner) {
      pas.Classes.TComponent.Create$1.call(this,aOwner);
      this.FEnv = this.CreateWasiEnvironment();
      this.FEnv.FOnStdErrorWrite = rtl.createCallback(this,"DoStdWrite");
      this.FEnv.FOnStdOutputWrite = rtl.createCallback(this,"DoStdWrite");
      this.FEnv.FOnGetConsoleInputString = rtl.createCallback(this,"DoStdRead");
      this.FMemoryDescriptor.initial = 256;
      this.FMemoryDescriptor.maximum = 256;
      this.FMemoryDescriptor.shared = false;
      this.FTableDescriptor.initial = 0;
      this.FTableDescriptor.maximum = 0;
      this.FTableDescriptor.element = "anyfunc";
      this.FPredefinedConsoleInput = pas.Classes.TStringList.$create("Create$1");
      return this;
    };
    this.Destroy = function () {
      pas.SysUtils.FreeAndNil({p: this, get: function () {
          return this.p.FPredefinedConsoleInput;
        }, set: function (v) {
          this.p.FPredefinedConsoleInput = v;
        }});
      pas.SysUtils.FreeAndNil({p: this, get: function () {
          return this.p.FEnv;
        }, set: function (v) {
          this.p.FEnv = v;
        }});
      pas.Classes.TComponent.Destroy.call(this);
    };
    this.WriteOutput = function (aOutput) {
      if (this.FOnConsoleWrite != null) {
        this.FOnConsoleWrite(this,aOutput)}
       else pas.System.Writeln(aOutput);
    };
    this.InitStartDescriptor = function (aMemory, aTable, aImportObj) {
      var Result = $mod.TWebAssemblyStartDescriptor.$new();
      Result.Memory = aMemory;
      Result.Table = aTable;
      if (!(aImportObj != null)) aImportObj = new Object();
      aImportObj["env"] = pas.JS.New(["memory",Result.Memory,"tbl",Result.Table]);
      this.FEnv.AddImports(aImportObj);
      Result.Imports = aImportObj;
      return Result;
    };
    this.StartWebAssembly = function (aPath, DoRun, aBeforeStart, aAfterStart) {
      var $Self = this;
      var WASD = $mod.TWebAssemblyStartDescriptor.$new();
      function InitEnv(aValue) {
        var Result = undefined;
        Result = true;
        WASD.Instance = aValue.instance;
        WASD.Module = aValue.module;
        WASD.Exported = WASD.Instance.exports;
        WASD.CallRun = function (aExports) {
          if ($Self.FRunEntryFunction === "") {
            aExports._start()}
           else aExports[$Self.FRunEntryFunction]();
        };
        $Self.PrepareWebAssemblyInstance($mod.TWebAssemblyStartDescriptor.$clone(WASD));
        if (DoRun) $Self.RunWebAssemblyInstance(aBeforeStart,aAfterStart,null);
        return Result;
      };
      function DoFail(aValue) {
        var Result = undefined;
        Result = true;
        console.log("Failed to create webassembly. Reason:");
        console.debug(aValue);
        return Result;
      };
      this.FReadLineCount = 0;
      this.FPreparedStartDescriptor.$assign($mod.TWebAssemblyStartDescriptor.$new());
      WASD.$assign(this.InitStartDescriptor(this.GetMemory(),this.GetTable(),null));
      this.CreateWebAssembly(aPath,WASD.Imports).then(InitEnv,DoFail).catch(DoFail);
    };
  });
  $mod.$implcode = function () {
    $impl.toUTF8Array = function (str) {
      var Result = null;
      var Len = 0;
      var I = 0;
      var P = 0;
      var charCode = 0;
      function push(abyte) {
        Result[P] = abyte;
        P += 1;
      };
      Result = new Uint8Array(str.length * 4);
      P = 0;
      Len = str.length;
      I = 1;
      while (I <= Len) {
        charCode = str.charCodeAt(I - 1);
        if (charCode < 0x80) {
          push(charCode)}
         else if (charCode < 0x800) {
          push(rtl.or(0xc0,Math.floor(charCode / 64)));
          push(rtl.or(0x80,charCode & 0x3f));
        } else if ((charCode < 0xd800) || (charCode >= 0xe000)) {
          push(rtl.or(0xe0,Math.floor(charCode / 4096)));
          push(rtl.or(0x80,Math.floor(charCode / 64) & 0x3f));
          push(rtl.or(0x80,charCode & 0x3f));
        } else {
          I += 1;
          charCode = 0x10000 + rtl.or(rtl.shl(charCode & 0x3ff,10),str.charCodeAt(I - 1) & 0x3ff);
          push(rtl.or(0xf0,Math.floor(charCode / 262144)));
          push(rtl.or(0x80,Math.floor(charCode / 4096) & 0x3f));
          push(rtl.or(0x80,Math.floor(charCode / 64) & 0x3f));
          push(rtl.or(0x80,charCode & 0x3f));
        };
        I += 1;
      };
      Result = Result.slice(0,P);
      return Result;
    };
  };
  $mod.$init = function () {
    (function () {
      var Opts = null;
      Opts = new Object();
      Opts.ignoreBOM = true;
      Opts.fatal = true;
      $mod.TPas2JSWASIEnvironment.UTF8TextDecoder = new TextDecoder("utf-8",Opts);
    })();
  };
},["weborworker"]);
rtl.module("CustApp",["System","Classes","SysUtils","Types","JS"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TCustomApplication",pas.Classes.TComponent,function () {
    this.$init = function () {
      pas.Classes.TComponent.$init.call(this);
      this.FExceptObjectJS = undefined;
      this.FTerminated = false;
      this.FOptionChar = "";
      this.FCaseSensitiveOptions = false;
      this.FStopOnException = false;
      this.FExceptionExitCode = 0;
      this.FExceptObject = null;
    };
    this.$final = function () {
      this.FExceptObject = undefined;
      pas.Classes.TComponent.$final.call(this);
    };
    this.Create$1 = function (AOwner) {
      pas.Classes.TComponent.Create$1.call(this,AOwner);
      this.FOptionChar = "-";
      this.FCaseSensitiveOptions = true;
      this.FStopOnException = false;
      return this;
    };
    this.HandleException = function (Sender) {
      var E = null;
      var Tmp = null;
      Tmp = null;
      E = this.FExceptObject;
      if ((E === null) && pas.System.Assigned(this.FExceptObjectJS)) {
        if (rtl.isExt(this.FExceptObjectJS,Error,1)) {
          Tmp = pas.SysUtils.EExternalException.$create("Create$1",[this.FExceptObjectJS.message])}
         else if (rtl.isExt(this.FExceptObjectJS,Object,1) && this.FExceptObjectJS.hasOwnProperty("message")) {
          Tmp = pas.SysUtils.EExternalException.$create("Create$1",["" + this.FExceptObjectJS["message"]])}
         else Tmp = pas.SysUtils.EExternalException.$create("Create$1",[JSON.stringify(this.FExceptObjectJS)]);
        E = Tmp;
      };
      try {
        this.ShowException(E);
        if (this.FStopOnException) this.Terminate$1(this.FExceptionExitCode);
      } finally {
        Tmp = rtl.freeLoc(Tmp);
      };
      if (Sender === null) ;
    };
    this.Initialize = function () {
      this.FTerminated = false;
    };
    this.Run = function () {
      do {
        this.FExceptObject = null;
        this.FExceptObjectJS = null;
        try {
          this.DoRun();
        } catch ($e) {
          if (pas.SysUtils.Exception.isPrototypeOf($e)) {
            var E = $e;
            this.FExceptObject = E;
            this.FExceptObjectJS = E;
            this.HandleException(this);
          } else {
            this.FExceptObject = null;
            this.FExceptObjectJS = $e;
            this.HandleException(this);
          }
        };
        break;
      } while (!this.FTerminated);
    };
    this.Terminate$1 = function (AExitCode) {
      this.FTerminated = true;
      rtl.exitcode = AExitCode;
    };
  });
});
rtl.module("BrowserApp",["System","Classes","SysUtils","Types","JS","Web","CustApp"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"TBrowserApplication",pas.CustApp.TCustomApplication,function () {
    this.$init = function () {
      pas.CustApp.TCustomApplication.$init.call(this);
      this.FShowExceptions = false;
    };
    this.DoRun = function () {
    };
    this.Create$1 = function (aOwner) {
      pas.CustApp.TCustomApplication.Create$1.call(this,aOwner);
      this.FShowExceptions = true;
      if ($impl.AppInstance === null) {
        $impl.AppInstance = this;
        pas.Classes.RegisterFindGlobalComponentProc($impl.DoFindGlobalComponent);
      };
      return this;
    };
    this.Destroy = function () {
      if ($impl.AppInstance === this) $impl.AppInstance = null;
      pas.Classes.TComponent.Destroy.call(this);
    };
    this.ShowException = function (E) {
      var S = "";
      if (E !== null) {
        S = E.$classname + ": " + E.fMessage}
       else if (this.FExceptObjectJS) S = this.FExceptObjectJS.toString();
      S = "Unhandled exception caught: " + S;
      if (this.FShowExceptions) window.alert(S);
      pas.System.Writeln(S);
    };
    this.HandleException = function (Sender) {
      if (pas.SysUtils.Exception.isPrototypeOf(this.FExceptObject)) this.ShowException(this.FExceptObject);
      pas.CustApp.TCustomApplication.HandleException.call(this,Sender);
    };
  });
  this.ReloadEnvironmentStrings = function () {
    var I = 0;
    var S = "";
    var N = "";
    var A = [];
    var P = [];
    if ($impl.EnvNames != null) pas.SysUtils.FreeAndNil({p: $impl, get: function () {
        return this.p.EnvNames;
      }, set: function (v) {
        this.p.EnvNames = v;
      }});
    $impl.EnvNames = new Object();
    S = window.location.search;
    S = pas.System.Copy(S,2,S.length - 1);
    A = S.split("&");
    for (var $l = 0, $end = rtl.length(A) - 1; $l <= $end; $l++) {
      I = $l;
      P = A[I].split("=");
      N = pas.SysUtils.LowerCase(decodeURIComponent(P[0]));
      if (rtl.length(P) === 2) {
        $impl.EnvNames[N] = decodeURIComponent(P[1])}
       else if (rtl.length(P) === 1) $impl.EnvNames[N] = "";
    };
  };
  $mod.$implcode = function () {
    $impl.EnvNames = null;
    $impl.Params = [];
    $impl.AppInstance = null;
    $impl.ReloadParamStrings = function () {
      var ParsLine = "";
      var Pars = [];
      var I = 0;
      ParsLine = pas.System.Copy$1(window.location.hash,2);
      if (ParsLine !== "") {
        Pars = pas.SysUtils.TStringHelper.Split$1.call({get: function () {
            return ParsLine;
          }, set: function (v) {
            ParsLine = v;
          }},["/"])}
       else Pars = rtl.arraySetLength(Pars,"",0);
      $impl.Params = rtl.arraySetLength($impl.Params,"",1 + rtl.length(Pars));
      $impl.Params[0] = window.location.pathname;
      for (var $l = 0, $end = rtl.length(Pars) - 1; $l <= $end; $l++) {
        I = $l;
        $impl.Params[1 + I] = Pars[I];
      };
    };
    $impl.GetParamCount = function () {
      var Result = 0;
      Result = rtl.length($impl.Params) - 1;
      return Result;
    };
    $impl.GetParamStr = function (Index) {
      var Result = "";
      if ((Index >= 0) && (Index < rtl.length($impl.Params))) Result = $impl.Params[Index];
      return Result;
    };
    $impl.MyGetEnvironmentVariable = function (EnvVar) {
      var Result = "";
      var aName = "";
      aName = pas.SysUtils.LowerCase(EnvVar);
      if ($impl.EnvNames.hasOwnProperty(aName)) {
        Result = "" + $impl.EnvNames[aName]}
       else Result = "";
      return Result;
    };
    $impl.MyGetEnvironmentVariableCount = function () {
      var Result = 0;
      Result = rtl.length(Object.getOwnPropertyNames($impl.EnvNames));
      return Result;
    };
    $impl.MyGetEnvironmentString = function (Index) {
      var Result = "";
      Result = "" + $impl.EnvNames[Object.getOwnPropertyNames($impl.EnvNames)[Index]];
      return Result;
    };
    $impl.DoFindGlobalComponent = function (aName) {
      var Result = null;
      if ($impl.AppInstance != null) {
        Result = $impl.AppInstance.FindComponent(aName)}
       else Result = null;
      return Result;
    };
  };
  $mod.$init = function () {
    pas.System.IsConsole = true;
    pas.System.OnParamCount = $impl.GetParamCount;
    pas.System.OnParamStr = $impl.GetParamStr;
    $mod.ReloadEnvironmentStrings();
    $impl.ReloadParamStrings();
    pas.SysUtils.OnGetEnvironmentVariable = $impl.MyGetEnvironmentVariable;
    pas.SysUtils.OnGetEnvironmentVariableCount = $impl.MyGetEnvironmentVariableCount;
    pas.SysUtils.OnGetEnvironmentString = $impl.MyGetEnvironmentString;
  };
},[]);
rtl.module("wasihostapp",["System","Classes","SysUtils","BrowserApp","webassembly","wasienv"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBrowserWASIHostApplication",pas.BrowserApp.TBrowserApplication,function () {
    this.$init = function () {
      pas.BrowserApp.TBrowserApplication.$init.call(this);
      this.FHost = null;
    };
    this.$final = function () {
      this.FHost = undefined;
      pas.BrowserApp.TBrowserApplication.$final.call(this);
    };
    this.GetEnv = function () {
      var Result = null;
      Result = this.FHost.FEnv;
      return Result;
    };
    this.SetRunEntryFunction = function (AValue) {
      this.FHost.FRunEntryFunction = AValue;
    };
    this.CreateHost = function () {
      var Result = null;
      Result = pas.wasienv.TWASIHost.$create("Create$1",[this]);
      return Result;
    };
    this.Create$1 = function (aOwner) {
      pas.BrowserApp.TBrowserApplication.Create$1.call(this,aOwner);
      this.FHost = this.CreateHost();
      return this;
    };
    this.Destroy = function () {
      pas.SysUtils.FreeAndNil({p: this, get: function () {
          return this.p.FHost;
        }, set: function (v) {
          this.p.FHost = v;
        }});
      pas.BrowserApp.TBrowserApplication.Destroy.call(this);
    };
    this.StartWebAssembly = function (aPath, DoRun, aBeforeStart, aAfterStart) {
      this.FHost.StartWebAssembly(aPath,DoRun,aBeforeStart,aAfterStart);
    };
  });
});
rtl.module("JOB_Shared",["System"],function () {
  "use strict";
  var $mod = this;
  this.JOBResult_None = 0;
  this.JOBResult_Success = 1;
  this.JOBResult_UnknownObjId = 2;
  this.JOBResult_NotAFunction = 3;
  this.JOBResult_WrongArgs = 4;
  this.JOBResult_Undefined = 5;
  this.JOBResult_Null = 6;
  this.JOBResult_Boolean = 7;
  this.JOBResult_Double = 8;
  this.JOBResult_String = 9;
  this.JOBResult_Function = 10;
  this.JOBResult_Object = 11;
  this.JOBResult_BigInt = 12;
  this.JOBResult_Symbol = 13;
  this.JOBExportName = "job";
  this.JOBFn_GetGlobal = "get_registered";
  this.JOBFn_InvokeNoResult = "invoke_noresult";
  this.JOBFn_InvokeBooleanResult = "invoke_boolresult";
  this.JOBFn_InvokeDoubleResult = "invoke_doubleresult";
  this.JOBFn_InvokeStringResult = "invoke_stringresult";
  this.JOBFn_GetStringResult = "get_stringresult";
  this.JOBFn_InvokeArrayStringResult = "invoke_arraystringresult";
  this.JOBFn_ReleaseStringResult = "release_stringresult";
  this.JOBFn_InvokeObjectResult = "invoke_objectresult";
  this.JOBFn_ReleaseObject = "release_object";
  this.JOBFn_InvokeJSValueResult = "invoke_jsvalueresult";
  this.JOBFn_CallbackHandler = "JOBCallback";
  this.JOBArgUndefined = 0;
  this.JOBArgLongint = 1;
  this.JOBArgDouble = 2;
  this.JOBArgTrue = 3;
  this.JOBArgFalse = 4;
  this.JOBArgChar = 5;
  this.JOBArgString = 6;
  this.JOBArgUnicodeString = 7;
  this.JOBArgNil = 8;
  this.JOBArgPointer = 9;
  this.JOBArgObject = 10;
  this.JOBArgMethod = 11;
  this.JOBArgDictionary = 12;
  this.JOBArgArrayOfJSValue = 13;
  this.JOBArgArrayOfDouble = 14;
  this.JOBInvokeCall = 0;
  this.JOBInvokeGet = 1;
  this.JOBInvokeGetTypeOf = 2;
  this.JOBInvokeSet = 3;
  this.JOBInvokeNew = 4;
});
rtl.module("JOB_Browser",["System","SysUtils","Types","JS","Web","wasienv","JOB_Shared"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"EJOBBridge",pas.SysUtils.Exception,function () {
  });
  rtl.createClass(this,"TJSObjectBridge",pas.wasienv.TImportExtension,function () {
    this.$init = function () {
      pas.wasienv.TImportExtension.$init.call(this);
      this.FCallbackHandler = null;
      this.FGlobalObjects = null;
      this.FGlobalNames = null;
      this.FLocalObjects = null;
      this.FFreeLocalIds = null;
      this.FStringResult = "";
      this.FWasiExports = null;
    };
    this.$final = function () {
      this.FCallbackHandler = undefined;
      this.FGlobalObjects = undefined;
      this.FGlobalNames = undefined;
      this.FLocalObjects = undefined;
      this.FFreeLocalIds = undefined;
      this.FWasiExports = undefined;
      pas.wasienv.TImportExtension.$final.call(this);
    };
    this.SetWasiExports = function (AValue) {
      if (this.FWasiExports === AValue) return;
      this.FWasiExports = AValue;
      if (this.FWasiExports !== null) {
        this.FCallbackHandler = this.FWasiExports[pas.JOB_Shared.JOBFn_CallbackHandler]}
       else this.FCallbackHandler = null;
    };
    this.Invoke_JSResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, JSResult) {
      var Result = 0;
      var View = null;
      var aBytes = null;
      var PropName = "";
      var Args = [];
      var Obj = null;
      var fn = undefined;
      pas.System.Writeln("TJSObjectBridge.Invoke_JSResult ObjId=",ObjId," FuncNameP=",NameP," FuncNameLen=",NameLen," ArgsP=",ArgsP," Invoke=",Invoke);
      Obj = this.FindObject(ObjId);
      if (Obj === null) return 2;
      View = this.getModuleMemoryDataView();
      aBytes = new Uint8Array(View.buffer,NameP,NameLen);
      PropName = $impl.TypedArrayToString(aBytes);
      pas.System.Writeln('TJSObjectBridge.Invoke_JSResult PropName="',PropName,'"');
      var $tmp = Invoke;
      if ($tmp === 0) {
        fn = Obj[PropName];
        if (typeof(fn) !== "function") return 3;
        if (ArgsP === 0) {
          JSResult.set(fn.call(Obj))}
         else {
          Args = this.GetInvokeArguments(View,ArgsP);
          JSResult.set(fn.apply(Obj,Args));
        };
      } else if ($tmp === 4) {
        if (PropName !== "") {
          fn = Obj[PropName]}
         else fn = Obj;
        if (typeof(fn) !== "function") return 3;
        if (ArgsP === 0) {
          JSResult.set($impl.NewObj(fn,[]))}
         else {
          Args = this.GetInvokeArguments(View,ArgsP);
          JSResult.set($impl.NewObj(fn,Args));
        };
      } else if (($tmp === 1) || ($tmp === 2)) {
        if (ArgsP > 0) return 4;
        JSResult.set(Obj[PropName]);
        if (Invoke === 2) {
          Result = this.GetJOBResult(typeof(JSResult.get()));
          return Result;
        };
      } else if ($tmp === 3) {
        JSResult.set(undefined);
        if (ArgsP === 0) return 4;
        Args = this.GetInvokeArguments(View,ArgsP);
        if (rtl.length(Args) !== 1) return 4;
        Obj[PropName] = Args[0];
      } else {
        return 3;
      };
      Result = 1;
      return Result;
    };
    this.GetInvokeArguments = function (View, ArgsP) {
      var $Self = this;
      var Result = [];
      var p = 0;
      function ReadWasmNativeInt() {
        var Result = 0;
        Result = View.getInt32(p,$Self.FEnv.FIsLittleEndian);
        p += 4;
        return Result;
      };
      function ReadArgMethod() {
        var Result = null;
        var aCall = 0;
        var aData = 0;
        var aCode = 0;
        var i = 0;
        aCall = ReadWasmNativeInt();
        aData = ReadWasmNativeInt();
        aCode = ReadWasmNativeInt();
        Result = function () {
          var Result = undefined;
          var Args = 0;
          var ResultP = 0;
          var TempObjIds = [];
          Args = $Self.CreateCallbackArgs(View,arguments,rtl.arrayRef(TempObjIds));
          try {
            ResultP = $Self.FCallbackHandler(aCall,aData,aCode,Args);
            View = $Self.getModuleMemoryDataView();
            Result = $Self.EatCallbackResult(View,ResultP);
          } finally {
            for (var $l = 0, $end = rtl.length(TempObjIds) - 1; $l <= $end; $l++) {
              i = $l;
              $Self.ReleaseObject(TempObjIds[i]);
            };
          };
          return Result;
        };
        return Result;
      };
      function ReadString() {
        var Result = "";
        var Len = 0;
        var aWords = null;
        Len = ReadWasmNativeInt();
        aWords = new Uint16Array(View.buffer,p,Len);
        p += Len * 2;
        Result = $impl.TypedArrayToString(aWords);
        return Result;
      };
      function ReadUnicodeString() {
        var Result = "";
        var Len = 0;
        var Ptr = 0;
        var aWords = null;
        Len = ReadWasmNativeInt();
        Ptr = ReadWasmNativeInt();
        aWords = new Uint16Array(View.buffer,Ptr,Len);
        Result = $impl.TypedArrayToString(aWords);
        return Result;
      };
      function ReadArgDictionary() {
        var Result = undefined;
        var Cnt = 0;
        var CurName = "";
        var i = 0;
        var aType = 0;
        Cnt = ReadWasmNativeInt();
        Result = new Object();
        for (var $l = 0, $end = Cnt - 1; $l <= $end; $l++) {
          i = $l;
          aType = View.getUint8(p);
          p += 1;
          if (aType !== 7) throw $mod.EJOBBridge.$create("Create$1",["20220825000909: dictionary name must be unicodestring, but was " + pas.SysUtils.IntToStr(aType)]);
          CurName = ReadUnicodeString();
          Result[CurName] = ReadValue();
        };
        return Result;
      };
      function ReadArgArrayOfJSValue() {
        var Result = undefined;
        var Cnt = 0;
        var i = 0;
        Cnt = ReadWasmNativeInt();
        Result = new Array();
        for (var $l = 0, $end = Cnt - 1; $l <= $end; $l++) {
          i = $l;
          Result[i] = ReadValue();
        };
        return Result;
      };
      function ReadArgArrayOfDouble() {
        var Result = undefined;
        var Cnt = 0;
        var El = 0;
        var i = 0;
        Cnt = ReadWasmNativeInt();
        El = ReadWasmNativeInt();
        Result = new Array();
        for (var $l = 0, $end = Cnt - 1; $l <= $end; $l++) {
          i = $l;
          Result[i] = View.getFloat64(El + (i * 8),$Self.FEnv.FIsLittleEndian);
        };
        return Result;
      };
      function ReadValue() {
        var Result = undefined;
        var aType = 0;
        var ObjID = 0;
        var Obj = null;
        aType = View.getUint8(p);
        p += 1;
        var $tmp = aType;
        if ($tmp === 0) {
          Result = undefined}
         else if ($tmp === 1) {
          Result = View.getInt32(p,$Self.FEnv.FIsLittleEndian);
          p += 4;
        } else if ($tmp === 2) {
          Result = View.getFloat64(p,$Self.FEnv.FIsLittleEndian);
          p += 8;
        } else if ($tmp === 3) {
          Result = true}
         else if ($tmp === 4) {
          Result = false}
         else if ($tmp === 5) {
          Result = String.fromCharCode(View.getUint16(p,$Self.FEnv.FIsLittleEndian));
          p += 2;
        } else if ($tmp === 6) {
          Result = ReadString()}
         else if ($tmp === 7) {
          Result = ReadUnicodeString()}
         else if ($tmp === 8) {
          Result = null}
         else if ($tmp === 9) {
          Result = ReadWasmNativeInt()}
         else if ($tmp === 10) {
          ObjID = ReadWasmNativeInt();
          Obj = $Self.FindObject(ObjID);
          if (Obj === null) throw $mod.EJOBBridge.$create("Create$1",["20220825000904: invalid JSObject " + pas.SysUtils.IntToStr(ObjID)]);
          Result = Obj;
        } else if ($tmp === 11) {
          Result = ReadArgMethod()}
         else if ($tmp === 12) {
          Result = ReadArgDictionary()}
         else if ($tmp === 13) {
          Result = ReadArgArrayOfJSValue()}
         else if ($tmp === 14) {
          Result = ReadArgArrayOfDouble()}
         else {
          throw $mod.EJOBBridge.$create("Create$1",["20220825000852: unknown arg type " + pas.SysUtils.IntToStr(aType)]);
        };
        return Result;
      };
      var Cnt = 0;
      var i = 0;
      p = ArgsP;
      Cnt = View.getUint8(p);
      p += 1;
      for (var $l = 0, $end = Cnt - 1; $l <= $end; $l++) {
        i = $l;
        Result[i] = ReadValue();
      };
      return Result;
    };
    this.CreateCallbackArgs = function (View, Args, TempObjIds) {
      var Result = 0;
      var i = 0;
      var Len = 0;
      var j = 0;
      var Arg = undefined;
      var r = 0;
      var s = "";
      var NewId = 0;
      var p = 0;
      Result = 0;
      if (Args.length === 0) return Result;
      if (Args.length > 255) throw $mod.EJOBBridge.$create("Create$1",["too many arguments"]);
      Len = 1;
      for (var $l = 0, $end = Args.length - 1; $l <= $end; $l++) {
        i = $l;
        Arg = Args[i];
        r = this.GetJOBResult(Arg);
        Len += 1;
        var $tmp = r;
        if ($tmp === 7) {}
        else if ($tmp === 8) {
          Len += 8}
         else if ($tmp === 9) {
          Len += 4 + (2 * Arg.length)}
         else if (($tmp === 10) || ($tmp === 11)) Len += 4;
      };
      Result = this.FWasiExports.wasiAlloc(Len);
      p = Result;
      View.setUint8(p,Args.length);
      p += 1;
      for (var $l1 = 0, $end1 = Args.length - 1; $l1 <= $end1; $l1++) {
        i = $l1;
        Arg = Args[i];
        r = this.GetJOBResult(Arg);
        pas.System.Writeln("TJSObjectBridge.CreateCallbackArgs ",i,"/",Args.length," r=",r);
        var $tmp1 = r;
        if ($tmp1 === 6) {
          View.setUint8(p,8);
          p += 1;
        } else if ($tmp1 === 7) {
          if (Arg) {
            View.setUint8(p,3)}
           else View.setUint8(p,4);
          p += 1;
        } else if ($tmp1 === 8) {
          View.setUint8(p,2);
          p += 1;
          View.setFloat64(p,rtl.getNumber(Arg),this.FEnv.FIsLittleEndian);
          p += 8;
        } else if ($tmp1 === 9) {
          View.setUint8(p,7);
          p += 1;
          s = "" + Arg;
          View.setUint32(p,s.length,this.FEnv.FIsLittleEndian);
          p += 4;
          for (var $l2 = 0, $end2 = s.length - 1; $l2 <= $end2; $l2++) {
            j = $l2;
            View.setUint16(p,s.charCodeAt((j + 1) - 1),this.FEnv.FIsLittleEndian);
            p += 2;
          };
        } else if (($tmp1 === 10) || ($tmp1 === 11)) {
          View.setUint8(p,10);
          p += 1;
          NewId = this.RegisterLocalObject(Arg);
          TempObjIds.push(NewId);
          pas.System.Writeln("TJSObjectBridge.CreateCallbackArgs Object ID=",NewId);
          View.setInt32(p,NewId,this.FEnv.FIsLittleEndian);
          p += 4;
        } else {
          View.setUint8(p,0);
          p += 1;
        };
      };
      return Result;
    };
    this.EatCallbackResult = function (View, ResultP) {
      var $Self = this;
      var Result = undefined;
      var p = 0;
      function EatString() {
        var Result = undefined;
        var Len = 0;
        var i = 0;
        var a = [];
        Len = View.getUint32(p,$Self.FEnv.FIsLittleEndian);
        p += 4;
        a = rtl.arraySetLength(a,0,Len);
        for (var $l = 0, $end = Len - 1; $l <= $end; $l++) {
          i = $l;
          a[i] = View.getUint16(p,$Self.FEnv.FIsLittleEndian);
          p += 2;
        };
        Result = String.fromCharCode.apply(null,a);
        return Result;
      };
      var aType = 0;
      var ObjId = 0;
      if (ResultP === 0) return undefined;
      p = ResultP;
      try {
        aType = View.getUint8(p);
        p += 1;
        var $tmp = aType;
        if ($tmp === 3) {
          Result = true}
         else if ($tmp === 4) {
          Result = false}
         else if ($tmp === 1) {
          Result = View.getInt32(p,this.FEnv.FIsLittleEndian)}
         else if ($tmp === 2) {
          Result = View.getFloat64(p,this.FEnv.FIsLittleEndian)}
         else if ($tmp === 7) {
          Result = EatString()}
         else if ($tmp === 8) {
          Result = null}
         else if ($tmp === 10) {
          ObjId = View.getInt32(p,this.FEnv.FIsLittleEndian);
          Result = this.FindObject(ObjId);
          pas.System.Writeln("TJSObjectBridge.EatCallbackResult ObjID=",ObjId," Result=",Result != null);
        } else {
          Result = undefined;
        };
      } finally {
        this.FWasiExports.wasiFree(ResultP);
      };
      return Result;
    };
    this.Get_GlobalID = function (NameP, NameLen) {
      var Result = 0;
      var View = null;
      var aWords = null;
      var aName = "";
      View = this.getModuleMemoryDataView();
      aWords = new Uint16Array(View.buffer,NameP,NameLen);
      aName = $impl.TypedArrayToString(aWords);
      Result = this.FindGlobalObject(aName);
      return Result;
    };
    this.Invoke_NoResult = function (ObjId, NameP, NameLen, Invoke, ArgsP) {
      var Result = 0;
      var JSResult = undefined;
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      return Result;
    };
    this.Invoke_BooleanResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, ResultP) {
      var Result = 0;
      var JSResult = undefined;
      var b = 0;
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      if (Result !== 1) return Result;
      if (typeof(JSResult) !== "boolean") return this.GetJOBResult(JSResult);
      if (JSResult) {
        b = 1}
       else b = 0;
      this.getModuleMemoryDataView().setUint8(ResultP,b);
      Result = 7;
      return Result;
    };
    this.Invoke_DoubleResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, ResultP) {
      var Result = 0;
      var JSResult = undefined;
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      if (Result !== 1) return Result;
      if (typeof(JSResult) !== "number") return this.GetJOBResult(JSResult);
      this.getModuleMemoryDataView().setFloat64(ResultP,rtl.getNumber(JSResult),this.FEnv.FIsLittleEndian);
      Result = 8;
      return Result;
    };
    this.Invoke_StringResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, ResultP) {
      var Result = 0;
      var JSResult = undefined;
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      if (Result !== 1) return Result;
      if (typeof(JSResult) !== "string") return this.GetJOBResult(JSResult);
      Result = 9;
      this.FStringResult = "" + JSResult;
      this.getModuleMemoryDataView().setInt32(ResultP,this.FStringResult.length,this.FEnv.FIsLittleEndian);
      return Result;
    };
    this.Invoke_ObjectResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, ResultP) {
      var Result = 0;
      var t = "";
      var JSResult = undefined;
      var NewId = 0;
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      if (Result !== 1) return Result;
      t = typeof(JSResult);
      if ((t !== "object") && (t !== "function")) return this.GetJOBResult(JSResult);
      if (JSResult == null) return 6;
      NewId = this.RegisterLocalObject(JSResult);
      this.getModuleMemoryDataView().setUint32(ResultP,NewId >>> 0,this.FEnv.FIsLittleEndian);
      Result = 11;
      return Result;
    };
    this.Invoke_JSValueResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, ResultP) {
      var Result = 0;
      var JSResult = undefined;
      var b = 0;
      var NewId = 0;
      pas.System.Writeln("TJSObjectBridge.Invoke_JSValueResult START");
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      pas.System.Writeln("TJSObjectBridge.Invoke_JSValueResult JSResult=",JSResult);
      if (Result !== 1) return Result;
      Result = this.GetJOBResult(JSResult);
      pas.System.Writeln("TJSObjectBridge.Invoke_JSValueResult Type=",Result);
      var $tmp = Result;
      if ($tmp === 7) {
        if (JSResult) {
          b = 1}
         else b = 0;
        this.getModuleMemoryDataView().setUint8(ResultP,b);
      } else if ($tmp === 8) {
        this.getModuleMemoryDataView().setFloat64(ResultP,rtl.getNumber(JSResult),this.FEnv.FIsLittleEndian)}
       else if ($tmp === 9) {
        this.FStringResult = "" + JSResult;
        this.getModuleMemoryDataView().setInt32(ResultP,this.FStringResult.length,this.FEnv.FIsLittleEndian);
      } else if (($tmp === 10) || ($tmp === 11)) {
        NewId = this.RegisterLocalObject(JSResult);
        this.getModuleMemoryDataView().setUint32(ResultP,NewId >>> 0,this.FEnv.FIsLittleEndian);
      };
      return Result;
    };
    this.Invoke_ArrayStringResult = function (ObjId, NameP, NameLen, Invoke, ArgsP, ResultP) {
      var Result = 0;
      var JSResult = undefined;
      Result = this.Invoke_JSResult(ObjId,NameP,NameLen,Invoke,ArgsP,{get: function () {
          return JSResult;
        }, set: function (v) {
          JSResult = v;
        }});
      if (Result !== 1) return Result;
      throw $mod.EJOBBridge.$create("Create$1",["TJSObjectBridge.Invoke_ArrayStringResult not yet implemented"]);
      Result = 9;
      if (ResultP === 0) ;
      return Result;
    };
    this.ReleaseObject = function (ObjId) {
      var Result = 0;
      pas.System.Writeln("TJSObjectBridge.ReleaseObject ",ObjId);
      if (ObjId < 0) throw $mod.EJOBBridge.$create("Create$1",["cannot release a global object"]);
      if (ObjId >= this.FLocalObjects.length) throw $mod.EJOBBridge.$create("Create$1",["cannot release unknown object"]);
      if (this.FLocalObjects[ObjId] == null) throw $mod.EJOBBridge.$create("Create$1",["object already released"]);
      this.FLocalObjects[ObjId] = null;
      this.FFreeLocalIds.push(ObjId);
      Result = 1;
      return Result;
    };
    this.GetStringResult = function (ResultP) {
      var Result = 0;
      var View = null;
      var l = 0;
      var i = 0;
      Result = 1;
      l = this.FStringResult.length;
      if (l === 0) return Result;
      View = this.getModuleMemoryDataView();
      for (var $l = 0, $end = l - 1; $l <= $end; $l++) {
        i = $l;
        View.setUint16(ResultP + (2 * i),this.FStringResult.charCodeAt((i + 1) - 1),this.FEnv.FIsLittleEndian);
      };
      this.FStringResult = "";
      return Result;
    };
    this.ReleaseStringResult = function () {
      var Result = 0;
      Result = 1;
      this.FStringResult = "";
      return Result;
    };
    this.Create$1 = function (aEnv) {
      pas.wasienv.TImportExtension.Create$1.call(this,aEnv);
      this.FGlobalObjects = new Array();
      this.FGlobalObjects.push(null);
      this.FGlobalNames = new Object();
      this.RegisterGlobalObject(document,"document");
      this.RegisterGlobalObject(window,"window");
      this.RegisterGlobalObject(window.console,"console");
      this.RegisterGlobalObject(caches,"caches");
      this.RegisterGlobalObject(Object,"Object");
      this.RegisterGlobalObject(Function,"Function");
      this.RegisterGlobalObject(Date,"Date");
      this.RegisterGlobalObject(String,"String");
      this.RegisterGlobalObject(Array,"Array");
      this.RegisterGlobalObject(ArrayBuffer,"ArrayBuffer");
      this.RegisterGlobalObject(Int8Array,"Int8Array");
      this.RegisterGlobalObject(Uint8Array,"Uint8Array");
      this.RegisterGlobalObject(Uint8ClampedArray,"Uint8ClampedArray");
      this.RegisterGlobalObject(Int16Array,"Int16Array");
      this.RegisterGlobalObject(Uint16Array,"Uint16Array");
      this.RegisterGlobalObject(Uint32Array,"Uint32Array");
      this.RegisterGlobalObject(Float32Array,"Float32Array");
      this.RegisterGlobalObject(Float64Array,"Float64Array");
      this.RegisterGlobalObject(JSON,"JSON");
      this.RegisterGlobalObject(Promise,"Promise");
      this.FLocalObjects = new Array();
      this.FLocalObjects.push(null);
      this.FFreeLocalIds = new Array();
      return this;
    };
    this.FillImportObject = function (aObject) {
      aObject[pas.JOB_Shared.JOBFn_GetGlobal] = rtl.createCallback(this,"Get_GlobalID");
      aObject[pas.JOB_Shared.JOBFn_InvokeNoResult] = rtl.createCallback(this,"Invoke_NoResult");
      aObject[pas.JOB_Shared.JOBFn_InvokeBooleanResult] = rtl.createCallback(this,"Invoke_BooleanResult");
      aObject[pas.JOB_Shared.JOBFn_InvokeDoubleResult] = rtl.createCallback(this,"Invoke_DoubleResult");
      aObject[pas.JOB_Shared.JOBFn_InvokeStringResult] = rtl.createCallback(this,"Invoke_StringResult");
      aObject[pas.JOB_Shared.JOBFn_GetStringResult] = rtl.createCallback(this,"GetStringResult");
      aObject[pas.JOB_Shared.JOBFn_ReleaseStringResult] = rtl.createCallback(this,"ReleaseStringResult");
      aObject[pas.JOB_Shared.JOBFn_InvokeObjectResult] = rtl.createCallback(this,"Invoke_ObjectResult");
      aObject[pas.JOB_Shared.JOBFn_ReleaseObject] = rtl.createCallback(this,"ReleaseObject");
      aObject[pas.JOB_Shared.JOBFn_InvokeJSValueResult] = rtl.createCallback(this,"Invoke_JSValueResult");
      aObject[pas.JOB_Shared.JOBFn_InvokeArrayStringResult] = rtl.createCallback(this,"Invoke_ArrayStringResult");
    };
    this.ImportName = function () {
      var Result = "";
      Result = pas.JOB_Shared.JOBExportName;
      return Result;
    };
    this.FindObject = function (ObjId) {
      var Result = null;
      if (ObjId < 0) {
        Result = this.FGlobalObjects[-ObjId]}
       else Result = this.FLocalObjects[ObjId];
      if (pas.JS.isUndefined(Result)) Result = null;
      return Result;
    };
    this.FindGlobalObject = function (aName) {
      var Result = 0;
      if (!this.FGlobalNames.hasOwnProperty(aName)) return 0;
      Result = rtl.trunc(this.FGlobalNames[aName]);
      return Result;
    };
    this.RegisterLocalObject = function (Obj) {
      var Result = 0;
      var NewId = undefined;
      NewId = this.FFreeLocalIds.pop();
      if (pas.JS.isUndefined(NewId)) {
        NewId = this.FLocalObjects.push(Obj) - 1;
        Result = rtl.trunc(NewId);
      } else {
        Result = rtl.trunc(NewId);
        this.FLocalObjects[Result] = Obj;
      };
      pas.System.Writeln("TJSObjectBridge.RegisterLocalObject ",Result);
      return Result;
    };
    this.RegisterGlobalObject = function (Obj, aName) {
      var Result = 0;
      if (this.FGlobalNames.hasOwnProperty(aName)) throw $mod.EJOBBridge.$create("Create$1",['duplicate "' + aName + '"']);
      Result = -(this.FGlobalObjects.push(Obj) - 1);
      this.FGlobalNames[aName] = Result;
      return Result;
    };
    this.GetJOBResult = function (v) {
      var Result = 0;
      var $tmp = typeof(v);
      if ($tmp === "undefined") {
        Result = 5}
       else if ($tmp === "boolean") {
        Result = 7}
       else if ($tmp === "number") {
        Result = 8}
       else if ($tmp === "string") {
        Result = 9}
       else if ($tmp === "symbol") {
        Result = 13}
       else if ($tmp === "bigint") {
        Result = 12}
       else if ($tmp === "function") {
        Result = 10}
       else if ($tmp === "object") {
        if (v == null) {
          Result = 6}
         else Result = 11}
       else {
        Result = 0;
      };
      return Result;
    };
  });
  $mod.$implcode = function () {
    $impl.TypedArrayToString = function (a) {
      return String.fromCharCode.apply(null,a);
    };
    $impl.NewObj = function (fn, Args) {
      if (Args == null){
        return new fn();
      }
      var l = Args.length;
      if (l==0){
        return new fn();
      } else if (l==1){
        return new fn(Args[0]);
      } else if (l==2){
        return new fn(Args[0],Args[1]);
      } else if (l==3){
        return new fn(Args[0],Args[1],Args[2]);
      } else if (l==4){
        return new fn(Args[0],Args[1],Args[2],Args[3]);
      } else if (l==5){
        return new fn(Args[0],Args[1],Args[2],Args[3],Args[4]);
      } else if (l==6){
        return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5]);
      } else if (l==7){
        return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6]);
      } else if (l==8){
        return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6],Args[7]);
      } else if (l==9){
        return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6],Args[7],Args[8]);
      } else if (l==10){
        return new fn(Args[0],Args[1],Args[2],Args[3],Args[4],Args[5],Args[6],Args[7],Args[8],Args[9]);
      } else {
        return null;
      };
    };
  };
},[]);
rtl.module("program",["System","browserconsole","JS","Classes","SysUtils","Web","wasienv","wasihostapp","JOB_Browser"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TMyApplication",pas.wasihostapp.TBrowserWASIHostApplication,function () {
    this.$init = function () {
      pas.wasihostapp.TBrowserWASIHostApplication.$init.call(this);
      this.FWADomBridge = null;
    };
    this.$final = function () {
      this.FWADomBridge = undefined;
      pas.wasihostapp.TBrowserWASIHostApplication.$final.call(this);
    };
    this.OnBeforeStart = function (Sender, aDescriptor) {
      var Result = false;
      this.FWADomBridge.SetWasiExports(aDescriptor.Exported);
      Result = true;
      return Result;
    };
    this.Create$1 = function (aOwner) {
      pas.wasihostapp.TBrowserWASIHostApplication.Create$1.call(this,aOwner);
      this.FWADomBridge = pas.JOB_Browser.TJSObjectBridge.$create("Create$1",[this.GetEnv()]);
      this.SetRunEntryFunction("_initialize");
      return this;
    };
    this.DoRun = function () {
      this.StartWebAssembly("WasiButton1.wasm",true,rtl.createCallback(this,"OnBeforeStart"),null);
    };
  });
  this.Application = null;
  $mod.$main = function () {
    $mod.Application = $mod.TMyApplication.$create("Create$1",[null]);
    $mod.Application.Initialize();
    $mod.Application.Run();
  };
});
//# sourceMappingURL=BrowserButton1.js.map
