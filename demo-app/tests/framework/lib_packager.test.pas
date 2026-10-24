program lib_packager_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVReactivity, BVCompiler, BlaiseVue;

function NormalizeLicenseId(const InputLic: string): string;
var
  Lic: string;
begin
  Lic := LowerCase(Trim(InputLic));
  if Lic = 'mit' then
    Result := 'MIT'
  else if (Lic = 'apache') or (Lic = 'apache-2.0') or (Lic = 'apache2') then
    Result := 'Apache-2.0'
  else if (Lic = 'lgpl') or (Lic = 'lgpl-3.0') or (Lic = 'lgpl3') then
    Result := 'LGPL-3.0'
  else if (Lic = 'commercial') or (Lic = 'proprietary') then
    Result := 'Commercial'
  else if (Lic = 'none') or (Lic = 'unlicensed') or (Lic = 'unlicense') then
    Result := 'UNLICENSED'
  else
    Result := 'MIT';
end;

function ResolveTagFromLibName(const LibName: string): string;
var
  Lower: string;
begin
  Lower := LowerCase(Trim(LibName));
  if Pos('bv-', Lower) = 1 then
    Result := Lower
  else
    Result := 'bv-' + Lower;
end;

function IsDistributableFile(const FilePath: string): Boolean;
var
  Lower: string;
begin
  Lower := LowerCase(FilePath);
  // Exclude tests, demo, git, and compiler artifacts
  if (Pos('tests/', Lower) = 1) or (Pos('demo/', Lower) = 1) or (Pos('.git', Lower) > 0) then
    Result := False
  else if (Pos('.o', Lower) > 0) or (Pos('.ppu', Lower) > 0) or (Pos('.tmp', Lower) > 0) then
    Result := False
  // Whitelist root metadata and src/styles
  else if (Lower = 'package.json') or (Lower = 'readme.md') or (Lower = 'license') or (Lower = 'setup.pas') then
    Result := True
  else if (Pos('src/', Lower) = 1) or (Pos('styles/', Lower) = 1) then
    Result := True
  else
    Result := False;
end;

function FormatSha256ChecksumLine(const Hash, ArchiveFileName: string): string;
begin
  Result := Hash + ' *' + ArchiveFileName;
end;

function IsLocalInstallSource(const Source: string): Boolean;
begin
  if (Pos('http://', LowerCase(Source)) = 1) or (Pos('https://', LowerCase(Source)) = 1) then
    Result := False
  else
    Result := True;
end;

begin
  Describe('BlaiseVue 4.0 External Library Scaffolding & Release Packager (bv create --lib & bv lib pack)', procedure
    begin
      It('should resolve standard open-source and commercial license identifiers', procedure
        begin
          Expect(NormalizeLicenseId('mit')).ToBe('MIT');
          Expect(NormalizeLicenseId('apache')).ToBe('Apache-2.0');
          Expect(NormalizeLicenseId('apache-2.0')).ToBe('Apache-2.0');
          Expect(NormalizeLicenseId('lgpl')).ToBe('LGPL-3.0');
          Expect(NormalizeLicenseId('lgpl-3.0')).ToBe('LGPL-3.0');
          Expect(NormalizeLicenseId('commercial')).ToBe('Commercial');
          Expect(NormalizeLicenseId('proprietary')).ToBe('Commercial');
          Expect(NormalizeLicenseId('none')).ToBe('UNLICENSED');
          Expect(NormalizeLicenseId('unlicense')).ToBe('UNLICENSED');
          Expect(NormalizeLicenseId('')).ToBe('MIT'); // Default fallback
        end);

      It('should map library names to idiomatic kebab-case tag names', procedure
        begin
          Expect(ResolveTagFromLibName('badge')).ToBe('bv-badge');
          Expect(ResolveTagFromLibName('bv-badge')).ToBe('bv-badge');
          Expect(ResolveTagFromLibName('awesome-card')).ToBe('bv-awesome-card');
          Expect(ResolveTagFromLibName('bv-avatar')).ToBe('bv-avatar');
        end);

      It('should strictly filter files for clean production distribution (stripping demo, tests, and caches)', procedure
        begin
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
        end);

      It('should format cryptographic SHA-256 checksum lines conforming to standard sha256sum', procedure
        var
          Hash, ZipName, ChecksumLine: string;
        begin
          Hash := '921e4954019ef498681dffc6a0725dd98dfdbcbd0922977f5402216af567fd1a';
          ZipName := 'sample-lib-1.0.0.zip';
          ChecksumLine := FormatSha256ChecksumLine(Hash, ZipName);

          Expect(ChecksumLine).ToBe('921e4954019ef498681dffc6a0725dd98dfdbcbd0922977f5402216af567fd1a *sample-lib-1.0.0.zip');
          Expect(Length(Hash)).ToBe(64);
        end);

      It('should distinguish between local archive installation and remote release URLs', procedure
        begin
          Expect(IsLocalInstallSource('./dist/my-lib-1.0.0.zip')).ToBe(True);
          Expect(IsLocalInstallSource('C:\packages\my-lib.zip')).ToBe(True);
          Expect(IsLocalInstallSource('https://github.com/blaisevue/blaise-ui/releases/latest/download/blaise-ui.zip')).ToBe(False);
          Expect(IsLocalInstallSource('http://cdn.example.com/packages/lib.zip')).ToBe(False);
        end);
    end);
end.
