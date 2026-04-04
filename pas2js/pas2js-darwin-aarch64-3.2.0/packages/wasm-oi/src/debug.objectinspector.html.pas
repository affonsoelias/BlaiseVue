{
    This file is part of the Pas2JS run time library.
    Copyright (c) 2024 by the Pas2JS development team.

    API to implement an object inspector in HTML
    
    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

unit debug.objectinspector.html;

{$mode ObjFPC}
{$modeswitch advancedrecords}

interface

uses
  typinfo, Classes, SysUtils, Web, rtti;

Type
  EHTMLTreeBuilder = class(Exception);

  { THTMLTreeBuilder }
  TObjectSelectedEvent = procedure(Sender : TObject; aObjectId : Integer) of object;

  TMemberVisibilities = Set of TMemberVisibility;

const
  AllMemberVisibilities = [low(TMemberVisibility)..High(TMemberVisibility)];
  DefaultRefreshHTML   = '&#x27F3;';
  DefaultDetailsHTML   = '&#x2026;'; // '&#x27A1;';
  DefaultConfigureHTML = '&#x2699;';
  DefaultBackHTML      = '&#x21E0;';    // '&#x2B05';
  DefaultCollapseHTML  = '&#x25B4;';

type

  { TIconHTML }

  TIconHTML = Class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FRefresh: String;
    FOwner : TComponent;
    procedure SetRefresh(AValue: String);
  protected
    constructor Create(aOwner : TComponent); virtual;
    function GetOwner: TPersistent; override;
    Procedure Changed; virtual;
    property OnChange: TNotifyEvent Read FOnChange Write FOnChange;
  public
    procedure Assign(Source: TPersistent); override;
  Published
    Property Refresh : String Read FRefresh Write SetRefresh;
  end;

  TObjectTreeIconHTML = class(TIconHTML);


  THTMLTreeBuilder = class(TObject)
  private
    FIcons: TObjectTreeIconHTML;
    FOnObjectSelect: TObjectSelectedEvent;
    FParentElement: TJSHTMLElement;
    FRootElement : TJSHTMLElement;
    FStartCollapsed: Boolean;
    procedure HandleItemCollapse(Event: TJSEvent);
    procedure HandleItemSelect(Event: TJSEvent);
    procedure SetIcons(AValue: TObjectTreeIconHTML);
    procedure SetParentElement(AValue: TJSHTMLElement);
  protected
    function CreateIcons(aOwner :TComponent) : TObjectTreeIconHTML; virtual;
  Public
    constructor Create(aOwner : TComponent);
    Destructor destroy; override;
    Function AddItem(aParent : TJSHTMLElement; aCaption : String; aID : Integer) : TJSHTMLElement;
    Function FindObjectItem(aID : Integer) : TJSHTMLElement;
    procedure Clear;
    Property ParentElement : TJSHTMLElement Read FParentElement Write SetParentElement;
    Property OnObjectSelected : TObjectSelectedEvent Read FOnObjectSelect Write FOnObjectSelect;
    Property StartCollapsed : Boolean Read FStartCollapsed Write FStartCollapsed;
    Property Icons : TObjectTreeIconHTML Read FIcons Write SetIcons;
  end;

  { THTMLObjectTree }
  TOTOption = (otShowCaption,otStartCollapsed);
  TOTOptions = set of TOTOption;

  THTMLObjectTree = class(TComponent)
  private
    FBuilder: THTMLTreeBuilder;
    FCaption: String;
    FOnRefresh: TNotifyEvent;
    FOptions: TOTOptions;
    FParentElement,
    FCaptionElement : TJSHTMLElement;
    FRootObjectID: Integer;
    function GetIconHtml: TObjectTreeIconHTML;
    function GetOnObjectSelected: TObjectSelectedEvent;
    function GetParentElement: TJSHTMLElement;
    function GetParentElementID: String;
    procedure HandleRefresh(aEvent: TJSEvent);
    procedure SetCaption(AValue: String);
    procedure SetIconHTML(AValue: TObjectTreeIconHTML);
    procedure SetOnObjectSelected(AValue: TObjectSelectedEvent);
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
    Procedure AddObject(aID : integer; const aClassName,aCaption : String); overload;
    Procedure AddObject(AParentID,aID : integer; const aClassName,aCaption : String); overload;
    Procedure Clear;
    Property ParentElement : TJSHTMLElement Read GetParentElement Write SetParentElement;
  Published
    Property ParentElementID : String Read GetParentElementID Write SetParentElementID;
    Property OnObjectSelected : TObjectSelectedEvent Read GetOnObjectSelected Write SetOnObjectSelected;
    Property Caption : String Read FCaption Write SetCaption;
    Property Options : TOTOptions Read FOptions Write SetOptions;
    Property OnRefresh : TNotifyEvent Read FOnRefresh Write FOnRefresh;
    Property Icons : TObjectTreeIconHTML Read GetIconHtml Write SetIconHTML;
    Property RootObjectID : Integer Read FRootObjectID;
  end;

  { TPropertyInspectorIconHTML }

  TPropertyInspectorIconHTML = class(TIconHTML)
  private
    FBack: String;
    FCollapse: String;
    FConfigure: String;
    FDetails: String;
    procedure SetBack(AValue: String);
    procedure SetCollapse(AValue: String);
    procedure SetConfigure(AValue: String);
    procedure SetDetails(AValue: String);
  Public
    constructor Create(aOwner : TComponent); override;
    procedure Assign(Source: TPersistent); override;
  Published
    Property Configure : String Read FConfigure Write SetConfigure;
    Property Back : String Read FBack Write SetBack;
    Property Details : String Read FDetails Write SetDetails;
    Property Collapse : String Read FCollapse Write SetCollapse;
  end;


  TPropDataFlag = (pdfNoValue,pdfError);
  TPropDataFlags = Set of TPropDataFlag;
  TOIPropData = record
    ObjectID : Longint;
    Index : Integer;
    Visibility : TMembervisibility;
    Kind : TTypeKind;
    Flags : TPropDataFlags;
    Name : String;
    Value : String;
    ValueObjectID : Longint;
  end;

  TOIColumn = (ocName,ocValue,ocKind,ocVisibility);
  TOIColumns = set of TOIColumn;

  TOIOption = (ooHidePropertiesWithoutValue,ooShowCaption,ooShowConfigPanel);
  TOIOptions = set of TOIOption;

  TInspectorObject = record
    Caption : String;
    ObjectID : Integer;
  end;

  { TInspectorObjectStack }

  TInspectorObjectStack = record
  Public
    const
      ArrayDelta = 10;
  private
    Objects: Array of TInspectorObject;
    Count : Integer;
    function GetCurrent: TInspectorObject;
    function GetFullCaption: String;
    function GetIsEmpty: Boolean;
  public
    constructor Create(initialSize : Integer);
    Procedure Clear;
    procedure Push(aObj : TInspectorObject);
    procedure SetCurrentObjectID(aObjectID : Integer);
    procedure SetCurrentCaption(aCaption : string);
    function Pop : TInspectorObject;
    property IsEmpty : Boolean Read GetIsEmpty;
    property Current : TInspectorObject read GetCurrent;
    property FUllCaption : String Read GetFullCaption;
  end;


  { THTMLObjectInspector }

  TBeforeAddPropertyEvent = procedure (Sender : TObject; aData : TOIPropData; var aAllow : Boolean) of object;
  TAfterAddPropertyEvent = procedure (Sender : TObject; aData : TOIPropData) of object;


  THTMLObjectInspector = class(TComponent)
  private
    FAfterAddProperty: TAfterAddPropertyEvent;
    FBeforeAddProperty: TBeforeAddPropertyEvent;
    FBorder: Boolean;
    FIcons: TPropertyInspectorIconHTML;
    FOnRefresh: TNotifyEvent;
    FOnRefreshObject: TNotifyEvent;
    FOptions: TOIOptions;
    FPropertyVisibilities: TMemberVisibilities;
    FSuffix: String;
    FVisibleColumns: TOIColumns;
    FParentElement : TJSHTMLElement;
    FTableElement : TJSHTMLTableElement;
    FCaptionElement : TJSHTMLElement;
    FConfigPanel : TJSHTMLElement;
    FWrapperElement : TJSHTMLElement;
    FProperties : Array of TOIPropData;
    FObjectStack : TInspectorObjectStack;
    FFullCaption : String;
    FBackElement : TJSHTMLElement;
    function GetFullCaption: String;
    function GetObjectCaption: String;
    function GetObjectID: integer;
    function GetParentElement: TJSHTMLElement;
    function GetParentElementID: String;
    procedure RenderCaption;
    procedure SetBorder(AValue: Boolean);
    procedure SetFullCaption(AValue: String);
    procedure SetIcons(AValue: TPropertyInspectorIconHTML);
    procedure SetObjectCaption(AValue: String);
    procedure SetOptions(AValue: TOIOptions);
    procedure SetPropertyVisibilities(AValue: TMemberVisibilities);
    procedure SetVisibleColumns(AValue: TOIColumns);
    procedure SetParentElementID(AValue: String);
    procedure ToggleConfig(aEvent: TJSEvent);
  protected
    procedure DisplayChanged;
    procedure Refresh; virtual; // Display only
    procedure RefreshObject; virtual; // Object only
    function CreateIcons: TPropertyInspectorIconHTML; virtual;
    function AppendEl(aParent: TJSHTMLElement; aTag: String; const aID: String; const aInnerText: String=''): TJSHTMLElement;
    function AppendSpan(aParent: TJSHTMLElement; const aInnerText: String=''): TJSHTMLElement;
    function CreateEl(aTag: String; const aID: String; const aInnerText: String=''): TJSHTMLElement;
    function CreateCaption(aParent: TJSHTMLElement): TJSHTMLElement; virtual;
    function CreateWrapper(aParent: TJSHTMLElement): TJSHTMLElement; virtual;
    function CreateConfigPanel() : TJSHTMLElement; virtual;
    function CreateTable(aParent : TJSHTMLElement) : TJSHTMLTableElement; virtual;
    procedure SetObjectID(AValue: integer); virtual;
    procedure SetParentElement(AValue: TJSHTMLElement);virtual;
    function CreateKindCell(aPropData: TOIPropData; const aKindName: String): TJSHTMLTableCellElement; virtual;
    function CreateNameCell(aPropData: TOIPropData): TJSHTMLTableCellElement; virtual;
    function CreateValueCell(aPropData: TOIPropData; const aKindName: string): TJSHTMLTableCellElement; virtual;
    function CreateVisibilityCell(aPropData: TOIPropData): TJSHTMLTableCellElement; virtual;
    // Various event handlers
    procedure HandleBack(aEvent: TJSHTMLElement); virtual;
    procedure HandleColumnVisibility(aEvent: TJSEvent); virtual;
    procedure HandleOptionsClick(aEvent: TJSEvent); virtual;
    procedure HandlePropertyDetails(aEvent: TJSEvent); virtual;
    procedure HandlePropertyVisibility(aEvent: TJSEvent); virtual;
    procedure HandleRefresh(aEvent: TJSHTMLElement); virtual;
    function ShowProperty(aPropData: TOIPropData): boolean; virtual;
    procedure DoAddProperty(aPropData: TOIPropData); virtual;
    procedure PushObject(aObjectID : Integer; const aCaption : String);
    function PopObject : Integer;
  Public
    constructor Create(aOwner : TComponent); override;
    destructor destroy; override;
    procedure Clear(ClearData : Boolean = true);
    procedure AddProperty(aIndex : Integer; aVisibility : TMemberVisibility; aKind : TTypeKind; aFlags : TPropDataFlags; const aName,aValue : String);
    procedure AddProperty(aPropData: TOIPropData);
    Property ParentElement : TJSHTMLElement Read GetParentElement Write SetParentElement;
    Property Suffix : String Read FSuffix Write FSuffix;
  Published
    Property ObjectID : integer Read GetObjectID Write SetObjectID;
    Property ParentElementID : String Read GetParentElementID Write SetParentElementID;
    Property Border : Boolean Read FBorder Write SetBorder;
    property VisibleColumns : TOIColumns read FVisibleColumns write SetVisibleColumns;
    property PropertyVisibilities : TMemberVisibilities Read FPropertyVisibilities Write SetPropertyVisibilities;
    Property Options : TOIOptions Read FOptions Write SetOptions;
    property BeforeAddProperty : TBeforeAddPropertyEvent Read FBeforeAddProperty Write FBeforeAddProperty;
    property AfterAddProperty : TAfterAddPropertyEvent Read FAfterAddProperty Write FAfterAddProperty;
    property OnRefresh : TNotifyEvent Read FOnRefresh write FOnRefresh;
    property OnRefreshObject : TNotifyEvent Read FOnRefreshObject write FOnRefreshObject;
    Property FullCaption : String Read GetFullCaption Write SetFullCaption;
    Property ObjectCaption : String Read GetObjectCaption Write SetObjectCaption;
    Property Icons : TPropertyInspectorIconHTML Read FIcons Write SetIcons;
  end;


implementation

uses js;

const
  VisibilityNames : Array[TMemberVisibility] of string = ('Private','Protected','Public','Published');

{ TIconHTML }

procedure TIconHTML.SetRefresh(AValue: String);
begin
  if FRefresh=AValue then Exit;
  FRefresh:=AValue;
  Changed;
end;

constructor TIconHTML.Create(aOwner: TComponent);
begin
  FOwner:=aOwner;
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
    FRefresh:=Src.Refresh;
    end
  else
    inherited Assign(Source);
end;


{ THTMLTreeBuilder }

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
  El.classList.toggle('ot-expanded');
  El.classList.toggle('ot-collapsed');
end;

procedure THTMLTreeBuilder.HandleItemSelect(Event : TJSEvent);

var
  El : TJSHTMLElement;
  lList : TJSNodeList;
  lSelectID,I : integer;

begin
  // List element
  El:=TJSHTMLElement(event.targetElement.parentElement);
  lList:=FRootElement.querySelectorAll('li.ot-selected');
  for I:=0 to lList.length-1 do
    if El<>lList.item(I) then
      TJSHtmlElement(lList.item(I)).classList.remove('ot-selected');
  El.classList.add('ot-selected');
  if Assigned(FOnObjectSelect) then
    begin
    lSelectID:=StrToIntDef(el.dataset['objectId'],-1);
    if (lSelectID<>-1) then
      FOnObjectSelect(Self,lSelectID);
    end;
end;

procedure THTMLTreeBuilder.SetIcons(AValue: TObjectTreeIconHTML);
begin
  if FIcons=AValue then Exit;
  FIcons.Assign(AValue);
end;



function THTMLTreeBuilder.AddItem(aParent: TJSHTMLElement; aCaption: String; aID: Integer): TJSHTMLElement;

var
  Span,Item,list : TJSHTMLELement;

begin
  if aParent=Nil then
    begin
    if FRootElement=Nil then
      begin
      FRootElement:=TJSHTMLElement(Document.createElement('ul'));
      FRootElement.className:='ot-tree-nested';
      FParentElement.appendChild(FRootElement);
      end;
    aParent:=FParentElement;
    end
  else
    begin
    if Not SameText(aParent.tagName,'li') then
      Raise EHTMLTreeBuilder.CreateFmt('Invalid parent item type: %s',[aParent.tagName]);
    if Not StartCollapsed then
      begin
      aParent.ClassList.remove('ot-collapsed');
      aParent.ClassList.add('ot-expanded');
      end;
    end;
  List:=TJSHTMLELement(aParent.querySelector('ul.ot-tree-nested'));
  if List=Nil then
    begin
    List:=TJSHTMLElement(Document.createElement('ul'));
    List.className:='ot-tree-nested';
    aParent.appendChild(List);
    end;
  Item:=TJSHTMLElement(Document.createElement('li'));
  Item.className:='ot-tree-item ot-collapsed';
  Item.dataset['objectId']:=IntToStr(aID);
  Span:=TJSHTMLElement(Document.createElement('span'));
  Span.InnerText:=aCaption;
  Span.className:='ot-tree-item-caption' ;
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

{ THTMLObjectTree }

function THTMLObjectTree.GetParentElement: TJSHTMLElement;
begin
  Result:=FBuilder.ParentElement;
end;


function THTMLObjectTree.GetOnObjectSelected: TObjectSelectedEvent;
begin
  Result:=FBuilder.OnObjectSelected
end;

function THTMLObjectTree.GetIconHtml: TObjectTreeIconHTML;
begin
  Result:=FBuilder.Icons;
end;

function THTMLObjectTree.GetParentElementID: String;
begin
  if Assigned(ParentElement) then
    Result:=ParentElement.id
  else
    Result:='';
end;

procedure THTMLObjectTree.HandleRefresh(aEvent: TJSEvent);
begin
  If Assigned(FOnRefresh) then
    FOnRefresh(Self);
end;

procedure THTMLObjectTree.SetCaption(AValue: String);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
  if Assigned(FCaption) then
    RenderCaption(FCaptionElement);
end;

procedure THTMLObjectTree.SetIconHTML(AValue: TObjectTreeIconHTML);
begin
  FBuilder.Icons.Assign(aValue);
end;

procedure THTMLObjectTree.SetOnObjectSelected(AValue: TObjectSelectedEvent);
begin
  FBuilder.OnObjectSelected:=aValue;
end;

procedure THTMLObjectTree.SetOptions(AValue: TOTOptions);
begin
  if FOptions=AValue then Exit;
  FOptions:=AValue;
  FBuilder.StartCollapsed:=(otStartCollapsed in FOptions);
end;

procedure THTMLObjectTree.RenderCaption(aEl : TJSHTMLELement);

begin
  aEL.InnerText:=Caption;
end;

function THTMLObjectTree.BuildWrapper(aParent : TJSHTMLElement) : TJSHTMLElement;

var
  RI,SC,DC,DT : TJSHTMLElement;

begin
  aParent.InnerHTML:='';
  DC:=TJSHTMLElement(document.createElement('div'));
  DC.className:='ot-caption';
  SC:=TJSHTMLElement(document.createElement('span'));
  DC.AppendChild(SC);
  RI:=TJSHTMLElement(document.createElement('div'));
  RI.className:='ot-icon-btn';
  RI.InnerHTML:=Icons.Refresh;
  RI.AddEventListener('click',@HandleRefresh);
  DC.AppendChild(RI);
  aParent.AppendChild(DC);
  FCaptionElement:=SC;
  if Not (otShowCaption in Options) then
    DC.classList.Add('ot-hidden');
  RenderCaption(SC);
  DT:=TJSHTMLElement(document.createElement('div'));
  DT.className:='ot-tree';
  aParent.AppendChild(DT);
  Result:=DT;
end;

procedure THTMLObjectTree.SetParentElement(AValue: TJSHTMLElement);
begin
  FParentElement:=aValue;
  FBuilder.ParentElement:=BuildWrapper(FParentElement);
end;

procedure THTMLObjectTree.SetParentElementID(AValue: String);

var
  lParent : TJSHTMlelement;

begin
  lParent:=TJSHTMlelement(Document.getElementById(aValue));
  if lParent=Nil then
    Raise EHTMLTreeBuilder.CreateFmt('Unknown element id: "%s"',[aValue]);
  ParentElement:=lParent;
end;

function THTMLObjectTree.CreateBuilder : THTMLTreeBuilder;

begin
  Result:=THTMLTreeBuilder.Create(Self);
end;

constructor THTMLObjectTree.Create(aOwner: TComponent);

begin
  inherited Create(aOwner);
  FBuilder:=CreateBuilder;
  FOptions:=[otShowCaption];
  FCaption:='Object Tree';
end;

destructor THTMLObjectTree.Destroy;
begin
  FreeAndNil(FBuilder);
  Inherited;
end;

procedure THTMLObjectTree.AddObject(aID: integer; const aClassName, aCaption: String);

begin
  AddObject(0,aID,aClassName,aCaption);
end;

procedure THTMLObjectTree.AddObject(AParentID, aID: integer; const aClassName, aCaption: String);

var
  lParent : TJSHTMLELement;

begin
  if aParentID<>0 then
    lParent:=FBuilder.FindObjectItem(aParentID)
  else
    begin
    lParent:=Nil;
    FRootObjectID:=AID;
    if aClassName<>'' then ;
    end;
  FBuilder.AddItem(lParent,aCaption,aID);
end;

procedure THTMLObjectTree.Clear;
begin
  FRootObjectID:=0;
  FBuilder.Clear;
end;

{ TPropertyInspectorIconHTML }

procedure TPropertyInspectorIconHTML.SetBack(AValue: String);
begin
  if FBack=AValue then Exit;
  FBack:=AValue;
  Changed;
end;

procedure TPropertyInspectorIconHTML.SetCollapse(AValue: String);
begin
  if FCollapse=AValue then Exit;
  FCollapse:=AValue;
  Changed;
end;

procedure TPropertyInspectorIconHTML.SetConfigure(AValue: String);
begin
  if FConfigure=AValue then Exit;
  FConfigure:=AValue;
  Changed;
end;

procedure TPropertyInspectorIconHTML.SetDetails(AValue: String);
begin
  if FDetails=AValue then Exit;
  FDetails:=AValue;
  Changed;
end;

constructor TPropertyInspectorIconHTML.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FDetails:=DefaultDetailsHTML;
  FConfigure:=DefaultConfigureHTML;
  FBack:=DefaultBackHTML;
  FCollapse:=DefaultCollapseHTML;
end;

procedure TPropertyInspectorIconHTML.Assign(Source: TPersistent);
var
  aSource: TPropertyInspectorIconHTML absolute Source;
begin
  inherited Assign(Source);
  if Source is TPropertyInspectorIconHTML then
  begin
    FDetails:=aSource.FDetails;
    FConfigure:=aSource.FConfigure;
    FBack:=aSource.FBack;
    FCollapse:=aSource.FCollapse;
  end;
end;

{ TInspectorObjectStack }

function TInspectorObjectStack.GetCurrent: TInspectorObject;
begin
  If Count>0 then
    Result:=Objects[Count-1]
  else
    Result:=Default(TInspectorObject)
end;

function TInspectorObjectStack.GetFullCaption: String;

var
  I : Integer;

begin
  Result:='';
  For I:=0 to Count-1 do
    begin
    if (Result<>'') then
      Result:=Result+'.';
    Result:=Result+Objects[i].Caption;
    end;
end;

function TInspectorObjectStack.GetIsEmpty: Boolean;
begin
  Result:=Count=0;
end;

constructor TInspectorObjectStack.Create(initialSize: Integer);
begin
  Count:=0;
  SetLength(Objects,InitialSize+ArrayDelta);
end;

procedure TInspectorObjectStack.Clear;
begin
  Count:=0;
  Objects:=[];
  SetLength(Objects,ArrayDelta);
end;

procedure TInspectorObjectStack.Push(aObj: TInspectorObject);

var
  Len : Integer;


begin
  Len:=Length(Objects);
  if Count=Len then
    SetLength(Objects,Len+ArrayDelta);
  Objects[Count]:=aObj;
  Inc(Count);
end;

procedure TInspectorObjectStack.SetCurrentObjectID(aObjectID: Integer);
begin
  if Count=0 then
    exit;
  Objects[Count-1].ObjectID:=aObjectID;
end;

procedure TInspectorObjectStack.SetCurrentCaption(aCaption: string);
begin
  if Count=0 then
    exit;
  Objects[Count-1].Caption:=aCaption;
end;

function TInspectorObjectStack.Pop: TInspectorObject;
begin
  if Count=0 then
    Result:=Default(TInspectorObject)
  else
    begin
    Dec(Count);
    Result:=Objects[Count];
    end;
end;

{ THTMLObjectInspector }

function THTMLObjectInspector.GetParentElement: TJSHTMLElement;
begin
  Result:=FParentElement;
end;

function THTMLObjectInspector.GetParentElementID: String;
begin
  if Assigned(FParentElement) then
    Result:=FParentElement.ID
  else
    Result:='';
end;

procedure THTMLObjectInspector.SetBorder(AValue: Boolean);
begin
  if FBorder=AValue then Exit;
  FBorder:=AValue;
  if Assigned(FTableElement) then
    FTableElement.Border:=IntToStr(Ord(aValue));
end;


procedure THTMLObjectInspector.SetFullCaption(AValue: String);
begin
  FFullCaption:=aValue;
  RenderCaption;
end;

procedure THTMLObjectInspector.SetIcons(AValue: TPropertyInspectorIconHTML);
begin
  if FIcons=AValue then Exit;
  FIcons.Assign(aValue);
end;

procedure THTMLObjectInspector.SetObjectCaption(AValue: String);
begin
  if GetObjectCaption=aValue then
    exit;
  if FObjectStack.IsEmpty then
    PushObject(0,aValue)
  else
    FObjectStack.SetCurrentCaption(aValue);
  RenderCaption;
end;

procedure THTMLObjectInspector.SetOptions(AValue: TOIOptions);
begin
  if FOptions=AValue then Exit;
  FOptions:=AValue;
  DisplayChanged;
end;


procedure THTMLObjectInspector.SetPropertyVisibilities(AValue: TMemberVisibilities);
begin
  if FPropertyVisibilities=AValue then Exit;
  FPropertyVisibilities:=AValue;
  DisplayChanged;
end;

procedure THTMLObjectInspector.SetVisibleColumns(AValue: TOIColumns);
begin
  if FVisibleColumns=AValue then Exit;
  FVisibleColumns:=AValue;
  DisplayChanged;
end;

procedure THTMLObjectInspector.SetObjectID(AValue: integer);
begin
  if GetObjectID=AValue then Exit;
  if FObjectStack.IsEmpty then
    PushObject(aValue,'Object '+IntToStr(aValue))
  else
    FObjectStack.SetCurrentObjectID(aValue);
  DisplayChanged;
end;

procedure THTMLObjectInspector.SetParentElement(AValue: TJSHTMLElement);
begin
  FParentElement:=aValue;
  DisplayChanged;
end;

procedure THTMLObjectInspector.SetParentElementID(AValue: String);

var
  lParent : TJSHTMlelement;

begin
  lParent:=TJSHTMlelement(Document.getElementById(aValue));
  if lParent=Nil then
    Raise EHTMLTreeBuilder.CreateFmt('Unknown element id: "%s"',[aValue]);
  ParentElement:=lParent;
end;

procedure THTMLObjectInspector.DisplayChanged;

var
  PropData : TOIPropData;

begin
  Clear(False);
  For PropData in FProperties do
    ShowProperty(PropData);
  Refresh;
end;

procedure THTMLObjectInspector.Refresh;
begin
  if Assigned(FOnRefresh) then
    FonRefresh(Self);
end;

procedure THTMLObjectInspector.RefreshObject;
begin
  If Assigned(FOnRefreshObject) then
    FOnRefreshObject(Self);
end;

function THTMLObjectInspector.AppendSpan(aParent: TJSHTMLElement; const aInnerText: String): TJSHTMLElement;
begin
  Result:=CreateEl('span','',aInnerText);
  aParent.AppendChild(Result);
end;

function THTMLObjectInspector.CreateEl(aTag: String; const aID: String; const aInnerText: String): TJSHTMLElement;

begin
  Result:=TJSHTMLElement(Document.CreateElement(aTag));
  if aID<>'' then
    Result.id:=aID;
  if aInnerText<>'' then
    Result.InnerText:=aInnerText;
end;

function THTMLObjectInspector.AppendEl(aParent: TJSHTMLElement; aTag: String; const aID: String; const aInnerText: String
  ): TJSHTMLElement;

begin
  Result:=CreateEl(aTag,aID,aInnerText);
  aParent.AppendChild(Result);
end;


procedure THTMLObjectInspector.HandleColumnVisibility (aEvent : TJSEvent);

var
  CB : TJSHTMLInputElement;
  aOrd : Integer;
  Col : TOIColumn;
  Cols : TOIColumns;

begin
  CB:=TJSHTMLInputElement(aEvent.targetHTMLElement);
  aOrd:=StrToIntDef(CB.dataset['ord'],-1);
  if aOrd=-1 then
    exit;
  Col:=TOIColumn(aOrd);
  Cols:=VisibleColumns;
  If CB.Checked then
    Include(Cols,Col)
  else
    Exclude(Cols,Col);
  VisibleColumns:=Cols;
end;

procedure THTMLObjectInspector.HandlePropertyVisibility(aEvent : TJSEvent);

var
  CB : TJSHTMLInputElement;
  aOrd : Integer;
  Vis : TMemberVisibility;
  Vises : TMemberVisibilities;

begin
  CB:=TJSHTMLInputElement(aEvent.targetHTMLElement);
  aOrd:=StrToIntDef(CB.dataset['ord'],-1);
  if aOrd=-1 then
    exit;
  Vis:=TMemberVisibility(aOrd);
  Writeln('Handling ',VisibilityNames[Vis],', including : ',CB.Checked);
  Vises:=PropertyVisibilities;
  If CB.Checked then
    Include(Vises,Vis)
  else
    Exclude(Vises,Vis);
  PropertyVisibilities:=Vises;
end;

procedure THTMLObjectInspector.HandleOptionsClick(aEvent : TJSEvent);

var
  CB : TJSHTMLInputElement;
  aOrd : Integer;
  Opt : TOIOption;
  Opts : TOIOptions;

begin
  CB:=TJSHTMLInputElement(aEvent.targetHTMLElement);
  aOrd:=StrToIntDef(CB.dataset['ord'],-1);
  if aOrd=-1 then
    exit;
  Opt:=TOIOption(aOrd);
  Opts:=Options;
  If CB.Checked then
    Include(Opts,Opt)
  else
    Exclude(Opts,Opt);
  Options:=Opts;
end;

function THTMLObjectInspector.CreateConfigPanel(): TJSHTMLElement;

  Function AppendCheckbox(aParent : TJSHTMLElement; aName,aLabel : String; aOrd : Integer; isChecked: Boolean; aHandler : TJSRawEventHandler) : TJSHTMLInputElement;

  var
    Tmp : TJSHTMLElement;

  begin
    Tmp:=AppendSpan(aParent,'');
    Tmp.ClassName:='oi-checkbox-row';
    Result:=TJSHTMLInputElement(AppendEl(Tmp,'input','cb'+aName+Suffix));
    Result.Checked:=isChecked;
    Result._type:='checkbox';
    Result.dataset['ord']:=IntToStr(aOrd);
    Result.AddEventListener('change',aHandler);
    Tmp:=AppendEl(Tmp,'label','',aLabel);
    Tmp['for']:='cb'+aName;
  end;

var
  Tmp,CBDiv,CBhead,CBCol : TJSHTMLElement;
  //CB : TJSHTMLInputElement;
  Vis : TMemberVisibility;

begin
  Result:=CreateEl('div','oiConfig'+Suffix);
  Result.classList.add('oi-config-panel-closed');

  appendEl(Result,'h5','Use the checkboxes to show/hide fields in the table:');
  CBDiv:=appendEl(Result,'div','');
  CBDiv.ClassName:='oi-checkbox-div';
  // Col 1
  CBCol:=appendEl(CBDiv,'div','');
  CBCol.ClassName:='oi-checkbox-col';
  CBHead:=AppendEl(CBCol,'div','');
  CBHead.ClassName:='oi-checkbox-header';
  AppendSpan(CBHead,'Columns');
  AppendCheckBox(CBCol,'PropertyName','Property name',Ord(ocName),ocName in VisibleColumns,@HandleColumnVisibility);
  AppendCheckBox(CBCol,'PropertyVisibility','Visibility',Ord(ocVisibility),ocVisibility in VisibleColumns,@HandleColumnVisibility);
  AppendCheckBox(CBCol,'PropertyKind','Kind',Ord(ocKind),ocKind in VisibleColumns,@HandleColumnVisibility);
  AppendCheckBox(CBCol,'PropertyValue','Value',Ord(ocValue),ocValue in VisibleColumns,@HandleColumnVisibility);
  // Col 2
  CBCol:=appendEl(CBDiv,'div','');
  CBCol.ClassName:='oi-checkbox-col';
  CBHead:=AppendEl(CBCol,'div','');
  CBHead.ClassName:='oi-checkbox-header';
  AppendSpan(CBHead,'Visibilities');
  For Vis in TMemberVisibility do
    AppendCheckBox(CBCol,'PropVis'+VisibilityNames[Vis],VisibilityNames[Vis],Ord(Vis),Vis in PropertyVisibilities,@HandlePropertyVisibility);
  Tmp:=AppendEl(Result,'div','');
  Tmp.classname:='oi-checkbox-last';
  AppendCheckBox(Tmp,'noShowNoValue','Hide properties without value',0,ooHidePropertiesWithoutValue in Options,@HandleOptionsClick);

(*

    <div class="checkbox-last">
      <span class="width-300">
        <input
          type="checkbox"
          id="colPublishedCheckbox"
          name="cbxPublished"
          unchecked
        />
        <label for="cbxPublished">Hide properties without value</label>
      </span>
    </div>
  </div>

*)
end;

procedure THTMLObjectInspector.RenderCaption;

begin
  if not (ooShowCaption in Options) then exit;
  if not Assigned(FCaptionElement) then exit;
  FCaptionElement.innerText:=FullCaption;
end;

procedure THTMLObjectInspector.ToggleConfig(aEvent : TJSEvent);

begin
  if not FConfigPanel.classList.toggle('oi-config-panel-open') then
    begin
    aEvent.TargetElement.innerHTML:=Icons.Configure;
    FConfigPanel.classList.add('oi-config-panel-closed');
    end
  else
    begin
    aEvent.TargetElement.innerHTML:=Icons.Collapse;
    FConfigPanel.classList.remove('oi-config-panel-closed');
    end
end;

procedure THTMLObjectInspector.HandleRefresh(aEvent: TJSHTMLElement);

begin
  Clear;
  RefreshObject;
  if aEvent=Nil then ;
end;

procedure THTMLObjectInspector.HandleBack(aEvent: TJSHTMLElement);
begin
  if aEvent=Nil then ;
  PopObject;
  Clear;
  RefreshObject;
end;

function THTMLObjectInspector.CreateCaption(aParent : TJSHTMLElement): TJSHTMLElement;

var
  CS,DC : TJSHTMLElement;

begin
  DC:=TJSHTMLElement(Document.createElement('div'));
  DC.className:='oi-caption';
  CS:=TJSHTMLElement(document.createElement('div'));
  CS.className:='oi-icon-btn-left oi-hidden' ;
  CS.InnerHTML:=Icons.Back;
  CS.AddEventListener('click',@HandleBack);
  FBackElement:=CS;
  DC.AppendChild(CS);
  CS:=TJSHTMLElement(document.createElement('div'));
  CS.className:='oi-icon-btn-left';
  CS.InnerHTML:=Icons.Refresh;
  CS.AddEventListener('click',@HandleRefresh);
  DC.AppendChild(CS);
  CS:=TJSHTMLElement(Document.createElement('span'));
  CS.className:='oi-caption-lbl';
  FCaptionElement:=CS;
  DC.AppendChild(CS);
  RenderCaption;
  aParent.AppendChild(DC);
  Result:=DC;
end;

function THTMLObjectInspector.CreateWrapper(aParent : TJSHTMLElement): TJSHTMLElement;

var
  CS,DC : TJSHTMLElement;

begin
  Result:=TJSHTMLElement(Document.createElement('div'));
  Result.className:='oi-wrapper';
  aParent.AppendChild(Result);
  if (ooShowCaption in Options) and (FullCaption<>'') then
    begin
    DC:=CreateCaption(Result);
    FConfigPanel:=nil;
    if ooShowConfigPanel in Options then
      begin
      CS:=TJSHTMLElement(Document.createElement('span'));
      CS.innerHTML:=Icons.Configure;
      CS.className:='oi-icon-btn';
      CS.addEventListener('click',@ToggleConfig);
      DC.AppendChild(CS);
      FConfigPanel:=CreateConfigPanel;
      Result.appendChild(FConfigPanel);
      end
    end
  else
    begin
    FConfigPanel:=nil;
    FCaptionElement:=Nil;
    end;
end;

function THTMLObjectInspector.GetFullCaption: String;
begin
  Result:=FFullCaption;
  if Result='' then
    Result:=FObjectStack.FullCaption;
  if Result='' then
    Result:='Property inspector';
end;

function THTMLObjectInspector.GetObjectCaption: String;
begin
  Result:=FObjectStack.Current.Caption;
end;

function THTMLObjectInspector.GetObjectID: integer;
begin
  Result:=FObjectStack.Current.ObjectID;
end;

function THTMLObjectInspector.CreateTable(aParent : TJSHTMLElement): TJSHTMLTableElement;


var
  P,R : TJSHTMLElement;

  function AddHeader(aCol : TOIColumn; aText,aClass : string) : TJSHTMLTableCellElement;
  begin
    Result:=nil;
    if not (aCol in VisibleColumns) then exit;
    Result:=TJSHTMLTableCellElement(Document.createElement('TH'));
    Result.InnerText:=aText;
    Result.className:=aClass;
    R.AppendChild(Result);
  end;

begin
  if FWrapperElement=Nil then
    FWrapperElement:=CreateWrapper(aParent);
  Result:=TJSHTMLTableElement(Document.createElement('TABLE'));
  Result.ClassName:='oi-table';
  P:=TJSHTMLTableElement(Document.createElement('THEAD'));
  Result.appendChild(P);
  R:=TJSHTMLTableRowElement(Document.createElement('TR'));
  addHeader(ocName,'Property Name','oi-property-name');
  addHeader(ocVisibility,'Visibility','oi-property-visibility');
  addHeader(ocKind, 'Kind','oi-property-kind');
  addHeader(ocValue,'Value','oi-property-value');
  P.appendChild(R);
  P:=TJSHTMLTableElement(Document.createElement('TBODY'));
  Result.border:=IntToStr(Ord(Border));
  Result.appendChild(P);
  FWrapperElement.appendChild(Result);
end;

procedure THTMLObjectInspector.Clear(ClearData: Boolean);
begin
  if not Assigned(FParentElement) then
    exit;
  if ClearData then
    FProperties:=[];
  if Assigned(FTableElement) then
    FWrapperElement.removeChild(FTableElement);
  FTableElement:=CreateTable(FParentElement);
end;


procedure THTMLObjectInspector.AddProperty(aIndex: Integer; aVisibility: TMemberVisibility; aKind: TTypeKind; aFlags: TPropDataFlags;
  const aName, aValue: String);

var
  aData : TOIPropData;

begin
  aData.Index:=aIndex;
  aData.Value:=aValue;
  aData.Name:=aName;
  aData.Kind:=aKind;
  aData.Flags:=aFlags;
  aData.Visibility:=aVisibility;
  AddProperty(aData);
end;

function THTMLObjectInspector.CreateNameCell(aPropData : TOIPropData) : TJSHTMLTableCellElement;

begin
  Result:=TJSHTMLTableCellElement(Document.createElement('TD'));
  Result.InnerText:=aPropData.Name;
  Result.className:='oi-property-name';
end;

function THTMLObjectInspector.CreateKindCell(aPropData : TOIPropData; const aKindName: String) : TJSHTMLTableCellElement;

begin
  Result:=TJSHTMLTableCellElement(Document.createElement('TD'));
  Result.InnerText:=aKindName;
  Result.className:='oi-property-kind';
end;

function THTMLObjectInspector.CreateVisibilityCell(aPropData : TOIPropData) : TJSHTMLTableCellElement;


begin
  Result:=TJSHTMLTableCellElement(Document.createElement('TD'));
  Result.InnerText:=VisibilityNames[aPropData.Visibility];
  Result.className:='oi-property-visibility';
end;

procedure THTMLObjectInspector.HandlePropertyDetails(aEvent : TJSEvent);

var
  El : TJSHTMLElement;
  aID : integer;
  aCaption : string;

begin
  El:=aEvent.currentTargetHTMLElement;
  if IsDefined(El.datasetObj['objectId']) then
    begin
    aID:=StrToIntDef(El.Dataset['objectId'],0);
    aCaption:=El.Dataset['propertyName'];
    if aId<>0 then
      begin
      PushObject(aID,aCaption);
      RefreshObject;
      end;
    end;

end;

function THTMLObjectInspector.CreateValueCell(aPropData: TOIPropData; const aKindName : string): TJSHTMLTableCellElement;

var
  Cap,Cell,Span : TJSHTMLElement;

begin
  Result:=TJSHTMLTableCellElement(Document.createElement('TD'));
//  Writeln(aPropData.Name,' : ',GetEnumName(TypeInfo(TTypeKind),Ord(aPropData.Kind)));
  Cell:=TJSHTMLElement(Document.createElement('div'));
  Result.Append(Cell);
  if (aPropData.Kind=tkClass) and (aPropData.ValueObjectID<>0) then
    begin
    Cell.ClassName:='oi-property-cell '+aKindName;
    Cap:=TJSHTMLElement(Document.createElement('span'));
    Cell.appendChild(Cap);
    Span:=TJSHTMLElement(Document.createElement('div'));
    Span.InnerHtml:=Icons.Details;
    Span.ClassName:='oi-icon-detail-btn';
    Span.Dataset['objectId']:=IntToStr(aPropData.ValueObjectID);
    Span.Dataset['propertyName']:=aPropData.Name;
    Span.AddEventListener('click',@HandlePropertyDetails);
    Cell.appendChild(Span);
    end
  else
    Cap:=Cell;
  Cap.InnerText:=aPropData.Value;
//  Cap.className:='oi-property-value '+aKindName;
//  Result.ClassName:='oi-property-cell';
end;


procedure THTMLObjectInspector.AddProperty(aPropData : TOIPropData);

begin
  TJSArray(FProperties).Push(aPropData);
  ShowProperty(aPropData);
end;

function THTMLObjectInspector.ShowProperty(aPropData : TOIPropData) : boolean;

var
  allow : Boolean;

begin
  if (ooHidePropertiesWithoutValue in Options) then
    allow:=Not (pdfNoValue in aPropdata.Flags)
  else
    allow:=True;
  if Allow then
    Allow:=aPropData.Visibility in PropertyVisibilities;
  if Assigned(BeforeAddProperty) then
    BeforeAddProperty(Self,aPropData,allow);
  if Allow then
    begin
    DoAddProperty(aPropData);
    if Assigned(AfterAddProperty) then
      AfterAddProperty(Self,aPropData);
    end;
  Result:=Allow;
end;

procedure THTMLObjectInspector.DoAddProperty(aPropData : TOIPropData);


var
  TN : String;
  PR,CN : TJSHTMLElement;

begin
  TN:=GetEnumName(TypeInfo(TTypeKind),Ord(aPropData.Kind));
  PR:=TJSHTMLTableRowElement(Document.createElement('TR'));
  PR.dataset['propertyIdx']:=IntToStr(aPropData.Index);
  PR.dataset['propertyName']:=aPropData.Name;
  PR.dataset['propertyKind']:=TN;
  PR.dataset['propertyKindOrd']:=IntToStr(Ord(aPropData.Kind));
  if ocName in VisibleColumns then
    begin
    cn:=CreateNameCell(aPropData);
    PR.AppendChild(CN);
    end;
  if ocVisibility in VisibleColumns then
    begin
    cn:=CreateVisibilityCell(aPropData);
    PR.AppendChild(CN);
    end;
  if ocKind in VisibleColumns then
    begin
    cn:=CreateKindCell(aPropData,TN);
    PR.AppendChild(CN);
    end;
  if ocValue in VisibleColumns then
    begin
    cn:=CreateValueCell(aPropData,TN);
    PR.AppendChild(CN);
    end;
  FTableElement.tBodies[0].AppendChild(PR);
end;

procedure THTMLObjectInspector.PushObject(aObjectID: Integer;
  const aCaption: String);

var
  O : TInspectorObject;

begin
  O.ObjectID:=aObjectID;
  O.Caption:=aCaption;
  FObjectStack.Push(O);
  Clear(True);
  if (FObjectStack.Count>1) and Assigned(FBackElement) then
    FBackElement.classList.remove('oi-hidden');
  RenderCaption;
end;

function THTMLObjectInspector.CreateIcons : TPropertyInspectorIconHTML;

begin
  Result:=TPropertyInspectorIconHTML.Create(Self);
end;

function THTMLObjectInspector.PopObject: Integer;

var
  Obj : TInspectorObject;

begin
  Obj:=FObjectstack.Pop;
  Result:=Obj.ObjectID;
  if (FObjectStack.Count<=1) and Assigned(FBackElement) then
    FBackElement.classList.add('oi-hidden');
  RenderCaption;
end;

constructor THTMLObjectInspector.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FIcons:=CreateIcons;
  Options:=[ooShowCaption,ooShowConfigPanel,ooHidePropertiesWithoutValue];
  VisibleColumns:=[ocName,ocValue];
  PropertyVisibilities:=AllMemberVisibilities;
  FObjectStack:=TInspectorObjectStack.Create(TInspectorObjectStack.ArrayDelta);
end;

destructor THTMLObjectInspector.destroy;
begin
  Clear;
  inherited destroy;
end;

end.

