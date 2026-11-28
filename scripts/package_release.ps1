<#
.SYNOPSIS
    Packages a standalone release archive of BlaiseVue CLI & SDK for Windows x86_64.
    Includes bv.exe, core/, packages/core/, templates/, vendor/zephyr/, and the Windows Pas2JS compiler.
    Excludes vendor/mormot2/ and demo-app/ (fetched on demand by the CLI).
#>

param(
    [string]$Version = "",
    [string]$OutDir = "dist",
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $RepoRoot

try {
    if ([string]::IsNullOrWhiteSpace($Version)) {
        $pkgFile = Join-Path $RepoRoot "package.json"
        if (Test-Path $pkgFile) {
            try {
                $pkg = Get-Content $pkgFile -Raw | ConvertFrom-Json
                if ($pkg.version) { $Version = [string]$pkg.version }
            } catch {
                $Version = ""
            }
        }
        if ([string]::IsNullOrWhiteSpace($Version)) {
            $Version = "0.1.0"
        }
    }

    $CleanVersion = $Version.Trim()
    if ($CleanVersion.StartsWith("v") -or $CleanVersion.StartsWith("V")) {
        $CleanVersion = $CleanVersion.Substring(1)
    }

    if (-not $SkipBuild) {
        $buildScript = Join-Path $RepoRoot "build.ps1"
        if (Test-Path $buildScript) {
            & powershell -ExecutionPolicy Bypass -NoProfile -File $buildScript
            if ($LASTEXITCODE -ne 0) {
                throw "BlaiseVue build.ps1 failed with exit code $LASTEXITCODE"
            }
        } else {
            Push-Location (Join-Path $RepoRoot "bin")
            try {
                & fpc -MObjFPC -Sh -O2 -obv.exe bv.pas
                if ($LASTEXITCODE -ne 0) {
                    throw "FPC build failed with exit code $LASTEXITCODE"
                }
            } finally {
                Pop-Location
            }
        }
    }

    $exePath = Join-Path $RepoRoot "bin\bv.exe"
    if (-not (Test-Path $exePath)) {
        throw "BlaiseVue CLI binary not found at $exePath"
    }

    if (-not [System.IO.Path]::IsPathRooted($OutDir)) {
        $OutDirFull = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $OutDir))
    } else {
        $OutDirFull = [System.IO.Path]::GetFullPath($OutDir)
    }
    if (-not (Test-Path $OutDirFull)) {
        New-Item -ItemType Directory -Path $OutDirFull -Force | Out-Null
    }

    $Arch = "x86_64"
    $AssetBase = "blaisevue-v$CleanVersion-windows-$Arch"
    $StageDir = Join-Path $OutDirFull "_stage_$AssetBase"
    if (Test-Path $StageDir) { Remove-Item $StageDir -Recurse -Force }
    New-Item -ItemType Directory -Path (Join-Path $StageDir "bin") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $StageDir "vendor\pas2js") -Force | Out-Null

    # 1. CLI binary & companion Node scripts / studio assets
    Copy-Item $exePath (Join-Path $StageDir "bin\bv.exe") -Force
    foreach ($helperScript in @("dev-server.js", "studio-server.js")) {
        $srcHelper = Join-Path $RepoRoot "bin\$helperScript"
        if (Test-Path $srcHelper) {
            Copy-Item $srcHelper (Join-Path $StageDir "bin\$helperScript") -Force
        }
    }
    $studioSrc = Join-Path $RepoRoot "bin\studio"
    if (Test-Path $studioSrc) {
        Copy-Item $studioSrc (Join-Path $StageDir "bin\studio") -Recurse -Force
    }

    # 2. Core framework, official packages, templates & Zephyr runtime
    foreach ($dirRel in @("core", "templates")) {
        $srcDir = Join-Path $RepoRoot $dirRel
        if (Test-Path $srcDir) {
            Copy-Item $srcDir (Join-Path $StageDir $dirRel) -Recurse -Force
        }
    }

    $pkgCoreSrc = Join-Path $RepoRoot "packages\core"
    if (Test-Path $pkgCoreSrc) {
        New-Item -ItemType Directory -Path (Join-Path $StageDir "packages") -Force | Out-Null
        Copy-Item $pkgCoreSrc (Join-Path $StageDir "packages\core") -Recurse -Force
    }

    $zephyrSrc = Join-Path $RepoRoot "vendor\zephyr"
    if (Test-Path $zephyrSrc) {
        Copy-Item $zephyrSrc (Join-Path $StageDir "vendor\zephyr") -Recurse -Force
    }

    # 3. Matching Windows x86_64 Pas2JS distribution ONLY
    $pas2jsWin = Get-ChildItem (Join-Path $RepoRoot "vendor\pas2js") -Directory -Filter "pas2js-win64-x86_64*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $pas2jsWin) {
        throw "Matching Windows Pas2JS directory (vendor\pas2js\pas2js-win64-x86_64*) not found."
    }
    Copy-Item $pas2jsWin.FullName (Join-Path $StageDir "vendor\pas2js\$($pas2jsWin.Name)") -Recurse -Force

    # 4. Root metadata files (package.json is used by bv --version / GetCliVersion)
    foreach ($rootFile in @("package.json", "README.md", "LICENSE")) {
        $srcFile = Join-Path $RepoRoot $rootFile
        if (Test-Path $srcFile) {
            Copy-Item $srcFile $StageDir -Force
        }
    }

    # Auto-stamp staged package.json version to match the exact release/tag version
    $stagedPkg = Join-Path $StageDir "package.json"
    if (Test-Path $stagedPkg) {
        try {
            $pkgObj = Get-Content $stagedPkg -Raw | ConvertFrom-Json
            $pkgObj.version = $CleanVersion
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($stagedPkg, ($pkgObj | ConvertTo-Json -Depth 10) + "`n", $utf8NoBom)
        } catch {
            Write-Warning "Could not update staged package.json version: $_"
        }
    }

    # Scrub any stray build artifacts inside staged core/packages
    Get-ChildItem -Path $StageDir -Recurse -Include "*.o", "*.ppu", "*.dcu", "*.bak", "*.log" -File -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue

    $ArchiveName = "$AssetBase.zip"
    $ArchivePath = Join-Path $OutDirFull $ArchiveName
    if (Test-Path $ArchivePath) { Remove-Item $ArchivePath -Force }
    Compress-Archive -Path (Join-Path $StageDir "*") -DestinationPath $ArchivePath -CompressionLevel Optimal
    Remove-Item $StageDir -Recurse -Force

    $Hash = (Get-FileHash -Path $ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    "$Hash  $ArchiveName" | Set-Content (Join-Path $OutDirFull "$ArchiveName.sha256") -Encoding ASCII
    "$Hash  $ArchiveName" | Set-Content (Join-Path $OutDirFull "SHA256SUMS.txt") -Encoding ASCII

    Write-Host "[OK] Packaged $ArchivePath" -ForegroundColor Green
    Write-Host "[OK] SHA-256: $Hash" -ForegroundColor Cyan
}
finally {
    Pop-Location
}
