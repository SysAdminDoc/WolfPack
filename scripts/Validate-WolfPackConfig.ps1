# Validates the JSON-shaped wolfpack.cfg used by the Windows build pipeline.

param(
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $repoRoot "wolfpack.cfg"
}

function Fail-Config($message) {
    throw "WolfPack config validation failed: $message"
}

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    Fail-Config "file not found: $ConfigPath"
}

try {
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
} catch {
    Fail-Config "invalid JSON: $($_.Exception.Message)"
}

if ($null -eq $config.schemaVersion -or [int]$config.schemaVersion -ne 1) {
    Fail-Config "schemaVersion must be 1"
}

if ($null -eq $config.search -or [string]::IsNullOrWhiteSpace([string]$config.search.fallback)) {
    Fail-Config "search.fallback is required"
}

$allowedSearchEngines = @("Google", "DuckDuckGo", "DuckDuckGo Lite", "SearXNG", "StartPage")
if ($config.search.fallback -notin $allowedSearchEngines) {
    Fail-Config "search.fallback '$($config.search.fallback)' is not a configured search engine"
}

$regionNames = @($config.search.regionDefaults.PSObject.Properties.Name)
foreach ($region in $regionNames) {
    if ($region -notmatch '^[A-Z]{2}$') {
        Fail-Config "search.regionDefaults key '$region' must be an ISO 3166-1 alpha-2 code"
    }
    if ([string]$config.search.regionDefaults.$region -notin $allowedSearchEngines) {
        Fail-Config "search.regionDefaults.$region references an unknown search engine"
    }
}

if ($null -eq $config.profile -or [string]::IsNullOrWhiteSpace([string]$config.profile.userOverridesFile)) {
    Fail-Config "profile.userOverridesFile is required"
}
if ([IO.Path]::GetFileName([string]$config.profile.userOverridesFile) -ne [string]$config.profile.userOverridesFile) {
    Fail-Config "profile.userOverridesFile must be a file name, not a path"
}

$pinnedIds = @($config.profile.autoPinExtensions | ForEach-Object { [string]$_ })
if ($pinnedIds.Count -ne (@($pinnedIds | Select-Object -Unique)).Count) {
    Fail-Config "profile.autoPinExtensions contains duplicate IDs"
}

if ($null -eq $config.extensions -or @($config.extensions).Count -eq 0) {
    Fail-Config "at least one extension is required"
}

$extensionNames = @()
$extensionIds = @()
foreach ($extension in @($config.extensions)) {
    if ([string]::IsNullOrWhiteSpace([string]$extension.name)) {
        Fail-Config "each extension needs a name"
    }
    if ([string]$extension.name -in $extensionNames) {
        Fail-Config "duplicate extension name '$($extension.name)'"
    }
    $extensionNames += [string]$extension.name
    if ([string]$extension.installUrl -notmatch '^https://') {
        Fail-Config "extension '$($extension.name)' installUrl must use HTTPS"
    }
    $fallbackUrls = @($extension.fallbackUrls | ForEach-Object { [string]$_ })
    if (@($fallbackUrls | Where-Object { $_ -notmatch '^https://' }).Count -gt 0) {
        Fail-Config "extension '$($extension.name)' has a non-HTTPS fallback URL"
    }
    $manifestVersions = @($extension.supportedManifestVersions | ForEach-Object { [int]$_ })
    if ($manifestVersions.Count -eq 0 -or @($manifestVersions | Where-Object { $_ -notin @(2, 3) }).Count -gt 0) {
        Fail-Config "extension '$($extension.name)' must declare manifest version 2 and/or 3"
    }
    $id = [string]$extension.id
    if (-not [string]::IsNullOrWhiteSpace($id)) {
        if ($id -in $extensionIds) {
            Fail-Config "duplicate extension ID '$id'"
        }
        $extensionIds += $id
    }
}

$unknownPins = @($pinnedIds | Where-Object { $_ -notin $extensionIds })
if ($unknownPins.Count -gt 0) {
    Fail-Config "auto-pinned extension IDs are not present in extensions: $($unknownPins -join ', ')"
}

Write-Output "WolfPack config valid: $ConfigPath (schema $($config.schemaVersion), $(@($config.extensions).Count) extensions)"
