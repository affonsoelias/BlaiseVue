program userprofile_view_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uUserProfile;

var
  Wrapper: TWrapper;

begin
  Register_uUserProfile;

  Describe('View: UserProfile', procedure
    begin
       It('deve inicializar o perfil de usuario e exibir informacoes de rota', procedure
         begin
            Wrapper := Mount('user-profile-page');
            Expect(Wrapper.Element <> nil).ToBe(True);
            Expect(Wrapper.Find('.section-title').textContent).ToContain('User Profile');
            Expect(Wrapper.Find('table')).toBeDefined;
         end);
    end);
end.
