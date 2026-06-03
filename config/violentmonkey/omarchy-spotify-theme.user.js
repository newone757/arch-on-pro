// ==UserScript==
// @name         Omarchy Spotify Theme
// @description  Applies your active Omarchy desktop theme to Spotify web
// @match        https://open.spotify.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-start
// ==/UserScript==

// Path to the theme JSON written by the Omarchy theme-set hook.
// Update this if your home directory differs.
const THEME_FILE = 'file:///home/lonnie/.config/omarchy/current/spotify-theme.json';

const STYLE_ID = 'omarchy-spotify-theme';

function buildCSS(c) {
  return `
    :root {
      --background-base:               ${c.background_base}              !important;
      --background-highlight:          ${c.background_highlight}         !important;
      --background-press:              ${c.background_press}             !important;
      --background-elevated-base:      ${c.background_elevated_base}     !important;
      --background-elevated-highlight: ${c.background_elevated_highlight}!important;
      --background-tinted-base:        ${c.background_tinted_base}       !important;
      --background-tinted-highlight:   ${c.background_tinted_highlight}  !important;
      --text-base:                     ${c.text_base}                    !important;
      --text-subdued:                  ${c.text_subdued}                 !important;
      --text-bright-accent:            ${c.accent}                       !important;
      --essential-base:                ${c.text_base}                    !important;
      --essential-subdued:             ${c.text_subdued}                 !important;
      --essential-bright-accent:       ${c.accent}                       !important;
      --essential-positive:            ${c.positive}                     !important;
      --essential-negative:            ${c.negative}                     !important;
      --decorative-base:               ${c.decorative_base}              !important;
      --decorative-subdued:            ${c.decorative_subdued}           !important;
    }
  `;
}

function inject(colors) {
  const existing = document.getElementById(STYLE_ID);
  if (existing) existing.remove();
  const style = document.createElement('style');
  style.id = STYLE_ID;
  style.textContent = buildCSS(colors);
  (document.head || document.documentElement).appendChild(style);
}

function load() {
  GM_xmlhttpRequest({
    method: 'GET',
    url: THEME_FILE,
    onload(res) {
      try {
        const colors = JSON.parse(res.responseText);
        inject(colors);
        // Re-inject after Spotify's own styles have loaded
        setTimeout(() => inject(colors), 800);
      } catch (e) {
        console.warn('[omarchy-spotify] failed to parse theme JSON:', e);
      }
    },
    onerror() {
      console.warn('[omarchy-spotify] could not read theme file:', THEME_FILE);
    }
  });
}

load();

// Re-apply on SPA navigation (Spotify changes the URL without a full page reload)
let lastUrl = location.href;
new MutationObserver(() => {
  if (location.href !== lastUrl) {
    lastUrl = location.href;
    setTimeout(load, 300);
  }
}).observe(document.documentElement, { subtree: true, childList: true });
