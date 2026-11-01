program demo_app;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils;

// BlaiseVue Reactive Single File Components (.bv)
// Press F9 in Lazarus IDE to launch the live dev server!
begin
  WriteLn('BlaiseVue Project: demo_app');
end.
