<#
.SYNOPSIS
    Official BlaiseVue SDK & CLI Installer for Windows.
    Installs bv.exe, core/, packages/core/, templates/, vendor/zephyr/, and Windows Pas2JS
    into %USERPROFILE%\.blaisevue and updates the User PATH.
#>

param(
    [string]$Version = "",
    [string]$Repo = $(if ($env:BLAISEVUE_UPGRADE_REPO) { $env:BLAISEVUE_UPGRADE_REPO } else { "affonsoelias/BlaiseVue" }),
    [string]$InstallRoot = $(if ($env:BLAISEVUE_HOME) { $env:BLAISEVUE_HOME } else { Join-Path $env:USERPROFILE ".blaisevue" }),
    [string]$Channel = "",
    [switch]$Nightly,
    [switch]$AllowUnsigned,
    [switch]$NoPathUpdate
)

$ErrorActionPreference = "Stop"

# Normalize channel aliases (main -> stable, develop/dev -> nightly)
$ResolvedChannel = "stable"
if (-not [string]::IsNullOrWhiteSpace($Channel)) {
    switch ($Channel.Trim().ToLowerInvariant()) {
        "main"    { $ResolvedChannel = "stable" }
        "stable"  { $ResolvedChannel = "stable" }
        "develop" { $ResolvedChannel = "nightly"; $Nightly = $true }
        "dev"     { $ResolvedChannel = "nightly"; $Nightly = $true }
        "nightly" { $ResolvedChannel = "nightly"; $Nightly = $true }
        default   { throw "Invalid channel '$Channel'. Valid options: stable (main) or nightly (develop)." }
    }
} elseif ($Nightly) {
    $ResolvedChannel = "nightly"
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  BlaiseVue Official Installer (Windows)                " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$apiHeaders = @{ "User-Agent" = "BlaiseVue-Installer"; "Accept" = "application/vnd.github.v3+json" }
if ($Version) {
    $verTag = if ($Version.StartsWith("v")) { $Version } else { "v$Version" }
    $releaseUrl = "https://api.github.com/repos/$Repo/releases/tags/$verTag"
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers $apiHeaders
} elseif ($Nightly) {
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases?per_page=15" -Headers $apiHeaders
    $release = $releases | Where-Object { $_.prerelease -or ($_.tag_name -like "*nightly*") -or ($_.tag_name -eq "dev") } | Select-Object -First 1
    if (-not $release) { $release = $releases | Select-Object -First 1 }
} else {
    $releaseUrl = "https://api.github.com/repos/$Repo/releases/latest"
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers $apiHeaders
}

if (-not $release) {
    throw "No published release found for repository $Repo."
}

$asset = $release.assets | Where-Object {
    ($_.name -match "windows") -and ($_.name -match "x86_64|x64|amd64") -and ($_.name -notmatch "\.(sha256|sig|asc)$")
} | Select-Object -First 1

if (-not $asset) {
    throw "No compatible Windows x86_64 archive found in release $($release.tag_name)."
}

$sumAsset = $release.assets | Where-Object {
    $_.name -eq "$($asset.name).sha256" -or $_.name -eq "SHA256SUMS.txt"
} | Select-Object -First 1

$tmpDir = Join-Path $env:TEMP ("blaisevue_install_" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

try {
    $pkgPath = Join-Path $tmpDir $asset.name
    $extDir = Join-Path $tmpDir "extracted"
    Write-Host "[1/4] Downloading $($asset.name) ($($release.tag_name))..."
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $pkgPath -Headers $apiHeaders

    Write-Host "[2/4] Verifying SHA-256 integrity..."
    $computedHash = (Get-FileHash -Path $pkgPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($sumAsset) {
        $sumText = (Invoke-WebRequest -Uri $sumAsset.browser_download_url -Headers $apiHeaders).Content
        if ($sumText.ToLowerInvariant() -notmatch [regex]::Escape($computedHash)) {
            throw "SHA-256 verification failed for $($asset.name)!"
        }
        Write-Host "      [OK] Checksum verified: $computedHash" -ForegroundColor Green
    } elseif (-not $AllowUnsigned) {
        throw "No SHA-256 checksum asset found. Pass -AllowUnsigned to override."
    }

    Write-Host "[3/4] Installing into $InstallRoot..."
    Expand-Archive -Path $pkgPath -DestinationPath $extDir -Force
    $exeSrc = Get-ChildItem -Path $extDir -Recurse -Filter "bv.exe" | Select-Object -First 1
    if (-not $exeSrc) { throw "bv.exe not found inside archive." }

    # Determine extracted SDK root (parent of bin/)
    $srcSdkRoot = Split-Path -Parent $exeSrc.DirectoryName
    if (-not (Test-Path (Join-Path $srcSdkRoot "core"))) {
        $srcSdkRoot = $extDir
    }

    New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
    $binDest = Join-Path $InstallRoot "bin"
    New-Item -ItemType Directory -Path $binDest -Force | Out-Null

    # Copy bin contents (preserving bv.bak.exe if present)
    Copy-Item (Join-Path $exeSrc.DirectoryName "*") $binDest -Recurse -Force

    # Sync SDK runtime folders cleanly (preserve ~/.blaisevue/versions, cache, config.json, projects.json)
    foreach ($relDir in @("core", "templates")) {
        $src = Join-Path $srcSdkRoot $relDir
        $dst = Join-Path $InstallRoot $relDir
        if (Test-Path $src) {
            if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
            Copy-Item $src $dst -Recurse -Force
        }
    }

    $pkgCoreSrc = Join-Path $srcSdkRoot "packages\core"
    $pkgCoreDst = Join-Path $InstallRoot "packages\core"
    if (Test-Path $pkgCoreSrc) {
        New-Item -ItemType Directory -Path (Join-Path $InstallRoot "packages") -Force | Out-Null
        if (Test-Path $pkgCoreDst) { Remove-Item $pkgCoreDst -Recurse -Force }
        Copy-Item $pkgCoreSrc $pkgCoreDst -Recurse -Force
    }

    foreach ($vSub in @("zephyr", "pas2js")) {
        $vSrc = Join-Path $srcSdkRoot "vendor\$vSub"
        $vDst = Join-Path $InstallRoot "vendor\$vSub"
        if (Test-Path $vSrc) {
            New-Item -ItemType Directory -Path (Join-Path $InstallRoot "vendor") -Force | Out-Null
            if (Test-Path $vDst) { Remove-Item $vDst -Recurse -Force }
            Copy-Item $vSrc $vDst -Recurse -Force
        }
    }

    foreach ($metaFile in @("package.json", "README.md", "LICENSE")) {
        $fSrc = Join-Path $srcSdkRoot $metaFile
        if (Test-Path $fSrc) {
            Copy-Item $fSrc (Join-Path $InstallRoot $metaFile) -Force
        }
    }

    # Persist release channel in ~/.blaisevue/config.json
    $cfgPath = Join-Path $InstallRoot "config.json"
    $cfgObj = @{}
    if (Test-Path $cfgPath) {
        try {
            $parsed = Get-Content $cfgPath -Raw | ConvertFrom-Json
            foreach ($prop in $parsed.PSObject.Properties) {
                $cfgObj[$prop.Name] = $prop.Value
            }
        } catch {
            $cfgObj = @{}
        }
    }
    $cfgObj["channel"] = $ResolvedChannel
    ($cfgObj | ConvertTo-Json -Depth 4) | Set-Content -Path $cfgPath -Encoding UTF8

    if (-not $NoPathUpdate) {
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ([string]::IsNullOrEmpty($userPath)) {
            [Environment]::SetEnvironmentVariable("Path", $binDest, "User")
            $env:Path = "$binDest;$env:Path"
            Write-Host "      [OK] Added $binDest to user PATH." -ForegroundColor Green
        } elseif ($userPath -notlike "*$binDest*") {
            [Environment]::SetEnvironmentVariable("Path", "$binDest;$userPath", "User")
            $env:Path = "$binDest;$env:Path"
            Write-Host "      [OK] Added $binDest to user PATH." -ForegroundColor Green
        }
    }

    Write-Host "[4/4] Verifying installation (channel: $ResolvedChannel)..."
    & (Join-Path $binDest "bv.exe") --version
}
finally {
    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
