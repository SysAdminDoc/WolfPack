// ==UserScript==
// @name         Return YouTube Dislike
// @namespace    WolfPack
// @version      1.0.0
// @description  Shows dislike count on YouTube videos using returnyoutubedislike.com API
// @author       WolfPack
// @match        *://www.youtube.com/*
// @grant        GM_xmlhttpRequest
// @connect      returnyoutubedislike.com
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    const API = 'https://returnyoutubedislikeapi.com/votes?videoId=';
    let lastVideoId = '';

    function getVideoId() {
        const params = new URLSearchParams(window.location.search);
        return params.get('v');
    }

    function formatCount(n) {
        if (n >= 1e9) return (n / 1e9).toFixed(1) + 'B';
        if (n >= 1e6) return (n / 1e6).toFixed(1) + 'M';
        if (n >= 1e3) return (n / 1e3).toFixed(1) + 'K';
        return String(n);
    }

    function injectDislikeCount(count) {
        const existing = document.getElementById('wolfpack-dislike-count');
        if (existing) existing.remove();

        const dislikeBtn = document.querySelector('dislike-button-view-model button, #segmented-dislike-button button');
        if (!dislikeBtn) return;

        const span = document.createElement('span');
        span.id = 'wolfpack-dislike-count';
        span.textContent = formatCount(count);
        span.style.cssText = 'margin-left:6px;font-size:12px;';
        dislikeBtn.appendChild(span);
    }

    function fetchDislikes() {
        const videoId = getVideoId();
        if (!videoId || videoId === lastVideoId) return;
        lastVideoId = videoId;

        GM_xmlhttpRequest({
            method: 'GET',
            url: API + videoId,
            onload: function(res) {
                try {
                    const data = JSON.parse(res.responseText);
                    if (data.dislikes !== undefined) {
                        injectDislikeCount(data.dislikes);
                    }
                } catch(e) { /* silent */ }
            }
        });
    }

    // Watch for navigation (YouTube is SPA)
    const observer = new MutationObserver(fetchDislikes);
    observer.observe(document.body, { childList: true, subtree: true });
    fetchDislikes();
})();
