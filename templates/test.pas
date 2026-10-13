program {{TEST_NAME}}_test;

{$mode objfpc}

uses JS, Web, BVTestUtils;

var
  Wrapper: TWrapper;

begin
  Describe('{{TEST_NAME}}', procedure
    begin
       It('should work', procedure
         begin
            Expect(True).ToEqual(True);
         end);
    end);
end.
