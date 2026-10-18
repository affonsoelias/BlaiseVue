{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2018 by Mattias Gaertner

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit Types;
{$ENDIF}

{$mode objfpc}
{$modeswitch advancedrecords}

interface

Type
  Single = Double; // Avoid warning.

const
  Epsilon: Single = 1E-40;
  Epsilon2: Single = 1E-30;

  cPI: Single = 3.141592654;
  cPIdiv180: Single = 0.017453292;
  cPIdiv2: Single = 1.570796326;
  cPIdiv4: Single = 0.785398163;

type
  RTLString = string; // Compatibility with FPC

  THandle = NativeInt;
  TDirection = (FromBeginning, FromEnd);

  TBooleanDynArray = array of Boolean;
  TWordDynArray = array of Word;
  TIntegerDynArray = array of Integer;
  TNativeIntDynArray = array of NativeInt;
  TStringDynArray = array of String;
  TDoubleDynArray = array of Double;
  TSingleDynArray = TDoubleDynArray; //Avoid warning
  TJSValueDynArray = array of JSValue;
  TObjectDynArray = array of TObject;
  TByteDynArray = array of Byte;

  TSplitRectType = (
    srLeft,
    srRight,
    srTop,
    srBottom
  );
  TDuplicates = (dupIgnore, dupAccept, dupError);
  TProc = Reference to Procedure;
  TProcString = Reference to Procedure(Const aString : String);

  TListCallback = procedure(data, arg: JSValue) of object;
  TListStaticCallback = procedure(data, arg: JSValue);

  TSize =  record
    cx : Longint; cy : Longint;
  public
    constructor Create(ax,ay:Longint); overload;
    constructor Create(asz :TSize); overload;
    function Add(const asz: TSize): TSize;
    function Distance(const asz : TSize) : Double;
    function IsZero : Boolean;
    function Subtract(const asz : TSize): TSize;
    (*
    class operator = (const asz1, asz2 : TSize) : Boolean;
    class operator <> (const asz1, asz2 : TSize): Boolean;
    class operator + (const asz1, asz2 : TSize): TSize;
    class operator - (const asz1, asz2 : TSize): TSize;
    *)
    property Width : Longint read cx write cx;
    property Height: Longint read cy write cy;
  end;

  { TPoint }

  TPoint  =
  {$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
   packed
  {$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
       X : Longint; Y : Longint;
     public
       {$ifdef VER3}
       constructor Create(ax,ay:Longint); overload;
       constructor Create(apt :TPoint); overload;
       {$endif}
       class function Zero: TPoint; static; inline;
       function Add(const apt: TPoint): TPoint;
       function Distance(const apt: TPoint) : ValReal;
       function IsZero : Boolean;
       function Subtract(const apt : TPoint): TPoint;
       procedure SetLocation(const apt :TPoint);
       procedure SetLocation(ax,ay : Longint);
       procedure Offset(const apt :TPoint);
       procedure Offset(dx,dy : Longint);
       function Angle(const pt : TPoint):Single;
       class function PointInCircle(const apt, acenter: TPoint; const aradius: Integer): Boolean; static; inline;
       (*
       class operator = (const apt1, apt2 : TPoint) : Boolean; static;
       class operator <> (const apt1, apt2 : TPoint): Boolean; static;
       class operator + (const apt1, apt2 : TPoint): TPoint;static;
       class operator - (const apt1, apt2 : TPoint): TPoint;static;
       class operator := (const aspt : TSmallPoint) : TPoint;static;
       class operator Explicit (Const apt : TPoint) : TSmallPoint;static;
       *)
     end;
  PPoint = ^TPoint;

  { TRect }

  TRect =
{$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
{$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
  private
    function GetBottomRight: TPoint;
    function  getHeight: Longint; inline;
    function  getLocation: TPoint;
    function  getSize: TSize;
    function GetTopLeft: TPoint;
    function  getWidth : Longint; inline;
    procedure SetBottomRight(const aValue: TPoint);
    procedure setHeight(AValue: Longint);
    procedure setSize(AValue: TSize);
    procedure SetTopLeft(const aValue: TPoint);
    procedure setWidth (AValue: Longint);
  public
    constructor Create(Origin: TPoint); // empty rect at given origin
    constructor Create(Origin: TPoint; AWidth, AHeight: Longint);
    constructor Create(ALeft, ATop, ARight, ABottom: Longint);
    constructor Create(P1, P2: TPoint; Normalize: Boolean = False);
    constructor Create(R: TRect; Normalize: Boolean = False);
    (*
    class operator = (L, R: TRect): Boolean; static;
    class operator <> (L, R: TRect): Boolean; static;
    class operator + (L, R: TRect): TRect; static; // union
    class operator * (L, R: TRect): TRect; static; // intersection
    *)
    class function Empty: TRect; static;
    procedure NormalizeRect;
    function IsEmpty: Boolean;
    function Contains(Pt: TPoint): Boolean;
    function Contains(R: TRect): Boolean;
    function IntersectsWith(R: TRect): Boolean;
    class function Intersect(R1: TRect; R2: TRect): TRect; static;
    procedure Intersect(R: TRect);
    class function Union(R1, R2: TRect): TRect; static;
    procedure Union(R: TRect);
    class function Union(const Points: array of TPoint): TRect; static;
    procedure Offset(DX, DY: Longint);
    procedure Offset(DP: TPoint);
    procedure SetLocation(X, Y: Longint);
    procedure SetLocation(P: TPoint);
    procedure Inflate(DX, DY: Longint);
    procedure Inflate(DL, DT, DR, DB: Longint);
    function CenterPoint: TPoint;
    function SplitRect(SplitType: TSplitRectType; ASize: Longint): TRect;
    function SplitRect(SplitType: TSplitRectType; Percent: Double): TRect;
  public
    Left,Top,Right,Bottom : Longint;
    property Height: Longint read getHeight write setHeight;
    property Width : Longint read getWidth  write setWidth;
    property Size  : TSize   read getSize   write setSize;
    property Location  : TPoint read getLocation write setLocation;
    property TopLeft : TPoint read GetTopLeft Write SetTopLeft;
    property BottomRight : TPoint Read GetBottomRight Write SetBottomRight;
    // 2: (Vector:TArray4IntegerType);
  end;
  PRect = ^TRect;

  { TPointF }
  PPointF = ^TPointF;
  TPointF =
{$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
{$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
       x,y : Single;
       public
          function Add(const apt: TPoint): TPointF;
          function Add(const apt: TPointF): TPointF;
          function Distance(const apt : TPointF) : Single;
          function DotProduct(const apt : TPointF) : Single;
          function IsZero : Boolean;
          function Subtract(const apt : TPointF): TPointF;
          function Subtract(const apt : TPoint): TPointF;
          procedure SetLocation(const apt :TPointF);
          procedure SetLocation(const apt :TPoint);
          procedure SetLocation(ax,ay : Single);
          procedure Offset(const apt :TPointF);
          procedure Offset(const apt :TPoint);
          procedure Offset(dx,dy : Single);
          function EqualsTo(const apt: TPointF; const aEpsilon : Single): Boolean; overload;
          function EqualsTo(const apt: TPointF): Boolean; overload;

          function  Scale (afactor:Single)  : TPointF;
          function  Ceiling : TPoint;
          function  Truncate: TPoint;
          function  Floor   : TPoint;
          function  Round   : TPoint;
          function  Length  : Single;

          function Rotate(angle: single): TPointF;
          function Reflect(const normal: TPointF): TPointF;
          function MidPoint(const b: TPointF): TPointF;
          class function PointInCircle(const pt, center: TPointF; radius: single): Boolean; static;
          class function PointInCircle(const pt, center: TPointF; radius: integer): Boolean; static;
          class function Zero: TPointF; inline; static;
          function Angle(const b: TPointF): Single;
          function AngleCosine(const b: TPointF): single;
          function CrossProduct(const apt: TPointF): Single;
          function Normalize: TPointF;
          function ToString(aSize,aDecimals : Byte) : RTLString; overload;
          function ToString : RTLString; overload; inline;

          class function Create(const ax, ay: Single): TPointF; overload; static; inline;
          class function Create(const apt: TPoint): TPointF; overload; static; inline;
(*
          class operator equals(const apt1, apt2 : TPointF) : Boolean; static;
          class operator <> (const apt1, apt2 : TPointF): Boolean; static;
          class operator + (const apt1, apt2 : TPointF): TPointF;static;
          class operator - (const apt1, apt2 : TPointF): TPointF;static;
          class operator - (const apt1 : TPointF): TPointF;static;
          class operator * (const apt1, apt2: TPointF): TPointF;static;
          class operator * (const apt1: TPointF; afactor: single): TPointF;static;
          class operator * (afactor: single; const apt1: TPointF): TPointF;static;
          class operator / (const apt1: TPointF; afactor: single): TPointF;static;
          class operator := (const apt: TPoint): TPointF;static;
          class operator ** (const apt1, apt2: TPointF): Single;static; // scalar product
*)
  end;

  { TSizeF }
  PSizeF = ^TSizeF;
  TSizeF =
{$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
{$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
       cx,cy : Single;
       public
          function Add(const asz: TSize): TSizeF;
          function Add(const asz: TSizeF): TSizeF;
          function Distance(const asz : TSizeF) : Single;
          function IsZero : Boolean;
          function Subtract(const asz : TSizeF): TSizeF;
          function Subtract(const asz : TSize): TSizeF;
          function SwapDimensions:TSizeF;

          function  Scale (afactor:Single)  : TSizeF;
          function  Ceiling : TSize;
          function  Truncate: TSize;
          function  Floor   : TSize;
          function  Round   : TSize;
          function  Length  : Single;
          function ToString(aSize,aDecimals : Byte) : RTLString; overload;
          function ToString : RTLString; overload; inline;

          class function Create(const ax, ay: Single): TSizeF; overload; static; inline;
          class function Create(const asz: TSize): TSizeF; overload; static; inline;
(*
          class operator = (const asz1, asz2 : TSizeF) : Boolean;static;
          class operator <> (const asz1, asz2 : TSizeF): Boolean;static;
          class operator + (const asz1, asz2 : TSizeF): TSizeF;static;
          class operator - (const asz1, asz2 : TSizeF): TSizeF;static;
          class operator - (const asz1 : TSizeF): TSizeF;static;
          class operator * (const asz1: TSizeF; afactor: single): TSizeF;static;
          class operator * (afactor: single; const asz1: TSizeF): TSizeF;static;
          class operator := (const apt: TPointF): TSizeF;static;
          class operator := (const asz: TSize): TSizeF;static;
          class operator := (const asz: TSizeF): TPointF;static;
*)
          property Width: Single read cx write cx;
          property Height: Single read cy write cy;
       end;

  {$SCOPEDENUMS ON}
  TVertRectAlign = (Center, Top, Bottom);
  THorzRectAlign = (Center, Left, Right);
  {$SCOPEDENUMS OFF}

  { TRectF }
  PRectF = ^TRectF;
  TRectF =
{$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
{$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
  private
    function GetBottomRight: TPointF;
    function  GetLocation: TPointF;
    function  GetSize: TSizeF;
    function GetTopLeft: TPointF;
    procedure SetBottomRight(const aValue: TPointF);
    procedure SetSize(AValue: TSizeF);
    function GetHeight: Single; inline;
    function GetWidth: Single;  inline;
    procedure SetHeight(AValue: Single);
    procedure SetTopLeft(const aValue: TPointF);
    procedure SetWidth (AValue: Single);
  public
    Left, Top, Right, Bottom: Single;
    constructor Create(Origin: TPointF); // empty rect at given origin
    constructor Create(Origin: TPointF; AWidth, AHeight: Single);
    constructor Create(ALeft, ATop, ARight, ABottom: Single);
    constructor Create(P1, P2: TPointF; Normalize: Boolean = False);
    constructor Create(R: TRectF; Normalize: Boolean = False);
    constructor Create(R: TRect; Normalize: Boolean = False);

(*
    class operator = (L, R: TRectF): Boolean;static;
    class operator <> (L, R: TRectF): Boolean;static;
    class operator + (L, R: TRectF): TRectF; static;// union
    class operator * (L, R: TRectF): TRectF; static;// intersection
    class operator := (const arc: TRect): TRectF; static;
*)
    class function Empty: TRectF; static;

    class function Intersect(R1: TRectF; R2: TRectF): TRectF; static;
    class function Union(const Points: array of TPointF): TRectF; static;
    class function Union(R1, R2: TRectF): TRectF; static;
    Function Ceiling : TRectF;
    function CenterAt(const Dest: TRectF): TRectF;
    function CenterPoint: TPointF;
    function Contains(Pt: TPointF): Boolean;
    function Contains(R: TRectF): Boolean;
    function EqualsTo(const R: TRectF; const Epsilon: Single = 0): Boolean;
    function Fit(const Dest: TRectF): Single; deprecated 'Use FitInto';
    function FitInto(const Dest: TRectF): TRectF; overload;
    function FitInto(const Dest: TRectF; out Ratio: Single): TRectF; overload;
    function IntersectsWith(R: TRectF): Boolean;
    function IsEmpty: Boolean;
    function PlaceInto(const Dest: TRectF; const AHorzAlign: THorzRectAlign = THorzRectAlign.Center;  const AVertAlign: TVertRectAlign = TVertRectAlign.Center): TRectF;
    function Round: TRect;
    function SnapToPixel(AScale: Single; APlaceBetweenPixels: Boolean = True): TRectF;
    function Truncate: TRect;
    procedure Inflate(DL, DT, DR, DB: Single);
    procedure Inflate(DX, DY: Single);
    procedure Intersect(R: TRectF);
    procedure NormalizeRect;
    procedure Offset (const dx,dy : Single); inline;
    procedure Offset (DP: TPointF); inline;
    procedure SetLocation(P: TPointF);
//    procedure SetLocation(X, Y: Single);
    function ToString(aSize,aDecimals : Byte; aUseSize : Boolean = False) : RTLString; overload;
    function ToString(aUseSize : Boolean = False) : RTLString; overload; inline;
    procedure Union  (const r: TRectF); inline;
    property  Width  : Single read GetWidth write SetWidth;
    property  Height : Single read GetHeight write SetHeight;
    property  Size   : TSizeF read getSize   write SetSize;
    property  Location: TPointF read getLocation write setLocation;
    property TopLeft : TPointF Read GetTopLeft Write SetTopLeft;
    property BottomRight : TPointF Read GetBottomRight Write SetBottomRight;
    end;



  { TPoint3D }

  TPoint3D = record
  Public
    Type TSingle3Array = array[0..2] of single;

    private
      function GetSingle3Array: TSingle3Array;
      procedure SetSingle3Array(const aValue: TSingle3Array);
    public
     constructor Create(const ax,ay,az:single);
     procedure   Offset(const adeltax,adeltay,adeltaz:single); inline;
     procedure   Offset(const adelta:TPoint3D); inline;
     function ToString(aSize,aDecimals : Byte) : RTLString; overload;
     function ToString : RTLString; overload; inline;
   public
     Property Data : TSingle3Array Read GetSingle3Array Write SetSingle3Array;
     x,y,z : single;
    end;

  
function EqualRect(const r1,r2 : TRect) : Boolean;
function EqualRect(const r1,r2 : TRectF) : Boolean;
function Rect(Left, Top, Right, Bottom : Integer) : TRect;
function RectF(Left,Top,Right,Bottom : Single) : TRectF; inline;
function Bounds(ALeft, ATop, AWidth, AHeight : Integer) : TRect;
function Point(x,y : Integer): TPoint; {$IFDEF Has_Inline}inline;{$ENDIF}
function PointF(x,y : single) : TPointF; {$IFDEF Has_Inline}inline;{$ENDIF}
function PtInRect(const aRect: TRect; const p: TPoint) : Boolean;
function IntersectRect(out aRect: TRect; const R1,R2: TRect) : Boolean;
function IntersectRect(const Rect1, Rect2: TRect): Boolean;
function IntersectRect(const Rect1, Rect2: TRectF): Boolean;
//function IntersectRect(var Rect : TRect; const R1,R2 : TRect) : Boolean;
function IntersectRect(var aRect : TRectF; const R1,R2 : TRectF) : Boolean;

function UnionRect(out aRect: TRect; const R1,R2: TRect) : Boolean;
function UnionRect(out aRectF: TRectF; const R1,R2: TRectF) : Boolean;
function UnionRect(const R1,R2 : TRect) : TRect;
function UnionRect(const R1,R2 : TRectF) : TRectF;

function IsRectEmpty(const aRect: TRect) : Boolean;
function OffsetRect(var aRect: TRect; DX, DY: Integer) : Boolean;
function OffsetRect(var aRect: TRectF; DX, DY: single) : Boolean;
function CenterPoint(const aRect: TRect): TPoint;
function InflateRect(var aRect: TRect; dx, dy: Integer): Boolean;
function Size(AWidth, AHeight: Integer): TSize;
function Size(const aRect: TRect): TSize;
function RectCenter(var R: TRect; const Bounds: TRect): TRect;
function RectCenter(var R: TRectF; const Bounds: TRectF): TRectF;

function NormalizeRectF(const Pts: array of TPointF): TRectF; overload;
function NormalizeRect(const ARect: TRectF): TRectF; overload;

function PtInRect(const Rect : TRectF; const p : TPointF) : Boolean;

function RectHeight(const Rect: TRect): Integer; inline;
function RectHeight(const Rect: TRectF): Single; inline;
function RectWidth(const Rect: TRect): Integer; inline;
function RectWidth(const Rect: TRectF): Single; inline;
function IsRectEmpty(const Rect : TRectF) : Boolean;
procedure MultiplyRect(var R: TRectF; const DX, DY: Single);
function InflateRect(var Rect: TRectF; dx: single; dy: Single): Boolean;
function Size(const ARect: TRectF): TSizeF; inline;
function ScalePoint(const P: TPointF; dX, dY: Single): TPointF; overload;
function ScalePoint(const P: TPoint; dX, dY: Single): TPoint; overload;
function MinPoint(const P1, P2: TPointF): TPointF; overload;
function MinPoint(const P1, P2: TPoint): TPoint; overload;
function SplitRect(const Rect: TRect; SplitType: TSplitRectType; Size: Integer): TRect; overload;
function SplitRect(const Rect: TRect; SplitType: TSplitRectType; Percent: Double): TRect; overload;
function CenteredRect(const SourceRect: TRect; const aCenteredRect: TRect): TRect;
function IntersectRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;
function UnionRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;


implementation

{$IFDEF FPC_DOTTEDUNITS}
uses System.Math;
{$ELSE FPC_DOTTEDUNITS}
uses math;
{$ENDIF FPC_DOTTEDUNITS}

function RectCenter(var R: TRect; const Bounds: TRect): TRect;

var
  C : TPoint;
  CS : TPoint;

begin
  C:=Bounds.CenterPoint;
  CS:=R.CenterPoint;
  OffsetRect(R,C.X-CS.X,C.Y-CS.Y);
  Result:=R;
end;

function RectCenter(var R: TRectF; const Bounds: TRectF): TRectF;

Var
  C,CS : TPointF;

begin
  C:=Bounds.CenterPoint;
  CS:=R.CenterPoint;
  OffsetRect(R,C.X-CS.X,C.Y-CS.Y);
  Result:=R;
end;

function NormalizeRectF(const Pts: array of TPointF): TRectF;
var
  Pt: TPointF;

begin
  Result.Left:=$FFFF;
  Result.Top:=$FFFF;
  Result.Right:=-$FFFF;
  Result.Bottom:=-$FFFF;
  for Pt in Pts do
    begin
    Result.Left:=Min(Pt.X,Result.left);
    Result.Top:=Min(Pt.Y,Result.Top);
    Result.Right:=Max(Pt.X,Result.Right);
    Result.Bottom:=Max(Pt.Y,Result.Bottom);
    end;
end;

function NormalizeRect(const ARect: TRectF): TRectF;

begin
  With aRect do
   Result:=NormalizeRectF([PointF(Left,Top),
                           PointF(Right,Top),
                           PointF(Right,Bottom),
                           PointF(Left,Bottom)]);
end;

function PtInRect(const Rect: TRectF; const p: TPointF): Boolean;

begin
  Result:=(p.y>=Rect.Top) and
          (p.y<Rect.Bottom) and
          (p.x>=Rect.Left) and
          (p.x<Rect.Right);
end;

function RectHeight(const Rect: TRect): Integer;
begin
  Result:=Rect.Height;
end;

function RectHeight(const Rect: TRectF): Single;
begin
  Result:=Rect.Height;
end;

function RectWidth(const Rect: TRect): Integer;
begin
  Result:=Rect.Width;

end;

function RectWidth(const Rect: TRectF): Single;
begin
  Result:=Rect.Width;
end;

function IsRectEmpty(const Rect: TRectF): Boolean;
begin
  Result:=Rect.IsEmpty;
end;

procedure MultiplyRect(var R: TRectF; const DX, DY: Single);
begin
  R.Left:=DX*R.Left;
  R.Right:=DX*R.Right;
  R.Top:=DY*R.Top;
  R.Bottom:=DY*R.Bottom;
end;

function InflateRect(var Rect: TRectF; dx: single; dy: Single): Boolean;
begin
  Result:=True;
  with Rect do
    begin
    Left:=Left-dx;
    Top:=Top-dy;
    Right:=Right+dx;
    Bottom:=Bottom+dy;
    end;
end;

function Size(const ARect: TRectF): TSizeF;
begin
  Result.cx := ARect.Right - ARect.Left;
  Result.cy := ARect.Bottom - ARect.Top;
end;

function ScalePoint(const P: TPointF; dX, dY: Single): TPointF;
begin
  Result.X:=P.X*dX;
  Result.Y:=P.Y*dY;
end;

function ScalePoint(const P: TPoint; dX, dY: Single): TPoint;
begin
  Result.X:=Round(P.X*dX);
  Result.Y:=Round(P.Y*dY);
end;

function MinPoint(const P1, P2: TPointF): TPointF;
begin
  Result:=P1;
  if (P2.Y<P1.Y)
     or ((P2.Y=P1.Y) and (P2.X<P1.X)) then
    Result:=P2;
end;

function MinPoint(const P1, P2: TPoint): TPoint;
begin
  Result:=P1;
  if (P2.Y<P1.Y)
     or ((P2.Y=P1.Y) and (P2.X<P1.X)) then
    Result:=P2;
end;

function SplitRect(const Rect: TRect; SplitType: TSplitRectType; Size: Integer): TRect;
begin
  Result:=Rect.SplitRect(SplitType,Size);
end;

function SplitRect(const Rect: TRect; SplitType: TSplitRectType; Percent: Double): TRect;
begin
  Result:=Rect.SplitRect(SplitType,Percent);
end;

function CenteredRect(const SourceRect: TRect; const aCenteredRect: TRect): TRect;
var
  W,H: Integer;
  Center : TPoint;
begin
  W:=aCenteredRect.Width;
  H:=aCenteredRect.Height;
  Center:=SourceRect.CenterPoint;
  With Center do
    Result:= Rect(X-(W div 2),Y-(H div 2),X+((W+1) div 2),Y+((H+1) div 2));
end;

function IntersectRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;
begin
  Result:=IntersectRect(Rect,R1,R2);
end;

function UnionRectF(out Rect: TRectF; const R1, R2: TRectF): Boolean;
begin
  Result:=UnionRect(Rect,R1,R2);
end;

function EqualRect(const r1, r2: TRect): Boolean;
begin
  Result:=(r1.left=r2.left) and (r1.right=r2.right) and (r1.top=r2.top) and (r1.bottom=r2.bottom);
end;

function EqualRect(const r1, r2: TRectF): Boolean;
begin
  EqualRect:=r1.EqualsTo(r2);
end;

function Rect(Left, Top, Right, Bottom: Integer): TRect;
begin
  Result.Left:=Left;
  Result.Top:=Top;
  Result.Right:=Right;
  Result.Bottom:=Bottom;
end;

function RectF(Left,Top,Right,Bottom : Single) : TRectF; inline;

begin
  Result.Left:=Left;
  Result.Top:=Top;
  Result.Right:=Right;
  Result.Bottom:=Bottom;
end;


function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;
begin
  Result.Left:=ALeft;
  Result.Top:=ATop;
  Result.Right:=ALeft+AWidth;
  Result.Bottom:=ATop+AHeight;
end;

function Point(x, y: Integer): TPoint;
begin
  Result.x:=x;
  Result.y:=y;
end;

function PointF(x, y: single): TPointF;
begin
  Result.X:=X;
  Result.Y:=Y;
end;

function PtInRect(const aRect: TRect; const p: TPoint): Boolean;
begin
  Result:=(p.y>=aRect.Top) and
          (p.y<aRect.Bottom) and
          (p.x>=aRect.Left) and
          (p.x<aRect.Right);
end;

function IntersectRect(out aRect: TRect; const R1, R2: TRect): Boolean;
var
  lRect: TRect;
begin
  lRect := R1;
  if R2.Left > R1.Left then
    lRect.Left := R2.Left;
  if R2.Top > R1.Top then
    lRect.Top := R2.Top;
  if R2.Right < R1.Right then
    lRect.Right := R2.Right;
  if R2.Bottom < R1.Bottom then
    lRect.Bottom := R2.Bottom;

  // The var parameter is only assigned in the end to avoid problems
  // when passing the same rectangle in the var and const parameters.
  if IsRectEmpty(lRect) then
  begin
    aRect:=Rect(0,0,0,0);
    Result:=false;
  end
  else
  begin
    Result:=true;
    aRect := lRect;
  end;
end;

function IntersectRect(const Rect1, Rect2: TRect): Boolean;

begin
  Result:=(Rect1.Left<Rect2.Right)
         and (Rect1.Right>Rect2.Left)
         and (Rect1.Top<Rect2.Bottom)
         and (Rect1.Bottom>Rect2.Top);
end;

function IntersectRect(const Rect1, Rect2: TRectF): Boolean;
begin
  Result:=(Rect1.Left<Rect2.Right)
         and (Rect1.Right>Rect2.Left)
         and (Rect1.Top<Rect2.Bottom)
         and (Rect1.Bottom>Rect2.Top);
end;

function IntersectRect(var aRect: TRectF; const R1, R2: TRectF): Boolean;
var
  lRect: TRectF;
begin
  lRect := R1;
  if R2.Left > R1.Left then
    lRect.Left := R2.Left;
  if R2.Top > R1.Top then
    lRect.Top := R2.Top;
  if R2.Right < R1.Right then
    lRect.Right := R2.Right;
  if R2.Bottom < R1.Bottom then
    lRect.Bottom := R2.Bottom;

  // The var parameter is only assigned in the end to avoid problems
  // when passing the same rectangle in the var and const parameters.
  if IsRectEmpty(lRect) then
  begin
    aRect:=RectF(0.0,0.0,0.0,0.0);
    Result:=false;
  end
  else
  begin
    Result:=true;
    aRect := lRect;
  end;
end;

function UnionRect(out aRect: TRect; const R1, R2: TRect): Boolean;
var
  lRect: TRect;
begin
  lRect:=R1;
  if R2.Left<R1.Left then
    lRect.Left:=R2.Left;
  if R2.Top<R1.Top then
    lRect.Top:=R2.Top;
  if R2.Right>R1.Right then
    lRect.Right:=R2.Right;
  if R2.Bottom>R1.Bottom then
    lRect.Bottom:=R2.Bottom;

  if IsRectEmpty(lRect) then
  begin
    aRect:=Rect(0,0,0,0);
    Result:=false;
  end
  else
  begin
    aRect:=lRect;
    Result:=true;
  end;
end;

function UnionRect(out aRectF: TRectF; const R1, R2: TRectF): Boolean;
var
  lRect: TRectF;
begin
  lRect:=R1;
  if R2.Left<R1.Left then
    lRect.Left:=R2.Left;
  if R2.Top<R1.Top then
    lRect.Top:=R2.Top;
  if R2.Right>R1.Right then
    lRect.Right:=R2.Right;
  if R2.Bottom>R1.Bottom then
    lRect.Bottom:=R2.Bottom;

  if IsRectEmpty(lRect) then
  begin
    aRectF:=RectF(0.0,0.0,0.0,0.0);
    Result:=false;
  end
  else
  begin
    aRectF:=lRect;
    Result:=true;
  end;
end;

function UnionRect(const R1, R2: TRect): TRect;
begin
  Result:=Default(TRect);
  UnionRect(Result,R1,R2);
end;

function UnionRect(const R1, R2: TRectF): TRectF;
begin
  Result:=Default(TRectF);
  UnionRect(Result,R1,R2);
end;

function IsRectEmpty(const aRect: TRect): Boolean;
begin
  Result:=(aRect.Right<=aRect.Left) or (aRect.Bottom<=aRect.Top);
end;

function OffsetRect(var aRect: TRectF; DX, DY: single) : Boolean;

begin
  with aRect do
    begin
    Left:=Left+dx;
    Top:=Top+dy;
    Right:=Right+dx;
    Bottom:=Bottom+dy;
    end;
  Result:=true;
end;

function OffsetRect(var aRect: TRect; DX, DY: Integer): Boolean;
begin
  with aRect do
    begin
    inc(Left,dx);
    inc(Top,dy);
    inc(Right,dx);
    inc(Bottom,dy);
    end;
  Result:=true;
end;

function CenterPoint(const aRect: TRect): TPoint;

  function Avg(a, b: Longint): Longint;
  begin
    if a < b then
      Result := a + ((b - a) shr 1)
    else
      Result := b + ((a - b) shr 1);
  end;

begin
  with aRect do
    begin
      Result.X := Avg(Left, Right);
      Result.Y := Avg(Top, Bottom);
    end;
end;

function InflateRect(var aRect: TRect; dx, dy: Integer): Boolean;
begin
  with aRect do
  begin
    dec(Left, dx);
    dec(Top, dy);
    inc(Right, dx);
    inc(Bottom, dy);
  end;
  Result := True;
end;

function Size(AWidth, AHeight: Integer): TSize;
begin
  Result.cx := AWidth;
  Result.cy := AHeight;
end;

function Size(const aRect: TRect): TSize;
begin
  Result.cx := aRect.Right - aRect.Left;
  Result.cy := aRect.Bottom - aRect.Top;
end;

{ TPointF}

Function SingleToStr(aValue : Single; aSize,aDecimals : Byte) : String; inline;

var
  S : String;
  Len,P : Byte;

begin
  Str(aValue:aSize:aDecimals,S);
  Len:=Length(S);
  P:=1;
  While (P<=Len) and (S[P]=' ') do
    Inc(P);
  if P>1 then
    Delete(S,1,P-1);
  Result:=S;
end;

{ TRect }

{ TRect }

(*
class operator TRect. * (L, R: TRect): TRect;
begin
  Result := TRect.Intersect(L, R);
end;

class operator TRect. + (L, R: TRect): TRect;
begin
  Result := TRect.Union(L, R);
end;

class operator TRect. <> (L, R: TRect): Boolean;
begin
  Result := not(L=R);
end;

class operator TRect. = (L, R: TRect): Boolean;
begin
  Result :=
    (L.Left = R.Left) and (L.Right = R.Right) and
    (L.Top = R.Top) and (L.Bottom = R.Bottom);
end;
*)
constructor TRect.Create(ALeft, ATop, ARight, ABottom: Longint);
begin
  Left := ALeft;
  Top := ATop;
  Right := ARight;
  Bottom := ABottom;
end;

constructor TRect.Create(P1, P2: TPoint; Normalize: Boolean);
begin
  TopLeft := P1;
  BottomRight := P2;
  if Normalize then
    NormalizeRect;
end;

constructor TRect.Create(Origin: TPoint);
begin
  TopLeft := Origin;
  BottomRight := Origin;
end;

constructor TRect.Create(Origin: TPoint; AWidth, AHeight: Longint);
begin
  TopLeft := Origin;
  Width := AWidth;
  Height := AHeight;
end;

constructor TRect.Create(R: TRect; Normalize: Boolean);
begin
  Self := R;
  if Normalize then
    NormalizeRect;
end;

function TRect.CenterPoint: TPoint;
begin
  Result.X := (Right-Left) div 2 + Left;
  Result.Y := (Bottom-Top) div 2 + Top;
end;

function TRect.Contains(Pt: TPoint): Boolean;
begin
  Result := (Left <= Pt.X) and (Pt.X < Right) and (Top <= Pt.Y) and (Pt.Y < Bottom);
end;

function TRect.Contains(R: TRect): Boolean;
begin
  Result := (Left <= R.Left) and (R.Right <= Right) and (Top <= R.Top) and (R.Bottom <= Bottom);
end;

class function TRect.Empty: TRect;
begin
  Result := TRect.Create(0,0,0,0);
end;

function TRect.GetBottomRight: TPoint;
begin
  Result:=Point(Right,Bottom);
end;

function TRect.getHeight: Longint;
begin
  result:=bottom-top;
end;

function TRect.getLocation: TPoint;
begin
  result.x:=Left; result.y:=top;
end;

function TRect.getSize: TSize;
begin
  result.cx:=width; result.cy:=height;
end;

function TRect.GetTopLeft: TPoint;
begin
  Result:=Point(Left,Top);
end;

function TRect.getWidth: Longint;
begin
  result:=right-left;
end;

procedure TRect.SetBottomRight(const aValue: TPoint);
begin
  Bottom:=aValue.Y;
  Right:=aValue.X;
end;

procedure TRect.Inflate(DX, DY: Longint);
begin
  InflateRect(Self, DX, DY);
end;

procedure TRect.Intersect(R: TRect);
begin
  Self := Intersect(Self, R);
end;

class function TRect.Intersect(R1: TRect; R2: TRect): TRect;
begin
  IntersectRect(Result, R1, R2);
end;

function TRect.IntersectsWith(R: TRect): Boolean;
begin
  Result := (Left < R.Right) and (R.Left < Right) and (Top < R.Bottom) and (R.Top < Bottom);
end;

function TRect.IsEmpty: Boolean;
begin
  Result := (Right <= Left) or (Bottom <= Top);
end;

procedure TRect.NormalizeRect;
var
  x: LongInt;
begin
  if Top>Bottom then
  begin
    x := Top;
    Top := Bottom;
    Bottom := x;
  end;
  if Left>Right then
  begin
    x := Left;
    Left := Right;
    Right := x;
  end
end;

procedure TRect.Inflate(DL, DT, DR, DB: Longint);
begin
  Dec(Left, DL);
  Dec(Top, DT);
  Inc(Right, DR);
  Inc(Bottom, DB);
end;

procedure TRect.Offset(DX, DY: Longint);
begin
  OffsetRect(Self, DX, DY);
end;

procedure TRect.Offset(DP: TPoint);
begin
  OffsetRect(Self, DP.X, DP.Y);
end;

procedure TRect.setHeight(AValue: Longint);
begin
  bottom:=top+avalue;
end;

procedure TRect.SetLocation(X, Y: Longint);
begin
  Offset(X-Left, Y-Top);
end;

procedure TRect.SetLocation(P: TPoint);
begin
  SetLocation(P.X, P.Y);
end;

procedure TRect.setSize(AValue: TSize);
begin
  bottom:=top+avalue.cy;
  right:=left+avalue.cx;
end;

procedure TRect.SetTopLeft(const aValue: TPoint);
begin
  Top:=aValue.y;
  Left:=aValue.x;
end;

procedure TRect.setWidth(AValue: Longint);
begin
  right:=left+avalue;
end;

function TRect.SplitRect(SplitType: TSplitRectType; Percent: Double): TRect;
begin
  Result := Self;
  case SplitType of
    srLeft: Result.Right := Left + Trunc(Percent*Width);
    srRight: Result.Left := Right - Trunc(Percent*Width);
    srTop: Result.Bottom := Top + Trunc(Percent*Height);
    srBottom: Result.Top := Bottom - Trunc(Percent*Height);
  end;
end;

function TRect.SplitRect(SplitType: TSplitRectType; ASize: Longint): TRect;
begin
  Result := Self;
  case SplitType of
    srLeft: Result.Right := Left + ASize;
    srRight: Result.Left := Right - ASize;
    srTop: Result.Bottom := Top + ASize;
    srBottom: Result.Top := Bottom - ASize;
  end;
end;

class function TRect.Union(const Points: array of TPoint): TRect;
var
  i: Integer;
begin
  if Length(Points) > 0 then
  begin
    Result.TopLeft := Points[Low(Points)];
    Result.BottomRight := Points[Low(Points)];

    for i := Low(Points)+1 to High(Points) do
    begin
      if Points[i].X < Result.Left then Result.Left := Points[i].X;
      if Points[i].X > Result.Right then Result.Right := Points[i].X;
      if Points[i].Y < Result.Top then Result.Top := Points[i].Y;
      if Points[i].Y > Result.Bottom then Result.Bottom := Points[i].Y;
    end;
  end else
    Result := Empty;
end;

procedure TRect.Union(R: TRect);
begin
  Self := Union(Self, R);
end;

class function TRect.Union(R1, R2: TRect): TRect;
begin
  UnionRect(Result, R1, R2);
end;

{ TPointF}

function TPointF.ToString : RTLString;

begin
  Result:=ToString(8,2);
end;

function TPointF.ToString(aSize,aDecimals : Byte) : RTLString;

var
  Sx,Sy : string;

begin
  Sx:=SingleToStr(X,aSize,aDecimals);
  Sy:=SingleToStr(Y,aSize,aDecimals);
  Result:='('+Sx+','+Sy+')';
end;

function TPointF.Add(const apt: TPoint): TPointF;
begin
  result.x:=x+apt.x;
  result.y:=y+apt.y;
end;

function TPointF.Add(const apt: TPointF): TPointF;
begin
  result.x:=x+apt.x;
  result.y:=y+apt.y;
end;

function TPointF.Subtract(const apt : TPointF): TPointF;
begin
  result.x:=x-apt.x;
  result.y:=y-apt.y;
end;

function TPointF.Subtract(const apt: TPoint): TPointF;
begin
  result.x:=x-apt.x;
  result.y:=y-apt.y;
end;

function TPointF.Distance(const apt : TPointF) : Single;
begin
  result:=sqrt(sqr(apt.x-x)+sqr(apt.y-y));
end;

function TPointF.DotProduct(const apt: TPointF): Single;
begin
  result:=x*apt.x+y*apt.y;
end;

function TPointF.IsZero : Boolean;
begin
  result:=SameValue(x,0.0) and SameValue(y,0.0);
end;

procedure TPointF.Offset(const apt :TPointF);
begin
  x:=x+apt.x;
  y:=y+apt.y;
end;

procedure TPointF.Offset(const apt: TPoint);
begin
  x:=x+apt.x;
  y:=y+apt.y;
end;

procedure TPointF.Offset(dx,dy : Single);
begin
  x:=x+dx;
  y:=y+dy;
end;

function TPointF.EqualsTo(const apt: TPointF): Boolean;

begin
  Result:=EqualsTo(apt,0);
end;

function TPointF.EqualsTo(const apt: TPointF; const aEpsilon: Single): Boolean;

  function Eq(a,b : single) : boolean; inline;

  begin
    result:=abs(a-b)<=aEpsilon;
  end;

begin
  Result:=Eq(X,apt.X) and Eq(Y,apt.Y);
end;

function TPointF.Scale(afactor: Single): TPointF;
begin
  result.x:=afactor*x;
  result.y:=afactor*y;
end;

function TPointF.Ceiling: TPoint;
begin
  result.x:=ceil(x);
  result.y:=ceil(y);
end;

function TPointF.Truncate: TPoint;
begin
  result.x:=trunc(x);
  result.y:=trunc(y);
end;

function TPointF.Floor: TPoint;
begin
  result.x:={$IFDEF FPC_DOTTEDUNITS}System.{$ENDIF}Math.floor(x);
  result.y:={$IFDEF FPC_DOTTEDUNITS}System.{$ENDIF}Math.floor(y);
end;

function TPointF.Round: TPoint;
begin
  result.x:=System.round(x);
  result.y:=System.round(y);
end;

function TPointF.Length: Single;
begin
  result:=sqrt(sqr(x)+sqr(y));
end;

function TPointF.Rotate(angle: single): TPointF;
var
  sina, cosa: single;
begin
  sincos(angle, sina, cosa);
  result.x := x * cosa - y * sina;
  result.y := x * sina + y * cosa;
end;

function TPointF.Reflect(const normal: TPointF): TPointF;
var
  lCross : single;
  lTmp : TPointF;

begin
  //result := self + (-2 * normal ** self) * normal;
  lCross:=x*normal.x + y*normal.y;
  lCross:=lCross * (-2);
  lTmp.x:=normal.x*lCross;
  lTmp.y:=normal.y*lCross;
  Result.X:=X+lTmp.x;
  Result.Y:=Y+lTmp.Y;
end;

function TPointF.MidPoint(const b: TPointF): TPointF;
begin
  result.x := 0.5 * (x + b.x);
  result.y := 0.5 * (y + b.y);
end;

class function TPointF.Zero: TPointF;

begin
  Result.X:=0;
  Result.Y:=0;
end;

class function TPointF.PointInCircle(const pt, center: TPointF; radius: single): Boolean;
begin
  result := sqr(center.x - pt.x) + sqr(center.y - pt.y) < sqr(radius);
end;

class function TPointF.PointInCircle(const pt, center: TPointF; radius: integer): Boolean;
begin
  result := sqr(center.x - pt.x) + sqr(center.y - pt.y) < sqr(single(radius));
end;

function TPointF.Angle(const b: TPointF): Single;
begin
  result := ArcTan2(y - b.y, x - b.x);
end;

function TPointF.AngleCosine(const b: TPointF): single;
var
  lCross : single;
begin
  lCross:=x*b.x + y*b.y;
  result := EnsureRange(lCross / sqrt((sqr(x) + sqr(y)) * (sqr(b.x) + sqr(b.y))), -1, 1);
end;

(*
class operator TPointF.= (const apt1, apt2 : TPointF) : Boolean; static;
begin
  result:=SameValue(apt1.x,apt2.x) and SameValue(apt1.y,apt2.y);
end;

class operator TPointF.<> (const apt1, apt2 : TPointF): Boolean;
begin
  result:=NOT (SameValue(apt1.x,apt2.x) and Samevalue(apt1.y,apt2.y));
end;

class operator TPointF. * (const apt1, apt2: TPointF): TPointF;
begin
  result.x:=apt1.x*apt2.x;
  result.y:=apt1.y*apt2.y;
end;

class operator TPointF. * (afactor: single; const apt1: TPointF): TPointF;
begin
  result:=apt1.Scale(afactor);
end;

class operator TPointF. * (const apt1: TPointF; afactor: single): TPointF;
begin
  result:=apt1.Scale(afactor);
end;

class operator TPointF. ** (const apt1, apt2: TPointF): Single;
begin
  result:=apt1.x*apt2.x + apt1.y*apt2.y;
end;

class operator TPointF.+ (const apt1, apt2 : TPointF): TPointF;
begin
  result.x:=apt1.x+apt2.x;
  result.y:=apt1.y+apt2.y;
end;

class operator TPointF.- (const apt1, apt2 : TPointF): TPointF;
begin
  result.x:=apt1.x-apt2.x;
  result.y:=apt1.y-apt2.y;
end;

class operator TPointF. - (const apt1: TPointF): TPointF;
begin
  Result.x:=-apt1.x;
  Result.y:=-apt1.y;
end;

class operator TPointF. / (const apt1: TPointF; afactor: single): TPointF;
begin
  result:=apt1.Scale(1/afactor);
end;

class operator TPointF. := (const apt: TPoint): TPointF;
begin
  Result.x:=apt.x;
  Result.y:=apt.y;
end;
*)
procedure TPointF.SetLocation(const apt :TPointF);
begin
 x:=apt.x; y:=apt.y;
end;

procedure TPointF.SetLocation(const apt: TPoint);
begin
  x:=apt.x; y:=apt.y;
end;

procedure TPointF.SetLocation(ax,ay : Single);
begin
  x:=ax; y:=ay;
end;

class function TPointF.Create(const ax, ay: Single): TPointF;
begin
  Result.x := ax;
  Result.y := ay;
end;

class function TPointF.Create(const apt: TPoint): TPointF;
begin
  Result.x := apt.X;
  Result.y := apt.Y;
end;


function TPointF.CrossProduct(const apt: TPointF): Single;
begin
  Result:=X*apt.Y-Y*apt.X;
end;

function TPointF.Normalize: TPointF;

var
  L: Single;

begin
  L:=Sqrt(Sqr(X)+Sqr(Y));
  if SameValue(L,0,Epsilon) then
    Result:=Self
  else
    begin
    Result.X:=X/L;
    Result.Y:=Y/L;
    end;
end;


{ TSizeF }

function TSizeF.ToString(aSize,aDecimals : Byte) : RTLString;

var
  Sx,Sy : string;

begin
  Sx:=SingleToStr(cx,aSize,aDecimals);
  Sy:=SingleToStr(cy,aSize,aDecimals);
  Result:='('+Sx+'x'+Sy+')';
end;

function TSizeF.ToString : RTLString;

begin
  Result:=ToString(8,2);
end;



function TSizeF.Add(const asz: TSize): TSizeF;
begin
  result.cx:=cx+asz.cx;
  result.cy:=cy+asz.cy;
end;

function TSizeF.Add(const asz: TSizeF): TSizeF;
begin
  result.cx:=cx+asz.cx;
  result.cy:=cy+asz.cy;
end;

function TSizeF.Subtract(const asz : TSizeF): TSizeF;
begin
  result.cx:=cx-asz.cx;
  result.cy:=cy-asz.cy;
end;

function TSizeF.SwapDimensions:TSizeF;
begin
  result.cx:=cy;
  result.cy:=cx;
end;

function TSizeF.Subtract(const asz: TSize): TSizeF;
begin
  result.cx:=cx-asz.cx;
  result.cy:=cy-asz.cy;
end;

function TSizeF.Distance(const asz : TSizeF) : Single;
begin
  result:=sqrt(sqr(asz.cx-cx)+sqr(asz.cy-cy));
end;

function TSizeF.IsZero : Boolean;
begin
  result:=SameValue(cx,0.0) and SameValue(cy,0.0);
end;

function TSizeF.Scale(afactor: Single): TSizeF;
begin
  result.cx:=afactor*cx;
  result.cy:=afactor*cy;
end;

function TSizeF.Ceiling: TSize;
begin
  result.cx:=ceil(cx);
  result.cy:=ceil(cy);
end;

function TSizeF.Truncate: TSize;
begin
  result.cx:=trunc(cx);
  result.cy:=trunc(cy);
end;

function TSizeF.Floor: TSize;
begin
  result.cx:={$IFDEF FPC_DOTTEDUNITS}System.{$ENDIF}Math.floor(cx);
  result.cy:={$IFDEF FPC_DOTTEDUNITS}System.{$ENDIF}Math.floor(cy);
end;

function TSizeF.Round: TSize;
begin
  result.cx:=System.round(cx);
  result.cy:=System.round(cy);
end;

function TSizeF.Length: Single;
begin     //distance(self) ?
  result:=sqrt(sqr(cx)+sqr(cy));
end;

(*
class operator TSizeF.= (const asz1, asz2 : TSizeF) : Boolean;
begin
  result:=SameValue(asz1.cx,asz2.cx) and SameValue(asz1.cy,asz2.cy);
end;

class operator TSizeF.<> (const asz1, asz2 : TSizeF): Boolean;
begin
  result:=NOT (SameValue(asz1.cx,asz2.cx) and Samevalue(asz1.cy,asz2.cy));
end;

class operator TSizeF. * (afactor: single; const asz1: TSizeF): TSizeF;
begin
  result:=asz1.Scale(afactor);
end;

class operator TSizeF. * (const asz1: TSizeF; afactor: single): TSizeF;
begin
  result:=asz1.Scale(afactor);
end;

class operator TSizeF.+ (const asz1, asz2 : TSizeF): TSizeF;
begin
  result.cx:=asz1.cx+asz2.cx;
  result.cy:=asz1.cy+asz2.cy;
end;

class operator TSizeF.- (const asz1, asz2 : TSizeF): TSizeF;
begin
  result.cx:=asz1.cx-asz2.cx;
  result.cy:=asz1.cy-asz2.cy;
end;

class operator TSizeF. - (const asz1: TSizeF): TSizeF;
begin
  Result.cx:=-asz1.cx;
  Result.cy:=-asz1.cy;
end;

class operator TSizeF. := (const apt: TPointF): TSizeF;
begin
  Result.cx:=apt.x;
  Result.cy:=apt.y;
end;

class operator TSizeF. := (const asz: TSize): TSizeF;
begin
  Result.cx := asz.cx;
  Result.cy := asz.cy;
end;

class operator TSizeF. := (const asz: TSizeF): TPointF;
begin
  Result.x := asz.cx;
  Result.y := asz.cy;
end;
*)
class function TSizeF.Create(const ax, ay: Single): TSizeF;
begin
  Result.cx := ax;
  Result.cy := ay;
end;

class function TSizeF.Create(const asz: TSize): TSizeF;
begin
  Result.cx := asz.cX;
  Result.cy := asz.cY;
end;

{ TRectF }

function TRectF.ToString(aSize,aDecimals : Byte; aUseSize : Boolean = False) : RTLString;

var
  S : RTLString;

begin
  if aUseSize then
    S:=Size.ToString(aSize,aDecimals)
  else
    S:=BottomRight.ToString(aSize,aDecimals);
  Result:='['+TopLeft.ToString(aSize,aDecimals)+' - '+S+']';
end;

function TRectF.ToString(aUseSize: Boolean = False) : RTLString;

begin
  Result:=ToString(8,2,aUseSize);
end;

(*
class operator TRectF. * (L, R: TRectF): TRectF;
begin
  Result := TRectF.Intersect(L, R);
end;

class operator TRectF. + (L, R: TRectF): TRectF;
begin
  Result := TRectF.Union(L, R);
end;

class operator TRectF. := (const arc: TRect): TRectF;
begin
  Result.Left:=arc.Left;
  Result.Top:=arc.Top;
  Result.Right:=arc.Right;
  Result.Bottom:=arc.Bottom;
end;

class operator TRectF. <> (L, R: TRectF): Boolean;
begin
  Result := not(L=R);
end;

class operator TRectF. = (L, R: TRectF): Boolean;
begin
  Result :=
    SameValue(L.Left,R.Left) and SameValue(L.Right,R.Right) and
    SameValue(L.Top,R.Top) and SameValue(L.Bottom,R.Bottom);
end;
*)
constructor TRectF.Create(ALeft, ATop, ARight, ABottom: Single);
begin
  Left := ALeft;
  Top := ATop;
  Right := ARight;
  Bottom := ABottom;
end;

constructor TRectF.Create(P1, P2: TPointF; Normalize: Boolean);
begin
  TopLeft := P1;
  BottomRight := P2;
  if Normalize then
    NormalizeRect;
end;

constructor TRectF.Create(Origin: TPointF);
begin
  TopLeft := Origin;
  BottomRight := Origin;
end;

constructor TRectF.Create(Origin: TPointF; AWidth, AHeight: Single);
begin
  TopLeft := Origin;
  Width := AWidth;
  Height := AHeight;
end;

constructor TRectF.Create(R: TRectF; Normalize: Boolean);
begin
  Self := R;
  if Normalize then
    NormalizeRect;
end;

constructor TRectF.Create(R: TRect; Normalize: Boolean);
begin
  Self.Left := R.Left;
  Self.Top := R.Top;
  Self.Right := R.Right;
  Self.Bottom := R.Bottom;
  if Normalize then
    NormalizeRect;
end;

function TRectF.CenterPoint: TPointF;
begin
  Result.X := (Right-Left) / 2 + Left;
  Result.Y := (Bottom-Top) / 2 + Top;
end;

function TRectF.Ceiling: TRectF;
begin
  Result.BottomRight:=TPointF.Create(BottomRight.Ceiling.X,BottomRight.Ceiling.Y);
  Result.TopLeft:=TPointF.Create(TopLeft.Ceiling.X,TopLeft.Ceiling.Y);
end;

function TRectF.CenterAt(const Dest: TRectF): TRectF;
begin
  Result:=Self;
  RectCenter(Result,Dest);
end;

function TRectF.Fit(const Dest: TRectF): Single;

var
  R : TRectF;

begin
  R:=FitInto(Dest,Result);
  Self:=R;
end;

function TRectF.FitInto(const Dest: TRectF; out Ratio: Single): TRectF;
begin
  if (Dest.Width<=0) or (Dest.Height<=0) then
  begin
    Ratio:=1.0;
    exit(Self);
  end;
  Ratio:=Max(Self.Width / Dest.Width, Self.Height / Dest.Height);
  if Ratio=0 then
    exit(Self);
  Result.Width:=Self.Width / Ratio;
  Result.Height:=Self.Height / Ratio;
  Result.Left:=Self.Left + (Self.Width - Result.Width) / 2;
  Result.Top:=Self.Top + (Self.Height - Result.Height) / 2;
end;

function TRectF.FitInto(const Dest: TRectF): TRectF;
var
  Ratio: Single;
begin
  Result:=FitInto(Dest,Ratio);
end;

function TRectF.PlaceInto(const Dest: TRectF; const AHorzAlign: THorzRectAlign = THorzRectAlign.Center;  const AVertAlign: TVertRectAlign = TVertRectAlign.Center): TRectF;

var
  R : TRectF;
  X,Y : Single;
  D : TRectF absolute dest;

begin
  if (Height>Dest.Height) or (Width>Dest.Width) then
    R:=FitInto(Dest)
  else
    R:=Self;
  case AHorzAlign of
     THorzRectAlign.Left:
       X:=D.Left;
     THorzRectAlign.Center:
       X:=(D.Left+D.Right-R.Width)/2;
     THorzRectAlign.Right:
       X:=D.Right-R.Width;
  end;
  case AVertAlign of
    TVertRectAlign.Top:
      Y:=D.Top;
    TVertRectAlign.Center:
      Y:=(D.Top+D.Bottom-R.Height)/2;
    TVertRectAlign.Bottom:
      Y:=D.Bottom-R.Height;
  end;
  R.SetLocation(PointF(X,Y));
  Result:=R;
end;

function TRectF.SnapToPixel(AScale: Single; APlaceBetweenPixels: Boolean): TRectF;

  function sc (S : single) : single; inline;

  begin
    Result:=System.Trunc(S*AScale)/AScale;
  end;

var
  R : TRectF;
  Off: Single;

begin
  if AScale<=0 then
    AScale := 1;
  R.Top:=Sc(Top);
  R.Left:=Sc(Left);
  R.Width:=Sc(Width);
  R.Height:=Sc(Height);
  if APlaceBetweenPixels then
    begin
    Off:=1/(2*aScale);
    R.Offset(Off,Off);
    end;
  Result:=R;
end;


function TRectF.Contains(Pt: TPointF): Boolean;
begin
  Result := (Left <= Pt.X) and (Pt.X < Right) and (Top <= Pt.Y) and (Pt.Y < Bottom);
end;

function TRectF.Contains(R: TRectF): Boolean;
begin
  Result := (Left <= R.Left) and (R.Right <= Right) and (Top <= R.Top) and (R.Bottom <= Bottom);
end;

class function TRectF.Empty: TRectF;
begin
  Result := TRectF.Create(0,0,0,0);
end;

function TRectF.EqualsTo(const R: TRectF; const Epsilon: Single): Boolean;
begin
  Result:=TopLeft.EqualsTo(R.TopLeft,Epsilon);
  Result:=Result and BottomRight.EqualsTo(R.BottomRight,Epsilon);
end;

function TRectF.GetHeight: Single;
begin
  result:=bottom-top;
end;

function TRectF.GetBottomRight: TPointF;
begin
  Result:=TPointF.Create(Right,Bottom);
end;

function TRectF.GetLocation: TPointF;
begin
  result.x:=Left; result.y:=top;
end;

function TRectF.GetSize: TSizeF;
begin
  result.cx:=width; result.cy:=height;
end;

function TRectF.GetTopLeft: TPointF;
begin
  Result:=TPointF.Create(Left,Top);
end;

procedure TRectF.SetBottomRight(const aValue: TPointF);
begin
  Right:=aValue.X;
  Bottom:=aValue.y;
end;

function TRectF.GetWidth: Single;
begin
  result:=right-left;
end;

procedure TRectF.Inflate(DX, DY: Single);
begin
  Left:=Left-dx;
  Top:=Top-dy;
  Right:=Right+dx;
  Bottom:=Bottom+dy;
end;

procedure TRectF.Intersect(R: TRectF);
begin
  Self := Intersect(Self, R);
end;

class function TRectF.Intersect(R1: TRectF; R2: TRectF): TRectF;
begin
  Result := R1;
  if R2.Left > R1.Left then
    Result.Left := R2.Left;
  if R2.Top > R1.Top then
    Result.Top := R2.Top;
  if R2.Right < R1.Right then
    Result.Right := R2.Right;
  if R2.Bottom < R1.Bottom then
    Result.Bottom := R2.Bottom;
end;

function TRectF.IntersectsWith(R: TRectF): Boolean;
begin
  Result := (Left < R.Right) and (R.Left < Right) and (Top < R.Bottom) and (R.Top < Bottom);
end;

function TRectF.IsEmpty: Boolean;
begin
  Result := (CompareValue(Right,Left)<=0) or (CompareValue(Bottom,Top)<=0);
end;

procedure TRectF.NormalizeRect;
var
  x: Single;
begin
  if Top>Bottom then
  begin
    x := Top;
    Top := Bottom;
    Bottom := x;
  end;
  if Left>Right then
  begin
    x := Left;
    Left := Right;
    Right := x;
  end
end;

procedure TRectF.Inflate(DL, DT, DR, DB: Single);
begin
  Left:=Left-dl;
  Top:=Top-dt;
  Right:=Right+dr;
  Bottom:=Bottom+db;
end;

procedure TRectF.Offset(const dx, dy: Single);
begin
  left:=left+dx; right:=right+dx;
  bottom:=bottom+dy; top:=top+dy;
end;

procedure TRectF.Offset(DP: TPointF);
begin
  left:=left+DP.x; right:=right+DP.x;
  bottom:=bottom+DP.y; top:=top+DP.y;
end;

function TRectF.Truncate: TRect;
begin
  Result.BottomRight:=BottomRight.Truncate;
  Result.TopLeft:=TopLeft.Truncate;
end;

function TRectF.Round: TRect;
begin
  Result.BottomRight:=BottomRight.Round;
  Result.TopLeft:=TopLeft.Round;
end;

procedure TRectF.SetHeight(AValue: Single);
begin
  bottom:=top+avalue;
end;

procedure TRectF.SetTopLeft(const aValue: TPointF);
begin
  Left:=aValue.X;
  Top:=aValue.Y;
end;

(*
procedure TRectF.SetLocation(const X, Y: Single);
begin
  Offset(X-Left, Y-Top);
end;
*)

procedure TRectF.SetLocation(P: TPointF);
begin
  Offset(P.X-Left,P.Y-Top);
end;

procedure TRectF.SetSize(AValue: TSizeF);
begin
  bottom:=top+avalue.cy;
  right:=left+avalue.cx;
end;

procedure TRectF.SetWidth(AValue: Single);
begin
  right:=left+avalue;
end;

class function TRectF.Union(const Points: array of TPointF): TRectF;
var
  i: Integer;
begin
  if Length(Points) > 0 then
  begin
    Result.TopLeft := Points[Low(Points)];
    Result.BottomRight := Points[Low(Points)];

    for i := Low(Points)+1 to High(Points) do
    begin
      if Points[i].X < Result.Left then Result.Left := Points[i].X;
      if Points[i].X > Result.Right then Result.Right := Points[i].X;
      if Points[i].Y < Result.Top then Result.Top := Points[i].Y;
      if Points[i].Y > Result.Bottom then Result.Bottom := Points[i].Y;
    end;
  end else
    Result := Empty;
end;

procedure TRectF.Union(const r: TRectF);
begin
  left:=min(r.left,left);
  top:=min(r.top,top);
  right:=max(r.right,right);
  bottom:=max(r.bottom,bottom);
end;

class function TRectF.Union(R1, R2: TRectF): TRectF;
begin
  Result:=R1;
  Result.Union(R2);
end;

{ TPoint3D }

function TPoint3D.ToString(aSize,aDecimals : Byte) : RTLString;

var
  Sx,Sy,Sz : string;
begin
  Sx:=SingleToStr(X,aSize,aDecimals);
  Sy:=SingleToStr(Y,aSize,aDecimals);
  Sz:=SingleToStr(Z,aSize,aDecimals);
  Result:='('+Sx+','+Sy+','+Sz+')';
end;

function TPoint3D.ToString : RTLString;

begin
  Result:=ToString(8,2);
end;

function TPoint3D.GetSingle3Array: TSingle3Array;
begin
  Result:=[x,y,z]
end;

procedure TPoint3D.SetSingle3Array(const aValue: TSingle3Array);
begin
  x:=aValue[0];
  y:=aValue[1];
  z:=aValue[2];
end;

constructor TPoint3D.Create(const ax,ay,az:single);
begin
  x:=ax; y:=ay; z:=az;
end;

procedure   TPoint3D.Offset(const adeltax,adeltay,adeltaz:single);
begin
  x:=x+adeltax; y:=y+adeltay; z:=z+adeltaz;
end;

procedure   TPoint3D.Offset(const adelta:TPoint3D);
begin
  x:=x+adelta.x; y:=y+adelta.y; z:=z+adelta.z;
end;


{ TSize }

constructor TSize.Create(ax,ay:Longint);
begin
  cx:=ax; cy:=ay;
end;

constructor TSize.Create(asz :TSize);
begin
  cx:=asz.cx; cy:=asz.cy;
  // vector:=TSize(asz.vector); ??
end;


function TSize.IsZero : Boolean;
begin
  result:=(cx=0) and (cy=0);
end;

function TSize.Distance(const asz : TSize) : Double;
begin
  result:=sqrt(sqr(cx-asz.cx)+sqr(cy-asz.cy));
end;

function TSize.Add(const asz : TSize): TSize;
begin
  result.cx:=cx+asz.cx;
  result.cy:=cy+asz.cy;
end;

function TSize.Subtract(const asz : TSize): TSize;
begin
  result.cx:=cx-asz.cx;
  result.cy:=cy-asz.cy;
end;

(*
class operator TSize.=(const asz1, asz2 : TSize) : Boolean;
begin
  result:=(asz1.cx=asz2.cx) and (asz1.cy=asz2.cy);
end;

class operator TSize.<> (const asz1, asz2 : TSize): Boolean;
begin
  result:=(asz1.cx<>asz2.cx) or (asz1.cy<>asz2.cy);
end;

class operator TSize.+(const asz1, asz2 : TSize): TSize;
begin
  result.cx:=asz1.cx+asz2.cx;
  result.cy:=asz1.cy+asz2.cy;
end;

class operator TSize.-(const asz1, asz2 : TSize): TSize;
begin
  result.cx:=asz1.cx-asz2.cx;
  result.cy:=asz1.cy-asz2.cy;
end;
*)
{$ifdef VER3}
constructor TPoint.Create(ax,ay:Longint);
begin
  x:=ax; y:=ay;
end;

constructor TPoint.Create(apt :TPoint);
begin
  x:=apt.x; y:=apt.y;
end;

{$endif}
function TPoint.Add(const apt: TPoint): TPoint;
begin
  result.x:=x+apt.x;
  result.y:=y+apt.y;
end;

function TPoint.Distance(const apt: TPoint): ValReal;
begin
  result:=sqrt(sqr(ValReal(apt.x)-ValReal(x))+sqr(ValReal(apt.y)-ValReal(y))); // convert to ValReal to prevent integer overflows
end;

function TPoint.IsZero : Boolean;
begin
 result:=(x=0) and (y=0);
end;

function TPoint.Subtract(const apt : TPoint): TPoint;
begin
  result.x:=x-apt.x;
  result.y:=y-apt.y;
end;

class function TPoint.Zero: TPoint;
begin
  Result.x := 0;
  Result.y := 0;
end;

procedure TPoint.SetLocation(const apt :TPoint);
begin
 x:=apt.x; y:=apt.y;
end;
procedure TPoint.SetLocation(ax,ay : Longint);
begin
  x:=ax; y:=ay;
end;

procedure TPoint.Offset(const apt :TPoint);
begin
 x:=x+apt.x;
 y:=y+apt.y;
end;

class function TPoint.PointInCircle(const apt, acenter: TPoint;
  const aradius: Integer): Boolean;
begin
  Result := apt.Distance(acenter) <= aradius;
end;

procedure TPoint.Offset(dx,dy : Longint);
begin
  x:=x+dx;
  y:=y+dy;
end;

function TPoint.Angle(const pt: TPoint): Single;

  function arctan2(y,x : Single) : Single;
    begin
      if x=0 then
        begin
          if y=0 then
            result:=0.0
          else if y>0 then
            result:=pi/2
          else
            result:=-pi/2;
        end
      else
        begin
          result:=ArcTan(y/x);
          if x<0 then
            if y<0 then
              result:=result-pi
            else
              result:=result+pi;
        end;
    end;

begin
  result:=ArcTan2(y-pt.y,x-pt.x);
end;

(*
class operator TPoint.= (const apt1, apt2 : TPoint) : Boolean;
begin
  result:=(apt1.x=apt2.x) and (apt1.y=apt2.y);
end;

class operator TPoint.<> (const apt1, apt2 : TPoint): Boolean;
begin
  result:=(apt1.x<>apt2.x) or (apt1.y<>apt2.y);
end;

class operator TPoint.+ (const apt1, apt2 : TPoint): TPoint;
begin
  result.x:=apt1.x+apt2.x;
  result.y:=apt1.y+apt2.y;
end;

class operator TPoint.- (const apt1, apt2 : TPoint): TPoint;
begin
  result.x:=apt1.x-apt2.x;
  result.y:=apt1.y-apt2.y;
end;

// warning suppression for the next ones?
class operator TPoint.:= (const aspt : TSmallPoint): TPoint;
begin
  result.x:=aspt.x;
  result.y:=aspt.y;
end;

class operator TPoint.Explicit (const apt: TPoint): TSmallPoint;
begin
  result.x:=apt.x;
  result.y:=apt.y;
end;
*)
end.

