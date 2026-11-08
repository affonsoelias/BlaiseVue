program fsm_test;

{$mode objfpc}

uses JS, Web, SysUtils, BVFSM, BVReactivity, BVTestUtils;

var
  OrderFSM: TBVStateMachine;
  PaymentCtx: TJSObject;
  EnterFired, ExitFired, ActionFired: Boolean;
  SubscribedOld, SubscribedNew, SubscribedEv: string;
  SubId: Integer;

begin
  Describe('BVFSM - Finite State Machine Engine (BlaiseX Pillar 1)', procedure
    begin
      It('deve inicializar maquina de estados com estado inicial correto', procedure
        begin
          OrderFSM := TBVStateMachine.Create('Order')
            .Initial('idle')
            .State('idle', [Transition('START', 'active')])
            .State('active', [Transition('FINISH', 'done')])
            .State('done', []);

          Expect(OrderFSM.Name).ToBe('Order');
          Expect(OrderFSM.Current).ToBe('idle');
          Expect(OrderFSM.Matches('idle')).ToBe(True);
          Expect(OrderFSM.Matches('active')).ToBe(False);
          Expect(OrderFSM.Previous).ToBe('');
        end);

      It('deve executar transicoes de estado deterministiscas com sucesso', procedure
        begin
          OrderFSM := TBVStateMachine.Create('Payment')
            .Initial('idle')
            .State('idle', [Transition('SUBMIT', 'processing')])
            .State('processing', [
              Transition('RESOLVE', 'completed'),
              Transition('REJECT', 'failed')
            ])
            .State('completed', [])
            .State('failed', [Transition('RETRY', 'processing')]);

          Expect(OrderFSM.Current).ToBe('idle');
          
          // Dispara SUBMIT -> processing
          Expect(OrderFSM.Send('SUBMIT')).ToBe(True);
          Expect(OrderFSM.Current).ToBe('processing');
          Expect(OrderFSM.Previous).ToBe('idle');
          Expect(OrderFSM.Matches('processing')).ToBe(True);

          // Dispara RESOLVE -> completed
          Expect(OrderFSM.Send('RESOLVE')).ToBe(True);
          Expect(OrderFSM.Current).ToBe('completed');
          Expect(OrderFSM.Previous).ToBe('processing');
        end);

      It('deve bloquear transicoes invalidas em modo estrito e nao-estrito', procedure
        var
          ErrorCaught: Boolean;
        begin
          OrderFSM := TBVStateMachine.Create('StrictGate')
            .Initial('idle')
            .State('idle', [Transition('OPEN', 'opened')])
            .State('opened', [Transition('CLOSE', 'idle')]);

          // Em modo estrito (padrao), evento invalido dispara excecao
          ErrorCaught := False;
          try
            OrderFSM.Send('CLOSE'); // CLOSE nao e permitido em idle!
          except
            on E: Exception do
              ErrorCaught := True;
          end;
          Expect(ErrorCaught).ToBe(True);
          Expect(OrderFSM.Current).ToBe('idle');

          // Em modo nao-estrito, retorna False sem estourar excecao
          OrderFSM.StrictMode(False);
          Expect(OrderFSM.Send('INVALID_EVENT')).ToBe(False);
          Expect(OrderFSM.Current).ToBe('idle');
        end);

      It('deve validar transicoes atraves de guards customizados', procedure
        var
          GuardCtx: TJSObject;
        begin
          GuardCtx := TJSObject.new;
          GuardCtx['balance'] := 50;

          OrderFSM := TBVStateMachine.Create('Withdrawal', GuardCtx)
            .Initial('ready');

          // Configura transicao com guard que exige saldo >= 100
          OrderFSM.State('ready')
            .On('WITHDRAW', 'dispensed', function(Ctx, Payload: JSValue): Boolean
              var
                Amt: Double;
              begin
                Amt := 0;
                if Payload <> nil then
                  Amt := Double(TJSObject(Payload)['amount']);
                Result := (Ctx <> nil) and (Double(TJSObject(Ctx)['balance']) >= Amt);
              end)
            .State('dispensed', []);

          // Tentativa de saque de 200 (saldo 50) deve ser barrada pelo guard
          PaymentCtx := TJSObject.new;
          PaymentCtx['amount'] := 200;
          Expect(OrderFSM.Can('WITHDRAW', PaymentCtx)).ToBe(False);
          Expect(OrderFSM.Send('WITHDRAW', PaymentCtx)).ToBe(False);
          Expect(OrderFSM.Current).ToBe('ready');

          // Tentativa de saque de 30 (saldo 50) deve passar no guard
          PaymentCtx['amount'] := 30;
          Expect(OrderFSM.Can('WITHDRAW', PaymentCtx)).ToBe(True);
          Expect(OrderFSM.Send('WITHDRAW', PaymentCtx)).ToBe(True);
          Expect(OrderFSM.Current).ToBe('dispensed');
        end);

      It('deve disparar hooks de lifecycle: OnEnter, OnExit e Transition Action', procedure
        var
          HookLog: TJSArray;
        begin
          HookLog := TJSArray.new;

          OrderFSM := TBVStateMachine.Create('LifecycleMachine')
            .Initial('step1');

          OrderFSM.State('step1')
            .ExitState(procedure(Ctx, Payload: JSValue)
              begin
                HookLog.push('step1_exit');
              end)
            .On('NEXT', 'step2', nil, procedure(Ctx, Payload: JSValue)
              begin
                HookLog.push('next_action');
              end);

          OrderFSM.State('step2')
            .Enter(procedure(Ctx, Payload: JSValue)
              begin
                HookLog.push('step2_enter');
              end);

          Expect(Integer(HookLog.length)).ToBe(0);

          OrderFSM.Send('NEXT');

          // Verifica ordem estrita: Exit -> Action -> Enter
          Expect(Integer(HookLog.length)).ToBe(3);
          Expect(string(HookLog[0])).ToBe('step1_exit');
          Expect(string(HookLog[1])).ToBe('next_action');
          Expect(string(HookLog[2])).ToBe('step2_enter');
        end);

      It('deve manter historico de auditoria das transicoes com timestamp', procedure
        var
          FirstHist, SecondHist: TJSObject;
        begin
          OrderFSM := TBVStateMachine.Create('AuditFSM')
            .Initial('created')
            .State('created', [Transition('APPROVE', 'approved')])
            .State('approved', [Transition('PUBLISH', 'published')])
            .State('published', []);

          Expect(OrderFSM.HistoryCount).ToBe(0);

          OrderFSM.Send('APPROVE');
          OrderFSM.Send('PUBLISH');

          Expect(OrderFSM.HistoryCount).ToBe(2);

          FirstHist := TJSObject(OrderFSM.History[0]);
          Expect(string(FirstHist['from'])).ToBe('created');
          Expect(string(FirstHist['to'])).ToBe('approved');
          Expect(string(FirstHist['event'])).ToBe('APPROVE');

          SecondHist := TJSObject(OrderFSM.History[1]);
          Expect(string(SecondHist['from'])).ToBe('approved');
          Expect(string(SecondHist['to'])).ToBe('published');
          Expect(string(SecondHist['event'])).ToBe('PUBLISH');
        end);

      It('deve notificar observadores inscritos via Subscribe e parar com Unsubscribe', procedure
        var
          CallCount: Integer;
        begin
          CallCount := 0;
          SubscribedOld := '';
          SubscribedNew := '';
          SubscribedEv := '';

          OrderFSM := TBVStateMachine.Create('ObservableFSM')
            .Initial('a')
            .State('a', [Transition('GO', 'b')])
            .State('b', [Transition('BACK', 'a')]);

          SubId := OrderFSM.Subscribe(procedure(Mach: TBVStateMachine; const NewSt, OldSt, Ev: string; Ctx: JSValue)
            begin
              Inc(CallCount);
              SubscribedOld := OldSt;
              SubscribedNew := NewSt;
              SubscribedEv := Ev;
            end);

          OrderFSM.Send('GO');
          Expect(CallCount).ToBe(1);
          Expect(SubscribedOld).ToBe('a');
          Expect(SubscribedNew).ToBe('b');
          Expect(SubscribedEv).ToBe('GO');

          // Desinscreve e dispara transicao subsequente
          OrderFSM.Unsubscribe(SubId);
          OrderFSM.Send('BACK');

          // Nao deve incrementar CallCount
          Expect(CallCount).ToBe(1);
          Expect(OrderFSM.Current).ToBe('a');
        end);

      It('deve suportar Reset restaurando o estado inicial', procedure
        begin
          OrderFSM := TBVStateMachine.Create('ResetTest')
            .Initial('idle')
            .State('idle', [Transition('START', 'running')])
            .State('running', [Transition('STOP', 'stopped')])
            .State('stopped', []);

          OrderFSM.Send('START');
          Expect(OrderFSM.Current).ToBe('running');

          OrderFSM.Reset;
          Expect(OrderFSM.Current).ToBe('idle');
          Expect(OrderFSM.Previous).ToBe('running');
        end);

      It('deve refletir mudancas no proxy reativo para bindings do BlaiseVue', procedure
        var
          ObservedState: string;
          ECount: Integer;
        begin
          OrderFSM := TBVStateMachine.Create('ReactiveFSM')
            .Initial('off')
            .State('off', [Transition('TOGGLE', 'on')])
            .State('on', [Transition('TOGGLE', 'off')]);

          ObservedState := '';
          ECount := 0;

          // Effect reativo que observa a propriedade 'current' do proxy da FSM
          Effect(procedure
            begin
              ObservedState := string(TJSObject(OrderFSM.Reactive)['current']);
              Inc(ECount);
            end);

          Expect(ObservedState).ToBe('off');
          Expect(ECount).ToBe(1);

          // Transicao dispara reatividade automatica
          OrderFSM.Send('TOGGLE');
          Expect(ObservedState).ToBe('on');
          Expect(ECount).ToBe(2);

          OrderFSM.Send('TOGGLE');
          Expect(ObservedState).ToBe('off');
          Expect(ECount).ToBe(3);
        end);

    end);
end.
