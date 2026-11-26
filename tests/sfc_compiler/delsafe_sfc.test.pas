program delsafe_sfc_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uDelSafeCounter;

var
  Wrapper: TWrapper;

begin
  Register_uDelSafeCounter;

  Describe('SFC Compiler: <script lang="delsafe">', procedure
    begin
      It('deve compilar modulo DelSafe, exportar wrapper para o template e renderizar stepValue(5) = 11', procedure
        begin
          Wrapper := Mount('del-safe-counter');
          Expect(Wrapper.Find('.delsafe-val').textContent).ToBe('11');
        end);
    end);
end.
