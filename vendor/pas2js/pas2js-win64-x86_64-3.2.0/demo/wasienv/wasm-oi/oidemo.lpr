library oidemo;

uses sysutils, classes, rtti, wasm.debuginspector.rtti;

{$RTTI INHERIT
   METHODS(DefaultMethodRttiVisibility)
   FIELDS(DefaultFieldRttiVisibility)
   PROPERTIES(DefaultPropertyRttiVisibility)
}

Type

  { TControl }
  TFontStyle = (fsBold,fsItalic,fsUnderline,fsStrikeThrough);
  TFontStyles = set of TFontStyle;

  { TFont }

  TFont = Class(TPersistent)
  private
    FName: String;
    FSize: Integer;
    FStyle: TFontStyles;
  Public
    procedure Assign(Source: TPersistent); override;

  Published
    Property Name : String Read FName Write FName;
    Property Size : Integer Read FSize Write FSize;
    Property Style : TFontStyles Read FStyle Write FStyle;
  end;

  TAlign = (alNone,alClient,alLeft,alTop,alRight,alBottom);

  TControl = class(TComponent)
  private
    FAlign: TAlign;
    FFocused: Boolean;
    FHeight: Integer;
    FLeft: Integer;
    FOnEnter: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FTop: Integer;
    FVisible: Boolean;
    FWidth: Integer;
    function GetParent: TControl;
    function GetRect: TRect;
  Protected
    Property Focused : Boolean Read FFocused Write FFocused;
  Public
    Property BoundsRect : TRect Read GetRect;
    Property Parent : TControl Read GetParent;
  Published
    Property OnEnter : TNotifyEvent Read FOnEnter Write FOnEnter;
    Property OnExit : TNotifyEvent Read FOnExit Write FOnExit;
    Property Align : TAlign Read FAlign Write FAlign;
    Property Top : Integer Read FTop Write FTop;
    Property Left : Integer Read FLeft Write FLeft;
    Property Width : Integer Read FWidth Write FWidth;
    Property Height : Integer Read FHeight Write FHeight;
    Property Visible : Boolean Read FVisible Write FVisible;
  end;
  TControlClass = Class of TControl;

  { TCaptionControl }

  TCaptionControl = Class(TControl)
  Private
    FCaption: String;
    FFont: TFont;
    procedure SetFont(const aValue: TFont);
  public
    constructor Create(aowner : TComponent); override;
    destructor Destroy; override;
  Published
    Property Caption : String Read FCaption Write FCaption;
    Property Font : TFont Read FFont Write SetFont;
  end;
  TForm = class(TCaptionControl);
  TPanel = class(TControl);

  { TLabel }

  TLabel = class(TCaptionControl)
  private
    FFocusControl: TControl;
    procedure SetFocusControl(const aValue: TControl);
  Protected
    Procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  Published
    Property FocusControl : TControl Read FFocusControl Write SetFocusControl;
  end;

  { TEdit }

  TEdit = Class(TControl)
  Private
    FPlaceHolder: String;
    FText: String;
  Published
    Property Text : String Read FText Write FText;
    Property Placeholder : String Read FPlaceHolder Write FPlaceHolder;
  end;

  { TCheckBox }

  TCheckBox = class(TCaptionControl)
  private
    FChecked: Boolean;
  Published
    Property Checked : Boolean Read FChecked Write FChecked;
  end;

  TModalResult = (mrNone,mrOK,mrCancel,mrClose,mrYes,mrYesToAll,mrNo,mrNoToAll);

  { TButton }

  TButton = class(TCaptionControl)
  private
    FModalResult: TModalResult;
  Published
    Property ModalResult : TModalResult Read FModalResult Write FModalResult;
  end;


{ TLabel }

procedure TLabel.SetFocusControl(const aValue: TControl);
begin
  if FFocusControl=aValue then Exit;
  if Assigned(FFocusControl) then
    FFocusControl.RemoveFreeNotification(Self);
  FFocusControl:=aValue;
  if Assigned(FFocusControl) then
    FFocusControl.FreeNotification(Self);
end;

procedure TLabel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation=opRemove then
    if aComponent=FFocusControl then
      FFocusControl:=nil;
end;

{ TCaptionControl }

procedure TCaptionControl.SetFont(const aValue: TFont);
begin
  if FFont=aValue then Exit;
  FFont.Assign(aValue);
end;

constructor TCaptionControl.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FFont:=TFont.Create;
end;

destructor TCaptionControl.Destroy;
begin
  FreeAndNil(FFont);
  inherited Destroy;
end;

{ TFont }

procedure TFont.Assign(Source: TPersistent);
var
  aSource: TFont;
begin
  if Source is TFont then
  begin
    aSource:=TFont(Source);
    Style:=aSource.Style;
    Size:=aSource.Size;
    Name:=aSource.Name;
  end else
    inherited Assign(Source);
end;

{ TControl }

function TControl.GetRect: TRect;
begin
  Result:=Rect(Left,Top,Left+Width,Top+Height);
end;

function TControl.GetParent: TControl;
begin
  if Owner is TControl then
    Result:=TControl(Owner)
  else
    Result:=Nil;
end;

var
  FForm : TForm;
  ctag : Integer;
  Inspector:TWasmDebugInspector;

Function CreateForm : TForm;

  Function CreateControl(aType : TControlClass; aParent : TControl; aName : String; aCaption : String = '') : TControl;
  begin
    inc(CTag);
    Result:=aType.Create(aParent);
    Result.Tag:=CTag;
    Result.Name:=aName;
    Result.Left:=10;
    Result.Top:=24*(cTag+1);
    Result.Width:=120;
    Result.Height:=22;
    if Result is TCaptionControl then
      TCaptionControl(Result).Caption:=aCaption
    else if Result is TEdit then
      TEdit(Result).Text:=aCaption
  end;

var
  btn,lbl,Edt,Pnl : TControl;

begin
  Result:=TForm.Create(Nil);
  Pnl:=CreateControl(TPanel,Result,'pnlTop','Top panel');
  Pnl.Align:=alClient;
  edt:=CreateControl(TEdit,Pnl,'edtFirst','Firstname');
  lbl:=CreateControl(TLabel,Pnl,'lblFirst','First name');
  TLabel(lbl).FocusControl:=edt;
  edt:=CreateControl(TEdit,Pnl,'edtLast','Lastname');
  lbl:=CreateControl(TLabel,Pnl,'lblLast','Last name');
  TLabel(lbl).FocusControl:=edt;
  edt:=CreateControl(TEdit,Pnl,'edtBirth','2001-04-16');
  lbl:=CreateControl(TLabel,Pnl,'lblBirth','Date of birth');
  TLabel(lbl).FocusControl:=edt;
  CreateControl(TCheckBox,Pnl,'cbRemember','Remember me');
  Pnl:=CreateControl(TPanel,Result,'pnlButtons','');
  Pnl.Align:=alBottom;
  btn:=CreateControl(TButton,Pnl,'btnOK','OK');
  btn.Align:=alRight;
  TButton(btn).ModalResult:=mrOK;
  btn:=CreateControl(TButton,Pnl,'btnCancel','Cancel');
  btn.Align:=alRight;
  TButton(btn).ModalResult:=mrCancel;
end;

begin
  FForm:=CreateForm;
  Inspector:=TWasmDebugInspector.Create(FFOrm);
  Inspector.SendObjectTree(FForm);
  inspector.SendObjectProperties(FForm,[Low(TMemberVisibility)..High(TMemberVisibility)]);
end.

