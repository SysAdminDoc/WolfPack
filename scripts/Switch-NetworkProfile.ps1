# =============================================================================
# WolfPack - Network Profile Switcher
# Switch between privacy/speed/balanced network profiles
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Privacy", "Balanced", "Speed")]
    [string]$Profile
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WolfPackRoot = Split-Path -Parent $ScriptDir

function Write-Status($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[+] $msg" -ForegroundColor Green }

# Find the profile's user.js (could be default or installed location)
$userJsPaths = @(
    (Join-Path $WolfPackRoot "Profiles\Default\user.js"),
    (Join-Path $WolfPackRoot "user.js")
)
$userJs = $userJsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $userJs) {
    Write-Host "[!] user.js not found." -ForegroundColor Yellow
    exit 1
}

$content = Get-Content $userJs -Raw

switch ($Profile) {
    "Privacy" {
        Write-Status "Switching to Maximum Privacy profile..."
        # TRR mode 3 = DoH only, no fallback
        $content = $content -replace 'user_pref\("network\.trr\.mode",\s*\d+\)', 'user_pref("network.trr.mode", 3)'
        # Disable all prefetching
        $content = $content -replace 'user_pref\("network\.dns\.disablePrefetch",\s*\w+\)', 'user_pref("network.dns.disablePrefetch", true)'
        $content = $content -replace 'user_pref\("network\.dns\.disablePrefetchFromHTTPS",\s*\w+\)', 'user_pref("network.dns.disablePrefetchFromHTTPS", true)'
        $content = $content -replace 'user_pref\("network\.prefetch-next",\s*\w+\)', 'user_pref("network.prefetch-next", false)'
        $content = $content -replace 'user_pref\("network\.predictor\.enabled",\s*\w+\)', 'user_pref("network.predictor.enabled", false)'
        $content = $content -replace 'user_pref\("network\.predictor\.enable-prefetch",\s*\w+\)', 'user_pref("network.predictor.enable-prefetch", false)'
        $content = $content -replace 'user_pref\("network\.http\.speculative-parallel-limit",\s*\d+\)', 'user_pref("network.http.speculative-parallel-limit", 0)'
        $content = $content -replace 'user_pref\("browser\.places\.speculativeConnect\.enabled",\s*\w+\)', 'user_pref("browser.places.speculativeConnect.enabled", false)'
        # Enable HTTPS-only strict
        $content = $content -replace 'user_pref\("dom\.security\.https_only_mode",\s*\w+\)', 'user_pref("dom.security.https_only_mode", true)'
        Write-Success "Maximum Privacy: DoH-only, no prefetch, HTTPS-only"
    }
    "Balanced" {
        Write-Status "Switching to Balanced profile (defaults)..."
        $content = $content -replace 'user_pref\("network\.trr\.mode",\s*\d+\)', 'user_pref("network.trr.mode", 2)'
        $content = $content -replace 'user_pref\("network\.dns\.disablePrefetch",\s*\w+\)', 'user_pref("network.dns.disablePrefetch", false)'
        $content = $content -replace 'user_pref\("network\.dns\.disablePrefetchFromHTTPS",\s*\w+\)', 'user_pref("network.dns.disablePrefetchFromHTTPS", false)'
        $content = $content -replace 'user_pref\("network\.prefetch-next",\s*\w+\)', 'user_pref("network.prefetch-next", true)'
        $content = $content -replace 'user_pref\("network\.predictor\.enabled",\s*\w+\)', 'user_pref("network.predictor.enabled", true)'
        $content = $content -replace 'user_pref\("network\.predictor\.enable-prefetch",\s*\w+\)', 'user_pref("network.predictor.enable-prefetch", true)'
        $content = $content -replace 'user_pref\("network\.http\.speculative-parallel-limit",\s*\d+\)', 'user_pref("network.http.speculative-parallel-limit", 6)'
        $content = $content -replace 'user_pref\("browser\.places\.speculativeConnect\.enabled",\s*\w+\)', 'user_pref("browser.places.speculativeConnect.enabled", true)'
        $content = $content -replace 'user_pref\("dom\.security\.https_only_mode",\s*\w+\)', 'user_pref("dom.security.https_only_mode", true)'
        Write-Success "Balanced: DoH with fallback, prefetch on, HTTPS-only"
    }
    "Speed" {
        Write-Status "Switching to Maximum Speed profile..."
        # TRR mode 0 = system DNS (fastest, no DoH overhead)
        $content = $content -replace 'user_pref\("network\.trr\.mode",\s*\d+\)', 'user_pref("network.trr.mode", 0)'
        # Enable all prefetching
        $content = $content -replace 'user_pref\("network\.dns\.disablePrefetch",\s*\w+\)', 'user_pref("network.dns.disablePrefetch", false)'
        $content = $content -replace 'user_pref\("network\.dns\.disablePrefetchFromHTTPS",\s*\w+\)', 'user_pref("network.dns.disablePrefetchFromHTTPS", false)'
        $content = $content -replace 'user_pref\("network\.prefetch-next",\s*\w+\)', 'user_pref("network.prefetch-next", true)'
        $content = $content -replace 'user_pref\("network\.predictor\.enabled",\s*\w+\)', 'user_pref("network.predictor.enabled", true)'
        $content = $content -replace 'user_pref\("network\.predictor\.enable-prefetch",\s*\w+\)', 'user_pref("network.predictor.enable-prefetch", true)'
        $content = $content -replace 'user_pref\("network\.http\.speculative-parallel-limit",\s*\d+\)', 'user_pref("network.http.speculative-parallel-limit", 10)'
        $content = $content -replace 'user_pref\("browser\.places\.speculativeConnect\.enabled",\s*\w+\)', 'user_pref("browser.places.speculativeConnect.enabled", true)'
        # Relax HTTPS-only
        $content = $content -replace 'user_pref\("dom\.security\.https_only_mode",\s*\w+\)', 'user_pref("dom.security.https_only_mode", false)'
        Write-Success "Maximum Speed: System DNS, all prefetch, no HTTPS-only"
    }
}

Set-Content -Path $userJs -Value $content -Encoding UTF8 -NoNewline
Write-Host ""
Write-Host "Restart WolfPack for changes to take effect." -ForegroundColor White
