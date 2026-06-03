// ==UserScript==
// @name         Omarchy Spotify Theme
// @description  Applies your active Omarchy desktop theme to Spotify web
// @match        https://open.spotify.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-start
// ==/UserScript==

// Theme JSON served by omarchy-theme-server (systemd user service on port 7842).
const THEME_FILE = 'http://localhost:7842/';

const VARS = {
  '--background-base':               'background_base',
  '--background-highlight':          'background_highlight',
  '--background-press':              'background_press',
  '--background-elevated-base':      'background_elevated_base',
  '--background-elevated-highlight': 'background_elevated_highlight',
  '--background-tinted-base':        'background_tinted_base',
  '--background-tinted-highlight':   'background_tinted_highlight',
  '--text-base':                     'text_base',
  '--text-subdued':                  'text_subdued',
  '--text-bright-accent':            'accent',
  '--essential-base':                'text_base',
  '--essential-subdued':             'text_subdued',
  '--essential-bright-accent':       'accent',
  '--essential-positive':            'positive',
  '--essential-negative':            'negative',
  '--decorative-base':               'decorative_base',
  '--decorative-subdued':            'decorative_subdued',
};

let _colors = null;
let _observer = null;

function apply(colors) {
  // Set inline styles with !important on html and body —
  // this beats Spotify's own JS-injected inline style tokens.
  for (const el of [document.documentElement, document.body]) {
    if (!el) continue;
    for (const [cssVar, key] of Object.entries(VARS)) {
      el.style.setProperty(cssVar, colors[key], 'important');
    }
  }
}

function watch(colors) {
  if (_observer) _observer.disconnect();
  _observer = new MutationObserver(() => {
    // Reapply if Spotify resets our inline styles
    _observer.disconnect();
    apply(colors);
    _observer.observe(document.documentElement, { attributes: true, attributeFilter: ['style'] });
    if (document.body) {
      _observer.observe(document.body, { attributes: true, attributeFilter: ['style'] });
    }
  });
  _observer.observe(document.documentElement, { attributes: true, attributeFilter: ['style'] });
  if (document.body) {
    _observer.observe(document.body, { attributes: true, attributeFilter: ['style'] });
  }
}

function load() {
  GM_xmlhttpRequest({
    method: 'GET',
    url: THEME_FILE,
    onload(res) {
      try {
        _colors = JSON.parse(res.responseText);
        apply(_colors);
        watch(_colors);
        // Re-apply after Spotify's own init runs
        setTimeout(() => apply(_colors), 500);
        setTimeout(() => apply(_colors), 1500);
      } catch (e) {
        console.warn('[omarchy-spotify] failed to parse theme JSON:', e);
      }
    },
    onerror() {
      console.warn('[omarchy-spotify] theme server not reachable — is omarchy-theme-server running?');
    }
  });
}

// Wait for body to exist before first apply
if (document.body) {
  load();
} else {
  new MutationObserver((_, obs) => {
    if (document.body) { obs.disconnect(); load(); }
  }).observe(document.documentElement, { childList: true });
}

// Re-apply on SPA navigation
let _lastUrl = location.href;
new MutationObserver(() => {
  if (location.href !== _lastUrl) {
    _lastUrl = location.href;
    setTimeout(() => { if (_colors) apply(_colors); }, 400);
  }
}).observe(document.documentElement, { subtree: true, childList: true });
