// ==UserScript==
// @name         Google Direct Links
// @namespace    WolfPack
// @version      1.0.0
// @description  Removes Google redirect tracking from search result links
// @author       WolfPack
// @match        *://www.google.com/search*
// @match        *://www.google.co.*/*search*
// @match        *://www.google.com.*/search*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

    function cleanLinks() {
        document.querySelectorAll('a[data-ved], a[ping]').forEach(a => {
            // Remove ping tracking attribute
            a.removeAttribute('ping');
            // Remove mousedown/click redirect handlers
            a.removeAttribute('onmousedown');
            // Clean Google redirect URLs
            if (a.href && a.href.includes('/url?')) {
                try {
                    const u = new URL(a.href);
                    const actual = u.searchParams.get('url') || u.searchParams.get('q');
                    if (actual && actual.startsWith('http')) {
                        a.href = actual;
                    }
                } catch(e) { /* not a valid URL */ }
            }
        });
    }

    cleanLinks();
    const observer = new MutationObserver(cleanLinks);
    observer.observe(document.body, { childList: true, subtree: true });
})();
