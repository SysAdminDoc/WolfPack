# Changelog

## v1.5.0 (2026-08-12)

### Build System
- Added stable and beta LibreWolf channels with isolated beta artifacts and a GitHub Actions matrix build.
- Added a SHA-256 locked LibreWolf archive manifest with CI enforcement.
- Added Windows SDK-backed MSIX packaging alongside the NSIS installer.
- Added locale-aware search defaults, preserved user overrides, toolbar pinning, and the `--profile-override` launcher option.
- Added validated `wolfpack.cfg` and packaged GPO/ADMX templates for managed Firefox policy deployment.
- Added the privileged `about:wolfpack` settings page with profile reset backups, LibreWolf's opt-in extension firewall, and bundled-extension availability controls.
- Added an online extension archive audit that verifies Firefox IDs, Manifest V2/V3 compatibility, and fallback package formats before policy URLs are updated.

## v1.4.0 (2026-03-15)

### Search & Navigation
- Custom search keyword engines: @yt (YouTube), @r (Reddit), @gh (GitHub), @w (Wikipedia), @maps (Google Maps), @ddg (DuckDuckGo), @ddgl (DuckDuckGo Lite), @sx (SearXNG), @sp (StartPage)
- Curated default new tab sites: GitHub, Reddit, YouTube, Wikipedia, ChatGPT, Hacker News, Twitch, Discord

### UI/UX
- Sidebar hidden by default (vertical tabs still available via Ctrl+B)
- WolfPack Dashboard page with browser info, network stats, privacy checks, and WebRTC leak detection
- Catppuccin Mocha PDF viewer theme (toolbar, sidebar, scrollbar, buttons)

### Containers & Privacy
- Pre-seeded container identities (containers.json): Personal, Work, Shopping, Banking

### Extension Config Pre-Seeding
- uBlock/uBlockVanced: Full filter list selection via managed storage (EasyList, EasyPrivacy, Fanboy Annoyances, AdGuard Social/Spyware, cookie notices, LAN block)
- SponsorBlock: Category auto-skip config (sponsors, self-promo, interaction skipped; intros/outros/previews/filler shown in bar)

### Userscript Bundle
- Return YouTube Dislike - shows dislike count via returnyoutubedislike.com API
- Old Reddit Redirect - auto-redirects to old.reddit.com
- Google Direct Links - removes tracking redirects from Google search results
- Auto Cookie Consent - auto-dismisses cookie banners (prefers reject/necessary-only)
- Wider GitHub - full-width code views and READMEs

### Tools & Scripts
- Auto-updater script (`scripts/Update-WolfPack.ps1`) - checks GitHub releases, hot-swaps browser files
- Network profile switcher (`scripts/Switch-NetworkProfile.ps1`) - Privacy/Balanced/Speed profiles
- Windows browser registration (`scripts/Register-Browser.ps1`) - registers WolfPack in Default Apps

### Build System
- Build script copies containers.json, all scripts, dashboard, userscripts, and version.txt
- Installer uninstall section updated for new files/directories

## v1.3.0 (2026-03-15)

### Theme
- Full Catppuccin Mocha theme overriding Edge-Frfox color variables across all browser chrome
- Catppuccin-themed about: pages, new tab, private browsing, error pages, and preferences
- Accent color: Catppuccin Blue (#89b4fa), close button: Catppuccin Red (#f38ba8)
- Themed scrollbars, tooltips, library window, dialogs, and selection highlight

### UI/UX
- Native vertical tabs enabled (Firefox sidebar tabs)
- Compact density mode enabled by default
- Pre-configured container tabs: Personal, Work, Shopping, Banking
- Curated bookmark toolbar with Privacy Tools, Dev Tools, and Speed Tests folders
- Picture-in-Picture enabled with improved toggle
- Strict site permissions: camera, microphone, location, and notifications blocked by default

### Network
- DNS-over-HTTPS via AdGuard DNS (ad-blocking resolver)
- Startup performance tuning (session restore, no skeleton UI)

### Tools
- Profile backup/restore PowerShell script (`scripts/Backup-Profile.ps1`)
- PortableApps.com integration INI file
- Build script now injects custom chrome CSS and utility scripts

### Policies
- Curated managed bookmarks bar (privacy tools, dev tools, speed tests)
- Site permissions enforced via enterprise policy
- Updated support menu link to WolfPack GitHub

## v1.2.0 (2026-03-15)

### Fixes
- Fixed Google not being set as default search engine (removed deprecated prefs, fixed duplicate policy engine, build now clears stale search cache)

### Branding
- Replaced all remaining LibreWolf icons with WolfPack branding (VisualElements, installer shortcuts, Add/Remove Programs, Start Menu)
- Removed old `librewolf.ico` and `librewolf-logo.png` assets
- Removed stale `launcher/LibreWolf-Dark.exe`
- Updated `branding.nsi` with WolfPack name/URLs for source builds
- Build script now auto-generates VisualElements PNGs from `wolfpack-logo.png`

## v1.1.0 (2026-03-13)

Rebranded from "LibreWolf Portable" to **WolfPack**.

### Changes
- New WolfPack icon and branding across all files
- Renamed launcher, installer, shortcuts, and registry entries
- Updated CI/CD workflow artifact names
- Backward-compatible uninstaller cleans up old naming

## v1.0.0 (2026-03-13)

Based on LibreWolf 146.0.1-1 (Firefox 146.0.1)

### Features

- Custom portable build system (`build-portable.ps1`) that downloads, patches, and packages LibreWolf
- NSIS installer with Start Menu, Desktop shortcuts, and Add/Remove Programs integration
- Lightweight C# launcher (`WolfPack.exe`, ~5KB) with embedded icon
- GitHub Actions CI/CD workflow for automated builds on release
- Enterprise `policies.json` for extension auto-install and search engine configuration

### Pre-Installed Extensions

- uBlockVanced (custom uBlock Origin fork)
- DarkReaderLocal (custom Dark Reader fork)
- ScriptVault (custom userscript manager)
- StyleKit (custom userstyle manager)
- SponsorBlock
- Reddit Enhancement Suite
- Adaptive Tab Bar Colour

### Changes from Stock LibreWolf

- Set Google as default search engine (both normal and private browsing)
- Enabled DRM / Encrypted Media Extensions (Netflix, Disney+, Spotify)
- Enabled disk cache for better performance
- Enabled search suggestions in URL bar
- Enabled DNS prefetching and speculative connections
- Enabled password manager and form autofill
- Disabled sanitize-on-shutdown (cookies and logins persist across restarts)
- Disabled Resist Fingerprinting (RFP) to prevent site breakage
- Disabled Global Privacy Control (GPC)
- Changed downloads to use default directory instead of always prompting
- Set extension scopes to 15 (profile + app + system + user) for policy-based installs
- Enabled weather widget on new tab page
- Patched `librewolf.cfg` during build to apply fixes at the autoconfig level

### Performance Optimizations

- Force-enabled GPU acceleration and WebRender
- Hardware video decoding enabled
- Increased network buffer and connection limits
- Physics-based smooth scrolling
- ClearType font rendering tuned for Windows

### Debloat (inherited from LibreWolf)

- All telemetry, crash reporting, and data collection disabled
- Mozilla promotions, Pocket, Firefox Sync disabled
- Safe browsing disabled (relying on uBlock)
- AI/ML features locked off
- Normandy studies and experiments disabled

## Roadmap archive — 2026-08-10 — ROADMAP.md

<details>
<summary>Original roadmap snapshot</summary>

```markdown
# WolfPack Roadmap

Forward-looking scope for the WolfPack LibreWolf distribution. Priority: keep upstream privacy posture while ironing out site-breakage and adding deployment ergonomics.

## Planned Features

### Build Pipeline
- Signed installers + extension bundle (Authenticode on the NSIS output + launcher exe).

### Policy & Profile
- `policies.json` audit tool: diff the shipped policies against upstream LibreWolf defaults so drift is visible in every PR.
- Profile reset wizard: one-click "reset to WolfPack defaults" inside the browser via a custom about: page shim.
- Per-user overrides: ship a `user-overrides.js` that is preserved across WolfPack updates (matches Arkenfox pattern).
- Region-aware defaults: auto-select search engine based on locale instead of hard-coding Google globally.

### Extension Management
- Manifest-V3 readiness pass: confirm every bundled extension survives MV3; ship MV2 fork URL fallbacks where upstream stalls.
- Extension firewall opt-in UI (expose LibreWolf's built-in allow/deny per extension).
- Auto-pin bundled extensions to the toolbar on first run.
- Signed EXT bundle: ship a single `.xpi` manifest that auto-installs the whole pack on first launch if the per-extension fetch fails.

### Deployment
- GPO/ADMX templates wrapping the policies so IT admins can override WolfPack defaults without rebuilding.
- Portable launcher flag: `--profile-override <path>` so WolfPack.exe accepts an external profile path for USB/multi-user scenarios.
- `wolfpack.cfg` documented schema + validation step in the build script.

## Competitive Research
- **Upstream LibreWolf** — the reference; WolfPack's value is "DRM on, Google default, extensions pre-bundled". Don't re-enable telemetry — track upstream every release within 72 hours.
- **Mullvad Browser / Tor Browser** — stronger fingerprinting posture but breaks sites; WolfPack's RFP-disabled stance is a deliberate counter-choice, document loudly in README.
- **Waterfox / Pale Moon** — older-codebase competitors with lax privacy; WolfPack wins on audit surface since it's a thin overlay of upstream LibreWolf.
- **Brave** — chromium-based, different audience; borrow their "update notification banner" UX for out-of-date builds.

## Nice-to-Haves
- Per-container cookie isolation preset that mirrors the Firefox Multi-Account Containers extension.
- Optional built-in DNS-over-HTTPS with Quad9/Mullvad/NextDNS presets in the launcher first-run wizard.
- Telemetry-free crash reporter that writes to `%LOCALAPPDATA%\WolfPack\crash\` only, never phones home.
- A "SafeFallback" build that disables WebGL, WASM, and service workers for high-threat environments.
- Companion CLI `wolfpack-cli` for headless profile bootstrap on sysadmin scripts.
- First-party sync option using a self-hosted Firefox Sync server (Syncstorage-rs) as an alternative to cloud-free profile export.

## Open-Source Research (Round 2)

### Related OSS Projects
- https://github.com/ltguillaume/librewolf-portable — official portable launcher, path rewriter, auto-cleanup
- https://github.com/librewolf/librewolf-winupdater — silent background updater for portable+installed LibreWolf
- https://codeberg.org/librewolf/source — upstream LibreWolf patch set (primary, GitHub mirror only)
- https://github.com/Penny-FOSS/librewolf — community-maintained Firefox privacy fork packaging
- https://github.com/pyllyukko/user.js — gold-standard Firefox hardening user.js reference
- https://github.com/arkenfox/user.js — most-cited hardening baseline
- https://github.com/yokoffing/Betterfox — curated performance/privacy/security prefs set
- https://github.com/intika/Librefox — older Librefox privacy fork, instructive patch history

### Features to Borrow
- Auto-update for portable builds via a bundled updater that diffs releases (librewolf-winupdater)
- Multi-instance portable support — can run alongside installed copy and other portable copies (ltguillaume)
- user.js layering: base (Arkenfox) + WolfPack overrides + user overrides, merged at startup
- Betterfox-style performance prefs set as an optional toggle for lower-end clinic PCs
- "Profile cleaner" on close: wipes lockfiles/telemetry remnants (librewolf-portable behavior)
- Signed manifest of bundled extensions with SHA256 + source URL for auditability
- Winget + Chocolatey + MSI + portable ZIP release matrix (LibreWolf distribution channels)
- Flavored builds: "clinic" (no CWS, no DRM), "home" (CWS enabled, uBO + Dark Reader) differentiated at build-time
- First-run onboarding that shows what's disabled vs. Firefox, linking to the patch that did it
- DoH/ECH defaults configurable by branding.json so enterprises can point to internal resolver

### Patterns & Architectures Worth Studying
- Patch-series layout: upstream Firefox tag + numbered .patch files applied in order, CI validates on each Firefox release (librewolf/source)
- bsys6-style build matrix producing deb/rpm/dmg/zip/msi from one spec (LibreWolf)
- Update channels as branches: `stable`, `beta`, `canary` track FF counterparts, release workflow picks up each
- Portable path virtualization by rewriting `profiles.ini` at launch (librewolf-portable)
- Registry-free portable detection via a marker file next to the exe
```

</details>
