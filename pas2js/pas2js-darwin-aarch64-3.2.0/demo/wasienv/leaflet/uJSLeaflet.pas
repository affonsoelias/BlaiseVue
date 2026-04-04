unit uJSLeaflet;

{$mode Delphi}

interface

uses
 Classes, SysUtils, JOB.Shared, JOB_Web, JOB.JS;

type
 TOnMapClickCallback = procedure (_e: IJSEvent) of object;

 { IJSLeafletMap }

 IJSLeafletMap
 =
  interface(IJSObject)
   ['{622B2D01-0F15-480B-BC46-FCB926059823}']
   procedure Set_onClick(const _Callback: TOnMapClickCallback);
   procedure setView( _Latitude, _Longitude, _Zoom: Extended);
  end;

 { TJSLeafletMap }

 TJSLeafletMap
 =
  class(TJSObject,IJSLeafletMap)
  public
    procedure Set_onClick(const _Callback: TOnMapClickCallback);
    procedure setView( _Latitude, _Longitude, _Zoom: Extended);
    class function JSClassName: UnicodeString; override;
    class function Cast(const Intf: IJSObject): IJSLeafletMap;
  end;

function JOBCallOnMapClickCallback(const _Method: TMethod; var _H: TJOBCallbackHelper): PByte;

type
 { IJSLeafletTileLayer }

 IJSLeafletTileLayer
 =
  interface(IJSObject)
   ['{54AD2D36-7A4B-4718-9DFE-653CE6754DFA}']
   procedure addTo( const _map: IJSLeafletMap);
  end;
 TJSLeafletTileLayer
 =
  class(TJSObject,IJSLeafletTileLayer)
  public
    procedure addTo( const _map: IJSLeafletMap);
    class function JSClassName: UnicodeString; override;
    class function Cast(const Intf: IJSObject): IJSLeafletTileLayer;
  end;

type
 { IJSLeaflet }

 IJSLeaflet
 =
  interface(IJSObject)
   ['{778EC20D-A7FB-4D52-90E2-D02A31A1607F}']
   function map(const _idMap: String; _params: IJSObject= nil): IJSLeafletMap;
   function tileLayer( const _urlTemplate: String; _options: IJSObject= nil): IJSLeafletTileLayer;
  end;

 { TJSLeafletMap }

 TJSLeaflet
 =
  class(TJSObject,IJSLeaflet)
  public
    function map(const _idMap: String; _params: IJSObject= nil): IJSLeafletMap;
    function tileLayer( const _urlTemplate: String; _options: IJSObject= nil): IJSLeafletTileLayer;
    class function JSClassName: UnicodeString; override;
    class function Cast(const Intf: IJSObject): IJSLeaflet;
    class function _from_id(const _id: String): IJSLeaflet;
  end;


implementation

function JOBCallOnMapClickCallback(const _Method: TMethod; var _H: TJOBCallbackHelper): PByte;
var
   o: TJSObject;
   e: IJSEvent;
begin
     o:=_H.GetObject(TJSObject);
     e:= TJSEvent.Cast( o);
     TOnMapClickCallback(_Method)( e);
     Result:=_H.AllocUndefined;
end;


procedure TJSLeafletMap.Set_onClick(const _Callback: TOnMapClickCallback);
var
   m: TJOB_Method;
begin
     m:=TJOB_Method.Create(TMethod(_Callback),@JOBCallOnMapClickCallback);
     try
        InvokeJSNoResult('on',['click',m]);
     finally
            m.free;
            end;
end;

procedure TJSLeafletMap.setView( _Latitude, _Longitude, _Zoom: Extended);
var
   latlng: TJOB_ArrayOfDouble;
begin
     latlng:= TJOB_ArrayOfDouble.Create( [_Latitude, _Longitude]);
     InvokeJSObjectResult( 'setView',[latlng, _Zoom],TJSObject);
end;

class function TJSLeafletMap.JSClassName: UnicodeString;
begin
     Result:= 'Map';
end;
class function TJSLeafletMap.Cast(const Intf: IJSObject): IJSLeafletMap;
begin
     Result:= TJSLeafletMap.JOBCast(Intf);
end;

{ TJSLeafletTileLayer }

class function TJSLeafletTileLayer.JSClassName: UnicodeString;
begin
     Result:=inherited JSClassName;
end;

class function TJSLeafletTileLayer.Cast(const Intf: IJSObject): IJSLeafletTileLayer;
begin
     Result:= TJSLeafletTileLayer.JOBCast(Intf);
end;

procedure TJSLeafletTileLayer.addTo( const _map: IJSLeafletMap);
begin
     InvokeJSNoResult('addTo', [_map]);
end;

{ TJSLeaflet }

function TJSLeaflet.map(const _idMap: String; _params: IJSObject= nil): IJSLeafletMap;
begin
     Result:= TJSLeafletMap.Cast( InvokeJSObjectResult( 'map',[_idMap, _params], TJSObject));
end;

function TJSLeaflet.tileLayer(const _urlTemplate: String; _options: IJSObject= nil): IJSLeafletTileLayer;
begin
     Result:= TJSLeafletTileLayer.Cast(InvokeJSObjectResult( 'tileLayer', [_urlTemplate, _options], TJSObject));
end;

class function TJSLeaflet.JSClassName: UnicodeString;
begin
     Result:=inherited JSClassName;
end;

class function TJSLeaflet.Cast(const Intf: IJSObject): IJSLeaflet;
begin
     Result:= TJSLeaflet.JOBCast(Intf);
end;

class function TJSLeaflet._from_id(const _id: String): IJSLeaflet;
begin
     Result:= TJSLeaflet.Cast(JSWindow.ReadJSPropertyObject( _id, TJSObject));
end;

end.

