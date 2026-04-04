rtl.module("weborworker",["System","JS","Types"],function () {
  "use strict";
  var $mod = this;
  $mod.$rtti.$ExtClass("TJSCryptoKey");
  $mod.$rtti.$ExtClass("TJSSubtleCrypto");
  $mod.$rtti.$ExtClass("TJSEventTarget");
  $mod.$rtti.$ExtClass("TIDBDatabase");
  $mod.$rtti.$ExtClass("TJSIDBObjectStore");
  $mod.$rtti.$ExtClass("TJSIDBRequest");
  $mod.$rtti.$ExtClass("TJSServiceWorker");
  $mod.$rtti.$ExtClass("TJSReadableStream");
  $mod.$rtti.$ExtClass("TJSClient");
  $mod.$rtti.$ExtClass("TJSFileSystemHandle");
  $mod.$rtti.$ExtClass("TJSFileSystemFileHandle");
  $mod.$rtti.$ExtClass("TJSFileSystemDirectoryHandle");
  $mod.$rtti.$ExtClass("TJSFileSystemWritableFileStream");
  $mod.$rtti.$ExtClass("TJSFileSystemSyncAccessHandle");
  $mod.$rtti.$ExtClass("TJSNotification");
  $mod.$rtti.$ExtClass("TJSNotificationEvent");
  $mod.$rtti.$ExtClass("TJSNotificationOptions");
  $mod.$rtti.$Class("TJSNotificationAction");
  $mod.$rtti.$Class("TJSGetNotificationOptions");
  $mod.$rtti.$Class("TJSNotificationEventInit");
  $mod.$rtti.$ExtClass("TJSAbortSignal");
  $mod.$rtti.$ProcVar("NotificationPermissionCallback",{procsig: rtl.newTIProcSig([["permission",rtl.string]])});
  $mod.$rtti.$ExtClass("TJSHTMLOffscreenCanvas");
  $mod.$rtti.$ExtClass("TJSOffscreenCanvasRenderingContext2D");
  $mod.$rtti.$DynArray("TJSFileSystemFileHandleArray",{eltype: $mod.$rtti["TJSFileSystemFileHandle"]});
  $mod.$rtti.$DynArray("TJSFileSystemDirectoryHandleArray",{eltype: $mod.$rtti["TJSFileSystemDirectoryHandle"]});
  $mod.$rtti.$ExtClass("TJSConsole",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Console"});
  $mod.$rtti.$RefToProcVar("TJSTimerCallBack",{procsig: rtl.newTIProcSig(null,8)});
  rtl.recNewT($mod,"TJSEventInit",function () {
    this.bubbles = false;
    this.cancelable = false;
    this.scoped = false;
    this.composed = false;
    this.$eq = function (b) {
      return (this.bubbles === b.bubbles) && (this.cancelable === b.cancelable) && (this.scoped === b.scoped) && (this.composed === b.composed);
    };
    this.$assign = function (s) {
      this.bubbles = s.bubbles;
      this.cancelable = s.cancelable;
      this.scoped = s.scoped;
      this.composed = s.composed;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSEventInit",{});
    $r.addField("bubbles",rtl.boolean);
    $r.addField("cancelable",rtl.boolean);
    $r.addField("scoped",rtl.boolean);
    $r.addField("composed",rtl.boolean);
  });
  $mod.$rtti.$ExtClass("TJSEvent",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Event"});
  $mod.$rtti.$ExtClass("TJSExtendableEvent",{ancestor: $mod.$rtti["TJSEvent"], jsclass: "ExtendableEvent"});
  $mod.$rtti.$RefToProcVar("TJSEventHandler",{procsig: rtl.newTIProcSig([["Event",$mod.$rtti["TJSEvent"]]],rtl.boolean,8)});
  $mod.$rtti.$RefToProcVar("TJSRawEventHandler",{procsig: rtl.newTIProcSig([["Event",$mod.$rtti["TJSEvent"]]],8)});
  $mod.$rtti.$ExtClass("TJSEventListenerOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSEventTarget",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "EventTarget"});
  $mod.$rtti.$ExtClass("TJSMessagePort",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "MessagePort"});
  $mod.$rtti.$DynArray("TJSMessagePortDynArray",{eltype: $mod.$rtti["TJSMessagePort"]});
  $mod.$rtti.$ExtClass("TJSMessageEvent",{ancestor: $mod.$rtti["TJSEvent"], jsclass: "MessageEvent"});
  $mod.$rtti.$ExtClass("TJSExtendableMessageEvent",{ancestor: $mod.$rtti["TJSExtendableEvent"], jsclass: "ExtendableMessageEvent"});
  $mod.$rtti.$ExtClass("TJSClient",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Client"});
  $mod.$rtti.$ExtClass("TJSStructuredSerializeOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSReadableStreamDefaultReader",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "ReadableStreamDefaultReader"});
  $mod.$rtti.$ExtClass("TJSReadableStream",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "ReadableStream"});
  $mod.$rtti.$ExtClass("TJSWritableStream",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "WritableStream"});
  $mod.$rtti.$ExtClass("TJSBlobInit",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSBlob",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "Blob"});
  $mod.$rtti.$ExtClass("TJSFileNewOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSFile",{ancestor: $mod.$rtti["TJSBlob"], jsclass: "File"});
  $mod.$rtti.$ExtClass("TJSBody",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Body"});
  $mod.$rtti.$StaticArray("Theader",{dims: [2], eltype: rtl.string});
  $mod.$rtti.$DynArray("THeaderArray",{eltype: $mod.$rtti["Theader"]});
  $mod.$rtti.$ExtClass("TJSHTMLHeaders",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Headers"});
  $mod.$rtti.$ExtClass("TJSResponseInit",{jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSResponse",{ancestor: $mod.$rtti["TJSBody"], jsclass: "Response"});
  $mod.$rtti.$ExtClass("TJSFormData",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "FormData"});
  $mod.$rtti.$ExtClass("TJSRequest",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Request"});
  $mod.$rtti.$DynArray("TJSRequestDynArray",{eltype: $mod.$rtti["TJSRequest"]});
  $mod.$rtti.$ExtClass("TJSFetchEvent",{ancestor: $mod.$rtti["TJSExtendableEvent"], jsclass: "FetchEvent"});
  rtl.createClass($mod,"TJSIDBTransactionMode",pas.System.TObject,function () {
    this.readonly = "readonly";
    this.readwrite = "readwrite";
    this.versionchange = "versionchange";
  });
  $mod.$rtti.$ExtClass("TJSIDBTransaction",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "IDBTransaction"});
  $mod.$rtti.$ExtClass("TJSIDBKeyRange",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "IDBKeyRange"});
  rtl.recNewT($mod,"TJSIDBIndexParameters",function () {
    this.unique = false;
    this.multiEntry = false;
    this.locale = "";
    this.$eq = function (b) {
      return (this.unique === b.unique) && (this.multiEntry === b.multiEntry) && (this.locale === b.locale);
    };
    this.$assign = function (s) {
      this.unique = s.unique;
      this.multiEntry = s.multiEntry;
      this.locale = s.locale;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSIDBIndexParameters",{});
    $r.addField("unique",rtl.boolean);
    $r.addField("multiEntry",rtl.boolean);
    $r.addField("locale",rtl.string);
  });
  $mod.$rtti.$ExtClass("TJSIDBIndex",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "IDBIndex"});
  $mod.$rtti.$ExtClass("TJSIDBCursorDirection",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "IDBCursorDirection"});
  $mod.$rtti.$ExtClass("TJSIDBCursor",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "IDBCursor"});
  $mod.$rtti.$ExtClass("TJSIDBObjectStore",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "IDBObjectStore"});
  $mod.$rtti.$ExtClass("TJSIDBRequest",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "IDBRequest"});
  $mod.$rtti.$ExtClass("TJSIDBOpenDBRequest",{ancestor: $mod.$rtti["TJSIDBRequest"], jsclass: "IDBOpenDBRequest"});
  rtl.recNewT($mod,"TJSCreateObjectStoreOptions",function () {
    this.keyPath = undefined;
    this.autoIncrement = false;
    this.$eq = function (b) {
      return (this.keyPath === b.keyPath) && (this.autoIncrement === b.autoIncrement);
    };
    this.$assign = function (s) {
      this.keyPath = s.keyPath;
      this.autoIncrement = s.autoIncrement;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCreateObjectStoreOptions",{});
    $r.addField("keyPath",rtl.jsvalue);
    $r.addField("autoIncrement",rtl.boolean);
  });
  $mod.$rtti.$ExtClass("TIDBDatabase",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "IDBDatabase"});
  $mod.$rtti.$ExtClass("TJSIDBFactory",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "IDBFactory"});
  $mod.$rtti.$ExtClass("TJSCacheDeleteOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$RefToProcVar("TJSParamEnumCallBack",{procsig: rtl.newTIProcSig([["aKey",rtl.string,2],["aValue",rtl.string,2]])});
  $mod.$rtti.$ExtClass("TJSURLSearchParams",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "URLSearchParams"});
  $mod.$rtti.$ExtClass("TJSURL",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "URL"});
  $mod.$rtti.$DynArray("TJSURLDynArray",{eltype: $mod.$rtti["TJSURL"]});
  $mod.$rtti.$ExtClass("TJSNavigationPreloadState",{jsclass: "navigationPreloadState"});
  $mod.$rtti.$ExtClass("TJSCache",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Cache"});
  $mod.$rtti.$ExtClass("TJSCacheStorage",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "CacheStorage"});
  rtl.recNewT($mod,"TJSCryptoAlgorithm",function () {
    this.name = "";
    this.$eq = function (b) {
      return this.name === b.name;
    };
    this.$assign = function (s) {
      this.name = s.name;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoAlgorithm",{});
    $r.addField("name",rtl.string);
  });
  rtl.recNewT($mod,"TJSCryptoAesCbcParams",function () {
    this.iv = null;
    this.$eq = function (b) {
      return this.iv === b.iv;
    };
    this.$assign = function (s) {
      this.iv = s.iv;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoAesCbcParams",{});
    $r.addField("iv",pas.JS.$rtti["TJSBufferSource"]);
  });
  rtl.recNewT($mod,"TJSCryptoAesCtrParams",function () {
    this.counter = null;
    this.$eq = function (b) {
      return (this.counter === b.counter) && (this.length === b.length);
    };
    this.$assign = function (s) {
      this.counter = s.counter;
      this.length = s.length;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoAesCtrParams",{});
    $r.addField("counter",pas.JS.$rtti["TJSBufferSource"]);
    $r.addField("length",rtl.byte);
  });
  rtl.recNewT($mod,"TJSCryptoAesGcmParams",function () {
    this.iv = null;
    this.additionalData = null;
    this.tagLength = 0;
    this.$eq = function (b) {
      return (this.iv === b.iv) && (this.additionalData === b.additionalData) && (this.tagLength === b.tagLength);
    };
    this.$assign = function (s) {
      this.iv = s.iv;
      this.additionalData = s.additionalData;
      this.tagLength = s.tagLength;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoAesGcmParams",{});
    $r.addField("iv",pas.JS.$rtti["TJSBufferSource"]);
    $r.addField("additionalData",pas.JS.$rtti["TJSBufferSource"]);
    $r.addField("tagLength",rtl.byte);
  });
  rtl.recNewT($mod,"TJSCryptoHmacImportParams",function () {
    this.hash = undefined;
    this.$eq = function (b) {
      return this.hash === b.hash;
    };
    this.$assign = function (s) {
      this.hash = s.hash;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoHmacImportParams",{});
    $r.addField("hash",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoPbkdf2Params",function () {
    this.salt = null;
    this.iterations = 0;
    this.hash = undefined;
    this.$eq = function (b) {
      return (this.salt === b.salt) && (this.iterations === b.iterations) && (this.hash === b.hash);
    };
    this.$assign = function (s) {
      this.salt = s.salt;
      this.iterations = s.iterations;
      this.hash = s.hash;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoPbkdf2Params",{});
    $r.addField("salt",pas.JS.$rtti["TJSBufferSource"]);
    $r.addField("iterations",rtl.nativeint);
    $r.addField("hash",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoRsaHashedImportParams",function () {
    this.hash = undefined;
    this.$eq = function (b) {
      return this.hash === b.hash;
    };
    this.$assign = function (s) {
      this.hash = s.hash;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoRsaHashedImportParams",{});
    $r.addField("hash",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoAesKeyGenParams",function () {
    this.$eq = function (b) {
      return this.length === b.length;
    };
    this.$assign = function (s) {
      this.length = s.length;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoAesKeyGenParams",{});
    $r.addField("length",rtl.longint);
  });
  rtl.recNewT($mod,"TJSCryptoHmacKeyGenParams",function () {
    this.hash = undefined;
    this.$eq = function (b) {
      return (this.hash === b.hash) && (this.length === b.length);
    };
    this.$assign = function (s) {
      this.hash = s.hash;
      this.length = s.length;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoHmacKeyGenParams",{});
    $r.addField("hash",rtl.jsvalue);
    $r.addField("length",rtl.longint);
  });
  rtl.recNewT($mod,"TJSCryptoRsaHashedKeyGenParams",function () {
    this.modulusLength = 0;
    this.publicExponent = null;
    this.hash = undefined;
    this.$eq = function (b) {
      return (this.modulusLength === b.modulusLength) && (this.publicExponent === b.publicExponent) && (this.hash === b.hash);
    };
    this.$assign = function (s) {
      this.modulusLength = s.modulusLength;
      this.publicExponent = s.publicExponent;
      this.hash = s.hash;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoRsaHashedKeyGenParams",{});
    $r.addField("modulusLength",rtl.longint);
    $r.addField("publicExponent",pas.JS.$rtti["TJSUint8Array"]);
    $r.addField("hash",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoRsaOaepParams",function () {
    this.$eq = function (b) {
      return this.label === b.label;
    };
    this.$assign = function (s) {
      this.label = s.label;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoRsaOaepParams",{});
    $r.addField("label",pas.JS.$rtti["TJSBufferSource"]);
  });
  rtl.recNewT($mod,"TJSCryptoRsaPssParams",function () {
    this.saltLength = 0;
    this.$eq = function (b) {
      return this.saltLength === b.saltLength;
    };
    this.$assign = function (s) {
      this.saltLength = s.saltLength;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoRsaPssParams",{});
    $r.addField("saltLength",rtl.longint);
  });
  rtl.recNewT($mod,"TJSCryptoDhKeyGenParams",function () {
    this.prime = null;
    this.generator = null;
    this.$eq = function (b) {
      return (this.prime === b.prime) && (this.generator === b.generator);
    };
    this.$assign = function (s) {
      this.prime = s.prime;
      this.generator = s.generator;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoDhKeyGenParams",{});
    $r.addField("prime",pas.JS.$rtti["TJSUint8Array"]);
    $r.addField("generator",pas.JS.$rtti["TJSUint8Array"]);
  });
  rtl.recNewT($mod,"TJSCryptoEcKeyGenParams",function () {
    this.$eq = function (b) {
      return this.namedCurve === b.namedCurve;
    };
    this.$assign = function (s) {
      this.namedCurve = s.namedCurve;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoEcKeyGenParams",{});
    $r.addField("namedCurve",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoAesDerivedKeyParams",function () {
    this.$eq = function (b) {
      return this.length === b.length;
    };
    this.$assign = function (s) {
      this.length = s.length;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoAesDerivedKeyParams",{});
    $r.addField("length",rtl.longint);
  });
  rtl.recNewT($mod,"TJSCryptoHmacDerivedKeyParams",function () {
    this.$eq = function (b) {
      return this.length === b.length;
    };
    this.$assign = function (s) {
      this.length = s.length;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoHmacDerivedKeyParams",{});
    $r.addField("length",rtl.longint);
  });
  rtl.recNewT($mod,"TJSCryptoEcdhKeyDeriveParams",function () {
    this.$eq = function (b) {
      return this.public === b.public;
    };
    this.$assign = function (s) {
      this.public = s.public;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoEcdhKeyDeriveParams",{});
    $r.addField("public",$mod.$rtti["TJSCryptoKey"]);
  });
  rtl.recNewT($mod,"TJSCryptoDhKeyDeriveParams",function () {
    this.$eq = function (b) {
      return this.public === b.public;
    };
    this.$assign = function (s) {
      this.public = s.public;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoDhKeyDeriveParams",{});
    $r.addField("public",$mod.$rtti["TJSCryptoKey"]);
  });
  rtl.recNewT($mod,"TJSCryptoDhImportKeyParams",function () {
    this.prime = null;
    this.generator = null;
    this.$eq = function (b) {
      return (this.prime === b.prime) && (this.generator === b.generator);
    };
    this.$assign = function (s) {
      this.prime = s.prime;
      this.generator = s.generator;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoDhImportKeyParams",{});
    $r.addField("prime",pas.JS.$rtti["TJSUint8Array"]);
    $r.addField("generator",pas.JS.$rtti["TJSUint8Array"]);
  });
  rtl.recNewT($mod,"TJSCryptoEcdsaParams",function () {
    this.hash = undefined;
    this.$eq = function (b) {
      return this.hash === b.hash;
    };
    this.$assign = function (s) {
      this.hash = s.hash;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoEcdsaParams",{});
    $r.addField("hash",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoEcKeyImportParams",function () {
    this.$eq = function (b) {
      return this.namedCurve === b.namedCurve;
    };
    this.$assign = function (s) {
      this.namedCurve = s.namedCurve;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoEcKeyImportParams",{});
    $r.addField("namedCurve",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSCryptoHkdfParams",function () {
    this.hash = undefined;
    this.salt = null;
    this.info = null;
    this.$eq = function (b) {
      return (this.hash === b.hash) && (this.salt === b.salt) && (this.info === b.info);
    };
    this.$assign = function (s) {
      this.hash = s.hash;
      this.salt = s.salt;
      this.info = s.info;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoHkdfParams",{});
    $r.addField("hash",rtl.jsvalue);
    $r.addField("salt",pas.JS.$rtti["TJSBufferSource"]);
    $r.addField("info",pas.JS.$rtti["TJSBufferSource"]);
  });
  rtl.recNewT($mod,"TJSCryptoRsaOtherPrimesInfo",function () {
    this.r = "";
    this.d = "";
    this.t = "";
    this.$eq = function (b) {
      return (this.r === b.r) && (this.d === b.d) && (this.t === b.t);
    };
    this.$assign = function (s) {
      this.r = s.r;
      this.d = s.d;
      this.t = s.t;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoRsaOtherPrimesInfo",{});
    $r.addField("r",rtl.string);
    $r.addField("d",rtl.string);
    $r.addField("t",rtl.string);
  });
  $mod.$rtti.$DynArray("TJSCryptoRsaOtherPrimesInfoDynArray",{eltype: $mod.$rtti["TJSCryptoRsaOtherPrimesInfo"]});
  rtl.recNewT($mod,"TJSCryptoJsonWebKey",function () {
    this.kty = "";
    this.use = "";
    this.alg = "";
    this.ext = false;
    this.crv = "";
    this.x = "";
    this.y = "";
    this.d = "";
    this.n = "";
    this.e = "";
    this.p = "";
    this.q = "";
    this.dp = "";
    this.dq = "";
    this.qi = "";
    this.k = "";
    this.$new = function () {
      var r = Object.create(this);
      r.key_ops = [];
      r.oth = [];
      return r;
    };
    this.$eq = function (b) {
      return (this.kty === b.kty) && (this.use === b.use) && (this.key_ops === b.key_ops) && (this.alg === b.alg) && (this.ext === b.ext) && (this.crv === b.crv) && (this.x === b.x) && (this.y === b.y) && (this.d === b.d) && (this.n === b.n) && (this.e === b.e) && (this.p === b.p) && (this.q === b.q) && (this.dp === b.dp) && (this.dq === b.dq) && (this.qi === b.qi) && (this.oth === b.oth) && (this.k === b.k);
    };
    this.$assign = function (s) {
      this.kty = s.kty;
      this.use = s.use;
      this.key_ops = rtl.arrayRef(s.key_ops);
      this.alg = s.alg;
      this.ext = s.ext;
      this.crv = s.crv;
      this.x = s.x;
      this.y = s.y;
      this.d = s.d;
      this.n = s.n;
      this.e = s.e;
      this.p = s.p;
      this.q = s.q;
      this.dp = s.dp;
      this.dq = s.dq;
      this.qi = s.qi;
      this.oth = rtl.arrayRef(s.oth);
      this.k = s.k;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoJsonWebKey",{});
    $r.addField("kty",rtl.string);
    $r.addField("use",rtl.string);
    $r.addField("key_ops",pas.Types.$rtti["TStringDynArray"]);
    $r.addField("alg",rtl.string);
    $r.addField("ext",rtl.boolean);
    $r.addField("crv",rtl.string);
    $r.addField("x",rtl.string);
    $r.addField("y",rtl.string);
    $r.addField("d",rtl.string);
    $r.addField("n",rtl.string);
    $r.addField("e",rtl.string);
    $r.addField("p",rtl.string);
    $r.addField("q",rtl.string);
    $r.addField("dp",rtl.string);
    $r.addField("dq",rtl.string);
    $r.addField("qi",rtl.string);
    $r.addField("oth",$mod.$rtti["TJSCryptoRsaOtherPrimesInfoDynArray"]);
    $r.addField("k",rtl.string);
  });
  rtl.recNewT($mod,"TJSCryptoKeyPair",function () {
    this.publicKey = null;
    this.privateKey = null;
    this.$eq = function (b) {
      return (this.publicKey === b.publicKey) && (this.privateKey === b.privateKey);
    };
    this.$assign = function (s) {
      this.publicKey = s.publicKey;
      this.privateKey = s.privateKey;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSCryptoKeyPair",{});
    $r.addField("publicKey",$mod.$rtti["TJSCryptoKey"]);
    $r.addField("privateKey",$mod.$rtti["TJSCryptoKey"]);
  });
  $mod.$rtti.$DynArray("TJSCryptoKeyUsageDynArray",{eltype: rtl.string});
  $mod.$rtti.$ExtClass("TJSCryptoKey",{jsclass: "CryptoKey"});
  $mod.$rtti.$ExtClass("TJSSubtleCrypto",{jsclass: "SubtleCrypto"});
  $mod.$rtti.$ExtClass("TJSCrypto",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Crypto"});
  $mod.$rtti.$ExtClass("TJSEventSourceOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSEventSource",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "EventSource"});
  $mod.$rtti.$ExtClass("TJSNavigationPreload",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "navigationPreload"});
  $mod.$rtti.$ExtClass("TJSWorker",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "Worker"});
  $mod.$rtti.$ExtClass("TJSServiceWorkerRegistration",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "ServiceWorkerRegistration"});
  $mod.$rtti.$ExtClass("TJSServiceWorker",{ancestor: $mod.$rtti["TJSWorker"], jsclass: "ServiceWorker"});
  $mod.$rtti.$RefToProcVar("TOnChangeProcedure",{procsig: rtl.newTIProcSig(null)});
  $mod.$rtti.$ExtClass("TJSPermissionDescriptor",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSPermissionStatus",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "PermissionStatus"});
  $mod.$rtti.$ExtClass("TJSPermissions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Permissions"});
  $mod.$rtti.$ExtClass("TJSFileSystemHandlePermissionDescriptor",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  rtl.recNewT($mod,"TJSFileSystemCreateWritableOptions",function () {
    this.keepExistingData = false;
    this.$eq = function (b) {
      return this.keepExistingData === b.keepExistingData;
    };
    this.$assign = function (s) {
      this.keepExistingData = s.keepExistingData;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSFileSystemCreateWritableOptions",{});
    $r.addField("keepExistingData",rtl.boolean);
  });
  rtl.recNewT($mod,"TJSFileSystemGetFileOptions",function () {
    this.create = false;
    this.$eq = function (b) {
      return this.create === b.create;
    };
    this.$assign = function (s) {
      this.create = s.create;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSFileSystemGetFileOptions",{});
    $r.addField("create",rtl.boolean);
  });
  rtl.recNewT($mod,"TJSFileSystemGetDirectoryOptions",function () {
    this.create = false;
    this.$eq = function (b) {
      return this.create === b.create;
    };
    this.$assign = function (s) {
      this.create = s.create;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSFileSystemGetDirectoryOptions",{});
    $r.addField("create",rtl.boolean);
  });
  rtl.recNewT($mod,"TJSFileSystemRemoveOptions",function () {
    this.recursive = false;
    this.$eq = function (b) {
      return this.recursive === b.recursive;
    };
    this.$assign = function (s) {
      this.recursive = s.recursive;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSFileSystemRemoveOptions",{});
    $r.addField("recursive",rtl.boolean);
  });
  rtl.recNewT($mod,"TJSWriteParams",function () {
    this.size = 0;
    this.position = 0;
    this.data = undefined;
    this.$eq = function (b) {
      return (this.type === b.type) && (this.size === b.size) && (this.position === b.position) && (this.data === b.data);
    };
    this.$assign = function (s) {
      this.type = s.type;
      this.size = s.size;
      this.position = s.position;
      this.data = s.data;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSWriteParams",{});
    $r.addField("type",rtl.string);
    $r.addField("size",rtl.nativeint);
    $r.addField("position",rtl.nativeint);
    $r.addField("data",rtl.jsvalue);
  });
  rtl.recNewT($mod,"TJSFileSystemReadWriteOptions",function () {
    this.at = 0;
    this.$eq = function (b) {
      return this.at === b.at;
    };
    this.$assign = function (s) {
      this.at = s.at;
      return this;
    };
    var $r = $mod.$rtti.$Record("TJSFileSystemReadWriteOptions",{});
    $r.addField("at",rtl.nativeint);
  });
  $mod.$rtti.$ExtClass("TJSFileSystemHandle",{jsclass: "FileSystemHandle"});
  $mod.$rtti.$ExtClass("TJSFileSystemSyncAccessHandle",{jsclass: "FileSystemSyncAccessHandle"});
  $mod.$rtti.$ExtClass("TJSFileSystemFileHandle",{ancestor: $mod.$rtti["TJSFileSystemHandle"], jsclass: "FileSystemFileHandle"});
  $mod.$rtti.$ExtClass("TJSFileSystemDirectoryHandle",{ancestor: $mod.$rtti["TJSFileSystemHandle"], jsclass: "FileSystemDirectoryHandle"});
  $mod.$rtti.$ExtClass("TJSFileSystemWritableFileStream",{ancestor: $mod.$rtti["TJSWritableStream"], jsclass: "FileSystemWritableFileStream"});
  $mod.$rtti.$ExtClass("TJSStorageManager",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "StorageManager"});
  $mod.$rtti.$RefToProcVar("TJSMicrotaskProcedure",{procsig: rtl.newTIProcSig(null)});
  $mod.$rtti.$ExtClass("TJSImageBitmapOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSEventCountsMap",{ancestor: pas.JS.$rtti["TJSMap"], jsclass: "EventCounts"});
  $mod.$rtti.$ExtClass("TJSPerformanceEntry",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "PerformanceEntry"});
  $mod.$rtti.$DynArray("TJSPerformanceEntryArray",{eltype: $mod.$rtti["TJSPerformanceEntry"]});
  $mod.$rtti.$ExtClass("TJSPerformanceMarkOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSPerformanceMeasureOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSPerformance",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Performance"});
  $mod.$rtti.$ExtClass("TWindowOrWorkerGlobalScope",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSAbortSignal",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "AbortSignal"});
  $mod.$rtti.$ExtClass("TJSAbortController",{ancestor: $mod.$rtti["TJSAbortSignal"], jsclass: "AbortController"});
  $mod.$rtti.$DynArray("TTJSNotificationActionDynArray",{eltype: $mod.$rtti["TJSNotificationAction"]});
  $mod.$rtti.$ExtClass("TJSNotificationOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  rtl.createClassExt($mod,"TJSNotificationAction",Object,"",function () {
    this.$init = function () {
      this.action = "";
      this.title = "";
      this.icon = "";
    };
    this.$final = function () {
    };
  });
  rtl.createClassExt($mod,"TJSGetNotificationOptions",Object,"",function () {
    this.$init = function () {
      this.tag = "";
    };
    this.$final = function () {
    };
  });
  rtl.createClassExt($mod,"TJSNotificationEventInit",Object,"",function () {
    this.$init = function () {
      this.notification = null;
      this.action = "";
    };
    this.$final = function () {
      this.notification = undefined;
    };
  });
  $mod.$rtti.$DynArray("TNativeIntDynArray",{eltype: rtl.nativeint});
  $mod.$rtti.$ExtClass("TJSNotification",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "Notification"});
  $mod.$rtti.$ExtClass("TJSBroadcastChannel",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "BroadcastChannel"});
  $mod.$rtti.$ExtClass("TJSNotificationEvent",{ancestor: $mod.$rtti["TJSExtendableEvent"], jsclass: "NotificationEvent"});
  $mod.$rtti.$ExtClass("TJSImageData",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "ImageData"});
  $mod.$rtti.$ExtClass("TJSTextMetrics",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "TextMetrics"});
  $mod.$rtti.$ExtClass("TJSCanvasGradient",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "CanvasGradient"});
  $mod.$rtti.$ExtClass("TJSCanvasPattern",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "CanvasPattern"});
  $mod.$rtti.$ExtClass("TJSPath2D",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Path2D"});
  $mod.$rtti.$ExtClass("TJSBaseCanvasRenderingContext2D",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "CanvasRenderingContext2D"});
  $mod.$rtti.$ExtClass("TJSCanvasRenderingContext2D",{ancestor: $mod.$rtti["TJSBaseCanvasRenderingContext2D"], jsclass: "CanvasRenderingContext2D"});
  $mod.$rtti.$ExtClass("TJSImageBitmap",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "ImageBitmap"});
  $mod.$rtti.$ExtClass("TJSImageBitmapCanvasRenderingContext",{ancestor: $mod.$rtti["TJSBaseCanvasRenderingContext2D"], jsclass: "ImageBitmapRenderingContext"});
  $mod.$rtti.$ExtClass("TJSConvertToBlobOptions",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSHTMLOffscreenCanvas",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "OffscreenCanvas"});
  $mod.$rtti.$ExtClass("TJSOffscreenCanvasRenderingContext2D",{ancestor: $mod.$rtti["TJSBaseCanvasRenderingContext2D"], jsclass: "CanvasRenderingContext2D"});
  $mod.$rtti.$ExtClass("TJSMessageChannel",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "MessageChannel"});
  $mod.$rtti.$ExtClass("TDOMRectReadOnly",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "DOMRectReadOnly"});
  $mod.$rtti.$ExtClass("TJSWorklet",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "Worklet"});
  $mod.$rtti.$ExtClass("TJSAudioWorklet",{ancestor: $mod.$rtti["TJSWorklet"], jsclass: "AudioWorklet"});
  this.TJSScriptContext = {"0": "jscUnknown", jscUnknown: 0, "1": "jscMainBrowserThread", jscMainBrowserThread: 1, "2": "jscWebWorker", jscWebWorker: 2, "3": "jscServiceWorker", jscServiceWorker: 3};
  $mod.$rtti.$Enum("TJSScriptContext",{minvalue: 0, maxvalue: 3, ordtype: 1, enumtype: this.TJSScriptContext});
  $mod.$rtti.$ExtClass("TJSDOMException",{ancestor: pas.JS.$rtti["TJSObject"], jsclass: "DOMException"});
  $mod.$rtti.$ExtClass("TJSFileReader",{ancestor: $mod.$rtti["TJSEventTarget"], jsclass: "FileReader"});
  this.isMainBrowserThread = function () {
    return (typeof window !== "undefined");
  };
  this.isWebWorker = function () {
    return (typeof DedicatedWorkerGlobalScope !== 'undefined') &&
    (self instanceof DedicatedWorkerGlobalScope);
  };
  this.IsServiceWorker = function () {
    return (typeof ServiceWorkerGlobalScope !== 'undefined') && (self instanceof ServiceWorkerGlobalScope);
  };
  this.GetScriptContext = function () {
    var Result = 0;
    Result = $mod.TJSScriptContext.jscUnknown;
    if ($mod.isMainBrowserThread()) return $mod.TJSScriptContext.jscMainBrowserThread;
    if ($mod.isWebWorker()) return $mod.TJSScriptContext.jscWebWorker;
    if ($mod.IsServiceWorker()) return $mod.TJSScriptContext.jscServiceWorker;
    return Result;
  };
});
