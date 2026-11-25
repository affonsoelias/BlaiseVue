program aether_sfc_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uAetherCounter;

var
  Wrapper: TWrapper;

begin
  Register_uAetherCounter;

  Describe('SFC Compiler: <script lang="aether">', procedure
    begin
      It('deve compilar modulo Aether, exportar wrapper para o template e renderizar stepValue(5) = 11', procedure
        begin
          Wrapper := Mount('aether-counter');
          Expect(Wrapper.Find('.aether-val').textContent).ToBe('11');
        end);
    end);
end.
