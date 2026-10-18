rtl.module("Types",["System"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  this.Epsilon = 1E-40;
  this.Epsilon2 = 1E-30;
  this.cPI = 3.141592654;
  this.cPIdiv180 = 0.017453292;
  this.cPIdiv2 = 1.570796326;
  this.cPIdiv4 = 0.785398163;
  this.TDirection = {"0": "FromBeginning", FromBeginning: 0, "1": "FromEnd", FromEnd: 1};
  $mod.$rtti.$Enum("TDirection",{minvalue: 0, maxvalue: 1, ordtype: 1, enumtype: this.TDirection});
  $mod.$rtti.$DynArray("TBooleanDynArray",{eltype: rtl.boolean});
  $mod.$rtti.$DynArray("TWordDynArray",{eltype: rtl.word});
  $mod.$rtti.$DynArray("TIntegerDynArray",{eltype: rtl.longint});
  $mod.$rtti.$DynArray("TNativeIntDynArray",{eltype: rtl.nativeint});
  $mod.$rtti.$DynArray("TStringDynArray",{eltype: rtl.string});
  $mod.$rtti.$DynArray("TDoubleDynArray",{eltype: rtl.double});
  $mod.$rtti.$DynArray("TJSValueDynArray",{eltype: rtl.jsvalue});
  $mod.$rtti.$DynArray("TObjectDynArray",{eltype: pas.System.$rtti["TObject"]});
  $mod.$rtti.$DynArray("TByteDynArray",{eltype: rtl.byte});
  this.TSplitRectType = {"0": "srLeft", srLeft: 0, "1": "srRight", srRight: 1, "2": "srTop", srTop: 2, "3": "srBottom", srBottom: 3};
  $mod.$rtti.$Enum("TSplitRectType",{minvalue: 0, maxvalue: 3, ordtype: 1, enumtype: this.TSplitRectType});
  this.TDuplicates = {"0": "dupIgnore", dupIgnore: 0, "1": "dupAccept", dupAccept: 1, "2": "dupError", dupError: 2};
  $mod.$rtti.$Enum("TDuplicates",{minvalue: 0, maxvalue: 2, ordtype: 1, enumtype: this.TDuplicates});
  $mod.$rtti.$RefToProcVar("TProc",{procsig: rtl.newTIProcSig(null)});
  $mod.$rtti.$RefToProcVar("TProcString",{procsig: rtl.newTIProcSig([["aString",rtl.string,2]])});
  $mod.$rtti.$MethodVar("TListCallback",{procsig: rtl.newTIProcSig([["data",rtl.jsvalue],["arg",rtl.jsvalue]]), methodkind: 0});
  $mod.$rtti.$ProcVar("TListStaticCallback",{procsig: rtl.newTIProcSig([["data",rtl.jsvalue],["arg",rtl.jsvalue]])});
  rtl.recNewT($mod,"TSize",function () {
    this.cx = 0;
    this.cy = 0;
    this.$eq = function (b) {
      return (this.cx === b.cx) && (this.cy === b.cy);
    };
    this.$assign = function (s) {
      this.cx = s.cx;
      this.cy = s.cy;
      return this;
    };
    this.Create = function (ax, ay) {
      this.cx = ax;
      this.cy = ay;
      return this;
    };
    this.Create$1 = function (asz) {
      this.cx = asz.cx;
      this.cy = asz.cy;
      return this;
    };
    this.Add = function (asz) {
      var Result = $mod.TSize.$new();
      Result.cx = this.cx + asz.cx;
      Result.cy = this.cy + asz.cy;
      return Result;
    };
    this.Distance = function (asz) {
      var Result = 0.0;
      Result = Math.sqrt(pas.System.Sqr(this.cx - asz.cx) + pas.System.Sqr(this.cy - asz.cy));
      return Result;
    };
    this.IsZero = function () {
      var Result = false;
      Result = (this.cx === 0) && (this.cy === 0);
      return Result;
    };
    this.Subtract = function (asz) {
      var Result = $mod.TSize.$new();
      Result.cx = this.cx - asz.cx;
      Result.cy = this.cy - asz.cy;
      return Result;
    };
    var $r = $mod.$rtti.$Record("TSize",{});
    $r.addField("cx",rtl.longint);
    $r.addField("cy",rtl.longint);
    $r.addMethod("Create",2,[["ax",rtl.longint],["ay",rtl.longint]]);
    $r.addMethod("Create$1",2,[["asz",$r]]);
    $r.addMethod("Add",1,[["asz",$r,2]],$r);
    $r.addMethod("Distance",1,[["asz",$r,2]],rtl.double);
    $r.addMethod("IsZero",1,null,rtl.boolean);
    $r.addMethod("Subtract",1,[["asz",$r,2]],$r);
    $r.addProperty("Width",0,rtl.longint,"cx","cx");
    $r.addProperty("Height",0,rtl.longint,"cy","cy");
  },true);
  rtl.recNewT($mod,"TPoint",function () {
    this.X = 0;
    this.Y = 0;
    this.$eq = function (b) {
      return (this.X === b.X) && (this.Y === b.Y);
    };
    this.$assign = function (s) {
      this.X = s.X;
      this.Y = s.Y;
      return this;
    };
    this.Zero = function () {
      var Result = $mod.TPoint.$new();
      Result.X = 0;
      Result.Y = 0;
      return Result;
    };
    this.Add = function (apt) {
      var Result = $mod.TPoint.$new();
      Result.X = this.X + apt.X;
      Result.Y = this.Y + apt.Y;
      return Result;
    };
    this.Distance = function (apt) {
      var Result = 0.0;
      Result = Math.sqrt(pas.System.Sqr$1(apt.X - this.X) + pas.System.Sqr$1(apt.Y - this.Y));
      return Result;
    };
    this.IsZero = function () {
      var Result = false;
      Result = (this.X === 0) && (this.Y === 0);
      return Result;
    };
    this.Subtract = function (apt) {
      var Result = $mod.TPoint.$new();
      Result.X = this.X - apt.X;
      Result.Y = this.Y - apt.Y;
      return Result;
    };
    this.SetLocation = function (apt) {
      this.X = apt.X;
      this.Y = apt.Y;
    };
    this.SetLocation$1 = function (ax, ay) {
      this.X = ax;
      this.Y = ay;
    };
    this.Offset = function (apt) {
      this.X = this.X + apt.X;
      this.Y = this.Y + apt.Y;
    };
    this.Offset$1 = function (dx, dy) {
      this.X = this.X + dx;
      this.Y = this.Y + dy;
    };
    this.Angle = function (pt) {
      var $Self = this;
      var Result = 0.0;
      function arctan2(y, x) {
        var Result = 0.0;
        if (x === 0) {
          if (y === 0) {
            Result = 0.0}
           else if (y > 0) {
            Result = Math.PI / 2}
           else Result = -Math.PI / 2;
        } else {
          Result = Math.atan(y / x);
          if (x < 0) if (y < 0) {
            Result = Result - Math.PI}
           else Result = Result + Math.PI;
        };
        return Result;
      };
      Result = arctan2($Self.Y - pt.Y,$Self.X - pt.X);
      return Result;
    };
    this.PointInCircle = function (apt, acenter, aradius) {
      var Result = false;
      Result = apt.Distance(acenter) <= aradius;
      return Result;
    };
    var $r = $mod.$rtti.$Record("TPoint",{});
    $r.addField("X",rtl.longint);
    $r.addField("Y",rtl.longint);
    $r.addMethod("Zero",5,null,$r,{flags: 1});
    $r.addMethod("Add",1,[["apt",$r,2]],$r);
    $r.addMethod("Distance",1,[["apt",$r,2]],rtl.double);
    $r.addMethod("IsZero",1,null,rtl.boolean);
    $r.addMethod("Subtract",1,[["apt",$r,2]],$r);
    $r.addMethod("SetLocation",0,[["apt",$r,2]]);
    $r.addMethod("SetLocation$1",0,[["ax",rtl.longint],["ay",rtl.longint]]);
    $r.addMethod("Offset",0,[["apt",$r,2]]);
    $r.addMethod("Offset$1",0,[["dx",rtl.longint],["dy",rtl.longint]]);
    $r.addMethod("Angle",1,[["pt",$r,2]],rtl.double);
    $r.addMethod("PointInCircle",5,[["apt",$r,2],["acenter",$r,2],["aradius",rtl.longint,2]],rtl.boolean,{flags: 1});
  });
  $mod.$rtti.$inherited("PPoint",{comptype: $mod.$rtti["TPoint"]});
  rtl.recNewT($mod,"TRect",function () {
    this.Left = 0;
    this.Top = 0;
    this.Right = 0;
    this.Bottom = 0;
    this.$eq = function (b) {
      return (this.Left === b.Left) && (this.Top === b.Top) && (this.Right === b.Right) && (this.Bottom === b.Bottom);
    };
    this.$assign = function (s) {
      this.Left = s.Left;
      this.Top = s.Top;
      this.Right = s.Right;
      this.Bottom = s.Bottom;
      return this;
    };
    this.GetBottomRight = function () {
      var Result = $mod.TPoint.$new();
      Result.$assign($mod.Point(this.Right,this.Bottom));
      return Result;
    };
    this.getHeight = function () {
      var Result = 0;
      Result = this.Bottom - this.Top;
      return Result;
    };
    this.getLocation = function () {
      var Result = $mod.TPoint.$new();
      Result.X = this.Left;
      Result.Y = this.Top;
      return Result;
    };
    this.getSize = function () {
      var Result = $mod.TSize.$new();
      Result.cx = this.getWidth();
      Result.cy = this.getHeight();
      return Result;
    };
    this.GetTopLeft = function () {
      var Result = $mod.TPoint.$new();
      Result.$assign($mod.Point(this.Left,this.Top));
      return Result;
    };
    this.getWidth = function () {
      var Result = 0;
      Result = this.Right - this.Left;
      return Result;
    };
    this.SetBottomRight = function (aValue) {
      this.Bottom = aValue.Y;
      this.Right = aValue.X;
    };
    this.setHeight = function (AValue) {
      this.Bottom = this.Top + AValue;
    };
    this.setSize = function (AValue) {
      this.Bottom = this.Top + AValue.cy;
      this.Right = this.Left + AValue.cx;
    };
    this.SetTopLeft = function (aValue) {
      this.Top = aValue.Y;
      this.Left = aValue.X;
    };
    this.setWidth = function (AValue) {
      this.Right = this.Left + AValue;
    };
    this.Create = function (Origin) {
      this.SetTopLeft(Origin);
      this.SetBottomRight(Origin);
      return this;
    };
    this.Create$1 = function (Origin, AWidth, AHeight) {
      this.SetTopLeft(Origin);
      this.setWidth(AWidth);
      this.setHeight(AHeight);
      return this;
    };
    this.Create$2 = function (ALeft, ATop, ARight, ABottom) {
      this.Left = ALeft;
      this.Top = ATop;
      this.Right = ARight;
      this.Bottom = ABottom;
      return this;
    };
    this.Create$3 = function (P1, P2, Normalize) {
      this.SetTopLeft(P1);
      this.SetBottomRight(P2);
      if (Normalize) this.NormalizeRect();
      return this;
    };
    this.Create$4 = function (R, Normalize) {
      this.$assign(R);
      if (Normalize) this.NormalizeRect();
      return this;
    };
    this.Empty = function () {
      var Result = $mod.TRect.$new();
      Result.$assign($mod.TRect.$new().Create$2(0,0,0,0));
      return Result;
    };
    this.NormalizeRect = function () {
      var x = 0;
      if (this.Top > this.Bottom) {
        x = this.Top;
        this.Top = this.Bottom;
        this.Bottom = x;
      };
      if (this.Left > this.Right) {
        x = this.Left;
        this.Left = this.Right;
        this.Right = x;
      };
    };
    this.IsEmpty = function () {
      var Result = false;
      Result = (this.Right <= this.Left) || (this.Bottom <= this.Top);
      return Result;
    };
    this.Contains = function (Pt) {
      var Result = false;
      Result = (this.Left <= Pt.X) && (Pt.X < this.Right) && (this.Top <= Pt.Y) && (Pt.Y < this.Bottom);
      return Result;
    };
    this.Contains$1 = function (R) {
      var Result = false;
      Result = (this.Left <= R.Left) && (R.Right <= this.Right) && (this.Top <= R.Top) && (R.Bottom <= this.Bottom);
      return Result;
    };
    this.IntersectsWith = function (R) {
      var Result = false;
      Result = (this.Left < R.Right) && (R.Left < this.Right) && (this.Top < R.Bottom) && (R.Top < this.Bottom);
      return Result;
    };
    this.Intersect = function (R1, R2) {
      var Result = $mod.TRect.$new();
      $mod.IntersectRect(Result,R1,R2);
      return Result;
    };
    this.Intersect$1 = function (R) {
      this.$assign(this.Intersect($mod.TRect.$clone(this),$mod.TRect.$clone(R)));
    };
    this.Union = function (R1, R2) {
      var Result = $mod.TRect.$new();
      $mod.UnionRect(Result,R1,R2);
      return Result;
    };
    this.Union$1 = function (R) {
      this.$assign(this.Union($mod.TRect.$clone(this),$mod.TRect.$clone(R)));
    };
    this.Union$2 = function (Points) {
      var Result = $mod.TRect.$new();
      var i = 0;
      if (rtl.length(Points) > 0) {
        Result.SetTopLeft(Points[0]);
        Result.SetBottomRight(Points[0]);
        for (var $l = 1, $end = rtl.length(Points) - 1; $l <= $end; $l++) {
          i = $l;
          if (Points[i].X < Result.Left) Result.Left = Points[i].X;
          if (Points[i].X > Result.Right) Result.Right = Points[i].X;
          if (Points[i].Y < Result.Top) Result.Top = Points[i].Y;
          if (Points[i].Y > Result.Bottom) Result.Bottom = Points[i].Y;
        };
      } else Result.$assign($mod.TRect.Empty());
      return Result;
    };
    this.Offset = function (DX, DY) {
      $mod.OffsetRect(this,DX,DY);
    };
    this.Offset$1 = function (DP) {
      $mod.OffsetRect(this,DP.X,DP.Y);
    };
    this.SetLocation = function (X, Y) {
      this.Offset(X - this.Left,Y - this.Top);
    };
    this.SetLocation$1 = function (P) {
      this.SetLocation(P.X,P.Y);
    };
    this.Inflate = function (DX, DY) {
      $mod.InflateRect(this,DX,DY);
    };
    this.Inflate$1 = function (DL, DT, DR, DB) {
      this.Left -= DL;
      this.Top -= DT;
      this.Right += DR;
      this.Bottom += DB;
    };
    this.CenterPoint = function () {
      var Result = $mod.TPoint.$new();
      Result.X = Math.floor((this.Right - this.Left) / 2) + this.Left;
      Result.Y = Math.floor((this.Bottom - this.Top) / 2) + this.Top;
      return Result;
    };
    this.SplitRect = function (SplitType, ASize) {
      var Result = $mod.TRect.$new();
      Result.$assign(this);
      var $tmp = SplitType;
      if ($tmp === $mod.TSplitRectType.srLeft) {
        Result.Right = this.Left + ASize}
       else if ($tmp === $mod.TSplitRectType.srRight) {
        Result.Left = this.Right - ASize}
       else if ($tmp === $mod.TSplitRectType.srTop) {
        Result.Bottom = this.Top + ASize}
       else if ($tmp === $mod.TSplitRectType.srBottom) Result.Top = this.Bottom - ASize;
      return Result;
    };
    this.SplitRect$1 = function (SplitType, Percent) {
      var Result = $mod.TRect.$new();
      Result.$assign(this);
      var $tmp = SplitType;
      if ($tmp === $mod.TSplitRectType.srLeft) {
        Result.Right = this.Left + pas.System.Trunc(Percent * this.getWidth())}
       else if ($tmp === $mod.TSplitRectType.srRight) {
        Result.Left = this.Right - pas.System.Trunc(Percent * this.getWidth())}
       else if ($tmp === $mod.TSplitRectType.srTop) {
        Result.Bottom = this.Top + pas.System.Trunc(Percent * this.getHeight())}
       else if ($tmp === $mod.TSplitRectType.srBottom) Result.Top = this.Bottom - pas.System.Trunc(Percent * this.getHeight());
      return Result;
    };
    var $r = $mod.$rtti.$Record("TRect",{});
    $r.addMethod("Create",2,[["Origin",$mod.$rtti["TPoint"]]]);
    $r.addMethod("Create$1",2,[["Origin",$mod.$rtti["TPoint"]],["AWidth",rtl.longint],["AHeight",rtl.longint]]);
    $r.addMethod("Create$2",2,[["ALeft",rtl.longint],["ATop",rtl.longint],["ARight",rtl.longint],["ABottom",rtl.longint]]);
    $r.addMethod("Create$3",2,[["P1",$mod.$rtti["TPoint"]],["P2",$mod.$rtti["TPoint"]],["Normalize",rtl.boolean]]);
    $r.addMethod("Create$4",2,[["R",$r],["Normalize",rtl.boolean]]);
    $r.addMethod("Empty",5,null,$r,{flags: 1});
    $r.addMethod("NormalizeRect",0,null);
    $r.addMethod("IsEmpty",1,null,rtl.boolean);
    $r.addMethod("Contains",1,[["Pt",$mod.$rtti["TPoint"]]],rtl.boolean);
    $r.addMethod("Contains$1",1,[["R",$r]],rtl.boolean);
    $r.addMethod("IntersectsWith",1,[["R",$r]],rtl.boolean);
    $r.addMethod("Intersect",5,[["R1",$r],["R2",$r]],$r,{flags: 1});
    $r.addMethod("Intersect$1",0,[["R",$r]]);
    $r.addMethod("Union",5,[["R1",$r],["R2",$r]],$r,{flags: 1});
    $r.addMethod("Union$1",0,[["R",$r]]);
    $r.addMethod("Union$2",5,[["Points",$mod.$rtti["TPoint"],10]],$r,{flags: 1});
    $r.addMethod("Offset",0,[["DX",rtl.longint],["DY",rtl.longint]]);
    $r.addMethod("Offset$1",0,[["DP",$mod.$rtti["TPoint"]]]);
    $r.addMethod("SetLocation",0,[["X",rtl.longint],["Y",rtl.longint]]);
    $r.addMethod("SetLocation$1",0,[["P",$mod.$rtti["TPoint"]]]);
    $r.addMethod("Inflate",0,[["DX",rtl.longint],["DY",rtl.longint]]);
    $r.addMethod("Inflate$1",0,[["DL",rtl.longint],["DT",rtl.longint],["DR",rtl.longint],["DB",rtl.longint]]);
    $r.addMethod("CenterPoint",1,null,$mod.$rtti["TPoint"]);
    $r.addMethod("SplitRect",1,[["SplitType",$mod.$rtti["TSplitRectType"]],["ASize",rtl.longint]],$r);
    $r.addMethod("SplitRect$1",1,[["SplitType",$mod.$rtti["TSplitRectType"]],["Percent",rtl.double]],$r);
    $r.addField("Left",rtl.longint);
    $r.addField("Top",rtl.longint);
    $r.addField("Right",rtl.longint);
    $r.addField("Bottom",rtl.longint);
    $r.addProperty("Height",3,rtl.longint,"getHeight","setHeight");
    $r.addProperty("Width",3,rtl.longint,"getWidth","setWidth");
    $r.addProperty("Size",3,$mod.$rtti["TSize"],"getSize","setSize");
    $r.addProperty("Location",3,$mod.$rtti["TPoint"],"getLocation","SetLocation$1");
    $r.addProperty("TopLeft",3,$mod.$rtti["TPoint"],"GetTopLeft","SetTopLeft");
    $r.addProperty("BottomRight",3,$mod.$rtti["TPoint"],"GetBottomRight","SetBottomRight");
  },true);
  $mod.$rtti.$inherited("PRect",{comptype: $mod.$rtti["TRect"]});
  $mod.$rtti.$inherited("PPointF",{comptype: $mod.$rtti["TPointF"]});
  rtl.recNewT($mod,"TPointF",function () {
    this.x = 0.0;
    this.y = 0.0;
    this.$eq = function (b) {
      return (this.x === b.x) && (this.y === b.y);
    };
    this.$assign = function (s) {
      this.x = s.x;
      this.y = s.y;
      return this;
    };
    this.Add = function (apt) {
      var Result = $mod.TPointF.$new();
      Result.x = this.x + apt.X;
      Result.y = this.y + apt.Y;
      return Result;
    };
    this.Add$1 = function (apt) {
      var Result = $mod.TPointF.$new();
      Result.x = this.x + apt.x;
      Result.y = this.y + apt.y;
      return Result;
    };
    this.Distance = function (apt) {
      var Result = 0.0;
      Result = Math.sqrt(pas.System.Sqr$1(apt.x - this.x) + pas.System.Sqr$1(apt.y - this.y));
      return Result;
    };
    this.DotProduct = function (apt) {
      var Result = 0.0;
      Result = (this.x * apt.x) + (this.y * apt.y);
      return Result;
    };
    this.IsZero = function () {
      var Result = false;
      Result = pas.Math.SameValue(this.x,0.0,0.0) && pas.Math.SameValue(this.y,0.0,0.0);
      return Result;
    };
    this.Subtract = function (apt) {
      var Result = $mod.TPointF.$new();
      Result.x = this.x - apt.x;
      Result.y = this.y - apt.y;
      return Result;
    };
    this.Subtract$1 = function (apt) {
      var Result = $mod.TPointF.$new();
      Result.x = this.x - apt.X;
      Result.y = this.y - apt.Y;
      return Result;
    };
    this.SetLocation = function (apt) {
      this.x = apt.x;
      this.y = apt.y;
    };
    this.SetLocation$1 = function (apt) {
      this.x = apt.X;
      this.y = apt.Y;
    };
    this.SetLocation$2 = function (ax, ay) {
      this.x = ax;
      this.y = ay;
    };
    this.Offset = function (apt) {
      this.x = this.x + apt.x;
      this.y = this.y + apt.y;
    };
    this.Offset$1 = function (apt) {
      this.x = this.x + apt.X;
      this.y = this.y + apt.Y;
    };
    this.Offset$2 = function (dx, dy) {
      this.x = this.x + dx;
      this.y = this.y + dy;
    };
    this.EqualsTo = function (apt, aEpsilon) {
      var $Self = this;
      var Result = false;
      function Eq(a, b) {
        var Result = false;
        Result = Math.abs(a - b) <= aEpsilon;
        return Result;
      };
      Result = Eq($Self.x,apt.x) && Eq($Self.y,apt.y);
      return Result;
    };
    this.EqualsTo$1 = function (apt) {
      var Result = false;
      Result = this.EqualsTo(apt,0);
      return Result;
    };
    this.Scale = function (afactor) {
      var Result = $mod.TPointF.$new();
      Result.x = afactor * this.x;
      Result.y = afactor * this.y;
      return Result;
    };
    this.Ceiling = function () {
      var Result = $mod.TPoint.$new();
      Result.X = pas.Math.Ceil(this.x);
      Result.Y = pas.Math.Ceil(this.y);
      return Result;
    };
    this.Truncate = function () {
      var Result = $mod.TPoint.$new();
      Result.X = pas.System.Trunc(this.x);
      Result.Y = pas.System.Trunc(this.y);
      return Result;
    };
    this.Floor = function () {
      var Result = $mod.TPoint.$new();
      Result.X = pas.Math.Floor(this.x);
      Result.Y = pas.Math.Floor(this.y);
      return Result;
    };
    this.Round = function () {
      var Result = $mod.TPoint.$new();
      Result.X = Math.round(this.x);
      Result.Y = Math.round(this.y);
      return Result;
    };
    this.Length = function () {
      var Result = 0.0;
      Result = Math.sqrt(pas.System.Sqr$1(this.x) + pas.System.Sqr$1(this.y));
      return Result;
    };
    this.Rotate = function (angle) {
      var Result = $mod.TPointF.$new();
      var sina = 0.0;
      var cosa = 0.0;
      pas.Math.SinCos(angle,{get: function () {
          return sina;
        }, set: function (v) {
          sina = v;
        }},{get: function () {
          return cosa;
        }, set: function (v) {
          cosa = v;
        }});
      Result.x = (this.x * cosa) - (this.y * sina);
      Result.y = (this.x * sina) + (this.y * cosa);
      return Result;
    };
    this.Reflect = function (normal) {
      var Result = $mod.TPointF.$new();
      var lCross = 0.0;
      var lTmp = $mod.TPointF.$new();
      lCross = (this.x * normal.x) + (this.y * normal.y);
      lCross = lCross * -2;
      lTmp.x = normal.x * lCross;
      lTmp.y = normal.y * lCross;
      Result.x = this.x + lTmp.x;
      Result.y = this.y + lTmp.y;
      return Result;
    };
    this.MidPoint = function (b) {
      var Result = $mod.TPointF.$new();
      Result.x = 0.5 * (this.x + b.x);
      Result.y = 0.5 * (this.y + b.y);
      return Result;
    };
    this.PointInCircle = function (pt, center, radius) {
      var Result = false;
      Result = (pas.System.Sqr$1(center.x - pt.x) + pas.System.Sqr$1(center.y - pt.y)) < pas.System.Sqr$1(radius);
      return Result;
    };
    this.PointInCircle$1 = function (pt, center, radius) {
      var Result = false;
      Result = (pas.System.Sqr$1(center.x - pt.x) + pas.System.Sqr$1(center.y - pt.y)) < pas.System.Sqr$1(radius);
      return Result;
    };
    this.Zero = function () {
      var Result = $mod.TPointF.$new();
      Result.x = 0;
      Result.y = 0;
      return Result;
    };
    this.Angle = function (b) {
      var Result = 0.0;
      Result = Math.atan2(this.y - b.y,this.x - b.x);
      return Result;
    };
    this.AngleCosine = function (b) {
      var Result = 0.0;
      var lCross = 0.0;
      lCross = (this.x * b.x) + (this.y * b.y);
      Result = pas.Math.EnsureRange$1(lCross / Math.sqrt((pas.System.Sqr$1(this.x) + pas.System.Sqr$1(this.y)) * (pas.System.Sqr$1(b.x) + pas.System.Sqr$1(b.y))),-1,1);
      return Result;
    };
    this.CrossProduct = function (apt) {
      var Result = 0.0;
      Result = (this.x * apt.y) - (this.y * apt.x);
      return Result;
    };
    this.Normalize = function () {
      var Result = $mod.TPointF.$new();
      var L = 0.0;
      L = Math.sqrt(pas.System.Sqr$1(this.x) + pas.System.Sqr$1(this.y));
      if (pas.Math.SameValue(L,0,1.1E-10)) {
        Result.$assign(this)}
       else {
        Result.x = this.x / L;
        Result.y = this.y / L;
      };
      return Result;
    };
    this.ToString = function (aSize, aDecimals) {
      var Result = "";
      var Sx = "";
      var Sy = "";
      Sx = $impl.SingleToStr(this.x,aSize,aDecimals);
      Sy = $impl.SingleToStr(this.y,aSize,aDecimals);
      Result = "(" + Sx + "," + Sy + ")";
      return Result;
    };
    this.ToString$1 = function () {
      var Result = "";
      Result = this.ToString(8,2);
      return Result;
    };
    this.Create = function (ax, ay) {
      var Result = $mod.TPointF.$new();
      Result.x = ax;
      Result.y = ay;
      return Result;
    };
    this.Create$1 = function (apt) {
      var Result = $mod.TPointF.$new();
      Result.x = apt.X;
      Result.y = apt.Y;
      return Result;
    };
    var $r = $mod.$rtti.$Record("TPointF",{});
    $r.addField("x",rtl.double);
    $r.addField("y",rtl.double);
    $r.addMethod("Add",1,[["apt",$mod.$rtti["TPoint"],2]],$r);
    $r.addMethod("Add$1",1,[["apt",$r,2]],$r);
    $r.addMethod("Distance",1,[["apt",$r,2]],rtl.double);
    $r.addMethod("DotProduct",1,[["apt",$r,2]],rtl.double);
    $r.addMethod("IsZero",1,null,rtl.boolean);
    $r.addMethod("Subtract",1,[["apt",$r,2]],$r);
    $r.addMethod("Subtract$1",1,[["apt",$mod.$rtti["TPoint"],2]],$r);
    $r.addMethod("SetLocation",0,[["apt",$r,2]]);
    $r.addMethod("SetLocation$1",0,[["apt",$mod.$rtti["TPoint"],2]]);
    $r.addMethod("SetLocation$2",0,[["ax",rtl.double],["ay",rtl.double]]);
    $r.addMethod("Offset",0,[["apt",$r,2]]);
    $r.addMethod("Offset$1",0,[["apt",$mod.$rtti["TPoint"],2]]);
    $r.addMethod("Offset$2",0,[["dx",rtl.double],["dy",rtl.double]]);
    $r.addMethod("EqualsTo",1,[["apt",$r,2],["aEpsilon",rtl.double,2]],rtl.boolean);
    $r.addMethod("EqualsTo$1",1,[["apt",$r,2]],rtl.boolean);
    $r.addMethod("Scale",1,[["afactor",rtl.double]],$r);
    $r.addMethod("Ceiling",1,null,$mod.$rtti["TPoint"]);
    $r.addMethod("Truncate",1,null,$mod.$rtti["TPoint"]);
    $r.addMethod("Floor",1,null,$mod.$rtti["TPoint"]);
    $r.addMethod("Round",1,null,$mod.$rtti["TPoint"]);
    $r.addMethod("Length",1,null,rtl.double);
    $r.addMethod("Rotate",1,[["angle",rtl.double]],$r);
    $r.addMethod("Reflect",1,[["normal",$r,2]],$r);
    $r.addMethod("MidPoint",1,[["b",$r,2]],$r);
    $r.addMethod("PointInCircle",5,[["pt",$r,2],["center",$r,2],["radius",rtl.double]],rtl.boolean,{flags: 1});
    $r.addMethod("PointInCircle$1",5,[["pt",$r,2],["center",$r,2],["radius",rtl.longint]],rtl.boolean,{flags: 1});
    $r.addMethod("Zero",5,null,$r,{flags: 1});
    $r.addMethod("Angle",1,[["b",$r,2]],rtl.double);
    $r.addMethod("AngleCosine",1,[["b",$r,2]],rtl.double);
    $r.addMethod("CrossProduct",1,[["apt",$r,2]],rtl.double);
    $r.addMethod("Normalize",1,null,$r);
    $r.addMethod("ToString",1,[["aSize",rtl.byte],["aDecimals",rtl.byte]],rtl.string);
    $r.addMethod("ToString$1",1,null,rtl.string);
    $r.addMethod("Create",5,[["ax",rtl.double,2],["ay",rtl.double,2]],$r,{flags: 1});
    $r.addMethod("Create$1",5,[["apt",$mod.$rtti["TPoint"],2]],$r,{flags: 1});
  });
  $mod.$rtti.$inherited("PSizeF",{comptype: $mod.$rtti["TSizeF"]});
  rtl.recNewT($mod,"TSizeF",function () {
    this.cx = 0.0;
    this.cy = 0.0;
    this.$eq = function (b) {
      return (this.cx === b.cx) && (this.cy === b.cy);
    };
    this.$assign = function (s) {
      this.cx = s.cx;
      this.cy = s.cy;
      return this;
    };
    this.Add = function (asz) {
      var Result = $mod.TSizeF.$new();
      Result.cx = this.cx + asz.cx;
      Result.cy = this.cy + asz.cy;
      return Result;
    };
    this.Add$1 = function (asz) {
      var Result = $mod.TSizeF.$new();
      Result.cx = this.cx + asz.cx;
      Result.cy = this.cy + asz.cy;
      return Result;
    };
    this.Distance = function (asz) {
      var Result = 0.0;
      Result = Math.sqrt(pas.System.Sqr$1(asz.cx - this.cx) + pas.System.Sqr$1(asz.cy - this.cy));
      return Result;
    };
    this.IsZero = function () {
      var Result = false;
      Result = pas.Math.SameValue(this.cx,0.0,0.0) && pas.Math.SameValue(this.cy,0.0,0.0);
      return Result;
    };
    this.Subtract = function (asz) {
      var Result = $mod.TSizeF.$new();
      Result.cx = this.cx - asz.cx;
      Result.cy = this.cy - asz.cy;
      return Result;
    };
    this.Subtract$1 = function (asz) {
      var Result = $mod.TSizeF.$new();
      Result.cx = this.cx - asz.cx;
      Result.cy = this.cy - asz.cy;
      return Result;
    };
    this.SwapDimensions = function () {
      var Result = $mod.TSizeF.$new();
      Result.cx = this.cy;
      Result.cy = this.cx;
      return Result;
    };
    this.Scale = function (afactor) {
      var Result = $mod.TSizeF.$new();
      Result.cx = afactor * this.cx;
      Result.cy = afactor * this.cy;
      return Result;
    };
    this.Ceiling = function () {
      var Result = $mod.TSize.$new();
      Result.cx = pas.Math.Ceil(this.cx);
      Result.cy = pas.Math.Ceil(this.cy);
      return Result;
    };
    this.Truncate = function () {
      var Result = $mod.TSize.$new();
      Result.cx = pas.System.Trunc(this.cx);
      Result.cy = pas.System.Trunc(this.cy);
      return Result;
    };
    this.Floor = function () {
      var Result = $mod.TSize.$new();
      Result.cx = pas.Math.Floor(this.cx);
      Result.cy = pas.Math.Floor(this.cy);
      return Result;
    };
    this.Round = function () {
      var Result = $mod.TSize.$new();
      Result.cx = Math.round(this.cx);
      Result.cy = Math.round(this.cy);
      return Result;
    };
    this.Length = function () {
      var Result = 0.0;
      Result = Math.sqrt(pas.System.Sqr$1(this.cx) + pas.System.Sqr$1(this.cy));
      return Result;
    };
    this.ToString = function (aSize, aDecimals) {
      var Result = "";
      var Sx = "";
      var Sy = "";
      Sx = $impl.SingleToStr(this.cx,aSize,aDecimals);
      Sy = $impl.SingleToStr(this.cy,aSize,aDecimals);
      Result = "(" + Sx + "x" + Sy + ")";
      return Result;
    };
    this.ToString$1 = function () {
      var Result = "";
      Result = this.ToString(8,2);
      return Result;
    };
    this.Create = function (ax, ay) {
      var Result = $mod.TSizeF.$new();
      Result.cx = ax;
      Result.cy = ay;
      return Result;
    };
    this.Create$1 = function (asz) {
      var Result = $mod.TSizeF.$new();
      Result.cx = asz.cx;
      Result.cy = asz.cy;
      return Result;
    };
    var $r = $mod.$rtti.$Record("TSizeF",{});
    $r.addField("cx",rtl.double);
    $r.addField("cy",rtl.double);
    $r.addMethod("Add",1,[["asz",$mod.$rtti["TSize"],2]],$r);
    $r.addMethod("Add$1",1,[["asz",$r,2]],$r);
    $r.addMethod("Distance",1,[["asz",$r,2]],rtl.double);
    $r.addMethod("IsZero",1,null,rtl.boolean);
    $r.addMethod("Subtract",1,[["asz",$r,2]],$r);
    $r.addMethod("Subtract$1",1,[["asz",$mod.$rtti["TSize"],2]],$r);
    $r.addMethod("SwapDimensions",1,null,$r);
    $r.addMethod("Scale",1,[["afactor",rtl.double]],$r);
    $r.addMethod("Ceiling",1,null,$mod.$rtti["TSize"]);
    $r.addMethod("Truncate",1,null,$mod.$rtti["TSize"]);
    $r.addMethod("Floor",1,null,$mod.$rtti["TSize"]);
    $r.addMethod("Round",1,null,$mod.$rtti["TSize"]);
    $r.addMethod("Length",1,null,rtl.double);
    $r.addMethod("ToString",1,[["aSize",rtl.byte],["aDecimals",rtl.byte]],rtl.string);
    $r.addMethod("ToString$1",1,null,rtl.string);
    $r.addMethod("Create",5,[["ax",rtl.double,2],["ay",rtl.double,2]],$r,{flags: 1});
    $r.addMethod("Create$1",5,[["asz",$mod.$rtti["TSize"],2]],$r,{flags: 1});
    $r.addProperty("Width",0,rtl.double,"cx","cx");
    $r.addProperty("Height",0,rtl.double,"cy","cy");
  });
  this.TVertRectAlign = {"0": "Center", Center: 0, "1": "Top", Top: 1, "2": "Bottom", Bottom: 2};
  $mod.$rtti.$Enum("TVertRectAlign",{minvalue: 0, maxvalue: 2, ordtype: 1, enumtype: this.TVertRectAlign});
  this.THorzRectAlign = {"0": "Center", Center: 0, "1": "Left", Left: 1, "2": "Right", Right: 2};
  $mod.$rtti.$Enum("THorzRectAlign",{minvalue: 0, maxvalue: 2, ordtype: 1, enumtype: this.THorzRectAlign});
  $mod.$rtti.$inherited("PRectF",{comptype: $mod.$rtti["TRectF"]});
  rtl.recNewT($mod,"TRectF",function () {
    this.Left = 0.0;
    this.Top = 0.0;
    this.Right = 0.0;
    this.Bottom = 0.0;
    this.$eq = function (b) {
      return (this.Left === b.Left) && (this.Top === b.Top) && (this.Right === b.Right) && (this.Bottom === b.Bottom);
    };
    this.$assign = function (s) {
      this.Left = s.Left;
      this.Top = s.Top;
      this.Right = s.Right;
      this.Bottom = s.Bottom;
      return this;
    };
    this.GetBottomRight = function () {
      var Result = $mod.TPointF.$new();
      Result.$assign($mod.TPointF.Create(this.Right,this.Bottom));
      return Result;
    };
    this.GetLocation = function () {
      var Result = $mod.TPointF.$new();
      Result.x = this.Left;
      Result.y = this.Top;
      return Result;
    };
    this.GetSize = function () {
      var Result = $mod.TSizeF.$new();
      Result.cx = this.GetWidth();
      Result.cy = this.GetHeight();
      return Result;
    };
    this.GetTopLeft = function () {
      var Result = $mod.TPointF.$new();
      Result.$assign($mod.TPointF.Create(this.Left,this.Top));
      return Result;
    };
    this.SetBottomRight = function (aValue) {
      this.Right = aValue.x;
      this.Bottom = aValue.y;
    };
    this.SetSize = function (AValue) {
      this.Bottom = this.Top + AValue.cy;
      this.Right = this.Left + AValue.cx;
    };
    this.GetHeight = function () {
      var Result = 0.0;
      Result = this.Bottom - this.Top;
      return Result;
    };
    this.GetWidth = function () {
      var Result = 0.0;
      Result = this.Right - this.Left;
      return Result;
    };
    this.SetHeight = function (AValue) {
      this.Bottom = this.Top + AValue;
    };
    this.SetTopLeft = function (aValue) {
      this.Left = aValue.x;
      this.Top = aValue.y;
    };
    this.SetWidth = function (AValue) {
      this.Right = this.Left + AValue;
    };
    this.Create = function (Origin) {
      this.SetTopLeft(Origin);
      this.SetBottomRight(Origin);
      return this;
    };
    this.Create$1 = function (Origin, AWidth, AHeight) {
      this.SetTopLeft(Origin);
      this.SetWidth(AWidth);
      this.SetHeight(AHeight);
      return this;
    };
    this.Create$2 = function (ALeft, ATop, ARight, ABottom) {
      this.Left = ALeft;
      this.Top = ATop;
      this.Right = ARight;
      this.Bottom = ABottom;
      return this;
    };
    this.Create$3 = function (P1, P2, Normalize) {
      this.SetTopLeft(P1);
      this.SetBottomRight(P2);
      if (Normalize) this.NormalizeRect();
      return this;
    };
    this.Create$4 = function (R, Normalize) {
      this.$assign(R);
      if (Normalize) this.NormalizeRect();
      return this;
    };
    this.Create$5 = function (R, Normalize) {
      this.Left = R.Left;
      this.Top = R.Top;
      this.Right = R.Right;
      this.Bottom = R.Bottom;
      if (Normalize) this.NormalizeRect();
      return this;
    };
    this.Empty = function () {
      var Result = $mod.TRectF.$new();
      Result.$assign($mod.TRectF.$new().Create$2(0,0,0,0));
      return Result;
    };
    this.Intersect = function (R1, R2) {
      var Result = $mod.TRectF.$new();
      Result.$assign(R1);
      if (R2.Left > R1.Left) Result.Left = R2.Left;
      if (R2.Top > R1.Top) Result.Top = R2.Top;
      if (R2.Right < R1.Right) Result.Right = R2.Right;
      if (R2.Bottom < R1.Bottom) Result.Bottom = R2.Bottom;
      return Result;
    };
    this.Union = function (Points) {
      var Result = $mod.TRectF.$new();
      var i = 0;
      if (rtl.length(Points) > 0) {
        Result.SetTopLeft(Points[0]);
        Result.SetBottomRight(Points[0]);
        for (var $l = 1, $end = rtl.length(Points) - 1; $l <= $end; $l++) {
          i = $l;
          if (Points[i].x < Result.Left) Result.Left = Points[i].x;
          if (Points[i].x > Result.Right) Result.Right = Points[i].x;
          if (Points[i].y < Result.Top) Result.Top = Points[i].y;
          if (Points[i].y > Result.Bottom) Result.Bottom = Points[i].y;
        };
      } else Result.$assign($mod.TRectF.Empty());
      return Result;
    };
    this.Union$1 = function (R1, R2) {
      var Result = $mod.TRectF.$new();
      Result.$assign(R1);
      Result.Union$2(R2);
      return Result;
    };
    this.Ceiling = function () {
      var Result = $mod.TRectF.$new();
      Result.SetBottomRight($mod.TPointF.Create(this.GetBottomRight().Ceiling().X,this.GetBottomRight().Ceiling().Y));
      Result.SetTopLeft($mod.TPointF.Create(this.GetTopLeft().Ceiling().X,this.GetTopLeft().Ceiling().Y));
      return Result;
    };
    this.CenterAt = function (Dest) {
      var Result = $mod.TRectF.$new();
      Result.$assign(this);
      $mod.RectCenter$1(Result,Dest);
      return Result;
    };
    this.CenterPoint = function () {
      var Result = $mod.TPointF.$new();
      Result.x = ((this.Right - this.Left) / 2) + this.Left;
      Result.y = ((this.Bottom - this.Top) / 2) + this.Top;
      return Result;
    };
    this.Contains = function (Pt) {
      var Result = false;
      Result = (this.Left <= Pt.x) && (Pt.x < this.Right) && (this.Top <= Pt.y) && (Pt.y < this.Bottom);
      return Result;
    };
    this.Contains$1 = function (R) {
      var Result = false;
      Result = (this.Left <= R.Left) && (R.Right <= this.Right) && (this.Top <= R.Top) && (R.Bottom <= this.Bottom);
      return Result;
    };
    this.EqualsTo = function (R, Epsilon) {
      var Result = false;
      Result = this.GetTopLeft().EqualsTo(R.GetTopLeft(),Epsilon);
      Result = Result && this.GetBottomRight().EqualsTo(R.GetBottomRight(),Epsilon);
      return Result;
    };
    this.Fit = function (Dest) {
      var Result = 0.0;
      var R = $mod.TRectF.$new();
      R.$assign(this.FitInto$1(Dest,{get: function () {
          return Result;
        }, set: function (v) {
          Result = v;
        }}));
      this.$assign(R);
      return Result;
    };
    this.FitInto = function (Dest) {
      var Result = $mod.TRectF.$new();
      var Ratio = 0.0;
      Result.$assign(this.FitInto$1(Dest,{get: function () {
          return Ratio;
        }, set: function (v) {
          Ratio = v;
        }}));
      return Result;
    };
    this.FitInto$1 = function (Dest, Ratio) {
      var Result = $mod.TRectF.$new();
      if ((Dest.GetWidth() <= 0) || (Dest.GetHeight() <= 0)) {
        Ratio.set(1.0);
        return this;
      };
      Ratio.set(Math.max(this.GetWidth() / Dest.GetWidth(),this.GetHeight() / Dest.GetHeight()));
      if (Ratio.get() === 0) return this;
      Result.SetWidth(this.GetWidth() / Ratio.get());
      Result.SetHeight(this.GetHeight() / Ratio.get());
      Result.Left = this.Left + ((this.GetWidth() - Result.GetWidth()) / 2);
      Result.Top = this.Top + ((this.GetHeight() - Result.GetHeight()) / 2);
      return Result;
    };
    this.IntersectsWith = function (R) {
      var Result = false;
      Result = (this.Left < R.Right) && (R.Left < this.Right) && (this.Top < R.Bottom) && (R.Top < this.Bottom);
      return Result;
    };
    this.IsEmpty = function () {
      var Result = false;
      Result = (pas.Math.CompareValue$3(this.Right,this.Left,0.0) <= 0) || (pas.Math.CompareValue$3(this.Bottom,this.Top,0.0) <= 0);
      return Result;
    };
    this.PlaceInto = function (Dest, AHorzAlign, AVertAlign) {
      var Result = $mod.TRectF.$new();
      var R = $mod.TRectF.$new();
      var X = 0.0;
      var Y = 0.0;
      if ((this.GetHeight() > Dest.GetHeight()) || (this.GetWidth() > Dest.GetWidth())) {
        R.$assign(this.FitInto(Dest))}
       else R.$assign(this);
      var $tmp = AHorzAlign;
      if ($tmp === $mod.THorzRectAlign.Left) {
        X = Dest.Left}
       else if ($tmp === $mod.THorzRectAlign.Center) {
        X = ((Dest.Left + Dest.Right) - R.GetWidth()) / 2}
       else if ($tmp === $mod.THorzRectAlign.Right) X = Dest.Right - R.GetWidth();
      var $tmp1 = AVertAlign;
      if ($tmp1 === $mod.TVertRectAlign.Top) {
        Y = Dest.Top}
       else if ($tmp1 === $mod.TVertRectAlign.Center) {
        Y = ((Dest.Top + Dest.Bottom) - R.GetHeight()) / 2}
       else if ($tmp1 === $mod.TVertRectAlign.Bottom) Y = Dest.Bottom - R.GetHeight();
      R.SetLocation($mod.TPointF.$clone($mod.PointF(X,Y)));
      Result.$assign(R);
      return Result;
    };
    this.Round = function () {
      var Result = $mod.TRect.$new();
      Result.SetBottomRight(this.GetBottomRight().Round());
      Result.SetTopLeft(this.GetTopLeft().Round());
      return Result;
    };
    this.SnapToPixel = function (AScale, APlaceBetweenPixels) {
      var $Self = this;
      var Result = $mod.TRectF.$new();
      function sc(S) {
        var Result = 0.0;
        Result = pas.System.Trunc(S * AScale) / AScale;
        return Result;
      };
      var R = $mod.TRectF.$new();
      var Off = 0.0;
      if (AScale <= 0) AScale = 1;
      R.Top = sc($Self.Top);
      R.Left = sc($Self.Left);
      R.SetWidth(sc($Self.GetWidth()));
      R.SetHeight(sc($Self.GetHeight()));
      if (APlaceBetweenPixels) {
        Off = 1 / (2 * AScale);
        R.Offset(Off,Off);
      };
      Result.$assign(R);
      return Result;
    };
    this.Truncate = function () {
      var Result = $mod.TRect.$new();
      Result.SetBottomRight(this.GetBottomRight().Truncate());
      Result.SetTopLeft(this.GetTopLeft().Truncate());
      return Result;
    };
    this.Inflate = function (DL, DT, DR, DB) {
      this.Left = this.Left - DL;
      this.Top = this.Top - DT;
      this.Right = this.Right + DR;
      this.Bottom = this.Bottom + DB;
    };
    this.Inflate$1 = function (DX, DY) {
      this.Left = this.Left - DX;
      this.Top = this.Top - DY;
      this.Right = this.Right + DX;
      this.Bottom = this.Bottom + DY;
    };
    this.Intersect$1 = function (R) {
      this.$assign(this.Intersect($mod.TRectF.$clone(this),$mod.TRectF.$clone(R)));
    };
    this.NormalizeRect = function () {
      var x = 0.0;
      if (this.Top > this.Bottom) {
        x = this.Top;
        this.Top = this.Bottom;
        this.Bottom = x;
      };
      if (this.Left > this.Right) {
        x = this.Left;
        this.Left = this.Right;
        this.Right = x;
      };
    };
    this.Offset = function (dx, dy) {
      this.Left = this.Left + dx;
      this.Right = this.Right + dx;
      this.Bottom = this.Bottom + dy;
      this.Top = this.Top + dy;
    };
    this.Offset$1 = function (DP) {
      this.Left = this.Left + DP.x;
      this.Right = this.Right + DP.x;
      this.Bottom = this.Bottom + DP.y;
      this.Top = this.Top + DP.y;
    };
    this.SetLocation = function (P) {
      this.Offset(P.x - this.Left,P.y - this.Top);
    };
    this.ToString = function (aSize, aDecimals, aUseSize) {
      var Result = "";
      var S = "";
      if (aUseSize) {
        S = this.GetSize().ToString(aSize,aDecimals)}
       else S = this.GetBottomRight().ToString(aSize,aDecimals);
      Result = "[" + this.GetTopLeft().ToString(aSize,aDecimals) + " - " + S + "]";
      return Result;
    };
    this.ToString$1 = function (aUseSize) {
      var Result = "";
      Result = this.ToString(8,2,aUseSize);
      return Result;
    };
    this.Union$2 = function (r) {
      this.Left = Math.min(r.Left,this.Left);
      this.Top = Math.min(r.Top,this.Top);
      this.Right = Math.max(r.Right,this.Right);
      this.Bottom = Math.max(r.Bottom,this.Bottom);
    };
    var $r = $mod.$rtti.$Record("TRectF",{});
    $r.addField("Left",rtl.double);
    $r.addField("Top",rtl.double);
    $r.addField("Right",rtl.double);
    $r.addField("Bottom",rtl.double);
    $r.addMethod("Create",2,[["Origin",$mod.$rtti["TPointF"]]]);
    $r.addMethod("Create$1",2,[["Origin",$mod.$rtti["TPointF"]],["AWidth",rtl.double],["AHeight",rtl.double]]);
    $r.addMethod("Create$2",2,[["ALeft",rtl.double],["ATop",rtl.double],["ARight",rtl.double],["ABottom",rtl.double]]);
    $r.addMethod("Create$3",2,[["P1",$mod.$rtti["TPointF"]],["P2",$mod.$rtti["TPointF"]],["Normalize",rtl.boolean]]);
    $r.addMethod("Create$4",2,[["R",$r],["Normalize",rtl.boolean]]);
    $r.addMethod("Create$5",2,[["R",$mod.$rtti["TRect"]],["Normalize",rtl.boolean]]);
    $r.addMethod("Empty",5,null,$r,{flags: 1});
    $r.addMethod("Intersect",5,[["R1",$r],["R2",$r]],$r,{flags: 1});
    $r.addMethod("Union",5,[["Points",$mod.$rtti["TPointF"],10]],$r,{flags: 1});
    $r.addMethod("Union$1",5,[["R1",$r],["R2",$r]],$r,{flags: 1});
    $r.addMethod("Ceiling",1,null,$r);
    $r.addMethod("CenterAt",1,[["Dest",$r,2]],$r);
    $r.addMethod("CenterPoint",1,null,$mod.$rtti["TPointF"]);
    $r.addMethod("Contains",1,[["Pt",$mod.$rtti["TPointF"]]],rtl.boolean);
    $r.addMethod("Contains$1",1,[["R",$r]],rtl.boolean);
    $r.addMethod("EqualsTo",1,[["R",$r,2],["Epsilon",rtl.double,2]],rtl.boolean);
    $r.addMethod("Fit",1,[["Dest",$r,2]],rtl.double);
    $r.addMethod("FitInto",1,[["Dest",$r,2]],$r);
    $r.addMethod("FitInto$1",1,[["Dest",$r,2],["Ratio",rtl.double,4]],$r);
    $r.addMethod("IntersectsWith",1,[["R",$r]],rtl.boolean);
    $r.addMethod("IsEmpty",1,null,rtl.boolean);
    $r.addMethod("PlaceInto",1,[["Dest",$r,2],["AHorzAlign",$mod.$rtti["THorzRectAlign"],2],["AVertAlign",$mod.$rtti["TVertRectAlign"],2]],$r);
    $r.addMethod("Round",1,null,$mod.$rtti["TRect"]);
    $r.addMethod("SnapToPixel",1,[["AScale",rtl.double],["APlaceBetweenPixels",rtl.boolean]],$r);
    $r.addMethod("Truncate",1,null,$mod.$rtti["TRect"]);
    $r.addMethod("Inflate",0,[["DL",rtl.double],["DT",rtl.double],["DR",rtl.double],["DB",rtl.double]]);
    $r.addMethod("Inflate$1",0,[["DX",rtl.double],["DY",rtl.double]]);
    $r.addMethod("Intersect$1",0,[["R",$r]]);
    $r.addMethod("NormalizeRect",0,null);
    $r.addMethod("Offset",0,[["dx",rtl.double,2],["dy",rtl.double,2]]);
    $r.addMethod("Offset$1",0,[["DP",$mod.$rtti["TPointF"]]]);
    $r.addMethod("SetLocation",0,[["P",$mod.$rtti["TPointF"]]]);
    $r.addMethod("ToString",1,[["aSize",rtl.byte],["aDecimals",rtl.byte],["aUseSize",rtl.boolean]],rtl.string);
    $r.addMethod("ToString$1",1,[["aUseSize",rtl.boolean]],rtl.string);
    $r.addMethod("Union$2",0,[["r",$r,2]]);
    $r.addProperty("Width",3,rtl.double,"GetWidth","SetWidth");
    $r.addProperty("Height",3,rtl.double,"GetHeight","SetHeight");
    $r.addProperty("Size",3,$mod.$rtti["TSizeF"],"GetSize","SetSize");
    $r.addProperty("Location",3,$mod.$rtti["TPointF"],"GetLocation","SetLocation");
    $r.addProperty("TopLeft",3,$mod.$rtti["TPointF"],"GetTopLeft","SetTopLeft");
    $r.addProperty("BottomRight",3,$mod.$rtti["TPointF"],"GetBottomRight","SetBottomRight");
  },true);
  $mod.$rtti.$StaticArray("TPoint3D.TSingle3Array",{dims: [3], eltype: rtl.double});
  rtl.recNewT($mod,"TPoint3D",function () {
    this.x = 0.0;
    this.y = 0.0;
    this.z = 0.0;
    this.$eq = function (b) {
      return (this.x === b.x) && (this.y === b.y) && (this.z === b.z);
    };
    this.$assign = function (s) {
      this.x = s.x;
      this.y = s.y;
      this.z = s.z;
      return this;
    };
    this.GetSingle3Array = function () {
      var Result = rtl.arraySetLength(null,0.0,3);
      Result = [this.x,this.y,this.z];
      return Result;
    };
    this.SetSingle3Array = function (aValue) {
      this.x = aValue[0];
      this.y = aValue[1];
      this.z = aValue[2];
    };
    this.Create = function (ax, ay, az) {
      this.x = ax;
      this.y = ay;
      this.z = az;
      return this;
    };
    this.Offset = function (adeltax, adeltay, adeltaz) {
      this.x = this.x + adeltax;
      this.y = this.y + adeltay;
      this.z = this.z + adeltaz;
    };
    this.Offset$1 = function (adelta) {
      this.x = this.x + adelta.x;
      this.y = this.y + adelta.y;
      this.z = this.z + adelta.z;
    };
    this.ToString = function (aSize, aDecimals) {
      var Result = "";
      var Sx = "";
      var Sy = "";
      var Sz = "";
      Sx = $impl.SingleToStr(this.x,aSize,aDecimals);
      Sy = $impl.SingleToStr(this.y,aSize,aDecimals);
      Sz = $impl.SingleToStr(this.z,aSize,aDecimals);
      Result = "(" + Sx + "," + Sy + "," + Sz + ")";
      return Result;
    };
    this.ToString$1 = function () {
      var Result = "";
      Result = this.ToString(8,2);
      return Result;
    };
    var $r = $mod.$rtti.$Record("TPoint3D",{});
    $r.addMethod("Create",2,[["ax",rtl.double,2],["ay",rtl.double,2],["az",rtl.double,2]]);
    $r.addMethod("Offset",0,[["adeltax",rtl.double,2],["adeltay",rtl.double,2],["adeltaz",rtl.double,2]]);
    $r.addMethod("Offset$1",0,[["adelta",$r,2]]);
    $r.addMethod("ToString",1,[["aSize",rtl.byte],["aDecimals",rtl.byte]],rtl.string);
    $r.addMethod("ToString$1",1,null,rtl.string);
    $r.addProperty("Data",3,$mod.$rtti["TPoint3D.TSingle3Array"],"GetSingle3Array","SetSingle3Array");
    $r.addField("x",rtl.double);
    $r.addField("y",rtl.double);
    $r.addField("z",rtl.double);
  },true);
  this.EqualRect = function (r1, r2) {
    var Result = false;
    Result = (r1.Left === r2.Left) && (r1.Right === r2.Right) && (r1.Top === r2.Top) && (r1.Bottom === r2.Bottom);
    return Result;
  };
  this.EqualRect$1 = function (r1, r2) {
    var Result = false;
    Result = r1.EqualsTo(r2,0);
    return Result;
  };
  this.Rect = function (Left, Top, Right, Bottom) {
    var Result = $mod.TRect.$new();
    Result.Left = Left;
    Result.Top = Top;
    Result.Right = Right;
    Result.Bottom = Bottom;
    return Result;
  };
  this.RectF = function (Left, Top, Right, Bottom) {
    var Result = $mod.TRectF.$new();
    Result.Left = Left;
    Result.Top = Top;
    Result.Right = Right;
    Result.Bottom = Bottom;
    return Result;
  };
  this.Bounds = function (ALeft, ATop, AWidth, AHeight) {
    var Result = $mod.TRect.$new();
    Result.Left = ALeft;
    Result.Top = ATop;
    Result.Right = ALeft + AWidth;
    Result.Bottom = ATop + AHeight;
    return Result;
  };
  this.Point = function (x, y) {
    var Result = $mod.TPoint.$new();
    Result.X = x;
    Result.Y = y;
    return Result;
  };
  this.PointF = function (x, y) {
    var Result = $mod.TPointF.$new();
    Result.x = x;
    Result.y = y;
    return Result;
  };
  this.PtInRect = function (aRect, p) {
    var Result = false;
    Result = (p.Y >= aRect.Top) && (p.Y < aRect.Bottom) && (p.X >= aRect.Left) && (p.X < aRect.Right);
    return Result;
  };
  this.IntersectRect = function (aRect, R1, R2) {
    var Result = false;
    var lRect = $mod.TRect.$new();
    lRect.$assign(R1);
    if (R2.Left > R1.Left) lRect.Left = R2.Left;
    if (R2.Top > R1.Top) lRect.Top = R2.Top;
    if (R2.Right < R1.Right) lRect.Right = R2.Right;
    if (R2.Bottom < R1.Bottom) lRect.Bottom = R2.Bottom;
    if ($mod.IsRectEmpty(lRect)) {
      aRect.$assign($mod.Rect(0,0,0,0));
      Result = false;
    } else {
      Result = true;
      aRect.$assign(lRect);
    };
    return Result;
  };
  this.IntersectRect$1 = function (Rect1, Rect2) {
    var Result = false;
    Result = (Rect1.Left < Rect2.Right) && (Rect1.Right > Rect2.Left) && (Rect1.Top < Rect2.Bottom) && (Rect1.Bottom > Rect2.Top);
    return Result;
  };
  this.IntersectRect$2 = function (Rect1, Rect2) {
    var Result = false;
    Result = (Rect1.Left < Rect2.Right) && (Rect1.Right > Rect2.Left) && (Rect1.Top < Rect2.Bottom) && (Rect1.Bottom > Rect2.Top);
    return Result;
  };
  this.IntersectRect$3 = function (aRect, R1, R2) {
    var Result = false;
    var lRect = $mod.TRectF.$new();
    lRect.$assign(R1);
    if (R2.Left > R1.Left) lRect.Left = R2.Left;
    if (R2.Top > R1.Top) lRect.Top = R2.Top;
    if (R2.Right < R1.Right) lRect.Right = R2.Right;
    if (R2.Bottom < R1.Bottom) lRect.Bottom = R2.Bottom;
    if ($mod.IsRectEmpty$1(lRect)) {
      aRect.$assign($mod.RectF(0.0,0.0,0.0,0.0));
      Result = false;
    } else {
      Result = true;
      aRect.$assign(lRect);
    };
    return Result;
  };
  this.UnionRect = function (aRect, R1, R2) {
    var Result = false;
    var lRect = $mod.TRect.$new();
    lRect.$assign(R1);
    if (R2.Left < R1.Left) lRect.Left = R2.Left;
    if (R2.Top < R1.Top) lRect.Top = R2.Top;
    if (R2.Right > R1.Right) lRect.Right = R2.Right;
    if (R2.Bottom > R1.Bottom) lRect.Bottom = R2.Bottom;
    if ($mod.IsRectEmpty(lRect)) {
      aRect.$assign($mod.Rect(0,0,0,0));
      Result = false;
    } else {
      aRect.$assign(lRect);
      Result = true;
    };
    return Result;
  };
  this.UnionRect$1 = function (aRectF, R1, R2) {
    var Result = false;
    var lRect = $mod.TRectF.$new();
    lRect.$assign(R1);
    if (R2.Left < R1.Left) lRect.Left = R2.Left;
    if (R2.Top < R1.Top) lRect.Top = R2.Top;
    if (R2.Right > R1.Right) lRect.Right = R2.Right;
    if (R2.Bottom > R1.Bottom) lRect.Bottom = R2.Bottom;
    if ($mod.IsRectEmpty$1(lRect)) {
      aRectF.$assign($mod.RectF(0.0,0.0,0.0,0.0));
      Result = false;
    } else {
      aRectF.$assign(lRect);
      Result = true;
    };
    return Result;
  };
  this.UnionRect$2 = function (R1, R2) {
    var Result = $mod.TRect.$new();
    Result.$assign($mod.TRect.$new());
    $mod.UnionRect(Result,R1,R2);
    return Result;
  };
  this.UnionRect$3 = function (R1, R2) {
    var Result = $mod.TRectF.$new();
    Result.$assign($mod.TRectF.$new());
    $mod.UnionRect$1(Result,R1,R2);
    return Result;
  };
  this.IsRectEmpty = function (aRect) {
    var Result = false;
    Result = (aRect.Right <= aRect.Left) || (aRect.Bottom <= aRect.Top);
    return Result;
  };
  this.OffsetRect = function (aRect, DX, DY) {
    var Result = false;
    aRect.Left += DX;
    aRect.Top += DY;
    aRect.Right += DX;
    aRect.Bottom += DY;
    Result = true;
    return Result;
  };
  this.OffsetRect$1 = function (aRect, DX, DY) {
    var Result = false;
    aRect.Left = aRect.Left + DX;
    aRect.Top = aRect.Top + DY;
    aRect.Right = aRect.Right + DX;
    aRect.Bottom = aRect.Bottom + DY;
    Result = true;
    return Result;
  };
  this.CenterPoint = function (aRect) {
    var Result = $mod.TPoint.$new();
    function Avg(a, b) {
      var Result = 0;
      if (a < b) {
        Result = a + ((b - a) >>> 1)}
       else Result = b + ((a - b) >>> 1);
      return Result;
    };
    Result.X = Avg(aRect.Left,aRect.Right);
    Result.Y = Avg(aRect.Top,aRect.Bottom);
    return Result;
  };
  this.InflateRect = function (aRect, dx, dy) {
    var Result = false;
    aRect.Left -= dx;
    aRect.Top -= dy;
    aRect.Right += dx;
    aRect.Bottom += dy;
    Result = true;
    return Result;
  };
  this.Size = function (AWidth, AHeight) {
    var Result = $mod.TSize.$new();
    Result.cx = AWidth;
    Result.cy = AHeight;
    return Result;
  };
  this.Size$1 = function (aRect) {
    var Result = $mod.TSize.$new();
    Result.cx = aRect.Right - aRect.Left;
    Result.cy = aRect.Bottom - aRect.Top;
    return Result;
  };
  this.RectCenter = function (R, Bounds) {
    var Result = $mod.TRect.$new();
    var C = $mod.TPoint.$new();
    var CS = $mod.TPoint.$new();
    C.$assign(Bounds.CenterPoint());
    CS.$assign(R.CenterPoint());
    $mod.OffsetRect(R,C.X - CS.X,C.Y - CS.Y);
    Result.$assign(R);
    return Result;
  };
  this.RectCenter$1 = function (R, Bounds) {
    var Result = $mod.TRectF.$new();
    var C = $mod.TPointF.$new();
    var CS = $mod.TPointF.$new();
    C.$assign(Bounds.CenterPoint());
    CS.$assign(R.CenterPoint());
    $mod.OffsetRect$1(R,C.x - CS.x,C.y - CS.y);
    Result.$assign(R);
    return Result;
  };
  this.NormalizeRectF = function (Pts) {
    var Result = $mod.TRectF.$new();
    var Pt = $mod.TPointF.$new();
    Result.Left = 0xFFFF;
    Result.Top = 0xFFFF;
    Result.Right = -0xFFFF;
    Result.Bottom = -0xFFFF;
    for (var $in = Pts, $l = 0, $end = rtl.length($in) - 1; $l <= $end; $l++) {
      Pt = $in[$l];
      Result.Left = Math.min(Pt.x,Result.Left);
      Result.Top = Math.min(Pt.y,Result.Top);
      Result.Right = Math.max(Pt.x,Result.Right);
      Result.Bottom = Math.max(Pt.y,Result.Bottom);
    };
    return Result;
  };
  this.NormalizeRect = function (ARect) {
    var Result = $mod.TRectF.$new();
    Result.$assign($mod.NormalizeRectF([$mod.TPointF.$clone($mod.PointF(ARect.Left,ARect.Top)),$mod.TPointF.$clone($mod.PointF(ARect.Right,ARect.Top)),$mod.TPointF.$clone($mod.PointF(ARect.Right,ARect.Bottom)),$mod.TPointF.$clone($mod.PointF(ARect.Left,ARect.Bottom))]));
    return Result;
  };
  this.PtInRect$1 = function (Rect, p) {
    var Result = false;
    Result = (p.y >= Rect.Top) && (p.y < Rect.Bottom) && (p.x >= Rect.Left) && (p.x < Rect.Right);
    return Result;
  };
  this.RectHeight = function (Rect) {
    var Result = 0;
    Result = Rect.getHeight();
    return Result;
  };
  this.RectHeight$1 = function (Rect) {
    var Result = 0.0;
    Result = Rect.GetHeight();
    return Result;
  };
  this.RectWidth = function (Rect) {
    var Result = 0;
    Result = Rect.getWidth();
    return Result;
  };
  this.RectWidth$1 = function (Rect) {
    var Result = 0.0;
    Result = Rect.GetWidth();
    return Result;
  };
  this.IsRectEmpty$1 = function (Rect) {
    var Result = false;
    Result = Rect.IsEmpty();
    return Result;
  };
  this.MultiplyRect = function (R, DX, DY) {
    R.Left = DX * R.Left;
    R.Right = DX * R.Right;
    R.Top = DY * R.Top;
    R.Bottom = DY * R.Bottom;
  };
  this.InflateRect$1 = function (Rect, dx, dy) {
    var Result = false;
    Result = true;
    Rect.Left = Rect.Left - dx;
    Rect.Top = Rect.Top - dy;
    Rect.Right = Rect.Right + dx;
    Rect.Bottom = Rect.Bottom + dy;
    return Result;
  };
  this.Size$2 = function (ARect) {
    var Result = $mod.TSizeF.$new();
    Result.cx = ARect.Right - ARect.Left;
    Result.cy = ARect.Bottom - ARect.Top;
    return Result;
  };
  this.ScalePoint = function (P, dX, dY) {
    var Result = $mod.TPointF.$new();
    Result.x = P.x * dX;
    Result.y = P.y * dY;
    return Result;
  };
  this.ScalePoint$1 = function (P, dX, dY) {
    var Result = $mod.TPoint.$new();
    Result.X = Math.round(P.X * dX);
    Result.Y = Math.round(P.Y * dY);
    return Result;
  };
  this.MinPoint = function (P1, P2) {
    var Result = $mod.TPointF.$new();
    Result.$assign(P1);
    if ((P2.y < P1.y) || ((P2.y === P1.y) && (P2.x < P1.x))) Result.$assign(P2);
    return Result;
  };
  this.MinPoint$1 = function (P1, P2) {
    var Result = $mod.TPoint.$new();
    Result.$assign(P1);
    if ((P2.Y < P1.Y) || ((P2.Y === P1.Y) && (P2.X < P1.X))) Result.$assign(P2);
    return Result;
  };
  this.SplitRect = function (Rect, SplitType, Size) {
    var Result = $mod.TRect.$new();
    Result.$assign(Rect.SplitRect(SplitType,Size));
    return Result;
  };
  this.SplitRect$1 = function (Rect, SplitType, Percent) {
    var Result = $mod.TRect.$new();
    Result.$assign(Rect.SplitRect$1(SplitType,Percent));
    return Result;
  };
  this.CenteredRect = function (SourceRect, aCenteredRect) {
    var Result = $mod.TRect.$new();
    var W = 0;
    var H = 0;
    var Center = $mod.TPoint.$new();
    W = aCenteredRect.getWidth();
    H = aCenteredRect.getHeight();
    Center.$assign(SourceRect.CenterPoint());
    Result.$assign($mod.Rect(Center.X - Math.floor(W / 2),Center.Y - Math.floor(H / 2),Center.X + Math.floor((W + 1) / 2),Center.Y + Math.floor((H + 1) / 2)));
    return Result;
  };
  this.IntersectRectF = function (Rect, R1, R2) {
    var Result = false;
    Result = $mod.IntersectRect$3(Rect,R1,R2);
    return Result;
  };
  this.UnionRectF = function (Rect, R1, R2) {
    var Result = false;
    Result = $mod.UnionRect$1(Rect,R1,R2);
    return Result;
  };
},["Math"],function () {
  "use strict";
  var $mod = this;
  var $impl = $mod.$impl;
  $impl.SingleToStr = function (aValue, aSize, aDecimals) {
    var Result = "";
    var S = "";
    var Len = 0;
    var P = 0;
    S = rtl.floatToStr(aValue,aSize,aDecimals);
    Len = S.length;
    P = 1;
    while ((P <= Len) && (S.charAt(P - 1) === " ")) P += 1;
    if (P > 1) pas.System.Delete({get: function () {
        return S;
      }, set: function (v) {
        S = v;
      }},1,P - 1);
    Result = S;
    return Result;
  };
});
