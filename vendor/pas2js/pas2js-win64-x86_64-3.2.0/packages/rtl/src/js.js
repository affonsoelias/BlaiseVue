rtl.module("JS",["System","Types"],function () {
  "use strict";
  var $mod = this;
  $mod.$rtti.$ExtClass("TJSArray");
  $mod.$rtti.$ExtClass("TJSMap");
  $mod.$rtti.$ExtClass("TJSBigInt");
  rtl.createClass($mod,"EJS",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FMessage = "";
    };
    this.Create$1 = function (Msg) {
      this.FMessage = Msg;
      return this;
    };
  });
  $mod.$rtti.$ExtClass("TJSObject",{jsclass: "Object"});
  $mod.$rtti.$ClassRef("TJSObjectClass",{instancetype: $mod.$rtti["TJSObject"]});
  $mod.$rtti.$DynArray("TJSObjectDynArray",{eltype: $mod.$rtti["TJSObject"]});
  $mod.$rtti.$DynArray("TJSObjectDynArrayArray",{eltype: $mod.$rtti["TJSObjectDynArray"]});
  $mod.$rtti.$DynArray("TJSStringDynArray",{eltype: rtl.string});
  $mod.$rtti.$ExtClass("TJSIteratorValue",{jsclass: "IteratorValue"});
  $mod.$rtti.$ExtClass("TJSIterator",{jsclass: "Iterator"});
  $mod.$rtti.$ExtClass("TJSSet");
  $mod.$rtti.$RefToProcVar("TJSSetEventProc",{procsig: rtl.newTIProcSig([["value",rtl.jsvalue],["key",rtl.nativeint],["set_",$mod.$rtti["TJSSet"]]])});
  $mod.$rtti.$RefToProcVar("TJSSetProcCallBack",{procsig: rtl.newTIProcSig([["value",rtl.jsvalue],["key",rtl.jsvalue]])});
  $mod.$rtti.$ExtClass("TJSSet",{jsclass: "Set"});
  $mod.$rtti.$RefToProcVar("TJSMapFunctionCallBack",{procsig: rtl.newTIProcSig([["arg",rtl.jsvalue]],rtl.jsvalue)});
  $mod.$rtti.$RefToProcVar("TJSMapProcCallBack",{procsig: rtl.newTIProcSig([["value",rtl.jsvalue],["key",rtl.jsvalue]])});
  $mod.$rtti.$ExtClass("TJSMap",{jsclass: "Map"});
  $mod.$rtti.$ExtClass("TJSFunction",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Function"});
  $mod.$rtti.$ExtClass("TJSDate",{ancestor: $mod.$rtti["TJSFunction"], jsclass: "Date"});
  $mod.$rtti.$ExtClass("TJSSymbol",{ancestor: $mod.$rtti["TJSFunction"], jsclass: "Symbol"});
  rtl.recNewT($mod,"TLocaleCompareOptions",function () {
    this.localematched = "";
    this.usage = "";
    this.sensitivity = "";
    this.ignorePunctuation = false;
    this.numeric = false;
    this.caseFirst = "";
    this.$eq = function (b) {
      return (this.localematched === b.localematched) && (this.usage === b.usage) && (this.sensitivity === b.sensitivity) && (this.ignorePunctuation === b.ignorePunctuation) && (this.numeric === b.numeric) && (this.caseFirst === b.caseFirst);
    };
    this.$assign = function (s) {
      this.localematched = s.localematched;
      this.usage = s.usage;
      this.sensitivity = s.sensitivity;
      this.ignorePunctuation = s.ignorePunctuation;
      this.numeric = s.numeric;
      this.caseFirst = s.caseFirst;
      return this;
    };
    var $r = $mod.$rtti.$Record("TLocaleCompareOptions",{});
    $r.addField("localematched",rtl.string);
    $r.addField("usage",rtl.string);
    $r.addField("sensitivity",rtl.string);
    $r.addField("ignorePunctuation",rtl.boolean);
    $r.addField("numeric",rtl.boolean);
    $r.addField("caseFirst",rtl.string);
  });
  $mod.$rtti.$ExtClass("TJSRegexp",{jsclass: "RegExp"});
  $mod.$rtti.$RefToProcVar("TReplaceCallBack",{procsig: rtl.newTIProcSig([["match",rtl.string,2]],rtl.string,2)});
  $mod.$rtti.$RefToProcVar("TReplaceCallBack0",{procsig: rtl.newTIProcSig([["match",rtl.string,2],["offset",rtl.longint],["AString",rtl.string]],rtl.string)});
  $mod.$rtti.$RefToProcVar("TReplaceCallBack1",{procsig: rtl.newTIProcSig([["match",rtl.string,2],["p1",rtl.string,2],["offset",rtl.longint],["AString",rtl.string]],rtl.string)});
  $mod.$rtti.$RefToProcVar("TReplaceCallBack2",{procsig: rtl.newTIProcSig([["match",rtl.string,2],["p1",rtl.string,2],["p2",rtl.string,2],["offset",rtl.longint],["AString",rtl.string]],rtl.string)});
  $mod.$rtti.$ExtClass("TJSString",{jsclass: "String"});
  $mod.$rtti.$RefToProcVar("TJSArrayEventProc",{procsig: rtl.newTIProcSig([["element",rtl.jsvalue],["index",rtl.nativeint],["anArray",$mod.$rtti["TJSArray"]]])});
  $mod.$rtti.$RefToProcVar("TJSArrayEvent",{procsig: rtl.newTIProcSig([["element",rtl.jsvalue],["index",rtl.nativeint],["anArray",$mod.$rtti["TJSArray"]]],rtl.boolean)});
  $mod.$rtti.$RefToProcVar("TJSArrayMapEvent",{procsig: rtl.newTIProcSig([["element",rtl.jsvalue],["index",rtl.nativeint],["anArray",$mod.$rtti["TJSArray"]]],rtl.jsvalue)});
  $mod.$rtti.$RefToProcVar("TJSArrayReduceEvent",{procsig: rtl.newTIProcSig([["accumulator",rtl.jsvalue],["currentValue",rtl.jsvalue],["currentIndex",rtl.nativeint],["anArray",$mod.$rtti["TJSArray"]]],rtl.jsvalue)});
  $mod.$rtti.$RefToProcVar("TJSArrayCompareEvent",{procsig: rtl.newTIProcSig([["a",rtl.jsvalue],["b",rtl.jsvalue]],rtl.nativeint)});
  $mod.$rtti.$ExtClass("TJSArray",{jsclass: "Array"});
  $mod.$rtti.$ExtClass("TJSAbstractArrayBuffer",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSArrayBuffer",{ancestor: $mod.$rtti["TJSAbstractArrayBuffer"], jsclass: "ArrayBuffer"});
  $mod.$rtti.$ExtClass("TJSSharedArrayBuffer",{ancestor: $mod.$rtti["TJSAbstractArrayBuffer"], jsclass: "SharedArrayBuffer"});
  $mod.$rtti.$ExtClass("TJSBufferSource",{ancestor: $mod.$rtti["TJSObject"], jsclass: "BufferSource"});
  $mod.$rtti.$ExtClass("TJSTypedArray");
  $mod.$rtti.$RefToProcVar("TJSTypedArrayCallBack",{procsig: rtl.newTIProcSig([["element",rtl.jsvalue],["index",rtl.nativeint],["anArray",$mod.$rtti["TJSTypedArray"]]],rtl.boolean)});
  $mod.$rtti.$RefToProcVar("TJSTypedArrayMapCallBack",{procsig: rtl.newTIProcSig([["element",rtl.jsvalue],["index",rtl.nativeint],["anArray",$mod.$rtti["TJSTypedArray"]]],rtl.jsvalue)});
  $mod.$rtti.$RefToProcVar("TJSTypedArrayReduceCallBack",{procsig: rtl.newTIProcSig([["accumulator",rtl.jsvalue],["currentValue",rtl.jsvalue],["currentIndex",rtl.nativeint],["anArray",$mod.$rtti["TJSTypedArray"]]],rtl.jsvalue)});
  $mod.$rtti.$RefToProcVar("TJSTypedArrayCompareCallBack",{procsig: rtl.newTIProcSig([["a",rtl.jsvalue],["b",rtl.jsvalue]],rtl.nativeint)});
  $mod.$rtti.$ExtClass("TJSTypedArray",{ancestor: $mod.$rtti["TJSBufferSource"], jsclass: "TypedArray"});
  $mod.$rtti.$ClassRef("TJSTypedArrayClass",{instancetype: $mod.$rtti["TJSTypedArray"]});
  $mod.$rtti.$ExtClass("TJSInt8Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Int8Array"});
  $mod.$rtti.$ExtClass("TJSUint8Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Uint8Array"});
  $mod.$rtti.$ExtClass("TJSUint8ClampedArray",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Uint8ClampedArray"});
  $mod.$rtti.$ExtClass("TJSInt16Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Int16Array"});
  $mod.$rtti.$ExtClass("TJSUint16Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Uint16Array"});
  $mod.$rtti.$ExtClass("TJSInt32Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Int32Array"});
  $mod.$rtti.$ExtClass("TJSUint32Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Uint32Array"});
  $mod.$rtti.$ExtClass("TJSFloat32Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Float32Array"});
  $mod.$rtti.$ExtClass("TJSFloat64Array",{ancestor: $mod.$rtti["TJSTypedArray"], jsclass: "Float64Array"});
  $mod.$rtti.$ExtClass("TJSDataView",{ancestor: $mod.$rtti["TJSBufferSource"], jsclass: "DataView"});
  $mod.$rtti.$ExtClass("TJSJSON",{ancestor: $mod.$rtti["TJSObject"], jsclass: "JSON"});
  $mod.$rtti.$ExtClass("TJSError",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Error"});
  $mod.$rtti.$ExtClass("TJSPromise");
  $mod.$rtti.$ExtClass("TJSPromiseResolvers",{jsclass: "Object"});
  $mod.$rtti.$RefToProcVar("TJSPromiseResolver",{procsig: rtl.newTIProcSig([["aValue",rtl.jsvalue]],rtl.jsvalue)});
  $mod.$rtti.$RefToProcVar("TJSPromiseExecutor",{procsig: rtl.newTIProcSig([["resolve",$mod.$rtti["TJSPromiseResolver"]],["reject",$mod.$rtti["TJSPromiseResolver"]]])});
  $mod.$rtti.$RefToProcVar("TJSPromiseFinallyHandler",{procsig: rtl.newTIProcSig(null)});
  $mod.$rtti.$ExtClass("TJSPromise",{jsclass: "Promise"});
  $mod.$rtti.$ExtClass("TJSFunctionArguments",{jsclass: "arguments"});
  $mod.$rtti.$ExtClass("TJSIteratorResult",{ancestor: $mod.$rtti["TJSObject"], jsclass: "IteratorResult"});
  $mod.$rtti.$ExtClass("TJSAsyncIterator",{ancestor: $mod.$rtti["TJSObject"], jsclass: "AsyncIterator"});
  $mod.$rtti.$ExtClass("TJSSyntaxError",{ancestor: $mod.$rtti["TJSError"], jsclass: "SyntaxError"});
  $mod.$rtti.$ExtClass("TJSTextDecoderOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSTextDecodeOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSTextDecoder",{ancestor: $mod.$rtti["TJSObject"], jsclass: "TextDecoder"});
  $mod.$rtti.$ExtClass("TJSTextEncoderEncodeIntoResult",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSTextEncoder",{ancestor: $mod.$rtti["TJSObject"], jsclass: "TextEncoder"});
  $mod.$rtti.$ExtClass("TGGenerator$G1",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Generator"});
  $mod.$rtti.$ExtClass("TJSProxy",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Proxy"});
  $mod.$rtti.$ExtClass("TJSNumber",{ancestor: $mod.$rtti["TJSFunction"], jsclass: "Number"});
  $mod.$rtti.$ExtClass("TJSBigInt",{ancestor: $mod.$rtti["TJSObject"], jsclass: "BigInt"});
  rtl.createHelper($mod,"TJSBigIntHelper",null,function () {
    this.New = function (aValue) {
      var Result = null;
      Result = BigInt(aValue);
      return Result;
    };
  });
  $mod.$rtti.$ExtClass("TJSAtomicWaitResult",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSAtomics",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Atomics"});
  $mod.$rtti.$ExtClass("TJSLocalesOfOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSFormatRangePart",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$DynArray("TJSFormatRangePartArray",{eltype: $mod.$rtti["TJSFormatRangePart"]});
  $mod.$rtti.$ExtClass("TJSFormatDatePart",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$DynArray("TJSFormatDatePartArray",{eltype: $mod.$rtti["TJSFormatDatePart"]});
  $mod.$rtti.$ExtClass("TJSDateTimeResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSDateLocaleOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlDateTimeFormat",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.DateTimeFormat"});
  $mod.$rtti.$ExtClass("TJSDisplayNamesOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlDisplayNamesResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlDisplayNames",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.DisplayNames"});
  $mod.$rtti.$ExtClass("TJSDurationLocaleOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSFormatDurationPart",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$DynArray("TJSFormatDurationPartArray",{eltype: $mod.$rtti["TJSFormatDurationPart"]});
  $mod.$rtti.$ExtClass("TJSDurationResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSDuration",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlDurationFormat",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.DurationFormat"});
  $mod.$rtti.$ExtClass("TJSListFormatOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSListFormatResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSFormatListPart",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$DynArray("TJSFormatListPartArray",{eltype: $mod.$rtti["TJSFormatListPart"]});
  $mod.$rtti.$ExtClass("TJSIntlListFormat",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.ListFormat"});
  $mod.$rtti.$ExtClass("TJSIntlLocaleOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlTextInfo",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlWeekInfo",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlLocale",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.Locale"});
  $mod.$rtti.$ExtClass("TJSNumberFormatOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSNumberFormatResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlNumberPart",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$DynArray("TJSIntlNumberPartArray",{eltype: $mod.$rtti["TJSIntlNumberPart"]});
  $mod.$rtti.$ExtClass("TJSIntlNumberFormat",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.NumberFormat"});
  $mod.$rtti.$ExtClass("TJSIntlCollatorOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlCollatorResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlCollator",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.Collator"});
  $mod.$rtti.$ExtClass("TJSIntlPluralRuleOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlPluralRuleResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlPluralRules",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.PluralRules"});
  $mod.$rtti.$ExtClass("TJSRelativeTimeParts",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$DynArray("TJSRelativeTimePartsArray",{eltype: $mod.$rtti["TJSRelativeTimeParts"]});
  $mod.$rtti.$ExtClass("TJSIntlRelativeTimeFormatOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlRelativeTimeFormatResolvedOptions",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Object"});
  $mod.$rtti.$ExtClass("TJSIntlRelativeTimeFormat",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl.RelativeTimeFormat"});
  $mod.$rtti.$ExtClass("TJSIntl",{ancestor: $mod.$rtti["TJSObject"], jsclass: "Intl"});
  this.Symbol$1 = function () {
    return Symbol();
  };
  this.Symbol$2 = function (Description) {
    return Symbol(Description);
  };
  this.AsNumber = function (v) {
    return Number(v);
  };
  this.AsIntNumber = function (v) {
    return Number(v);
  };
  this.JSValueArrayOf = function (Args) {
    var Result = [];
    var I = 0;
    Result = rtl.arraySetLength(Result,undefined,rtl.length(Args));
    for (var $l = 0, $end = rtl.length(Args) - 1; $l <= $end; $l++) {
      I = $l;
      Result[I] = Args[I].VJSValue;
    };
    return Result;
  };
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
  this.JSDelete = function (Obj, PropName) {
    return delete Obj[PropName];
  };
  this.hasValue = function (v) {
    if(v){ return true; } else { return false; };
  };
  this.jsIn = function (keyName, object) {
    return keyName in object;
  };
  this.isBoolean = function (v) {
    return typeof(v) == 'boolean';
  };
  this.isDate = function (v) {
    return (v instanceof Date);
  };
  this.isCallback = function (v) {
    return rtl.isObject(v) && rtl.isObject(v.scope) && (rtl.isString(v.fn) || rtl.isFunction(v.fn));
  };
  this.isChar = function (v) {
    return (typeof(v)!="string") && (v.length==1);
  };
  this.isClass = function (v) {
    return (typeof(v)=="object") && (v!=null) && (v.$class == v);
  };
  this.isClassInstance = function (v) {
    return (typeof(v)=="object") && (v!=null) && (v.$class == Object.getPrototypeOf(v));
  };
  this.isInteger = function (v) {
    return Math.floor(v)===v;
  };
  this.isNull = function (v) {
    return v === null;
  };
  this.isRecord = function (v) {
    return (typeof(v)==="object")
    && (typeof(v.$new)==="function")
    && (typeof(v.$clone)==="function")
    && (typeof(v.$eq)==="function")
    && (typeof(v.$assign)==="function");
  };
  this.isBigint = function (v) {
    return typeof(v) === 'bigint';
  };
  this.isUndefined = function (v) {
    return v == undefined;
  };
  this.isDefined = function (v) {
    return !(v == undefined);
  };
  this.isUTF16Char = function (v) {
    if (typeof(v)!="string") return false;
    if ((v.length==0) || (v.length>2)) return false;
    var code = v.charCodeAt(0);
    if (code < 0xD800){
      if (v.length == 1) return true;
    } else if (code <= 0xDBFF){
      if (v.length==2){
        code = v.charCodeAt(1);
        if (code >= 0xDC00 && code <= 0xDFFF) return true;
      };
    };
    return false;
  };
  this.jsInstanceOf = function (aFunction, aFunctionWithPrototype) {
    return aFunction instanceof aFunctionWithPrototype;
  };
  this.toNumber = function (v) {
    return v-0;
  };
  this.toInteger = function (v) {
    var Result = 0;
    if ($mod.isInteger(v)) {
      Result = Math.floor(v)}
     else Result = 0;
    return Result;
  };
  this.toObject = function (Value) {
    var Result = null;
    if (rtl.isObject(Value)) {
      Result = rtl.getObject(Value)}
     else Result = null;
    return Result;
  };
  this.toArray = function (Value) {
    var Result = null;
    if (rtl.isArray(Value)) {
      Result = rtl.getObject(Value)}
     else Result = null;
    return Result;
  };
  this.toBoolean = function (Value) {
    var Result = false;
    if ($mod.isBoolean(Value)) {
      Result = !(Value == false)}
     else Result = false;
    return Result;
  };
  this.ToString = function (Value) {
    var Result = "";
    if (rtl.isString(Value)) {
      Result = "" + Value}
     else Result = "";
    return Result;
  };
  this.JSClassName = function (aObj) {
    var Result = "";
    Result = "";
    if (aObj === null) return Result;
    return aObj.constructor.name;
    return Result;
  };
  this.TJSValueType = {"0": "jvtNull", jvtNull: 0, "1": "jvtBoolean", jvtBoolean: 1, "2": "jvtInteger", jvtInteger: 2, "3": "jvtFloat", jvtFloat: 3, "4": "jvtString", jvtString: 4, "5": "jvtObject", jvtObject: 5, "6": "jvtArray", jvtArray: 6};
  $mod.$rtti.$Enum("TJSValueType",{minvalue: 0, maxvalue: 6, ordtype: 1, enumtype: this.TJSValueType});
  this.GetValueType = function (JS) {
    var Result = 0;
    var t = "";
    if ($mod.isNull(JS)) {
      Result = $mod.TJSValueType.jvtNull}
     else {
      t = typeof(JS);
      if (t === "string") {
        Result = $mod.TJSValueType.jvtString}
       else if (t === "boolean") {
        Result = $mod.TJSValueType.jvtBoolean}
       else if (t === "object") {
        if (rtl.isArray(JS)) {
          Result = $mod.TJSValueType.jvtArray}
         else Result = $mod.TJSValueType.jvtObject;
      } else if (t === "number") if ($mod.isInteger(JS)) {
        Result = $mod.TJSValueType.jvtInteger}
       else Result = $mod.TJSValueType.jvtFloat;
    };
    return Result;
  };
  this.HaveSharedArrayBuffer = function () {
    return (typeof SharedArrayBuffer !== 'undefined');
  };
  this.SharedToNonShared = function (aBuffer) {
    var Result = null;
    var Src = null;
    var Dest = null;
    if ($mod.HaveSharedArrayBuffer() && rtl.isExt(aBuffer,SharedArrayBuffer)) {
      Result = new ArrayBuffer(aBuffer.byteLength);
      Src = new Uint8Array(aBuffer);
      Dest = new Uint8Array(Result);
      Dest.set(Src);
    } else Result = aBuffer;
    return Result;
  };
  this.SharedToNonShared$1 = function (aArray, aWordSized) {
    var Result = null;
    var Buf = null;
    if ($mod.HaveSharedArrayBuffer() && rtl.isExt(aArray.buffer,SharedArrayBuffer)) {
      Buf = aArray.buffer.slice(aArray.byteOffset,aArray.byteOffset + aArray.byteLength);
      if (aWordSized) {
        Result = new Uint16Array($mod.SharedToNonShared(Buf))}
       else Result = new Uint8Array($mod.SharedToNonShared(Buf));
    } else Result = aArray;
    return Result;
  };
});
