unit BVMiddleware;

{
  BVMiddleware - Action & Mutation Pipeline for BlaiseX (Pillar 1 Step 3)
  ------------------------------------------------------------------------
  Enterprise middleware pipeline for TBVStore 2.0.
  Allows intercepting actions, mutations, and state transitions before and
  after execution.

  Includes built-in enterprise middlewares:
  - TBVLoggerMiddleware: Grouped console logging with payload, state diffs & timing
  - TBVAuthGuardMiddleware: Role-Based Access Control (RBAC) & permission guards
  - TBVTelemetryMiddleware: Performance metrics, execution timers & slow action alerts
}

{$mode objfpc}

interface

uses JS, Web, SysUtils;

type
  TBVMiddlewareKind = (mkMutation, mkAction, mkTransition);

  { Execution Context passed down through the middleware pipeline }
  TBVMiddlewareContext = class
  private
    FSliceName: string;
    FTargetName: string;
    FKind: TBVMiddlewareKind;
    FPayload: JSValue;
    FStateBefore: JSValue;
    FStateAfter: JSValue;
    FStartTime: Double;
    FDurationMs: Double;
    FCancelled: Boolean;
    FCancelReason: string;
    FMetadata: TJSObject;
  public
    constructor Create(const ASliceName, ATargetName: string; AKind: TBVMiddlewareKind; APayload, AStateBefore: JSValue);
    
    procedure Cancel(const AReason: string);
    procedure Complete(AStateAfter: JSValue);
    function KindStr: string;

    property SliceName: string read FSliceName;
    property TargetName: string read FTargetName;
    property Kind: TBVMiddlewareKind read FKind;
    property Payload: JSValue read FPayload write FPayload;
    property StateBefore: JSValue read FStateBefore;
    property StateAfter: JSValue read FStateAfter;
    property StartTime: Double read FStartTime;
    property DurationMs: Double read FDurationMs;
    property Cancelled: Boolean read FCancelled;
    property CancelReason: string read FCancelReason;
    property Metadata: TJSObject read FMetadata;
  end;

  { Base Abstract Middleware Class }
  TBVMiddleware = class
  public
    function Name: string; virtual;
    procedure Before(Context: TBVMiddlewareContext); virtual;
    procedure After(Context: TBVMiddlewareContext); virtual;
    procedure OnError(Context: TBVMiddlewareContext; E: Exception); virtual;
  end;

  { Procedural / Anonymous function callback signatures }
  TBVMiddlewareBeforeProc = reference to procedure(Context: TBVMiddlewareContext);
  TBVMiddlewareAfterProc = reference to procedure(Context: TBVMiddlewareContext);
  TBVMiddlewareErrorProc = reference to procedure(Context: TBVMiddlewareContext; E: Exception);

  { Functional Adapter Middleware for quick closures }
  TBVFunctionalMiddleware = class(TBVMiddleware)
  private
    FName: string;
    FBefore: TBVMiddlewareBeforeProc;
    FAfter: TBVMiddlewareAfterProc;
    FError: TBVMiddlewareErrorProc;
  public
    constructor Create(const AName: string; ABefore: TBVMiddlewareBeforeProc = nil; AAfter: TBVMiddlewareAfterProc = nil; AError: TBVMiddlewareErrorProc = nil);
    function Name: string; override;
    procedure Before(Context: TBVMiddlewareContext); override;
    procedure After(Context: TBVMiddlewareContext); override;
    procedure OnError(Context: TBVMiddlewareContext; E: Exception); override;
  end;

  { 1. Enterprise Console Logger Middleware }
  TBVLoggerMiddleware = class(TBVMiddleware)
  private
    FEnabled: Boolean;
    FLogStateDiff: Boolean;
  public
    constructor Create(AEnabled: Boolean = True; ALogStateDiff: Boolean = True);
    function Name: string; override;
    procedure Before(Context: TBVMiddlewareContext); override;
    procedure After(Context: TBVMiddlewareContext); override;
    procedure OnError(Context: TBVMiddlewareContext; E: Exception); override;
    property Enabled: Boolean read FEnabled write FEnabled;
    property LogStateDiff: Boolean read FLogStateDiff write FLogStateDiff;
  end;

  { 2. Role-Based Access Control (RBAC) & Permission Guard Middleware }
  TBVAuthRuleFunc = reference to function(Context: TBVMiddlewareContext): Boolean;

  TBVAuthGuardMiddleware = class(TBVMiddleware)
  private
    FRules: TJSObject; { Key: Target (or Target + '#' + Role) -> Rule }
    FCurrentUserRole: string;
    FCurrentUserPerms: TJSArray;
  public
    constructor Create;
    function Name: string; override;
    procedure SetUserContext(const ARole: string; const APermissions: array of string);
    procedure Rule(const ATarget: string; const ARequiredRole: string; const ARequiredPerm: string = '');
    procedure CustomRule(const ATarget: string; ARuleFn: TBVAuthRuleFunc);
    procedure Before(Context: TBVMiddlewareContext); override;
    property CurrentUserRole: string read FCurrentUserRole write FCurrentUserRole;
  end;

  { 3. Enterprise Telemetry & Performance Metrics Middleware }
  TBVTelemetryMetric = class
  public
    Target: string;
    Kind: string;
    TotalCalls: Integer;
    TotalDurationMs: Double;
    AvgDurationMs: Double;
    MaxDurationMs: Double;
    MinDurationMs: Double;
    SlowCallsCount: Integer;
  end;

  TBVTelemetryMiddleware = class(TBVMiddleware)
  private
    FMetrics: TJSObject; { Target -> TBVTelemetryMetric }
    FSlowThresholdMs: Double;
    FHistory: TJSArray;
  public
    constructor Create(ASlowThresholdMs: Double = 50.0);
    destructor Destroy; override;
    function Name: string; override;
    procedure After(Context: TBVMiddlewareContext); override;

    function GetMetric(const ATarget: string): TBVTelemetryMetric;
    function GetMetricsArray: TJSArray;
    function GetTotalRecordedCalls: Integer;
    procedure ResetMetrics;

    property SlowThresholdMs: Double read FSlowThresholdMs write FSlowThresholdMs;
  end;

  { Pipeline manager executing an ordered sequence of middlewares }
  TBVMiddlewarePipeline = class
  private
    FItems: TJSArray; { Array of TBVMiddleware }
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AMiddleware: TBVMiddleware);
    procedure Remove(const AName: string);
    function Count: Integer;
    function Item(AIndex: Integer): TBVMiddleware;

    function ExecuteBefore(Context: TBVMiddlewareContext): Boolean;
    procedure ExecuteAfter(Context: TBVMiddlewareContext);
    procedure ExecuteError(Context: TBVMiddlewareContext; E: Exception);
  end;

implementation

{ ============================================================================ }
{ TBVMiddlewareContext                                                         }
{ ============================================================================ }

constructor TBVMiddlewareContext.Create(const ASliceName, ATargetName: string; AKind: TBVMiddlewareKind; APayload, AStateBefore: JSValue);
begin
  inherited Create;
  FSliceName := ASliceName;
  FTargetName := ATargetName;
  FKind := AKind;
  FPayload := APayload;
  FStateBefore := AStateBefore;
  FStateAfter := nil;
  FStartTime := TJSDate.now;
  FDurationMs := 0.0;
  FCancelled := False;
  FCancelReason := '';
  FMetadata := TJSObject.new;
end;

procedure TBVMiddlewareContext.Cancel(const AReason: string);
begin
  FCancelled := True;
  FCancelReason := AReason;
end;

procedure TBVMiddlewareContext.Complete(AStateAfter: JSValue);
begin
  FStateAfter := AStateAfter;
  FDurationMs := TJSDate.now - FStartTime;
end;

function TBVMiddlewareContext.KindStr: string;
begin
  case FKind of
    mkMutation: Result := 'MUTATION';
    mkAction: Result := 'ACTION';
    mkTransition: Result := 'TRANSITION';
  else
    Result := 'UNKNOWN';
  end;
end;

{ ============================================================================ }
{ TBVMiddleware Base                                                           }
{ ============================================================================ }

function TBVMiddleware.Name: string;
begin
  Result := 'BaseMiddleware';
end;

procedure TBVMiddleware.Before(Context: TBVMiddlewareContext);
begin
  // No-op by default
end;

procedure TBVMiddleware.After(Context: TBVMiddlewareContext);
begin
  // No-op by default
end;

procedure TBVMiddleware.OnError(Context: TBVMiddlewareContext; E: Exception);
begin
  // No-op by default
end;

{ ============================================================================ }
{ TBVFunctionalMiddleware                                                      }
{ ============================================================================ }

constructor TBVFunctionalMiddleware.Create(const AName: string; ABefore: TBVMiddlewareBeforeProc; AAfter: TBVMiddlewareAfterProc; AError: TBVMiddlewareErrorProc);
begin
  inherited Create;
  FName := AName;
  FBefore := ABefore;
  FAfter := AAfter;
  FError := AError;
end;

function TBVFunctionalMiddleware.Name: string;
begin
  Result := FName;
end;

procedure TBVFunctionalMiddleware.Before(Context: TBVMiddlewareContext);
begin
  if Assigned(FBefore) then FBefore(Context);
end;

procedure TBVFunctionalMiddleware.After(Context: TBVMiddlewareContext);
begin
  if Assigned(FAfter) then FAfter(Context);
end;

procedure TBVFunctionalMiddleware.OnError(Context: TBVMiddlewareContext; E: Exception);
begin
  if Assigned(FError) then FError(Context, E);
end;

{ ============================================================================ }
{ TBVLoggerMiddleware                                                          }
{ ============================================================================ }

constructor TBVLoggerMiddleware.Create(AEnabled: Boolean; ALogStateDiff: Boolean);
begin
  inherited Create;
  FEnabled := AEnabled;
  FLogStateDiff := ALogStateDiff;
end;

function TBVLoggerMiddleware.Name: string;
begin
  Result := 'Logger';
end;

procedure TBVLoggerMiddleware.Before(Context: TBVMiddlewareContext);
var
  Title: string;
begin
  if not FEnabled then Exit;
  Title := '[BlaiseX: ' + Context.SliceName + '] ' + Context.KindStr + ' ' + Context.TargetName;
  asm
    if (typeof console !== 'undefined' && console.groupCollapsed) {
      console.groupCollapsed('%c' + Title, 'color: #3b82f6; font-weight: bold;');
      console.log('%cPayload:', 'color: #10b981; font-weight: bold;', Context.FPayload);
      if (this.FLogStateDiff && Context.FStateBefore) {
        console.log('%cState Before:', 'color: #6b7280; font-weight: bold;', Context.FStateBefore);
      }
    }
  end;
end;

procedure TBVLoggerMiddleware.After(Context: TBVMiddlewareContext);
begin
  if not FEnabled then Exit;
  asm
    if (typeof console !== 'undefined' && console.groupEnd) {
      if (this.FLogStateDiff && Context.FStateAfter) {
        console.log('%cState After:', 'color: #8b5cf6; font-weight: bold;', Context.FStateAfter);
      }
      console.log('%cDuration:', 'color: #f59e0b; font-weight: bold;', Context.FDurationMs.toFixed(2) + ' ms');
      console.groupEnd();
    }
  end;
end;

procedure TBVLoggerMiddleware.OnError(Context: TBVMiddlewareContext; E: Exception);
begin
  if not FEnabled then Exit;
  asm
    if (typeof console !== 'undefined' && console.error) {
      console.error('%c[BlaiseX Error in ' + Context.TargetName + ']:', 'color: #ef4444; font-weight: bold;', E.message);
      if (console.groupEnd) console.groupEnd();
    }
  end;
end;

{ ============================================================================ }
{ TBVAuthGuardMiddleware                                                       }
{ ============================================================================ }

constructor TBVAuthGuardMiddleware.Create;
begin
  inherited Create;
  FRules := TJSObject.new;
  FCurrentUserRole := 'guest';
  FCurrentUserPerms := TJSArray.new;
end;

function TBVAuthGuardMiddleware.Name: string;
begin
  Result := 'AuthGuard';
end;

procedure TBVAuthGuardMiddleware.SetUserContext(const ARole: string; const APermissions: array of string);
var
  i: Integer;
begin
  FCurrentUserRole := LowerCase(Trim(ARole));
  FCurrentUserPerms := TJSArray.new;
  for i := Low(APermissions) to High(APermissions) do
    FCurrentUserPerms.push(LowerCase(Trim(APermissions[i])));
end;

procedure TBVAuthGuardMiddleware.Rule(const ATarget: string; const ARequiredRole: string; const ARequiredPerm: string);
var
  RuleObj: TJSObject;
  CleanTarget: string;
begin
  CleanTarget := Trim(ATarget);
  RuleObj := TJSObject.new;
  RuleObj['role'] := LowerCase(Trim(ARequiredRole));
  RuleObj['perm'] := LowerCase(Trim(ARequiredPerm));
  RuleObj['custom'] := nil;
  FRules[CleanTarget] := RuleObj;
end;

procedure TBVAuthGuardMiddleware.CustomRule(const ATarget: string; ARuleFn: TBVAuthRuleFunc);
var
  RuleObj: TJSObject;
  CleanTarget: string;
begin
  CleanTarget := Trim(ATarget);
  RuleObj := TJSObject.new;
  RuleObj['role'] := '';
  RuleObj['perm'] := '';
  RuleObj['custom'] := ARuleFn;
  FRules[CleanTarget] := RuleObj;
end;

procedure TBVAuthGuardMiddleware.Before(Context: TBVMiddlewareContext);
var
  Key, NamespacedKey: string;
  RuleObj: TJSObject;
  ReqRole, ReqPerm: string;
  CustomFn: TBVAuthRuleFunc;
  i: Integer;
  HasPerm: Boolean;
begin
  Key := Context.TargetName;
  NamespacedKey := Context.SliceName + '/' + Key;

  RuleObj := nil;
  if Boolean(FRules.hasOwnProperty(NamespacedKey)) then
    RuleObj := TJSObject(FRules[NamespacedKey])
  else if Boolean(FRules.hasOwnProperty(Key)) then
    RuleObj := TJSObject(FRules[Key]);

  if RuleObj = nil then Exit; { No restriction defined }

  { Custom callback rule }
  if RuleObj['custom'] <> nil then
  begin
    CustomFn := TBVAuthRuleFunc(RuleObj['custom']);
    if Assigned(CustomFn) and (not CustomFn(Context)) then
    begin
      Context.Cancel('Access denied: Custom auth guard rejected execution of "' + Key + '".');
      Exit;
    end;
  end;

  { Role restriction }
  ReqRole := string(RuleObj['role']);
  if (ReqRole <> '') and (FCurrentUserRole <> ReqRole) and (FCurrentUserRole <> 'admin') and (FCurrentUserRole <> 'root') then
  begin
    Context.Cancel('Access denied: Action "' + Key + '" requires role "' + ReqRole + '", got "' + FCurrentUserRole + '".');
    Exit;
  end;

  { Permission restriction }
  ReqPerm := string(RuleObj['perm']);
  if ReqPerm <> '' then
  begin
    HasPerm := False;
    for i := 0 to Integer(FCurrentUserPerms.length) - 1 do
    begin
      if string(FCurrentUserPerms[i]) = ReqPerm then
      begin
        HasPerm := True;
        Break;
      end;
    end;
    if (not HasPerm) and (FCurrentUserRole <> 'admin') and (FCurrentUserRole <> 'root') then
    begin
      Context.Cancel('Access denied: Missing required permission "' + ReqPerm + '" for "' + Key + '".');
      Exit;
    end;
  end;
end;

{ ============================================================================ }
{ TBVTelemetryMiddleware                                                       }
{ ============================================================================ }

constructor TBVTelemetryMiddleware.Create(ASlowThresholdMs: Double);
begin
  inherited Create;
  FMetrics := TJSObject.new;
  FSlowThresholdMs := ASlowThresholdMs;
  FHistory := TJSArray.new;
end;

destructor TBVTelemetryMiddleware.Destroy;
var
  Keys: TJSStringDynArray;
  i: Integer;
  M: TBVTelemetryMetric;
begin
  Keys := TJSObject.keys(FMetrics);
  for i := 0 to Length(Keys) - 1 do
  begin
    M := TBVTelemetryMetric(FMetrics[Keys[i]]);
    M.Free;
  end;
  inherited Destroy;
end;

function TBVTelemetryMiddleware.Name: string;
begin
  Result := 'Telemetry';
end;

function TBVTelemetryMiddleware.GetMetric(const ATarget: string): TBVTelemetryMetric;
var
  CleanTarget: string;
  M: TBVTelemetryMetric;
begin
  CleanTarget := Trim(ATarget);
  if Boolean(FMetrics.hasOwnProperty(CleanTarget)) then
    Result := TBVTelemetryMetric(FMetrics[CleanTarget])
  else
  begin
    M := TBVTelemetryMetric.Create;
    M.Target := CleanTarget;
    M.Kind := '';
    M.TotalCalls := 0;
    M.TotalDurationMs := 0.0;
    M.AvgDurationMs := 0.0;
    M.MaxDurationMs := 0.0;
    M.MinDurationMs := 9999999.0;
    M.SlowCallsCount := 0;
    FMetrics[CleanTarget] := M;
    Result := M;
  end;
end;

function TBVTelemetryMiddleware.GetMetricsArray: TJSArray;
var
  Keys: TJSStringDynArray;
  i: Integer;
begin
  Result := TJSArray.new;
  Keys := TJSObject.keys(FMetrics);
  for i := 0 to Length(Keys) - 1 do
    Result.push(FMetrics[Keys[i]]);
end;

function TBVTelemetryMiddleware.GetTotalRecordedCalls: Integer;
begin
  Result := Integer(FHistory.length);
end;

procedure TBVTelemetryMiddleware.ResetMetrics;
var
  Keys: TJSStringDynArray;
  i: Integer;
  M: TBVTelemetryMetric;
begin
  Keys := TJSObject.keys(FMetrics);
  for i := 0 to Length(Keys) - 1 do
  begin
    M := TBVTelemetryMetric(FMetrics[Keys[i]]);
    M.Free;
  end;
  FMetrics := TJSObject.new;
  FHistory := TJSArray.new;
end;

procedure TBVTelemetryMiddleware.After(Context: TBVMiddlewareContext);
var
  FullTarget: string;
  M: TBVTelemetryMetric;
  Dur: Double;
  HistItem: TJSObject;
begin
  FullTarget := Context.SliceName + '/' + Context.TargetName;
  Dur := Context.DurationMs;
  M := GetMetric(FullTarget);

  M.Kind := Context.KindStr;
  M.TotalCalls := M.TotalCalls + 1;
  M.TotalDurationMs := M.TotalDurationMs + Dur;
  M.AvgDurationMs := M.TotalDurationMs / M.TotalCalls;

  if Dur > M.MaxDurationMs then
    M.MaxDurationMs := Dur;
  if Dur < M.MinDurationMs then
    M.MinDurationMs := Dur;

  if Dur >= FSlowThresholdMs then
    M.SlowCallsCount := M.SlowCallsCount + 1;

  HistItem := TJSObject.new;
  HistItem['target'] := FullTarget;
  HistItem['kind'] := Context.KindStr;
  HistItem['duration'] := Dur;
  HistItem['timestamp'] := Context.StartTime;
  FHistory.push(HistItem);
end;

{ ============================================================================ }
{ TBVMiddlewarePipeline                                                        }
{ ============================================================================ }

constructor TBVMiddlewarePipeline.Create;
begin
  inherited Create;
  FItems := TJSArray.new;
end;

destructor TBVMiddlewarePipeline.Destroy;
begin
  inherited Destroy;
end;

procedure TBVMiddlewarePipeline.Add(AMiddleware: TBVMiddleware);
begin
  if AMiddleware <> nil then
    FItems.push(AMiddleware);
end;

procedure TBVMiddlewarePipeline.Remove(const AName: string);
var
  i: Integer;
  M: TBVMiddleware;
begin
  for i := Integer(FItems.length) - 1 downto 0 do
  begin
    M := TBVMiddleware(FItems[i]);
    if M.Name = AName then
    begin
      FItems.splice(i, 1);
      Break;
    end;
  end;
end;

function TBVMiddlewarePipeline.Count: Integer;
begin
  Result := Integer(FItems.length);
end;

function TBVMiddlewarePipeline.Item(AIndex: Integer): TBVMiddleware;
begin
  if (AIndex >= 0) and (AIndex < Integer(FItems.length)) then
    Result := TBVMiddleware(FItems[AIndex])
  else
    Result := nil;
end;

function TBVMiddlewarePipeline.ExecuteBefore(Context: TBVMiddlewareContext): Boolean;
var
  i: Integer;
  M: TBVMiddleware;
begin
  Result := True;
  for i := 0 to Integer(FItems.length) - 1 do
  begin
    M := TBVMiddleware(FItems[i]);
    try
      M.Before(Context);
      if Context.Cancelled then
        Exit(False);
    except
      on E: Exception do
      begin
        Context.Cancel('Middleware "' + M.Name + '" failed: ' + E.Message);
        Exit(False);
      end;
    end;
  end;
end;

procedure TBVMiddlewarePipeline.ExecuteAfter(Context: TBVMiddlewareContext);
var
  i: Integer;
  M: TBVMiddleware;
begin
  for i := 0 to Integer(FItems.length) - 1 do
  begin
    M := TBVMiddleware(FItems[i]);
    try
      M.After(Context);
    except
      // Middlewares must not crash the after-phase
    end;
  end;
end;

procedure TBVMiddlewarePipeline.ExecuteError(Context: TBVMiddlewareContext; E: Exception);
var
  i: Integer;
  M: TBVMiddleware;
begin
  for i := 0 to Integer(FItems.length) - 1 do
  begin
    M := TBVMiddleware(FItems[i]);
    try
      M.OnError(Context, E);
    except
    end;
  end;
end;

end.
