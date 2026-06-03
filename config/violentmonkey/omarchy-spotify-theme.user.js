// ==UserScript==
// @name         Omarchy Spotify Theme
// @description  Applies your active Omarchy desktop theme to Spotify web
// @match        https://open.spotify.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-start
// ==/UserScript==

const CSS_URL  = 'http://localhost:7842/spotify.css';
const STYLE_ID = 'omarchy-spotify-theme';

function inject(css) {
  let el = document.getElementById(STYLE_ID);
  if (!el) {
    el = document.createElement('style');
    el.id = STYLE_ID;
    (document.head || document.documentElement).appendChild(el);
  }
  el.textContent = css;
}

function load() {
  GM_xmlhttpRequest({
    method: 'GET',
    url: CSS_URL,
    onload(res) {
      inject(res.responseText);
      setTimeout(() => inject(res.responseText), 800);
      setTimeout(() => inject(res.responseText), 2500);
    },
    onerror() {
      console.warn('[omarchy-spotify] theme server not reachable — is omarchy-theme-server running?');
    }
  });
}

if (document.head || document.body) {
  load();
} else {
  new MutationObserver((_, obs) => {
    if (document.head || document.body) { obs.disconnect(); load(); }
  }).observe(document.documentElement, { childList: true });
}

// Re-apply on SPA navigation
let _lastUrl = location.href;
new MutationObserver(() => {
  if (location.href !== _lastUrl) {
    _lastUrl = location.href;
    setTimeout(load, 300);
  }
}).observe(document.documentElement, { subtree: true, childList: true });
