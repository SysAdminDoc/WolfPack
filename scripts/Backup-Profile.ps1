# =============================================================================
# WolfPack - Profile Backup & Restore
# Creates timestamped zip backups of the WolfPack profile
# =============================================================================

param(
    [switch]$Restore,
    [string]$BackupFile = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WolfPackRoot = Split-Path -Parent $ScriptDir
$ProfileDir = Join-Path $WolfPackRoot "Profiles\Default"
$BackupDir = Join-Path $WolfPackRoot "Backups"

function Write-Status($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

if (-not (Test-Path $ProfileDir)) {
    Write-Warn "Profile directory not found: $ProfileDir"
    Write-Warn "Launch WolfPack at least once to create a profile."
    exit 1
}

if ($Restore) {
    # --- Restore Mode ---
    if (-not $BackupFile) {
        # Show available backups
        if (-not (Test-Path $BackupDir)) {
            Write-Warn "No backups found in: $BackupDir"
            exit 1
        }
        $backups = Get-ChildItem -Path $BackupDir -Filter "WolfPack-Backup-*.zip" | Sort-Object LastWriteTime -Descending
        if ($backups.Count -eq 0) {
            Write-Warn "No backup files found."
            exit 1
        }
        Write-Host ""
        Write-Host "Available backups:" -ForegroundColor Magenta
        for ($i = 0; $i -lt $backups.Count; $i++) {
            $size = [math]::Round($backups[$i].Length / 1MB, 1)
            Write-Host "  [$i] $($backups[$i].Name) ($size MB)" -ForegroundColor White
        }
        Write-Host ""
        $selection = Read-Host "Enter number to restore (or 'q' to quit)"
        if ($selection -eq 'q') { exit 0 }
        $idx = [int]$selection
        if ($idx -lt 0 -or $idx -ge $backups.Count) {
            Write-Warn "Invalid selection."
            exit 1
        }
        $BackupFile = $backups[$idx].FullName
    }

    if (-not (Test-Path $BackupFile)) {
        Write-Warn "Backup file not found: $BackupFile"
        exit 1
    }

    Write-Status "Restoring profile from: $(Split-Path -Leaf $BackupFile)"

    # Kill running instances
    $lwProc = Get-Process -Name "librewolf" -ErrorAction SilentlyContinue
    if ($lwProc) {
        Write-Warn "WolfPack is running. Close it before restoring."
        exit 1
    }

    # Backup current profile before overwriting
    $safetyBackup = Join-Path $BackupDir "WolfPack-PreRestore-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Compress-Archive -Path "$ProfileDir\*" -DestinationPath $safetyBackup -CompressionLevel Fastest
    Write-Success "Safety backup created: $(Split-Path -Leaf $safetyBackup)"

    # Clear and restore
    Remove-Item "$ProfileDir\*" -Recurse -Force
    Expand-Archive -Path $BackupFile -DestinationPath $ProfileDir -Force
    Write-Success "Profile restored successfully!"
} else {
    # --- Backup Mode ---
    Write-Status "Backing up WolfPack profile..."

    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $zipName = "WolfPack-Backup-$timestamp.zip"
    $zipPath = Join-Path $BackupDir $zipName

    # Exclude cache directories to keep backups small
    $tempStaging = Join-Path $env:TEMP "WolfPack-Backup-Staging"
    if (Test-Path $tempStaging) { Remove-Item $tempStaging -Recurse -Force }

    # Copy profile excluding caches
    $excludeDirs = @("cache2", "startupCache", "shader-cache", "thumbnails", "safebrowsing")
    $items = Get-ChildItem -Path $ProfileDir
    New-Item -ItemType Directory -Path $tempStaging -Force | Out-Null

    foreach ($item in $items) {
        if ($excludeDirs -contains $item.Name) { continue }
        if ($item.PSIsContainer) {
            Copy-Item $item.FullName (Join-Path $tempStaging $item.Name) -Recurse -Force
        } else {
            Copy-Item $item.FullName (Join-Path $tempStaging $item.Name) -Force
        }
    }

    Compress-Archive -Path "$tempStaging\*" -DestinationPath $zipPath -CompressionLevel Optimal
    Remove-Item $tempStaging -Recurse -Force

    $size = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
    Write-Success "Backup created: $zipName ($size MB)"
    Write-Success "Location: $BackupDir"

    # Keep only last 5 backups
    $oldBackups = Get-ChildItem -Path $BackupDir -Filter "WolfPack-Backup-*.zip" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip 5
    foreach ($old in $oldBackups) {
        Remove-Item $old.FullName -Force
        Write-Warn "Pruned old backup: $($old.Name)"
    }
}
