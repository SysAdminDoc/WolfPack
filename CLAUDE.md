# WolfPack - Project Notes

## What This Is
Custom LibreWolf distribution for Windows. Downloads stock LibreWolf portable, patches it, injects custom config/theme/extensions, packages as portable zip + NSIS installer.

**Current version**: v1.4.0 | **Base**: LibreWolf 146.0.1-1 (Firefox 146.0.1)

## Tech Stack
- **Build system**: PowerShell (`build-portable.ps1`)
- **Installer**: NSIS (`installer.nsi`)
- **Launcher**: C# compiled via .NET Framework CSC (`launcher/WolfPack.cs`)
- **Browser config**: `policies.json` (enterprise), `user.js` (user prefs), `librewolf.cfg` (autoconfig patching)
- **Theme**: Edge-Frfox CSS theme + Catppuccin Mocha overrides in `chrome-custom/`
- **CI/CD**: GitHub Actions (`.github/workflows/build.yml`)

## Key File Paths
| File | Purpose |
|------|---------|
| `build-portable.ps1` | Main build script - downloads, patches, injects, packages |
| `installer.nsi` | NSIS installer definition |
| `policies.json` | Enterprise policies: extensions, search engines, bookmarks, containers, permissions, 3rdparty extension configs |
| `user.js` | All browser prefs (v0.5.0) - search, privacy, performance, UI, network |
| `containers.json` | Pre-seeded container tab identities (Personal, Work, Shopping, Banking) |
| `chrome-custom/custom.css` | Catppuccin Mocha theme + URL bar cleanup + nav button ordering + tab top margin fix |
| `chrome-custom/catppuccin-content.css` | Catppuccin for about: pages, new tab, error pages, PDF viewer, preferences |
| `dashboard/index.html` | WolfPack dashboard page (browser info, privacy checks, WebRTC leak test) |
| `scripts/Backup-Profile.ps1` | Profile backup/restore with auto-prune |
| `scripts/Update-WolfPack.ps1` | Auto-updater via GitHub releases API |
| `scripts/Switch-NetworkProfile.ps1` | Privacy/Balanced/Speed network profile switcher |
| `scripts/Register-Browser.ps1` | Registers WolfPack in Windows Default Apps (HKCU registry) |
| `userscripts/*.user.js` | 5 bundled userscripts (YouTube Dislike, Old Reddit, Google Direct, Cookie Consent, Wider GitHub) |
| `version.txt` | Current version string for the auto-updater |

## Build Commands
```powershell
.\build-portable.ps1                              # Full build (downloads latest LibreWolf)
.\build-portable.ps1 -SkipDownload -PortableOnly  # Rebuild from existing download, zip only
.\build-portable.ps1 -Version "146.0.1-1"         # Pin specific version
```

Output goes to `output/` (zip + exe). Build working directory is `build/portable-<version>/`.

## Config Hierarchy (important)
1. `librewolf.cfg` - Autoconfig, runs first. Build script patches it to fix stock LibreWolf defaults (DRM, cache, RFP, etc.)
2. `policies.json` - Enterprise policies. Installs extensions, sets default search engine, managed bookmarks, site permissions.
3. `user.js` - User prefs. Overrides everything above. This is where most WolfPack customization lives.
4. `containers.json` - Dropped into profile directory, pre-seeds container tab identities.

## Chrome Theme Architecture
- Edge-Frfox is the base theme, copied from `../LibreWolf_DarkPortable/Profiles/Default/chrome` during build step 6
- `chrome-custom/` in repo root contains WolfPack overrides, overlaid by build step 6b
- `custom.css` is already imported by Edge-Frfox's `userChrome.css` at line 18 - it just needs to exist
- `catppuccin-content.css` is copied to `chrome/content/catppuccin.css` and an `@import` is appended to `userContent.css`
- Color variable system: Edge-Frfox defines vars in `global/colors.css` (~370 lines), `custom.css` overrides them with Catppuccin Mocha values targeting `:root:not([lwtheme])`

## UI Customizations Applied
- Sidebar and vertical tabs: **disabled entirely** (`sidebar.verticalTabs: false`)
- URL bar: all icons hidden except extension icons (lock, star, reader, zoom, page actions, etc. all `display: none`)
- Nav buttons (back/forward/reload) forced to left of URL bar via CSS `order`
- Top tab margin set to 0px (Edge-Frfox default was 8px drag space, caused top-edge clicks to miss tabs)
- Compact density mode enabled

## Gotchas / Traps
- **Chrome files don't exist in repo root** - only in `build/portable-<version>/Profiles/Default/chrome/`. The repo has `chrome-custom/` for overrides only.
- **`librewolf.cfg` uses `pref()` not `defaultPref()` for some settings** - `pref()` overrides `user.js`. The build script patches these to `defaultPref()` so `user.js` wins.
- **Search engine cache** - `search.json.mozlz4` in the profile caches search config. Build step 5 deletes it so policies rebuild it fresh.
- **NSIS path mangling in Git Bash** - Forward slashes get mangled. Use `//D` prefix for defines when calling makensis from bash.
- **Extension UUIDs are random per-install** - Can't pre-seed extension storage by UUID. Use `policies.json` `3rdparty.Extensions` with the extension's static ID instead.
- **`sidebar.visibility: "hide-sidebar"` doesn't reliably hide the new sidebar revamp** - Had to fully disable `sidebar.revamp` and `sidebar.verticalTabs` to remove it.

## Version History
- **v1.0.0** - Initial release. Build system, extensions, optimized defaults.
- **v1.1.0** - Rebrand from "LibreWolf Portable" to WolfPack.
- **v1.2.0** - Fixed Google default search, completed icon branding.
- **v1.3.0** - Catppuccin Mocha theme, vertical tabs, DoH, containers, bookmarks, backup script.
- **v1.4.0** - Search keywords, dashboard, userscripts, extension configs, network profiles, auto-updater, browser registration. Sidebar removed, URL bar cleaned up, tab top margin fixed.
