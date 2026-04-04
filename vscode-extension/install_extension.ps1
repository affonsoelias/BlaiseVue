# BlaiseVue VS Code Extension Installer
# This script automates the manual installation process.

$ErrorActionPreference = "Stop"

# 1. Define paths
$SourceDir = $PSScriptRoot
$ExtensionName = "blaisevue-vscode"
$VSCodeExtensionsDir = Join-Path $env:USERPROFILE ".vscode\extensions"
$TargetDir = Join-Path $VSCodeExtensionsDir $ExtensionName

Write-Host "--- BlaiseVue VS Code Extension Installer ---" -ForegroundColor Cyan

# 2. Check if VS Code Extensions directory exists
if (-not (Test-Path $VSCodeExtensionsDir)) {
    Write-Error "VS Code extensions directory not found at: $VSCodeExtensionsDir"
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

# Copy subdirectories
if (Test-Path (Join-Path $SourceDir "syntaxes")) {
    Copy-Item -Path (Join-Path $SourceDir "syntaxes") -Destination $TargetDir -Recurse
}
if (Test-Path (Join-Path $SourceDir "snippets")) {
    Copy-Item -Path (Join-Path $SourceDir "snippets") -Destination $TargetDir -Recurse
}

Write-Host ""
Write-Host "✅ Installation successful!" -ForegroundColor Green
Write-Host "🚀 Please RESTART VS Code or run 'Developer: Reload Window' (Ctrl+Shift+P) to activate." -ForegroundColor Cyan
Write-Host "--------------------------------------------"
