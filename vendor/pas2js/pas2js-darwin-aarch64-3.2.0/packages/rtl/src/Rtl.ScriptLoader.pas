{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2019 by Michael Van Canneyt

    This unit implements a HTML script tag loader.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit Rtl.ScriptLoader;
{$ENDIF}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  System.Types;
{$ELSE} 
  Types;
{$ENDIF}

Type
  TloadedCallBack = Reference to procedure(Data : TObject);
  TProc = reference to procedure;
    
Procedure loadScripts(scripts : TStringDynArray; callback : TLoadedCallback; Data : TObject);

implementation

Uses
{$IFDEF FPC_DOTTEDUNITS}
  JSApi.JS, BrowserApi.Web;
{$ELSE}
  js, web;
{$ENDIF}

Procedure loadScripts(scripts : TStringDynArray; callback : TLoadedCallback; Data : TObject);

  Procedure loader (src : String; handler : TProc);
  
  var 
    head,script : TJSElement;

    Procedure DoLoaded;
    
    begin
      script.Properties['onload']:=Nil;
      script.Properties['onreadystatechange']:=Nil;
      Handler;
    end;
    
  begin
    script:= document.createElement('script');
    script['src'] := src;
    script.Properties['onload'] := @DoLoaded;
    script.Properties['onreadystatechange']:=@DoLoaded;
    head:=TJSElement(document.getElementsByTagName('head')[0]);
    if Head=Nil then
      Head:=Document.body;
    head.appendChild( script );
  end; 
    
  Procedure run;
  begin
    if Length(Scripts)<>0 then
      loader(String(TJSArray(scripts).shift()), @run)
    else if Assigned(callback) then
      callback(data);
  end;
        
begin
  Run;
end;

end. 
