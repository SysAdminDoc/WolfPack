# =============================================================================
# WolfPack - Auto-Updater
# Checks GitHub releases for updates and hot-swaps the browser files
# =============================================================================

param(
    [switch]$Check,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WolfPackRoot = Split-Path -Parent $ScriptDir
$Repo = "SysAdminDoc/WolfPack"
$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"
$CurrentVersionFile = Join-Path $WolfPackRoot "version.txt"

function Write-Status($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

# Get current version
$currentVersion = ""
if (Test-Path $CurrentVersionFile) {
    $currentVersion = (Get-Content $CurrentVersionFile -Raw).Trim()
}

# Check latest release
Write-Status "Checking for updates..."
try {
    $headers = @{ "User-Agent" = "WolfPack-Updater" }
    $release = Invoke-RestMethod -Uri $ApiUrl -Headers $headers -UseBasicParsing
    $latestTag = $release.tag_name
    $latestVersion = $latestTag -replace '^v', ''
    Write-Success "Current: $currentVersion"
    Write-Success "Latest:  $latestVersion ($latestTag)"
} catch {
    Write-Warn "Failed to check for updates: $_"
    exit 1
}

if ($currentVersion -eq $latestVersion -and -not $Force) {
    Write-Success "Already up to date!"
    if ($Check) { exit 0 }
    exit 0
}

if ($Check) {
    Write-Warn "Update available: $currentVersion -> $latestVersion"
    Write-Host "Run without -Check to install the update."
    exit 0
}

# Find the portable zip asset
$zipAsset = $release.assets | Where-Object { $_.name -match "portable\.zip$" } | Select-Object -First 1
if (-not $zipAsset) {
    Write-Warn "No portable zip found in release assets."
    exit 1
}

$downloadUrl = $zipAsset.browser_download_url
$tempZip = Join-Path $env:TEMP "WolfPack-update.zip"
$tempExtract = Join-Path $env:TEMP "WolfPack-update"

# Check if WolfPack is running
$lwProc = Get-Process -Name "librewolf" -ErrorAction SilentlyContinue
if ($lwProc) {
    Write-Warn "WolfPack is currently running. Please close it before updating."
    $confirm = Read-Host "Kill running instance? (y/n)"
    if ($confirm -eq 'y') {
        Stop-Process -Name "librewolf" -Force
        Start-Sleep -Seconds 2
    } else {
        exit 1
    }
}

# Download
Write-Status "Downloading $($zipAsset.name) ($([math]::Round($zipAsset.size / 1MB, 1)) MB)..."
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "WolfPack-Updater")
$wc.DownloadFile($downloadUrl, $tempZip)
$wc.Dispose()
Write-Success "Downloaded update."

# Extract to temp
Write-Status "Extracting update..."
if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

# Find the LibreWolf app directory in the extracted update
$updateAppDir = $null
$searchPaths = @(
    (Join-Path $tempExtract "LibreWolf"),
    (Get-ChildItem -Path $tempExtract -Directory -Recurse | Where-Object { $_.Name -eq "LibreWolf" } | Select-Object -First 1 -ExpandProperty FullName)
)
foreach ($p in $searchPaths) {
    if ($p -and (Test-Path (Join-Path $p "librewolf.exe"))) {
        $updateAppDir = $p
        break
    }
}

if (-not $updateAppDir) {
    Write-Warn "Could not find LibreWolf directory in the update package."
    exit 1
}

# Backup current app directory
$currentAppDir = Join-Path $WolfPackRoot "LibreWolf"
$backupDir = Join-Path $WolfPackRoot "LibreWolf.bak"
if (Test-Path $backupDir) { Remove-Item $backupDir -Recurse -Force }

Write-Status "Backing up current installation..."
Rename-Item $currentAppDir $backupDir

# Copy new app files
Write-Status "Installing update..."
Copy-Item $updateAppDir $currentAppDir -Recurse -Force

# Copy updated root-level files (launchers, scripts, etc.)
$rootItems = Get-ChildItem -Path (Split-Path $updateAppDir) -File
foreach ($item in $rootItems) {
    if ($item.Name -notmatch "^(Profiles|LibreWolf|Backups)") {
        Copy-Item $item.FullName (Join-Path $WolfPackRoot $item.Name) -Force
    }
}

# Refresh the managed defaults while preserving the user's separate override file.
# The profile itself is intentionally not replaced: it contains bookmarks, cookies,
# extension state, and other user data.
$currentProfileDir = Join-Path $WolfPackRoot "Profiles\Default"
$updateProfileDir = Join-Path (Split-Path $updateAppDir) "Profiles\Default"
if (-not (Test-Path -LiteralPath $currentProfileDir)) {
    New-Item -ItemType Directory -Path $currentProfileDir -Force | Out-Null
}

$overridePath = Join-Path $currentProfileDir "user-overrides.js"
$overrideText = if (Test-Path -LiteralPath $overridePath) {
    Get-Content -LiteralPath $overridePath -Raw
} else {
    ""
}

$updatedUserJs = Join-Path $updateProfileDir "user.js"
if (Test-Path -LiteralPath $updatedUserJs) {
    Copy-Item -LiteralPath $updatedUserJs -Destination (Join-Path $currentProfileDir "user.js") -Force
}

$updatedOverride = Join-Path $updateProfileDir "user-overrides.js"
if ([string]::IsNullOrWhiteSpace($overrideText) -and (Test-Path -LiteralPath $updatedOverride)) {
    Copy-Item -LiteralPath $updatedOverride -Destination $overridePath -Force
    $overrideText = Get-Content -LiteralPath $overridePath -Raw
}

if (-not [string]::IsNullOrWhiteSpace($overrideText)) {
    $managedUserJs = Join-Path $currentProfileDir "user.js"
    if (Test-Path -LiteralPath $managedUserJs) {
        $managedText = Get-Content -LiteralPath $managedUserJs -Raw
        $managedText += "`r`n`r`n// WolfPack user-overrides.js (preserved across updates)`r`n$overrideText"
        Set-Content -LiteralPath $managedUserJs -Value $managedText -Encoding UTF8 -NoNewline
    }
}

# Update version file
Set-Content -Path $CurrentVersionFile -Value $latestVersion -Encoding UTF8

# Cleanup
Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $backupDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Success "Updated to $latestVersion!"
Write-Host ""
Write-Host "You can now launch WolfPack." -ForegroundColor White
