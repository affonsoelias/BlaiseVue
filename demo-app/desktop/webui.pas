unit webui;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, DynLibs;

const
  NoBrowser = 0;
  AnyBrowser = 1;
  Chrome = 2;
  Firefox = 3;
  Edge = 4;
  Safari = 5;
  Chromium = 6;
  Opera = 7;
  Brave = 8;
  Vivaldi = 9;
  Yandex = 10;
  Epic = 11;

type
  PWebUIEvent = ^TWebUIEvent;
  TWebUIEvent = record
    window: Size_t;
    event_type: Size_t;
    element: PChar;
    event_number: Size_t;
    bind_id: Size_t;
    client_id: Size_t;
    connection_id: Size_t;
    cookies: PChar;
  end;

  TWebUIBindCallback = procedure(e: PWebUIEvent); cdecl;

var
  webui_new_window: function(): Size_t; cdecl;
  webui_show: function(window: Size_t; const content: PChar): Boolean; cdecl;
  webui_show_browser: function(window: Size_t; const content: PChar; browser: Cardinal): Boolean; cdecl;
  webui_bind: function(window: Size_t; const element: PChar; func: TWebUIBindCallback): Size_t; cdecl;
  webui_wait: procedure(); cdecl;
  webui_close: procedure(window: Size_t); cdecl;
  webui_exit: procedure(); cdecl;
  webui_set_title: procedure(window: Size_t; const title: PChar); cdecl;
  webui_set_size: procedure(window: Size_t; width, height: Cardinal); cdecl;
  webui_set_position: procedure(window: Size_t; x, y: Cardinal); cdecl;
  webui_run: procedure(window: Size_t; const script: PChar); cdecl;
  webui_script: function(window: Size_t; const script: PChar; timeout: Size_t; buffer: PChar; buffer_len: Size_t): Boolean; cdecl;
  webui_set_kiosk: procedure(window: Size_t; status: Boolean); cdecl;
  webui_get_string: function(e: PWebUIEvent): PChar; cdecl;
  webui_get_int: function(e: PWebUIEvent): Int64; cdecl;
  webui_get_bool: function(e: PWebUIEvent): Boolean; cdecl;
  webui_get_size: function(e: PWebUIEvent): Size_t; cdecl;
  webui_return_string: procedure(e: PWebUIEvent; const str: PChar); cdecl;
  webui_return_int: procedure(e: PWebUIEvent; num: Int64); cdecl;
  webui_return_bool: procedure(e: PWebUIEvent; b: Boolean); cdecl;
  webui_is_shown: function(window: Size_t): Boolean; cdecl;

function InitWebUI(const LibPath: string = ''): Boolean;
procedure FreeWebUI;
function IsWebUIAvailable: Boolean;

implementation

var
  WebUILibHandle: TLibHandle = NilHandle;

function IsWebUIAvailable: Boolean;
begin
  Result := (WebUILibHandle <> NilHandle);
end;

function InitWebUI(const LibPath: string): Boolean;
var
  TargetLib: string;
  BaseDir: string;
begin
  Result := False;
  if WebUILibHandle <> NilHandle then Exit(True);

  TargetLib := LibPath;
  if TargetLib = '' then
  begin
    {$IFDEF MSWINDOWS}
    TargetLib := 'webui-2.dll';
    {$ELSE}
      {$IFDEF DARWIN}
      TargetLib := 'libwebui-2.dylib';
      {$ELSE}
      TargetLib := 'libwebui-2.so';
      {$ENDIF}
    {$ENDIF}

    if not FileExists(TargetLib) then
    begin
      BaseDir := ExtractFilePath(ParamStr(0));
      // 1. Next to executable: desktop/bin/<platform>/webui-2.dll
      if FileExists(BaseDir + TargetLib) then
        TargetLib := BaseDir + TargetLib
      // 2. Parent bin folder: desktop/bin/webui-2.dll
      else if FileExists(BaseDir + '..' + DirectorySeparator + TargetLib) then
        TargetLib := BaseDir + '..' + DirectorySeparator + TargetLib
      // 3. Desktop root folder: desktop/webui-2.dll
      else if FileExists(BaseDir + '..' + DirectorySeparator + '..' + DirectorySeparator + TargetLib) then
        TargetLib := BaseDir + '..' + DirectorySeparator + '..' + DirectorySeparator + TargetLib
      // 4. Current working directory
      else if FileExists(GetCurrentDir + DirectorySeparator + TargetLib) then
        TargetLib := GetCurrentDir + DirectorySeparator + TargetLib;
    end;
  end;

  WebUILibHandle := SafeLoadLibrary(TargetLib);
  if WebUILibHandle = NilHandle then Exit(False);

  Pointer(webui_new_window) := GetProcedureAddress(WebUILibHandle, 'webui_new_window');
  Pointer(webui_show) := GetProcedureAddress(WebUILibHandle, 'webui_show');
  Pointer(webui_show_browser) := GetProcedureAddress(WebUILibHandle, 'webui_show_browser');
  Pointer(webui_bind) := GetProcedureAddress(WebUILibHandle, 'webui_bind');
  Pointer(webui_wait) := GetProcedureAddress(WebUILibHandle, 'webui_wait');
  Pointer(webui_close) := GetProcedureAddress(WebUILibHandle, 'webui_close');
  Pointer(webui_exit) := GetProcedureAddress(WebUILibHandle, 'webui_exit');
  Pointer(webui_set_title) := GetProcedureAddress(WebUILibHandle, 'webui_set_title');
  Pointer(webui_set_size) := GetProcedureAddress(WebUILibHandle, 'webui_set_size');
  Pointer(webui_set_position) := GetProcedureAddress(WebUILibHandle, 'webui_set_position');
  Pointer(webui_run) := GetProcedureAddress(WebUILibHandle, 'webui_run');
  Pointer(webui_script) := GetProcedureAddress(WebUILibHandle, 'webui_script');
  Pointer(webui_set_kiosk) := GetProcedureAddress(WebUILibHandle, 'webui_set_kiosk');
  Pointer(webui_get_string) := GetProcedureAddress(WebUILibHandle, 'webui_get_string');
  Pointer(webui_get_int) := GetProcedureAddress(WebUILibHandle, 'webui_get_int');
  Pointer(webui_get_bool) := GetProcedureAddress(WebUILibHandle, 'webui_get_bool');
  Pointer(webui_get_size) := GetProcedureAddress(WebUILibHandle, 'webui_get_size');
  Pointer(webui_return_string) := GetProcedureAddress(WebUILibHandle, 'webui_return_string');
  Pointer(webui_return_int) := GetProcedureAddress(WebUILibHandle, 'webui_return_int');
  Pointer(webui_return_bool) := GetProcedureAddress(WebUILibHandle, 'webui_return_bool');
  Pointer(webui_is_shown) := GetProcedureAddress(WebUILibHandle, 'webui_is_shown');

  Result := Assigned(webui_new_window) and Assigned(webui_show) and Assigned(webui_wait);
end;

procedure FreeWebUI;
begin
  if WebUILibHandle <> NilHandle then
  begin
    UnloadLibrary(WebUILibHandle);
    WebUILibHandle := NilHandle;
  end;
end;

finalization
  FreeWebUI;

end.
