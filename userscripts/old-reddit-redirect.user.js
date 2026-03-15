// ==UserScript==
// @name         Old Reddit Redirect
// @namespace    WolfPack
// @version      1.0.0
// @description  Redirects new Reddit (sh.reddit.com, www.reddit.com) to old.reddit.com
// @author       WolfPack
// @match        *://www.reddit.com/*
// @match        *://sh.reddit.com/*
// @match        *://new.reddit.com/*
// @exclude      *://old.reddit.com/*
// @exclude      *://*.reddit.com/media*
// @exclude      *://*.reddit.com/poll/*
// @exclude      *://*.reddit.com/gallery/*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';
    const url = window.location;
    if (url.hostname === 'old.reddit.com') return;
    // Preserve path and query
    window.location.replace('https://old.reddit.com' + url.pathname + url.search + url.hash);
})();
