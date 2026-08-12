# Audits the configured extension candidates against their packaged manifests.
# Use -Online to download each candidate; the build itself does not need this
# network probe because policy installation happens when the browser starts.

param(
    [string]$ConfigPath = "",
    [switch]$Online,
    [switch]$Json,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $repoRoot "wolfpack.cfg"
}

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "WolfPack extension audit failed: config not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$extensions = @($config.extensions)

function Get-ManifestFromArchive($archivePath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $bytes = [IO.File]::ReadAllBytes($archivePath)
    if ($bytes.Length -lt 4) {
        throw "archive is empty or truncated"
    }

    $format = "xpi"
    $offset = 0
    $magic = [Text.Encoding]::ASCII.GetString($bytes, 0, 4)
    if ($magic -eq "Cr24") {
        $format = "crx"
        if ($bytes.Length -lt 12) {
            throw "CRX header is truncated"
        }
        $crxVersion = [BitConverter]::ToUInt32($bytes, 4)
        if ($crxVersion -eq 2) {
            if ($bytes.Length -lt 16) {
                throw "CRX2 header is truncated"
            }
            $publicKeyLength = [BitConverter]::ToUInt32($bytes, 8)
            $signatureLength = [BitConverter]::ToUInt32($bytes, 12)
            $offset = 16 + $publicKeyLength + $signatureLength
        } elseif ($crxVersion -eq 3) {
            $headerLength = [BitConverter]::ToUInt32($bytes, 8)
            $offset = 12 + $headerLength
        } else {
            throw "unsupported CRX version $crxVersion"
        }
    } elseif (-not (
        $bytes[0] -eq 0x50 -and $bytes[1] -eq 0x4b -and
        (($bytes[2] -eq 0x03 -and $bytes[3] -eq 0x04) -or
         ($bytes[2] -eq 0x05 -and $bytes[3] -eq 0x06) -or
         ($bytes[2] -eq 0x07 -and $bytes[3] -eq 0x08))
    )) {
        throw "not a ZIP/XPI archive"
    }

    if ($offset -ge $bytes.Length) {
        throw "archive payload is empty"
    }

    $archiveBytes = New-Object byte[] ($bytes.Length - $offset)
    [Array]::Copy($bytes, $offset, $archiveBytes, 0, $archiveBytes.Length)
    $memory = [IO.MemoryStream]::new($archiveBytes, $false)
    $archive = [IO.Compression.ZipArchive]::new($memory, [IO.Compression.ZipArchiveMode]::Read, $false)
    try {
        $entry = $archive.GetEntry("manifest.json")
        if (-not $entry) {
            throw "manifest.json is missing"
        }
        $reader = [IO.StreamReader]::new($entry.Open(), [Text.Encoding]::UTF8)
        try {
            $manifest = $reader.ReadToEnd() | ConvertFrom-Json
        } finally {
            $reader.Dispose()
        }
    } finally {
        $archive.Dispose()
        $memory.Dispose()
    }

    $gecko = $null
    if ($manifest.browser_specific_settings -and $manifest.browser_specific_settings.gecko) {
        $gecko = $manifest.browser_specific_settings.gecko
    } elseif ($manifest.applications -and $manifest.applications.gecko) {
        $gecko = $manifest.applications.gecko
    }

    return [pscustomobject]@{
        Format = $format
        Manifest = [int]$manifest.manifest_version
        Id = if ($gecko) { [string]$gecko.id } else { "" }
        Version = [string]$manifest.version
        Name = [string]$manifest.name
    }
}

function Get-CandidateResult($extension, $url, $tempRoot) {
    $result = [ordered]@{
        Url = [string]$url
        Status = "Unavailable"
        Format = ""
        ManifestVersion = $null
        Id = ""
        Version = ""
        Error = ""
    }
    $archivePath = Join-Path $tempRoot ([guid]::NewGuid().ToString("N") + ".archive")
    try {
        Invoke-WebRequest -Uri ([string]$url) -OutFile $archivePath -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 45
        $package = Get-ManifestFromArchive $archivePath
        $result.Format = $package.Format
        $result.ManifestVersion = $package.Manifest
        $result.Id = $package.Id
        $result.Version = $package.Version

        $supported = @($extension.supportedManifestVersions | ForEach-Object { [int]$_ })
        if ($package.Format -eq "crx") {
            $result.Status = "UnsupportedFormat"
            $result.Error = "CRX is a Chromium package; Firefox policy installation requires an XPI/ZIP package."
        } elseif ($package.Manifest -notin $supported) {
            $result.Status = "Incompatible"
            $result.Error = "manifest_version $($package.Manifest) is not in supportedManifestVersions [$($supported -join ', ')]"
        } elseif (-not [string]::IsNullOrWhiteSpace([string]$extension.id) -and
            [string]::IsNullOrWhiteSpace($package.Id)) {
            $result.Status = "IdMissing"
            $result.Error = "manifest does not declare the configured Firefox ID '$($extension.id)'"
        } elseif (-not [string]::IsNullOrWhiteSpace([string]$extension.id) -and
            $package.Id -ne [string]$extension.id) {
            $result.Status = "IdMismatch"
            $result.Error = "manifest ID '$($package.Id)' does not match configured ID '$($extension.id)'"
        } else {
            $result.Status = "Ready"
        }
    } catch {
        $result.Status = "Unavailable"
        $result.Error = $_.Exception.Message
    } finally {
        if (Test-Path -LiteralPath $archivePath) {
            Remove-Item -LiteralPath $archivePath -Force -ErrorAction SilentlyContinue
        }
    }
    return [pscustomobject]$result
}

if (-not $Online) {
    $message = "Configuration loaded for $($extensions.Count) extensions. Re-run with -Online to inspect each candidate archive."
    if ($Json) {
        [pscustomobject]@{ ConfigPath = $ConfigPath; Online = $false; Message = $message } | ConvertTo-Json -Depth 5
    } else {
        Write-Output $message
    }
    exit 0
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("wolfpack-extension-audit-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
$results = @()
try {
    foreach ($extension in $extensions) {
        $candidateUrls = @([string]$extension.installUrl) + @($extension.fallbackUrls | ForEach-Object { [string]$_ })
        $candidateUrls = @($candidateUrls | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
        $candidates = @($candidateUrls | ForEach-Object { Get-CandidateResult $extension $_ $tempRoot })
        $selected = $candidates | Where-Object { $_.Status -eq "Ready" } | Select-Object -First 1
        $status = if ($selected) { "Ready" } elseif (@($candidates | Where-Object { $_.Status -ne "Unavailable" }).Count -gt 0) { "Blocked" } else { "Unavailable" }
        $results += [pscustomobject]@{
            Name = [string]$extension.name
            ConfiguredId = [string]$extension.id
            Status = $status
            SelectedUrl = if ($selected) { $selected.Url } else { "" }
            SelectedManifestVersion = if ($selected) { $selected.ManifestVersion } else { $null }
            SelectedId = if ($selected) { $selected.Id } else { "" }
            Candidates = $candidates
        }
    }
} finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($Json) {
    $results | ConvertTo-Json -Depth 8
} else {
    Write-Output "WolfPack extension archive audit"
    foreach ($result in $results) {
        $selection = if ($result.SelectedUrl) { "manifest $($result.SelectedManifestVersion), id $($result.SelectedId)" } else { "no usable candidate" }
        Write-Output ("[{0}] {1}: {2}" -f $result.Status, $result.Name, $selection)
        foreach ($candidate in $result.Candidates) {
            $detail = if ($candidate.Error) { $candidate.Error } else { "manifest $($candidate.ManifestVersion), id $($candidate.Id)" }
            Write-Output ("  - {0}: {1} ({2})" -f $candidate.Status, $candidate.Url, $detail)
        }
    }
}

if ($Strict -and @($results | Where-Object { $_.Status -ne "Ready" }).Count -gt 0) {
    throw "WolfPack extension audit found one or more extensions without a usable Firefox package."
}
