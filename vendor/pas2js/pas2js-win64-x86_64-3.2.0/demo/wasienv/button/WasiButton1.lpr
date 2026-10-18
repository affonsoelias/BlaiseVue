library WasiButton1;

{$mode objfpc}
{$h+}
{$codepage UTF8}

uses
  NoThreads, SysUtils, JOB.Shared, JOB_Web, JOB.JS;

type

  { TWasmApp }

  TWasmApp = class
  private
    function OnButtonClick(Event: IJSEvent): boolean;
  public
    procedure Run;
  end;

{ TApplication }

function TWasmApp.OnButtonClick(Event: IJSEvent): boolean;
begin
  writeln('TWasmApp.OnButtonClick ');
  if Event=nil then ;

  JSWindow.Alert('You triggered TWasmApp.OnButtonClick');
  Result:=true;
end;

procedure TWasmApp.Run;
var
  JSDiv: IJSHTMLDivElement;
  JSButton: IJSHTMLButtonElement;
begin
  writeln('TWasmApp.Run getElementById "playground" ...');
  // get reference of HTML element "playground" and type cast it to Div
  JSDiv:=TJSHTMLDivElement.Cast(JSDocument.getElementById('playground'));

  // create button
  writeln('TWasmApp.Run create button ...');
  JSButton:=TJSHTMLButtonElement.Cast(JSDocument.createElement('button'));
  writeln('TWasmApp.Run set button caption ...');
  JSButton.InnerHTML:='Click me!';

  // add button to div
  writeln('TWasmApp.Run add button to div ...');
  JSDiv.append(JSButton);

  // add event listener OnButtonClick
  writeln('TWasmApp.Run addEventListener OnButtonClick ...');
  JSButton.addEventListener('click',@OnButtonClick);

  writeln('TWasmApp.Run END');
end;

var
  Application: TWasmApp;
begin
  Application:=TWasmApp.Create;
  Application.Run;
end.

