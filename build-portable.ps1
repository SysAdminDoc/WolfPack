# =============================================================================
# WolfPack - Build Script v1.4.0
# Downloads latest LibreWolf, injects custom config, packages portable + installer
# =============================================================================

param(
    [string]$Version = "",
    [string]$Arch = "x86_64",
    [switch]$SkipDownload,
    [switch]$PortableOnly,
    [switch]$InstallerOnly
)

$ErrorActionPreference = "Stop"
$ProjectName = "WolfPack"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildDir = Join-Path $ScriptDir "build"
$OutputDir = Join-Path $ScriptDir "output"
$GitLabProjectId = "44042130"
$GitLabApiBase = "https://gitlab.com/api/v4/projects/$GitLabProjectId"

# ---- Functions ----

function Write-Status($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

function Get-LatestVersion {
    Write-Status "Fetching latest LibreWolf release version..."
    $release = Invoke-RestMethod -Uri "$GitLabApiBase/releases/permalink/latest" -UseBasicParsing
    $tag = $release.tag_name
    Write-Success "Latest version: $tag"
    return $tag
}

function Download-LibreWolf($ver, $arch) {
    $fileName = "librewolf-$ver-windows-$arch-portable.zip"
    $url = "$GitLabApiBase/packages/generic/librewolf/$ver/$fileName"
    $dest = Join-Path $BuildDir $fileName

    if (Test-Path $dest) {
        Write-Warn "Already downloaded: $fileName"
        return $dest
    }

    Write-Status "Downloading $fileName..."
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $dest)
    $wc.Dispose()

    $size = [math]::Round((Get-Item $dest).Length / 1MB, 1)
    Write-Success "Downloaded: $fileName ($size MB)"
    return $dest
}

function Extract-LibreWolf($zipPath, $extractTo) {
    Write-Status "Extracting LibreWolf..."
    $tempExtract = "$extractTo-temp"
    if (Test-Path $tempExtract) { Remove-Item $tempExtract -Recurse -Force }
    if (Test-Path $extractTo) { Remove-Item $extractTo -Recurse -Force }

    Expand-Archive -Path $zipPath -DestinationPath $tempExtract -Force

    # The portable zip nests everything under a version folder (e.g. librewolf-146.0.1-1/)
    # Unwrap it so our root is the portable directory directly
    $innerDirs = Get-ChildItem -Path $tempExtract -Directory
    if ($innerDirs.Count -eq 1 -and $innerDirs[0].Name -match "librewolf") {
        $innerPath = $innerDirs[0].FullName
        # Check if this inner folder has LibreWolf/ or librewolf.exe
        if ((Test-Path (Join-Path $innerPath "LibreWolf")) -or
            (Test-Path (Join-Path $innerPath "librewolf.exe"))) {
            Move-Item $innerPath $extractTo
            Remove-Item $tempExtract -Recurse -Force
            Write-Success "Extracted and unwrapped to: $extractTo"
            return
        }
    }

    # No nesting detected, use as-is
    Move-Item $tempExtract $extractTo
    Write-Success "Extracted to: $extractTo"
}

function Find-AppDir($lwRoot) {
    # Search for librewolf.exe in common locations
    $searchPaths = @(
        (Join-Path $lwRoot "LibreWolf\librewolf.exe"),
        (Join-Path $lwRoot "librewolf\librewolf.exe"),
        (Join-Path $lwRoot "librewolf.exe")
    )
    foreach ($p in $searchPaths) {
        if (Test-Path $p) { return (Split-Path -Parent $p) }
    }

    # Deep search as fallback
    $found = Get-ChildItem -Path $lwRoot -Filter "librewolf.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.DirectoryName }

    throw "Could not find librewolf.exe in: $lwRoot"
}

function Patch-LibreWolfCfg($appDir) {
    Write-Status "Patching librewolf.cfg to fix common issues..."

    $cfgPath = Join-Path $appDir "librewolf.cfg"
    if (-not (Test-Path $cfgPath)) {
        Write-Warn "  librewolf.cfg not found, skipping patch"
        return
    }

    $cfg = Get-Content $cfgPath -Raw

    # --- Fix DRM (Netflix, Disney+, Spotify) ---
    # Change DRM from disabled to enabled
    $cfg = $cfg -replace 'defaultPref\("media\.eme\.enabled",\s*false\)', 'defaultPref("media.eme.enabled", true)'
    $cfg = $cfg -replace 'defaultPref\("media\.gmp-manager\.url",\s*"data:text/plain,"\)', '// defaultPref("media.gmp-manager.url", "data:text/plain,"); // Allow GMP updates for DRM'
    $cfg = $cfg -replace 'defaultPref\("media\.gmp-provider\.enabled",\s*false\)', 'defaultPref("media.gmp-provider.enabled", true)'
    $cfg = $cfg -replace 'defaultPref\("media\.gmp-gmpopenh264\.enabled",\s*false\)', 'defaultPref("media.gmp-gmpopenh264.enabled", true)'

    # --- Fix disk cache (performance) ---
    $cfg = $cfg -replace 'defaultPref\("browser\.cache\.disk\.enable",\s*false\)', 'defaultPref("browser.cache.disk.enable", true)'

    # --- Fix search suggestions ---
    $cfg = $cfg -replace 'defaultPref\("browser\.urlbar\.suggest\.searches",\s*false\)', 'defaultPref("browser.urlbar.suggest.searches", true)'
    $cfg = $cfg -replace 'defaultPref\("browser\.search\.suggest\.enabled",\s*false\)', 'defaultPref("browser.search.suggest.enabled", true)'

    # --- Fix RFP (Resist Fingerprinting) causing site breakage ---
    $cfg = $cfg -replace 'defaultPref\("privacy\.resistFingerprinting",\s*true\)', 'defaultPref("privacy.resistFingerprinting", false)'
    $cfg = $cfg -replace 'defaultPref\("privacy\.globalprivacycontrol\.enabled",\s*true\)', 'defaultPref("privacy.globalprivacycontrol.enabled", false)'
    $cfg = $cfg -replace 'defaultPref\("privacy\.globalprivacycontrol\.functionality\.enabled",\s*true\)', 'defaultPref("privacy.globalprivacycontrol.functionality.enabled", false)'

    # --- Fix downloads always prompting ---
    $cfg = $cfg -replace 'defaultPref\("browser\.download\.useDownloadDir",\s*false\)', 'defaultPref("browser.download.useDownloadDir", true)'

    # --- Fix cookies cleared on shutdown (users getting logged out) ---
    $cfg = $cfg -replace 'defaultPref\("privacy\.sanitize\.sanitizeOnShutdown",\s*true\)', 'defaultPref("privacy.sanitize.sanitizeOnShutdown", false)'

    # --- Fix form history disabled ---
    $cfg = $cfg -replace 'defaultPref\("browser\.formfill\.enable",\s*false\)', 'defaultPref("browser.formfill.enable", true)'

    # --- Fix session store privacy level (allow session restore) ---
    $cfg = $cfg -replace 'defaultPref\("browser\.sessionstore\.privacy_level",\s*2\)', 'defaultPref("browser.sessionstore.privacy_level", 0)'

    # --- Fix password manager / autofill disabled ---
    $cfg = $cfg -replace 'defaultPref\("signon\.rememberSignons",\s*false\)', 'defaultPref("signon.rememberSignons", true)'
    $cfg = $cfg -replace 'defaultPref\("signon\.autofillForms",\s*false\)', 'defaultPref("signon.autofillForms", true)'
    $cfg = $cfg -replace 'defaultPref\("extensions\.formautofill\.addresses\.enabled",\s*false\)', 'defaultPref("extensions.formautofill.addresses.enabled", true)'
    $cfg = $cfg -replace 'defaultPref\("extensions\.formautofill\.creditCards\.enabled",\s*false\)', 'defaultPref("extensions.formautofill.creditCards.enabled", true)'
    $cfg = $cfg -replace 'defaultPref\("signon\.formlessCapture\.enabled",\s*false\)', 'defaultPref("signon.formlessCapture.enabled", true)'

    # --- Fix prefetching disabled (performance) ---
    # Change pref() to defaultPref() so user.js can override, and enable by default
    $cfg = $cfg -replace 'pref\("network\.prefetch-next",\s*false\)', 'defaultPref("network.prefetch-next", true)'
    $cfg = $cfg -replace 'pref\("network\.http\.speculative-parallel-limit",\s*0\)', 'defaultPref("network.http.speculative-parallel-limit", 6)'
    $cfg = $cfg -replace 'defaultPref\("network\.dns\.disablePrefetch",\s*true\)', 'defaultPref("network.dns.disablePrefetch", false)'
    $cfg = $cfg -replace 'defaultPref\("network\.dns\.disablePrefetchFromHTTPS",\s*true\)', 'defaultPref("network.dns.disablePrefetchFromHTTPS", false)'

    # --- Fix extension scopes (needed for policy-based extension install) ---
    $cfg = $cfg -replace 'defaultPref\("extensions\.enabledScopes",\s*5\)', 'defaultPref("extensions.enabledScopes", 15)'

    # --- Fix weather on new tab page ---
    $cfg = $cfg -replace 'defaultPref\("browser\.newtabpage\.activity-stream\.showWeather",\s*false\)', 'defaultPref("browser.newtabpage.activity-stream.showWeather", true)'

    Set-Content -Path $cfgPath -Value $cfg -Encoding UTF8 -NoNewline
    Write-Success "  Patched librewolf.cfg (DRM, cache, search, RFP, cookies, passwords, prefetch, extensions)"
}

function Inject-Config($lwRoot) {
    Write-Status "Injecting custom configuration..."

    $appDir = Find-AppDir $lwRoot
    Write-Status "App directory: $appDir"

    # 1. Patch librewolf.cfg to fix common issues BEFORE injecting our config
    Patch-LibreWolfCfg $appDir

    # 2. Inject policies.json
    $distDir = Join-Path $appDir "distribution"
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
    Copy-Item (Join-Path $ScriptDir "policies.json") (Join-Path $distDir "policies.json") -Force
    Write-Success "  policies.json -> distribution/"

    # 3. Create portable profile directory structure
    $profilesDir = Join-Path $lwRoot "Profiles"
    $defaultProfile = Join-Path $profilesDir "Default"
    New-Item -ItemType Directory -Path $defaultProfile -Force | Out-Null

    # 4. Inject user.js into the profile
    Copy-Item (Join-Path $ScriptDir "user.js") (Join-Path $defaultProfile "user.js") -Force
    Write-Success "  user.js -> Profiles/Default/"

    # 5. Remove stale search cache so policies rebuild it fresh on first launch
    $staleSearch = Join-Path $defaultProfile "search.json.mozlz4"
    if (Test-Path $staleSearch) {
        Remove-Item $staleSearch -Force
        Write-Success "  Removed stale search.json.mozlz4 (will rebuild from policies)"
    }

    # 6. Copy chrome theme from old portable if it exists
    $oldChrome = Join-Path $ScriptDir "..\LibreWolf_DarkPortable\Profiles\Default\chrome"
    if (Test-Path $oldChrome) {
        $chromeDir = Join-Path $defaultProfile "chrome"
        Copy-Item $oldChrome $chromeDir -Recurse -Force
        Write-Success "  chrome/ theme -> Profiles/Default/chrome/"
    }

    # 6b. Overlay WolfPack custom chrome files (Catppuccin Mocha theme, etc.)
    $customChrome = Join-Path $ScriptDir "chrome-custom"
    if (Test-Path $customChrome) {
        $chromeDir = Join-Path $defaultProfile "chrome"
        New-Item -ItemType Directory -Path $chromeDir -Force | Out-Null
        # Copy custom.css (imported by userChrome.css)
        $customCss = Join-Path $customChrome "custom.css"
        if (Test-Path $customCss) {
            Copy-Item $customCss (Join-Path $chromeDir "custom.css") -Force
            Write-Success "  custom.css (Catppuccin Mocha) -> chrome/"
        }
        # Append catppuccin-content.css to userContent.css
        $catContent = Join-Path $customChrome "catppuccin-content.css"
        $ucContent = Join-Path $chromeDir "userContent.css"
        if ((Test-Path $catContent) -and (Test-Path $ucContent)) {
            $append = "`n`n/* WolfPack Catppuccin Mocha content overrides */`n@import url(`"content/catppuccin.css`");"
            Add-Content -Path $ucContent -Value $append -Encoding UTF8
            # Also copy the actual file
            $contentDir = Join-Path $chromeDir "content"
            New-Item -ItemType Directory -Path $contentDir -Force | Out-Null
            Copy-Item $catContent (Join-Path $contentDir "catppuccin.css") -Force
            Write-Success "  catppuccin-content.css -> chrome/content/catppuccin.css"
        }
    }

    # 7. Copy extension configs if they exist
    $extConfigs = Join-Path $ScriptDir "..\LibreWolf_DarkPortable\Extension_Configs"
    if (Test-Path $extConfigs) {
        $destConfigs = Join-Path $lwRoot "Extension_Configs"
        Copy-Item $extConfigs $destConfigs -Recurse -Force
        Write-Success "  Extension_Configs/ -> root"
    }

    # 8. Create profiles.ini for portable mode
    $profilesIni = @"
[General]
StartWithLastProfile=1
Version=2

[Profile0]
Name=Default
IsRelative=1
Path=../Profiles/Default
Default=1
"@
    Set-Content -Path (Join-Path $appDir "profiles.ini") -Value $profilesIni -Encoding UTF8
    Write-Success "  profiles.ini -> app root"

    # 10. Inject WolfPack branding (icon + VisualElements)
    $icoSrc = Join-Path $ScriptDir "assets\wolfpack.ico"
    $logoSrc = Join-Path $ScriptDir "assets\wolfpack-logo.png"
    if (Test-Path $icoSrc) {
        Copy-Item $icoSrc (Join-Path $lwRoot "wolfpack.ico") -Force
        Write-Success "  wolfpack.ico -> root"
    }
    # Replace VisualElements PNGs with WolfPack logo
    $veDir = Join-Path $appDir "browser\VisualElements"
    if ((Test-Path $veDir) -and (Test-Path $logoSrc)) {
        try {
            Add-Type -AssemblyName System.Drawing
            $srcImg = [System.Drawing.Image]::FromFile((Resolve-Path $logoSrc).Path)
            foreach ($size in @(150, 70)) {
                $destFile = Join-Path $veDir "VisualElements_$size.png"
                $bmp = New-Object System.Drawing.Bitmap $size, $size
                $g = [System.Drawing.Graphics]::FromImage($bmp)
                $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $g.Clear([System.Drawing.Color]::Transparent)
                $g.DrawImage($srcImg, 0, 0, $size, $size)
                $g.Dispose()
                $bmp.Save($destFile, [System.Drawing.Imaging.ImageFormat]::Png)
                $bmp.Dispose()
                Write-Success "  VisualElements_$size.png replaced with WolfPack logo"
            }
            $srcImg.Dispose()
        } catch {
            Write-Warn "  Could not generate VisualElements PNGs: $_"
        }
    }

    # 11. (scripts copied in step 14 below)

    # 12. Copy PortableApps.com INI
    $paIni = Join-Path $ScriptDir "WolfPackPortable.ini"
    if (Test-Path $paIni) {
        Copy-Item $paIni (Join-Path $lwRoot "WolfPackPortable.ini") -Force
        Write-Success "  WolfPackPortable.ini -> root"
    }

    # 13b. Copy containers.json into profile
    $containersJson = Join-Path $ScriptDir "containers.json"
    if (Test-Path $containersJson) {
        Copy-Item $containersJson (Join-Path $defaultProfile "containers.json") -Force
        Write-Success "  containers.json -> Profiles/Default/"
    }

    # 14. Copy all utility scripts
    $repoScripts = Join-Path $ScriptDir "scripts"
    if (Test-Path $repoScripts) {
        $scriptsDir = Join-Path $lwRoot "scripts"
        New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
        Get-ChildItem -Path $repoScripts -Filter "*.ps1" | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $scriptsDir $_.Name) -Force
            Write-Success "  $($_.Name) -> scripts/"
        }
    }

    # 15. Copy dashboard
    $dashboardSrc = Join-Path $ScriptDir "dashboard"
    if (Test-Path $dashboardSrc) {
        $dashboardDest = Join-Path $lwRoot "dashboard"
        New-Item -ItemType Directory -Path $dashboardDest -Force | Out-Null
        Copy-Item (Join-Path $dashboardSrc "index.html") (Join-Path $dashboardDest "index.html") -Force
        Write-Success "  dashboard/index.html -> root"
    }

    # 16. Copy userscripts bundle
    $userscriptsSrc = Join-Path $ScriptDir "userscripts"
    if (Test-Path $userscriptsSrc) {
        $userscriptsDest = Join-Path $lwRoot "userscripts"
        New-Item -ItemType Directory -Path $userscriptsDest -Force | Out-Null
        Get-ChildItem -Path $userscriptsSrc -Filter "*.user.js" | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $userscriptsDest $_.Name) -Force
            Write-Success "  $($_.Name) -> userscripts/"
        }
    }

    # 17. Copy version.txt
    $versionFile = Join-Path $ScriptDir "version.txt"
    if (Test-Path $versionFile) {
        Copy-Item $versionFile (Join-Path $lwRoot "version.txt") -Force
        Write-Success "  version.txt -> root"
    }

    # 13a. Create portable marker file (tells LibreWolf to use local profiles)
    $portableMarker = Join-Path $lwRoot "portable.ini"
    @"
[Portable]
Mode=1
"@ | Set-Content -Path $portableMarker -Encoding UTF8
    Write-Success "  portable.ini marker created"

    return @{
        AppDir = $appDir
        RootDir = $lwRoot
        ProfileDir = $defaultProfile
    }
}

function Build-PortableLauncher($lwRoot, $appDir) {
    Write-Status "Creating portable launcher..."

    # Create a batch launcher (works without compilation)
    $launcherBat = @'
@echo off
setlocal
set "SCRIPT_DIR=%~dp0"

:: Find librewolf.exe
if exist "%SCRIPT_DIR%librewolf\librewolf.exe" (
    set "LW_EXE=%SCRIPT_DIR%librewolf\librewolf.exe"
    set "LW_DIR=%SCRIPT_DIR%librewolf"
) else if exist "%SCRIPT_DIR%LibreWolf\librewolf.exe" (
    set "LW_EXE=%SCRIPT_DIR%LibreWolf\librewolf.exe"
    set "LW_DIR=%SCRIPT_DIR%LibreWolf"
) else (
    set "LW_EXE=%SCRIPT_DIR%librewolf.exe"
    set "LW_DIR=%SCRIPT_DIR%"
)

set "PROFILE_DIR=%SCRIPT_DIR%Profiles\Default"
if not exist "%PROFILE_DIR%" mkdir "%PROFILE_DIR%"

start "" "%LW_EXE%" --profile "%PROFILE_DIR%" --no-remote %*
'@
    Set-Content -Path (Join-Path $lwRoot "WolfPack.bat") -Value $launcherBat -Encoding ASCII

    # Create a VBS wrapper to launch without console window
    $launcherVbs = @'
Set WshShell = CreateObject("WScript.Shell")
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

lwExe = ""
If CreateObject("Scripting.FileSystemObject").FileExists(scriptDir & "\librewolf\librewolf.exe") Then
    lwExe = scriptDir & "\librewolf\librewolf.exe"
ElseIf CreateObject("Scripting.FileSystemObject").FileExists(scriptDir & "\LibreWolf\librewolf.exe") Then
    lwExe = scriptDir & "\LibreWolf\librewolf.exe"
Else
    lwExe = scriptDir & "\librewolf.exe"
End If

profileDir = scriptDir & "\Profiles\Default"
If Not CreateObject("Scripting.FileSystemObject").FolderExists(profileDir) Then
    CreateObject("Scripting.FileSystemObject").CreateFolder(profileDir)
End If

WshShell.Run """" & lwExe & """ --profile """ & profileDir & """ --no-remote", 0, False
'@
    Set-Content -Path (Join-Path $lwRoot "WolfPack.vbs") -Value $launcherVbs -Encoding ASCII

    # Create a PowerShell launcher
    $launcherPs1 = @'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$lwPaths = @(
    (Join-Path $scriptDir "librewolf\librewolf.exe"),
    (Join-Path $scriptDir "LibreWolf\librewolf.exe"),
    (Join-Path $scriptDir "librewolf.exe")
)
$lwExe = $lwPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
$profileDir = Join-Path $scriptDir "Profiles\Default"
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
Start-Process -FilePath $lwExe -ArgumentList "--profile `"$profileDir`" --no-remote" -WindowStyle Hidden
'@
    Set-Content -Path (Join-Path $lwRoot "WolfPack.ps1") -Value $launcherPs1 -Encoding UTF8

    # Compile C# launcher exe (no console window)
    $csFile = Join-Path $ScriptDir "launcher\WolfPack.cs"
    if (Test-Path $csFile) {
        $exeDest = Join-Path $lwRoot "WolfPack.exe"
        $cscPaths = @(
            (Join-Path $env:SystemRoot "Microsoft.NET\Framework64\v4.0.30319\csc.exe"),
            (Join-Path $env:SystemRoot "Microsoft.NET\Framework\v4.0.30319\csc.exe")
        )
        $csc = $cscPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

        if ($csc) {
            $icoFile = Join-Path $ScriptDir "assets\wolfpack.ico"
            $icoArg = if (Test-Path $icoFile) { "-win32icon:$icoFile" } else { "" }
            $cscArgs = @("-nologo", "-target:winexe", "-out:$exeDest", "-reference:System.Windows.Forms.dll")
            if ($icoArg) { $cscArgs += $icoArg }
            $cscArgs += $csFile
            & $csc @cscArgs 2>&1 | Out-Null
            if (Test-Path $exeDest) {
                Write-Success "  Compiled WolfPack.exe"
            } else {
                Write-Warn "  C# compilation failed, using script launchers instead"
            }
        } else {
            Write-Warn "  .NET Framework CSC not found, using script launchers instead"
        }
    }

    # Clean up old-named launchers if they exist from previous builds
    foreach ($old in @("LibreWolf-Dark.bat", "LibreWolf-Dark.vbs", "LibreWolf-Dark.ps1", "LibreWolf-Dark.exe", "LibreWolf.bat", "LibreWolf.vbs", "LibreWolf.ps1", "LibreWolf.exe")) {
        $oldPath = Join-Path $lwRoot $old
        if (Test-Path $oldPath) { Remove-Item $oldPath -Force }
    }

    Write-Success "  Created portable launchers"
}

function Build-PortableZip($lwRoot, $version) {
    Write-Status "Packaging portable zip..."
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

    $zipName = "$ProjectName-$version-portable.zip"
    $zipPath = Join-Path $OutputDir $zipName

    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

    Compress-Archive -Path "$lwRoot\*" -DestinationPath $zipPath -CompressionLevel Optimal
    $size = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
    Write-Success "Portable: $zipName ($size MB)"
    return $zipPath
}

function Build-NsisInstaller($lwRoot, $version) {
    $nsisScript = Join-Path $ScriptDir "installer.nsi"
    if (-not (Test-Path $nsisScript)) {
        Write-Warn "installer.nsi not found, skipping installer build"
        return $null
    }

    $makensis = $null
    $nsisLocations = @(
        "C:\Program Files (x86)\NSIS\makensis.exe",
        "C:\Program Files\NSIS\makensis.exe",
        (Get-Command makensis -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
    )
    foreach ($loc in $nsisLocations) {
        if ($loc -and (Test-Path $loc)) { $makensis = $loc; break }
    }

    if (-not $makensis) {
        Write-Warn "NSIS not found. Install from https://nsis.sourceforge.io/ to build the installer."
        Write-Warn "The installer.nsi script is ready - run: makensis /DVERSION=$version /DSOURCE_DIR=$lwRoot installer.nsi"
        return $null
    }

    Write-Status "Building NSIS installer..."
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

    $exeName = "$ProjectName-$version-setup.exe"
    $exePath = Join-Path $OutputDir $exeName

    & $makensis /DVERSION="$version" /DSOURCE_DIR="$lwRoot" /DOUTPUT_FILE="$exePath" "$nsisScript"

    if ($LASTEXITCODE -eq 0) {
        $size = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
        Write-Success "Installer: $exeName ($size MB)"
        return $exePath
    } else {
        Write-Warn "NSIS build failed with exit code $LASTEXITCODE"
        return $null
    }
}

# ---- Main ----

Write-Host ""
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  WolfPack - Build System" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

# Get version
if (-not $Version) {
    $Version = Get-LatestVersion
}

# Download
$extractDir = Join-Path $BuildDir "portable-$Version"
if (-not $SkipDownload) {
    $zipFile = Download-LibreWolf $Version $Arch
    Extract-LibreWolf $zipFile $extractDir
} else {
    if (-not (Test-Path $extractDir)) {
        throw "Extract directory not found and -SkipDownload specified: $extractDir"
    }
}

# Inject config
$paths = Inject-Config $extractDir

# Create launchers
Build-PortableLauncher $extractDir $paths.AppDir

# Build outputs
Write-Host ""
if (-not $InstallerOnly) {
    $portableZip = Build-PortableZip $extractDir $Version
}
if (-not $PortableOnly) {
    $installerExe = Build-NsisInstaller $extractDir $Version
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Build Complete" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "  Version:   $Version" -ForegroundColor White
Write-Host "  Arch:      $Arch" -ForegroundColor White
if ($portableZip) { Write-Host "  Portable:  $portableZip" -ForegroundColor White }
if ($installerExe) { Write-Host "  Installer: $installerExe" -ForegroundColor White }
Write-Host ""
