# Changelog

## v1.0.0 (2026-03-13)

Based on LibreWolf 146.0.1-1 (Firefox 146.0.1)

### Features

- Custom portable build system (`build-portable.ps1`) that downloads, patches, and packages LibreWolf
- NSIS installer with Start Menu, Desktop shortcuts, and Add/Remove Programs integration
- Lightweight C# launcher (`LibreWolf.exe`, ~5KB) with embedded LibreWolf icon
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
