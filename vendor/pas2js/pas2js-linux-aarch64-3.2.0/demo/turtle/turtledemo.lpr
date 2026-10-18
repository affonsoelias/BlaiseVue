program turtledemo;

{$mode objfpc}

uses
  BrowserConsole, BrowserApp, JS, Classes, SysUtils, Web, turtlegraphics;

type
  TMyApplication = class(TBrowserApplication)
  protected
    procedure DoRun; override;
  public
  end;

procedure TMyApplication.DoRun;
begin
  blank(yellow);
  point;
  forward(100);
  point;
  direction(90);
//  right(90);
  forward(100);
  point;
  direction(180);
  //  right(90);
  forward(100);
  point;
  // right(90);
  direction(270);
  forward(100);
end;

var
  Application : TMyApplication;

begin
  Application:=TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
