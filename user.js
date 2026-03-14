// =============================================================================
// WolfPack - user.js v0.3.0
// Custom configuration for WolfPack (LibreWolf-based) distribution
// =============================================================================

// =============================================================================
// ENTERPRISE / CONFIG LOADING
// =============================================================================
user_pref("general.config.filename", "librewolf.cfg");
user_pref("general.config.obscure_value", 0);

// =============================================================================
// SEARCH ENGINE
// =============================================================================
user_pref("browser.search.defaultenginename", "Google");
user_pref("browser.search.order.1", "Google");
user_pref("browser.search.selectedEngine", "Google");
user_pref("browser.search.update", false);
user_pref("browser.urlbar.placeholderName", "Google");
user_pref("browser.urlbar.placeholderName.private", "Google");
// Force re-application of search engine policy on next launch
user_pref("browser.policies.runOncePerModification.setDefaultSearchEngine", "");
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.urlbar.suggest.searches", true);

// =============================================================================
// EXTENSION INSTALLATION
// =============================================================================
user_pref("xpinstall.signatures.required", false);
user_pref("xpinstall.whitelist.required", false);
user_pref("xpinstall.enabled", true);
user_pref("extensions.allowPrivateBrowsingByDefault", true);
user_pref("extensions.autoDisableScopes", 0);
user_pref("extensions.enabledScopes", 15);
user_pref("extensions.update.autoUpdateDefault", true);
user_pref("extensions.update.enabled", true);
user_pref("extensions.webextensions.restrictedDomains", "");
user_pref("extensions.blocklist.enabled", false);
user_pref("extensions.systemAddon.update.enabled", false);
user_pref("extensions.systemAddon.update.url", "");

// =============================================================================
// DEBLOAT - TELEMETRY / DATA COLLECTION / STUDIES
// =============================================================================
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.policy.firstRunURL", "");
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);

// =============================================================================
// DEBLOAT - MOZILLA FEATURES / PROMOTIONS
// =============================================================================
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.contentanalysis.default_result", 0);
user_pref("browser.contentanalysis.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.shopping.experience2023.enabled", false);
user_pref("browser.translations.enable", false);
user_pref("browser.uitour.enabled", false);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("extensions.getAddons.discovery.api_url", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.discover.enabled", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.screenshots.upload-disabled", true);
user_pref("identity.fxaccounts.enabled", false);
user_pref("signon.firefoxRelay.feature", "");

// =============================================================================
// DEBLOAT - SAFE BROWSING (relying on uBlock Origin instead)
// =============================================================================
user_pref("browser.safebrowsing.allowOverride", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.url", "");
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.provider.mozilla.gethashURL", "");
user_pref("browser.safebrowsing.provider.mozilla.updateURL", "");

// =============================================================================
// PRIVACY - TRACKING PROTECTION (disabled, uBlock handles this)
// =============================================================================
user_pref("privacy.trackingprotection.cryptomining.enabled", false);
user_pref("privacy.trackingprotection.enabled", false);
user_pref("privacy.trackingprotection.fingerprinting.enabled", false);
user_pref("privacy.trackingprotection.socialtracking.enabled", false);
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.globalprivacycontrol.enabled", false);
user_pref("privacy.globalprivacycontrol.functionality.enabled", false);

// =============================================================================
// PRIVACY - NETWORK
// Re-enable prefetching/speculative connections for performance
// (librewolf.cfg disables these with pref() which we override here)
// =============================================================================
user_pref("beacon.enabled", false);
user_pref("browser.places.speculativeConnect.enabled", true);
user_pref("browser.send_pings", false);
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);
user_pref("network.connectivity-service.enabled", false);
user_pref("network.dns.disablePrefetch", false);
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.http.speculative-parallel-limit", 6);
user_pref("network.manage-offline-status", false);
user_pref("network.predictor.enabled", true);
user_pref("network.predictor.enable-prefetch", true);
user_pref("network.prefetch-next", true);
user_pref("network.proxy.socks_remote_dns", true);
user_pref("network.trr.mode", 5);

// =============================================================================
// PRIVACY - DOM / API RESTRICTIONS
// =============================================================================
user_pref("dom.battery.enabled", false);
user_pref("dom.disable_window_move_resize", true);
user_pref("dom.event.clipboardevents.enabled", false);
user_pref("dom.gamepad.enabled", false);
user_pref("dom.push.enabled", false);
user_pref("dom.security.https_only_mode", true);
user_pref("dom.webnotifications.enabled", false);
user_pref("dom.webnotifications.serviceworker.enabled", false);
user_pref("geo.enabled", true);
user_pref("geo.provider.ms-windows-location", false);
user_pref("geo.provider.network.url", "");
user_pref("geo.provider.use_corelocation", false);
user_pref("geo.provider.use_geoclue", false);
user_pref("media.navigator.enabled", false);
user_pref("media.webspeech.synth.enabled", false);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.manager.defaultsUrl", "");

// =============================================================================
// PRIVACY - SESSION / CLEANUP
// Keep cookies and sessions on shutdown (common complaint: getting logged out)
// =============================================================================
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false);
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
user_pref("browser.privateWindowSeparation.enabled", false);
user_pref("privacy.userContext.enabled", false);
user_pref("browser.sessionstore.privacy_level", 0);

// =============================================================================
// SECURITY
// =============================================================================
user_pref("security.enterprise_roots.enabled", false);
user_pref("security.fileuri.strict_origin_policy", false);
user_pref("security.insecure_connection_text.enabled", false);

// =============================================================================
// PERFORMANCE - GPU / RENDERING
// =============================================================================
user_pref("gfx.canvas.accelerated", true);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.enabled", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("layers.async-pan-zoom.enabled", true);
user_pref("layers.gpu-process.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("image.mem.decode_bytes_at_a_time", 131072);

// =============================================================================
// PERFORMANCE - NETWORK / CONNECTIONS
// =============================================================================
user_pref("network.buffer.cache.count", 128);
user_pref("network.buffer.cache.size", 262144);
user_pref("network.dnsCacheEntries", 2000);
user_pref("network.dnsCacheExpiration", 7200);
user_pref("network.dnsCacheExpirationGracePeriod", 3600);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.burst", 14);
user_pref("network.http.pacing.requests.min-parallelism", 10);
user_pref("network.ssl_tokens_cache_capacity", 32768);

// =============================================================================
// PERFORMANCE - CONTENT / PAINT
// =============================================================================
user_pref("content.notify.interval", 100000);
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.max_shutdown_io_lag", 16);
user_pref("browser.sessionhistory.max_total_viewers", 4);
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);
user_pref("dom.ipc.processPriorityManager.backgroundUsesEcoQoS", false);

// =============================================================================
// PERFORMANCE - MEDIA CACHE
// =============================================================================
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.mediasource.webm.enabled", true);

// =============================================================================
// FONT RENDERING (ClearType / Windows)
// =============================================================================
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
user_pref("gfx.font_rendering.cleartype_params.force_gdi_classic_for_families", "");
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
user_pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);

// =============================================================================
// SMOOTH SCROLLING (physics-based)
// =============================================================================
user_pref("general.smoothScroll.currentVelocityWeighting", "0.12");
user_pref("general.smoothScroll.durationToIntervalRatio", 1000);
user_pref("general.smoothScroll.lines.durationMaxMS", 100);
user_pref("general.smoothScroll.lines.durationMinMS", 0);
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 100);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 0);
user_pref("general.smoothScroll.mouseWheel.migrationPercent", 100);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 200);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 200);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 10);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "1.20");
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 1000);
user_pref("general.smoothScroll.other.durationMaxMS", 100);
user_pref("general.smoothScroll.other.durationMinMS", 0);
user_pref("general.smoothScroll.pages.durationMaxMS", 100);
user_pref("general.smoothScroll.pages.durationMinMS", 0);
user_pref("general.smoothScroll.pixels.durationMaxMS", 100);
user_pref("general.smoothScroll.pixels.durationMinMS", 0);
user_pref("general.smoothScroll.scrollbars.durationMaxMS", 100);
user_pref("general.smoothScroll.scrollbars.durationMinMS", 0);
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6");

// =============================================================================
// MOUSE WHEEL
// =============================================================================
user_pref("mousewheel.acceleration.factor", 3);
user_pref("mousewheel.acceleration.start", -1);
user_pref("mousewheel.default.delta_multiplier_x", 100);
user_pref("mousewheel.default.delta_multiplier_y", 300);
user_pref("mousewheel.default.delta_multiplier_z", 100);
user_pref("mousewheel.min_line_scroll_amount", 0);
user_pref("mousewheel.system_scroll_override.enabled", true);
user_pref("mousewheel.system_scroll_override_on_root_content.enabled", false);
user_pref("mousewheel.transaction.timeout", 1500);

// =============================================================================
// UI / UX
// =============================================================================

// Dark mode
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("pdfjs.viewerCssTheme", 2);
user_pref("devtools.theme", "dark");

// Scrollbar
user_pref("widget.non-native-theme.scrollbar.style", 3);

// Compact mode
user_pref("browser.compactmode.show", true);

// New tab
user_pref("browser.newtabpage.enabled", true);
user_pref("browser.newtabpage.activity-stream.showWeather", true);
user_pref("browser.newtabpage.activity-stream.weather.display", "detailed");
user_pref("browser.newtabpage.activity-stream.weather.temperatureUnits", "f");

// Downloads - use download dir instead of always prompting
user_pref("browser.download.autohideButton", false);
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.open_pdf_attachments_inline", true);
user_pref("browser.download.start_downloads_in_tmp_dir", false);
user_pref("browser.download.useDownloadDir", true);

// Tabs
user_pref("browser.tabs.loadBookmarksInTabs", true);
user_pref("browser.tabs.warnOnClose", false);

// Navigation
user_pref("browser.backspace_action", 0);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.warnOnQuit", true);
user_pref("browser.zoom.full", true);

// URL bar
user_pref("browser.urlbar.addons.featureGate", false);
user_pref("browser.urlbar.decodeURLsOnCopy", true);
user_pref("browser.urlbar.fakespot.featureGate", false);
user_pref("browser.urlbar.mdn.featureGate", false);
user_pref("browser.urlbar.pocket.featureGate", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.showSearchSuggestionsFirst", false);
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.calculator", true);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.trimHttps", false);
user_pref("browser.urlbar.unitConversion.enabled", true);
user_pref("browser.urlbar.weather.featureGate", false);
user_pref("browser.urlbar.yelp.featureGate", false);

// PDF viewer
user_pref("pdfjs.defaultZoomValue", "125");
user_pref("pdfjs.sidebarViewOnLoad", 2);

// Findbar
user_pref("findbar.highlightAll", true);
user_pref("findbar.modalHighlight", true);

// View source
user_pref("view_source.wrap_long_lines", true);

// Fullscreen
user_pref("full-screen-api.transition.timeout", 0);
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.delay", 50);
user_pref("full-screen-api.warning.timeout", 50);

// Accessibility / keyboard
user_pref("ui.key.menuAccessKey", 0);
user_pref("ui.prefersReducedMotion", 1);

// Spellcheck
user_pref("layout.spellcheckDefault", 2);
user_pref("ui.SpellCheckerUnderlineStyle", 1);

// Word selection
user_pref("layout.word_select.eat_space_to_next_word", false);

// Scroll distance
user_pref("toolkit.scrollbox.horizontalScrollDistance", 4);
user_pref("toolkit.scrollbox.verticalScrollDistance", 3);

// Misc UI
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("browser.pagethumbnails.capturing_disabled", true);
user_pref("reader.parse-on-load.enabled", false);
user_pref("browser.disableResetPrompt", true);

// =============================================================================
// MEDIA AUTOPLAY
// =============================================================================
user_pref("media.autoplay.default", 5);
user_pref("media.block-autoplay-until-in-foreground", false);
user_pref("media.block-play-until-document-interaction", true);
user_pref("media.block-play-until-visible", true);
user_pref("media.hardwaremediakeys.enabled", false);

// =============================================================================
// DRM / STREAMING (Netflix, Disney+, Spotify, etc.)
// LibreWolf disables DRM by default - re-enable it
// =============================================================================
user_pref("media.eme.enabled", true);
user_pref("media.gmp-manager.url", "https://aus5.mozilla.org/update/3/GMP/%VERSION%/%BUILD_ID%/%BUILD_TARGET%/%LOCALE%/%CHANNEL%/%OS_VERSION%/%DISTRIBUTION%/%DISTRIBUTION_VERSION%/update.xml");
user_pref("media.gmp-provider.enabled", true);
user_pref("media.gmp-gmpopenh264.enabled", true);

// =============================================================================
// FORMS / AUTOFILL / PASSWORDS
// LibreWolf disables these by default - re-enable them
// =============================================================================
user_pref("extensions.formautofill.addresses.enabled", true);
user_pref("extensions.formautofill.creditCards.enabled", true);
user_pref("signon.autofillForms", true);
user_pref("signon.formlessCapture.enabled", true);
user_pref("signon.generation.enabled", false);
user_pref("signon.management.page.breach-alerts.enabled", false);
user_pref("signon.rememberSignons", true);
user_pref("browser.formfill.enable", true);

// =============================================================================
// CSS FEATURES
// =============================================================================
user_pref("layout.css.color-mix.enabled", true);
user_pref("layout.css.grid-template-masonry-value.enabled", true);
user_pref("layout.css.has-selector.enabled", true);
user_pref("layout.css.light-dark.enabled", true);
user_pref("layout.css.scroll-behavior.spring-constant", "250.0");
user_pref("layout.css.visited_links_enabled", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// =============================================================================
// COOKIE BANNERS
// =============================================================================
user_pref("cookiebanners.service.mode", 0);
user_pref("cookiebanners.service.mode.privateBrowsing", 0);

// =============================================================================
// DEVTOOLS
// =============================================================================
user_pref("devtools.accessibility.enabled", false);
user_pref("devtools.debugger.ui.editor-wrapping", true);

// =============================================================================
// ZOOMING
// =============================================================================
user_pref("apz.allow_zooming", true);
user_pref("apz.force_disable_desktop_zooming_scrollbars", false);
user_pref("apz.paint_skipping.enabled", true);
user_pref("apz.windows.use_direct_manipulation", true);
user_pref("dom.event.wheel-deltaMode-lines.always-disabled", true);
