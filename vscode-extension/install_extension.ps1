# BlaiseVue Extension Installer & Packager
# Supports Antigravity IDE, Cursor, and VS Code.

$ErrorActionPreference = "Stop"

$SourceDir = $PSScriptRoot
$ExtensionFolderName = "blaisevue.blaisevue-vscode-3.5.0"

$TargetExtensionDirs = @(
    (Join-Path $env:USERPROFILE ".antigravity-ide\extensions"),
    (Join-Path $env:USERPROFILE ".antigravity\extensions"),
    (Join-Path $env:USERPROFILE ".vscode\extensions")
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  BlaiseVue 3.5 Extension Installer (IDE)   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Package .vsix if npx is available
Write-Host "Packaging standalone .vsix..." -ForegroundColor Yellow
try {
    npx @vscode/vsce package --no-git-tag-version --allow-missing-repository
    Write-Host "VSIX package generated successfully!" -ForegroundColor Green
} catch {
    Write-Warning "VSIX packaging skipped. Continuing directory installation..."
}

# 2. Install to detected IDE directories
foreach ($extBase in $TargetExtensionDirs) {
    if (Test-Path $extBase) {
        $target = Join-Path $extBase $ExtensionFolderName
        Write-Host "Deploying extension to: $target" -ForegroundColor Cyan
        if (Test-Path $target) {
            Remove-Item -Path $target -Recurse -Force
        }
        New-Item -ItemType Directory -Path $target -Force | Out-Null

        Copy-Item -Path (Join-Path $SourceDir "package.json") -Destination $target
        Copy-Item -Path (Join-Path $SourceDir "language-configuration.json") -Destination $target
        Copy-Item -Path (Join-Path $SourceDir "README.md") -Destination $target
        Copy-Item -Path (Join-Path $SourceDir "LICENSE") -Destination $target

        if (Test-Path (Join-Path $SourceDir "src")) {
            Copy-Item -Path (Join-Path $SourceDir "src") -Destination $target -Recurse
        }
        if (Test-Path (Join-Path $SourceDir "data")) {
            Copy-Item -Path (Join-Path $SourceDir "data") -Destination $target -Recurse
        }
        if (Test-Path (Join-Path $SourceDir "syntaxes")) {
            Copy-Item -Path (Join-Path $SourceDir "syntaxes") -Destination $target -Recurse
        }
        if (Test-Path (Join-Path $SourceDir "snippets")) {
            Copy-Item -Path (Join-Path $SourceDir "snippets") -Destination $target -Recurse
        }
        Write-Host "Installed in $extBase!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Installation completed successfully!" -ForegroundColor Green
Write-Host "Restart Antigravity IDE or run Developer: Reload Window to activate." -ForegroundColor Cyan
Write-Host "---------------------------------------------"
