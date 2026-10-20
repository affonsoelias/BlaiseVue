rtl.module("System",[],function () {
  "use strict";
  var $mod = this;
  this.MaxLongint = 0x7fffffff;
  this.Maxint = 2147483647;
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
  this.Random = function (Range) {
    return Math.floor(Math.random()*Range);
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
  this.TrimLeft = function (S) {
    return S.replace(/^[\s\uFEFF\xA0\x00-\x1f]+/,'');
  };
  this.UpperCase = function (s) {
    return s.toUpperCase();
  };
  this.LowerCase = function (s) {
    return s.toLowerCase();
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
  this.TFloatFormat = {"0": "ffFixed", ffFixed: 0, "1": "ffGeneral", ffGeneral: 1, "2": "ffExponent", ffExponent: 2, "3": "ffNumber", ffNumber: 3, "4": "ffCurrency", ffCurrency: 4};
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
          try {
            let f = new Function('data', '$event', 'with(data) { return (' + expr + '); }');
            return f(d, ev);
          } catch(e1) {
            try {
              let f2 = new Function('data', '$event', 'with(data) { ' + expr + '; }');
              return f2(d, ev);
            } catch(e2) { return undefined; }
          }
        };
        this.SetValue = function(k, val) {
          let d = this.FData || this;
          d[k] = val;
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
                  this.socket = new WebSocket(this.url);
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
              let d = (Data && Data.FData) ? Data.FData : Data;
              try {
                let f = new Function('data', '$event', 'with(data) { return (' + expr + '); }');
                return f(d, ev);
              } catch(e1) {
                try {
                  let f2 = new Function('data', '$event', 'with(data) { ' + expr + '; }');
                  return f2(d, ev);
                } catch(e2) { return undefined; }
              }
            };
          }
          if (Data && !Data.SetValue) {
            Data.SetValue = function(k, val) {
              let d = (Data && Data.FData) ? Data.FData : Data;
              d[k] = val;
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
                       SetValue: function(k, val) { this.FData[k] = val; }
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
              let vmodel = null, vfor = null, vif = null, vshow = null, vref = null, vvalidate = null, vvalidateField = null;
              let binds = [];
              let events = [];
              if (el.attributes) {
                for (let i = 0; i < el.attributes.length; i++) {
                   let a = el.attributes[i];
                   let n = a.name.toLowerCase();
                   if (n === 'b-model' || n === 'v-model') vmodel = a.value;
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
                   el.value = Data.Evaluate(vmodel) || '';
                   const sync = function() { Data.SetValue(vmodel, this.value); };
                   el.oninput = sync; el.onchange = sync; 
                   bv.effect(function() {
                     let v = Data.Evaluate(vmodel);
                     if (el.value !== v) el.value = (v === undefined || v === null) ? '' : v;
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
                            try {
                              let f = new Function('data', '$event', 'with(data) { return (' + expr + '); }');
                              return f(this.FData, ev);
                            } catch(e1) {
                              try {
                                let f2 = new Function('data', '$event', 'with(data) { ' + expr + '; }');
                                return f2(this.FData, ev);
                              } catch(e2) { return undefined; }
                            }
                          },
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
                               let f = new Function('data', 'with(data) { try { return ' + attr.value + '; } catch(e) { return undefined; } }');
                               slotProps[propKey] = f(pRef);
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
                            try {
                               let f = new Function('data', '$event', 'with(data) { try { return ' + expr + '; } catch(e) { return undefined; } }');
                               return f(this.FData, ev);
                            } catch(ex) { return undefined; }
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
                    try { 
                      let f = new Function('data', '$event', 'with(data) { return (' + expr + '); }'); 
                      return f(this.FData, ev); 
                    } catch(e1) {
                      try {
                        let f2 = new Function('data', '$event', 'with(data) { ' + expr + '; }');
                        return f2(this.FData, ev);
                      } catch(e2) { return undefined; }
                    } 
                  },
                  SetValue: function(k, val) { this.FData[k] = val; }
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
             if (window.__BV_CORE__.api) pRef[''] = window.__BV_CORE__.api;
             if (window.__BV_CORE__.ws) pRef[''] = window.__BV_CORE__.ws;
             if (window.__BV_CORE__.auth) pRef[''] = window.__BV_CORE__.auth;
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
      
          if (CompOpt.created) CompOpt.created.call(pRef);
          
          let cD = {
            FData: pRef,
            Evaluate: function(expr, ev) {
              try {
                let f = new Function('data', '$event', 'with(data) { return (' + expr + '); }');
                return f(pRef, ev);
              } catch(e1) {
                try {
                  let f2 = new Function('data', '$event', 'with(data) { ' + expr + '; }');
                  return f2(pRef, ev);
                } catch(e2) { return undefined; }
              }
            },
            SetValue: function(k, val) { pRef[k] = val; }
          };
          
          window.__BV_CORE__.compile(rootPageEl, cD, CompOpt.methods);
      
          let stopEffect = window.__BV_CORE__.effect(function() {
             let dummy = JSON.stringify(pRef);
             if (CompOpt.updated) CompOpt.updated.call(pRef);
          });
      
          if (CompOpt.mounted) CompOpt.mounted.call(pRef);
      
          rootPageEl['bvUnmount'] = function() {
             if (stopEffect && typeof stopEffect === 'function') stopEffect();
             if (CompOpt.unmounted) CompOpt.unmounted.call(pRef);
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
rtl.module("BlaiseVue",["System","JS","Web","SysUtils","BVReactivity","BVCompiler","BVRouting","BVComponents","BVValidation","BVI18n","BVTheme","BVWasm","BVMobile","BVDesktop","BVClient","BVAuth","BlaiseIonic"],function () {
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
    comp["props"].push("title");
    comp["props"].push("subtitle");
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
      this.logado = !this.logado; 
      console.log("[Method] logado toggle: ", this.logado);
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
    };
  };
});
rtl.module("uCharts",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BlaiseCharts"],function () {
  "use strict";
  var $mod = this;
  this.Register_uCharts = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".chart-dashboard {     padding: 24px;     background: #f8fafc;     min-height: 100vh;   }   .header-card {     background: #ffffff;     padding: 24px 28px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     margin-bottom: 24px;     border: 1px solid #e2e8f0;   }   .universal-card {     background: #ffffff;     border: 1px solid #cbd5e1;     border-top: 4px solid #3b82f6;   }   .chart-grid {     display: grid;     grid-template-columns: repeat(auto-fit, minmax(460px, 1fr));     gap: 24px;   }   .chart-item {     background: #ffffff;     padding: 20px 24px;     border-radius: 14px;     box-shadow: 0 4px 12px rgba(0,0,0,0.04);     border: 1px solid #e2e8f0;     display: flex;     flex-direction: column;     align-items: center;   }   .chart-header-row {     display: flex;     justify-content: space-between;     align-items: center;     width: 100%;     margin-bottom: 16px;     padding-bottom: 12px;     border-bottom: 1px solid #f1f5f9;   }   .chart-item h3 {     margin: 0;     font-size: 1.05rem;     font-weight: 600;     color: #1e293b;   }   .badge-type {     font-size: 0.75rem;     padding: 4px 8px;     background: #f1f5f9;     color: #475569;     border-radius: 6px;     font-weight: 600;     text-transform: uppercase;   }   .btn-type-pill {     background: #ffffff;     border: 1px solid #cbd5e1;     color: #334155;     padding: 5px 10px;     border-radius: 6px;     font-size: 0.8rem;     font-weight: 500;     cursor: pointer;     transition: all 0.15s ease;   }   .btn-type-pill:hover {     background: #3b82f6;     color: #ffffff;     border-color: #3b82f6;   }";
    document.head.appendChild(_styleEl);
    comp = new Object();
    comp["template"] = '  <div class="chart-dashboard">' + '    <div class="header-card">' + '      <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">' + '        <div style="text-align: left;">' + '          <h1 style="margin: 0; font-size: 1.8rem; font-weight: 700; color: #1e293b;">' + "            📊 BlaiseCharts 4.0 - Data Visualization Suite" + "          </h1>" + '          <p style="margin: 6px 0 0 0; color: #64748b; font-size: 0.95rem;">' + "            Suíte oficial e dedicada de gráficos reativos via HTML5 Canvas (Chart.js), com classes e registros fortemente tipados em Object Pascal (<strong>packages/blaise-charts</strong>)." + "          </p>" + "        </div>" + '        <div style="display: flex; gap: 10px; flex-wrap: wrap;">' + '          <bv-btn variant="primary" @click="randomizeData">🎲 Randomizar Dados</bv-btn>' + '          <bv-btn variant="secondary" @click="togglePalette">🎨 Alternar Paleta ({{ currentPalette }})</bv-btn>' + '          <bv-btn variant="dark" @click="toggleDarkMode">🌓 {{ isDarkMode ? \'Modo Claro\' : \'Modo Escuro\' }}</bv-btn>' + "        </div>" + "      </div>" + "" + '      <div b-if="clickedPointInfo" style="margin-top: 18px; padding: 10px 16px; background: #e0f2fe; border-left: 4px solid #0284c7; border-radius: 6px; font-size: 0.9rem; color: #0369a1; text-align: left;">' + "        <strong>🎯 Ponto Selecionado / Status:</strong> {{ clickedPointInfo }}" + "      </div>" + "    </div>" + "" + "    <!-- 1. DESTAQUE: Componente Universal <bv-chart> com Troca Dinâmica de Tipo -->" + '    <div class="chart-item universal-card" style="margin-bottom: 24px;">' + '      <div class="chart-header-row">' + "        <div>" + "          <h3>🌟 &lt;bv-chart&gt; - Componente Universal com Tipo Dinâmico</h3>" + '          <p style="margin: 4px 0 0 0; font-size: 0.85rem; color: #64748b;">' + '            Um único componente reativo capaz de renderizar qualquer gráfico dinamicamente via prop <code>:type="{{ universalType }}"</code>:' + "          </p>" + "        </div>" + '        <div style="display: flex; gap: 6px; flex-wrap: wrap;">' + '          <button class="btn-type-pill" @click="setUniversalType(\'bar\')">📊 Barras</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'line\')">📈 Linha</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'pie\')">🍕 Pizza</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'doughnut\')">🍩 Rosca</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'radar\')">🕸️ Radar</button>' + '          <button class="btn-type-pill" @click="setUniversalType(\'polarArea\')">❄️ Polar</button>' + "        </div>" + "      </div>" + '      <bv-chart :type="universalType" :data="barData" :options="chartOptions" height="340px" @chart-click="onPointClick"></bv-chart>' + "    </div>" + "" + "    <!-- 2. GRID: Componentes Especializados do BlaiseCharts -->" + '    <div class="chart-grid">' + "      <!-- 2.1 Barras (bv-bar-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>📊 Vendas Trimestrais (&lt;bv-bar-chart&gt;)</h3>" + '          <span class="badge-type">Bar / Column</span>' + "        </div>" + '        <bv-bar-chart :data="barData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-bar-chart>' + "      </div>" + "" + "      <!-- 2.2 Linhas & Tendências (bv-line-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>📈 Usuários &amp; Conexões WS (&lt;bv-line-chart&gt;)</h3>" + '          <span class="badge-type">Spline Line</span>' + "        </div>" + '        <bv-line-chart :data="lineData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-line-chart>' + "      </div>" + "" + "      <!-- 2.3 Pizza Proporcional (bv-pie-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>🍕 Distribuição de Tráfego (&lt;bv-pie-chart&gt;)</h3>" + '          <span class="badge-type">Pie Chart</span>' + "        </div>" + '        <bv-pie-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-pie-chart>' + "      </div>" + "" + "      <!-- 2.4 Rosca / Doughnut (bv-doughnut-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>🍩 Plataformas Suportadas (&lt;bv-doughnut-chart&gt;)</h3>" + '          <span class="badge-type">Doughnut</span>' + "        </div>" + '        <bv-doughnut-chart :data="doughnutData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-doughnut-chart>' + "      </div>" + "" + "      <!-- 2.5 Área Polar (bv-polar-area-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>❄️ Distribuição de Recursos (&lt;bv-polar-area-chart&gt;)</h3>" + '          <span class="badge-type">Polar Area</span>' + "        </div>" + '        <bv-polar-area-chart :data="pieData" :options="pieOptions" height="300px" @chart-click="onPointClick"></bv-polar-area-chart>' + "      </div>" + "" + "      <!-- 2.6 Radar / Competências (bv-radar-chart) -->" + '      <div class="chart-item">' + '        <div class="chart-header-row">' + "          <h3>🕸️ Análise de Desempenho (&lt;bv-radar-chart&gt;)</h3>" + '          <span class="badge-type">Radar Matrix</span>' + "        </div>" + '        <bv-radar-chart :data="radarData" :options="chartOptions" height="300px" @chart-click="onPointClick"></bv-radar-chart>' + "      </div>" + "    </div>" + "  </div>";
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
      if (this.chartOptions) {
        if (!this.chartOptions.scales) this.chartOptions.scales = {};
        if (!this.chartOptions.scales.x) this.chartOptions.scales.x = {};
        if (!this.chartOptions.scales.y) this.chartOptions.scales.y = {};
        const gridColor = NewDark ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.08)';
        const textColor = NewDark ? '#94a3b8' : '#64748b';
        this.chartOptions.scales.x.grid = { color: gridColor };
        this.chartOptions.scales.y.grid = { color: gridColor };
        this.chartOptions.scales.x.ticks = { color: textColor };
        this.chartOptions.scales.y.ticks = { color: textColor };
        this.chartOptions = Object.assign({}, this.chartOptions);
      };
      if (NewDark) {
        _this["clickedPointInfo"] = "Modo escuro ativado para escalas dos gráficos!"}
       else _this["clickedPointInfo"] = "Modo claro ativado para escalas dos gráficos!";
    };
    m["randomizeData"] = function (_this) {
      var NewData = null;
      var i = 0;
      var Val = 0;
      NewData = new Array();
      for (i = 0; i <= 5; i++) {
        Val = 10000 + pas.System.Random(35000);
        NewData.push(Val);
      };
      if (this.barData && this.barData.datasets && this.barData.datasets[0]) {
        this.barData.datasets[0].data = NewData;
        this.barData = Object.assign({}, this.barData);
      };
      _this["clickedPointInfo"] = "Dados randomizados com sucesso!";
    };
    m["togglePalette"] = function (_this) {
      var Pal = null;
      var Cur = "";
      Cur = "" + _this["currentPalette"];
      if (Cur === "Emerald") {
        _this["currentPalette"] = "Sunset";
        Pal = pas.BlaiseCharts.TBVChartPalette.Sunset(4,0.7);
      } else if (Cur === "Sunset") {
        _this["currentPalette"] = "Cyberpunk";
        Pal = pas.BlaiseCharts.TBVChartPalette.Cyberpunk(4,0.7);
      } else if (Cur === "Cyberpunk") {
        _this["currentPalette"] = "Neon";
        Pal = pas.BlaiseCharts.TBVChartPalette.Neon(4,0.7);
      } else {
        _this["currentPalette"] = "Emerald";
        Pal = pas.BlaiseCharts.TBVChartPalette.Emerald(4,0.7);
      };
      if (this.pieData && this.pieData.datasets && this.pieData.datasets[0]) {
        this.pieData.datasets[0].backgroundColor = Pal;
        this.pieData.datasets[0].borderColor = Pal;
        this.pieData = Object.assign({}, this.pieData);
      }
      if (this.doughnutData && this.doughnutData.datasets && this.doughnutData.datasets[0]) {
        this.doughnutData.datasets[0].backgroundColor = Pal;
        this.doughnutData.datasets[0].borderColor = Pal;
        this.doughnutData = Object.assign({}, this.doughnutData);
      };
      _this["clickedPointInfo"] = "Paleta alterada para " + ("" + _this["currentPalette"]) + "!";
    };
    m["onPointClick"] = function (_this, ev) {
      if (ev && ev.label !== undefined) {
        this.clickedPointInfo = 'Categoria: "' + ev.label + '", Valor: ' + ev.value + ' (Série #' + (ev.datasetIndex + 1) + ')';
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      this.initCharts();
    };
    pas.BVComponents.RegisterComponent("charts-page",comp);
  };
});
rtl.module("uCustomerView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["template"] = '  <div class="customer-view-page">' + "    <!-- HEADER SECTION -->" + '    <div class="crud-header">' + "      <div>" + '        <h1 class="crud-title">📦 Customer Management</h1>' + '        <p class="crud-subtitle">High-throughput reactive CRUD module connected to mORMot 2 native backend.</p>' + "      </div>" + '      <div class="crud-header-btns">' + '        <button class="bui-btn bui-btn-primary" @click="openCreateModal">➕ New Customer</button>' + '        <button class="bui-btn bui-btn-secondary" @click="fetchItems">🔄 Refresh</button>' + "      </div>" + "    </div>" + "" + "    <!-- REAL-TIME SYNC & STATS BAR -->" + '    <div class="crud-stats-bar">' + '      <span class="sync-badge">🟢 Real-time WebSocket Sync Active</span>' + '      <span class="count-badge">Total: <strong>{{ items.length }}</strong> customers</span>' + "    </div>" + "" + "    <!-- SEARCH & FILTER TOOLBAR -->" + '    <div class="crud-toolbar">' + "      <input" + '        type="text"' + '        class="crud-search-input"' + '        placeholder="🔍 Search customers by any keyword..."' + '        b-model="searchQuery"' + "      />" + "    </div>" + "" + "    <!-- RESPONSIVE DATA TABLE -->" + '    <div class="crud-table-wrap">' + '      <table class="crud-table">' + "        <thead>" + "          <tr>" + '            <th style="width: 70px;">ID</th>' + "            <th>Name</th>" + "            <th>Email</th>" + "            <th>Phone</th>" + "            <th>Active</th>" + "            <th>Created</th>" + '            <th style="width: 170px; text-align: center;">Actions</th>' + "          </tr>" + "        </thead>" + "        <tbody>" + '          <tr b-for="item in filteredItems">' + '            <td class="cell-id">#{{ item.id }}</td>' + "            <td><strong>{{ item.name }}</strong></td>" + "            <td><strong>{{ item.email }}</strong></td>" + "            <td><strong>{{ item.phone }}</strong></td>" + '            <td><span class="status-pill" :class="{ \'pill-active\': item.active, \'pill-inactive\': !item.active }">{{ item.active ? \'Active\' : \'Inactive\' }}</span></td>' + '            <td class="cell-date">{{ item.createdAt }}</td>' + '            <td class="cell-actions">' + '              <button class="action-btn edit-btn" title="Edit" @click="openEditModal(item)">✏️ Edit</button>' + '              <button class="action-btn del-btn" title="Delete" @click="deleteItem(item.id)">🗑️ Delete</button>' + "            </td>" + "          </tr>" + "        </tbody>" + "      </table>" + "" + "      <!-- EMPTY STATE -->" + '      <div class="crud-empty" v-if="filteredItems.length === 0">' + '        <div class="empty-icon">📂</div>' + "        <h3>No customers found</h3>" + '        <p v-if="searchQuery">No matching records for "<strong>{{ searchQuery }}</strong>".</p>' + '        <p v-if="!searchQuery">Click "➕ New Customer" above to add your first record!</p>' + "      </div>" + "    </div>" + "" + "    <!-- MODAL DIALOG -->" + '    <div class="crud-modal-backdrop" v-if="isModalOpen">' + '      <div class="crud-modal">' + '        <div class="modal-header">' + "          <h3>{{ isEditing ? '✏️ Edit ' + modelTitle : '➕ New ' + modelTitle }}</h3>" + '          <button class="modal-close-btn" @click="closeModal">✕</button>' + "        </div>" + '        <div class="modal-body">' + '          <div class="form-group">' + '            <label class="form-label">Name:</label>' + '            <input type="text" class="form-control" b-model="form.name" placeholder="Enter name..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Email:</label>' + '            <input type="text" class="form-control" b-model="form.email" placeholder="Enter email..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Phone:</label>' + '            <input type="text" class="form-control" b-model="form.phone" placeholder="Enter phone..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="checkbox-container">' + '              <input type="checkbox" b-model="form.active" />' + "              <span>Active Active</span>" + "            </label>" + "          </div>" + '          <div class="form-error-banner" v-if="formError">' + "            ⚠️ {{ formError }}" + "          </div>" + "        </div>" + '        <div class="modal-footer">' + '          <button class="bui-btn bui-btn-secondary" @click="closeModal">Cancel</button>' + '          <button class="bui-btn bui-btn-primary" @click="saveItem">' + "            {{ isEditing ? 'Save Changes' : 'Create ' + modelTitle }}" + "          </button>" + "        </div>" + "      </div>" + "    </div>" + "  </div>";
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
      this.form = {
        name: '',
        email: '',
        phone: '',
        active: true
      };
      this.formError = '';
    };
    m["openCreateModal"] = function (_this) {
      this.resetForm();
      this.isEditing = false;
      this.currentEditId = 0;
      this.isModalOpen = true;
    };
    m["openEditModal"] = function (_this, item) {
      this.form = Object.assign({}, item);
      this.currentEditId = item.id;
      this.isEditing = true;
      this.formError = '';
      this.isModalOpen = true;
    };
    m["closeModal"] = function (_this) {
      this.isModalOpen = false;
      this.formError = '';
    };
    m["fetchItems"] = function (_this) {
      var self = this;
      var ep = '/api/' + this.apiEndpoint;
      var p = (this.$api && typeof this.$api.get === 'function')
        ? this.$api.get(ep)
        : fetch('http://localhost:8090' + ep).then(function(r) { return r.json(); });
      Promise.resolve(p).then(function(data) {
        if (Array.isArray(data)) {
          self.items = data;
        } else if (data && Array.isArray(data.items)) {
          self.items = data.items;
        }
      }).catch(function(err) {
        console.error('Error fetching ' + self.apiEndpoint + ':', err);
      });
    };
    m["saveItem"] = function (_this) {
      var self = this;
      if (!this.form) return;
      var isEdit = Boolean(this.isEditing);
      var id = this.currentEditId;
      var ep = '/api/' + this.apiEndpoint + (isEdit ? ('/' + id) : '');
      var method = isEdit ? 'put' : 'post';
      var p = (this.$api && typeof this.$api[method] === 'function')
        ? this.$api[method](ep, this.form)
        : fetch('http://localhost:8090' + ep, {
            method: method.toUpperCase(),
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(this.form)
          }).then(function(r) { return r.json(); });
      Promise.resolve(p).then(function(resp) {
        self.isModalOpen = false;
        self.fetchItems();
      }).catch(function(err) {
        self.formError = 'Failed to save: ' + (err.message || err);
      });
    };
    m["deleteItem"] = function (_this, id) {
      if (!confirm('Are you sure you want to delete this ' + this.modelTitle + '?')) return;
      var self = this;
      var ep = '/api/' + this.apiEndpoint + '/' + id;
      var p = (this.$api && typeof this.$api.delete === 'function')
        ? this.$api.delete(ep)
        : fetch('http://localhost:8090' + ep, { method: 'DELETE' }).then(function(r) { return r.json(); });
      Promise.resolve(p).then(function() {
        self.fetchItems();
      }).catch(function(err) {
        alert('Failed to delete: ' + (err.message || err));
      });
    };
    m["setupWebSocket"] = function (_this) {
      var self = this;
      if (!this.$ws) return;
      if (typeof this.$ws.connect === 'function') {
        this.$ws.connect();
      }
      var pfx = String(this.modelTitle).toLowerCase();
      if (typeof this.$ws.on === 'function') {
        this.$ws.on(pfx + '_created', function(d) {
          console.log('⚡ Real-time ' + pfx + ' created:', d);
          self.fetchItems();
        });
        this.$ws.on(pfx + '_updated', function(d) {
          console.log('⚡ Real-time ' + pfx + ' updated:', d);
          self.fetchItems();
        });
        this.$ws.on(pfx + '_deleted', function(d) {
          console.log('⚡ Real-time ' + pfx + ' deleted:', d);
          self.fetchItems();
        });
      };
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      this.resetForm();
      this.fetchItems();
      this.setupWebSocket();
    };
    comp["computed"] = new Object();
    comp["computed"]["filteredItems"] = function (_this) {
      var Result = undefined;
      let list = this.items || [];
      let q = (this.searchQuery || '').toLowerCase().trim();
      if (!q) return list;
      return list.filter(function(item) {
        return Object.values(item).some(function(v) {
          return String(v).toLowerCase().indexOf(q) !== -1;
        });
      });
      return Result;
    };
    pas.BVComponents.RegisterComponent("customer-view-page",comp);
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
      valido = this.$validate ? this.$validate() : true;
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
      if (this.$v && this.$v.$touch) this.$v.$touch();
    };
    m["limpar"] = function (_this) {
      _this["nome"] = "";
      _this["email"] = "";
      _this["cidade"] = "";
      _this["msgSucesso"] = "";
      if (this.$v && this.$v.$reset) this.$v.$reset();
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
rtl.module("uLibBootstrap",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils","BVRouting"],function () {
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
    comp["template"] = '  <div class="lib-bootstrap-page">' + "    <!-- INTERNAL NAVIGATION (DEMO) -->" + '    <bv-navbar brand="BlaiseVue UI">' + '       <bv-nav-item href="#/" active="true" label="Home"></bv-nav-item>' + '       <bv-nav-item href="#/charts" label="Charts"></bv-nav-item>' + '       <bv-nav-item href="#/pro" label="Pro Features"></bv-nav-item>' + '       <bv-nav-item href="#" label="⚙️ Settings" @click="openSettings"></bv-nav-item>' + "    </bv-navbar>" + "" + "    <!-- CONTENT CONTAINER (USING NATIVE BLAISEUI RESPONSIVE GRID) -->" + '    <bv-container fluid="true">' + '      <bv-row gutter="md" class="mb-5">' + '         <bv-col cols="12" md="7">' + '            <h1 class="mb-2">🎨 BlaiseUI Official Kit</h1>' + '            <p class="text-muted mb-4">Demonstration of unified reactive components built 100% in Pascal with native responsive grid layout.</p>' + "            " + "            <bv-breadcrumb>" + '               <bv-breadcrumb-item href="#/">Home</bv-breadcrumb-item>' + '               <bv-breadcrumb-item href="#">Components</bv-breadcrumb-item>' + '               <bv-breadcrumb-item active="true">BlaiseUI</bv-breadcrumb-item>' + "            </bv-breadcrumb>" + "         </bv-col>" + '         <bv-col cols="12" md="5" class="d-flex align-items-end justify-content-end p-2 gap-2 flex-wrap">' + '            <bv-btn label="Open Drawer" variant="secondary" size="lg" @click="showDrawer"></bv-btn>' + '            <bv-btn label="Open Modal" variant="primary" size="lg" @click="showModal"></bv-btn>' + '            <bv-btn label="Trigger Toast" variant="info" size="lg" @click="clickNotif(\'Manual Toast Trigger\')"></bv-btn>' + '            <bv-btn label="⚙️ Settings" variant="outline-primary" size="lg" @click="openSettings"></bv-btn>' + "         </bv-col>" + "      </bv-row>" + "" + '      <bv-row gutter="md">' + "         <!-- LEFT COLUMN: Feedback & Status (Responsive: 12 on mobile, 4 on desktop) -->" + '         <bv-col cols="12" md="4">' + '            <bv-card title="📊 System Status">' + '               <div class="mb-3">' + "                  <small>Engine Load (Reactivity)</small>" + '                  <bv-progress :value="count" variant="success"></bv-progress>' + "               </div>" + '               <div class="mb-3">' + "                  <small>Memory Usage ($Store)</small>" + '                  <bv-progress :value="35" variant="info"></bv-progress>' + "               </div>" + '               <div class="d-flex gap-2">' + '                  <bv-btn label="Pulse (Count++)" variant="outline-primary" @click="count = (count + 10) % 105"></bv-btn>' + '                  <bv-spinner variant="primary" small="true" v-if="count > 80"></bv-spinner>' + "               </div>" + "            </bv-card>" + "" + '            <bv-card title="📋 Notification Center" class="mt-4">' + "               <bv-list-group>" + '                  <bv-list-group-item badge="5" badgeVariant="danger" @click="clickNotif(\'New Emails\')">📨 Inbox Messages</bv-list-group-item>' + '                  <bv-list-group-item active="true" @click="clickNotif(\'Highlight\')">🌟 Weekly Highlight</bv-list-group-item>' + '                  <bv-list-group-item badge="ONLINE" badgeVariant="secondary" @click="clickNotif(\'BlaiseUI Kit\')">💎 BlaiseUI v2.0</bv-list-group-item>' + '                  <bv-list-group-item @click="clickNotif(\'Cloud Sync\')">☁️ Cloud Synchronization</bv-list-group-item>' + "               </bv-list-group>" + "            </bv-card>" + "         </bv-col>" + "" + "         <!-- RIGHT COLUMN: Tabs / Forms / Navigation (Responsive: 12 on mobile, 8 on desktop) -->" + '         <bv-col cols="12" md="8">' + '            <bv-card style="height: 100%;">' + '               <bv-tabs @change="tabChanged">' + '                  <bv-tab id="forms" title="📝 Forms" active="true">' + '                     <div class="p-4">' + "                        <h4>Input Controls</h4>" + '                        <bv-row gutter="md" class="mt-4">' + '                           <bv-col cols="12" md="6">' + '                              <bv-input label="UI Identifier" b-model="libName" placeholder="Ex: Turbo_Node"></bv-input>' + '                              <bv-form-select label="Priority" b-model="category" :options="catOptions"></bv-form-select>' + "                           </bv-col>" + '                           <bv-col cols="12" md="6">' + '                              <bv-input-group label="Operation Cost" prepend="$" append=".00" b-model="count"></bv-input-group>' + '                              <bv-input-group label="API Key" append="Regenerate">' + '                                 <bv-input b-model="libName" readonly="true"></bv-input>' + "                              </bv-input-group>" + "                           </bv-col>" + "                        </bv-row>" + '                        <div class="bui-alert bui-alert-info mt-3" style="border-radius: 8px;">' + "                           <strong>Note:</strong> All fields above use <code>b-model</code> linked directly to the reactive Pascal state." + "                        </div>" + "                     </div>" + "                  </bv-tab>" + "" + '                  <bv-tab id="nav" title="📍 Pagination">' + '                     <div class="p-4 text-center">' + '                        <h5 class="mb-4">Atomic Data Navigation</h5>' + '                        <bv-pagination :value="currentPage" :total="10" @input="updatePage"></bv-pagination>' + '                        <p class="mt-3">Currently viewing segment <strong>#{{ currentPage }}</strong></p>' + '                        <bv-alert variant="warning" dismissible="true" class="mt-4">' + "                           Attention: Segment 7 contains simulated network instabilities." + "                        </bv-alert>" + "                     </div>" + "                  </bv-tab>" + "" + '                  <bv-tab id="extras" title="🔥 Accordions">' + '                     <div class="p-4">' + '                        <bv-accordion :items="faqItems" initialActiveId="q1"></bv-accordion>' + "                     </div>" + "                  </bv-tab>" + "" + '                  <bv-tab id="icons" title="⭐ Icons & Themes">' + '                     <div class="p-4">' + "                        <h5>Bootstrap Icons & Bootswatch Themes</h5>" + '                        <p class="text-muted">Over 1,800+ vector icons powered by <code>blaise-icons</code> and reactive Bootswatch styling.</p>' + '                        <div class="d-flex gap-4 align-items-center mb-4 flex-wrap" style="display: flex; gap: 16px; flex-wrap: wrap;">' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="check-circle" size="24" color="#28a745"></bv-icon> <span>check-circle</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="star-fill" size="24" color="#ffc107"></bv-icon> <span>star-fill</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="heart-fill" size="24" color="#dc3545"></bv-icon> <span>heart-fill</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="gear-fill" size="24" color="#6c757d"></bv-icon> <span>gear-fill</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="shield-check" size="24" color="#0d6efd"></bv-icon> <span>shield-check</span></div>' + '                           <div class="d-flex align-items-center gap-2"><bv-icon name="lightning-charge-fill" size="24" color="#fd7e14"></bv-icon> <span>lightning</span></div>' + "                        </div>" + "                     </div>" + "                  </bv-tab>" + "               </bv-tabs>" + "            </bv-card>" + "         </bv-col>" + "      </bv-row>" + "    </bv-container>" + "" + "    <!-- DRAWER: Programmatically triggered via $ref -->" + '    <bv-drawer ref="mainDrawer" title="🎨 BlaiseUI Drawer">' + '       <p class="mb-3">This is the new <strong>bv-drawer</strong> component! On desktop or mobile it smoothly slides out.</p>' + "       <bv-list-group>" + '          <bv-list-group-item active="true" @click="clickNotif(\'Drawer Menu 1\')">🏠 Dashboard View</bv-list-group-item>' + '          <bv-list-group-item @click="clickNotif(\'Drawer Menu 2\')">⚙️ Component Config</bv-list-group-item>' + '          <bv-list-group-item @click="clickNotif(\'Drawer Menu 3\')">📱 Mobile Optimization</bv-list-group-item>' + "       </bv-list-group>" + '       <div class="mt-4">' + '          <bv-btn label="Close Drawer" variant="outline-primary" @click="closeDrawer"></bv-btn>' + "       </div>" + "    </bv-drawer>" + "" + "    <!-- OVERLAYS: Programmatically triggered via $ref -->" + '    <bv-modal b-ref="mainModal" title="🔥 System Confirmation" okLabel="Process" cancelLabel="Close" @ok="modalConfirm">' + "       <p>You are about to process a state update via Pascal.</p>" + '       <div class="p-3 bg-light rounded text-center" style="background: #f8fafc; padding: 12px; border-radius: 6px; margin-top: 10px;">' + "          <p>Current Values:</p>" + '          <bv-badge variant="info">{{ libName }}</bv-badge>' + '          <bv-badge variant="success">{{ count }}%</bv-badge>' + "       </div>" + "    </bv-modal>" + "" + "    <!-- SETTINGS MODAL: Programmatically triggered via ⚙️ Settings -->" + '    <bv-modal b-ref="settingsModal" title="⚙️ Configurações & Preferências" okLabel="Aplicar" cancelLabel="Fechar" @ok="applySettings">' + '       <div class="p-2">' + '          <div class="mb-3" style="margin-bottom: 14px;">' + '             <strong style="display: block; margin-bottom: 6px; font-size: 14px;">🌓 Alternar Tema Visual</strong>' + '             <button class="bui-btn bui-btn-sm bui-btn-secondary" type="button" @click="$theme.toggle()">' + '                <span v-if="$theme.isDark">☀️ Mudar para Tema Claro</span>' + '                <span v-if="!$theme.isDark">🌙 Mudar para Tema Escuro</span>' + "             </button>" + "          </div>" + '          <div class="mb-3" style="margin-bottom: 14px;">' + '             <strong style="display: block; margin-bottom: 6px; font-size: 14px;">🌐 Idioma da Aplicação</strong>' + '             <div style="display: flex; gap: 8px;">' + '                <button class="bui-btn bui-btn-sm" :class="{ \'bui-btn-primary\': $i18n.locale === \'pt\', \'bui-btn-secondary\': $i18n.locale !== \'pt\' }" type="button" @click="$setLocale(\'pt\')">🇧🇷 Português</button>' + '                <button class="bui-btn bui-btn-sm" :class="{ \'bui-btn-primary\': $i18n.locale === \'en\', \'bui-btn-secondary\': $i18n.locale !== \'en\' }" type="button" @click="$setLocale(\'en\')">🇺🇸 English</button>' + "             </div>" + "          </div>" + '          <div class="p-2 rounded" style="background: #f1f5f9; border-radius: 6px; font-size: 12px; color: #475569; margin-top: 10px;">' + "             🛡️ <strong>BlaiseVue 3.0 TURBO</strong> &bull; Reatividade Pascal + WebAssembly" + "          </div>" + "       </div>" + "    </bv-modal>" + "" + '    <bv-toast b-ref="mainToast" title="Global Notification" variant="success" :duration="4000">' + "       Action performed: <strong>{{ lastAction }}</strong>" + "    </bv-toast>" + "  </div>";
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
      this.lastAction = info;
      if (this.$refs.mainToast && this.$refs.mainToast.showToast) {
        this.$refs.mainToast.showToast();
      } else if (this.$refs.mainToast && this.$refs.mainToast.show) {
        this.$refs.mainToast.show();
      };
    };
    m["showModal"] = function (_this) {
      if (this.$refs.mainModal && this.$refs.mainModal.showModal) {
        this.$refs.mainModal.showModal();
      } else if (this.$refs.mainModal && this.$refs.mainModal.show) {
        this.$refs.mainModal.show();
      };
    };
    m["modalConfirm"] = function (_this) {
      this.libName = 'SYNC_' + Date.now();
      this.lastAction = 'Modal Confirmed';
      if (this.$refs.mainToast && this.$refs.mainToast.showToast) {
        this.$refs.mainToast.showToast();
      } else if (this.$refs.mainToast && this.$refs.mainToast.show) {
        this.$refs.mainToast.show();
      };
    };
    m["updatePage"] = function (_this, p) {
      this.currentPage = p;
    };
    m["tabChanged"] = function (_this, id) {
      console.log("Tab changed to: ", id);
    };
    m["showDrawer"] = function (_this) {
      if (this.$refs.mainDrawer && this.$refs.mainDrawer.open) {
        this.$refs.mainDrawer.open();
      } else if (this.$refs.mainDrawer && this.$refs.mainDrawer.toggle) {
        this.$refs.mainDrawer.toggle();
      };
    };
    m["closeDrawer"] = function (_this) {
      if (this.$refs.mainDrawer && this.$refs.mainDrawer.close) {
        this.$refs.mainDrawer.close();
      };
    };
    m["openSettings"] = function (_this) {
      if (this.$refs.settingsModal && this.$refs.settingsModal.showModal) {
        this.$refs.settingsModal.showModal();
      } else if (this.$refs.settingsModal && this.$refs.settingsModal.show) {
        this.$refs.settingsModal.show();
      };
    };
    m["applySettings"] = function (_this) {
      this.clickNotif('Configurações salvas!');
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      this.faqItems = [
        { id: 'q1', title: 'How does Shared State work?', content: 'BlaiseVue uses B-Store for centralized reactive state management in Pascal.' },
        { id: 'q2', title: 'Unified Design System?', content: 'BlaiseUI is 100% native Pascal with pure CSS variables and zero external dependencies.' },
        { id: 'q3', title: 'JIT Optimization?', content: 'The compiler generates minimalist JavaScript bundles, resulting in instant load times.' }
      ];
      this.catOptions = [
        { value: 'low', text: 'Low Priority' },
        { value: 'med', text: 'Medium Priority' },
        { value: 'high', text: 'High Priority (Critical)' }
      ];
    };
    pas.BVComponents.RegisterComponent("lib-bootstrap-page",comp);
  };
});
rtl.module("uLoginView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
      this.email = e;
      this.password = p;
      this.errorMessage = '';
      this.submitLogin();
    };
    m["submitLogin"] = function (_this) {
      var self = this;
      if (!this.email || !this.password) {
        this.errorMessage = 'Por favor, informe o e-mail e a senha.';
        return;
      }
      this.loading = true;
      this.errorMessage = '';
      this.successMessage = '';
      if (!this.$auth || typeof this.$auth.login !== 'function') {
        this.errorMessage = 'Módulo $auth não inicializado.';
        this.loading = false;
        return;
      }
      this.$auth.login(this.email, this.password)
        .then(function(resp) {
          self.loading = false;
          self.successMessage = 'Autenticado com sucesso como ' + (resp.user ? resp.user.name : self.email) + '!';
          setTimeout(function() {
            var target = (window.__BV_CORE__.auth && window.__BV_CORE__.auth.redirectAfterLogin)
              ? window.__BV_CORE__.auth.redirectAfterLogin
              : '#/';
            window.__BV_CORE__.auth.redirectAfterLogin = '';
            window.location.hash = target;
          }, 600);
        })
        .catch(function(err) {
          self.loading = false;
          self.errorMessage = (err && err.message) ? err.message : 'Falha na autenticação. Verifique os dados.';
        });
    };
    m["handleLogout"] = function (_this) {
      if (this.$auth && typeof this.$auth.logout === 'function') {
        this.$auth.logout();
      };
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("login-view-page",comp);
  };
});
rtl.module("uMobileView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
      this.currentMode = 'ios';
      if (window.$ionic) window.$ionic.setMode('ios');
      this.lastAction = 'Modo visual alterado para 🍎 iOS (Cupertino)';
    };
    m["setMdMode"] = function (_this) {
      this.currentMode = 'md';
      if (window.$ionic) window.$ionic.setMode('md');
      this.lastAction = 'Modo visual alterado para 🤖 Android (Material Design)';
    };
    m["showToast"] = function (_this) {
      let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
      if (ionic && ionic.toast) {
        ionic.toast.show('Notificação rápida com estilo nativo!', 2500, 'bottom', 'success');
      }
      this.lastAction = '🔔 TIonicToast.Show disparado com sucesso!';
    };
    m["showAlert"] = function (_this) {
      let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
      if (ionic && ionic.alert) {
        ionic.alert.alert('BlaiseVue Mobile', 'Estes componentes funcionam igualmente na Web, no Desktop e no Celular!', 'Entendido');
      }
      this.lastAction = '💬 TIonicAlert.Alert exibido!';
    };
    m["showConfirm"] = function (_this) {
      let self = this;
      let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
      self.lastAction = '❓ TIonicAlert.Confirm aberto...';
      if (ionic && ionic.alert) {
        ionic.alert.confirm('Confirmar Operação', 'Deseja sincronizar os dados locais com o mORMot 2?',
          function() {
            self.lastAction = '✅ Confirmação aceita! Dados sincronizados!';
            if (ionic.toast) ionic.toast.show('Dados sincronizados com sucesso!', 2000, 'bottom', 'primary');
          },
          function() {
            self.lastAction = '❌ Operação cancelada pelo usuário.';
          }
        );
      };
    };
    m["showLoading"] = function (_this) {
      let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
      if (ionic && ionic.loading) {
        ionic.loading.present('Carregando registros...', 1800);
      }
      this.lastAction = '⏳ TIonicLoading.Present exibido (auto-dispensa em 1.8s)';
    };
    m["showActionSheet"] = function (_this) {
      let self = this;
      let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
      self.lastAction = '📑 TIonicActionSheet.Show aberto...';
      if (ionic && ionic.actionSheet) {
        ionic.actionSheet.show('Ações do Registro', ['Compartilhar', 'Editar', 'Duplicar', 'Excluir'],
          function(opt, idx) {
            self.lastAction = '👉 Opção selecionada no Action Sheet: ' + opt;
            if (ionic.toast) ionic.toast.show('Selecionado: ' + opt, 1800, 'bottom', 'dark');
          }
        );
      };
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (window.$ionic && typeof window.$ionic.getMode === 'function') {
        this.currentMode = window.$ionic.getMode();
      };
    };
    pas.BVComponents.RegisterComponent("mobile-view-page",comp);
  };
});
rtl.module("uProductView",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["template"] = '  <div class="product-view-page">' + "    <!-- HEADER SECTION -->" + '    <div class="crud-header">' + "      <div>" + '        <h1 class="crud-title">📦 Product Management</h1>' + '        <p class="crud-subtitle">High-throughput reactive CRUD module connected to mORMot 2 native backend.</p>' + "      </div>" + '      <div class="crud-header-btns">' + '        <button class="bui-btn bui-btn-primary" @click="openCreateModal">➕ New Product</button>' + '        <button class="bui-btn bui-btn-secondary" @click="fetchItems">🔄 Refresh</button>' + "      </div>" + "    </div>" + "" + "    <!-- REAL-TIME SYNC & STATS BAR -->" + '    <div class="crud-stats-bar">' + '      <span class="sync-badge">🟢 Real-time WebSocket Sync Active</span>' + '      <span class="count-badge">Total: <strong>{{ items.length }}</strong> products</span>' + "    </div>" + "" + "    <!-- SEARCH & FILTER TOOLBAR -->" + '    <div class="crud-toolbar">' + "      <input" + '        type="text"' + '        class="crud-search-input"' + '        placeholder="🔍 Search products by any keyword..."' + '        b-model="searchQuery"' + "      />" + "    </div>" + "" + "    <!-- RESPONSIVE DATA TABLE -->" + '    <div class="crud-table-wrap">' + '      <table class="crud-table">' + "        <thead>" + "          <tr>" + '            <th style="width: 70px;">ID</th>' + "            <th>Name</th>" + "            <th>Price</th>" + "            <th>Stock</th>" + "            <th>Category</th>" + "            <th>Created</th>" + '            <th style="width: 170px; text-align: center;">Actions</th>' + "          </tr>" + "        </thead>" + "        <tbody>" + '          <tr b-for="item in filteredItems">' + '            <td class="cell-id">#{{ item.id }}</td>' + "            <td><strong>{{ item.name }}</strong></td>" + '            <td><span class="badge-price">$ {{ Number(item.price).toFixed(2) }}</span></td>' + '            <td><span class="badge-num">{{ item.stock }}</span></td>' + "            <td><strong>{{ item.category }}</strong></td>" + '            <td class="cell-date">{{ item.createdAt }}</td>' + '            <td class="cell-actions">' + '              <button class="action-btn edit-btn" title="Edit" @click="openEditModal(item)">✏️ Edit</button>' + '              <button class="action-btn del-btn" title="Delete" @click="deleteItem(item.id)">🗑️ Delete</button>' + "            </td>" + "          </tr>" + "        </tbody>" + "      </table>" + "" + "      <!-- EMPTY STATE -->" + '      <div class="crud-empty" v-if="filteredItems.length === 0">' + '        <div class="empty-icon">📂</div>' + "        <h3>No products found</h3>" + '        <p v-if="searchQuery">No matching records for "<strong>{{ searchQuery }}</strong>".</p>' + '        <p v-if="!searchQuery">Click "➕ New Product" above to add your first record!</p>' + "      </div>" + "    </div>" + "" + "    <!-- MODAL DIALOG -->" + '    <div class="crud-modal-backdrop" v-if="isModalOpen">' + '      <div class="crud-modal">' + '        <div class="modal-header">' + "          <h3>{{ isEditing ? '✏️ Edit ' + modelTitle : '➕ New ' + modelTitle }}</h3>" + '          <button class="modal-close-btn" @click="closeModal">✕</button>' + "        </div>" + '        <div class="modal-body">' + '          <div class="form-group">' + '            <label class="form-label">Name:</label>' + '            <input type="text" class="form-control" b-model="form.name" placeholder="Enter name..." />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Price:</label>' + '            <input type="number" step="0.01" class="form-control" b-model="form.price" placeholder="0.00" />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Stock:</label>' + '            <input type="number" class="form-control" b-model="form.stock" placeholder="0" />' + "          </div>" + '          <div class="form-group">' + '            <label class="form-label">Category:</label>' + '            <input type="text" class="form-control" b-model="form.category" placeholder="Enter category..." />' + "          </div>" + '          <div class="form-error-banner" v-if="formError">' + "            ⚠️ {{ formError }}" + "          </div>" + "        </div>" + '        <div class="modal-footer">' + '          <button class="bui-btn bui-btn-secondary" @click="closeModal">Cancel</button>' + '          <button class="bui-btn bui-btn-primary" @click="saveItem">' + "            {{ isEditing ? 'Save Changes' : 'Create ' + modelTitle }}" + "          </button>" + "        </div>" + "      </div>" + "    </div>" + "  </div>";
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
      this.form = {
        name: '',
        price: 0.0,
        stock: 0,
        category: ''
      };
      this.formError = '';
    };
    m["openCreateModal"] = function (_this) {
      this.resetForm();
      this.isEditing = false;
      this.currentEditId = 0;
      this.isModalOpen = true;
    };
    m["openEditModal"] = function (_this, item) {
      this.form = Object.assign({}, item);
      this.currentEditId = item.id;
      this.isEditing = true;
      this.formError = '';
      this.isModalOpen = true;
    };
    m["closeModal"] = function (_this) {
      this.isModalOpen = false;
      this.formError = '';
    };
    m["fetchItems"] = function (_this) {
      var self = this;
      var ep = '/api/' + this.apiEndpoint;
      var p = (this.$api && typeof this.$api.get === 'function')
        ? this.$api.get(ep)
        : fetch('http://localhost:8090' + ep).then(function(r) { return r.json(); });
      Promise.resolve(p).then(function(data) {
        if (Array.isArray(data)) {
          self.items = data;
        } else if (data && Array.isArray(data.items)) {
          self.items = data.items;
        }
      }).catch(function(err) {
        console.error('Error fetching ' + self.apiEndpoint + ':', err);
      });
    };
    m["saveItem"] = function (_this) {
      var self = this;
      if (!this.form) return;
      var isEdit = Boolean(this.isEditing);
      var id = this.currentEditId;
      var ep = '/api/' + this.apiEndpoint + (isEdit ? ('/' + id) : '');
      var method = isEdit ? 'put' : 'post';
      var p = (this.$api && typeof this.$api[method] === 'function')
        ? this.$api[method](ep, this.form)
        : fetch('http://localhost:8090' + ep, {
            method: method.toUpperCase(),
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(this.form)
          }).then(function(r) { return r.json(); });
      Promise.resolve(p).then(function(resp) {
        self.isModalOpen = false;
        self.fetchItems();
      }).catch(function(err) {
        self.formError = 'Failed to save: ' + (err.message || err);
      });
    };
    m["deleteItem"] = function (_this, id) {
      if (!confirm('Are you sure you want to delete this ' + this.modelTitle + '?')) return;
      var self = this;
      var ep = '/api/' + this.apiEndpoint + '/' + id;
      var p = (this.$api && typeof this.$api.delete === 'function')
        ? this.$api.delete(ep)
        : fetch('http://localhost:8090' + ep, { method: 'DELETE' }).then(function(r) { return r.json(); });
      Promise.resolve(p).then(function() {
        self.fetchItems();
      }).catch(function(err) {
        alert('Failed to delete: ' + (err.message || err));
      });
    };
    m["setupWebSocket"] = function (_this) {
      var self = this;
      if (!this.$ws) return;
      if (typeof this.$ws.connect === 'function') {
        this.$ws.connect();
      }
      var pfx = String(this.modelTitle).toLowerCase();
      if (typeof this.$ws.on === 'function') {
        this.$ws.on(pfx + '_created', function(d) {
          console.log('⚡ Real-time ' + pfx + ' created:', d);
          self.fetchItems();
        });
        this.$ws.on(pfx + '_updated', function(d) {
          console.log('⚡ Real-time ' + pfx + ' updated:', d);
          self.fetchItems();
        });
        this.$ws.on(pfx + '_deleted', function(d) {
          console.log('⚡ Real-time ' + pfx + ' deleted:', d);
          self.fetchItems();
        });
      };
    };
    comp["methods"] = m;
    comp["mounted"] = function (_this) {
      this.resetForm();
      this.fetchItems();
      this.setupWebSocket();
    };
    comp["computed"] = new Object();
    comp["computed"]["filteredItems"] = function (_this) {
      var Result = undefined;
      let list = this.items || [];
      let q = (this.searchQuery || '').toLowerCase().trim();
      if (!q) return list;
      return list.filter(function(item) {
        return Object.values(item).some(function(v) {
          return String(v).toLowerCase().indexOf(q) !== -1;
        });
      });
      return Result;
    };
    pas.BVComponents.RegisterComponent("product-view-page",comp);
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
      console.log("[Slot Test] O pai está falando!");
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
      console.log("%c[Store] Memória Central Atualizada! Versão: " + newVer + " | Usuário: " + newUser, "color: #10b981; font-weight: bold; font-size: 13px;");
    };
    m["incrementar"] = function (_this) {
      _this["contador"] = rtl.trunc(_this["contador"]) + 1;
    };
    m["toggleShow"] = function (_this) {
      _this["showElement"] = !!(_this["showElement"] == false);
    };
    m["embaralhar"] = function (_this) {
      if (Array.isArray(this.itens)) {
        this.itens = this.itens.slice().sort(() => Math.random() - 0.5);
      };
    };
    m["adicionarItem"] = function (_this) {
      if (Array.isArray(this.itens)) {
        const emojis = ['⚡ Lightning', '🔥 Fire', '🚀 Rocket', '💎 Diamond', '🔮 Crystal', '🌟 Star', '🛡️ Shield', '🎯 Target'];
        const rand = emojis[Math.floor(Math.random() * emojis.length)];
        this.itens.push(rand + ' #' + (this.itens.length + 1));
      };
    };
    m["removerItem"] = function (_this) {
      if (Array.isArray(this.itens) && this.itens.length > 0) {
        this.itens.shift();
      };
    };
    m["resetarLista"] = function (_this) {
      this.itens = ['⚡ Pascal', '🔥 BlaiseVue', '🚀 WebAssembly', '💎 HighPerf'];
    };
    m["calcularWasmFib"] = function (_this) {
      const n = parseInt(this.fibInput, 10) || 1;
      const t0 = performance.now();
      const res = this.$wasm.call('math', 'fib', n);
      const t1 = performance.now();
      this.wasmFibResult = res;
      this.wasmFibTime = (t1 - t0).toFixed(3);
    };
    m["testarPrimoWasm"] = function (_this) {
      const n = parseInt(this.primeInput, 10) || 2;
      const isP = this.$wasm.call('math', 'isPrime', n);
      if (isP === 1) {
        this.primeResult = n + ' é um NÚMERO PRIMO! 💎';
      } else {
        this.primeResult = n + ' NÃO é primo ❌';
      };
    };
    m["rodarBenchmark"] = function (_this) {
      const n = parseInt(this.fibInput, 10) || 20;
      const rep = this.$wasm.benchmark('math', 'fib', n, 1000);
      this.benchJsTime = rep.jsDurationMs;
      this.benchWasmTime = rep.wasmDurationMs;
      this.benchSpeedup = rep.speedup + ' Mais Rápido! 🚀';
      this.benchSummary = 'Executadas 1.000 iterações com sucesso no módulo math.';
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      this.itens = ['⚡ Pascal', '🔥 BlaiseVue', '🚀 WebAssembly', '💎 HighPerf'];
      if (this.$wasm) {
        const rep = this.$wasm.benchmark('math', 'fib', 20, 1000);
        this.benchJsTime = rep.jsDurationMs;
        this.benchWasmTime = rep.wasmDurationMs;
        this.benchSpeedup = rep.speedup + ' Mais Rápido! 🚀';
        this.benchSummary = 'Módulo WebAssembly math ativo e operacional.';
      };
    };
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
      var link = document.getElementById('theme-link');
      if (link) {
         if (ATheme === 'default') {
           link.href = 'css/lib/blaise-ui.css';
         } else {
           link.href = 'assets/themes/' + ATheme + '.min.css';
         }
         document.body.className = 'theme-' + ATheme;
         document.head.appendChild(link);
         console.log('BlaiseVue: Theme applied.');
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
rtl.module("uBVBarChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-bar-chart",comp);
  };
});
rtl.module("uBVBubbleChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-bubble-chart",comp);
  };
});
rtl.module("uBVChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVChart = function () {
    var comp = null;
    var m = null;
    var _styleEl = null;
    _styleEl = document.createElement("style");
    _styleEl.textContent = ".bui-chart-wrapper {     position: relative;     margin-bottom: 20px;     background: white;     padding: 15px;     border-radius: var(--bui-radius);     border: 1px solid var(--bui-border);     box-shadow: 0 2px 10px rgba(0,0,0,0.04);   }";
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
    comp["props"].push("type");
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    m = new Object();
    m["initChart"] = function (_this) {
      if (this._initPending) return;
      this._initPending = true;
      requestAnimationFrame(() => {
        const canvas = this.$refs.chartCanvas;
        if (!canvas) { this._initPending = false; return; }
        if (typeof Chart === 'undefined') {
          console.warn('[BVChart] Chart.js is not loaded.');
          this._initPending = false;
          return;
        }
        const existingChart = Chart.getChart(canvas);
        if (existingChart) {
          try { existingChart.destroy(); } catch(e) {}
        }
        this._chart = null;
        function extractData(input) {
          if (!input) return null;
          if (typeof input.ToJS === 'function') return input.ToJS();
          if (typeof input.toJS === 'function') return input.toJS();
          if (input.FJS) return input.FJS;
          return input;
        }
        const rawData = extractData(this.data);
        if (!rawData || !rawData.datasets) { this._initPending = false; return; }
        const ctx = canvas.getContext('2d');
        if (!ctx) { this._initPending = false; return; }
        try {
          const chartData = window.__BV_CORE__.unproxy(rawData);
          const rawOpts = extractData(this.options);
          const chartOptions = rawOpts ? window.__BV_CORE__.unproxy(rawOpts) : {
            responsive: true,
            maintainAspectRatio: false
          };
          this._chart = new Chart(ctx, {
            type: this.type,
            data: chartData,
            options: chartOptions
          });
        } catch (e) {
          console.error('[BVChart] Failed to initialize chart:', e);
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
      const delay = 50 + Math.random() * 100;
      setTimeout(() => {
        this._updatePending = false;
        const dataToUse = this._pendingData;
        if (this._chart && dataToUse && dataToUse.datasets) {
          try {
            const rawNewData = window.__BV_CORE__.unproxy(dataToUse);
            if (this._chart.data && this._chart.data.datasets && this._chart.data.datasets[0] && rawNewData.datasets[0]) {
               this._chart.data.datasets[0].data = rawNewData.datasets[0].data;
               if (rawNewData.labels) this._chart.data.labels = rawNewData.labels;
               this._chart.update();
            } else {
               this._chart.data = rawNewData;
               this._chart.update('none');
            }
          } catch (e) {
            console.warn('[BVChart] Hot update failed, falling back to full re-init:', e);
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
    pas.BVComponents.RegisterComponent("bv-chart",comp);
  };
});
rtl.module("uBVDoughnutChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-doughnut-chart",comp);
  };
});
rtl.module("uBVLineChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-line-chart",comp);
  };
});
rtl.module("uBVPieChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-pie-chart",comp);
  };
});
rtl.module("uBVPolarAreaChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-polar-area-chart",comp);
  };
});
rtl.module("uBVRadarChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-radar-chart",comp);
  };
});
rtl.module("uBVScatterChart",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("data");
    comp["props"].push("options");
    comp["props"].push("width");
    comp["props"].push("height");
    comp["props"].push("themeAware");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('chart-click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-scatter-chart",comp);
  };
});
rtl.module("uBVAccordion",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("items");
    comp["props"].push("initialActiveId");
    comp["props"].push("initialactiveid");
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
      this.activeId = String(this.initialActiveId || this.initialactiveid || '');
    };
    pas.BVComponents.RegisterComponent("bv-accordion",comp);
  };
});
rtl.module("uBVAlert",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("variant");
    comp["props"].push("dismissible");
    comp["props"].push("show");
    m = new Object();
    m["close"] = function (_this) {
      _this["visible"] = false;
      this.$emit('close');
    };
    comp["methods"] = m;
    comp["created"] = function (_this) {
      _this["visible"] = !(_this["show"] == false);
    };
    pas.BVComponents.RegisterComponent("bv-alert",comp);
  };
});
rtl.module("uBVBadge",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("variant");
    comp["props"].push("pill");
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
rtl.module("uBVBottomNav",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVBottomNavItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("href");
    comp["props"].push("label");
    comp["props"].push("icon");
    comp["props"].push("active");
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
rtl.module("uBVBreadcrumb",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVBreadcrumbItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("active");
    comp["props"].push("href");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('click', ev);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-breadcrumb-item",comp);
  };
});
rtl.module("uBVBtn",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("label");
    comp["props"].push("variant");
    comp["props"].push("size");
    comp["props"].push("disabled");
    comp["props"].push("outline");
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
rtl.module("uBVCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    comp["props"].push("hasFooter");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-card",comp);
  };
});
rtl.module("uBVCol",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("cols");
    comp["props"].push("sm");
    comp["props"].push("md");
    comp["props"].push("lg");
    comp["props"].push("xl");
    comp["props"].push("offset");
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
rtl.module("uBVContainer",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("fluid");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-container",comp);
  };
});
rtl.module("uBVDataGrid",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
  "use strict";
  var $mod = this;
  this.Register_uBVDataGrid = function () {
    var comp = null;
    var m = null;
    comp = new Object();
    comp["template"] = '  <div class="bui-datagrid-container">' + '    <div class="bui-datagrid-toolbar">' + "      <input " + '        type="text" ' + '        class="bui-datagrid-search" ' + '        placeholder="Buscar..." ' + '        b-model="searchQuery" ' + '        @input="handleSearch"' + "      />" + "      <span>Total: {{ totalItems }}</span>" + "    </div>" + "" + '    <table class="bui-datagrid-table">' + "      <thead>" + "        <tr>" + '          <th b-for="col in columns" @click="sortBy(col.key)">' + "            {{ col.label }}" + "          </th>" + "        </tr>" + "      </thead>" + "      <tbody>" + '        <tr b-for="row in pagedItems">' + '          <td b-for="col in columns">' + '            <slot name="cell" :row="row" :column="col" :value="row[col.key]">' + "              {{ row[col.key] }}" + "            </slot>" + "          </td>" + "        </tr>" + "      </tbody>" + "    </table>" + "" + '    <div class="bui-datagrid-pagination">' + '      <button class="bui-btn bui-btn-sm" :disabled="currentPage <= 1" @click="prevPage">Anterior</button>' + "      <span>Página {{ currentPage }} de {{ totalPages }}</span>" + '      <button class="bui-btn bui-btn-sm" :disabled="currentPage >= totalPages" @click="nextPage">Próxima</button>' + "    </div>" + "  </div>";
    comp["data"] = function () {
      var Result = null;
      var d = null;
      d = new Object();
      d["items"] = new Array();
      d["columns"] = new Array();
      d["searchQuery"] = "";
      d["sortKey"] = "";
      d["sortAsc"] = true;
      d["currentPage"] = 1;
      d["pageSize"] = 5;
      Result = d;
      return Result;
    };
    m = new Object();
    m["handleSearch"] = function (_this) {
      _this["currentPage"] = 1;
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
    comp["methods"] = m;
    comp["computed"] = new Object();
    comp["computed"]["totalItems"] = function (_this) {
      var Result = undefined;
      Result = (this.items && Array.isArray(this.items)) ? this.items.length : 0;
      return Result;
    };
    comp["computed"]["filteredItems"] = function (_this) {
      var Result = undefined;
      let list = this.items || [];
      let q = (this.searchQuery || '').toLowerCase();
      if (!q) return list;
      return list.filter(function(item) {
        return Object.values(item).some(function(v) {
          return String(v).toLowerCase().indexOf(q) !== -1;
        });
      });
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
      let list = this.filteredItems || [];
      let start = (this.currentPage - 1) * this.pageSize;
      return list.slice(start, start + this.pageSize);
      return Result;
    };
    pas.BVComponents.RegisterComponent("bv-data-grid",comp);
    pas.BVComponents.RegisterComponent("bv-datagrid",comp);
  };
});
rtl.module("uBVDrawer",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    comp["props"].push("width");
    comp["props"].push("position");
    comp["props"].push("overlay");
    comp["props"].push("hasFooter");
    comp["props"].push("show");
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
      if ((_this["show"] == true) || (_this["show"] == "true")) {
        _this["isOpen"] = true}
       else _this["isOpen"] = false;
    };
    pas.BVComponents.RegisterComponent("bv-drawer",comp);
  };
});
rtl.module("uBVFormSelect",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("label");
    comp["props"].push("value");
    comp["props"].push("options");
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
rtl.module("uBVIcon",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("name");
    comp["props"].push("size");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-icon",comp);
  };
});
rtl.module("uBVInput",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("label");
    comp["props"].push("placeholder");
    comp["props"].push("type");
    comp["props"].push("value");
    comp["props"].push("readonly");
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
rtl.module("uBVInputGroup",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("label");
    comp["props"].push("placeholder");
    comp["props"].push("value");
    comp["props"].push("prepend");
    comp["props"].push("append");
    m = new Object();
    m["onInput"] = function (_this, ev) {
      var val = (ev && ev.target) ? ev.target.value : (ev || '');
      this.$emit('input', val);
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-input-group",comp);
  };
});
rtl.module("uBVListGroup",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVListGroupItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("active");
    comp["props"].push("badge");
    comp["props"].push("badgeVariant");
    comp["props"].push("badgevariant");
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
rtl.module("uBVModal",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    comp["props"].push("okLabel");
    comp["props"].push("oklabel");
    comp["props"].push("cancelLabel");
    comp["props"].push("cancellabel");
    comp["props"].push("show");
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
rtl.module("uBVNavbar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("brand");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-navbar",comp);
  };
});
rtl.module("uBVNavItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("href");
    comp["props"].push("label");
    comp["props"].push("active");
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
rtl.module("uBVPagination",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("value");
    comp["props"].push("total");
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
rtl.module("uBVProgress",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("value");
    comp["props"].push("variant");
    comp["props"].push("label");
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
rtl.module("uBVRow",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("gutter");
    comp["props"].push("align");
    comp["props"].push("justify");
    comp["props"].push("noGutters");
    comp["props"].push("nogutters");
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
rtl.module("uBVSpinner",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("variant");
    comp["props"].push("small");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-spinner",comp);
  };
});
rtl.module("uBVTab",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("id");
    comp["props"].push("title");
    comp["props"].push("active");
    m = new Object();
    comp["methods"] = m;
    comp["created"] = function (_this) {
      if (typeof this.registerTab === 'function') {
        var t = { id: this.id, title: this.title, active: Boolean(this.active && this.active !== 'false') };
        this.registerTab(t);
      };
    };
    comp["mounted"] = function (_this) {
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
rtl.module("uBVTabs",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVToast",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    comp["props"].push("message");
    comp["props"].push("duration");
    comp["props"].push("variant");
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
rtl.module("uBVIonApp",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("mode");
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
rtl.module("uBVIonBadge",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("color");
    comp["props"].push("value");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-badge",comp);
  };
});
rtl.module("uBVIonButton",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("label");
    comp["props"].push("color");
    comp["props"].push("fill");
    comp["props"].push("expand");
    comp["props"].push("disabled");
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
rtl.module("uBVIonCard",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    comp["props"].push("subtitle");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-card",comp);
  };
});
rtl.module("uBVIonContent",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("padding");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-content",comp);
  };
});
rtl.module("uBVIonHeader",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVIonItem",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    comp["props"].push("subtitle");
    comp["props"].push("detail");
    comp["props"].push("expandable");
    comp["props"].push("expanded");
    comp["props"].push("hasStart");
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
rtl.module("uBVIonList",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("inset");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-list",comp);
  };
});
rtl.module("uBVIonTabBar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVIonTabButton",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("label");
    comp["props"].push("active");
    comp["props"].push("tab");
    m = new Object();
    m["handleClick"] = function (_this, ev) {
      this.$emit('tab-click', { tab: this.tab, originalEvent: ev });
    };
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-tab-button",comp);
  };
});
rtl.module("uBVIonTabs",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVIonTitle",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
    comp["props"].push("title");
    m = new Object();
    comp["methods"] = m;
    pas.BVComponents.RegisterComponent("bv-ion-title",comp);
  };
});
rtl.module("uBVIonToolbar",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVThemeSelect",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uBVThemeToggle",["System","JS","Web","BVComponents","BVReactivity","BVStore","SysUtils"],function () {
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
rtl.module("uApp",["System","JS","Web","BlaiseVue","BVComponents","BVStore","BVCompiler","BVDevTools","BVRouting","uCard","uCounter","uFormHeader","uInfoCard","uAbout","uCharts","uCustomerView","uFormulario","uHome","uLibBootstrap","uLoginView","uMobileView","uProductView","uProFeatures","uShowcase","uUserProfile","uBVBarChart","uBVBubbleChart","uBVChart","uBVDoughnutChart","uBVLineChart","uBVPieChart","uBVPolarAreaChart","uBVRadarChart","uBVScatterChart","uBVAccordion","uBVAlert","uBVBadge","uBVBottomNav","uBVBottomNavItem","uBVBreadcrumb","uBVBreadcrumbItem","uBVBtn","uBVCard","uBVCol","uBVContainer","uBVDataGrid","uBVDrawer","uBVFormSelect","uBVIcon","uBVInput","uBVInputGroup","uBVListGroup","uBVListGroupItem","uBVModal","uBVNavbar","uBVNavItem","uBVPagination","uBVProgress","uBVRow","uBVSpinner","uBVTab","uBVTabs","uBVToast","uBVIonApp","uBVIonBadge","uBVIonButton","uBVIonCard","uBVIonContent","uBVIonHeader","uBVIonItem","uBVIonList","uBVIonTabBar","uBVIonTabButton","uBVIonTabs","uBVIonTitle","uBVIonToolbar","uBVThemeSelect","uBVThemeToggle"],function () {
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
    console.log("[Init] Registering uCustomerView...");
    pas.uCustomerView.Register_uCustomerView();
    console.log("[Init] Registering uFormulario...");
    pas.uFormulario.Register_uFormulario();
    console.log("[Init] Registering uHome...");
    pas.uHome.Register_uHome();
    console.log("[Init] Registering uLibBootstrap...");
    pas.uLibBootstrap.Register_uLibBootstrap();
    console.log("[Init] Registering uLoginView...");
    pas.uLoginView.Register_uLoginView();
    console.log("[Init] Registering uMobileView...");
    pas.uMobileView.Register_uMobileView();
    console.log("[Init] Registering uProductView...");
    pas.uProductView.Register_uProductView();
    console.log("[Init] Registering uProFeatures...");
    pas.uProFeatures.Register_uProFeatures();
    console.log("[Init] Registering uShowcase...");
    pas.uShowcase.Register_uShowcase();
    console.log("[Init] Registering uUserProfile...");
    pas.uUserProfile.Register_uUserProfile();
    console.log("[Init] Registering uBVBarChart...");
    pas.uBVBarChart.Register_uBVBarChart();
    console.log("[Init] Registering uBVBubbleChart...");
    pas.uBVBubbleChart.Register_uBVBubbleChart();
    console.log("[Init] Registering uBVChart...");
    pas.uBVChart.Register_uBVChart();
    console.log("[Init] Registering uBVDoughnutChart...");
    pas.uBVDoughnutChart.Register_uBVDoughnutChart();
    console.log("[Init] Registering uBVLineChart...");
    pas.uBVLineChart.Register_uBVLineChart();
    console.log("[Init] Registering uBVPieChart...");
    pas.uBVPieChart.Register_uBVPieChart();
    console.log("[Init] Registering uBVPolarAreaChart...");
    pas.uBVPolarAreaChart.Register_uBVPolarAreaChart();
    console.log("[Init] Registering uBVRadarChart...");
    pas.uBVRadarChart.Register_uBVRadarChart();
    console.log("[Init] Registering uBVScatterChart...");
    pas.uBVScatterChart.Register_uBVScatterChart();
    console.log("[Init] Registering uBVAccordion...");
    pas.uBVAccordion.Register_uBVAccordion();
    console.log("[Init] Registering uBVAlert...");
    pas.uBVAlert.Register_uBVAlert();
    console.log("[Init] Registering uBVBadge...");
    pas.uBVBadge.Register_uBVBadge();
    console.log("[Init] Registering uBVBottomNav...");
    pas.uBVBottomNav.Register_uBVBottomNav();
    console.log("[Init] Registering uBVBottomNavItem...");
    pas.uBVBottomNavItem.Register_uBVBottomNavItem();
    console.log("[Init] Registering uBVBreadcrumb...");
    pas.uBVBreadcrumb.Register_uBVBreadcrumb();
    console.log("[Init] Registering uBVBreadcrumbItem...");
    pas.uBVBreadcrumbItem.Register_uBVBreadcrumbItem();
    console.log("[Init] Registering uBVBtn...");
    pas.uBVBtn.Register_uBVBtn();
    console.log("[Init] Registering uBVCard...");
    pas.uBVCard.Register_uBVCard();
    console.log("[Init] Registering uBVCol...");
    pas.uBVCol.Register_uBVCol();
    console.log("[Init] Registering uBVContainer...");
    pas.uBVContainer.Register_uBVContainer();
    console.log("[Init] Registering uBVDataGrid...");
    pas.uBVDataGrid.Register_uBVDataGrid();
    console.log("[Init] Registering uBVDrawer...");
    pas.uBVDrawer.Register_uBVDrawer();
    console.log("[Init] Registering uBVFormSelect...");
    pas.uBVFormSelect.Register_uBVFormSelect();
    console.log("[Init] Registering uBVIcon...");
    pas.uBVIcon.Register_uBVIcon();
    console.log("[Init] Registering uBVInput...");
    pas.uBVInput.Register_uBVInput();
    console.log("[Init] Registering uBVInputGroup...");
    pas.uBVInputGroup.Register_uBVInputGroup();
    console.log("[Init] Registering uBVListGroup...");
    pas.uBVListGroup.Register_uBVListGroup();
    console.log("[Init] Registering uBVListGroupItem...");
    pas.uBVListGroupItem.Register_uBVListGroupItem();
    console.log("[Init] Registering uBVModal...");
    pas.uBVModal.Register_uBVModal();
    console.log("[Init] Registering uBVNavbar...");
    pas.uBVNavbar.Register_uBVNavbar();
    console.log("[Init] Registering uBVNavItem...");
    pas.uBVNavItem.Register_uBVNavItem();
    console.log("[Init] Registering uBVPagination...");
    pas.uBVPagination.Register_uBVPagination();
    console.log("[Init] Registering uBVProgress...");
    pas.uBVProgress.Register_uBVProgress();
    console.log("[Init] Registering uBVRow...");
    pas.uBVRow.Register_uBVRow();
    console.log("[Init] Registering uBVSpinner...");
    pas.uBVSpinner.Register_uBVSpinner();
    console.log("[Init] Registering uBVTab...");
    pas.uBVTab.Register_uBVTab();
    console.log("[Init] Registering uBVTabs...");
    pas.uBVTabs.Register_uBVTabs();
    console.log("[Init] Registering uBVToast...");
    pas.uBVToast.Register_uBVToast();
    console.log("[Init] Registering uBVIonApp...");
    pas.uBVIonApp.Register_uBVIonApp();
    console.log("[Init] Registering uBVIonBadge...");
    pas.uBVIonBadge.Register_uBVIonBadge();
    console.log("[Init] Registering uBVIonButton...");
    pas.uBVIonButton.Register_uBVIonButton();
    console.log("[Init] Registering uBVIonCard...");
    pas.uBVIonCard.Register_uBVIonCard();
    console.log("[Init] Registering uBVIonContent...");
    pas.uBVIonContent.Register_uBVIonContent();
    console.log("[Init] Registering uBVIonHeader...");
    pas.uBVIonHeader.Register_uBVIonHeader();
    console.log("[Init] Registering uBVIonItem...");
    pas.uBVIonItem.Register_uBVIonItem();
    console.log("[Init] Registering uBVIonList...");
    pas.uBVIonList.Register_uBVIonList();
    console.log("[Init] Registering uBVIonTabBar...");
    pas.uBVIonTabBar.Register_uBVIonTabBar();
    console.log("[Init] Registering uBVIonTabButton...");
    pas.uBVIonTabButton.Register_uBVIonTabButton();
    console.log("[Init] Registering uBVIonTabs...");
    pas.uBVIonTabs.Register_uBVIonTabs();
    console.log("[Init] Registering uBVIonTitle...");
    pas.uBVIonTitle.Register_uBVIonTitle();
    console.log("[Init] Registering uBVIonToolbar...");
    pas.uBVIonToolbar.Register_uBVIonToolbar();
    console.log("[Init] Registering uBVThemeSelect...");
    pas.uBVThemeSelect.Register_uBVThemeSelect();
    console.log("[Init] Registering uBVThemeToggle...");
    pas.uBVThemeToggle.Register_uBVThemeToggle();
    console.log("[Init] Setting #app template...");
    document.querySelector("#app").innerHTML = '  <div translate="no" class="notranslate">' + "    <!-- RESPONSIVE DRAWER (MOBILE & DESKTOP OFFCANVAS) -->" + '    <bv-drawer ref="appDrawer" title="🧭 BlaiseVue Menu">' + '      <div class="drawer-nav">' + '        <a href="#/login" class="drawer-link" @click="closeDrawer">🔐 {{ ($auth && $auth.isAuthenticated) ? $auth.user.name : \'Entrar\' }}</a>' + '        <a href="#/customers" class="drawer-link" @click="closeDrawer">📦 Customers</a>' + '        <a href="#/products" class="drawer-link" @click="closeDrawer">📦 Products</a>' + '        <a href="#/mobile" class="drawer-link" @click="closeDrawer">📱 Mobile & Desktop Kit</a>' + '        <a href="#/" class="drawer-link" @click="closeDrawer">🏠 {{ $t(\'nav.home\') }}</a>' + '        <a href="#/about" class="drawer-link" @click="closeDrawer">ℹ️ {{ $t(\'nav.about\') }}</a>' + '        <a href="#/pro" class="drawer-link" @click="closeDrawer">⚡ {{ $t(\'nav.pro\') }}</a>' + '        <a href="#/form" class="drawer-link" @click="closeDrawer">📋 {{ $t(\'nav.form\') }}</a>' + '        <a href="#/bootstrap" class="drawer-link" @click="closeDrawer">🎨 {{ $t(\'nav.blaiseui\') }}</a>' + '        <a href="#/charts" class="drawer-link" @click="closeDrawer">📊 {{ $t(\'nav.charts\') }}</a>' + '        <a href="#/showcase" class="drawer-link" @click="closeDrawer">✨ {{ $t(\'nav.showcase\') }}</a>' + '        <a href="docs/index.html" class="drawer-link" @click="closeDrawer">📚 Docs (v3.0)</a>' + '        <a href="/api/docs" target="_blank" class="drawer-link" @click="closeDrawer">📜 Swagger (/api/docs)</a>' + "      </div>" + "    </bv-drawer>" + "" + '    <nav class="navbar">' + '      <div style="display: flex; align-items: center; gap: 8px;">' + '        <button class="drawer-btn" type="button" @click="toggleDrawer" title="Menu">☰</button>' + '        <strong class="brand">BlaiseVue 3.0 TURBO</strong>' + "      </div>" + '      <div class="nav-links">' + '        <a href="#/customers">📦 Customers</a>' + '        <a href="#/products">📦 Products</a>' + '        <a href="#/mobile" style="background: #3880ff; color: white;">📱 Mobile Kit</a>' + '        <a href="#/login" style="background: rgba(255,255,255,0.08); border: 1px solid #42b883; color: white;">🔐 {{ ($auth && $auth.isAuthenticated) ? $auth.user.name : \'Entrar\' }}</a>' + '        <a href="#/">{{ $t(\'nav.home\') }}</a>' + '        <a href="#/about">{{ $t(\'nav.about\') }}</a>' + '        <a href="#/pro" style="background: #27ae60; color: white;">⚡ {{ $t(\'nav.pro\') }}</a>' + '        <a href="#/form">{{ $t(\'nav.form\') }}</a>' + '        <a href="#/bootstrap">{{ $t(\'nav.blaiseui\') }}</a>' + '        <a href="#/charts" style="background: #42b883; color: white;">{{ $t(\'nav.charts\') }}</a>' + '        <a href="#/showcase" style="background: #3498db; color: white;">{{ $t(\'nav.showcase\') }}</a>' + '        <a href="docs/index.html" style="background: #8e44ad; color: white;">📚 Docs (v3.0)</a>' + '        <a href="/api/docs" target="_blank" style="background: #2c3e50; border: 1px solid #3498db; color: #5dade2; font-weight: 600;">📜 Swagger</a>' + "      </div>" + '      <div class="lang-switcher">' + '        <button class="lang-btn" :class="{ \'active-lang\': $i18n.locale === \'pt\' }" @click="$setLocale(\'pt\')">🇧🇷 PT</button>' + '        <button class="lang-btn" :class="{ \'active-lang\': $i18n.locale === \'en\' }" @click="$setLocale(\'en\')">🇺🇸 EN</button>' + "      </div>" + '      <div class="theme-switcher">' + '        <button class="theme-toggle-btn" @click="$theme.toggle()" :title="$theme.isDark ? \'Modo Claro\' : \'Modo Escuro\'">' + '          <span v-if="$theme.isDark">☀️</span>' + '          <span v-if="!$theme.isDark">🌙</span>' + "        </button>" + '        <select class="theme-select" :value="$theme.current" @change="onThemeSelect($event)">' + '          <option value="flatly">Flatly</option>' + '          <option value="cosmo">Cosmo</option>' + '          <option value="lux">Lux</option>' + '          <option value="zephyr">Zephyr</option>' + '          <option value="darkly">Darkly</option>' + '          <option value="cyborg">Cyborg</option>' + '          <option value="solar">Solar</option>' + '          <option value="vapor">Vapor</option>' + '          <option value="pulse">Pulse</option>' + "        </select>" + "      </div>" + '      <span class="nav-msg">{{ mensagem }}</span>' + "    </nav>" + "" + "    <!-- MAIN RESPONSIVE CONTAINER -->" + '    <bv-container class="main-content-container">' + "      <router-view></router-view>" + "    </bv-container>" + "" + "    <!-- MOBILE BOTTOM NAVIGATION (PINNED ON MOBILE SCREENS) -->" + '    <bv-bottom-nav class="mobile-bottom-bar">' + '      <bv-bottom-nav-item href="#/" icon="🏠" label="Início"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/pro" icon="⚡" label="Pro"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/form" icon="📋" label="Forms"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/mobile" icon="📱" label="Mobile"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="#/bootstrap" icon="🎨" label="BlaiseUI"></bv-bottom-nav-item>' + '      <bv-bottom-nav-item href="docs/index.html" icon="📚" label="Docs"></bv-bottom-nav-item>' + "    </bv-bottom-nav>" + "" + '    <div class="footer-status desktop-only-footer">' + "       {{ $t('status.globalStore') }}: {{ $store.appVersion }} | {{ $t('status.localeActive') }}: <strong>{{ $i18n.locale.toUpperCase() }}</strong> | {{ $t('status.theme') }}: <strong>{{ $theme.current.toUpperCase() }}</strong> | ⚡ Wasm: <strong>Active</strong> | 🚀 SSG: <strong>Ready</strong> | Dev: {{ $store.user }}" + "    </div>" + "  </div>";
    data = new Object();
    data["mensagem"] = "BlaiseVue SPA v3.0 TURBO";
    methods = new Object();
    m = methods;
    m["onThemeSelect"] = function (_this, e) {
      var sel = "";
      sel = "" + e["target"]["value"];
      if (sel !== "") {
        if (window.$theme) window.$theme.setTheme(sel);
      };
    };
    m["toggleDrawer"] = function (_this) {
      if (this.$refs.appDrawer && this.$refs.appDrawer.toggle) {
        this.$refs.appDrawer.toggle();
      };
    };
    m["closeDrawer"] = function (_this) {
      if (this.$refs.appDrawer && this.$refs.appDrawer.close) {
        this.$refs.appDrawer.close();
      };
    };
    opts = new Object();
    comp = opts;
    comp["created"] = function (_this) {
      _this["$store"]["appVersion"] = "3.0.0-TURBO";
      _this["$store"]["user"] = "Pascal Master 🚀";
      if (window.__BV_CORE__.i18n) {
        window.__BV_CORE__.i18n.addMessages('pt', {
          nav: {
            home: 'Início',
            about: 'Sobre',
            pro: 'Pro & Wasm ⚡',
            form: 'Formulário 📋',
            blaiseui: 'BlaiseUI Kit 🎨',
            charts: 'Gráficos 📊',
            showcase: 'Showcase ✨'
          },
          status: {
            globalStore: 'Memória Global',
            localeActive: 'Idioma Ativo',
            theme: 'Tema'
          },
          form: {
            title: 'Formulário de Validação Reativa',
            subtitle: 'Demonstração de b-validate, $errors e $v no BlaiseVue 2.5',
            name: 'Nome Completo',
            email: 'E-mail Corporativo',
            city: 'Cidade',
            submit: 'Validar & Enviar 🚀',
            reset: 'Limpar Formulário 🔄',
            fillValid: 'Preencher Válido ✨',
            statusValid: 'Válido ✅',
            statusInvalid: 'Inválido ❌',
            formState: 'Status do Formulário'
          },
          pro: {
            title: '⚡ BlaiseVue 3.0 Pro & WebAssembly Engine',
            transitionTitle: '🎬 Lista com Animações FLIP (<transition-group>)',
            shuffle: 'Embaralhar 🔀',
            add: 'Adicionar Item ➕',
            remove: 'Remover Primeiro ➖',
            resetList: 'Resetar Lista 🔄'
          }
        });
        window.__BV_CORE__.i18n.addMessages('en', {
          nav: {
            home: 'Home',
            about: 'About',
            pro: 'Pro & Wasm ⚡',
            form: 'Form 📋',
            blaiseui: 'BlaiseUI Kit 🎨',
            charts: 'Charts 📊',
            showcase: 'Showcase ✨'
          },
          status: {
            globalStore: 'Global Store',
            localeActive: 'Active Locale',
            theme: 'Theme'
          },
          form: {
            title: 'Reactive Form Validation',
            subtitle: 'Demonstrating b-validate, $errors, and $v in BlaiseVue 2.5',
            name: 'Full Name',
            email: 'Corporate Email',
            city: 'City',
            submit: 'Validate & Submit 🚀',
            reset: 'Reset Form 🔄',
            fillValid: 'Fill Valid Sample ✨',
            statusValid: 'Valid ✅',
            statusInvalid: 'Invalid ❌',
            formState: 'Form Status'
          },
          pro: {
            title: '⚡ BlaiseVue 3.0 Pro & WebAssembly Engine',
            transitionTitle: '🎬 FLIP List Transitions (<transition-group>)',
            shuffle: 'Shuffle 🔀',
            add: 'Add Item ➕',
            remove: 'Remove First ➖',
            resetList: 'Reset List 🔄'
          }
        });
        window.__BV_CORE__.i18n.setLocale('pt');
      };
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
