{
    This file is part of the Pas2JS run time library.
    Copyright (C) 2023 Michael Van Canneyt

    tinyeditor import unit

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit libtinyeditor;
{$ENDIF}

{$mode objfpc}
{$modeswitch externalclass}

interface

Uses 
{$IFDEF FPC_DOTTEDUNITS}
  JSApi.JS, BrowserApi.Web;
{$ELSE}
  JS, Web;
{$ENDIF}

Type
  TTinyEditor = class external name 'Object' (TJSObject)
  Public
    procedure transformToEditor(aElement : TJSHTMLElement);
  end;  

var
  tinyEditor : TTinyEditor; external name '__tinyEditor';

Implementation
 
end.
