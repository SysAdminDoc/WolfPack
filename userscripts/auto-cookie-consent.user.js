// ==UserScript==
// @name         Auto Cookie Consent
// @namespace    WolfPack
// @version      1.0.0
// @description  Automatically dismisses cookie consent banners by clicking reject/necessary-only buttons
// @author       WolfPack
// @match        *://*/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    // Common selectors for reject/dismiss buttons (prefer rejecting over accepting)
    const REJECT_SELECTORS = [
        // Reject / Decline buttons
        '[id*="reject" i]',
        '[class*="reject" i]',
        'button[data-testid*="reject" i]',
        '[id*="decline" i]',
        '[class*="decline" i]',
        // "Necessary only" / "Essential only"
        '[class*="necessary" i]',
        '[id*="necessary" i]',
        // "Manage" / "Customize" fallback (to get to reject-all)
        // Common cookie frameworks
        '.cmp-button_button--decline',
        '#onetrust-reject-all-handler',
        '.ot-pc-refuse-all-handler',
        'button.fc-cta-do-not-consent',
        '[data-tid="banner-decline"]',
        '.js-decline-cookies',
        '.cookie-banner__reject',
        '#CybotCookiebotDialogBodyLevelButtonLevelOptinDeclineAll',
        '.cc-deny',
        '.cc-dismiss',
        // Dismiss / Close
        '[aria-label="Close cookie banner" i]',
        '[aria-label="Dismiss" i]',
    ];

    function tryDismiss() {
        for (const selector of REJECT_SELECTORS) {
            const btn = document.querySelector(selector);
            if (btn && btn.offsetParent !== null) {
                btn.click();
                return true;
            }
        }
        // Text-based fallback: look for buttons with reject-like text
        const buttons = document.querySelectorAll('button, a[role="button"], [class*="cookie"] button');
        for (const btn of buttons) {
            const text = (btn.textContent || '').trim().toLowerCase();
            if (btn.offsetParent !== null &&
                (text === 'reject all' || text === 'reject' || text === 'decline' ||
                 text === 'decline all' || text === 'deny' || text === 'deny all' ||
                 text === 'refuse' || text === 'refuse all' ||
                 text === 'only necessary' || text === 'necessary only' ||
                 text === 'essential only' || text === 'only essential')) {
                btn.click();
                return true;
            }
        }
        return false;
    }

    // Try immediately and a few times after with delay
    setTimeout(tryDismiss, 500);
    setTimeout(tryDismiss, 1500);
    setTimeout(tryDismiss, 3000);
})();
