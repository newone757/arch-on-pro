// ==UserScript==
// @name         Omarchy Spotify Theme
// @description  Applies your active Omarchy desktop theme to Spotify web
// @match        https://open.spotify.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-start
// ==/UserScript==

// Theme JSON served by omarchy-theme-server (systemd user service on port 7842).
const THEME_FILE = 'http://localhost:7842/';
const STYLE_ID   = 'omarchy-spotify-theme';

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

function buildCSS(colors) {
  // Use * selector so every element in the tree gets the variable,
  // overriding Spotify's scoped per-component token declarations.
  const decls = Object.entries(VARS)
    .map(([cssVar, key]) => `  ${cssVar}: ${colors[key]} !important;`)
    .join('\n');
  return `*, *::before, *::after {\n${decls}\n}`;
}

function inject(colors) {
  let el = document.getElementById(STYLE_ID);
  if (!el) {
    el = document.createElement('style');
    el.id = STYLE_ID;
    (document.head || document.documentElement).appendChild(el);
  }
  el.textContent = buildCSS(colors);
}

function load() {
  GM_xmlhttpRequest({
    method: 'GET',
    url: THEME_FILE,
    onload(res) {
      try {
        const colors = JSON.parse(res.responseText);
        inject(colors);
        setTimeout(() => inject(colors), 800);
        setTimeout(() => inject(colors), 2000);
      } catch (e) {
        console.warn('[omarchy-spotify] failed to parse theme JSON:', e);
      }
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
