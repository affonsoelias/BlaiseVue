unit uDesktopBridge;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, webui;

procedure RegisterDesktopBridge(AWindow: Size_t);
procedure HandleMinimize(e: PWebUIEvent); cdecl;
procedure HandleMaximize(e: PWebUIEvent); cdecl;
procedure HandleClose(e: PWebUIEvent); cdecl;
procedure HandleSetTitle(e: PWebUIEvent); cdecl;
procedure HandleSetFullScreen(e: PWebUIEvent); cdecl;
procedure HandleNotify(e: PWebUIEvent); cdecl;
procedure HandleOpenURL(e: PWebUIEvent); cdecl;
procedure HandleOpenFileDialog(e: PWebUIEvent); cdecl;
procedure HandleSaveFileDialog(e: PWebUIEvent); cdecl;
procedure HandleGetSystemInfo(e: PWebUIEvent); cdecl;

implementation

procedure HandleMinimize(e: PWebUIEvent); cdecl;
begin
  WriteLn('[uDesktopBridge] Minimize window requested');
  if Assigned(webui_return_bool) then webui_return_bool(e, True);
end;

procedure HandleMaximize(e: PWebUIEvent); cdecl;
begin
  WriteLn('[uDesktopBridge] Maximize window requested');
  if Assigned(webui_return_bool) then webui_return_bool(e, True);
end;

procedure HandleClose(e: PWebUIEvent); cdecl;
begin
  WriteLn('[uDesktopBridge] Close window requested');
  if Assigned(webui_close) and (e <> nil) then
    webui_close(e^.window);
  if Assigned(webui_exit) then
    webui_exit();
end;

procedure HandleSetTitle(e: PWebUIEvent); cdecl;
var
  NewTitle: PChar;
begin
  if Assigned(webui_get_string) and (e <> nil) then
  begin
    NewTitle := webui_get_string(e);
    if Assigned(webui_set_title) and (NewTitle <> nil) then
      webui_set_title(e^.window, NewTitle);
  end;
  if Assigned(webui_return_bool) then webui_return_bool(e, True);
end;

procedure HandleSetFullScreen(e: PWebUIEvent); cdecl;
var
  Status: Boolean;
begin
  if Assigned(webui_get_bool) and (e <> nil) then
  begin
    Status := webui_get_bool(e);
    if Assigned(webui_set_kiosk) then
      webui_set_kiosk(e^.window, Status);
  end;
  if Assigned(webui_return_bool) then webui_return_bool(e, True);
end;

procedure HandleNotify(e: PWebUIEvent); cdecl;
var
  Title: PChar;
begin
  if Assigned(webui_get_string) and (e <> nil) then
  begin
    Title := webui_get_string(e);
    WriteLn('[uDesktopBridge] Desktop Notification: ', Title);
  end;
  if Assigned(webui_return_bool) then webui_return_bool(e, True);
end;

procedure HandleOpenURL(e: PWebUIEvent); cdecl;
var
  URL: PChar;
begin
  if Assigned(webui_get_string) and (e <> nil) then
  begin
    URL := webui_get_string(e);
    WriteLn('[uDesktopBridge] Open URL: ', URL);
  end;
  if Assigned(webui_return_bool) then webui_return_bool(e, True);
end;

procedure HandleOpenFileDialog(e: PWebUIEvent); cdecl;
var
  MockResult: string;
begin
  MockResult := '{"name":"document.txt","path":"/path/to/document.txt","size":1024}';
  if Assigned(webui_return_string) and (e <> nil) then
    webui_return_string(e, PChar(MockResult));
end;

procedure HandleSaveFileDialog(e: PWebUIEvent); cdecl;
var
  MockResult: string;
begin
  MockResult := '{"saved":true,"filename":"exported_data.json"}';
  if Assigned(webui_return_string) and (e <> nil) then
    webui_return_string(e, PChar(MockResult));
end;

procedure HandleGetSystemInfo(e: PWebUIEvent); cdecl;
var
  SysInfoJSON: string;
  OSName: string;
begin
  {$IFDEF MSWINDOWS}
  OSName := 'Windows';
  {$ELSE}
    {$IFDEF DARWIN}
    OSName := 'macOS';
    {$ELSE}
    OSName := 'Linux';
    {$ENDIF}
  {$ENDIF}

  SysInfoJSON := '{' +
    '"platform":"' + OSName + '",' +
    '"framework":"BlaiseVue 3.5 Desktop (WebUI + Lazarus)",' +
    '"compiler":"Free Pascal ' + {$I %FPCVERSION%} + '",' +
    '"arch":"' + {$I %FPCTARGETCPU%} + '",' +
    '"isDesktop":true' +
    '}';

  if Assigned(webui_return_string) and (e <> nil) then
    webui_return_string(e, PChar(SysInfoJSON));
end;

procedure RegisterDesktopBridge(AWindow: Size_t);
begin
  if not Assigned(webui_bind) then Exit;

  webui_bind(AWindow, 'bv_minimize', @HandleMinimize);
  webui_bind(AWindow, 'bv_maximize', @HandleMaximize);
  webui_bind(AWindow, 'bv_close', @HandleClose);
  webui_bind(AWindow, 'bv_set_title', @HandleSetTitle);
  webui_bind(AWindow, 'bv_set_fullscreen', @HandleSetFullScreen);
  webui_bind(AWindow, 'bv_notify', @HandleNotify);
  webui_bind(AWindow, 'bv_open_url', @HandleOpenURL);
  webui_bind(AWindow, 'bv_open_file_dialog', @HandleOpenFileDialog);
  webui_bind(AWindow, 'bv_save_file_dialog', @HandleSaveFileDialog);
  webui_bind(AWindow, 'bv_get_system_info', @HandleGetSystemInfo);
end;

initialization
  {$IFDEF MSWINDOWS}
  if not IsConsole then
  begin
    try
      AssignFile(Output, 'NUL');
      Rewrite(Output);
      AssignFile(ErrOutput, 'NUL');
      Rewrite(ErrOutput);
    except
    end;
  end;
  {$ENDIF}

end.
