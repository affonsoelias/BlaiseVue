program demoregex;

{$mode objfpc}

uses
  browserconsole, JS, Classes, SysUtils, Web, fpexprpars, db,jsondataset;

Procedure AssertTrue(Msg : String; B : Boolean);

begin
  if not B then
    Writeln('Failed: '+Msg)
  else
    Writeln('OK: '+Msg);
end;

Procedure TestEx;

var
  Ex : TFPExpressionParser;

begin
  Ex:=TFPExpressionParser.Create(Nil);
  Ex.AllowLike:=True;
  Ex.Identifiers.AddStringVariable('aField','Michael');
  Ex.Expression:='aField like ''M%''';
  AssertTrue('M% on match',Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Aimee';
  AssertTrue('M% on no match (not beginning)',not Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Liesbet';
  AssertTrue('M% on not match',Not Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Liam';
  Ex.Expression:='aField like ''%M''';
  AssertTrue('%M on match',Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Aimee';
  AssertTrue('%M on no match (not end)',not Ex.AsBoolean);
end;

Procedure TestEx2;

var
  Ex : TFPExpressionParser;

begin
  Ex:=TFPExpressionParser.Create(Nil);
  Ex.AllowLike:=True;
  Ex.Identifiers.AddStringVariable('aField','Michael');
  Ex.Expression:='aField like ''%e%''';
  AssertTrue('%e% on match',Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Sara';
  AssertTrue('%e% on not match',Not Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Liesbet';
  AssertTrue('%e% on match 2',Ex.AsBoolean);
end;


Procedure TestDotted;

var
  Ex : TFPExpressionParser;

begin
  Ex:=TFPExpressionParser.Create(Nil);
  Ex.AllowLike:=True;
  Ex.Identifiers.AddStringVariable('aField','12.14.2023');
  Ex.Expression:='aField like ''%.%.%''';
  AssertTrue('%.%.% on match',Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='Liesbet';
  AssertTrue('%.%.% on not match',Not Ex.AsBoolean);
end;

Procedure TestUnderscore;

var
  Ex : TFPExpressionParser;

begin
  Ex:=TFPExpressionParser.Create(Nil);
  Ex.AllowLike:=True;
  Ex.Identifiers.AddStringVariable('aField','man');
  Ex.Expression:='aField like ''M_n''';
  AssertTrue('M_n on match',Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='moon';
  AssertTrue('M_n on not match',Not Ex.AsBoolean);
  Ex.IdentifierByName('aField').AsString:='mon';
  AssertTrue('M_n on match 2',Ex.AsBoolean);
end;

Procedure TestDatasetFilter;

var
  DS : TJSONDataset;

begin
  DS:=TJSONDataset.Create(Nil);
  DS.FieldDefs.Add('name',ftString,50);
  DS.Open;
  DS.AppendRecord(['Michael']);
  DS.AppendRecord(['mattias']);
  DS.AppendRecord(['Bruno']);
  DS.AppendRecord(['Detlef']);
  DS.AppendRecord(['Aimee']);
  AssertTrue('RecordCount',5=DS.RecordCount);
  DS.First;
  DS.Filter:='(name like ''M%'')';
  DS.Filtered:=True;
  AssertTrue('First',DS.Fields[0].AsString='Michael');
  DS.Next;
  AssertTrue('Second',DS.Fields[0].AsString='mattias');
  DS.Next;
  AssertTrue('EOf',DS.EOF);
  DS.Free;
end;




begin
  testex;
  testex2;
  TestDotted;
  TestUnderscore;
  TestDatasetFilter;
end.
