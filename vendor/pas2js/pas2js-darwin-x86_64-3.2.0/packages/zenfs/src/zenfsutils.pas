unit zenfsutils;

{$mode objfpc}

interface

uses
  Classes, SysUtils, WebOrWorker, Web, JS, LibZenFS;

Type
  EHTMLTreeBuilder = class(Exception);

  TFileType = (ftUnknown,ftFile,ftDirectory,ftSymLink);
  TFileSelectedEvent = procedure(Sender : TObject; aFileName : String; aType : TFileType) of object;

  { TIconHTML }

  TIconHTML = Class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FDir: String;
    FFile: String;
    FOwner : TComponent;
    FRefresh: String;
    FSymlink: String;
    procedure SetDir(AValue: String);
    procedure SetNormalFile(AValue: String);
    procedure SetRefresh(AValue: String);
    procedure SetSymlink(AValue: String);
  protected
    constructor Create(aOwner : TComponent); virtual;
    function GetOwner: TPersistent; override;
    Procedure Changed; virtual;
    property OnChange: TNotifyEvent Read FOnChange Write FOnChange;
  public
    procedure Assign(Source: TPersistent); override;
  Published
    Property Directory : String Read FDir Write SetDir;
    Property NormalFile : String Read FFile Write SetNormalFile;
    Property Refresh : String Read FRefresh Write SetRefresh;
    Property Symlink : String Read FSymlink Write SetSymlink;
  end;

  TObjectTreeIconHTML = class(TIconHTML);

  { THTMLTreeBuilder }

  THTMLTreeBuilder = class(TObject)
  private
    FIcons: TObjectTreeIconHTML;
    FOnObjectSelect: TFileSelectedEvent;
    FParentElement: TJSHTMLElement;
    FRootDir: String;
    FRootElement : TJSHTMLElement;
    FStartCollapsed: Boolean;
    function GetItemFileName(Itm: TJSHTMLElement): string;
    function GetParentDirEl(el: TJSHTMLElement): TJSHTMLELement;
    function GetPathFromEl(el: TJSHTmlElement): String;
    procedure HandleItemCollapse(Event: TJSEvent);
    procedure HandleItemSelect(Event: TJSEvent);
    procedure SetIcons(AValue: TObjectTreeIconHTML);
    procedure SetParentElement(AValue: TJSHTMLElement);
  protected
    function CreateIcons(aOwner :TComponent) : TObjectTreeIconHTML; virtual;
  Public
    constructor Create(aOwner : TComponent);
    Destructor destroy; override;
    Function AddItem(aParent : TJSHTMLElement; aCaption : String; aType : TFileType) : TJSHTMLElement;
    Function FindObjectItem(aID : Integer) : TJSHTMLElement;
    procedure Clear;
    Property ParentElement : TJSHTMLElement Read FParentElement Write SetParentElement;
    Property OnFileSelected : TFileSelectedEvent Read FOnObjectSelect Write FOnObjectSelect;
    Property StartCollapsed : Boolean Read FStartCollapsed Write FStartCollapsed;
    Property Icons : TObjectTreeIconHTML Read FIcons Write SetIcons;
    Property RootDir : String Read FRootDir;
  end;


  Type
  TOTOption = (otShowCaption,otStartCollapsed);
  TOTOptions = set of TOTOption;

  { THTMLZenFSTree }

  THTMLZenFSTree = class(TComponent)
  private
    FBuilder: THTMLTreeBuilder;
    FCaption: String;
    FMaxHeight: String;
    FOnRefresh: TNotifyEvent;
    FOptions: TOTOptions;
    FParentElement,
    FCaptionElement : TJSHTMLElement;
    FRootDir: String;
    function GetIconHtml: TObjectTreeIconHTML;
    function GetOnObjectSelected: TFileSelectedEvent;
    function GetParentElement: TJSHTMLElement;
    function GetParentElementID: String;
    procedure HandleRefresh(aEvent: TJSEvent);
    procedure SetCaption(AValue: String);
    procedure SetIconHTML(AValue: TObjectTreeIconHTML);
    procedure SetOnObjectSelected(AValue: TFileSelectedEvent);
    procedure SetOptions(AValue: TOTOptions);
    procedure SetParentElement(AValue: TJSHTMLElement);
    procedure SetParentElementID(AValue: String);
  Protected
    function CreateBuilder: THTMLTreeBuilder; virtual;
    function BuildWrapper(aParent: TJSHTMLElement): TJSHTMLElement;
    procedure RenderCaption(aEl: TJSHTMLELement);
  Public
    Constructor Create(aOwner : TComponent); override;
    Destructor Destroy; override;
    Procedure ShowDir(aParent : TJSHTMLElement; aDir : String);
    Procedure ShowDir(aDir : String);
    Procedure Clear;
    Property ParentElement : TJSHTMLElement Read GetParentElement Write SetParentElement;
  Published
    Property ParentElementID : String Read GetParentElementID Write SetParentElementID;
    Property OnFileSelected : TFileSelectedEvent Read GetOnObjectSelected Write SetOnObjectSelected;
    Property Caption : String Read FCaption Write SetCaption;
    Property Options : TOTOptions Read FOptions Write SetOptions;
    Property OnRefresh : TNotifyEvent Read FOnRefresh Write FOnRefresh;
    Property Icons : TObjectTreeIconHTML Read GetIconHtml Write SetIconHTML;
    Property RootDir : String Read FRootDir;
    Property MaxHeight : String Read FMaxHeight Write FMaxHeight;
  end;



function base64ToBytes(str : string) : TJSuint8array;
function BytesToString(aBuffer: TJSUint8Array) : String;
function bytesToBase64(bytes : TJSUInt8Array) : String;
function base64encode(str: string) : string;
Function ReadFileAsBytes(aFileName : string) : TJSUint8Array;
Function ReadFileAsString(aFileName : string) : String;
Function CreateDataURL(aFileName,aMimeType : string) : String;
Function CreateDownLoadFromFile(const aFileName,aMimeType : string; aParent : TJSHTMLElement; const aLinkText : String) : TJSHTMLAnchorElement;
Function CreateDownLoadFromFile(const aFileName,aMimeType : string; aParent : TJSHTMLElement; const aLinkContent : TJSNode) : TJSHTMLAnchorElement;

implementation

uses math;

// uses debug.objectinspector.html;

{ TIconHTML }

procedure TIconHTML.SetDir(AValue: String);
begin
  if FDir=AValue then Exit;
  FDir:=AValue;
  Changed;
end;

procedure TIconHTML.SetNormalFile(AValue: String);
begin
  if FFIle=AValue then Exit;
  FFile:=AValue;
  Changed;
end;

procedure TIconHTML.SetRefresh(AValue: String);
begin
  if FRefresh=AValue then Exit;
  FRefresh:=AValue;
  Changed;
end;

procedure TIconHTML.SetSymlink(AValue: String);
begin
  if FSymlink=AValue then Exit;
  FSymlink:=AValue;
  Changed;
end;

const
  DefaultDirHTML = '&#x1F4C1';
  DefaultFileHTML = '&#x1F5CB;';
  DefaultRefreshHTML   = '&#x27F3;';

constructor TIconHTML.Create(aOwner: TComponent);
begin
  FOwner:=aOwner;
  FDir:=DefaultDirHTML;
  FFile:=DefaultFileHTML;
  FRefresh:=DefaultRefreshHTML;
end;

function TIconHTML.GetOwner: TPersistent;
begin
  Result:=FOwner;
end;

procedure TIconHTML.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TIconHTML.Assign(Source: TPersistent);

var
  Src : TIconHTML absolute Source;

begin
  if Source is TIconHTML then
    begin
    FFile:=Src.FFile;
    FDir:=Src.FDir;
    end
  else
    inherited Assign(Source);
end;


procedure THTMLTreeBuilder.SetParentElement(AValue: TJSHTMLElement);
begin
  if FParentElement=AValue then Exit;
  FParentElement:=AValue;
  FParentElement.innerHTML:='';
  FRootElement:=nil;
end;

constructor THTMLTreeBuilder.Create(aOwner: TComponent);
begin
  FIcons:=CreateIcons(aOwner);
end;

destructor THTMLTreeBuilder.destroy;
begin
  FreeAndNil(FIcons);
  inherited destroy;
end;

function THTMLTreeBuilder.CreateIcons(aOwner: TComponent): TObjectTreeIconHTML;
begin
  Result:=TObjectTreeIconHTML.Create(aOwner);
end;

procedure THTMLTreeBuilder.HandleItemCollapse(Event : TJSEvent);

var
  El : TJSHTMLElement;

begin
  El:=TJSHTMLElement(event.targetElement.parentElement);
  El.classList.toggle('zft-expanded');
  El.classList.toggle('zft-collapsed');
end;

function THTMLTreeBuilder.GetParentDirEl(el: TJSHTMLElement): TJSHTMLELement;

  function IsDirEl(aItem : TJSHTMLELement) : boolean;
  begin
    Result:=SameText(aItem.tagName,'li') and aItem.ClassList.contains('zft-directory');
  end;

begin
  Result:=TJSHTMLElement(El.parentElement);
  While (Result<>Nil) and Not IsDirEl(Result) do
    Result:=TJSHTMLElement(Result.parentElement);
end;

function THTMLTreeBuilder.GetItemFileName(Itm : TJSHTMLElement) : string;

var
  Cap : TJSHTMLElement;
begin
  cap:=TJSHTMLElement(Itm.querySelector(':scope > span.zft-tree-item-caption'));
  if assigned(cap) then
    Result:=cap.innertext
  else
    Result:='';
end;

function THTMLTreeBuilder.GetPathFromEl(el: TJSHTmlElement): String;


var
  Dir : TJSHTMLElement;

begin
  Result:=GetItemFileName(el);
  Dir:=GetParentDirEl(el);
  While Dir<>Nil do
    begin
    Result:=IncludeTrailingPathDelimiter(GetItemFileName(Dir))+Result;
    Dir:=GetParentDirEl(Dir);
    end;
  Result:=ExcludeTrailingPathDelimiter(RootDir)+Result
end;

procedure THTMLTreeBuilder.HandleItemSelect(Event : TJSEvent);

var
  El : TJSHTMLElement;
  lList : TJSNodeList;
  I : integer;
  fType:TFileType;

begin
  // List element
  El:=TJSHTMLElement(event.targetElement.parentElement);
  lList:=FRootElement.querySelectorAll('li.zft-selected');
  for I:=0 to lList.length-1 do
    if El<>lList.item(I) then
      TJSHtmlElement(lList.item(I)).classList.remove('zft-selected');
  El.classList.add('zft-selected');
  if Assigned(FOnObjectSelect) then
    begin
    fType:=TFileType(StrToIntDef(el.dataset['fileType'],0));
    if (fType<>ftUnknown) then
      FOnObjectSelect(Self,GetPathFromEl(el),fType);
    end;
end;

procedure THTMLTreeBuilder.SetIcons(AValue: TObjectTreeIconHTML);
begin
  if FIcons=AValue then Exit;
  FIcons.Assign(AValue);
end;



function THTMLTreeBuilder.AddItem(aParent: TJSHTMLElement; aCaption: String; aType: TFileType): TJSHTMLElement;

const
  FileTypeClassNames : Array[TFileType] of string = ('','zft-file','zft-directory','zft-symlink');

var
  CName : String;
  Icon,Span,Item,list : TJSHTMLELement;

begin
  if aParent=Nil then
    begin
    if FRootElement=Nil then
      begin
      FRootElement:=TJSHTMLElement(Document.createElement('ul'));
      FRootElement.className:='zft-tree-nested';
      FParentElement.appendChild(FRootElement);
      FRootDir:=IncludeTrailingPathDelimiter(aCaption)
      end;
    aParent:=FParentElement;
    end
  else
    begin
    if Not SameText(aParent.tagName,'li') then
      Raise EHTMLTreeBuilder.CreateFmt('Invalid parent item type: %s',[aParent.tagName]);
    if Not StartCollapsed then
      begin
      aParent.ClassList.remove('zft-collapsed');
      aParent.ClassList.add('zft-expanded');
      end;
    end;
  List:=TJSHTMLELement(aParent.querySelector('ul.zft-tree-nested'));
  if List=Nil then
    begin
    List:=TJSHTMLElement(Document.createElement('ul'));
    List.className:='zft-tree-nested';
    aParent.appendChild(List);
    end;
  Item:=TJSHTMLElement(Document.createElement('li'));
  CName:='zft-tree-item '+FileTypeClassNames[aType];
  if aType=ftDirectory then
    cName:=CName+' zft-collapsed';
  Item.className:=CName;
  Item.dataset['fileType']:=IntToStr(Ord(aType));
  Icon:=TJSHTMLElement(Document.createElement('span'));
  Case aType of
    ftDirectory: Icon.InnerHTML:=Icons.Directory;
    ftFile: Icon.InnerHTML:=Icons.NormalFile;
    ftSymLink: Icon.InnerHTML:=Icons.SymLink;
  end;
  Item.appendChild(icon);
  Span:=TJSHTMLElement(Document.createElement('span'));
  Span.InnerText:=aCaption;
  Span.className:='zft-tree-item-caption' ;
  Span.addEventListener('dblclick',@HandleItemCollapse);
  Span.addEventListener('click',@HandleItemSelect);
  Item.appendChild(Span);
  List.AppendChild(Item);
  Result:=Item;
end;

function THTMLTreeBuilder.FindObjectItem(aID: Integer): TJSHTMLElement;
begin
  Result:=TJSHTMLElement(ParentElement.querySelector('li[data-object-id="'+IntToStr(aID)+'"]'));
end;

procedure THTMLTreeBuilder.Clear;
begin
  if Assigned(FParentElement) then
    FParentElement.innerHTML:='';
  FRootElement:=Nil;
end;

{ THTMLZenFSTree }

{ THTMLZenFSTree }

function THTMLZenFSTree.GetParentElement: TJSHTMLElement;
begin
  Result:=FBuilder.ParentElement;
end;


function THTMLZenFSTree.GetOnObjectSelected: TFileSelectedEvent;
begin
  Result:=FBuilder.OnFileSelected
end;

function THTMLZenFSTree.GetIconHtml: TObjectTreeIconHTML;
begin
  Result:=FBuilder.Icons;
end;

function THTMLZenFSTree.GetParentElementID: String;
begin
  if Assigned(ParentElement) then
    Result:=ParentElement.id
  else
    Result:='';
end;

procedure THTMLZenFSTree.HandleRefresh(aEvent: TJSEvent);
var
  lRoot: String;

begin
  If Assigned(FOnRefresh) then
    FOnRefresh(Self)
  else
    begin
    lRoot:=RootDir;
    Clear;
    ShowDir(lRoot);
    end;
end;

procedure THTMLZenFSTree.SetCaption(AValue: String);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
  if Assigned(FCaption) then
    RenderCaption(FCaptionElement);
end;

procedure THTMLZenFSTree.SetIconHTML(AValue: TObjectTreeIconHTML);
begin
  FBuilder.Icons.Assign(aValue);
end;

procedure THTMLZenFSTree.SetOnObjectSelected(AValue: TFileSelectedEvent);
begin
  FBuilder.OnFileSelected:=aValue;
end;

procedure THTMLZenFSTree.SetOptions(AValue: TOTOptions);
begin
  if FOptions=AValue then Exit;
  FOptions:=AValue;
  FBuilder.StartCollapsed:=(otStartCollapsed in FOptions);
end;

procedure THTMLZenFSTree.RenderCaption(aEl : TJSHTMLELement);

begin
  aEL.InnerText:=Caption;
end;

function THTMLZenFSTree.BuildWrapper(aParent : TJSHTMLElement) : TJSHTMLElement;

var
  RI,SC,DW,DC,DT : TJSHTMLElement;

begin
  aParent.InnerHTML:='';
  DC:=TJSHTMLElement(document.createElement('div'));
  DC.className:='zft-caption';
  SC:=TJSHTMLElement(document.createElement('span'));
  DC.AppendChild(SC);
  RI:=TJSHTMLElement(document.createElement('div'));
  RI.className:='zft-icon-btn';
  RI.InnerHTML:=Icons.Refresh;
  RI.AddEventListener('click',@HandleRefresh);
  DC.AppendChild(RI);
  aParent.AppendChild(DC);
  FCaptionElement:=SC;
  if Not (otShowCaption in Options) then
    DC.classList.Add('zft-hidden');
  RenderCaption(SC);
  DT:=TJSHTMLElement(document.createElement('div'));
  DT.className:='zft-tree';
  if MaxHeight<>'' then
    begin
    DT.style.setProperty('max-height',MaxHeight);
    DT.style.setProperty('overflow','scroll');
    end;
  aParent.AppendChild(DT);
  Result:=DT;
end;

procedure THTMLZenFSTree.SetParentElement(AValue: TJSHTMLElement);
begin
  FParentElement:=aValue;
  FBuilder.ParentElement:=BuildWrapper(FParentElement);
end;

procedure THTMLZenFSTree.SetParentElementID(AValue: String);

var
  lParent : TJSHTMlelement;

begin
  lParent:=TJSHTMlelement(Document.getElementById(aValue));
  if lParent=Nil then
    Raise EHTMLTreeBuilder.CreateFmt('Unknown element id: "%s"',[aValue]);
  ParentElement:=lParent;
end;

function THTMLZenFSTree.CreateBuilder : THTMLTreeBuilder;

begin
  Result:=THTMLTreeBuilder.Create(Self);
end;

constructor THTMLZenFSTree.Create(aOwner: TComponent);

begin
  inherited Create(aOwner);
  FBuilder:=CreateBuilder;
  FOptions:=[otShowCaption];
  FCaption:='ZenFS File Tree';
end;

destructor THTMLZenFSTree.Destroy;
begin
  FreeAndNil(FBuilder);
  Inherited;
end;

procedure THTMLZenFSTree.ShowDir(aParent: TJSHTMLElement; aDir: String);

var
  ZenDir : TZenFSDir;
  Enum : TZenFSDirEnumerator;
  DirEnt : TZenFSDirEnt;
  El: TJSHTMLElement;
  FT : TFileType;

begin
  ZenDir:=ZenFS.opendirSync(aDir);
  // buggy
  TJSObject(ZenDir)['_entries']:=undefined;
  Enum:=TZenFSDirEnumerator.Create(ZenDir);
  While Enum.MoveNext do
    begin
    Dirent:=Enum.Current;
    if (Dirent.isDirectory) then
      ft:=ftDirectory
    else if Dirent.isSymbolicLink then
      ft:=ftSymLink
    else
      ft:=ftFile;
    El:=FBuilder.AddItem(aParent,Dirent.path,ft);
    if ft=ftDirectory then
      ShowDir(El,aDir+'/'+Dirent.Path);
    end;
  Enum.Free;
end;

procedure THTMLZenFSTree.ShowDir(aDir: String);

var
  El : TJSHTMLElement;

begin
  FRootDir:=aDir;
  EL:=FBuilder.AddItem(Nil,aDir,ftDirectory);
  ShowDir(El,aDir);
end;

procedure THTMLZenFSTree.Clear;
begin
  FRootDir:='';
  FBuilder.Clear;
end;


const base64abc : Array of char = (
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
	'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
	'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
	'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
);


const base64codes : Array of byte = (
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
	255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 62, 255, 255, 255, 63,
	52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 255, 255, 255, 0, 255, 255,
	255, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 255, 255, 255, 255, 255,
	255, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
);

function getBase64Code(charCode : integer) : byte;

begin
   if (charCode >= Length(base64codes)) then
     Raise EConvertError.Create('Unable to parse base64 string.');
   Result:=base64codes[charCode];
   if (Result=255) then
     Raise EConvertError.Create('Unable to parse base64 string.');
end;

function bytesToBase64(bytes : TJSUInt8Array) : String;

var
  l,I : integer;

begin
  result:='';
  l:=bytes.length;
  i:=2;
  While I<l do
    begin
    result := result+base64abc[bytes[i - 2] shr 2];
    result := result+base64abc[((bytes[i - 2] and $03) shl 4) or (bytes[i - 1] shr 4)];
    result := result+base64abc[((bytes[i - 1] and $0F) shl 2) or (bytes[i] shr 6)];
    result := result+base64abc[bytes[i] and $3F];
    inc(I,3);
    end;
   if (i=l+1) then
     begin
     result := result+base64abc[bytes[i - 2] shr 2];
     result := result+base64abc[(bytes[i - 2] and $03) shl 4];
     result := result+'==';
     end;
   if (i = l) then
     begin
     result := result+base64abc[bytes[i - 2] shr 2];
     result := result+base64abc[((bytes[i - 2] and $03) shl 4) or (bytes[i - 1] shr 4)];
     result := result+base64abc[(bytes[i - 1] and $0F) shl 2];
     result := result+'=';
     end;
end;

function base64ToBytes(str : string) : TJSuint8array;

var
  Buffer,Len,MissingOctets, Index,I,j : integer;
  S : TJSString;
  Res : TJSUint8Array;

begin
  Len:=Length(str);
  if ((len mod 4) <> 0) then
    Raise EConvertError.Create('Unable to parse base64 string');
  Index:=Pos('=',str);
  if (index=0) or (Index < Len-2) then
    Raise EConvertError.Create('Unable to parse base64 string');
  MissingOctets:=0;
  if Str[Len]='=' then
    MissingOctets:=1;
  if Str[Len-1]='=' then
    MissingOctets:=2;
  Res:=TJSUint8Array.New(3 * (Len div 4));
  i:=0;
  J:=0;
  S:=TJSString(Str);
  While I<Len do
    begin
    buffer:=(getBase64Code(S.charCodeAt(i) shl 18)) or
    	    (getBase64Code(S.charCodeAt(i) shl 12)) or
    	    (getBase64Code(S.charCodeAt(i + 2) shl 6)) or
     	    getBase64Code(S.charCodeAt(i + 3));
    res[j]:=buffer shr 16;
    res[j + 1]:=(buffer shr 8) and $FF;
    res[j + 2]:=buffer and $FF;
    Inc(I,4);
    Inc(J,3);
    end;
  if MissingOctets=0 then
    Result:=res
  else
    Result:=res.subarray(0,res.length-missingOctets);
end;


var
  Encoder : TJSTextEncoder;
  Decoder : TJSTextDecoder;

function base64encode(str: string) : string;
begin
  Result:=bytesToBase64(encoder.encode(str));
end;

function base64decode(str: string) : string;
begin
  Result:=decoder.decode(base64ToBytes(str));
end;

function BytesToString(aBuffer: TJSUint8Array) : String;
begin
  Result:=decoder.decode(aBuffer);
end;

function uint8ArrayToDataURL(aBuffer: TJSUint8Array; aMimeType : String) : String;
const
  chunksize = 8192;
var
  b2,lBase64 : String;
  i, len : integer;
  lChunk: TJSUint8Array;

begin
  result:='';
  I:=0;
  len:=aBuffer.byteLength;
  Writeln('Len:',len,' bytes');
  While I<Len do
    begin
    lchunk:=aBuffer.subarray(i, min(i + chunkSize, len));
    asm
      lBase64=String.fromCharCode.apply(null,lChunk);
    end;
    Result:=Result+lBase64;
    inc(i,ChunkSize);
    end;
  Result:=window.btoa(Result);
  Writeln('Result : ',result);
  Result:='data:'+aMimeType+';base64,' + Result;
end;

Function ReadFileAsBytes(aFileName : string) : TJSUint8Array;
var
  nRead,fd : NativeInt;
  Stat : TZenFSStats;
  aSize : NativeInt;
  V : TJSDataView;
  opts : TZenFSReadSyncOptions;

begin
  fd:=Zenfs.openSync(aFileName,'r');
  Stat:=ZenFS.FStatSync(fd);
  aSize:=Stat.size;
  Result:=TJSUint8Array.New(aSize);
  V:=TJSDataView.new(Result.buffer);
  opts:=TZenFSReadSyncOptions.new;
  opts.offset:=0;
  opts.length:=aSize;
  ZenFS.readSync(FD,V,Opts);
end;

Function ReadFileAsString(aFileName : string) : String;
begin
  Result:=BytesToString(ReadFileAsBytes(aFileName));
end;

Function CreateDataURL(aFileName : string; aMimeType : String) : String;

begin
  Result:=Uint8ArrayToDataURL(ReadFileAsBytes(aFileName),aMimeType);
end;

Function CreateDownLoadFromFile(const aFileName,aMimeType : string; aParent : TJSHTMLElement; const aLinkText : String) : TJSHTMLAnchorElement;

begin
  Result:=CreateDownLoadFromFile(aFileName,aMimeType,aParent,Document.createTextNode(aLinkText));
end;

Function CreateDownLoadFromFile(const aFileName,aMimeType : string; aParent : TJSHTMLElement; const aLinkContent : TJSNode) : TJSHTMLAnchorElement;

begin
  Result:=TJSHTMLAnchorElement(Document.createElement('a'));
  Result.AppendChild(aLinkContent);
  Result.href:=CreateDataURL(aFileName,aMimetype);
  Result.Download:=ExtractFileName(aFileName);
  aParent.AppendChild(Result);
end;

initialization
  Encoder:=TJSTextEncoder.New;
  Decoder:=TJSTextDecoder.New;
end.

