$ErrorActionPreference = 'Stop'

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $RootDir 'bin'
$SrcFile = Join-Path $BinDir 'bv.pas'
$TargetNew = Join-Path $BinDir 'bv_new.exe'
$TargetExe = Join-Path $BinDir 'bv.exe'
$TargetBak = Join-Path $BinDir 'bv.bak.exe'

function Find-FpcExecutable {
    $cmd = Get-Command fpc -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe',
        'C:\lazarus\fpc\3.2.0\bin\x86_64-win64\fpc.exe',
        'D:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe',
        'C:\FPC\3.2.2\bin\i386-win32\fpc.exe'
    )
    foreach ($cand in $candidates) {
        if (Test-Path $cand) { return $cand }
    }
    return $null
}

Write-Host '================================================================'
Write-Host '  BlaiseVue CLI Native Build (Windows / PowerShell)'
Write-Host '================================================================'

if (-not (Test-Path $SrcFile)) {
    Write-Host "[ERROR] Source file not found: $SrcFile" -ForegroundColor Red
    exit 1
}

$FpcExe = Find-FpcExecutable
if (-not $FpcExe) {
    Write-Host '[ERROR] Free Pascal Compiler (fpc) was not detected in PATH or standard Lazarus folders.' -ForegroundColor Red
    Write-Host '        Install Lazarus IDE / FPC 3.2.2+: https://www.lazarus-ide.org/'
    exit 1
}

Write-Host "  [+] FPC Compiler: $FpcExe"
Write-Host '  [+] Compiling bin\bv.pas -> bin\bv_new.exe ...'

Push-Location $BinDir
try {
    if (Test-Path $TargetNew) { Remove-Item -Force $TargetNew }
    & $FpcExe -MObjFPC -Sh -O2 '-obv_new.exe' bv.pas
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

if (($exitCode -eq 0) -and (Test-Path $TargetNew)) {
    if (Test-Path $TargetExe) {
        Copy-Item -Force $TargetExe $TargetBak
        Write-Host '  [BACKUP] Previous binary preserved at bin\bv.bak.exe'
    }
    Move-Item -Force $TargetNew $TargetExe
    Write-Host ''
    Write-Host '  [SUCCESS] BlaiseVue CLI built cleanly: bin\bv.exe' -ForegroundColor Green
    & $TargetExe --version
    Write-Host ''
    Write-Host '  Next step (if not already in PATH):'
    Write-Host "    Add '$BinDir' to your User PATH, then run: bv doctor"
    Write-Host '================================================================'
    exit 0
} else {
    if (Test-Path $TargetNew) { Remove-Item -Force $TargetNew }
    Write-Host ''
    Write-Host '  [ERROR] Compilation failed. See Free Pascal output above.' -ForegroundColor Red
    if (Test-Path $TargetExe) {
        Write-Host '  [SAFETY] Existing bin\bv.exe was NOT modified and remains functional.' -ForegroundColor Yellow
    }
    Write-Host '================================================================'
    exit 1
}
