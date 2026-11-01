unit uBVAutoComplete;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Menus, LCLType,
  SynEdit, SynCompletion;

procedure PopulateBVCompletions(AList: TStrings);
function AttachBVCompletion(ASynEdit: TCustomSynEdit): TSynCompletion;

implementation

const
  BV_COMPLETION_NAME = 'BVAutoCompletionPlugin';

procedure PopulateBVCompletions(AList: TStrings);
begin
  if AList = nil then Exit;
  AList.BeginUpdate;
  try
    AList.Clear;

    // 1. Directives & Attributes
    AList.Add('b-model');
    AList.Add('b-for');
    AList.Add('b-if');
    AList.Add('b-else-if');
    AList.Add('b-else');
    AList.Add('b-show');
    AList.Add('b-validate');
    AList.Add('b-bind');
    AList.Add('b-on');
    AList.Add('@click');
    AList.Add('@input');
    AList.Add('@change');
    AList.Add('@submit');
    AList.Add('@keydown');
    AList.Add('@keyup');
    AList.Add('@blur');
    AList.Add('@focus');
    AList.Add(':class');
    AList.Add(':style');
    AList.Add(':key');
    AList.Add(':disabled');
    AList.Add(':value');
    AList.Add('v-model');
    AList.Add('v-for');
    AList.Add('v-if');
    AList.Add('v-show');

    // 2. BlaiseUI Components
    AList.Add('bv-alert');
    AList.Add('bv-avatar');
    AList.Add('bv-badge');
    AList.Add('bv-bar-chart');
    AList.Add('bv-breadcrumb');
    AList.Add('bv-btn');
    AList.Add('bv-btn-group');
    AList.Add('bv-card');
    AList.Add('bv-checkbox');
    AList.Add('bv-col');
    AList.Add('bv-container');
    AList.Add('bv-datagrid');
    AList.Add('bv-dialog');
    AList.Add('bv-divider');
    AList.Add('bv-doughnut-chart');
    AList.Add('bv-drawer');
    AList.Add('bv-dropdown');
    AList.Add('bv-form');
    AList.Add('bv-icon');
    AList.Add('bv-input');
    AList.Add('bv-line-chart');
    AList.Add('bv-link');
    AList.Add('bv-list');
    AList.Add('bv-list-item');
    AList.Add('bv-modal');
    AList.Add('bv-navbar');
    AList.Add('bv-pagination');
    AList.Add('bv-pie-chart');
    AList.Add('bv-progress');
    AList.Add('bv-radar-chart');
    AList.Add('bv-radio');
    AList.Add('bv-row');
    AList.Add('bv-select');
    AList.Add('bv-slider');
    AList.Add('bv-spinner');
    AList.Add('bv-switch');
    AList.Add('bv-tab');
    AList.Add('bv-tabs');
    AList.Add('bv-textarea');
    AList.Add('bv-toast');
    AList.Add('bv-tooltip');

    // 3. SFC Tags
    AList.Add('<template>');
    AList.Add('</template>');
    AList.Add('<script>');
    AList.Add('</script>');
    AList.Add('<style>');
    AList.Add('</style>');

    // 4. Component Options & Lifecycle
    AList.Add('props:');
    AList.Add('data:');
    AList.Add('computed:');
    AList.Add('watch:');
    AList.Add('methods:');
    AList.Add('created:');
    AList.Add('mounted:');
    AList.Add('updated:');
    AList.Add('unmounted:');
    AList.Add('provide:');
    AList.Add('inject:');
    AList.Add('routes:');

    // 5. Object Pascal Keywords & Runtime Helpers
    AList.Add('procedure');
    AList.Add('function');
    AList.Add('begin');
    AList.Add('end;');
    AList.Add('var');
    AList.Add('const');
    AList.Add('JSValue');
    AList.Add('TJSArray');
    AList.Add('TJSObject');
    AList.Add('TJSFunction');
    AList.Add('CallMethod');
    AList.Add('GetFieldStr');
    AList.Add('GetFieldInt');
    AList.Add('GetFieldBool');
    AList.Add('SetFieldStr');
    AList.Add('SetFieldInt');
    AList.Add('SetFieldBool');
    AList.Add('this');
    AList.Add('console.log');

    // 6. Global Plugins & Services
    AList.Add('$store');
    AList.Add('$router');
    AList.Add('$route');
    AList.Add('$i18n');
    AList.Add('$t');
    AList.Add('$theme');
    AList.Add('$errors');
    AList.Add('$v');
    AList.Add('$wasm');
    AList.Add('$mobile');
  finally
    AList.EndUpdate;
  end;
end;

function AttachBVCompletion(ASynEdit: TCustomSynEdit): TSynCompletion;
var
  Existing: TComponent;
begin
  if ASynEdit = nil then Exit(nil);

  Existing := ASynEdit.FindComponent(BV_COMPLETION_NAME);
  if Existing is TSynCompletion then
    Exit(TSynCompletion(Existing));

  Result := TSynCompletion.Create(ASynEdit);
  Result.Name := BV_COMPLETION_NAME;
  Result.Editor := ASynEdit;
  Result.EndOfTokenChr := '()[].<>"'#39' ';
  Result.ShortCut := Menus.ShortCut(VK_SPACE, [ssCtrl]);
  PopulateBVCompletions(Result.ItemList);
end;

end.
