unit BVPascalDX;

{
  BVPascalDX - Idiomatic Object Pascal Developer Experience (Phase 8)
  -------------------------------------------------------------------
  Provides high-level, strongly-typed Pascal utilities, UI controllers,
  and collection manipulation routines, eliminating the need for inline
  asm ... end; blocks in application views and components.
}

{$mode objfpc}

interface

uses JS, Web, SysUtils, BVDataSet, BVRpc, BlaiseReports;

{ --- UI Notification & Dialog Helpers --- }
procedure ShowToast(const Msg: string; DurationMs: Integer = 2500);
procedure ShowAlert(const Msg: string);
function Confirm(const Msg: string): Boolean;

{ --- Logging & Timer Helpers (Zero-ASM) --- }
procedure ConsoleLog(const Msg: string);
function StartInterval(Callback: JSValue; IntervalMs: Integer): Integer;
procedure StopInterval(TimerId: Integer);
function StartTimeout(Callback: JSValue; DelayMs: Integer): Integer;
procedure StopTimeout(TimerId: Integer);

{ --- SPA Navigation Helpers --- }
procedure NavigateTo(const Path: string);
procedure GoBack;

{ --- Method & Invocation Helpers --- }
procedure CallMethod(Instance: JSValue; const MethodName: string); overload;
procedure CallMethod(Instance: JSValue; const MethodName: string; const Args: array of JSValue); overload;
function CallFunction(Instance: JSValue; const MethodName: string): JSValue; overload;
function CallFunction(Instance: JSValue; const MethodName: string; const Args: array of JSValue): JSValue; overload;
procedure Emit(Instance: JSValue; const EventName: string; Payload: JSValue = nil);

{ --- Component $refs Controller --- }
function TriggerRef(Instance: JSValue; const RefName, MethodName: string): Boolean;

{ --- Reactive Form Validation Helpers --- }
function ValidateForm(Instance: JSValue): Boolean;
procedure TouchValidation(Instance: JSValue);
procedure ResetValidation(Instance: JSValue);

{ --- Object & Array Helpers --- }
function NewObject: TJSObject;
function NewArray: TJSArray;
function ObjectAssign(Target, Source: JSValue): JSValue;
function JsonStringify(Value: JSValue): string;
function JsonParse(const Str: string): JSValue;
function NowTimestampStr: string;

{ --- Collection & Filtering Helpers --- }
function FilterByQuery(List: JSValue; Query: JSValue): JSValue;
function RemoveItemById(List: JSValue; Id: Integer): JSValue;
function FindItemById(List: JSValue; Id: Integer): JSValue;

{ --- Full-Stack mORMot 2 & API Client Helpers --- }
procedure ApiFetch(Instance: JSValue; const Endpoint: string; const PropertyName: string = 'items');
procedure ApiSave(Instance: JSValue; const Endpoint: string; Id: Integer; IsEditing: Boolean; AFormData: JSValue; const OnSuccessMethod: string = 'fetchItems'; const ErrorProp: string = 'formError');
procedure ApiDelete(Instance: JSValue; const Endpoint: string; Id: Integer; const ConfirmMsg: string = ''; const OnSuccessMethod: string = 'fetchItems');
procedure ApiSetupRealtime(Instance: JSValue; const ModelPrefix: string; const RefreshMethod: string = 'fetchItems');

{ --- Enterprise Authentication ($auth) Helpers --- }
procedure AuthLogin(Instance: JSValue; Email, Password: JSValue; const DefaultRedirect: string = '#/');
procedure AuthLogout(Instance: JSValue);

{ --- Mobile & Ionic Ecosystem ($ionic) Helpers --- }
function IonicGetMode: string;
procedure IonicSetMode(const Mode: string);
procedure IonicToast(const Msg: string; Duration: Integer = 2500; const Position: string = 'bottom'; const Color: string = 'success');
procedure IonicAlert(const Title, Subtitle, ButtonText: string);
procedure IonicConfirm(Instance: JSValue; const Title, Message: string; const OnConfirmMethod: string; const OnCancelMethod: string = ''); overload;
procedure IonicConfirm(const Title, Message: string; OnConfirm, OnCancel: TJSFunction); overload;
procedure IonicLoading(const Message: string; Duration: Integer = 2000);
procedure IonicActionSheet(Instance: JSValue; const Title: string; const Options: array of string; const OnSelectMethod: string); overload;
procedure IonicActionSheet(const Title: string; const Options: array of string; OnSelect: TJSFunction); overload;

{ --- WebAssembly Engine ($wasm) Helpers --- }
function WasmCall(Instance: JSValue; const ModName, FuncName: string; Arg: Integer): JSValue;
function WasmBenchmark(Instance: JSValue; const ModName, FuncName: string; Arg, Iterations: Integer): JSValue;
function NowTimestampMs: Double;

{ --- Chart & Visual Theming Helpers --- }
procedure UpdateChartDarkMode(OptionsObj: JSValue; Dark: Boolean);
procedure ThemeSet(const ThemeName: string);
procedure ThemeToggle;

{ --- I18n Internationalization Helpers --- }
procedure I18nAddMessages(const Locale: string; const JsonStr: string);
procedure I18nSetLocale(const Locale: string);

{ --- Dynamic Field Accessors --- }
function GetFieldStr(Obj: JSValue; const PropName: string; const DefaultVal: string = ''): string;
function GetFieldInt(Obj: JSValue; const PropName: string; DefaultVal: Integer = 0): Integer;
function GetFieldBool(Obj: JSValue; const PropName: string; DefaultVal: Boolean = False): Boolean;
procedure SetField(Obj: JSValue; const PropName: string; Value: JSValue);

{ --- LiveBindings & Reactive TBVDataSet Helpers (Phase 9 / 4.2) --- }
function NewDataSet: JSValue;
procedure DataSetLoad(DS: JSValue; Data: JSValue);
procedure DataSetAppend(DS: JSValue);
procedure DataSetEdit(DS: JSValue);
procedure DataSetPost(DS: JSValue);
procedure DataSetCancel(DS: JSValue);
procedure DataSetDelete(DS: JSValue);
procedure DataSetFirst(DS: JSValue);
procedure DataSetPrior(DS: JSValue);
procedure DataSetNext(DS: JSValue);
procedure DataSetLast(DS: JSValue);
function DataSetLocate(DS: JSValue; const AFieldName: string; AValue: JSValue): Boolean;
procedure DataSetFilter(DS: JSValue; const AQuery: string);
procedure DataSetSort(DS: JSValue; const AFieldName: string; Ascending: Boolean = True);
function DataSetFieldVal(DS: JSValue; const AFieldName: string): JSValue;
procedure DataSetSetFieldVal(DS: JSValue; const AFieldName: string; AValue: JSValue);
function DataSetDeltaJSON(DS: JSValue): string;
procedure DataSetApplyUpdates(DS: JSValue);
{ --- Offline-First TBVDataSet & Delta Sync Helpers (BlaiseVue 4.4 Pillar 2) --- }
procedure DataSetSaveIndexedDB(DS: JSValue; const StoreKey: string = ''; OnSuccess: JSValue = nil; OnError: JSValue = nil);
procedure DataSetLoadIndexedDB(DS: JSValue; const StoreKey: string = ''; OnComplete: JSValue = nil);
procedure DataSetSetAutoPersist(DS: JSValue; Enable: Boolean; const StoreKey: string = '');
procedure DataSetSetAutoSync(DS: JSValue; Enable: Boolean; const EndpointOrService: string = '');
procedure DataSetApplyUpdatesAsync(DS: JSValue; const EndpointOrService: string = ''; OnSuccess: JSValue = nil; OnError: JSValue = nil);
function DataSetHasPending(DS: JSValue): Boolean;
function DataSetChangeCount(DS: JSValue): Integer;
function DataSetDeltaList(DS: JSValue): JSValue;
procedure DataSetClearDelta(DS: JSValue);

{ --- Type-Safe mORMot 2 Pascal RPC Helpers (BlaiseVue 4.3) --- }
procedure RpcSetBaseUrl(const Url: string);
procedure RpcSetToken(const Token: string);
procedure RpcClearToken;
procedure RpcSetTransport(const Transport: string);
procedure RpcSetTimeout(TimeoutMs: Integer);
procedure RpcSetUsePack(Enable: Boolean);
function RpcCall(const ServiceName, MethodName: string; Params: JSValue = nil; OnSuccess: JSValue = nil; OnError: JSValue = nil): JSValue;
function RpcCallAsync(const ServiceName, MethodName: string; Params: JSValue = nil): JSValue;

{ --- BlaiseReports Enterprise Reporting Helpers (BlaiseVue 5.0 Pillar 1) --- }
function NewReport(DataSetOrArray: JSValue = nil): JSValue;
procedure ReportSetTitle(Report: JSValue; const ATitle: string; const ASubtitle: string = '');
procedure ReportSetHeader(Report: JSValue; const AHeader: string; const AFooter: string = '');
procedure ReportSetCompany(Report: JSValue; const ACompanyName: string; const ALogoText: string = '');
procedure ReportSetPageLayout(Report: JSValue; const ALayoutName: string);
procedure ReportSetColumns(Report: JSValue; const AFields: array of string);
procedure ReportAddColumn(Report: JSValue; const AFieldName, ACaption: string; AWidth: Integer = 120; const AAlign: string = 'left'; const AFormat: string = '');
procedure ReportAddSummary(Report: JSValue; const ALabel, AFieldName: string; const AAggregate: string = 'sum'; const AFormat: string = 'currency');
function ReportExportPDF(Report: JSValue; const AFileName: string = 'report.pdf'): string;
function ReportExportExcel(Report: JSValue; const AFileName: string = 'report.xlsx'): string;
function ReportExportCSV(Report: JSValue; const AFileName: string = 'report.csv'): string;
function ReportPrintPreview(Report: JSValue; const ATargetElementId: string = ''): string;
function ReportComputeSummary(Report: JSValue; const AFieldName: string; const AAggregate: string = 'sum'): Double;

implementation

procedure ShowToast(const Msg: string; DurationMs: Integer = 2500);
begin
  asm
    try {
      if (window.__BV_CORE__ && window.__BV_CORE__.ionic && window.__BV_CORE__.ionic.toast) {
        window.__BV_CORE__.ionic.toast(Msg, DurationMs);
        return;
      }
    } catch(e) {}
    
    let el = document.createElement('div');
    el.className = 'bv-pascal-toast';
    el.style.position = 'fixed';
    el.style.bottom = '24px';
    el.style.right = '24px';
    el.style.backgroundColor = '#1e293b';
    el.style.color = '#ffffff';
    el.style.padding = '12px 20px';
    el.style.borderRadius = '8px';
    el.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.2)';
    el.style.zIndex = '99999';
    el.style.fontSize = '14px';
    el.style.fontWeight = '500';
    el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    el.innerText = Msg;
    document.body.appendChild(el);
    setTimeout(function() {
      el.style.opacity = '0';
      el.style.transform = 'translateY(10px)';
      setTimeout(function() { if (el.parentNode) el.parentNode.removeChild(el); }, 350);
    }, DurationMs);
  end;
end;

procedure ShowAlert(const Msg: string);
begin
  asm window.alert(Msg); end;
end;

function Confirm(const Msg: string): Boolean;
begin
  asm Result = window.confirm(Msg); end;
end;

procedure ConsoleLog(const Msg: string);
begin
  asm console.log(Msg); end;
end;

function StartInterval(Callback: JSValue; IntervalMs: Integer): Integer;
begin
  asm
    Result = window.setInterval(function() {
      if (typeof Callback === 'function') Callback();
    }, IntervalMs);
  end;
end;

procedure StopInterval(TimerId: Integer);
begin
  asm
    window.clearInterval(TimerId);
  end;
end;

function StartTimeout(Callback: JSValue; DelayMs: Integer): Integer;
begin
  asm
    Result = window.setTimeout(function() {
      if (typeof Callback === 'function') Callback();
    }, DelayMs);
  end;
end;

procedure StopTimeout(TimerId: Integer);
begin
  asm
    window.clearTimeout(TimerId);
  end;
end;

procedure NavigateTo(const Path: string);
begin
  asm
    if (window.__BV_CORE__ && window.__BV_CORE__.router) {
      window.__BV_CORE__.router.push(Path);
    } else {
      window.location.hash = Path;
    }
  end;
end;

procedure GoBack;
begin
  asm window.history.back(); end;
end;

procedure CallMethod(Instance: JSValue; const MethodName: string);
begin
  asm
    if (Instance && typeof Instance[MethodName] === 'function') {
      Instance[MethodName]();
    }
  end;
end;

procedure CallMethod(Instance: JSValue; const MethodName: string; const Args: array of JSValue);
begin
  asm
    if (Instance && typeof Instance[MethodName] === 'function') {
      Instance[MethodName].apply(Instance, Args);
    }
  end;
end;

function CallFunction(Instance: JSValue; const MethodName: string): JSValue;
begin
  asm
    if (Instance && typeof Instance[MethodName] === 'function') {
      Result = Instance[MethodName]();
    } else {
      Result = null;
    }
  end;
end;

function CallFunction(Instance: JSValue; const MethodName: string; const Args: array of JSValue): JSValue;
begin
  asm
    if (Instance && typeof Instance[MethodName] === 'function') {
      Result = Instance[MethodName].apply(Instance, Args);
    } else {
      Result = null;
    }
  end;
end;

procedure Emit(Instance: JSValue; const EventName: string; Payload: JSValue = nil);
begin
  asm
    if (Instance && typeof Instance['$emit'] === 'function') {
      Instance['$emit'](EventName, Payload);
    }
  end;
end;

function TriggerRef(Instance: JSValue; const RefName, MethodName: string): Boolean;
begin
  asm
    Result = false;
    if (!Instance || !Instance.$refs) return;
    let r = Instance.$refs[RefName];
    if (!r) return;
    
    if (typeof r[MethodName] === 'function') {
      r[MethodName]();
      Result = true;
    } else if (MethodName === 'show' && typeof r.showModal === 'function') {
      r.showModal();
      Result = true;
    } else if (MethodName === 'show' && typeof r.showToast === 'function') {
      r.showToast();
      Result = true;
    } else if (MethodName === 'open' && typeof r.toggle === 'function') {
      r.toggle();
      Result = true;
    }
  end;
end;

function ValidateForm(Instance: JSValue): Boolean;
begin
  asm
    if (Instance && typeof Instance.$validate === 'function') {
      Result = Instance.$validate();
    } else {
      Result = true;
    }
  end;
end;

procedure TouchValidation(Instance: JSValue);
begin
  asm
    if (Instance && Instance.$v && typeof Instance.$v.$touch === 'function') {
      Instance.$v.$touch();
    }
  end;
end;

procedure ResetValidation(Instance: JSValue);
begin
  asm
    if (Instance && Instance.$v && typeof Instance.$v.$reset === 'function') {
      Instance.$v.$reset();
    }
  end;
end;

function NewObject: TJSObject;
begin
  Result := TJSObject.new;
end;

function NewArray: TJSArray;
begin
  Result := TJSArray.new;
end;

function ObjectAssign(Target, Source: JSValue): JSValue;
begin
  asm Result = Object.assign(Target || {}, Source || {}); end;
end;

function JsonStringify(Value: JSValue): string;
begin
  asm Result = JSON.stringify(Value); end;
end;

function JsonParse(const Str: string): JSValue;
begin
  asm
    try {
      Result = JSON.parse(Str);
    } catch(e) {
      Result = null;
    }
  end;
end;

function NowTimestampStr: string;
begin
  asm Result = String(Date.now()); end;
end;

function FilterByQuery(List: JSValue; Query: JSValue): JSValue;
begin
  asm
    let arr = List || [];
    let q = (Query !== undefined && Query !== null ? String(Query) : '').toLowerCase().trim();
    if (!q) { Result = arr; return Result; }
    if (!Array.isArray(arr)) { Result = arr; return Result; }
    
    Result = arr.filter(function(item) {
      if (!item) return false;
      return Object.values(item).some(function(v) {
        return String(v).toLowerCase().indexOf(q) !== -1;
      });
    });
  end;
end;

function RemoveItemById(List: JSValue; Id: Integer): JSValue;
begin
  asm
    let arr = List || [];
    if (!Array.isArray(arr)) { Result = arr; return Result; }
    Result = arr.filter(function(item) {
      return item && item.id !== Id;
    });
  end;
end;

function FindItemById(List: JSValue; Id: Integer): JSValue;
begin
  asm
    let arr = List || [];
    if (!Array.isArray(arr)) { Result = null; return Result; }
    let found = arr.find(function(item) {
      return item && item.id === Id;
    });
    Result = found || null;
  end;
end;

function GetFieldStr(Obj: JSValue; const PropName: string; const DefaultVal: string = ''): string;
begin
  asm
    if (Obj && typeof Obj === 'object' && Obj[PropName] !== undefined && Obj[PropName] !== null) {
      Result = String(Obj[PropName]);
    } else {
      Result = DefaultVal;
    }
  end;
end;

function GetFieldInt(Obj: JSValue; const PropName: string; DefaultVal: Integer = 0): Integer;
begin
  asm
    if (Obj && typeof Obj === 'object' && Obj[PropName] !== undefined && Obj[PropName] !== null) {
      let n = parseInt(Obj[PropName], 10);
      Result = isNaN(n) ? DefaultVal : n;
    } else {
      Result = DefaultVal;
    }
  end;
end;

function GetFieldBool(Obj: JSValue; const PropName: string; DefaultVal: Boolean = False): Boolean;
begin
  asm
    if (Obj && typeof Obj === 'object' && Obj[PropName] !== undefined && Obj[PropName] !== null) {
      Result = Boolean(Obj[PropName]);
    } else {
      Result = DefaultVal;
    }
  end;
end;

procedure SetField(Obj: JSValue; const PropName: string; Value: JSValue);
begin
  asm
    if (Obj && typeof Obj === 'object') {
      Obj[PropName] = Value;
    }
  end;
end;

{ --- LiveBindings & Reactive TBVDataSet Helpers (Phase 9 / 4.2) --- }

function NewDataSet: JSValue;
var
  ds: TBVDataSet;
begin
  ds := TBVDataSet.Create;
  Result := ds;
end;

procedure DataSetLoad(DS: JSValue; Data: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).LoadFromData(Data)
  else
  begin
    asm
      if (DS && typeof DS.LoadFromData === 'function') DS.LoadFromData(Data);
    end;
  end;
end;

procedure DataSetAppend(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Append
  else
  begin
    asm
      if (DS && typeof DS.Append === 'function') DS.Append();
    end;
  end;
end;

procedure DataSetEdit(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Edit
  else
  begin
    asm
      if (DS && typeof DS.Edit === 'function') DS.Edit();
    end;
  end;
end;

procedure DataSetPost(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Post
  else
  begin
    asm
      if (DS && typeof DS.Post === 'function') DS.Post();
    end;
  end;
end;

procedure DataSetCancel(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Cancel
  else
  begin
    asm
      if (DS && typeof DS.Cancel === 'function') DS.Cancel();
    end;
  end;
end;

procedure DataSetDelete(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Delete
  else
  begin
    asm
      if (DS && typeof DS.Delete === 'function') DS.Delete();
    end;
  end;
end;

procedure DataSetFirst(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).First
  else
  begin
    asm
      if (DS && typeof DS.First === 'function') DS.First();
    end;
  end;
end;

procedure DataSetPrior(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Prior
  else
  begin
    asm
      if (DS && typeof DS.Prior === 'function') DS.Prior();
    end;
  end;
end;

procedure DataSetNext(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Next
  else
  begin
    asm
      if (DS && typeof DS.Next === 'function') DS.Next();
    end;
  end;
end;

procedure DataSetLast(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).Last
  else
  begin
    asm
      if (DS && typeof DS.Last === 'function') DS.Last();
    end;
  end;
end;

function DataSetLocate(DS: JSValue; const AFieldName: string; AValue: JSValue): Boolean;
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    Result := TBVDataSet(DS).Locate(AFieldName, AValue)
  else
  begin
    Result := False;
    asm
      if (DS && typeof DS.Locate === 'function') {
        Result = Boolean(DS.Locate(AFieldName, AValue));
      }
    end;
  end;
end;

procedure DataSetFilter(DS: JSValue; const AQuery: string);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).SetFilter(AQuery)
  else
  begin
    asm
      if (DS && typeof DS.SetFilter === 'function') DS.SetFilter(AQuery);
    end;
  end;
end;

procedure DataSetSort(DS: JSValue; const AFieldName: string; Ascending: Boolean);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).SortBy(AFieldName, Ascending)
  else
  begin
    asm
      if (DS && typeof DS.SortBy === 'function') DS.SortBy(AFieldName, Ascending);
    end;
  end;
end;

function DataSetFieldVal(DS: JSValue; const AFieldName: string): JSValue;
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    Result := TBVDataSet(DS).FieldByName(AFieldName).Value
  else
  begin
    Result := '';
    asm
      if (!DS) return;
      if (typeof DS.FieldByName === 'function') {
        var f = DS.FieldByName(AFieldName);
        if (!f) return;
        Result = (typeof f.GetAsString === 'function') ? f.GetAsString() : (f.AsString !== undefined ? f.AsString : '');
      } else if (DS.Current) {
        Result = DS.Current[AFieldName] !== undefined ? DS.Current[AFieldName] : '';
      }
    end;
  end;
end;

procedure DataSetSetFieldVal(DS: JSValue; const AFieldName: string; AValue: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).FieldByName(AFieldName).Value := AValue
  else
  begin
    asm
      if (!DS) return;
      if (typeof DS.FieldByName === 'function') {
        var st = (typeof DS.GetStateStr === 'function') ? DS.GetStateStr() : DS.StateStr;
        if (st === 'browse') DS.Edit();
        var f = DS.FieldByName(AFieldName);
        if (f) {
          if (typeof f.SetAsString === 'function') f.SetAsString(String(AValue));
          else f.AsString = String(AValue);
        }
      } else if (DS.Current) {
        DS.Current[AFieldName] = AValue;
      }
    end;
  end;
end;

function DataSetDeltaJSON(DS: JSValue): string;
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    Result := TBVDataSet(DS).GetDeltaJSON
  else
  begin
    Result := '[]';
    asm
      if (DS && typeof DS.GetDeltaJSON === 'function') {
        Result = DS.GetDeltaJSON();
      }
    end;
  end;
end;

procedure DataSetApplyUpdates(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).ApplyUpdates
  else
  begin
    asm
      if (DS && typeof DS.ApplyUpdates === 'function') DS.ApplyUpdates();
    end;
  end;
end;

procedure DataSetSaveIndexedDB(DS: JSValue; const StoreKey: string; OnSuccess: JSValue; OnError: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).SaveToIndexedDB(StoreKey, OnSuccess, OnError)
  else
  begin
    asm
      if (DS && typeof DS.SaveToIndexedDB === 'function') DS.SaveToIndexedDB(StoreKey, OnSuccess, OnError);
    end;
  end;
end;

procedure DataSetLoadIndexedDB(DS: JSValue; const StoreKey: string; OnComplete: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).LoadFromIndexedDB(StoreKey, OnComplete)
  else
  begin
    asm
      if (DS && typeof DS.LoadFromIndexedDB === 'function') DS.LoadFromIndexedDB(StoreKey, OnComplete);
    end;
  end;
end;

procedure DataSetSetAutoPersist(DS: JSValue; Enable: Boolean; const StoreKey: string);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).SetAutoPersist(Enable, StoreKey)
  else
  begin
    asm
      if (DS && typeof DS.SetAutoPersist === 'function') DS.SetAutoPersist(Enable, StoreKey);
    end;
  end;
end;

procedure DataSetSetAutoSync(DS: JSValue; Enable: Boolean; const EndpointOrService: string);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).SetAutoSyncOnReconnect(Enable, EndpointOrService)
  else
  begin
    asm
      if (DS && typeof DS.SetAutoSyncOnReconnect === 'function') DS.SetAutoSyncOnReconnect(Enable, EndpointOrService);
    end;
  end;
end;

procedure DataSetApplyUpdatesAsync(DS: JSValue; const EndpointOrService: string; OnSuccess: JSValue; OnError: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).ApplyUpdates(EndpointOrService, OnSuccess, OnError)
  else
  begin
    asm
      if (DS && typeof DS.ApplyUpdates === 'function') DS.ApplyUpdates(EndpointOrService, OnSuccess, OnError);
    end;
  end;
end;

function DataSetHasPending(DS: JSValue): Boolean;
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    Result := TBVDataSet(DS).GetHasPendingChanges
  else
  begin
    asm
      if (DS && typeof DS.GetHasPendingChanges === 'function') Result = DS.GetHasPendingChanges();
      else if (DS && DS.HasPendingChanges !== undefined) Result = Boolean(DS.HasPendingChanges);
      else Result = false;
    end;
  end;
end;

function DataSetChangeCount(DS: JSValue): Integer;
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    Result := TBVDataSet(DS).ChangeCount
  else
  begin
    asm
      if (DS && typeof DS.GetChangeCount === 'function') Result = DS.GetChangeCount();
      else Result = 0;
    end;
  end;
end;

function DataSetDeltaList(DS: JSValue): JSValue;
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    Result := TBVDataSet(DS).Delta
  else
  begin
    asm
      if (DS && DS.FDelta) Result = DS.FDelta;
      else Result = [];
    end;
  end;
end;

procedure DataSetClearDelta(DS: JSValue);
begin
  if (DS <> nil) and (TObject(DS) is TBVDataSet) then
    TBVDataSet(DS).ClearDelta
  else
  begin
    asm
      if (DS && typeof DS.ClearDelta === 'function') DS.ClearDelta();
    end;
  end;
end;

procedure ApiFetch(Instance: JSValue; const Endpoint: string; const PropertyName: string = 'items');
begin
  asm
    var self = Instance;
    if (!self) return;
    var ep = Endpoint;
    var p = (self.$api && typeof self.$api.get === 'function')
      ? self.$api.get(ep)
      : fetch('http://localhost:8090' + ep).then(function(r) { return r.json(); });

    Promise.resolve(p).then(function(data) {
      if (Array.isArray(data)) {
        self[PropertyName] = data;
      } else if (data && Array.isArray(data.items)) {
        self[PropertyName] = data.items;
      }
    }).catch(function(err) {
      console.error('Error fetching ' + ep + ':', err);
    });
  end;
end;

procedure ApiSave(Instance: JSValue; const Endpoint: string; Id: Integer; IsEditing: Boolean; AFormData: JSValue; const OnSuccessMethod: string = 'fetchItems'; const ErrorProp: string = 'formError');
begin
  asm
    var self = Instance;
    var dataPayload = (typeof AFormData !== 'undefined' && AFormData !== window.FormData) ? AFormData : ((typeof aformdata !== 'undefined' && aformdata !== window.FormData) ? aformdata : null);
    if (!self || !dataPayload) return;
    if (self && typeof dataPayload === 'object' && dataPayload !== null) {
      for (var k in self) {
        if (k.indexOf('form.') === 0) {
          var fieldKey = k.substring(5);
          dataPayload[fieldKey] = self[k];
        }
      }
    }
    var ep = Endpoint + (IsEditing ? ('/' + Id) : '');
    var method = IsEditing ? 'put' : 'post';

    var p = (self.$api && typeof self.$api[method] === 'function')
      ? self.$api[method](ep, dataPayload)
      : fetch('http://localhost:8090' + ep, {
          method: method.toUpperCase(),
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(dataPayload)
        }).then(function(r) { return r.json(); });

    Promise.resolve(p).then(function(resp) {
      self.isModalOpen = false;
      if (OnSuccessMethod && typeof self[OnSuccessMethod] === 'function') {
        self[OnSuccessMethod]();
      }
    }).catch(function(err) {
      if (ErrorProp) {
        self[ErrorProp] = 'Failed to save: ' + (err.message || err);
      }
    });
  end;
end;

procedure ApiDelete(Instance: JSValue; const Endpoint: string; Id: Integer; const ConfirmMsg: string = ''; const OnSuccessMethod: string = 'fetchItems');
begin
  asm
    var self = Instance;
    if (!self) return;
    if (ConfirmMsg && !confirm(ConfirmMsg)) return;
    var ep = Endpoint + '/' + Id;

    var p = (self.$api && typeof self.$api.delete === 'function')
      ? self.$api.delete(ep)
      : fetch('http://localhost:8090' + ep, { method: 'DELETE' }).then(function(r) { return r.json(); });

    Promise.resolve(p).then(function() {
      if (OnSuccessMethod && typeof self[OnSuccessMethod] === 'function') {
        self[OnSuccessMethod]();
      }
    }).catch(function(err) {
      alert('Failed to delete: ' + (err.message || err));
    });
  end;
end;

procedure ApiSetupRealtime(Instance: JSValue; const ModelPrefix: string; const RefreshMethod: string = 'fetchItems');
begin
  asm
    var self = Instance;
    if (!self || !self.$ws) return;
    if (typeof self.$ws.connect === 'function') {
      self.$ws.connect();
    }
    var pfx = String(ModelPrefix).toLowerCase();
    if (typeof self.$ws.on === 'function') {
      self.$ws.on(pfx + '_created', function(d) {
        if (typeof self[RefreshMethod] === 'function') self[RefreshMethod]();
      });
      self.$ws.on(pfx + '_updated', function(d) {
        if (typeof self[RefreshMethod] === 'function') self[RefreshMethod]();
      });
      self.$ws.on(pfx + '_deleted', function(d) {
        if (typeof self[RefreshMethod] === 'function') self[RefreshMethod]();
      });
    }
  end;
end;

procedure AuthLogin(Instance: JSValue; Email, Password: JSValue; const DefaultRedirect: string = '#/');
begin
  asm
    var self = Instance;
    if (!self) return;
    self.loading = true;
    self.errorMessage = '';
    self.successMessage = '';

    if (!self.$auth || typeof self.$auth.login !== 'function') {
      self.errorMessage = 'Módulo $auth não inicializado.';
      self.loading = false;
      return;
    }

    var e = (Email !== undefined && Email !== null) ? String(Email) : '';
    var p = (Password !== undefined && Password !== null) ? String(Password) : '';

    self.$auth.login(e, p)
      .then(function(resp) {
        self.loading = false;
        self.successMessage = 'Autenticado com sucesso como ' + (resp.user ? resp.user.name : e) + '!';
        setTimeout(function() {
          var target = (window.__BV_CORE__.auth && window.__BV_CORE__.auth.redirectAfterLogin)
            ? window.__BV_CORE__.auth.redirectAfterLogin
            : DefaultRedirect;
          window.__BV_CORE__.auth.redirectAfterLogin = '';
          window.location.hash = target;
        }, 600);
      })
      .catch(function(err) {
        self.loading = false;
        self.errorMessage = (err && err.message) ? err.message : 'Falha na autenticação. Verifique os dados.';
      });
  end;
end;

procedure AuthLogout(Instance: JSValue);
begin
  asm
    var self = Instance;
    if (self && self.$auth && typeof self.$auth.logout === 'function') {
      self.$auth.logout();
    }
  end;
end;

function IonicGetMode: string;
begin
  asm
    if (window.$ionic && typeof window.$ionic.getMode === 'function') {
      Result = window.$ionic.getMode();
    } else {
      Result = 'md';
    }
  end;
end;

procedure IonicSetMode(const Mode: string);
begin
  asm
    if (window.$ionic && typeof window.$ionic.setMode === 'function') {
      window.$ionic.setMode(Mode);
    }
  end;
end;

procedure IonicToast(const Msg: string; Duration: Integer = 2500; const Position: string = 'bottom'; const Color: string = 'success');
begin
  asm
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.toast && typeof ionic.toast.show === 'function') {
      ionic.toast.show(Msg, Duration, Position, Color);
    }
  end;
end;

procedure IonicAlert(const Title, Subtitle, ButtonText: string);
begin
  asm
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.alert && typeof ionic.alert.alert === 'function') {
      ionic.alert.alert(Title, Subtitle, ButtonText);
    }
  end;
end;

procedure IonicConfirm(Instance: JSValue; const Title, Message: string; const OnConfirmMethod: string; const OnCancelMethod: string = '');
begin
  asm
    let self = Instance;
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.alert && typeof ionic.alert.confirm === 'function') {
      ionic.alert.confirm(Title, Message,
        function() {
          if (self && OnConfirmMethod && typeof self[OnConfirmMethod] === 'function') {
            self[OnConfirmMethod]();
          }
        },
        function() {
          if (self && OnCancelMethod && typeof self[OnCancelMethod] === 'function') {
            self[OnCancelMethod]();
          }
        }
      );
    }
  end;
end;

procedure IonicConfirm(const Title, Message: string; OnConfirm, OnCancel: TJSFunction);
begin
  asm
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.alert && typeof ionic.alert.confirm === 'function') {
      ionic.alert.confirm(Title, Message, OnConfirm, OnCancel);
    }
  end;
end;

procedure IonicLoading(const Message: string; Duration: Integer = 2000);
begin
  asm
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.loading && typeof ionic.loading.present === 'function') {
      ionic.loading.present(Message, Duration);
    }
  end;
end;

procedure IonicActionSheet(Instance: JSValue; const Title: string; const Options: array of string; const OnSelectMethod: string);
begin
  asm
    let self = Instance;
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.actionSheet && typeof ionic.actionSheet.show === 'function') {
      ionic.actionSheet.show(Title, Options, function(opt, idx) {
        if (self && OnSelectMethod && typeof self[OnSelectMethod] === 'function') {
          self[OnSelectMethod](opt, idx);
        }
      });
    }
  end;
end;

procedure IonicActionSheet(const Title: string; const Options: array of string; OnSelect: TJSFunction);
begin
  asm
    let ionic = window.$ionic || (window.__BV_CORE__ && window.__BV_CORE__.ionic);
    if (ionic && ionic.actionSheet && typeof ionic.actionSheet.show === 'function') {
      ionic.actionSheet.show(Title, Options, OnSelect);
    }
  end;
end;

function WasmCall(Instance: JSValue; const ModName, FuncName: string; Arg: Integer): JSValue;
begin
  asm
    if (Instance && Instance.$wasm && typeof Instance.$wasm.call === 'function') {
      Result = Instance.$wasm.call(ModName, FuncName, Arg);
    } else {
      Result = 0;
    }
  end;
end;

function WasmBenchmark(Instance: JSValue; const ModName, FuncName: string; Arg, Iterations: Integer): JSValue;
begin
  asm
    if (Instance && Instance.$wasm && typeof Instance.$wasm.benchmark === 'function') {
      Result = Instance.$wasm.benchmark(ModName, FuncName, Arg, Iterations);
    } else {
      Result = null;
    }
  end;
end;

function NowTimestampMs: Double;
begin
  asm
    if (typeof performance !== 'undefined' && typeof performance.now === 'function') {
      Result = performance.now();
    } else {
      Result = Date.now();
    }
  end;
end;

procedure UpdateChartDarkMode(OptionsObj: JSValue; Dark: Boolean);
begin
  asm
    if (OptionsObj) {
      const gridColor = Dark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(0, 0, 0, 0.08)';
      const textColor = Dark ? '#e2e8f0' : '#475569';

      if (!OptionsObj.scales) OptionsObj.scales = {};
      if (!OptionsObj.scales.x) OptionsObj.scales.x = {};
      if (!OptionsObj.scales.y) OptionsObj.scales.y = {};
      OptionsObj.scales.x.grid = { color: gridColor };
      OptionsObj.scales.y.grid = { color: gridColor };
      OptionsObj.scales.x.ticks = { color: textColor };
      OptionsObj.scales.y.ticks = { color: textColor };

      if (!OptionsObj.scales.r) OptionsObj.scales.r = {};
      OptionsObj.scales.r.grid = { color: gridColor };
      OptionsObj.scales.r.angleLines = { color: gridColor };
      OptionsObj.scales.r.pointLabels = { color: textColor };
      OptionsObj.scales.r.ticks = { color: textColor, backdropColor: 'transparent' };

      if (!OptionsObj.plugins) OptionsObj.plugins = {};
      if (!OptionsObj.plugins.legend) OptionsObj.plugins.legend = {};
      if (!OptionsObj.plugins.legend.labels) OptionsObj.plugins.legend.labels = {};
      OptionsObj.plugins.legend.labels.color = textColor;
    }
  end;
end;

procedure ThemeSet(const ThemeName: string);
begin
  asm
    if (window.$theme && typeof window.$theme.setTheme === 'function') {
      window.$theme.setTheme(ThemeName);
    }
  end;
end;

procedure ThemeToggle;
begin
  asm
    if (window.$theme && typeof window.$theme.toggle === 'function') {
      window.$theme.toggle();
    }
  end;
end;

procedure I18nAddMessages(const Locale: string; const JsonStr: string);
begin
  asm
    if (window.__BV_CORE__ && window.__BV_CORE__.i18n && typeof window.__BV_CORE__.i18n.addMessages === 'function') {
      try {
        var obj = JSON.parse(JsonStr);
        window.__BV_CORE__.i18n.addMessages(Locale, obj);
      } catch(e) {
        console.error('Invalid JSON for i18n messages:', e);
      }
    }
  end;
end;

procedure I18nSetLocale(const Locale: string);
begin
  asm
    if (window.__BV_CORE__ && window.__BV_CORE__.i18n && typeof window.__BV_CORE__.i18n.setLocale === 'function') {
      window.__BV_CORE__.i18n.setLocale(Locale);
    }
  end;
end;

procedure RpcSetBaseUrl(const Url: string);
begin
  TBVRpcClient.SetBaseUrl(Url);
end;

procedure RpcSetToken(const Token: string);
begin
  TBVRpcClient.SetToken(Token);
end;

procedure RpcClearToken;
begin
  TBVRpcClient.ClearToken;
end;

procedure RpcSetTransport(const Transport: string);
begin
  TBVRpcClient.SetTransport(Transport);
end;

procedure RpcSetTimeout(TimeoutMs: Integer);
begin
  TBVRpcClient.SetTimeout(TimeoutMs);
end;

procedure RpcSetUsePack(Enable: Boolean);
begin
  TBVRpcClient.SetUsePack(Enable);
end;

function RpcCall(const ServiceName, MethodName: string; Params: JSValue; OnSuccess: JSValue; OnError: JSValue): JSValue;
begin
  Result := TBVRpcClient.Invoke(ServiceName, MethodName, Params, OnSuccess, OnError);
end;

function RpcCallAsync(const ServiceName, MethodName: string; Params: JSValue): JSValue;
begin
  Result := TBVRpcClient.InvokeAsync(ServiceName, MethodName, Params);
end;

{ --- BlaiseReports Enterprise Reporting Helpers (BlaiseVue 5.0 Pillar 1) --- }

function NewReport(DataSetOrArray: JSValue = nil): JSValue;
begin
  Result := TBVReport.Create(DataSetOrArray);
end;

procedure ReportSetTitle(Report: JSValue; const ATitle: string; const ASubtitle: string = '');
begin
  if Report <> nil then
  begin
    TBVReport(Report).Title(ATitle);
    if ASubtitle <> '' then
      TBVReport(Report).Subtitle(ASubtitle);
  end;
end;

procedure ReportSetHeader(Report: JSValue; const AHeader: string; const AFooter: string = '');
begin
  if Report <> nil then
  begin
    TBVReport(Report).Header(AHeader);
    if AFooter <> '' then
      TBVReport(Report).Footer(AFooter);
  end;
end;

procedure ReportSetCompany(Report: JSValue; const ACompanyName: string; const ALogoText: string = '');
begin
  if Report <> nil then
    TBVReport(Report).Company(ACompanyName, ALogoText);
end;

procedure ReportSetPageLayout(Report: JSValue; const ALayoutName: string);
begin
  if Report <> nil then
    TBVReport(Report).PageSize(ALayoutName);
end;

procedure ReportSetColumns(Report: JSValue; const AFields: array of string);
begin
  if Report <> nil then
    TBVReport(Report).Columns(AFields);
end;

procedure ReportAddColumn(Report: JSValue; const AFieldName, ACaption: string; AWidth: Integer = 120; const AAlign: string = 'left'; const AFormat: string = '');
begin
  if Report <> nil then
    TBVReport(Report).AddColumn(AFieldName, ACaption, AWidth, ParseColumnAlign(AAlign), AFormat);
end;

procedure ReportAddSummary(Report: JSValue; const ALabel, AFieldName: string; const AAggregate: string = 'sum'; const AFormat: string = 'currency');
begin
  if Report <> nil then
    TBVReport(Report).AddSummary(ALabel, AFieldName, ParseAggregateType(AAggregate), AFormat);
end;

function ReportExportPDF(Report: JSValue; const AFileName: string = 'report.pdf'): string;
begin
  if Report <> nil then
    Result := TBVReport(Report).ExportPDF(AFileName)
  else
    Result := '';
end;

function ReportExportExcel(Report: JSValue; const AFileName: string = 'report.xlsx'): string;
begin
  if Report <> nil then
    Result := TBVReport(Report).ExportExcel(AFileName)
  else
    Result := '';
end;

function ReportExportCSV(Report: JSValue; const AFileName: string = 'report.csv'): string;
begin
  if Report <> nil then
    Result := TBVReport(Report).ExportCSV(AFileName)
  else
    Result := '';
end;

function ReportPrintPreview(Report: JSValue; const ATargetElementId: string = ''): string;
begin
  if Report <> nil then
    Result := TBVReport(Report).PrintPreview(ATargetElementId)
  else
    Result := '';
end;

function ReportComputeSummary(Report: JSValue; const AFieldName: string; const AAggregate: string = 'sum'): Double;
begin
  if Report <> nil then
    Result := TBVReport(Report).ComputeSummary(AFieldName, ParseAggregateType(AAggregate))
  else
    Result := 0.0;
end;

procedure RetainDXDataSetSymbols;
var
  dummy: JSValue;
begin
  if False then
  begin
    dummy := NewDataSet;
    DataSetLoad(dummy, nil);
    DataSetAppend(dummy);
    DataSetEdit(dummy);
    DataSetPost(dummy);
    DataSetCancel(dummy);
    DataSetDelete(dummy);
    DataSetFirst(dummy);
    DataSetPrior(dummy);
    DataSetNext(dummy);
    DataSetLast(dummy);
    DataSetLocate(dummy, '', nil);
    DataSetFilter(dummy, '');
    DataSetSort(dummy, '', True);
    DataSetFieldVal(dummy, '');
    DataSetSetFieldVal(dummy, '', nil);
    DataSetDeltaJSON(dummy);
    DataSetApplyUpdates(dummy);
    DataSetSaveIndexedDB(dummy, '', nil, nil);
    DataSetLoadIndexedDB(dummy, '', nil);
    DataSetSetAutoPersist(dummy, False, '');
    DataSetSetAutoSync(dummy, False, '');
    DataSetApplyUpdatesAsync(dummy, '', nil, nil);
    DataSetHasPending(dummy);
    DataSetChangeCount(dummy);
    DataSetDeltaList(dummy);
    DataSetClearDelta(dummy);
    RpcSetBaseUrl('');
    RpcSetToken('');
    RpcClearToken;
    RpcSetTransport('');
    RpcSetTimeout(0);
    RpcSetUsePack(False);
    RpcCall('', '', nil, nil, nil);
    RpcCallAsync('', '', nil);
    dummy := NewReport(nil);
    ReportSetTitle(dummy, '', '');
    ReportSetHeader(dummy, '', '');
    ReportSetCompany(dummy, '', '');
    ReportSetPageLayout(dummy, '');
    ReportSetColumns(dummy, ['']);
    ReportAddColumn(dummy, '', '', 100, '', '');
    ReportAddSummary(dummy, '', '', '', '');
    ReportExportPDF(dummy, '');
    ReportExportExcel(dummy, '');
    ReportExportCSV(dummy, '');
    ReportPrintPreview(dummy, '');
    ReportComputeSummary(dummy, '', '');
  end;
end;

initialization
  RetainDXDataSetSymbols;

end.