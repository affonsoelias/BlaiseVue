library wasmdemo;

{$mode objfpc}{$H+}

uses
  Classes,
  job.js,
  job_web;

Type

  { TApplication }

  TApplication = class(TComponent)
    Procedure Run;
  private
    function HandleClick(event: IJSEvent): Variant;
  end;

{ TApplication }

procedure TApplication.Run;

var
  EL : IJSElement;
  HTMLEl : IJSHtmlElement;

begin
  El:=JSDocument.getelementbyid('btnOK');
  HTMLEl:=TJSHTMLELement.Cast(El);
  HTMLEl.OnClick:=@HandleClick;
end;

function TApplication.HandleClick(event: IJSEvent): Variant;
begin
  Writeln('Here in webassembly handleclick');
  Result:=UnAssigned;
  JSWindow.alert('You clicked the button.');
end;


begin
  With TApplication.Create(nil) do
    Run;
end.

