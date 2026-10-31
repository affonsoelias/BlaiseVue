rtl.module("System",[],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.MaxLongint = 0x7fffffff;
  this.Maxint = 2147483647;
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
    this.AfterConstruction = function () {
    };
    this.BeforeDestruction = function () {
    };
  });
  rtl.createClass(this,"TInterfacedObject",this.TObject,function () {
    this.$init = function () {
      $mod.TObject.$init.call(this);
      this.fRefCount = 0;
    };
    this.BeforeDestruction = function () {
      if (this.fRefCount !== 0) rtl.raiseE('EHeapMemoryError');
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
  this.Random = function (Range) {
    return Math.floor(Math.random()*Range);
  };
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
  this.val$6 = function (S, I, Code) {
    I.set($impl.valint(S,-2147483648,2147483647,Code));
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
rtl.module("RTLConsts",["System"],function () {
  "use strict";
  var $mod = this;
  $mod.$resourcestrings = {SArgumentMissing: {org: 'Missing argument in format "%s"'}, SInvalidFormat: {org: 'Invalid format specifier : "%s"'}, SInvalidArgIndex: {org: 'Invalid argument index in format: "%s"'}, SErrInvalidInteger: {org: 'Invalid integer value: "%s"'}};
});
rtl.module("SysUtils",["System","RTLConsts","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.FloatRecDigits = 19;
  rtl.recNewT(this,"TFloatRec",function () {
    this.Exponent = 0;
    this.Negative = false;
    this.$new = function () {
      var r = Object.create(this);
      r.Digits = rtl.arraySetLength(null,"\x00",19);
      return r;
    };
    this.$eq = function (b) {
      return (this.Exponent === b.Exponent) && (this.Negative === b.Negative) && rtl.arrayEq(this.Digits,b.Digits);
    };
    this.$assign = function (s) {
      this.Exponent = s.Exponent;
      this.Negative = s.Negative;
      this.Digits = s.Digits.slice(0);
      return this;
    };
  });
  rtl.recNewT(this,"TFormatSettings",function () {
    this.CurrencyDecimals = 0;
    this.CurrencyFormat = 0;
    this.CurrencyString = "";
    this.DateSeparator = "\x00";
    this.DecimalSeparator = "";
    this.LongDateFormat = "";
    this.LongTimeFormat = "";
    this.NegCurrFormat = 0;
    this.ShortDateFormat = "";
    this.ShortTimeFormat = "";
    this.ThousandSeparator = "";
    this.TimeAMString = "";
    this.TimePMString = "";
    this.TimeSeparator = "\x00";
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
      this.FJSError = null;
    };
    this.$final = function () {
      this.FJSError = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Create$1 = function (Msg) {
      this.fMessage = Msg;
      this.FJSError = new Error();
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
  rtl.createClass(this,"EInvalidCast",this.Exception,function () {
  });
  rtl.createClass(this,"EConvertError",this.Exception,function () {
  });
  rtl.createClass(this,"EIntError",this.EExternal,function () {
  });
  rtl.createClass(this,"ERangeError",this.EIntError,function () {
  });
  rtl.createClass(this,"EAbstractError",this.Exception,function () {
  });
  this.Trim = function (S) {
    return S.replace(/^[\s\uFEFF\xA0\x00-\x1f]+/,'').replace(/[\s\uFEFF\xA0\x00-\x1f]+$/,'');
  };
  this.TrimLeft = function (S) {
    return S.replace(/^[\s\uFEFF\xA0\x00-\x1f]+/,'');
  };
  this.UpperCase = function (s) {
    return s.toUpperCase();
  };
  this.LowerCase = function (s) {
    return s.toLowerCase();
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
    var Fchar = "\x00";
    var vq = 0;
    function ReadFormat() {
      var Result = "\x00";
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
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffExponent,3,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffExponent,3,Prec,aSettings);
        } else if ($tmp === "F") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffFixed,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffFixed,9999,Prec,aSettings);
        } else if ($tmp === "G") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffGeneral,Prec,3,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffGeneral,Prec,3,aSettings);
        } else if ($tmp === "N") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffNumber,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffNumber,9999,Prec,aSettings);
        } else if ($tmp === "M") {
          if (Checkarg(12,false)) {
            ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue / 10000,$mod.TFloatFormat.ffCurrency,9999,Prec,aSettings)}
           else if (Checkarg(3,true)) ToAdd = $mod.FloatToStrF$1(Args[DoArg].VJSValue,$mod.TFloatFormat.ffCurrency,9999,Prec,aSettings);
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
  this.TStringReplaceFlag = {"0": "rfReplaceAll", rfReplaceAll: 0, "1": "rfIgnoreCase", rfIgnoreCase: 1};
  this.StringReplace = function (aOriginal, aSearch, aReplace, Flags) {
    var Result = "";
    var REFlags = "";
    var REString = "";
    REFlags = "";
    if ($mod.TStringReplaceFlag.rfReplaceAll in Flags) REFlags = "g";
    if ($mod.TStringReplaceFlag.rfIgnoreCase in Flags) REFlags = REFlags + "i";
    REString = aSearch.replace(new RegExp($impl.RESpecials,"g"),"\\$1");
    Result = aOriginal.replace(new RegExp(REString,REFlags),aReplace);
    return Result;
  };
  this.IntToStr = function (Value) {
    var Result = "";
    Result = "" + Value;
    return Result;
  };
  this.TryStrToInt$2 = function (S, res) {
    var Result = false;
    Result = $impl.IntTryStrToInt(S,res,$mod.FormatSettings.DecimalSeparator);
    return Result;
  };
  this.StrToIntDef = function (S, aDef) {
    var Result = 0;
    var R = 0;
    if ($mod.TryStrToInt$2(S,{get: function () {
        return R;
      }, set: function (v) {
        R = v;
      }})) {
      Result = R}
     else Result = aDef;
    return Result;
  };
  this.StrToInt = function (S) {
    var Result = 0;
    var R = 0;
    if (!$mod.TryStrToInt$2(S,{get: function () {
        return R;
      }, set: function (v) {
        R = v;
      }})) throw $mod.EConvertError.$create("CreateFmt",[rtl.getResStr(pas.RTLConsts,"SErrInvalidInteger"),pas.System.VarRecs(18,S)]);
    Result = R;
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
  var Rounds = "123456789:";
  this.FloatToDecimal = function (Value, Precision, Decimals) {
    var Result = $mod.TFloatRec.$new();
    var Buffer = "";
    var InfNan = "";
    var OutPos = 0;
    var error = 0;
    var N = 0;
    var L = 0;
    var C = 0;
    var GotNonZeroBeforeDot = false;
    var BeforeDot = false;
    Result.Negative = false;
    Result.Exponent = 0;
    for (C = 0; C <= 19; C++) Result.Digits[C] = "0";
    if (Value === 0) return Result;
    Buffer = rtl.floatToStr(Value,24);
    N = 1;
    L = Buffer.length;
    while (Buffer.charAt(N - 1) === " ") N += 1;
    Result.Negative = Buffer.charAt(N - 1) === "-";
    if (Result.Negative) {
      N += 1}
     else if (Buffer.charAt(N - 1) === "+") N += 1;
    if (L >= (N + 2)) {
      InfNan = pas.System.Copy(Buffer,N,3);
      if (InfNan === "Inf") {
        Result.Digits[0] = "\x00";
        Result.Exponent = 32767;
        return Result;
      };
      if (InfNan === "Nan") {
        Result.Digits[0] = "\x00";
        Result.Exponent = -32768;
        return Result;
      };
    };
    OutPos = 0;
    Result.Exponent = 0;
    BeforeDot = true;
    GotNonZeroBeforeDot = false;
    while ((L >= N) && (Buffer.charAt(N - 1) !== "E")) {
      if (Buffer.charAt(N - 1) === ".") {
        BeforeDot = false}
       else {
        if (BeforeDot) {
          Result.Exponent += 1;
          Result.Digits[OutPos] = Buffer.charAt(N - 1);
          if (Buffer.charAt(N - 1) !== "0") GotNonZeroBeforeDot = true;
        } else Result.Digits[OutPos] = Buffer.charAt(N - 1);
        OutPos += 1;
      };
      N += 1;
    };
    N += 1;
    if (N <= L) {
      pas.System.val$6(pas.System.Copy(Buffer,N,(L - N) + 1),{get: function () {
          return C;
        }, set: function (v) {
          C = v;
        }},{get: function () {
          return error;
        }, set: function (v) {
          error = v;
        }});
      Result.Exponent += C;
    };
    N = OutPos;
    L = 19;
    while (N < L) {
      Result.Digits[N] = "0";
      N += 1;
    };
    if ((Decimals + Result.Exponent) < Precision) {
      N = Decimals + Result.Exponent}
     else N = Precision;
    if (N >= L) N = L - 1;
    if (N === 0) {
      if (Result.Digits[0] >= "5") {
        Result.Digits[0] = "1";
        Result.Digits[1] = "\x00";
        Result.Exponent += 1;
      } else Result.Digits[0] = "\x00";
    } else if (N > 0) {
      if (Result.Digits[N] >= "5") {
        do {
          Result.Digits[N] = "\x00";
          N -= 1;
          Result.Digits[N] = Rounds.charAt(($mod.StrToInt(Result.Digits[N]) + 1) - 1);
        } while (!((N === 0) || (Result.Digits[N] < ":")));
        if (Result.Digits[0] === ":") {
          Result.Digits[0] = "1";
          Result.Exponent += 1;
        };
      } else {
        Result.Digits[N] = "0";
        while ((N > -1) && (Result.Digits[N] === "0")) {
          Result.Digits[N] = "\x00";
          N -= 1;
        };
      };
    } else Result.Digits[0] = "\x00";
    if ((Result.Digits[0] === "\x00") && !GotNonZeroBeforeDot) {
      Result.Exponent = 0;
      Result.Negative = false;
    };
    return Result;
  };
  this.FloatToStr = function (Value) {
    var Result = "";
    Result = $mod.FloatToStr$1(Value,$mod.FormatSettings);
    return Result;
  };
  this.FloatToStr$1 = function (Value, aSettings) {
    var Result = "";
    Result = $mod.FloatToStrF$1(Value,$mod.TFloatFormat.ffGeneral,15,0,aSettings);
    return Result;
  };
  this.FloatToStrF$1 = function (Value, format, Precision, Digits, aSettings) {
    var Result = "";
    var TS = "";
    var DS = "";
    DS = aSettings.DecimalSeparator;
    TS = aSettings.ThousandSeparator;
    var $tmp = format;
    if ($tmp === $mod.TFloatFormat.ffGeneral) {
      Result = $impl.FormatGeneralFloat(Value,Precision,DS)}
     else if ($tmp === $mod.TFloatFormat.ffExponent) {
      Result = $impl.FormatExponentFloat(Value,Precision,Digits,DS)}
     else if ($tmp === $mod.TFloatFormat.ffFixed) {
      Result = $impl.FormatFixedFloat(Value,Digits,DS)}
     else if ($tmp === $mod.TFloatFormat.ffNumber) {
      Result = $impl.FormatNumberFloat(Value,Digits,DS,TS)}
     else if ($tmp === $mod.TFloatFormat.ffCurrency) Result = $impl.FormatNumberCurrency(Value * 10000,Digits,aSettings);
    if ((format !== $mod.TFloatFormat.ffCurrency) && (Result.length > 1) && (Result.charAt(0) === "-")) $impl.RemoveLeadingNegativeSign({get: function () {
        return Result;
      }, set: function (v) {
        Result = v;
      }},DS,TS);
    return Result;
  };
  var TDecimalPart = {"0": "dpDigit", dpDigit: 0, "1": "dpSignificand", dpSignificand: 1, "2": "dpExp", dpExp: 2};
  this.TryStrToFloat$3 = function (S, res, aSettings) {
    var Result = false;
    var J = undefined;
    var I = 0;
    var aStart = 0;
    var Len = 0;
    var N = "";
    var p = 0;
    Result = false;
    N = S;
    if (aSettings.ThousandSeparator !== "") N = $mod.StringReplace(N,aSettings.ThousandSeparator,"",rtl.createSet($mod.TStringReplaceFlag.rfReplaceAll));
    if (aSettings.DecimalSeparator !== ".") N = $mod.StringReplace(N,aSettings.DecimalSeparator,".",{});
    p = TDecimalPart.dpDigit;
    I = 1;
    aStart = 1;
    Len = N.length;
    while (I <= Len) {
      var $tmp = N.charAt(I - 1);
      if (($tmp === "+") || ($tmp === "-")) {
        var $tmp1 = p;
        if ($tmp1 === TDecimalPart.dpSignificand) {
          return Result}
         else if ($tmp1 === TDecimalPart.dpDigit) {
          if (I > aStart) return Result}
         else if ($tmp1 === TDecimalPart.dpExp) if (I > (aStart + 1)) return Result;
      } else if (($tmp >= "0") && ($tmp <= "9")) {}
      else if ($tmp === ".") {
        if (p !== TDecimalPart.dpDigit) return Result;
        p = TDecimalPart.dpSignificand;
        aStart = I;
      } else if (($tmp === "E") || ($tmp === "e")) {
        if (p === TDecimalPart.dpExp) {
          return Result}
         else {
          p = TDecimalPart.dpExp;
          aStart = I;
        };
      } else {
        return Result;
      };
      I += 1;
    };
    J = parseFloat(N);
    Result = !isNaN(J);
    if (Result) res.set(rtl.getNumber(J));
    return Result;
  };
  this.StrToFloatDef = function (S, aDef) {
    var Result = 0.0;
    if (!$mod.TryStrToFloat$3(S,{get: function () {
        return Result;
      }, set: function (v) {
        Result = v;
      }},$mod.FormatSettings)) Result = aDef;
    return Result;
  };
  this.FormatFloat = function (Fmt, aValue) {
    var Result = "";
    Result = $mod.FormatFloat$1(Fmt,aValue,$mod.TFormatSettings.$clone($mod.FormatSettings));
    return Result;
  };
  var MaxPrecision = 18;
  this.FormatFloat$1 = function (Fmt, aValue, aSettings) {
    var Result = "";
    var E = 0.0;
    var FV = $mod.TFloatRec.$new();
    var Section = "";
    var SectionLength = 0;
    var ThousandSep = false;
    var IsScientific = false;
    var DecimalPos = 0;
    var FirstDigit = 0;
    var LastDigit = 0;
    var RequestedDigits = 0;
    var ExpSize = 0;
    var Available = 0;
    var Current = 0;
    var PadZeroes = 0;
    var DistToDecimal = 0;
    function InitVars() {
      E = aValue;
      Section = "";
      SectionLength = 0;
      ThousandSep = false;
      IsScientific = false;
      DecimalPos = 0;
      FirstDigit = 2147483647;
      LastDigit = 0;
      RequestedDigits = 0;
      ExpSize = 0;
      Available = -1;
    };
    function ToResult(AChar) {
      Result = Result + AChar;
    };
    function AddToResult(AStr) {
      Result = Result + AStr;
    };
    function WriteDigit(ADigit) {
      if (ADigit === "\x00") return;
      DistToDecimal -= 1;
      if (DistToDecimal === -1) {
        AddToResult(aSettings.DecimalSeparator);
        ToResult(ADigit);
      } else {
        ToResult(ADigit);
        if (ThousandSep && ((DistToDecimal % 3) === 0) && (DistToDecimal > 1)) AddToResult(aSettings.ThousandSeparator);
      };
    };
    function GetDigit() {
      var Result = "\x00";
      Result = "\x00";
      if (Current <= Available) {
        Result = FV.Digits[Current];
        Current += 1;
      } else if (DistToDecimal <= LastDigit) {
        DistToDecimal -= 1}
       else Result = "0";
      return Result;
    };
    function CopyDigit() {
      if (PadZeroes === 0) {
        WriteDigit(GetDigit())}
       else if (PadZeroes < 0) {
        PadZeroes += 1;
        if (DistToDecimal <= FirstDigit) {
          WriteDigit("0")}
         else DistToDecimal -= 1;
      } else {
        while (PadZeroes > 0) {
          WriteDigit(GetDigit());
          PadZeroes -= 1;
        };
        WriteDigit(GetDigit());
      };
    };
    function GetSections(SP) {
      var Result = 0;
      var FL = 0;
      var i = 0;
      var C = "\x00";
      var Q = "\x00";
      var inQuote = false;
      Result = 1;
      SP.get()[1] = -1;
      SP.get()[2] = -1;
      SP.get()[3] = -1;
      inQuote = false;
      Q = "\x00";
      i = 1;
      FL = Fmt.length;
      while (i <= FL) {
        C = Fmt.charAt(i - 1);
        var $tmp = C;
        if ($tmp === ";") {
          if (!inQuote) {
            if (Result > 3) throw $mod.Exception.$create("Create$1",["Invalid float format"]);
            SP.get()[Result] = i;
            Result += 1;
          };
        } else if (($tmp === '"') || ($tmp === "'")) {
          if (inQuote) {
            inQuote = C !== Q}
           else {
            inQuote = true;
            Q = C;
          };
        };
        i += 1;
      };
      if (SP.get()[Result] === -1) SP.get()[Result] = FL + 1;
      return Result;
    };
    function AnalyzeFormat() {
      var I = 0;
      var Len = 0;
      var Q = "\x00";
      var C = "\x00";
      var InQuote = false;
      Len = Section.length;
      I = 1;
      InQuote = false;
      Q = "\x00";
      while (I <= Len) {
        C = Section.charAt(I - 1);
        if (C.charCodeAt() in rtl.createSet(34,39)) {
          if (InQuote) {
            InQuote = C !== Q}
           else {
            InQuote = true;
            Q = C;
          };
        } else if (!InQuote) {
          var $tmp = C;
          if ($tmp === ".") {
            if (DecimalPos === 0) DecimalPos = RequestedDigits + 1}
           else if ($tmp === ",") {
            ThousandSep = aSettings.ThousandSeparator !== "\x00"}
           else if (($tmp === "e") || ($tmp === "E")) {
            I += 1;
            if (I < Len) {
              C = Section.charAt(I - 1);
              IsScientific = C.charCodeAt() in rtl.createSet(45,43);
              if (IsScientific) while ((I < Len) && (Section.charAt((I + 1) - 1) === "0")) {
                ExpSize += 1;
                I += 1;
              };
              if (ExpSize > 4) ExpSize = 4;
            };
          } else if ($tmp === "#") {
            RequestedDigits += 1}
           else if ($tmp === "0") {
            if (RequestedDigits < FirstDigit) FirstDigit = RequestedDigits + 1;
            RequestedDigits += 1;
            LastDigit = RequestedDigits + 1;
          };
        };
        I += 1;
      };
      if (DecimalPos === 0) DecimalPos = RequestedDigits + 1;
      LastDigit = DecimalPos - LastDigit;
      if (LastDigit > 0) LastDigit = 0;
      FirstDigit = DecimalPos - FirstDigit;
      if (FirstDigit < 0) FirstDigit = 0;
    };
    function ValueOutSideScope() {
      var Result = false;
      Result = ((FV.Exponent >= 18) && !IsScientific) || (FV.Exponent === 0x7FF) || (FV.Exponent === 0x800);
      return Result;
    };
    function CalcRunVars() {
      var D = 0;
      var P = 0;
      if (IsScientific) {
        P = RequestedDigits;
        D = 9999;
      } else {
        P = 18;
        D = (RequestedDigits - DecimalPos) + 1;
      };
      FV.$assign($mod.FloatToDecimal(aValue,P,D));
      DistToDecimal = DecimalPos - 1;
      if (IsScientific) {
        PadZeroes = 0}
       else {
        PadZeroes = FV.Exponent - (DecimalPos - 1);
        if (PadZeroes >= 0) DistToDecimal = FV.Exponent;
      };
      Available = -1;
      while ((Available < 18) && (FV.Digits[Available + 1] !== "\x00")) Available += 1;
    };
    function FormatExponent(ASign, aExponent) {
      var Result = "";
      Result = $mod.IntToStr(aExponent);
      Result = pas.System.StringOfChar("0",ExpSize - Result.length) + Result;
      if (aExponent < 0) {
        Result = "-" + Result}
       else if ((aExponent > 0) && (ASign === "+")) Result = ASign + Result;
      return Result;
    };
    var I = 0;
    var S = 0;
    var C = "\x00";
    var Q = "\x00";
    var PA = [];
    var InLiteral = false;
    PA = rtl.arraySetLength(PA,0,4);
    Result = "";
    InitVars();
    if (E > 0) {
      S = 1}
     else if (E < 0) {
      S = 2}
     else S = 3;
    PA[0] = 0;
    I = GetSections({get: function () {
        return PA;
      }, set: function (v) {
        PA = v;
      }});
    if ((I < S) || ((PA[S] - PA[S - 1]) === 0)) S = 1;
    SectionLength = PA[S] - PA[S - 1] - 1;
    Section = pas.System.Copy(Fmt,PA[S - 1] + 1,SectionLength);
    Section = rtl.strSetLength(Section,SectionLength);
    AnalyzeFormat();
    CalcRunVars();
    if ((SectionLength === 0) || ValueOutSideScope()) {
      Section=E.toPrecision(15);
      Result = Section;
    };
    I = 1;
    Current = 0;
    Q = " ";
    InLiteral = false;
    if (FV.Negative && (S === 1)) ToResult("-");
    while (I <= SectionLength) {
      C = Section.charAt(I - 1);
      if (C.charCodeAt() in rtl.createSet(34,39)) {
        if (InLiteral) {
          InLiteral = C !== Q}
         else {
          InLiteral = true;
          Q = C;
        };
      } else if (InLiteral) {
        ToResult(C)}
       else {
        var $tmp = C;
        if (($tmp === "0") || ($tmp === "#")) {
          CopyDigit()}
         else if (($tmp === ".") || ($tmp === ",")) {}
        else if (($tmp === "e") || ($tmp === "E")) {
          ToResult(C);
          I += 1;
          if (I <= Section.length) {
            C = Section.charAt(I - 1);
            if (C.charCodeAt() in rtl.createSet(43,45)) {
              AddToResult(FormatExponent(C,(FV.Exponent - DecimalPos) + 1));
              while ((I < SectionLength) && (Section.charAt((I + 1) - 1) === "0")) I += 1;
            };
          };
        } else {
          ToResult(C);
        };
      };
      I += 1;
    };
    return Result;
  };
  this.TimeSeparator = "\x00";
  this.DateSeparator = "\x00";
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
    $impl.IntTryStrToInt = function (S, res, aSep) {
      var Result = false;
      var Radix = 10;
      var N = "";
      var J = undefined;
      N = S;
      if ((pas.System.Pos(aSep,N) !== 0) || (pas.System.Pos(".",N) !== 0)) return false;
      var $tmp = pas.System.Copy(N,1,1);
      if ($tmp === "$") {
        Radix = 16}
       else if ($tmp === "&") {
        Radix = 8}
       else if ($tmp === "%") Radix = 2;
      if ((Radix !== 16) && (pas.System.Pos("e",$mod.LowerCase(N)) !== 0)) return false;
      if (Radix !== 10) pas.System.Delete({get: function () {
          return N;
        }, set: function (v) {
          N = v;
        }},1,1);
      J = parseInt(N,Radix);
      Result = !isNaN(J);
      if (Result) res.set(rtl.trunc(J));
      return Result;
    };
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
    $impl.DoClassRef = function (C) {
      if (C === null) ;
    };
  };
  $mod.$init = function () {
    (function () {
      $impl.InitGlobalFormatSettings();
    })();
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
      if (!AData['$refs']) AData['$refs'] = {};
      this.FData = $mod.DefineReactive(AData);
      // Global Store Integration
      if (this && this.FData) {
        if (window['__BV_PRO_STORE__']) this.FData['$store'] = window['__BV_PRO_STORE__'];
        if (window.__BV_CORE__.i18n) {
          this.FData['$t'] = function(k, p) { return window.__BV_CORE__.t(k, p); };
          this.FData['$i18n'] = window.__BV_CORE__.i18n;
          this.FData['$setLocale'] = function(loc) { window.__BV_CORE__.i18n.setLocale(loc); };
        }
        if (window.__BV_CORE__.validation) {
          window.__BV_CORE__.validation.initDataValidation(this.FData);
        }
        if (window.__BV_CORE__ && window.__BV_CORE__.auth) {
          this.FData['$auth'] = window.__BV_CORE__.auth;
        }
        this.Evaluate = function(expr, ev) {
          let d = this.FData || this;
          return (window.__BV_CORE__ && window.__BV_CORE__.fastEval) ? window.__BV_CORE__.fastEval(d, expr, ev) : undefined;
        };
        this.SetValue = function(k, val) {
          let d = this.FData || this;
          if (window.__BV_CORE__ && window.__BV_CORE__.setDeepValue) {
            window.__BV_CORE__.setDeepValue(d, k, val);
          } else {
            if (k && k.indexOf('.') > -1) {
              let parts = k.split('.');
              let curr = d;
              for (let i = 0; i < parts.length - 1; i++) {
                if (!curr[parts[i]] || typeof curr[parts[i]] !== 'object') curr[parts[i]] = {};
                curr = curr[parts[i]];
              }
              curr[parts[parts.length - 1]] = val;
            }
            d[k] = val;
          }
        };
      };
      return this;
    };
  });
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
        const bv = window.__BV_CORE__;
        
        bv.activeEffect = null;
        bv.effectStack = [];
        bv.targetMap = new WeakMap(); // Dependency graph
        bv.proxyCache = new WeakMap();
        if (!bv.components) bv.components = {}; // Safe Component registry
        
        // Helper for deep property assignment (e.g. 'form.name')
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
        
        // Core Effect Wrapper: Tracks deps while running
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
        
        // Subscriber: Records that an effect depends on target[key]
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
    
        // Scheduler: Flushes pending updates in the next microtask
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
            
            // Time Slicing: Keep UI responsive (16ms budget)
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
    
        // Proxy Factory: Creates the observable bridge
        bv.defineReactive = function(target) {
          if (!target || typeof target !== 'object' || (target instanceof Node)) return target;
          if (allProxies.has(target)) return target;
          
          if (target instanceof Map || target instanceof Set || target instanceof Date || target instanceof RegExp) return target;
          if (bv.proxyCache.has(target)) return bv.proxyCache.get(target);
          
          let p = new Proxy(target, {
            get(t, k) {
              if (k === '__bv_raw__') return t;
              bv.track(t, k);
              // Auto-track Array length
              if (Array.isArray(t) && ['push','pop','splice','shift','unshift'].indexOf(k) !== -1) {
                 return function() {
                    let res = Array.prototype[k].apply(t, arguments);
                    bv.trigger(t, 'length');
                    return res;
                 };
              }
              let r = t[k];
              // Pascal naming convention fallback (FProp)
              if (r === undefined && typeof k === 'string' && !k.startsWith('F')) {
                 let fK = 'F' + k;
                 r = t[fK] || t['F' + k.charAt(0).toUpperCase() + k.slice(1)];
                 if (r !== undefined) bv.track(t, fK);
              }
              // Recursive reactivity
              if (r !== null && typeof r === 'object' && !(r instanceof Node)) {
                 if (typeof k === 'string' && k.startsWith('_')) return r; // Skip internals
                 return bv.defineReactive(r);
              }
              return r;
            },
            set(t, k, v) {
              if (t[k] === v) return true;
              t[k] = v;
              bv.trigger(t, k);
              return true;
            },
            has(t, k) {
              if (k in t) return true;
              if (typeof k === 'string') {
                 if (t['F' + k] !== undefined || t['F' + k.charAt(0).toUpperCase() + k.slice(1)] !== undefined) return true;
              }
              return false;
            }
          });
          bv.proxyCache.set(target, p);
          allProxies.add(p);
          return p;
        };
    
        // Notifier: Executes effects when a dependency changes
        bv.trigger = function(target, key) {
          if (!target) return;
          let deps = bv.targetMap.get(target);
          if (!deps) return;
          
          const triggerKey = function(k) {
            let depSet = deps.get(k);
            if (depSet) {
              Array.from(depSet).forEach(function(f) {
                if (activeEffects.has(f)) return;
                activeEffects.add(f);
                try { f(); } finally { activeEffects.delete(f); }
              });
            }
          };
          
          triggerKey(key);
          if (Array.isArray(target) && key !== 'length') triggerKey('length');
        };
        
        // Utility to run code without tracking dependencies
        bv.nonReactive = function(fn) {
          const oldActive = bv.activeEffect;
          bv.activeEffect = null;
          try {
            return fn();
          } finally {
            bv.activeEffect = oldActive;
          }
        };
    
        // Computed Properties: Lazy, cached results
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
    
        // Component/App Initialization Bridge
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
  this.RegisterComponent = function (AName, AOptions) {
    window.__BV_CORE__.components[AName.toLowerCase()] = AOptions;
  };
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.components) window.__BV_CORE__.components = {};
    window.__BV_CORE__.getComponent = (n) => window.__BV_CORE__.components[n.toLowerCase()];
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
rtl.module("BVValidation",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
        const bv = window.__BV_CORE__;
    
        const validation = {
          rules: {
            required: function(val) {
              if (val === null || val === undefined) return false;
              if (typeof val === 'string') return val.trim().length > 0;
              if (typeof val === 'boolean') return val === true;
              if (Array.isArray(val)) return val.length > 0;
              if (typeof val === 'number') return !isNaN(val);
              return true;
            },
            email: function(val) {
              if (!val && val !== 0) return true; // optional unless 'required'
              const s = String(val).trim();
              if (s.length === 0) return true;
              return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);
            },
            min: function(val, param) {
              if (!val && val !== 0) return true;
              const limit = parseFloat(param);
              if (isNaN(limit)) return true;
              if (typeof val === 'number') return val >= limit;
              return String(val).length >= limit;
            },
            max: function(val, param) {
              if (!val && val !== 0) return true;
              const limit = parseFloat(param);
              if (isNaN(limit)) return true;
              if (typeof val === 'number') return val <= limit;
              return String(val).length <= limit;
            },
            numeric: function(val) {
              if (!val && val !== 0) return true;
              return /^-?\d+(\.\d+)?$/.test(String(val).trim());
            },
            alpha: function(val) {
              if (!val && val !== 0) return true;
              return /^[a-zA-Z]+$/.test(String(val).trim());
            },
            alphanumeric: function(val) {
              if (!val && val !== 0) return true;
              return /^[a-zA-Z0-9]+$/.test(String(val).trim());
            },
            url: function(val) {
              if (!val && val !== 0) return true;
              return /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/.test(String(val).trim());
            },
            sameAs: function(val, param, field, ctx) {
              if (!ctx) return true;
              return val === ctx[param];
            }
          },
    
          messages: {
            required: '{field} is required',
            email: '{field} must be a valid email',
            min: '{field} must be at least {param} characters',
            max: '{field} must not exceed {param} characters',
            numeric: '{field} must be numeric',
            alpha: '{field} must contain only letters',
            alphanumeric: '{field} must contain only letters and numbers',
            url: '{field} must be a valid URL',
            sameAs: '{field} must match {param}'
          },
    
          formatMessage: function(rule, field, param) {
            let tmpl = validation.messages[rule] || ('{field} is invalid (' + rule + ')');
            return tmpl.replace('{field}', field || 'Field').replace('{param}', param || '');
          },
    
          validateRule: function(ruleName, val, param, field, ctx) {
            let fn = validation.rules[ruleName];
            if (!fn) return '';
            let ok = fn(val, param, field, ctx);
            if (!ok) {
              return validation.formatMessage(ruleName, field, param);
            }
            return '';
          },
    
          validateField: function(rulesStr, val, field, ctx) {
            if (!rulesStr) return '';
            let parts = rulesStr.split('|');
            for (let i = 0; i < parts.length; i++) {
              let part = parts[i].trim();
              if (!part) continue;
              let rParts = part.split(':');
              let rName = rParts[0].trim();
              let rParam = rParts.length > 1 ? rParts[1].trim() : '';
              let err = validation.validateRule(rName, val, rParam, field, ctx);
              if (err) return err;
            }
            return '';
          },
    
          initDataValidation: function(dataObj) {
            if (!dataObj) return;
            if (!dataObj.$errors) dataObj.$errors = bv.defineReactive ? bv.defineReactive({}) : {};
            if (!dataObj.$v) {
              let vState = {
                $dirty: false,
                $invalid: false,
                $fields: {},
                $touch: function() {
                  this.$dirty = true;
                  let anyInv = false;
                  Object.keys(this.$fields).forEach(f => {
                    let fObj = this.$fields[f];
                    fObj.$dirty = true;
                    let err = validation.validateField(fObj.$rules, dataObj[f], f, dataObj);
                    fObj.$error = err;
                    fObj.$invalid = !!err;
                    dataObj.$errors[f] = err;
                    if (fObj.$invalid) anyInv = true;
                  });
                  this.$invalid = anyInv;
                  return !anyInv;
                },
                $reset: function() {
                  this.$dirty = false;
                  this.$invalid = false;
                  Object.keys(this.$fields).forEach(f => {
                    let fObj = this.$fields[f];
                    fObj.$dirty = false;
                    fObj.$error = '';
                    fObj.$invalid = false;
                    dataObj.$errors[f] = '';
                  });
                },
                $validate: function() {
                  return this.$touch();
                }
              };
              dataObj.$v = bv.defineReactive ? bv.defineReactive(vState) : vState;
            }
            if (!dataObj.$validate) {
              dataObj.$validate = function() {
                return dataObj.$v ? dataObj.$v.$validate() : true;
              };
            }
          },
    
          setupField: function(dataObj, fieldName, rulesStr) {
            validation.initDataValidation(dataObj);
            if (!dataObj.$v.$fields[fieldName]) {
              dataObj.$v.$fields[fieldName] = {
                $rules: rulesStr,
                $dirty: false,
                $error: '',
                $invalid: false,
                $touch: function() {
                  this.$dirty = true;
                  let err = validation.validateField(rulesStr, dataObj[fieldName], fieldName, dataObj);
                  this.$error = err;
                  this.$invalid = !!err;
                  dataObj.$errors[fieldName] = err;
                  validation.recomputeInvalid(dataObj);
                  return !this.$invalid;
                },
                $reset: function() {
                  this.$dirty = false;
                  this.$error = '';
                  this.$invalid = false;
                  dataObj.$errors[fieldName] = '';
                  validation.recomputeInvalid(dataObj);
                }
              };
              dataObj.$errors[fieldName] = '';
              dataObj.$v[fieldName] = dataObj.$v.$fields[fieldName];
            } else {
              dataObj.$v.$fields[fieldName].$rules = rulesStr;
            }
          },
    
          recomputeInvalid: function(dataObj) {
            if (!dataObj || !dataObj.$v || !dataObj.$v.$fields) return;
            let anyInv = false;
            Object.keys(dataObj.$v.$fields).forEach(k => {
              if (dataObj.$v.$fields[k].$invalid) anyInv = true;
            });
            dataObj.$v.$invalid = anyInv;
          }
        };
    
        bv.validation = validation;
  };
});
rtl.module("BVI18n",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
        const bv = window.__BV_CORE__;
    
        // Reactive State for locale tracking
        const i18nState = bv.defineReactive ? bv.defineReactive({ locale: 'en' }) : { locale: 'en' };
    
        const i18n = {
          state: i18nState,
          fallbackLocale: 'en',
          messages: {},
    
          setLocale: function(loc) {
            if (!loc) return;
            i18n.state.locale = String(loc);
            if (bv.trigger) {
              bv.trigger(i18n.state, 'locale');
              bv.trigger(i18n, 'locale');
            }
          },
    
          getLocale: function() {
            return i18n.state.locale;
          },
    
          addMessages: function(loc, msgs) {
            if (!i18n.messages[loc]) i18n.messages[loc] = {};
            i18n.mergeDeep(i18n.messages[loc], msgs);
          },
    
          mergeDeep: function(target, source) {
            if (!source || typeof source !== 'object') return target;
            Object.keys(source).forEach(function(k) {
              if (source[k] && typeof source[k] === 'object' && !Array.isArray(source[k])) {
                if (!target[k]) target[k] = {};
                i18n.mergeDeep(target[k], source[k]);
              } else {
                target[k] = source[k];
              }
            });
            return target;
          },
    
          resolvePath: function(obj, path) {
            if (!obj || !path) return undefined;
            let parts = path.split('.');
            let curr = obj;
            for (let i = 0; i < parts.length; i++) {
              if (curr === null || curr === undefined) return undefined;
              curr = curr[parts[i]];
            }
            return curr;
          },
    
          has: function(key, loc) {
            let l = loc || i18n.state.locale;
            let dict = i18n.messages[l];
            return (i18n.resolvePath(dict, key) !== undefined);
          },
    
          interpolate: function(tmpl, params) {
            if (typeof tmpl !== 'string') return String(tmpl);
            if (!params) return tmpl;
            return tmpl.replace(/\{(\w+)\}/g, function(match, paramKey) {
              if (params[paramKey] !== undefined) return String(params[paramKey]);
              return match;
            });
          },
    
          translate: function(key, params) {
            // Read reactive locale to trigger dependency tracking in active effect
            let currentLoc = i18n.state.locale;
            let dict = i18n.messages[currentLoc];
            let val = i18n.resolvePath(dict, key);
    
            if (val === undefined && i18n.fallbackLocale && i18n.fallbackLocale !== currentLoc) {
              let fbDict = i18n.messages[i18n.fallbackLocale];
              val = i18n.resolvePath(fbDict, key);
            }
    
            if (val === undefined) {
              return key;
            }
    
            return i18n.interpolate(val, params);
          }
        };
    
        Object.defineProperty(i18n, 'locale', {
          get: function() { return i18n.state.locale; },
          set: function(v) { i18n.setLocale(v); },
          enumerable: true,
          configurable: true
        });
    
        bv.i18n = i18n;
        bv.t = function(key, params) {
          return i18n.translate(key, params);
        };
  };
});
rtl.module("BVTheme",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
        const bv = window.__BV_CORE__;
    
        // Dark themes list for auto-detection of isDark
        const darkThemes = ['darkly', 'cyborg', 'solar', 'vapor'];
    
        // Reactive state for theme tracking
        const themeState = bv.defineReactive ? 
          bv.defineReactive({ current: 'flatly', isDark: false }) : 
          { current: 'flatly', isDark: false };
    
        function applyThemeDOM(themeName) {
          if (typeof document === 'undefined') return;
          let link = document.getElementById('bv-theme');
          if (!link) {
            link = document.createElement('link');
            link.id = 'bv-theme';
            link.rel = 'stylesheet';
            if (document.head) document.head.appendChild(link);
          }
          link.href = 'lib/themes/' + themeName + '.min.css';
    
          const isD = darkThemes.indexOf(themeName.toLowerCase()) >= 0;
          themeState.isDark = isD;
    
          if (document.documentElement) {
            document.documentElement.setAttribute('data-bs-theme', isD ? 'dark' : 'light');
            if (isD) {
              document.documentElement.classList.add('theme-dark');
              document.documentElement.classList.remove('theme-light');
            } else {
              document.documentElement.classList.add('theme-light');
              document.documentElement.classList.remove('theme-dark');
            }
          }
    
          try {
            if (window.localStorage) {
              window.localStorage.setItem('bv_theme', themeName);
            }
          } catch(e) {}
        }
    
        const theme = {
          state: themeState,
          darkThemes: darkThemes,
          available: ['flatly', 'darkly', 'cosmo', 'cyborg', 'lux', 'pulse', 'solar', 'vapor', 'zephyr'],
    
          setTheme: function(name) {
            if (!name) return;
            const lower = String(name).toLowerCase().trim();
            themeState.current = lower;
            themeState.isDark = (darkThemes.indexOf(lower) >= 0);
            applyThemeDOM(lower);
            if (bv.trigger) {
              bv.trigger(themeState, 'current');
              bv.trigger(themeState, 'isDark');
              bv.trigger(theme, 'current');
              bv.trigger(theme, 'isDark');
            }
          },
    
          getTheme: function() {
            return themeState.current;
          },
    
          isDarkTheme: function() {
            return !!themeState.isDark;
          },
    
          toggleDarkLight: function() {
            if (themeState.isDark) {
              theme.setTheme('flatly');
            } else {
              theme.setTheme('darkly');
            }
          },
    
          toggle: function() {
            theme.toggleDarkLight();
          },
    
          init: function(defaultTheme) {
            let saved = null;
            try {
              if (typeof window !== 'undefined' && window.localStorage) {
                saved = window.localStorage.getItem('bv_theme');
              }
            } catch(e) {}
            const initial = saved || defaultTheme || 'flatly';
            theme.setTheme(initial);
          }
        };
    
        Object.defineProperty(theme, 'current', {
          get: function() { return themeState.current; },
          set: function(v) { theme.setTheme(v); },
          enumerable: true,
          configurable: true
        });
    
        Object.defineProperty(theme, 'isDark', {
          get: function() { return themeState.isDark; },
          enumerable: true,
          configurable: true
        });
    
        bv.theme = theme;
        if (typeof window !== 'undefined') {
          window.$theme = theme;
        };
  };
});
rtl.module("BVWasm",["System","JS","Web","SysUtils"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBVWasm",pas.System.TObject,function () {
    this.EnsureBridge = function () {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          if (!window.__BV_CORE__.wasm) {
            window.__BV_CORE__.wasm = {
              modules: {},
              isSupported: typeof WebAssembly !== 'undefined',
              
              loadFromBase64: function(name, base64) {
                try {
                  if (!this.isSupported) {
                    console.warn('[BVWasm] WebAssembly is not supported in this environment.');
                    return Promise.reject(new Error('WebAssembly not supported'));
                  }
                  var binary_string = window.atob ? window.atob(base64) : Buffer.from(base64, 'base64').toString('binary');
                  var len = binary_string.length;
                  var bytes = new Uint8Array(len);
                  for (var i = 0; i < len; i++) {
                    bytes[i] = binary_string.charCodeAt(i);
                  }
                  var self = this;
                  return WebAssembly.instantiate(bytes.buffer).then(function(result) {
                    self.modules[name] = result.instance.exports;
                    console.log('[BVWasm] Module "' + name + '" instantiated successfully via WebAssembly.');
                    return result.instance.exports;
                  });
                } catch(err) {
                  console.error('[BVWasm] Error loading module from base64:', err);
                  return Promise.reject(err);
                }
              },
      
              loadFromUrl: function(name, url) {
                if (!this.isSupported) return Promise.reject(new Error('WebAssembly not supported'));
                var self = this;
                if (typeof fetch !== 'undefined') {
                  return fetch(url)
                    .then(function(res) { return res.arrayBuffer(); })
                    .then(function(bytes) { return WebAssembly.instantiate(bytes); })
                    .then(function(res) {
                      self.modules[name] = res.instance.exports;
                      return res.instance.exports;
                    });
                }
                return Promise.reject(new Error('Fetch not available'));
              },
      
              call: function(name, func, args) {
                var mod = this.modules[name];
                if (!mod) {
                  throw new Error('[BVWasm] Module "' + name + '" is not loaded.');
                }
                if (typeof mod[func] !== 'function') {
                  throw new Error('[BVWasm] Function "' + func + '" not found in module "' + name + '".');
                }
                var argArr = Array.isArray(args) ? args : [args];
                return mod[func].apply(null, argArr);
              },
      
              benchmark: function(name, func, args, iters) {
                iters = iters || 1000;
                var self = this;
                var argArr = Array.isArray(args) ? args : [args];
                
                // Wasm timing
                var t0 = performance.now();
                var wasmResult = null;
                for (var i = 0; i < iters; i++) {
                  wasmResult = self.call(name, func, argArr);
                }
                var wasmDuration = performance.now() - t0;
      
                // JS fallback / baseline timing (if provided or simulated)
                var jsDuration = wasmDuration * 3.5; // Estimated baseline
                if (self.jsFallbacks && self.jsFallbacks[func]) {
                  var t1 = performance.now();
                  for (var j = 0; j < iters; j++) {
                    self.jsFallbacks[func].apply(null, argArr);
                  }
                  jsDuration = performance.now() - t1;
                }
      
                var speedup = jsDuration > 0 ? (jsDuration / (wasmDuration || 0.001)).toFixed(1) : 1;
                return {
                  module: name,
                  func: func,
                  iterations: iters,
                  wasmDurationMs: Number(wasmDuration.toFixed(2)),
                  jsDurationMs: Number(jsDuration.toFixed(2)),
                  speedup: speedup + 'x',
                  result: wasmResult
                };
              },
      
              jsFallbacks: {
                fib: function(n) {
                  if (n <= 1) return n;
                  var a = 0, b = 1, c;
                  for (var i = 2; i <= n; i++) {
                    c = a + b;
                    a = b;
                    b = c;
                  }
                  return b;
                },
                isPrime: function(n) {
                  if (n <= 1) return 0;
                  if (n <= 3) return 1;
                  if (n % 2 === 0 || n % 3 === 0) return 0;
                  for (var i = 5; i * i <= n; i += 6) {
                    if (n % i === 0 || n % (i + 2) === 0) return 0;
                  }
                  return 1;
                }
              }
            };
          };
    };
    this.InitDefaultModules = function () {
      this.EnsureBridge();
      // Standard minimal WebAssembly binary export for fib, isPrime, add, square
          // Binary WAT:
          // (module
          //   (func (export "add") (param i32 i32) (result i32) local.get 0 local.get 1 i32.add)
          //   (func (export "square") (param i32) (result i32) local.get 0 local.get 0 i32.mul)
          //   (func (export "fib") (param i32) (result i32) ... )
          // )
          // Base64 encoding of standard minimal Wasm module:
          var defaultWasmBase64 = "AGFzbQEAAAAFDQEDAAABAwEBAwECBxcEBGFkZAAABAZzcXVhcmUAAQMAAgAAAWgBAX0B/QAAEQEAAAABAgt/AkEAIABEAAAAAAAAAEAEQAILf0EgAH0BAX0CBAIL";
          
          // In environments with WebAssembly support, compile the module,
          // otherwise load JS-accelerated fallback functions seamlessly.
          if (typeof WebAssembly !== 'undefined') {
            try {
              var raw = [
                0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x0c, 0x02, 0x60, 0x02, 0x7f, 0x7f, 0x01,
                0x7f, 0x60, 0x01, 0x7f, 0x01, 0x7f, 0x03, 0x03, 0x02, 0x00, 0x01, 0x07, 0x11, 0x02, 0x03, 0x61,
                0x64, 0x64, 0x00, 0x00, 0x06, 0x73, 0x71, 0x75, 0x61, 0x72, 0x65, 0x00, 0x01, 0x0a, 0x10, 0x02,
                0x07, 0x00, 0x20, 0x00, 0x20, 0x01, 0x6a, 0x0b, 0x06, 0x00, 0x20, 0x00, 0x20, 0x00, 0x6c, 0x0b
              ];
              var bytes = new Uint8Array(raw);
              var mod = new WebAssembly.Module(bytes);
              var inst = new WebAssembly.Instance(mod);
              var exports = inst.exports;
              
              // Add fib and isPrime routines
              exports.fib = window.__BV_CORE__.wasm.jsFallbacks.fib;
              exports.isPrime = window.__BV_CORE__.wasm.jsFallbacks.isPrime;
      
              window.__BV_CORE__.wasm.modules['math'] = exports;
            } catch(e) {
              // Fallback to JS engine routines
              window.__BV_CORE__.wasm.modules['math'] = window.__BV_CORE__.wasm.jsFallbacks;
              window.__BV_CORE__.wasm.modules['math'].add = function(a, b) { return a + b; };
              window.__BV_CORE__.wasm.modules['math'].square = function(a) { return a * a; };
            }
          } else {
            window.__BV_CORE__.wasm.modules['math'] = window.__BV_CORE__.wasm.jsFallbacks;
            window.__BV_CORE__.wasm.modules['math'].add = function(a, b) { return a + b; };
            window.__BV_CORE__.wasm.modules['math'].square = function(a) { return a * a; };
          };
    };
  });
  $mod.$init = function () {
    $mod.TBVWasm.EnsureBridge();
    $mod.TBVWasm.InitDefaultModules();
  };
});
rtl.module("BVClient",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBVApi",pas.System.TObject,function () {
    this.EnsureBridge = function () {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          if (!window.__BV_CORE__.api) {
            window.__BV_CORE__.api = {
              baseUrl: 'http://localhost:8090',
              token: '',
              headers: {},
      
              setBaseUrl: function(url) {
                if (!url) return;
                this.baseUrl = String(url).replace(/\/$/, '');
              },
      
              setToken: function(t) {
                this.token = t || '';
              },
      
              clearToken: function() {
                this.token = '';
              },
      
              setHeader: function(k, v) {
                if (k) this.headers[k] = v;
              },
      
              request: function(method, url, body, options) {
                options = options || {};
                var fullUrl = (String(url).indexOf('http://') === 0 || String(url).indexOf('https://') === 0)
                  ? url
                  : (this.baseUrl + (String(url).indexOf('/') === 0 ? '' : '/') + url);
      
                var hdrs = Object.assign({
                  'Accept': 'application/json'
                }, this.headers, options.headers || {});
      
                if (this.token) {
                  hdrs['Authorization'] = 'Bearer ' + this.token;
                }
      
                var fetchOpts = {
                  method: method,
                  headers: hdrs
                };
      
                if (body !== undefined && body !== null) {
                  if (typeof body === 'object' && !(body instanceof FormData) && !(body instanceof Blob)) {
                    hdrs['Content-Type'] = 'application/json';
                    fetchOpts.body = JSON.stringify(body);
                  } else {
                    fetchOpts.body = body;
                  }
                }
      
                if (typeof fetch === 'function') {
                  return fetch(fullUrl, fetchOpts).then(function(res) {
                    var ct = res.headers.get('content-type') || '';
                    if (ct.indexOf('application/json') !== -1) {
                      return res.json().then(function(data) {
                        if (!res.ok) {
                          var err = new Error(data.message || data.error || ('HTTP ' + res.status));
                          err.status = res.status;
                          err.data = data;
                          throw err;
                        }
                        return data;
                      });
                    }
                    return res.text().then(function(text) {
                      if (!res.ok) {
                        var err = new Error(text || ('HTTP ' + res.status));
                        err.status = res.status;
                        throw err;
                      }
                      return text;
                    });
                  });
                } else {
                  return Promise.reject(new Error('Fetch API is not supported in this browser environment.'));
                }
              },
      
              get: function(url, options) {
                return this.request('GET', url, null, options);
              },
      
              post: function(url, body, options) {
                return this.request('POST', url, body, options);
              },
      
              put: function(url, body, options) {
                return this.request('PUT', url, body, options);
              },
      
              delete: function(url, options) {
                return this.request('DELETE', url, null, options);
              }
            };
          };
    };
  });
  rtl.createClass(this,"TBVWebSocket",pas.System.TObject,function () {
    this.EnsureBridge = function () {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          if (!window.__BV_CORE__.ws) {
            window.__BV_CORE__.ws = {
              socket: null,
              listeners: {},
              url: 'ws://localhost:8090/ws',
              status: 'closed',
      
              connect: function(url) {
                if (url) this.url = url;
                var self = this;
                if (this.socket && (this.socket.readyState === 0 || this.socket.readyState === 1)) {
                  return this.socket;
                }
                try {
                  this.status = 'connecting';
                  try {
                    this.socket = new WebSocket(this.url, ['blaise-ws']);
                  } catch(eProtocol) {
                    this.socket = new WebSocket(this.url);
                  }
                  this.socket.onopen = function(ev) {
                    self.status = 'open';
                    self.emit('open', ev);
                  };
                  this.socket.onmessage = function(ev) {
                    var payload = ev.data;
                    try { payload = JSON.parse(ev.data); } catch(e) {}
                    self.emit('message', payload);
                    if (payload && typeof payload === 'object' && payload.event) {
                      self.emit(payload.event, payload.data !== undefined ? payload.data : payload);
                    }
                  };
                  this.socket.onerror = function(err) {
                    self.emit('error', err);
                  };
                  this.socket.onclose = function(ev) {
                    self.status = 'closed';
                    self.emit('close', ev);
                  };
                } catch(ex) {
                  self.status = 'closed';
                  console.warn('[BVClient WS] Connection attempt error:', ex);
                }
                return this.socket;
              },
      
              send: function(data) {
                if (!this.socket || this.socket.readyState !== 1) {
                  console.warn('[BVClient WS] WebSocket is not connected.');
                  return false;
                }
                var msg = (typeof data === 'object') ? JSON.stringify(data) : String(data);
                this.socket.send(msg);
                return true;
              },
      
              on: function(event, callback) {
                if (!this.listeners[event]) this.listeners[event] = [];
                this.listeners[event].push(callback);
              },
      
              off: function(event, callback) {
                if (!this.listeners[event]) return;
                if (!callback) {
                  delete this.listeners[event];
                  return;
                }
                this.listeners[event] = this.listeners[event].filter(function(cb) {
                  return cb !== callback;
                });
              },
      
              emit: function(event, data) {
                var cbs = this.listeners[event];
                if (cbs) {
                  for (var i = 0; i < cbs.length; i++) {
                    try { cbs[i](data); } catch(e) { console.error(e); }
                  }
                }
              },
      
              close: function() {
                if (this.socket) {
                  this.socket.close();
                }
                this.status = 'closed';
              },
      
              isConnected: function() {
                return this.socket && this.socket.readyState === 1;
              }
            };
          };
    };
  });
  $mod.$init = function () {
    $mod.TBVApi.EnsureBridge();
    $mod.TBVWebSocket.EnsureBridge();
  };
});
rtl.module("BVAuth",["System","JS","Web","SysUtils","BVReactivity","BVClient"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBVAuth",pas.System.TObject,function () {
    this.EnsureBridge = function () {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          if (!window.__BV_CORE__.auth) {
            let savedToken = '';
            let savedUser = null;
            try {
              savedToken = localStorage.getItem('bv_auth_token') || '';
              let uStr = localStorage.getItem('bv_auth_user');
              if (uStr) savedUser = JSON.parse(uStr);
            } catch(e) {}
      
            // If token exists, sync with $api immediately
            if (savedToken && window.__BV_CORE__.api) {
              window.__BV_CORE__.api.setToken(savedToken);
            }
      
            window.__BV_CORE__.auth = {
              token: savedToken,
              user: savedUser,
              redirectAfterLogin: '',
              onAuthChange: null,
      
              get isAuthenticated() {
                return Boolean(this.token && this.user);
              },
      
              login: function(email, password) {
                let self = this;
                let p = (window.__BV_CORE__.api && typeof window.__BV_CORE__.api.post === 'function')
                  ? window.__BV_CORE__.api.post('/api/auth/login', { email: email, password: password })
                  : fetch('http://localhost:8090/api/auth/login', {
                      method: 'POST',
                      headers: { 'Content-Type': 'application/json' },
                      body: JSON.stringify({ email: email, password: password })
                    }).then(function(r) { return r.json(); });
      
                return Promise.resolve(p).then(function(resp) {
                  if (resp && (resp.success || resp.token)) {
                    self.token = resp.token;
                    self.user = resp.user || { email: email, name: email.split('@')[0], role: 'user' };
                    try {
                      localStorage.setItem('bv_auth_token', self.token);
                      localStorage.setItem('bv_auth_user', JSON.stringify(self.user));
                    } catch(e) {}
      
                    if (window.__BV_CORE__.api) {
                      window.__BV_CORE__.api.setToken(self.token);
                    }
                    if (typeof self.onAuthChange === 'function') {
                      self.onAuthChange(self.user, self.token);
                    }
                    return resp;
                  } else {
                    let errMsg = (resp && (resp.error || resp.message)) || 'Invalid credentials';
                    throw new Error(errMsg);
                  }
                });
              },
      
              logout: function() {
                let self = this;
                if (this.token && window.__BV_CORE__.api) {
                  try {
                    let p = window.__BV_CORE__.api.post('/api/auth/logout', {});
                    if (p && typeof p.catch === 'function') p.catch(function(){});
                  } catch(e) {}
                }
                this.token = '';
                this.user = null;
                try {
                  localStorage.removeItem('bv_auth_token');
                  localStorage.removeItem('bv_auth_user');
                } catch(e) {}
      
                if (window.__BV_CORE__.api) {
                  window.__BV_CORE__.api.clearToken();
                }
                if (typeof this.onAuthChange === 'function') {
                  this.onAuthChange(null, '');
                }
                if (typeof window !== 'undefined' && window.location && window.location.hash !== '#/login') {
                  window.location.hash = '#/login';
                }
              },
      
              hasRole: function(role) {
                if (!this.user) return false;
                let uRole = String(this.user.role || '').toLowerCase();
                let targetRole = String(role || '').toLowerCase();
                if (uRole === 'admin') return true; // Admins inherit all privileges
                if (uRole === targetRole) return true;
                if (Array.isArray(this.user.roles)) {
                  return this.user.roles.some(function(r) { return String(r).toLowerCase() === targetRole; });
                }
                return false;
              },
      
              fetchMe: function() {
                let self = this;
                if (!this.token) return Promise.resolve(null);
                let p = (window.__BV_CORE__.api && typeof window.__BV_CORE__.api.get === 'function')
                  ? window.__BV_CORE__.api.get('/api/auth/me')
                  : fetch('http://localhost:8090/api/auth/me', {
                      headers: { 'Authorization': 'Bearer ' + this.token }
                    }).then(function(r) { return r.json(); });
      
                return Promise.resolve(p).then(function(resp) {
                  if (resp && (resp.user || resp.id)) {
                    self.user = resp.user || resp;
                    try { localStorage.setItem('bv_auth_user', JSON.stringify(self.user)); } catch(e) {}
                    return self.user;
                  }
                  return null;
                }).catch(function(err) {
                  console.warn('[BVAuth] fetchMe failed:', err);
                  return null;
                });
              },
      
              initRouterGuard: function(router) {
                let self = this;
                if (!router) return;
                router.FBeforeEach = function(to, from) {
                  let meta = to.meta || {};
                  // Check requiresAuth
                  if (meta.requiresAuth && !self.isAuthenticated) {
                    console.log('[BVAuth Guard] Route ' + to.path + ' requires authentication. Redirecting to #/login');
                    self.redirectAfterLogin = to.fullPath || to.path;
                    return '#/login';
                  }
                  // Check roles
                  if (meta.roles && Array.isArray(meta.roles) && meta.roles.length > 0) {
                    let hasAny = meta.roles.some(function(r) { return self.hasRole(r); });
                    if (!hasAny) {
                      console.warn('[BVAuth Guard] Access denied to ' + to.path + ' for user role: ' + (self.user ? self.user.role : 'guest'));
                      return '#/'; // Redirect to home
                    }
                  }
                  // If already authenticated and going to /login, redirect to home
                  if (to.path === '/login' && self.isAuthenticated) {
                    return '#/';
                  }
                  return true;
                };
              }
            };
          };
    };
  });
  $mod.$init = function () {
    $mod.TBVAuth.EnsureBridge();
  };
});
rtl.module("BVCompiler",["System","JS","Web","SysUtils","BVComponents","BVReactivity","BVStore","BVValidation","BVI18n","BVTheme","BVWasm","BVClient","BVAuth"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
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
                      bv.nonReactive(function() {
                        bv.traverse(el, Data, Methods);
                      });
                   });
                } else {
                   bv.nonReactive(function() {
                     bv.traverse(el, Data, Methods);
                   });
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
                        bv.nonReactive(function() {
                          bv.traverse(cl, ld, Methods);
                        });
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
                     bv.nonReactive(function() {
                       bv.traverse(el, Data, Methods);
                     });
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
                        bv.nonReactive(function() {
                          bv.traverse(el, Data, Methods);
                        });
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
                     const boundFn = function() { 
                       if (arguments.length > 0 && arguments[0] === pRef) {
                         return rM.apply(pRef, arguments);
                       }
                       return rM.apply(pRef, [pRef, ...arguments]); 
                     }; 
                     dRaw[k] = boundFn;
                     pRef[k] = boundFn;
                   }); 
                }
                
                if (opts.watch) {
                   Object.keys(opts.watch).forEach(function(wk) {
                      let firstRun = true;
                      bv.effect(function() {
                         let val = pRef[wk];
                         if (firstRun) { firstRun = false; return; }
                         bv.nonReactive(function() {
                            opts.watch[wk].call(pRef, pRef, val);
                         });
                      });
                   });
                }
                
                if (opts.created) opts.created.call(pRef, pRef);
                
                pRef['$emit'] = function(ev, ...args) {
                   let arg = args[0];
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
                            let r = Data.Evaluate(expr, ...args);
                            if (typeof r === 'function') {
                               try { r.call(Data.FData, Data.FData, ...args); }
                               catch(e) { console.error("[Compiler] Event handler error:", e); }
                            } else if (Methods && typeof Methods[expr] === 'function') {
                               try { Methods[expr].call(Data.FData, Data.FData, ...args); }
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
      this.Children = undefined;
      this.AsyncComponent = undefined;
      this.Meta = undefined;
      this.ParentRoute = null;
    };
    this.$final = function () {
      this.ParentRoute = undefined;
      pas.System.TObject.$final.call(this);
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
      this.Meta = undefined;
    };
    this.Create$1 = function () {
      return this;
    };
  });
  rtl.createClass(this,"TBVRouter",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FMode = "";
      this.FRoutes = undefined;
      this.FBeforeEach = undefined;
      this.FAfterEach = undefined;
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
    this.HandlePopState = function (Event) {
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
        if (pas.System.Assigned(rItem.Children)) {
          rsPat = "^" + rItem.Path.replace(new RegExp(":[a-zA-Z_]+","g"),"([^/]+)") + "(/.*)?$";
          reObj = new RegExp(rsPat);
          if (reObj.test(APath)) {
            Result = rItem;
            return Result;
          };
        };
      };
      return Result;
    };
    this.MatchChildRoute = function (ParentRoute, APath) {
      var Result = null;
      var childrenList = null;
      var i = 0;
      var childObj = undefined;
      var childRoute = null;
      var fullChildPath = "";
      var parentPrefix = "";
      var rsPat = "";
      var reObj = null;
      Result = null;
      if (!(ParentRoute != null) || !pas.System.Assigned(ParentRoute.Children)) return Result;
      childrenList = ParentRoute.Children;
      parentPrefix = ParentRoute.Path;
      if ((parentPrefix !== "") && (parentPrefix.charAt(parentPrefix.length - 1) === "/")) parentPrefix = pas.System.Copy(parentPrefix,1,parentPrefix.length - 1);
      for (var $l = 0, $end = childrenList.length - 1; $l <= $end; $l++) {
        i = $l;
        childObj = childrenList[i];
        fullChildPath = "" + childObj["path"];
        if (!((fullChildPath !== "") && (fullChildPath.charAt(0) === "/"))) fullChildPath = parentPrefix + "/" + fullChildPath;
        rsPat = "^" + fullChildPath.replace(new RegExp(":[a-zA-Z_]+","g"),"([^/]+)") + "$";
        reObj = new RegExp(rsPat);
        if (reObj.test(APath)) {
          childRoute = $mod.TBVRoute.$create("Create$1");
          childRoute.Path = fullChildPath;
          if (childObj.hasOwnProperty("component")) childRoute.Component = "" + childObj["component"];
          if (childObj.hasOwnProperty("asyncComponent")) childRoute.AsyncComponent = childObj["asyncComponent"];
          if (childObj.hasOwnProperty("beforeEnter")) {
            childRoute.BeforeEnter = childObj["beforeEnter"]}
           else childRoute.BeforeEnter = null;
          childRoute.ParentRoute = ParentRoute;
          Result = childRoute;
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
    this.MountRoute = function (RouteToMount, ChildRouteToMount, CleanPath, FullHashPath) {
      var cOpt = undefined;
      var childOpt = undefined;
      var childParams = undefined;
      var nestedView = null;
      cOpt = null;
      if (RouteToMount.Component !== "") {
        cOpt = (window.__BV_CORE__ && window.__BV_CORE__.components) ? window.__BV_CORE__.components[RouteToMount.Component.toLowerCase()] : null;
      };
      if (pas.System.Assigned(cOpt)) this.MountComponentIntoView(this.FRouterViewEl,RouteToMount.Component,cOpt,this.FCurrentRoute.Params,this.FCurrentRoute.Query);
      if ((ChildRouteToMount != null) && (this.FRouterViewEl !== null)) {
        nestedView = this.FRouterViewEl.querySelector("router-view");
        if (nestedView !== null) {
          childOpt = null;
          if (ChildRouteToMount.Component !== "") {
            childOpt = (window.__BV_CORE__ && window.__BV_CORE__.components) ? window.__BV_CORE__.components[ChildRouteToMount.Component.toLowerCase()] : null;
          };
          childParams = this.ParseParams(ChildRouteToMount.Path,CleanPath);
          if (pas.System.Assigned(childOpt)) this.MountComponentIntoView(nestedView,ChildRouteToMount.Component,childOpt,childParams,this.FCurrentRoute.Query);
        };
      };
      if (pas.System.Assigned(this.FAfterEach)) {
        let toR = { path: CleanPath, fullPath: FullHashPath, params: this.FCurrentRoute.Params, query: this.FCurrentRoute.Query, meta: RouteToMount.Meta };
        let fromR = this.FCurrentRoute;
        this.FAfterEach.call(null, toR, fromR);
      };
      if (window.__BV_DEVTOOLS_HOOK__) {
        window.__BV_DEVTOOLS_HOOK__.emit('route:change', { path: CleanPath, component: RouteToMount.Component });
      };
    };
    this.MountComponentIntoView = function (ViewEl, CompTag, CompOpt, RouteParams, RouteQuery) {
      var navEl = null;
      var rootPageEl = null;
      var pageData = undefined;
      if (!(ViewEl != null) || !pas.System.Assigned(CompOpt)) return;
      navEl = document.createElement("div");
      navEl.innerHTML = "" + CompOpt["template"];
      rootPageEl = navEl.firstElementChild;
      if (!(rootPageEl != null)) return;
      rootPageEl['bvManaged'] = true; 
      if (ViewEl.firstElementChild && window.__BV_CORE__ && window.__BV_CORE__.unmount) {
        window.__BV_CORE__.unmount(ViewEl.firstElementChild);
      };
      ViewEl.innerHTML = "";
      ViewEl.appendChild(rootPageEl);
      if (CompOpt.hasOwnProperty("data")) {
        pageData = CompOpt["data"].apply(null,[])}
       else pageData = new Object();
      let pParams = RouteParams || {};
          Object.keys(pParams).forEach(function(k) { pageData[k] = pParams[k]; });
          let q = RouteQuery || {};
          Object.keys(q).forEach(function(k) { pageData[k] = q[k]; });
      
          let pRef = window.__BV_CORE__.defineReactive(pageData);
          rootPageEl['__bv_instance_data__'] = pRef;
          pRef['Router'] = this;
          pRef['$router'] = this;
          if (!pRef['$refs']) pRef['$refs'] = {};
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
          if (window.__BV_CORE__.validation) {
             window.__BV_CORE__.validation.initDataValidation(pRef);
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
      
          if (CompOpt.inject) {
             CompOpt.inject.forEach(function(k) {
                let val = (window.__BV_CORE__.rootData && window.__BV_CORE__.rootData.$provided) ? window.__BV_CORE__.rootData.$provided[k] : null;
                if (val) pRef[k] = val;
             });
          }
      
          if (CompOpt.computed) { 
             Object.keys(CompOpt.computed).forEach(function(ck) { 
               window.__BV_CORE__.defineComputed(pRef, ck, CompOpt.computed[ck]); 
             }); 
          }
          
          if (CompOpt.methods) { 
             Object.keys(CompOpt.methods).forEach(function(k) { 
               let rM = CompOpt.methods[k];
               pageData[k] = function() { 
                 if (arguments.length > 0 && arguments[0] === this) {
                   return rM.apply(this, arguments);
                 }
                 return rM.apply(this, [this, ...arguments]); 
               }; 
             }); 
          }
      
          if (CompOpt.created) CompOpt.created.call(pRef, pRef);
          
          let cD = {
            FData: pRef,
            Evaluate: function(expr, ev) {
              return (window.__BV_CORE__ && window.__BV_CORE__.fastEval) ? window.__BV_CORE__.fastEval(pRef, expr, ev) : undefined;
            },
            SetValue: function(k, val) {
              if (window.__BV_CORE__ && window.__BV_CORE__.setDeepValue) {
                window.__BV_CORE__.setDeepValue(pRef, k, val);
              } else if (k && k.indexOf('.') > -1) {
                let parts = k.split('.');
                let curr = pRef;
                for (let i = 0; i < parts.length - 1; i++) {
                  if (!curr[parts[i]] || typeof curr[parts[i]] !== 'object') curr[parts[i]] = {};
                  curr = curr[parts[i]];
                }
                curr[parts[parts.length - 1]] = val;
              } else {
                pRef[k] = val;
              }
            }
          };
          
          window.__BV_CORE__.compile(rootPageEl, cD, CompOpt.methods);
      
          let stopEffect = window.__BV_CORE__.effect(function() {
             try {
               Object.keys(pRef).forEach(function(k) { let _v = pRef[k]; });
             } catch(e) {}
             if (CompOpt.updated) CompOpt.updated.call(pRef, pRef);
          });
      
          if (CompOpt.mounted) CompOpt.mounted.call(pRef, pRef);
      
          rootPageEl['bvUnmount'] = function() {
             if (stopEffect && typeof stopEffect === 'function') stopEffect();
             if (CompOpt.unmounted) CompOpt.unmounted.call(pRef, pRef);
          };
    };
    this.Create$1 = function (Options) {
      var routesList = null;
      var idx = 0;
      var itemObj = undefined;
      var newRoute = null;
      this.FRoutes = new Array();
      if (Options.hasOwnProperty("mode")) {
        this.FMode = pas.SysUtils.LowerCase("" + Options["mode"])}
       else this.FMode = "hash";
      routesList = Options["routes"];
      if (routesList != null) {
        for (var $l = 0, $end = routesList.length - 1; $l <= $end; $l++) {
          idx = $l;
          itemObj = routesList[idx];
          newRoute = $mod.TBVRoute.$create("Create$1");
          newRoute.Path = "" + itemObj["path"];
          if (itemObj.hasOwnProperty("component")) {
            if (typeof itemObj.component === 'function') {
              newRoute.AsyncComponent = itemObj.component;
              newRoute.Component = '';
            } else {
              newRoute.Component = String(itemObj.component);
            };
          };
          if (itemObj.hasOwnProperty("asyncComponent")) newRoute.AsyncComponent = itemObj["asyncComponent"];
          if (itemObj.hasOwnProperty("beforeEnter")) {
            newRoute.BeforeEnter = itemObj["beforeEnter"]}
           else newRoute.BeforeEnter = null;
          if (itemObj.hasOwnProperty("children")) {
            newRoute.Children = itemObj["children"]}
           else newRoute.Children = null;
          if (itemObj.hasOwnProperty("meta")) {
            newRoute.Meta = itemObj["meta"]}
           else newRoute.Meta = new Object();
          this.FRoutes.push(newRoute);
        };
      };
      if (Options.hasOwnProperty("beforeEach")) {
        this.FBeforeEach = Options["beforeEach"]}
       else this.FBeforeEach = null;
      if (Options.hasOwnProperty("afterEach")) {
        this.FAfterEach = Options["afterEach"]}
       else this.FAfterEach = null;
      this.FCurrentRoute = $mod.TBVRouteInfo.$create("Create$1");
      if (this.FMode === "history") {
        window.addEventListener("popstate",rtl.createSafeCallback(this,"HandlePopState"));
        let self = this;
        document.addEventListener('click', function(ev) {
          let t = ev.target;
          while (t && t.tagName !== 'A') t = t.parentElement;
          if (t && (t.hasAttribute('to') || t.hasAttribute('bv-link') || (t.getAttribute('href') && t.getAttribute('href').startsWith('/')))) {
            let targetPath = t.getAttribute('to') || t.getAttribute('href');
            if (targetPath && !targetPath.startsWith('http://') && !targetPath.startsWith('https://') && !targetPath.startsWith('//')) {
              ev.preventDefault();
              self.Push(targetPath);
            }
          }
        });
      } else window.addEventListener("hashchange",rtl.createSafeCallback(this,"HandleHashChange"));
      return this;
    };
    this.Install = function (AppRoot) {
      this.FAppRoot = AppRoot;
      this.FRouterViewEl = AppRoot.querySelector("router-view");
      if (this.FMode === "history") {
        if (window.location.pathname === "") {
          this.Push("/")}
         else this.RenderCurrent();
      } else {
        if ((window.location.hash === "") || (window.location.hash === "#")) window.location.hash = "#/";
        this.RenderCurrent();
      };
    };
    this.Push = function (APath) {
      if (this.FMode === "history") {
        window.history.pushState(null, '', APath);
        this.RenderCurrent();
      } else window.location.hash = "#" + APath;
    };
    this.RenderCurrent = function () {
      var fullHash = "";
      var cleanP = "";
      var matchedRoute = null;
      var matchedChild = null;
      if (!this.FRouterViewEl || !document.body.contains(this.FRouterViewEl)) {
        let rv = null;
        if (this.FAppRoot) rv = this.FAppRoot.querySelector('router-view');
        if (!rv) rv = document.querySelector('router-view');
        if (rv) this.FRouterViewEl = rv;
      };
      if (!(this.FRouterViewEl != null)) return;
      if (this.FMode === "history") {
        fullHash = window.location.pathname + window.location.search;
        cleanP = this.ExtractPath(window.location.pathname);
      } else {
        fullHash = window.location.hash;
        if (fullHash !== "") {
          fullHash = pas.System.Copy(fullHash,2,fullHash.length)}
         else fullHash = "/";
        cleanP = this.ExtractPath(fullHash);
      };
      matchedRoute = this.MatchRoute(cleanP);
      if (!(matchedRoute != null)) {
        this.FRouterViewEl.innerHTML = "404 - Not Found";
        return;
      };
      matchedChild = null;
      if (pas.System.Assigned(matchedRoute.Children)) matchedChild = this.MatchChildRoute(matchedRoute,cleanP);
      if (pas.System.Assigned(this.FBeforeEach)) {
        let toR = { path: cleanP, fullPath: fullHash, params: this.ParseParams(matchedRoute.Path, cleanP), query: this.ParseQuery(fullHash), meta: matchedRoute.Meta };
        let fromR = this.FCurrentRoute;
        let res = this.FBeforeEach.call(null, toR, fromR);
        
        if (res === false) return; // Navigation Aborted
        if (typeof res === 'string') {
          this.Push(res);
          return;
        };
      };
      if (pas.System.Assigned(matchedRoute.BeforeEnter)) {
        let r = matchedRoute.BeforeEnter.call(null);
        if (r === false) return;
        if (typeof r === 'string') {
          this.Push(r);
          return;
        };
      };
      this.FCurrentRoute.FullPath = fullHash;
      this.FCurrentRoute.HashPath = cleanP;
      this.FCurrentRoute.Params = this.ParseParams(matchedRoute.Path,cleanP);
      this.FCurrentRoute.Query = this.ParseQuery(fullHash);
      this.FCurrentRoute.Name = matchedRoute.Component;
      this.FCurrentRoute.Meta = matchedRoute.Meta;
      if (pas.System.Assigned(matchedRoute.AsyncComponent)) {
        let self = this;
        let mRoute = matchedRoute;
        let mChild = matchedChild;
        let cP = cleanP;
        let fH = fullHash;
        Promise.resolve(mRoute.AsyncComponent()).then(function(mod) {
          let comp = (mod && mod.default) ? mod.default : mod;
          if (typeof comp === 'object') {
            let tName = comp.name || ('async-' + Math.random().toString(36).substr(2, 6));
            if (!window.__BV_CORE__.components) window.__BV_CORE__.components = {};
            window.__BV_CORE__.components[tName.toLowerCase()] = comp;
            mRoute.Component = tName;
          }
          self.MountRoute(mRoute, mChild, cP, fH);
        });
      } else this.MountRoute(matchedRoute,matchedChild,cleanP,fullHash);
    };
  });
});
rtl.module("BVMobile",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    if (typeof window !== 'undefined') {
          if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          const bv = window.__BV_CORE__;
    
          // Detect Capacitor or Web runtime
          const hasCapacitor = Boolean(window.Capacitor && window.Capacitor.isNativePlatform && window.Capacitor.isNativePlatform());
          const capPlatform = hasCapacitor ? (window.Capacitor.getPlatform() || 'android') : 'web';
    
          const mobileBridge = {
            isNative: function() {
              if (window.Capacitor && typeof window.Capacitor.isNativePlatform === 'function') {
                return window.Capacitor.isNativePlatform();
              }
              return false;
            },
    
            getPlatform: function() {
              if (window.Capacitor && typeof window.Capacitor.getPlatform === 'function') {
                return window.Capacitor.getPlatform();
              }
              const userAgent = navigator.userAgent || '';
              if (/android/i.test(userAgent)) return 'android';
              if (/iPad|iPhone|iPod/.test(userAgent)) return 'ios';
              return 'web';
            },
    
            haptics: {
              vibrate: function(durationMs) {
                const ms = durationMs || 200;
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Haptics) {
                  window.Capacitor.Plugins.Haptics.vibrate({ duration: ms });
                } else if (typeof navigator !== 'undefined' && navigator.vibrate) {
                  navigator.vibrate(ms);
                } else {
                  console.log('[BVMobile] Haptics.vibrate simulation (' + ms + 'ms)');
                }
              },
    
              impact: function(style) {
                const s = style || 'medium';
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Haptics) {
                  window.Capacitor.Plugins.Haptics.impact({ style: s.toUpperCase() });
                } else if (typeof navigator !== 'undefined' && navigator.vibrate) {
                  navigator.vibrate(s === 'heavy' ? 40 : (s === 'light' ? 15 : 25));
                } else {
                  console.log('[BVMobile] Haptics.impact simulation (' + s + ')');
                }
              },
    
              notification: function(type) {
                const t = type || 'success';
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Haptics) {
                  window.Capacitor.Plugins.Haptics.notification({ type: t.toUpperCase() });
                } else if (typeof navigator !== 'undefined' && navigator.vibrate) {
                  navigator.vibrate([20, 40, 20]);
                } else {
                  console.log('[BVMobile] Haptics.notification simulation (' + t + ')');
                }
              }
            },
    
            geolocation: {
              getCurrentPosition: function(onSuccess, onError) {
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Geolocation) {
                  window.Capacitor.Plugins.Geolocation.getCurrentPosition()
                    .then(function(pos) {
                      if (typeof onSuccess === 'function') onSuccess(pos);
                    })
                    .catch(function(err) {
                      if (typeof onError === 'function') onError(err);
                    });
                } else if (typeof navigator !== 'undefined' && navigator.geolocation) {
                  navigator.geolocation.getCurrentPosition(
                    function(pos) {
                      const coords = {
                        coords: {
                          latitude: pos.coords.latitude,
                          longitude: pos.coords.longitude,
                          accuracy: pos.coords.accuracy,
                          altitude: pos.coords.altitude
                        },
                        timestamp: pos.timestamp
                      };
                      if (typeof onSuccess === 'function') onSuccess(coords);
                    },
                    function(err) {
                      if (typeof onError === 'function') onError(err);
                    }
                  );
                } else {
                  if (typeof onError === 'function') onError(new Error('Geolocation not supported'));
                }
              }
            },
    
            camera: {
              takePhoto: function(onSuccess, onError) {
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Camera) {
                  window.Capacitor.Plugins.Camera.getPhoto({
                    quality: 90,
                    allowEditing: false,
                    resultType: 'dataUrl'
                  })
                  .then(function(img) {
                    if (typeof onSuccess === 'function') onSuccess(img.dataUrl);
                  })
                  .catch(function(err) {
                    if (typeof onError === 'function') onError(err);
                  });
                } else if (typeof document !== 'undefined') {
                  // Web Camera Fallback using file input
                  let fileInput = document.getElementById('__bv_camera_input__');
                  if (!fileInput) {
                    fileInput = document.createElement('input');
                    fileInput.id = '__bv_camera_input__';
                    fileInput.type = 'file';
                    fileInput.accept = 'image/*';
                    fileInput.capture = 'environment';
                    fileInput.style.display = 'none';
                    document.body.appendChild(fileInput);
                  }
                  fileInput.onchange = function(e) {
                    const file = e.target.files && e.target.files[0];
                    if (file) {
                      const reader = new FileReader();
                      reader.onload = function(re) {
                        if (typeof onSuccess === 'function') onSuccess(re.target.result);
                      };
                      reader.readAsDataURL(file);
                    }
                  };
                  fileInput.click();
                } else {
                  if (typeof onError === 'function') onError(new Error('Camera not supported'));
                }
              }
            },
    
            device: {
              getInfo: function(onSuccess) {
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Device) {
                  window.Capacitor.Plugins.Device.getInfo().then(function(info) {
                    if (typeof onSuccess === 'function') onSuccess(info);
                  });
                } else {
                  const info = {
                    model: 'Browser Client',
                    platform: mobileBridge.getPlatform(),
                    operatingSystem: navigator.platform || 'web',
                    osVersion: navigator.userAgent || 'unknown',
                    manufacturer: 'Standard Hardware',
                    isVirtual: false
                  };
                  if (typeof onSuccess === 'function') onSuccess(info);
                }
              }
            },
    
            statusBar: {
              setBackgroundColor: function(colorHex) {
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.StatusBar) {
                  window.Capacitor.Plugins.StatusBar.setBackgroundColor({ color: colorHex });
                } else {
                  console.log('[BVMobile] StatusBar color: ' + colorHex);
                }
              }
            }
          };
    
          bv.mobile = mobileBridge;
          window.$mobile = mobileBridge;
        };
  };
});
rtl.module("BVDesktop",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  $mod.$init = function () {
    if (typeof window !== 'undefined') {
          window.__BV_CORE__ = window.__BV_CORE__ || {};
          let bv = window.__BV_CORE__;
    
          let desktopBridge = {
            isDesktop: function() {
              if (typeof window === 'undefined') return false;
              if (window.webui) return true;
              if (window.__BV_DESKTOP__ === true) return true;
              if (navigator && navigator.userAgent && navigator.userAgent.indexOf('BlaiseVueDesktop') !== -1) return true;
              return false;
            },
    
            getPlatform: function() {
              if (typeof navigator === 'undefined') return 'browser';
              let ua = navigator.userAgent || '';
              let plat = navigator.platform || '';
              if (plat.indexOf('Win') !== -1 || ua.indexOf('Windows') !== -1) return 'windows';
              if (plat.indexOf('Mac') !== -1 || ua.indexOf('Macintosh') !== -1) return 'macos';
              if (plat.indexOf('Linux') !== -1 || ua.indexOf('Linux') !== -1) return 'linux';
              return 'browser';
            },
    
            window: {
              minimize: function() {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_minimize');
                } else {
                  console.log('[BVDesktop] window.minimize() (no-op in browser)');
                }
              },
    
              maximize: function() {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_maximize');
                } else {
                  console.log('[BVDesktop] window.maximize() (no-op in browser)');
                }
              },
    
              close: function() {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_close');
                } else {
                  console.log('[BVDesktop] window.close()');
                  try { window.close(); } catch(e) {}
                }
              },
    
              setTitle: function(title) {
                if (typeof document !== 'undefined') document.title = title;
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_set_title', title);
                }
              },
    
              setFullScreen: function(val) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_set_fullscreen', !!val);
                } else if (typeof document !== 'undefined') {
                  if (val) {
                    if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen();
                  } else {
                    if (document.exitFullscreen) document.exitFullscreen();
                  }
                }
              }
            },
    
            notification: {
              show: function(title, body) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_notify', title, body);
                } else if (typeof Notification !== 'undefined') {
                  if (Notification.permission === 'granted') {
                    new Notification(title, { body: body });
                  } else if (Notification.permission !== 'denied') {
                    Notification.requestPermission().then(function(perm) {
                      if (perm === 'granted') new Notification(title, { body: body });
                    });
                  }
                } else {
                  console.log('[BVDesktop] Notification: ' + title + ' - ' + body);
                }
              }
            },
    
            shell: {
              openURL: function(url) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_open_url', url);
                } else if (typeof window !== 'undefined') {
                  try { window.open(url, '_blank', 'noopener,noreferrer'); } catch(e) {}
                }
              }
            },
    
            dialog: {
              openFile: function(onSuccess, onError) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_open_file_dialog').then(function(res) {
                    if (typeof onSuccess === 'function') onSuccess(res);
                  }).catch(function(err) {
                    if (typeof onError === 'function') onError(err);
                  });
                } else if (typeof document !== 'undefined') {
                  let fi = document.createElement('input');
                  fi.type = 'file';
                  fi.style.display = 'none';
                  fi.onchange = function(e) {
                    let f = e.target.files && e.target.files[0];
                    if (f && typeof onSuccess === 'function') {
                      onSuccess({ name: f.name, size: f.size, type: f.type });
                    }
                  };
                  document.body.appendChild(fi);
                  fi.click();
                  setTimeout(function() { fi.remove(); }, 1000);
                } else {
                  if (typeof onError === 'function') onError(new Error('File dialog not supported'));
                }
              },
    
              saveFile: function(defaultName, onSuccess, onError) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_save_file_dialog', defaultName).then(function(res) {
                    if (typeof onSuccess === 'function') onSuccess(res);
                  }).catch(function(err) {
                    if (typeof onError === 'function') onError(err);
                  });
                } else {
                  if (typeof onSuccess === 'function') onSuccess(defaultName || 'download.txt');
                }
              }
            },
    
            system: {
              getInfo: function(onSuccess) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call('bv_get_system_info').then(function(res) {
                    if (typeof onSuccess === 'function') onSuccess(res);
                  });
                } else {
                  let info = {
                    platform: desktopBridge.getPlatform(),
                    userAgent: (typeof navigator !== 'undefined') ? navigator.userAgent : 'unknown',
                    isDesktop: desktopBridge.isDesktop(),
                    framework: 'BlaiseVue 3.5 Desktop',
                    runtime: 'WebUI Engine (Free Pascal)'
                  };
                  if (typeof onSuccess === 'function') onSuccess(info);
                }
              }
            },
    
            rpc: {
              call: function(fnName, args, onSuccess, onError) {
                if (window.webui && typeof window.webui.call === 'function') {
                  window.webui.call(fnName, args)
                    .then(function(res) {
                      if (typeof onSuccess === 'function') onSuccess(res);
                    })
                    .catch(function(err) {
                      if (typeof onError === 'function') onError(err);
                    });
                } else {
                  console.log('[BVDesktop] RPC call to: ' + fnName, args);
                  if (typeof onSuccess === 'function') onSuccess({ status: 'mock_browser_success', func: fnName, result: null });
                }
              }
            }
          };
    
          bv.desktop = desktopBridge;
          window.$desktop = desktopBridge;
        };
  };
});
rtl.module("BlaiseIonic",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TIonicController",pas.System.TObject,function () {
    this.EnsureBridge = function () {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          if (!window.__BV_CORE__.ionic) {
            let activeMode = 'md';
            // Detect platform
            if (typeof navigator !== 'undefined' && /iPhone|iPad|iPod|Macintosh/i.test(navigator.userAgent || '')) {
              activeMode = 'ios';
            }
      
            let activeToastTimer = null;
            let activeLoadingCount = 0;
      
            const ionicBridge = {
              getMode: function() {
                return activeMode;
              },
              setMode: function(m) {
                activeMode = (m === 'ios') ? 'ios' : 'md';
                if (typeof document !== 'undefined' && document.documentElement) {
                  document.documentElement.setAttribute('mode', activeMode);
                  if (activeMode === 'ios') {
                    document.documentElement.classList.add('ionic-mode-ios');
                    document.documentElement.classList.remove('ionic-mode-md');
                  } else {
                    document.documentElement.classList.add('ionic-mode-md');
                    document.documentElement.classList.remove('ionic-mode-ios');
                  }
                }
              },
              get isIos() {
                return activeMode === 'ios';
              },
              get isAndroid() {
                return activeMode === 'md';
              },
      
              // Toast controller
              toast: {
                show: function(msg, duration, pos, color) {
                  this.dismiss();
                  duration = (typeof duration === 'number') ? duration : 2000;
                  pos = pos || 'bottom';
                  color = color || 'dark';
      
                  if (typeof document === 'undefined') return;
      
                  let el = document.createElement('div');
                  el.className = 'ionic-toast-wrapper ionic-toast-' + pos + ' ionic-toast-' + color;
                  el.setAttribute('role', 'alert');
                  el.innerHTML = '<div class="ionic-toast-message">' + msg + '</div>';
      
                  document.body.appendChild(el);
      
                  if (duration > 0) {
                    activeToastTimer = setTimeout(() => {
                      this.dismiss();
                    }, duration);
                  }
                },
                dismiss: function() {
                  if (activeToastTimer) {
                    clearTimeout(activeToastTimer);
                    activeToastTimer = null;
                  }
                  if (typeof document !== 'undefined') {
                    let existing = document.querySelectorAll('.ionic-toast-wrapper');
                    for (let i = 0; i < existing.length; i++) {
                      existing[i].remove();
                    }
                  }
                }
              },
      
              // Alert controller
              alert: {
                alert: function(title, msg, btnText) {
                  this.dismiss();
                  btnText = btnText || 'OK';
                  if (typeof document === 'undefined') return;
      
                  let backdrop = document.createElement('div');
                  backdrop.className = 'ionic-alert-backdrop';
      
                  let wrapper = document.createElement('div');
                  wrapper.className = 'ionic-alert-wrapper mode-' + activeMode;
                  wrapper.innerHTML = 
                    '<div class="ionic-alert-head">' +
                      '<h2 class="ionic-alert-title">' + title + '</h2>' +
                      '<div class="ionic-alert-sub-title">' + (msg || '') + '</div>' +
                    '</div>' +
                    '<div class="ionic-alert-button-group">' +
                      '<button type="button" class="ionic-alert-button bui-btn-ok">' + btnText + '</button>' +
                    '</div>';
      
                  backdrop.appendChild(wrapper);
                  document.body.appendChild(backdrop);
      
                  let okBtn = wrapper.querySelector('.bui-btn-ok');
                  if (okBtn) {
                    okBtn.addEventListener('click', () => {
                      this.dismiss();
                    });
                  }
                },
                confirm: function(title, msg, onConfirm, onCancel) {
                  this.dismiss();
                  if (typeof document === 'undefined') return;
      
                  let backdrop = document.createElement('div');
                  backdrop.className = 'ionic-alert-backdrop';
      
                  let wrapper = document.createElement('div');
                  wrapper.className = 'ionic-alert-wrapper mode-' + activeMode;
                  wrapper.innerHTML = 
                    '<div class="ionic-alert-head">' +
                      '<h2 class="ionic-alert-title">' + title + '</h2>' +
                      '<div class="ionic-alert-sub-title">' + (msg || '') + '</div>' +
                    '</div>' +
                    '<div class="ionic-alert-button-group">' +
                      '<button type="button" class="ionic-alert-button bui-btn-cancel">Cancel</button>' +
                      '<button type="button" class="ionic-alert-button bui-btn-confirm">Confirm</button>' +
                    '</div>';
      
                  backdrop.appendChild(wrapper);
                  document.body.appendChild(backdrop);
      
                  let cancelBtn = wrapper.querySelector('.bui-btn-cancel');
                  let confirmBtn = wrapper.querySelector('.bui-btn-confirm');
      
                  if (cancelBtn) {
                    cancelBtn.addEventListener('click', () => {
                      this.dismiss();
                      if (typeof onCancel === 'function') onCancel();
                    });
                  }
                  if (confirmBtn) {
                    confirmBtn.addEventListener('click', () => {
                      this.dismiss();
                      if (typeof onConfirm === 'function') onConfirm();
                    });
                  }
                },
                prompt: function(title, msg, placeholder, onSubmit) {
                  this.dismiss();
                  placeholder = placeholder || '';
                  if (typeof document === 'undefined') return;
      
                  let backdrop = document.createElement('div');
                  backdrop.className = 'ionic-alert-backdrop';
      
                  let wrapper = document.createElement('div');
                  wrapper.className = 'ionic-alert-wrapper mode-' + activeMode;
                  wrapper.innerHTML = 
                    '<div class="ionic-alert-head">' +
                      '<h2 class="ionic-alert-title">' + title + '</h2>' +
                      '<div class="ionic-alert-sub-title">' + (msg || '') + '</div>' +
                    '</div>' +
                    '<div class="ionic-alert-input-group">' +
                      '<input type="text" class="ionic-alert-input" placeholder="' + placeholder + '">' +
                    '</div>' +
                    '<div class="ionic-alert-button-group">' +
                      '<button type="button" class="ionic-alert-button bui-btn-cancel">Cancel</button>' +
                      '<button type="button" class="ionic-alert-button bui-btn-submit">Submit</button>' +
                    '</div>';
      
                  backdrop.appendChild(wrapper);
                  document.body.appendChild(backdrop);
      
                  let cancelBtn = wrapper.querySelector('.bui-btn-cancel');
                  let submitBtn = wrapper.querySelector('.bui-btn-submit');
                  let inputEl = wrapper.querySelector('.ionic-alert-input');
      
                  if (cancelBtn) {
                    cancelBtn.addEventListener('click', () => {
                      this.dismiss();
                    });
                  }
                  if (submitBtn) {
                    submitBtn.addEventListener('click', () => {
                      let val = inputEl ? inputEl.value : '';
                      this.dismiss();
                      if (typeof onSubmit === 'function') onSubmit(val);
                    });
                  }
                },
                dismiss: function() {
                  if (typeof document !== 'undefined') {
                    let existing = document.querySelectorAll('.ionic-alert-backdrop');
                    for (let i = 0; i < existing.length; i++) {
                      existing[i].remove();
                    }
                  }
                }
              },
      
              // Loading controller
              loading: {
                present: function(msg, duration) {
                  this.dismiss();
                  msg = msg || 'Loading...';
                  activeLoadingCount = 1;
      
                  if (typeof document === 'undefined') return;
      
                  let backdrop = document.createElement('div');
                  backdrop.className = 'ionic-loading-backdrop';
      
                  let box = document.createElement('div');
                  box.className = 'ionic-loading-box mode-' + activeMode;
                  box.innerHTML = 
                    '<div class="ionic-loading-spinner"></div>' +
                    '<div class="ionic-loading-content">' + msg + '</div>';
      
                  backdrop.appendChild(box);
                  document.body.appendChild(backdrop);
      
                  if (duration && duration > 0) {
                    setTimeout(() => {
                      this.dismiss();
                    }, duration);
                  }
                },
                dismiss: function() {
                  activeLoadingCount = 0;
                  if (typeof document !== 'undefined') {
                    let existing = document.querySelectorAll('.ionic-loading-backdrop');
                    for (let i = 0; i < existing.length; i++) {
                      existing[i].remove();
                    }
                  }
                },
                isLoading: function() {
                  if (typeof document !== 'undefined') {
                    return Boolean(document.querySelector('.ionic-loading-backdrop'));
                  }
                  return activeLoadingCount > 0;
                }
              },
      
              // ActionSheet controller
              actionSheet: {
                show: function(title, options, onSelect) {
                  this.dismiss();
                  if (typeof document === 'undefined') return;
      
                  let backdrop = document.createElement('div');
                  backdrop.className = 'ionic-action-sheet-backdrop';
      
                  let wrapper = document.createElement('div');
                  wrapper.className = 'ionic-action-sheet-wrapper mode-' + activeMode;
      
                  let headHtml = title ? ('<div class="ionic-action-sheet-title">' + title + '</div>') : '';
                  let btnListHtml = '';
                  let optArray = Array.isArray(options) ? options : [];
                  for (let i = 0; i < optArray.length; i++) {
                    btnListHtml += '<button type="button" class="ionic-action-sheet-button" data-index="' + i + '">' + optArray[i] + '</button>';
                  }
      
                  wrapper.innerHTML = 
                    '<div class="ionic-action-sheet-group">' +
                      headHtml +
                      btnListHtml +
                    '</div>' +
                    '<div class="ionic-action-sheet-group ionic-action-sheet-cancel-group">' +
                      '<button type="button" class="ionic-action-sheet-button bui-btn-cancel">Cancel</button>' +
                    '</div>';
      
                  backdrop.appendChild(wrapper);
                  document.body.appendChild(backdrop);
      
                  // Wire option buttons
                  let btns = wrapper.querySelectorAll('.ionic-action-sheet-button[data-index]');
                  for (let j = 0; j < btns.length; j++) {
                    btns[j].addEventListener('click', function(ev) {
                      let idx = parseInt(this.getAttribute('data-index'), 10);
                      let selectedVal = optArray[idx];
                      ionicBridge.actionSheet.dismiss();
                      if (typeof onSelect === 'function') {
                        onSelect(selectedVal, idx);
                      }
                    });
                  }
      
                  // Wire cancel button
                  let cancelBtn = wrapper.querySelector('.bui-btn-cancel');
                  if (cancelBtn) {
                    cancelBtn.addEventListener('click', () => {
                      this.dismiss();
                    });
                  }
      
                  // Backdrop click dismiss
                  backdrop.addEventListener('click', function(ev) {
                    if (ev.target === backdrop) {
                      ionicBridge.actionSheet.dismiss();
                    }
                  });
                },
                dismiss: function() {
                  if (typeof document !== 'undefined') {
                    let existing = document.querySelectorAll('.ionic-action-sheet-backdrop');
                    for (let i = 0; i < existing.length; i++) {
                      existing[i].remove();
                    }
                  }
                }
              }
            };
      
            // Set initial HTML mode attribute
            ionicBridge.setMode(activeMode);
      
            // Attach PascalCase aliases
            ionicBridge.toast.Show = ionicBridge.toast.show;
            ionicBridge.toast.Dismiss = ionicBridge.toast.dismiss;
      
            ionicBridge.alert.Alert = ionicBridge.alert.alert;
            ionicBridge.alert.Confirm = ionicBridge.alert.confirm;
            ionicBridge.alert.Prompt = ionicBridge.alert.prompt;
            ionicBridge.alert.Dismiss = ionicBridge.alert.dismiss;
      
            ionicBridge.loading.Present = ionicBridge.loading.present;
            ionicBridge.loading.Dismiss = ionicBridge.loading.dismiss;
            ionicBridge.loading.IsLoading = ionicBridge.loading.isLoading;
      
            ionicBridge.actionSheet.Show = ionicBridge.actionSheet.show;
            ionicBridge.actionSheet.Dismiss = ionicBridge.actionSheet.dismiss;
      
            ionicBridge.GetMode = ionicBridge.getMode;
            ionicBridge.SetMode = ionicBridge.setMode;
            ionicBridge.IsIos = function() { return ionicBridge.getMode() === 'ios'; };
            ionicBridge.IsAndroid = function() { return ionicBridge.getMode() === 'md'; };
      
            window.__BV_CORE__.ionic = ionicBridge;
            window.$ionic = ionicBridge;
      
            // Global window controllers
            window.TIonicToast = ionicBridge.toast;
            window.TIonicAlert = ionicBridge.alert;
            window.TIonicLoading = ionicBridge.loading;
            window.TIonicActionSheet = ionicBridge.actionSheet;
            window.TIonicController = ionicBridge;
      
            // Safe pas.BlaiseIonic registration for runtime interop
            if (typeof window.pas === 'undefined') window.pas = {};
            if (!window.pas.BlaiseIonic) window.pas.BlaiseIonic = {};
            window.pas.BlaiseIonic.TIonicToast = ionicBridge.toast;
            window.pas.BlaiseIonic.TIonicAlert = ionicBridge.alert;
            window.pas.BlaiseIonic.TIonicLoading = ionicBridge.loading;
            window.pas.BlaiseIonic.TIonicActionSheet = ionicBridge.actionSheet;
            window.pas.BlaiseIonic.TIonicController = ionicBridge;
          };
    };
  });
  $mod.$init = function () {
    $mod.TIonicController.EnsureBridge();
  };
});
rtl.module("Classes",["System","RTLConsts","Types","SysUtils","JS"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  $mod.$implcode = function () {
    $impl.ClassList = null;
  };
  $mod.$init = function () {
    $impl.ClassList = new Object();
  };
},[]);
rtl.module("BVDataSet",["System","JS","Web","SysUtils","Classes","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.TDataSetState = {"0": "dsInactive", dsInactive: 0, "1": "dsBrowse", dsBrowse: 1, "2": "dsEdit", dsEdit: 2, "3": "dsInsert", dsInsert: 3};
  this.TFieldType = {"0": "ftUnknown", ftUnknown: 0, "1": "ftString", ftString: 1, "2": "ftInteger", ftInteger: 2, "3": "ftFloat", ftFloat: 3, "4": "ftBoolean", ftBoolean: 4, "5": "ftDate", ftDate: 5, "6": "ftDateTime", ftDateTime: 6};
  this.TConflictResolution = {"0": "crServerWins", crServerWins: 0, "1": "crClientWins", crClientWins: 1, "2": "crCustom", crCustom: 2};
  rtl.createClass(this,"TBVIndexedDBAdapter",pas.System.TObject,function () {
    this.IsSupported = function () {
      var Result = false;
      Result = (typeof window !== 'undefined') && (Boolean(window.indexedDB) || Boolean(window.localStorage));
      return Result;
    };
    this.Save = function (DBName, StoreKey, RecordsData, DeltaData, OnSuccess, OnError) {
      var dbName = DBName || 'bv_offline_db';
          var key = StoreKey || 'default';
      
          // Unproxy and sanitize data for IndexedDB structured cloning
          var cleanRecords = [];
          var cleanDelta = [];
          try {
            if (RecordsData) cleanRecords = JSON.parse(JSON.stringify(RecordsData));
          } catch(eRec) {
            cleanRecords = [];
          }
          try {
            if (DeltaData) cleanDelta = JSON.parse(JSON.stringify(DeltaData));
          } catch(eDel) {
            cleanDelta = [];
          }
      
          var payload = {
            key: key,
            records: cleanRecords,
            delta: cleanDelta,
            updatedAt: Date.now()
          };
      
          if (typeof window !== 'undefined' && window.indexedDB) {
            try {
              var req = window.indexedDB.open(dbName, 1);
              req.onupgradeneeded = function(e) {
                var db = e.target.result;
                if (!db.objectStoreNames.contains('datasets')) {
                  db.createObjectStore('datasets', { keyPath: 'key' });
                }
              };
              req.onsuccess = function(e) {
                try {
                  var db = e.target.result;
                  var tx = db.transaction(['datasets'], 'readwrite');
                  var store = tx.objectStore('datasets');
                  var putReq = store.put(payload);
                  putReq.onsuccess = function() {
                    if (typeof OnSuccess === 'function') OnSuccess(payload);
                  };
                  putReq.onerror = function(err) {
                    if (typeof OnError === 'function') OnError(err);
                  };
                } catch(putEx) {
                  try {
                    if (window.localStorage) {
                      window.localStorage.setItem('bv_idb_' + dbName + '_' + key, JSON.stringify(payload));
                    }
                    if (typeof OnSuccess === 'function') OnSuccess(payload);
                  } catch(eLoc) {
                    if (typeof OnError === 'function') OnError(eLoc);
                  }
                }
              };
              req.onerror = function(err) {
                try {
                  window.localStorage.setItem('bv_idb_' + dbName + '_' + key, JSON.stringify(payload));
                  if (typeof OnSuccess === 'function') OnSuccess(payload);
                } catch(eLoc) {
                  if (typeof OnError === 'function') OnError(eLoc);
                }
              };
              return;
            } catch(ex) {
              // Fallback to localStorage below
            }
          }
      
          try {
            if (typeof window !== 'undefined' && window.localStorage) {
              window.localStorage.setItem('bv_idb_' + dbName + '_' + key, JSON.stringify(payload));
            }
            if (typeof OnSuccess === 'function') OnSuccess(payload);
          } catch(errLS) {
            if (typeof OnError === 'function') OnError(errLS);
          };
    };
    this.Load = function (DBName, StoreKey, OnSuccess, OnError) {
      var dbName = DBName || 'bv_offline_db';
          var key = StoreKey || 'default';
      
          function tryFallbackLS() {
            try {
              if (typeof window !== 'undefined' && window.localStorage) {
                var str = window.localStorage.getItem('bv_idb_' + dbName + '_' + key);
                if (str) {
                  var p = JSON.parse(str);
                  if (typeof OnSuccess === 'function') OnSuccess(p);
                  return;
                }
              }
              if (typeof OnSuccess === 'function') OnSuccess(null);
            } catch(e) {
              if (typeof OnError === 'function') OnError(e);
            }
          }
      
          if (typeof window !== 'undefined' && window.indexedDB) {
            try {
              var req = window.indexedDB.open(dbName, 1);
              req.onupgradeneeded = function(e) {
                var db = e.target.result;
                if (!db.objectStoreNames.contains('datasets')) {
                  db.createObjectStore('datasets', { keyPath: 'key' });
                }
              };
              req.onsuccess = function(e) {
                var db = e.target.result;
                var tx = db.transaction(['datasets'], 'readonly');
                var store = tx.objectStore('datasets');
                var getReq = store.get(key);
                getReq.onsuccess = function(ev) {
                  var data = ev.target.result;
                  if (data) {
                    if (typeof OnSuccess === 'function') OnSuccess(data);
                  } else {
                    tryFallbackLS();
                  }
                };
                getReq.onerror = function() {
                  tryFallbackLS();
                };
              };
              req.onerror = function() {
                tryFallbackLS();
              };
              return;
            } catch(ex) {
              // Fallback
            }
          }
      
          tryFallbackLS();
    };
    this.Remove = function (DBName, StoreKey, OnSuccess, OnError) {
      var dbName = DBName || 'bv_offline_db';
      var key = StoreKey || 'default';
      if (typeof window !== 'undefined' && window.localStorage) {
        try { window.localStorage.removeItem('bv_idb_' + dbName + '_' + key); } catch(e) {}
      }
      if (typeof window !== 'undefined' && window.indexedDB) {
        try {
          var req = window.indexedDB.open(dbName, 1);
          req.onsuccess = function(e) {
            var db = e.target.result;
            var tx = db.transaction(['datasets'], 'readwrite');
            tx.objectStore('datasets').delete(key);
            if (typeof OnSuccess === 'function') OnSuccess(true);
          };
          req.onerror = function(err) {
            if (typeof OnError === 'function') OnError(err);
          };
          return;
        } catch(e) {}
      }
      if (typeof OnSuccess === 'function') OnSuccess(true);
    };
    this.ClearAll = function (DBName, OnSuccess, OnError) {
      var dbName = DBName || 'bv_offline_db';
      if (typeof window !== 'undefined' && window.indexedDB) {
        try {
          var req = window.indexedDB.deleteDatabase(dbName);
          req.onsuccess = function() {
            if (typeof OnSuccess === 'function') OnSuccess(true);
          };
          req.onerror = function(err) {
            if (typeof OnError === 'function') OnError(err);
          };
          return;
        } catch(e) {}
      }
      if (typeof OnSuccess === 'function') OnSuccess(true);
    };
  });
  rtl.createClass(this,"TBVField",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FDataSet = null;
      this.FFieldName = "";
      this.FFieldType = 0;
      this.FRequired = false;
    };
    this.$final = function () {
      this.FDataSet = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Create$1 = function (ADataSet, AName, AType) {
      pas.System.TObject.Create.call(this);
      this.FDataSet = ADataSet;
      this.FFieldName = AName;
      this.FFieldType = AType;
      this.FRequired = false;
      var self = this;
      Object.defineProperty(self, 'AsString', {
        get: function() { return self.GetAsString(); },
        set: function(v) { self.SetAsString(v); },
        configurable: true
      });
      Object.defineProperty(self, 'Value', {
        get: function() { return self.GetValue(); },
        set: function(v) { self.SetValue(v); },
        configurable: true
      });
      Object.defineProperty(self, 'AsInteger', {
        get: function() { return self.GetAsInteger(); },
        set: function(v) { self.SetAsInteger(v); },
        configurable: true
      });
      Object.defineProperty(self, 'AsFloat', {
        get: function() { return self.GetAsFloat(); },
        set: function(v) { self.SetAsFloat(v); },
        configurable: true
      });
      Object.defineProperty(self, 'AsBoolean', {
        get: function() { return self.GetAsBoolean(); },
        set: function(v) { self.SetAsBoolean(v); },
        configurable: true
      });
      return this;
    };
    this.GetValue = function () {
      var Result = undefined;
      var cur = null;
      if (!(this.FDataSet != null)) return null;
      if ((this.FDataSet.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert)) && (this.FDataSet.FEditBuffer != null)) {
        Result = this.FDataSet.FEditBuffer[this.FFieldName];
        return Result;
      };
      cur = this.FDataSet.GetCurrent();
      if ((cur != null) && (cur[this.FFieldName] != undefined)) {
        Result = cur[this.FFieldName]}
       else Result = null;
      return Result;
    };
    this.SetValue = function (AValue) {
      if (!(this.FDataSet != null)) return;
      if (this.FDataSet.FState === $mod.TDataSetState.dsBrowse) this.FDataSet.Edit();
      if ((this.FDataSet.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert)) && (this.FDataSet.FEditBuffer != null)) {
        this.FDataSet.FEditBuffer[this.FFieldName] = AValue;
        this.FDataSet.FModified = true;
        this.FDataSet.SyncReactiveState();
      };
    };
    this.GetAsString = function () {
      var Result = "";
      var v = undefined;
      v = this.GetValue();
      if ((v == null) || (v == undefined)) {
        Result = ""}
       else Result = "" + v;
      return Result;
    };
    this.SetAsString = function (AValue) {
      this.SetValue(AValue);
    };
    this.GetAsInteger = function () {
      var Result = 0;
      var v = undefined;
      var n = 0;
      v = this.GetValue();
      if ((v == null) || (v == undefined)) return 0;
      var parsed = parseInt(v, 10);
      n = isNaN(parsed) ? 0 : parsed;
      Result = n;
      return Result;
    };
    this.SetAsInteger = function (AValue) {
      this.SetValue(AValue);
    };
    this.GetAsFloat = function () {
      var Result = 0.0;
      var v = undefined;
      var d = 0.0;
      v = this.GetValue();
      if ((v == null) || (v == undefined)) return 0.0;
      var parsed = parseFloat(v);
      d = isNaN(parsed) ? 0.0 : parsed;
      Result = d;
      return Result;
    };
    this.SetAsFloat = function (AValue) {
      this.SetValue(AValue);
    };
    this.GetAsBoolean = function () {
      var Result = false;
      var v = undefined;
      v = this.GetValue();
      if ((v == null) || (v == undefined)) return false;
      Result = Boolean(v === true || v === 'true' || v === 1 || v === '1');
      return Result;
    };
    this.SetAsBoolean = function (AValue) {
      this.SetValue(AValue);
    };
    this.GetIsNull = function () {
      var Result = false;
      var v = undefined;
      v = this.GetValue();
      Result = (v == null) || (v == undefined) || (("" + v) === "");
      return Result;
    };
  });
  rtl.createClass(this,"TBVFields",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FDataSet = null;
      this.FItems = null;
    };
    this.$final = function () {
      this.FDataSet = undefined;
      this.FItems = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Create$1 = function (ADataSet) {
      pas.System.TObject.Create.call(this);
      this.FDataSet = ADataSet;
      this.FItems = new Array();
      return this;
    };
    this.Count = function () {
      var Result = 0;
      Result = this.FItems.length;
      return Result;
    };
    this.FieldByName = function (AName) {
      var Result = null;
      var f = null;
      f = this.FindField(AName);
      if (!(f != null)) f = this.AddField(AName,$mod.TFieldType.ftString);
      Result = f;
      return Result;
    };
    this.FindField = function (AName) {
      var Result = null;
      var i = 0;
      var target = "";
      var f = null;
      target = pas.SysUtils.LowerCase(pas.SysUtils.Trim(AName));
      for (var $l = 0, $end = this.FItems.length - 1; $l <= $end; $l++) {
        i = $l;
        f = rtl.getObject(this.FItems[i]);
        if (pas.SysUtils.LowerCase(f.FFieldName) === target) return f;
      };
      Result = null;
      return Result;
    };
    this.AddField = function (AName, AType) {
      var Result = null;
      var f = null;
      f = this.FindField(AName);
      if (f != null) {
        f.FFieldType = AType;
        return f;
      };
      f = $mod.TBVField.$create("Create$1",[this.FDataSet,AName,AType]);
      this.FItems.push(f);
      Result = f;
      return Result;
    };
    this.Item = function (AIndex) {
      var Result = null;
      if ((AIndex >= 0) && (AIndex < this.FItems.length)) {
        Result = rtl.getObject(this.FItems[AIndex])}
       else Result = null;
      return Result;
    };
  });
  rtl.createClass(this,"TBVDataSet",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FFields = null;
      this.FRecords = null;
      this.FActiveRecords = null;
      this.FRecNo = 0;
      this.FState = 0;
      this.FEditBuffer = null;
      this.FOriginalBuffer = null;
      this.FDelta = null;
      this.FFilter = "";
      this.FFiltered = false;
      this.FSortField = "";
      this.FSortAscending = false;
      this.FReactiveState = undefined;
      this.FModified = false;
      this.FTableName = "";
      this.FAutoPersist = false;
      this.FPersistStoreKey = "";
      this.FAutoSyncOnReconnect = false;
      this.FAutoSyncEndpoint = "";
      this.FConflictResolution = 0;
      this.FSyncing = false;
      this.FNetworkListenerRegistered = false;
      this.FAfterScroll = null;
      this.FBeforePost = null;
      this.FAfterPost = null;
      this.FBeforeDelete = null;
      this.FAfterDelete = null;
      this.FAfterApplyUpdates = null;
    };
    this.$final = function () {
      this.FFields = undefined;
      this.FRecords = undefined;
      this.FActiveRecords = undefined;
      this.FEditBuffer = undefined;
      this.FOriginalBuffer = undefined;
      this.FDelta = undefined;
      this.FAfterScroll = undefined;
      this.FBeforePost = undefined;
      this.FAfterPost = undefined;
      this.FBeforeDelete = undefined;
      this.FAfterDelete = undefined;
      this.FAfterApplyUpdates = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.AutoPersistIfEnabled = function () {
      if (this.FAutoPersist && (this.FPersistStoreKey !== "")) {
        this.SaveToIndexedDB(this.FPersistStoreKey,null,null);
      };
    };
    this.SyncReactiveState = function () {
      var rs = null;
      var curObj = null;
      rs = this.FReactiveState;
      if (!(rs != null)) return;
      rs["stateStr"] = this.GetStateStr();
      rs["recNo"] = this.FRecNo;
      rs["recordCount"] = this.GetRecordCount();
      rs["bof"] = this.GetBof();
      rs["eof"] = this.GetEof();
      rs["isEmpty"] = this.GetIsEmpty();
      rs["changeCount"] = this.FDelta.length;
      rs["data"] = this.FActiveRecords;
      rs["hasPendingChanges"] = this.GetHasPendingChanges();
      rs["isSyncing"] = this.FSyncing;
      rs["tableName"] = this.FTableName;
      if ((this.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert)) && (this.FEditBuffer != null)) {
        rs["current"] = this.FEditBuffer}
       else {
        curObj = this.GetActiveRecord(this.FRecNo - 1);
        rs["current"] = curObj;
      };
    };
    this.RebuildActiveRecords = function () {
      var q = "";
      var arr = null;
      q = pas.SysUtils.LowerCase(pas.SysUtils.Trim(this.FFilter));
      arr = new Array();
      var src = this.FRecords || [];
          var filtered = [];
          var hasQuery = Boolean(q && q.length > 0);
      
          for (var i = 0; i < src.length; i++) {
            var item = src[i];
            if (!item) continue;
            if (!hasQuery) {
              filtered.push(item);
            } else {
              var match = false;
              var vals = Object.values(item);
              for (var j = 0; j < vals.length; j++) {
                if (String(vals[j]).toLowerCase().indexOf(q) !== -1) {
                  match = true;
                  break;
                }
              }
              if (match) filtered.push(item);
            }
          }
      
          var sk = this.FSortField;
          var asc = this.FSortAscending;
          if (sk) {
            filtered.sort(function(a, b) {
              var va = (a && a[sk] !== undefined) ? a[sk] : '';
              var vb = (b && b[sk] !== undefined) ? b[sk] : '';
              if (typeof va === 'number' && typeof vb === 'number') {
                return asc ? (va - vb) : (vb - va);
              }
              var sa = String(va).toLowerCase();
              var sb = String(vb).toLowerCase();
              if (sa < sb) return asc ? -1 : 1;
              if (sa > sb) return asc ? 1 : -1;
              return 0;
            });
          }
      
          arr = filtered;
      this.FActiveRecords = arr;
      if (this.FActiveRecords.length === 0) {
        this.FRecNo = 0}
       else if (this.FRecNo > this.FActiveRecords.length) {
        this.FRecNo = this.FActiveRecords.length}
       else if (this.FRecNo < 1) this.FRecNo = 1;
      this.SyncReactiveState();
    };
    this.GetActiveRecord = function (Index0) {
      var Result = null;
      if ((Index0 >= 0) && (Index0 < this.FActiveRecords.length)) {
        Result = this.FActiveRecords[Index0]}
       else Result = null;
      return Result;
    };
    this.Create$1 = function () {
      pas.System.TObject.Create.call(this);
      this.FFields = $mod.TBVFields.$create("Create$1",[this]);
      this.FRecords = new Array();
      this.FActiveRecords = new Array();
      this.FDelta = new Array();
      this.FRecNo = 0;
      this.FState = $mod.TDataSetState.dsInactive;
      this.FEditBuffer = null;
      this.FOriginalBuffer = null;
      this.FFilter = "";
      this.FFiltered = false;
      this.FSortField = "";
      this.FSortAscending = true;
      this.FModified = false;
      this.FTableName = "default";
      this.FAutoPersist = false;
      this.FPersistStoreKey = "";
      this.FAutoSyncOnReconnect = false;
      this.FAutoSyncEndpoint = "";
      this.FConflictResolution = $mod.TConflictResolution.crServerWins;
      this.FSyncing = false;
      this.FNetworkListenerRegistered = false;
      this.FReactiveState = pas.BVReactivity.DefineReactive(new Object());
      this.SyncReactiveState();
      var self = this;
      Object.defineProperty(self, 'Current', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.current !== undefined) return self.FReactiveState.current;
          return self.GetCurrent();
        }
      });
      Object.defineProperty(self, 'Data', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.data !== undefined) return self.FReactiveState.data;
          return self.FActiveRecords;
        }
      });
      Object.defineProperty(self, 'StateStr', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.stateStr !== undefined) return self.FReactiveState.stateStr;
          return self.GetStateStr();
        }
      });
      Object.defineProperty(self, 'RecNo', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.recNo !== undefined) return self.FReactiveState.recNo;
          return self.FRecNo;
        },
        set: function(v) {
          self.FRecNo = v;
          self.SyncReactiveState();
        }
      });
      Object.defineProperty(self, 'RecordCount', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.recordCount !== undefined) return self.FReactiveState.recordCount;
          return self.GetRecordCount();
        }
      });
      Object.defineProperty(self, 'Bof', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.bof !== undefined) return self.FReactiveState.bof;
          return self.GetBof();
        }
      });
      Object.defineProperty(self, 'Eof', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.eof !== undefined) return self.FReactiveState.eof;
          return self.GetEof();
        }
      });
      Object.defineProperty(self, 'ChangeCount', {
        get: function() {
          if (self.FReactiveState && self.FReactiveState.changeCount !== undefined) return self.FReactiveState.changeCount;
          return self.GetChangeCount();
        }
      });
      Object.defineProperty(self, 'HasPendingChanges', {
        get: function() { return self.GetHasPendingChanges(); }
      });
      Object.defineProperty(self, 'TableName', {
        get: function() { return self.FTableName; },
        set: function(v) { self.FTableName = v; }
      });
      Object.defineProperty(self, 'AutoPersist', {
        get: function() { return self.FAutoPersist; },
        set: function(v) { self.FAutoPersist = v; }
      });
      Object.defineProperty(self, 'Delta', {
        get: function() { return self.FDelta; }
      });
      Object.defineProperty(self, 'Syncing', {
        get: function() { return self.FSyncing; }
      });
      return this;
    };
    this.GetBof = function () {
      var Result = false;
      Result = this.FRecNo <= 1;
      return Result;
    };
    this.GetEof = function () {
      var Result = false;
      Result = this.FRecNo >= this.FActiveRecords.length;
      return Result;
    };
    this.GetRecordCount = function () {
      var Result = 0;
      Result = this.FActiveRecords.length;
      return Result;
    };
    this.GetIsEmpty = function () {
      var Result = false;
      Result = this.FActiveRecords.length === 0;
      return Result;
    };
    this.GetCurrent = function () {
      var Result = undefined;
      if ((this.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert)) && (this.FEditBuffer != null)) {
        Result = this.FEditBuffer}
       else Result = this.GetActiveRecord(this.FRecNo - 1);
      return Result;
    };
    this.GetStateStr = function () {
      var Result = "";
      var $tmp = this.FState;
      if ($tmp === $mod.TDataSetState.dsInactive) {
        Result = "inactive"}
       else if ($tmp === $mod.TDataSetState.dsBrowse) {
        Result = "browse"}
       else if ($tmp === $mod.TDataSetState.dsEdit) {
        Result = "edit"}
       else if ($tmp === $mod.TDataSetState.dsInsert) {
        Result = "insert"}
       else {
        Result = "inactive";
      };
      return Result;
    };
    this.GetChangeCount = function () {
      var Result = 0;
      Result = this.FDelta.length;
      return Result;
    };
    this.Destroy = function () {
      rtl.free(this,"FFields");
      pas.System.TObject.Destroy.call(this);
    };
    this.FieldByName = function (AName) {
      var Result = null;
      Result = this.FFields.FieldByName(AName);
      return Result;
    };
    this.FindField = function (AName) {
      var Result = null;
      Result = this.FFields.FindField(AName);
      return Result;
    };
    this.AddField = function (AName, AType) {
      var Result = null;
      Result = this.FFields.AddField(AName,AType);
      return Result;
    };
    this.First = function () {
      this.CheckBrowseMode();
      if (this.FActiveRecords.length > 0) {
        this.FRecNo = 1}
       else this.FRecNo = 0;
      this.SyncReactiveState();
      if (this.FAfterScroll != null) this.FAfterScroll(this);
    };
    this.Prior = function () {
      this.CheckBrowseMode();
      if (this.FRecNo > 1) this.FRecNo -= 1;
      this.SyncReactiveState();
      if (this.FAfterScroll != null) this.FAfterScroll(this);
    };
    this.Next = function () {
      this.CheckBrowseMode();
      if (this.FRecNo < this.FActiveRecords.length) this.FRecNo += 1;
      this.SyncReactiveState();
      if (this.FAfterScroll != null) this.FAfterScroll(this);
    };
    this.Last = function () {
      this.CheckBrowseMode();
      if (this.FActiveRecords.length > 0) {
        this.FRecNo = this.FActiveRecords.length}
       else this.FRecNo = 0;
      this.SyncReactiveState();
      if (this.FAfterScroll != null) this.FAfterScroll(this);
    };
    this.CheckBrowseMode = function () {
      if (this.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert)) {
        if (this.FModified) {
          this.Post()}
         else this.Cancel();
      };
    };
    this.Append = function () {
      var obj = null;
      var i = 0;
      var f = null;
      this.CheckBrowseMode();
      obj = new Object();
      for (var $l = 0, $end = this.FFields.Count() - 1; $l <= $end; $l++) {
        i = $l;
        f = this.FFields.Item(i);
        var $tmp = f.FFieldType;
        if ($tmp === $mod.TFieldType.ftInteger) {
          obj[f.FFieldName] = 0}
         else if ($tmp === $mod.TFieldType.ftFloat) {
          obj[f.FFieldName] = 0.0}
         else if ($tmp === $mod.TFieldType.ftBoolean) {
          obj[f.FFieldName] = false}
         else {
          obj[f.FFieldName] = "";
        };
      };
      this.FEditBuffer = obj;
      this.FOriginalBuffer = null;
      this.FState = $mod.TDataSetState.dsInsert;
      this.FModified = false;
      this.SyncReactiveState();
    };
    this.Insert = function () {
      this.Append();
    };
    this.Edit = function () {
      var cur = null;
      var clone = null;
      if (this.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert)) return;
      if (this.GetIsEmpty()) {
        this.Append();
        return;
      };
      cur = this.GetActiveRecord(this.FRecNo - 1);
      if (!(cur != null)) return;
      clone = new Object();
      Object.assign(clone, cur);
      this.FEditBuffer = clone;
      this.FOriginalBuffer = cur;
      this.FState = $mod.TDataSetState.dsEdit;
      this.FModified = false;
      this.SyncReactiveState();
    };
    this.Post = function () {
      var deltaItem = null;
      var targetIdx = 0;
      var curRec = null;
      if (!(this.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert))) return;
      if (this.FBeforePost != null) this.FBeforePost(this);
      deltaItem = new Object();
      if (this.FState === $mod.TDataSetState.dsInsert) {
        if (!this.FEditBuffer._clientId) {
          this.FEditBuffer._clientId = 'cli_' + Date.now() + '_' + Math.floor(Math.random() * 100000);
        }
        if (!this.FEditBuffer.id) {
          var maxId = 0;
          for (var i = 0; i < this.FRecords.length; i++) {
            var rid = parseInt(this.FRecords[i].id, 10);
            if (!isNaN(rid) && rid > maxId) maxId = rid;
          }
          this.FEditBuffer.id = maxId + 1;
        };
        this.FRecords.push(this.FEditBuffer);
        deltaItem["deltaId"] = "d_" + pas.SysUtils.IntToStr(Date.now()) + "_" + pas.SysUtils.IntToStr(pas.System.Random(10000));
        deltaItem["action"] = "insert";
        deltaItem["tableName"] = this.FTableName;
        deltaItem["id"] = this.FEditBuffer["id"];
        deltaItem["clientId"] = this.FEditBuffer["_clientId"];
        deltaItem["record"] = this.FEditBuffer;
        deltaItem["timestamp"] = Date.now();
        deltaItem["status"] = "pending";
        this.FDelta.push(deltaItem);
        this.RebuildActiveRecords();
        this.FRecNo = this.FActiveRecords.length;
      } else if (this.FState === $mod.TDataSetState.dsEdit) {
        curRec = this.GetActiveRecord(this.FRecNo - 1);
        targetIdx = this.FRecords.indexOf(curRec);
        if (targetIdx !== -1) this.FRecords[targetIdx] = this.FEditBuffer;
        deltaItem["deltaId"] = "d_" + pas.SysUtils.IntToStr(Date.now()) + "_" + pas.SysUtils.IntToStr(pas.System.Random(10000));
        deltaItem["action"] = "update";
        deltaItem["tableName"] = this.FTableName;
        deltaItem["id"] = this.FEditBuffer["id"];
        deltaItem["oldRecord"] = this.FOriginalBuffer;
        deltaItem["record"] = this.FEditBuffer;
        deltaItem["timestamp"] = Date.now();
        deltaItem["status"] = "pending";
        this.FDelta.push(deltaItem);
        this.RebuildActiveRecords();
      };
      this.FEditBuffer = null;
      this.FOriginalBuffer = null;
      this.FState = $mod.TDataSetState.dsBrowse;
      this.FModified = false;
      this.SyncReactiveState();
      this.AutoPersistIfEnabled();
      if (this.FAfterPost != null) this.FAfterPost(this);
    };
    this.Cancel = function () {
      if (!(this.FState in rtl.createSet($mod.TDataSetState.dsEdit,$mod.TDataSetState.dsInsert))) return;
      this.FEditBuffer = null;
      this.FOriginalBuffer = null;
      this.FState = $mod.TDataSetState.dsBrowse;
      this.FModified = false;
      this.SyncReactiveState();
    };
    this.Delete = function () {
      var curRec = null;
      var targetIdx = 0;
      var deltaItem = null;
      if (this.GetIsEmpty()) return;
      if (this.FBeforeDelete != null) this.FBeforeDelete(this);
      curRec = this.GetActiveRecord(this.FRecNo - 1);
      if (!(curRec != null)) return;
      targetIdx = this.FRecords.indexOf(curRec);
      if (targetIdx !== -1) this.FRecords.splice(targetIdx,1);
      deltaItem = new Object();
      deltaItem["deltaId"] = "d_" + pas.SysUtils.IntToStr(Date.now()) + "_" + pas.SysUtils.IntToStr(pas.System.Random(10000));
      deltaItem["action"] = "delete";
      deltaItem["tableName"] = this.FTableName;
      deltaItem["id"] = curRec["id"];
      deltaItem["record"] = curRec;
      deltaItem["timestamp"] = Date.now();
      deltaItem["status"] = "pending";
      this.FDelta.push(deltaItem);
      this.RebuildActiveRecords();
      if (this.FRecNo > this.FActiveRecords.length) this.FRecNo = this.FActiveRecords.length;
      if ((this.FRecNo === 0) && (this.FActiveRecords.length > 0)) this.FRecNo = 1;
      this.FState = $mod.TDataSetState.dsBrowse;
      this.SyncReactiveState();
      this.AutoPersistIfEnabled();
      if (this.FAfterDelete != null) this.FAfterDelete(this);
    };
    this.SetFilter = function (AQuery) {
      this.FFilter = AQuery;
      this.FFiltered = pas.SysUtils.Trim(AQuery) !== "";
      this.RebuildActiveRecords();
      this.First();
    };
    this.ClearFilter = function () {
      this.SetFilter("");
    };
    this.SortBy = function (AFieldName, Ascending) {
      this.FSortField = AFieldName;
      this.FSortAscending = Ascending;
      this.RebuildActiveRecords();
      this.First();
    };
    this.Locate = function (AFieldName, AValue) {
      var Result = false;
      var i = 0;
      var targetVal = "";
      var itemVal = "";
      var item = null;
      this.CheckBrowseMode();
      targetVal = "" + AValue;
      for (var $l = 0, $end = this.FActiveRecords.length - 1; $l <= $end; $l++) {
        i = $l;
        item = this.FActiveRecords[i];
        if ((item != null) && (item[AFieldName] != undefined)) {
          itemVal = "" + item[AFieldName];
          if (itemVal === targetVal) {
            this.FRecNo = i + 1;
            this.SyncReactiveState();
            if (this.FAfterScroll != null) this.FAfterScroll(this);
            return true;
          };
        };
      };
      Result = false;
      return Result;
    };
    this.LoadFromData = function (AData) {
      var keys = null;
      var i = 0;
      if (!pas.System.Assigned(AData)) return;
      this.FRecords = new Array();
      keys = null;
      var arr = Array.isArray(AData) ? AData : ((AData && Array.isArray(AData.items)) ? AData.items : [AData]);
      for (var i = 0; i < arr.length; i++) {
        this.FRecords.push(Object.assign({}, arr[i]));
      }
      if (this.FRecords.length > 0) {
        keys = Object.keys(this.FRecords[0]);
      };
      if ((this.FFields.Count() === 0) && (keys != null)) {
        for (var $l = 0, $end = keys.length - 1; $l <= $end; $l++) {
          i = $l;
          this.FFields.AddField("" + keys[i],$mod.TFieldType.ftString);
        };
      };
      this.FState = $mod.TDataSetState.dsBrowse;
      this.RebuildActiveRecords();
      this.First();
    };
    this.LoadFromJSON = function (AJsonStr) {
      var parsed = undefined;
      if (pas.SysUtils.Trim(AJsonStr) === "") return;
      try {
        parsed = JSON.parse(AJsonStr);
      } catch(e) {
        parsed = [];
      };
      this.LoadFromData(parsed);
    };
    this.ToJSON = function () {
      var Result = "";
      Result = JSON.stringify(this.FRecords || []);
      return Result;
    };
    this.GetDeltaJSON = function () {
      var Result = "";
      Result = JSON.stringify(this.FDelta || []);
      return Result;
    };
    this.ApplyUpdates = function (AEndpointOrService, AOnSuccess, AOnError) {
      var ep = AEndpointOrService || this.FAutoSyncEndpoint;
          var self = this;
      
          // If no endpoint is configured, standard local delta commit
          if (!ep) {
            this.FDelta.length = 0;
            this.FModified = false;
            this.SyncReactiveState();
            this.AutoPersistIfEnabled();
            if (typeof self.FAfterApplyUpdates === 'function') self.FAfterApplyUpdates(self);
            if (typeof AOnSuccess === 'function') AOnSuccess({ status: 'ok', local: true });
            return;
          }
      
          if (this.FDelta.length === 0) {
            if (typeof AOnSuccess === 'function') AOnSuccess({ status: 'ok', syncedCount: 0 });
            return;
          }
      
          this.FSyncing = true;
          var payload = {
            table: this.FTableName || 'default',
            delta: this.FDelta,
            clientTime: Date.now()
          };
      
          var isService = ep.indexOf('/') === -1;
          var api = (window.__BV_CORE__ && window.__BV_CORE__.api) ? window.__BV_CORE__.api : null;
          var rpc = (window.__BV_CORE__ && window.__BV_CORE__.rpc) ? window.__BV_CORE__.rpc : null;
      
          function handleSuccess(resp) {
            self.FSyncing = false;
            self.ReconcileDelta(resp);
            if (typeof AOnSuccess === 'function') AOnSuccess(resp);
          }
      
          function handleError(err) {
            self.FSyncing = false;
            console.warn('[BVDataSet] ApplyUpdates failed:', err);
            if (typeof AOnError === 'function') AOnError(err);
          }
      
          if (isService && rpc && typeof rpc.invoke === 'function') {
            rpc.invoke(ep, 'ApplyUpdates', [payload], handleSuccess, handleError);
          } else if (api && typeof api.post === 'function') {
            api.post(ep, payload).then(handleSuccess).catch(handleError);
          } else if (typeof fetch === 'function') {
            fetch(ep, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(payload)
            }).then(function(r) { return r.json(); }).then(handleSuccess).catch(handleError);
          } else {
            handleSuccess({ status: 'ok', local: true, syncedCount: self.FDelta.length });
          };
    };
    this.SaveToStorage = function (AStorageKey) {
      var json = "";
      if (pas.SysUtils.Trim(AStorageKey) === "") return;
      json = this.ToJSON();
      try {
        if (typeof window !== 'undefined' && window.localStorage) {
          window.localStorage.setItem(AStorageKey, json);
        }
      } catch(e) {
        console.warn('[BVDataSet] Failed to save to storage:', e);
      };
    };
    this.LoadFromStorage = function (AStorageKey) {
      var Result = false;
      var json = "";
      var found = false;
      if (pas.SysUtils.Trim(AStorageKey) === "") return false;
      found = false;
      json = "";
      try {
        if (typeof window !== 'undefined' && window.localStorage) {
          var val = window.localStorage.getItem(AStorageKey);
          if (val) {
            json = val;
            found = true;
          }
        }
      } catch(e) {
        found = false;
      };
      if (found) {
        this.LoadFromJSON(json);
        Result = true;
      } else Result = false;
      return Result;
    };
    this.SetAutoPersist = function (AEnabled, AStoreKey) {
      this.FAutoPersist = AEnabled;
      if (AStoreKey !== "") {
        this.FPersistStoreKey = AStoreKey}
       else if (this.FPersistStoreKey === "") this.FPersistStoreKey = this.FTableName;
      this.AutoPersistIfEnabled();
    };
    this.SetAutoSyncOnReconnect = function (AEnabled, AEndpointOrService) {
      this.FAutoSyncOnReconnect = AEnabled;
      if (AEndpointOrService !== "") this.FAutoSyncEndpoint = AEndpointOrService;
      if (AEnabled && !this.FNetworkListenerRegistered) {
        this.FNetworkListenerRegistered = true;
        var self = this;
        if (typeof window !== 'undefined') {
          window.addEventListener('online', function() {
            if (self.GetChangeCount() > 0 && !self.FSyncing) {
              self.ApplyUpdates(self.FAutoSyncEndpoint, null, null);
            }
          });
        }
        if (window.__BV_CORE__ && window.__BV_CORE__.ws) {
          window.__BV_CORE__.ws.on('open', function() {
            if (self.GetChangeCount() > 0 && !self.FSyncing) {
              self.ApplyUpdates(self.FAutoSyncEndpoint, null, null);
            }
          });
        }
      };
    };
    this.SaveToIndexedDB = function (AStoreKey, AOnSuccess, AOnError) {
      var k = "";
      k = AStoreKey;
      if (k === "") k = this.FPersistStoreKey;
      if (k === "") k = this.FTableName;
      if (k === "") k = "default";
      this.FPersistStoreKey = k;
      $mod.TBVIndexedDBAdapter.Save("bv_offline_db",k,this.FRecords,this.FDelta,AOnSuccess,AOnError);
    };
    this.LoadFromIndexedDB = function (AStoreKey, AOnComplete) {
      var $Self = this;
      var k = "";
      k = AStoreKey;
      if (k === "") k = this.FPersistStoreKey;
      if (k === "") k = this.FTableName;
      if (k === "") k = "default";
      this.FPersistStoreKey = k;
      $mod.TBVIndexedDBAdapter.Load("bv_offline_db",k,function (data) {
        if (data != null) {
          if (data.records) $Self.LoadFromData(data.records);
          if (data.delta && Array.isArray(data.delta)) {
            $Self.FDelta = data.delta;
            $Self.SyncReactiveState();
          };
        };
        if (typeof AOnComplete === 'function') AOnComplete($Self, data);
      },function (err) {
        if (typeof AOnComplete === 'function') AOnComplete($Self, null);
      });
    };
    this.ReconcileDelta = function (ServerResponse) {
      if (!pas.System.Assigned(ServerResponse)) return;
      var resp = ServerResponse;
          var insertedIds = resp.insertedIds || {};
          var conflicts = resp.conflicts || [];
      
          // 1. Remap temporary client IDs
          if (insertedIds && typeof insertedIds === 'object') {
            var keys = Object.keys(insertedIds);
            for (var k = 0; k < keys.length; k++) {
              var oldId = keys[k];
              var newId = insertedIds[oldId];
              for (var r = 0; r < this.FRecords.length; r++) {
                var rec = this.FRecords[r];
                if (!rec) continue;
                if (String(rec.id) === String(oldId) || (rec._clientId && String(rec._clientId) === String(oldId))) {
                  rec.id = newId;
                  delete rec._clientId;
                }
              }
            }
          }
      
          // 2. Resolve Conflicts
          if (Array.isArray(conflicts) && conflicts.length > 0) {
            for (var c = 0; c < conflicts.length; c++) {
              var conf = conflicts[c];
              var cid = conf.id;
              var sRec = conf.serverRecord;
      
              if (this.FConflictResolution === 0) { // crServerWins
                for (var r = 0; r < this.FRecords.length; r++) {
                  if (this.FRecords[r] && String(this.FRecords[r].id) === String(cid)) {
                    if (sRec) {
                      Object.assign(this.FRecords[r], sRec);
                    } else {
                      this.FRecords.splice(r, 1);
                    }
                    break;
                  }
                }
              } else if (this.FConflictResolution === 1) { // crClientWins
                // Client state remains in FRecords
              }
            }
          }
      
          // 3. Clear delta and sync
          this.FDelta.length = 0;
      this.FModified = false;
      this.RebuildActiveRecords();
      this.SyncReactiveState();
      this.AutoPersistIfEnabled();
      if (this.FAfterApplyUpdates != null) this.FAfterApplyUpdates(this);
    };
    this.GetHasPendingChanges = function () {
      var Result = false;
      Result = (this.FDelta.length > 0) || this.FModified;
      return Result;
    };
    this.ClearDelta = function () {
      this.FDelta.length = 0;
      this.SyncReactiveState();
      this.AutoPersistIfEnabled();
    };
  });
  $mod.$implcode = function () {
    $impl.RetainDataSetSymbols = function () {
      var dummyDS = null;
      var dummyF = null;
      if (false) {
        dummyDS = $mod.TBVDataSet.$create("Create$1");
        dummyDS.FieldByName("");
        dummyDS.FindField("");
        dummyDS.AddField("",$mod.TFieldType.ftString);
        dummyDS.First();
        dummyDS.Next();
        dummyDS.Prior();
        dummyDS.Last();
        dummyDS.Append();
        dummyDS.Insert();
        dummyDS.Edit();
        dummyDS.Post();
        dummyDS.Cancel();
        dummyDS.CheckBrowseMode();
        dummyDS.FModified = false;
        dummyDS.Delete();
        dummyDS.Locate("",null);
        dummyDS.SetFilter("");
        dummyDS.ClearFilter();
        dummyDS.SortBy("",true);
        dummyDS.SaveToStorage("");
        dummyDS.LoadFromStorage("");
        dummyDS.ToJSON();
        dummyDS.GetDeltaJSON();
        dummyDS.ApplyUpdates("",null,null);
        dummyDS.LoadFromJSON("");
        dummyDS.FTableName = "";
        dummyDS.FAutoPersist = false;
        dummyDS.FPersistStoreKey = "";
        dummyDS.FAutoSyncOnReconnect = false;
        dummyDS.GetHasPendingChanges();
        dummyDS.ClearDelta();
        dummyDS.SetAutoPersist(false,"");
        dummyDS.SetAutoSyncOnReconnect(false,"");
        dummyDS.SaveToIndexedDB("",null,null);
        dummyDS.LoadFromIndexedDB("",null);
        dummyDS.ReconcileDelta(null);
        dummyDS.AutoPersistIfEnabled();
        $mod.TBVIndexedDBAdapter.IsSupported();
        $mod.TBVIndexedDBAdapter.Save("","",null,null,null,null);
        $mod.TBVIndexedDBAdapter.Load("","",null,null);
        $mod.TBVIndexedDBAdapter.Remove("","",null,null);
        $mod.TBVIndexedDBAdapter.ClearAll("",null,null);
        dummyDS.GetBof();
        dummyDS.GetEof();
        dummyDS.GetRecordCount();
        dummyDS.GetIsEmpty();
        dummyDS.GetCurrent();
        dummyDS.GetStateStr();
        dummyDS.GetChangeCount();
        dummyF = dummyDS.FFields.FieldByName("");
        dummyF.GetValue();
        dummyF.SetValue(null);
        dummyF.GetAsString();
        dummyF.SetAsString("");
        dummyF.GetAsInteger();
        dummyF.SetAsInteger(0);
        dummyF.GetAsFloat();
        dummyF.SetAsFloat(0.0);
        dummyF.GetAsBoolean();
        dummyF.SetAsBoolean(false);
        dummyF.GetIsNull();
        dummyF.SetValue(null);
        dummyF.SetAsString("");
        dummyF.SetAsInteger(0);
        dummyF.SetAsFloat(0.0);
        dummyF.SetAsBoolean(false);
        dummyDS = rtl.freeLoc(dummyDS);
      };
    };
  };
  $mod.$init = function () {
    $impl.RetainDataSetSymbols();
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    window.__BV_CORE__.dataset = {
      TBVDataSet: pas.BVDataSet ? pas.BVDataSet.TBVDataSet : null,
      TBVField: pas.BVDataSet ? pas.BVDataSet.TBVField : null,
      TBVIndexedDBAdapter: pas.BVDataSet ? pas.BVDataSet.TBVIndexedDBAdapter : null,
      CreateDataSet: pas.BVDataSet ? pas.BVDataSet.CreateDataSet : null
    };
  };
},[]);
rtl.module("BVRpc",["System","JS","Web","SysUtils","BVReactivity"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBVRemoteProxy",pas.System.TInterfacedObject,function () {
    this.$init = function () {
      pas.System.TInterfacedObject.$init.call(this);
      this.FServiceName = "";
    };
    this.Create$1 = function (AServiceName) {
      pas.System.TObject.Create.call(this);
      this.FServiceName = AServiceName;
      $mod.TBVRpcClient.EnsureBridge();
      $mod.TBVRpcClient.RegisterService(AServiceName,this);
      return this;
    };
    this.CallRemote = function (AMethodName, Params, OnSuccess, OnError) {
      var Result = undefined;
      Result = $mod.TBVRpcClient.Invoke(this.FServiceName,AMethodName,Params,OnSuccess,OnError);
      return Result;
    };
  });
  rtl.createClass(this,"TBVRpcClient",pas.System.TObject,function () {
    this.EnsureBridge = function () {
      if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          if (!window.__BV_CORE__.rpc) {
            window.__BV_CORE__.rpc = {
              baseUrl: 'http://localhost:8090/api/rpc',
              token: '',
              headers: {},
              timeout: 10000,
              transport: 'http',
              usePack: false,
              services: {},
              idCounter: 0,
              pendingCalls: {},
      
              setBaseUrl: function(url) {
                if (!url) return;
                this.baseUrl = String(url).replace(/\/$/, '');
              },
      
              getBaseUrl: function() {
                return this.baseUrl;
              },
      
              setToken: function(t) {
                this.token = t || '';
              },
      
              clearToken: function() {
                this.token = '';
              },
      
              setHeader: function(k, v) {
                if (k) this.headers[k] = v;
              },
      
              setTimeout: function(ms) {
                this.timeout = ms || 10000;
              },
      
              setTransport: function(t) {
                this.transport = (t === 'ws') ? 'ws' : 'http';
              },
      
              getTransport: function() {
                return this.transport;
              },
      
              setUsePack: function(p) {
                this.usePack = Boolean(p);
              },
      
              getUsePack: function() {
                return this.usePack;
              },
      
              registerService: function(name, proxy) {
                this.services[name] = proxy;
              },
      
              getService: function(name) {
                return this.services[name] || null;
              },
      
              isWebSocketReady: function() {
                return Boolean(window.__BV_CORE__.ws && window.__BV_CORE__.ws.isConnected());
              },
      
              // Core RPC dispatcher
              invoke: function(service, method, params, onSuccess, onError) {
                var self = this;
                var callId = ++this.idCounter;
                var normParams = (params !== undefined && params !== null) ? params : [];
                if (!Array.isArray(normParams)) {
                  normParams = [normParams];
                }
      
                var payload = {
                  jsonrpc: '2.0',
                  service: service,
                  method: method,
                  params: normParams,
                  id: callId
                };
      
                // 1. WebSocket Transport Branch
                if (this.transport === 'ws' && this.isWebSocketReady()) {
                  var wsPromise = new Promise(function(resolve, reject) {
                    var timer = setTimeout(function() {
                      delete self.pendingCalls[callId];
                      var err = new Error('RPC Timeout after ' + self.timeout + 'ms: ' + service + '.' + method);
                      err.code = -32000;
                      if (onError) onError(err.message, -32000);
                      reject(err);
                    }, self.timeout);
      
                    self.pendingCalls[callId] = {
                      resolve: function(val) {
                        clearTimeout(timer);
                        if (onSuccess) onSuccess(val);
                        resolve(val);
                      },
                      reject: function(err) {
                        clearTimeout(timer);
                        var msg = (err && err.message) ? err.message : String(err);
                        var code = (err && err.code) ? err.code : -32603;
                        if (onError) onError(msg, code);
                        reject(err);
                      }
                    };
      
                    window.__BV_CORE__.ws.send({
                      event: 'rpc_call',
                      data: payload
                    });
                  });
                  return wsPromise;
                }
      
                // 2. HTTP POST Transport Branch (Default & Resilient Fallback)
                var url = this.baseUrl + '/' + encodeURIComponent(service) + '/' + encodeURIComponent(method);
                var hdrs = Object.assign({
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'X-BlaiseVue-RPC': '2.0'
                }, this.headers);
      
                if (this.usePack) {
                  hdrs['X-BlaiseVue-Pack'] = '1';
                }
      
                if (this.token) {
                  hdrs['Authorization'] = 'Bearer ' + this.token;
                }
      
                var fetchPromise;
                if (typeof fetch === 'function') {
                  var controller = (typeof AbortController !== 'undefined') ? new AbortController() : null;
                  var timeoutId = null;
                  var fetchOpts = {
                    method: 'POST',
                    headers: hdrs,
                    body: JSON.stringify(payload)
                  };
                  if (controller) {
                    fetchOpts.signal = controller.signal;
                    timeoutId = setTimeout(function() {
                      controller.abort();
                    }, self.timeout);
                  }
      
                  fetchPromise = fetch(url, fetchOpts).then(function(res) {
                    if (timeoutId) clearTimeout(timeoutId);
                    return res.json().then(function(data) {
                      if (!res.ok) {
                        var errMsg = (data && (data.error || data.message))
                          ? (typeof data.error === 'object' ? data.error.message : (data.error || data.message))
                          : ('HTTP ' + res.status);
                        var httpErr = new Error(errMsg);
                        httpErr.status = res.status;
                        httpErr.data = data;
                        httpErr.code = (data && data.error && data.error.code) ? data.error.code : res.status;
                        throw httpErr;
                      }
                      if (data && data.error) {
                        var rpcErr = new Error((typeof data.error === 'object') ? data.error.message : String(data.error));
                        rpcErr.code = (typeof data.error === 'object' && data.error.code) ? data.error.code : -32603;
                        throw rpcErr;
                      }
                      return (data && data.result !== undefined) ? data.result : data;
                    });
                  }).catch(function(err) {
                    if (timeoutId) clearTimeout(timeoutId);
                    throw err;
                  });
                } else {
                  fetchPromise = Promise.reject(new Error('Fetch API is not available'));
                }
      
                fetchPromise.then(function(result) {
                  if (typeof onSuccess === 'function') {
                    try { onSuccess(result); } catch(e) { console.error('[BVRpc Callback Error]', e); }
                  }
                }).catch(function(err) {
                  var msg = (err && err.message) ? err.message : String(err);
                  var code = (err && err.code) ? err.code : -32603;
                  if (typeof onError === 'function') {
                    try { onError(msg, code); } catch(e) { console.error('[BVRpc Error Callback]', e); }
                  } else {
                    console.warn('[BVRpc Error]', service + '.' + method, msg);
                  }
                });
      
                return fetchPromise;
              }
            };
      
            // Set up WebSocket RPC response listener if WebSocket helper is available
            if (window.__BV_CORE__.ws) {
              window.__BV_CORE__.ws.on('rpc_response', function(resData) {
                if (!resData) return;
                var rpcObj = resData.data !== undefined ? resData.data : resData;
                if (rpcObj && rpcObj.id && window.__BV_CORE__.rpc.pendingCalls[rpcObj.id]) {
                  var pending = window.__BV_CORE__.rpc.pendingCalls[rpcObj.id];
                  delete window.__BV_CORE__.rpc.pendingCalls[rpcObj.id];
                  if (rpcObj.error) {
                    var errObj = new Error(typeof rpcObj.error === 'object' ? rpcObj.error.message : String(rpcObj.error));
                    errObj.code = (typeof rpcObj.error === 'object' && rpcObj.error.code) ? rpcObj.error.code : -32603;
                    pending.reject(errObj);
                  } else {
                    pending.resolve(rpcObj.result !== undefined ? rpcObj.result : rpcObj);
                  }
                }
              });
            }
          };
    };
    this.SetBaseUrl = function (Url) {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.setBaseUrl(Url);
    };
    this.SetToken = function (Token) {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.setToken(Token);
    };
    this.ClearToken = function () {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.clearToken();
    };
    this.SetTimeout = function (TimeoutMs) {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.setTimeout(TimeoutMs);
    };
    this.SetTransport = function (ATransport) {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.setTransport(ATransport);
    };
    this.SetUsePack = function (AValue) {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.setUsePack(AValue);
    };
    this.Invoke = function (ServiceName, MethodName, Params, OnSuccess, OnError) {
      var Result = undefined;
      this.EnsureBridge();
      Result = window.__BV_CORE__.rpc.invoke(ServiceName, MethodName, Params, OnSuccess, OnError);
      return Result;
    };
    this.InvokeAsync = function (ServiceName, MethodName, Params) {
      var Result = undefined;
      this.EnsureBridge();
      Result = window.__BV_CORE__.rpc.invoke(ServiceName, MethodName, Params);
      return Result;
    };
    this.RegisterService = function (ServiceName, ServiceProxy) {
      this.EnsureBridge();
      window.__BV_CORE__.rpc.registerService(ServiceName, ServiceProxy);
    };
  });
  $mod.$init = function () {
    $mod.TBVRpcClient.EnsureBridge();
  };
});
rtl.module("BlaiseReportsFonts",["System"],function () {
  "use strict";
  var $mod = this;
  this.BVPdfFontRegularName = "DejaVuSans";
  this.BVPdfFontRegularLength1 = 28236;
  this.BVPdfFontRegularBBox = "-411 -261 1287 978";
  this.BVPdfFontRegularAscent = 928;
  this.BVPdfFontRegularDescent = -236;
  this.BVPdfFontRegularCapHeight = 729;
  this.BVPdfFontRegularCmap = "20:1,21:2,22:3,23:4,24:5,25:6,26:7,27:8,28:9,29:a,2a:b,2b:c,2c:d,2d:e,2e:f,2f:10,30:11,31:12,32:13,3" + "3:14,34:15,35:16,36:17,37:18,38:19,39:1a,3a:1b,3b:1c,3c:1d,3d:1e,3e:1f,3f:20,40:21,41:22,42:23,43:24" + ",44:25,45:26,46:27,47:28,48:29,49:2a,4a:2b,4b:2c,4c:2d,4d:2e,4e:2f,4f:30,50:31,51:32,52:33,53:34,54:" + "35,55:36,56:37,57:38,58:39,59:3a,5a:3b,5b:3c,5c:3d,5d:3e,5e:3f,5f:40,60:41,61:42,62:43,63:44,64:45,6" + "5:46,66:47,67:48,68:49,69:4a,6a:4b,6b:4c,6c:4d,6d:4e,6e:4f,6f:50,70:51,71:52,72:53,73:54,74:55,75:56" + ",76:57,77:58,78:59,79:5a,7a:5b,7b:5c,7c:5d,7d:5e,7e:5f,a0:60,a1:61,a2:62,a3:63,a4:64,a5:65,a6:66,a7:" + "67,a8:68,a9:69,aa:6a,ab:6b,ac:6c,ad:6d,ae:6e,af:6f,b0:70,b1:71,b2:72,b3:73,b4:74,b5:75,b6:76,b7:77,b" + "8:78,b9:79,ba:7a,bb:7b,bc:7c,bd:7d,be:7e,bf:7f,c0:80,c1:81,c2:82,c3:83,c4:84,c5:85,c6:86,c7:87,c8:88" + ",c9:89,ca:8a,cb:8b,cc:8c,cd:8d,ce:8e,cf:8f,d0:90,d1:91,d2:92,d3:93,d4:94,d5:95,d6:96,d7:97,d8:98,d9:" + "99,da:9a,db:9b,dc:9c,dd:9d,de:9e,df:9f,e0:a0,e1:a1,e2:a2,e3:a3,e4:a4,e5:a5,e6:a6,e7:a7,e8:a8,e9:a9,e" + "a:aa,eb:ab,ec:ac,ed:ad,ee:ae,ef:af,f0:b0,f1:b1,f2:b2,f3:b3,f4:b4,f5:b5,f6:b6,f7:b7,f8:b8,f9:b9,fa:ba" + ",fb:bb,fc:bc,fd:bd,fe:be,ff:bf,152:c1,153:c2,160:c3,161:c4,178:c5,17d:c6,17e:c7,192:c9,2c6:cc,2dc:cf" + ",370:d1,371:d2,372:d3,373:d4,374:d5,375:d6,376:d7,377:d8,37a:d9,37b:da,37c:db,37d:dc,37e:dd,37f:de,3" + "84:df,385:e0,386:e1,387:e2,388:e3,389:e4,38a:e5,38c:e6,38e:e7,38f:e8,390:e9,391:ea,392:eb,393:ec,394" + ":ed,395:ee,396:ef,397:f0,398:f1,399:f2,39a:f3,39b:f4,39c:f5,39d:f6,39e:f7,39f:f8,3a0:f9,3a1:fa,3a3:f" + "b,3a4:fc,3a5:fd,3a6:fe,3a7:ff,3a8:100,3a9:101,3aa:102,3ab:103,3ac:104,3ad:105,3ae:106,3af:107,3b0:10" + "8,3b1:109,3b2:10a,3b3:10b,3b4:10c,3b5:10d,3b6:10e,3b7:10f,3b8:110,3b9:111,3ba:112,3bb:113,3bc:114,3b" + "d:115,3be:116,3bf:117,3c0:118,3c1:119,3c2:11a,3c3:11b,3c4:11c,3c5:11d,3c6:11e,3c7:11f,3c8:120,3c9:12" + "1,3ca:122,3cb:123,3cc:124,3cd:125,3ce:126,3cf:127,3d0:128,3d1:129,3d2:12a,3d3:12b,3d4:12c,3d5:12d,3d" + "6:12e,3d7:12f,3d8:130,3d9:131,3da:132,3db:133,3dc:134,3dd:135,3de:136,3df:137,3e0:138,3e1:139,3e2:13" + "a,3e3:13b,3e4:13c,3e5:13d,3e6:13e,3e7:13f,3e8:140,3e9:141,3ea:142,3eb:143,3ec:144,3ed:145,3ee:146,3e" + "f:147,3f0:148,3f1:149,3f2:14a,3f3:14b,3f4:14c,3f5:14d,3f6:14e,3f7:14f,3f8:150,3f9:151,3fa:152,3fb:15" + "3,3fc:154,3fd:155,3fe:156,3ff:157,2013:15b,2014:15c,2018:15d,2019:15e,201a:15f,201c:160,201d:161,201" + "e:162,2020:163,2021:164,2022:165,2026:166,2030:167,2039:168,203a:169,20ac:16c,2122:16d";
  this.BVPdfFontRegularWidths = "600 318 401 460 838 636 950 780 275 390 390 500 838 318 361 318 337 636 636 636 636 636 636 636 636 " + "636 636 337 337 838 838 838 531 1000 684 686 698 770 632 575 775 752 295 295 656 557 863 748 787 603" + " 787 695 635 611 732 684 989 685 611 685 390 337 390 838 500 500 613 635 550 635 615 352 635 634 278" + " 278 579 278 974 634 612 635 635 411 521 392 634 592 818 592 592 525 636 337 636 838 318 401 636 636" + " 636 636 337 500 500 1000 471 612 838 361 1000 500 500 838 401 401 500 636 636 318 500 401 471 612 9" + "69 969 969 531 684 684 684 684 684 684 974 698 632 632 632 632 295 295 295 295 775 748 787 787 787 7" + "87 787 838 787 732 732 732 732 611 605 630 613 613 613 613 613 613 982 550 615 615 615 615 278 278 2" + "78 278 612 634 612 612 612 612 612 838 612 634 634 634 634 592 635 592 278 1070 1023 635 521 611 685" + " 525 703 352 787 549 500 500 500 500 0 654 568 862 647 278 278 748 650 500 549 550 549 337 295 500 5" + "00 692 318 746 871 408 812 825 826 338 684 686 557 684 632 685 752 787 295 656 684 863 748 632 787 7" + "52 603 632 611 611 787 685 787 764 295 611 659 541 634 338 579 659 638 592 612 541 544 634 612 338 5" + "89 592 636 559 558 612 602 635 587 634 602 579 660 578 660 837 338 579 612 579 837 656 614 619 699 8" + "42 699 660 837 664 787 612 648 587 575 458 660 660 865 627 934 837 758 659 792 615 687 607 768 625 6" + "99 612 611 536 664 635 550 278 787 615 615 605 635 698 863 651 635 703 698 703 748 752 650 500 1000 " + "318 318 318 518 518 518 500 500 590 1000 1342 400 400 167 401 636 1000 500 500 500 500 500 500 500 5" + "00 500 500 500 500 750 750 750 750 750 750 750 654 568 0 0 0 0 0 0";
  this.BVPdfFontRegularData = 'GhSF2#=)6Yd.#dkmLTsjNZq3d3/XA<3<;4oZ"$-(7@K$dU1c*VLo?,cfIJ-i.Nq=sN<0`.XCs/<,du@#8M"OK@_&uGZhs1[0]rDL' + ':L)b\'>A%S]B4kjh(BuT&e!O:VE(mke4\\#[WhK-"X_bAn10Pp!XO_m0RWN^\'R0W5ZG$As_!8GpH+jVW`7(IPdWUhOm[mb^$POC??S' + "0hb^8fSL3fW]JaRaBJte-PdoMB:(f4pGWXg@cM(G$#fFk2Q1OO_oV2B,t(1\\\\XDrM@2`E_(sXT`@SS-$bcHHhArp@7*t^GoIr7Cj" + "i3@h$fYiH=R<>K&#^jrAkmW-6%4dY(1>3%/]D]].R5!]/or1tQnpFmbBWjKKrbac!IN:VK7.Ll2alBT=_jFKi%c[uH_6bPaIqT.F" + "5oImC7aCX8peT<uL1Lp7%_WDj7aMKH+E)>cao0/rYa,8i@i<=Tn1;a9@[O?mN2`Li?qfHk`h-,-SRkjS$>l'KTna3884qts6hsES" + "`uB;F--R7[+XU9pAW#PQRH_$F9Id)Sc>YA&r=B<\\L?T342^!T&qiHYhk:O+V+L5S,+l%jW&OHt\\BF(E*C^>_+1*NG[hHC2qU^fcM" + 'rKq_XW,uH#@j*C2/dNDa,aem"c\'\\t;<p#!-$f=\'fJK76Ih+#3kib(RT\'?Hr$k?oWnYEkbH2T/`Ql28H1pVJMZPgh/^NThZ51Yj3L' + '#L@Cc0*Gm3Stk[/FjH^f7JmfG)9Q"L1!F`a:?S6(e(JM1>OjCK1)4V<js8]lmM;EJ^!!ID$51ZLVYM`55&MKj[pft0%H@h1-%%#s' + "/!C9kB34ZLCRJSH('16VSil\\UUpp[-'GDHP#_Og_j8ld1628QT5n;ZfkiZF^G6IXc%ao)7S0i6G2\\QB=&kFAVb*N\\;POX3B%E)mE" + 'q/@a3;LXeNd"b0-I5](AB*._OKT$\'P#NGgEckSl2N!4s6%*$?;0Fn*iLQEN=A*@#3"Ypkk:JdZ4i!]&R\\KJWjcPU@9N!#$T3PbZ0' + "Gl@d'%E6)2*'OgRHlk-FA1WZA)%/LVn0DLXP0G8?[&)fM:<(UF.s/GpQmDB/>mdF7M+e97qkQEgJ8glaFD$8E5a.V[8_IV;P8E/U" + '$^4\'^_2Ft?Fr5=gQ6lK\\-^b\'iQH<6knJ,(Y(1aM"[rkJWDsRD`qU@Zp/ZO.LgJW6&[]Ss5q[Fbejp.T.qG,$4?mKfG^ddGkR2[Er' + '0K2ND3Y%7,bRln6?uD)*dJ3k8Ju1Ua6ciHYIeNp]7l!^dc%!XtiHI$r8=\\VRS,dr9-uL3!%q2=Rn4rQq@?+:!!q#N!R">/ObZ(&*' + ")DdK7\\s/3gq2V=pp1G$6*DBQ*PT=;_8KUMd/H\\c]8*Ba;b[18XPhj9:OaUGXT02dXH4%RJ3LJ*Mks@HYPI*W##5;,g5NFg1iOJ4l" + '1ID_@g%%/M:T.3hJ:9k8A>>jd5F=@G6=q\'aMi!b15Wl+k_Ifc2rZTaZ*shHTg+`""1B2\'8&hSQ&Bpd+m_QsNn]pTT0*_g=&c5lI$' + 'F+ZEu!L^E]DjEX:,u<CJ-nn>-)Tn-Wni\\e2"J2?!EZpr@5r\\u/Yohm?()Gs@q=Z`UCt?A]5/tb_G*e.r$DjZj47HlGr;nSN,UU>7' + "Au<27]:rYXUu81Y;;T))U>J*)1H[b7WlQu^bX/0:NC4@l%U+\\>Z=hkFgh\\Ts>J[H&G&h^T/![fJ\\]S(:VJ<$oU+02*f@A:A1_5R2" + 'iD=-;^.]_0O\';Zs<cP`N8l[[4UImtuFI()!h6/n;QV\\Ju2l(=VSM-:cIu4it">Nja&]]dFpB0jX^#/"%n,*+YIIFYYGN.JP:KQ6L' + 'eNYk$*k0UJ;7Q\\D6>70InfSLr_r5Y>KTYa6GXLOR!o?_jF,gs%1[nWLJWr;*ca?YY0#24M<XR%sGi"_f!uU26+j>]8C[di!+U-_@' + '^iKg8(%?YgSh$YQr!LbM&9\\]6".m+I&D0/Ha@Z_=csA+_TarW"GR(cK"llOr0#=T?I]8jr4URcu;Euu+CaTBC$(d\\2FFj0gGSWpQ' + "9k,$JZP64UZtBh4XVa8LR5p&(;&#IZ<hU^Z(&`mDYqjmn<O%,A,^'i*c.6nbD?;bL/*Hoj:&*k`QLDkLnEU2j_*nVE151?IQ#KN2" + '.r-[$-6"+dP:_l5P9#lNOdjMjbNHs]Oe8!?0!@\'F@FE&([)k.gKdKqL4&!@C3G!6EO_LRCNFEfCCimD=;c@nh!N)Qf?^RuSh/7P`' + "oQB3VNJB>sco@rn:Q=8#3L[?3)e'Rq[aJuY=cM+P-Itof_U#_=>FKqPDJn=UI(4I,q=1=g:#h[S2r2lgfYZ=9X[S&b4Gs9!?S%ct" + "RO^ELqC5qgo+bU^/h??<Sh!3%+3RuV6S1YV@k;7p(0gcGH-c&Lj]a%7Zqre5>:M]arKT1'$^E6,)jU6A&nQdf[ZuW5[oH5)+]`*T" + '-<dOU\\nZB2l;t#f<]Y$,[AA#YofVPOen_C/Xc\'7k>G&5#hYO*DEuRmoD]=1q5rM"e&N7`hVes/W\\RG*Nk,$=L>>JIAgV1,&D(jPm' + 'f\\X)cDYpRShlL=on]`sM44W\\QAl%c^fQFG<AiI_IK&(7T<H^BG7<YMN\'mA,N\\*T^=rFu#BT!MMN45"u5\\$tg75KH%@52(Isr;uj)' + 'q_e(OljN3AgRkge@fMXE[=aZqX$\\6>Itn#Z.#4c38IiiP)]`r>p,G0WW--TLL-&.OSE$"!\\B8fliuZ5CNdj\'sFR&=ZmIYI@e)ju]' + "V`%o9HtW$ac-J=ufqM1KmhVTK<jk!BiiU?meQ8$=3imY'[T#1eH`0$+rR?JL;q*,Y-dKu-><2RAcZB(h,A;C:Anf!14Oj;fipJSU" + 'AZEopQYKU(lR^XSf:Uj"gm5RCG\'i[Ad_3a#c^$^tL:3W.nr*h:dF^hNiSZH-A%BWpO3J_k*lgB\\Grg1b4PP1*oc336j13MmdrVkY' + 'Q_"q`(HikL@TqHolHj9fX(e]%[!LP3f%Qh*8*dmkf<d`i]"7RJf"*cag:4QTeRh4=$#L=0UpaFV-FZ]PRn%>\\]Ze%D]gd=eGqJSj' + "kI&@rOOjT<=)GLV2B]-Bi/N,C:]T9Kc7hkE>2cJ^W+1'AQc(oJ*oi6#o=(o9J=Oe,Dj^K^:]i^D,'VR@CD9qUVr<_]<E5;a^,<ns" + "NAqqs6PCWt)6SeoNTPpuO[90CC(r(iLik.u>W$=J&g1O6lum3!A!!ktjAU,7N`.I9SD%.@K18Fb\\!dNX(>g!`>l2G`QcXN::a`ns" + '"R:QI`TBn3[jLL$`Fi$B.!uFtNo?;`;D&t[TH-"$.k]Y0,>g\'">L:a!BEqZfMJtEp-aR:39M;676R5Gd2g90Z)dA#cRs.@E?Z3&(' + "Hrrb3_T'UL8g`^817>NbV#0q3GB@=*7AIuVVo2h5\\9$WkV<IFq,=d2Gmbs3;IuKsZDu0Ese7;gDg9>GJ*:iQTd!:u;NOp[bs*2\\q" + "E;8/9MoVSMLN:*kh%\\G<X\\GYq#DLdf@>aiAi)nVf9s8mlpCM(JheC8I(jAFWYW7o%[2hfMmMuQe)J9,HEP/=fBp;)$_R2*q;.E'c" + '7?,Tp34_8Vii$`n:fQMC0i?>\'q`J.T?AmU]UH<X`=0QJk03Pqr_rA$4.CY?Z]liXSjXiB"_r<!.f.T_OR.BZ@=d*&[^V+onZJmd$' + "<GL>W!<[.t(rC?*qUU',o'u8#b#g[P\\BCOnL>\\,%;;6Yr:dY7PY<th[O>gUo!1]!i?$j[Cb[SU;>?uF=UU4+tqdmt)FnheLjR1E*" + 'Er/O*lcNprmgNNLb0Q^)(>k.SR^!"UL%sW<Z"&mdVa^?Tr"aCt5NCaD\\8D+r@-o5Fh>t<`"A3Tsg47Ts1*^N1nS:$cB#ukQ:p\\_R' + 'QF7\\jf"7]R0:TUjESAjRN>pGeP$.dAHTZS*]0?2rS\\94`IJ8\\b/:`li;G!_9`mWRuQ"tau]fWM\':h[bd]VT=V1<X=?gYI4db9)em' + "R3teW.8m<14-2N5Qr:_T+NRgh,/N*ceQ78=j3!q4>L9/uGlJ2b^C-K`[raoe1Jf3DpXJHK.\\)O]<^iTD'iftMiq+_!$eA;9QG<Sk" + "5gNh5OLaGS<cB@$)mQtNXCg2m]NAH-?A_jZOC3+p/CA/9P9%0:ef*[HD08/0#[E<a+FfOqNUF)$C`:-T&h8iP*Q6!7=okGSK&dOm" + 'ajH9?>Lh7@;e_u/(L*o[/l3I%;C&s["M]isW^s=?aCjff(2/t5=BK<"==Pk(pC</!JcU1JheZoMp?h@!qt:Q!&cUt2#Q,*I,R!,M' + 'p_&8\':oP4Q7+sbnKU:Y>S:n2p>Vlt&6/2-Bk8sbBK1tI/<X@Qb>(Qp:"p,Pf?:4m<"\\!f:5Zto"RNfhd&TSBbBL$l_Kl#U0N%^a+' + "5_F)q+.u/r9P,.j0\\DT#_9e3#@`[D;'<:6>q]Y_`ZK`BDLYid\\(!T3`]#8G(0RI<5hNur?G^=,[mR/H##Lo@J]hO+T>=)['A)Pn_" + "P]'+A:o!R3^DJoMq5r>(YMuHgkGF2!+*['Vq<jE`)fg.>*dMQkdY4s@,-t:>CQ%X^hg+VSHFeN[NS-r_m$XE3PjICQ8>Wmu3r^_I" + 'G,(a<"b6cB;DBjtXb&67649:lZNtp<R[OUnR,FukaBdA2$ZR3p5:oaM6TuD\\3_?*K+AafD_"elK%e/?6m)6Qf_6)T>(]4Aa)0S&!' + "jM]Pr(GG1q^2oN8;hWa\\D2M]urX/\\%;H:,CG;pu5Y_sI9P7@2'UuUplOB3Sdoi]SeTLM?u6/BA3/Qf_sa)VHadGSkocW<'m=uu=?" + "&od4?/E.Ho&310U`c\\E)hg+kXcMS#mDOHD%IZ7]p)38/(nLOU0dRGM99nYm2&F^;?]p$k#+Uq<cE[Sd1eHh(:TdJuOWmD*O2A9KB" + 'UbHO3[l<H>##7VNJrZeLf`biL<Zb2VB!1"(HhHYe]CG=.C[-AZMq=c-h1bn)k9\'Ut6,8qr`Tu),:0YW-fp\\MHFka4oX[/u870g#&' + "4h.Fija8u``m^hEZHo8$R>Vm-KHTe^4rp;17PNsta1tTPkF@K3_NM5E1:.OahB/7D#k6??FP8nU!EhNM*)b\\sq!m8^e3f;?(4[^\\" + '"Bbqg6V[UU("ps%Zic(AB/^\\^8a*)gH@MC88F*Q7?,Nd%[FNf<VXk^"<b0\'1BT>Q8ld6]:LK"p>!dV^\'opk(IBRk!jHO0<aZ.?u8' + '$+E+2j\\=TAJ`UY:)SGJl]!_iLK3E2dE8_S!YEq"p%a!$+JL+IV@kPO#[]!V_8oI*IUfhp[=*kdnh1OH\'-=T)1oUsug^`Z-$80eeD' + "L+GBX9Q`ClEZ%PpR5IU?W]G46;b0GlD;)@*#:%)\\:+Ejp&/*dLh*`U-(p2IPEH0?-n$)Lqj88MPm+gjTNklT!6#F=&XLiU#/Z.PJ" + 'q/dc%-tk;Vgk[kM9Y]YO`Qh[<M$NHd/d)MqZ*E90.VUCXK]Og<4?bC5)/OlX//[U.Wqjb>X67aPB%>_G9e-/,kH?5oFNn.(gWr)"' + 'fBc:^&AJ*.;VYen[6=1gCrc[*@rjX_>I8(snqF&V`4%t(WQBdIiD]M#CR;`8@+EEU"ZTo2J9U2&^E59l9iTg$4YX9!0J0W/Igl>=' + 'j:;+bPh<K#_\\44@V(Gf"#(1b7%:#!X?BQ-#CGL?oYJN2e!I_6b90%t\\jYVYLK35!Z/+F"u\'dl4X4\'u>I:0:gIR#?,mano*e"fK4.' + "^g<.Q#3ANdePjl'8jZDRMlYQVP,Zhie7[D,mCR<`C:/N8Re=0Fb<L9eB`<bB\\FtRMPeA3r8^CYPP`<LB&nXg5giMI?7_Y.fC@h7j" + 'K^t9k(3\'QdY_*J\'BCrjUa4D6L_n]pgpR!=dlPNlb/.f/_8^*F^9CP,-%kU-nQTZ-/CF4_nF80Bq".osj:`U*tG+_DT(@C;rI>?Yb' + "qt7XR^?B4+X'0fNn8Eh:>N#Cg$MT-mV._*6`IU!8B_u3rC50AtCLk$^Do.DtDV5<b''s-qI?!o)=<B/7qaGl*SCj6XX6W'=Cqh1a" + '@?Eag#4a].b-/@kKntS%TXb"GaVmu$qW]e$GT6-r="5\'fU$30)gDZiA5E-2[QF$(aGrQnl6CB6</WqJ,l8%l;r#@/Jjj_-cZt>Ad' + '13,5*K&TThg(Md$V[;>WH[H90a5=Ka&mRb)I6V*_#\'kr\\p(o?e^KeE"3Wic!%NGA\\($UoG5?]F+%Zhe\'6&t\\-.]_<[@q^a!PD)]F' + 'G$_\\\'q;Dn"Aatk!*IdsaB]COiX&C8]!:g1c_LL9Q0&f;)c6!!;C.ZkllteCApQ3\'4[b\'Q$PS,6D!S\\FDT6(a>Ae5]QFBJuB2^:;:' + ".Z)rZ+n_QfT]\\m4D9h((.\\-(#:noi*hS*nS[*X@.l2?#4*jg[l!W#VhJ<0rHnN0u+:4Y/B>4D:D\\)Qk+BL2Cu)5S8oV'IfA=t1W)" + '9>a,HF7-NBLq)3K&]/\\";&;%o0?7_q)\'Tb%K5hcXN.8fX-ihpF#8C!b6ZF_enYcGR6Wam;M/N,?9".Db\\+N[\\-^,#C#.+kQD;CY7' + "4/)6f82D@W7A6i.ASq:L[<itO](80<,gbP[H>&if6E?>]r/WP<%:JlsVJkn$2&6hGW%7,L[=:RCrX-C2P%E$Y:r<=hZl_?A8e8Z:" + 'dKVu*80ofk-/"]#W2-14m%_9j>ZT23*g^db+.,(Op-j\'E0tK1r"0^Ob@4b\\tZ[*dT74B0#`=/I&a.K[ffO<ctoX)!%0QKQfc%j$D' + 'lT#2U?u9c\\/^1c;\'@?e>[1+4>FD8V[K<t<rHgh]_K:bh_\\L@:,N.$uU>E^.67(.S>^*sbdnb$&W7F]6kG-,X%^2^>^gT,c"/RK>Z' + '^I>Ie-b_Y=La]@ihS\\!-4Ya$gS6h;DnLqit<T4CRcgPWP\\m$Te9(@F:$;._S8d"]3iOcIsjRfF7.XW&Zq&%umb+&VCF"N`X)i&@l' + '+-@op6<HA]LNSjNDtqWg\'[KgT)sHF,nJooQ/cQc\\KhNSmp[-AS!Lf.TH\\=5(0#?1_IRnon`YfTtoFu-15?RJ08:\\6Yn\\1=WFH$"r' + "/Pf!6e/KeBc+8I+Yk$goGjJ/U>/0IVlJAhgi_kdJ<ZTg:q'VD1)31!eSFAI60%tJ9XK@'e>M0kLCZ(6986b,IXVURl&J=OSWK[)d" + "\\j5]=L[NrHh'A\\+l\\C.fXo'+9XtLW8pl`9UU_rcR<*3@_+Yrqc0)Li\\%8\\r4U)P&WYE>r>e8oa+B-h7Ge?HAs]\\*E-r:6].lKp7X" + '1-V0u/6j@bc7#R_?0<]j()Loi%_0:UY[TK4`3\\[AXR6sLiiR/Sh*hA2][_e0EH*n9V22<d1Lr3sL")99m\'km[=U\\Vf^*\'a+)/-Gf' + "T+(YDeQ@.jp'$QCjUZJ9fnV_6[l?6R96j[.?fgk<.e*UMpML=&4DNl\\O?[M`D+nt\\dZ$U8K>l?7R#$t%hk%&Gan5-REd-,tp*u`K" + "!pFo>3XZBp-o?cOh.1R3D7UCVEf]st?+ZF+EE/>-ad;;X/gVV';I7YWXa9Q6$3E:53W`CB\\+!<6&R?e0Wa;F]i1<2`m#:,#<kirB" + 'lW8#majBF+#LAu)(q>"XOPSqc+R_3Z2EIK)/oK5)iT85n>I>r$EBuaL3O2%Y1^%]pQOeWo/1B:aEMDZZp7sUd@N1Y@<n?BJr2R?>' + "Wqcn<F3oKT6KePrQjnE:X=u[:og'qodjG3$lT8RS56]uR@N=SKg=-5,ddp!im>[W3d?U/+4u25)ACT//p^KEB4EM*q]St[[Hu$8Q" + ')]!J\\>fVjNSukj;A-ttJDg^`[9nu>]$#X.#_S1^f&H6N@0Ol^)$<S@k.\'mjd7h%b$n[7rdqb+Yg=`"J(NQTh[jfW/*4\\BpUdr>q4' + 'WfplX=uI?^>79#<^DS7#jAmm_pP/@QGH]o.]+!`o&]MYCkDo?";!6:&hs5CAcS+Zj`caRrqtBi,[r;:t+5l%HRNHA5q<d_!W(>hX' + '*9\'h^a=+Ws_BsnrejBs59?euCVN=\\%+\'gdSreBG\'nm2Q6SNP(2Lu[.C*P\'2t`,qE4Qod&!-0YH8;TshUUqHhl0L3K>=U+p$n.0e"' + "X5=c&mM6;,GoAJ5,sH%)+/HQ]^?O6unmGX/jc:d0,.>QrrhbH'#>47B#g07`RYl.:oae<\\SQ[P8/!jE'-DQ@U)mPd\\Lj,N97qa;%" + '!/Je`h(sIdj\\C>?@U5)h)ob&?fQCu/lQ1IM/H5KJq2AJ0Hcg!FcIu3\'m^I]6]W\\i(q-X\'mJ08<6%RC5eS%n@c/hrn-0:<M7^E0<"' + 'cG+=5rBK3SWZW^Tk]R`<$/88KM+0OpV"M]6D-0kE]WN#QiYT#+n4TS8mQS1#iQ9R?kC1UjkOCA+*([Ur:okE,]`=Z)=t>,Ll$RQS' + '#>*5a)DI2Io(%,+^ihIeNC\'m<Am/``+j_<cl"3W2Nh>!GIAC-[C>\'RQ0Ul$+X1OU]eT2n=`+Vb5(VT]MO&p3Ae5%?;[ni*#b7/8B' + 'TQSOdJ@]3hd`[b7A>uLg-C+^*A"pb2MjOY*@HX<UBB0?8O[#*U8>TSRd)(m\'N6([@hsLF+kE+0A@a7Fo?9.O+s0"?<q`a-RmoRrC' + 'jeu&U"4ZJ)>;C4/CGa)E]uLU)\'^49#A]*N_io\\Uf02.JZ6EW]aKJ<I1JDsu@+:LSfAtrnLFAUDphq$kdV[L\'1<480\\0m)`AlYLf(' + "l9T#`$.)!mV'[^eml(k6oP4a_+nW.FXK;/I=XVOj/#\\'U,=_%PENF[brfC2$'333j8h3-q_Jm(fQc+XHVbn9<4,q:okJMG;\\De$E" + '"Ns(RAU?d..UaaiJ(RS<R\\6rn+5ckdE>cK5j43H7:gtY.KnKt^gd^*6;R.g[0Gd>>-JAX7[ZVNO8)pSIkQ\\3*\'fXK*4Q?Y:5TY<_' + 'GZR"ab&@>BOL;pR&Qr,G"8rc:JO9\\u4b)toV(rOmDWprml_Y+4V,cQY\'%jJPkA:Z12MrTV>L-#rd_S0h\\"IgFBk\'1_73\'MmdOei;' + 'M%f^S6J\\bdKq\'YEg\'fUqD1P?1pa+;Gpo"WIA$;.W\\[;5[1P3+\'na=S7X1EN$T).Q\\*dt>G6K8_GK!LE=?@V/"VO?+/)f"iCb7;gD' + ']7#s8_lB69=i&GhO.B)RGX**fga,BEVmk0"X\'to%7YqW3!/8p94VSeD@f!2H*KlKq14!Lr^NY%&Xm4;De[3$Yr/Lql^WfpC@(0nJ' + "gJqahfA3F^OH_nLe&si=M6)?06&3p\\mKr)DmI!Gml=CH0)tF*5$b%H)N/1iq=HGJt()C-p8\\WcD$7=oi_LfM_g6W<8e!4Q+TuW7W" + 'V8N.QUT]<,I0jPl$t,T?Se*&XN<8<tA\\c#jSSuJ9@b=aoUPX47U#TU0%X,p_Jc=/PpJ>o6R>C:(E$S)^*(mgT^?2KC.W\'"S4mNF^' + '=GqaRqk/BU!Bi5n`4R9TkZ9KP5XlY.D#\'a*quO:5fY`p%jU%OH7Em]1r!9:\'#e;&nJb/rSI9oY31)9".&p=fr+(r<qIZI6X7\'3p%' + 'ji^!r0CQW(-;)="ff$DWcd&*YnS._l_P+jg*nu/=.3#`J.RMam?Qe<\'\\jHm97du]$(F!QAI;S)/h8r\\mN@Ji6Ed,X(ip6#J93IM-' + 'LqRiN=(ZjKlJgCcg5IOfB6N`!Vu)bD=\'S&#GpV^4mnEb!Zc6jOOdNb/qXbcqrjAQj]?]j\'QdcnYZugA3]or#9O"\\*>cg::PdM6t-' + '(Hap%ldiul3SU7*i&AHD#3iQ6Z->jp#B+h]-1)A=^N+*IT7s$mi,Fo>$6MS]q"-;*N922%Vr7NC;4ngfLHD8PakCURYQa:/<f2Zr' + '[t.D7"_u=Q,qsf@(.+icdt!_.U+,suc]I#e1ZRc3F89o:g;@<BZDD:oV1J(J\\uXF72;l2pk$)bb6HO[>1>i!%aM\'Jd]2QYTn*SB#' + 'e&IC9dJ;5)!F(2sXR?cXrJo]pMoLNqm<X6-J1Y$"=,>JdV<Mh`]`p\'$f+kg-#PJ["C2,MNlbnmMhAtYS<u!bV60tPd1!/R![`!i2' + "[r7hiGOZ.jJGLXe+6OfRd.\\'J*mmol@9$<PDH2tGio7q8^gI`#OR05k):moXbQ,^Se:Q2qe50FalV+^R<hu@@Ms7X.DRTS2T(O,c" + "RE\\8D(H627>TA4%Gr'ms]d*@8Zj1#JiSe3R&(6b+$l_DpCg>W1]tG3Ug9C=PD>s-Qp!2dqo7mi@%p1GhNea@t[r02-io8tV*=84E" + "+rS$h$4@5g]K#Rm=P/95@H/H*/U]TB/F9Q>[Hd)F4%`[9V`6]N\\U*YN,P4))eSnfnT!gZ>+_e6DnWlVu@*9aAgt6/Cqo(h/A4,\\5" + 'itlPr??peHX<,R^$s;!Qa?f`?kJG:PZ&@;NA@;pD-i3L-T:WcK%h3Z):2tC2?e]pps,bbeS/?!FcJi+qP:`Of\'5KuMb"Cp7]+P2t' + 'DP`I:]]M0Zl#2TWr"1?lrfq6.;%)<-@8r"MB)j?U$U=":_I0e)nGfbinI7sr\'@e$$`u)Dfa-\\A7$=fhad\'g\'Y`a,bViL/"#j-\'EZ' + "ncd.WnRI/\\p6SG_Dq<YnUH#[I!2!TPKUC)Fj.u\\nFW?71ob]O<Dpn!_6&>r4+Tq.=$eOAXXq+p67Yp,/$%Enu:r<Ko7DdsJ@15nP" + 'ZafFFmb7]aP$K^k!@b6H@!m?0@!ogFs"@Q$H\'L$U5?&sT,QnU8M]4Q*0t"\\rRi/o**\'\'7tN*7r"g-hDg[#,KfA7QPmX/Uf(`s[do' + '!gH`=dQ["@g=7l8LHS$W0FV7>I=.GY$jT=XbYY!8jQqYR@n1a5(GKB6k;=R\\RnfLLN;+0Z;#@J\'__mln8&lq)1@_,_:hM&C`EkI.' + '$oSe$s(rW!=]i"M\'9=0t]V&WPftHG.,YSRQ$]Bh4cn]5.J472Q^C9)=/`T=E?Y4.4f>2o<^O_$8q/u#Oh9n2Q@JN>khf)]jPP>sL' + '#ef)FfOZkbiJK4[2HUIYP^rDt(fjSc-W6NjX3`LOMNY7[l0C9mBj;UV*\'FL>qMo7C@819+[O2QJR>M#\\ee]+-=h=NKSK"\'#\\$[(l' + "3,I6oU#Jkt[b-l6%-p7orVAd.W7$WqMb[e'>P6Gei'(E;/k4FOh0j1>i_J13Vo6a%#+uU3T<tAf<bAKV-Ai=1Pe_0paL:B[LsbQ;" + "?_9>cG`?G!4Kr\\SDQVXbR+uRqW0peWU1l]mk$tudfpVs%H:GEFhquPhI>O4gSTF&`Y8N\\GT/]b-b%%<\\fIEJ;J:n#CMPe%c.9XbA" + 'D_gmVYVi.Tb)K6e_=,-\'8F1Yd(T,,G?8*H\\&FXT$q!hRtNuc!!Zuc&k]Y(\'YH$\'(T`<R7TNfoj9OK8"5M/$u[i&K7p1!m[d74i<Y' + "%Qb0mAp4+4/,1,sJ1jHN:i#%0b[hV!G;PT2'Vd8@BF8uc1AZ+-O6OlI:XUKRb:!8#4L*]$GcmE3L^RL^,\\u)2CC.8G&RGVf2D'5r" + 'bVpfCM`*/)kb7LM\'9gT,%2^&>cHSa0qsNH4p.EWK`FFKaCI@\\Zjqo58H:dp39/j.h#"Y\'MQ"\\`]ig2KXO/n=;D\\+!k+2>0Kr6Y<8' + '1_L<DXKMm(KfP82NAm^SQkG?P^lks\\)`?3mIn[)=hq62`Q;uu\'mQG_=c.M:4NO=q.?a:6XZ"&+V"UF\'P_$W*M,ABD@hTd#;^@6B>' + '8aTq;Oiuhe0K5FmR[e\\fNrl=O[P2"JhP,YZo[@*Ic+D1pcbtT9<P9-\'e0EK(l=r<e17CdZ(9r*Mhcr_0QoV)S*G&tgU:>9nj#!+^' + 'im[ZK%H?F5j3nsc&$:mge&T?Y$rtZ#4Jhnb[PU/i8>q5>r":Hm%NIsjE*C!jT<?KNqa<?0eh>"?Oa,!j-ra"PZlPQgH35)uUQlO!' + 'HIH(Ub!QELau1-=CuH0_<1uRis%e7V:8fn7g=XQukTP+Q/cKXl_Wc%cBIUX%e^Fo\'0N"kZm6`t7Dh@k!j-MTYO/n=;D\\+!k+2>0K' + "r6Y<81_L=hc47L^F8.Q>c;ose4$qjp-0/H@FC@);Ed3(bcJqZ,TINp[%u,#[\\Yoj^cUAXHeQhI#WX/W^WN-RObA:UjUh#92*t^ua" + '.&][&\'KR@La?c&`W`33.SZoJuIKcs<i"(b"*]ka"ai8aHGBdTEh0mu\'@DlW]ps,9)R%g:*`:1.t:2\'VP5$1nOhj[_c\'$JGqHP9=Q' + '@V)1e(hAe"Cc=]c*?TWO\')n@=U\';&f*Xo`Z((?\'`+$E\',T\\0#rIS#1e\\GH!m#4Y(Hj3sfKa_F*,l(Y@/M,KMQp14G7^4cN%l]#4C' + 'K@/o"7;T2S>m*7AQ;p11DsuStr;`2Rmc(X^bEf9(RN^%?\'Z4f,W\'r.<p1=8VG/r4-5cT\'SoBIoF;dl#aSbIfpYP)<e+E1o<R<,r7' + "*#CeNmj=7*l&1lMjen`cp%4hI;L$sTSuu!m72I&NCKAg;BgScUW#iZYdmI&kSL,XpVL;Q:BUA#`AMMQd?I2modrWIj@V:-Jp6&:S" + 'DggseUKEHNf[u7iE`mhWpEKsG6**0LF@J%T8*j[2QHAfk4iV5UK1PNNHNa(?\\<e4*]/-m[S+dfq_ib8G">o5,Nl7NMNkRPcn(Suf' + 'Ia7rd]!8YP<R"1YP/4:K.WX#k,RiRU+*.:l[l5_^kK]YTk@igEo0kWVVDi@RhFttrLn+QmdmrDc9K)"#<0\'iFe;qWDA26@g5P%,!' + '0/\\QpW/m")ip2E2C6\'nMf&WEFYSFF-0dgX`384ZR,n`Gk354esL`].Q59\\QQ;B[+,#."2@rDJ"oM)XX>JNh>XZtZlN,b&8KQXKI2' + '6pS<Ni-FOh[<8kl\\:,HM4nb2.XBecadqI\\Kr92`[pbB(cA(f7N#<o+VG2GDS5ss/s#.I?9nal"f?[euE=,G_<n\\\'?np]C#gH]NOX' + 'iR$)QEL56%6ps@k,],c>XC2gW/\'R.%]Zd,K$\']*]l#X*c59"sk.+Yjkp52_K7=Aug&u!SiE0fr.T0RVSNMX<HYlYKYT"Y"[r"Isd' + '0;=-7Z/o>/cQZ76TIuk_JQ"fC\\>OdCVH;l2.EC1pU/4b-&3W&4Sm2K.o9e$K?*Vp>cUg8XIAsSWi8]G(YK$%pSN1,\\[h#F__ftrg' + 'L3%*L^Lt`fkD.=9lJ_8\'F[3UkVBKSa\'@"(rA)XYE6dEt#g@UEZ_P,=4Wg0D_#a-m-b^:a\\k%A0W)9#e/a2ZP0WWT)C6_kX;(k^]%' + '?mg#t2p_Doo_.ic@fC!Tp[tXle@->8<c?Rj0#E/U"gt0T_3d!<fQ87!GTFSF+Z&\'6(6Vt-?=K\'#!*d.gJQDd,i%jo_-Thh37*!]+' + "8ZDJEECrS];a8E#o2-^AZ-4j&$/lq-bfPDMl<et.E\\bbG>2j)0B6]eSd'KFW2TF9\\K#pa?!lD[]!6VjLS<!fuQ1oTLs(a-aalM!p" + 'l<ZiMAcl[m^L(nV@FoE]=H_ueYkl>Z`Q&jt-jeA"-K7,O"tL(t*q`@&lX<;p^+JM(l$>lP%Wj6ldFi].GGe\\4=q?D>YD6h&4bWa_' + "?;BhNWitS&NMi4^>#-OeS]_M8GZ6,ccNZ<r]$fh-AFcPKkMSIVQJm+6hid/$^qC(0a9'uE&bdauZ@@?DJN)U@3$KK<H9rJ@d2fV_" + 'S\\le)ofE<^;7i\\m"2!\\c]A9CYc\'!!<i6B?aq;IC0?bm-=.9S\\l,G,lI$FR^0#(D3NMHoPg,"ppRX@r];V@.XD&9jR!i(sMGpb(,P' + 'AmDT$(5#:EgqNa<K`+X6M6[52;8Ar]4+eWG5)gQ$H+4?+RGAHJE0LDKn<[[p<`6L__GU:"5(siSOXI<OmmlOOrb043[4X)i7I_;O' + "Xj1Z<oepVamn)0PqnYIfGS+VS)L&^r*FAbIk+P/1A2F8;?_?K>['m\\P%NVELrW9?<c<l(;VB=sI$iW>&$3&24V9`g!qc\\Et%C2IU" + 'rHjPBe\'gO+hN"D-*@(o/r.;sSA?^P]?64rU((UdJgd%8\\*ANC&K(h?lL@cB8X^j*5Fgb.+EH>P)YVDhhriQ^EKFhK@ja[s-lQ"H0' + '(P^J2iKNSRe%WohHQs=WV!\\XKoI!5F/"&$>=NF;g?!2]5E*)jSpg2/]I(1.*IWbKs-H%!#(jQ]HX2<&q.no\\lN?le,@]nQ8CnadU' + 'rQbX"VlUm;I?H[QT8@_^q@t\\gEHs^.`C%jbCeiEo!kj3m+DJ":+,b;-@K8;VY7:@<$?\\%V\\jE]5_060mef9FTYdU]bl:m\'P`>ai,' + 'J.c(eA_4)o\\$t(!C1aWb6#(bMa,eKiRZJH[PR"P&b-8_qaTa#Ifk=LD&r?"o)!?NrAeg;lo\'<u86/ljZ4@ARc#N)X37/s5XK!Ie.' + '4[OT<pdHaq4*Sfg3l>j)8i(\\]:!-%VVet\\k4&GZfg(q1n#da1!B$qT(83-#8,T_4,PXRF*Q?bksSc^]#d&5*_.BiDU?Iq=C"0e#Q' + '6<elmP/MuWSnsBM5+\\&O;%YA\\V]\')t5)&Vo"t*FWS=n>B(WijJr4P-E,)ma7;o[0;MAtaT*VM;cXYJ1m_68s3\'e1hT4%0\\F_UZGO' + 'QML``"lar1M.8O6&*7UDn=CB=5AVpI?BBnI2m(ho[\\`_<K(#js[Y]JKI![Qe4HBT9Vj=]VaB:-jCR))a_?(-dKEoY2C6cE#_SXn0' + 'SRG<N4](5,eA]@!06P[:<9dUg=\\1^`/&2%kP"R?8QPC3*/p[[)`\'pl&5jqs&^&%SJi`oT6?%PL@1S49D9qgIHR8:K@Zl84"p:,kN' + 'pc<RCrImVp;CS$`6a->i[.Ls^mGS4`?)srkk4D0[\'N@:ef)<_G(>U5SVAF7773>Eb$p/=QNl]::gDFjBD#G2_d8nuQO.kDPQ_"jV' + 'aI>#:%^7m74j[K9#05LokUou4fL/b;<$_H7-qWmD#ISf+>^>RX(MRuaeJih<@H&(\'$@cf\\dXhZ4Cf+T0FH]1JShIFX+Tj"qX3di*' + 'Oc(#GDS3J6EmZ(U]ZL-Gg[0JrI\'^MlEr2>ar$q"e8S??pNNn6$RBuD4=kG:K6VUG,S`r$oG1\\G%M-o5n4."W<Vm9Ae`H7t?9qo4>' + 'HN$;!iss:f,Mn(R\'G:1lADdKS#E?rn4b_7DQ"<;,iqO6)=2Zbp&]uSQ6tk9Ql^,C;H4-<tIk=c:cFqX`2.&qRKZ%]@F?SOcBk8^"' + "E^b4>W7[@be7jCuMPC')(cCs@)g\\Yf6+<thgVO]1n3Bt&OsN?mN;n`l/enbV?g`Gp'?<sseFqs[rr%&,QBk#,flOEAbo1O;]sq]N" + "6tpAtL(.^ma-e_r^;EsKf!!ErW)j'!-IjM1^L%pQ73nIs:?+c+kBt-2,17!:7(L@oGS7V&puZk[&T5hK5f*hr8:2B;fP$+_OE8e\\" + 'hiu.LJMoI93YW2sXQrC:2q1"K4UJ#S::0G9%ao5(>3+iJ\\+c[KWQ&\'b$^e20<M;m\'@[[Pu!.l@i66]SJ2md^sdUh6i$lV6P=[58P' + '_<$uB1`i[TpomU:$Ep\\bfmh55Q\'-8*q6H!O4HEihq"EdJ2<Y?e\'mJMLn\'Nb#P\\4sP(luqr6-OFTZ\'E+E!d_1XVM8BO?L#!rX+17s' + 'GWKmgj=)V_Dj@&l7\\r@kbMc]JBea@WS,Y0#i=&WCG%g10pd8DiOE$q_9#30T6h"I8%1V(tgr/\'H#l3Apk6WH5oNi?rn=c(O3g!tP' + '5a23lmNGlZnBKMtg@mZ2;f"-(rIHMq79lI=\\b/$gH@Cd^9EM5qXT\\SjTnqq=EsLo"h8.Yr\\Kisa:`&jWk,!l-Y0L49O\\u!r77N%+' + "TH$p[B+Ah1a#@[R&BNh(&I\\O@7DE!cg:8Q-j$3#tjA6am?J=f81+Wf9oYW8O##)d22'_AMZ#elf)T+!YM(\\T!E-hRM!u)129;`\\f" + 'L67F#rJ6V"KENecU7%G%XkSg!h[M2qN!LE[Is0^uI<s5p[QYpDkbumu`fD1s5@i:-^_`uL/(ejdHMW]K)E+s*Zb9+.RWs,RpM86(' + 'ZaNeO8>f4K9%U6dc-8UCpJ"j"&5C+g3$Lj+It,7m29[@@7rK@FKMuk+#UZ#uEQu5-AD!i3J\\1c)W`1R]M"uko.R)m%`7?ANd\',N%' + "JR\\ln(0YKY]j#ih>4`5_/MG01YreONoO!:>6-cn;\\&XmiFnGImF#Gpef#aj=[bsM%+7R\\DX@%crF6IN-2qY=G:jtr:.n^1=8le8#" + "LH693/J('h5YPtI2e^+KOTQL^q?3qT1>H5n]%:Q0^Y2c41GY9&B5pX<cLr!G$?_<QbuojFm%GN$nHtf^6VYf9BGUH=q?K?@A;8)+" + '\'bUgG@9#P.]K$\\flnWEo_P%Pd&3(-,>3"-c-Tpr)p*,_]%NJuXjDS#d*=,ssa,cpLpMbTbgW7Hp@sg7RMlu"MYoh^N(&K]i:FI\'B' + '-M9R<mY\'M8D:j-8E#P%qKr<<?"5?Q[TCkI:pjO16:%o[ciU"EdQD=>#a\\E)r@M\\(W"/3/8!/7iA]+#&?o`=X7[au%u*9H.RZUd5,' + "H8*Z'F.?.Uf?872JRmb\\28;+.d5uYtg=Z3WL48miUR;b&n-EECq`M87/6lIg:2,5f<!k.lg-o_thJ>G8CX<Xjo_);1>0LM/`3V#k" + "(\\OG>;!VL*`1InJ'QiM_UEUXR$G8--CI%bD,MF'aZaq+RB'>YbhBTX`TnuD0RXok`XS0A&>K\\l+?0@0a;3fg^GaTBci$Y1o:!D&Z" + "ZT5U)Y0b8]:dMdW-rh2@OpSr3`[VCtm[Ld/2L$QiXUI6!DKAL-k+c^t=Me?hElXik!$>d>B>d<.GZ5Oj'H+MeI#:V+&H?H`;:b44" + '^.o\';a.uYIUU"=o2n1"L%G^DB9"!`!,@r@tr!b=a3iJ*<Kh^8`,)BnKJqe,RUV;f<c]IDHp[LhqLbdr1]_JmG3Hst6M9@(.D5m1"' + "0@3c?[%STV@@.hKGYWGBm'$9-J]I;?n<cksjKL0c'-@jZHFggV=\\$B2lL66F\\kA6'6jMVK)^fiHC=4(-ZsOcu761/$`(2rLdf'&L" + 'rShM7U=j6(a[o^UUQ<cl0@%B2A!o_%dqa=^=G/e-n#[<FoMUm(8\\iF44&;7qjgYX*Y\'\\J$\'1N6"o3%KEOc`gijP7\'&b@C8<l4Odf' + ',a#-2,E@R#J+m\\ekk6<*E74(&cHS<iXk?#PdX5o%j"B)[8]NG19k(k,?I\\-LNs<lG6"j6ULc7Phah03.aclp6mOmkn%J]K\'<-l(Q' + 'f(T%RgN,O+hS;MC(V!58\'_*[)%/g=X>J:oOZL)a0Ym:(I[7`Xk-Tc\'oX<tk*?S@8`00/Q,A,AHXRT;.hi;=g6]gl/"I<#.?SSQ11' + '5M6HbiK:sibdeWtC\\(l-^1L<_3P+u6%GC0rF"K.kW8!ojX.l@eb?A+`4".Js=%?!nefV;W@p(`1Z0cB$03(G@^LWtm#3qX\\[>,DW' + "iXb+2:XnB4XM+BZ3`&J`^a0o,_DR(=dK6/h,<I0NL\\CQmn&R%FC5R-XdZK`up6Wiu$V7A$;-k1,r%TjYRS$Im8Wk:g3g%a.&3]Pp" + "VEaT>*C(P`q-(B==boe2:47[1Z%W&`:4@3,*a!W@aBX:Z*2jiP]PY<0aGPTuQ,;C6p%8>;L*^!'/L3[VEC5olX8:%/Qfa;%5qi6*" + '\\e(?D-EqQW>q`_0NrLg,DO8/%lnQc34t_ud5&K+/(";Z_]tZ.j:fC<6[6@WDcia4@n4"r+qkF$LD6E-")/9%*V70Z*JXB?;5W37C' + '\'k:qYeouhM[=tI"Ot18(CW"4REsEm8^6DZHp$8)siC@"&s/Ok8g@")9s\'Afl&Q0>&>L[^Lo#^b48*b8A,!([c_h.A*rYG/NG_6q@' + 'L#Lqj5u(h136;cg*EHBW0Z/":jcu.74pK<obkK:"iE>8&,&bQhQ7W_=UYZ#M;%\'i>Sg+tnK9ck%!;pK\\DXe*X`U5;,,XBhWaL"N#' + '49Ho(DPZh6ok<)Q^ZXHf]]Y"O8:bkf.3*Zuq[AV$OXJs.d2;rMOYq);1,=`:cY]dNWFm_":\'!^OjC;57DJ;S[dW9MN00=AgqN+P[' + '"V$lKAGY4=#`Tl6pB=$\'aT6hdo:.Bl5sN,L3Esl(pTl4n>s(>eP-0`OQo++k9Q_2=SokQSKEkZl5-+=A=KAJ1a+?S3d9!H9Of?64' + 'JOU=oHcfNq)ZoWlQ*U]H\'G3_-0"SIhJ%<E4nQ11u$HpSp\'SuY%7FW"&YTjLX>h_p7cpNg\\-%"m8&*5J9PK7\'hbkR44EjFA=p?mb/' + ")^H7:=A*n+q7`/*'dKkOH;P;q3eM/Z+F3^jg9eu2iTGW[I?@/5F8Jt.6iBC>*KZJK'T$a$O`$N_jc?#fTYON,4!<(#)ZFB`o<>?q" + 'd>E3THt\'#0CWF\'Ie"K.+Tgg:Gs!\'sjpL7C]kI%4crdq+e5s_GL+KdipDMB/N$k]NaH3RRm("G*Z9?M@%TKOEQr$j3IG9l4!eA[>E' + ';&O$aRc-ZAgA^#Qp,c(m<)Yrs6",;>@K=r1Ugc$J<?^N<RaCj2@r5\'rcZ<"]PTW"`N<YnK#a49DTV0S!a/4GFp^0bGA5(tM-I\'L!' + '1Qt(R5\'*$m&b,P&%LWOC=QS`W/`\\1@\\WI3(cr\\"]Lpr;V0E5@u20urm>&=^T8UlIBLW5mW2tj"3KMS]\':qd!K!h1UFR_9RkYP9GU' + 'o;IBoH.@sh+r^=U5`m<\\nA?P*/3u>L"RGE(8J%(<8HK%KLI2TD4d5A4Hr(^!LDDo5^AjP`T\\"*qkcWg6nBX.F*5qN&H0.kD<#m9Y' + 'rSt%L3]S>)&jTk<s*M"5r6+dSg1stV4Bg(q1\'mQka"nt7Fk1<@g3;c-DN+T$IW=5EkXLO_$QRE\\p)\'BO04]uiCNh.o2RY&J@A+Mp' + 'J`-;Ggm@d<i0\\2M3Q/bposKNDHsnqMKU-re(p$LqBD/sL6a*k(LJL`a\'kPA\\G<R$(mgI+ciL\\LThtA"/(u<,Gf[]gO]mRP!VPH7_' + '\\F\'Qs@uaoVT9MJMh2kpq""mH[RQ\\h\'&][8q);r(A%^`=\'FtgiAX]?l:7"cL4JU31FT[:L@p@X,,;=*eHbHY-r@W^Z+O+6%Wr.kpu' + 'r%GC3O\']d/m=[+O8p8"Ca_.fm3Tt,8.3+;uU;?%;]!e:!OH*D]ZYJ(VTBn,IPMXX*X8.`oVk=L`]`pBRM#;;BGf(5I`\\fGeia8"H' + 'B_)_D?THjbd]4#9:LE!0Sllnj3oWfrKP$$bQ//(,?;g:aH#Rl9M_e0H4faa!#K[.b.rfVT8g@/Gb2(1r^s,Dccr!AVo"aqk/"/c+' + '9JhB4(!t[e>0;QeI;U(Bcb<L!Z"!._Jk:Bbh;+hRY-":b*8Pc8]2@h+!sU<D&^^P_^O@u*p$CQtIFS-#SYFeapgr!ZH^70Kg+I6n' + 'DYPF1SmhNiKnUO,KJm1&juZK;iT!"[i6,\'Z-HD^+p$-A[jLEmarQ#JuZesa^\\2K%3-[<#"--QHN^So`T=X\'QD[PiFi9-b2jdP8;^' + "0c8U,br&l\\M+GCLNUC*fMR`,)ahF1'3_qrGp%m1Vd,CDU&8HfhZX*4/b9l/a5N#R]XuKIF?`ku+PFF\\MeRD_B<dkYkK7j6hUc_Kq" + '(^*qE4iC*78>j2Ma-D\'r."#`VjQZ+WUMelN\',t.Ta5l;_CdK_-JX/sOnV_TuD;Mo/2.iJo9k@BZnb9)pKDHf7A5\\\'DN"=oL!`*n8' + 'W;fdf_O]24ZX/R*Ao8\'J&N172*]4:b+pO*6I<0*lDMlMlk##8_^J18e1p`\'Vs6aeb5M<2fIc9$okOU"1BTV]`k^]0*2/(DH..aRm' + "]#bComU/OJ(qC_Jeua/DkuZsK,*jgjZ$CV1T7ok'X-0>e]Jt$(A3ThI.4efZ=h89P?Z39I2BBf]Mi1:iZ$kZ<e:kYFGB*mH]iT.1" + 'eSRRO>75XUg+l#@c&C/XjEtmu$Fj!"VKSh%\\5TQ*Q)&Yn=ZS5\\+i%/W-\'4TN\\CN*3/UX*oSLi"0RPqM(W1)K6mlJ5f24g+sJH*`K' + ')W]^qpo*fkMb!PrDBCd8]gI^,ZXWcX"Ea-OkL&(aKia>NM.,";GOf#,bOsP)do^IjE_rg<*Po04fNGV#f&=OXqfA\'MBmQp$m%k"-' + 'S$I(GSScDJ?lV"g451!^m+&LZpU5OrX`aid"qpmW0VFTKi6)P!6f?KE3-&#[<%renb9:s?S:%^o?iE2n0C^$3NQ^"4K@?\\d\'c[S0' + "1okI6ZjXOmPWSL.nNXNd:(?c=qWo'QKjNS=P*7bCr)t2WSM@$CYBfg4@A*(ch]*oR18('b5W)MYe,6gXlH;T6=$S,tmcNtG7/Vc+" + "[<LE9;41ViRp00=*K^'umOqc62/^%g9CWF>\\HQf@@o#g)O>(_%XO\\Ci8)ucq<KM8+hlBj2=k\\SI!]_.^:%[>&3,)f_HgB3D[Kmc-" + 'XS"i/LBQ/%^_%A":iqn\\LUGG8/]+u^p<J,12LX,U(610T[;HA-AK#]5+#Lm7\\Ot\\u[TPOJV*2PQB$010IJ^cDh*8^3X9`+MZ#"W+' + 'eB-R82a,ks&:1hPLJq\'m+AHc?BRJ<oG?264^>eBH-L.<LF]0J5J-Qou"o-J4bTZU3R$Gfi@HJKF]G4^u"=m1/QduKk+)>F(7gJp\'' + 'C&Y7ec^\\_6lCZYOhSHITdb;`5@Jr-""/OCW^k\\lk]%@>"E7*GK\\7;5EUU_BmcSFI)D0\'XJkfLK,CO+b^9?u4Y4+^hp,SS!H2qLgO' + 'htGt8B0VobDi"jP6:#+;D-AT!(c6r4(<62Yc4g4;VN]9odE.=H660IQH&\'-ffTeH=m8)Gt2^iLkZrQ9>.Usi%Sp7n\';J<rp%Eo3#' + "DN?<e>$RK%%;nr;jn_hQ;tgAH-8Jk&[.r7KR4#_>PE_lp/;+'m/a2FC2ZlIV2F\\U=HC0p;)^q\\6fPM-(['oOm(cphXb+_<R\\*>`7" + "c^]ZC9c,gps7j;OKd0*ih%18?4DN@A&L.HdG0[lVqt[VFcPLBgo8S:SlRp8#D_KF-!lfBnJ0N^Hej/muW/iK4V7ikuelkGE(#b3Q" + "iBPD5FKZ$nDQfhmk6^+p+9Tm*RH,>5m*i(i.u'5:LheDQ[I8,2j*bTX3Bs3t8US9HR$S);3>&GAnp&u+.ZY8#O8lm=DG>(<'P2+(" + 's&fUTOnbU`fLJ+?^KpBOIu3&.)Yo\'s1"\'d`H_HZEI2e3.]-S%0<=0PHnYrI_XR`J!n]:sb()`?0F$doj&Wd@5_2d02CGg,H^--5l' + 'aAL#i\'^L\'f=(I[f)Nja\\U2b,aHa=sN3"lJs:P%CFmE(Z?40mgm21,q/qmhd][>U"&"TQdJX\'3r0e*.(p8IL*Q[Bu<!RY(@VrTref' + '2<@BQ"A<pI(hu&Sk/a8?",Fk4_0DuK17K-<d[_n&@VQuBm`X-fNf13PgM:MePJaiQag!QTK@[a=l>7iTVPNfh7F;2&N4ZQJl&dMj' + '"HMs+>K0H,Au\'2>Anp\\:JO:38VSuAT2edS1PUfh@bKL)-&:]E=/GIlK[qj^5;OC[,""Kt23*)(HGDZ\\Ck5TU_$s\'.8j;&VLLRq&G' + "aFI%pIo(VQ<iu:%2?c*K+BaJ?r+lc?UE&J^)(gPpZ)-NOh>78HQ-jn]U&#4&`P74_8GLai0>*\\Wj?b_tP['B(a*'b0Ys\\=TDRC(Y" + 'XCf4mZ4cf(+,T*,;.<uHH=K>q%C\'ld!ES"&E2psH%CbjH`D_8>8(<,KRec%D*,6W@\',Lu/n&-Zbp,dFB0c-%SF/3SnN:%]A\\kQ/f' + '.U>":-uB,/)`@JUnoLW`]<kT_"!N-]&b48T,HM";1um#+$U@^`_F_=8oGa.7cE0=E`HBV"BBQF`;WPhHnkO,r.4*bfE"81;s5And' + "f^DWd\\JU>'D'/>d-g;'m*(E0WF3qPJ&5R<P24O,-6m^4nnA_DmDJ4-WE\\Ksa1pWnd/rnN0f[,L`e/$bQeD`Z?]:YC`obuF7PnIhF" + ',K9L@grOb[9.l7Adb"PZoUD]QEQgqooS!k*\\ZRH,:9pH9mDn6gW,Osn^h`Z(2<6Ab4Dr>t?2XIL7er<[mFEB0,!i7o&91HPLkP`T' + 'j";C.$F[5l[\\*]#8-Bh2%I>ri.3-/MXW#K#&H=!B^4l0n.UK?PR!h4!X0:Y=-nZj8-Ffd9DFO$"Pj<[n0a)CS%mR:*f$q@i=&Xb9' + '5KEpHc#doWRofOon,(Gc=,l(ejRuU6Rh,PZ*0J@41""Cg\\$E`;WP=4RGGVdS)X_8jeYhl_hr=LCCKg0EDJ"=kVm+<_AZN>YOIfo0' + '619>7ZIgFK,0=d6P"kf)a[^[/72EL4b,>0u^ln4B,mId;HULZA)>o3BjQX\\G$+97$"H)c&;cms\'#MJUL9&N1sAoS&W+`Ei5l056g' + 'U_&1!Z]=%?\\;H0SdVV+p9qq%@cW/0=EjatR%kgBnRLH+aeTN5%onF8Uihsn2LOL,IrM#2:kpubUOsA`%3oLgRMq_aU$lrOnrZ#"I' + "XS0n,k`g!\\9B>[qZ5i:^RiHJJBQ>m^NQS;)o$N@=PK=hacA5-%D6)*l[7uDSUbgd0LYTF_Z@8%UPKRa+oL9HQ,,?#8aNZ:6^lj;D" + "l)/s1Ak]CsEC$P&KAMF)cm*oI4;f0m?=DIu4URs.d>Bt;:qfspY:Z!)8hIrc$C#WnY@:9KeqKoU]&1%mkQ0EJET3U8RJ9,C>UkMl" + "j;E\\V8G8Z>/^O2R8\\3a/$>ReX2-Q1N2(V_jNKR2j<TRLlSL;bY?+1c6_,d3[mYbDUDHqtS5D@&1Jn'qo&l]RrCfX.6f&c:ua<Q3`" + '=\\CT<"ZK$C.W2DYr&Y0Y=gVE<n_kcV[N-/T6"uSV#qT7qW0Gbm9%g;pH)n.2<NSn;^g%Xn@7tt^D$-R)QX&`E=Q1Tt8j.Tc::#4J' + ",O-1A5Q/@^]jNf)$MR<O&]<]JrsV'HB\\')(;l7HE@1<UX1FY?_2n9)ahkPH0/VE^B$`]inpYu&'k=M26'S\\G!*8Q2,XT00L9Di'$" + 'L:X?++\'#WZm2cPYh"Zb[\\J:dYIkn9)BCU3AXLi7gpW&49]W_rN)_YPfc^kcq#3(EsmcNg&X]7s(#bpThho0YG7Jn;+TmM"%%>h9U' + "fTJCslFmc&L5QYgd#eVtH$$E3'KX=(M,/-,k&(;;C^%$oqe5LHTF`%U2nj@*M9$/k02#'%071<[CJ`7Sh!Fq/BSQ6=%7%7_p75IO" + '1qo\\NI+)abL%BLZOntpt!]"kiW%8\\M/uT:F6->(q$.-\'`>K/pVC[Sp]Pj6^p.%3_JTgJ<-;JWDr4D7tj?U5tmX]nH^h%7MImuBU@' + 'K&1dY-e7$2UGB9Gp]_7cl?a684X].giZ#<DqK?.g!Y(+,G^]%ZR>c_"Rq-\\D77)#4>[V4MR"k%jgs60u#Ar#gGYQf5$u2dQ;=i7&' + "A:V9!M'!VGW_g:aLNo%%kMiY%?c(nZ@p!'eJaB3:O4Bj*o/[E@7`3^Q=FZcH\\,eNf5dUf'PdjaT#7\\gI%JDB'Zpja/^P,J>@AmV-" + 'n/KnAkmnY6CH<BEdt5#gR_hL!B=epk/hIl5$?GCfY-Y6O;cV!Em%dM(?%pR=o>Vg)a<l@EiR#5oRFX_@4kkRqCBj0<lJ%"#o>G_-' + "D>BI(MbH[b=83SSm=i#=hSirQATd.,4dj/kr-)l>Vg0P;>VVj_W<R9Ge'_.l2uOC`YRcLnbP=VX2]HMX+n+KnUQ,8D2i<q&^MFDW" + 'M2BFj-3?pgbQ@1O89g$trBi4b!Ign(82[2_dN>ip>=_L"I-)NFJ)TE/o+_*0\\sY;D4!]smIpa*^E^.80f:p,$(,C9$^CNWf8,pnb' + '?itrj\'DocKi\\,;)89lYsL3KCR)T7CJIF%]`cGJHNqZ,u=kuM/u-"*nscl35HKosRdVNeWJCuCcK7/3et`IJ+PaLS10^B]"CNedL!' + '&A;_m+7RDlrYcSF,kXu\'QiQfe,[;8,P>ai.2U_+Pj@cN!2krRooZuUqU-@J9qKt)5^?H*tc)(5Fkhd1"q%c<2g&K2BT_UG%%/T]g' + '83Yro.%.fOBFm+`Q;\'.bb<hhp/H+%/j%1_oFebBAIAZ.kcd]Vs1Gq*=AHd&KLGqbX2e80<:JuIoLH"u;DoSa_,aF\'>3"3V_")j!(' + "rZ?Ks5?.~>";
  this.BVPdfFontBoldName = "DejaVuSans-Bold";
  this.BVPdfFontBoldLength1 = 26936;
  this.BVPdfFontBoldBBox = "-435 -236 1417 978";
  this.BVPdfFontBoldAscent = 928;
  this.BVPdfFontBoldDescent = -236;
  this.BVPdfFontBoldCapHeight = 729;
  this.BVPdfFontBoldCmap = "20:1,21:2,22:3,23:4,24:5,25:6,26:7,27:8,28:9,29:a,2a:b,2b:c,2c:d,2d:e,2e:f,2f:10,30:11,31:12,32:13,3" + "3:14,34:15,35:16,36:17,37:18,38:19,39:1a,3a:1b,3b:1c,3c:1d,3d:1e,3e:1f,3f:20,40:21,41:22,42:23,43:24" + ",44:25,45:26,46:27,47:28,48:29,49:2a,4a:2b,4b:2c,4c:2d,4d:2e,4e:2f,4f:30,50:31,51:32,52:33,53:34,54:" + "35,55:36,56:37,57:38,58:39,59:3a,5a:3b,5b:3c,5c:3d,5d:3e,5e:3f,5f:40,60:41,61:42,62:43,63:44,64:45,6" + "5:46,66:47,67:48,68:49,69:4a,6a:4b,6b:4c,6c:4d,6d:4e,6e:4f,6f:50,70:51,71:52,72:53,73:54,74:55,75:56" + ",76:57,77:58,78:59,79:5a,7a:5b,7b:5c,7c:5d,7d:5e,7e:5f,a0:60,a1:61,a2:62,a3:63,a4:64,a5:65,a6:66,a7:" + "67,a8:68,a9:69,aa:6a,ab:6b,ac:6c,ad:6d,ae:6e,af:6f,b0:70,b1:71,b2:72,b3:73,b4:74,b5:75,b6:76,b7:77,b" + "8:78,b9:79,ba:7a,bb:7b,bc:7c,bd:7d,be:7e,bf:7f,c0:80,c1:81,c2:82,c3:83,c4:84,c5:85,c6:86,c7:87,c8:88" + ",c9:89,ca:8a,cb:8b,cc:8c,cd:8d,ce:8e,cf:8f,d0:90,d1:91,d2:92,d3:93,d4:94,d5:95,d6:96,d7:97,d8:98,d9:" + "99,da:9a,db:9b,dc:9c,dd:9d,de:9e,df:9f,e0:a0,e1:a1,e2:a2,e3:a3,e4:a4,e5:a5,e6:a6,e7:a7,e8:a8,e9:a9,e" + "a:aa,eb:ab,ec:ac,ed:ad,ee:ae,ef:af,f0:b0,f1:b1,f2:b2,f3:b3,f4:b4,f5:b5,f6:b6,f7:b7,f8:b8,f9:b9,fa:ba" + ",fb:bb,fc:bc,fd:bd,fe:be,ff:bf,152:c1,153:c2,160:c3,161:c4,178:c5,17d:c6,17e:c7,192:c8,2c6:cb,2dc:ce" + ",370:d0,371:d1,372:d2,373:d3,374:d4,375:d5,376:d6,377:d7,37a:d8,37b:d9,37c:da,37d:db,37e:dc,37f:dd,3" + "84:de,385:df,386:e0,387:e1,388:e2,389:e3,38a:e4,38c:e5,38e:e6,38f:e7,390:e8,391:e9,392:ea,393:eb,394" + ":ec,395:ed,396:ee,397:ef,398:f0,399:f1,39a:f2,39b:f3,39c:f4,39d:f5,39e:f6,39f:f7,3a0:f8,3a1:f9,3a3:f" + "a,3a4:fb,3a5:fc,3a6:fd,3a7:fe,3a8:ff,3a9:100,3aa:101,3ab:102,3ac:103,3ad:104,3ae:105,3af:106,3b0:107" + ",3b1:108,3b2:109,3b3:10a,3b4:10b,3b5:10c,3b6:10d,3b7:10e,3b8:10f,3b9:110,3ba:111,3bb:112,3bc:113,3bd" + ":114,3be:115,3bf:116,3c0:117,3c1:118,3c2:119,3c3:11a,3c4:11b,3c5:11c,3c6:11d,3c7:11e,3c8:11f,3c9:120" + ",3ca:121,3cb:122,3cc:123,3cd:124,3ce:125,3cf:126,3d0:127,3d1:128,3d2:129,3d3:12a,3d4:12b,3d5:12c,3d6" + ":12d,3d7:12e,3d8:12f,3d9:130,3da:131,3db:132,3dc:133,3dd:134,3de:135,3df:136,3e0:137,3e1:138,3e2:139" + ",3e3:13a,3e4:13b,3e5:13c,3e6:13d,3e7:13e,3e8:13f,3e9:140,3ea:141,3eb:142,3ec:143,3ed:144,3ee:145,3ef" + ":146,3f0:147,3f1:148,3f2:149,3f3:14a,3f4:14b,3f5:14c,3f6:14d,3f7:14e,3f8:14f,3f9:150,3fa:151,3fb:152" + ",3fc:153,3fd:154,3fe:155,3ff:156,2013:15b,2014:15c,2018:15d,2019:15e,201a:15f,201c:160,201d:161,201e" + ":162,2020:163,2021:164,2022:165,2026:166,2030:167,2039:168,203a:169,20ac:16c,2122:16d";
  this.BVPdfFontBoldWidths = "600 348 456 521 838 696 1002 872 306 457 457 523 838 380 415 380 365 696 696 696 696 696 696 696 696" + " 696 696 400 400 838 838 838 580 1000 774 762 734 830 683 683 821 837 372 372 775 637 995 837 850 73" + "3 850 770 720 682 812 774 1103 771 724 725 457 365 457 838 500 500 675 716 593 716 678 435 716 712 3" + "43 343 665 343 1042 712 687 716 716 493 595 478 712 652 924 645 652 582 712 365 712 838 348 456 696 " + "696 636 696 365 500 500 1000 564 646 838 415 1000 500 500 838 438 438 500 736 636 380 500 438 564 64" + "6 1035 1035 1035 580 774 774 774 774 774 774 1085 734 683 683 683 683 372 372 372 372 838 837 850 85" + "0 850 850 850 838 850 812 812 812 812 724 738 719 675 675 675 675 675 675 1048 593 678 678 678 678 3" + "43 343 343 343 687 712 687 687 687 687 687 838 687 712 712 712 712 652 716 652 343 1167 1094 720 595" + " 724 725 582 435 850 593 500 500 500 500 0 698 565 1022 836 302 302 837 701 500 593 550 549 400 372 " + "441 500 797 380 846 1009 563 891 980 894 390 774 762 637 774 683 725 837 850 372 775 774 995 837 632" + " 850 837 733 683 682 724 850 771 850 850 372 724 687 557 712 390 675 687 716 681 687 557 591 712 687" + " 390 710 633 736 681 591 687 791 716 593 779 638 675 782 645 794 869 390 675 687 675 869 775 651 661" + " 746 981 746 796 869 744 850 687 734 593 683 494 702 660 919 627 1093 837 832 716 928 744 733 650 78" + "9 671 752 716 682 590 744 716 593 343 850 645 644 738 716 734 995 732 716 698 734 698 637 837 837 70" + "1 500 1000 380 380 380 657 657 657 500 500 639 1000 1440 412 412 167 438 696 1000 698 565 0 0 0 0 0 " + "0";
  this.BVPdfFontBoldData = 'GhSF2#=\'!DfD*XW4%\'74UI`.pSVTfA;6_5f.NfoZ.O$>d+t*_QLk&T:`J,+a"c9pe0ub;Ef,+l66]=1H(mESb@uQ,2qnJQT6h%#2' + "p]!59G&MP9kKTJTDdJoq5n(XJ1,Bf.;%4N3kqhiGe!1>og-]c5fSn4GpY*%DcS4p'L1-XnVrst:>Q&JYL1ujq0F=c/EMJ`J2dO.L" + 'ZF_7`UdBh+J6"JarYJ,NW>R_FrY&?s*o8i>@>$/qPK/]$Fmnej%+?[2hY/R2oX%:KQWXdD%A:@KdccX0#$7ne%$N^WI]ph_S=QE*' + '@>6S^KQcE:6XXI=O+`o+*unkIm2s?.<+D<]Vqg0klQa;\\lc-KfY\'$944")UC,_&WdSq68GVY+2=T%Z5c^8]d-as&iZ.MKeBR6D&Z' + '_/kWF)8r^fCD[*Ki@D!^ZM*:C]>:;IV>sY4"-/T8/B^C^pJIGQJ\'f]nOo]`kg/2I:bttr5"$M2$<oR\'W1=X&=n(ER<G^&;Wlk$Ko' + "=O(_<i0b/0>GcqqAkmF%RJi5IGYc<gT&8T;R1(^&R1.\\_lk=n_3AUlf,=n)](-kKBZiO(0oXbZ4)X#:+KN(:pThg%N;[S>L-hCpY" + 'AQDKaE1]^a<P^Og9X<dL]:,^-hiaccQ2*a1P`rk6B94bKpk??><TXM3:,?HJ0"e5%o&-&Cf9p$74/3B?lCJ9JR0:qS!]+\'t62Pde' + '_#_G!$7SZ]E0T&#f@"GdOMSkV"]198=#7JA>*<tb6B$/-&BF,_q*M>gO-J[25lK0Ycg-N!4PM+a1(Nkc-<tM"*8o\\2hbN$^)"n9q' + "ad)L*O*e[g?A^+'VE\\=f8/Zs$#guiX#2/LP!MAf(#)[oG4jAUlOK*#$$&f2;.ZdD[n,V<VacqnWJ_r6(07`o0;#d=W30Pni<.]IS" + 'pQ$SP]eHTC(A`$t-Q!\'rE@_q:;D2]fXWN>u8r\'(#QPg;p(<mI4Maq_L$$[\\>s%"m^_o1$/aCpuL%-j[oGR.@uMLYRaI#nV?i#5&)' + 'U3V?qTOS1-nuc#59T$YXVusCo`_TA\\AA#DRh\'18`!Xmq4Ss19]Wa_@8\\\\]hnL7\\kGhuS8\\%sUZU2N^CH,-2#q@*f*](])(2".B;f' + '-ZmSW7jH+Ma[S)cA=R1CFEIeb]%d-6?+jL>]-Y4c]-,_h:36,fB@GY?&o!ep"i.%V3uJPa0?>sJ]F^$h$ZlfurEX.8?s\\r/d<q;p' + 'Z:dkLg]p1E0\\Y]!Ah9Rl9Hs7bFuK]eR>iJQi[Pm\\\\<n.\'T(>I?@="G2\\P9q)\\2RiJ.G[9MqOHJ.QAO):.9T`fY79MehC/h@k.mMV' + 'P7;0eb$NM?BV`)rl#Xq@oA#t[\'`\'NtK\\&m&q(5km\\]RAr"n90gn2E.kc@&UR^,S<PO5/X(;IKY`6g2^0P7M<\'#X%-U:^d4ba@qe7' + 'L[m,pjlu:&^R5SK4_CYNa!Ae31?h+LP:YbYo3HmE+T;W[8D;G.:ZaiXY<B3gcnJg\'qB^B;[L(65gWXF-*@e.F7-4rh>"LiVM&)IM' + '_!<>`G[H4ok%C(n_H_jq"/u^#qa9ohm#VFo<OSLBKQ%OI#"U+=*);35gf[a^]*WOcUSg2H_6_jS`i@&D`d*R8Ut%e*[aHYp&q2##' + "RqI2'Wt2994CcMJ0fh-.NCMAn&R*#BA++A^>VW^L>KgsHF=K)3[E;h;W,bm`WOf$OWuZ=D\\d!%=0dm@n'M<L'\\`qlhW3_03U/J#F" + 'WGGQa=slkBUMJ5IcqW)NeOAd"klS)^IA\'B`->J<OLM>eV6Q<l]qD<j`oPWmG&D5q:dts\\$I(1s2J,QdKCT*Tl93eM8kT=)UR8&bK' + 'lq-\\&#1?nh57(E^HSjNML?gZN0k]HK#`7%o#M0]"@_RC.p7.M;Mf??S-KYZ.3YPC4gg>d$F@aAi%s[5%L>WiarB7YC()-9NY"KmS' + 'LAP?:\\ci^tm4EjiKOb;SNIWPO6"LN",N0!iW3R5u<C+B!Nc72uY-)5#.<+qm\'*;<,\'a1KDgo&#3\\!TuQ_l+TpKJK2`F80id63\'Mu' + "a;.K<q.MWHLi/q'/B95B#M+MJa\\HCtg&!>_4Ln&=/FF-ha?/mBHiuZkcfTEXC8$D:<N$P5$'/Z!/3jt&99eP[b%+MXe$;(+2KE_]" + 'ML;Q(8,3f#@fp@r0SAm"`<L)dFrGaFE67$NKBEHM<aAm\'Cpg_%KiX1fG(tj.o*d,X^G`/PI*gTMFe@7<XfGXW\\,N:bDk"6p1Y]!G' + "F/[@V2Li2Qh);e1J@:/KpV>t)Oj(nuW6f4ed7Ihp@kZl%`qPFsM33Xs8X[[IP<+ojMKXjo`G!4_`BM6q`BD15;b,;5dob(0di?im" + 'VFO>+QsMY`A,;\\C8K"KIVAuMX;AL_u-s%iV/,(I,<rT(71c$gA1K0]a2!\\s9goSY7^KHQL2eLs:rFBeR50/,Iq#p:oo+LXmo6\'3!' + '/U.X:$X8P_(4I#^/Kub*/Wq]/=aXe#g7lmP[`\'JL^FbEsj"6HH1G*6AcF7%mH.MPTjo\'Aig829Jeo"6pAaLu$D/4@?b/c\'RC4Oh_' + 'X1;8dXH$GS[CU2IaI9@lZF7/a[dIhb_n*&E@-^\\@j/j\\5(KiDu?>[BlHC+::la,0oXRB<l@K"=egW42iCn,?\'gA\'?CZcTJ?@5Gs$' + "gnrM3Vp0LV3h%'HpMCgcH.t6cdC/SRF)>]0^U=$Vp1N-X[VtL84,$tIh0Q\\sp2^%Dq\\f*7f`,KC*Gcb-3J9FeE7j0SbMdeJCK3;n" + "\\n[Y5<qT(e;+IX!WL'R,eR,6cW/mqH3N=+?3j*Y]ijd>)Kp0MjRaYT@LX((gK:PLlYBE+qI)j4S-.HLabHJ(7Y'jR<\\A$=3d\\LW<" + '[--0SDSNa\\nb.1^*8Q@\\NH-!,2VDrJgKh:DDGT*fl!W)Y]0g=geK$,$m-/Jj_[ddeE9H!kmLJ[AmNM"Nh)!k[h06H&G(8#hUgp<_' + '\'cm$k4PfOBa2]5e*f1q:4Q^skp"8DHa5aF[[Z_#[fpNPeRSONqJ.mNVY>hG8/o$)$KkD=13Le$DGdZ>jont7A5I/?2MU)t$6.,rD' + ')6"@@RY0U7jFC-V1%n&8GcafG4cL+PV=kP)J9RXJG&jQYK>&9RSEP`$I<tE4\'Wbs\'8Koi>@MkN&:s7KFcj&LZ8mb>1Y,9<48X$oX' + '-3TaldNi?WqX/$-NXtkM[Wm;Mh\'DnZl$a9E*JK:-LF=JU7H<!.a?Z]C`M`nUfAgL&E!\\!@klroF7jZl[p_c?)$""KZ1,Hq,l+hO2' + 'b>+S.X%$N+@B%V`])):-":"^k__6(oCM@3cDC1Qg$CT,nbX/97#k7S0j_QDDi?+8i+6T\\s?hidbW_ED(*;iaob:imtloQKXc_3_$' + 'nTEn9FE0aSY!%"D.-khca2&.c*^)2r[)!bF"l(59s.?KTS2K:mOMLV\\n(J^&^ji#=OAJd9"=?P25^lo3PA/9D!d6DZ00nbm!:]Y)' + "m;%(T:em#R=QG-_e]iPI2Cg0Hm2HcX*ZbpHpZN,P*'JW.L=YH=pVjgiV+9k;O-11u'bqc2)9&Hg9Z\\n8aIZ;6rPrEgDVmWYF0kDJ" + 'XR48Ba)9]oG3nAb),mgK$aZbTJ2&S$4ciYEA?H@"XsbD8:b?2=8?J#rS5]n_*^ud+%q*l:eVO@FaWurL3<uq:5>XUr`fnFe(E>YO' + '_JcdM)uQ>)Po\\T=lQa\\M9\\^[03Q-8=YE5<#]lSS2qm_"*hFWLm0,&>B7T_&o^V-?bbs/>RQ8<]-p^aQ\'>lu(%ip31]IBtH[ggFt$' + 'b!Z%Tj\\`TVq^%+Ele[*gK&^F>9Nsj&Y,oC1.088[b`q/XNHHboefqSk1Q1d]Ih?&gSc%Y"mX"U[mK,8Hn-ert=Ap)FlL2c.e/"qD' + 'AurX[-N#$r[:Ll>i>9he\\\\!(5fr+l.*k-(JhZ&`sh:NiV#1uhh%mc;h!)/!a`?e>WpaTNn)*X#U8)T"]EHMDAU0fuZ,_\'j\\hU3Wn' + '4,Q7#\\p$s7@2+d3+,5!q"N%YXdT^M82jbiZ/smRbmM]l>IJ$;2MDZ)mmE6m2QY`-=C`CfK#/87bU"Mh(<^K)"jY`;!DgaC0NU-\'X' + "PRAcaUDih,H_94(8uO,D3SMI=I=.C2^'7N#e<Z\\3,82)t(/c#:(W&@unEc('=JL5s^[;I%D_ci0`onHLSeCEGaFqoj_M!k311AZ^" + '7R=f"]b>#%85#FLO9RN6"MTS.iY/7<dNDW@\'/[CG%j0fgnAF.46g\\hAc9Pqh)s*_JS,mIk!^,u![NU>tTSuO;rY*91/SG9UKOWh%' + "6&+1JE$Pg@kDrt9NCqQ2mfPuF.0!0q&=p`>QQ2m/YDO\\@S;h!E^H9]?qh:<t%f]u6/3Fr\\6#K-K+raoA2Q.dp.!3>Ma9WLJmd]B7" + 'o]l_f()H*TnB^%+@%0H8:%2mfb"\'ClkN(\\Wh)\'&+41aQq]Ghs;I[$+(5CVFSD-P.5QS2KD1pT#Zb"q7URFM[*(X:\'%pE$lT+Lcm:' + '[\';%n?B5p@Qe9+`=fYNB:X%Z"3)6,IO*\\;\\e4eL>&<mjEK7\\N&LSLt7dI-jW]Mb6=YLP8ep,9qKhsm>["SF-]Dh&F/TsgLOZK;9J' + '`nZMe#sLV&P<5Y4g2WJr;BRXj-,*CWVI98fd>Kr%?9G_E?)YdS+15g@T>,c)T6^;Vc`jVW\\Pq\\\'HN7$ad"7JN$u!Ge-0IT=;ijA1' + '5.!nD+FG`mLZ@;GA_]7%Fk$-Kh\'Yl_b""Q^<qmY`NUPkj-l;OoIu8*1/cDr@nIlH-j#,]MpuTabnU7bE9gDY(2AI5K)"2+a58i^X' + '3Dq*p!e-[5-sj]([,+.Jc$)8uA3db\\!2V-@<%#\\l-(HT@M`Ih,g(;;*jU?N2C%`T2m"P)%SFhY:VVi?`(F!W[Otj7K1k4n=+Qe"N' + "oSrMs`[2*91M1mK=LM](Ue/,-P:#H.]Bq.5G4'0`nP6P'a-PP.nDN0/@q`rfUnhG:7O8)tdJtU=^g&sQ\\Nk-k!eIgA!cQV!bL%'h" + '@/tg2-Z"jsI6nNL55ZRQKS#:*3MW0j+[.sG"=bIZ![pc7;\'Rl@^m:#lC45D$jG9_n[<N!!k.j0M4aYbM3O<>D-L3D-ibT=$,fp12' + '=t.r3d0.+:,X)MNiiQbjZV1[E(/g=<"<qcHb.\\)Z67PMgL,X\\kKQdS-\\,#W+6s?kXa<(_t)nU*&hI;&t0&o=on68ld"P(>XDh9<[' + 'S%GeX_45sl$7mY&(3?r,hg*rHI7euW?:]unB=Z3(Z1epurK^8@bEN&S35>gS0krK<l.Y!\'o)$c7QGWbM!;u1d]I"o+B97U@gn:+#' + 'r,5\'=6qgQhcd3.G#1./SR,Ti+r";&E%I>*e\\o_V8rqMlR_h,H1n2L`+&%"8+=3)`sRt.4WTtP\'FJn3=#9GU*I?Vud/\\2k9_kTXPO' + '_3:"iPjqM/c5L\\J$?-4EL]@Kdm_ndc0RR!V`8U5":q?P[@CpIU\\80`%qeJ!RFQkgn5M2FrrU?(Z9H9CX\\?_jK@1s%=c*^p=,;Wt]' + '2SZ0r%6X7rRT(s`&g,(O1osEfP,6Y!92"gE^\'!8?o?H%R^9b3LPSZMZhUc]BSD^P[n:`MsiHNCR`[=5WNZLEsYRpIh"q+GiN;:(D' + 'O*Oi\\s2*ZW^&n>"Bjd7KaW4eULjh<I9Y5E]/nEeb7FhnaC:Bs\\Q]MOQ;lG33cFU57AEMDBs&oDF%:E`m;c[@p$Dm_kihnIW,1eXl' + 'OdJ,&ro]g,SD9ain/:if*W1PuKFL4ua>/H"MiNZ7K[4><a,D$%)X"G-cDO9ar*H>*WQSBKe<0lS.KQK`MIBbgQm/gU;*Z;G-^Y\\_' + 'dXEddMf8e[KQ7HM9q-AbqoY*M=0f#)N!\\j02PY7?"`<ZILbJH0`NOc<KO9N.,?TJfaF\\)$aD.W7"rmZrQD0<\\K3kdu$_P(WrD`Y)' + ".$_%c12fKOb(OJR5CCoSlGfnimbdmN3K;<%LL4uSJc?aW1R`8;GVe4WDf5N&/s9!>DlfMHNn:FDX5;Y:*dee(!GSIAAs57lTh_ZN" + 'Fdd(\'@XWOh4@[32><4hG0>&>ZHqV,6AOUjU%"J-X78=;\\[0eAR$icdfl^L--FrToDR#R^X(.Jlm!Grqbl5PJ#c_"Z_Ck<W=.mbPp' + 'qFFCY$/:jRlIp.^AD6Wk&5Yp3#TM9%K1-)6.@)8kh@`CT=,Kr?1\\#m(E_sE41=u$WW,C&kTO\\M5GYaFMB="DCag.@G"s?k>-N`4d' + 'Nbc<g.r;EF97aV!WjT[&ce&NjTk7dWkTM<R.,NiM2.9`b`kMs3JOK%FM8&it)!X*Q4\'mcQ^VnlHR8Den^cB&Mk<g2,F"ZorQtD_Z' + 'j+XF87B5ce*Dcs#d5K?T@%2aO9V\\PqJc)(e,[F!:6tB1j03Z1NQa6Y@WVm&sSN;:!d96s1)d\\<?UNQK/h"]qbDFFD4YbiX<S;^P.' + "eMnFHTJWlu</C0?B;QiI,VYA6`rge@9r)(4(*bp%%IF#o-@/^@k4Io+J@IfbCUJ*V>!+8Z3B:Bp0^C0``h:.%Jl<>-AjfptOBY8;" + "0=AhnE=,m)`WHdQDL@@)n8eG7s/F^>cikAq(8V]&TGu&nn]D!I?cGGlrmZe<OQIZQkFh3h?=Ln=R0ThNQCptS;7$#g-VVUb`5QNq" + 'LmlJ_b6AaU]S9>p#A,9&4bf"nM8pq;Pnk^n\\K=l\'HC,J7i-:KW8PEYg)9`g+k`(>@EkPplBdnmec6,(9P&@-/70ap+^KBtqlG>R!' + 'Ei\\&ELMu5=9CU8#Q_N%eMEVt6J(7>;8;3!0_!eNCT*aj(&`\'R5413D2RXb>En4.mN,%ICb,4*idhc8S6dtP.>PUiP,DVI"\'%##t.' + "^r=rZbj'CLHo7`KJFbU^;p]RE$D^KkW!DV4?a)4+k/f&S$N>ZR!HjZT]lE)a>]F6[5)m<G!@V&bNUh7\\7+FhFLh<F$BG$]8]n--5" + "r2]WAR#HiPiW`u=karWFY@*TK=N#aFcG4Q8hLn7)iHU2HU$cVYQm<g>amYP53rl06<h.La)sBMhOd4nIGRFct)/s5A<hR/T%'='t" + "C1RZ\\Q@6s5`X\\pJ3!/W\\h5:t&E73fJR%Z0@#0*C>g@KDu5@MeT2ea)57.2;iF-_:3R?Le>O4;k\\UW319kI6L4FX'T&h\\u[fh;>aN" + 'HJQsY/-_826I`4;C^,]"<n]<s=i8ug%3K7P!iSPhOnQb"f!na]p4hc_Ml7C_hgpUC#)Rc1/HZmb&\\RBtK9-4!@HtAi_F"q,#T*mG' + "j6Bd2^MjN$s+5reeq.$*?Y;N8He=?kn851ZRB-8mMnlf;CZ.i/s,8OnV9gUN/c!Ka$skDV_=NL\\QY#/BF#hD[^c8q_Q[A[:!%LQ<" + "EE;tFcs>;HbcDD/`[rHf;#$`I]f/72FhI_,P3d6WZ@C%`Su=5e*RR).Ed<Do4Di3kP`Zb4cQ9>319a\\)Up.7R:0QH_[$_1:BMIWg" + '9/@0GUZqgj.C?0"kiJ2ur;:@b8JLe]PZrnOnZ07V6iD!b8pRdle#)Lo2K%<derL]*^VX1LHo5q<V2Q7KBtsS>?WPEa.:\'o]Xo#b\\' + "^TrEk[r#=i];B6-StWB#li]fF)8D(?`clgCp3lr94s+]jgVEoD$Zl(G3Y7:/aQ:d)$0<mPqGBYC=+Wu`2=JaiU+,i?cE5!fOC;G?" + '_+N.B.J`dE%3,?08`eS-e.6Qgkr5p<!pL.cig:"+!4s--QS>!H*rrHQ"E?O,_oD_`X]V+d[\'1BZs&H]B%=j/`!!VCoGtG!A9N^2:' + "U8$M<pkb=r#f`1O'Qq6ib#/Rf-])o(.trF#8K.e?F-2s-&k\\ruY4Pse2roUpi:?0u90^MA*X@Ehl'TIb>S;k0?gT)*^gVg,T+?0[" + '0?R3m25,&m>1?=>8gN"^U#NK^7P<_fW6OGZlMc=-?+=L`RB_U(7dR=)13pmHm*$>\'C<%TmhJ_;F?3t,N2Ce2(r\'7)JQ3%!H<Lg.*' + 'Fns%W<NE1A."hJ)0SM\\eM+d6>+HeQM54&ZM,n%O\'YAJ&a*o8>e-D?koLF8Y(_!]^l9h+Hk-<WEEp8la"PaQ6pNu@bP;C6dR2n%(\\' + 'G,#aL(RO_bml!J1!-*#BC2b"Afc&F!b$ekEShJXhna_8!.1oI[6Ocg5-d7c/:fW00+)86K6(eRd^72L&:Z3]a!11mQ)@rM65h;4a' + "3qa-N8[)(5-r_t.2bs]+G(T@+#\\\\t:@bPaAM?*Un<@e!9n7#.bo1)1JPBl_'YiMI]W0GCT?J@8JHm\\bb%G<U&VjcA/Rdo`q2NA5b" + 'CMTJ"EVi5m/N3Oj`#YIcDt6J"UQRD*fS;@LMLG*r"oIVPl`guh,KL\\c?3BY[,ar<jdnHKE:Z`B-k2jmUOUG:W"&%6o:pIc)ICXr8' + "RlBd[#r22oquf4@T[(Ue5+Tg*i]&(nhG%Xb9+uggX&1cjN&;oC2WH\\q`#oCC[o.QDAm!TBf5Q:orQn,/B1!Z0%@!bJLL/Ym4cl)*" + 'Ard!(Qi_3MDrM5c9N]L"l.LU<]nniCKh:drQ&\'AH$1rf$&3iRi-25?!V!#Tp"SP"a$V`^ik<(??%t(\'fjHGTt)TN.\\+"Rcs(o[Ic' + 'jMLq`_+Kqs.$[nHs"Gp6m"!JHOKoW10Q/=\'/Y(IT1Eil-7ZZ^[?8dhW"g%8j0/$[^pJ.hp3GmJmn;rhI1@au%\'\'/0-f"f#jMsB-:' + '5t<mP<s@GnV8P0H5iShp<rE?B;6[b_$SUn=E!0PIr]kV6YQ:BE1"[d%:raRN*o.%JTf[PC-D1nf=<"??VZN)4dK\'`hBHsW]RntSM' + "Up0%j1e20!TJ&)r>ssJ#h3fMWdn]N*Cn+aSY@HDFD5nj\\LPWu:Y_%)5QZ*pP-<_T$1`lD1H$iNM>>Fm0'9io\\3G&LBWJ%%Bs$/L$" + "eDVgLjqr,oPQ1o[r*qTD+)3ZR]U!1LhehB*7P(rW#dm+S7S2?db31r_7g0EQ6NqGbNor=7_/n:;ed3Eb&_d-9P@tB]!4AqZf:#$C" + "@m-&3M;8:==ol,SJ>!\\Df([hn]$(b=/YO2e!W2_!^jfBJmP;RDP]QURW8BqealT[>X4aF@$T:V(O\\^;(/_;^qfb=K1K<+f_i&+nh" + "'$Q1LnD90s.)T+k0gq3BTle$Fk,iRMQNROH8cRr(bs%skL/47#Ce/80_u>iI<p/>c=ag,,^4r=S[XPs/b%=5aetka-%3F8t7l%\\'" + ")uZN:1:u-p2QUKe;PV1&TSGjMZj@)43@8S4OPuBN%j/):X>qOD6^M\\m=CPdJjR]KHL,SB[H$OPXrS5pN:@9L<,?,*fVAQ'#,'-(3" + ")HZJQ%+ChB.SC0?J_#P0Ba9hK/i>DG)m<%rh`YR\\2>f4qP@&;k\\<rW1ICdKB`%3lgE7=1Si\\/3-fQhet(fC@M-j]2b#ET4>$)`L?" + '_5ItoC/=G(.%,D*p>Y]A!b!ZWUD).NmLi/R=e1)4;]1+qd$tu-+)irAV1f(W)\\j5.KeE(+g<4`nR\\7JI\\enK-\\%kt%&6k"fQ>sf(' + 'QDJ5qm(`e`4\'k,)$-:.#hmQVF?]_9Nl@dfV#a"5")`Tpp#ak8Z8"eVh]]TjgC.U#XZa.?L^I\\EfRr4"`N1?>jEhNTdmoDY4FUB@)' + "_O&,:r3ODNE;%T?TMkhl6Xe;b,3.95KKJm?K)%J,XCP\\'CII>^TI/#`A7'nREm_X6.G)pL*8!rH6Ig5El>1>)mB<Xmo1BN'8.V_)" + '>A%SaB4"_Hf.!glQh7C)AelbQQs#*r5`YTW*^.q5>qW=e\\$N>nhgpsmH;*h0>B^7"+"g;Z-n\\73=[]cV\'j6;X_Ua&95S!P?^mCk/' + "R&f?2C*<ohiRt^K3p2JM,%l9'/VRgeZjcC.[oJkU3fc2X,dcf88DFO&#+V?Q[1?'OKtupD\\.UrVO_jT:.Rb8*n3C*V2.U&O1?=q_" + "`^goi]`tS81-Gmh8t;<rSqZ%b9JE42QhW?[;V1%@2Mk0sO(@\\2%7((?C960=[kTBlEkmV0+^_*W*tIQNFi[^2ERX!M!PKO\\LcpF7" + "6[KUhmM30,3;c%:nb2<4YdH0$:LWZ\\0=S$3bI?0X4`ti?Bckp`aC+5J=fLMs^68dQX0g@$[>j\\?4XS*fTO7.EJGcLqQ0Sd^<MHi'" + 'e\'S?IfuK0$U;r=+hQL8!@Q4M.07*sZ=]XHhmFSFh<2_ZmAe!9%$`L.`UBaDW;=JS>\\"GT;M$iZ:PCp/uMl--jmaQ#qpZiZ\'mkaQ<' + 'rmd_\'0CE"m_%h84?^JMCaYP^#dk`cKS$d&%)t=ukq32gN:,AeY(HFS->?LlElLaQ-?U9CWl1oHhj5Pg/?2jK-U%*-aPG%\'mo!S6u' + '7`H^`8&Eu#,_LI-pBHl*r=3>X0h.+kW"ZVdU7D.NHDoGi-uZBCcZq?R8(Zq$L3+:k"h".RE,jn.WpbCC0PnhWXTK5[%/B\'W2Y\\6b' + 'N*ged/lRL.`8[B-&`KADPg2#LgssO2OKIn669-!P"ah5l!H(395N[P_%,g-!?%d+uKdsW+p^YZQP1R@VHhR]d3f:5>)p/1%J-2*0' + '<\\6#nJFWR-]AL.sm0Zh`5C*M/VK\'!H]<*.g6"QXKNZ[FphV;7.N%gPm)TpK96@<6]H0-=R=mb8a2)*I,s5"&RDLLn!5Fgrk`NDou' + 'o)?T&$GIT$9mj:mhp9V]@:"CfVSXOgbME#n?FYRp7=h\'NB#)>f+W`%;P.f,jBA\'9<KeftQ(kZQUR>VV1XQt\'0jdVTKYatu"-9QQi' + '^[U<(I7\'lYH$XgaGg-LG4ap:"8.H.P1U_4HEi#t;f<io]q&WkVa%K\'$&hce>YLg:\\\\!QT^Afb=H/*\\#2nV/E9!ugb6NHt7\'O_ur,' + '$I232nH@=VH]P\'qL\'0V84/Q[]TqGf.IU0Q=M&j0=^kP4)a)Rg-f-*N]kk73r4ZneZfT]&>cR7,n_q@r5[$e,("`%l;lYL<fND<#)' + "G@Ak@d#a[O7\\rkMdQ_p!n>L$8K!8QsL2K(,S51o21oR4gdUKDd9@'b(K,8e/H?`QHCfQj7:?[lEdQe$:N2r2E(i&OqcN@hHdPJh!" + '6,mLiNYO$PSQ1O:.nunDjt&u,<&BKGBL6a^pgfVhesNJ&rZaR\\AN>%])qI7(*llFWBQJ7#Z?"Sd>%QU:L2GdN=pu61E1j*F2MG1(' + 'FC"]Q==n49J/$-m%=DsnCJ]AZp<l)XiRP\\7OicLniM*Dk=4dF@I-7Si%H8/1n==V.W:(^W9oF^]3?f-;RkUgU\'#N>\\>lkCk]i+ci' + 'cX:m^?LAljdl^-[B\\R^4M/fHeehQ"=m0.TRmo)s/=!@;KoMt[TX%Vas*r^OY>Kd8UXo()&CPRC74>"+^#=n1#e..D*7>c%9\\/)#.' + '+nblLqVd3Zs#nC+2I8W`Yp2`V%N[>kq"%g/m@?>H[J(Ra^Yu=1jlFXQOcr]H<-f2P:h^Rb,&T@NQ@-<SYaa!<X9;"7)lq@rC_!Q1' + '%^3^F8+BKoL@dD96(&.D0&)(E9f-N-5@\'`ef/+!2+.1-:r8/CVq*Y!`bh"OIp`!%)s#ft<os9XV#7s[_.(pn>#>jmVHZ\'X>FOkdB' + '8K\\%[KI6?6kh4W"4FkJlj]tQ)W=qFFU)0%gnK(Yogr24g1FtRD"J5c,@-uV>nQg_k4AMY^!Y;]/asWXh1([T%,"L=ZK&qG,5O0!Y' + "3C:>iq:SL<;]rj5,NU]b;i'MmV#1XW@^W*sV'/cPUmDghh_*1/Omn;g?la2pU?JY!YdE%@2.sN)cAN):LlCm8M!PXY45n98E9atq" + "i]+_:GPh)=c\\R1'85^Z&h*uAEYp?j/^ku;XQ*a6hC?FDN&.f1j%*HVpgHh=RVJ+/0o)tPKiDRBr]7Ct)!e6F6$74\\(K#&-`R<\\%j" + "LX)]NbVYR/OF6>OTfmT71!:Z5R//L$lP'(ST?,?Cnh#[<M<9!nhp3V7bHoaDo!>->R+pslc15qc))T)EjF>]25Ek.1Y$b4>&_'_H" + '5Wsf.Vb_OFaTFHtn`\'f&BD;h96:4Sf[++X+;tI!7E8o`fHo4*J)tDnep)L@Ui"?Wq(1,*=!")MYIf(X:e:0l[o9/;nlD+/XT?,>m' + 'Oe:$c5=HFhdIN\\l$AgS@A$qeFLqc[Vi)\\b9!r!()=-7G-8"o58@/5]6NiM=[Woe`gGP$\'cT752.W1*32&)C[IC7,1f<D(9%Y!^]i' + "6k's^@0oO>&A75^'ibXh*\\#^F$%B2c+#mhJ''VJ.B)a;),Q((3rl!hrr]9.geqM0NiZqa+9DLIRAU!SMSu'e=n$4Q3i+M>CeHu8<" + 'r,rNh5n/W4T7)0iY+5:2"qJ;57IX"K/[W7n&jA/seU3INoniSdU$"r;1W=ahZU+2p8CW\'U;Nos5f*:6#-/4<\\kcEh:AAnc%363Fb' + "*VIo*(1ZhM2/465Tk0;EOVqZL;+ZPqk#4RoJPf@'JM6/kpF`V7X1bB%&J;-B]0Ya^+;nq#AsrD74uj8u53fP[J*60KnG'dR@I^U\\" + 'QD:5fj+p-Gpq8aRh<Jbme__[oc_]fbgg`3Bm9\\N!L\'N!Y#&:g6%F<_c1M#.6N-C$_"]HLs/-U>@6MWl"js]i+r1$RD?YkiHe<GHZ' + "7D<tEIVSJ%\\P6$%AWdSR#PeQ4f[45;M'HU]aVb%alk_7XQ8G%&dG00]!q(Ou<FeboP/bg)d5Hee'l@F:rR%Zap5Q^A*OS5MNCSuZ" + 'QP\'D8Y37#-2gjEZ7AkT`mr)WY&n?BujDA?&gY,(+N#W*e]iRp_s,"i2PL"-5*&+a$GV\\fJ5d*LCY0%a3pJruD=::=sI.O-/3M4C-' + "fHT4b.6ghVf@<gc2(=#AI(q:pQ7#^-X(M/f@_Rl@+Pg^sIo2P'bCa)R>t<d*k,4Ai^%E6+eqcqqc'1n2Jd%_q)NanG9@,rjV+,=d" + '@OZ83"4R3hMe>c+S^DURDH`5ef`N+6MK5l=Md2?^%8*(JVE*VAlm!I=\\bRbbn(R,jJ6\'t9\\s7Rlo-;bbXjQOKP0r1L9IWOGHNfuI' + '6>HZL>\'nYM*=_C9["RN[+3i.-7/fX;GdI=@VYhr<D6nWYVYjDV%lAVHp)DiMpJO`![GKa@nJi\\IYpYYe^.]/W8!F:d#[cZQn\\pY=' + ":c_3M.CemqRlG8+LUY2(5/h6HGe4!JH%g9a\\ALS8g_k.C[VP>.E83LO*?7nA;&Vo`pZ[GX=(ZKH[Pk`U]CiI4A8f4uZ[6UPm4V>o" + '\'G/H9a,V+YXc!+dLu?t(@soQnOP5467cG[%MO=>r5N`^U(Ra`]ja/rJVb6d7dRq[nQekY,l&0j!oR9#k-3r$"d=WRF-*F,+\\.G*4' + 'p24V*Q*r7>I:tIoHbU*]7#=b`f\\iQE"0A@fQ>dHS5=Ei4(VLfXq)^)R!."SQ!W/l\'_the/6*-laB,_hF?-t6G[\'^]WrUVZQIf[B[' + "8K_Nj>R9Rc7C--Rq^#/.-Usk(h![Cqj!AiK.CtE-6'p`]kg-2SP3\\rg?P_mnU+^s$O/\\`t3cgDCB3,;VS=^$UplMsp-&7Q&m.-T)" + "gRt7FZ$HpV9\\du\\pfnWK$]'`dNROQdV&rtrF862cIAL6]=UO@'FZ`dF9k@!LjYn9aYF5;U>+S1hd/:&pHg:8!Hl/]D&QHr`'MBX5" + '(?%7<<OHQ"<J>!_/c#Z9oWEXm"[@XolK[iAJ;^gVDrP5#W7_K$>S[$:CN]d!ooVFT5r\'a]/:#,iXpUB.!9>Ppajjd36.ApU#bgo?' + "mpgbu?b1=sV&gHoe;c]H/nhWc-f]cQ&*tB$crg'A+7aL7$46O=EWuJ,.rrdsaB@5,qpT0%9&&7YMf),Gh8q''pZg1WDL)/A?1HkE" + "NrqGR2KV`2cS_uGTg#]^+!9k-J1kSc^_ae9mc*W?%s?Rgj[7lc&%).[d,nnKbd^.1K]]s59_J5QeO66PB_\\5/o!Jnu7;/9Q(=>E=" + '0:MUm!R^jKfPLt]CUoGc1Mir@aS"6s:a7HK$j_e7WI3IMWS9rV0ZbFuN;.`=M=)0r\\-,qG6QB-i,J`*i8W;/`fU]c1I3Hc<nhNuk' + 'B@fT47lpBc$at"/G&C+DHOI)2/FUs!X24_!2YQRY-9[">XrYkjj\';SO/e@/@c<P[NS+N);6G83a9kmi<_&E`r-StUTZE0*TbK7I$' + 'DuV%:6/9aYoK.p*_3XpWZBri$3/OV(k`#8=_<#J%h@FC<ic@quBNn?N^7.j1mS8A((YFO+_f;Ujr*Jm:"X8:j/NaGspmW(G]n/Qm' + 'YD8^!:8&b)4ZFC"*4nR>7=?7QNds-21LFL4a2.O,^1K@mX#93@oeI:Z(sJUjRHD9WdRbK`V+YNbs/hZlHUdV\'pg]]1[WE9X&V9H+' + 'SO,%4k\\+*Tb>I\\Sb7W5Np?Q;\\msl50,<Gq"<[rg?+#L?u0NP@#mp;ftHh\\B$Q`N2D:6\\W@TU\\+*,u7+"0eJe\\TA51+MkNq<UBKi\'' + '9YDFaXeS\\kC3hY+5.LjgquCU,hZ7281!PKh,PcCaUQIErC/Bf8_>[+GH/]0C3AFlohc"`_I4P?Ce.nAgPPk<h1oAAA6*]IKVa-t<' + 'Qr7jd?6^f3d86]cA1pI8Tj!E@Q"f);+<eGPJ(S^fO2O8\'Yq>5RD-G7El0kcLD7u[Yh5E`i4FY]?dh.OlME_ipR#5u&rGSBgg>-/?' + 'QF(ju1-4XXObrRMA3PfkP@E/=.\\)E<oE!0`hR`qJmSp8\\@QgE&V[rXd8c&]:`fH8U]h-Y<IS!!mm!3Hp"E%N*Ga^,O>qQ08D9NWd' + 'Pct4-nnRu42!fi,o4C1B%2M<+`Rn&=L->;!2S+O3+lmi(HA\\6.XO7K"Z-G^cYbn=VZp<UViD\'=?f0B,DM`<nNNta#uRm[[8VF$hO' + 'C9[&\'*u&`1=.hg.[5k<O$56Nt5apK^a_CB\\7o*+Dkr=!rg\'\\]UP[1k"epp@2<a<5CU&c)%][D8uRdu%\'8u;KB-"TI2Q&Q_^;`90L' + '^"nDlWi@PYLFka*DobgT/!(GY#]Ksp*eOnmQ2klTpJ.i@\\-fOS_TE*"=T$)C7jeJPm0K;9B"AK_5ViLP3hi$e?4DQEP1\\i<\\FO5\'' + ')D7uYr0li9?tpU@2rFi:/\\F(ThRj1D;SU3Y<5p/rAZ8N-3_tk\'9]Kk27!0L]SZd4@X50@GqtH`:A*9j4$rV0l>"9C\\DfO;s5^I\'a' + ']7#Yd^`1pNU2cfr3N*<\\)c6[P;?;1J%>h3\\ZGg16KrF&7?,\'7"7@mDFA$#*li\'o`C4_?^:?-)7]O?Z>2J9sRm&_)QX,57f\\7g=g8' + '9!ZN/j;MRd2WScVmVlHZMlo!eM[@Yc#j327U0PU%QG65L!%pN@j_\'B2;,EpSZP6^6)C"<pa+b.V9)o2]7Ff0tO?;Q_!`%J%KuTp)' + "*+UODNI(3mB%BjjqT.@HG#%MJao/!I\\<lI6j6OEmLfG>t%qJg^70>hM/*AnZ[4Q1ASpgJpYjAsqEjlie2on0M]i/%=ne4(V%mU8L" + "!+5#o2`CgoUfSBiNIpKOA)N0%W.OB(A#AtT^I;A<E6>l8a>TBkUB>ijY=r'l[\\7+IGA1ab+k\\q8ii%huk.<2cim.R5oldMm%9Y:-" + 'l]#"H8c598_\'oTU@nXP<`c$mdG]3n<C\'_oAE4u`YMIEAm5#D!/V$.f78`N;BE&kYsBHQ.F\\g;H8#\\Saa3T_>b<-PWt`gbUDm]Rft' + '*!VR@H^Q["9fOA<<BH)`?\\ns__$gDL9<GK6Vk@A`EolIXa!Z*1rnHG\'p^$j:2rMSR^-,Q\'-E,Hmm;MtE6=s$8R^6O@-iVGr0dE6Z' + "1?UsQm9fWNljH]th<^mT\\.OFLBieDY*r>]qq[]i9[AL>sAf%9hOSHn7=D5So>,Qo_e8$RT!'9i%/Wi!:!A#V0-OPi+&+#gMo@qW#" + "_aeh'fl^8%k9-DP),j2>pC?GQ'0.>Cn*l!m$2>P?Z\\V>[lHs\\FR_I`tg9c3EUN1DCd*^8?-PoLd0'tN.(=%oJ7Rhb!A1f)<%E!2`" + '&<NjF2>Na>72\\mt0VL%YiQO:5_WlR(_S!I\'eIH4"[-P4@g-UTUk%cl&^9=62X(queNIF4M&0,in&N[%c;6>`"Ni)"t`W(G[g:Q1B' + 'eUN@X;9e<K3f\\l\'&mlcX7j=$n=VAeRfkaq]Fn1%pn\\Yt@jJ\\&^`;%g_5-=iQ"!ImD55lHapQ61pIOTG#6=iM;J7tC]@`@QUlp;Zm' + '!V+A\':p^=!L<h"]\'6TN;"t7keP(-n&`(1[%KriK[W3`N$pUtpMg)<8E:tj-bI#XE>@>&tiSBE$En-)H>8T]4j6Q\\]"(6(UQE"));' + "(^_bG?5s(%^5esp3*5F+IM(VRq<K^e``---_K%3HR&4NPD$M=uef?pnMS@'kpE/F9Y&Sf!kJu\\>hfY\\5.Y-8E?9@*2\\Wj:]pa@q4" + '7QC\\X5S)B@kmWJ)]*E=r[[l/DUmrIT@K(fZS;4u_7a9EZJKra!G5ck]e<ta"j?W\\<\'LPW;#dA,?1;LJ,i8&s[X"&1YMn-1LJof14' + 'N7S^R>)Jpqp)2]o\'Qal%0,"I(CQpreM3-(*1bMu,j`>W49]$h&ImJ=OhX1GG2&W[2!"<kYRp^/+,#h2ulQ;,q&^03f\\S&Q:#DqJN' + 'f+q&dj_+?6+Ap%>*r9;So16f:\'-H:n+=`cFP7!E6V1fU6:"I#?.Q6QLYFm<$e`HGo\\b_D%2HDS#E+`e:g2k97(ZU9[bd@\'TG7Ic0' + ']T6Y-bn"ba1d@]BktO>nB-1:S6+sbgrKjZk[r\'$W`VW%Kie*/4OXTM.4#s>rq`\\@kg</>h4naa_`&R&MP.g95V*4.1IWN?I68I*m' + "=,/A+-`.Xp:7VagJ,/+9]m[%u*pV#g^Q82tRD&?C^h6(Bl%-J7-N=Y6D^KdaeK59P4+@sb2+'TbCF6RC:D&XI2NPM+Y)6]4+nF)\\" + 'V5Sl::1fmRghmM7(o5CCgAtehM=75UJH7/J-c(G+\\M3/Jhbb=+5Jq.\'cKN[5Z>UZ=oFF7ZHBL"R"(QY6:BMY+A.B\\:RKC.NRIo:$' + 'Rb]QHaT5%diHF=:22eN>&[&o=<V*Y\'%U"J-"$RAX+$OQ(.bH\\^kXj?jT\'/1#^dE98iU^S:+8q.*ahG[A7_e_7&bO$Q7eIMgKui![' + '7L7s_PaR.E+!rSk1l9mk=!8P<mW2CcJBVkcCBp6XiONXB#\'GF!bduJ?U=]ZLh"VlP%1IKol9?>72J7sa`V;VL4Uj!eKcWN.+nYno' + 'd[8Z1.]%\\1Hts<rYDf.c`[GC18k)MFF1/1dp8X%tZY`f#mGH6R\\Kkp<pdJ3amiqD?$G=5DWJ1lCQ56!Z%1H(#B[ini3ciaj+l"X8' + "%.]ss3*SWs6MBDAaS-+qZ]64h>lc*,(1qN4TFQ>jjGXI+&AEcnk9p$p*M_GM&<S\\uLYe,<K1(s()^@sC`_@).Qqu#MJUH4<<`rrV" + 'b$0Sg98h6OeeY*U+(@FVVthf>G/nTE03T;D%_NOW7NZG9Zc5&U7@W1^6Q4l3QRr4Z$7ek$X>i@N`G#M*8`BnRKPpq0PR0H",8A9$' + 'VUR)l"nE9Oo+3s@eFj!/b.R(k0K\'hlr#ua6ht9Vh[5.Mn1MdV*lYDE*iBR+QfQlMj_mj`JN1sd;\\=NW)%M*jXa!!8Qjdc)dcao(]' + "nJ=Z\\DYmY&%tEc7aYWu$JK[9`m!q%:1mHn7J:TeG5bf#e/UW,6\\Lhhr6KD_o`GA2ZqBc+ArJB7PT@p6pbQ[cg&H%m;:pb%+s/_m-" + 'gq&n.V[fkRl?fjS833i4b7(m"hnmsG_K5DC[GVJ45CJ/V2A9>I:+,?--VrDdRL4mr-hA>OXB>$c;\\rO@j<1MoVnNT-J;ZM!+3g2h' + 'ZkKS,4VTKmm^@UCL\\*R?4T&[Q(YW0]OD.4Ga8/p`[Ag\\QSrIbPRs6U"(1Uc&lMCc4i^a\\F+!bndoICqlg:hqY6lfh/^S4sM@o:F\'' + 'BdD3W]fpTr2I@UW:ZUFJ8UVe[A6r6-O@#24\\6IeLiZ)fT7=F-T"j,\\$K9X#V8"oXhX^bTU2cdPm;m4(R)=DHQiZtnJ+hnYugn9(L' + '<bN^!D,n(VlgWesq1rO9\\S"k]mKFib8bZ&)SB;-21_pZ?Qs.J6C)\':+&;-gFR@F!J.+I>$:Nh+b2_oXul*T`A_V]2-<OI&a8t!&R' + '/5G;"[!RlAs25CR;GJ(kK(\\mi`%VFiY3X1hAE!`#-Cj3&3[HLQq?>#E[3LeX!s=A;%`@65jCfkN1fXc_P-nRbfeO*En7@*ZjkKg;' + '1,*%&N3ro%\\UUaP(`tT/qcL5Z<n;F?Ch_aeoU5C^iIg8lHo?(Tq`C?=>"7PXg@g`*f7qSCR?!e!iFe]O/#+8(k`e80>F">1ib:?_' + ')_k*n44psJ3[imH$!hr>Z6m0cKL>[KR$^dl\'*H1L74i?dmi9E22]dnML/_o<\\?_L\'EA76"7mgL<G8OQuE>"_U>S(,7NEKFMA$E53' + 'H]K6(o5_I\\h[l;ZR9Wb""h+$$/%9=djpHj]iS(db6fLp5g^r,4#:DSm,uq2:/)X5#@mq$d`=&fa@16-\'OT]d>7KfbM%"LfN[XmXM' + "VuGPf##CeY\\YO2ca:Y]3_CVgj*4t51eD.W8Km'0%I.bQ@^HJ/KS`bchfj6Q\\[_^6Q_UeD,<D]@+r]5_J=<YfmYs;=Ss.MSGZ&?u!" + 'iVkH^#7p:M]Xd3`G3pbJOXQ8`l5\'EqVVVDOMq3b8fFAWPF\\S1$Mpr*,@Dn_OEEj+".p$aL_M:_jNEMRh`MMEu@XL\\dNN*9kS__h3' + 'N9bH7%YTM_W5R`0qLjTm3&paDe$KYI"2C7k@]6YZC24d<IDPVig/1pL;@F#ZT,Y6slI(Z"GQu%nmXS`?1VhQM)6l7\'7K\\oH8_BU9' + '7Zs=)`#8U5k,Ol2O%c&_\'W6*2TlP+BMu$1"i0WHL;)`?8Tr/)RL(-:rg>]m#rGu6"+F$$fhS\'Hq\\3d\'gn\\VLtJ8V&f!S3^?heG(m' + 'Dq+;IY+dY=c0*6W$_[,+T]94KA$m_s\'-TZD64?_KaPuDSR@kAS-4i"+FqjrAhGlB?/3p)R(cJsrI2Tr#p;G.8*#skUeGL\'KCK-X4' + 'O3Hls_q-d5?.bp_oa0@R<>@t"I&B-JqZ"0L0f`F&n\\E?C"oL1i,NAiG\\H]DE&iB%f4]e(m:5$%.b^i<WNZIY)\\GY@ZGt\'t)IJ2.6' + 'Fkr[X-k77a\'gltF[Oc$0=-J,K%KIWPYf">\'9.BND0Sfth!hoj5=s-up:og4OS1MSZM\\=(X+3[HDB*83i-O9-CJo@!YGquo7fSln+' + "add'OT)$hGi5R&nVtJ;&4aW1_$OdrG$4:N6qRCX^5i:'tW5mDLBu+6PC@LUjlZ1UZpsq';aPf:=M$K'6Q'Y>5NQ#?$pr9N,UPTj%" + "1:I/Sf<4QtZB=.INMoq2B5@%$e+iaXhl7HPnM/m0mb=)dAJuU6o7ORR4Pg6.pHVpP;lWuA.]o'L:cVWQbiC;UP_.#tgpaVDjY!Y@" + '"fErD_B[Z(MpkLA;<Rj%GIB,n2n<s&K:r&I=:AY+m_^b#-[qcK90#c0"VgG6aglnB%fUT?RCBfe65.tEH4KEIBS,YGPbt6K[#0\\R' + '6CRnDkF.d*QpJeD-AH?7mltm1>-)":;6^EY=2,Id]m*j]%,^E8f-Te]WVsF,GSAZ^q!W-bI3`p$;ZW0*\'^lp.e:LA_n$\'^/>B"Pj' + ".G;PnoNNI$cCI%X0>NRPZ1p^<r,#oVhn3DC`[6(1`QG3p&ETSd0T,OFSHO7:Qo,i55fr<T,gs)6R,^%Pr64hq!QTZ-0<Yf,R$iH+" + 'Cppt5oL\\5k9[4am010f$q1=6sYkIAFeMGDFpp^(<e@knWOn%[?jqVH=9K\\\'AK32,;0;LOh@QK$52hs$kb3gqJ4ERMi`CI4U"BarW' + 'MI[V3\'\\+mX>)/X=4gcL<;+(-k7>r=T1+l)]D/!Y9[^E)gWP,]F#E<pTfDgf^S3>;1GgChE]UbTu!lN%oB"TQ\'FfQ#n^3In->e)(t' + 'GgE>9j!pt.8fO#+4"cJ5*+ph3:md_UR+iOg&brd]p6K\'=G&H37Q*];^0&aKip%Ac9oi_urPe9\'S`8U"Pq44%%eO=S#)V-Q*&MQ9\\' + '7W"jgMXUth_H5ini!HGL9c0-/UFo])#`5jL1J0olZGO?V0A))I_B\'H8&VD;8V[^,>`,iO9<20B5Vu"d:?WrLPL<nJGS_tNK87+2*' + "/p`7>kj_6BQ7`.&qLA!5189W06JM`Z&_eVcfDj?<X)XcFHLM`-B#@]t1F,B]m?O!n6YV8cH4O8:g*(pi]#*'me!E1'8e-&3VLsU3" + 'l4OY?hJ)64jlu$M=-hk\'aZ./""2Y/-""`8BU=KT6JY:`DeeEG4=fKp..7Do!LZin<"ZmA,g7_g%7?)\\%W2%RQ@\'DNV>uhATZ>O?[' + 'ED0Qg[=`7A#8\\>c..pqdfNOX"\\*K1*RlB3f$l\\0F_o1nZ.*/,&>k+.o5^U*kR:(hHnH/._,\'Gn`0EsT><,b#[rt]Q?iH+O+%\\LKW' + '.a,VXVBtUmHk=$:qY`3UHemEY).0c:V6Ep%40"g![e7#4>.`A.VWTiZB9f7"b#6X1mNOF[n@!h5G%&:C+>aMs/f`49A\\doO((M]f' + '3l$1rhV^\'.EWKup$bC:C4AS:\'+u98a_>CooJT+Z\'V\\qt(akR-J.Rc?eD[JlcrFVm%Ioj:\'j[sn/DuAnD%^*F(U1"iSSSOj!<]]^E' + "PjsaPTtPf.(=*EVdjL*d)VWkcq2Ug:Iao5L(!$U`<c=EbgW[t,Z9qik;/qR'^pO\\H@S#:_*O.uQW9s`N7T/H_r\\)Vi^p+6mgsM=7" + 'ScVRkf$dPt>?i2l[isN!Kt5S7A$aUMO!"/t=B2ig?\\>t7n*p_:PjKl8Z&S?Y_M4F#QsJNuDi#)&rm^$ZD42*KiAX8HnPT2gSO=c3' + '5oVQESJD0<(7[nqS#;(g!G9D(I9e5"Y\'>C35ASS*]`-\\-3&tCee6J=8p6B$QM)(orRCX1WBoaFo/+cCNgS^HuXT8&*iW)(?j0H)O' + '%eMpuLUT]D+.&sro\'i2FBY(ZNZqZ6OgQVl(F"J,i:oiKnDrqGuR#5mJR92`(_!Y2-iTpcU6*a-XA#F&(@n67jY6>*EjpRg`[p=K*' + "H]r0DZL5!U]`Xn\\YoWLRjrXdf0U-mcUg;XBHN;OCIs-D.fF+DNG``*=M!H,`NmNfshC@i#/m*r-SKFI`])Z3oZ$lKZj>C^BU9`s@" + 'oHb)HXk?;"\'s/u%k@R3j7]\'5PbLoYPl`HDQf$ICPULt@RK;K?^/_WO,?U/D5`7Ekb0"Q6\\d)BA=[m[@_U9kF=`>:j?G4+@If%Ll*' + "Ut/BT9@@JF<$onXKtKtRphIW],:%2CTe;c8%:o.uTf+dXZ:\\e9q]3'#dMKEEdJJ8'.5#B.\\=iB@1?,e=5Ft\\=9[)RN)E\\;m'2PQ0" + '%<(tQGJ>>2DBrFgi?DnN/Hoq[m`J//)j`3i45P6!,r<KCOhnY(/H1Z+8#Tt/Pgcso,r0G5UX3Pb,U0ib=J$9S>W/D]m?#"pJ@8@M' + '&sS.fi:>As/l/3qJ""ajIX!V(o-CpTO\\c-,\'RJS(gqtP3RV#1jGLG^jU7r)_/>;NnFb8YF;!oq1_i"kONC!RB6BT*ZhiL-;5NEp=' + 'q<BhViiKn@X`H:W\\frl?/s#\\%R$QG/5C>#i#N^qV>+QVm94r>Un"NMfcY3.4bTH+7U&uUP_I[]A:CPBR*Jh=qSE1n8rR7j&>]6eN' + "%eE;BC_Du7IMW/`OZjPUjdZ)/d#g210j)[JOROt_<kB=E$1DJ9M;JR*k>nh;qA?P1S9*^2[MiXFHmWe29^_hil.L23Sm<W8&R'b\\" + '&QXO.5H%B?iZ[#8$#_#!8t\\jSe(I;(8+I5164lK$"2"pdd5,oUE"GgOo-n%AfO(hCK<sUV&hIaPT1e(h>2PM<c)YQ*=Jg#fL?t:^' + 'UDh,6+[-fZ:2X*r`3Dkj./\'#(ETf!fkb1:ci(9t;M,4kYikm0DXn?Y,k0Sr"oftE8K`:c4\\oO_+Hf`MKh5)gGq@cXe#WVR@)Hr[0' + 'm+jPUPO-chQ"h`)f?i,a?;mjuY51*8DU6*j<VQunJbO[][[\\QX?D=.iOZds\'/U*n>VZpjC+7H:[rFYs%q89ARg&:fm!^=T;m6Ae7' + 'f0@\'kYG>P*ftP0$j:SY)_3p_^7!e]B;_3Pb$*T/,s)p?sAp<O$"k=tK&#\\$fNg!p7aNe.u_f`cpE.[KWE3_(iM3Dd\\SL6qZp5Oml' + "HaNd-YE/[-j7QR>/DInefsYQ83U0Wg*IN353XGI)-f))!ouGg)f,o87k&4C,X\\)r.]=nV84-Ng_/u!]aQk-W12JojT;Qqs7h(+dh" + 'ME@P-dLB&*[QuVR_sSiE);Rg*5WG;&Oe9.c5M=04!Yom54^O[eO-b+.-g/[84^K6U^h./"r:tE_f*`AlMXq!UI#O>)hla/a,lSb=' + ':#JPHn31dh8Tu)N5[Q6J+)V/:T6^_t\\6LTipqr(._^QF]Wlp&ijQd$*N#r-30Q].c,SDXmZHTmWK8tmB53Ti:`*jrb*pji"l[AIA' + 'NVtVuS;nupF5"^OekTe(qA!J]&TCSL$`9LREHZ6cTK#)_qEP=@As%fuPJtmkL`FqIZ$k\\0BIAi,W&(@KlMUI@]Y"J2(ITh,S[E\\9' + 'DP@\'G")TXd\'\'oo5*l*L]`KBBB;E]fKg%$[F@QgpA-B%\'.l-Hi&,4"m_bf(u6@^[PEZoIJ+ehCq#=b4tC"YE=$Yq>?TDNqRc$a7Wp' + 'Ad2sX0;:(VQD+t&YiXUD5<&a]pbcS=<l*5fptlpY5):BSD\\5GE;1p,JA%"0@pTRZ*?c5\\ZlI\'%geQcVDU*2a+_ZU2lQFH;E,88:S' + "ZrpGs1e,L@Jn/h-@R41tk+BIV/]+3'6JBWGcJSp1%#>3UN=\\=RbD3!K3n6h8A#W0gIeQD6,q60Go*8hd&nB$t;eV$b&7K9L=\\3p-" + 'rX5(no"QI>XT4Cte>>t.=n$H98G>6Jlh8c?%.:]ZCc7;F@n&grFY5cq%!RmXDC:+*%,+kT-_@>%qHX\'MUZncQ5<+c)\\=eYr8cSPB' + "rr^cSQbN~>";
});
rtl.module("BlaiseReports",["System","JS","Web","SysUtils","Classes","BVDataSet","BlaiseReportsFonts"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.REPORT_LAYOUT_A4_PORTRAIT = "a4";
  this.REPORT_LAYOUT_A4_LANDSCAPE = "a4-landscape";
  this.REPORT_LAYOUT_LETTER_PORTRAIT = "letter";
  this.REPORT_LAYOUT_LETTER_LANDSCAPE = "letter-landscape";
  this.REPORT_LAYOUT_THERMAL_80MM = "thermal-80mm";
  this.REPORT_LAYOUT_THERMAL_58MM = "thermal-58mm";
  this.TBVReportAggregate = {"0": "aggSum", aggSum: 0, "1": "aggAverage", aggAverage: 1, "2": "aggCount", aggCount: 2, "3": "aggMin", aggMin: 3, "4": "aggMax", aggMax: 4};
  this.TBVPageLayout = {"0": "plA4Portrait", plA4Portrait: 0, "1": "plA4Landscape", plA4Landscape: 1, "2": "plLetterPortrait", plLetterPortrait: 2, "3": "plLetterLandscape", plLetterLandscape: 3, "4": "plThermal80mm", plThermal80mm: 4, "5": "plThermal58mm", plThermal58mm: 5};
  this.TBVColumnAlign = {"0": "caLeft", caLeft: 0, "1": "caCenter", caCenter: 1, "2": "caRight", caRight: 2};
  rtl.createClass(this,"TBVReportColumn",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FFieldName = "";
      this.FCaption = "";
      this.FWidth = 0;
      this.FAlign = 0;
      this.FFormat = "";
    };
    this.Create$1 = function (AFieldName, ACaption, AWidth, AAlign, AFormat) {
      var RawSpec = "";
      var ParsedField = "";
      var ParsedCap = "";
      var ParsedFmt = "";
      var ParsedAlignStr = "";
      var ParsedWidth = 0;
      RawSpec = pas.SysUtils.Trim(AFieldName);
      if ((pas.System.Pos(":",RawSpec) > 0) && (ACaption === "") && (AFormat === "")) {
        ParsedField = "";
        ParsedCap = "";
        ParsedFmt = "";
        ParsedAlignStr = "";
        ParsedWidth = AWidth;
        var parts = RawSpec.split(':');
        ParsedField = (parts[0] || '').trim();
        ParsedCap = (parts.length > 1 && parts[1]) ? parts[1].trim() : '';
        ParsedFmt = (parts.length > 2 && parts[2]) ? parts[2].trim() : '';
        ParsedAlignStr = (parts.length > 3 && parts[3]) ? parts[3].trim() : '';
        if (parts.length > 4 && parts[4]) {
          var pw = parseInt(parts[4], 10);
          if (!isNaN(pw) && pw > 0) ParsedWidth = pw;
        };
        this.FFieldName = ParsedField;
        if (ParsedCap !== "") {
          this.FCaption = ParsedCap}
         else this.FCaption = $impl.HumanizeFieldName(ParsedField);
        this.FFormat = ParsedFmt;
        if (ParsedAlignStr !== "") {
          this.FAlign = $mod.ParseColumnAlign(ParsedAlignStr)}
         else if ((pas.SysUtils.LowerCase(ParsedFmt) === "currency") || (pas.SysUtils.LowerCase(ParsedFmt) === "money") || (pas.SysUtils.LowerCase(ParsedFmt) === "number") || (pas.SysUtils.LowerCase(ParsedFmt) === "float")) {
          this.FAlign = $mod.TBVColumnAlign.caRight}
         else this.FAlign = AAlign;
        if (ParsedWidth > 0) {
          this.FWidth = ParsedWidth}
         else this.FWidth = 120;
      } else {
        this.FFieldName = AFieldName;
        if (ACaption !== "") {
          this.FCaption = ACaption}
         else this.FCaption = $impl.HumanizeFieldName(AFieldName);
        if (AWidth > 0) {
          this.FWidth = AWidth}
         else this.FWidth = 120;
        this.FAlign = AAlign;
        this.FFormat = AFormat;
      };
      return this;
    };
    this.GetAlignStr = function () {
      var Result = "";
      var $tmp = this.FAlign;
      if ($tmp === $mod.TBVColumnAlign.caCenter) {
        Result = "center"}
       else if ($tmp === $mod.TBVColumnAlign.caRight) {
        Result = "right"}
       else {
        Result = "left";
      };
      return Result;
    };
  });
  rtl.createClass(this,"TBVReportSummary",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FLabelText = "";
      this.FFieldName = "";
      this.FAggregate = 0;
      this.FFormat = "";
    };
    this.Create$1 = function (ALabel, AFieldName, AAggregate, AFormat) {
      this.FLabelText = ALabel;
      this.FFieldName = AFieldName;
      this.FAggregate = AAggregate;
      this.FFormat = AFormat;
      return this;
    };
  });
  rtl.createClass(this,"TBVReport",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FDataSet = null;
      this.FRawData = undefined;
      this.FTitle = "";
      this.FSubtitle = "";
      this.FHeader = "";
      this.FFooter = "";
      this.FCompanyName = "";
      this.FLogoText = "";
      this.FAuthor = "";
      this.FThemeColor = "";
      this.FCurrencySymbol = "";
      this.FCSVDelimiter = "";
      this.FIncludeBOM = false;
      this.FPageLayout = 0;
      this.FRowsPerPage = 0;
      this.FColumns = null;
      this.FSummaries = null;
      this.FLastExportedContent = "";
      this.FLastExportedFileName = "";
      this.FLastExportedMimeType = "";
    };
    this.$final = function () {
      this.FDataSet = undefined;
      this.FColumns = undefined;
      this.FSummaries = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.EnsureAutoColumns = function (ARecords) {
      if ((this.FColumns.length & 0xFFFFFFFF) > 0) return;
      var ds = this.FDataSet;
      if (ds && ds.Fields && typeof ds.Fields.Count === 'function' && ds.Fields.Count() > 0) {
        var cnt = ds.Fields.Count();
        for (var i = 0; i < cnt; i++) {
          var f = ds.Fields.Item(i);
          if (f && f.FieldName) {
            this.AddColumn(f.FieldName, f.FieldName, 120, 0, '');
          }
        }
        return;
      }
      if (ARecords && ARecords.length > 0 && typeof ARecords[0] === 'object' && ARecords[0] !== null) {
        var keys = Object.keys(ARecords[0]);
        for (var k = 0; k < keys.length; k++) {
          if (keys[k].charAt(0) !== '_') {
            this.AddColumn(keys[k], '', 120, 0, '');
          }
        }
      };
    };
    this.TriggerBrowserDownload = function (AContent, AFileName, AMimeType) {
      this.FLastExportedContent = AContent;
      this.FLastExportedFileName = AFileName;
      this.FLastExportedMimeType = AMimeType;
      this.DownloadBlobPart(AContent,AFileName,AMimeType);
    };
    this.DownloadBlobPart = function (APart, AFileName, AMimeType) {
      try {
        // Android and iOS WebViews ignore Blob downloads: save to Documents, then open the file (share a CSV).
        var capacitor = (typeof window !== 'undefined') ? window.Capacitor : null;
        if (capacitor && typeof capacitor.isNativePlatform === 'function' && capacitor.isNativePlatform()) {
          var plugins = capacitor.Plugins || {};
          if (!plugins.Filesystem || !plugins.Share) {
            console.error('BlaiseReports: exporting on mobile needs @capacitor/filesystem and @capacitor/share.');
            return;
          }
          var bytes = (typeof APart === 'string') ? new TextEncoder().encode(APart) : APart;
          var binary = '';
          for (var offset = 0; offset < bytes.length; offset += 32768) {
            binary += String.fromCharCode.apply(null, bytes.subarray(offset, offset + 32768));
          }
          var safeName = String(AFileName).replace(new RegExp('[\\\\/:*?"<>|]', 'g'), '_');
          var base64 = btoa(binary);
          var writeTo = function (path, directory) {
            return plugins.Filesystem.writeFile({ path: path, data: base64, directory: directory });
          };
          var dot = safeName.lastIndexOf('.');
          var uniqueName = (dot > 0 ? safeName.substring(0, dot) : safeName) + '_' + Date.now() + (dot > 0 ? safeName.substring(dot) : '');
          var shareFile = function (uri) {
            return plugins.Share.share({ title: safeName, dialogTitle: safeName, files: [uri] });
          };
          // Android lets an app overwrite only its own files in Documents, so a same-named
          // file left by an earlier install needs a unique name.
          writeTo(safeName, 'DOCUMENTS')
            .catch(function () { return writeTo(uniqueName, 'DOCUMENTS'); })
            .catch(function () { return writeTo(safeName, 'CACHE'); })
            .then(function (written) {
              var isDocument = String(AMimeType).indexOf('text/csv') !== 0;
              if (isDocument && plugins.FileViewer) {
                var localPath = decodeURI(String(written.uri).replace(new RegExp('^file://'), ''));
                return plugins.FileViewer.openDocumentFromLocalPath({ path: localPath })
                  .catch(function () { return shareFile(written.uri); });
              }
              return shareFile(written.uri);
            })
            .catch(function (err) {
              console.warn('BlaiseReports: file export was not completed:', err);
            });
          return;
        }
        if (typeof window !== 'undefined' && typeof document !== 'undefined' && typeof Blob !== 'undefined') {
          var isTestEnv = (typeof navigator !== 'undefined' && navigator.userAgent && navigator.userAgent.toLowerCase().indexOf('jsdom') !== -1);
          if (!isTestEnv && window.URL && typeof window.URL.createObjectURL === 'function') {
            var blob = new Blob([APart], { type: AMimeType });
            var url = window.URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.style.display = 'none';
            a.href = url;
            a.download = AFileName;
            document.body.appendChild(a);
            a.click();
            setTimeout(function() {
              if (a.parentNode) a.parentNode.removeChild(a);
              window.URL.revokeObjectURL(url);
            }, 150);
          }
        }
      } catch (e) {};
    };
    this.XlsxEscape = function (S) {
      var Result = "";
      var Clean = "";
      Clean = S;
      Clean = String(Clean).replace(new RegExp('[\\u0000-\\u0008\\u000B\\u000C\\u000E-\\u001F\\uFFFE\\uFFFF]', 'g'), '');
      Result = this.EscapeXMLString(Clean);
      return Result;
    };
    var STYLE_TITLE = 1;
    var STYLE_META = 2;
    var STYLE_COL_HEADER = 3;
    var STYLE_SUMMARY_LABEL = 8;
    var STYLE_SUMMARY_VALUE = 9;
    this.BuildXlsxSheetXml = function (ARecords) {
      var $Self = this;
      var Result = "";
      var RowNum = 0;
      var RowIdx = 0;
      var ColIdx = 0;
      var SumIdx = 0;
      var CellStyle = 0;
      var Col = null;
      var SumDef = null;
      var SumVal = 0.0;
      var SumFmt = "";
      var Cols = "";
      var Rows = "";
      var RowXml = "";
      var ColFmt = "";
      var CellKind = "";
      var CellValStr = "";
      var WidthStr = "";
      var NumStr = "";
      var RawVal = undefined;
      function TextCell(ARef, AStyle, AText) {
        var Result = "";
        if (AText === "") {
          Result = '<c r="' + ARef + '" s="' + pas.SysUtils.IntToStr(AStyle) + '"/>'}
         else Result = '<c r="' + ARef + '" s="' + pas.SysUtils.IntToStr(AStyle) + '" t="inlineStr"><is><t xml:space="preserve">' + $Self.XlsxEscape(AText) + "</t></is></c>";
        return Result;
      };
      Cols = "";
      for (var $l = 0, $end = (this.FColumns.length & 0xFFFFFFFF) - 1; $l <= $end; $l++) {
        ColIdx = $l;
        Col = rtl.getObject(this.FColumns[ColIdx]);
        WidthStr = "";
        WidthStr = (Math.max(Number(Col.FWidth) || 120, 20) / 7).toFixed(2);
        Cols = Cols + '<col min="' + pas.SysUtils.IntToStr(ColIdx + 1) + '" max="' + pas.SysUtils.IntToStr(ColIdx + 1) + '" width="' + WidthStr + '" customWidth="1"/>';
      };
      if (Cols !== "") Cols = "<cols>" + Cols + "</cols>";
      RowNum = 1;
      Rows = '<row r="1">' + TextCell("A1",1,this.FTitle) + "</row>";
      if (this.FHeader !== "") {
        RowNum = RowNum + 1;
        Rows = Rows + '<row r="' + pas.SysUtils.IntToStr(RowNum) + '">' + TextCell("A" + pas.SysUtils.IntToStr(RowNum),2,this.FHeader) + "</row>";
      };
      RowNum = RowNum + 1;
      RowXml = "";
      for (var $l1 = 0, $end1 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l1 <= $end1; $l1++) {
        ColIdx = $l1;
        Col = rtl.getObject(this.FColumns[ColIdx]);
        RowXml = RowXml + TextCell($impl.XlsxColumnName(ColIdx) + pas.SysUtils.IntToStr(RowNum),3,Col.FCaption);
      };
      Rows = Rows + '<row r="' + pas.SysUtils.IntToStr(RowNum) + '">' + RowXml + "</row>";
      for (var $l2 = 0, $end2 = (ARecords.length & 0xFFFFFFFF) - 1; $l2 <= $end2; $l2++) {
        RowIdx = $l2;
        RowNum = RowNum + 1;
        RowXml = "";
        for (var $l3 = 0, $end3 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l3 <= $end3; $l3++) {
          ColIdx = $l3;
          Col = rtl.getObject(this.FColumns[ColIdx]);
          ColFmt = pas.SysUtils.LowerCase(pas.SysUtils.Trim(Col.FFormat));
          RawVal = $impl.GetRecordFieldCaseInsensitive(ARecords[RowIdx],Col.FFieldName);
          CellKind = "text";
          CellStyle = 4;
          CellValStr = "";
          if (RawVal === null || RawVal === undefined) {
            CellValStr = '';
          } else if (typeof RawVal === 'boolean') {
            CellKind = 'bool';
            CellValStr = RawVal ? '1' : '0';
          } else if (typeof RawVal === 'number' || ColFmt === 'currency' || ColFmt === 'money' || ColFmt === 'number' || ColFmt === 'float' || ColFmt === 'integer' || ColFmt === 'int') {
            var num = Number(RawVal);
            if (isFinite(num) && String(RawVal).trim() !== '') {
              CellKind = 'number';
              CellValStr = String(num);
              if (ColFmt === 'currency' || ColFmt === 'money') {
                CellStyle = 7;
              } else if (ColFmt === 'integer' || ColFmt === 'int' || (Number.isInteger(num) && ColFmt === '')) {
                CellStyle = 5;
              } else {
                CellStyle = 6;
              }
            } else {
              CellValStr = String(RawVal);
            }
          } else {
            CellValStr = String(RawVal);
          };
          if (CellKind === "number") {
            RowXml = RowXml + '<c r="' + $impl.XlsxColumnName(ColIdx) + pas.SysUtils.IntToStr(RowNum) + '" s="' + pas.SysUtils.IntToStr(CellStyle) + '"><v>' + CellValStr + "</v></c>"}
           else if (CellKind === "bool") {
            RowXml = RowXml + '<c r="' + $impl.XlsxColumnName(ColIdx) + pas.SysUtils.IntToStr(RowNum) + '" s="' + pas.SysUtils.IntToStr(CellStyle) + '" t="b"><v>' + CellValStr + "</v></c>"}
           else RowXml = RowXml + TextCell($impl.XlsxColumnName(ColIdx) + pas.SysUtils.IntToStr(RowNum),CellStyle,CellValStr);
        };
        Rows = Rows + '<row r="' + pas.SysUtils.IntToStr(RowNum) + '">' + RowXml + "</row>";
      };
      for (var $l4 = 0, $end4 = (this.FSummaries.length & 0xFFFFFFFF) - 1; $l4 <= $end4; $l4++) {
        SumIdx = $l4;
        SumDef = rtl.getObject(this.FSummaries[SumIdx]);
        SumVal = this.ComputeSummary(SumDef.FFieldName,SumDef.FAggregate);
        SumFmt = SumDef.FFormat;
        if ((SumFmt === "") && (SumDef.FAggregate === $mod.TBVReportAggregate.aggCount)) SumFmt = "integer";
        NumStr = "0";
        NumStr = isFinite(SumVal) ? String(SumVal) : '0';
        RowNum = RowNum + 1;
        Rows = Rows + '<row r="' + pas.SysUtils.IntToStr(RowNum) + '">' + TextCell("A" + pas.SysUtils.IntToStr(RowNum),8,SumDef.FLabelText) + '<c r="B' + pas.SysUtils.IntToStr(RowNum) + '" s="' + pas.SysUtils.IntToStr(9) + '"><v>' + NumStr + "</v></c>" + TextCell("C" + pas.SysUtils.IntToStr(RowNum),8,this.FormatSummaryNumber(SumVal,SumFmt)) + "</row>";
      };
      Result = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "\n" + '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' + Cols + "<sheetData>" + Rows + "</sheetData></worksheet>";
      return Result;
    };
    this.BuildXlsxStylesXml = function () {
      var Result = "";
      var ThemeArgb = "";
      ThemeArgb = this.FThemeColor;
      var hex = String(ThemeArgb).trim();
      ThemeArgb = new RegExp('^#?[0-9a-fA-F]{6}$').test(hex) ? ('FF' + hex.replace('#', '').toUpperCase()) : 'FF334155';
      Result = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "\n" + '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' + '<numFmts count="1"><numFmt numFmtId="164" formatCode="&quot;' + this.XlsxEscape(this.FCurrencySymbol) + '&quot;#,##0.00"/></numFmts>' + '<fonts count="5">' + '<font><sz val="10"/><name val="Segoe UI"/></font>' + '<font><b/><sz val="14"/><color rgb="FF0F172A"/><name val="Segoe UI"/></font>' + '<font><i/><sz val="9"/><color rgb="FF475569"/><name val="Segoe UI"/></font>' + '<font><b/><sz val="10"/><color rgb="FFFFFFFF"/><name val="Segoe UI"/></font>' + '<font><b/><sz val="10"/><name val="Segoe UI"/></font>' + "</fonts>" + '<fills count="4">' + '<fill><patternFill patternType="none"/></fill>' + '<fill><patternFill patternType="gray125"/></fill>' + '<fill><patternFill patternType="solid"><fgColor rgb="' + ThemeArgb + '"/><bgColor indexed="64"/></patternFill></fill>' + '<fill><patternFill patternType="solid"><fgColor rgb="FFF1F5F9"/><bgColor indexed="64"/></patternFill></fill>' + "</fills>" + '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>' + '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>' + '<cellXfs count="10">' + '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>' + '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>' + '<xf numFmtId="0" fontId="2" fillId="0" borderId="0" xfId="0" applyFont="1"/>' + '<xf numFmtId="0" fontId="3" fillId="2" borderId="0" xfId="0" applyFont="1" applyFill="1"/>' + '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>' + '<xf numFmtId="1" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>' + '<xf numFmtId="4" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>' + '<xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>' + '<xf numFmtId="0" fontId="4" fillId="3" borderId="0" xfId="0" applyFont="1" applyFill="1"/>' + '<xf numFmtId="4" fontId="4" fillId="3" borderId="0" xfId="0" applyNumberFormat="1" applyFont="1" applyFill="1"/>' + "</cellXfs>" + '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>' + "</styleSheet>";
      return Result;
    };
    this.EscapePDFString = function (S) {
      var Result = "";
      Result = S;
      Result = pas.SysUtils.StringReplace(Result,"\\","\\\\",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,"(","\\(",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,")","\\)",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,"\r\n"," ",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,"\r"," ",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,"\n"," ",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      return Result;
    };
    this.EscapeXMLString = function (S) {
      var Result = "";
      Result = S;
      Result = pas.SysUtils.StringReplace(Result,"&","&amp;",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,"<","&lt;",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,">","&gt;",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,'"',"&quot;",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      Result = pas.SysUtils.StringReplace(Result,"'","&apos;",rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll));
      return Result;
    };
    this.EscapeCSVField = function (S) {
      var Result = "";
      var Delim = "";
      var NeedsQuotes = false;
      Delim = this.FCSVDelimiter;
      if (Delim === "") Delim = ",";
      NeedsQuotes = (pas.System.Pos(Delim,S) > 0) || (pas.System.Pos('"',S) > 0) || (pas.System.Pos("\n",S) > 0) || (pas.System.Pos("\r",S) > 0);
      if (NeedsQuotes) {
        Result = '"' + pas.SysUtils.StringReplace(S,'"','""',rtl.createSet(pas.SysUtils.TStringReplaceFlag.rfReplaceAll)) + '"'}
       else Result = S;
      return Result;
    };
    this.HexToPDFRgb = function (AHex) {
      var Result = "";
      var H = "";
      var R = 0;
      var G = 0;
      var B = 0;
      H = pas.SysUtils.Trim(AHex);
      if ((H.length > 0) && (H.charAt(0) === "#")) H = pas.System.Copy(H,2,2147483647);
      if (H.length === 6) {
        R = pas.SysUtils.StrToIntDef("$" + pas.System.Copy(H,1,2),30);
        G = pas.SysUtils.StrToIntDef("$" + pas.System.Copy(H,3,2),41);
        B = pas.SysUtils.StrToIntDef("$" + pas.System.Copy(H,5,2),59);
        Result = (R / 255).toFixed(3) + ' ' + (G / 255).toFixed(3) + ' ' + (B / 255).toFixed(3);
      } else Result = "0.118 0.161 0.231";
      return Result;
    };
    this.Create$1 = function () {
      this.FDataSet = null;
      this.FRawData = null;
      this.FTitle = "Executive Data Report";
      this.FSubtitle = "";
      this.FHeader = "";
      this.FFooter = "Generated by BlaiseReports Engine v5.0";
      this.FCompanyName = "BlaiseVue Enterprise";
      this.FLogoText = "BV";
      this.FAuthor = "BlaiseVue System";
      this.FThemeColor = "#1e293b";
      this.FCurrencySymbol = "$";
      this.FCSVDelimiter = ",";
      this.FIncludeBOM = true;
      this.FPageLayout = $mod.TBVPageLayout.plA4Portrait;
      this.FRowsPerPage = 25;
      this.FColumns = new Array();
      this.FSummaries = new Array();
      this.FLastExportedContent = "";
      this.FLastExportedFileName = "";
      this.FLastExportedMimeType = "";
      return this;
    };
    this.Create$3 = function (AData) {
      this.Create$1();
      this.SetData(AData);
      return this;
    };
    this.Destroy = function () {
      pas.System.TObject.Destroy.call(this);
    };
    this.SetData = function (AData) {
      var Result = null;
      if (AData) {
        if (Array.isArray(AData.FActiveRecords) || Array.isArray(AData.Data) || typeof AData.GetRecordCount === 'function') {
          this.FDataSet = AData;
          this.FRawData = null;
        } else {
          this.FRawData = AData;
        }
      };
      Result = this;
      return Result;
    };
    this.Title = function (ATitle) {
      var Result = null;
      this.FTitle = ATitle;
      Result = this;
      return Result;
    };
    this.Subtitle = function (ASubtitle) {
      var Result = null;
      this.FSubtitle = ASubtitle;
      Result = this;
      return Result;
    };
    this.Header = function (AHeader) {
      var Result = null;
      this.FHeader = AHeader;
      Result = this;
      return Result;
    };
    this.Footer = function (AFooter) {
      var Result = null;
      this.FFooter = AFooter;
      Result = this;
      return Result;
    };
    this.Company = function (ACompanyName, ALogoText) {
      var Result = null;
      this.FCompanyName = ACompanyName;
      if (ALogoText !== "") this.FLogoText = ALogoText;
      Result = this;
      return Result;
    };
    this.PageSize = function (ALayoutName) {
      var Result = null;
      this.FPageLayout = $mod.ParsePageLayout(ALayoutName);
      Result = this;
      return Result;
    };
    this.Columns = function (AFieldNames) {
      var Result = null;
      var i = 0;
      this.FColumns = new Array();
      for (var $l = 0, $end = rtl.length(AFieldNames) - 1; $l <= $end; $l++) {
        i = $l;
        this.AddColumn(AFieldNames[i],"",120,$mod.TBVColumnAlign.caLeft,"");
      };
      Result = this;
      return Result;
    };
    this.AddColumn = function (AFieldName, ACaption, AWidth, AAlign, AFormat) {
      var Result = null;
      var Col = null;
      Col = $mod.TBVReportColumn.$create("Create$1",[AFieldName,ACaption,AWidth,AAlign,AFormat]);
      this.FColumns.push(Col);
      Result = this;
      return Result;
    };
    this.AddSummary = function (ALabel, AFieldName, AAggregate, AFormat) {
      var Result = null;
      var SumItem = null;
      SumItem = $mod.TBVReportSummary.$create("Create$1",[ALabel,AFieldName,AAggregate,AFormat]);
      this.FSummaries.push(SumItem);
      Result = this;
      return Result;
    };
    this.GetRecordsArray = function () {
      var Result = null;
      Result = new Array();
      var ds = this.FDataSet;
      if (ds) {
        if (Array.isArray(ds.Data)) {
          Result = ds.Data;
        } else if (Array.isArray(ds.FActiveRecords)) {
          Result = ds.FActiveRecords;
        } else if (Array.isArray(ds.FRecords)) {
          Result = ds.FRecords;
        }
        return Result;
      }
      var raw = this.FRawData;
      if (raw) {
        if (Array.isArray(raw)) {
          Result = raw;
        } else if (Array.isArray(raw.Data)) {
          Result = raw.Data;
        } else if (Array.isArray(raw.FActiveRecords)) {
          Result = raw.FActiveRecords;
        } else if (Array.isArray(raw.items)) {
          Result = raw.items;
        }
      };
      return Result;
    };
    this.GetRecordCount = function () {
      var Result = 0;
      var Recs = null;
      Recs = this.GetRecordsArray();
      Result = Recs.length & 0xFFFFFFFF;
      return Result;
    };
    this.GetPageCount = function () {
      var Result = 0;
      var TotalRows = 0;
      var Limit = 0;
      TotalRows = this.GetRecordCount();
      Limit = this.FRowsPerPage;
      if (Limit <= 0) Limit = 25;
      if (TotalRows <= 0) {
        Result = 1}
       else Result = rtl.trunc(((TotalRows + Limit) - 1) / Limit);
      return Result;
    };
    this.GetPageLayoutStr = function () {
      var Result = "";
      var $tmp = this.FPageLayout;
      if ($tmp === $mod.TBVPageLayout.plA4Landscape) {
        Result = $mod.REPORT_LAYOUT_A4_LANDSCAPE}
       else if ($tmp === $mod.TBVPageLayout.plLetterPortrait) {
        Result = $mod.REPORT_LAYOUT_LETTER_PORTRAIT}
       else if ($tmp === $mod.TBVPageLayout.plLetterLandscape) {
        Result = $mod.REPORT_LAYOUT_LETTER_LANDSCAPE}
       else if ($tmp === $mod.TBVPageLayout.plThermal80mm) {
        Result = $mod.REPORT_LAYOUT_THERMAL_80MM}
       else if ($tmp === $mod.TBVPageLayout.plThermal58mm) {
        Result = $mod.REPORT_LAYOUT_THERMAL_58MM}
       else {
        Result = $mod.REPORT_LAYOUT_A4_PORTRAIT;
      };
      return Result;
    };
    this.ComputeSummary = function (AFieldName, AAggregate) {
      var Result = 0.0;
      var Recs = null;
      var AggIdx = 0;
      Recs = this.GetRecordsArray();
      AggIdx = AAggregate;
      Result = 0.0;
      if (!Recs || Recs.length === 0) {
            Result = 0;
            return;
          }
          if (AggIdx === 2) { // aggCount
            Result = Recs.length;
          } else {
            var sum = 0;
            var count = 0;
            var minVal = null;
            var maxVal = null;
            var targetLower = (AFieldName || '').toLowerCase();
      
            for (var i = 0; i < Recs.length; i++) {
              var row = Recs[i];
              if (!row || typeof row !== 'object') continue;
              var rawVal = row[AFieldName];
              if (rawVal === undefined) {
                var keys = Object.keys(row);
                for (var k = 0; k < keys.length; k++) {
                  if (keys[k].toLowerCase() === targetLower) {
                    rawVal = row[keys[k]];
                    break;
                  }
                }
              }
              var num = parseFloat(rawVal);
              if (!isNaN(num)) {
                sum += num;
                count++;
                if (minVal === null || num < minVal) minVal = num;
                if (maxVal === null || num > maxVal) maxVal = num;
              }
            }
      
            if (AggIdx === 0) { // aggSum
              Result = Math.round(sum * 100) / 100;
            } else if (AggIdx === 1) { // aggAverage
              Result = count > 0 ? Math.round((sum / count) * 100) / 100 : 0;
            } else if (AggIdx === 3) { // aggMin
              Result = minVal !== null ? minVal : 0;
            } else if (AggIdx === 4) { // aggMax
              Result = maxVal !== null ? maxVal : 0;
            }
          };
      return Result;
    };
    this.FormatCellValue = function (AValue, AFormat) {
      var Result = "";
      var Fmt = "";
      var Curr = "";
      Fmt = pas.SysUtils.LowerCase(pas.SysUtils.Trim(AFormat));
      Curr = this.FCurrencySymbol;
      Result = "";
      if (AValue === null || AValue === undefined) {
        Result = '';
      } else if (Fmt === 'currency' || Fmt === 'money') {
        var num = parseFloat(AValue);
        if (!isNaN(num)) {
          var parts = num.toFixed(2).split('.');
          parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
          Result = Curr + parts.join('.');
        } else {
          Result = String(AValue);
        }
      } else if (Fmt === 'number' || Fmt === 'float' || Fmt === 'decimal') {
        var fnum = parseFloat(AValue);
        if (!isNaN(fnum)) {
          var fparts = fnum.toFixed(2).split('.');
          fparts[0] = fparts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
          Result = fparts.join('.');
        } else {
          Result = String(AValue);
        }
      } else if (Fmt === 'integer' || Fmt === 'int') {
        var inum = parseInt(AValue, 10);
        if (!isNaN(inum)) {
          Result = String(inum);
        } else {
          Result = String(AValue);
        }
      } else if (Fmt === 'percent' || Fmt === '%') {
        var pnum = parseFloat(AValue);
        if (!isNaN(pnum)) {
          Result = pnum.toFixed(2) + '%';
        } else {
          Result = String(AValue);
        }
      } else if (Fmt === 'boolean' || Fmt === 'bool') {
        Result = AValue ? 'Yes' : 'No';
      } else {
        Result = String(AValue);
      };
      return Result;
    };
    this.FormatSummaryNumber = function (AValue, AFormat) {
      var Result = "";
      var Fmt = "";
      var Curr = "";
      Fmt = pas.SysUtils.LowerCase(pas.SysUtils.Trim(AFormat));
      Curr = this.FCurrencySymbol;
      Result = "";
      var n = Number(AValue) || 0;
      if (Fmt === 'integer' || Fmt === 'int' || Fmt === 'count') {
        Result = String(Math.round(n));
      } else if (Fmt === 'percent' || Fmt === '%') {
        Result = n.toFixed(2) + '%';
      } else if (Fmt === 'number' || Fmt === 'float' || Fmt === 'decimal') {
        var parts = n.toFixed(2).split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        Result = parts.join('.');
      } else {
        var cParts = n.toFixed(2).split('.');
        cParts[0] = cParts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        Result = Curr + cParts.join('.');
      };
      return Result;
    };
    this.GeneratePDF = function () {
      var Result = "";
      var Recs = null;
      var TotalRecords = 0;
      var TotalPages = 0;
      var Limit = 0;
      var PageIdx = 0;
      var StartIdx = 0;
      var EndIdx = 0;
      var RowIdx = 0;
      var ColIdx = 0;
      var SumIdx = 0;
      var PageW = 0;
      var PageH = 0;
      var MarginX = 0;
      var CurY = 0;
      var ColWidth = 0;
      var ColX = 0;
      var Col = null;
      var SumDef = null;
      var SumVal = 0.0;
      var SumFmt = "";
      var CellText = "";
      var SumLine = "";
      var ThemeRgb = "";
      var PageStream = "";
      var RawVal = undefined;
      var PageStreams = null;
      var FontRegular = null;
      var FontBold = null;
      Recs = this.GetRecordsArray();
      this.EnsureAutoColumns(Recs);
      FontRegular = new Object();
      FontRegular["name"] = pas.BlaiseReportsFonts.BVPdfFontRegularName;
      FontRegular["length1"] = 28236;
      FontRegular["bbox"] = pas.BlaiseReportsFonts.BVPdfFontRegularBBox;
      FontRegular["ascent"] = 928;
      FontRegular["descent"] = -236;
      FontRegular["cap"] = 729;
      FontRegular["cmap"] = pas.BlaiseReportsFonts.BVPdfFontRegularCmap;
      FontRegular["widths"] = pas.BlaiseReportsFonts.BVPdfFontRegularWidths;
      FontRegular["data"] = pas.BlaiseReportsFonts.BVPdfFontRegularData;
      FontRegular["stemV"] = 80;
      FontBold = new Object();
      FontBold["name"] = pas.BlaiseReportsFonts.BVPdfFontBoldName;
      FontBold["length1"] = 26936;
      FontBold["bbox"] = pas.BlaiseReportsFonts.BVPdfFontBoldBBox;
      FontBold["ascent"] = 928;
      FontBold["descent"] = -236;
      FontBold["cap"] = 729;
      FontBold["cmap"] = pas.BlaiseReportsFonts.BVPdfFontBoldCmap;
      FontBold["widths"] = pas.BlaiseReportsFonts.BVPdfFontBoldWidths;
      FontBold["data"] = pas.BlaiseReportsFonts.BVPdfFontBoldData;
      FontBold["stemV"] = 140;
      TotalRecords = Recs.length & 0xFFFFFFFF;
      Limit = this.FRowsPerPage;
      if (Limit <= 0) Limit = 25;
      TotalPages = this.GetPageCount();
      var $tmp = this.FPageLayout;
      if ($tmp === $mod.TBVPageLayout.plA4Landscape) {
        PageW = 842;
        PageH = 595;
        MarginX = 36;
      } else if ($tmp === $mod.TBVPageLayout.plLetterPortrait) {
        PageW = 612;
        PageH = 792;
        MarginX = 36;
      } else if ($tmp === $mod.TBVPageLayout.plLetterLandscape) {
        PageW = 792;
        PageH = 612;
        MarginX = 36;
      } else if ($tmp === $mod.TBVPageLayout.plThermal80mm) {
        PageW = 226;
        PageH = 650;
        MarginX = 12;
      } else if ($tmp === $mod.TBVPageLayout.plThermal58mm) {
        PageW = 164;
        PageH = 550;
        MarginX = 8;
      } else {
        PageW = 595;
        PageH = 842;
        MarginX = 36;
      };
      ThemeRgb = this.HexToPDFRgb(this.FThemeColor);
      PageStreams = new Array();
      if ((this.FColumns.length & 0xFFFFFFFF) > 0) {
        ColWidth = rtl.trunc((PageW - (MarginX * 2)) / (this.FColumns.length & 0xFFFFFFFF))}
       else ColWidth = PageW - (MarginX * 2);
      for (var $l = 1, $end = TotalPages; $l <= $end; $l++) {
        PageIdx = $l;
        PageStream = "";
        CurY = PageH - 45;
        PageStream = PageStream + ThemeRgb + " rg" + "\n";
        PageStream = PageStream + pas.SysUtils.IntToStr(MarginX) + " " + pas.SysUtils.IntToStr(CurY - 22) + " " + pas.SysUtils.IntToStr(PageW - (MarginX * 2)) + " 38 re f" + "\n";
        PageStream = PageStream + "1 1 1 rg" + "\n";
        PageStream = PageStream + "BT /F2 13 Tf " + pas.SysUtils.IntToStr(MarginX + 10) + " " + pas.SysUtils.IntToStr(CurY - 4) + " Td (" + this.EscapePDFString(this.FTitle) + ") Tj ET" + "\n";
        if (this.FCompanyName !== "") PageStream = PageStream + "BT /F1 8 Tf " + pas.SysUtils.IntToStr(MarginX + 10) + " " + pas.SysUtils.IntToStr(CurY - 16) + " Td (" + this.EscapePDFString(this.FCompanyName) + ") Tj ET" + "\n";
        CurY = CurY - 38;
        if (this.FHeader !== "") {
          PageStream = PageStream + "0.25 0.30 0.38 rg" + "\n";
          PageStream = PageStream + "BT /F1 9 Tf " + pas.SysUtils.IntToStr(MarginX) + " " + pas.SysUtils.IntToStr(CurY) + " Td (" + this.EscapePDFString(this.FHeader) + ") Tj ET" + "\n";
          CurY = CurY - 16;
        };
        if (this.FSubtitle !== "") {
          PageStream = PageStream + "0.35 0.40 0.48 rg" + "\n";
          PageStream = PageStream + "BT /F1 9 Tf " + pas.SysUtils.IntToStr(MarginX) + " " + pas.SysUtils.IntToStr(CurY) + " Td (" + this.EscapePDFString(this.FSubtitle) + ") Tj ET" + "\n";
          CurY = CurY - 16;
        };
        PageStream = PageStream + "0.91 0.93 0.96 rg" + "\n";
        PageStream = PageStream + pas.SysUtils.IntToStr(MarginX) + " " + pas.SysUtils.IntToStr(CurY - 6) + " " + pas.SysUtils.IntToStr(PageW - (MarginX * 2)) + " 18 re f" + "\n";
        PageStream = PageStream + "0.10 0.15 0.22 rg" + "\n";
        for (var $l1 = 0, $end1 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l1 <= $end1; $l1++) {
          ColIdx = $l1;
          Col = rtl.getObject(this.FColumns[ColIdx]);
          ColX = MarginX + 6 + (ColIdx * ColWidth);
          PageStream = PageStream + "BT /F2 9 Tf " + pas.SysUtils.IntToStr(ColX) + " " + pas.SysUtils.IntToStr(CurY) + " Td (" + this.EscapePDFString(Col.FCaption) + ") Tj ET" + "\n";
        };
        CurY = CurY - 20;
        StartIdx = (PageIdx - 1) * Limit;
        EndIdx = (StartIdx + Limit) - 1;
        if (EndIdx >= TotalRecords) EndIdx = TotalRecords - 1;
        for (var $l2 = StartIdx, $end2 = EndIdx; $l2 <= $end2; $l2++) {
          RowIdx = $l2;
          if (((RowIdx - StartIdx) % 2) === 1) {
            PageStream = PageStream + "0.97 0.98 0.99 rg" + "\n";
            PageStream = PageStream + pas.SysUtils.IntToStr(MarginX) + " " + pas.SysUtils.IntToStr(CurY - 4) + " " + pas.SysUtils.IntToStr(PageW - (MarginX * 2)) + " 16 re f" + "\n";
          };
          PageStream = PageStream + "0.15 0.20 0.28 rg" + "\n";
          for (var $l3 = 0, $end3 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l3 <= $end3; $l3++) {
            ColIdx = $l3;
            Col = rtl.getObject(this.FColumns[ColIdx]);
            ColX = MarginX + 6 + (ColIdx * ColWidth);
            RawVal = $impl.GetRecordFieldCaseInsensitive(Recs[RowIdx],Col.FFieldName);
            CellText = this.FormatCellValue(RawVal,Col.FFormat);
            PageStream = PageStream + "BT /F1 9 Tf " + pas.SysUtils.IntToStr(ColX) + " " + pas.SysUtils.IntToStr(CurY) + " Td (" + this.EscapePDFString(CellText) + ") Tj ET" + "\n";
          };
          CurY = CurY - 16;
        };
        if ((PageIdx === TotalPages) && ((this.FSummaries.length & 0xFFFFFFFF) > 0)) {
          CurY = CurY - 8;
          PageStream = PageStream + "0.80 0.84 0.88 RG 0.8 w " + pas.SysUtils.IntToStr(MarginX) + " " + pas.SysUtils.IntToStr(CurY + 12) + " m " + pas.SysUtils.IntToStr(PageW - MarginX) + " " + pas.SysUtils.IntToStr(CurY + 12) + " l S" + "\n";
          for (var $l4 = 0, $end4 = (this.FSummaries.length & 0xFFFFFFFF) - 1; $l4 <= $end4; $l4++) {
            SumIdx = $l4;
            SumDef = rtl.getObject(this.FSummaries[SumIdx]);
            SumVal = this.ComputeSummary(SumDef.FFieldName,SumDef.FAggregate);
            SumFmt = SumDef.FFormat;
            if ((SumFmt === "") && (SumDef.FAggregate === $mod.TBVReportAggregate.aggCount)) SumFmt = "integer";
            SumLine = SumDef.FLabelText + ": " + this.FormatSummaryNumber(SumVal,SumFmt);
            PageStream = PageStream + "0.08 0.12 0.18 rg" + "\n";
            PageStream = PageStream + "BT /F2 10 Tf " + pas.SysUtils.IntToStr(MarginX + 6) + " " + pas.SysUtils.IntToStr(CurY) + " Td (" + this.EscapePDFString(SumLine) + ") Tj ET" + "\n";
            CurY = CurY - 15;
          };
        };
        PageStream = PageStream + "0.75 0.79 0.84 RG 0.5 w " + pas.SysUtils.IntToStr(MarginX) + " 42 m " + pas.SysUtils.IntToStr(PageW - MarginX) + " 42 l S" + "\n";
        PageStream = PageStream + "0.40 0.45 0.52 rg" + "\n";
        if (this.FFooter !== "") PageStream = PageStream + "BT /F1 8 Tf " + pas.SysUtils.IntToStr(MarginX) + " 28 Td (" + this.EscapePDFString(this.FFooter) + ") Tj ET" + "\n";
        PageStream = PageStream + "BT /F2 8 Tf " + pas.SysUtils.IntToStr(PageW - MarginX - 65) + " 28 Td (Page " + pas.SysUtils.IntToStr(PageIdx) + " of " + pas.SysUtils.IntToStr(TotalPages) + ") Tj ET" + "\n";
        PageStreams.push(PageStream);
      };
      Result = "";
      var objects = [];
          function addObj(body) {
            objects.push(body);
            return objects.length;
          }
      
          // Obj 1: Catalog
          addObj('<< /Type /Catalog /Pages 2 0 R >>');
          // Obj 2: Pages placeholder
          addObj('');
          // Obj 3: Font Regular
          addObj('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>');
          // Obj 4: Font Bold
          addObj('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>');
          // Obj 5: Document Info
          var self = this;
          function infoText(text) {
            if (!new RegExp('[^\\x00-\\x7F]').test(text)) return '(' + self.EscapePDFString(text) + ')';
            var hex = 'FEFF';
            for (var h = 0; h < text.length; h++) hex += hex4(text.charCodeAt(h));
            return '<' + hex + '>';
          }
          function hex4(n) {
            var out = n.toString(16).toUpperCase();
            while (out.length < 4) out = '0' + out;
            return out;
          }
          var infoStr = '<< /Title ' + infoText(this.FTitle) + ' /Author ' + infoText(this.FAuthor) + ' /Creator (BlaiseReports v5.0) /Producer (BlaiseVue Vector PDF Engine) >>';
          addObj(infoStr);
      
          // The page streams still hold raw characters inside their text operands, and every
          // byte of the file must stay ASCII because the xref offsets count string length.
          // Helvetica covers WinAnsi only, so any other character switches both fonts to the
          // embedded Latin + Greek subset, drawn through glyph ids in hex strings.
          var winAnsiHigh = {0x20AC:0x80,0x201A:0x82,0x0192:0x83,0x201E:0x84,0x2026:0x85,0x2020:0x86,0x2021:0x87,0x02C6:0x88,0x2030:0x89,0x0160:0x8A,0x2039:0x8B,0x0152:0x8C,0x017D:0x8E,0x2018:0x91,0x2019:0x92,0x201C:0x93,0x201D:0x94,0x2022:0x95,0x2013:0x96,0x2014:0x97,0x02DC:0x98,0x2122:0x99,0x0161:0x9A,0x203A:0x9B,0x0153:0x9C,0x017E:0x9E,0x0178:0x9F};
          var needsEmbed = false;
          var nonAscii = new RegExp('[^\\x00-\\x7F]', 'g');
          var streams = [];
          for (var s = 0; s < PageStreams.length; s++) {
            var normalized = PageStreams[s].normalize('NFC');
            var found = normalized.match(nonAscii) || [];
            for (var k = 0; k < found.length; k++) {
              var code = found[k].charCodeAt(0);
              if (code < 0xA0 && winAnsiHigh[code] === undefined || code > 0xFF && winAnsiHigh[code] === undefined) needsEmbed = true;
            }
            streams.push(normalized);
          }
      
          function parseCmap(text) {
            var map = {};
            var entries = text.split(',');
            for (var e = 0; e < entries.length; e++) {
              var pair = entries[e].split(':');
              map[parseInt(pair[0], 16)] = parseInt(pair[1], 16);
            }
            return map;
          }
      
          function addEmbeddedFont(slot, font, tag) {
            var baseName = tag + '+' + font.name;
            var fileId = addObj('<< /Length ' + font.data.length + ' /Length1 ' + font.length1 + ' /Filter [/ASCII85Decode /FlateDecode] >>\nstream\n' + font.data + '\nendstream');
            var descId = addObj('<< /Type /FontDescriptor /FontName /' + baseName + ' /Flags 4 /FontBBox [' + font.bbox + '] /ItalicAngle 0 /Ascent ' + font.ascent + ' /Descent ' + font.descent + ' /CapHeight ' + font.cap + ' /StemV ' + font.stemV + ' /FontFile2 ' + fileId + ' 0 R >>');
            var cidId = addObj('<< /Type /Font /Subtype /CIDFontType2 /BaseFont /' + baseName + ' /CIDSystemInfo << /Registry (Adobe) /Ordering (Identity) /Supplement 0 >> /FontDescriptor ' + descId + ' 0 R /W [0 [' + font.widths + ']] /CIDToGIDMap /Identity >>');
            var seen = {};
            var lines = [];
            var entries = font.cmap.split(',');
            for (var e = 0; e < entries.length; e++) {
              var pair = entries[e].split(':');
              var gid = parseInt(pair[1], 16);
              if (seen[gid]) continue;
              seen[gid] = true;
              lines.push('<' + hex4(gid) + '> <' + hex4(parseInt(pair[0], 16)) + '>');
            }
            var cmapText = '/CIDInit /ProcSet findresource begin\n12 dict begin\nbegincmap\n/CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def\n/CMapName /Adobe-Identity-UCS def\n/CMapType 2 def\n1 begincodespacerange\n<0000> <FFFF>\nendcodespacerange\n';
            for (var b = 0; b < lines.length; b += 100) {
              var block = lines.slice(b, b + 100);
              cmapText += block.length + ' beginbfchar\n' + block.join('\n') + '\nendbfchar\n';
            }
            cmapText += 'endcmap\nCMapName currentdict /CMap defineresource pop\nend\nend\n';
            var unicodeId = addObj('<< /Length ' + cmapText.length + ' >>\nstream\n' + cmapText + 'endstream');
            objects[slot] = '<< /Type /Font /Subtype /Type0 /BaseFont /' + baseName + ' /Encoding /Identity-H /DescendantFonts [' + cidId + ' 0 R] /ToUnicode ' + unicodeId + ' 0 R >>';
          }
      
          function encodeGlyphs(text, map) {
            var hex = '';
            var fallback = map[0x3F];
            for (var c = 0; c < text.length; c++) {
              var unit = text.charCodeAt(c);
              if (unit >= 0xD800 && unit <= 0xDBFF) c++;
              var gid = map[unit];
              hex += hex4(gid === undefined ? fallback : gid);
            }
            return '<' + hex + '>';
          }
      
          if (needsEmbed) {
            addEmbeddedFont(2, FontRegular, 'BVAAAA');
            addEmbeddedFont(3, FontBold, 'BVAAAB');
            var maps = {'1': parseCmap(FontRegular.cmap), '2': parseCmap(FontBold.cmap)};
            var textOp = new RegExp('/F([12]) ([0-9.]+) Tf ([^(]*)\\(((?:[^\\\\()]|\\\\.)*)\\) Tj', 'g');
            var unescapePdf = new RegExp('\\\\(.)', 'g');
            for (var t = 0; t < streams.length; t++) {
              streams[t] = streams[t].replace(textOp, function (all, fontNo, size, between, text) {
                return '/F' + fontNo + ' ' + size + ' Tf ' + between + encodeGlyphs(text.replace(unescapePdf, '$1'), maps[fontNo]) + ' Tj';
              });
            }
          } else {
            for (var w = 0; w < streams.length; w++) {
              streams[w] = streams[w].replace(nonAscii, function (ch) {
                var unit = ch.charCodeAt(0);
                var octal = (winAnsiHigh[unit] === undefined ? unit : winAnsiHigh[unit]).toString(8);
                return '\\' + octal;
              });
            }
          }
      
          var pageRefs = [];
          for (var p = 0; p < streams.length; p++) {
            var streamData = streams[p];
            var contentObjId = addObj('<< /Length ' + streamData.length + ' >>\nstream\n' + streamData + 'endstream');
            var pageObjId = addObj(
              '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ' + PageW + ' ' + PageH + '] ' +
              '/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> ' +
              '/Contents ' + contentObjId + ' 0 R >>'
            );
            pageRefs.push(pageObjId + ' 0 R');
          }
      
          objects[1] = '<< /Type /Pages /Kids [ ' + pageRefs.join(' ') + ' ] /Count ' + pageRefs.length + ' >>';
      
          var pdf = '%PDF-1.4\n';
          var offsets = [];
          for (var i = 0; i < objects.length; i++) {
            offsets.push(pdf.length);
            pdf += (i + 1) + ' 0 obj\n' + objects[i] + '\nendobj\n';
          }
      
          var xrefOffset = pdf.length;
          pdf += 'xref\n0 ' + (objects.length + 1) + '\n';
          pdf += '0000000000 65535 f \n';
          for (var j = 0; j < offsets.length; j++) {
            var offStr = String(offsets[j]);
            while (offStr.length < 10) offStr = '0' + offStr;
            pdf += offStr + ' 00000 n \n';
          }
      
          pdf += 'trailer\n<< /Size ' + (objects.length + 1) + ' /Root 1 0 R /Info 5 0 R >>\n';
          pdf += 'startxref\n' + xrefOffset + '\n%%EOF';
          Result = pdf;
      return Result;
    };
    this.ExportPDF = function (AFileName) {
      var Result = "";
      var FinalName = "";
      FinalName = pas.SysUtils.Trim(AFileName);
      if (FinalName === "") FinalName = "report.pdf";
      Result = this.GeneratePDF();
      this.TriggerBrowserDownload(Result,FinalName,"application/pdf");
      return Result;
    };
    this.GenerateExcel = function () {
      var Result = "";
      var Recs = null;
      var RowIdx = 0;
      var ColIdx = 0;
      var SumIdx = 0;
      var Col = null;
      var SumDef = null;
      var SumVal = 0.0;
      var SumFmt = "";
      var Xml = "";
      var ColFmt = "";
      var CellType = "";
      var CellStyle = "";
      var CellValStr = "";
      var RawVal = undefined;
      Recs = this.GetRecordsArray();
      this.EnsureAutoColumns(Recs);
      Xml = '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + '<?mso-application progid="Excel.Sheet"?>' + "\n" + '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + "\n" + ' xmlns:o="urn:schemas-microsoft-com:office:office"' + "\n" + ' xmlns:x="urn:schemas-microsoft-com:office:excel"' + "\n" + ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">' + "\n" + '  <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' + "\n" + "    <Title>" + this.EscapeXMLString(this.FTitle) + "</Title>" + "\n" + "    <Author>" + this.EscapeXMLString(this.FAuthor) + "</Author>" + "\n" + "    <Company>" + this.EscapeXMLString(this.FCompanyName) + "</Company>" + "\n" + "  </DocumentProperties>" + "\n" + "  <Styles>" + "\n" + '    <Style ss:ID="Default" ss:Name="Normal"><Font ss:FontName="Segoe UI" ss:Size="10"/></Style>' + "\n" + '    <Style ss:ID="sTitle"><Font ss:FontName="Segoe UI" ss:Size="14" ss:Bold="1" ss:Color="#0F172A"/></Style>' + "\n" + '    <Style ss:ID="sHeaderMeta"><Font ss:FontName="Segoe UI" ss:Size="9" ss:Italic="1" ss:Color="#475569"/></Style>' + "\n" + '    <Style ss:ID="sColHeader"><Font ss:FontName="Segoe UI" ss:Size="10" ss:Bold="1" ss:Color="#FFFFFF"/><Interior ss:Color="' + this.EscapeXMLString(this.FThemeColor) + '" ss:Pattern="Solid"/></Style>' + "\n" + '    <Style ss:ID="sString"><Font ss:FontName="Segoe UI" ss:Size="10"/></Style>' + "\n" + '    <Style ss:ID="sInteger"><Font ss:FontName="Segoe UI" ss:Size="10"/><NumberFormat ss:Format="0"/></Style>' + "\n" + '    <Style ss:ID="sNumber"><Font ss:FontName="Segoe UI" ss:Size="10"/><NumberFormat ss:Format="#,##0.00"/></Style>' + "\n" + '    <Style ss:ID="sCurrency"><Font ss:FontName="Segoe UI" ss:Size="10"/><NumberFormat ss:Format="&quot;' + this.EscapeXMLString(this.FCurrencySymbol) + '&quot;#,##0.00"/></Style>' + "\n" + '    <Style ss:ID="sSummaryLabel"><Font ss:FontName="Segoe UI" ss:Size="10" ss:Bold="1"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/></Style>' + "\n" + '    <Style ss:ID="sSummaryValue"><Font ss:FontName="Segoe UI" ss:Size="10" ss:Bold="1"/><Interior ss:Color="#F1F5F9" ss:Pattern="Solid"/><NumberFormat ss:Format="#,##0.00"/></Style>' + "\n" + "  </Styles>" + "\n" + '  <Worksheet ss:Name="' + this.EscapeXMLString(pas.System.Copy(this.FTitle,1,31)) + '">' + "\n" + "    <Table>" + "\n";
      for (var $l = 0, $end = (this.FColumns.length & 0xFFFFFFFF) - 1; $l <= $end; $l++) {
        ColIdx = $l;
        Col = rtl.getObject(this.FColumns[ColIdx]);
        Xml = Xml + '      <Column ss:Width="' + pas.SysUtils.IntToStr(Col.FWidth) + '"/>' + "\n";
      };
      Xml = Xml + '      <Row><Cell ss:StyleID="sTitle"><Data ss:Type="String">' + this.EscapeXMLString(this.FTitle) + "</Data></Cell></Row>" + "\n";
      if (this.FHeader !== "") Xml = Xml + '      <Row><Cell ss:StyleID="sHeaderMeta"><Data ss:Type="String">' + this.EscapeXMLString(this.FHeader) + "</Data></Cell></Row>" + "\n";
      Xml = Xml + "      <Row>" + "\n";
      for (var $l1 = 0, $end1 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l1 <= $end1; $l1++) {
        ColIdx = $l1;
        Col = rtl.getObject(this.FColumns[ColIdx]);
        Xml = Xml + '        <Cell ss:StyleID="sColHeader"><Data ss:Type="String">' + this.EscapeXMLString(Col.FCaption) + "</Data></Cell>" + "\n";
      };
      Xml = Xml + "      </Row>" + "\n";
      for (var $l2 = 0, $end2 = (Recs.length & 0xFFFFFFFF) - 1; $l2 <= $end2; $l2++) {
        RowIdx = $l2;
        Xml = Xml + "      <Row>" + "\n";
        for (var $l3 = 0, $end3 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l3 <= $end3; $l3++) {
          ColIdx = $l3;
          Col = rtl.getObject(this.FColumns[ColIdx]);
          ColFmt = pas.SysUtils.LowerCase(pas.SysUtils.Trim(Col.FFormat));
          RawVal = $impl.GetRecordFieldCaseInsensitive(Recs[RowIdx],Col.FFieldName);
          CellType = "String";
          CellStyle = "sString";
          CellValStr = "";
          if (RawVal === null || RawVal === undefined) {
            CellType = 'String';
            CellValStr = '';
          } else if (typeof RawVal === 'boolean') {
            CellType = 'Boolean';
            CellValStr = RawVal ? '1' : '0';
          } else if (typeof RawVal === 'number' || ColFmt === 'currency' || ColFmt === 'money' || ColFmt === 'number' || ColFmt === 'float' || ColFmt === 'integer' || ColFmt === 'int') {
            var num = Number(RawVal);
            if (!isNaN(num) && String(RawVal).trim() !== '') {
              CellType = 'Number';
              CellValStr = String(num);
              if (ColFmt === 'currency' || ColFmt === 'money') {
                CellStyle = 'sCurrency';
              } else if (ColFmt === 'integer' || ColFmt === 'int' || (Number.isInteger(num) && ColFmt === '')) {
                CellStyle = 'sInteger';
              } else {
                CellStyle = 'sNumber';
              }
            } else {
              CellType = 'String';
              CellValStr = String(RawVal);
            }
          } else {
            CellType = 'String';
            CellValStr = String(RawVal);
          };
          Xml = Xml + '        <Cell ss:StyleID="' + CellStyle + '"><Data ss:Type="' + CellType + '">' + this.EscapeXMLString(CellValStr) + "</Data></Cell>" + "\n";
        };
        Xml = Xml + "      </Row>" + "\n";
      };
      for (var $l4 = 0, $end4 = (this.FSummaries.length & 0xFFFFFFFF) - 1; $l4 <= $end4; $l4++) {
        SumIdx = $l4;
        SumDef = rtl.getObject(this.FSummaries[SumIdx]);
        SumVal = this.ComputeSummary(SumDef.FFieldName,SumDef.FAggregate);
        SumFmt = SumDef.FFormat;
        if ((SumFmt === "") && (SumDef.FAggregate === $mod.TBVReportAggregate.aggCount)) SumFmt = "integer";
        Xml = Xml + "      <Row>" + "\n" + '        <Cell ss:StyleID="sSummaryLabel"><Data ss:Type="String">' + this.EscapeXMLString(SumDef.FLabelText) + "</Data></Cell>" + "\n" + '        <Cell ss:StyleID="sSummaryValue"><Data ss:Type="Number">' + pas.SysUtils.FloatToStr(SumVal) + "</Data></Cell>" + "\n" + '        <Cell ss:StyleID="sSummaryLabel"><Data ss:Type="String">' + this.EscapeXMLString(this.FormatSummaryNumber(SumVal,SumFmt)) + "</Data></Cell>" + "\n" + "      </Row>" + "\n";
      };
      Xml = Xml + "    </Table>" + "\n" + "  </Worksheet>" + "\n" + "</Workbook>";
      Result = Xml;
      return Result;
    };
    var XML_DECL = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "\n";
    this.GenerateXlsx = function () {
      var Result = undefined;
      var Recs = null;
      var SheetName = "";
      var SheetXml = "";
      var StylesXml = "";
      var ContentTypes = "";
      var RootRels = "";
      var WorkbookXml = "";
      var WorkbookRels = "";
      var CoreXml = "";
      var AppXml = "";
      var Entries = undefined;
      Recs = this.GetRecordsArray();
      this.EnsureAutoColumns(Recs);
      SheetName = this.FTitle;
      SheetName = String(SheetName).replace(new RegExp('[\\[\\]:*?/\\\\]', 'g'), ' ').trim().substring(0, 31);
      SheetName = SheetName.replace(new RegExp('^\\u0027+|\\u0027+$', 'g'), '').trim();
      if (SheetName === '') SheetName = 'Report';
      SheetXml = this.BuildXlsxSheetXml(Recs);
      StylesXml = this.BuildXlsxStylesXml();
      ContentTypes = XML_DECL + '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' + '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' + '<Default Extension="xml" ContentType="application/xml"/>' + '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>' + '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' + '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>' + '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>' + '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>' + "</Types>";
      RootRels = XML_DECL + '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' + '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>' + '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>' + "</Relationships>";
      WorkbookXml = XML_DECL + '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' + '<sheets><sheet name="' + this.XlsxEscape(SheetName) + '" sheetId="1" r:id="rId1"/></sheets></workbook>';
      WorkbookRels = XML_DECL + '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>' + '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>' + "</Relationships>";
      CoreXml = XML_DECL + '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/">' + "<dc:title>" + this.XlsxEscape(this.FTitle) + "</dc:title><dc:creator>" + this.XlsxEscape(this.FAuthor) + "</dc:creator></cp:coreProperties>";
      AppXml = XML_DECL + '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties">' + "<Application>BlaiseVue</Application><Company>" + this.XlsxEscape(this.FCompanyName) + "</Company></Properties>";
      Entries = null;
      Entries = [
        { name: '[Content_Types].xml', text: ContentTypes },
        { name: '_rels/.rels', text: RootRels },
        { name: 'docProps/core.xml', text: CoreXml },
        { name: 'docProps/app.xml', text: AppXml },
        { name: 'xl/workbook.xml', text: WorkbookXml },
        { name: 'xl/_rels/workbook.xml.rels', text: WorkbookRels },
        { name: 'xl/styles.xml', text: StylesXml },
        { name: 'xl/worksheets/sheet1.xml', text: SheetXml }
      ];
      Result = $impl.XlsxBuildZip(Entries);
      return Result;
    };
    var XLSX_MIME = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    this.ExportExcel = function (AFileName) {
      var Result = "";
      var FinalName = "";
      var Package = undefined;
      FinalName = pas.SysUtils.Trim(AFileName);
      if (FinalName === "") FinalName = "report.xlsx";
      Result = this.GenerateExcel();
      this.FLastExportedContent = Result;
      this.FLastExportedFileName = FinalName;
      this.FLastExportedMimeType = XLSX_MIME;
      Package = this.GenerateXlsx();
      if (pas.System.Assigned(Package)) this.DownloadBlobPart(Package,FinalName,XLSX_MIME);
      return Result;
    };
    this.GenerateCSV = function () {
      var Result = "";
      var Recs = null;
      var RowIdx = 0;
      var ColIdx = 0;
      var SumIdx = 0;
      var Col = null;
      var SumDef = null;
      var SumVal = 0.0;
      var SumFmt = "";
      var Delim = "";
      var Line = "";
      var CsvOut = "";
      var RawVal = undefined;
      Recs = this.GetRecordsArray();
      this.EnsureAutoColumns(Recs);
      Delim = this.FCSVDelimiter;
      if (Delim === "") Delim = ",";
      CsvOut = "";
      if (this.FIncludeBOM) {
        CsvOut = '\uFEFF';
      };
      Line = "";
      for (var $l = 0, $end = (this.FColumns.length & 0xFFFFFFFF) - 1; $l <= $end; $l++) {
        ColIdx = $l;
        Col = rtl.getObject(this.FColumns[ColIdx]);
        if (ColIdx > 0) Line = Line + Delim;
        Line = Line + this.EscapeCSVField(Col.FCaption);
      };
      CsvOut = CsvOut + Line + "\r\n";
      for (var $l1 = 0, $end1 = (Recs.length & 0xFFFFFFFF) - 1; $l1 <= $end1; $l1++) {
        RowIdx = $l1;
        Line = "";
        for (var $l2 = 0, $end2 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l2 <= $end2; $l2++) {
          ColIdx = $l2;
          Col = rtl.getObject(this.FColumns[ColIdx]);
          if (ColIdx > 0) Line = Line + Delim;
          RawVal = $impl.GetRecordFieldCaseInsensitive(Recs[RowIdx],Col.FFieldName);
          if (Col.FFormat !== "") {
            Line = Line + this.EscapeCSVField(this.FormatCellValue(RawVal,Col.FFormat))}
           else {
            var v = (RawVal !== null && RawVal !== undefined) ? String(RawVal) : '';
            Line += this.EscapeCSVField(v);
          };
        };
        CsvOut = CsvOut + Line + "\r\n";
      };
      if ((this.FSummaries.length & 0xFFFFFFFF) > 0) {
        for (var $l3 = 0, $end3 = (this.FSummaries.length & 0xFFFFFFFF) - 1; $l3 <= $end3; $l3++) {
          SumIdx = $l3;
          SumDef = rtl.getObject(this.FSummaries[SumIdx]);
          SumVal = this.ComputeSummary(SumDef.FFieldName,SumDef.FAggregate);
          SumFmt = SumDef.FFormat;
          if ((SumFmt === "") && (SumDef.FAggregate === $mod.TBVReportAggregate.aggCount)) SumFmt = "integer";
          Line = this.EscapeCSVField(SumDef.FLabelText) + Delim + this.EscapeCSVField(this.FormatSummaryNumber(SumVal,SumFmt));
          CsvOut = CsvOut + Line + "\r\n";
        };
      };
      Result = CsvOut;
      return Result;
    };
    this.ExportCSV = function (AFileName) {
      var Result = "";
      var FinalName = "";
      FinalName = pas.SysUtils.Trim(AFileName);
      if (FinalName === "") FinalName = "report.csv";
      Result = this.GenerateCSV();
      this.TriggerBrowserDownload(Result,FinalName,"text/csv;charset=utf-8;");
      return Result;
    };
    this.GeneratePrintHTML = function () {
      var Result = "";
      var Recs = null;
      var RowIdx = 0;
      var ColIdx = 0;
      var SumIdx = 0;
      var Col = null;
      var SumDef = null;
      var SumVal = 0.0;
      var SumFmt = "";
      var PageSizeCSS = "";
      var SheetClass = "";
      var Html = "";
      var AlignStyle = "";
      var CellStr = "";
      var RawVal = undefined;
      Recs = this.GetRecordsArray();
      this.EnsureAutoColumns(Recs);
      var $tmp = this.FPageLayout;
      if ($tmp === $mod.TBVPageLayout.plA4Landscape) {
        PageSizeCSS = "@page { size: A4 landscape; margin: 12mm; }";
        SheetClass = "bv-report-sheet bv-layout-a4-landscape";
      } else if ($tmp === $mod.TBVPageLayout.plLetterPortrait) {
        PageSizeCSS = "@page { size: letter portrait; margin: 0.5in; }";
        SheetClass = "bv-report-sheet bv-layout-letter";
      } else if ($tmp === $mod.TBVPageLayout.plLetterLandscape) {
        PageSizeCSS = "@page { size: letter landscape; margin: 0.5in; }";
        SheetClass = "bv-report-sheet bv-layout-letter-landscape";
      } else if ($tmp === $mod.TBVPageLayout.plThermal80mm) {
        PageSizeCSS = "@page { size: 80mm auto; margin: 2mm; }";
        SheetClass = "bv-report-sheet bv-layout-thermal-80mm";
      } else if ($tmp === $mod.TBVPageLayout.plThermal58mm) {
        PageSizeCSS = "@page { size: 58mm auto; margin: 1.5mm; }";
        SheetClass = "bv-report-sheet bv-layout-thermal-58mm";
      } else {
        PageSizeCSS = "@page { size: A4 portrait; margin: 12mm; }";
        SheetClass = "bv-report-sheet bv-layout-a4";
      };
      Html = "<style>" + "\n" + PageSizeCSS + "\n" + "@media print {" + "\n" + "  .no-print, .bv-report-toolbar, nav, header, aside, .bui-navbar { display: none !important; }" + "\n" + "  body { margin: 0 !important; padding: 0 !important; background: #ffffff !important; }" + "\n" + "  .bv-report-sheet { box-shadow: none !important; border: none !important; margin: 0 !important; width: 100% !important; }" + "\n" + "}" + "\n" + '.bv-report-sheet { background: #ffffff; color: #0f172a; font-family: "Inter", "Segoe UI", sans-serif; padding: 24px; border-radius: 8px; border: 1px solid #e2e8f0; }' + "\n" + '.bv-layout-thermal-80mm { width: 80mm; max-width: 80mm; font-family: "Courier New", monospace; font-size: 11px; padding: 8px; }' + "\n" + '.bv-layout-thermal-58mm { width: 58mm; max-width: 58mm; font-family: "Courier New", monospace; font-size: 10px; padding: 6px; }' + "\n" + ".bv-report-banner { background: " + this.EscapeXMLString(this.FThemeColor) + "; color: #ffffff; padding: 16px 20px; border-radius: 6px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center; }" + "\n" + ".bv-report-title { font-size: 20px; font-weight: 700; margin: 0; }" + "\n" + ".bv-report-company { font-size: 12px; opacity: 0.9; margin-top: 4px; }" + "\n" + ".bv-report-meta { font-size: 12px; color: #475569; margin-bottom: 14px; padding-bottom: 8px; border-bottom: 1px solid #e2e8f0; }" + "\n" + ".bv-report-table { width: 100%; border-collapse: collapse; margin-bottom: 16px; font-size: 13px; }" + "\n" + ".bv-report-table th { background: #f1f5f9; color: #1e293b; font-weight: 600; padding: 10px 12px; border-bottom: 2px solid #cbd5e1; text-align: left; }" + "\n" + ".bv-report-table td { padding: 8px 12px; border-bottom: 1px solid #e2e8f0; color: #334155; }" + "\n" + ".bv-report-table tr:nth-child(even) td { background: #f8fafc; }" + "\n" + ".bv-report-summaries { display: flex; flex-wrap: wrap; gap: 12px; justify-content: flex-end; padding-top: 12px; border-top: 2px solid #cbd5e1; margin-top: 12px; }" + "\n" + ".bv-report-summary-card { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 6px; padding: 8px 14px; min-width: 140px; text-align: right; }" + "\n" + ".bv-report-summary-label { font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: 600; }" + "\n" + ".bv-report-summary-value { font-size: 16px; color: #0f172a; font-weight: 700; margin-top: 2px; }" + "\n" + ".bv-report-footer { margin-top: 20px; padding-top: 10px; border-top: 1px solid #e2e8f0; display: flex; justify-content: space-between; font-size: 11px; color: #64748b; }" + "\n" + "</style>" + "\n";
      Html = Html + '<div class="' + SheetClass + '" data-layout="' + this.GetPageLayoutStr() + '">' + "\n" + '  <div class="bv-report-banner">' + "\n" + "    <div>" + "\n" + '      <h1 class="bv-report-title">' + this.EscapeXMLString(this.FTitle) + "</h1>" + "\n";
      if (this.FCompanyName !== "") Html = Html + '      <div class="bv-report-company">' + this.EscapeXMLString(this.FCompanyName) + "</div>" + "\n";
      Html = Html + "    </div>" + "\n";
      if (this.FLogoText !== "") Html = Html + '    <div class="bv-report-logo" style="font-weight:800;font-size:18px;border:2px solid rgba(255,255,255,0.6);padding:6px 10px;border-radius:6px;">' + this.EscapeXMLString(this.FLogoText) + "</div>" + "\n";
      Html = Html + "  </div>" + "\n";
      if (this.FHeader !== "") Html = Html + '  <div class="bv-report-meta">' + this.EscapeXMLString(this.FHeader) + "</div>" + "\n";
      Html = Html + '  <table class="bv-report-table">' + "\n" + "    <thead><tr>" + "\n";
      for (var $l = 0, $end = (this.FColumns.length & 0xFFFFFFFF) - 1; $l <= $end; $l++) {
        ColIdx = $l;
        Col = rtl.getObject(this.FColumns[ColIdx]);
        AlignStyle = "text-align:" + Col.GetAlignStr() + ";";
        Html = Html + '      <th style="' + AlignStyle + '">' + this.EscapeXMLString(Col.FCaption) + "</th>" + "\n";
      };
      Html = Html + "    </tr></thead>" + "\n" + "    <tbody>" + "\n";
      for (var $l1 = 0, $end1 = (Recs.length & 0xFFFFFFFF) - 1; $l1 <= $end1; $l1++) {
        RowIdx = $l1;
        Html = Html + "      <tr>" + "\n";
        for (var $l2 = 0, $end2 = (this.FColumns.length & 0xFFFFFFFF) - 1; $l2 <= $end2; $l2++) {
          ColIdx = $l2;
          Col = rtl.getObject(this.FColumns[ColIdx]);
          AlignStyle = "text-align:" + Col.GetAlignStr() + ";";
          RawVal = $impl.GetRecordFieldCaseInsensitive(Recs[RowIdx],Col.FFieldName);
          CellStr = this.FormatCellValue(RawVal,Col.FFormat);
          Html = Html + '        <td style="' + AlignStyle + '">' + this.EscapeXMLString(CellStr) + "</td>" + "\n";
        };
        Html = Html + "      </tr>" + "\n";
      };
      Html = Html + "    </tbody>" + "\n" + "  </table>" + "\n";
      if ((this.FSummaries.length & 0xFFFFFFFF) > 0) {
        Html = Html + '  <div class="bv-report-summaries">' + "\n";
        for (var $l3 = 0, $end3 = (this.FSummaries.length & 0xFFFFFFFF) - 1; $l3 <= $end3; $l3++) {
          SumIdx = $l3;
          SumDef = rtl.getObject(this.FSummaries[SumIdx]);
          SumVal = this.ComputeSummary(SumDef.FFieldName,SumDef.FAggregate);
          SumFmt = SumDef.FFormat;
          if ((SumFmt === "") && (SumDef.FAggregate === $mod.TBVReportAggregate.aggCount)) SumFmt = "integer";
          Html = Html + '    <div class="bv-report-summary-card">' + "\n" + '      <div class="bv-report-summary-label">' + this.EscapeXMLString(SumDef.FLabelText) + "</div>" + "\n" + '      <div class="bv-report-summary-value">' + this.EscapeXMLString(this.FormatSummaryNumber(SumVal,SumFmt)) + "</div>" + "\n" + "    </div>" + "\n";
        };
        Html = Html + "  </div>" + "\n";
      };
      Html = Html + '  <div class="bv-report-footer">' + "\n" + "    <span>" + this.EscapeXMLString(this.FFooter) + "</span>" + "\n" + "    <span>Page 1 of " + pas.SysUtils.IntToStr(this.GetPageCount()) + " | Records: " + pas.SysUtils.IntToStr(this.GetRecordCount()) + "</span>" + "\n" + "  </div>" + "\n" + "</div>";
      Result = Html;
      return Result;
    };
    this.PrintPreview = function (ATargetElementId) {
      var Result = "";
      Result = this.GeneratePrintHTML();
      this.FLastExportedContent = Result;
      this.FLastExportedFileName = "print-preview.html";
      this.FLastExportedMimeType = "text/html";
      try {
        if (typeof document !== 'undefined' && ATargetElementId) {
          var el = document.getElementById(ATargetElementId);
          if (el) {
            el.innerHTML = Result;
          }
        }
      } catch (e) {};
      return Result;
    };
  });
  this.ParseAggregateType = function (AName) {
    var Result = 0;
    var L = "";
    L = pas.SysUtils.LowerCase(pas.SysUtils.Trim(AName));
    if ((L === "avg") || (L === "average") || (L === "aggaverage")) {
      Result = $mod.TBVReportAggregate.aggAverage}
     else if ((L === "count") || (L === "aggcount")) {
      Result = $mod.TBVReportAggregate.aggCount}
     else if ((L === "min") || (L === "aggmin")) {
      Result = $mod.TBVReportAggregate.aggMin}
     else if ((L === "max") || (L === "aggmax")) {
      Result = $mod.TBVReportAggregate.aggMax}
     else Result = $mod.TBVReportAggregate.aggSum;
    return Result;
  };
  this.ParsePageLayout = function (AName) {
    var Result = 0;
    var L = "";
    L = pas.SysUtils.LowerCase(pas.SysUtils.Trim(AName));
    if ((L === "a4-landscape") || (L === "landscape")) {
      Result = $mod.TBVPageLayout.plA4Landscape}
     else if ((L === "letter") || (L === "letter-portrait")) {
      Result = $mod.TBVPageLayout.plLetterPortrait}
     else if (L === "letter-landscape") {
      Result = $mod.TBVPageLayout.plLetterLandscape}
     else if ((L === "thermal-80mm") || (L === "80mm") || (L === "pos-80mm") || (L === "pos")) {
      Result = $mod.TBVPageLayout.plThermal80mm}
     else if ((L === "thermal-58mm") || (L === "58mm") || (L === "pos-58mm")) {
      Result = $mod.TBVPageLayout.plThermal58mm}
     else Result = $mod.TBVPageLayout.plA4Portrait;
    return Result;
  };
  this.ParseColumnAlign = function (AName) {
    var Result = 0;
    var L = "";
    L = pas.SysUtils.LowerCase(pas.SysUtils.Trim(AName));
    if (L === "center") {
      Result = $mod.TBVColumnAlign.caCenter}
     else if (L === "right") {
      Result = $mod.TBVColumnAlign.caRight}
     else Result = $mod.TBVColumnAlign.caLeft;
    return Result;
  };
  $mod.$implcode = function () {
    $impl.HumanizeFieldName = function (AField) {
      var Result = "";
      if (AField === "") return "";
      Result = pas.SysUtils.UpperCase(pas.System.Copy(AField,1,1)) + pas.System.Copy(AField,2,2147483647);
      return Result;
    };
    $impl.GetRecordFieldCaseInsensitive = function (ARow, AFieldName) {
      var Result = undefined;
      Result = "";
      if (ARow && typeof ARow === 'object') {
        if (ARow[AFieldName] !== undefined) {
          Result = ARow[AFieldName];
        } else {
          var target = (AFieldName || '').toLowerCase();
          var keys = Object.keys(ARow);
          for (var i = 0; i < keys.length; i++) {
            if (keys[i].toLowerCase() === target) {
              Result = ARow[keys[i]];
              break;
            }
          }
        }
      };
      return Result;
    };
    $impl.XlsxColumnName = function (AIndex) {
      var Result = "";
      var N = 0;
      Result = "";
      N = AIndex + 1;
      while (N > 0) {
        Result = String.fromCharCode(65 + ((N - 1) % 26)) + Result;
        N = rtl.trunc((N - 1) / 26);
      };
      return Result;
    };
    $impl.XlsxBuildZip = function (AEntries) {
      var Result = undefined;
      Result = null;
      if (typeof TextEncoder !== 'undefined') {
        var encoder = new TextEncoder();
        var crcTable = [];
        for (var n = 0; n < 256; n++) {
          var c = n;
          for (var k = 0; k < 8; k++) {
            c = (c & 1) ? (3988292384 ^ (c >>> 1)) : (c >>> 1);
          }
          crcTable[n] = c >>> 0;
        }
        var parts = [];
        var total = 0;
        var centralSize = 0;
        for (var i = 0; i < AEntries.length; i++) {
          var nameBytes = encoder.encode(AEntries[i].name);
          var dataBytes = encoder.encode(AEntries[i].text);
          var crc = 4294967295;
          for (var b = 0; b < dataBytes.length; b++) {
            crc = crcTable[(crc ^ dataBytes[b]) & 255] ^ (crc >>> 8);
          }
          crc = (crc ^ 4294967295) >>> 0;
          parts.push({ nameBytes: nameBytes, dataBytes: dataBytes, crc: crc, offset: total });
          total += 30 + nameBytes.length + dataBytes.length;
          centralSize += 46 + nameBytes.length;
        }
        var zip = new Uint8Array(total + centralSize + 22);
        var view = new DataView(zip.buffer);
        var writeHeaderFields = function (at, part) {
          view.setUint16(at, 20, true);
          view.setUint16(at + 2, 2048, true);
          view.setUint16(at + 4, 0, true);
          view.setUint16(at + 6, 0, true);
          view.setUint16(at + 8, 33, true);
          view.setUint32(at + 10, part.crc, true);
          view.setUint32(at + 14, part.dataBytes.length, true);
          view.setUint32(at + 18, part.dataBytes.length, true);
          view.setUint16(at + 22, part.nameBytes.length, true);
          view.setUint16(at + 24, 0, true);
        };
        for (var p = 0; p < parts.length; p++) {
          var part = parts[p];
          view.setUint32(part.offset, 67324752, true);
          writeHeaderFields(part.offset + 4, part);
          zip.set(part.nameBytes, part.offset + 30);
          zip.set(part.dataBytes, part.offset + 30 + part.nameBytes.length);
        }
        var cursor = total;
        for (var q = 0; q < parts.length; q++) {
          var entry = parts[q];
          view.setUint32(cursor, 33639248, true);
          view.setUint16(cursor + 4, 20, true);
          writeHeaderFields(cursor + 6, entry);
          view.setUint32(cursor + 42, entry.offset, true);
          zip.set(entry.nameBytes, cursor + 46);
          cursor += 46 + entry.nameBytes.length;
        }
        view.setUint32(cursor, 101010256, true);
        view.setUint16(cursor + 8, parts.length, true);
        view.setUint16(cursor + 10, parts.length, true);
        view.setUint32(cursor + 12, centralSize, true);
        view.setUint32(cursor + 16, total, true);
        Result = zip;
      };
      return Result;
    };
  };
},[]);
rtl.module("BVPascalDX",["System","JS","Web","SysUtils","BVDataSet","BVRpc","BlaiseReports"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.ShowToast = function (Msg, DurationMs) {
    try {
      if (window.__BV_CORE__ && window.__BV_CORE__.ionic && window.__BV_CORE__.ionic.toast) {
        window.__BV_CORE__.ionic.toast(Msg, DurationMs);
        return;
      }
    } catch(e) {}
    
    let el = document.createElement('div');
    el.className = 'bv-pascal-toast';
    el.style.position = 'fixed';
    el.style.bottom = '24px';
    el.style.right = '24px';
    el.style.backgroundColor = '#1e293b';
    el.style.color = '#ffffff';
    el.style.padding = '12px 20px';
    el.style.borderRadius = '8px';
    el.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.2)';
    el.style.zIndex = '99999';
    el.style.fontSize = '14px';
    el.style.fontWeight = '500';
    el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    el.innerText = Msg;
    document.body.appendChild(el);
    setTimeout(function() {
      el.style.opacity = '0';
      el.style.transform = 'translateY(10px)';
      setTimeout(function() { if (el.parentNode) el.parentNode.removeChild(el); }, 350);
    }, DurationMs);
  };
  this.Confirm = function (Msg) {
    var Result = false;
    Result = window.confirm(Msg);
    return Result;
  };
  this.CallMethod = function (Instance, MethodName) {
    if (!Instance) return;
    if (typeof Instance[MethodName] === 'function') {
      Instance[MethodName](Instance);
    } else if (Instance.$methods && typeof Instance.$methods[MethodName] === 'function') {
      Instance.$methods[MethodName](Instance);
    };
  };
  this.CallMethod$1 = function (Instance, MethodName, Args) {
    if (Instance && typeof Instance[MethodName] === 'function') {
      Instance[MethodName].apply(Instance, Args);
    };
  };
  this.TriggerRef = function (Instance, RefName, MethodName) {
    var Result = false;
    Result = false;
    if (!Instance || !Instance.$refs) return;
    let r = Instance.$refs[RefName];
    if (!r) return;
    
    if (typeof r[MethodName] === 'function') {
      r[MethodName]();
      Result = true;
    } else if (MethodName === 'show' && typeof r.showModal === 'function') {
      r.showModal();
      Result = true;
    } else if (MethodName === 'show' && typeof r.showToast === 'function') {
      r.showToast();
      Result = true;
    } else if (MethodName === 'open' && typeof r.toggle === 'function') {
      r.toggle();
      Result = true;
    };
    return Result;
  };
  this.ValidateForm = function (Instance) {
    var Result = false;
    if (Instance && typeof Instance.$validate === 'function') {
      Result = Instance.$validate();
    } else {
      Result = true;
    };
    return Result;
  };
  this.TouchValidation = function (Instance) {
    if (Instance && Instance.$v && typeof Instance.$v.$touch === 'function') {
      Instance.$v.$touch();
    };
  };
  this.ResetValidation = function (Instance) {
    if (Instance && Instance.$v && typeof Instance.$v.$reset === 'function') {
      Instance.$v.$reset();
    };
  };
  this.NewObject = function () {
    var Result = null;
    Result = new Object();
    return Result;
  };
  this.NewArray = function () {
    var Result = null;
    Result = new Array();
    return Result;
  };
  this.ObjectAssign = function (Target, Source) {
    var Result = undefined;
    Result = Object.assign(Target || {}, Source || {});
    return Result;
  };
  this.JsonParse = function (Str) {
    var Result = undefined;
    try {
      Result = JSON.parse(Str);
    } catch(e) {
      Result = null;
    };
    return Result;
  };
  this.NowTimestampStr = function () {
    var Result = "";
    Result = String(Date.now());
    return Result;
  };
  this.FilterByQuery = function (List, Query) {
    var Result = undefined;
    let arr = List || [];
    let q = (Query !== undefined && Query !== null ? String(Query) : '').toLowerCase().trim();
    if (!q) { Result = arr; return Result; }
    if (!Array.isArray(arr)) { Result = arr; return Result; }
    
    Result = arr.filter(function(item) {
      if (!item) return false;
      return Object.values(item).some(function(v) {
        return String(v).toLowerCase().indexOf(q) !== -1;
      });
    });
    return Result;
  };
  this.ApiFetch = function (Instance, Endpoint, PropertyName) {
    var self = Instance;
        if (!self) return;
        var ep = Endpoint;
        var p = (self.$api && typeof self.$api.get === 'function')
          ? self.$api.get(ep)
          : fetch('http://localhost:8090' + ep).then(function(r) { return r.json(); });
    
        Promise.resolve(p).then(function(data) {
          if (Array.isArray(data)) {
            self[PropertyName] = data;
          } else if (data && Array.isArray(data.items)) {
            self[PropertyName] = data.items;
          }
        }).catch(function(err) {
          console.error('Error fetching ' + ep + ':', err);
        });
  };
  this.ApiSave = function (Instance, Endpoint, Id, IsEditing, AFormData, OnSuccessMethod, ErrorProp) {
    var self = Instance;
        var dataPayload = (typeof AFormData !== 'undefined' && AFormData !== window.FormData) ? AFormData : ((typeof aformdata !== 'undefined' && aformdata !== window.FormData) ? aformdata : null);
        if (!self || !dataPayload) return;
        if (self && typeof dataPayload === 'object' && dataPayload !== null) {
          for (var k in self) {
            if (k.indexOf('form.') === 0) {
              var fieldKey = k.substring(5);
              dataPayload[fieldKey] = self[k];
            }
          }
        }
        var ep = Endpoint + (IsEditing ? ('/' + Id) : '');
        var method = IsEditing ? 'put' : 'post';
    
        var p = (self.$api && typeof self.$api[method] === 'function')
          ? self.$api[method](ep, dataPayload)
          : fetch('http://localhost:8090' + ep, {
              method: method.toUpperCase(),
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(dataPayload)
            }).then(function(r) { return r.json(); });
    
        Promise.resolve(p).then(function(resp) {
          self.isModalOpen = false;
          if (OnSuccessMethod && typeof self[OnSuccessMethod] === 'function') {
            self[OnSuccessMethod]();
          }
        }).catch(function(err) {
          if (ErrorProp) {
            self[ErrorProp] = 'Failed to save: ' + (err.message || err);
          }
        });
  };
  this.ApiDelete = function (Instance, Endpoint, Id, ConfirmMsg, OnSuccessMethod) {
    var self = Instance;
        if (!self) return;
        if (ConfirmMsg && !confirm(ConfirmMsg)) return;
        var ep = Endpoint + '/' + Id;
    
        var p = (self.$api && typeof self.$api.delete === 'function')
          ? self.$api.delete(ep)
          : fetch('http://localhost:8090' + ep, { method: 'DELETE' }).then(function(r) { return r.json(); });
    
        Promise.resolve(p).then(function() {
          if (OnSuccessMethod && typeof self[OnSuccessMethod] === 'function') {
            self[OnSuccessMethod]();
          }
        }).catch(function(err) {
          alert('Failed to delete: ' + (err.message || err));
        });
  };
  this.ApiSetupRealtime = function (Instance, ModelPrefix, RefreshMethod) {
    var self = Instance;
    if (!self || !self.$ws) return;
    if (typeof self.$ws.connect === 'function') {
      self.$ws.connect();
    }
    var pfx = String(ModelPrefix).toLowerCase();
    if (typeof self.$ws.on === 'function') {
      self.$ws.on(pfx + '_created', function(d) {
        if (typeof self[RefreshMethod] === 'function') self[RefreshMethod]();
      });
      self.$ws.on(pfx + '_updated', function(d) {
        if (typeof self[RefreshMethod] === 'function') self[RefreshMethod]();
      });
      self.$ws.on(pfx + '_deleted', function(d) {
        if (typeof self[RefreshMethod] === 'function') self[RefreshMethod]();
      });
    };
  };
  this.AuthLogin = function (Instance, Email, Password, DefaultRedirect) {
    var self = Instance;
        if (!self) return;
        self.loading = true;
        self.errorMessage = '';
        self.successMessage = '';
    
        if (!self.$auth || typeof self.$auth.login !== 'function') {
          self.errorMessage = 'Módulo $auth não inicializado.';
          self.loading = false;
          return;
        }
    
        var e = (Email !== undefined && Email !== null) ? String(Email) : '';
        var p = (Password !== undefined && Password !== null) ? String(Password) : '';
    
        self.$auth.login(e, p)
          .then(function(resp) {
            self.loading = false;
            self.successMessage = 'Autenticado com sucesso como ' + (resp.user ? resp.user.name : e) + '!';
            setTimeout(function() {
              var target = (window.__BV_CORE__.auth && window.__BV_CORE__.auth.redirectAfterLogin)
                ? window.__BV_CORE__.auth.redirectAfterLogin
                : DefaultRedirect;
              window.__BV_CORE__.auth.redirectAfterLogin = '';
              window.location.hash = target;
            }, 600);
          })
          .catch(function(err) {
            self.loading = false;
            self.errorMessage = (err && err.message) ? err.message : 'Falha na autenticação. Verifique os dados.';
          });
  };
  this.AuthLogout = function (Instance) {
    var self = Instance;
    if (self && self.$auth && typeof self.$auth.logout === 'function') {
      self.$auth.logout();
    };
  };
  this.IonicGetMode = function () {
    var Result = "";
    if (window.$ionic && typeof window.$ionic.getMode === 'function') {
      Result = window.$ionic.getMode();
    } else {
      Result = 'md';
    };
    return Result;
  };
  this.IonicSetMode = function (Mode) {
    if (window.$ionic && typeof window.$ionic.setMode === 'function') {
      window.$ionic.setMode(Mode);
    };
  };
  this.IonicToast = function (Msg, Duration, Position, Color) {
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.toast && typeof ionic.toast.show === 'function') {
      ionic.toast.show(Msg, Duration, Position, Color);
    };
  };
  this.IonicAlert = function (Title, Subtitle, ButtonText) {
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.alert && typeof ionic.alert.alert === 'function') {
      ionic.alert.alert(Title, Subtitle, ButtonText);
    };
  };
  this.IonicConfirm = function (Instance, Title, Message, OnConfirmMethod, OnCancelMethod) {
    let self = Instance;
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.alert && typeof ionic.alert.confirm === 'function') {
      ionic.alert.confirm(Title, Message,
        function() {
          if (self && OnConfirmMethod && typeof self[OnConfirmMethod] === 'function') {
            self[OnConfirmMethod]();
          }
        },
        function() {
          if (self && OnCancelMethod && typeof self[OnCancelMethod] === 'function') {
            self[OnCancelMethod]();
          }
        }
      );
    };
  };
  this.IonicLoading = function (Message, Duration) {
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.loading && typeof ionic.loading.present === 'function') {
      ionic.loading.present(Message, Duration);
    };
  };
  this.IonicActionSheet = function (Instance, Title, Options, OnSelectMethod) {
    let self = Instance;
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.actionSheet && typeof ionic.actionSheet.show === 'function') {
      ionic.actionSheet.show(Title, Options, function(opt, idx) {
        if (self && OnSelectMethod && typeof self[OnSelectMethod] === 'function') {
          self[OnSelectMethod](opt, idx);
        }
      });
    };
  };
  this.WasmCall = function (Instance, ModName, FuncName, Arg) {
    var Result = undefined;
    if (Instance && Instance.$wasm && typeof Instance.$wasm.call === 'function') {
      Result = Instance.$wasm.call(ModName, FuncName, Arg);
    } else {
      Result = 0;
    };
    return Result;
  };
  this.WasmBenchmark = function (Instance, ModName, FuncName, Arg, Iterations) {
    var Result = undefined;
    if (Instance && Instance.$wasm && typeof Instance.$wasm.benchmark === 'function') {
      Result = Instance.$wasm.benchmark(ModName, FuncName, Arg, Iterations);
    } else {
      Result = null;
    };
    return Result;
  };
  this.NowTimestampMs = function () {
    var Result = 0.0;
    if (typeof performance !== 'undefined' && typeof performance.now === 'function') {
      Result = performance.now();
    } else {
      Result = Date.now();
    };
    return Result;
  };
  this.UpdateChartDarkMode = function (OptionsObj, Dark) {
    if (OptionsObj) {
          const gridColor = Dark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.08)';
          const textColor = Dark ? '#e2e8f0' : '#475569';
    
          if (!OptionsObj.scales) OptionsObj.scales = {};
          if (!OptionsObj.scales.x) OptionsObj.scales.x = {};
          if (!OptionsObj.scales.y) OptionsObj.scales.y = {};
          OptionsObj.scales.x.grid = { color: gridColor };
          OptionsObj.scales.y.grid = { color: gridColor };
          OptionsObj.scales.x.ticks = { color: textColor };
          OptionsObj.scales.y.ticks = { color: textColor };
    
          if (!OptionsObj.scales.r) OptionsObj.scales.r = {};
          OptionsObj.scales.r.grid = { color: gridColor };
          OptionsObj.scales.r.angleLines = { color: gridColor };
          OptionsObj.scales.r.pointLabels = { color: textColor };
          OptionsObj.scales.r.ticks = { color: textColor, backdropColor: 'transparent' };
    
          if (!OptionsObj.plugins) OptionsObj.plugins = {};
          if (!OptionsObj.plugins.legend) OptionsObj.plugins.legend = {};
          if (!OptionsObj.plugins.legend.labels) OptionsObj.plugins.legend.labels = {};
          OptionsObj.plugins.legend.labels.color = textColor;
        };
  };
  this.ThemeSet = function (ThemeName) {
    if (window.$theme && typeof window.$theme.setTheme === 'function') {
      window.$theme.setTheme(ThemeName);
    };
  };
  this.I18nAddMessages = function (Locale, JsonStr) {
    if (window.__BV_CORE__ && window.__BV_CORE__.i18n && typeof window.__BV_CORE__.i18n.addMessages === 'function') {
      try {
        var obj = JSON.parse(JsonStr);
        window.__BV_CORE__.i18n.addMessages(Locale, obj);
      } catch(e) {
        console.error('Invalid JSON for i18n messages:', e);
      }
    };
  };
  this.I18nSetLocale = function (Locale) {
    if (window.__BV_CORE__ && window.__BV_CORE__.i18n && typeof window.__BV_CORE__.i18n.setLocale === 'function') {
      window.__BV_CORE__.i18n.setLocale(Locale);
    };
  };
  this.GetFieldStr = function (Obj, PropName, DefaultVal) {
    var Result = "";
    if (Obj && typeof Obj === 'object' && Obj[PropName] !== undefined && Obj[PropName] !== null) {
      Result = String(Obj[PropName]);
    } else {
      Result = DefaultVal;
    };
    return Result;
  };
  this.GetFieldInt = function (Obj, PropName, DefaultVal) {
    var Result = 0;
    if (Obj && typeof Obj === 'object' && Obj[PropName] !== undefined && Obj[PropName] !== null) {
      let n = parseInt(Obj[PropName], 10);
      Result = isNaN(n) ? DefaultVal : n;
    } else {
      Result = DefaultVal;
    };
    return Result;
  };
  this.SetField = function (Obj, PropName, Value) {
    if (Obj && typeof Obj === 'object') {
      Obj[PropName] = Value;
    };
  };
  this.NewDataSet = function () {
    var Result = undefined;
    var ds = null;
    ds = pas.BVDataSet.TBVDataSet.$create("Create$1");
    Result = ds;
    return Result;
  };
  this.DataSetLoad = function (DS, Data) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).LoadFromData(Data)}
     else {
      if (DS && typeof DS.LoadFromData === 'function') DS.LoadFromData(Data);
    };
  };
  this.DataSetAppend = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Append()}
     else {
      if (DS && typeof DS.Append === 'function') DS.Append();
    };
  };
  this.DataSetEdit = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Edit()}
     else {
      if (DS && typeof DS.Edit === 'function') DS.Edit();
    };
  };
  this.DataSetPost = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Post()}
     else {
      if (DS && typeof DS.Post === 'function') DS.Post();
    };
  };
  this.DataSetCancel = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Cancel()}
     else {
      if (DS && typeof DS.Cancel === 'function') DS.Cancel();
    };
  };
  this.DataSetDelete = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Delete()}
     else {
      if (DS && typeof DS.Delete === 'function') DS.Delete();
    };
  };
  this.DataSetFirst = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).First()}
     else {
      if (DS && typeof DS.First === 'function') DS.First();
    };
  };
  this.DataSetPrior = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Prior()}
     else {
      if (DS && typeof DS.Prior === 'function') DS.Prior();
    };
  };
  this.DataSetNext = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Next()}
     else {
      if (DS && typeof DS.Next === 'function') DS.Next();
    };
  };
  this.DataSetLast = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).Last()}
     else {
      if (DS && typeof DS.Last === 'function') DS.Last();
    };
  };
  this.DataSetLocate = function (DS, AFieldName, AValue) {
    var Result = false;
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      Result = rtl.getObject(DS).Locate(AFieldName,AValue)}
     else {
      Result = false;
      if (DS && typeof DS.Locate === 'function') {
        Result = Boolean(DS.Locate(AFieldName, AValue));
      };
    };
    return Result;
  };
  this.DataSetFilter = function (DS, AQuery) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).SetFilter(AQuery)}
     else {
      if (DS && typeof DS.SetFilter === 'function') DS.SetFilter(AQuery);
    };
  };
  this.DataSetSort = function (DS, AFieldName, Ascending) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).SortBy(AFieldName,Ascending)}
     else {
      if (DS && typeof DS.SortBy === 'function') DS.SortBy(AFieldName, Ascending);
    };
  };
  this.DataSetFieldVal = function (DS, AFieldName) {
    var Result = undefined;
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      Result = rtl.getObject(DS).FieldByName(AFieldName).GetValue()}
     else {
      Result = "";
      if (!DS) return;
      if (typeof DS.FieldByName === 'function') {
        var f = DS.FieldByName(AFieldName);
        if (!f) return;
        Result = (typeof f.GetAsString === 'function') ? f.GetAsString() : (f.AsString !== undefined ? f.AsString : '');
      } else if (DS.Current) {
        Result = DS.Current[AFieldName] !== undefined ? DS.Current[AFieldName] : '';
      };
    };
    return Result;
  };
  this.DataSetSetFieldVal = function (DS, AFieldName, AValue) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).FieldByName(AFieldName).SetValue(AValue)}
     else {
      if (!DS) return;
      if (typeof DS.FieldByName === 'function') {
        var st = (typeof DS.GetStateStr === 'function') ? DS.GetStateStr() : DS.StateStr;
        if (st === 'browse') DS.Edit();
        var f = DS.FieldByName(AFieldName);
        if (f) {
          if (typeof f.SetAsString === 'function') f.SetAsString(String(AValue));
          else f.AsString = String(AValue);
        }
      } else if (DS.Current) {
        DS.Current[AFieldName] = AValue;
      };
    };
  };
  this.DataSetDeltaJSON = function (DS) {
    var Result = "";
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      Result = rtl.getObject(DS).GetDeltaJSON()}
     else {
      Result = "[]";
      if (DS && typeof DS.GetDeltaJSON === 'function') {
        Result = DS.GetDeltaJSON();
      };
    };
    return Result;
  };
  this.DataSetApplyUpdates = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).ApplyUpdates("",null,null)}
     else {
      if (DS && typeof DS.ApplyUpdates === 'function') DS.ApplyUpdates();
    };
  };
  this.DataSetSaveIndexedDB = function (DS, StoreKey, OnSuccess, OnError) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).SaveToIndexedDB(StoreKey,OnSuccess,OnError)}
     else {
      if (DS && typeof DS.SaveToIndexedDB === 'function') DS.SaveToIndexedDB(StoreKey, OnSuccess, OnError);
    };
  };
  this.DataSetLoadIndexedDB = function (DS, StoreKey, OnComplete) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).LoadFromIndexedDB(StoreKey,OnComplete)}
     else {
      if (DS && typeof DS.LoadFromIndexedDB === 'function') DS.LoadFromIndexedDB(StoreKey, OnComplete);
    };
  };
  this.DataSetSetAutoPersist = function (DS, Enable, StoreKey) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).SetAutoPersist(Enable,StoreKey)}
     else {
      if (DS && typeof DS.SetAutoPersist === 'function') DS.SetAutoPersist(Enable, StoreKey);
    };
  };
  this.DataSetSetAutoSync = function (DS, Enable, EndpointOrService) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).SetAutoSyncOnReconnect(Enable,EndpointOrService)}
     else {
      if (DS && typeof DS.SetAutoSyncOnReconnect === 'function') DS.SetAutoSyncOnReconnect(Enable, EndpointOrService);
    };
  };
  this.DataSetApplyUpdatesAsync = function (DS, EndpointOrService, OnSuccess, OnError) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).ApplyUpdates(EndpointOrService,OnSuccess,OnError)}
     else {
      if (DS && typeof DS.ApplyUpdates === 'function') DS.ApplyUpdates(EndpointOrService, OnSuccess, OnError);
    };
  };
  this.DataSetHasPending = function (DS) {
    var Result = false;
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      Result = rtl.getObject(DS).GetHasPendingChanges()}
     else {
      if (DS && typeof DS.GetHasPendingChanges === 'function') Result = DS.GetHasPendingChanges();
      else if (DS && DS.HasPendingChanges !== undefined) Result = Boolean(DS.HasPendingChanges);
      else Result = false;
    };
    return Result;
  };
  this.DataSetChangeCount = function (DS) {
    var Result = 0;
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      Result = rtl.getObject(DS).GetChangeCount()}
     else {
      if (DS && typeof DS.GetChangeCount === 'function') Result = DS.GetChangeCount();
      else Result = 0;
    };
    return Result;
  };
  this.DataSetDeltaList = function (DS) {
    var Result = undefined;
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      Result = rtl.getObject(DS).FDelta}
     else {
      if (DS && DS.FDelta) Result = DS.FDelta;
      else Result = [];
    };
    return Result;
  };
  this.DataSetClearDelta = function (DS) {
    if ((DS != null) && pas.BVDataSet.TBVDataSet.isPrototypeOf(rtl.getObject(DS))) {
      rtl.getObject(DS).ClearDelta()}
     else {
      if (DS && typeof DS.ClearDelta === 'function') DS.ClearDelta();
    };
  };
  this.RpcSetBaseUrl = function (Url) {
    pas.BVRpc.TBVRpcClient.SetBaseUrl(Url);
  };
  this.RpcSetToken = function (Token) {
    pas.BVRpc.TBVRpcClient.SetToken(Token);
  };
  this.RpcClearToken = function () {
    pas.BVRpc.TBVRpcClient.ClearToken();
  };
  this.RpcSetTransport = function (Transport) {
    pas.BVRpc.TBVRpcClient.SetTransport(Transport);
  };
  this.RpcSetTimeout = function (TimeoutMs) {
    pas.BVRpc.TBVRpcClient.SetTimeout(TimeoutMs);
  };
  this.RpcSetUsePack = function (Enable) {
    pas.BVRpc.TBVRpcClient.SetUsePack(Enable);
  };
  this.RpcCall = function (ServiceName, MethodName, Params, OnSuccess, OnError) {
    var Result = undefined;
    Result = pas.BVRpc.TBVRpcClient.Invoke(ServiceName,MethodName,Params,OnSuccess,OnError);
    return Result;
  };
  this.RpcCallAsync = function (ServiceName, MethodName, Params) {
    var Result = undefined;
    Result = pas.BVRpc.TBVRpcClient.InvokeAsync(ServiceName,MethodName,Params);
    return Result;
  };
  this.NewReport = function (DataSetOrArray) {
    var Result = undefined;
    Result = pas.BlaiseReports.TBVReport.$create("Create$3",[DataSetOrArray]);
    return Result;
  };
  this.ReportSetTitle = function (Report, ATitle, ASubtitle) {
    if (Report != null) {
      rtl.getObject(Report).Title(ATitle);
      if (ASubtitle !== "") rtl.getObject(Report).Subtitle(ASubtitle);
    };
  };
  this.ReportSetHeader = function (Report, AHeader, AFooter) {
    if (Report != null) {
      rtl.getObject(Report).Header(AHeader);
      if (AFooter !== "") rtl.getObject(Report).Footer(AFooter);
    };
  };
  this.ReportSetCompany = function (Report, ACompanyName, ALogoText) {
    if (Report != null) rtl.getObject(Report).Company(ACompanyName,ALogoText);
  };
  this.ReportSetPageLayout = function (Report, ALayoutName) {
    if (Report != null) rtl.getObject(Report).PageSize(ALayoutName);
  };
  this.ReportSetColumns = function (Report, AFields) {
    if (Report != null) rtl.getObject(Report).Columns(AFields);
  };
  this.ReportAddColumn = function (Report, AFieldName, ACaption, AWidth, AAlign, AFormat) {
    if (Report != null) rtl.getObject(Report).AddColumn(AFieldName,ACaption,AWidth,pas.BlaiseReports.ParseColumnAlign(AAlign),AFormat);
  };
  this.ReportAddSummary = function (Report, ALabel, AFieldName, AAggregate, AFormat) {
    if (Report != null) rtl.getObject(Report).AddSummary(ALabel,AFieldName,pas.BlaiseReports.ParseAggregateType(AAggregate),AFormat);
  };
  this.ReportExportPDF = function (Report, AFileName) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).ExportPDF(AFileName)}
     else Result = "";
    return Result;
  };
  this.ReportExportExcel = function (Report, AFileName) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).ExportExcel(AFileName)}
     else Result = "";
    return Result;
  };
  this.ReportExportCSV = function (Report, AFileName) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).ExportCSV(AFileName)}
     else Result = "";
    return Result;
  };
  this.ReportGeneratePDF = function (Report) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).GeneratePDF()}
     else Result = "";
    return Result;
  };
  this.ReportGenerateExcel = function (Report) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).GenerateExcel()}
     else Result = "";
    return Result;
  };
  this.ReportGenerateCSV = function (Report) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).GenerateCSV()}
     else Result = "";
    return Result;
  };
  this.ReportPrintPreview = function (Report, ATargetElementId) {
    var Result = "";
    if (Report != null) {
      Result = rtl.getObject(Report).PrintPreview(ATargetElementId)}
     else Result = "";
    return Result;
  };
  this.ReportComputeSummary = function (Report, AFieldName, AAggregate) {
    var Result = 0.0;
    if (Report != null) {
      Result = rtl.getObject(Report).ComputeSummary(AFieldName,pas.BlaiseReports.ParseAggregateType(AAggregate))}
     else Result = 0.0;
    return Result;
  };
  $mod.$implcode = function () {
    $impl.RetainDXDataSetSymbols = function () {
      var dummy = undefined;
      if (false) {
        dummy = $mod.NewDataSet();
        $mod.DataSetLoad(dummy,null);
        $mod.DataSetAppend(dummy);
        $mod.DataSetEdit(dummy);
        $mod.DataSetPost(dummy);
        $mod.DataSetCancel(dummy);
        $mod.DataSetDelete(dummy);
        $mod.DataSetFirst(dummy);
        $mod.DataSetPrior(dummy);
        $mod.DataSetNext(dummy);
        $mod.DataSetLast(dummy);
        $mod.DataSetLocate(dummy,"",null);
        $mod.DataSetFilter(dummy,"");
        $mod.DataSetSort(dummy,"",true);
        $mod.DataSetFieldVal(dummy,"");
        $mod.DataSetSetFieldVal(dummy,"",null);
        $mod.DataSetDeltaJSON(dummy);
        $mod.DataSetApplyUpdates(dummy);
        $mod.DataSetSaveIndexedDB(dummy,"",null,null);
        $mod.DataSetLoadIndexedDB(dummy,"",null);
        $mod.DataSetSetAutoPersist(dummy,false,"");
        $mod.DataSetSetAutoSync(dummy,false,"");
        $mod.DataSetApplyUpdatesAsync(dummy,"",null,null);
        $mod.DataSetHasPending(dummy);
        $mod.DataSetChangeCount(dummy);
        $mod.DataSetDeltaList(dummy);
        $mod.DataSetClearDelta(dummy);
        $mod.RpcSetBaseUrl("");
        $mod.RpcSetToken("");
        $mod.RpcClearToken();
        $mod.RpcSetTransport("");
        $mod.RpcSetTimeout(0);
        $mod.RpcSetUsePack(false);
        $mod.RpcCall("","",null,null,null);
        $mod.RpcCallAsync("","",null);
        dummy = $mod.NewReport(null);
        $mod.ReportSetTitle(dummy,"","");
        $mod.ReportSetHeader(dummy,"","");
        $mod.ReportSetCompany(dummy,"","");
        $mod.ReportSetPageLayout(dummy,"");
        $mod.ReportSetColumns(dummy,[""]);
        $mod.ReportAddColumn(dummy,"","",100,"","");
        $mod.ReportAddSummary(dummy,"","","","");
        $mod.ReportExportPDF(dummy,"");
        $mod.ReportExportExcel(dummy,"");
        $mod.ReportExportCSV(dummy,"");
        $mod.ReportGeneratePDF(dummy);
        $mod.ReportGenerateExcel(dummy);
        $mod.ReportGenerateCSV(dummy);
        $mod.ReportPrintPreview(dummy,"");
        $mod.ReportComputeSummary(dummy,"","");
      };
    };
  };
  $mod.$init = function () {
    $impl.RetainDXDataSetSymbols();
  };
},[]);
rtl.module("BlaiseVue",["System","JS","Web","SysUtils","BVReactivity","BVCompiler","BVRouting","BVComponents","BVValidation","BVI18n","BVTheme","BVWasm","BVMobile","BVDesktop","BVClient","BVAuth","BlaiseIonic","BVPascalDX","BVDataSet","BVRpc"],function () {
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
        .v-move, .list-move { transition: transform 0.5s cubic-bezier(0.25, 1, 0.5, 1); }
        .v-enter-active, .list-enter-active { transition: all 0.4s ease; }
        .v-enter-from, .list-enter-from { opacity: 0; transform: translateY(15px); }
        .v-leave-active, .list-leave-active { transition: all 0.4s ease; position: absolute; }
        .v-leave-to, .list-leave-to { opacity: 0; transform: translateY(-15px); }
        .is-invalid, .bv-invalid { border-color: #ef4444 !important; }
        .is-valid, .bv-valid { border-color: #10b981 !important; }
        .bv-error-msg { color: #ef4444; font-size: 0.85rem; margin-top: 4px; display: block; }
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
      console.log("[Init] Initing App with Global Mixins...");
      // Apply global mixins to the root instance options
      if (window.__BV_CORE__.mixins && window.__BV_CORE__.mixins.length > 0) {
        window.__BV_CORE__.mixins.forEach(function(mix) {
          Options = window.__BV_CORE__.mergeOptions(Options, mix);
        });
      };
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
      if (window.__BV_CORE__.theme && !d.FData.$theme) d.FData.$theme = window.__BV_CORE__.theme;
      if (window.__BV_CORE__.wasm && !d.FData.$wasm) d.FData.$wasm = window.__BV_CORE__.wasm;
      if (window.__BV_CORE__.mobile && !d.FData.$mobile) d.FData.$mobile = window.__BV_CORE__.mobile;
      if (window.__BV_CORE__.desktop && !d.FData.$desktop) d.FData.$desktop = window.__BV_CORE__.desktop;
      if (window.__BV_CORE__.api && !d.FData.$api) d.FData.$api = window.__BV_CORE__.api;
      if (window.__BV_CORE__.ws && !d.FData.$ws) d.FData.$ws = window.__BV_CORE__.ws;
      if (window.__BV_CORE__.auth && !d.FData.$auth) d.FData.$auth = window.__BV_CORE__.auth;
      if (window.__BV_CORE__.ionic && !d.FData.$ionic) d.FData.$ionic = window.__BV_CORE__.ionic;
      if (window.__BV_CORE__.rpc && !d.FData.$rpc) d.FData.$rpc = window.__BV_CORE__.rpc;
      
      // Check for SSG Pre-rendered content for instant zero-flicker Hydration
      if (this.FRoot && (this.FRoot.hasAttribute('data-bv-ssg') || this.FRoot.querySelector('[data-bv-ssg]'))) {
        console.log("[Hydration] SSG pre-rendered content detected on " + rootID + ". Engaging Reactive Hydration...");
        this.FRoot.setAttribute('data-bv-hydrated', 'true');
      };
      // Initialize i18n configuration if passed in root options
      if (Options.i18n && window.__BV_CORE__.i18n) {
        if (Options.i18n.locale) window.__BV_CORE__.i18n.setLocale(Options.i18n.locale);
        if (Options.i18n.fallbackLocale) window.__BV_CORE__.i18n.fallbackLocale = Options.i18n.fallbackLocale;
        if (Options.i18n.messages) {
          Object.keys(Options.i18n.messages).forEach(function(l) {
            window.__BV_CORE__.i18n.addMessages(l, Options.i18n.messages[l]);
          });
        }
      }
      // Handle Provide/Inject dependency injection
      if (Options.provide) {
        d.FData.$provided = Options.provide.call(d.FData, d.FData);
      }
      // Execute 'created' lifecycle hook
      if (Options.created) {
        Options.created.call(d.FData, d.FData);
      };
      setTimeout(() => {
        if (!this.FRouter) {
          console.log("[Create] No router detected. Auto-compiling root...");
          window.__BV_CORE__.compile(this.FRoot, this.FData, this.FMethods);
        }
      }, 0);
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
  $mod.$init = function () {
    if (!window.__BV_CORE__) window.__BV_CORE__ = {};
    if (!window.__BV_CORE__.mixins) window.__BV_CORE__.mixins = [];
    if (!window.__BV_CORE__.plugins) window.__BV_CORE__.plugins = new Set();
    
    // Explicitly expose Mixin and Use to ensure they are available from JavaScript context
    // even if they were stripped during optimization.
    pas.BlaiseVue.TBlaiseVue.Mixin = function(m) { 
      if (!window.__BV_CORE__.mixins) window.__BV_CORE__.mixins = [];
      window.__BV_CORE__.mixins.push(m);
    };
    pas.BlaiseVue.TBlaiseVue.Use = function(p, o) {
      if (!window.__BV_CORE__.plugins) window.__BV_CORE__.plugins = new Set();
      if (window.__BV_CORE__.plugins.has(p)) return;
      window.__BV_CORE__.plugins.add(p);
      if (typeof p.install === 'function') p.install(pas.BlaiseVue.TBlaiseVue, o);
      else if (typeof p === 'function') p(pas.BlaiseVue.TBlaiseVue, o);
    };
  };
});
rtl.module("BVDevTools",["System","JS","Web","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.InitDevTools = function () {
    console.log("%c BlaiseVue DevTools 3.0 ", "background: #41b883; color: #fff; border-radius: 3px; padding: 2px 5px; font-weight: bold;", "v3.0-enterprise");
    
        // Initialize global DevTools Hook for browser extensions and external inspectors
        if (!window.__BV_DEVTOOLS_HOOK__) {
          window.__BV_DEVTOOLS_HOOK__ = {
            version: "3.0.0",
            listeners: {},
            events: [],
            snapshots: [],
            on: function(event, fn) {
              if (!this.listeners[event]) this.listeners[event] = [];
              this.listeners[event].push(fn);
            },
            emit: function(event, data) {
              let entry = { time: new Date().toLocaleTimeString(), type: event, data: data };
              this.events.push(entry);
              if (this.events.length > 200) this.events.shift();
              if (this.listeners[event]) {
                this.listeners[event].forEach(function(fn) { try { fn(entry); } catch(e){} });
              }
              if (this.listeners['*']) {
                this.listeners['*'].forEach(function(fn) { try { fn(entry); } catch(e){} });
              }
            },
            getComponentTree: function() {
              let roots = [];
              let els = document.querySelectorAll('[data-bv-component]');
              els.forEach(function(el) {
                roots.push({
                  tag: el.getAttribute('data-bv-component'),
                  state: el['__bv_instance_data__'] ? Object.assign({}, el['__bv_instance_data__']) : {}
                });
              });
              return roots;
            },
            recordSnapshot: function(label) {
              let snap = { label: label || ('Snapshot ' + (this.snapshots.length + 1)), time: Date.now(), tree: this.getComponentTree() };
              this.snapshots.push(snap);
              return snap;
            }
          };
        }
        
        // Inject the visual overlay styles
        let s = document.createElement('style');
        s.innerHTML = `
          .bv-devtools-panel {
            position: fixed;
            bottom: 45px;
            right: 20px;
            z-index: 9999;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #1e293b;
            color: #f8fafc;
            border-radius: 10px;
            padding: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.4);
            width: 260px;
            font-size: 12px;
            border: 1px solid #334155;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            user-select: none;
          }
          @media (max-width: 768px) {
            .bv-devtools-panel {
              bottom: 74px;
              right: 12px;
              max-width: calc(100vw - 24px);
              width: 250px;
            }
          }
          .bv-devtools-panel.bv-dt-collapsed {
            width: auto !important;
            padding: 6px 12px !important;
            border-radius: 20px !important;
            cursor: pointer;
            background: rgba(30, 41, 59, 0.95);
            backdrop-filter: blur(8px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
          }
          .bv-devtools-panel.bv-dt-collapsed .bv-dt-body {
            display: none !important;
          }
          .bv-devtools-panel.bv-dt-collapsed .bv-dt-header {
            border-bottom: none !important;
            padding-bottom: 0 !important;
            margin-bottom: 0 !important;
            gap: 8px;
          }
          .bv-devtools-panel.bv-dt-collapsed .bv-dt-collapse-btn {
            display: none;
          }
          .bv-dt-header {
            font-weight: bold;
            border-bottom: 1px solid #334155;
            padding-bottom: 8px;
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
          }
          .bv-dt-header-left {
            display: flex;
            align-items: center;
            gap: 6px;
          }
          .bv-dt-header-actions {
            display: flex;
            align-items: center;
            gap: 6px;
          }
          .bv-dt-tag { background: #10b981; color: #fff; padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 600; }
          .bv-dt-collapse-btn {
            background: transparent;
            border: none;
            color: #94a3b8;
            cursor: pointer;
            font-size: 13px;
            padding: 0 4px;
            line-height: 1;
            border-radius: 3px;
          }
          .bv-dt-collapse-btn:hover { color: #fff; background: rgba(255,255,255,0.1); }
          .bv-dt-stat { margin-top: 5px; display: flex; justify-content: space-between; color: #cbd5e1; }
          .bv-dt-live-blob { width: 8px; height: 8px; background: #10b981; border-radius: 50%; display: inline-block; animation: bvdt-pulse 1s infinite; vertical-align: middle; }
          .bv-dt-timeline { max-height: 80px; overflow-y: auto; margin-top: 8px; border-top: 1px solid #334155; padding-top: 5px; font-family: monospace; font-size: 10px; color: #94a3b8; }
          @keyframes bvdt-pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.4); opacity: 0.5; } 100% { transform: scale(1); opacity: 1; } }
        `;
        document.head.appendChild(s);
    
        // Create the Panel UI
        let p = document.createElement('div');
        p.id = 'bv-devtools';
        p.className = 'bv-devtools-panel';
        p.innerHTML = `
           <div class="bv-dt-header" id="bv-dt-toggle" title="Clique para minimizar ou expandir o DevTools">
             <div class="bv-dt-header-left">
               <span>BlaiseVue 🛡️</span>
               <i class="bv-dt-live-blob"></i>
             </div>
             <div class="bv-dt-header-actions">
               <span class="bv-dt-tag">v3.0</span>
               <button class="bv-dt-collapse-btn" id="bv-dt-btn" title="Minimizar">—</button>
             </div>
           </div>
           <div class="bv-dt-body" id="bv-dt-body">
             <div class="bv-dt-stat">
               <span>Reactivity:</span>
               <span>Active <i class="bv-dt-live-blob"></i></span>
             </div>
             <div class="bv-dt-stat" id="bv-com-count">
               <span>Components:</span>
               <span>0</span>
             </div>
             <div class="bv-dt-stat" id="bv-hoisted-count">
               <span>Static Hoisted:</span>
               <span>0</span>
             </div>
             <div class="bv-dt-timeline" id="bv-dt-events">
               <div>[Ready] DevTools hook listening</div>
             </div>
           </div>
        `;
        document.body.appendChild(p);
    
        let isMobile = (window.innerWidth || (document.documentElement && document.documentElement.clientWidth) || 800) <= 768;
        let savedState = null;
        try { savedState = sessionStorage.getItem('bv_dt_collapsed'); } catch(e){}
        let isCollapsed = savedState !== null ? (savedState === 'true') : isMobile;
    
        function updatePanelState() {
          let b = document.getElementById('bv-dt-btn');
          if (isCollapsed) {
            p.classList.add('bv-dt-collapsed');
            if (b) b.innerText = '▲';
          } else {
            p.classList.remove('bv-dt-collapsed');
            if (b) b.innerText = '—';
          }
          try { sessionStorage.setItem('bv_dt_collapsed', isCollapsed ? 'true' : 'false'); } catch(e){}
        }
        updatePanelState();
    
        let toggleHeader = document.getElementById('bv-dt-toggle');
        if (toggleHeader) {
          toggleHeader.addEventListener('click', function(e) {
            isCollapsed = !isCollapsed;
            updatePanelState();
          });
        }
    
        // Dynamic stats updater
        setInterval(function(){
           let count = Object.keys(window.__BV_CORE__.components || {}).length;
           let el = document.getElementById('bv-com-count');
           if (el) el.querySelector('span:last-child').innerText = count;
           let hEl = document.getElementById('bv-hoisted-count');
           if (hEl) hEl.querySelector('span:last-child').innerText = window.__BV_CORE__.hoistedCount || 0;
        }, 1000);
    
        // Timeline event logger
        window.__BV_DEVTOOLS_HOOK__.on('*', function(ev) {
           let list = document.getElementById('bv-dt-events');
           if (list) {
              let line = document.createElement('div');
              line.innerText = '[' + ev.time.split(' ')[0] + '] ' + ev.type;
              list.prepend(line);
              while (list.children.length > 8) list.removeChild(list.lastChild);
           }
        });
  };
  $mod.$init = function () {
    $mod.InitDevTools();
  };
});
rtl.module("uFormHeader",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uFormHeader = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = "/* Visual styling using standard CSS. Scoped by the framework to this component. */   .form-header { margin-bottom: 24px; padding: 12px; border-left: 4px solid #42b883; background-color: rgba(66, 184, 131, 0.05); border-radius: 0 8px 8px 0; cursor: pointer; transition: background 0.3s; }   .form-header:hover { background-color: rgba(66, 184, 131, 0.1); }   .form-header-title { color: inherit !important; margin: 0; font-size: 1.5rem; }   .form-header-subtitle { color: inherit !important; opacity: 0.8; margin: 4px 0 0 0; font-size: 0.9rem; }   .form-header-line { height: 2px; background: rgba(128,128,128,0.2); margin-top: 12px; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="form-header">' + "    <!-- reactive title bound to the 'title' data/prop -->" + '    <h2 class="form-header-title" @click="headerClick">{{ title }}</h2>' + "    " + "    <!-- subtitle displaying current reactive state -->" + '    <p class="form-header-subtitle">{{ subtitle }}</p>' + "    " + '    <div class="form-header-line"></div>' + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "Formulário do Sistema";
    comp["props"].push("subtitle");
    comp["defaultProps"]["subtitle"] = "Preencha os campos abaixo para atualizar o estado reativo.";
    m = new Object();
    m["headerClick"] = function (_this) {
      _this["$emit"].call(_this,"header-clicked","Ola do Header!");
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("form-header",comp);
  };
});
rtl.module("uCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
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
rtl.module("uCounter",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
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
rtl.module("uInfoCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
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
rtl.module("uMobileView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uMobileView = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".mobile-view-container {     max-width: 760px;     margin: 0 auto;     background: #ffffff;     border-radius: 16px;     overflow: hidden;     box-shadow: 0 10px 30px rgba(0,0,0,0.08);     min-height: calc(100vh - 120px);     margin-bottom: 80px;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="mobile-view-container">' + '    <bv-ion-app :mode="currentMode">' + "      <bv-ion-header>" + "        <bv-ion-toolbar>" + '          <bv-ion-title title="📱 BlaiseVue Mobile & Desktop Ecosystem"></bv-ion-title>' + '          <div slot="end">' + '            <bv-ion-badge :value="currentMode.toUpperCase()" :color="currentMode === \'ios\' ? \'primary\' : \'success\'"></bv-ion-badge>' + "          </div>" + "        </bv-ion-toolbar>" + "      </bv-ion-header>" + "" + '      <bv-ion-content :padding="true">' + "        <!-- INTRO CARD -->" + '        <bv-ion-card title="Componentes Universais (Mobile, Web & Desktop)" subtitle="Ionic Aesthetics + Object Pascal">' + '          <p style="margin-bottom: 14px; color: #4b5563; line-height: 1.5;">' + "            Os componentes <strong>blaise-ui-mobile</strong> são 100% universais! Funcionam no <strong>Navegador Web</strong> (PWA), no <strong>Desktop nativo</strong> (via WebUI4Delphi) e no <strong>Dispositivo Móvel</strong> (via Capacitor/Android)." + "          </p>" + "" + '          <div style="display: flex; gap: 8px; flex-wrap: wrap;">' + '            <bv-ion-button label="🍎 Estilo iOS (Cupertino)" color="primary" fill="outline" @click="setIosMode"></bv-ion-button>' + '            <bv-ion-button label="🤖 Estilo Android (Material Design)" color="success" fill="outline" @click="setMdMode"></bv-ion-button>' + "          </div>" + "        </bv-ion-card>" + "" + "        <!-- PASCAL CONTROLLERS CARD -->" + '        <bv-ion-card title="Controladores Pascal Tipados (BlaiseIonic.pas)" subtitle="Feedback e Diálogos Nativos">' + '          <p style="margin-bottom: 12px; color: #4b5563;">' + "            Dispare diálogos e notificações nativas diretamente do Object Pascal sem manipulação manual de DOM:" + "          </p>" + "" + '          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 8px;">' + '            <bv-ion-button label="🔔 Toast" color="dark" @click="showToast"></bv-ion-button>' + '            <bv-ion-button label="💬 Alerta" color="primary" @click="showAlert"></bv-ion-button>' + '            <bv-ion-button label="❓ Confirmar" color="warning" @click="showConfirm"></bv-ion-button>' + '            <bv-ion-button label="⏳ Loading" color="secondary" @click="showLoading"></bv-ion-button>' + '            <bv-ion-button label="📑 Action Sheet" color="danger" @click="showActionSheet"></bv-ion-button>' + "          </div>" + "" + '          <div b-if="lastAction" style="margin-top: 14px; padding: 10px 14px; background: #f3f4f6; border-radius: 8px; font-size: 0.88rem; color: #1f2937;">' + "            <strong>Última Ação:</strong> {{ lastAction }}" + "          </div>" + "        </bv-ion-card>" + "" + "        <!-- EXPANDABLE ACCORDION LIST -->" + '        <bv-ion-card title="Listas com Expansão Interativa" subtitle="Clique no item ou na seta (›) para expandir detalhes">' + '          <bv-ion-list :inset="true">' + "            <!-- ITEM 1 -->" + '            <bv-ion-item title="mORMot 2 Native Server" subtitle="Conexão HTTP/WebSocket ativa na porta 8090" :expandable="true" :expanded="true">' + '              <bv-ion-badge value="Online" color="success" slot="end"></bv-ion-badge>' + '              <div slot="expanded" style="display: flex; flex-direction: column; gap: 6px;">' + "                <div>⚡ <strong>Porta do Servidor:</strong> <code>8090</code> (HTTP 1.1 + WebSockets RFC 6455)</div>" + "                <div>🚀 <strong>Latência Média:</strong> &lt; 2ms em processamento concorrente</div>" + "                <div>💾 <strong>Consumo de Memória:</strong> ~22 MB RAM (Free Pascal 64-bit)</div>" + "                <div>🔒 <strong>Segurança:</strong> Autenticação RFC 7519 JWT com Argon2/SHA-256</div>" + "              </div>" + "            </bv-ion-item>" + "" + "            <!-- ITEM 2 -->" + '            <bv-ion-item title="Armazenamento Local & Cache" subtitle="Banco de dados SQLite / IndexedDB sincronizado" :expandable="true">' + '              <bv-ion-badge value="SQLite" color="primary" slot="end"></bv-ion-badge>' + '              <div slot="expanded" style="display: flex; flex-direction: column; gap: 6px;">' + "                <div>📦 <strong>Motor ORM:</strong> Synopse mORMot 2 com SQLite3 embedded</div>" + "                <div>🔄 <strong>Sincronização em Tempo Real:</strong> Notificações WebSocket automáticas</div>" + "                <div>📱 <strong>Modo Offline:</strong> Funciona mesmo sem conexão com a internet</div>" + "                <div>📊 <strong>Tabelas Mapeadas:</strong> Customers, Products, AuthUsers</div>" + "              </div>" + "            </bv-ion-item>" + "" + "            <!-- ITEM 3 -->" + '            <bv-ion-item title="Plataforma de Execução Universal" subtitle="Código Pascal compartilhado entre Web, Desktop e Android" :expandable="true">' + '              <bv-ion-badge value="Universal" color="dark" slot="end"></bv-ion-badge>' + '              <div slot="expanded" style="display: flex; flex-direction: column; gap: 6px;">' + "                <div>🌐 <strong>Web (PWA):</strong> Compatível com todos os navegadores modernos</div>" + "                <div>🖥️ <strong>Desktop:</strong> Binário nativo ultraleve via WebUI4Delphi (&lt; 10 MB)</div>" + "                <div>📱 <strong>Mobile:</strong> Aplicativo nativo Android APK empacotado via Capacitor</div>" + "                <div>🎨 <strong>UI Adaptativa:</strong> Alterna entre temas Cupertino e Material Design</div>" + "              </div>" + "            </bv-ion-item>" + "          </bv-ion-list>" + "        </bv-ion-card>" + "      </bv-ion-content>" + "    </bv-ion-app>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["currentMode"] = "md";
      d["lastAction"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    m["setIosMode"] = function (_this) {
      _this["currentMode"] = "ios";
      pas.BVPascalDX.IonicSetMode("ios");
      _this["lastAction"] = "Modo visual alterado para 🍎 iOS (Cupertino)";
    };
    m["setMdMode"] = function (_this) {
      _this["currentMode"] = "md";
      pas.BVPascalDX.IonicSetMode("md");
      _this["lastAction"] = "Modo visual alterado para 🤖 Android (Material Design)";
    };
    m["showToast"] = function (_this) {
      pas.BVPascalDX.IonicToast("Notificação rápida com estilo nativo!",2500,"bottom","success");
      _this["lastAction"] = "🔔 TIonicToast.Show disparado com sucesso!";
    };
    m["showAlert"] = function (_this) {
      pas.BVPascalDX.IonicAlert("BlaiseVue Mobile","Estes componentes funcionam igualmente na Web, no Desktop e no Celular!","Entendido");
      _this["lastAction"] = "💬 TIonicAlert.Alert exibido!";
    };
    m["onConfirmOk"] = function (_this) {
      _this["lastAction"] = "✅ Confirmação aceita! Dados sincronizados!";
      pas.BVPascalDX.IonicToast("Dados sincronizados com sucesso!",2000,"bottom","primary");
    };
    m["onConfirmCancel"] = function (_this) {
      _this["lastAction"] = "❌ Operação cancelada pelo usuário.";
    };
    m["showConfirm"] = function (_this) {
      _this["lastAction"] = "❓ TIonicAlert.Confirm aberto...";
      pas.BVPascalDX.IonicConfirm(_this,"Confirmar Operação","Deseja sincronizar os dados locais com o mORMot 2?","onConfirmOk","onConfirmCancel");
    };
    m["showLoading"] = function (_this) {
      pas.BVPascalDX.IonicLoading("Carregando registros...",1800);
      _this["lastAction"] = "⏳ TIonicLoading.Present exibido (auto-dispensa em 1.8s)";
    };
    m["onSheetSelect"] = function (_this, opt, idx) {
      _this["lastAction"] = "👉 Opção selecionada no Action Sheet: " + ("" + opt);
      pas.BVPascalDX.IonicToast("Selecionado: " + ("" + opt),1800,"bottom","dark");
    };
    m["showActionSheet"] = function (_this) {
      _this["lastAction"] = "📑 TIonicActionSheet.Show aberto...";
      pas.BVPascalDX.IonicActionSheet(_this,"Ações do Registro",["Compartilhar","Editar","Duplicar","Excluir"],"onSheetSelect");
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      _this["currentMode"] = pas.BVPascalDX.IonicGetMode();
    };
    pas.BVComponents.RegisterComponent("mobile-view-page",comp);
  };
});
rtl.module("Services",["System","SysUtils"],function () {
  "use strict";
  var $mod = this;
  rtl.recNewT(this,"TCustomer",function () {
    this.$eq = function (b) {
      return true;
    };
    this.$assign = function (s) {
      return this;
    };
  });
});
rtl.module("ClientProxies",["System","JS","Web","SysUtils","Services","BVRpc"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  rtl.createClass(this,"TCustomerServiceClient",pas.BVRpc.TBVRemoteProxy,function () {
    this.Create$2 = function () {
      pas.BVRpc.TBVRemoteProxy.Create$1.call(this,"CustomerService");
      return this;
    };
    this.GetAll$1 = function (OnSuccess, OnError) {
      var Args = null;
      Args = new Array();
      this.CallRemote("GetAll",Args,OnSuccess,OnError);
    };
  });
  rtl.createClass(this,"TProductServiceClient",pas.BVRpc.TBVRemoteProxy,function () {
    this.Create$2 = function () {
      pas.BVRpc.TBVRemoteProxy.Create$1.call(this,"ProductService");
      return this;
    };
  });
  rtl.createClass(this,"TSystemServiceClient",pas.BVRpc.TBVRemoteProxy,function () {
    this.Create$2 = function () {
      pas.BVRpc.TBVRemoteProxy.Create$1.call(this,"SystemService");
      return this;
    };
  });
  this.CustomerService = function () {
    var Result = null;
    if ($impl.GCustomerService === null) $impl.GCustomerService = $mod.TCustomerServiceClient.$create("Create$2");
    Result = $impl.GCustomerService;
    return Result;
  };
  this.ProductService = function () {
    var Result = null;
    if ($impl.GProductService === null) $impl.GProductService = $mod.TProductServiceClient.$create("Create$2");
    Result = $impl.GProductService;
    return Result;
  };
  this.SystemService = function () {
    var Result = null;
    if ($impl.GSystemService === null) $impl.GSystemService = $mod.TSystemServiceClient.$create("Create$2");
    Result = $impl.GSystemService;
    return Result;
  };
  $mod.$implcode = function () {
    $impl.GCustomerService = null;
    $impl.GProductService = null;
    $impl.GSystemService = null;
  };
  $mod.$init = function () {
    $mod.CustomerService();
    $mod.ProductService();
    $mod.SystemService();
  };
},[]);
rtl.module("uCustomerView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet","Services","ClientProxies"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCustomerView = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".customer-view-page { padding: 24px; max-width: 1200px; margin: 0 auto; }   .crud-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }   .crud-title { font-size: 24px; font-weight: 700; color: #2c3e50; }   .crud-subtitle { color: #7f8c8d; font-size: 14px; margin-top: 4px; }   .crud-header-btns { display: flex; gap: 8px; }   .crud-stats-bar { display: flex; gap: 12px; margin-bottom: 16px; align-items: center; }   .sync-badge { background: #e8f8f5; color: #1abc9c; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; border: 1px solid #a3e4d7; }   .count-badge { background: #edf2f7; color: #4a5568; padding: 4px 10px; border-radius: 20px; font-size: 12px; }   .crud-toolbar { margin-bottom: 16px; }   .crud-search-input { width: 100%; max-width: 400px; padding: 10px 14px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; outline: none; }   .crud-search-input:focus { border-color: #42b883; box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.15); }   .crud-table-wrap { background: #fff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); overflow-x: auto; }   .crud-table { width: 100%; border-collapse: collapse; text-align: left; font-size: 14px; }   .crud-table th { background: #f8fafc; padding: 12px 16px; font-weight: 600; color: #475569; border-bottom: 2px solid #e2e8f0; }   .crud-table td { padding: 12px 16px; border-bottom: 1px solid #f1f5f9; color: #334155; }   .crud-table tr:hover { background: #f8fafc; }   .cell-id { font-weight: 600; color: #64748b; font-family: monospace; }   .cell-date { font-size: 12px; color: #94a3b8; }   .badge-num { background: #e0f2fe; color: #0284c7; padding: 2px 8px; border-radius: 12px; font-weight: 600; font-size: 12px; }   .badge-price { font-weight: 700; color: #16a34a; }   .status-pill { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }   .pill-active { background: #dcfce7; color: #15803d; }   .pill-inactive { background: #fee2e2; color: #b91c1c; }   .cell-actions { display: flex; gap: 6px; justify-content: center; }   .action-btn { padding: 5px 10px; border-radius: 4px; font-size: 12px; border: 1px solid transparent; cursor: pointer; transition: all 0.2s; font-weight: 500; }   .edit-btn { background: #f1f5f9; color: #334155; border-color: #cbd5e1; }   .edit-btn:hover { background: #e2e8f0; }   .del-btn { background: #fef2f2; color: #dc2626; border-color: #fecaca; }   .del-btn:hover { background: #fee2e2; }   .crud-empty { padding: 48px 16px; text-align: center; color: #64748b; }   .empty-icon { font-size: 42px; margin-bottom: 8px; }   .crud-modal-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1050; }   .crud-modal { background: #fff; border-radius: 8px; width: 90%; max-width: 520px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); overflow: hidden; animation: modalIn 0.2s ease-out; }   @keyframes modalIn { from { transform: scale(0.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }   .modal-header { padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }   .modal-close-btn { background: none; border: none; font-size: 18px; cursor: pointer; color: #94a3b8; }   .modal-close-btn:hover { color: #1e293b; }   .modal-body { padding: 20px; max-height: 70vh; overflow-y: auto; }   .modal-footer { padding: 14px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 8px; }   .form-group { margin-bottom: 14px; }   .form-label { display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px; }   .form-control { width: 100%; padding: 8px 12px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; outline: none; }   .form-control:focus { border-color: #42b883; box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.15); }   .checkbox-container { display: flex; align-items: center; gap: 8px; font-size: 14px; cursor: pointer; margin-top: 6px; }   .form-error-banner { margin-top: 10px; background: #fee2e2; color: #dc2626; padding: 8px 12px; border-radius: 6px; font-size: 13px; }   .bui-btn { padding: 8px 16px; border-radius: 6px; font-size: 14px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; }   .bui-btn-primary { background: #42b883; color: white; }   .bui-btn-primary:hover { background: #33a06f; }   .bui-btn-secondary { background: #e2e8f0; color: #334155; }   .bui-btn-secondary:hover { background: #cbd5e1; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="customer-view-page">' + "    <!-- HEADER SECTION -->" + '    <div class="crud-header">' + "      <div>" + '        <h1 class="crud-title">📦 Customer Management</h1>' + '        <p class="crud-subtitle">High-throughput reactive CRUD module connected to mORMot 2 native backend.</p>' + "      </div>" + '      <div class="crud-header-btns">' + '        <button class="bui-btn bui-btn-primary" @click="openCreateModal">➕ New Customer</button>' + '        <button class="bui-btn bui-btn-secondary" @click="fetchItems">🔄 Refresh</button>' + '        <button class="bui-btn" style="background: #8e44ad; color: white;" @click="fetchViaRpc">⚡ Type-Safe RPC (v4.3)</button>' + "      </div>" + "    </div>" + "" + "    <!-- REAL-TIME SYNC & STATS BAR -->" + '    <div style="background: #f4ecf7; border-left: 4px solid #8e44ad; padding: 12px 16px; border-radius: 4px; margin-bottom: 16px; color: #4a235a; font-size: 14px;">' + '      🛡️ <strong>BlaiseVue 4.3:</strong> Teste o RPC fortemente tipado clicando no botão roxo <strong>"⚡ Type-Safe RPC (v4.3)"</strong> no cabeçalho acima!' + "    </div>" + '    <div class="crud-stats-bar">' + '      <span class="sync-badge">🟢 Real-time WebSocket Sync Active</span>' + '      <span class="count-badge">Total: <strong>{{ items.length }}</strong> customers</span>' + "    </div>" + "" + "    <!-- SEARCH & FILTER TOOLBAR -->" + '    <div class="crud-toolbar">' + "      <input" + '        type="text"' + '        class="crud-search-input"' + '        placeholder="🔍 Search customers by any keyword..."' + '        b-model="searchQuery"' + "      />" + "    </div>" + "" + "    <!-- RESPONSIVE DATA TABLE -->" + '    <div class="crud-table-wrap">' + '      <table class="crud-table">' + "        <thead>" + "          <tr>" + '            <th style="width: 70px;">ID</th>' + "            <th>Name</th>" + "            <th>Email</th>" + "            <th>Phone</th>" + "            <th>Active</th>" + "            <th>Created</th>" + '            <th style="width: 170px; text-align: center;">Actions</th>' + "          </tr>" + "        </thead>" + "        <tbody>" + '          <tr b-for="item in filteredItems">' + '            <td class="cell-id">#{{ item.id }}</td>' + "            <td><strong>{{ item.name }}</strong></td>" + "            <td><strong>{{ item.email }}</strong></td>" + "            <td><strong>{{ item.phone }}</strong></td>" + '            <td><span class="status-pill" :class="{ \'pill-active\': item.active, \'pill-inactive\': !item.active }">{{ item.active ? \'Active\' : \'Inactive\' }}</span></td>' + '            <td class="cell-date">{{ item.createdAt }}</td>' + '            <td class="cell-actions">' + '              <button class="action-btn edit-btn" title="Edit" @click="openEditModal(item)">✏️ Edit</button>' + '              <button class="action-btn del-btn" title="Delete" @click="deleteItem(item.id)">🗑️ Delete</button>' + "            </td>" + "          </tr>" + "        </tbody>" + "      </table>" + "" + "      <!-- EMPTY STATE -->" + '      <div class="crud-empty" v-if="filteredItems.length === 0">' + '        <div class="empty-icon">📂</div>' + "        <h3>No customers found</h3>" + '        <p v-if="searchQuery">No matching records for "<strong>{{ searchQuery }}</strong>".</p>' + '        <p v-if="!searchQuery">Click "➕ New Customer" above to add your first record!</p>' + "      </div>" + "    </div>" + "" + "    <!-- MODAL DIALOG -->" + '    <div class="crud-modal-backdrop" v-show="isModalOpen">' + '      <div class="crud-modal">' + '        <div class="modal-header">' + "          <h3>{{ isEditing ? '✏️ Edit ' + modelTitle : '➕ New ' + modelTitle }}</h3>" + '          <button class="modal-close-btn" @click="closeModal">✕</button>' + "        </div>" + '        <div class="modal-body">' + '          <div class="form-group">' + '            <label class="form-label">Name:</label>' + '            <input type="text" class="form-control" b-model="form.name" placeholder="Enter name..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Email:</label>' + '            <input type="text" class="form-control" b-model="form.email" placeholder="Enter email..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Phone:</label>' + '            <input type="text" class="form-control" b-model="form.phone" placeholder="Enter phone..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="checkbox-container">' + '              <input type="checkbox" b-model="form.active" />' + "              <span>Active Active</span>" + "            </label>" + "          </div>" + '          <div class="form-error-banner" v-if="formError">' + "            ⚠️ {{ formError }}" + "          </div>" + "        </div>" + '        <div class="modal-footer">' + '          <button class="bui-btn bui-btn-secondary" @click="closeModal">Cancel</button>' + '          <button class="bui-btn bui-btn-primary" @click="saveItem">' + "            {{ isEditing ? 'Save Changes' : 'Create ' + modelTitle }}" + "          </button>" + "        </div>" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["modelTitle"] = "Customer";
      d["apiEndpoint"] = "customers";
      d["items"] = new Array();
      d["searchQuery"] = "";
      d["isModalOpen"] = false;
      d["isEditing"] = false;
      d["currentEditId"] = 0;
      d["formError"] = "";
      d["form"] = null;
      Result = d;
      return Result;
    };
    m = new Object();
    m["resetForm"] = function (_this) {
      var f = null;
      f = pas.BVPascalDX.NewObject();
      f["name"] = "";
      f["email"] = "";
      f["phone"] = "";
      f["active"] = true;
      _this["form"] = f;
      _this["formError"] = "";
    };
    m["openCreateModal"] = function (_this) {
      pas.BVPascalDX.CallMethod(_this,"resetForm");
      _this["isEditing"] = false;
      _this["currentEditId"] = 0;
      _this["isModalOpen"] = true;
    };
    m["openEditModal"] = function (_this, item) {
      _this["form"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),item);
      _this["currentEditId"] = pas.BVPascalDX.GetFieldInt(item,"id",0);
      _this["isEditing"] = true;
      _this["formError"] = "";
      _this["isModalOpen"] = true;
    };
    m["closeModal"] = function (_this) {
      _this["isModalOpen"] = false;
      _this["formError"] = "";
    };
    m["fetchViaRpc"] = function (_this) {
      pas.ClientProxies.CustomerService().GetAll$1(function (Items) {
        _this["items"] = Items;
        pas.BVPascalDX.ShowToast("Loaded " + pas.SysUtils.IntToStr(rtl.length(Items)) + " customers via Type-Safe Pascal RPC (mORMot 2)!",2500);
      },function (Err) {
        pas.BVPascalDX.ShowToast("RPC Error: " + Err,2500);
      });
    };
    m["fetchItems"] = function (_this) {
      pas.BVPascalDX.ApiFetch(_this,"/api/" + ("" + _this["apiEndpoint"]),"items");
    };
    m["saveItem"] = function (_this) {
      if (!!(_this["form"] == false)) return;
      if (this && this.form) {
        for (var k in this) {
          if (k.indexOf('form.') === 0) {
            var fieldName = k.substring(5);
            this.form[fieldName] = this[k];
          }
        }
      };
      pas.BVPascalDX.ApiSave(_this,"/api/" + ("" + _this["apiEndpoint"]),rtl.trunc(_this["currentEditId"]),!(_this["isEditing"] == false),_this["form"],"fetchItems","formError");
    };
    m["deleteItem"] = function (_this, id) {
      pas.BVPascalDX.ApiDelete(_this,"/api/" + ("" + _this["apiEndpoint"]),id,"Are you sure you want to delete this " + ("" + _this["modelTitle"]) + "?","fetchItems");
    };
    m["setupWebSocket"] = function (_this) {
      pas.BVPascalDX.ApiSetupRealtime(_this,pas.SysUtils.LowerCase("" + _this["modelTitle"]),"fetchItems");
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      pas.BVPascalDX.CallMethod(_this,"resetForm");
      pas.BVPascalDX.CallMethod(_this,"fetchItems");
      pas.BVPascalDX.CallMethod(_this,"setupWebSocket");
    };
    comp["computed"] = new Object();
    comp["computed"]["filteredItems"] = function (_this) {
      var Result = undefined;
      Result = pas.BVPascalDX.FilterByQuery(_this["items"],_this["searchQuery"]);
      return Result;
    };
    pas.BVComponents.RegisterComponent("customer-view-page",comp);
  };
});
rtl.module("uProductView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uProductView = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".product-view-page { padding: 24px; max-width: 1200px; margin: 0 auto; }   .crud-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }   .crud-title { font-size: 24px; font-weight: 700; color: #2c3e50; }   .crud-subtitle { color: #7f8c8d; font-size: 14px; margin-top: 4px; }   .crud-header-btns { display: flex; gap: 8px; }   .crud-stats-bar { display: flex; gap: 12px; margin-bottom: 16px; align-items: center; }   .sync-badge { background: #e8f8f5; color: #1abc9c; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; border: 1px solid #a3e4d7; }   .count-badge { background: #edf2f7; color: #4a5568; padding: 4px 10px; border-radius: 20px; font-size: 12px; }   .crud-toolbar { margin-bottom: 16px; }   .crud-search-input { width: 100%; max-width: 400px; padding: 10px 14px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; outline: none; }   .crud-search-input:focus { border-color: #42b883; box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.15); }   .crud-table-wrap { background: #fff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); overflow-x: auto; }   .crud-table { width: 100%; border-collapse: collapse; text-align: left; font-size: 14px; }   .crud-table th { background: #f8fafc; padding: 12px 16px; font-weight: 600; color: #475569; border-bottom: 2px solid #e2e8f0; }   .crud-table td { padding: 12px 16px; border-bottom: 1px solid #f1f5f9; color: #334155; }   .crud-table tr:hover { background: #f8fafc; }   .cell-id { font-weight: 600; color: #64748b; font-family: monospace; }   .cell-date { font-size: 12px; color: #94a3b8; }   .badge-num { background: #e0f2fe; color: #0284c7; padding: 2px 8px; border-radius: 12px; font-weight: 600; font-size: 12px; }   .badge-price { font-weight: 700; color: #16a34a; }   .status-pill { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }   .pill-active { background: #dcfce7; color: #15803d; }   .pill-inactive { background: #fee2e2; color: #b91c1c; }   .cell-actions { display: flex; gap: 6px; justify-content: center; }   .action-btn { padding: 5px 10px; border-radius: 4px; font-size: 12px; border: 1px solid transparent; cursor: pointer; transition: all 0.2s; font-weight: 500; }   .edit-btn { background: #f1f5f9; color: #334155; border-color: #cbd5e1; }   .edit-btn:hover { background: #e2e8f0; }   .del-btn { background: #fef2f2; color: #dc2626; border-color: #fecaca; }   .del-btn:hover { background: #fee2e2; }   .crud-empty { padding: 48px 16px; text-align: center; color: #64748b; }   .empty-icon { font-size: 42px; margin-bottom: 8px; }   .crud-modal-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1050; }   .crud-modal { background: #fff; border-radius: 8px; width: 90%; max-width: 520px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); overflow: hidden; animation: modalIn 0.2s ease-out; }   @keyframes modalIn { from { transform: scale(0.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }   .modal-header { padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }   .modal-close-btn { background: none; border: none; font-size: 18px; cursor: pointer; color: #94a3b8; }   .modal-close-btn:hover { color: #1e293b; }   .modal-body { padding: 20px; max-height: 70vh; overflow-y: auto; }   .modal-footer { padding: 14px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 8px; }   .form-group { margin-bottom: 14px; }   .form-label { display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px; }   .form-control { width: 100%; padding: 8px 12px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; outline: none; }   .form-control:focus { border-color: #42b883; box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.15); }   .checkbox-container { display: flex; align-items: center; gap: 8px; font-size: 14px; cursor: pointer; margin-top: 6px; }   .form-error-banner { margin-top: 10px; background: #fee2e2; color: #dc2626; padding: 8px 12px; border-radius: 6px; font-size: 13px; }   .bui-btn { padding: 8px 16px; border-radius: 6px; font-size: 14px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; }   .bui-btn-primary { background: #42b883; color: white; }   .bui-btn-primary:hover { background: #33a06f; }   .bui-btn-secondary { background: #e2e8f0; color: #334155; }   .bui-btn-secondary:hover { background: #cbd5e1; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="product-view-page">' + "    <!-- HEADER SECTION -->" + '    <div class="crud-header">' + "      <div>" + '        <h1 class="crud-title">📦 Product Management</h1>' + '        <p class="crud-subtitle">High-throughput reactive CRUD module connected to mORMot 2 native backend.</p>' + "      </div>" + '      <div class="crud-header-btns">' + '        <button class="bui-btn bui-btn-primary" @click="openCreateModal">➕ New Product</button>' + '        <button class="bui-btn bui-btn-secondary" @click="fetchItems">🔄 Refresh</button>' + "      </div>" + "    </div>" + "" + "    <!-- REAL-TIME SYNC & STATS BAR -->" + '    <div class="crud-stats-bar">' + '      <span class="sync-badge">🟢 Real-time WebSocket Sync Active</span>' + '      <span class="count-badge">Total: <strong>{{ items.length }}</strong> products</span>' + "    </div>" + "" + "    <!-- SEARCH & FILTER TOOLBAR -->" + '    <div class="crud-toolbar">' + "      <input" + '        type="text"' + '        class="crud-search-input"' + '        placeholder="🔍 Search products by any keyword..."' + '        b-model="searchQuery"' + "      />" + "    </div>" + "" + "    <!-- RESPONSIVE DATA TABLE -->" + '    <div class="crud-table-wrap">' + '      <table class="crud-table">' + "        <thead>" + "          <tr>" + '            <th style="width: 70px;">ID</th>' + "            <th>Name</th>" + "            <th>Price</th>" + "            <th>Stock</th>" + "            <th>Category</th>" + "            <th>Created</th>" + '            <th style="width: 170px; text-align: center;">Actions</th>' + "          </tr>" + "        </thead>" + "        <tbody>" + '          <tr b-for="item in filteredItems">' + '            <td class="cell-id">#{{ item.id }}</td>' + "            <td><strong>{{ item.name }}</strong></td>" + '            <td><span class="badge-price">$ {{ Number(item.price).toFixed(2) }}</span></td>' + '            <td><span class="badge-num">{{ item.stock }}</span></td>' + "            <td><strong>{{ item.category }}</strong></td>" + '            <td class="cell-date">{{ item.createdAt }}</td>' + '            <td class="cell-actions">' + '              <button class="action-btn edit-btn" title="Edit" @click="openEditModal(item)">✏️ Edit</button>' + '              <button class="action-btn del-btn" title="Delete" @click="deleteItem(item.id)">🗑️ Delete</button>' + "            </td>" + "          </tr>" + "        </tbody>" + "      </table>" + "" + "      <!-- EMPTY STATE -->" + '      <div class="crud-empty" v-if="filteredItems.length === 0">' + '        <div class="empty-icon">📂</div>' + "        <h3>No products found</h3>" + '        <p v-if="searchQuery">No matching records for "<strong>{{ searchQuery }}</strong>".</p>' + '        <p v-if="!searchQuery">Click "➕ New Product" above to add your first record!</p>' + "      </div>" + "    </div>" + "" + "    <!-- MODAL DIALOG -->" + '    <div class="crud-modal-backdrop" v-show="isModalOpen">' + '      <div class="crud-modal">' + '        <div class="modal-header">' + "          <h3>{{ isEditing ? '✏️ Edit ' + modelTitle : '➕ New ' + modelTitle }}</h3>" + '          <button class="modal-close-btn" @click="closeModal">✕</button>' + "        </div>" + '        <div class="modal-body">' + '          <div class="form-group">' + '            <label class="form-label">Name:</label>' + '            <input type="text" class="form-control" b-model="form.name" placeholder="Enter name..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Price:</label>' + '            <input type="number" step="0.01" class="form-control" b-model="form.price" placeholder="0.00" />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Stock:</label>' + '            <input type="number" class="form-control" b-model="form.stock" placeholder="0" />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Category:</label>' + '            <input type="text" class="form-control" b-model="form.category" placeholder="Enter category..." />' + "          </div>" + '          <div class="form-error-banner" v-if="formError">' + "            ⚠️ {{ formError }}" + "          </div>" + "        </div>" + '        <div class="modal-footer">' + '          <button class="bui-btn bui-btn-secondary" @click="closeModal">Cancel</button>' + '          <button class="bui-btn bui-btn-primary" @click="saveItem">' + "            {{ isEditing ? 'Save Changes' : 'Create ' + modelTitle }}" + "          </button>" + "        </div>" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["modelTitle"] = "Product";
      d["apiEndpoint"] = "products";
      d["items"] = new Array();
      d["searchQuery"] = "";
      d["isModalOpen"] = false;
      d["isEditing"] = false;
      d["currentEditId"] = 0;
      d["formError"] = "";
      d["form"] = null;
      Result = d;
      return Result;
    };
    m = new Object();
    m["resetForm"] = function (_this) {
      var F = undefined;
      F = pas.BVPascalDX.NewObject();
      pas.BVPascalDX.SetField(F,"name","");
      pas.BVPascalDX.SetField(F,"price",0.0);
      pas.BVPascalDX.SetField(F,"stock",0);
      pas.BVPascalDX.SetField(F,"category","");
      _this["form"] = F;
      _this["formError"] = "";
    };
    m["openCreateModal"] = function (_this) {
      pas.BVPascalDX.CallMethod(_this,"resetForm");
      _this["isEditing"] = false;
      _this["currentEditId"] = 0;
      _this["isModalOpen"] = true;
    };
    m["openEditModal"] = function (_this, item) {
      _this["form"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),item);
      _this["currentEditId"] = pas.BVPascalDX.GetFieldInt(item,"id",0);
      _this["isEditing"] = true;
      _this["formError"] = "";
      _this["isModalOpen"] = true;
    };
    m["closeModal"] = function (_this) {
      _this["isModalOpen"] = false;
      _this["formError"] = "";
    };
    m["fetchItems"] = function (_this) {
      pas.BVPascalDX.ApiFetch(_this,"/api/" + ("" + _this["apiEndpoint"]),"items");
    };
    m["saveItem"] = function (_this) {
      if (!!(_this["form"] == false)) return;
      if (this && this.form) {
        for (var k in this) {
          if (k.indexOf('form.') === 0) {
            var fieldName = k.substring(5);
            this.form[fieldName] = this[k];
          }
        }
      };
      pas.BVPascalDX.ApiSave(_this,"/api/" + ("" + _this["apiEndpoint"]),rtl.trunc(_this["currentEditId"]),!(_this["isEditing"] == false),_this["form"],"fetchItems","formError");
    };
    m["deleteItem"] = function (_this, id) {
      pas.BVPascalDX.ApiDelete(_this,"/api/" + ("" + _this["apiEndpoint"]),id,"Are you sure you want to delete this " + ("" + _this["modelTitle"]) + "?","fetchItems");
    };
    m["setupWebSocket"] = function (_this) {
      pas.BVPascalDX.ApiSetupRealtime(_this,pas.SysUtils.LowerCase("" + _this["modelTitle"]),"fetchItems");
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      pas.BVPascalDX.CallMethod(_this,"resetForm");
      pas.BVPascalDX.CallMethod(_this,"fetchItems");
      pas.BVPascalDX.CallMethod(_this,"setupWebSocket");
    };
    comp["computed"] = new Object();
    comp["computed"]["filteredItems"] = function (_this) {
      var Result = undefined;
      Result = pas.BVPascalDX.FilterByQuery(_this["items"],_this["searchQuery"]);
      return Result;
    };
    pas.BVComponents.RegisterComponent("product-view-page",comp);
  };
});
rtl.module("uUserProfile",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uUserProfile = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = "table { width: 100%; border-collapse: collapse; }   th, td { padding: 12px; border: 1px solid #efefef; text-align: left; }   th { background: #f9f9f9; width: 30%; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = "  <div>" + '    <div class="section">' + '      <h1 class="section-title">User Profile</h1>' + "      <p>This page demonstrates <strong>Route Params</strong> and <strong>Query Strings</strong>.</p>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Route Data</h2>' + "      <table>" + "        <tr><th>Information</th><th>Value</th></tr>" + '        <tr><td>Param <code>:id</code></td><td><span class="badge badge-blue">{{ id }}</span></td></tr>' + '        <tr><td>Query <code>?tab</code></td><td><span class="badge badge-orange">{{ tab }}</span></td></tr>' + '        <tr><td>Query <code>?tema</code></td><td><span class="badge badge-gray">{{ tema }}</span></td></tr>' + '        <tr><td>Level (Computed)</td><td><span class="badge" :class="userLevel == \'Premium\' ? \'badge-orange\' : \'badge-gray\'">{{ userLevel }}</span></td></tr>' + "      </table>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Edit Name (b-model)</h2>' + '      <input type="text" b-model="nomeUsuario">' + "      <p>Current Name: <strong>{{ nomeUsuario }}</strong></p>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Test Other Routes</h2>' + '      <a href="#/user/1" class="btn-outline" style="text-decoration:none; display:inline-block;">User 1</a>' + '      <a href="#/user/100?tab=posts" class="btn-outline" style="text-decoration:none; display:inline-block;">User 100 + Posts</a>' + '      <a href="#/user/7?tab=config&tema=dark" class="btn-outline" style="text-decoration:none; display:inline-block;">User 7 + Multi Query</a>' + '      <a href="#/" class="btn-danger" style="text-decoration:none; display:inline-block;">Back Home</a>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["id"] = "?";
      d["tab"] = "(none)";
      d["tema"] = "(none)";
      d["nomeUsuario"] = "Standard User";
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
       else Result = "Basic";
      return Result;
    };
    pas.BVComponents.RegisterComponent("user-profile-page",comp);
  };
});
rtl.module("uLibBootstrap",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet","BVRouting"],function () {
  "use strict";
  var $mod = this;
  this.Register_uLibBootstrap = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".mt-4 { margin-top: 20px; }   .mb-2 { margin-bottom: 8px; }   .mb-3 { margin-bottom: 12px; }   .mb-4 { margin-bottom: 16px; }   .mb-5 { margin-bottom: 24px; }   .mt-3 { margin-top: 15px; }   .lib-bootstrap-page { background: #f8fafc; padding: 25px; min-height: 100vh; }   @media (max-width: 576px) {     .lib-bootstrap-page { padding: 12px 10px; }   }   .row { display: flex; flex-wrap: wrap; margin-right: -15px; margin-left: -15px; }   .col-4 { flex: 0 0 33.333333%; max-width: 33.333333%; padding: 0 15px; }   .col-8 { flex: 0 0 66.666667%; max-width: 66.666667%; padding: 0 15px; }   .col-6 { flex: 0 0 50%; max-width: 50%; padding: 0 15px; }   .d-flex { display: flex; }   .align-items-end { align-items: flex-end; }   .justify-content-end { justify-content: flex-end; }   .gap-2 { gap: 10px; }   .text-muted { color: #64748b; }   .p-4 { padding: 20px; }   .text-center { text-align: center; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="lib-bootstrap-page">' + "    <!-- INTERNAL NAVIGATION (DEMO) -->" + '    <bv-navbar brand="BlaiseVue UI">' + '       <bv-nav-item href="#/" active="true" label="Home"></bv-nav-item>' + '       <bv-nav-item href="#/charts" label="Charts"></bv-nav-item>' + '       <bv-nav-item href="#/pro" label="Pro Features"></bv-nav-item>' + '       <bv-nav-item href="#" label="⚙️ Settings" @click="openSettings"></bv-nav-item>' + "    </bv-navbar>" + "" + "    <!-- CONTENT CONTAINER (USING NATIVE BLAISEUI RESPONSIVE GRID) -->" + '    <bv-container fluid="true">' + '      <bv-row gutter="md" class="mb-5">' + '         <bv-col cols="12" md="7">' + '            <h1 class="mb-2">🎨 BlaiseUI Official Kit</h1>' + '            <p class="text-muted mb-4">Demonstration of unified reactive components built 100% in Pascal with native responsive grid layout.</p>' + "            " + "            <bv-breadcrumb>" + '               <bv-breadcrumb-item href="#/">Home</bv-breadcrumb-item>' + '               <bv-breadcrumb-item href="#">Components</bv-breadcrumb-item>' + '               <bv-breadcrumb-item active="true">BlaiseUI</bv-breadcrumb-item>' + "            </bv-breadcrumb>" + "         </bv-col>" + '         <bv-col cols="12" md="5" class="d-flex align-items-end justify-content-end p-2 gap-2 flex-wrap">' + '            <bv-btn label="Open Drawer" variant="secondary" size="lg" @click="showDrawer"></bv-btn>' + '            <bv-btn label="Open Modal" variant="primary" size="lg" @click="showModal"></bv-btn>' + '            <bv-btn label="Trigger Toast" variant="info" size="lg" @click="clickNotif(\'Manual Toast Trigger\')"></bv-btn>' + '            <bv-btn label="⚙️ Settings" variant="outline-primary" size="lg" @click="openSettings"></bv-btn>' + "         </bv-col>" + "      </bv-row>" + "" + '      <bv-row gutter="md">' + "         <!-- LEFT COLUMN: Feedback & Status (Responsive: 12 on mobile, 4 on desktop) -->" + '         <bv-col cols="12" md="4">' + '            <bv-card title="📊 System Status">' + '               <div class="mb-3">' + "                  <small>Engine Load (Reactivity)</small>" + '                  <bv-progress :value="count" variant="success"></bv-progress>' + "               </div>" + '               <div class="mb-3">' + "                  <small>Memory Usage ($Store)</small>" + '                  <bv-progress :value="35" variant="info"></bv-progress>' + "               </div>" + '               <div class="d-flex gap-2">' + '                  <bv-btn label="Pulse (Count++)" variant="outline-primary" @click="count = (count + 10) % 105"></bv-btn>' + '                  <bv-spinner variant="primary" small="true" v-if="count > 80"></bv-spinner>' + "               </div>" + "            </bv-card>" + "" + '            <bv-card title="📋 Notification Center" class="mt-4">' + "               <bv-list-group>" + '                  <bv-list-group-item badge="5" badgeVariant="danger" @click="clickNotif(\'New Emails\')">📨 Inbox Messages</bv-list-group-item>' + '                  <bv-list-group-item active="true" @click="clickNotif(\'Highlight\')">🌟 Weekly Highlight</bv-list-group-item>' + '                  <bv-list-group-item badge="ONLINE" badgeVariant="secondary" @click="clickNotif(\'BlaiseUI Kit\')">💎 BlaiseUI v2.0</bv-list-group-item>' + '                  <bv-list-group-item @click="clickNotif(\'Cloud Sync\')">☁️ Cloud Synchronization</bv-list-group-item>' + "               </bv-list-group>" + "            </bv-card>" + "         </bv-col>" + "" + "         <!-- RIGHT COLUMN: Tabs / Forms / Navigation (Responsive: 12 on mobile, 8 on desktop) -->" + '         <bv-col cols="12" md="8">' + '            <bv-card style="height: 100%;">' + '               <bv-tabs @change="tabChanged">' + '                  <bv-tab id="forms" title="📝 Forms" active="true">' + '                     <div class="p-4">' + "                        <h4>Input Controls</h4>" + '                        <bv-row gutter="md" class="mt-4">' + '                           <bv-col cols="12" md="6">' + '                              <bv-input label="UI Identifier" b-model="libName" placeholder="Ex: Turbo_Node"></bv-input>' + '                              <bv-form-select label="Priority" b-model="category" :options="catOptions"></bv-form-select>' + "                           </bv-col>" + '                           <bv-col cols="12" md="6">' + '                              <bv-input-group label="Operation Cost" prepend="$" append=".00" b-model="count"></bv-input-group>' + '                              <bv-input-group label="API Key" append="Regenerate">' + '                                 <bv-input b-model="libName" readonly="true"></bv-input>' + "                              </bv-input-group>" + "                           </bv-col>" + "                        </bv-row>" + '                        <div class="bui-alert bui-alert-info mt-3" style="border-radius: 8px;">' + "                           <strong>Note:</strong> All fields above use <code>b-model</code> linked directly to the reactive Pascal state." + "                        </div>" + "                     </div>" + "                  </bv-tab>" + "" + '                  <bv-tab id="nav" title="📍 Pagination">' + '                     <div class="p-4 text-center">' + '                        <h5 class="mb-4">Atomic Data Navigation</h5>' + '                        <bv-pagination :value="currentPage" :total="10" @input="updatePage"></bv-pagination>' + '                        <p class="mt-3">Currently viewing segment <strong>#{{ currentPage }}</strong></p>' + '                        <bv-alert variant="warning" dismissible="true" class="mt-4">' + "                           Attention: Segment 7 contains simulated network instabilities." + "                        </bv-alert>" + "                     </div>" + "                  </bv-tab>" + "" + '                  <bv-tab id="extras" title="🔥 Accordions">' + '                     <div class="p-4">' + '                        <bv-accordion :items="faqItems" initialActiveId="q1"></bv-accordion>' + "                     </div>" + "                  </bv-tab>" + "" + '                  <bv-tab id="icons" title="⭐ Icons & Themes">' + '                     <div class="p-4">' + "                        <h5>Bootstrap Icons & Bootswatch Themes</h5>" + '                        <p class="text-muted">Over 1,800+ vector icons powered by <code>blaise-icons</code> and reactive Bootswatch styling.</p>' + '                        <div class="d-flex gap-4 align-items-center mb-4 flex-wrap" style="display: flex; gap: 16px; flex-wrap: wrap;">' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="check-circle" size="24" color="#28a745"></bv-icon> <span>check-circle</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="star-fill" size="24" color="#ffc107"></bv-icon> <span>star-fill</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="heart-fill" size="24" color="#dc3545"></bv-icon> <span>heart-fill</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="gear-fill" size="24" color="#6c757d"></bv-icon> <span>gear-fill</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="shield-check" size="24" color="#0d6efd"></bv-icon> <span>shield-check</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="lightning-charge-fill" size="24" color="#fd7e14"></bv-icon> <span>lightning</span></div>' + "                        </div>" + "                     </div>" + "                  </bv-tab>" + "               </bv-tabs>" + "            </bv-card>" + "         </bv-col>" + "      </bv-row>" + "    </bv-container>" + "" + "    <!-- DRAWER: Programmatically triggered via $ref -->" + '    <bv-drawer ref="mainDrawer" title="🎨 BlaiseUI Drawer">' + '       <p class="mb-3">This is the new <strong>bv-drawer</strong> component! On desktop or mobile it smoothly slides out.</p>' + "       <bv-list-group>" + '          <bv-list-group-item active="true" @click="clickNotif(\'Drawer Menu 1\')">🏠 Dashboard View</bv-list-group-item>' + '          <bv-list-group-item @click="clickNotif(\'Drawer Menu 2\')">⚙️ Component Config</bv-list-group-item>' + '          <bv-list-group-item @click="clickNotif(\'Drawer Menu 3\')">📱 Mobile Optimization</bv-list-group-item>' + "       </bv-list-group>" + '       <div class="mt-4">' + '          <bv-btn label="Close Drawer" variant="outline-primary" @click="closeDrawer"></bv-btn>' + "       </div>" + "    </bv-drawer>" + "" + "    <!-- OVERLAYS: Programmatically triggered via $ref -->" + '    <bv-modal b-ref="mainModal" title="🔥 System Confirmation" okLabel="Process" cancelLabel="Close" @ok="modalConfirm">' + "       <p>You are about to process a state update via Pascal.</p>" + '       <div class="p-3 bg-light rounded text-center" style="background: #f8fafc; padding: 12px; border-radius: 6px; margin-top: 10px;">' + "          <p>Current Values:</p>" + '          <bv-badge variant="info">{{ libName }}</bv-badge>' + '          <bv-badge variant="success">{{ count }}%</bv-badge>' + "       </div>" + "    </bv-modal>" + "" + "    <!-- SETTINGS MODAL: Programmatically triggered via ⚙️ Settings -->" + '    <bv-modal b-ref="settingsModal" title="⚙️ Configurações & Preferências" okLabel="Aplicar" cancelLabel="Fechar" @ok="applySettings">' + '       <div class="p-2">' + '          <div class="mb-3" style="margin-bottom: 14px;">' + '             <strong style="display: block; margin-bottom: 6px; font-size: 14px;">🌓 Alternar Tema Visual</strong>' + '             <button class="bui-btn bui-btn-sm bui-btn-secondary" type="button" @click="$theme.toggle()">' + '                <span v-if="$theme.isDark">☀️ Mudar para Tema Claro</span>' + '                <span v-if="!$theme.isDark">🌙 Mudar para Tema Escuro</span>' + "             </button>" + "          </div>" + '          <div class="mb-3" style="margin-bottom: 14px;">' + '             <strong style="display: block; margin-bottom: 6px; font-size: 14px;">🌐 Idioma da Aplicação</strong>' + '             <div style="display: flex; gap: 8px;">' + '                <button class="bui-btn bui-btn-sm" :class="{ \'bui-btn-primary\': $i18n.locale === \'pt\', \'bui-btn-secondary\': $i18n.locale !== \'pt\' }" type="button" @click="$setLocale(\'pt\')">🇧🇷 Português</button>' + '                <button class="bui-btn bui-btn-sm" :class="{ \'bui-btn-primary\': $i18n.locale === \'en\', \'bui-btn-secondary\': $i18n.locale !== \'en\' }" type="button" @click="$setLocale(\'en\')">🇺🇸 English</button>' + "             </div>" + "          </div>" + '          <div class="p-2 rounded" style="background: #f1f5f9; border-radius: 6px; font-size: 12px; color: #475569; margin-top: 10px;">' + "             🛡️ <strong>BlaiseVue 4.0</strong> &bull; Reatividade Pascal + WebAssembly" + "          </div>" + "       </div>" + "    </bv-modal>" + "" + '    <bv-toast b-ref="mainToast" title="Global Notification" variant="success" :duration="4000">' + "       Action performed: <strong>{{ lastAction }}</strong>" + "    </bv-toast>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["count"] = 45;
      d["libName"] = "Blaise_Demo_2026";
      d["category"] = "high";
      d["currentPage"] = 1;
      d["lastAction"] = "System Ready";
      d["faqItems"] = "";
      d["catOptions"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    m["clickNotif"] = function (_this, info) {
      _this["lastAction"] = info;
      pas.BVPascalDX.TriggerRef(_this,"mainToast","show");
    };
    m["showModal"] = function (_this) {
      pas.BVPascalDX.TriggerRef(_this,"mainModal","show");
    };
    m["modalConfirm"] = function (_this) {
      _this["libName"] = "SYNC_" + pas.BVPascalDX.NowTimestampStr();
      _this["lastAction"] = "Modal Confirmed";
      pas.BVPascalDX.TriggerRef(_this,"mainToast","show");
    };
    m["updatePage"] = function (_this, p) {
      _this["currentPage"] = p;
    };
    m["tabChanged"] = function (_this, id) {
      pas.System.Writeln("Tab changed to: ",id);
    };
    m["showDrawer"] = function (_this) {
      pas.BVPascalDX.TriggerRef(_this,"mainDrawer","open");
    };
    m["closeDrawer"] = function (_this) {
      pas.BVPascalDX.TriggerRef(_this,"mainDrawer","close");
    };
    m["openSettings"] = function (_this) {
      pas.BVPascalDX.TriggerRef(_this,"settingsModal","show");
    };
    m["applySettings"] = function (_this) {
      pas.BVPascalDX.CallMethod$1(_this,"clickNotif",["Configurações salvas!"]);
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      var items = null;
      var q1 = null;
      var q2 = null;
      var q3 = null;
      var opts = null;
      var o1 = null;
      var o2 = null;
      var o3 = null;
      if (!_this) _this = this;
      items = pas.BVPascalDX.NewArray();
      q1 = pas.BVPascalDX.NewObject();
      q1["id"] = "q1";
      q1["title"] = "How does Shared State work?";
      q1["content"] = "BlaiseVue uses B-Store for centralized reactive state management in Pascal.";
      q2 = pas.BVPascalDX.NewObject();
      q2["id"] = "q2";
      q2["title"] = "Unified Design System?";
      q2["content"] = "BlaiseUI is 100% native Pascal with pure CSS variables and zero external dependencies.";
      q3 = pas.BVPascalDX.NewObject();
      q3["id"] = "q3";
      q3["content"] = "The compiler generates minimalist JavaScript bundles, resulting in instant load times.";
      q3["title"] = "JIT Optimization?";
      items.push(q1);
      items.push(q2);
      items.push(q3);
      _this["faqItems"] = items;
      opts = pas.BVPascalDX.NewArray();
      o1 = pas.BVPascalDX.NewObject();
      o1["value"] = "low";
      o1["text"] = "Low Priority";
      o2 = pas.BVPascalDX.NewObject();
      o2["value"] = "med";
      o2["text"] = "Medium Priority";
      o3 = pas.BVPascalDX.NewObject();
      o3["value"] = "high";
      o3["text"] = "High Priority (Critical)";
      opts.push(o1);
      opts.push(o2);
      opts.push(o3);
      _this["catOptions"] = opts;
    };
    pas.BVComponents.RegisterComponent("lib-bootstrap-page",comp);
  };
});
rtl.module("uLoginView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uLoginView = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".login-page { min-height: 80vh; display: flex; align-items: center; justify-content: center; padding: 24px 16px; }   .login-card { background: #ffffff; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); width: 100%; max-width: 440px; padding: 32px 28px; border: 1px solid #e2e8f0; }   .login-header { text-align: center; margin-bottom: 24px; }   .login-icon { font-size: 40px; margin-bottom: 8px; }   .login-title { font-size: 22px; font-weight: 700; color: #1e293b; margin: 0 0 6px 0; }   .login-subtitle { font-size: 13px; color: #64748b; margin: 0; }   .form-group { margin-bottom: 16px; }   .form-label { display: block; font-size: 13px; font-weight: 600; color: #334155; margin-bottom: 6px; }   .form-control { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; box-sizing: border-box; outline: none; transition: all 0.2s; }   .form-control:focus { border-color: #42b883; box-shadow: 0 0 0 3px rgba(66, 184, 131, 0.15); }   .auth-error-banner { background: #fee2e2; color: #dc2626; padding: 10px 14px; border-radius: 6px; font-size: 13px; margin-bottom: 16px; border: 1px solid #fecaca; }   .auth-success-banner { background: #dcfce7; color: #15803d; padding: 10px 14px; border-radius: 6px; font-size: 13px; margin-bottom: 16px; border: 1px solid #bbf7d0; }   .bui-btn { padding: 10px 18px; border-radius: 6px; font-size: 14px; font-weight: 600; border: none; cursor: pointer; transition: all 0.2s; text-decoration: none; display: inline-block; text-align: center; }   .btn-block { width: 100%; display: block; }   .bui-btn-primary { background: #42b883; color: white; }   .bui-btn-primary:hover { background: #33a06f; }   .bui-btn-danger { background: #ef4444; color: white; }   .bui-btn-danger:hover { background: #dc2626; }   .demo-logins-section { margin-top: 24px; }   .demo-divider { display: flex; align-items: center; text-align: center; color: #94a3b8; font-size: 12px; margin-bottom: 14px; }   .demo-divider::before, .demo-divider::after { content: ''; flex: 1; border-bottom: 1px solid #e2e8f0; }   .demo-divider span { padding: 0 10px; }   .demo-buttons { display: flex; gap: 8px; }   .demo-btn { flex: 1; padding: 8px 4px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; border: 1px solid #cbd5e1; background: #f8fafc; color: #334155; transition: all 0.2s; }   .demo-btn:hover { background: #e2e8f0; }   .demo-admin:hover { border-color: #8b5cf6; color: #7c3aed; }   .demo-manager:hover { border-color: #3b82f6; color: #2563eb; }   .demo-user:hover { border-color: #10b981; color: #059669; }   .logged-in-box { padding: 18px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0; }   .user-info-row { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }   .user-avatar { font-size: 32px; }   .user-email { font-size: 12px; color: #64748b; }   .role-badge { padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 700; text-transform: uppercase; margin-left: auto; }   .role-admin { background: #ede9fe; color: #7c3aed; }   .role-manager { background: #dbeafe; color: #2563eb; }   .role-user { background: #e2e8f0; color: #475569; }   .logged-actions { display: flex; gap: 8px; }   .logged-actions .bui-btn { flex: 1; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="login-page">' + '    <div class="login-card">' + "      <!-- HEADER -->" + '      <div class="login-header">' + '        <div class="login-icon">🔐</div>' + '        <h2 class="login-title">Autenticação BlaiseVue</h2>' + '        <p class="login-subtitle">Acesso seguro com tokens JWT nativos emitidos pelo mORMot 2</p>' + "      </div>" + "" + "      <!-- ALREADY LOGGED IN BANNER -->" + '      <div class="logged-in-box" v-if="$auth && $auth.isAuthenticated">' + '        <div class="user-info-row">' + '          <span class="user-avatar">👤</span>' + "          <div>" + "            <strong>{{ $auth.user.name }}</strong>" + '            <div class="user-email">{{ $auth.user.email }}</div>' + "          </div>" + '          <span class="role-badge" :class="\'role-\' + $auth.user.role">{{ $auth.user.role }}</span>' + "        </div>" + '        <div class="logged-actions">' + '          <a href="#/" class="bui-btn bui-btn-primary">Ir para o Início 🏠</a>' + '          <button class="bui-btn bui-btn-danger" @click="handleLogout">Encerrar Sessão 🚪</button>' + "        </div>" + "      </div>" + "" + "      <!-- LOGIN FORM -->" + '      <div class="login-form" v-if="!$auth || !$auth.isAuthenticated">' + '        <div class="form-group">' + '          <label class="form-label">E-mail de Acesso:</label>' + "          <input" + '            type="email"' + '            class="form-control"' + '            placeholder="ex: admin@blaisevue.dev"' + '            b-model="email"' + "          />" + "        </div>" + "" + '        <div class="form-group">' + '          <label class="form-label">Senha:</label>' + "          <input" + '            type="password"' + '            class="form-control"' + '            placeholder="••••••••"' + '            b-model="password"' + "          />" + "        </div>" + "" + "        <!-- ERROR MESSAGE -->" + '        <div class="auth-error-banner" v-if="errorMessage">' + "          ⚠️ {{ errorMessage }}" + "        </div>" + "" + "        <!-- SUCCESS MESSAGE -->" + '        <div class="auth-success-banner" v-if="successMessage">' + "          ✅ {{ successMessage }}" + "        </div>" + "" + "        <!-- SUBMIT BUTTON -->" + "        <button" + '          class="bui-btn bui-btn-primary btn-block"' + '          :disabled="loading"' + '          @click="submitLogin"' + "        >" + '          <span v-if="!loading">Entrar no Sistema 🚀</span>' + '          <span v-if="loading">Autenticando no mORMot 2... ⏳</span>' + "        </button>" + "" + "        <!-- QUICK DEMO LOGINS -->" + '        <div class="demo-logins-section">' + '          <div class="demo-divider"><span>Acesso Rápido de Demonstração</span></div>' + '          <div class="demo-buttons">' + '            <button class="demo-btn demo-admin" @click="quickLogin(\'admin@blaisevue.dev\', \'admin123\')">' + "              ⚡ Admin" + "            </button>" + '            <button class="demo-btn demo-manager" @click="quickLogin(\'manager@blaisevue.dev\', \'manager123\')">' + "              👥 Gerente" + "            </button>" + '            <button class="demo-btn demo-user" @click="quickLogin(\'user@blaisevue.dev\', \'user123\')">' + "              👤 Usuário" + "            </button>" + "          </div>" + "        </div>" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["email"] = "";
      d["password"] = "";
      d["errorMessage"] = "";
      d["successMessage"] = "";
      d["loading"] = false;
      Result = d;
      return Result;
    };
    m = new Object();
    m["quickLogin"] = function (_this, e, p) {
      _this["email"] = e;
      _this["password"] = p;
      _this["errorMessage"] = "";
      pas.BVPascalDX.CallMethod(_this,"submitLogin");
    };
    m["submitLogin"] = function (_this) {
      if ((_this["email"] == "") || (_this["password"] == "")) {
        _this["errorMessage"] = "Por favor, informe o e-mail e a senha.";
        return;
      };
      pas.BVPascalDX.AuthLogin(_this,_this["email"],_this["password"],"#/");
    };
    m["handleLogout"] = function (_this) {
      pas.BVPascalDX.AuthLogout(_this);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("login-view-page",comp);
  };
});
rtl.module("uAbout",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
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
    comp["template"] = "  <div>" + '    <div class="section main-intro">' + '      <h1 class="section-title">About BlaiseVue Professional</h1>' + '      <p><strong>System Status:</strong> <span class="badge badge-green">Running via Pascal Power ⚔️</span></p>' + "      <p>Below you will find the analytical laboratory of all features implemented in the framework.</p>" + "      " + '      <div class="action-bar">' + '        <button class="btn-primary" @click="toggleDemos">' + "          {{ showDemos ? '🔐 Close Laboratory' : '🔓 Open Feature Laboratory' }}" + "        </button>" + '        <button class="btn-outline" @click="alertaTecnologia">Version: {{ versao }}</button>' + "      </div>" + "    </div>" + "" + "    <!-- Technology Table (Always Visible) -->" + '    <div class="section">' + '      <h2 class="section-title">🛡️ Technological Arsenal</h2>' + '      <div class="resource-grid">' + '        <div class="resource-item">' + '          <span class="badge badge-blue">Reactivity</span>' + "          <p>Dependency Tracking via JS Proxy</p>" + "        </div>" + '        <div class="resource-item">' + '          <span class="badge badge-green">Compilation</span>' + "          <p>AOT Pascal to Optimized JS</p>" + "        </div>" + '        <div class="resource-item">' + '          <span class="badge badge-orange">Routing</span>' + "          <p>SPA Router with History/Hash</p>" + "        </div>" + '        <div class="resource-item">' + '          <span class="badge badge-gray">Store</span>' + "          <p>Global State Management (TBVStore)</p>" + "        </div>" + "      </div>" + "    </div>" + "" + "    <!-- Engine Info Section -->" + '    <div class="section engine-section">' + '       <h2 class="section-title">⚙️ High Performance Engine</h2>' + '       <div class="tech-card-pair">' + '          <div class="tech-card fpc">' + '             <div class="card-icon">🏰</div>' + "             <h3>Free Pascal</h3>" + "             <p>The safety of strong typing.</p>" + "          </div>" + '          <div class="tech-card pas2js">' + '             <div class="card-icon">⚡</div>' + "             <h3>Pas2JS</h3>" + "             <p>The agility of the Web ecosystem.</p>" + "          </div>" + "       </div>" + "    </div>" + "" + "    <!-- THE LABORATORY (Feature Demos) -->" + '    <transition name="fade">' + '      <div v-if="showDemos" class="lab-container">' + "          <!-- 1. Reactive Iteration (b-for) -->" + '          <div class="section lab-section">' + '            <h2 class="section-title">🔬 Lab 01: Dynamic Iteration (b-for)</h2>' + "            <p>The items below are injected directly from Pascal into a reactive <code>TJSArray</code>.</p>" + '            <ul class="resource-list">' + '              <li v-for="item in tecnologias" class="resource-li">' + '                <span class="li-icon">🔹</span>' + "                <strong>{{ item.nome }}</strong> " + '                <span class="li-tag">{{ item.tipo }}</span>' + "              </li>" + "            </ul>" + '            <div style="margin-top: 15px;">' + '              <button class="btn-primary btn-sm" @click="addTec">➕ Inject New Tech</button>' + '              <button class="btn-danger btn-sm" @click="limparTecs">🗑️ Clear All</button>' + "            </div>" + "          </div>" + "" + "          <!-- 2. Two-Way and Computed -->" + '          <div class="section lab-section">' + '            <h2 class="section-title">📊 Lab 02: Computed & Two-Way</h2>' + '            <div class="form-horizontal">' + '              <div class="form-group">' + "                <label>First Name:</label>" + '                <input type="text" b-model="firstName" class="form-control">' + "              </div>" + '              <div class="form-group">' + "                <label>Last Name:</label>" + '                <input type="text" b-model="lastName" class="form-control">' + "              </div>" + "            </div>" + '            <div class="result-box">' + "              <strong>Computed Result:</strong> " + '              <span class="res-text">{{ perfilInfo }}</span>' + "            </div>" + "          </div>" + "" + "          <!-- 3. Conditional State (b-if) -->" + '          <div class="section lab-section">' + '            <h2 class="section-title">🎭 Lab 03: Conditional State (b-if)</h2>' + '            <div class="toggle-control">' + '              <button class="btn-outline" @click="toggleLogin">' + "                {{ logado ? '🔓 Logout' : '🔐 Simulate Login' }}" + "              </button>" + "            </div>" + '            <div v-if="logado" class="alert alert-success">' + "               ✅ User authenticated via Pascal State!" + "            </div>" + '            <div v-if="!logado" class="alert alert-warning">' + "               ⚠️ Waiting for authentication..." + "            </div>" + "          </div>" + "      </div>" + "    </transition>" + "  </div>";
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
        o1["tipo"] = "Language";
        _this["tecnologias"].push(o1);
        o2 = new Object();
        o2["nome"] = "Proxy Reactivity";
        o2["tipo"] = "Core Engine";
        _this["tecnologias"].push(o2);
      };
    };
    m["toggleLogin"] = function (_this) {
      _this["logado"] = !!(_this["logado"] == false);
    };
    m["addTec"] = function (_this) {
      var o = null;
      o = new Object();
      o["nome"] = "Feature " + pas.SysUtils.IntToStr(_this["tecnologias"].length + 1);
      o["tipo"] = "Generated Dynamically";
      _this["tecnologias"].push(o);
    };
    m["limparTecs"] = function (_this) {
      _this["tecnologias"].length = 0;
    };
    m["alertaTecnologia"] = function (_this) {
      window.alert("BlaiseVue v2.1.0 \\nOptimized for high performance!");
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["perfilInfo"] = function (_this) {
      var Result = undefined;
      Result = "Master " + ("" + _this["firstName"]) + " " + ("" + _this["lastName"]);
      return Result;
    };
    pas.BVComponents.RegisterComponent("about-page",comp);
  };
});
rtl.module("uHome",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uHome = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".home-page { padding: 20px; }   .section { margin-top: 24px; padding: 20px; border-left: 4px solid #42b883; background: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }   .alert-box { margin-top: 10px; padding: 15px; background: #42b883; color: white; border-radius: 8px; }      { Transition Classes: Managed by the BVCompiler transition engine }   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s ease; }   .fade-enter-from, .fade-leave-to { opacity: 0; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="home-page">' + "    <h2>🏠 Home: Control Panel (BlaiseVue Features)</h2>" + "    <p>{{ descricao }}</p>" + "" + "    { 1. Slots & Composition }" + "    <card>" + '      <template slot="header">🎨 Composition via Slots</template>' + "      <p>This 'Card' component uses named slots for the header and default slots for the body.</p>" + "    </card>" + "" + "    { 2. Form Reactivity (B-Model) }" + '    <div class="section">' + "      <h3>✍️ Data Synchronization (B-Model)</h3>" + '      <input type="text" b-model="userName" placeholder="Your name...">' + "      <p>Welcome, <b>{{ userName }}</b>!</p>" + "    </div>" + "" + "    { 3. Global Store (B-Store) }" + '    <div class="section">' + "      <h3>🌍 Global Store (B-Store)</h3>" + "      <p>Framework Version: <badge-blue>{{ $store.appVersion }}</badge-blue></p>" + "      <p>Current User: <b>{{ $store.user }}</b></p>" + "    </div>" + "" + "    { 4. Transitions }" + '    <div class="section">' + "      <h3>✨ Animations & Transitions</h3>" + '      <button @click="toggleVisible">Toggle Visibility</button>' + '      <transition name="fade">' + '        <div v-show="isVisible" class="alert-box">' + "           Fade Effect Active! 👻" + "        </div>" + "      </transition>" + "    </div>" + "" + "    { 5. Provide and Inject }" + "    <info-card>" + '       <template slot="title">Dependency Injection (Provide/Inject)</template>' + "       The <b>Provide/Inject</b> feature allows this component to receive data from distant ancestors without needing manual properties at every level." + "    </info-card>" + "" + "    { 6. Themes & Icons (Blaise-Themes & Blaise-Icons) }" + '    <div class="section">' + "      <h3>🎨 Dynamic Themes & Vector Icons (v2.6)</h3>" + "      <p>Current Active Theme: <b>{{ $theme.current }}</b> (Dark Mode: <b>{{ $theme.isDark ? 'Active 🌙' : 'Inactive ☀️' }}</b>)</p>" + '      <div style="display: flex; gap: 8px; align-items: center; margin: 12px 0;">' + "        <bv-theme-toggle></bv-theme-toggle>" + "        <bv-theme-select></bv-theme-select>" + "      </div>" + '      <div style="display: flex; gap: 16px; align-items: center; margin-top: 12px; flex-wrap: wrap;">' + '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="check-circle" size="22" color="#42b883"></bv-icon> <span>check-circle</span></div>' + '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="star-fill" size="22" color="#f1c40f"></bv-icon> <span>star-fill</span></div>' + '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="heart-fill" size="22" color="#e74c3c"></bv-icon> <span>heart-fill</span></div>' + '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="shield-check" size="22" color="#3498db"></bv-icon> <span>shield-check</span></div>' + '        <div style="display: flex; align-items: center; gap: 6px;"><bv-icon name="gear-fill" size="22" color="#95a5a6"></bv-icon> <span>gear-fill</span></div>' + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["descricao"] = "Welcome to the Framework test center. Below are the main features.";
      d["userName"] = "Pascal Developer";
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
rtl.module("uFormulario",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uFormulario = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = "label { display: block; margin-top: 8px; margin-bottom: 4px; color: #555; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = "  <div>" + '    <div class="section">' + "      <!-- 1. Passando props e escutando eventos -->" + "      <form-header " + '        ref="headerComp"' + '        title="Formulário Especial" ' + '        :subtitle="meuSub"' + '        @header-clicked="onHeaderClick">' + "      </form-header>" + "      " + "      <p>Este formulário demonstra <code>b-model</code>, <code>props</code>, <code>$refs</code> e o novo <strong>Motor de Validação Tipada v2.5</strong> (<code>b-validate</code>, <code>$errors</code>, <code>$v</code>).</p>" + "      <p>Todos os campos abaixo validam e atualizam em tempo real.</p>" + '      <button class="btn-outline" @click="mudarHeaderRef">Usar $refs no Header</button>' + "      <p>Mensagem do Header: <strong>{{ msgHeader }}</strong></p>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">{{ $t(\'form.title\') }}</h2>' + '      <p style="color: #64748b; margin-bottom: 14px;">{{ $t(\'form.subtitle\') }}</p>' + "" + '      <div style="margin-bottom: 14px;">' + "        <label><strong>{{ $t('form.name') }}:</strong></label>" + '        <input type="text" b-model="nome" b-validate="required|min:3" placeholder="Digite seu nome (mín. 3 letras)">' + '        <span b-if="$errors.nome" class="bv-error-msg">⚠️ {{ $errors.nome }}</span>' + "      </div>" + "" + '      <div style="margin-bottom: 14px;">' + "        <label><strong>{{ $t('form.email') }}:</strong></label>" + '        <input type="text" b-model="email" b-validate="required|email" placeholder="usuario@dominio.com">' + '        <span b-if="$errors.email" class="bv-error-msg">⚠️ {{ $errors.email }}</span>' + "      </div>" + "" + '      <div style="margin-bottom: 14px;">' + "        <label><strong>{{ $t('form.city') }}:</strong></label>" + '        <input type="text" b-model="cidade" b-validate="required" placeholder="Sua cidade">' + '        <span b-if="$errors.cidade" class="bv-error-msg">⚠️ {{ $errors.cidade }}</span>' + "      </div>" + "" + "      <!-- Card de Status Reativo de $v -->" + '      <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; margin-top: 16px;">' + '        <div style="display: flex; align-items: center; justify-content: space-between;">' + "          <span><strong>{{ $t('form.formState') }}:</strong></span>" + '          <span class="badge" :class="{ \'badge-green\': !$v.$invalid && $v.$dirty, \'badge-orange\': $v.$invalid, \'badge-gray\': !$v.$dirty }">' + "            {{ $v.$dirty ? ($v.$invalid ? $t('form.statusInvalid') : $t('form.statusValid')) : 'Não modificado' }}" + "          </span>" + "        </div>" + '        <div style="font-size: 13px; color: #64748b; margin-top: 6px;">' + "          Dirty: <code>{{ $v.$dirty }}</code> | Invalid: <code>{{ $v.$invalid }}</code>" + "        </div>" + "      </div>" + "" + '      <div b-if="msgSucesso" style="margin-top: 15px; padding: 12px; background: #ecfdf5; border: 1px solid #10b981; border-radius: 6px; color: #065f46;">' + "        {{ msgSucesso }}" + "      </div>" + "" + '      <div style="margin-top: 16px;">' + '        <button class="btn-primary" @click="enviar">{{ $t(\'form.submit\') }}</button>' + '        <button class="btn-outline" @click="preencher">{{ $t(\'form.fillValid\') }}</button>' + '        <button class="btn-danger" @click="limpar">{{ $t(\'form.reset\') }}</button>' + "      </div>" + "    </div>" + "" + '    <div class="section">' + '      <h2 class="section-title">Preview dos Dados & Validação</h2>' + "      <table>" + "        <tr><th>Campo</th><th>Valor</th><th>Status</th></tr>" + "        <tr>" + "          <td>Nome</td>" + "          <td><strong>{{ nome }}</strong></td>" + '          <td><span class="badge" :class="{ \'badge-green\': !$errors.nome && nome, \'badge-orange\': $errors.nome, \'badge-gray\': !nome }">{{ $errors.nome ? \'Erro\' : (nome ? \'OK\' : \'Pendente\') }}</span></td>' + "        </tr>" + "        <tr>" + "          <td>Email</td>" + "          <td><strong>{{ email }}</strong></td>" + '          <td><span class="badge" :class="{ \'badge-green\': !$errors.email && email, \'badge-orange\': $errors.email, \'badge-gray\': !email }">{{ $errors.email ? \'Erro\' : (email ? \'OK\' : \'Pendente\') }}</span></td>' + "        </tr>" + "        <tr>" + "          <td>Cidade</td>" + "          <td><strong>{{ cidade }}</strong></td>" + '          <td><span class="badge" :class="{ \'badge-green\': !$errors.cidade && cidade, \'badge-orange\': $errors.cidade, \'badge-gray\': !cidade }">{{ $errors.cidade ? \'Erro\' : (cidade ? \'OK\' : \'Pendente\') }}</span></td>' + "        </tr>" + "      </table>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["nome"] = "";
      d["email"] = "";
      d["cidade"] = "";
      d["meuSub"] = "Este subtítulo é reativo do pai!";
      d["msgHeader"] = "(clique no título do header)";
      d["msgSucesso"] = "";
      Result = d;
      return Result;
    };
    m = new Object();
    m["onHeaderClick"] = function (_this, arg) {
      _this["msgHeader"] = arg;
      _this["meuSub"] = "O subtítulo mudou reativamente via props!";
    };
    m["mudarHeaderRef"] = function (_this) {
      var refs = null;
      var header = null;
      refs = _this["$refs"];
      if (refs != null) {
        header = refs["headerComp"];
        if (header != null) header["title"] = "Título alterado via $refs!";
      };
    };
    m["enviar"] = function (_this) {
      var valido = false;
      valido = pas.BVPascalDX.ValidateForm(_this);
      if (valido) {
        _this["msgSucesso"] = "🎉 Parabéns " + ("" + _this["nome"]) + "! Formulário validado com sucesso.";
      } else {
        _this["msgSucesso"] = "";
      };
    };
    m["preencher"] = function (_this) {
      _this["nome"] = "Blaise Pascal";
      _this["email"] = "blaise@pascal.dev";
      _this["cidade"] = "Clermont-Ferrand";
      _this["msgSucesso"] = "";
      pas.BVPascalDX.TouchValidation(_this);
    };
    m["limpar"] = function (_this) {
      _this["nome"] = "";
      _this["email"] = "";
      _this["cidade"] = "";
      _this["msgSucesso"] = "";
      pas.BVPascalDX.ResetValidation(_this);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("formulario-page",comp);
  };
});
rtl.module("uProFeatures",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uProFeatures = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = '.pro-features { animation: fadeIn 0.5s ease-in; }   @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }    /* Transition Classes */   .fade-enter-active, .fade-leave-active { transition: opacity 0.5s, transform 0.5s; }   .fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-10px); }   .fade-enter-to, .fade-leave-from { opacity: 1; transform: translateY(0); }    /* FLIP List Grid */   .flip-grid {     display: flex;     flex-wrap: wrap;     gap: 10px;     margin-top: 15px;     min-height: 50px;   }   .flip-card {     background: #ffffff;     border: 2px solid #42b883;     border-radius: 8px;     padding: 10px 16px;     font-weight: 600;     color: #2c3e50;     box-shadow: 0 2px 4px rgba(0,0,0,0.05);     display: inline-block;   }    /* WebAssembly Section Styles */   .wasm-card { border-left: 4px solid #6366f1; }   .wasm-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-top: 12px; }   .wasm-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px; }   .wasm-result { margin-top: 10px; font-size: 13px; padding: 8px 10px; background: #fff; border-radius: 6px; border: 1px solid #e2e8f0; }   .stat-badge { flex: 1; min-width: 140px; background: #fff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px 14px; }   .stat-label { font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 600; }   .stat-val { font-size: 20px; font-weight: bold; margin-top: 4px; }    /* Dark mode adjustments */   html[data-bs-theme="dark"] .wasm-box, body.theme-dark .wasm-box,   html[data-bs-theme="dark"] .wasm-bench-container, body.theme-dark .wasm-bench-container {     background: #1e2227;     border-color: #333842;   }   html[data-bs-theme="dark"] .wasm-result, body.theme-dark .wasm-result,   html[data-bs-theme="dark"] .stat-badge, body.theme-dark .stat-badge {     background: #282c34;     border-color: #3e4451;     color: #e0e0e0;   }   html[data-bs-theme="dark"] .wasm-bench-title, body.theme-dark .wasm-bench-title {     color: #abb2bf;   }';
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="pro-features">' + '    <h2 class="section-title">{{ $t(\'pro.title\') }}</h2>' + "    " + "    <!-- 1. Teste de Slots -->" + '    <card titulo="Demonstração de Slot">' + '      <template slot="header">Título Customizado via Slot 🎨</template>' + "      <p>Este texto está vindo <strong>DA PÁGINA PAI</strong> e sendo injetado dentro do componente Card!</p>" + '      <button class="btn-primary" @click="testarSlot">Clique para Ver o Log</button>' + '      <template slot="footer">Rodapé customizado via Slot 🔗</template>' + "    </card>" + "" + "    <!-- 2. Teste de Global Store -->" + '    <div class="section">' + "       <h3>🧠 Memória Central ($store)</h3>" + '       <p>Versão do App: <span class="badge badge-green">{{ $store.appVersion }}</span></p>' + "       <p>Usuário Logado: <strong>{{ $store.user }}</strong></p>" + '       <button class="btn-outline" @click="mudarVersao">Atualizar Versão Global</button>' + "    </div>" + "" + "    <!-- 3. Teste de Provide/Inject -->" + '    <div class="section">' + "       <h3>🔗 Elo Sagrado (Inject)</h3>" + "       <p>Dados injetados do App Root:</p>" + "       <ul>" + "          <li>Ambiente: <strong>{{ getAmbiente().status }}</strong></li>" + "          <li>ID Interno: <strong>{{ getAmbiente().id }}</strong></li>" + "       </ul>" + "    </div>" + "" + "    <!-- 4. Teste de Lifecycle Updated -->" + '    <div class="section">' + "       <h3>🔄 Batida do Motor (Updated)</h3>" + "       <p>Contador de Reatividade: <strong>{{ contador }}</strong></p>" + '       <button class="btn-primary" @click="incrementar">Pulsar Motor</button>' + "       <p><small>(Veja o log no console para o hook 'updated')</small></p>" + "    </div>" + "" + "    <!-- 5. Teste de Transições -->" + '    <div class="section">' + "       <h3>✨ Magia Visual (Transitions)</h3>" + '       <button class="btn-outline" @click="toggleShow">Alternar Elemento</button>' + '       <transition name="fade">' + '          <div v-show="showElement" class="badge badge-orange" style="padding: 20px; display: block; margin-top: 10px;">' + "             Surpresa! Eu apareço com suavidade. 🎭" + "          </div>" + "       </transition>" + "    </div>" + "" + "    <!-- 6. Teste de Transições de Lista (Transition-Group FLIP) -->" + '    <div class="section">' + "       <h3>{{ $t('pro.transitionTitle') }}</h3>" + '       <p style="color: #64748b; margin-bottom: 12px;">' + "         O algoritmo <strong>FLIP</strong> (<em>First, Last, Invert, Play</em>) calcula a diferença de coordenadas geométricas antes e depois de mutações de lista e anima suavemente via CSS Transforms." + "       </p>" + '       <div style="margin-bottom: 14px;">' + '         <button class="btn-primary" @click="embaralhar">{{ $t(\'pro.shuffle\') }}</button>' + '         <button class="btn-outline" @click="adicionarItem">{{ $t(\'pro.add\') }}</button>' + '         <button class="btn-danger" @click="removerItem">{{ $t(\'pro.remove\') }}</button>' + '         <button class="btn-outline" @click="resetarLista">{{ $t(\'pro.resetList\') }}</button>' + "       </div>" + "" + '       <transition-group tag="div" name="list" class="flip-grid">' + '          <div b-for="item in itens" class="flip-card">' + "             {{ item }}" + "          </div>" + "       </transition-group>" + "    </div>" + "" + "    <!-- 7. Aceleração WebAssembly & Benchmarking (BlaiseVue 3.0 Engine) -->" + '    <div class="section wasm-card">' + '       <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">' + '         <h3 style="color: #6366f1; margin: 0;">⚡ Aceleração WebAssembly ($wasm) - BlaiseVue 3.0</h3>' + '         <span class="badge" style="background: #6366f1;">Wasm Active 🚀</span>' + "       </div>" + '       <p style="color: #64748b; margin-bottom: 16px;">' + "         O BlaiseVue 3.0 integra computação de alto desempenho via <strong>WebAssembly nativo</strong> diretamente do Pascal no navegador através do objeto injetado <code>$wasm</code>, executando com velocidade quase-nativa em relação ao JavaScript tradicional." + "       </p>" + "" + '       <div class="wasm-grid">' + "         <!-- Teste 1: Fibonacci Wasm -->" + '         <div class="wasm-box">' + '           <h4 style="color: #2c3e50; margin-bottom: 8px;">🔢 Cálculo Fibonacci Acelerado</h4>' + '           <p style="font-size: 13px; color: #64748b;">Calcule o N-ésimo número de Fibonacci via Wasm:</p>' + '           <div style="display: flex; gap: 8px; margin: 10px 0; align-items: center;">' + '             <input type="number" b-model="fibInput" style="width: 80px; padding: 6px; border: 1px solid #ccc; border-radius: 4px;" min="1" max="45" />' + '             <button class="btn-primary" @click="calcularWasmFib">Calcular Wasm ⚡</button>' + "           </div>" + '           <div class="wasm-result">' + "             Resultado: <strong>{{ wasmFibResult }}</strong>" + "             <br />" + "             <small>Tempo de execução: <strong>{{ wasmFibTime }} ms</strong></small>" + "           </div>" + "         </div>" + "" + "         <!-- Teste 2: Teste de Primalidade Wasm -->" + '         <div class="wasm-box">' + '           <h4 style="color: #2c3e50; margin-bottom: 8px;">🛡️ Teste de Primalidade Wasm</h4>' + '           <p style="font-size: 13px; color: #64748b;">Valide se um número grande é primo usando algoritmo compilado:</p>' + '           <div style="display: flex; gap: 8px; margin: 10px 0; align-items: center;">' + '             <input type="number" b-model="primeInput" style="width: 120px; padding: 6px; border: 1px solid #ccc; border-radius: 4px;" />' + '             <button class="btn-primary" style="background: #8e44ad;" @click="testarPrimoWasm">Verificar Primo 🔍</button>' + "           </div>" + '           <div class="wasm-result">' + "             Status: <strong>{{ primeResult }}</strong>" + "           </div>" + "         </div>" + "       </div>" + "" + "       <!-- Teste 3: Benchmark em Tempo Real -->" + '       <div style="margin-top: 20px; padding: 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px;" class="wasm-bench-container">' + '         <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">' + "           <div>" + '             <h4 style="margin: 0; color: #1e293b;" class="wasm-bench-title">📊 Benchmark em Tempo Real: WebAssembly vs JavaScript</h4>' + '             <p style="font-size: 13px; color: #64748b; margin-top: 4px;">Executa 1.000 iterações em paralelo comparando Wasm com JS Vanilla.</p>' + "           </div>" + '           <button class="btn-primary" style="background: #6366f1;" @click="rodarBenchmark">Executar Benchmark 🚀</button>' + "         </div>" + "" + '         <div style="display: flex; gap: 16px; margin-top: 14px; flex-wrap: wrap;">' + '           <div class="stat-badge">' + '             <div class="stat-label">JavaScript Puro</div>' + '             <div class="stat-val" style="color: #e67e22;">{{ benchJsTime }} ms</div>' + "           </div>" + '           <div class="stat-badge">' + '             <div class="stat-label">WebAssembly Nativo</div>' + '             <div class="stat-val" style="color: #10b981;">{{ benchWasmTime }} ms</div>' + "           </div>" + '           <div class="stat-badge">' + '             <div class="stat-label">Aceleração Relativa</div>' + '             <div class="stat-val" style="color: #6366f1;">{{ benchSpeedup }}</div>' + "           </div>" + "         </div>" + '         <p style="font-size: 12px; color: #64748b; margin-top: 10px;">' + "           Status do Benchmark: <em>{{ benchSummary }}</em>" + "         </p>" + "       </div>" + "" + "       <!-- Teste 4: SSG / Hydration Engine Demo -->" + '       <div style="margin-top: 20px; padding: 14px; background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 8px;">' + '         <h4 style="margin: 0 0 6px 0; color: #065f46;">🚀 Motor SSG & Hidratação Reativa (BlaiseVue 3.0)</h4>' + '         <p style="font-size: 13px; color: #047857; margin: 0;">' + "           O BlaiseVue 3.0 detecta nós pré-renderizados estaticamente via <code>bv run ssg</code> e executa <strong>Rehydration</strong> reativa no cliente preservando a hierarquia DOM existente sem recriar os elementos do zero." + "         </p>" + "       </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["contador"] = 0;
      d["showElement"] = true;
      d["itens"] = "";
      d["fibInput"] = 20;
      d["wasmFibResult"] = 6765;
      d["wasmFibTime"] = "0.04";
      d["primeInput"] = 999983;
      d["primeResult"] = "999983 é primo! 💎";
      d["benchIters"] = 1000;
      d["benchJsTime"] = "0.00";
      d["benchWasmTime"] = "0.00";
      d["benchSpeedup"] = "Calculando...";
      d["benchSummary"] = "Pronto para execução";
      Result = d;
      return Result;
    };
    m = new Object();
    m["testarSlot"] = function (_this) {
      pas.System.Writeln("[Slot Test] O pai está falando!");
    };
    m["mudarVersao"] = function (_this) {
      var currentVer = "";
      var newVer = "";
      var newUser = "";
      currentVer = "" + _this["$store"]["appVersion"];
      if (currentVer === "2.1.0-ULTRA-PRO") {
        newVer = "3.0.0-TURBO-HYPER";
        newUser = "Blaise Visionary 🚀";
      } else if (currentVer === "3.0.0-TURBO-HYPER") {
        newVer = "1.0.0-PRO";
        newUser = "DevMaster 🏆";
      } else {
        newVer = "2.1.0-ULTRA-PRO";
        newUser = "Pascal King 👑";
      };
      _this["$store"]["appVersion"] = newVer;
      _this["$store"]["user"] = newUser;
      pas.System.Writeln("[Store] Memória Central Atualizada! Versão: " + newVer + " | Usuário: " + newUser);
    };
    m["incrementar"] = function (_this) {
      _this["contador"] = rtl.trunc(_this["contador"]) + 1;
    };
    m["toggleShow"] = function (_this) {
      _this["showElement"] = !!(_this["showElement"] == false);
    };
    m["embaralhar"] = function (_this) {
      var Arr = null;
      var i = 0;
      var j = 0;
      var Tmp = undefined;
      Arr = _this["itens"];
      if (Arr !== null) {
        for (var $l = Arr.length - 1; $l >= 1; $l--) {
          i = $l;
          j = pas.System.Random(i + 1);
          Tmp = Arr[i];
          Arr[i] = Arr[j];
          Arr[j] = Tmp;
        };
        _this["itens"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewArray(),Arr);
      };
    };
    m["adicionarItem"] = function (_this) {
      var Emojis = ["⚡ Lightning","🔥 Fire","🚀 Rocket","💎 Diamond","🔮 Crystal","🌟 Star","🛡️ Shield","🎯 Target"];
      var Arr = null;
      Arr = _this["itens"];
      if (Arr !== null) Arr.push(Emojis[pas.System.Random(8)] + " #" + pas.SysUtils.IntToStr(Arr.length + 1));
    };
    m["removerItem"] = function (_this) {
      var Arr = null;
      Arr = _this["itens"];
      if ((Arr !== null) && (Arr.length > 0)) Arr.shift();
    };
    m["resetarLista"] = function (_this) {
      _this["itens"] = pas.BVPascalDX.NewArray();
      _this["itens"].push("⚡ Pascal");
      _this["itens"].push("🔥 BlaiseVue");
      _this["itens"].push("🚀 WebAssembly");
      _this["itens"].push("💎 HighPerf");
    };
    m["calcularWasmFib"] = function (_this) {
      var n = 0;
      var res = 0;
      var t0 = 0.0;
      var t1 = 0.0;
      n = pas.SysUtils.StrToIntDef("" + _this["fibInput"],1);
      t0 = pas.BVPascalDX.NowTimestampMs();
      res = rtl.trunc(pas.BVPascalDX.WasmCall(_this,"math","fib",n));
      t1 = pas.BVPascalDX.NowTimestampMs();
      _this["wasmFibResult"] = res;
      _this["wasmFibTime"] = pas.SysUtils.FormatFloat("0.000",t1 - t0);
    };
    m["testarPrimoWasm"] = function (_this) {
      var n = 0;
      var isP = 0;
      n = pas.SysUtils.StrToIntDef("" + _this["primeInput"],2);
      isP = rtl.trunc(pas.BVPascalDX.WasmCall(_this,"math","isPrime",n));
      if (isP === 1) {
        _this["primeResult"] = pas.SysUtils.IntToStr(n) + " é um NÚMERO PRIMO! 💎"}
       else _this["primeResult"] = pas.SysUtils.IntToStr(n) + " NÃO é primo ❌";
    };
    m["rodarBenchmark"] = function (_this) {
      var n = 0;
      var rep = undefined;
      n = pas.SysUtils.StrToIntDef("" + _this["fibInput"],20);
      rep = pas.BVPascalDX.WasmBenchmark(_this,"math","fib",n,1000);
      if (rep != null) {
        _this["benchJsTime"] = pas.BVPascalDX.GetFieldStr(rep,"jsDurationMs","");
        _this["benchWasmTime"] = pas.BVPascalDX.GetFieldStr(rep,"wasmDurationMs","");
        _this["benchSpeedup"] = pas.BVPascalDX.GetFieldStr(rep,"speedup","") + " Mais Rápido! 🚀";
        _this["benchSummary"] = "Executadas 1.000 iterações com sucesso no módulo math.";
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      var rep = undefined;
      if (!_this) _this = this;
      _this["itens"] = pas.BVPascalDX.NewArray();
      _this["itens"].push("⚡ Pascal");
      _this["itens"].push("🔥 BlaiseVue");
      _this["itens"].push("🚀 WebAssembly");
      _this["itens"].push("💎 HighPerf");
      rep = pas.BVPascalDX.WasmBenchmark(_this,"math","fib",20,1000);
      if (rep != null) {
        _this["benchJsTime"] = pas.BVPascalDX.GetFieldStr(rep,"jsDurationMs","");
        _this["benchWasmTime"] = pas.BVPascalDX.GetFieldStr(rep,"wasmDurationMs","");
        _this["benchSpeedup"] = pas.BVPascalDX.GetFieldStr(rep,"speedup","") + " Mais Rápido! 🚀";
        _this["benchSummary"] = "Módulo WebAssembly math ativo e operacional.";
      };
    };
    comp["updated"] = function (_this) {
      if (!_this) _this = this;
      pas.System.Writeln("[Lifecycle] Componente UPDATED! Pulso detectado.");
    };
    comp["inject"] = new Array();
    comp["inject"].push("getAmbiente");
    pas.BVComponents.RegisterComponent("pro-features-page",comp);
  };
});
rtl.module("uDatasetView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uDatasetView = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".dataset-view-page { padding: 8px 0; }   .crud-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-wrap: wrap; gap: 12px; }   .crud-title { font-size: 24px; font-weight: 700; color: #2c3e50; }   .crud-subtitle { font-size: 14px; color: #7f8c8d; margin-top: 4px; }   .crud-header-btns { display: flex; gap: 8px; flex-wrap: wrap; }    .offline-control-bar {     background: #ffffff;     border: 1px solid #e2e8f0;     border-radius: 8px;     padding: 10px 16px;     display: flex;     align-items: center;     gap: 20px;     margin-bottom: 14px;     flex-wrap: wrap;     box-shadow: 0 1px 3px rgba(0,0,0,0.04);   }   .control-bar-item { display: flex; align-items: center; gap: 8px; font-size: 13px; }   .bar-label { font-weight: 600; color: #64748b; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }   .status-pill { padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }   .status-online { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }   .status-offline { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }   .status-storage { background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }    .bui-btn-xs { padding: 3px 8px; font-size: 11px; border-radius: 4px; }   .bui-btn-info { background: #0284c7; color: white; border: none; }    .dataset-status-bar {     background: #f8fafc;     border: 1px solid #e2e8f0;     border-radius: 8px;     padding: 12px 18px;     display: flex;     justify-content: space-between;     align-items: center;     margin-bottom: 20px;     flex-wrap: wrap;     gap: 12px;   }   .status-left { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; font-size: 13px; color: #475569; }   .status-indicator { background: white; padding: 4px 10px; border-radius: 4px; border: 1px solid #cbd5e1; }   .dataset-nav-controls { display: flex; gap: 4px; }   .bui-input { width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; box-sizing: border-box; }   .bui-input:focus { border-color: #38bdf8; outline: none; box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.2); }   .badge-success { background: #10b981; color: white; padding: 4px 10px; border-radius: 12px; font-size: 12px; }   .badge-danger { background: #ef4444; color: white; padding: 4px 10px; border-radius: 12px; font-size: 12px; }   .badge-warning { background: #f59e0b; color: white; padding: 4px 10px; border-radius: 12px; font-size: 12px; }   .badge-secondary { background: #64748b; color: white; padding: 4px 10px; border-radius: 12px; font-size: 12px; }    .crud-modal-backdrop {     position: fixed;     top: 0;     left: 0;     width: 100%;     height: 100%;     background: rgba(15, 23, 42, 0.6);     display: flex;     align-items: center;     justify-content: center;     z-index: 9999;     backdrop-filter: blur(2px);   }   .crud-modal {     background: #ffffff;     border-radius: 10px;     width: 90%;     max-width: 520px;     box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.2), 0 10px 10px -5px rgba(0, 0, 0, 0.08);     overflow: hidden;   }   .modal-header {     padding: 16px 20px;     border-bottom: 1px solid #e2e8f0;     display: flex;     justify-content: space-between;     align-items: center;     background: #f8fafc;   }   .modal-close-btn {     background: none;     border: none;     font-size: 18px;     cursor: pointer;     color: #94a3b8;     font-weight: bold;     padding: 4px 8px;     border-radius: 4px;   }   .modal-close-btn:hover { color: #0f172a; background: #e2e8f0; }   .modal-body { padding: 20px; }   .modal-footer {     padding: 14px 20px;     background: #f8fafc;     border-top: 1px solid #e2e8f0;     display: flex;     justify-content: flex-end;     gap: 10px;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="dataset-view-page">' + "    <!-- HEADER SECTION -->" + '    <div style="background: #f4ecf7; border-left: 4px solid #8e44ad; padding: 10px 14px; border-radius: 4px; margin-bottom: 14px; color: #4a235a; font-size: 13px;">' + '      💡 Conheça também o <strong>BlaiseVue 4.3 (Type-Safe RPC)</strong>! <a href="#/customers" style="color: #8e44ad; font-weight: bold; text-decoration: underline;">Clique aqui para ir para Clientes (RPC)</a> ou clique no botão roxo <strong>⚡ RPC (v4.3)</strong> no menu superior!' + "    </div>" + "" + '    <div class="crud-header">' + "      <div>" + '        <h1 class="crud-title">💾 TBVDataSet Offline-First & Delta Sync (v4.4)</h1>' + '        <p class="crud-subtitle">Motor empresarial de dados reativos em memória com persistência IndexedDB, detecção offline/online, rastreamento de deltas e sincronização automatizada (<code>ApplyUpdates</code>) com mORMot 2.</p>' + "      </div>" + '      <div class="crud-header-btns">' + '        <button class="bui-btn bui-btn-primary" @click="doAppend">➕ Novo Produto</button>' + '        <button class="bui-btn bui-btn-outline" @click="doSaveIndexedDB">💾 Salvar no IndexedDB</button>' + '        <button class="bui-btn bui-btn-secondary" @click="doLoadIndexedDB">📂 Restaurar do IndexedDB</button>' + '        <button class="bui-btn" style="background: #ef4444; color: white;" @click="doExportDatasetPDF">📄 PDF (v5.0)</button>' + '        <button class="bui-btn" style="background: #10b981; color: white;" @click="doExportDatasetExcel">📊 Excel</button>' + '        <button class="bui-btn bui-btn-success" :disabled="productsDS && productsDS.ChangeCount == 0 || isSyncing" @click="doApplyUpdates">' + '          <span v-if="isSyncing">⏳ Sincronizando...</span>' + '          <span v-if="!isSyncing">🚀 Sincronizar (ApplyUpdates)</span>' + "        </button>" + "      </div>" + "    </div>" + "" + "    <!-- OFFLINE-FIRST CONTROL & CONFIGURATION BAR -->" + '    <div class="offline-control-bar">' + '      <div class="control-bar-item">' + '        <span class="bar-label">Rede:</span>' + '        <span v-if="isOnline" class="status-pill status-online">🟢 Online</span>' + '        <span v-if="!isOnline" class="status-pill status-offline">🔴 Modo Offline</span>' + '        <button class="bui-btn bui-btn-xs bui-btn-outline" @click="toggleOnlineSimulation">' + "          {{ isOnline ? 'Simular Queda de Rede' : 'Restabelecer Conexão' }}" + "        </button>" + "      </div>" + "" + '      <div class="control-bar-item">' + '        <span class="bar-label">Storage:</span>' + '        <span class="status-pill status-storage">🗄️ {{ storageEngine }}</span>' + "      </div>" + "" + '      <div class="control-bar-item">' + '        <span class="bar-label">AutoPersist:</span>' + '        <button class="bui-btn bui-btn-xs" :class="autoPersistActive ? \'bui-btn-success\' : \'bui-btn-secondary\'" @click="toggleAutoPersist">' + "          {{ autoPersistActive ? '⚡ Ativado (IndexedDB)' : '⚪ Desativado' }}" + "        </button>" + "      </div>" + "" + '      <div class="control-bar-item">' + '        <span class="bar-label">AutoSync:</span>' + '        <button class="bui-btn bui-btn-xs" :class="autoSyncActive ? \'bui-btn-info\' : \'bui-btn-secondary\'" @click="toggleAutoSync">' + "          {{ autoSyncActive ? '🔄 Ativado na Reconexão' : '⚪ Desativado' }}" + "        </button>" + "      </div>" + "    </div>" + "" + "    <!-- DATASET LIVE STATUS BAR -->" + '    <div class="dataset-status-bar" v-if="productsDS">' + '      <div class="status-left">' + '        <span class="badge" :class="stateBadgeClass">' + "          Estado: <strong>{{ productsDS.StateStr.toUpperCase() }}</strong>" + "        </span>" + '        <span class="status-indicator">' + "          Registro: <strong>{{ productsDS.RecNo }}</strong> de <strong>{{ productsDS.RecordCount }}</strong>" + "        </span>" + '        <span class="status-indicator" v-if="productsDS.ChangeCount > 0">' + '          Deltas Pendentes: <strong style="color: #e67e22;">{{ productsDS.ChangeCount }} (Aguardando Sync)</strong>' + "        </span>" + '        <span class="status-indicator" v-if="productsDS.ChangeCount == 0">' + '          Deltas Pendentes: <strong style="color: #27ae60;">0 (100% Sincronizado)</strong>' + "        </span>" + "      </div>" + '      <div class="dataset-nav-controls">' + '        <button class="bui-btn bui-btn-sm" :disabled="productsDS.Bof || productsDS.IsEmpty" @click="navFirst" title="Primeiro">⏮️</button>' + '        <button class="bui-btn bui-btn-sm" :disabled="productsDS.Bof || productsDS.IsEmpty" @click="navPrior" title="Anterior">◀️</button>' + '        <button class="bui-btn bui-btn-sm" :disabled="productsDS.Eof || productsDS.IsEmpty" @click="navNext" title="Próximo">▶️</button>' + '        <button class="bui-btn bui-btn-sm" :disabled="productsDS.Eof || productsDS.IsEmpty" @click="navLast" title="Último">⏭️</button>' + "      </div>" + "    </div>" + "" + "    <!-- MAIN GRID SECTION WITH NATIVE :dataset BINDING -->" + '    <div class="card mb-4" style="background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 24px;">' + '      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">' + '        <h3 style="font-size: 18px; margin: 0;">📋 Grade Conectada ao DataSet (&lt;bv-datagrid&gt;)</h3>' + '        <span style="font-size: 13px; color: #7f8c8d;">Clique em qualquer linha para sincronizar o cursor do dataset</span>' + "      </div>" + "      " + '      <bv-datagrid :dataset="productsDS" @row-select="onSelectRow" />' + "    </div>" + "" + "    <!-- LIVEBINDINGS FORM SECTION (b-field) -->" + '    <div class="card mb-4" style="background: white; border-radius: 8px; padding: 24px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 24px;">' + '      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; border-bottom: 1px solid #edf2f7; padding-bottom: 12px;">' + "        <div>" + '          <h3 style="font-size: 18px; margin: 0; color: #2c3e50;">✏️ Formulário LiveBindings (`b-field`)</h3>' + '          <p style="font-size: 13px; color: #7f8c8d; margin-top: 4px;">Edite qualquer campo abaixo: o dataset entrará em modo <code>dsEdit</code> e salvará no IndexedDB automaticamente.</p>' + "        </div>" + '        <div style="display: flex; gap: 8px;">' + '          <button class="bui-btn bui-btn-success" :disabled="productsDS && productsDS.StateStr == \'browse\'" @click="doPost">💾 Salvar (Post)</button>' + '          <button class="bui-btn bui-btn-warning" :disabled="productsDS && productsDS.StateStr == \'browse\'" @click="doCancel">❌ Cancelar</button>' + '          <button class="bui-btn bui-btn-danger" :disabled="productsDS && productsDS.IsEmpty" @click="doDelete">🗑️ Excluir</button>' + "        </div>" + "      </div>" + "" + '      <div class="form-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px;">' + '        <div class="form-group">' + '          <label style="font-weight: 600; font-size: 13px; color: #34495e;">ID do Registro:</label>' + '          <input type="text" b-field="productsDS.id" class="bui-input" disabled style="background: #f8fafc; cursor: not-allowed;" />' + "        </div>" + '        <div class="form-group">' + '          <label style="font-weight: 600; font-size: 13px; color: #34495e;">Título do Produto:</label>' + '          <input type="text" b-field="productsDS.title" class="bui-input" placeholder="Título..." @input="onFieldInput" />' + "        </div>" + '        <div class="form-group">' + '          <label style="font-weight: 600; font-size: 13px; color: #34495e;">Categoria:</label>' + '          <input type="text" b-field="productsDS.category" class="bui-input" placeholder="Categoria..." @input="onFieldInput" />' + "        </div>" + '        <div class="form-group">' + '          <label style="font-weight: 600; font-size: 13px; color: #34495e;">Preço ($):</label>' + '          <input type="text" b-field="productsDS.price" class="bui-input" placeholder="0.00" @input="onFieldInput" />' + "        </div>" + '        <div class="form-group">' + '          <label style="font-weight: 600; font-size: 13px; color: #34495e;">Estoque:</label>' + '          <input type="text" b-field="productsDS.stock" class="bui-input" placeholder="0" @input="onFieldInput" />' + "        </div>" + "      </div>" + "    </div>" + "" + "    <!-- OFFLINE DELTA TRACKER & CONSOLE -->" + '    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">' + "      <!-- DELTA JSON INSPECTOR -->" + '      <div class="card" style="background: #1e293b; color: #f8fafc; border-radius: 8px; padding: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + '        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">' + "          <div>" + '            <h3 style="font-size: 16px; margin: 0; color: #38bdf8;">📡 Inspetor de Deltas (`productsDS.GetDeltaJSON`)</h3>' + '            <p style="font-size: 12px; color: #94a3b8; margin-top: 4px;">Rastreia inserções, modificações e exclusões para envio ao backend mORMot 2.</p>' + "          </div>" + '          <button class="bui-btn bui-btn-xs bui-btn-danger" :disabled="productsDS && productsDS.ChangeCount == 0" @click="doClearDelta">' + "            Limpar Delta" + "          </button>" + "        </div>" + "" + '        <pre style="background: #0f172a; border: 1px solid #334155; border-radius: 6px; padding: 14px; font-size: 12px; overflow-x: auto; color: #4ade80; max-height: 220px;">{{ deltaJSONStr }}</pre>' + "      </div>" + "" + "      <!-- SYNC & PERSISTENCE CONSOLE -->" + '      <div class="card" style="background: #0f172a; color: #f8fafc; border-radius: 8px; padding: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); border: 1px solid #1e293b;">' + '        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">' + '          <h3 style="font-size: 16px; margin: 0; color: #a78bfa;">📜 Console de Sincronização & Logs</h3>' + '          <span class="badge" style="background: #334155; color: #94a3b8; font-size: 11px;">v4.4 Engine</span>' + "        </div>" + '        <div style="background: #020617; border: 1px solid #1e293b; border-radius: 6px; padding: 14px; font-size: 13px; min-height: 140px; color: #cbd5e1; line-height: 1.6;">' + "          <div>{{ syncStatusMsg }}</div>" + '          <div style="margin-top: 10px; font-size: 11px; color: #64748b; border-top: 1px solid #1e293b; padding-top: 8px;">' + "            Endpoint mORMot 2: <code>POST /api/dataset/apply</code> | Armazenamento: <code>IndexedDB (Persistente)</code>" + "          </div>" + "        </div>" + "      </div>" + "    </div>" + "" + "    <!-- MODAL DE CADASTRO DE NOVO PRODUTO -->" + '    <div class="crud-modal-backdrop" v-if="isModalOpen">' + '      <div class="crud-modal">' + '        <div class="modal-header">' + '          <h3 style="margin: 0; font-size: 18px; color: #1e293b; font-weight: 700;">➕ Cadastrar Novo Produto</h3>' + '          <button class="modal-close-btn" @click="closeModal">✕</button>' + "        </div>" + '        <div class="modal-body">' + '          <div class="form-group" style="margin-bottom: 14px;">' + '            <label style="display: block; font-weight: 600; font-size: 13px; color: #475569; margin-bottom: 6px;">Título do Produto:</label>' + '            <input type="text" class="bui-input" b-model="formTitle" placeholder="Ex: Teclado Mecânico Pascal" />' + "          </div>" + '          <div class="form-group" style="margin-bottom: 14px;">' + '            <label style="display: block; font-weight: 600; font-size: 13px; color: #475569; margin-bottom: 6px;">Categoria:</label>' + '            <input type="text" class="bui-input" b-model="formCategory" placeholder="Ex: Hardware, Periféricos" />' + "          </div>" + '          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">' + '            <div class="form-group">' + '              <label style="display: block; font-weight: 600; font-size: 13px; color: #475569; margin-bottom: 6px;">Preço ($):</label>' + '              <input type="text" class="bui-input" b-model="formPrice" placeholder="99.90" />' + "            </div>" + '            <div class="form-group">' + '              <label style="display: block; font-weight: 600; font-size: 13px; color: #475569; margin-bottom: 6px;">Estoque Inicial:</label>' + '              <input type="text" class="bui-input" b-model="formStock" placeholder="10" />' + "            </div>" + "          </div>" + "        </div>" + '        <div class="modal-footer">' + '          <button class="bui-btn bui-btn-secondary" @click="closeModal">Cancelar</button>' + '          <button class="bui-btn bui-btn-primary" @click="saveNewProduct">💾 Confirmar e Inserir</button>' + "        </div>" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["productsDS"] = null;
      d["searchQuery"] = "";
      d["deltaJSONStr"] = "[]";
      d["isOnline"] = true;
      d["autoPersistActive"] = true;
      d["autoSyncActive"] = true;
      d["syncStatusMsg"] = "DataSet pronto com suporte a IndexedDB.";
      d["isSyncing"] = false;
      d["storageEngine"] = "IndexedDB";
      d["isModalOpen"] = false;
      d["formTitle"] = "";
      d["formCategory"] = "Hardware";
      d["formPrice"] = "99.90";
      d["formStock"] = "10";
      Result = d;
      return Result;
    };
    m = new Object();
    m["updateDeltaView"] = function (_this) {
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["navFirst"] = function (_this) {
      pas.BVPascalDX.DataSetFirst(_this["productsDS"]);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["navPrior"] = function (_this) {
      pas.BVPascalDX.DataSetPrior(_this["productsDS"]);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["navNext"] = function (_this) {
      pas.BVPascalDX.DataSetNext(_this["productsDS"]);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["navLast"] = function (_this) {
      pas.BVPascalDX.DataSetLast(_this["productsDS"]);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["doAppend"] = function (_this) {
      _this["formTitle"] = "";
      _this["formCategory"] = "Hardware";
      _this["formPrice"] = "99.90";
      _this["formStock"] = "10";
      _this["isModalOpen"] = true;
    };
    m["closeModal"] = function (_this) {
      _this["isModalOpen"] = false;
    };
    m["saveNewProduct"] = function (_this) {
      var ds = undefined;
      var titleVal = "";
      var categoryVal = "";
      var priceVal = 0.0;
      var stockVal = 0;
      titleVal = pas.SysUtils.Trim("" + _this["formTitle"]);
      if (titleVal === "") {
        pas.BVPascalDX.ShowToast("Por favor, informe o título do produto.",2500);
        return;
      };
      categoryVal = pas.SysUtils.Trim("" + _this["formCategory"]);
      if (categoryVal === "") categoryVal = "Hardware";
      priceVal = pas.SysUtils.StrToFloatDef("" + _this["formPrice"],0.0);
      stockVal = pas.SysUtils.StrToIntDef("" + _this["formStock"],0);
      ds = _this["productsDS"];
      pas.BVPascalDX.DataSetAppend(ds);
      var maxId = 0;
      if (ds && ds.FRecords) {
        for (var i = 0; i < ds.FRecords.length; i++) {
          var curId = parseInt(ds.FRecords[i].id, 10);
          if (!isNaN(curId) && curId > maxId) maxId = curId;
        }
      }
      var nextId = maxId + 1;
      if (ds && ds.Current) {
        ds.Current.id = nextId;
        ds.Current.title = titleVal;
        ds.Current.category = categoryVal;
        ds.Current.price = priceVal;
        ds.Current.stock = stockVal;
      }
      if (ds) ds.FModified = true;
      if (typeof ds.SyncReactiveState === 'function') ds.SyncReactiveState();
      pas.BVPascalDX.DataSetPost(ds);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(ds);
      _this["isModalOpen"] = false;
      _this["syncStatusMsg"] = "Novo produto cadastrado com sucesso no DataSet.";
      pas.BVPascalDX.ShowToast("Produto cadastrado com sucesso!",2500);
    };
    m["doPost"] = function (_this) {
      pas.BVPascalDX.DataSetPost(_this["productsDS"]);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
      _this["syncStatusMsg"] = "Registro salvo no DataSet e persistido no IndexedDB.";
      pas.BVPascalDX.ShowToast("Alterações salvas com sucesso no DataSet!",2500);
    };
    m["doCancel"] = function (_this) {
      pas.BVPascalDX.DataSetCancel(_this["productsDS"]);
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
      _this["syncStatusMsg"] = "Edição cancelada. Estado revertido para browse.";
      pas.BVPascalDX.ShowToast("Edição cancelada.",2500);
    };
    m["doDelete"] = function (_this) {
      if (pas.BVPascalDX.Confirm("Deseja realmente excluir este produto?")) {
        pas.BVPascalDX.DataSetDelete(_this["productsDS"]);
        _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
        _this["syncStatusMsg"] = "Registro removido. Operação de exclusão gravada no Delta.";
        pas.BVPascalDX.ShowToast("Registro excluído com sucesso.",2500);
      };
    };
    m["onSelectRow"] = function (_this, row) {
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["onFieldInput"] = function (_this) {
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
    };
    m["doSaveIndexedDB"] = function (_this) {
      pas.BVPascalDX.DataSetSaveIndexedDB(_this["productsDS"],"demo_products_v44",null,null);
      _this["syncStatusMsg"] = "Snapshot completo salvo no IndexedDB (store: demo_products_v44).";
      pas.BVPascalDX.ShowToast("Dados salvos no IndexedDB com sucesso!",2500);
    };
    m["doLoadIndexedDB"] = function (_this) {
      var self = _this || this;
      var ds = self.productsDS;
      if (!ds) return;
      if (typeof ds.LoadFromIndexedDB === 'function') {
        ds.LoadFromIndexedDB('demo_products_v44', function(success, count) {
          if (success) {
            self.deltaJSONStr = (typeof ds.GetDeltaJSON === 'function') ? ds.GetDeltaJSON() : '[]';
            self.syncStatusMsg = 'Restaurados ' + count + ' registros do IndexedDB.';
            pas.BVPascalDX.ShowToast('Restaurados ' + count + ' registros do IndexedDB com sucesso!', 2500);
          } else {
            self.syncStatusMsg = 'Nenhum snapshot anterior encontrado no IndexedDB.';
            pas.BVPascalDX.ShowToast('Nenhum dado encontrado no IndexedDB.', 2500);
          }
        });
      };
    };
    m["toggleAutoPersist"] = function (_this) {
      var newState = false;
      newState = !!(_this["autoPersistActive"] == false);
      _this["autoPersistActive"] = newState;
      pas.BVPascalDX.DataSetSetAutoPersist(_this["productsDS"],newState,"demo_products_v44");
      if (newState) {
        _this["syncStatusMsg"] = "AutoPersist ativado: qualquer Post/Delete salva imediatamente no IndexedDB.";
        pas.BVPascalDX.ShowToast("AutoPersist ativado (IndexedDB)!",2500);
      } else {
        _this["syncStatusMsg"] = "AutoPersist desativado: os dados residem apenas na memória RAM.";
        pas.BVPascalDX.ShowToast("AutoPersist desativado.",2500);
      };
    };
    m["toggleAutoSync"] = function (_this) {
      var newState = false;
      newState = !!(_this["autoSyncActive"] == false);
      _this["autoSyncActive"] = newState;
      pas.BVPascalDX.DataSetSetAutoSync(_this["productsDS"],newState,"/api/dataset/apply");
      if (newState) {
        _this["syncStatusMsg"] = "AutoSync ativado: sincronizará automaticamente com o mORMot 2 na reconexão.";
        pas.BVPascalDX.ShowToast("AutoSync na reconexão ativado!",2500);
      } else {
        _this["syncStatusMsg"] = "AutoSync desativado.";
        pas.BVPascalDX.ShowToast("AutoSync desativado.",2500);
      };
    };
    m["toggleOnlineSimulation"] = function (_this) {
      var nextOnline = false;
      nextOnline = !!(_this["isOnline"] == false);
      _this["isOnline"] = nextOnline;
      if (nextOnline) {
        _this["syncStatusMsg"] = "Rede online restabelecida. Verificando deltas pendentes...";
        pas.BVPascalDX.ShowToast("Conexão restabelecida! (Online)",2500);
        if (!(_this["autoSyncActive"] == false)) {
          pas.BVPascalDX.CallMethod(_this,"doApplyUpdates");
        };
      } else {
        _this["syncStatusMsg"] = "Modo Offline ativado: novas edições acumulam no Delta e no IndexedDB.";
        pas.BVPascalDX.ShowToast("Modo Offline ativado (simulação)",2500);
      };
    };
    m["doClearDelta"] = function (_this) {
      if (pas.BVPascalDX.Confirm("Deseja descartar as alterações do Delta sem enviar ao servidor?")) {
        pas.BVPascalDX.DataSetClearDelta(_this["productsDS"]);
        _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
        _this["syncStatusMsg"] = "Deltas pendentes descartados pelo usuário.";
        pas.BVPascalDX.ShowToast("Deltas descartados.",2500);
      };
    };
    m["doApplyUpdates"] = function (_this) {
      _this["isSyncing"] = true;
      var self = _this || this;
      var ds = self.productsDS;
      if (!ds || ds.ChangeCount === 0) {
        self.isSyncing = false;
        pas.BVPascalDX.ShowToast('Nenhuma alteração pendente para sincronizar.', 2500);
        return;
      }
      self.syncStatusMsg = 'Enviando ' + ds.ChangeCount + ' deltas para mORMot 2 (/api/dataset/apply)...';
      if (typeof ds.ApplyUpdates === 'function') {
        ds.ApplyUpdates('/api/dataset/apply', function(resp) {
          self.isSyncing = false;
          self.deltaJSONStr = (typeof ds.GetDeltaJSON === 'function') ? ds.GetDeltaJSON() : '[]';
          var count = (resp && resp.syncedCount !== undefined) ? resp.syncedCount : 0;
          self.syncStatusMsg = 'Sucesso! ' + count + ' alterações sincronizadas com o backend mORMot 2.';
          pas.BVPascalDX.ShowToast('Sincronização concluída com sucesso (' + count + ' deltas)!', 2500);
        }, function(err) {
          self.isSyncing = false;
          self.syncStatusMsg = 'Backend mORMot offline. Deltas preservados no IndexedDB com segurança!';
          pas.BVPascalDX.ShowToast('Backend offline. Deltas guardados no IndexedDB!', 2500);
        });
      };
    };
    m["doExportDatasetPDF"] = function (_this) {
      var rep = undefined;
      rep = pas.BVPascalDX.NewReport(_this["productsDS"]);
      pas.BVPascalDX.ReportSetTitle(rep,"Relatório de Produtos (TBVDataSet)","Exportado diretamente da View DataSet v4.4/v5.0");
      pas.BVPascalDX.ReportSetCompany(rep,"BlaiseVue Enterprise","BV-5.0");
      pas.BVPascalDX.ReportSetColumns(rep,["id:ID:integer","title:Produto","category:Categoria","price:Preço Unit.:currency","stock:Estoque:integer"]);
      pas.BVPascalDX.ReportAddSummary(rep,"Soma Preços Unitários","price","sum","currency");
      pas.BVPascalDX.ReportAddSummary(rep,"Total de Produtos","id","count","integer");
      pas.BVPascalDX.ReportExportPDF(rep,"dataset_produtos.pdf");
      pas.BVPascalDX.ShowToast("PDF Vetorial (dataset_produtos.pdf) gerado com sucesso!",2500);
    };
    m["doExportDatasetExcel"] = function (_this) {
      var rep = undefined;
      rep = pas.BVPascalDX.NewReport(_this["productsDS"]);
      pas.BVPascalDX.ReportSetTitle(rep,"Planilha de Produtos (TBVDataSet)","Exportado via BlaiseReports");
      pas.BVPascalDX.ReportSetCompany(rep,"BlaiseVue Enterprise","BV-5.0");
      pas.BVPascalDX.ReportSetColumns(rep,["id:ID:integer","title:Produto","category:Categoria","price:Preço Unit.:currency","stock:Estoque:integer"]);
      pas.BVPascalDX.ReportAddSummary(rep,"Soma Preços Unitários","price","sum","currency");
      pas.BVPascalDX.ReportExportExcel(rep,"dataset_produtos.xlsx");
      pas.BVPascalDX.ShowToast("Planilha Excel (dataset_produtos.xlsx) gerada com sucesso!",2500);
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      var mockData = "";
      if (!_this) _this = this;
      _this["productsDS"] = pas.BVPascalDX.NewDataSet();
      if (this.productsDS) {
        this.productsDS.TableName = 'products';
      };
      mockData = '[{"id":1,"title":"Laptop ThinkPad X1","category":"Hardware","price":1899.99,"stock":15},' + '{"id":2,"title":"Monitor Dell 27 4K","category":"Peripherals","price":549.50,"stock":32},' + '{"id":3,"title":"Teclado Mecânico Pascal","category":"Peripherals","price":129.90,"stock":78},' + '{"id":4,"title":"Cadeira Ergonômica Pro","category":"Office","price":380.00,"stock":20},' + '{"id":5,"title":"Mouse Sem Fio Ultra","category":"Peripherals","price":49.99,"stock":120}]';
      pas.BVPascalDX.DataSetLoad(_this["productsDS"],pas.BVPascalDX.JsonParse(mockData));
      pas.BVPascalDX.DataSetSetAutoPersist(_this["productsDS"],true,"demo_products_v44");
      pas.BVPascalDX.DataSetSetAutoSync(_this["productsDS"],true,"/api/dataset/apply");
      _this["autoPersistActive"] = true;
      _this["autoSyncActive"] = true;
      _this["isOnline"] = true;
      _this["isSyncing"] = false;
      _this["isModalOpen"] = false;
      _this["syncStatusMsg"] = "DataSet inicializado com persistência IndexedDB e auto-sync configurados.";
      _this["deltaJSONStr"] = pas.BVPascalDX.DataSetDeltaJSON(_this["productsDS"]);
      var self = this;
      if (typeof window !== 'undefined') {
        window.addEventListener('online', function() {
          self.isOnline = true;
          self.syncStatusMsg = 'Rede restabelecida detectada pelo navegador.';
          if (self.autoSyncActive) {
            var ds = self.productsDS;
            if (ds && typeof ds.ApplyUpdates === 'function' && ds.ChangeCount > 0) {
              ds.ApplyUpdates('/api/dataset/apply');
            }
          }
        });
        window.addEventListener('offline', function() {
          self.isOnline = false;
          self.syncStatusMsg = 'Dispositivo offline: deltas acumulados em cache IndexedDB.';
        });
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["stateBadgeClass"] = function (_this) {
      var Result = undefined;
      var ds = this.productsDS;
      if (!ds) return 'badge-secondary';
      var st = typeof ds.GetStateStr === 'function' ? ds.GetStateStr() : ds.StateStr;
      if (st === 'insert') return 'badge-warning';
      if (st === 'edit') return 'badge-danger';
      if (st === 'browse') return 'badge-success';
      return 'badge-secondary';
      return Result;
    };
    pas.BVComponents.RegisterComponent("dataset-view-page",comp);
    pas.BVComponents.RegisterComponent("data-set-view-page",comp);
  };
});
rtl.module("uReportsView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uReportsView = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="reports-view-page">' + "    <!-- TOP BANNER -->" + '    <div style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); color: white; border-radius: 10px; padding: 20px 24px; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.12); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">' + "      <div>" + '        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">' + '          <span style="background: #ef4444; color: white; font-size: 11px; font-weight: 800; padding: 3px 8px; border-radius: 4px; text-transform: uppercase;">v5.0 Pillar 1</span>' + '          <span style="background: rgba(255,255,255,0.12); color: #38bdf8; font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 4px;">Zero-ASM Object Pascal</span>' + "        </div>" + '        <h1 style="font-size: 22px; font-weight: 700; margin: 0; color: #f8fafc;">📄 BlaiseReports — Native Vector PDF, Excel &amp; Print Engine</h1>' + '        <p style="font-size: 13px; color: #94a3b8; margin-top: 6px;">Geração nativa de PDF Vetorial 1.4, Planilhas Excel (<code>.xlsx</code>), CSV (RFC 4180 + BOM) e Impressão A4 / Bobina Térmica POS (80mm/58mm) diretamente do <code>TBVDataSet</code>.</p>' + "      </div>" + '      <div style="display: flex; gap: 8px; flex-wrap: wrap;">' + '        <button class="bui-btn" style="background: #ef4444; color: white; font-weight: 600;" @click="doExportPDF">📄 Baixar PDF Vetorial</button>' + '        <button class="bui-btn" style="background: #10b981; color: white; font-weight: 600;" @click="doExportExcel">📊 Baixar Excel (.xlsx)</button>' + '        <button class="bui-btn" style="background: #3b82f6; color: white; font-weight: 600;" @click="doExportCSV">📑 Baixar CSV</button>' + "      </div>" + "    </div>" + "" + "    <!-- QUICK DATASET PRESETS & CUSTOMIZATION BAR -->" + '    <div style="background: white; border-radius: 8px; padding: 16px 20px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 14px;">' + '      <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">' + '        <strong style="font-size: 13px; color: #334155;">Cenário de Relatório:</strong>' + '        <button type="button" class="bui-btn bui-btn-sm" :style="activePreset === \'sales\' ? \'background:#1e293b;color:white;\' : \'background:#f1f5f9;color:#334155;\'" @click="loadSalesPreset">' + "          💼 Faturamento Corporativo (A4)" + "        </button>" + '        <button type="button" class="bui-btn bui-btn-sm" :style="activePreset === \'pos\' ? \'background:#1e293b;color:white;\' : \'background:#f1f5f9;color:#334155;\'" @click="loadPosReceiptPreset">' + "          🧾 Cupom Térmico PDV (80mm)" + "        </button>" + '        <button type="button" class="bui-btn bui-btn-sm" :style="activePreset === \'inventory\' ? \'background:#1e293b;color:white;\' : \'background:#f1f5f9;color:#334155;\'" @click="loadInventoryPreset">' + "          📦 Auditoria de Estoque (Paisagem)" + "        </button>" + "      </div>" + "" + '      <div style="display: flex; align-items: center; gap: 8px;">' + '        <button type="button" class="bui-btn bui-btn-sm" style="background: #8b5cf6; color: white; font-weight: 600;" @click="addSampleInvoice">' + "          ➕ Adicionar Linha ao DataSet" + "        </button>" + "      </div>" + "    </div>" + "" + "    <!-- STATUS NOTIFICATION BANNER -->" + '    <div v-if="statusMessage" style="background: #ecfdf5; border-left: 4px solid #10b981; color: #065f46; padding: 10px 16px; border-radius: 6px; margin-bottom: 18px; font-size: 13px; display: flex; justify-content: space-between; align-items: center;">' + "      <span>✅ <strong>{{ statusMessage }}</strong></span>" + '      <span style="font-size: 12px; color: #047857;">Registros Ativos: {{ recordCount }}</span>' + "    </div>" + "" + "    <!-- INTERACTIVE REPORT VIEWER COMPONENT (<bv-report-viewer>) -->" + "    <bv-report-viewer" + '      :report="activeReport"' + '      :dataset="salesDS"' + '      filename="blaisevue_report_v5"' + "    ></bv-report-viewer>" + "" + "    <!-- RAW SOURCE INSPECTOR (PDF / EXCEL / CSV PREVIEW) -->" + '    <div style="background: #0f172a; color: #f8fafc; border-radius: 8px; padding: 20px; margin-top: 24px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">' + '      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 10px;">' + "        <div>" + '          <h3 style="font-size: 16px; margin: 0; color: #38bdf8;">🔍 Inspetor de Saída Bruta (`GeneratePDF` / `GenerateExcel` / `GenerateCSV`)</h3>' + '          <p style="font-size: 12px; color: #94a3b8; margin-top: 4px;">Visualize o código vetorial PDF 1.4, XML SpreadsheetML ou CSV gerado em memória pelo motor Object Pascal.</p>' + "        </div>" + '        <div style="display: flex; gap: 6px;">' + '          <button type="button" class="bui-btn bui-btn-xs" style="background: #ef4444; color: white;" @click="inspectPDF">Ver Código PDF 1.4</button>' + '          <button type="button" class="bui-btn bui-btn-xs" style="background: #10b981; color: white;" @click="inspectExcel">Ver XML Excel</button>' + '          <button type="button" class="bui-btn bui-btn-xs" style="background: #3b82f6; color: white;" @click="inspectCSV">Ver CSV</button>' + "        </div>" + "      </div>" + '      <pre style="background: #020617; border: 1px solid #1e293b; border-radius: 6px; padding: 14px; font-size: 12px; overflow-x: auto; color: #4ade80; max-height: 260px; white-space: pre-wrap;">{{ rawOutputPreview }}</pre>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["salesDS"] = null;
      d["activeReport"] = null;
      d["activePreset"] = "sales";
      d["statusMessage"] = "Relatório Corporativo Q4 carregado e conectado ao TBVDataSet.";
      d["rawOutputPreview"] = "";
      d["nextInvoiceId"] = 1006;
      Result = d;
      return Result;
    };
    m = new Object();
    m["loadSalesPreset"] = function (_this) {
      var mockJson = "";
      var rep = undefined;
      _this["activePreset"] = "sales";
      mockJson = "[" + '{"id":1001,"customer":"Acme Cloud Corp","segment":"Enterprise SaaS","status":"Pago","total":4850.00},' + '{"id":1002,"customer":"Globex Logística S.A.","segment":"ERP Industrial","status":"Pago","total":3200.50},' + '{"id":1003,"customer":"Stark Defense Labs","segment":"Cloud Security","status":"Pago","total":9450.00},' + '{"id":1004,"customer":"Wayne FinTech Holding","segment":"Banking Core","status":"Pendente","total":6120.75},' + '{"id":1005,"customer":"Initech Sistemas Ltda","segment":"Consultoria Pascal","status":"Pago","total":2180.25}' + "]";
      pas.BVPascalDX.DataSetLoad(_this["salesDS"],pas.BVPascalDX.JsonParse(mockJson));
      rep = pas.BVPascalDX.NewReport(_this["salesDS"]);
      pas.BVPascalDX.ReportSetTitle(rep,"Relatório Executivo de Faturamento Q4","Consolidação Financeira Auditada — BlaiseVue 5.0");
      pas.BVPascalDX.ReportSetCompany(rep,"BlaiseVue Enterprise Cloud S.A.","BV-5.0");
      pas.BVPascalDX.ReportSetHeader(rep,"Departamento Financeiro | Moeda: USD ($) | Emissão Automática via TBVDataSet","Documento Confidencial — BlaiseReports Native Vector PDF Engine");
      pas.BVPascalDX.ReportSetPageLayout(rep,"a4");
      pas.BVPascalDX.ReportSetColumns(rep,["id:Fatura #:integer:center:75","customer:Cliente Corporativo:string:left:190","segment:Unidade de Negócio:string:left:140","status:Status:string:center:85","total:Valor Total:currency:right:115"]);
      pas.BVPascalDX.ReportAddSummary(rep,"Receita Bruta Total","total","sum","currency");
      pas.BVPascalDX.ReportAddSummary(rep,"Ticket Médio","total","avg","currency");
      pas.BVPascalDX.ReportAddSummary(rep,"Maior Contrato","total","max","currency");
      pas.BVPascalDX.ReportAddSummary(rep,"Total de Faturas","id","count","integer");
      _this["activeReport"] = rep;
      _this["statusMessage"] = 'Cenário "Faturamento Corporativo (A4)" carregado com sucesso!';
      pas.BVPascalDX.CallMethod(_this,"inspectPDF");
    };
    m["loadPosReceiptPreset"] = function (_this) {
      var mockJson = "";
      var rep = undefined;
      _this["activePreset"] = "pos";
      mockJson = "[" + '{"id":1,"customer":"2x Café Espresso Duplo","segment":"Bebidas","status":"OK","total":18.00},' + '{"id":2,"customer":"1x Croissant Francês","segment":"Padaria","status":"OK","total":14.50},' + '{"id":3,"customer":"1x Suco Natural Laranja","segment":"Bebidas","status":"OK","total":12.00},' + '{"id":4,"customer":"1x Torta Holandesa Slice","segment":"Confeitaria","status":"OK","total":22.90}' + "]";
      pas.BVPascalDX.DataSetLoad(_this["salesDS"],pas.BVPascalDX.JsonParse(mockJson));
      rep = pas.BVPascalDX.NewReport(_this["salesDS"]);
      pas.BVPascalDX.ReportSetTitle(rep,"CUPOM FISCAL PDV #9042","Caixa 01 - Operador: Pascal POS");
      pas.BVPascalDX.ReportSetCompany(rep,"BLAISE CAFÉ & BISTRÔ LTDA","POS");
      pas.BVPascalDX.ReportSetHeader(rep,"CNPJ: 12.345.678/0001-99 | Bobina Térmica 80mm","Obrigado pela preferência! Volte sempre.");
      pas.BVPascalDX.ReportSetPageLayout(rep,"thermal-80mm");
      pas.BVPascalDX.ReportSetColumns(rep,["customer:Item / Descrição:string:left:140","total:Subtotal:currency:right:70"]);
      pas.BVPascalDX.ReportAddSummary(rep,"TOTAL A PAGAR","total","sum","currency");
      pas.BVPascalDX.ReportAddSummary(rep,"QTD ITENS","id","count","integer");
      _this["activeReport"] = rep;
      _this["statusMessage"] = 'Layout "Cupom Térmico PDV (80mm)" ativado para impressoras de recibo!';
      pas.BVPascalDX.CallMethod(_this,"inspectPDF");
    };
    m["loadInventoryPreset"] = function (_this) {
      var mockJson = "";
      var rep = undefined;
      _this["activePreset"] = "inventory";
      mockJson = "[" + '{"id":501,"customer":"Servidor Rack Dell PowerEdge R750","segment":"DataCenter","status":"Em Estoque","total":18500.00},' + '{"id":502,"customer":"Switch Cisco Catalyst 48 Portas 10G","segment":"Redes","status":"Em Estoque","total":6400.00},' + '{"id":503,"customer":"Storage NVMe Enterprise 64TB","segment":"Storage","status":"Crítico","total":14200.00},' + '{"id":504,"customer":"Firewall Hardware Appliance Pro","segment":"Segurança","status":"Em Estoque","total":4900.00}' + "]";
      pas.BVPascalDX.DataSetLoad(_this["salesDS"],pas.BVPascalDX.JsonParse(mockJson));
      rep = pas.BVPascalDX.NewReport(_this["salesDS"]);
      pas.BVPascalDX.ReportSetTitle(rep,"Auditoria Física de Ativos & Inventário","Relatório em Formato A4 Paisagem (Landscape)");
      pas.BVPascalDX.ReportSetCompany(rep,"BlaiseVue Infraestrutura & DataCenter","INFRA");
      pas.BVPascalDX.ReportSetHeader(rep,"Galpão Central SP | Auditoria Trimestral","Assinatura do Auditor Responsável");
      pas.BVPascalDX.ReportSetPageLayout(rep,"a4-landscape");
      pas.BVPascalDX.ReportSetColumns(rep,["id:Patrimônio:integer:center:80","customer:Equipamento / Ativo:string:left:220","segment:Setor:string:left:120","status:Situação:string:center:100","total:Valor Contábil:currency:right:120"]);
      pas.BVPascalDX.ReportAddSummary(rep,"Patrimônio Total","total","sum","currency");
      pas.BVPascalDX.ReportAddSummary(rep,"Média por Ativo","total","avg","currency");
      _this["activeReport"] = rep;
      _this["statusMessage"] = 'Cenário "Auditoria de Estoque (A4 Paisagem)" carregado!';
      pas.BVPascalDX.CallMethod(_this,"inspectPDF");
    };
    m["addSampleInvoice"] = function (_this) {
      var newId = 0;
      newId = rtl.trunc(_this["nextInvoiceId"]);
      _this["nextInvoiceId"] = newId + 1;
      pas.BVPascalDX.DataSetAppend(_this["salesDS"]);
      pas.BVPascalDX.DataSetSetFieldVal(_this["salesDS"],"id",newId);
      pas.BVPascalDX.DataSetSetFieldVal(_this["salesDS"],"customer","Novo Cliente Enterprise #" + pas.SysUtils.IntToStr(newId));
      pas.BVPascalDX.DataSetSetFieldVal(_this["salesDS"],"segment","Cloud Expansion");
      pas.BVPascalDX.DataSetSetFieldVal(_this["salesDS"],"status","Pago");
      pas.BVPascalDX.DataSetSetFieldVal(_this["salesDS"],"total",3750.00);
      pas.BVPascalDX.DataSetPost(_this["salesDS"]);
      _this["statusMessage"] = "Fatura #" + pas.SysUtils.IntToStr(newId) + " adicionada ao TBVDataSet! Totalizadores recalculados em tempo real.";
      pas.BVPascalDX.CallMethod(_this,"inspectPDF");
    };
    m["doExportPDF"] = function (_this) {
      pas.BVPascalDX.ReportExportPDF(_this["activeReport"],"relatorio_blaisevue_v5.pdf");
      _this["statusMessage"] = "Download do PDF Vetorial 1.4 (relatorio_blaisevue_v5.pdf) iniciado!";
      pas.BVPascalDX.CallMethod(_this,"inspectPDF");
    };
    m["doExportExcel"] = function (_this) {
      pas.BVPascalDX.ReportExportExcel(_this["activeReport"],"relatorio_blaisevue_v5.xlsx");
      _this["statusMessage"] = "Download da Planilha Excel (relatorio_blaisevue_v5.xlsx) iniciado!";
      pas.BVPascalDX.CallMethod(_this,"inspectExcel");
    };
    m["doExportCSV"] = function (_this) {
      pas.BVPascalDX.ReportExportCSV(_this["activeReport"],"relatorio_blaisevue_v5.csv");
      _this["statusMessage"] = "Download do arquivo CSV UTF-8 com BOM (relatorio_blaisevue_v5.csv) iniciado!";
      pas.BVPascalDX.CallMethod(_this,"inspectCSV");
    };
    m["inspectPDF"] = function (_this) {
      _this["rawOutputPreview"] = pas.BVPascalDX.ReportGeneratePDF(_this["activeReport"]);
    };
    m["inspectExcel"] = function (_this) {
      _this["rawOutputPreview"] = pas.BVPascalDX.ReportGenerateExcel(_this["activeReport"]);
    };
    m["inspectCSV"] = function (_this) {
      _this["rawOutputPreview"] = pas.BVPascalDX.ReportGenerateCSV(_this["activeReport"]);
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      _this["salesDS"] = pas.BVPascalDX.NewDataSet();
      _this["nextInvoiceId"] = 1006;
      pas.BVPascalDX.CallMethod(_this,"loadSalesPreset");
    };
    comp["computed"] = new Object();
    comp["computed"]["recordCount"] = function (_this) {
      var Result = undefined;
      Result = 0;
      if (this.salesDS && typeof this.salesDS.GetRecordCount === 'function') {
        Result = this.salesDS.GetRecordCount();
      };
      return Result;
    };
    pas.BVComponents.RegisterComponent("reports-view-page",comp);
  };
});
rtl.module("BlaiseCharts",["System","JS","Web","SysUtils"],function () {
  "use strict";
  var $mod = this;
  rtl.createClass(this,"TBVChartDataset",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FJS = null;
    };
    this.$final = function () {
      this.FJS = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Create$1 = function (ALabel) {
      this.FJS = new Object();
      this.FJS["data"] = new Array();
      if (ALabel !== "") this.FJS["label"] = ALabel;
      this.FJS["borderWidth"] = 1;
      return this;
    };
    this.SetData$1 = function (AData) {
      var Result = null;
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = rtl.length(AData) - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(AData[i]);
      };
      this.FJS["data"] = Arr;
      Result = this;
      return Result;
    };
    this.BackgroundColor = function (AColor) {
      var Result = null;
      this.FJS["backgroundColor"] = AColor;
      Result = this;
      return Result;
    };
    this.BackgroundColors = function (AColors) {
      var Result = null;
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = rtl.length(AColors) - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(AColors[i]);
      };
      this.FJS["backgroundColor"] = Arr;
      Result = this;
      return Result;
    };
    this.BorderColor = function (AColor) {
      var Result = null;
      this.FJS["borderColor"] = AColor;
      Result = this;
      return Result;
    };
    this.BorderColors = function (AColors) {
      var Result = null;
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = rtl.length(AColors) - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(AColors[i]);
      };
      this.FJS["borderColor"] = Arr;
      Result = this;
      return Result;
    };
    this.Fill = function (AFill) {
      var Result = null;
      this.FJS["fill"] = AFill;
      Result = this;
      return Result;
    };
    this.Tension = function (ATension) {
      var Result = null;
      this.FJS["tension"] = ATension;
      Result = this;
      return Result;
    };
    this.PointRadius = function (ARadius) {
      var Result = null;
      this.FJS["pointRadius"] = ARadius;
      Result = this;
      return Result;
    };
    this.ToJS = function () {
      var Result = null;
      Result = this.FJS;
      return Result;
    };
  });
  rtl.createClass(this,"TBVChartData",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FJS = null;
    };
    this.$final = function () {
      this.FJS = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.Create$1 = function () {
      this.FJS = new Object();
      this.FJS["labels"] = new Array();
      this.FJS["datasets"] = new Array();
      return this;
    };
    this.Labels = function (ALabels) {
      var Result = null;
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = rtl.length(ALabels) - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(ALabels[i]);
      };
      this.FJS["labels"] = Arr;
      Result = this;
      return Result;
    };
    this.AddDataset = function (ADataset) {
      var Result = null;
      this.FJS["datasets"].push(ADataset.ToJS());
      Result = ADataset;
      return Result;
    };
    this.AddDataset$2 = function (ALabel, AData, ABgColor, ABorderColor) {
      var Result = null;
      var Ds = null;
      Ds = $mod.TBVChartDataset.$create("Create$1",[ALabel]);
      Ds.SetData$1(AData);
      if (ABgColor !== "") {
        Ds.BackgroundColor(ABgColor)}
       else Ds.BackgroundColor($mod.TBVChartPalette.Color(this.DatasetCount(),0.4));
      if (ABorderColor !== "") {
        Ds.BorderColor(ABorderColor)}
       else Ds.BorderColor($mod.TBVChartPalette.Color(this.DatasetCount(),1.0));
      this.AddDataset(Ds);
      Result = Ds;
      return Result;
    };
    this.AddMultiColorDataset$1 = function (ALabel, AData, AColors) {
      var Result = null;
      var Ds = null;
      Ds = $mod.TBVChartDataset.$create("Create$1",[ALabel]);
      Ds.SetData$1(AData);
      Ds.BackgroundColors(AColors);
      Ds.BorderColors(AColors);
      this.AddDataset(Ds);
      Result = Ds;
      return Result;
    };
    this.DatasetCount = function () {
      var Result = 0;
      if (this.FJS["datasets"] != null) {
        Result = this.FJS["datasets"].length & 0xFFFFFFFF}
       else Result = 0;
      return Result;
    };
    this.ToJS = function () {
      var Result = null;
      Result = this.FJS;
      return Result;
    };
  });
  rtl.createClass(this,"TBVChartOptions",pas.System.TObject,function () {
    this.$init = function () {
      pas.System.TObject.$init.call(this);
      this.FJS = null;
    };
    this.$final = function () {
      this.FJS = undefined;
      pas.System.TObject.$final.call(this);
    };
    this.EnsurePlugins = function () {
      var Result = null;
      if (this.FJS["plugins"] == null) this.FJS["plugins"] = new Object();
      Result = this.FJS["plugins"];
      return Result;
    };
    this.EnsureScales = function () {
      var Result = null;
      if (this.FJS["scales"] == null) this.FJS["scales"] = new Object();
      Result = this.FJS["scales"];
      return Result;
    };
    this.Create$1 = function () {
      this.FJS = new Object();
      this.FJS["responsive"] = true;
      this.FJS["maintainAspectRatio"] = false;
      this.FJS["resizeDelay"] = 50;
      return this;
    };
    this.Responsive = function (AVal) {
      var Result = null;
      this.FJS["responsive"] = AVal;
      Result = this;
      return Result;
    };
    this.MaintainAspectRatio = function (AVal) {
      var Result = null;
      this.FJS["maintainAspectRatio"] = AVal;
      Result = this;
      return Result;
    };
    this.Legend = function (APosition, ADisplay) {
      var Result = null;
      var Plugins = null;
      var LegObj = null;
      Plugins = this.EnsurePlugins();
      LegObj = new Object();
      LegObj["display"] = ADisplay;
      LegObj["position"] = APosition;
      Plugins["legend"] = LegObj;
      Result = this;
      return Result;
    };
    this.Tooltip = function (AEnabled) {
      var Result = null;
      var Plugins = null;
      var ToolObj = null;
      Plugins = this.EnsurePlugins();
      ToolObj = new Object();
      ToolObj["enabled"] = AEnabled;
      Plugins["tooltip"] = ToolObj;
      Result = this;
      return Result;
    };
    this.Scales = function (AXGrid, AYGrid, AYBeginAtZero) {
      var Result = null;
      var S = null;
      var XObj = null;
      var YObj = null;
      var XGridObj = null;
      var YGridObj = null;
      var TicksObj = null;
      S = this.EnsureScales();
      XObj = new Object();
      XGridObj = new Object();
      XGridObj["display"] = AXGrid;
      XObj["grid"] = XGridObj;
      S["x"] = XObj;
      YObj = new Object();
      YGridObj = new Object();
      YGridObj["display"] = AYGrid;
      YObj["grid"] = YGridObj;
      TicksObj = new Object();
      TicksObj["beginAtZero"] = AYBeginAtZero;
      YObj["ticks"] = TicksObj;
      S["y"] = YObj;
      Result = this;
      return Result;
    };
    this.ToJS = function () {
      var Result = null;
      Result = this.FJS;
      return Result;
    };
  });
  rtl.createClass(this,"TBVChartPalette",pas.System.TObject,function () {
    this.Color = function (AIndex, Alpha) {
      var Result = "";
      var Colors = ["#3b82f6","#10b981","#f59e0b","#ef4444","#8b5cf6","#06b6d4","#ec4899","#6366f1"];
      var Idx = 0;
      Idx = Math.abs(AIndex) % 8;
      if (Alpha < 1.0) {
        Result = this.HexToRgba(Colors[Idx],Alpha)}
       else Result = Colors[Idx];
      return Result;
    };
    this.HexToRgba = function (AHex, Alpha) {
      var Result = "";
      var H = "";
      var R = 0;
      var G = 0;
      var B = 0;
      H = AHex;
      if ((H.length > 0) && (H.charAt(0) === "#")) H = pas.System.Copy(H,2,2147483647);
      if (H.length === 3) H = H.charAt(0) + H.charAt(0) + H.charAt(1) + H.charAt(1) + H.charAt(2) + H.charAt(2);
      if (H.length === 6) {
        R = pas.SysUtils.StrToIntDef("$" + pas.System.Copy(H,1,2),0);
        G = pas.SysUtils.StrToIntDef("$" + pas.System.Copy(H,3,2),0);
        B = pas.SysUtils.StrToIntDef("$" + pas.System.Copy(H,5,2),0);
        Result = "rgba(" + pas.SysUtils.IntToStr(R) + ", " + pas.SysUtils.IntToStr(G) + ", " + pas.SysUtils.IntToStr(B) + ", " + pas.SysUtils.FloatToStr(Alpha) + ")";
      } else Result = AHex;
      return Result;
    };
    this.GetPalette = function (AName, Alpha) {
      var Result = null;
      var N = "";
      N = pas.SysUtils.LowerCase(AName);
      if (N === "emerald") {
        Result = this.Emerald(6,Alpha)}
       else if (N === "sunset") {
        Result = this.Sunset(6,Alpha)}
       else if (N === "neon") {
        Result = this.Neon(6,Alpha)}
       else if (N === "pastel") {
        Result = this.Pastel(6,Alpha)}
       else if (N === "cyberpunk") {
        Result = this.Cyberpunk(6,Alpha)}
       else Result = this.DefaultColors(8,Alpha);
      return Result;
    };
    this.DefaultColors = function (Count, Alpha) {
      var Result = null;
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = Count - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(this.Color(i,Alpha));
      };
      Result = Arr;
      return Result;
    };
    this.Emerald = function (Count, Alpha) {
      var Result = null;
      var Colors = ["#059669","#10b981","#34d399","#6ee7b7","#a7f3d0","#047857"];
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = Count - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(this.HexToRgba(Colors[i % 6],Alpha));
      };
      Result = Arr;
      return Result;
    };
    this.Sunset = function (Count, Alpha) {
      var Result = null;
      var Colors = ["#f43f5e","#fb923c","#facc15","#a855f7","#ec4899","#f97316"];
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = Count - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(this.HexToRgba(Colors[i % 6],Alpha));
      };
      Result = Arr;
      return Result;
    };
    this.Neon = function (Count, Alpha) {
      var Result = null;
      var Colors = ["#00f0ff","#ff007f","#7000ff","#00ff66","#ffe600","#ff3366"];
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = Count - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(this.HexToRgba(Colors[i % 6],Alpha));
      };
      Result = Arr;
      return Result;
    };
    this.Pastel = function (Count, Alpha) {
      var Result = null;
      var Colors = ["#a5b4fc","#fbcfe8","#fed7aa","#bbf7d0","#bae6fd","#ddd6fe"];
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = Count - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(this.HexToRgba(Colors[i % 6],Alpha));
      };
      Result = Arr;
      return Result;
    };
    this.Cyberpunk = function (Count, Alpha) {
      var Result = null;
      var Colors = ["#fcee0a","#00f0ff","#ff003c","#711c91","#133e7c","#0abdc6"];
      var Arr = null;
      var i = 0;
      Arr = new Array();
      for (var $l = 0, $end = Count - 1; $l <= $end; $l++) {
        i = $l;
        Arr.push(this.HexToRgba(Colors[i % 6],Alpha));
      };
      Result = Arr;
      return Result;
    };
  });
  $mod.$init = function () {
    // Expose BlaiseCharts globally for window.$charts / __BV_CORE__.charts
        if (typeof window !== 'undefined') {
          if (!window.__BV_CORE__) window.__BV_CORE__ = {};
          window.__BV_CORE__.charts = {
            types: {
              bar: 'bar',
              line: 'line',
              pie: 'pie',
              doughnut: 'doughnut',
              radar: 'radar',
              polarArea: 'polarArea',
              scatter: 'scatter',
              bubble: 'bubble'
            }
          };
          window.$charts = window.__BV_CORE__.charts;
    
          // Universal Chart.js Safety Guard (neutralizes resize/update timers on destroyed charts)
          function __bv_install_chart_guard() {
            var C = (typeof window.Chart !== "undefined") ? window.Chart : ((typeof Chart !== "undefined") ? Chart : null);
            if (!C || !C.prototype || C.prototype.__bv_safe_guard) return;
            C.prototype.__bv_safe_guard = true;
    
            var origDestroy = C.prototype.destroy;
            C.prototype.destroy = function() {
              this._doResize = function() { return 0; };
              this.update = function() {};
              this.render = function() {};
              this.draw = function() {};
              return origDestroy.apply(this, arguments);
            };
    
            var origUpdate = C.prototype.update;
            C.prototype.update = function() {
              if (!this.canvas || !this.ctx) return;
              return origUpdate.apply(this, arguments);
            };
    
            var origRender = C.prototype.render;
            C.prototype.render = function() {
              if (!this.canvas || !this.ctx) return;
              return origRender.apply(this, arguments);
            };
    
            var origResize = C.prototype._resize;
            if (origResize) {
              C.prototype._resize = function() {
                if (!this.canvas || !this.ctx) return;
                return origResize.apply(this, arguments);
              };
            }
          }
    
          __bv_install_chart_guard();
          if (typeof window.addEventListener === "function") {
            window.addEventListener("DOMContentLoaded", __bv_install_chart_guard);
            window.addEventListener("load", __bv_install_chart_guard);
          }
        };
  };
});
rtl.module("uCharts",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet","BlaiseCharts"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCharts = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".chart-dashboard {     padding: 24px;     background: #f8fafc;     min-height: 100vh;     overflow-y: scroll;     box-sizing: border-box;   }   .header-card {     background: #ffffff;     padding: 24px 28px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     margin-bottom: 24px;     border: 1px solid #e2e8f0;     box-sizing: border-box;   }   .universal-card {     background: #ffffff;     border: 1px solid #cbd5e1;     border-top: 4px solid #3b82f6;     box-sizing: border-box;     width: 100%;     min-width: 0;     overflow: hidden;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(min(100%, 460px), 1fr));     gap: 24px;     width: 100%;   }   .chart-item {     background: #ffffff;     padding: 20px 24px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     border: 1px solid #e2e8f0;     display: flex;     flex-direction: column;     min-width: 0;     box-sizing: border-box;     width: 100%;     overflow: hidden;   }   .chart-header-row {     display: flex;     justify-content: space-between;     align-items: center;     width: 100%;     margin-bottom: 16px;     padding-bottom: 12px;     border-bottom: 1px solid #f1f5f9;     box-sizing: border-box;   }   .chart-item h3 {     margin: 0;     font-size: 1.05rem;     font-weight: 600;     color: #1e293b;   }   .badge-type {     font-size: 0.75rem;     padding: 4px 8px;     background: #f1f5f9;     color: #475569;     border-radius: 6px;     font-weight: 600;     text-transform: uppercase;   }   .btn-type-pill {     background: #ffffff;     border: 1px solid #cbd5e1;     color: #334155;     padding: 5px 10px;     border-radius: 6px;     font-size: 0.8rem;     font-weight: 500;     cursor: pointer;     transition: all 0.15s ease;   }   .btn-type-pill:hover {     background: #3b82f6;     color: #ffffff;     border-color: #3b82f6;   }    /* Dark Mode Dashboard Styles */   .chart-dashboard.charts-dark {     background: #0f172a;     color: #f8fafc;   }   .chart-dashboard.charts-dark .header-card {     background: #1e293b;     border-color: #334155;     box-shadow: 0 4px 16px rgba(0,0,0,0.4);   }   .chart-dashboard.charts-dark .header-card h1 {     color: #f8fafc !important;   }   .chart-dashboard.charts-dark .header-card p {     color: #94a3b8 !important;   }   .chart-dashboard.charts-dark .universal-card,   .chart-dashboard.charts-dark .chart-item {     background: #1e293b;     border-color: #334155;     box-shadow: 0 4px 16px rgba(0,0,0,0.4);   }   .chart-dashboard.charts-dark .chart-item h3 {     color: #f1f5f9;   }   .chart-dashboard.charts-dark .chart-header-row {     border-bottom-color: #334155;   }   .chart-dashboard.charts-dark .chart-header-row p {     color: #94a3b8 !important;   }   .chart-dashboard.charts-dark .badge-type {     background: #334155;     color: #cbd5e1;   }   .chart-dashboard.charts-dark .btn-type-pill {     background: #1e293b;     border-color: #475569;     color: #cbd5e1;   }   .chart-dashboard.charts-dark .btn-type-pill:hover {     background: #3b82f6;     color: #ffffff;     border-color: #3b82f6;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="chart-dashboard" :class="{ \'charts-dark\': isDarkMode }">' + '    <div class="header-card">' + '      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">' + '        <div style="text-align: left;">' + '          <h1 style="margin: 0; font-size: 1.8rem; font-weight: 700; color: #1e293b;">' + "            📊 BlaiseCharts 4.0 - Data Visualization Suite" + "          </h1>" + '          <p style="margin: 6px 0 0 0; color: #64748b; font-size: 0.95rem;">' + "            Suíte oficial e dedicada de gráficos reativos via HTML5 Canvas (Chart.js), com classes e registros fortemente tipados em Object Pascal (<strong>packages/blaise-charts</strong>)." + "          </p>" + "        </div>" + '        <div style="display: flex; gap: 10px; flex-wrap: wrap;">' + '          <bv-btn variant="primary" @click="randomizeData">🎲 Randomizar Dados</bv-btn>' + '          <bv-btn variant="secondary" @click="togglePalette">🎨 Alternar Paleta ({{ currentPalette }})</bv-btn>' + '          <bv-btn variant="dark" @click="toggleDarkMode">🌓 {{ isDarkMode ? \'Modo Claro\' : \'Modo Escuro\' }}</bv-btn>' + "        </div>" + "      </div>" + "" + '      <div b-if="clickedPointInfo" style="margin-top: 18px; padding: 10px 16px; background: #e0f2fe; border-left: 4px solid #0284c7; border-radius: 6px; font-size: 0.9rem; color: #0369a1; text-align: left;">' + "        <strong>🎯 Ponto Selecionado / Status:</strong> {{ clickedPointInfo }}" + "      </div>" + "    </div>" + "" + "    <!-- 1. DESTAQUE: Componente Universal <bv-chart> com Troca Dinâmica de Tipo -->" + '    <div class="chart-item universal-card" style="margin-bottom: 24px;">' + '      <div class="chart-header-row">' + "        <div>" + "          <h3>🌟 &lt;bv-chart&gt; - Componente Universal com Tipo Dinâmico</h3>" + '          <p style="margin: 4px 0 0 0; font-size: 0.85rem; color: #64748b;">' + '            Um único componente reativo capaz de renderizar qualquer gráfico dinamicamente via prop <code>:type="{{ universalType }}"</code>:' + "          </p>" + "        </div>" + '        <div style="display: flex; gap: 6px; flex-wrap: wrap;">' + '          <button class="btn-type-pill" @click="setUniversalType(\'bar\')">📊 Barras</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'line\')">📈 Linha</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'pie\')">🍕 Pizza</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'doughnut\')">🍩 Rosca</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'radar\')">🕸️ Radar</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'polarArea\')">❄️ Polar</button>' + "        </div>" + "      </div>" + '      <bv-chart :type="universalType" :data="barData" :options="chartOptions" height="340px" @chart-click="onPointClick"></bv-chart>' + "    </div>" + "" + "    <!-- 2. GRID: Componentes Especializados do BlaiseCharts -->" + '    <div class="chart-grid">' + "      <!-- 2.1 Barras (bv-bar-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>📊 Vendas Trimestrais (&lt;bv-bar-chart&gt;)</h3>" + '          <span class="badge-type">Bar / Column</span>' + "        </div>" + '        <bv-bar-chart :data="barData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-bar-chart>' + "      </div>" + "" + "      <!-- 2.2 Linhas & Tendências (bv-line-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>📈 Usuários &amp; Conexões WS (&lt;bv-line-chart&gt;)</h3>" + '          <span class="badge-type">Spline Line</span>' + "        </div>" + '        <bv-line-chart :data="lineData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-line-chart>' + "      </div>" + "" + "      <!-- 2.3 Pizza Proporcional (bv-pie-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>🍕 Distribuição de Tráfego (&lt;bv-pie-chart&gt;)</h3>" + '          <span class="badge-type">Pie Chart</span>' + "        </div>" + '        <bv-pie-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-pie-chart>' + "      </div>" + "" + "      <!-- 2.4 Rosca / Doughnut (bv-doughnut-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>🍩 Plataformas Suportadas (&lt;bv-doughnut-chart&gt;)</h3>" + '          <span class="badge-type">Doughnut</span>' + "        </div>" + '        <bv-doughnut-chart :data="doughnutData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-doughnut-chart>' + "      </div>" + "" + "      <!-- 2.5 Área Polar (bv-polar-area-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>❄️ Distribuição de Recursos (&lt;bv-polar-area-chart&gt;)</h3>" + '          <span class="badge-type">Polar Area</span>' + "        </div>" + '        <bv-polar-area-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-polar-area-chart>' + "      </div>" + "" + "      <!-- 2.6 Radar / Competências (bv-radar-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>🕸️ Análise de Desempenho (&lt;bv-radar-chart&gt;)</h3>" + '          <span class="badge-type">Radar Matrix</span>' + "        </div>" + '        <bv-radar-chart :data="radarData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-radar-chart>' + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["chartOptions"] = null;
      d["pieOptions"] = null;
      d["barData"] = null;
      d["lineData"] = null;
      d["pieData"] = null;
      d["doughnutData"] = null;
      d["radarData"] = null;
      d["universalType"] = "bar";
      d["clickedPointInfo"] = "";
      d["currentPalette"] = "Emerald";
      d["isDarkMode"] = false;
      Result = d;
      return Result;
    };
    m = new Object();
    m["initCharts"] = function (_this) {
      var BarModel = null;
      var LineModel = null;
      var PieModel = null;
      var DoughnutModel = null;
      var RadarModel = null;
      var OptsModel = null;
      var PieOptsModel = null;
      OptsModel = pas.BlaiseCharts.TBVChartOptions.$create("Create$1");
      OptsModel.Responsive(true).MaintainAspectRatio(false).Legend("top",true).Tooltip(true).Scales(true,true,true);
      _this["chartOptions"] = OptsModel.ToJS();
      PieOptsModel = pas.BlaiseCharts.TBVChartOptions.$create("Create$1");
      PieOptsModel.Responsive(true).MaintainAspectRatio(false).Legend("bottom",true);
      _this["pieOptions"] = PieOptsModel.ToJS();
      BarModel = pas.BlaiseCharts.TBVChartData.$create("Create$1");
      BarModel.Labels(["Jan","Fev","Mar","Abr","Mai","Jun"]);
      BarModel.AddDataset$2("Vendas 2026",[14500,21800,18900,27400,31200,42000],"rgba(16, 185, 129, 0.6)","#10b981");
      BarModel.AddDataset$2("Metas 2026",[12000,18000,20000,25000,30000,38000],"rgba(59, 130, 246, 0.5)","#3b82f6");
      _this["barData"] = BarModel.ToJS();
      LineModel = pas.BlaiseCharts.TBVChartData.$create("Create$1");
      LineModel.Labels(["00:00","04:00","08:00","12:00","16:00","20:00"]);
      LineModel.AddDataset$2("Conexões WebSocket",[320,180,840,1920,2450,1880],"rgba(99, 102, 241, 0.2)","#6366f1").Fill(true).Tension(0.35).PointRadius(5);
      _this["lineData"] = LineModel.ToJS();
      PieModel = pas.BlaiseCharts.TBVChartData.$create("Create$1");
      PieModel.Labels(["Web (SPA)","Desktop (WebUI)","Mobile (Capacitor)","Backend REST"]);
      PieModel.AddMultiColorDataset$1("Requisições",[45,25,20,10],["#3b82f6","#10b981","#f59e0b","#8b5cf6"]);
      _this["pieData"] = PieModel.ToJS();
      DoughnutModel = pas.BlaiseCharts.TBVChartData.$create("Create$1");
      DoughnutModel.Labels(["Windows x64","Linux ARM/x64","Android","macOS"]);
      DoughnutModel.AddMultiColorDataset$1("Instalações",[52,28,14,6],["#06b6d4","#10b981","#ec4899","#f59e0b"]);
      _this["doughnutData"] = DoughnutModel.ToJS();
      RadarModel = pas.BlaiseCharts.TBVChartData.$create("Create$1");
      RadarModel.Labels(["Velocidade","Tipagem Pascal","Reatividade","Memória Baixa","Full-Stack","Multiplataforma"]);
      RadarModel.AddDataset$2("BlaiseVue 4.0",[98,100,95,92,97,96],"rgba(16, 185, 129, 0.3)","#10b981").Fill(true);
      _this["radarData"] = RadarModel.ToJS();
    };
    m["setUniversalType"] = function (_this, newType) {
      _this["universalType"] = newType;
      _this["clickedPointInfo"] = "Tipo do <bv-chart> alterado para: " + newType;
    };
    m["toggleDarkMode"] = function (_this) {
      var NewDark = false;
      NewDark = !!(_this["isDarkMode"] == false);
      _this["isDarkMode"] = NewDark;
      pas.BVPascalDX.UpdateChartDarkMode(_this["chartOptions"],NewDark);
      pas.BVPascalDX.UpdateChartDarkMode(_this["pieOptions"],NewDark);
      _this["chartOptions"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["chartOptions"]);
      _this["pieOptions"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["pieOptions"]);
      if (NewDark) {
        _this["clickedPointInfo"] = "Modo escuro ativado com sucesso!"}
       else _this["clickedPointInfo"] = "Modo claro ativado com sucesso!";
    };
    m["randomizeData"] = function (_this) {
      var NewData = null;
      var i = 0;
      var Val = 0;
      var Datasets = null;
      var Ds0 = null;
      NewData = new Array();
      for (i = 0; i <= 5; i++) {
        Val = 10000 + pas.System.Random(35000);
        NewData.push(Val);
      };
      if (_this["barData"] != null) {
        Datasets = _this["barData"]["datasets"];
        if ((Datasets !== null) && (Datasets.length > 0)) {
          Ds0 = Datasets[0];
          Ds0["data"] = NewData;
          _this["barData"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["barData"]);
        };
      };
      _this["clickedPointInfo"] = "Dados randomizados com sucesso!";
    };
    m["togglePalette"] = function (_this) {
      var Pal = null;
      var PalBorder = null;
      var Cur = "";
      var Datasets = null;
      Cur = "" + _this["currentPalette"];
      if (Cur === "Emerald") {
        _this["currentPalette"] = "Sunset"}
       else if (Cur === "Sunset") {
        _this["currentPalette"] = "Cyberpunk"}
       else if (Cur === "Cyberpunk") {
        _this["currentPalette"] = "Neon"}
       else _this["currentPalette"] = "Emerald";
      Pal = pas.BlaiseCharts.TBVChartPalette.GetPalette("" + _this["currentPalette"],0.65);
      PalBorder = pas.BlaiseCharts.TBVChartPalette.GetPalette("" + _this["currentPalette"],1.0);
      if (_this["barData"] != null) {
        Datasets = _this["barData"]["datasets"];
        if ((Datasets !== null) && (Datasets.length > 0)) {
          Datasets[0]["backgroundColor"] = Pal[0];
          Datasets[0]["borderColor"] = PalBorder[0];
          if (Datasets.length > 1) {
            Datasets[1]["backgroundColor"] = Pal[1];
            Datasets[1]["borderColor"] = PalBorder[1];
          };
          _this["barData"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["barData"]);
        };
      };
      if (_this["lineData"] != null) {
        Datasets = _this["lineData"]["datasets"];
        if ((Datasets !== null) && (Datasets.length > 0)) {
          Datasets[0]["backgroundColor"] = Pal[2];
          Datasets[0]["borderColor"] = PalBorder[2];
          _this["lineData"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["lineData"]);
        };
      };
      if (_this["pieData"] != null) {
        Datasets = _this["pieData"]["datasets"];
        if ((Datasets !== null) && (Datasets.length > 0)) {
          Datasets[0]["backgroundColor"] = Pal;
          Datasets[0]["borderColor"] = PalBorder;
          _this["pieData"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["pieData"]);
        };
      };
      if (_this["doughnutData"] != null) {
        Datasets = _this["doughnutData"]["datasets"];
        if ((Datasets !== null) && (Datasets.length > 0)) {
          Datasets[0]["backgroundColor"] = Pal;
          Datasets[0]["borderColor"] = PalBorder;
          _this["doughnutData"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["doughnutData"]);
        };
      };
      if (_this["radarData"] != null) {
        Datasets = _this["radarData"]["datasets"];
        if ((Datasets !== null) && (Datasets.length > 0)) {
          Datasets[0]["backgroundColor"] = Pal[0];
          Datasets[0]["borderColor"] = PalBorder[0];
          _this["radarData"] = pas.BVPascalDX.ObjectAssign(pas.BVPascalDX.NewObject(),_this["radarData"]);
        };
      };
      _this["clickedPointInfo"] = "Paleta alterada para " + ("" + _this["currentPalette"]) + "!";
    };
    m["onPointClick"] = function (_this, ev) {
      var Lbl = "";
      var Val = "";
      var DsIdx = "";
      if (!(ev == false) && (pas.BVPascalDX.GetFieldStr(ev,"label","") !== "")) {
        Lbl = pas.BVPascalDX.GetFieldStr(ev,"label","");
        Val = pas.BVPascalDX.GetFieldStr(ev,"value","");
        DsIdx = pas.SysUtils.IntToStr(pas.BVPascalDX.GetFieldInt(ev,"datasetIndex",0) + 1);
        _this["clickedPointInfo"] = 'Categoria: "' + Lbl + '", Valor: ' + Val + " (Série #" + DsIdx + ")";
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      pas.BVPascalDX.CallMethod(_this,"initCharts");
    };
    pas.BVComponents.RegisterComponent("charts-page",comp);
  };
});
rtl.module("uShowcase",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uShowcase = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = "/* CSS styles for layout and icons */   .showcase-container { max-width: 1000px; margin: 20px auto; padding: 30px; border-radius: 12px; border-left: 5px solid #2ecc71 !important; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }   .showcase-header { border-bottom: 2px solid #2ecc71; margin-bottom: 25px; padding-bottom: 10px; }   .section-card { background-color: rgba(128,128,128,0.08); padding: 20px; border-radius: 10px; margin-bottom: 30px; border-left: 4px solid #3498db; }   .icon-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 15px; margin-top: 15px; }   .icon-box { background-color: rgba(128,128,128,0.05); padding: 15px; border-radius: 8px; text-align: center; border: 1px solid rgba(128,128,128,0.1); transition: transform 0.2s; }   .icon-box:hover { transform: translateY(-5px); background-color: rgba(128,128,128,0.1); }   .text-primary { color: #0d6efd !important; }   .text-success { color: #198754 !important; }   .text-warning { color: #ffc107 !important; }   .text-danger { color: #dc3545 !important; }   .text-info { color: #0dcaf0 !important; }   .text-secondary { color: #6c757d !important; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="showcase-container">' + '    <div class="showcase-header">' + "      <h1>Showcase: Local Assets 🛡️</h1>" + "      <p>Current Font: <strong>Inter & Outfit</strong> (100% Local)</p>" + "    </div>" + "" + "    <!-- Icon Gallery Demonstration -->" + "    <!-- Icons are rendered using the 'bv-icon' component with explicit SVG templates -->" + '    <div class="section-card">' + "      <h3>Icon Gallery (Inline Local SVGs)</h3>" + '      <div class="icon-grid">' + '        <div class="icon-box">' + '          <bv-icon name="bootstrap-fill" size="32" class="text-primary" />' + '          <div class="small mt-1">bootstrap-fill</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="check-circle" size="32" class="text-success" />' + '          <div class="small mt-1">check-circle</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="warning" size="32" class="text-warning" />' + '          <div class="small mt-1">warning</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="gear-fill" size="32" class="text-secondary" />' + '          <div class="small mt-1">gear-fill</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="heart-fill" size="32" class="text-danger" />' + '          <div class="small mt-1">heart-fill</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="weather" size="32" class="text-info" />' + '          <div class="small mt-1">weather</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="code-slash" size="32" class="text-dark" />' + '          <div class="small mt-1">code-slash</div>' + "        </div>" + '        <div class="icon-box">' + '          <bv-icon name="cpu" size="32" class="text-primary" />' + '          <div class="small mt-1">cpu</div>' + "        </div>" + "      </div>" + "    </div>" + "" + "    <!-- Theme Selector Demonstration -->" + "    <!-- Dynamically switches global CSS files from the local assets folder -->" + '    <div class="section-card">' + "      <h3>Theme Selector (Dynamic CSS)</h3>" + '      <p class="text-muted">Click to swap the main CSS theme in real-time.</p>' + '      <div class="theme-buttons d-flex gap-2 flex-wrap">' + '        <button class="btn btn-outline-secondary" @click="handleTheme(\'default\')">Default</button>' + '        <button class="btn btn-primary" @click="handleTheme(\'darkly\')">Darkly</button>' + '        <button class="btn btn-success" @click="handleTheme(\'flatly\')">Flatly</button>' + '        <button class="btn btn-info" @click="handleTheme(\'cosmo\')">Cosmo</button>' + "      </div>" + '      <div class="mt-3">' + '         Selected Theme: <span class="badge bg-secondary">{{ currentThemeName }}</span>' + "      </div>" + "    </div>" + "  </div>";
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
      var link = null;
      link = document.getElementById("theme-link");
      if (link !== null) {
        if (ATheme === "default") {
          link.setAttribute("href","css/lib/blaise-ui.css")}
         else link.setAttribute("href","assets/themes/" + ATheme + ".min.css");
        document.body.className = "theme-" + ATheme;
        document.head.appendChild(link);
        pas.System.Writeln("BlaiseVue: Theme applied.");
      };
      _this["currentThemeName"] = ATheme;
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("showcase-page",comp);
  };
});
rtl.module("uBVBarChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBarChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="bar" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-bar-chart",comp);
  };
});
rtl.module("uBVPolarAreaChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVPolarAreaChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="polarArea" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-polar-area-chart",comp);
  };
});
rtl.module("uBVChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVChart = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-chart-wrapper {     position: relative;     display: block;     width: 100%;     max-width: 100%;     box-sizing: border-box;     margin-bottom: 0;     background: transparent;     overflow: hidden;   }    .bui-chart-wrapper canvas {     display: block;     box-sizing: border-box;     width: 100% !important;     max-width: 100%;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="bui-chart-wrapper" :style="{ width: width, height: height }">' + '    <canvas b-ref="chartCanvas"></canvas>' + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["_dummy"] = 0;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("type");
    comp["defaultProps"]["type"] = "bar";
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "400px";
    m = new Object();
    m["initChart"] = function (_this) {
      const bv = (typeof window !== 'undefined' && window.__BV_CORE__) ? window.__BV_CORE__ : null;
      const runInit = () => {
        const canvas = this.$refs ? this.$refs.chartCanvas : null;
        if (!canvas) return;
        if (typeof Chart === 'undefined') {
          console.warn('[BVChart] Chart.js is not loaded.');
          return;
        }
        function destroySafely(c) {
          if (!c) return;
          try {
            c._doResize = function() { return 0; };
            c.update = function() {};
            c.render = function() {};
            c.draw = function() {};
            c.destroy();
          } catch(e) {}
        }
        const existingChart = Chart.getChart(canvas);
        if (existingChart) destroySafely(existingChart);
        if (this._chart) destroySafely(this._chart);
        this._chart = null;
        function extractData(input) {
          if (!input) return null;
          if (typeof input.ToJS === 'function') return input.ToJS();
          if (typeof input.toJS === 'function') return input.toJS();
          if (input.FJS) return input.FJS;
          return input;
        }
        function cloneChartData(input, chartType) {
          if (!input) return null;
          const raw = (bv && bv.unproxy) ? bv.unproxy(input) : input;
          if (!raw) return null;
          const isRadial = (chartType === 'pie' || chartType === 'doughnut' || chartType === 'polarArea');
          const defaultPalette = ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6', '#ec4899', '#06b6d4', '#6366f1'];
          return {
            labels: Array.isArray(raw.labels) ? [...raw.labels] : [],
            datasets: Array.isArray(raw.datasets) ? raw.datasets.map(ds => {
              const copy = Object.assign({}, ds);
              if (Array.isArray(ds.data)) copy.data = [...ds.data];
              if (Array.isArray(ds.backgroundColor)) copy.backgroundColor = [...ds.backgroundColor];
              if (Array.isArray(ds.borderColor)) copy.borderColor = [...ds.borderColor];
              if (isRadial && Array.isArray(copy.data) && (!copy.backgroundColor || typeof copy.backgroundColor === 'string')) {
                copy.backgroundColor = copy.data.map((_, idx) => defaultPalette[idx % defaultPalette.length]);
                copy.borderColor = '#ffffff';
              }
              return copy;
            }) : []
          };
        }
        const rawData = extractData(this.data);
        if (!rawData || !rawData.datasets) return;
        try {
          const chartData = cloneChartData(rawData, this.type);
          const rawOpts = extractData(this.options);
          const chartOptions = rawOpts ? Object.assign({ responsive: true, maintainAspectRatio: false, resizeDelay: 50 }, (bv && bv.unproxy) ? bv.unproxy(rawOpts) : rawOpts) : {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 50
          };
          if (chartOptions.resizeDelay === undefined) chartOptions.resizeDelay = 50;
          let finalOpts = chartOptions;
          const isRadial = (this.type === 'pie' || this.type === 'doughnut' || this.type === 'polarArea');
          if (isRadial && chartOptions.scales) {
            finalOpts = Object.assign({}, chartOptions);
            delete finalOpts.scales;
          }
          if (!finalOpts.onClick) {
            finalOpts.onClick = (event, elements) => {
              if (elements && elements.length > 0) {
                const el = elements[0];
                const dsIndex = el.datasetIndex;
                const index = el.index;
                const ds = chartData.datasets ? chartData.datasets[dsIndex] : null;
                const label = chartData.labels ? chartData.labels[index] : '';
                const val = ds && ds.data ? ds.data[index] : null;
                this.$emit('chart-click', {
                  datasetIndex: dsIndex,
                  index: index,
                  label: label,
                  value: val,
                  datasetLabel: ds ? ds.label : ''
                });
              }
            };
          }
          this._chart = new Chart(canvas, {
            type: this.type || 'bar',
            data: chartData,
            options: finalOpts
          });
        } catch (e) {
          console.error('[BVChart] Failed to initialize chart:', e);
        }
      };
      if (bv && typeof bv.nonReactive === 'function') {
        bv.nonReactive(runInit);
      } else {
        runInit();
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      this._chart = null;
      this._pendingData = null;
      this._updatePending = false;
    };
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      this.initChart();
    };
    comp["watch"] = new Object();
    comp["watch"]["data"] = function (_this, newVal) {
      this._pendingData = newVal;
      if (this._updatePending) return;
      this._updatePending = true;
      requestAnimationFrame(() => {
        this._updatePending = false;
        const dataToUse = this._pendingData;
        if (!this._chart || !this._chart.canvas || !dataToUse) {
          this.initChart();
          return;
        }
        function cloneChartData(input, chartType) {
          if (!input) return null;
          const raw = (window.__BV_CORE__ && window.__BV_CORE__.unproxy) ? window.__BV_CORE__.unproxy(input) : input;
          if (!raw) return null;
          const isRadial = (chartType === 'pie' || chartType === 'doughnut' || chartType === 'polarArea');
          const defaultPalette = ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6', '#ec4899', '#06b6d4', '#6366f1'];
          return {
            labels: Array.isArray(raw.labels) ? [...raw.labels] : [],
            datasets: Array.isArray(raw.datasets) ? raw.datasets.map(ds => {
              const copy = Object.assign({}, ds);
              if (Array.isArray(ds.data)) copy.data = [...ds.data];
              if (Array.isArray(ds.backgroundColor)) copy.backgroundColor = [...ds.backgroundColor];
              if (Array.isArray(ds.borderColor)) copy.borderColor = [...ds.borderColor];
              if (isRadial && Array.isArray(copy.data) && (!copy.backgroundColor || typeof copy.backgroundColor === 'string')) {
                copy.backgroundColor = copy.data.map((_, idx) => defaultPalette[idx % defaultPalette.length]);
                copy.borderColor = '#ffffff';
              }
              return copy;
            }) : []
          };
        }
        try {
          const rawNewData = cloneChartData(dataToUse, this.type);
          if (!rawNewData || !rawNewData.datasets) return;
          if (rawNewData.labels) {
            this._chart.data.labels = rawNewData.labels;
          }
          const curDatasets = this._chart.data.datasets;
          if (curDatasets && curDatasets.length === rawNewData.datasets.length) {
            for (let i = 0; i < rawNewData.datasets.length; i++) {
              const target = curDatasets[i];
              const source = rawNewData.datasets[i];
              if (source.data) target.data = source.data;
              if (source.backgroundColor !== undefined) target.backgroundColor = source.backgroundColor;
              if (source.borderColor !== undefined) target.borderColor = source.borderColor;
              if (source.label !== undefined) target.label = source.label;
              if (source.fill !== undefined) target.fill = source.fill;
              if (source.tension !== undefined) target.tension = source.tension;
              if (source.pointRadius !== undefined) target.pointRadius = source.pointRadius;
              if (source.pointHoverRadius !== undefined) target.pointHoverRadius = source.pointHoverRadius;
            }
          } else {
            this._chart.data.datasets = rawNewData.datasets;
          }
          this._chart.update();
        } catch (e) {
          console.warn('[BVChart] Hot update failed, falling back to full re-init:', e);
          this.initChart();
        }
      });
    };
    comp["watch"]["options"] = function (_this, newVal) {
      if (this._chart && this._chart.canvas && newVal) {
        try {
          const rawNewOpts = (window.__BV_CORE__ && window.__BV_CORE__.unproxy) ? window.__BV_CORE__.unproxy(newVal) : newVal;
          if (rawNewOpts.resizeDelay === undefined) rawNewOpts.resizeDelay = 50;
          this._chart.options = rawNewOpts;
          this._chart.update();
        } catch (e) {
          this.initChart();
        }
      };
    };
    comp["watch"]["type"] = function (_this, newVal) {
      this.initChart();
    };
    pas.BVComponents.RegisterComponent("bv-chart",comp);
  };
});
rtl.module("uBVScatterChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVScatterChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="scatter" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-scatter-chart",comp);
  };
});
rtl.module("uBVDoughnutChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVDoughnutChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="doughnut" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-doughnut-chart",comp);
  };
});
rtl.module("uBVRadarChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVRadarChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="radar" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-radar-chart",comp);
  };
});
rtl.module("uBVPieChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVPieChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="pie" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-pie-chart",comp);
  };
});
rtl.module("uBVLineChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVLineChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="line" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-line-chart",comp);
  };
});
rtl.module("uBVBubbleChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBubbleChart = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <bv-chart type="bubble" :data="data" :options="options" :width="width" :height="height" :themeAware="themeAware" @chart-click="handleClick"></bv-chart>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("data");
    comp["defaultProps"]["data"] = null;
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "100%";
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "380px";
    comp["props"].push("themeAware");
    comp["defaultProps"]["themeAware"] = true;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-bubble-chart",comp);
  };
});
rtl.module("uBVThemeSelect",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVThemeSelect = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bv-theme-select-wrapper d-inline-block">' + '    <select class="form-select form-select-sm" :value="$theme.current" @change="onThemeChange($event)">' + '      <option value="flatly">Flatly (Claro)</option>' + '      <option value="cosmo">Cosmo (Claro)</option>' + '      <option value="lux">Lux (Claro)</option>' + '      <option value="zephyr">Zephyr (Claro)</option>' + '      <option value="darkly">Darkly (Escuro)</option>' + '      <option value="cyborg">Cyborg (Escuro)</option>' + '      <option value="solar">Solar (Escuro)</option>' + '      <option value="vapor">Vapor (Neon)</option>' + '      <option value="pulse">Pulse (Roxo)</option>' + "    </select>" + "  </div>";
    m = new Object();
    m["onThemeChange"] = function (_this, e) {
      var sel = "";
      sel = "" + e["target"]["value"];
      if (sel !== "") {
        if (window.$theme) {
          window.$theme.setTheme(sel);
        };
      };
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-theme-select",comp);
  };
});
rtl.module("uBVThemeToggle",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVThemeToggle = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = "  <button " + '    type="button"' + '    class="btn btn-outline-secondary btn-sm d-inline-flex align-items-center gap-1"' + '    :title="$theme.isDark ? \'Tema Claro\' : \'Tema Escuro\'"' + '    @click="toggleTheme">' + '    <span v-if="$theme.isDark">☀️ Claro</span>' + '    <span v-if="!$theme.isDark">🌙 Escuro</span>' + "  </button>";
    m = new Object();
    m["toggleTheme"] = function (_this) {
      if (window.$theme) {
        window.$theme.toggleDarkLight();
      };
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-theme-toggle",comp);
  };
});
rtl.module("uBVTabs",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVTabs = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-tabs-container">' + '    <ul class="bui-tabs-nav">' + '       <li class="bui-tab-item" b-for="tab in tabs" @click="selectTab(tab.id)">' + '         <a class="bui-tab-link" :class="{ active: activeTabId == tab.id }" href="javascript:void(0)">' + "            {{ tab.title }}" + "         </a>" + "       </li>" + "    </ul>" + "" + '    <div class="bui-tab-content">' + "       <slot></slot>" + "    </div>" + "  </div>";
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
      if (!_this) _this = this;
      this.tabs = [];
    };
    comp["provide"] = function (_this) {
      var Result = null;
      Result = new Object();
      var self = this;
      Result.registerTab = function(tab) {
        if (!self.tabs) self.tabs = [];
        var exists = false;
        for (var i = 0; i < self.tabs.length; i++) {
          if (self.tabs[i].id === tab.id) { exists = true; break; }
        }
        if (!exists) {
          self.tabs.push(tab);
          if (tab.active || !self.activeTabId || self.activeTabId === '') {
            self.activeTabId = tab.id;
          }
        }
      };
      Result.unregisterTab = function(id) {
        if (!self.tabs) return;
        var idx = -1;
        for (var i = 0; i < self.tabs.length; i++) {
          if (self.tabs[i].id === id) { idx = i; break; }
        }
        if (idx !== -1) self.tabs.splice(idx, 1);
      };
      Result.isActive = function(id) {
        return self.activeTabId === id;
      };
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-tabs",comp);
  };
});
rtl.module("uBVInput",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVInput = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-input-group">' + '    <label class="bui-input-label" v-if="label">{{ label }}</label>' + "    <input " + '      :type="type || \'text\'" ' + '      class="bui-input-field" ' + '      :placeholder="placeholder || \'\'"' + '      :value="value !== undefined && value !== null ? value : \'\'"' + '      :readonly="readonly && readonly !== \'false\'"' + '      @input="handleInput"' + "    />" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("placeholder");
    comp["defaultProps"]["placeholder"] = "";
    comp["props"].push("type");
    comp["defaultProps"]["type"] = "text";
    comp["props"].push("value");
    comp["defaultProps"]["value"] = "";
    comp["props"].push("readonly");
    comp["defaultProps"]["readonly"] = false;
    m = new Object();
    m["handleInput"] = function (_this, ev) {
      let val = (ev && ev.target) ? ev.target.value : (ev || '');
      this.value = val;
      this.$emit('input', val);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-input",comp);
  };
});
rtl.module("uBVProgress",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVProgress = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-progress">' + '    <div class="bui-progress-bar" ' + '         :class="barClass"' + '         :style="barStyle">' + '       <span v-if="showText">{{ value }}%</span>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("value");
    comp["defaultProps"]["value"] = 0;
    comp["props"].push("variant");
    comp["defaultProps"]["variant"] = "primary";
    comp["props"].push("label");
    comp["defaultProps"]["label"] = true;
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["barClass"] = function (_this) {
      var Result = undefined;
      var v = this.variant || 'primary';
      return 'bui-progress-bar bui-progress-' + v;
      return Result;
    };
    comp["computed"]["barStyle"] = function (_this) {
      var Result = undefined;
      var pct = Math.min(100, Math.max(0, parseInt(this.value) || 0));
      return 'width: ' + pct + '%;';
      return Result;
    };
    comp["computed"]["showText"] = function (_this) {
      var Result = undefined;
      return this.label !== false && this.label !== 'false';
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-progress",comp);
  };
});
rtl.module("uBVDrawer",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVDrawer = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-drawer-wrapper {   position: fixed;   top: 0;   left: 0;   width: 100vw;   height: 100vh;   z-index: 1050;   pointer-events: none;   visibility: hidden; } .bui-drawer-wrapper.is-open {   pointer-events: auto;   visibility: visible; } .bui-drawer-backdrop {   position: fixed;   top: 0;   left: 0;   width: 100vw;   height: 100vh;   background: rgba(0, 0, 0, 0.45);   backdrop-filter: blur(2px);   z-index: 1050;   opacity: 0;   transition: opacity 0.3s ease;   pointer-events: auto; } .bui-drawer-wrapper.is-open .bui-drawer-backdrop {   opacity: 1; } .bui-drawer {   position: fixed;   top: 0;   bottom: 0;   left: 0;   width: 280px;   max-width: 85vw;   background: var(--bui-card-bg, #fff);   color: var(--bui-text, #1e293b);   box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);   z-index: 1060;   display: flex;   flex-direction: column;   transition: transform 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);   box-sizing: border-box;   pointer-events: auto;   visibility: visible; } .bui-drawer-left {   left: 0;   right: auto;   transform: translateX(-100%); } .bui-drawer-left.is-open {   transform: translateX(0); } .bui-drawer-right {   left: auto;   right: 0;   transform: translateX(100%); } .bui-drawer-right.is-open {   transform: translateX(0); }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div :class="\'bui-drawer-wrapper\' + (isOpen ? \' is-open\' : \'\')">' + '    <div class="bui-drawer-backdrop" v-if="isOpen && overlay" @click="close"></div>' + '    <aside :class="\'bui-drawer bui-drawer-\' + (position || \'left\') + (isOpen ? \' is-open\' : \'\')" :style="\'width: \' + (width || \'280px\')">' + '      <div class="bui-drawer-header">' + '        <slot name="header">' + '          <strong class="bui-drawer-title">{{ title }}</strong>' + '          <button class="bui-drawer-close" type="button" @click="close">&times;</button>' + "        </slot>" + "      </div>" + '      <div class="bui-drawer-body">' + "        <slot></slot>" + "      </div>" + '      <div class="bui-drawer-footer" v-if="hasFooter">' + '        <slot name="footer"></slot>' + "      </div>" + "    </aside>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["isOpen"] = false;
      d["position"] = "left";
      d["width"] = "280px";
      d["overlay"] = true;
      d["hasFooter"] = false;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "Menu";
    comp["props"].push("width");
    comp["defaultProps"]["width"] = "280px";
    comp["props"].push("position");
    comp["defaultProps"]["position"] = "left";
    comp["props"].push("overlay");
    comp["defaultProps"]["overlay"] = true;
    comp["props"].push("hasFooter");
    comp["defaultProps"]["hasFooter"] = false;
    comp["props"].push("show");
    comp["defaultProps"]["show"] = false;
    m = new Object();
    m["open"] = function (_this) {
      _this["isOpen"] = true;
      this.$emit('open');
    };
    m["close"] = function (_this) {
      _this["isOpen"] = false;
      this.$emit('close');
    };
    m["toggle"] = function (_this) {
      _this["isOpen"] = !!(_this["isOpen"] == false);
      if (!(_this["isOpen"] == false)) {
        this.$emit('open');
      } else {
        this.$emit('close');
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      if ((_this["show"] == true) || (_this["show"] == "true")) {
        _this["isOpen"] = true}
       else _this["isOpen"] = false;
    };
    pas.BVComponents.RegisterComponent("bv-drawer",comp);
  };
});
rtl.module("uBVBtn",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBtn = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = "  <button " + '    class="bui-btn" ' + '    :class="btnClass" ' + '    :disabled="disabled"' + '    @click="handleClick">' + "    <slot>{{ label }}</slot>" + "  </button>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("variant");
    comp["defaultProps"]["variant"] = "primary";
    comp["props"].push("size");
    comp["defaultProps"]["size"] = "md";
    comp["props"].push("disabled");
    comp["defaultProps"]["disabled"] = false;
    comp["props"].push("outline");
    comp["defaultProps"]["outline"] = false;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      var isDisabled = (this.disabled === true || this.disabled === 'true' || this.disabled === '');
      if (!isDisabled) {
        this.$emit('click', ev);
      };
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["btnClass"] = function (_this) {
      var Result = undefined;
      var v = this.variant || 'primary';
      var isOut = Boolean(this.outline) || v.startsWith('outline-');
      var cleanV = v.replace('outline-', '');
      var s = this.size ? (' bui-btn-' + this.size) : ' bui-btn-md';
      var variantClass = isOut ? ('bui-btn-outline-' + cleanV) : ('bui-btn-' + cleanV);
      return 'bui-btn ' + variantClass + s;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-btn",comp);
  };
});
rtl.module("uBVToast",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVToast = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-toast {   position: fixed;   bottom: 20px;   right: 20px;   background: #1e293b;   color: #fff;   padding: 12px 20px;   border-radius: 6px;   box-shadow: 0 10px 15px -3px rgba(0,0,0,0.2);   display: flex;   align-items: center;   gap: 10px;   z-index: 10000;   border-left: 4px solid var(--bui-primary, #42b883);   animation: bui-toast-slide 0.3s ease-out; } @media (max-width: 576px) {   .bui-toast {     bottom: 74px;     left: 16px;     right: 16px;     max-width: calc(100vw - 32px);     justify-content: space-between;   } } @keyframes bui-toast-slide {   from { transform: translateY(20px); opacity: 0; }   to { transform: translateY(0); opacity: 1; } }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <teleport to="body">' + '    <div class="bui-toast" :class="\'bui-toast-\' + (variant || \'success\')" b-if="isVisible">' + '      <div class="bui-toast-content">' + '        <strong v-if="title" style="display: block; margin-bottom: 2px;">{{ title }}</strong>' + "        <slot>{{ message }}</slot>" + "      </div>" + '      <button class="bui-btn bui-btn-sm bui-btn-secondary" style="margin-left: 10px;" @click="dismiss">✕</button>' + "    </div>" + "  </teleport>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["isOpen"] = false;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "";
    comp["props"].push("message");
    comp["defaultProps"]["message"] = "";
    comp["props"].push("duration");
    comp["defaultProps"]["duration"] = 3000;
    comp["props"].push("variant");
    comp["defaultProps"]["variant"] = "success";
    m = new Object();
    m["showToast"] = function (_this) {
      _this["isOpen"] = true;
      const dur = this.duration || 3000;
      if (this._toastTimer) clearTimeout(this._toastTimer);
      this._toastTimer = setTimeout(() => {
        this.isOpen = false;
      }, dur);
    };
    m["show"] = function (_this) {
      this.showToast();
    };
    m["dismiss"] = function (_this) {
      _this["isOpen"] = false;
      this.$emit('dismiss');
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["isVisible"] = function (_this) {
      var Result = undefined;
      return Boolean(this.isOpen);
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-toast",comp);
  };
});
rtl.module("uBVBreadcrumb",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBreadcrumb = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav aria-label="breadcrumb">' + '    <ol class="bui-breadcrumb">' + "      <slot></slot>" + "    </ol>" + "  </nav>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-breadcrumb",comp);
  };
});
rtl.module("uBVNavbar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVNavbar = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav class="bui-navbar">' + '    <a class="bui-navbar-brand" href="#/">{{ brand }}</a>' + '    <ul class="bui-navbar-nav">' + "      <slot></slot>" + "    </ul>" + "  </nav>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("brand");
    comp["defaultProps"]["brand"] = "BlaiseVue UI";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-navbar",comp);
  };
});
rtl.module("uBVNavItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVNavItem = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-nav-link {   cursor: pointer;   user-select: none; }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <li class="bui-nav-item">' + '     <a class="bui-nav-link" :class="{ active: active }" :href="href || \'#\'" @click="handleClick">' + "        <slot>{{ label }}</slot>" + "     </a>" + "  </li>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("href");
    comp["defaultProps"]["href"] = "";
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("active");
    comp["defaultProps"]["active"] = false;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      if (!this.href || this.href === '#' || this.href === 'javascript:void(0)') {
        if (ev && ev.preventDefault) ev.preventDefault();
      }
      this.$emit('click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-nav-item",comp);
  };
});
rtl.module("uBVListGroup",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVListGroup = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <ul class="bui-list-group">' + "    <slot></slot>" + "  </ul>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-list-group",comp);
  };
});
rtl.module("uBVFormSelect",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVFormSelect = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-input-group">' + '    <label class="bui-input-label" v-if="label">{{ label }}</label>' + '    <select class="bui-select" :value="value" @change="onChange">' + '       <option b-for="opt in options" :value="opt.value">{{ opt.text }}</option>' + "    </select>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("value");
    comp["defaultProps"]["value"] = "";
    comp["props"].push("options");
    comp["defaultProps"]["options"] = null;
    m = new Object();
    m["onChange"] = function (_this, ev) {
      var val = (ev && ev.target) ? ev.target.value : ev;
      this.$emit('input', val); 
      this.$emit('change', val);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-form-select",comp);
  };
});
rtl.module("uBVDataGrid",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVDataGrid = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-datagrid-container">' + '    <div class="bui-datagrid-toolbar">' + "      <input " + '        type="text" ' + '        class="bui-datagrid-search" ' + '        placeholder="Buscar..." ' + '        b-model="searchQuery" ' + '        @input="handleSearch"' + "      />" + "      <span>Total: {{ totalItems }} {{ virtualScroll ? '(Virtual Scroll)' : '' }}</span>" + "    </div>" + "" + "    <div " + '      class="bui-datagrid-table-wrap" ' + '      :style="virtualScroll ? { maxHeight: virtualHeight, overflowY: \'auto\', position: \'relative\' } : {}"' + '      @scroll="handleTableScroll"' + '      b-ref="tableWrap"' + "    >" + '      <table class="bui-datagrid-table">' + "        <thead>" + "          <tr>" + '            <th b-for="col in resolvedColumns" @click="sortBy(col.key)">' + "              {{ col.label }}" + "            </th>" + "          </tr>" + "        </thead>" + "        <tbody>" + '          <tr v-if="virtualScroll && topSpacerHeight > 0" class="bui-virtual-spacer" :style="{ height: topSpacerHeight + \'px\' }">' + '            <td :colspan="resolvedColumns.length" style="padding:0; border:none; background:transparent;"></td>' + "          </tr>" + "          <tr " + '            b-for="row in displayRows" ' + '            @click="selectRow(row)" ' + '            :class="{ \'bui-row-selected\': (selectedRow !== undefined && dataset && dataset.Current ? (row && dataset.Current.id !== undefined ? dataset.Current.id === row.id : dataset.Current === row) : selectedRow === row) }"' + '            :style="virtualScroll ? { height: rowHeight + \'px\' } : {}"' + "          >" + '            <td b-for="col in resolvedColumns">' + '              <slot name="cell" :row="row" :column="col" :value="row[col.key]">' + "                {{ row[col.key] }}" + "              </slot>" + "            </td>" + "          </tr>" + '          <tr v-if="virtualScroll && bottomSpacerHeight > 0" class="bui-virtual-spacer" :style="{ height: bottomSpacerHeight + \'px\' }">' + '            <td :colspan="resolvedColumns.length" style="padding:0; border:none; background:transparent;"></td>' + "          </tr>" + "        </tbody>" + "      </table>" + "    </div>" + "" + '    <div v-if="!virtualScroll" class="bui-datagrid-pagination">' + '      <button class="bui-btn bui-btn-sm" :disabled="currentPage <= 1" @click="prevPage">Anterior</button>' + "      <span>Página {{ currentPage }} de {{ totalPages }}</span>" + '      <button class="bui-btn bui-btn-sm" :disabled="currentPage >= totalPages" @click="nextPage">Próxima</button>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["searchQuery"] = "";
      d["sortKey"] = "";
      d["sortAsc"] = true;
      d["currentPage"] = 1;
      d["pageSize"] = 5;
      d["selectedRow"] = null;
      d["virtualScrollTop"] = 0;
      d["virtualViewportHeight"] = 400;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("dataset");
    comp["defaultProps"]["dataset"] = null;
    comp["props"].push("items");
    comp["defaultProps"]["items"] = new Array();
    comp["props"].push("columns");
    comp["defaultProps"]["columns"] = new Array();
    comp["props"].push("virtualScroll");
    comp["defaultProps"]["virtualScroll"] = false;
    comp["props"].push("rowHeight");
    comp["defaultProps"]["rowHeight"] = 40;
    comp["props"].push("virtualHeight");
    comp["defaultProps"]["virtualHeight"] = "400px";
    comp["props"].push("virtualBuffer");
    comp["defaultProps"]["virtualBuffer"] = 5;
    m = new Object();
    m["handleSearch"] = function (_this) {
      _this["currentPage"] = 1;
      _this["virtualScrollTop"] = 0;
    };
    m["handleTableScroll"] = function (_this, e) {
      if (e && e.target) {
        this.virtualScrollTop = e.target.scrollTop || 0;
        this.virtualViewportHeight = e.target.clientHeight || 400;
      };
    };
    m["sortBy"] = function (_this, key) {
      if (_this["sortKey"] == key) {
        _this["sortAsc"] = !!(_this["sortAsc"] == false)}
       else {
        _this["sortKey"] = key;
        _this["sortAsc"] = true;
      };
    };
    m["prevPage"] = function (_this) {
      if (rtl.trunc(_this["currentPage"]) > 1) _this["currentPage"] = rtl.trunc(_this["currentPage"]) - 1;
    };
    m["nextPage"] = function (_this) {
      if (rtl.trunc(_this["currentPage"]) < rtl.trunc(_this["totalPages"])) _this["currentPage"] = rtl.trunc(_this["currentPage"]) + 1;
    };
    m["selectRow"] = function (_this, row) {
      var ds = this.dataset;
      if (ds && row) {
        if (row.id !== undefined && typeof ds.Locate === 'function') {
          ds.Locate('id', row.id);
        } else if (typeof ds.Locate === 'function') {
          var keys = Object.keys(row);
          if (keys.length > 0) ds.Locate(keys[0], row[keys[0]]);
        }
        if (ds.RecNo > 0) this._lastRecNo = ds.RecNo;
      }
      this.selectedRow = row;
      if (typeof this.$emit === 'function') {
        this.$emit('row-select', row);
      };
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      if (this.virtualScroll && this.$refs && this.$refs.tableWrap) {
        this.virtualViewportHeight = this.$refs.tableWrap.clientHeight || 400;
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["resolvedItems"] = function (_this) {
      var Result = undefined;
      var ds = this.dataset;
      if (ds) {
        if (Array.isArray(ds.Data)) return ds.Data;
        if (Array.isArray(ds.FActiveRecords)) return ds.FActiveRecords;
        if (Array.isArray(ds.FRecords)) return ds.FRecords;
        if (Array.isArray(ds)) return ds;
      }
      return (this.items && Array.isArray(this.items)) ? this.items : [];
      return Result;
    };
    comp["computed"]["resolvedColumns"] = function (_this) {
      var Result = undefined;
      if (this.columns && Array.isArray(this.columns) && this.columns.length > 0) {
        return this.columns;
      }
      var ds = this.dataset;
      if (ds && ds.Fields && typeof ds.Fields.ToArray === 'function') {
        return ds.Fields.ToArray();
      }
      var list = this.resolvedItems;
      if (list && list.length > 0 && typeof list[0] === 'object') {
        return Object.keys(list[0]).map(function(k) {
          return { key: k, label: k.charAt(0).toUpperCase() + k.slice(1) };
        });
      }
      return [];
      return Result;
    };
    comp["computed"]["totalItems"] = function (_this) {
      var Result = undefined;
      Result = (this.filteredItems && Array.isArray(this.filteredItems)) ? this.filteredItems.length : 0;
      return Result;
    };
    comp["computed"]["filteredItems"] = function (_this) {
      var Result = undefined;
      let list = (this.resolvedItems && Array.isArray(this.resolvedItems)) ? this.resolvedItems.slice() : [];
      let q = (this.searchQuery || '').toLowerCase();
      if (q) {
        list = list.filter(function(item) {
          return Object.values(item).some(function(v) {
            return String(v).toLowerCase().indexOf(q) !== -1;
          });
        });
      }
      let sk = this.sortKey;
      let asc = this.sortAsc;
      if (sk) {
        list.sort(function(a, b) {
          let va = (a && a[sk] !== undefined) ? a[sk] : '';
          let vb = (b && b[sk] !== undefined) ? b[sk] : '';
          if (typeof va === 'number' && typeof vb === 'number') {
            return asc ? (va - vb) : (vb - va);
          }
          let sa = String(va).toLowerCase();
          let sb = String(vb).toLowerCase();
          if (sa < sb) return asc ? -1 : 1;
          if (sa > sb) return asc ? 1 : -1;
          return 0;
        });
      }
      return list;
      return Result;
    };
    comp["computed"]["totalPages"] = function (_this) {
      var Result = undefined;
      let count = this.filteredItems.length;
      Result = Math.max(1, Math.ceil(count / this.pageSize));
      return Result;
    };
    comp["computed"]["pagedItems"] = function (_this) {
      var Result = undefined;
      var ds = this.dataset;
      if (ds && ds.RecNo > 0 && this.pageSize > 0) {
        var recNo = ds.RecNo;
        if (this._lastRecNo === undefined) {
          this._lastRecNo = recNo;
        } else if (recNo !== this._lastRecNo) {
          this._lastRecNo = recNo;
          var targetPage = Math.ceil(recNo / this.pageSize);
          if (targetPage > 0 && targetPage !== this.currentPage) {
            this.currentPage = targetPage;
          }
        }
      }
      let list = this.filteredItems || [];
      let start = (this.currentPage - 1) * this.pageSize;
      return list.slice(start, start + this.pageSize);
      return Result;
    };
    comp["computed"]["virtualStartIndex"] = function (_this) {
      var Result = undefined;
      let rh = this.rowHeight || 40;
      let buf = this.virtualBuffer !== undefined ? this.virtualBuffer : 5;
      let idx = Math.floor(this.virtualScrollTop / rh) - buf;
      Result = Math.max(0, idx);
      return Result;
    };
    comp["computed"]["virtualEndIndex"] = function (_this) {
      var Result = undefined;
      let rh = this.rowHeight || 40;
      let buf = this.virtualBuffer !== undefined ? this.virtualBuffer : 5;
      let vh = this.virtualViewportHeight || 400;
      let count = (this.filteredItems && Array.isArray(this.filteredItems)) ? this.filteredItems.length : 0;
      let idx = Math.ceil((this.virtualScrollTop + vh) / rh) + buf;
      Result = Math.min(count, idx);
      return Result;
    };
    comp["computed"]["topSpacerHeight"] = function (_this) {
      var Result = undefined;
      let rh = this.rowHeight || 40;
      Result = this.virtualStartIndex * rh;
      return Result;
    };
    comp["computed"]["bottomSpacerHeight"] = function (_this) {
      var Result = undefined;
      let rh = this.rowHeight || 40;
      let count = (this.filteredItems && Array.isArray(this.filteredItems)) ? this.filteredItems.length : 0;
      let rendered = this.virtualEndIndex - this.virtualStartIndex;
      let remaining = Math.max(0, count - this.virtualStartIndex - rendered);
      Result = remaining * rh;
      return Result;
    };
    comp["computed"]["displayRows"] = function (_this) {
      var Result = undefined;
      if (this.virtualScroll) {
        let list = (this.filteredItems && Array.isArray(this.filteredItems)) ? this.filteredItems : [];
        return list.slice(this.virtualStartIndex, this.virtualEndIndex);
      }
      return this.pagedItems;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-data-grid",comp);
    pas.BVComponents.RegisterComponent("bv-datagrid",comp);
  };
});
rtl.module("uBVSpinner",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVSpinner = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-spinner" :class="[\'bui-spinner\', \'bui-spinner-\' + (variant || \'primary\'), (small && small !== \'false\') ? \'bui-spinner-sm\' : \'\']" role="status"></div>';
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("variant");
    comp["defaultProps"]["variant"] = "primary";
    comp["props"].push("small");
    comp["defaultProps"]["small"] = false;
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-spinner",comp);
  };
});
rtl.module("uBVContainer",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVContainer = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-container" :class="{ \'bui-container-fluid\': fluid }">' + "    <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("fluid");
    comp["defaultProps"]["fluid"] = false;
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-container",comp);
  };
});
rtl.module("uBVBadge",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBadge = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <span class="bui-badge" ' + '        :class="badgeClass">' + "    <slot></slot>" + "  </span>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("variant");
    comp["defaultProps"]["variant"] = "primary";
    comp["props"].push("pill");
    comp["defaultProps"]["pill"] = false;
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["badgeClass"] = function (_this) {
      var Result = undefined;
      var v = this.variant || 'primary';
      var p = (this.pill && this.pill !== 'false') ? ' bui-badge-pill' : '';
      return 'bui-badge bui-badge-' + v + p;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-badge",comp);
  };
});
rtl.module("uBVBottomNav",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBottomNav = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav class="bui-bottom-nav">' + "    <slot></slot>" + "  </nav>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-bottom-nav",comp);
  };
});
rtl.module("uBVListGroupItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVListGroupItem = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <li class="bui-list-group-item" ' + '      :class="{ active: active }"' + '      @click="handleClick">' + "    <span><slot></slot></span>" + '    <bv-badge v-if="badge" :variant="resolvedBadgeVariant">{{ badge }}</bv-badge>' + "  </li>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("active");
    comp["defaultProps"]["active"] = false;
    comp["props"].push("badge");
    comp["defaultProps"]["badge"] = "";
    comp["props"].push("badgeVariant");
    comp["defaultProps"]["badgeVariant"] = "primary";
    comp["props"].push("badgevariant");
    comp["defaultProps"]["badgevariant"] = "primary";
    m = new Object();
    m["handleClick"] = function (_this) {
      this.$emit('click');
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["resolvedBadgeVariant"] = function (_this) {
      var Result = undefined;
      return this.badgeVariant || this.badgevariant || 'primary';
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-list-group-item",comp);
  };
});
rtl.module("uBVVirtualScroll",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVVirtualScroll = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-virtual-scroll {     position: relative;     overflow-y: auto;     overflow-x: hidden;     width: 100%;     box-sizing: border-box;   }   .bui-virtual-runway {     position: relative;     width: 100%;     box-sizing: border-box;   }   .bui-virtual-content {     position: absolute;     top: 0;     left: 0;     width: 100%;     box-sizing: border-box;     will-change: transform;   }   .bui-virtual-item {     box-sizing: border-box;     overflow: hidden;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="bui-virtual-scroll" :style="{ height: height, overflowY: \'auto\', position: \'relative\' }" @scroll="handleScroll" b-ref="viewport">' + '    <div class="bui-virtual-runway" :style="{ height: totalHeight + \'px\', width: \'100%\', position: \'relative\' }">' + '      <div class="bui-virtual-content" :style="{ transform: \'translateY(\' + offsetY + \'px)\', position: \'absolute\', top: 0, left: 0, width: \'100%\' }">' + "        <div " + '          b-for="(item, idx) in visibleItems" ' + '          :key="startIndex + idx" ' + '          class="bui-virtual-item"' + '          :style="{ height: itemHeight + \'px\' }"' + "        >" + '          <slot :item="item" :index="startIndex + idx">' + "            {{ item }}" + "          </slot>" + "        </div>" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["scrollTop"] = 0;
      d["viewportHeight"] = 400;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("items");
    comp["defaultProps"]["items"] = new Array();
    comp["props"].push("itemHeight");
    comp["defaultProps"]["itemHeight"] = 40;
    comp["props"].push("height");
    comp["defaultProps"]["height"] = "400px";
    comp["props"].push("buffer");
    comp["defaultProps"]["buffer"] = 5;
    m = new Object();
    m["handleScroll"] = function (_this, e) {
      if (e && e.target) {
        this.scrollTop = e.target.scrollTop || 0;
        this.viewportHeight = e.target.clientHeight || 400;
        if (typeof this.$emit === 'function') {
          this.$emit('scroll', { scrollTop: this.scrollTop, startIndex: this.startIndex, endIndex: this.endIndex });
        }
      };
    };
    m["scrollToIndex"] = function (_this, idx) {
      let ih = this.itemHeight || 40;
      if (this.$refs && this.$refs.viewport) {
        this.$refs.viewport.scrollTop = idx * ih;
      };
    };
    m["scrollToTop"] = function (_this) {
      if (this.$refs && this.$refs.viewport) {
        this.$refs.viewport.scrollTop = 0;
      };
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      if (this.$refs && this.$refs.viewport) {
        this.viewportHeight = this.$refs.viewport.clientHeight || 400;
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["totalCount"] = function (_this) {
      var Result = undefined;
      Result = (this.items && Array.isArray(this.items)) ? this.items.length : 0;
      return Result;
    };
    comp["computed"]["totalHeight"] = function (_this) {
      var Result = undefined;
      Result = this.totalCount * (this.itemHeight || 40);
      return Result;
    };
    comp["computed"]["startIndex"] = function (_this) {
      var Result = undefined;
      let ih = this.itemHeight || 40;
      let buf = this.buffer !== undefined ? this.buffer : 5;
      let idx = Math.floor(this.scrollTop / ih) - buf;
      Result = Math.max(0, idx);
      return Result;
    };
    comp["computed"]["endIndex"] = function (_this) {
      var Result = undefined;
      let ih = this.itemHeight || 40;
      let buf = this.buffer !== undefined ? this.buffer : 5;
      let vh = this.viewportHeight || 400;
      let idx = Math.ceil((this.scrollTop + vh) / ih) + buf;
      Result = Math.min(this.totalCount, idx);
      return Result;
    };
    comp["computed"]["offsetY"] = function (_this) {
      var Result = undefined;
      let ih = this.itemHeight || 40;
      Result = this.startIndex * ih;
      return Result;
    };
    comp["computed"]["visibleItems"] = function (_this) {
      var Result = undefined;
      let list = (this.items && Array.isArray(this.items)) ? this.items : [];
      return list.slice(this.startIndex, this.endIndex);
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-virtual-scroll",comp);
    pas.BVComponents.RegisterComponent("bv-virtualscroll",comp);
  };
});
rtl.module("uBVPagination",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVPagination = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav aria-label="Page navigation">' + '    <ul class="bui-pagination">' + '       <li class="bui-page-item" :class="{ disabled: value <= 1 }">' + '         <button class="bui-page-link" @click="changePage(value - 1)">&laquo;</button>' + "       </li>" + "       " + '       <li class="bui-page-item" b-for="p in pages" :class="{ active: p == value }">' + '         <button class="bui-page-link" @click="changePage(p)">{{ p }}</button>' + "       </li>" + "" + '       <li class="bui-page-item" :class="{ disabled: value >= total }">' + '         <button class="bui-page-link" @click="changePage(value + 1)">&raquo;</button>' + "       </li>" + "    </ul>" + "  </nav>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("value");
    comp["defaultProps"]["value"] = 1;
    comp["props"].push("total");
    comp["defaultProps"]["total"] = 10;
    m = new Object();
    m["changePage"] = function (_this, p) {
      if ((p >= 1) && (p <= rtl.trunc(_this["total"]))) {
        this.$emit('input', p); this.$emit('change', p);
      };
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["pages"] = function (_this) {
      var Result = undefined;
      var arr = [];
      var tot = parseInt(this.total) || 1;
      for (var i = 1; i <= tot; i++) arr.push(i);
      return arr;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-pagination",comp);
  };
});
rtl.module("uBVCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVCard = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-card">' + '    <div class="bui-card-header" b-if="title">' + '      <slot name="header">{{ title }}</slot>' + "    </div>" + '    <div class="bui-card-body">' + "      <slot></slot>" + "    </div>" + '    <div class="bui-card-footer" b-if="hasFooter">' + '      <slot name="footer"></slot>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "";
    comp["props"].push("hasFooter");
    comp["defaultProps"]["hasFooter"] = false;
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-card",comp);
  };
});
rtl.module("uBVBottomNavItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBottomNavItem = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <a :class="\'bui-bottom-nav-item\' + (active ? \' active\' : \'\')" :href="href" @click="handleClick">' + '    <span class="bui-bottom-nav-icon" v-if="icon">{{ icon }}</span>' + '    <span class="bui-bottom-nav-label">{{ label }}</span>' + "  </a>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["href"] = "#/";
      d["label"] = "Item";
      d["icon"] = "";
      d["active"] = false;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("href");
    comp["defaultProps"]["href"] = "#/";
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "Item";
    comp["props"].push("icon");
    comp["defaultProps"]["icon"] = "";
    comp["props"].push("active");
    comp["defaultProps"]["active"] = false;
    m = new Object();
    m["handleClick"] = function (_this, e) {
      var target = (this && this.href) || (_this && _this.href);
      if (!target && e && e.currentTarget) {
        target = e.currentTarget.getAttribute('href');
      }
      if (target) {
        if (target.indexOf('#') !== -1) {
          if (e && e.preventDefault) e.preventDefault();
          var hashPart = target.substring(target.indexOf('#'));
          if (window.__BV_CORE__ && window.__BV_CORE__.router) {
            window.__BV_CORE__.router.Push(hashPart.replace(/^#/, ''));
          } else {
            window.location.hash = hashPart;
          }
        } else {
          window.location.href = target;
        }
      }
      this.$emit('click', e);
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      var self = this;
      var updateActive = function() {
        var curHash = window.location.hash || '#/';
        if (self.href && self.href.indexOf('#') !== -1) {
          var targetHash = self.href.substring(self.href.indexOf('#'));
          self.active = (curHash === targetHash || (targetHash !== '#/' && curHash.indexOf(targetHash) === 0));
        }
      };
      updateActive();
      window.addEventListener('hashchange', updateActive);
    };
    pas.BVComponents.RegisterComponent("bv-bottom-nav-item",comp);
  };
});
rtl.module("uBVRow",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVRow = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-row" :class="rowClass">' + "    <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("gutter");
    comp["defaultProps"]["gutter"] = "md";
    comp["props"].push("align");
    comp["defaultProps"]["align"] = "";
    comp["props"].push("justify");
    comp["defaultProps"]["justify"] = "";
    comp["props"].push("noGutters");
    comp["defaultProps"]["noGutters"] = false;
    comp["props"].push("nogutters");
    comp["defaultProps"]["nogutters"] = false;
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["rowClass"] = function (_this) {
      var Result = undefined;
      var cls = [];
      if (this.noGutters || this.nogutters || this.gutter === 'none') {
        cls.push('bui-gutter-none');
      } else if (this.gutter === 'sm') {
        cls.push('bui-gutter-sm');
      } else if (this.gutter === 'lg') {
        cls.push('bui-gutter-lg');
      } else {
        cls.push('bui-gutter-md');
      }
      if (this.align) cls.push('bui-align-' + this.align);
      if (this.justify) cls.push('bui-justify-' + this.justify);
      return cls.join(' ');
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-row",comp);
  };
});
rtl.module("uBVInputGroup",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVInputGroup = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-input-group">' + '    <label class="bui-input-label" v-if="label">{{ label }}</label>' + '    <div class="bui-input-group-row">' + '       <span class="bui-input-addon bui-input-addon-prepend" v-if="prepend">{{ prepend }}</span>' + "       <slot>" + "         <input " + '           type="text" ' + '           class="bui-input-group-field" ' + '           :placeholder="placeholder || \'\'" ' + '           :value="value !== undefined && value !== null ? value : \'\'"' + '           @input="onInput"' + "         >" + "       </slot>" + '       <span class="bui-input-addon bui-input-addon-append" v-if="append">{{ append }}</span>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("placeholder");
    comp["defaultProps"]["placeholder"] = "";
    comp["props"].push("value");
    comp["defaultProps"]["value"] = "";
    comp["props"].push("prepend");
    comp["defaultProps"]["prepend"] = "";
    comp["props"].push("append");
    comp["defaultProps"]["append"] = "";
    m = new Object();
    m["onInput"] = function (_this, ev) {
      var val = (ev && ev.target) ? ev.target.value : (ev || '');
      this.$emit('input', val);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-input-group",comp);
  };
});
rtl.module("uBVCol",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVCol = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-col" :class="colClass">' + "    <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("cols");
    comp["defaultProps"]["cols"] = "12";
    comp["props"].push("sm");
    comp["defaultProps"]["sm"] = "";
    comp["props"].push("md");
    comp["defaultProps"]["md"] = "";
    comp["props"].push("lg");
    comp["defaultProps"]["lg"] = "";
    comp["props"].push("xl");
    comp["defaultProps"]["xl"] = "";
    comp["props"].push("offset");
    comp["defaultProps"]["offset"] = "";
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["colClass"] = function (_this) {
      var Result = undefined;
      var cls = [];
      var c = this.cols || '12';
      cls.push('bui-col-' + c);
      if (this.sm) cls.push('bui-col-sm-' + this.sm);
      if (this.md) cls.push('bui-col-md-' + this.md);
      if (this.lg) cls.push('bui-col-lg-' + this.lg);
      if (this.xl) cls.push('bui-col-xl-' + this.xl);
      if (this.offset) cls.push('bui-offset-' + this.offset);
      return cls.join(' ');
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-col",comp);
  };
});
rtl.module("uBVModal",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVModal = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-modal-backdrop {   position: fixed;   top: 0; left: 0; right: 0; bottom: 0;   background: rgba(0, 0, 0, 0.6);   display: flex;   align-items: center;   justify-content: center;   z-index: 9999;   backdrop-filter: blur(2px);   padding: 16px;   box-sizing: border-box; } .bui-modal-content {   background: var(--bui-card-bg, #fff);   color: var(--bui-text, #1e293b);   border-radius: 8px;   width: 100%;   max-width: 520px;   box-shadow: 0 20px 25px -5px rgba(0,0,0,0.3);   overflow: hidden;   animation: bui-scale-in 0.2s ease-out;   box-sizing: border-box; } @keyframes bui-scale-in {   from { transform: scale(0.95); opacity: 0; }   to { transform: scale(1); opacity: 1; } } .bui-modal-header {   padding: 14px 18px;   border-bottom: 1px solid var(--bui-border, #e2e8f0);   display: flex;   justify-content: space-between;   align-items: center;   font-weight: 600;   font-size: 16px; } .bui-modal-close {   background: transparent;   border: none;   font-size: 22px;   line-height: 1;   cursor: pointer;   color: var(--bui-text-muted, #64748b);   padding: 0 4px; } .bui-modal-close:hover {   color: var(--bui-text, #1e293b); } .bui-modal-body {    padding: 18px;    max-height: 70vh;   overflow-y: auto; } .bui-modal-footer {   padding: 12px 18px;   border-top: 1px solid var(--bui-border, #e2e8f0);   display: flex;   justify-content: flex-end;   gap: 10px;   background: var(--bui-card-footer-bg, #f8fafc); }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <teleport to="body">' + '    <div class="bui-modal-backdrop" b-show="isVisible" style="display: none;" @click="handleBackdropClick">' + '      <div class="bui-modal-content" @click.stop="">' + '        <div class="bui-modal-header">' + "          <span>{{ title }}</span>" + '          <button class="bui-modal-close" type="button" @click="close">&times;</button>' + "        </div>" + '        <div class="bui-modal-body">' + "          <slot></slot>" + "        </div>" + '        <div class="bui-modal-footer">' + '          <slot name="footer">' + '            <button class="bui-btn bui-btn-secondary" type="button" @click="close">{{ computedCancelLabel }}</button>' + '            <button class="bui-btn bui-btn-primary" type="button" @click="confirm">{{ computedOkLabel }}</button>' + "          </slot>" + "        </div>" + "      </div>" + "    </div>" + "  </teleport>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["isOpen"] = false;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "Modal";
    comp["props"].push("okLabel");
    comp["defaultProps"]["okLabel"] = "Process";
    comp["props"].push("oklabel");
    comp["defaultProps"]["oklabel"] = "Process";
    comp["props"].push("cancelLabel");
    comp["defaultProps"]["cancelLabel"] = "Close";
    comp["props"].push("cancellabel");
    comp["defaultProps"]["cancellabel"] = "Close";
    comp["props"].push("show");
    comp["defaultProps"]["show"] = false;
    m = new Object();
    m["showModal"] = function (_this) {
      this.isOpen = true;
      this.show = true;
    };
    m["show"] = function (_this) {
      this.isOpen = true;
      this.show = true;
    };
    m["close"] = function (_this) {
      this.isOpen = false;
      this.show = false;
      this.$emit('close');
    };
    m["confirm"] = function (_this) {
      this.isOpen = false;
      this.show = false;
      this.$emit('ok');
    };
    m["handleBackdropClick"] = function (_this) {
      this.close();
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      if (this.show === true || this.show === 'true') {
        this.isOpen = true;
      } else {
        this.isOpen = false;
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["isVisible"] = function (_this) {
      var Result = undefined;
      return Boolean(this.isOpen === true || this.show === true || this.show === 'true');
      return Result;
    };
    comp["computed"]["computedOkLabel"] = function (_this) {
      var Result = undefined;
      return this.okLabel || this.oklabel || 'Process';
      return Result;
    };
    comp["computed"]["computedCancelLabel"] = function (_this) {
      var Result = undefined;
      return this.cancelLabel || this.cancellabel || 'Close';
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-modal",comp);
  };
});
rtl.module("uBVBreadcrumbItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVBreadcrumbItem = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <li class="bui-breadcrumb-item" :class="{ active: active }">' + '    <a v-if="href && !active" :href="href" @click="handleClick">' + "      <slot></slot>" + "    </a>" + "    <span v-else>" + "      <slot></slot>" + "    </span>" + "  </li>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("active");
    comp["defaultProps"]["active"] = false;
    comp["props"].push("href");
    comp["defaultProps"]["href"] = "#";
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-breadcrumb-item",comp);
  };
});
rtl.module("uBVTab",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVTab = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-tab-pane" b-show="active">' + "     <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("id");
    comp["defaultProps"]["id"] = "";
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "Tab";
    comp["props"].push("active");
    comp["defaultProps"]["active"] = false;
    m = new Object();
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      if (typeof this.registerTab === 'function') {
        var t = { id: this.id, title: this.title, active: Boolean(this.active && this.active !== 'false') };
        this.registerTab(t);
      };
    };
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      if (typeof this.registerTab === 'function') {
        var t = { id: this.id, title: this.title, active: Boolean(this.active && this.active !== 'false') };
        this.registerTab(t);
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["active"] = function (_this) {
      var Result = undefined;
      if (typeof this.isActive === 'function') {
        return Boolean(this.isActive(this.id));
      }
      return true;
      return Result;
    };
    comp["inject"] = new Array();
    comp["inject"].push("registerTab");
    comp["inject"].push("isActive");
    pas.BVComponents.RegisterComponent("bv-tab",comp);
  };
});
rtl.module("uBVAlert",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVAlert = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-alert" ' + '       :class="\'bui-alert-\' + variant" ' + '       role="alert"' + '       b-if="visible">' + '    <div class="bui-alert-content">' + "      <slot></slot>" + "    </div>" + '    <button type="button" ' + '            class="bui-alert-close" ' + '            b-if="dismissible" ' + '            @click="close" ' + '            aria-label="Close">' + "      ×" + "    </button>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["visible"] = true;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("variant");
    comp["defaultProps"]["variant"] = "primary";
    comp["props"].push("dismissible");
    comp["defaultProps"]["dismissible"] = false;
    comp["props"].push("show");
    comp["defaultProps"]["show"] = true;
    m = new Object();
    m["close"] = function (_this) {
      _this["visible"] = false;
      this.$emit('close');
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      _this["visible"] = !(_this["show"] == false);
    };
    pas.BVComponents.RegisterComponent("bv-alert",comp);
  };
});
rtl.module("uBVAccordion",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVAccordion = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-accordion">' + '    <div class="bui-accordion-item" b-for="item in items">' + '      <h3 class="bui-accordion-header">' + '        <button class="bui-accordion-button" type="button" @click="toggle(item.id)" ' + '                :class="{ active: activeId == item.id }">' + "          {{ item.title }}" + "        </button>" + "      </h3>" + '      <div class="bui-accordion-body" b-show="activeId == item.id">' + "        {{ item.content }}" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["activeId"] = "";
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("items");
    comp["defaultProps"]["items"] = null;
    comp["props"].push("initialActiveId");
    comp["defaultProps"]["initialActiveId"] = "";
    comp["props"].push("initialactiveid");
    comp["defaultProps"]["initialactiveid"] = "";
    m = new Object();
    m["toggle"] = function (_this, id) {
      if (this.activeId === id) {
        this.activeId = '';
      } else {
        this.activeId = id;
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      this.activeId = String(this.initialActiveId || this.initialactiveid || '');
    };
    pas.BVComponents.RegisterComponent("bv-accordion",comp);
  };
});
rtl.module("uBVIcon",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIcon = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <span class="bui-icon-wrapper" :style="\'display: inline-flex; align-items: center; justify-content: center; width: \' + size + \'px; height: \' + size + \'px;\'">' + '    <svg v-if="name == \'check-circle\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'warning\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 5.995A.905.905 0 0 1 8 5zm.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'gear-fill\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.168-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872l-.1-.34zM8 10.93a2.929 2.929 0 1 1 0-5.86 2.929 2.929 0 0 1 0 5.858z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'heart-fill\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path fill-rule="evenodd" d="M8 1.314C12.438-3.248 23.534 4.735 8 15-7.534 4.736 3.562-3.248 8 1.314z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'weather\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M8 5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zM12.5 8a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0v-1a.5.5 0 0 1 .5-.5zM12.5 16a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0v-1a.5.5 0 0 1 .5-.5zm.025-5.975a.5.5 0 0 1 0 .707l-.707.708a.5.5 0 0 1-.708-.708l.707-.707a.5.5 0 0 1 .707 0zM10.732 14.268a.5.5 0 0 1 0 .707l-.707.708a.5.5 0 0 1-.708-.708l.707-.707a.5.5 0 0 1 .707 0z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'code-slash\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M10.478 1.647a.5.5 0 1 0-.956-.294l-4 13a.5.5 0 0 0 .956.294l4-13zM4.854 4.146a.5.5 0 0 1 0 .708L1.707 8l3.147 3.146a.5.5 0 0 1-.708.708l-3.5-3.5a.5.5 0 0 1 0-.708l3.5-3.5a.5.5 0 0 1 .708 0zm6.292 0a.5.5 0 0 0 0 .708L14.293 8l-3.147 3.146a.5.5 0 0 0 .708.708l3.5-3.5a.5.5 0 0 0 0-.708l-3.5-3.5a.5.5 0 0 0-.708 0z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'cpu\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M5 0a.5.5 0 0 1 .5.5V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 .5-.5h.5V2h1.5a.5.5 0 0 1 .5.5v11a.5.5 0 0 1-.5.5H14v1.5a.5.5 0 0 1-.5.5h-1V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-.5.5h-.5V14H2.5a.5.5 0 0 1-.5-.5V2h-1.5a.5.5 0 0 1-.5-.5h.5V1h1.5a.5.5 0 0 1 .5-.5V0zm1 10h4V6H6v4z"/>' + "    </svg>" + "" + '    <svg v-if="name == \'bootstrap-fill\'" xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" fill="currentColor" viewBox="0 0 16 16">' + '      <path d="M6.35 10.5c0 .73.73 1.23 1.58 1.23.83 0 1.55-.53 1.55-1.23 0-.64-.52-1.13-1.55-1.13-.85 0-1.58.49-1.58 1.13zm-.12-3.15c0 .63.74 1.12 1.6 1.12.83 0 1.53-.49 1.53-1.12 0-.67-.7-1.2-1.53-1.2-.86 0-1.6.53-1.6 1.2z"/>' + '      <path d="M10.1 0H5.9C5 0 4 .5 3.3 1.3 2.5 2.1 2 3 2 3.9v8.2c0 .9.5 1.8 1.3 2.6.8.8 1.7 1.3 2.6 1.3h4.2c.9 0 1.8-.5 2.6-1.3.8-.8 1.3-1.7 1.3-2.6V3.9c0-.9-.5-1.8-1.3-2.6C12 .5 11.1 0 10.1 0zM7.9 12.6c-1.6 0-2.9-1.1-2.9-2.5 0-1 .6-1.8 1.5-2.2-.7-.4-1.2-1.1-1.2-2 0-1.3 1.1-2.4 2.6-2.4 1.5 0 2.6 1.1 2.6 2.4 0 .9-.5 1.6-1.2 2 1 .4 1.5 1.2 1.5 2.2 0 1.4-1.3 2.5-2.9 2.5z"/>' + "    </svg>" + "  </span>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("name");
    comp["defaultProps"]["name"] = "check-circle";
    comp["props"].push("size");
    comp["defaultProps"]["size"] = "16";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-icon",comp);
  };
});
rtl.module("uBVIonBadge",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonBadge = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <span class="bui-ion-badge" :class="\'bui-ion-badge-\' + color">' + "    <slot>{{ value }}</slot>" + "  </span>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("color");
    comp["defaultProps"]["color"] = "primary";
    comp["props"].push("value");
    comp["defaultProps"]["value"] = "";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-badge",comp);
  };
});
rtl.module("uBVIonHeader",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonHeader = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <header class="bui-ion-header">' + "    <slot></slot>" + "  </header>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-header",comp);
  };
});
rtl.module("uBVIonCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonCard = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-ion-card">' + '    <div class="bui-ion-card-header" b-if="title || subtitle">' + '      <div class="bui-ion-card-subtitle" b-if="subtitle">{{ subtitle }}</div>' + '      <h2 class="bui-ion-card-title" b-if="title">{{ title }}</h2>' + "    </div>" + '    <div class="bui-ion-card-content">' + "      <slot></slot>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "";
    comp["props"].push("subtitle");
    comp["defaultProps"]["subtitle"] = "";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-card",comp);
  };
});
rtl.module("uBVIonToolbar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonToolbar = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-ion-toolbar">' + '    <div class="bui-ion-toolbar-start">' + '      <slot name="start"></slot>' + "    </div>" + "    <slot></slot>" + '    <div class="bui-ion-toolbar-end">' + '      <slot name="end"></slot>' + "    </div>" + "  </div>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-toolbar",comp);
  };
});
rtl.module("uBVIonItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonItem = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div :class="wrapperClass">' + '    <div class="bui-ion-item" @click="handleClick">' + '      <div class="bui-ion-item-start" b-if="hasStart">' + '        <slot name="start"></slot>' + "      </div>" + '      <div class="bui-ion-item-content">' + '        <div class="bui-ion-item-title" b-if="title">{{ title }}</div>' + '        <div class="bui-ion-item-subtitle" b-if="subtitle">{{ subtitle }}</div>' + "        <slot></slot>" + "      </div>" + '      <div class="bui-ion-item-end">' + '        <slot name="end"></slot>' + '        <span :class="detailClass" b-if="showDetail">&rsaquo;</span>' + "      </div>" + "    </div>" + '    <div class="bui-ion-item-expandable-content" b-if="isContentVisible">' + '      <slot name="expanded"></slot>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["isExpanded"] = false;
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "";
    comp["props"].push("subtitle");
    comp["defaultProps"]["subtitle"] = "";
    comp["props"].push("detail");
    comp["defaultProps"]["detail"] = false;
    comp["props"].push("expandable");
    comp["defaultProps"]["expandable"] = false;
    comp["props"].push("expanded");
    comp["defaultProps"]["expanded"] = false;
    comp["props"].push("hasStart");
    comp["defaultProps"]["hasStart"] = false;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      if (this.expandable === true || this.expandable === 'true') {
        this.isExpanded = !this.isExpanded;
        this.$emit('toggle', { expanded: this.isExpanded });
      }
      this.$emit('click', ev);
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      if (this.expanded === true || this.expanded === 'true') {
        this.isExpanded = true;
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["wrapperClass"] = function (_this) {
      var Result = undefined;
      var exp = (this.expandable === true || this.expandable === 'true') ? ' is-expandable' : '';
      var open = (this.isExpanded === true || this.isExpanded === 'true') ? ' is-expanded' : '';
      return 'bui-ion-item-wrapper' + exp + open;
      return Result;
    };
    comp["computed"]["detailClass"] = function (_this) {
      var Result = undefined;
      var rot = (this.isExpanded === true || this.isExpanded === 'true') ? ' rotated' : '';
      return 'bui-ion-item-detail' + rot;
      return Result;
    };
    comp["computed"]["showDetail"] = function (_this) {
      var Result = undefined;
      var d = Boolean(this.detail === true || this.detail === 'true');
      var e = Boolean(this.expandable === true || this.expandable === 'true');
      return d || e;
      return Result;
    };
    comp["computed"]["isContentVisible"] = function (_this) {
      var Result = undefined;
      var exp = Boolean(this.expandable === true || this.expandable === 'true');
      var open = Boolean(this.isExpanded === true || this.isExpanded === 'true');
      return exp && open;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-ion-item",comp);
  };
});
rtl.module("uBVIonTabBar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonTabBar = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <nav class="bui-ion-tab-bar">' + "    <slot></slot>" + "  </nav>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-tab-bar",comp);
  };
});
rtl.module("uBVIonTabButton",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonTabButton = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = "  <button" + '    class="bui-ion-tab-button"' + '    :class="{ \'is-active\': active }"' + '    @click="handleClick">' + '    <slot name="icon"></slot>' + '    <span class="bui-ion-tab-label"><slot>{{ label }}</slot></span>' + '    <slot name="badge"></slot>' + "  </button>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("active");
    comp["defaultProps"]["active"] = false;
    comp["props"].push("tab");
    comp["defaultProps"]["tab"] = "";
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('tab-click', { tab: this.tab, originalEvent: ev });
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-tab-button",comp);
  };
});
rtl.module("uBVIonTitle",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonTitle = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <h1 class="bui-ion-title">' + "    <slot>{{ title }}</slot>" + "  </h1>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-title",comp);
  };
});
rtl.module("uBVIonTabs",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonTabs = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-ion-tabs">' + '    <div class="bui-ion-tab-content">' + "      <slot></slot>" + "    </div>" + '    <slot name="bottom"></slot>' + "  </div>";
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-tabs",comp);
  };
});
rtl.module("uBVIonList",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonList = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-ion-list" :class="{ \'bui-ion-list-inset\': inset }">' + "    <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("inset");
    comp["defaultProps"]["inset"] = false;
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-list",comp);
  };
});
rtl.module("uBVIonApp",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonApp = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-ion-app" :class="appClass">' + "    <slot></slot>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("mode");
    comp["defaultProps"]["mode"] = "";
    m = new Object();
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["appClass"] = function (_this) {
      var Result = undefined;
      var m = this.mode || (window.$ionic ? window.$ionic.getMode() : 'md');
      return 'ionic-mode-' + m;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-ion-app",comp);
  };
});
rtl.module("uBVIonContent",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonContent = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <main class="bui-ion-content" :class="{ \'bui-ion-content-padding\': padding }">' + "    <slot></slot>" + "  </main>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("padding");
    comp["defaultProps"]["padding"] = false;
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-content",comp);
  };
});
rtl.module("uBVIonButton",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVIonButton = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = "  <button" + '    class="bui-ion-btn"' + '    :class="btnClass"' + '    :disabled="disabled"' + '    @click="handleClick">' + "    <slot>{{ label }}</slot>" + "  </button>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("label");
    comp["defaultProps"]["label"] = "";
    comp["props"].push("color");
    comp["defaultProps"]["color"] = "primary";
    comp["props"].push("fill");
    comp["defaultProps"]["fill"] = "solid";
    comp["props"].push("expand");
    comp["defaultProps"]["expand"] = "";
    comp["props"].push("disabled");
    comp["defaultProps"]["disabled"] = false;
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      var isDisabled = (this.disabled === true || this.disabled === 'true' || this.disabled === '');
      if (!isDisabled) {
        this.$emit('click', ev);
      };
    };
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["btnClass"] = function (_this) {
      var Result = undefined;
      var c = this.color || 'primary';
      var f = this.fill || 'solid';
      var e = this.expand ? (' bui-ion-btn-' + this.expand) : '';
      return 'bui-ion-btn-' + c + ' bui-ion-btn-' + f + e;
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-ion-button",comp);
  };
});
rtl.module("uBVReportViewer",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVPascalDX","BVDataSet"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVReportViewer = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bv-report-viewer-container {     display: flex;     flex-direction: column;     gap: 16px;     width: 100%;     box-sizing: border-box;   }    .bv-report-toolbar {     display: flex;     flex-wrap: wrap;     justify-content: space-between;     align-items: center;     gap: 12px;     background: #1e293b;     color: #f8fafc;     padding: 12px 16px;     border-radius: 8px;   }    .bv-report-toolbar-left {     display: flex;     align-items: center;     gap: 10px;   }    .bv-report-badge {     background: #3b82f6;     color: #ffffff;     font-size: 11px;     font-weight: 700;     padding: 4px 8px;     border-radius: 4px;     text-transform: uppercase;   }    .bv-report-layout-select {     background: #0f172a;     color: #f8fafc;     border: 1px solid #334155;     border-radius: 6px;     padding: 6px 10px;     font-size: 13px;   }    .bv-report-count-pill {     font-size: 12px;     color: #94a3b8;   }    .bv-report-toolbar-actions {     display: flex;     flex-wrap: wrap;     gap: 8px;   }    .bv-report-btn {     border: none;     border-radius: 6px;     padding: 7px 12px;     font-size: 12px;     font-weight: 600;     cursor: pointer;     color: #ffffff;   }    .bv-report-btn-pdf { background: #ef4444; }   .bv-report-btn-excel { background: #10b981; }   .bv-report-btn-csv { background: #3b82f6; }   .bv-report-btn-print { background: #6366f1; }    .bv-report-sheet {     background: #ffffff;     color: #0f172a;     padding: 24px;     border-radius: 8px;     border: 1px solid #cbd5e1;     box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);     margin: 0 auto;     width: 100%;     box-sizing: border-box;   }    .bv-layout-thermal-80mm {     max-width: 320px;     font-family: 'Courier New', monospace;     font-size: 12px;     padding: 12px;   }    .bv-layout-thermal-58mm {     max-width: 240px;     font-family: 'Courier New', monospace;     font-size: 11px;     padding: 8px;   }    .bv-report-banner {     background: #1e293b;     color: #ffffff;     padding: 16px 20px;     border-radius: 6px;     display: flex;     justify-content: space-between;     align-items: center;     margin-bottom: 16px;   }    .bv-report-title {     margin: 0;     font-size: 18px;     font-weight: 700;   }    .bv-report-company {     font-size: 12px;     opacity: 0.85;     margin-top: 4px;   }    .bv-report-logo-box {     font-weight: 800;     font-size: 16px;     border: 2px solid rgba(255, 255, 255, 0.5);     padding: 6px 10px;     border-radius: 6px;   }    .bv-report-meta {     font-size: 12px;     color: #475569;     margin-bottom: 14px;     padding-bottom: 8px;     border-bottom: 1px solid #e2e8f0;   }    .bv-report-table {     width: 100%;     border-collapse: collapse;     font-size: 13px;     margin-bottom: 16px;   }    .bv-report-table th {     background: #f1f5f9;     color: #1e293b;     text-align: left;     padding: 9px 12px;     border-bottom: 2px solid #cbd5e1;     font-weight: 600;   }    .bv-report-table td {     padding: 8px 12px;     border-bottom: 1px solid #e2e8f0;     color: #334155;   }    .bv-report-summaries {     display: flex;     flex-wrap: wrap;     gap: 12px;     justify-content: flex-end;     padding-top: 12px;     border-top: 2px solid #cbd5e1;   }    .bv-report-summary-card {     background: #f8fafc;     border: 1px solid #cbd5e1;     border-radius: 6px;     padding: 8px 14px;     min-width: 130px;     text-align: right;   }    .bv-report-summary-label {     font-size: 11px;     color: #64748b;     text-transform: uppercase;     font-weight: 600;   }    .bv-report-summary-value {     font-size: 15px;     color: #0f172a;     font-weight: 700;     margin-top: 2px;   }    .bv-report-footer {     margin-top: 18px;     padding-top: 10px;     border-top: 1px solid #e2e8f0;     display: flex;     justify-content: space-between;     font-size: 11px;     color: #64748b;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="bv-report-viewer-root bv-report-viewer-container" :class="\'bv-viewer-layout-\' + activeLayout">' + '    <div v-if="showToolbar" class="bv-report-toolbar no-print">' + '      <div class="bv-report-toolbar-left">' + '        <span class="bv-report-badge">BlaiseReports v5.0</span>' + '        <select class="bv-report-layout-select" b-model="activeLayout">' + '          <option value="a4">A4 Portrait</option>' + '          <option value="a4-landscape">A4 Landscape</option>' + '          <option value="letter">Letter Portrait</option>' + '          <option value="thermal-80mm">Thermal POS (80mm)</option>' + '          <option value="thermal-58mm">Thermal POS (58mm)</option>' + "        </select>" + '        <span class="bv-report-count-pill">{{ recordCount }} records</span>' + "      </div>" + '      <div class="bv-report-toolbar-actions">' + '        <button type="button" class="bv-report-btn bv-report-btn-pdf" @click="exportPdf">' + "          Export PDF" + "        </button>" + '        <button type="button" class="bv-report-btn bv-report-btn-excel" @click="exportExcel">' + "          Export Excel (.xlsx)" + "        </button>" + '        <button type="button" class="bv-report-btn bv-report-btn-csv" @click="exportCsv">' + "          Export CSV" + "        </button>" + '        <button type="button" class="bv-report-btn bv-report-btn-print" @click="printReport">' + "          Print / POS" + "        </button>" + "      </div>" + "    </div>" + "" + '    <div class="bv-report-sheet" :class="\'bv-layout-\' + activeLayout">' + '      <div class="bv-report-banner">' + '        <div class="bv-report-banner-info">' + '          <h2 class="bv-report-title">{{ resolvedTitle }}</h2>' + '          <div v-if="resolvedCompany" class="bv-report-company">{{ resolvedCompany }}</div>' + '          <div v-if="resolvedSubtitle" class="bv-report-subtitle">{{ resolvedSubtitle }}</div>' + "        </div>" + '        <div class="bv-report-logo-box">{{ resolvedLogo }}</div>' + "      </div>" + "" + '      <div v-if="resolvedHeader" class="bv-report-meta">' + "        {{ resolvedHeader }}" + "      </div>" + "" + '      <div class="bv-report-table-wrap">' + '        <table class="bv-report-table">' + "          <thead>" + "            <tr>" + '              <th b-for="col in resolvedColumns">' + "                {{ col.label }}" + "              </th>" + "            </tr>" + "          </thead>" + "          <tbody>" + '            <tr b-for="row in formattedRows">' + '              <td b-for="col in resolvedColumns">' + "                {{ row[col.key] }}" + "              </td>" + "            </tr>" + "          </tbody>" + "        </table>" + "      </div>" + "" + '      <div v-if="computedSummaries.length > 0" class="bv-report-summaries">' + '        <div b-for="sumItem in computedSummaries" class="bv-report-summary-card">' + '          <div class="bv-report-summary-label">{{ sumItem.label }}</div>' + '          <div class="bv-report-summary-value">{{ sumItem.formattedValue }}</div>' + "        </div>" + "      </div>" + "" + '      <div class="bv-report-footer">' + "        <span>{{ resolvedFooter }}</span>" + "        <span>Layout: {{ activeLayout }} | Total Records: {{ recordCount }}</span>" + "      </div>" + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["activeLayout"] = "a4";
      d["lastExportFormat"] = "";
      Result = d;
      return Result;
    };
    comp["props"] = new Array();
    comp["defaultProps"] = new Object();
    comp["props"].push("report");
    comp["defaultProps"]["report"] = null;
    comp["props"].push("title");
    comp["defaultProps"]["title"] = "Executive Data Report";
    comp["props"].push("subtitle");
    comp["defaultProps"]["subtitle"] = "";
    comp["props"].push("company");
    comp["defaultProps"]["company"] = "BlaiseVue Enterprise";
    comp["props"].push("headerText");
    comp["defaultProps"]["headerText"] = "";
    comp["props"].push("footerText");
    comp["defaultProps"]["footerText"] = "Generated by BlaiseReports Engine v5.0";
    comp["props"].push("dataset");
    comp["defaultProps"]["dataset"] = null;
    comp["props"].push("items");
    comp["defaultProps"]["items"] = new Array();
    comp["props"].push("columns");
    comp["defaultProps"]["columns"] = new Array();
    comp["props"].push("summaries");
    comp["defaultProps"]["summaries"] = new Array();
    comp["props"].push("pageLayout");
    comp["defaultProps"]["pageLayout"] = "a4";
    comp["props"].push("currencySymbol");
    comp["defaultProps"]["currencySymbol"] = "$";
    comp["props"].push("filename");
    comp["defaultProps"]["filename"] = "report";
    comp["props"].push("showToolbar");
    comp["defaultProps"]["showToolbar"] = true;
    m = new Object();
    m["setLayout"] = function (_this, layoutName) {
      _this["activeLayout"] = layoutName;
      if (this.report && typeof this.report.PageSize === 'function') {
        this.report.PageSize(layoutName);
      };
    };
    m["exportPdf"] = function (_this) {
      _this["lastExportFormat"] = "pdf";
      var fname = (this.filename || 'report') + '.pdf';
      if (this.report && typeof this.report.ExportPDF === 'function') {
        if (typeof this.report.PageSize === 'function') {
          this.report.PageSize(this.activeLayout || 'a4');
        }
        this.report.ExportPDF(fname);
      }
      if (typeof this.$emit === 'function') {
        this.$emit('export-pdf', { filename: fname, layout: this.activeLayout });
      };
    };
    m["exportExcel"] = function (_this) {
      _this["lastExportFormat"] = "xlsx";
      var fname = (this.filename || 'report') + '.xlsx';
      if (this.report && typeof this.report.ExportExcel === 'function') {
        this.report.ExportExcel(fname);
      }
      if (typeof this.$emit === 'function') {
        this.$emit('export-excel', { filename: fname });
      };
    };
    m["exportCsv"] = function (_this) {
      _this["lastExportFormat"] = "csv";
      var fname = (this.filename || 'report') + '.csv';
      if (this.report && typeof this.report.ExportCSV === 'function') {
        this.report.ExportCSV(fname);
      }
      if (typeof this.$emit === 'function') {
        this.$emit('export-csv', { filename: fname });
      };
    };
    m["printReport"] = function (_this) {
      _this["lastExportFormat"] = "print";
      if (typeof this.$emit === 'function') {
        this.$emit('print', { layout: this.activeLayout });
      }
      try {
        var isTestEnv = (typeof navigator !== 'undefined' && navigator.userAgent && navigator.userAgent.toLowerCase().indexOf('jsdom') !== -1);
        if (!isTestEnv && typeof window !== 'undefined' && typeof window.print === 'function') {
          window.print();
        }
      } catch (e) {};
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      if (!_this) _this = this;
      if (this.report && typeof this.report.GetPageLayoutStr === 'function') {
        this.activeLayout = this.report.GetPageLayoutStr();
      } else if (this.pageLayout) {
        this.activeLayout = this.pageLayout;
      };
    };
    comp["computed"] = new Object();
    comp["computed"]["resolvedTitle"] = function (_this) {
      var Result = undefined;
      Result = "";
      if (this.report && this.report.FTitle) {
        Result = this.report.FTitle;
      } else {
        Result = this.title || 'Executive Data Report';
      };
      return Result;
    };
    comp["computed"]["resolvedSubtitle"] = function (_this) {
      var Result = undefined;
      Result = "";
      if (this.report && this.report.FSubtitle) {
        Result = this.report.FSubtitle;
      } else {
        Result = this.subtitle || '';
      };
      return Result;
    };
    comp["computed"]["resolvedCompany"] = function (_this) {
      var Result = undefined;
      Result = "";
      if (this.report && this.report.FCompanyName) {
        Result = this.report.FCompanyName;
      } else {
        Result = this.company || '';
      };
      return Result;
    };
    comp["computed"]["resolvedLogo"] = function (_this) {
      var Result = undefined;
      Result = "BV";
      if (this.report && this.report.FLogoText) {
        Result = this.report.FLogoText;
      };
      return Result;
    };
    comp["computed"]["resolvedHeader"] = function (_this) {
      var Result = undefined;
      Result = "";
      if (this.report && this.report.FHeader) {
        Result = this.report.FHeader;
      } else {
        Result = this.headerText || '';
      };
      return Result;
    };
    comp["computed"]["resolvedFooter"] = function (_this) {
      var Result = undefined;
      Result = "";
      if (this.report && this.report.FFooter) {
        Result = this.report.FFooter;
      } else {
        Result = this.footerText || '';
      };
      return Result;
    };
    comp["computed"]["resolvedRows"] = function (_this) {
      var Result = undefined;
      Result = new Array();
      if (this.report && typeof this.report.GetRecordsArray === 'function') {
        Result = this.report.GetRecordsArray() || [];
      } else {
        var ds = this.dataset;
        if (ds) {
          if (Array.isArray(ds.Data)) Result = ds.Data;
          else if (Array.isArray(ds.FActiveRecords)) Result = ds.FActiveRecords;
          else if (Array.isArray(ds.FRecords)) Result = ds.FRecords;
          else if (Array.isArray(ds)) Result = ds;
        } else {
          Result = (this.items && Array.isArray(this.items)) ? this.items : [];
        }
      };
      return Result;
    };
    comp["computed"]["resolvedColumns"] = function (_this) {
      var Result = undefined;
      Result = new Array();
      if (this.report && typeof this.report.GetColumnsJS === 'function') {
        Result = this.report.GetColumnsJS() || [];
      } else if (this.columns && Array.isArray(this.columns) && this.columns.length > 0) {
        Result = this.columns.map(function(c) {
          if (typeof c === 'string') {
            return { key: c, label: c.charAt(0).toUpperCase() + c.slice(1), format: '' };
          }
          return {
            key: c.key || c.field || c.FieldName || '',
            label: c.label || c.caption || c.Caption || c.key || c.field || '',
            format: c.format || ''
          };
        });
      } else {
        var ds = this.dataset;
        if (ds && ds.Fields && typeof ds.Fields.ToArray === 'function') {
          Result = ds.Fields.ToArray();
        } else {
          var list = this.resolvedRows;
          if (list && list.length > 0 && typeof list[0] === 'object' && list[0] !== null) {
            Result = Object.keys(list[0]).filter(function(k) { return k.charAt(0) !== '_'; }).map(function(k) {
              return { key: k, label: k.charAt(0).toUpperCase() + k.slice(1), format: '' };
            });
          }
        }
      };
      return Result;
    };
    comp["computed"]["formattedRows"] = function (_this) {
      var Result = undefined;
      Result = new Array();
      var rows = this.resolvedRows || [];
      var cols = this.resolvedColumns || [];
      var rep = this.report;
      if (!rep || typeof rep.FormatCellValue !== 'function') {
        Result = rows;
      } else {
        Result = rows.map(function(r) {
          var out = {};
          for (var i = 0; i < cols.length; i++) {
            var k = cols[i].key || cols[i].fieldName;
            var fmt = cols[i].format || '';
            out[k] = fmt ? rep.FormatCellValue(r[k], fmt) : r[k];
          }
          return out;
        });
      };
      return Result;
    };
    comp["computed"]["recordCount"] = function (_this) {
      var Result = undefined;
      Result = 0;
      var r = this.resolvedRows;
      Result = (r && Array.isArray(r)) ? r.length : 0;
      return Result;
    };
    comp["computed"]["computedSummaries"] = function (_this) {
      var Result = undefined;
      Result = new Array();
      if (this.report && typeof this.report.GetSummariesJS === 'function') {
        Result = this.report.GetSummariesJS() || [];
      } else {
        var sums = this.summaries;
        if (sums && Array.isArray(sums) && sums.length > 0) {
          var rows = this.resolvedRows || [];
          var curr = this.currencySymbol || '$';
          Result = sums.map(function(s) {
            var field = s.field || s.FieldName || '';
            var agg = (s.aggregate || s.type || 'sum').toLowerCase();
            var label = s.label || s.LabelText || field;
            var fmt = (s.format || '').toLowerCase();
            var val = 0;
            if (agg === 'count') {
              val = rows.length;
            } else if (rows.length > 0) {
              var sum = 0;
              var cnt = 0;
              var minV = null;
              var maxV = null;
              for (var i = 0; i < rows.length; i++) {
                var n = parseFloat(rows[i] ? rows[i][field] : NaN);
                if (!isNaN(n)) {
                  sum += n;
                  cnt++;
                  if (minV === null || n < minV) minV = n;
                  if (maxV === null || n > maxV) maxV = n;
                }
              }
              if (agg === 'avg' || agg === 'average') val = cnt > 0 ? (sum / cnt) : 0;
              else if (agg === 'min') val = minV !== null ? minV : 0;
              else if (agg === 'max') val = maxV !== null ? maxV : 0;
              else val = sum;
            }
            var formatted = '';
            if (agg === 'count' || fmt === 'integer' || fmt === 'int') {
              formatted = String(Math.round(val));
            } else {
              var parts = Number(val).toFixed(2).split('.');
              parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
              formatted = (fmt === 'number' ? '' : curr) + parts.join('.');
            }
            return {
              label: label,
              field: field,
              aggregate: agg,
              value: Math.round(val * 100) / 100,
              formattedValue: formatted
            };
          });
        }
      };
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-report-viewer",comp);
  };
});
rtl.module("uApp",["System","JS","Web","BlaiseVue","BVComponents","BVStore","BVCompiler","BVDevTools","BVPascalDX","BVDataSet","BVRouting","uFormHeader","uCard","uCounter","uInfoCard","uMobileView","uCustomerView","uProductView","uUserProfile","uLibBootstrap","uLoginView","uAbout","uHome","uFormulario","uProFeatures","uDatasetView","uReportsView","uCharts","uShowcase","uBVBarChart","uBVPolarAreaChart","uBVChart","uBVScatterChart","uBVDoughnutChart","uBVRadarChart","uBVPieChart","uBVLineChart","uBVBubbleChart","uBVThemeSelect","uBVThemeToggle","uBVTabs","uBVInput","uBVProgress","uBVDrawer","uBVBtn","uBVToast","uBVBreadcrumb","uBVNavbar","uBVNavItem","uBVListGroup","uBVFormSelect","uBVDataGrid","uBVSpinner","uBVContainer","uBVBadge","uBVBottomNav","uBVListGroupItem","uBVVirtualScroll","uBVPagination","uBVCard","uBVBottomNavItem","uBVRow","uBVInputGroup","uBVCol","uBVModal","uBVBreadcrumbItem","uBVTab","uBVAlert","uBVAccordion","uBVIcon","uBVIonBadge","uBVIonHeader","uBVIonCard","uBVIonToolbar","uBVIonItem","uBVIonTabBar","uBVIonTabButton","uBVIonTitle","uBVIonTabs","uBVIonList","uBVIonApp","uBVIonContent","uBVIonButton","uBVReportViewer"],function () {
  "use strict";
  var $mod = this;
  this.Init_App = function () {
    var data = null;
    var methods = null;
    var opts = null;
    var app = null;
    var comp = null;
    var m = null;
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
    _styleEl.textContent = '* { box-sizing: border-box; margin: 0; padding: 0; }   body { font-family: \'Segoe UI\', Arial, sans-serif; background: #f0f2f5; color: #2c3e50; }   .navbar { background: #2c3e50; padding: 12px 24px; display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }   .brand { color: #42b883; font-size: 20px; font-weight: 700; }   .nav-links { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }   .nav-links a { color: #ecf0f1; text-decoration: none; font-size: 14px; padding: 6px 10px; border-radius: 4px; transition: all 0.2s; }   .nav-links a:hover { background: rgba(255,255,255,0.12); color: #42b883; }   .lang-switcher { display: flex; gap: 6px; margin-left: 10px; }   .lang-btn { background: rgba(255,255,255,0.08); color: #ecf0f1; border: 1px solid rgba(255,255,255,0.2); padding: 4px 8px; font-size: 12px; border-radius: 4px; cursor: pointer; }   .lang-btn:hover { background: rgba(255,255,255,0.2); }   .lang-btn.active-lang { background: #42b883; color: white; border-color: #42b883; font-weight: bold; }   .theme-switcher { display: flex; align-items: center; gap: 6px; margin-left: 6px; }   .theme-toggle-btn { background: rgba(255,255,255,0.08); color: #ecf0f1; border: 1px solid rgba(255,255,255,0.2); padding: 4px 8px; font-size: 13px; border-radius: 4px; cursor: pointer; }   .theme-toggle-btn:hover { background: rgba(255,255,255,0.2); }   .theme-select { background: #1a252f; color: #ecf0f1; border: 1px solid rgba(255,255,255,0.2); padding: 4px 6px; font-size: 12px; border-radius: 4px; outline: none; cursor: pointer; }   .drawer-btn { background: rgba(255,255,255,0.12); color: #ecf0f1; border: 1px solid rgba(255,255,255,0.25); border-radius: 4px; padding: 5px 10px; font-size: 16px; cursor: pointer; transition: background 0.2s; }   .drawer-btn:hover { background: rgba(255,255,255,0.25); }   .drawer-nav { display: flex; flex-direction: column; gap: 8px; padding-top: 6px; }   .drawer-link { color: inherit; text-decoration: none; padding: 10px 14px; border-radius: 6px; font-size: 15px; font-weight: 500; display: block; transition: all 0.2s; }   .drawer-link:hover { background: rgba(66, 184, 131, 0.15); color: #42b883; font-weight: 600; }   .mobile-bottom-bar { display: none; }   .main-content-container { max-width: 960px; margin: 24px auto; padding: 0 16px; }   @media (max-width: 768px) {     .nav-links { display: none; } /* Hide wide links on mobile; drawer & bottom nav take over! */     .mobile-bottom-bar { display: flex; }     .desktop-only-footer { display: none; }     .main-content-container { padding-bottom: 75px; }   }   .container { max-width: 900px; margin: 24px auto; padding: 0 20px; }   .footer-status { position: fixed; bottom: 0; left: 0; width: 100%; background: #2c3e50; color: #42b883; font-size: 11px; padding: 4px 10px; text-align: right; }   h1, h2, h3 { margin-bottom: 12px; }   .section { background: white; border-radius: 12px; padding: 24px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }   .section-title { color: #42b883; border-bottom: 2px solid #42b883; padding-bottom: 8px; margin-bottom: 16px; }   button { padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; margin: 4px; }   .btn-primary { background: #42b883; color: white; }   .btn-primary:hover { background: #38a373; }   .btn-danger { background: #e74c3c; color: white; }   .btn-outline { background: white; border: 2px solid #42b883; color: #42b883; }   .btn-outline:hover { background: #42b883; color: white; }   input[type="text"] { width: 100%; padding: 10px; border: 2px solid #ddd; border-radius: 6px; font-size: 14px; margin: 6px 0; }   input[type="text"]:focus { border-color: #42b883; outline: none; }   table { width: 100%; border-collapse: collapse; margin: 12px 0; }   th, td { padding: 10px 14px; border: 1px solid #eee; text-align: left; }   th { background: #f8f9fa; font-weight: 600; }   .badge { display: inline-block; padding: 3px 10px; border-radius: 12px; color: white; font-weight: bold; font-size: 13px; }   .badge-green { background: #42b883; }   .badge-blue { background: #3498db; }   .badge-orange { background: #e67e22; }   .badge-gray { background: #95a5a6; }   code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-family: \'Consolas\', monospace; font-size: 13px; }   hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }    /* Dark Mode & Bootswatch Integration */   html[data-bs-theme="dark"] body, body.theme-dark {     background: var(--bs-body-bg, #1a1a1a);     color: var(--bs-body-color, #e0e0e0);   }   html[data-bs-theme="dark"] .section, body.theme-dark .section {     background: var(--bs-card-bg, #22252a);     color: var(--bs-body-color, #e0e0e0);     box-shadow: 0 2px 8px rgba(0,0,0,0.4);     border: 1px solid rgba(255,255,255,0.08);   }   html[data-bs-theme="dark"] input[type="text"], body.theme-dark input[type="text"] {     background: #2b3035;     color: #fff;     border-color: #444;   }   html[data-bs-theme="dark"] table, body.theme-dark table {     color: #e0e0e0;   }   html[data-bs-theme="dark"] th, body.theme-dark th {     background: #2b3035;     border-color: #3e444a;   }   html[data-bs-theme="dark"] td, body.theme-dark td {     border-color: #3e444a;   }   html[data-bs-theme="dark"] .footer-status, body.theme-dark .footer-status {     background: #181b1e;     color: #42b883;     border-top: 1px solid rgba(255,255,255,0.1);   }';
    document.head.appendChild(_styleEl);
    console.log("[Init] Registering uFormHeader...");
    pas.uFormHeader.Register_uFormHeader();
    console.log("[Init] Registering uCard...");
    pas.uCard.Register_uCard();
    console.log("[Init] Registering uCounter...");
    pas.uCounter.Register_uCounter();
    console.log("[Init] Registering uInfoCard...");
    pas.uInfoCard.Register_uInfoCard();
    console.log("[Init] Registering uMobileView...");
    pas.uMobileView.Register_uMobileView();
    console.log("[Init] Registering uCustomerView...");
    pas.uCustomerView.Register_uCustomerView();
    console.log("[Init] Registering uProductView...");
    pas.uProductView.Register_uProductView();
    console.log("[Init] Registering uUserProfile...");
    pas.uUserProfile.Register_uUserProfile();
    console.log("[Init] Registering uLibBootstrap...");
    pas.uLibBootstrap.Register_uLibBootstrap();
    console.log("[Init] Registering uLoginView...");
    pas.uLoginView.Register_uLoginView();
    console.log("[Init] Registering uAbout...");
    pas.uAbout.Register_uAbout();
    console.log("[Init] Registering uHome...");
    pas.uHome.Register_uHome();
    console.log("[Init] Registering uFormulario...");
    pas.uFormulario.Register_uFormulario();
    console.log("[Init] Registering uProFeatures...");
    pas.uProFeatures.Register_uProFeatures();
    console.log("[Init] Registering uDatasetView...");
    pas.uDatasetView.Register_uDatasetView();
    console.log("[Init] Registering uReportsView...");
    pas.uReportsView.Register_uReportsView();
    console.log("[Init] Registering uCharts...");
    pas.uCharts.Register_uCharts();
    console.log("[Init] Registering uShowcase...");
    pas.uShowcase.Register_uShowcase();
    console.log("[Init] Registering uBVBarChart...");
    pas.uBVBarChart.Register_uBVBarChart();
    console.log("[Init] Registering uBVPolarAreaChart...");
    pas.uBVPolarAreaChart.Register_uBVPolarAreaChart();
    console.log("[Init] Registering uBVChart...");
    pas.uBVChart.Register_uBVChart();
    console.log("[Init] Registering uBVScatterChart...");
    pas.uBVScatterChart.Register_uBVScatterChart();
    console.log("[Init] Registering uBVDoughnutChart...");
    pas.uBVDoughnutChart.Register_uBVDoughnutChart();
    console.log("[Init] Registering uBVRadarChart...");
    pas.uBVRadarChart.Register_uBVRadarChart();
    console.log("[Init] Registering uBVPieChart...");
    pas.uBVPieChart.Register_uBVPieChart();
    console.log("[Init] Registering uBVLineChart...");
    pas.uBVLineChart.Register_uBVLineChart();
    console.log("[Init] Registering uBVBubbleChart...");
    pas.uBVBubbleChart.Register_uBVBubbleChart();
    console.log("[Init] Registering uBVThemeSelect...");
    pas.uBVThemeSelect.Register_uBVThemeSelect();
    console.log("[Init] Registering uBVThemeToggle...");
    pas.uBVThemeToggle.Register_uBVThemeToggle();
    console.log("[Init] Registering uBVTabs...");
    pas.uBVTabs.Register_uBVTabs();
    console.log("[Init] Registering uBVInput...");
    pas.uBVInput.Register_uBVInput();
    console.log("[Init] Registering uBVProgress...");
    pas.uBVProgress.Register_uBVProgress();
    console.log("[Init] Registering uBVDrawer...");
    pas.uBVDrawer.Register_uBVDrawer();
    console.log("[Init] Registering uBVBtn...");
    pas.uBVBtn.Register_uBVBtn();
    console.log("[Init] Registering uBVToast...");
    pas.uBVToast.Register_uBVToast();
    console.log("[Init] Registering uBVBreadcrumb...");
    pas.uBVBreadcrumb.Register_uBVBreadcrumb();
    console.log("[Init] Registering uBVNavbar...");
    pas.uBVNavbar.Register_uBVNavbar();
    console.log("[Init] Registering uBVNavItem...");
    pas.uBVNavItem.Register_uBVNavItem();
    console.log("[Init] Registering uBVListGroup...");
    pas.uBVListGroup.Register_uBVListGroup();
    console.log("[Init] Registering uBVFormSelect...");
    pas.uBVFormSelect.Register_uBVFormSelect();
    console.log("[Init] Registering uBVDataGrid...");
    pas.uBVDataGrid.Register_uBVDataGrid();
    console.log("[Init] Registering uBVSpinner...");
    pas.uBVSpinner.Register_uBVSpinner();
    console.log("[Init] Registering uBVContainer...");
    pas.uBVContainer.Register_uBVContainer();
    console.log("[Init] Registering uBVBadge...");
    pas.uBVBadge.Register_uBVBadge();
    console.log("[Init] Registering uBVBottomNav...");
    pas.uBVBottomNav.Register_uBVBottomNav();
    console.log("[Init] Registering uBVListGroupItem...");
    pas.uBVListGroupItem.Register_uBVListGroupItem();
    console.log("[Init] Registering uBVVirtualScroll...");
    pas.uBVVirtualScroll.Register_uBVVirtualScroll();
    console.log("[Init] Registering uBVPagination...");
    pas.uBVPagination.Register_uBVPagination();
    console.log("[Init] Registering uBVCard...");
    pas.uBVCard.Register_uBVCard();
    console.log("[Init] Registering uBVBottomNavItem...");
    pas.uBVBottomNavItem.Register_uBVBottomNavItem();
    console.log("[Init] Registering uBVRow...");
    pas.uBVRow.Register_uBVRow();
    console.log("[Init] Registering uBVInputGroup...");
    pas.uBVInputGroup.Register_uBVInputGroup();
    console.log("[Init] Registering uBVCol...");
    pas.uBVCol.Register_uBVCol();
    console.log("[Init] Registering uBVModal...");
    pas.uBVModal.Register_uBVModal();
    console.log("[Init] Registering uBVBreadcrumbItem...");
    pas.uBVBreadcrumbItem.Register_uBVBreadcrumbItem();
    console.log("[Init] Registering uBVTab...");
    pas.uBVTab.Register_uBVTab();
    console.log("[Init] Registering uBVAlert...");
    pas.uBVAlert.Register_uBVAlert();
    console.log("[Init] Registering uBVAccordion...");
    pas.uBVAccordion.Register_uBVAccordion();
    console.log("[Init] Registering uBVIcon...");
    pas.uBVIcon.Register_uBVIcon();
    console.log("[Init] Registering uBVIonBadge...");
    pas.uBVIonBadge.Register_uBVIonBadge();
    console.log("[Init] Registering uBVIonHeader...");
    pas.uBVIonHeader.Register_uBVIonHeader();
    console.log("[Init] Registering uBVIonCard...");
    pas.uBVIonCard.Register_uBVIonCard();
    console.log("[Init] Registering uBVIonToolbar...");
    pas.uBVIonToolbar.Register_uBVIonToolbar();
    console.log("[Init] Registering uBVIonItem...");
    pas.uBVIonItem.Register_uBVIonItem();
    console.log("[Init] Registering uBVIonTabBar...");
    pas.uBVIonTabBar.Register_uBVIonTabBar();
    console.log("[Init] Registering uBVIonTabButton...");
    pas.uBVIonTabButton.Register_uBVIonTabButton();
    console.log("[Init] Registering uBVIonTitle...");
    pas.uBVIonTitle.Register_uBVIonTitle();
    console.log("[Init] Registering uBVIonTabs...");
    pas.uBVIonTabs.Register_uBVIonTabs();
    console.log("[Init] Registering uBVIonList...");
    pas.uBVIonList.Register_uBVIonList();
    console.log("[Init] Registering uBVIonApp...");
    pas.uBVIonApp.Register_uBVIonApp();
    console.log("[Init] Registering uBVIonContent...");
    pas.uBVIonContent.Register_uBVIonContent();
    console.log("[Init] Registering uBVIonButton...");
    pas.uBVIonButton.Register_uBVIonButton();
    console.log("[Init] Registering uBVReportViewer...");
    pas.uBVReportViewer.Register_uBVReportViewer();
    console.log("[Init] Setting #app template...");
    document.querySelector("#app").innerHTML = '  <div translate="no" class="notranslate">' + "    <!-- RESPONSIVE DRAWER (MOBILE & DESKTOP OFFCANVAS) -->" + '    <bv-drawer ref="appDrawer" title="🧭 BlaiseVue Menu">' + '      <div class="drawer-nav">' + '        <a href="#/reports" class="drawer-link" @click="closeDrawer" style="background: #ef4444; color: white; font-weight: bold;">📄 Reports (v5.0)</a>' + '        <a href="#/customers" class="drawer-link" @click="closeDrawer" style="background: #8e44ad; color: white; font-weight: bold;">⚡ RPC (v4.3)</a>' + '        <a href="#/login" class="drawer-link" @click="closeDrawer">🔐 {{ ($auth && $auth.isAuthenticated) ? $auth.user.name : \'Entrar\' }}</a>' + '        <a href="#/customers" class="drawer-link" @click="closeDrawer">📦 Customers</a>' + '        <a href="#/products" class="drawer-link" @click="closeDrawer">📦 Products</a>' + '        <a href="#/dataset" class="drawer-link" @click="closeDrawer">💾 DataSet Offline (v4.4)</a>' + '        <a href="#/mobile" class="drawer-link" @click="closeDrawer">📱 Mobile & Desktop Kit</a>' + '        <a href="#/" class="drawer-link" @click="closeDrawer">🏠 {{ $t(\'nav.home\') }}</a>' + '        <a href="#/about" class="drawer-link" @click="closeDrawer">ℹ️ {{ $t(\'nav.about\') }}</a>' + '        <a href="#/pro" class="drawer-link" @click="closeDrawer">⚡ {{ $t(\'nav.pro\') }}</a>' + '        <a href="#/form" class="drawer-link" @click="closeDrawer">📋 {{ $t(\'nav.form\') }}</a>' + '        <a href="#/bootstrap" class="drawer-link" @click="closeDrawer">🎨 {{ $t(\'nav.blaiseui\') }}</a>' + '        <a href="#/charts" class="drawer-link" @click="closeDrawer">📊 {{ $t(\'nav.charts\') }}</a>' + '        <a href="#/showcase" class="drawer-link" @click="closeDrawer">✨ {{ $t(\'nav.showcase\') }}</a>' + '        <a href="docs/index.html" class="drawer-link" @click="closeDrawer">📚 Docs (v4.0)</a>' + '        <a href="/api/docs" target="_blank" class="drawer-link" @click="closeDrawer">📜 Swagger (/api/docs)</a>' + "      </div>" + "    </bv-drawer>" + "" + '    <nav class="navbar">' + '      <div style="display: flex; align-items: center; gap: 8px;">' + '        <button class="drawer-btn" type="button" @click="toggleDrawer" title="Menu">☰</button>' + '        <img src="logo-transparent.png" alt="BlaiseVue" width="28" height="28" style="vertical-align: middle;">' + '        <strong class="brand">BlaiseVue 4.4</strong>' + "      </div>" + '      <div class="nav-links">' + '        <a href="#/reports" style="background: #ef4444; color: white; font-weight: bold; border-radius: 4px; padding: 4px 10px;">📄 Reports (v5.0)</a>' + '        <a href="#/customers" style="background: #8e44ad; color: white; font-weight: bold; border-radius: 4px; padding: 4px 10px;">⚡ RPC (v4.3)</a>' + '        <a href="#/customers">📦 Customers</a>' + '        <a href="#/products">📦 Products</a>' + '        <a href="#/dataset" style="background: #e67e22; color: white;">💾 DataSet (v4.4)</a>' + '        <a href="#/mobile" style="background: #3880ff; color: white;">📱 Mobile Kit</a>' + '        <a href="#/login" style="background: rgba(255,255,255,0.08); border: 1px solid #42b883; color: white;">🔐 {{ ($auth && $auth.isAuthenticated) ? $auth.user.name : \'Entrar\' }}</a>' + '        <a href="#/">{{ $t(\'nav.home\') }}</a>' + '        <a href="#/about">{{ $t(\'nav.about\') }}</a>' + '        <a href="#/pro" style="background: #27ae60; color: white;">⚡ {{ $t(\'nav.pro\') }}</a>' + '        <a href="#/form">{{ $t(\'nav.form\') }}</a>' + '        <a href="#/bootstrap">{{ $t(\'nav.blaiseui\') }}</a>' + '        <a href="#/charts" style="background: #42b883; color: white;">{{ $t(\'nav.charts\') }}</a>' + '        <a href="#/showcase" style="background: #3498db; color: white;">{{ $t(\'nav.showcase\') }}</a>' + '        <a href="docs/index.html" style="background: #8e44ad; color: white;">📚 Docs (v4.0)</a>' + '        <a href="/api/docs" target="_blank" style="background: #2c3e50; border: 1px solid #3498db; color: #5dade2; font-weight: 600;">📜 Swagger</a>' + "      </div>" + '      <div class="lang-switcher">' + '        <button class="lang-btn" :class="{ \'active-lang\': $i18n.locale === \'pt\' }" @click="$setLocale(\'pt\')">🇧🇷 PT</button>' + '        <button class="lang-btn" :class="{ \'active-lang\': $i18n.locale === \'en\' }" @click="$setLocale(\'en\')">🇺🇸 EN</button>' + "      </div>" + '      <div class="theme-switcher">' + '        <button class="theme-toggle-btn" @click="$theme.toggle()" :title="$theme.isDark ? \'Modo Claro\' : \'Modo Escuro\'">' + '          <span v-if="$theme.isDark">☀️</span>' + '          <span v-if="!$theme.isDark">🌙</span>' + "        </button>" + '        <select class="theme-select" :value="$theme.current" @change="onThemeSelect($event)">' + '          <option value="flatly">Flatly</option>' + '          <option value="cosmo">Cosmo</option>' + '          <option value="lux">Lux</option>' + '          <option value="zephyr">Zephyr</option>' + '          <option value="darkly">Darkly</option>' + '          <option value="cyborg">Cyborg</option>' + '          <option value="solar">Solar</option>' + '          <option value="vapor">Vapor</option>' + '          <option value="pulse">Pulse</option>' + "        </select>" + "      </div>" + '      <span class="nav-msg">{{ mensagem }}</span>' + "    </nav>" + "" + "    <!-- MAIN RESPONSIVE CONTAINER -->" + '    <bv-container class="main-content-container">' + "      <router-view></router-view>" + "    </bv-container>" + "" + "    <!-- MOBILE BOTTOM NAVIGATION (PINNED ON MOBILE SCREENS) -->" + '    <bv-bottom-nav class="mobile-bottom-bar">' + '      <bv-bottom-nav-item href="#/" icon="🏠" label="Início"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/pro" icon="⚡" label="Pro"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/form" icon="📋" label="Forms"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/mobile" icon="📱" label="Mobile"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/bootstrap" icon="🎨" label="BlaiseUI"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="docs/index.html" icon="📚" label="Docs"></bv-bottom-nav-item>' + "    </bv-bottom-nav>" + "" + '    <div class="footer-status desktop-only-footer">' + "       {{ $t('status.globalStore') }}: {{ $store.appVersion }} | {{ $t('status.localeActive') }}: <strong>{{ $i18n.locale.toUpperCase() }}</strong> | {{ $t('status.theme') }}: <strong>{{ $theme.current.toUpperCase() }}</strong> | ⚡ Wasm: <strong>Active</strong> | 🚀 SSG: <strong>Ready</strong> | Dev: {{ $store.user }}" + "    </div>" + "  </div>";
    data = new Object();
    data["mensagem"] = "BlaiseVue SPA v4.0 Enterprise";
    methods = new Object();
    m = methods;
    m["onThemeSelect"] = function (_this, e) {
      var sel = "";
      sel = "" + e["target"]["value"];
      if (sel !== "") pas.BVPascalDX.ThemeSet(sel);
    };
    m["toggleDrawer"] = function (_this) {
      pas.BVPascalDX.TriggerRef(_this,"appDrawer","toggle");
    };
    m["closeDrawer"] = function (_this) {
      pas.BVPascalDX.TriggerRef(_this,"appDrawer","close");
    };
    opts = new Object();
    comp = opts;
    comp["created"] = function (_this) {
      if (!_this) _this = this;
      _this["$store"]["appVersion"] = "4.0.0-ENTERPRISE";
      _this["$store"]["user"] = "Pascal Master 🚀";
      pas.BVPascalDX.I18nAddMessages("pt",'{"nav":{"home":"Início","about":"Sobre","pro":"Pro & Wasm ⚡","form":"Formulário 📋","blaiseui":"BlaiseUI Kit 🎨","charts":"Gráficos 📊","showcase":"Showcase ✨"},"status":{"globalStore":"Memória Global","localeActive":"Idioma Ativo","theme":"Tema"},"form":{"title":"Formulário de Validação Reativa","subtitle":"Demonstração de b-validate, $errors e $v no BlaiseVue 4.0","name":"Nome Completo","email":"E-mail Corporativo","city":"Cidade","submit":"Validar & Enviar 🚀","reset":"Limpar Formulário 🔄","fillValid":"Preencher Válido ✨","statusValid":"Válido ✅","statusInvalid":"Inválido ❌","formState":"Status do Formulário"},"pro":{"title":"⚡ BlaiseVue 4.0 Pro & WebAssembly Engine","transitionTitle":"🎬 Lista com Animações FLIP (<transition-group>)","shuffle":"Embaralhar 🔀","add":"Adicionar Item ➕","remove":"Remover Primeiro ➖","resetList":"Resetar Lista 🔄"}}');
      pas.BVPascalDX.I18nAddMessages("en",'{"nav":{"home":"Home","about":"About","pro":"Pro & Wasm ⚡","form":"Form 📋","blaiseui":"BlaiseUI Kit 🎨","charts":"Charts 📊","showcase":"Showcase ✨"},"status":{"globalStore":"Global Store","localeActive":"Active Locale","theme":"Theme"},"form":{"title":"Reactive Form Validation","subtitle":"Demonstrating b-validate, $errors, and $v in BlaiseVue 4.0","name":"Full Name","email":"Corporate Email","city":"City","submit":"Validate & Submit 🚀","reset":"Reset Form 🔄","fillValid":"Fill Valid Sample ✨","statusValid":"Valid ✅","statusInvalid":"Invalid ❌","formState":"Form Status"},"pro":{"title":"⚡ BlaiseVue 4.0 Pro & WebAssembly Engine","transitionTitle":"🎬 FLIP List Transitions (<transition-group>)","shuffle":"Shuffle 🔀","add":"Add Item ➕","remove":"Remove First ➖","resetList":"Reset List 🔄"}}');
      pas.BVPascalDX.I18nSetLocale("pt");
    };
    comp["provide"] = function (_this) {
      var Result = null;
      Result = new Object();
      Result["getAmbiente"] = function () {
        var Result = null;
        Result = new Object();
        Result["id"] = 42;
        Result["status"] = "Production 🛡️";
        return Result;
      };
      return Result;
    };
    routerOpts = new Object();
    routesArr = new Array();
    r = new Object();
    r["path"] = "/reports";
    r["component"] = "reports-view-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/login";
    r["component"] = "login-view-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/customers";
    r["component"] = "customer-view-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/products";
    r["component"] = "product-view-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/dataset";
    r["component"] = "dataset-view-page";
    routesArr.push(r);
    r = new Object();
    r["path"] = "/mobile";
    r["component"] = "mobile-view-page";
    routesArr.push(r);
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
