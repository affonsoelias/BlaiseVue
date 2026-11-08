program component_store_test;

{$mode objfpc}

uses JS, Web, SysUtils, BVTestUtils, BVComponents, BVCompiler, BVReactivity, BVStore, BVFSM, BVPascalDX;

var
  Wrapper: TWrapper;

procedure RegisterTemplate(const AName, ATemplate: string; AData: TJSObject = nil);
var
  Comp: TJSObject;
begin
  Comp := TJSObject.new;
  Comp['template'] := ATemplate;
  Comp['data'] := function(): TJSObject
  var
    Key: string;
  begin
    Result := TJSObject.new;
    if AData <> nil then
    begin
      for Key in TJSObject.keys(AData) do
        Result[Key] := AData[Key];
    end;
  end;
  RegisterComponent(AName, Comp);
end;

function TextOf(const ASelector: string): string;
var
  El: TJSElement;
begin
  El := Wrapper.Element.querySelector(ASelector);
  if El <> nil then
    Result := TJSString(El.textContent).trim()
  else
    Result := '';
end;

begin
  Describe('BlaiseVue 4.0 Phase 8: BlaiseX Reactive Component Integration & Pascal DX', procedure
    var
      CartSlice, OrderSlice: TBVStoreSlice;
      CartState, OrderState: TJSObject;
      FSMOrder: TBVStateMachine;
    begin
      { Setup global BlaiseX store slices and finite state machines }
      CartState := TJSObject.new;
      CartState['count'] := 0;
      CartState['price'] := 50;

      CartSlice := DefineStore('cart', CartState)
        .Mutation('increment', procedure(AState, APayload: JSValue)
          begin
            TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) + 1;
          end)
        .Mutation('decrement', procedure(AState, APayload: JSValue)
          begin
            TJSObject(AState)['count'] := Integer(TJSObject(AState)['count']) - 1;
          end)
        .Getter('total', function(AState: JSValue): JSValue
          begin
            Result := Integer(TJSObject(AState)['count']) * Integer(TJSObject(AState)['price']);
          end)
        .Action('asyncCheckout', function(ACtx, APayload: JSValue): JSValue
          begin
            TBVStoreSlice(TJSObject(ACtx)['slice']).Commit('increment');
            Result := 'CHECKOUT_SUCCESS';
          end);

      FSMOrder := TBVStateMachine.Create('checkoutFlow')
        .Initial('cart')
        .State('cart')
          .On('CHECKOUT', 'processing')
        .State('processing')
          .On('SUCCESS', 'completed')
          .On('FAIL', 'cart')
        .State('completed')
        .Machine;

      OrderState := TJSObject.new;
      OrderState['orderId'] := 101;

      OrderSlice := DefineStore('order', OrderState)
        .AttachMachine('checkout', FSMOrder);

      RegisterTemplate('test-cart-component',
        '<div>' +
        '  <span class="count-val">{{ $store.cart.count }}</span>' +
        '  <button class="btn-inc" @click="$blaisex.Commit(''cart/increment'')">+</button>' +
        '  <button class="btn-undo" @click="$blaisex.Undo(''cart'')">Undo</button>' +
        '</div>');

      RegisterTemplate('test-fsm-component',
        '<div>' +
        '  <span class="order-step">{{ $store.order.checkout.current }}</span>' +
        '</div>');

      It('should render initial store slice reactive state in component template', procedure
        begin
          Wrapper := Mount('test-cart-component');
          Expect(TextOf('.count-val')).ToBe('0');
        end);

      It('should reactively update component DOM when mutation is triggered via $blaisex.Commit', procedure
        var
          Btn: TJSHTMLElement;
        begin
          Wrapper := Mount('test-cart-component');
          Btn := TJSHTMLElement(Wrapper.Element.querySelector('.btn-inc'));
          Expect(Btn <> nil).ToBe(True);

          Btn.click();
          Expect(TextOf('.count-val')).ToBe('1');

          Btn.click();
          Expect(TextOf('.count-val')).ToBe('2');
        end);

      It('should revert component DOM reactively when time-travel undo is triggered via $blaisex.Undo', procedure
        var
          BtnUndo: TJSHTMLElement;
        begin
          Wrapper := Mount('test-cart-component');
          Expect(TextOf('.count-val')).ToBe('2');

          BtnUndo := TJSHTMLElement(Wrapper.Element.querySelector('.btn-undo'));
          Expect(BtnUndo <> nil).ToBe(True);

          BtnUndo.click();
          Expect(TextOf('.count-val')).ToBe('1');

          BtnUndo.click();
          Expect(TextOf('.count-val')).ToBe('0');
        end);

      It('should bind attached FSM state reactively to component DOM and update on machine transitions', procedure
        begin
          Wrapper := Mount('test-fsm-component');
          Expect(TextOf('.order-step')).ToBe('cart');

          FSMOrder.Send('CHECKOUT');
          Expect(TextOf('.order-step')).ToBe('processing');

          FSMOrder.Send('SUCCESS');
          Expect(TextOf('.order-step')).ToBe('completed');
        end);

      It('should execute pure Pascal DX helpers: StoreCommit, StoreDispatch, StoreGet, StoreUndo, StoreRedo', procedure
        var
          DispRes, TotalVal: JSValue;
        begin
          { Pure Pascal DX StoreCommit }
          StoreCommit('cart/increment');
          Expect(Integer(TJSObject(CartSlice.State)['count'])).ToBe(1);

          { Pure Pascal DX StoreGet }
          TotalVal := StoreGet('cart/total');
          Expect(Integer(TotalVal)).ToBe(50);

          { Pure Pascal DX StoreDispatch }
          DispRes := StoreDispatch('cart/asyncCheckout');
          Expect(String(DispRes)).ToBe('CHECKOUT_SUCCESS');
          Expect(Integer(TJSObject(CartSlice.State)['count'])).ToBe(2);

          { Pure Pascal DX StoreUndo and StoreRedo }
          Expect(StoreUndo('cart')).ToBe(True);
          Expect(Integer(TJSObject(CartSlice.State)['count'])).ToBe(1);

          Expect(StoreRedo('cart')).ToBe(True);
          Expect(Integer(TJSObject(CartSlice.State)['count'])).ToBe(2);
        end);

      It('should retrieve store slices and attached FSM using UseStore and UseFSM DX helpers', procedure
        var
          Sl: JSValue;
          FoundFSM: TBVStateMachine;
        begin
          Sl := UseStore('cart');
          Expect(Sl <> nil).ToBe(True);
          Expect(TBVStoreSlice(Sl).Name).ToBe('cart');

          FoundFSM := UseFSM('checkout');
          Expect(FoundFSM <> nil).ToBe(True);
          Expect(FoundFSM.Name).ToBe('checkoutFlow');
          Expect(FoundFSM.Current).ToBe('completed');

          FoundFSM := UseFSM('order', 'checkout');
          Expect(FoundFSM <> nil).ToBe(True);
          Expect(FoundFSM.Name).ToBe('checkoutFlow');
        end);
    end);
end.
