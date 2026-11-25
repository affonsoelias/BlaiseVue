program middleware_test;

{$mode objfpc}

uses JS, Web, SysUtils, BVStore, BVMiddleware, BVTestUtils;

var
  OrderSlice, SecureSlice, PerfSlice: TBVStoreSlice;
  OrderState, SecureState, PerfState: TJSObject;
  AuthGuard: TBVAuthGuardMiddleware;
  Telemetry: TBVTelemetryMiddleware;
  Logger: TBVLoggerMiddleware;
  HookCalls: TJSArray;
  CapturedDuration: Double;
  Metric: TBVTelemetryMetric;

begin
  Describe('BVMiddleware - Action & Mutation Pipeline (BlaiseX Pillar 1 Step 3)', procedure
    begin
      It('deve interceptar mutacoes e acoes antes e depois da execucao', procedure
        begin
          HookCalls := TJSArray.new;
          CapturedDuration := 0.0;

          OrderState := TJSObject.new;
          OrderState['status'] := 'draft';
          OrderSlice := DefineStore('order_mid', OrderState);

          OrderSlice.Mutation('publish', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['status'] := 'published';
            end);

          // Registra middleware funcional
          OrderSlice.Use(
            procedure(Ctx: TBVMiddlewareContext)
            begin
              HookCalls.push('before_' + Ctx.TargetName);
            end,
            procedure(Ctx: TBVMiddlewareContext)
            begin
              HookCalls.push('after_' + Ctx.TargetName);
              CapturedDuration := Ctx.DurationMs;
            end
          );

          Expect(Integer(HookCalls.length)).ToBe(0);

          OrderSlice.Commit('publish');

          Expect(Integer(HookCalls.length)).ToBe(2);
          Expect(string(HookCalls[0])).ToBe('before_publish');
          Expect(string(HookCalls[1])).ToBe('after_publish');
          Expect(string(TJSObject(OrderSlice.State)['status'])).ToBe('published');
          Expect(CapturedDuration >= 0.0).ToBe(True);
        end);

      It('deve abortar mutacoes quando o middleware chamar Context.Cancel', procedure
        var
          ErrCaught: Boolean;
        begin
          OrderState := TJSObject.new;
          OrderState['amount'] := 0.0;
          OrderSlice := DefineStore('order_cancel', OrderState);

          OrderSlice.Mutation('setAmount', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['amount'] := Double(APayload);
            end);

          // Middleware de validacao que cancela se valor for negativo
          OrderSlice.Use(procedure(Ctx: TBVMiddlewareContext)
            begin
              if (Ctx.Payload <> nil) and (Double(Ctx.Payload) < 0.0) then
                Ctx.Cancel('Valor nao pode ser negativo');
            end);

          // Valor positivo deve passar normalmente
          OrderSlice.Commit('setAmount', 150.0);
          Expect(Double(TJSObject(OrderSlice.State)['amount'])).ToBe(150.0);

          // Valor negativo deve ser bloqueado com erro
          ErrCaught := False;
          try
            OrderSlice.Commit('setAmount', -50.0);
          except
            on E: Exception do
              ErrCaught := True;
          end;

          Expect(ErrCaught).ToBe(True);
          // O estado nao deve ter sido corrompido para -50.0
          Expect(Double(TJSObject(OrderSlice.State)['amount'])).ToBe(150.0);
        end);

      It('deve aplicar RBAC e permissao com TBVAuthGuardMiddleware', procedure
        var
          ErrBlocked: Boolean;
        begin
          SecureState := TJSObject.new;
          SecureState['config'] := 'default';
          SecureSlice := DefineStore('secure_slice', SecureState);

          SecureSlice.Action('superAdminAction', function(Ctx, APayload: JSValue): JSValue
            begin
              TJSObject(TBVStoreSlice(TJSObject(Ctx)['slice']).State)['config'] := 'unlocked';
              Result := 'UNLOCKED';
            end);

          AuthGuard := TBVAuthGuardMiddleware.Create;
          AuthGuard.SetUserContext('guest', []);
          AuthGuard.Rule('superAdminAction', 'admin');

          SecureSlice.Use(AuthGuard);

          // Usuario 'guest' tentando executar acao que requer 'admin' deve ser bloqueado
          ErrBlocked := False;
          try
            SecureSlice.Dispatch('superAdminAction');
          except
            on E: Exception do
              ErrBlocked := True;
          end;
          Expect(ErrBlocked).ToBe(True);
          Expect(string(TJSObject(SecureSlice.State)['config'])).ToBe('default');

          // Promove usuario para 'admin' e tenta novamente
          AuthGuard.SetUserContext('admin', ['system.manage']);
          SecureSlice.Dispatch('superAdminAction');

          Expect(string(TJSObject(SecureSlice.State)['config'])).ToBe('unlocked');
        end);

      It('deve bloquear mutacoes com falta de permissao granular', procedure
        var
          PermBlocked: Boolean;
        begin
          SecureState := TJSObject.new;
          SecureState['refundIssued'] := False;
          SecureSlice := DefineStore('refund_slice', SecureState);

          SecureSlice.Mutation('refund', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['refundIssued'] := True;
            end);

          AuthGuard := TBVAuthGuardMiddleware.Create;
          // Usuario e 'manager', mas nao tem a permissao especifica 'finance.refund'
          AuthGuard.SetUserContext('manager', ['finance.view', 'finance.export']);
          AuthGuard.Rule('refund', '', 'finance.refund');

          SecureSlice.Use(AuthGuard);

          PermBlocked := False;
          try
            SecureSlice.Commit('refund');
          except
            on E: Exception do
              PermBlocked := True;
          end;

          Expect(PermBlocked).ToBe(True);
          Expect(Boolean(TJSObject(SecureSlice.State)['refundIssued'])).ToBe(False);

          // Concede permissao e repete
          AuthGuard.SetUserContext('manager', ['finance.view', 'finance.export', 'finance.refund']);
          SecureSlice.Commit('refund');
          Expect(Boolean(TJSObject(SecureSlice.State)['refundIssued'])).ToBe(True);
        end);

      It('deve coletar metricas de performance e chamadas lentas com TBVTelemetryMiddleware', procedure
        begin
          PerfState := TJSObject.new;
          PerfState['data'] := 0;
          PerfSlice := DefineStore('perf_slice', PerfState);

          PerfSlice.Mutation('compute', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['data'] := Integer(TJSObject(AState)['data']) + 1;
            end);

          // Telemetria com limiar de 10ms
          Telemetry := TBVTelemetryMiddleware.Create(10.0);
          PerfSlice.Use(Telemetry);

          Expect(Telemetry.GetTotalRecordedCalls).ToBe(0);

          PerfSlice.Commit('compute');
          PerfSlice.Commit('compute');
          PerfSlice.Commit('compute');

          Expect(Telemetry.GetTotalRecordedCalls).ToBe(3);

          Metric := Telemetry.GetMetric('perf_slice/compute');
          Expect(Metric <> nil).ToBe(True);
          Expect(Metric.TotalCalls).ToBe(3);
          Expect(Metric.TotalDurationMs >= 0.0).ToBe(True);
          Expect(Metric.AvgDurationMs >= 0.0).ToBe(True);

          // Reset de metricas
          Telemetry.ResetMetrics;
          Expect(Telemetry.GetTotalRecordedCalls).ToBe(0);
        end);

      It('deve suportar middleware de Logger corporativo sem falhas', procedure
        begin
          Logger := TBVLoggerMiddleware.Create(False); // Desabilitado em testes para nao poluir saida
          Expect(Logger.Name).ToBe('Logger');
          Expect(Logger.Enabled).ToBe(False);

          Logger.Enabled := True;
          Expect(Logger.Enabled).ToBe(True);
        end);

      It('deve propagar middlewares globais do root store para todos os slices', procedure
        var
          GlobalHookCount: Integer;
          ChildSlice: TBVStoreSlice;
          ChildState: TJSObject;
        begin
          GlobalHookCount := 0;

          // Registra middleware global no root store
          GetStore.Use(procedure(Ctx: TBVMiddlewareContext)
            begin
              Inc(GlobalHookCount);
            end);

          ChildState := TJSObject.new;
          ChildState['val'] := 10;
          ChildSlice := DefineStore('child_slice', ChildState);

          ChildSlice.Mutation('inc', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['val'] := Integer(TJSObject(AState)['val']) + 1;
            end);

          ChildSlice.Commit('inc');
          Expect(GlobalHookCount >= 1).ToBe(True);
        end);

    end);
end.
