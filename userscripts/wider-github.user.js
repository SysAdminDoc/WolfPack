// ==UserScript==
// @name         Wider GitHub
// @namespace    WolfPack
// @version      1.0.0
// @description  Makes GitHub code views and READMEs use the full viewport width
// @author       WolfPack
// @match        *://github.com/*
// @grant        GM_addStyle
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';
    const css = `
        .container-xl, .container-lg {
            max-width: 100% !important;
            padding-left: 32px !important;
            padding-right: 32px !important;
        }
        .repository-content .Box-body,
        .markdown-body,
        .blob-wrapper {
            max-width: 100% !important;
        }
        .Layout-main {
            max-width: 100% !important;
        }
    `;
    if (typeof GM_addStyle !== 'undefined') {
        GM_addStyle(css);
    } else {
        const style = document.createElement('style');
        style.textContent = css;
        (document.head || document.documentElement).appendChild(style);
    }
})();
