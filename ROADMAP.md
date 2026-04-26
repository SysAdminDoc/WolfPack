# WolfPack Roadmap

Forward-looking scope for the WolfPack LibreWolf distribution. Priority: keep upstream privacy posture while ironing out site-breakage and adding deployment ergonomics.

## Planned Features

### Build Pipeline
- Dual-channel releases: `stable` (tracks upstream LibreWolf stable) + `beta` (tracks upstream beta), with Actions matrix building both.
- Deterministic/reproducible build: lock LibreWolf hash in `librewolf.lock` and fail CI if `build-portable.ps1` pulls a different archive.
- Delta updates via `mar` (Mozilla ARchive) instead of full-installer downloads.
- MSI/MSIX build alongside NSIS installer for enterprise deployment.
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
