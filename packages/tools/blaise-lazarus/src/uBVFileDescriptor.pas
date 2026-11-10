unit uBVFileDescriptor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ProjectIntf, NewItemIntf, uBVStrings;

type
  { TNewIDEItemCategoryBlaiseVue }
  TNewIDEItemCategoryBlaiseVue = class(TNewIDEItemCategory)
  public
    function LocalizedName: string; override;
    function Description: string; override;
  end;

  { TBVComponentFileDescriptor }
  TBVComponentFileDescriptor = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function CreateSource(const aFilename, aSourceName, aResourceName: string): string; override;
  end;

  { TBVViewFileDescriptor }
  TBVViewFileDescriptor = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function CreateSource(const aFilename, aSourceName, aResourceName: string): string; override;
  end;

procedure RegisterFileDescriptors;

implementation

{ TNewIDEItemCategoryBlaiseVue }

function TNewIDEItemCategoryBlaiseVue.LocalizedName: string;
begin
  Result := 'BlaiseVue';
end;

function TNewIDEItemCategoryBlaiseVue.Description: string;
begin
  Result := rsBVCategoryDescription;
end;

procedure RegisterFileDescriptors;
begin
  // 1. Registra a categoria no assistente File -> New... se ainda não existir
  if (NewIDEItems <> nil) and (NewIDEItems.FindByName('BlaiseVue') = nil) then
    RegisterNewItemCategory(TNewIDEItemCategoryBlaiseVue.Create('BlaiseVue'));

  // 2. Registra os descritores de arquivo associados à categoria BlaiseVue
  RegisterProjectFileDescriptor(TBVComponentFileDescriptor.Create, 'BlaiseVue');
  RegisterProjectFileDescriptor(TBVViewFileDescriptor.Create, 'BlaiseVue');
end;

{ TBVComponentFileDescriptor }

constructor TBVComponentFileDescriptor.Create;
begin
  inherited Create;
  Name := 'BlaiseVue Component (.bv)';
  DefaultFilename := 'MyComponent.bv';
  DefaultFileExt := '.bv';
  DefaultSourceName := 'MyComponent';
  VisibleInNewDialog := True;
  IsPascalUnit := False;
end;

function TBVComponentFileDescriptor.GetLocalizedName: string;
begin
  Result := rsBVComponentName;
end;

function TBVComponentFileDescriptor.GetLocalizedDescription: string;
begin
  Result := rsBVComponentDescription;
end;

function TBVComponentFileDescriptor.CreateSource(const {%H-}aFilename, aSourceName, {%H-}aResourceName: string): string;
const
  LE = LineEnding;
var
  CompName: string;
begin
  CompName := aSourceName;
  if (CompName = '') or (LowerCase(CompName) = 'unit') then
    CompName := 'MyComponent';

  Result :=
    '<template>' + LE +
    '  <div class="' + LowerCase(CompName) + '-wrapper">' + LE +
    '    <h3>{{ title }}</h3>' + LE +
    '    <p>{{ description }}</p>' + LE +
    '    <button class="btn btn-primary" @click="doClick">Ação</button>' + LE +
    '  </div>' + LE +
    '</template>' + LE + LE +
    '<script>' + LE +
    'type' + LE +
    '  T' + CompName + ' = class(TBVComponent)' + LE +
    '  published' + LE +
    '    property title: string;' + LE +
    '    property description: string;' + LE +
    '  public' + LE +
    '    procedure doClick;' + LE +
    '  end;' + LE + LE +
    'procedure T' + CompName + '.doClick;' + LE +
    'begin' + LE +
    '  ShowMessage(''BlaiseVue component action triggered!'');' + LE +
    'end;' + LE +
    '</script>' + LE + LE +
    '<style scoped>' + LE +
    '.' + LowerCase(CompName) + '-wrapper {' + LE +
    '  padding: 1rem;' + LE +
    '  border: 1px solid #e2e8f0;' + LE +
    '  border-radius: 6px;' + LE +
    '  background: #ffffff;' + LE +
    '}' + LE +
    '</style>' + LE;
end;

{ TBVViewFileDescriptor }

constructor TBVViewFileDescriptor.Create;
begin
  inherited Create;
  Name := 'BlaiseVue View (.bv)';
  DefaultFilename := 'MyView.bv';
  DefaultFileExt := '.bv';
  DefaultSourceName := 'MyView';
  VisibleInNewDialog := True;
  IsPascalUnit := False;
end;

function TBVViewFileDescriptor.GetLocalizedName: string;
begin
  Result := rsBVViewName;
end;

function TBVViewFileDescriptor.GetLocalizedDescription: string;
begin
  Result := rsBVViewDescription;
end;

function TBVViewFileDescriptor.CreateSource(const {%H-}aFilename, aSourceName, {%H-}aResourceName: string): string;
const
  LE = LineEnding;
var
  ViewName: string;
begin
  ViewName := aSourceName;
  if (ViewName = '') or (LowerCase(ViewName) = 'unit') then
    ViewName := 'MyView';

  Result :=
    '<template>' + LE +
    '  <div class="view-container ' + LowerCase(ViewName) + '-view">' + LE +
    '    <header class="view-header">' + LE +
    '      <h1>{{ pageTitle }}</h1>' + LE +
    '    </header>' + LE +
    '    <main class="view-content">' + LE +
    '      <p>Bem-vindo à página {{ pageTitle }}.</p>' + LE +
    '    </main>' + LE +
    '  </div>' + LE +
    '</template>' + LE + LE +
    '<script>' + LE +
    'type' + LE +
    '  T' + ViewName + ' = class(TBVView)' + LE +
    '  published' + LE +
    '    property pageTitle: string;' + LE +
    '  public' + LE +
    '    procedure created; override;' + LE +
    '  end;' + LE + LE +
    'procedure T' + ViewName + '.created;' + LE +
    'begin' + LE +
    '  inherited created;' + LE +
    '  pageTitle := ''' + ViewName + ''';' + LE +
    'end;' + LE +
    '</script>' + LE + LE +
    '<style scoped>' + LE +
    '.' + LowerCase(ViewName) + '-view {' + LE +
    '  display: flex;' + LE +
    '  flex-direction: column;' + LE +
    '  gap: 1rem;' + LE +
    '  padding: 1.5rem;' + LE +
    '}' + LE +
    '</style>' + LE;
end;

end.
