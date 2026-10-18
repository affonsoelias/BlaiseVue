program makenamespaceslist;
{$mode objfpc}
{$h+}

uses sysutils, classes;

Function ExtractInclude(const aFileName : string) : string;

Const
  SInclude = '{$include ';
  SI = '{$i ';


var
  aFile: TStringList;
  FN,S : String;
  P : Integer;

begin
  Result:='';
  aFile:=TStringList.Create;
  try
    aFile.LoadFromFile(aFileName);
    For S in aFile do
      begin
      FN:=S;
      P:=Pos(SInclude,LowerCase(FN));
      if P<>0 then
        Delete(FN,1,P+Length(SInclude)-1)
      else
        begin
        P:=Pos(SI,LowerCase(FN));
        if P<>0 then
          Delete(FN,1,P+Length(SI)-1)
        end;
      if P<>0 then
        begin
        P:=Pos('}',FN);
        if P>0 then
          begin
          FN:=Trim(Copy(FN,1,P-1));
          FN:=ExtractFilePath(aFileName)+FN;
          Result:=ExpandFileName(FN);
          end;
        end;
      end;
  finally
    aFile.Free;
  end;
end;

Procedure AddNameSpaces(const aBaseDir,aSubDir : String; aList : TStrings; IsKnownList : Boolean);

var
  Info : TSearchRec;
  Ext : string;
  NS,NonNS: String;

begin
  Writeln('Examining dir: ',aSubDir+AllFilesMask);
  if FindFirst(aSubDir+AllFilesMask,0,Info)=0 then
   try
     Repeat
       if ((Info.Attr and faDirectory)=0)  then
         begin
         Ext:=ExtractFileExt(Info.Name);
         Writeln('Examining ',Info.Name);
         if SameText(Ext,'.pp') or SameText(Ext,'.pas') then
           begin
           NS:=aSubDir+Info.Name;
           NonNS:=ExtractInclude(NS);
           Writeln(NS,' -> ',NonNS);
           if NonNS<>'' then
             begin
             if IsKnownList then
                begin
                NS:='*'+ChangeFileExt(ExtractFileName(NS),'');
                NonNS:=ChangeFileExt(ExtractFileName(NonNS),'');
                end
             else
               begin
               NS:=ExtractRelativePath(aBaseDir,NS);
               NonNS:=ExtractRelativePath(aBaseDir,NonNS);
               end;
             aList.Add(NonNS+'='+NS);
             end;
           end;
         end;
     Until (FindNext(Info)<>0);
   finally
     FindClose(Info);
   end;
end;

Procedure CreateNameSpaces(const aBaseDir : string; const aListFile : String; MakeKnownList : Boolean);

var
  L : TStringList;
  Info : TSearchRec;
  Subdir : string;

begin
  L:=TStringList.Create;
  try
    if FindFirst(aBaseDir+AllFilesMask,faDirectory,Info)=0 then
      try
        Repeat
          if ((Info.Attr and faDirectory)=faDirectory) and
             Not ((Info.Name='.') or (Info.Name='..')) then
            begin
            SubDir:=aBaseDir+Info.Name+PathDelim+'namespaced'+PathDelim;
            if DirectoryExists(SubDir) then
              AddNameSpaces(aBaseDir,SubDir,L,MakeKnownList);
            end;
        Until FindNext(Info)<>0;
      finally
        FindClose(Info);
      end;
     if L.Count>0 then
       begin
       Writeln('Writing ',L.Count,' namespaces to ',aListFile);
       L.SaveToFile(aListFile)
       end
     else
       Writeln('Error : no namespaced files found');
  finally
    L.Free;
  end;
end;


var
  ListFile,BaseDir : String;
  MakeKnownList : Boolean;

begin
  BaseDir:=ParamStr(1);
  if BaseDir='-k' then
    begin
    MakeKnownList:=True;
    BaseDir:=ParamStr(2);
    end;
  if (BaseDir='') then
    begin
    Writeln('Usage : ',ExtractFileName(Paramstr(0)),' [-k] DIR [LISTFILE]');
    Writeln('If Listfile is not specified then it defaults to : DIR/namespaces.lst');
    Halt(1);
    end;
  BaseDir:=IncludeTrailingPathDelimiter(BaseDir);
  ListFile:=ParamStr(2+Ord(MakeKNownList));
  if ListFile='' then
    if MakeKnownList then
      ListFile:=BaseDir+'knownaliases.lst'
    else
      ListFile:=BaseDir+'namespaces.lst';
  CreateNameSpaces(BaseDir,ListFile,MakeKnownList);
end.

