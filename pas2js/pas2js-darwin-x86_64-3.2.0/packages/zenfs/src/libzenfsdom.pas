{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2017-2020 by the Pas2JS development team.

    Interface for ZenFS - DOM backends

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
{$IFNDEF FPC_DOTTEDUNITS}
unit libzenfsdom;
{$ENDIF}

{
  Include the browser.min.js file if you wish to use these backends.
}

{$mode ObjFPC}
{$modeswitch externalclass}

interface

{$IFDEF FPC_DOTTEDUNITS}
uses
  Api.ZenFs.Core;
{$ELSE}
uses
  libzenfs;
{$ENDIF}

Type
  TDomBackends = class external name 'Object'
    WebStorage : TZenFSFileSystem;
    IndexedDB : TZenFSFileSystem;
    WebAccess : TZenFSFileSystem;
  end;

var
  DomBackends : TDomBackends external name 'ZenFS_DOM';

implementation

end.

