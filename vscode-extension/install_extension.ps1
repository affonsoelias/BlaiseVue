# BlaiseVue VS Code Extension Installer & Packager
# Automates the installation and packaging process for VS Code and Cursor.

$ErrorActionPreference = "Stop"

$SourceDir = $PSScriptRoot
$ExtensionName = "blaisevue-vscode"
$VSCodeExtensionsDir = Join-Path $env:USERPROFILE ".vscode\extensions"
$TargetDir = Join-Path $VSCodeExtensionsDir $ExtensionName

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   BlaiseVue 3.5 VS Code Extension Installer " -ForegroundColor Cyan
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

# 2. Check if VS Code Extensions directory exists
if (-not (Test-Path $VSCodeExtensionsDir)) {
    Write-Host "Creating VS Code extensions folder at: $VSCodeExtensionsDir"
    New-Item -ItemType Directory -Path $VSCodeExtensionsDir -Force | Out-Null
}

# 3. Cleanup existing installation
if (Test-Path $TargetDir) {
    Write-Host "Removing existing installation at $TargetDir..." -ForegroundColor Yellow
    Remove-Item -Path $TargetDir -Recurse -Force
}

# 4. Create target directory
Write-Host "Creating extension directory..."
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

# 5. Copy files
Write-Host "Copying extension files to $TargetDir..."
Copy-Item -Path (Join-Path $SourceDir "package.json") -Destination $TargetDir
Copy-Item -Path (Join-Path $SourceDir "language-configuration.json") -Destination $TargetDir
Copy-Item -Path (Join-Path $SourceDir "README.md") -Destination $TargetDir

if (Test-Path (Join-Path $SourceDir "src")) {
    Copy-Item -Path (Join-Path $SourceDir "src") -Destination $TargetDir -Recurse
}
if (Test-Path (Join-Path $SourceDir "data")) {
    Copy-Item -Path (Join-Path $SourceDir "data") -Destination $TargetDir -Recurse
}
if (Test-Path (Join-Path $SourceDir "syntaxes")) {
    Copy-Item -Path (Join-Path $SourceDir "syntaxes") -Destination $TargetDir -Recurse
}
if (Test-Path (Join-Path $SourceDir "snippets")) {
    Copy-Item -Path (Join-Path $SourceDir "snippets") -Destination $TargetDir -Recurse
}

Write-Host ""
Write-Host "Installation completed successfully!" -ForegroundColor Green
Write-Host "Restart VS Code or run Developer: Reload Window to activate." -ForegroundColor Cyan
Write-Host "---------------------------------------------"
