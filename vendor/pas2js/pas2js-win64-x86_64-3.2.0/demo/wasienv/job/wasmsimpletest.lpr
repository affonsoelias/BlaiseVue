library wasmsimpletest;

{$mode objfpc}
{$h+}
{$codepage UTF8}
{$WARN 5028 off : Local $1 "$2" is not used}

{off $DEFINE UseDucet}

{off $DEFINE UseDucet}
{$IFDEF FPC_DOTTEDUNITS}
uses
  {$IFDEF UseDucet}
  System.Unicode.Unicodeducet,   // first support for unicode ? 
  System.CodePages.unicodedata,    // second support for unicode
  System.FPWideString,   // support for WideString
  {$ENDIF}
  System.Math,           // math support
  System.SysUtils, 
  System.Variants,
  Wasm.Job.Shared,     // free pascal unit
  Wasm.Job.Js         // free pascal unit
  ;
{$ELSE}
uses
 {$IFDEF UseDucet}
  unicodeducet,   // first support for unicode ? 
  unicodedata,    // second support for unicode
  fpwidestring,   // support for WideString
   {$ENDIF}
  Math,           // math support
  SysUtils,
  Variants,
  Job.Shared,     // free pascal unit
  Job.Js,         // free pascal unit
  JOB_Web        // generated from the BrowerTixeoDom.lpr + job_shared.pp + job_browser.pp
  ;
{$ENDIF}

type
  EWasiTest = class(Exception);

  IJSTestObj = Interface (IJSObject) ['{DE03E9A4-3960-4090-A3FA-387B61E8AEA9}']
    function GetStringAttr : UnicodeString;
    procedure SetStringAttr(const aValue : UnicodeString);
    property StringAttr : Unicodestring Read GetStringAttr Write SetStringAttr;
  end;

  { TTestObj }
  // Creates directly a TJSObject
  TTestObj = Class(TJSObject,IJSTestObj)
    constructor Create;
    function GetStringAttr : UnicodeString;
    procedure SetStringAttr(const aValue : UnicodeString);
    property StringAttr : Unicodestring Read GetStringAttr Write SetStringAttr;
  end;

  { TMyTestObj }

  // Creates a MyObject, using a factory
  TMyTestObj = Class(TJSObject,IJSTestObj)
    constructor Create(a: String);
    class function JSClassName: UnicodeString; override;
    function GetStringAttr : UnicodeString;
    procedure SetStringAttr(const aValue : UnicodeString);
    property StringAttr : Unicodestring Read GetStringAttr Write SetStringAttr;
  end;

  // Creates a BrowserObject, using a factory

  { TBrowserObj }

  TBrowserObj = Class(TJSObject,IJSTestObj)
    constructor Create(a: String);
    class function JSClassName: UnicodeString; override;
    function GetStringAttr : UnicodeString;
    procedure SetStringAttr(const aValue : UnicodeString);
    property StringAttr : Unicodestring Read GetStringAttr Write SetStringAttr;
  end;



// TWASMAPP CLASS DEFINITION
  TWasmApp = class
  private
    procedure DoTest;
    procedure DoTest2;
    procedure DoTest3;
    procedure Header(const aHeader : String);
  public
    procedure Run;
    procedure Fail(const Msg: string);
  public

  end;

{ TBrowserObj }

constructor TBrowserObj.Create(a: String);
begin
  Inherited JOBCreate([a]);
end;

class function TBrowserObj.JSClassName: UnicodeString;
begin
  Result:='MyBrowserObject';
end;

function TBrowserObj.GetStringAttr: UnicodeString;
begin
  Result:=ReadJSPropertyUnicodeString('Aloha');
end;

procedure TBrowserObj.SetStringAttr(const aValue: UnicodeString);
begin
  WriteJSPropertyUnicodeString('Aloha',aValue);
end;

constructor TMyTestObj.Create(a: String);
begin
  Inherited JobCreate([a]);
end;

Class function TMyTestObj.JSClassName: UnicodeString;
begin
  Result:='MyObject';
end;

function TMyTestObj.GetStringAttr: UnicodeString;
begin
  Result:=ReadJSPropertyUnicodeString('fa');
end;

procedure TMyTestObj.SetStringAttr(const aValue: UnicodeString);
begin
  WriteJSPropertyUnicodeString('fa',aValue);
end;

{ TTestObj }

constructor TTestObj.Create;

begin
  Inherited JOBCreate([]);
  StringAttr:='Created';
end;

function TTestObj.GetStringAttr: UnicodeString;
begin
  Result:=ReadJSPropertyUnicodeString('Aloha')
end;

procedure TTestObj.SetStringAttr(const aValue: UnicodeString);
begin
  WriteJSPropertyUnicodeString('Aloha',aValue);
end;

{ TApplication }

procedure TWasmApp.Fail(const Msg: string);
begin
  writeln('TWasmApp.Fail ',Msg);
  raise EWasiTest.Create(Msg);
end;

procedure TWasmApp.Header(const aHeader : String);

var
  Len : Integer;

begin
  Len:=50;
  If Length(aHeader)>Len then
    Len:=Length(aHeader);
  Writeln(StringOfChar('-',Len));
  Writeln(aHeader);
  Writeln(StringOfChar('-',Len));
end;

procedure TWasmApp.DoTest;

var
  T : IJSTestObj;

begin
  Header('Test 1');
  Writeln('Creating TTestObj object');
  T:=TTestObj.Create;
  Writeln('Property Aloha: ',T.StringAttr);
end;

procedure TWasmApp.DoTest2;

var
  T : IJSTestObj;

begin
  Header('Test 2');
  Writeln('Creating TMyTestObj object');
  T:=TMyTestObj.Create('solo');
  Writeln('Property : ',T.StringAttr);
end;

procedure TWasmApp.DoTest3;

var
  T : IJSTestObj;

begin
  Header('Test 3');
  Writeln('Creating TBrowserObj object');
  T:=TBrowserObj.Create('Nice one!');
  Writeln('Property : ',T.StringAttr);
end;



procedure TWasmApp.Run;

begin
  DoTest;
  DoTest2;
  DoTest3;
end;

// workaround: fpc wasm does not yet support exporting functions from units
function JOBCallback(const Func: TJOBCallback; Data, Code: Pointer; Args: pbyte) : pbyte;
begin
  Result := {$IFDEF FPC_DOTTEDUNITS}Wasm.{$ENDIF}Job.Js.JOBCallback(Func, Data, Code, Args);
end;

exports
  JOBCallback;

var
  Application: TWasmApp;
begin
  {$IFDEF UseDucet}
  SetActiveCollation('DUCET');
  {$ENDIF}
  Application:=TWasmApp.Create;
  Application.Run;
end.
