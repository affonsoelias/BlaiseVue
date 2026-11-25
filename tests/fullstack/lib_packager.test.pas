
Program lib_packager_test;

{$mode objfpc}


Uses JS, Web, SysUtils, BVTestUtils, BVReactivity, BVCompiler, BlaiseVue;

Function NormalizeLicenseId(Const InputLic: String): string;

Var 
  Lic: string;
Begin
  Lic := LowerCase(Trim(InputLic));
  If Lic = 'mit' Then
    Result := 'MIT'
  Else If (Lic = 'apache') Or (Lic = 'apache-2.0') Or (Lic = 'apache2') Then
         Result := 'Apache-2.0'
  Else If (Lic = 'lgpl') Or (Lic = 'lgpl-3.0') Or (Lic = 'lgpl3') Then
         Result := 'LGPL-3.0'
  Else If (Lic = 'commercial') Or (Lic = 'proprietary') Then
         Result := 'Commercial'
  Else If (Lic = 'none') Or (Lic = 'unlicensed') Or (Lic = 'unlicense') Then
         Result := 'UNLICENSED'
  Else
    Result := 'MIT';
End;

Function ResolveTagFromLibName(Const LibName: String): string;

Var 
  Lower: string;
Begin
  Lower := LowerCase(Trim(LibName));
  If Pos('bv-', Lower) = 1 Then
    Result := Lower
  Else
    Result := 'bv-' + Lower;
End;

Function IsDistributableFile(Const FilePath: String): Boolean;

Var 
  Lower: string;
Begin
  Lower := LowerCase(FilePath);
  // Exclude tests, demo, git, and compiler artifacts
  If (Pos('tests/', Lower) = 1) Or (Pos('demo/', Lower) = 1) Or (Pos('.git',
     Lower) > 0) Then
    Result := False
  Else If (Pos('.o', Lower) > 0) Or (Pos('.ppu', Lower) > 0) Or (Pos('.tmp',
          Lower) > 0) Then
         Result := False
                   // Whitelist root metadata and src/styles
  Else If (Lower = 'package.json') Or (Lower = 'readme.md') Or (Lower =
          'license') Or (Lower = 'setup.pas') Then
         Result := True
  Else If (Pos('src/', Lower) = 1) Or (Pos('styles/', Lower) = 1) Then
         Result := True
  Else
    Result := False;
End;

Function FormatSha256ChecksumLine(Const Hash, ArchiveFileName: String): string;
Begin
  Result := Hash + ' *' + ArchiveFileName;
End;

Function IsLocalInstallSource(Const Source: String): Boolean;
Begin
  If (Pos('http://', LowerCase(Source)) = 1) Or (Pos('https://', LowerCase(
     Source)) = 1) Then
    Result := False
  Else
    Result := True;
End;

Begin
  Describe(
'BlaiseVue 4.0 External Library Scaffolding & Release Packager (bv create --lib & bv lib pack)'
           , Procedure
           Begin
           It(
        'should resolve standard open-source and commercial license identifiers'
           , Procedure
           Begin
           Expect(NormalizeLicenseId('mit')).ToBe('MIT');
  Expect(NormalizeLicenseId('apache')).ToBe('Apache-2.0');
  Expect(NormalizeLicenseId('apache-2.0')).ToBe('Apache-2.0');
  Expect(NormalizeLicenseId('lgpl')).ToBe('LGPL-3.0');
  Expect(NormalizeLicenseId('lgpl-3.0')).ToBe('LGPL-3.0');
  Expect(NormalizeLicenseId('commercial')).ToBe('Commercial');
  Expect(NormalizeLicenseId('proprietary')).ToBe('Commercial');
  Expect(NormalizeLicenseId('none')).ToBe('UNLICENSED');
  Expect(NormalizeLicenseId('unlicense')).ToBe('UNLICENSED');
  Expect(NormalizeLicenseId('')).ToBe('MIT');
  // Default fallback
End
);

It('should map library names to idiomatic kebab-case tag names', Procedure
   Begin
   Expect(ResolveTagFromLibName('badge')).ToBe('bv-badge');
Expect(ResolveTagFromLibName('bv-badge')).ToBe('bv-badge');
Expect(ResolveTagFromLibName('awesome-card')).ToBe('bv-awesome-card');
Expect(ResolveTagFromLibName('bv-avatar')).ToBe('bv-avatar');
End
);

It(
'should strictly filter files for clean production distribution (stripping demo, tests, and caches)'
   , Procedure
   Begin
   // Distributable files
   Expect(IsDistributableFile('package.json')).ToBe(True);
Expect(IsDistributableFile('README.md')).ToBe(True);
Expect(IsDistributableFile('LICENSE')).ToBe(True);
Expect(IsDistributableFile('src/BVBadge.bv')).ToBe(True);
Expect(IsDistributableFile('src/BVBadge.pas')).ToBe(True);
Expect(IsDistributableFile('styles/bv-badge.css')).ToBe(True);
Expect(IsDistributableFile('setup.pas')).ToBe(True);

// Internal development files (MUST be excluded from release artifact)
Expect(IsDistributableFile('tests/badge.test.pas')).ToBe(False);
Expect(IsDistributableFile('demo/index.html')).ToBe(False);
Expect(IsDistributableFile('demo/app.bv')).ToBe(False);
Expect(IsDistributableFile('.git/config')).ToBe(False);
Expect(IsDistributableFile('src/BVBadge.o')).ToBe(False);
Expect(IsDistributableFile('src/BVBadge.ppu')).ToBe(False);
Expect(IsDistributableFile('temp.tmp')).ToBe(False);
End
);

It(
'should format cryptographic SHA-256 checksum lines conforming to standard sha256sum'
   , Procedure
   Var
   Hash, ZipName, ChecksumLine: String;
   Begin
   Hash := '921e4954019ef498681dffc6a0725dd98dfdbcbd0922977f5402216af567fd1a';
   ZipName := 'sample-lib-1.0.0.zip';
   ChecksumLine := FormatSha256ChecksumLine(Hash, ZipName);

Expect(ChecksumLine).ToBe(
'921e4954019ef498681dffc6a0725dd98dfdbcbd0922977f5402216af567fd1a *sample-lib-1.0.0.zip'
);
Expect(Length(Hash)).ToBe(64);
End
);

It(
 'should distinguish between local archive installation and remote release URLs'
   , Procedure
   Begin
   Expect(IsLocalInstallSource('./dist/my-lib-1.0.0.zip')).ToBe(True);
Expect(IsLocalInstallSource('C:\packages\my-lib.zip')).ToBe(True);
Expect(IsLocalInstallSource(
 'https://github.com/blaisevue/blaise-ui/releases/latest/download/blaise-ui.zip'
)).ToBe(False);
Expect(IsLocalInstallSource('http://cdn.example.com/packages/lib.zip')).ToBe(
                                                                           False
);
End
);
End
);
End.
