# Changelog

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
