program member_bodies_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uMemberBodies;

var
  Wrapper: TWrapper;

begin
  Register_uMemberBodies;

  Describe('SFC member bodies', procedure
    begin
       It('should keep function inside asm in a computed body', procedure
         begin
            Wrapper := Mount('member-bodies');
            Expect(Wrapper.Find('.kept').textContent).ToBe('2');
            Expect(Wrapper.Find('.second').textContent).ToBe('ok');
         end);

       It('should return a value from a function in methods', procedure
         begin
            Wrapper := Mount('member-bodies');
            Expect(Wrapper.Find('.twice').textContent).ToBe('42');
         end);

       It('should keep procedure and function inside asm in a method body', procedure
         begin
            Wrapper := Mount('member-bodies');
            Wrapper.Find('.go').click();
            Expect(Wrapper.Find('.hits').textContent).ToBe('1');
         end);
    end);
end.
