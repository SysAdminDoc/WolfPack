# =============================================================================
# WolfPack - Windows Default Browser Registration
# Registers WolfPack as a selectable default browser in Windows Settings
# =============================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WolfPackRoot = Split-Path -Parent $ScriptDir

function Write-Status($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

# Find librewolf.exe
$exePaths = @(
    (Join-Path $WolfPackRoot "LibreWolf\librewolf.exe"),
    (Join-Path $WolfPackRoot "librewolf\librewolf.exe"),
    (Join-Path $WolfPackRoot "librewolf.exe")
)
$lwExe = $exePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $lwExe) {
    Write-Warn "Could not find librewolf.exe"
    exit 1
}

$lwExe = (Resolve-Path $lwExe).Path
$icoPath = Join-Path $WolfPackRoot "wolfpack.ico"
if (-not (Test-Path $icoPath)) { $icoPath = "$lwExe,0" }

Write-Status "Registering WolfPack as a browser..."

$appId = "WolfPack"
$appName = "WolfPack"
$appDesc = "Privacy-focused browser based on LibreWolf"

# Register application
$appKey = "HKCU:\Software\Clients\StartMenuInternet\$appId"
New-Item -Path $appKey -Force | Out-Null
Set-ItemProperty -Path $appKey -Name "(Default)" -Value $appName

# Capabilities
$capKey = "$appKey\Capabilities"
New-Item -Path $capKey -Force | Out-Null
Set-ItemProperty -Path $capKey -Name "ApplicationDescription" -Value $appDesc
Set-ItemProperty -Path $capKey -Name "ApplicationIcon" -Value "$icoPath"
Set-ItemProperty -Path $capKey -Name "ApplicationName" -Value $appName

# URL associations
$urlAssoc = "$capKey\URLAssociations"
New-Item -Path $urlAssoc -Force | Out-Null
Set-ItemProperty -Path $urlAssoc -Name "http" -Value "WolfPackURL"
Set-ItemProperty -Path $urlAssoc -Name "https" -Value "WolfPackURL"
Set-ItemProperty -Path $urlAssoc -Name "ftp" -Value "WolfPackURL"

# File associations
$fileAssoc = "$capKey\FileAssociations"
New-Item -Path $fileAssoc -Force | Out-Null
foreach ($ext in @(".htm", ".html", ".shtml", ".xhtml", ".svg", ".webp", ".pdf")) {
    Set-ItemProperty -Path $fileAssoc -Name $ext -Value "WolfPackHTML"
}

# Default icon
$iconKey = "$appKey\DefaultIcon"
New-Item -Path $iconKey -Force | Out-Null
Set-ItemProperty -Path $iconKey -Name "(Default)" -Value "$icoPath"

# Shell open command
$cmdKey = "$appKey\shell\open\command"
New-Item -Path $cmdKey -Force | Out-Null
$profileDir = Join-Path $WolfPackRoot "Profiles\Default"
Set-ItemProperty -Path $cmdKey -Name "(Default)" -Value "`"$lwExe`" --profile `"$profileDir`" --no-remote `"%1`""

# Register URL protocol handler
$urlKey = "HKCU:\Software\Classes\WolfPackURL"
New-Item -Path $urlKey -Force | Out-Null
Set-ItemProperty -Path $urlKey -Name "(Default)" -Value "WolfPack URL"
Set-ItemProperty -Path $urlKey -Name "URL Protocol" -Value ""
New-Item -Path "$urlKey\DefaultIcon" -Force | Out-Null
Set-ItemProperty -Path "$urlKey\DefaultIcon" -Name "(Default)" -Value "$icoPath"
New-Item -Path "$urlKey\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$urlKey\shell\open\command" -Name "(Default)" -Value "`"$lwExe`" --profile `"$profileDir`" --no-remote `"%1`""

# Register HTML file handler
$htmlKey = "HKCU:\Software\Classes\WolfPackHTML"
New-Item -Path $htmlKey -Force | Out-Null
Set-ItemProperty -Path $htmlKey -Name "(Default)" -Value "WolfPack Document"
New-Item -Path "$htmlKey\DefaultIcon" -Force | Out-Null
Set-ItemProperty -Path "$htmlKey\DefaultIcon" -Name "(Default)" -Value "$icoPath"
New-Item -Path "$htmlKey\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$htmlKey\shell\open\command" -Name "(Default)" -Value "`"$lwExe`" --profile `"$profileDir`" --no-remote `"%1`""

# Register with Windows Registered Applications
$regApps = "HKCU:\Software\RegisteredApplications"
if (-not (Test-Path $regApps)) { New-Item -Path $regApps -Force | Out-Null }
Set-ItemProperty -Path $regApps -Name $appId -Value "Software\Clients\StartMenuInternet\$appId\Capabilities"

Write-Success "WolfPack registered as a browser!"
Write-Host ""
Write-Host "Open Windows Settings > Default Apps to set WolfPack as your default browser." -ForegroundColor White
Write-Host "Or run: ms-settings:defaultapps" -ForegroundColor Gray
