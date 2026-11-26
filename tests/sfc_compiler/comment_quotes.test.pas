program comment_quotes_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, uCommentQuotes;

var
  Wrapper: TWrapper;

begin
  Register_uCommentQuotes;

  Describe('SFC apostrophes in comments and JS strings', procedure
    begin
       It('should still turn this.method() into a call after an apostrophe in a comment or a JS string', procedure
         begin
            Wrapper := Mount('comment-quotes');
            Wrapper.Find('.run').click();
            Expect(Wrapper.Find('.log').textContent).ToBe('1;2;3;4;5;6;7;');
         end);
    end);
end.
