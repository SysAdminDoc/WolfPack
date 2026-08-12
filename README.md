<p align="center">
  <img src="assets/wolfpack-logo.png" width="128" alt="WolfPack">
</p>

<h1 align="center">WolfPack</h1>

<p align="center">
  A custom LibreWolf distribution for Windows with optimized defaults, pre-installed extensions, and portable packaging.
</p>

<p align="center">
  <a href="https://github.com/SysAdminDoc/WolfPack/releases/latest"><img src="https://img.shields.io/github/v/release/SysAdminDoc/WolfPack?style=flat-square&color=blue" alt="Latest Release"></a>
  <a href="https://github.com/SysAdminDoc/WolfPack/releases/latest"><img src="https://img.shields.io/github/downloads/SysAdminDoc/WolfPack/total?style=flat-square&color=green" alt="Downloads"></a>
  <a href="https://github.com/SysAdminDoc/WolfPack/actions"><img src="https://img.shields.io/github/actions/workflow/status/SysAdminDoc/WolfPack/build.yml?style=flat-square" alt="Build"></a>
</p>

---

## What Is This?

WolfPack takes the official [LibreWolf](https://librewolf.net/) portable build and repackages it with:

- **Google as default search engine** (with suggestions enabled)
- **DRM enabled** out of the box (Netflix, Disney+, Spotify work immediately)
- **Pre-installed extensions** via enterprise policies
- **Optimized performance** defaults (disk cache, prefetching, GPU acceleration)
- **Session persistence** (cookies and logins survive restarts)
- **Password manager and autofill** enabled by default
- **Resist Fingerprinting (RFP) disabled** to prevent site breakage
- **Dark theme** with custom CSS support
- **Portable mode** with local profile storage

All telemetry, Mozilla promotions, Pocket, Firefox Sync, safe browsing, and other bloat remains disabled from upstream LibreWolf.

## Downloads

| File | Description |
|------|-------------|
| `WolfPack-<version>-setup.exe` | Windows installer (Start Menu + Desktop shortcuts, Add/Remove Programs) |
| `WolfPack-<version>-portable.zip` | Portable zip (extract anywhere and run `WolfPack.exe`) |
| `WolfPack-<version>.msix` | MSIX package for enterprise deployment (requires signing before end-user installation) |

Download from the [Releases](https://github.com/SysAdminDoc/WolfPack/releases) page.

## Pre-Installed Extensions

| Extension | Source |
|-----------|--------|
| [uBlockVanced](https://github.com/SysAdminDoc/uBlockVanced) | Custom uBlock Origin fork |
| [DarkReaderLocal](https://github.com/SysAdminDoc/DarkReaderLocal) | Custom Dark Reader fork |
| [ScriptVault](https://github.com/SysAdminDoc/ScriptVault) | Custom userscript manager |
| [StyleKit](https://github.com/SysAdminDoc/StyleKit) | Custom userstyle manager |
| [SponsorBlock](https://addons.mozilla.org/firefox/addon/sponsorblock/) | Skip YouTube sponsors |
| [Reddit Enhancement Suite](https://addons.mozilla.org/firefox/addon/reddit-enhancement-suite/) | Reddit improvements |
| [Adaptive Tab Bar Colour](https://addons.mozilla.org/firefox/addon/adaptive-tab-bar-colour/) | Tab bar matches page color |

Extensions are installed automatically on first launch via `policies.json`.

The extracted package also contains `admin-templates/WolfPack.admx` and the matching
`en-US/WolfPack.adml`. Copy them to the domain Central Store (or the local
`%WINDIR%\PolicyDefinitions` directory) to expose WolfPack settings in Group Policy.
The templates write the standard Firefox policy registry path,
`Software\Policies\Mozilla\Firefox`, so they can be used with managed or portable
WolfPack deployments without rebuilding the package.

## Changes from Stock LibreWolf

### Enabled (was disabled)
- DRM / Encrypted Media Extensions (streaming services)
- Disk cache (performance)
- Search suggestions in URL bar
- DNS prefetching and speculative connections
- Password manager and form autofill
- Session persistence (cookies kept on shutdown)
- Weather widget on new tab page

### Disabled (was enabled)
- Resist Fingerprinting (RFP) - causes timezone, canvas, and font issues
- Global Privacy Control (GPC)
- Sanitize on shutdown (users were getting logged out)
- Always-ask download location

### Search Engines
Google is the default. Also available: DuckDuckGo, DuckDuckGo Lite, SearXNG, StartPage.

## Building

### Prerequisites
- Windows 10/11
- PowerShell 5.1+
- [NSIS](https://nsis.sourceforge.io/) (for installer builds)
- Windows 10/11 SDK (for MSIX builds)
- .NET Framework 4.x (for launcher compilation)

### Build Commands

```powershell
# Build everything (downloads latest LibreWolf automatically)
.\build-portable.ps1

# Build the beta channel (requires an upstream beta artifact/version)
.\build-portable.ps1 -Channel beta

# Build specific version
.\build-portable.ps1 -Version "146.0.1-1"

# Portable zip only (skip installer)
.\build-portable.ps1 -PortableOnly

# Rebuild without re-downloading
.\build-portable.ps1 -SkipDownload
```

### Output
- `output/WolfPack-<version>-portable.zip`
- `output/WolfPack-<version>-setup.exe`
- `output/WolfPack-<version>.msix`

The build verifies the downloaded LibreWolf archive against `librewolf.lock`. CI builds fail when the version or SHA-256 hash differs; intentional local experiments can use `-AllowUnpinned`.

## Project Structure

```
WolfPack/
  assets/              # Icon and logo files
  launcher/            # C# portable launcher source
  patches/             # Upstream LibreWolf patches
  themes/              # Upstream LibreWolf branding/themes
  scripts/             # Upstream LibreWolf build scripts
  l10n/                # Localization files
  .github/workflows/   # CI/CD build pipeline
  build-portable.ps1   # Main build script
  installer.nsi        # NSIS installer script
  policies.json        # Enterprise policies (extensions, search engines)
  user.js              # Browser preferences
```

## How It Works

1. Downloads the latest official LibreWolf portable zip from GitLab
2. Patches `librewolf.cfg` to fix common complaints (DRM, cache, RFP, etc.)
3. Injects custom `policies.json` for extension auto-install and Google default
4. Injects `user.js` with optimized preferences into the portable profile
5. Copies the GPO/ADMX templates into `admin-templates/`
6. Compiles a lightweight C# launcher (`WolfPack.exe`, ~5KB)
7. Packages as portable zip and NSIS installer

## License

LibreWolf is licensed under the [Mozilla Public License 2.0](https://www.mozilla.org/MPL/2.0/). This repackaging project adds configuration and build tooling only.
