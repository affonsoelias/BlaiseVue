program wasm_ssg_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BVWasm, BlaiseVue;

begin
  Describe('BlaiseVue 3.0 WebAssembly Acceleration & SSG Hydration Engine', procedure
    begin
       It('deve detectar suporte a WebAssembly no ambiente', procedure
         begin
            Expect(TBVWasm.IsSupported).ToBe(True);
         end);

       It('deve inicializar e disponibilizar o modulo math padrao', procedure
         begin
            TBVWasm.InitDefaultModules;
            Expect(TBVWasm.HasModule('math')).ToBe(True);
         end);

       It('deve executar operacoes aritmeticas compiladas no modulo math', procedure
         var
           SumVal, SqrVal: Integer;
         begin
            TBVWasm.InitDefaultModules;
            SumVal := Integer(TBVWasm.Call('math', 'add', TJSArray.new(15, 27)));
            Expect(SumVal).ToBe(42);

            SqrVal := Integer(TBVWasm.Call('math', 'square', 9));
            Expect(SqrVal).ToBe(81);
         end);

       It('deve executar algoritmos de Fibonacci e Primos acelerados', procedure
         var
           Fib10, Prime17, NonPrime18: Integer;
         begin
            TBVWasm.InitDefaultModules;
            Fib10 := Integer(TBVWasm.Call('math', 'fib', 10));
            Expect(Fib10).ToBe(55);

            Prime17 := Integer(TBVWasm.Call('math', 'isPrime', 17));
            Expect(Prime17).ToBe(1);

            NonPrime18 := Integer(TBVWasm.Call('math', 'isPrime', 18));
            Expect(NonPrime18).ToBe(0);
         end);

       It('deve executar benchmark comparativo Wasm vs JS', procedure
         var
           BenchObj: JSValue;
           Speedup: string;
         begin
            TBVWasm.InitDefaultModules;
            BenchObj := TBVWasm.Benchmark('math', 'fib', 12, 50);
            asm
              Speedup = BenchObj.speedup;
            end;
            Expect(Speedup <> '').ToBe(True);
         end);

       It('deve injetar $wasm no compilador e nas expressoes de template', procedure
         var
           Root: TJSHTMLElement;
           Data: TBlaiseData;
           ResText: string;
         begin
            Root := TJSHTMLElement(document.createElement('div'));
            Root.innerHTML := '<span>Fib(8) = {{ $wasm.call(''math'', ''fib'', 8) }}</span>';
            document.body.appendChild(Root);

            Data := TBlaiseData.Create(TJSObject.new);
            Compile(Root, Data, nil);

            ResText := Root.textContent;
            Expect(ResText).ToContain('Fib(8) = 21');
            document.body.removeChild(Root);
         end);

       It('deve identificar container SSG pre-renderizado e ativar hidratacao sem destruir o DOM', procedure
         var
           SsgRoot: TJSHTMLElement;
           Opts: TJSObject;
           App: TBlaiseVue;
           HasHydratedAttr: Boolean;
         begin
            SsgRoot := TJSHTMLElement(document.createElement('div'));
            SsgRoot.id := 'app-ssg-test';
            SsgRoot.setAttribute('data-bv-ssg', 'true');
            SsgRoot.innerHTML := '<h1 class="ssg-title">Titulo Pre-Renderizado</h1><p>Conteudo do Servidor</p>';
            document.body.appendChild(SsgRoot);

            Opts := TJSObject.new;
            Opts['el'] := '#app-ssg-test';
            Opts['data'] := TJSObject.new;
            App := TBlaiseVue.Create(Opts);

            HasHydratedAttr := SsgRoot.hasAttribute('data-bv-hydrated');
            Expect(HasHydratedAttr).ToBe(True);
            Expect(SsgRoot.querySelector('.ssg-title') <> nil).ToBe(True);
            Expect(SsgRoot.textContent).ToContain('Titulo Pre-Renderizado');

            document.body.removeChild(SsgRoot);
         end);
    end);
end.
