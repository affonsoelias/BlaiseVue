library wasm_leaflet;

{$mode objfpc}
{$h+}
{$codepage UTF8}

uses
    uJSLeaflet,
    uCoordinate,
  NoThreads, SysUtils, StrUtils, JOB.Shared, JOB_Web, JOB.JS;

type

  { Twasm_leaflet }

 Twasm_leaflet
 =
  class
  //Lifecycle Management
  public
    constructor Create;
    destructor Destroy; override;
  //Parameters
  private
    Latitude, Longitude: T_Coordinate;
    iParameters_Latitude : IJSHTMLInputElement;
    iParameters_Longitude: IJSHTMLInputElement;
    bCalculation: IJSHTMLButtonElement;
    procedure bCalculation_Show;
    procedure bCalculation_Hide;
    procedure iParameters_LatitudeInput (Event: IJSEvent);
    procedure iParameters_LongitudeInput(Event: IJSEvent);
    procedure bCalculationClick(Event: IJSEvent);
    procedure _from_Parameters;
  //Result
  private
    dCalculation_Result: IJSHTMLDivElement;
    procedure Display;
  //Leaflet Map
  private
    LeafLet_initialized: Boolean;
    Leaflet: IJSLeaflet;
    map: IJSLeafletMap;
    procedure mapClick(_e: IJSEvent);
    procedure RefreshMap;
    procedure Set_Map_to( _Latitude, _Longitude: Extended);
    procedure Ensure_LeafLet_initialized;
  //GeoLocation
  private
    procedure DoGeoLocation;
    procedure successCallback(_Position : IJSGeolocationPosition);
    procedure errorCallback(_Value : IJSGeolocationPositionError);
    procedure Process_the_location( _Latitude_Degrees, _Longitude_Degrees: Extended);
  //Execution
  public
    procedure Run;
  end;

{ Twasm_leaflet }

constructor Twasm_leaflet.Create;
begin
     inherited;
     LeafLet_initialized:= False;
     Latitude := T_Coordinate.Create( True);
     Longitude:= T_Coordinate.Create( False);
     Latitude.Longitude_from_LatitudeOverflow:= @Longitude.Longitude_Turnaround;
end;

destructor Twasm_leaflet.Destroy;
begin
     inherited;
end;

procedure Twasm_leaflet.Display;
var
   sResult: String;
begin
     //WriteLn(ClassName+'.Display: Latitude: ',UTF8Encode(iParameters_Latitude.value));
     iParameters_Latitude.value:= UTF8Decode(Latitude.Str);
     //WriteLn(ClassName+'.Display: Longitude: ',UTF8Encode(iParameters_Longitude.value));
     iParameters_Longitude.value:= UTF8Decode(Longitude.Str);

     DefaultFormatSettings.ThousandSeparator:= ' ';
     DefaultFormatSettings.DecimalSeparator:= ',';

     sResult
     :=
        'Latitude:' +Latitude .Str+'<br/>'
       +'Longitude:'+Longitude.Str+'<br/>'
       ;
     dCalculation_Result.innerHTML:= UTF8Decode( sResult);

     RefreshMap;
end;

procedure Twasm_leaflet._from_Parameters;
begin
     //WriteLn(ClassName+'._from_Parameters: Latitude: ',UTF8Encode(iParameters_Latitude.value));
     Latitude.Set_Str( UTF8Encode(iParameters_Latitude.value));

     //WriteLn(ClassName+'._from_Parameters: Longitude: ',UTF8Encode(iParameters_Longitude.value));
     Longitude.Set_Str( UTF8Encode(iParameters_Longitude.value));

     Display;
     bCalculation_Hide;
end;

procedure Twasm_leaflet.bCalculationClick(Event: IJSEvent);
begin
     _from_Parameters;
end;

procedure Twasm_leaflet.bCalculation_Show;
begin
     //WriteLn(ClassName+'.bCalculation_Show');
     WriteLn(ClassName+'.bCalculation_Show: bCalculation.style.cssText:' ,bCalculation.style.cssText);
     bCalculation.style.cssText:= 'visibility: visible;';
end;

procedure Twasm_leaflet.bCalculation_Hide;
begin
     bCalculation.style.cssText:= 'visibility: hidden;';
end;

procedure Twasm_leaflet.iParameters_LatitudeInput(Event: IJSEvent);
begin
     bCalculation_Show;
end;

procedure Twasm_leaflet.iParameters_LongitudeInput(Event: IJSEvent);
begin
     bCalculation_Show;
end;

procedure Twasm_leaflet.mapClick(_e: IJSEvent);
var
   latlng: TJSObject;
   lat, lng: double;
   procedure dump_latlng_variables;
   var
      latlng_variables: TJSObject;
   begin
        latlng_variables:= JSObject.InvokeJSObjectResult( 'keys'    ,[latlng],TJSObject);
        WriteLn( ClassName+'.Set_Map_To global_variables: type', latlng_variables.JSClassName, 'value: ', latlng_variables.toString);
   end;
begin
     //WriteLn( Classname+'.mapClick: _e.type_:',_e.type_);
     latlng:= _e.ReadJSPropertyObject('latlng', TJSObject);
     //dump_latlng_variables;
     lat:= latlng.ReadJSPropertyDouble('lat');
     lng:= latlng.ReadJSPropertyDouble('lng');
     Process_the_location( lat, lng);
end;

procedure Twasm_leaflet.Ensure_LeafLet_initialized;
   procedure L_tileLayer;
   var
      params: TJSObject;
   begin
        //L
        // .tileLayer( 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        //             {
        //             attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors',
        //             maxZoom: 19,
        //             }
        //           )
        // .addTo(map);

        params:= TJSObject.JOBCreate([]);
        params.Properties['attribution']:= 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors';
        params.Properties['maxZoom'    ]:= 19;

        Leaflet
         .tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', params)
         .addTo( map);
   end;
begin
     if LeafLet_initialized then exit;

     Leaflet:= TJSLeaflet._from_id( 'L');
     map:= Leaflet.map('dMap'); //dMap is the container <div> id
     L_tileLayer;
     map.Set_onClick(@mapClick);

     LeafLet_initialized:= True;
end;

procedure Twasm_leaflet.Set_Map_to(_Latitude, _Longitude: Extended);
   procedure dump_global_variables;
   var
      global_variables: TJSObject;
   begin
        global_variables:= JSObject.InvokeJSObjectResult( 'keys',[JSWindow],TJSObject);
        WriteLn( ClassName+'.Set_Map_To global_variables: type',
                 global_variables.JSClassName, 'valeur: ', global_variables.toString);
   end;
begin
     Ensure_LeafLet_initialized;
     //dump_global_variables;

     //const map = L.map('map').setView([latitude, longitude], 13);
     map.setView( _Latitude, _Longitude, 13);
end;

procedure Twasm_leaflet.RefreshMap;
begin
     Set_Map_to( Latitude.Degrees, Longitude.Degrees);
end;

procedure Twasm_leaflet.Process_the_location( _Latitude_Degrees, _Longitude_Degrees: Extended);
begin
     Latitude .Degrees:= _Latitude_Degrees ;
     Longitude.Degrees:= _Longitude_Degrees;
     Display;
end;

procedure Twasm_leaflet.successCallback(_Position : IJSGeolocationPosition);
   //procedure dump_latlng_variables;
   //var
   //   latlng_variables: TJSObject;
   //begin
   //     latlng_variables:= JSObject.InvokeJSObjectResult( 'keys'    ,[latlng],TJSObject);
   //     WriteLn( ClassName+'.Set_Map_To global_variables: type', latlng_variables.JSClassName, 'valeur: ', latlng_variables.toString);
   //end;
begin
     //The longitude given by the navigator is negative towards the West
     Process_the_location( _Position.coords.latitude, _Position.coords.longitude);

end;
procedure Twasm_leaflet.errorCallback(_Value : IJSGeolocationPositionError);
begin
     WriteLn( ClassName+'.b_Click: geolocation.getCurrentPosition: ', _Value.message);
     Process_the_location( 43.604312,1.4436825);//Toulouse, France
end;

procedure Twasm_leaflet.DoGeoLocation;
begin
     if  true//window.navigator.hasOwnProperty('geoLocation')
     then
         JSWindow.navigator.geolocation.getCurrentPosition(@successCallback, @errorCallback)
     else
         WriteLn(ClassName+'.b_Click: GeoLocation unavailable');
end;

procedure Twasm_leaflet.Run;
begin
     iParameters_Latitude :=TJSHTMLInputElement .Cast(JSDocument.getElementById('iParameters_Latitude' ));
     iParameters_Longitude:=TJSHTMLInputElement .Cast(JSDocument.getElementById('iParameters_Longitude'));
     bCalculation         :=TJSHTMLButtonElement.Cast(JSDocument.getElementById('bCalculation'         ));
     dCalculation_Result  :=TJSHTMLDivElement   .Cast(JSDocument.getElementById('dCalculation_Result'  ));

     iParameters_Latitude .addEventListener('input', @iParameters_LatitudeInput );
     iParameters_Longitude.addEventListener('input', @iParameters_LongitudeInput);
     bCalculation         .addEventListener('click' ,@bCalculationClick         );

     DoGeoLocation;
end;

var
   Application: Twasm_leaflet;
begin
     Application:=Twasm_leaflet.Create;
     Application.Run;
end.

