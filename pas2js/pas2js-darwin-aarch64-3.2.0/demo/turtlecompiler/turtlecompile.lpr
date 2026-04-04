program turtlecompile;

{$mode objfpc}

uses
  Math, Classes, SysUtils, browserapp, Web, webfilecache, pas2jswebcompiler;

Type

  { TWebCompilerDemo }

  TWebCompilerDemo = Class(TBrowserApplication)
  Private
    btnCloseNotification,
    BRun : TJSHTMLButtonElement;
    MSource : TJSHTMLTextAreaElement;
    MLog: TJSHTMLElement;
    pnlLog : TJSHTMLElement;
    RFrame : TJSHTMLIFrameElement;
    FCompiler : TPas2JSWebCompiler;
    procedure ClearResult;
    procedure DoLog(Sender: TObject; const Msg: String);
    function HideNotification(aEvent: TJSMouseEvent): boolean;
    procedure LogError(const aMsg: string);
    procedure OnUnitsLoaded(Sender: TObject; aFileName: String; aError: string);
    function Prepare(aSource: string): string;
    function RunClick(aEvent: TJSMouseEvent): boolean;
    procedure RunResult;
  Protected
    function CompileClick(aEvent: TJSMouseEvent): boolean;
    Procedure LinkElements;
    Property Compiler : TPas2JSWebCompiler Read FCompiler;
  Public
    Constructor Create(aOwner : TComponent); override;
    Procedure Execute;
  end;

Const
  // Default run HTML page, shown in IFrame.

  SHTMLHead =
    '<HTML>'+LineEnding+
    '<head>'+LineEnding+
    '  <meta charset="UTF-8">'+LineEnding+
    '  <Title>Pas2JS Turtle graphics program output</Title>'+LineEnding+
    '  <script type="application/javascript">'+LineEnding;

  SHTMLTail =
    '   </script>'+LineEnding+
    '  <link href="bulma.min.css" rel="stylesheet">'+LineEnding+
    '</head>'+LineEnding+
    '<body>'+LineEnding+
    '  <div class="container is-fluid">'+LineEnding+
    '    <div class="box">'+LineEnding+
    '      <h1 class="is-title">Run program output</h1>'+LineEnding+
    '      <div class="block" style="min-height: 75hv;">'+LineEnding+
    '        <canvas id="cnvTurtle" style="width: 100%; height: 100%;"></canvas>'+LineEnding+
    '      </div> <!-- .block --> '+LineEnding+
    '    </div> <!-- .box -->'+LineEnding+
    '  </div> <!-- .container -->'+LineEnding+
    '<script>'+LineEnding+
    '  rtl.run();'+LineEnding+
    '</script>'+LineEnding+
    '</body>'+LineEnding+
    '</HTML>';


{ TWebCompilerDemo }

procedure TWebCompilerDemo.LogError(const aMsg : string);

begin
  MLog.InnerText:=aMsg;
  pnlLog.classList.remove('is-hidden');
end;

procedure TWebCompilerDemo.OnUnitsLoaded(Sender: TObject; aFileName: String; aError: string);
begin
  BRun.classList.remove('is-loading');
  if aError='' then
    BRun.disabled:=False
  else
    begin
    LogError('Error Loading "'+aFileName+'": '+AError);
    end;
end;

procedure TWebCompilerDemo.LinkElements;
begin
  BRun:=TJSHTMLButtonElement(GetHTMLElement('btnRun'));
  BRun.onClick:=@CompileClick;
  btnCloseNotification:=TJSHTMLButtonElement(GetHTMLElement('btnCloseNotification'));
  btnCloseNotification.onClick:=@HideNotification;
  MSource:=TJSHTMLTextAreaElement(GetHTMLElement('memSource'));
  MLog:=GetHTMLElement('lblCompilerOutput');
  pnlLog:=GetHTMLElement('pnlLog');
  RFrame:=TJSHTMLIFrameElement(Document.getElementById('runarea'));
end;

constructor TWebCompilerDemo.Create(aOwner : TComponent);
begin
  Inherited;
  FCompiler:=TPas2JSWebCompiler.Create;
  Compiler.Log.OnLog:=@DoLog;
end;

function TWebCompilerDemo.RunClick(aEvent: TJSMouseEvent): boolean;

Var
  Src : String;

begin
  Result:=True;
end;

procedure TWebCompilerDemo.DoLog(Sender: TObject; const Msg: String);
begin
  MLog.InnerHTML:=MLog.InnerHTML+'<BR>'+Msg;
end;

function TWebCompilerDemo.HideNotification(aEvent: TJSMouseEvent): boolean;
begin
  pnlLog.classList.Add('is-hidden');
end;


Procedure TWebCompilerDemo.ClearResult;

begin
end;

function TWebCompilerDemo.Prepare(aSource : string) : string;

var
  Src,un : String;
  p, pu, pp, ps : Integer;
  doinsert,withcomma : boolean;

begin
  Result:=aSource;
  Src:=LowerCase(aSource);
  p:=pos('begin',Src);
  p:=Min(P,pos('function ',Src));
  p:=Min(P,pos('procedure ',Src));
  doinsert:=true;
  withcomma:=false;
  pu:=Pos('uses',Src);
  // No uses
  if (pu=0) then
    begin
    pp:=pos('program',src);
    if pp=0 then
      pu:=1
    else
      pu:=pos(';',Src,pp+6)+1;
    System.Insert(#10'uses  ;',result,pu);
    pu:=pu+6;
    end
  else
    begin
    pu:=pu+5;
    ps:=pos(';',Src,pu);
    if pos('turtlegraphics',Src,pu)<ps then
      doinsert:=False;
    withcomma:=true;
    end;
  if doInsert then
    begin
    un:=' turtlegraphics';
    if Withcomma then
      un:=un+', ';
    System.insert(un,result,pu);
    end;
   Writeln('Final code : ',Result);
end;

Procedure TWebCompilerDemo.RunResult;

var
  Src : String;

begin
  Src:=Compiler.WebFS.GetFileContent('main.js');
  if Src='' then
    begin
    Window.Alert('No source available');
    exit;
    end;
  Src:=SHTMLHead+Src+LineEnding+SHTMLTail;
  RFrame['srcdoc']:=Src;
end;

function TWebCompilerDemo.CompileClick(aEvent: TJSMouseEvent): boolean;

  Procedure ShowResult(success : boolean);

  begin
    ClearResult;
    BRun.classList.remove('is-loading');
    if not Success then
      pnlLog.classList.remove('is-hidden');
    BRun.Disabled:=False;
  end;

Var
  args : TStrings;
  Res : Boolean;

begin
  Result:=False;
  BRun.classList.add('is-loading');
  //  BRun.disabled:=True;
  ClearResult;
  MLog.InnerHTML:='';
  Compiler.WebFS.SetFileContent('main.pp',Prepare(MSource.value));
  args:=TStringList.Create;
  try
    Args.Add('-Tbrowser');
    Args.Add('-Jc');
    Args.Add('-Jirtl.js');
    Args.Add('main.pp');
    RFrame.Src:='run.html';
    Compiler.Run('','',Args,True);
    Res:=Compiler.ExitCode=0;
    ShowResult(Res);
    if Res then
    RunResult;
  finally
   Args.Free;
  end;
end;

procedure TWebCompilerDemo.Execute;
begin
  LinkElements;
  Compiler.WebFS.LoadBaseURL:='sources';
  BRun.classList.add('is-loading');
  Compiler.WebFS.LoadFiles(['rtl.js','system.pas','p2jsres.pas','sysutils.pas','types.pas','typinfo.pas','classes.pas','rtlconsts.pas','js.pas','simplelinkedlist.pas','web.pas','weborworker.pas','browserconsole.pas','turtlegraphics.pas'],@OnUnitsLoaded);

end;

begin
  With TWebCompilerDemo.Create(Nil) do
    Execute;
end.
