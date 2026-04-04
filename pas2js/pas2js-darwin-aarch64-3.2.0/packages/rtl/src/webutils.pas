{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2022 by Michael Van Canneyt
    
    Utility routines for in the browser. Deprecated.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$IFNDEF FPC_DOTTEDUNITS}
unit webutils deprecated 'Use rtl.HTMLUtils';
{$ENDIF}

{$mode objfpc}

interface

uses
{$IFDEF FPC_DOTTEDUNITS}
  BrowserApi.Web, JSApi.JS;
{$ELSE}
  web, js;
{$ENDIF}  

function AsyncSleep(ms: NativeInt): TJSPromise deprecated 'Use HTML.Utils.AsyncSleep';

implementation

function AsyncSleep(ms: NativeInt): TJSPromise;

begin
  Result := TJSPromise.New(
  procedure(resolve,reject : TJSPromiseResolver)
  begin
    window.setTimeout(
    procedure()
    begin
      resolve(ms);
    end,
    ms);
  end);
end;

end.

