{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2017-2020 by the Pas2JS development team.

    Demo sending output to /debugcapture API of simpleserver (or compileserver)

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
program democapture;

{$mode objfpc}
{$h+}

uses
  sysutils, classes, browserconsole, debugcapture;

Var
  I : integer;

begin
  With TDebugCaptureClient.Instance do
    begin
    URL:='/debugcapture';
    BufferTimeout:=100;
    HookConsole:=True;
    end;
  For I:=1 to 100 do
    Writeln('This is output line '+IntToStr(I))
end.

