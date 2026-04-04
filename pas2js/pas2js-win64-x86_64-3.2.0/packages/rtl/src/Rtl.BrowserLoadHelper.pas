{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2023 by Michael Van Canneyt
    
    Loader helper for TStringList, usable in the browser.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit Rtl.BrowserLoadHelper;
{$ENDIF}

{$mode objfpc}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Classes, System.SysUtils, JSApi.JS, BrowserApi.Web;
{$ELSE}
  Classes, SysUtils, JS, Web;
{$ENDIF}  

Type
  { TBrowserLoadHelper }

  TBrowserLoadHelper = Class (TLoadHelper)
  Public
    Class Procedure LoadText(aURL : String; aSync : Boolean; aOnLoaded : TTextLoadedCallBack; aOnError : TErrorCallBack); override;
    Class Procedure LoadBytes(aURL : String; aSync : Boolean; aOnLoaded : TBytesLoadedCallBack; aOnError : TErrorCallBack); override;
  end;

implementation

{ TBrowserLoadHelper }

class procedure TBrowserLoadHelper.LoadText(aURL: String; aSync: Boolean; aOnLoaded: TTextLoadedCallBack; aOnError: TErrorCallBack);

  function doFetchOK(response : JSValue) : JSValue;

  var
    Res : TJSResponse absolute response;

  begin
    Result:=False;
    If (Res.status<>200) then
      begin
      If Assigned(aOnError) then
        aOnError('Error '+IntToStr(Res.Status)+ ': '+Res.StatusText)
      end
    else
      Res.Text._then(
        function (value : JSValue) : JSValue
          begin
          aOnLoaded(String(value));
          end
      );
  end;

  function doFetchFail(response : JSValue) : JSValue;

  begin
    Result:=False;
    aOnError('Error 999: unknown error: '+TJSJSON.Stringify(response));
  end;

begin
  if ASync then
    Window.Fetch(aURl)._then(@DoFetchOK).catch(@DoFetchFail)
  else
    With TJSXMLHttpRequest.new do
      begin
      open('GET', aURL, False);
      AddEventListener('load',Procedure (oEvent: JSValue)
        begin
        aOnLoaded(responseText);
        end
      );
      AddEventListener('error',Procedure (oEvent: JSValue)
        begin
        if Assigned(aOnError) then
          aOnError(TJSError(oEvent).Message);
        end
      );
      send();
      end;
end;

class procedure TBrowserLoadHelper.LoadBytes(aURL: String; aSync: Boolean; aOnLoaded: TBytesLoadedCallBack; aOnError: TErrorCallBack);

  function doFetchFail(response : JSValue) : JSValue;

  begin
    Result:=False;
    if assigned(aOnError) then
      if isObject(Response) and (TJSObject(Response) is TJSError) then
        aOnError('Error 999: '+TJSError(Response).Message)
      else
        aOnError('Error 999: unknown error');
  end;


  function doFetchOK(response : JSValue) : JSValue;

  var
    Res : TJSResponse absolute response;

  begin
    Result:=False;
    If (Res.status<>200) then
      begin
      If Assigned(aOnError) then
        aOnError('Error '+IntToStr(Res.Status)+ ': '+Res.StatusText)
      end
    else
      Res.Blob._then(
        function (value : JSValue) : JSValue
          begin
          TJSBlob(Value).ArrayBuffer._then(function(arr : JSValue) : JSValue
            begin
            aOnLoaded(TJSArrayBuffer(arr))
            end
          ).Catch(@DoFetchFail);
          end
        );
  end;


  function StringToArrayBuffer(str : string) : TJSArrayBuffer;

  Var
    i,l : Integer;

  begin
    L:=Length(str);
    Result:=TJSArrayBuffer.New(l*2); // 2 bytes for each char
    With TJSUint16Array.New(Result) do
      for i:=1 to L do
        Values[i-1]:=Ord(Str[i]);
  end;

begin
  if ASync then
    Window.Fetch(aURl)._then(@DoFetchOK).catch(@DoFetchFail)
  else
    With TJSXMLHttpRequest.new do
      begin
      open('GET', aURL, False);
      AddEventListener('load',Procedure (oEvent: JSValue)
        begin
        if (Status<>200) then
          begin
          if assigned(aOnError) then
            aOnError('Error '+IntToStr(Status)+ ': '+StatusText)
          end  
        else
          aOnLoaded(StringToArrayBuffer(responseText));
        end
      );
      AddEventListener('error',Procedure (oEvent: JSValue)
        begin
        if Assigned(aOnError) then
          aOnError(TJSError(oEvent).Message);
        end
      );
      send();
      end;
end;

initialization
  SetLoadHelperClass(TBrowserLoadHelper);
end.

