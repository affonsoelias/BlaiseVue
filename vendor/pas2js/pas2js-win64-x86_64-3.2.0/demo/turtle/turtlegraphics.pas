unit turtlegraphics;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils;

{ Commands & constants taken from the turtle graphics at
  https://www.turtle.ox.ac.uk/documentation/reference
}

const
  green       = $228B22;
  red         = $FF0000;
  blue        = $0000FF;
  yellow      = $FFFF00;
  violet      = $8A2BE2;
  lime        = $00FF00;
  orange      = $FFAA00;
  skyblue     = $00B0FF;
  brown       = $964B00;
  pink        = $EE1289;
  darkgreen   = $006400;
  darkred     = $B22222;
  darkblue    = $000080;
  ochre       = $C0B030;
  indigo      = $4B0082;
  olive       = $808000;
  orangered   = $FF6600;
  teal        = $008080;
  darkbrown   = $5C4033;
  magenta     = $FF00FF;
  lightgreen  = $98FB98;
  lightred    = $CD5C5C;
  lightblue   = $99BBFF;
  cream       = $FFFFBB;
  lilac       = $B093FF;
  yellowgreen = $AACC33;
  peach       = $FFCCB0;
  cyan        = $00FFFF;
  lightbrown  = $B08050;
  lightpink   = $FFB6C0;
  seagreen    = $3CB371;
  maroon      = $800000;
  royal       = $4169E1;
  gold        = $FFC800;
  purple      = $800080;
  emerald     = $00C957;
  salmon      = $FA8072;
  turquoise   = $00BEC1;
  coffee      = $926F3F;
  rose        = $FF88AA;
  greengrey   = $709070;
  redgrey     = $B08080;
  bluegrey    = $8080A0;
  yellowgrey  = $909070;
  darkgrey    = $404040;
  midgrey     = $808080;
  lightgrey   = $A0A0A0;
  silver      = $C0C0C0;
  white       = $FFFFFF;
  black       = $000000;

// Relative movement
procedure forward(n : integer);
procedure back(n : integer);
procedure left(n : integer);
procedure right(n : integer);
procedure drawxy(x,y : integer);
procedure movexy(x,y : integer);

// Absolute movement
procedure home;
procedure setx(x : integer);
procedure sety(y : integer);
procedure setxy(x,y : integer);
procedure direction(n : integer);
procedure angles(degrees : integer);
procedure turnxy(x,y : integer);

// Other
procedure point;
procedure setpointsize(aSize : Integer);
procedure penup;
procedure pendown;
procedure colour(aColor : Integer);
procedure color(aColor : Integer);
procedure randcol(n: integer);
function rgb(i : integer) : Integer;
procedure thickness(i : integer);

procedure box(x,y,color : integer; border : Boolean);
procedure circle(radius : integer);
procedure blot(radius : integer);
procedure ellipse(xRadius,yRadius : integer);
procedure ellblot(xRadius,yRadius : integer);

procedure blank(acolor : integer);

// Not part of the API, but needed to set up stuff.
// Maybe it should be moved to another unit ?
procedure _initcanvas(aID : string);

// Variables that can be set directly.
var
  turtc, turtd, turtx, turty, turtt : integer;

implementation

uses web;

const
  colours : array[1..50] of integer = (
    green,
    red,
    blue,
    yellow,
    violet,
    lime,
    orange,
    skyblue,
    brown,
    pink,
    darkgreen,
    darkred,
    darkblue,
    ochre,
    indigo,
    olive,
    orangered,
    teal,
    darkbrown,
    magenta,
    lightgreen,
    lightred,
    lightblue,
    cream,
    lilac,
    yellowgreen,
    peach,
    cyan,
    lightbrown,
    lightpink,
    seagreen,
    maroon,
    royal,
    gold,
    purple,
    emerald,
    salmon,
    turquoise,
    coffee,
    rose,
    greengrey,
    redgrey,
    bluegrey,
    yellowgrey,
    darkgrey,
    midgrey,
    lightgrey,
    silver,
    white,
    black
  );

var
  turtAngles : integer = 360;
  drawing : boolean;
  pointSize : Integer = 4;
  canvas : TJSCanvasRenderingContext2D;

Function ToRad(aDirection : Integer) : Double;

begin
  Result:=(aDirection/turtAngles)*2*Pi;
end;

Function ToDegrees(aAngle : Double) : Integer;
begin
  Result:=Round((aAngle*turtAngles)/(2*Pi));
end;

procedure forward(n : integer);

var
  deltaX,deltaY : integer;

begin
  DeltaX:=round(n * cos(ToRad(turtd)));
  DeltaY:=round(n * sin(ToRad(turtd)));
  DrawXY(DeltaX,DeltaY)
end;

procedure back(n : integer);
var
  deltaX,deltaY : integer;

begin
  DeltaX:=-round(n * cos(ToRad(turtd)));
  DeltaY:=-round(n * sin(ToRad(turtd)));
  DrawXY(DeltaX,DeltaY)
end;

procedure left(n : integer);
begin
  TurtD:=TurtD-N;
end;

procedure right(n : integer);
begin
  TurtD:=TurtD+N;
end;

procedure applycolor(acolor: integer);
var
  r,g,b : Integer;
  col : string;

begin
  col:=format('%.6x',[aColor]);
  B:=aColor and $FF;
  G:=(aColor shr 8) and $FF;
  R:=(aColor shr 16) and $FF;
  col:=Format('rgb(%d,%d,%d)',[R,G,B]);
  canvas.strokestyle:=col;
  canvas.fillstyle:=col;
end;

procedure setcanvasparams;
begin
  Canvas.lineWidth:=turtt;
  applycolor(turtc);
end;

procedure drawxy(x,y : integer);

begin
  if Drawing then
    begin
    Canvas.BeginPath;
    setcanvasparams;
    Canvas.MoveTo(TurtX,TurtY);
    Canvas.Lineto(TurtX+X,TurtY+Y);
    Canvas.Stroke;
    end;
  MoveXY(X,Y);
end;

procedure movexy(x,y : integer);

begin
  TurtX:=TurtX+X;
  TurtY:=TurtY+Y;
end;

// Absolute movement
procedure home;
begin
  TurtX:=0;
  TurtY:=0;
  TurtD:=0;
end;

procedure setx(x : integer);
begin
  TurtX:=X;
end;

procedure sety(y : integer);
begin
  TurtY:=Y;
end;

procedure setxy(x,y : integer);

begin
  TurtX:=X;
  TurtY:=Y;
end;

procedure direction(n : integer);
begin
  TurtD:=N;
end;

procedure angles(degrees : integer);

begin
  TurtAngles:=Degrees;
end;

procedure turnxy(x,y : integer);

begin
  TurtD:= ToDegrees(ArcTan2(x,y));
end;

procedure point;

begin
  blot(pointsize);
end;

procedure setpointsize(aSize: Integer);
begin
  pointSize:=aSize;
end;

procedure penup;
begin
  Drawing:=False;
end;

procedure pendown;

begin
  Drawing:=True;
end;

procedure circle(radius: integer);
begin
  setcanvasparams;
  Canvas.arc(TurtX,TurtY,radius,0,2*pi);
end;

procedure box(x,y,color : integer; border : Boolean);

var
  c : integer;

begin
  c:=turtc;
  turtc:=color;
  setcanvasparams;
  Canvas.fillrect(TurtX,TurtY,X,Y);
  turtc:=c;
  if border then
    begin
    setcanvasparams;
    Canvas.rect(TurtX,TurtY,X,Y);
    end;
end;

procedure blot(radius: integer);
var
  P : TJSPath2D;
begin
  P:=TJSPath2D.new;
  P.arc(TurtX,TurtY,radius,0,2*pi);
  setcanvasparams;
  canvas.beginpath;
  canvas.fill(P);
  canvas.stroke;
end;

procedure ellipse(xRadius,yRadius: integer);
begin
  setcanvasparams;
  Canvas.ellipse(TurtX,TurtY,xRadius,yRadius,0,0,2*pi);
end;

procedure ellblot(xRadius,yRadius : integer);
var
  P : TJSPath2D;
begin
  P:=TJSPath2D.new;
  P.ellipse(TurtX,TurtY,xRadius,yRadius,0,0,2*pi);
  setcanvasparams;
  canvas.beginpath;
  canvas.fill(P);
  canvas.stroke;
end;

procedure blank(acolor: integer);

var
  c : integer;

begin
  c:=turtc;
  turtc:=acolor;
  setcanvasparams;
  canvas.FillRect(-500,-500,1000,1000);
  turtc:=c;
end;

procedure _initcanvas(aID : string);

var
  cEl : TJSHTMLCanvasElement;
  D,w,h : double;

begin
  cEl:=TJSHTMLCanvasElement(Document.getElementById(aID));
  if cEl=Nil then exit;
  W := cEl.getBoundingClientRect().width;
  H := cEl.getBoundingClientRect().height;
  if H<W then
    D:=H
  else
    D:=W;
  cEl.width:=Round(D);
  cEl.height:=Round(D);
  canvas:=TJSCanvasRenderingContext2D(cel.getContext('2d'));
  if not assigned(Canvas) then
    exit;
  // Transform so middle point is 0,0
  // Up is zero degrees...
  canvas.transform(0,-D/1000,D/1000,0,D/2,D/2);

  colour(black);
  thickness(2);

  drawing:=true;
end;

procedure colour(aColor : Integer);

begin
  turtc:=aColor;
end;

procedure color(aColor: Integer);
begin
  colour(aColor);
end;

procedure randcol(n : integer);
begin
  if n>50 then n:=50;
  if n<1 then n:=1;
  color(rgb(1+random(n)));
end;

function rgb(i : integer) : integer;

begin
  if (I>=1) and (I<=50) then
    Result:=colours[i];
end;

procedure thickness(i : integer);

begin
  if I<=0 then exit;
  turtt:=i;
end;

initialization
  _initCanvas('cnvTurtle');
end.

