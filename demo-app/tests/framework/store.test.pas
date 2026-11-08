program store_test;

{$mode objfpc}

uses JS, Web, SysUtils, BVStore, BVFSM, BVReactivity, BVTestUtils;

var
  CartSlice, UserSlice: TBVStoreSlice;
  CartState, UserState, ItemPayload: TJSObject;
  CheckoutMachine: TBVStateMachine;
  SubCount: Integer;
  LastMutName: string;
  SubId: Integer;

begin
  Describe('BVStore - BlaiseX TBVStore 2.0 (Pillar 1 Step 2)', procedure
    begin
      It('deve manter compatibilidade retroativa com store legado $store.state', procedure
        var
          LegacyStore: TBVStore;
          InitialData: TJSObject;
        begin
          InitialData := TJSObject.new;
          InitialData['appName'] := 'BlaiseVue Legacy';
          LegacyStore := CreateStore(InitialData);

          Expect(LegacyStore.State <> nil).ToBe(True);
          Expect(string(TJSObject(LegacyStore.State)['appName'])).ToBe('BlaiseVue Legacy');
        end);

      It('deve criar e recuperar slices modulares independentes via DefineStore e GetStore', procedure
        begin
          CartState := TJSObject.new;
          CartState['itemsCount'] := 0;
          CartSlice := DefineStore('cart', CartState);

          UserState := TJSObject.new;
          UserState['isLogged'] := False;
          UserSlice := DefineStore('user', UserState);

          Expect(CartSlice.Name).ToBe('cart');
          Expect(UserSlice.Name).ToBe('user');

          Expect(GetStore('cart') = CartSlice).ToBe(True);
          Expect(GetStore('user') = UserSlice).ToBe(True);

          // Valida que o root state monta os namespaces automaticamente
          Expect(TJSObject(GetStore.State)['cart'] <> nil).ToBe(True);
          Expect(TJSObject(GetStore.State)['user'] <> nil).ToBe(True);
        end);

      It('deve registrar e executar mutacoes sincronas atomicas com Commit', procedure
        var
          ErrCaught: Boolean;
        begin
          CartState := TJSObject.new;
          CartState['itemsCount'] := 0;
          CartState['totalPrice'] := 0.0;
          CartSlice := DefineStore('cart_mut', CartState);

          // Registra mutacao
          CartSlice.Mutation('addItem', procedure(AState, APayload: JSValue)
            var
              Price: Double;
            begin
              TJSObject(AState)['itemsCount'] := Integer(TJSObject(AState)['itemsCount']) + 1;
              Price := 10.0;
              if APayload <> nil then
                Price := Double(TJSObject(APayload)['price']);
              TJSObject(AState)['totalPrice'] := Double(TJSObject(AState)['totalPrice']) + Price;
            end);

          ItemPayload := TJSObject.new;
          ItemPayload['price'] := 25.5;

          CartSlice.Commit('addItem', ItemPayload);

          Expect(Integer(TJSObject(CartSlice.State)['itemsCount'])).ToBe(1);
          Expect(Double(TJSObject(CartSlice.State)['totalPrice'])).ToBe(25.5);

          // Disparar mutacao inexistente lanca excecao controlada
          ErrCaught := False;
          try
            CartSlice.Commit('unknownMutation');
          except
            on E: Exception do
              ErrCaught := True;
          end;
          Expect(ErrCaught).ToBe(True);
        end);

      It('deve registrar e despachar acoes com contexto de commit e dispatch', procedure
        var
          ActionResult: JSValue;
        begin
          CartState := TJSObject.new;
          CartState['itemsCount'] := 0;
          CartState['discountApplied'] := False;
          CartSlice := DefineStore('cart_act', CartState);

          CartSlice.Mutation('applyDiscount', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['discountApplied'] := True;
            end);

          CartSlice.Action('checkout', function(Ctx, APayload: JSValue): JSValue
            begin
              // Aciona mutacao atraves do contexto
              TBVStoreSlice(TJSObject(Ctx)['slice']).Commit('applyDiscount');
              Result := 'CHECKOUT_SUCCESS';
            end);

          ActionResult := CartSlice.Dispatch('checkout');

          Expect(string(ActionResult)).ToBe('CHECKOUT_SUCCESS');
          Expect(Boolean(TJSObject(CartSlice.State)['discountApplied'])).ToBe(True);
        end);

      It('deve calcular getters computados baseados no estado reativo', procedure
        begin
          CartState := TJSObject.new;
          CartState['price'] := 100.0;
          CartState['taxRate'] := 0.15;
          CartSlice := DefineStore('cart_gtr', CartState);

          CartSlice.Getter('totalWithTax', function(AState: JSValue): JSValue
            var
              BasePrice, Tax: Double;
            begin
              BasePrice := Double(TJSObject(AState)['price']);
              Tax := Double(TJSObject(AState)['taxRate']);
              Result := BasePrice + (BasePrice * Tax);
            end);

          Expect(Double(CartSlice.Get('totalWithTax'))).ToBe(115.0);
        end);

      It('deve integrar maquina de estados finitos (BVFSM) anexada ao slice', procedure
        begin
          CartState := TJSObject.new;
          CartState['status'] := 'pending';
          CartSlice := DefineStore('cart_fsm', CartState);

          CheckoutMachine := TBVStateMachine.Create('CheckoutFSM')
            .Initial('cart')
            .State('cart', [Transition('PROCEED', 'payment')])
            .State('payment', [Transition('PAID', 'shipped')])
            .State('shipped', []);

          CartSlice.AttachMachine('flow', CheckoutMachine);

          Expect(CartSlice.FSM('flow') <> nil).ToBe(True);
          Expect(CartSlice.FSM('flow').Current).ToBe('cart');

          CartSlice.FSM('flow').Send('PROCEED');
          Expect(CartSlice.FSM('flow').Current).ToBe('payment');
        end);

      It('deve permitir modificacao atomica via Patch e restauracao via Reset', procedure
        var
          Patches: TJSObject;
        begin
          CartState := TJSObject.new;
          CartState['coupon'] := 'NONE';
          CartState['shipping'] := 15.0;
          CartSlice := DefineStore('cart_patch', CartState);

          // Patch altera multiplas propriedades
          Patches := TJSObject.new;
          Patches['coupon'] := 'BLACKFRIDAY';
          Patches['shipping'] := 0.0;

          CartSlice.Patch(Patches);

          Expect(string(TJSObject(CartSlice.State)['coupon'])).ToBe('BLACKFRIDAY');
          Expect(Double(TJSObject(CartSlice.State)['shipping'])).ToBe(0.0);

          // Reset restaura exatamente o estado inicial
          CartSlice.Reset;

          Expect(string(TJSObject(CartSlice.State)['coupon'])).ToBe('NONE');
          Expect(Double(TJSObject(CartSlice.State)['shipping'])).ToBe(15.0);
        end);

      It('deve notificar observadores via Subscribe e permitir Unsubscribe', procedure
        begin
          SubCount := 0;
          LastMutName := '';

          CartState := TJSObject.new;
          CartState['counter'] := 0;
          CartSlice := DefineStore('cart_obs', CartState);

          CartSlice.Mutation('inc', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['counter'] := Integer(TJSObject(AState)['counter']) + 1;
            end);

          SubId := CartSlice.Subscribe(procedure(Sl: TBVStoreSlice; const Mut: string; St, Payload: JSValue)
            begin
              Inc(SubCount);
              LastMutName := Mut;
            end);

          CartSlice.Commit('inc');
          Expect(SubCount).ToBe(1);
          Expect(LastMutName).ToBe('inc');

          CartSlice.Unsubscribe(SubId);
          CartSlice.Commit('inc');
          // Nao deve incrementar apos desinscricao
          Expect(SubCount).ToBe(1);
          Expect(Integer(TJSObject(CartSlice.State)['counter'])).ToBe(2);
        end);

      It('deve suportar commits e dispatches globais namespaced (slice/mutation)', procedure
        begin
          CartState := TJSObject.new;
          CartState['score'] := 10;
          CartSlice := DefineStore('global_test', CartState);

          CartSlice.Mutation('addScore', procedure(AState, APayload: JSValue)
            begin
              TJSObject(AState)['score'] := Integer(TJSObject(AState)['score']) + Integer(APayload);
            end);

          GetStore.Commit('global_test/addScore', 25);
          Expect(Integer(TJSObject(CartSlice.State)['score'])).ToBe(35);
        end);

    end);
end.
