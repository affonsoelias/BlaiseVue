unit uCoordinate;

{$mode Delphi}

interface

uses
    Classes, SysUtils, Math;

type
  TLongitude_from_LatitudeOverflow_Proc= procedure of object;

  { T_Coordinate }

  T_Coordinate
  =
   class
   private
     //FLatLon_ True: type Latitude -90..+90; False: Longitude -180..+180
     FLatLon_: Boolean;
     FStr: String;
     FSign, FDeg, FMin, FSec: Integer;
     FDegrees, FRadians: Extended;
     procedure Set_Degrees ( Value: Extended);
     procedure Set_Radians( Value: Extended);

     function  String_to_Sexagesimal: Byte;
     procedure Sexagesimal_to_String;
     procedure Sexagesimal_to_Degrees;
     procedure Degrees_to_Sexagesimal;
     procedure Degrees_to_Radians;
     procedure Radians_to_Degrees;

     function Check_Radians: Boolean;
     function Check_Degrees: Boolean;
     function Check_Sexagesimal: Byte;

     procedure doModify;
   public
     sinus, cosinus: Extended;

     //procedure called by latitude if 90° is exceeded in absolute value
     // in this case we make a half turn in longitude and recalculate the latitude
     Longitude_from_LatitudeOverflow: TLongitude_from_LatitudeOverflow_Proc; //for the latitude coordinate
     procedure Longitude_Turnaround;                  // for the longitude coordinate, the link is made in Twasm_leaflet

     constructor Create( _LatLon_: Boolean);
     destructor Destroy; override;
     procedure Copy_From( _Coordinate: T_Coordinate);
     function Set_To(aSign, aDeg, aMin, aSec: Integer): Byte;
     function Set_Str(Value: String): Byte;
     property LatLon_: Boolean read FLatLon_;
     property Str    : String  read FStr;
     property Sign   : integer read FSign;
     property Deg    : integer read FDeg;
     property Min    : Integer read FMin;
     property Sec    : Integer read FSec;
     property Degrees : Extended  read FDegrees  write Set_Degrees ;
     property Radians: Extended  read FRadians write Set_Radians;
   end;


implementation

//from uuStrings.pas
function StrToK( Key: String; var S: String): String;
var
   I: Integer;
begin
     I:= Pos( Key, S);
     if I = 0
     then
         begin
         Result:= S;
         S:= '';
         end
     else
         begin
         Result:= Copy( S, 1, I-1);
         Delete( S, 1, (I-1)+Length( Key));
         end;
end;

//from uuStrings.pas
//Like StrToK but takes the first NbCaracteres characters
function StrReadString( var S: String; NbCaracteres: Integer): String;
begin
     Result:= Copy( S, 1, NbCaracteres);
     Delete( S, 1, NbCaracteres);
end;

//from uuStrings.pas
function IsDigit( S: String): Boolean;
var
   I: Integer;
begin
     Result:= S <> '';
     if not Result then exit;

     for I:= 1 to Length( S)
     do
       begin
       Result:= S[I] in ['0'..'9'];
       if not Result then break;
       end;
end;


//from uuStrings.pas
function IsInt( S: String): Boolean;
var
   I, LS: Integer;
begin
     Result:= False;

     // String length
     LS:= Length( S);
     if LS = 0 then exit; // empty string

     // Evacuation of spaces before the number
     I:= 1;
     while I <= LS
     do
       if S[I] = ' '
       then
           Inc( I)
       else
           break;
     if I > LS then exit; // only spaces

     // Process eventual sign
     if S[I] = '+'
     then
         Inc( I)
     else if S[I] = '-'
     then
         Inc( I);
     if I > LS then exit; // no digits

     // Checking that we only have digits
     Result:= True;
     while I <= LS
     do
       if IsDigit(S[I])
       then
           Inc( I)
       else
           begin
           Result:= False;
           break;
           end;
end;

{ T_Coordinate }

constructor T_Coordinate.Create( _LatLon_: Boolean);
begin
     FLatLon_:= _LatLon_;
     Longitude_from_LatitudeOverflow:= nil;
end;

destructor T_Coordinate.Destroy;
begin
     inherited Destroy;
end;


const
     DegSize: array[False..True] of Byte = (4,3); // LatLon_
     MinSize= 3;
     SecSize= 3;
// 4: incorrect sign, 3: incorrect deg , 2: incorrect Min, 1: incorrect Sec
// 0: OK
function T_Coordinate.String_to_Sexagesimal: Byte;
var
   sSign, sDeg, sMin, sSec: String;
   S: String;
   cSign: Char;
begin
     S:= FStr;
     sSign:= StrReadString( S, 1);
     cSign:= sSign[1];

     sDeg:= StrTok( '°', S);
     sMin:= StrTok( '''', S);
     sSec:= StrTok( '"', S);

     if sSec = ''
     then
         sSec:= '0';
     //if not FLatLon_
     //then
     //    begin
     //    WriteLn(ClassName+'.String_to_Sexagesimal: cSign:'+cSign+' sDeg:'+sDeg+' sMin:'+sMin+' sSec:'+sSec);
     //    end;

     Result:= 4; if (cSign <> '-') and (cSign <> '+') then exit;

     Result:= 3; if not IsInt( sDeg) then exit;

     Result:= 2; if not IsInt( sMin) then exit;

     Result:= 1; if not IsInt( sSec) then exit;

     Result:= 0;

     case sSign[1]
     of
       '-': FSign:= -1;
       '+': FSign:= +1;
       end;
     FDeg:= StrToInt( sDeg);
     FMin:= StrToInt( sMin);
     FSec:= StrToInt( sSec);
end;

procedure T_Coordinate.Sexagesimal_to_String;
var
   sSign, sDeg, sMin, sSec: String;
begin
     if FSign < 0
     then
         sSign:= '-'
     else
         sSign:= '+';

     sDeg:= IntToStr(FDeg)+'°';
     while Length(sDeg) < DegSize[LatLon_] do sDeg:= ' '+sDeg;

     sMin:= IntToStr(FMin)+ '''';
     while Length(sMin) < 3 do sMin:= ' '+sMin;

     sSec:= IntToStr(FSec)+'"';
     while Length(sSec) < 3 do sSec:= ' '+sSec;

     FStr:= sSign+sDeg+sMin+sSec;
end;

procedure T_Coordinate.Sexagesimal_to_Degrees;
begin
     FDegrees:= FSign*(FDeg+(FMin+FSec/60.0)/60.0);
end;

procedure T_Coordinate.Degrees_to_Sexagesimal;
var
   d: Extended;
begin
     if FDegrees < 0
     then
         begin
         FSign:= -1;
         d:= -FDegrees;
         end
     else
         begin
         FSign:= +1;
         d:= FDegrees;
         end;
     FDeg:= Trunc(d);
     d:= (d - FDeg) * 60;
     FMin:= Trunc(d);
     d:= (d - FMin) * 60;
     FSec:= Trunc( d);
end;

procedure T_Coordinate.Degrees_to_Radians;
begin
     FRadians:= FDegrees * PI /180;
end;

procedure T_Coordinate.Radians_to_Degrees;
begin
     FDegrees:= FRadians * 180 / PI;
end;

procedure T_Coordinate.Set_Degrees(Value: Extended);
begin
     if FDegrees = Value then exit;
     FDegrees:= Value;
     Check_Degrees;
     Degrees_to_Radians;
     Degrees_to_Sexagesimal;Sexagesimal_to_String;
     doModify;
end;

procedure T_Coordinate.Set_Radians(Value: Extended);
begin
     if FRadians = Value then exit;
     FRadians:= Value;
     Check_Radians;
     Radians_to_Degrees; Degrees_to_Sexagesimal; Sexagesimal_to_String;
     doModify;
end;

function T_Coordinate.Set_To(aSign, aDeg, aMin, aSec: Integer): Byte;
begin
     Result:= 0;
     if (Sign = aSign) and (Deg = aDeg) and (Min = aMin) and (Sec = aSec) then exit;

     FSign:= aSign;
     FDeg:= aDeg;
     FMin:= aMin;
     FSec:= aSec;

     Sexagesimal_to_Degrees;
     if Check_Degrees
     then
         begin
         Result:= Check_Sexagesimal;
         Radians_to_Degrees;
         Degrees_to_Sexagesimal;
         exit;
         end;

     Degrees_to_Radians;
     Sexagesimal_to_String;
     doModify;
end;

function T_Coordinate.Set_Str(Value: String): Byte;
begin
     Result:= 0;
     if FStr = Value then exit;
     FStr:= Value;

     Result:= String_to_Sexagesimal;
     if Result > 0
     then
         begin
         Sexagesimal_to_String;
         exit;
         end;

     Sexagesimal_to_Degrees;
     if Check_Degrees
     then
         begin
         Result:= Check_Sexagesimal;
         Radians_to_Degrees;

         Degrees_to_Sexagesimal;
         Sexagesimal_to_String;
         exit;
         end;

     Degrees_to_Radians;
     Sexagesimal_to_String;
     doModify;
end;

function T_Coordinate.Check_Sexagesimal: Byte;
begin
     Result:= 4; if abs(FSign) <> 1 then exit;
     if LatLon_
     then
         begin
         Result:= 3; if (FDeg < 0)or( 89 < FDeg ) then exit;
         end
     else
         begin
         Result:= 3; if (FDeg < 0)or(179 < FDeg ) then exit;
         end;

     Result:= 2; if (FMin < 0)or(59 < FMin) then exit;
     Result:= 1; if (FSec < 0)or(59 < FMin) then exit;
     Result:= 0;
end;

function T_Coordinate.Check_Degrees: Boolean;
begin
     Result:= True;
     if LatLon_
     then
         if 90 < FDegrees
         then
             FDegrees:= 180 - FDegrees
         else
             if FDegrees < -90
             then
                 FDegrees:= 180 + FDegrees
             else
                 Result:= False
     else
         if 180 < FDegrees
         then
             FDegrees:= 360 - FDegrees
         else
             if FDegrees < -180
             then
                 FDegrees:= 360 + FDegrees
             else
                 Result:= False;
end;

function T_Coordinate.Check_Radians: Boolean;
begin
     Result:= True;
     if LatLon_
     then
         if PI/2 < FRadians
         then
             begin
             if Assigned( Longitude_from_LatitudeOverflow)
             then
                 Longitude_from_LatitudeOverflow;
             FRadians:= PI - FRadians
             end
         else
             if FRadians < -PI/2
             then
                 begin
                 if Assigned( Longitude_from_LatitudeOverflow)
                 then
                     Longitude_from_LatitudeOverflow;
                 FRadians:= -PI - FRadians
                 end
             else
                 Result:= False
     else
              if PI < FRadians
         then
             FRadians:= FRadians - 2*PI
         else if FRadians < -PI
             then
                 FRadians:= 2*PI + FRadians
             else
                 Result:= False;
end;

procedure T_Coordinate.Longitude_Turnaround;
begin
     if LatLon_ then exit; // this only applies to a longitude coordinate.

     FRadians:= FRadians + PI;
     Check_Radians;

     Radians_To_Degrees;
     Degrees_to_Sexagesimal;
     Sexagesimal_to_String;
     doModify;
end;

procedure T_Coordinate.Copy_From( _Coordinate: T_Coordinate);
begin
     if _Coordinate = nil then exit;

     FLatLon_:= _Coordinate.FLatLon_;
     FStr    := _Coordinate.FStr    ;
     FSign   := _Coordinate.FSign   ;
     FDeg    := _Coordinate.FDeg    ;
     FMin    := _Coordinate.FMin    ;
     FSec    := _Coordinate.FSec    ;
     FDegrees := _Coordinate.FDegrees ;
     FRadians:= _Coordinate.FRadians;

     sinus   := _Coordinate.sinus   ;
     cosinus := _Coordinate.cosinus ;
end;

procedure T_Coordinate.doModify;
begin
     SinCos( FRadians, sinus, cosinus);
end;

end.

