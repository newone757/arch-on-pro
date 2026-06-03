// ==UserScript==
// @name         Omarchy Spotify Theme
// @description  Applies your active Omarchy desktop theme to Spotify web
// @match        https://open.spotify.com/*
// @grant        GM_xmlhttpRequest
// @run-at       document-start
// ==/UserScript==

const SERVER   = 'http://localhost:7842';
const STYLE_ID = 'omarchy-spotify-theme';

// Tags whose inline background we should never touch
const SKIP_TAGS = new Set(['IMG', 'VIDEO', 'CANVAS', 'SVG', 'INPUT', 'TEXTAREA', 'BUTTON']);

// Selector for slider containers — their children render Spotify's
// native fill/thumb and must not have their inline styles overridden
const SLIDER_SEL = '[data-testid="progress-bar"],[data-testid="volume-bar"]';

// Spotify's native green values (hardcoded in their hover CSS)
const SPOTIFY_GREENS = new Set([
  'rgb(29, 185, 84)',   // #1db954
  'rgb(30, 215, 96)',   // #1ed760
  'rgb(31, 215, 96)',
  'rgb(30, 215, 95)',
]);

let _bgColor  = null; // hex e.g. "#121212"
let _accColor = null; // hex e.g. "#6381bf"

// ── CSS injection ──────────────────────────────────────────────
function injectCSS(css) {
  let el = document.getElementById(STYLE_ID);
  if (!el) {
    el = document.createElement('style');
    el.id = STYLE_ID;
    (document.head || document.documentElement).appendChild(el);
  }
  el.textContent = css;
}

// ── Inline-style background override ──────────────────────────
// Spotify sets album-art-extracted colours as inline background-color/
// background-image on dynamically generated obfuscated div classes.
// CSS can't target these reliably; override them via JS instead.
function fixEl(el) {
  if (!_bgColor || SKIP_TAGS.has(el.tagName)) return;
  if (el.closest(SLIDER_SEL)) return;
  const style = el.getAttribute('style') || '';
  if (/background(-color|-image|:)/i.test(style)) {
    el.style.setProperty('background-color', _bgColor, 'important');
    el.style.setProperty('background-image', 'none', 'important');
  }
}

function fixTree(root) {
  if (!_bgColor || !root) return;
  const els = root.querySelectorAll
    ? [root, ...root.querySelectorAll('div, span')]
    : [root];
  els.forEach(el => {
    if (SKIP_TAGS.has(el.tagName)) return;
    if (el.closest(SLIDER_SEL)) return;
    try {
      const cs = getComputedStyle(el);
      const bgc = cs.backgroundColor;
      const bgi = cs.backgroundImage;
      const hasProblematicBg =
        bgc === 'rgb(0, 0, 0)' ||
        (bgi !== 'none' && bgi.includes('gradient'));
      const hasInlineBg = /background(-color|-image|:)/i.test(el.getAttribute('style') || '');
      if (hasProblematicBg || hasInlineBg) {
        el.style.setProperty('background-color', _bgColor, 'important');
        el.style.setProperty('background-image', 'none', 'important');
      }
    } catch (_) {}
  });
}

// ── Slider hover — replace Spotify's hardcoded green ──────────
// Spotify's hover state uses obfuscated CSS class selectors with
// hardcoded #1db954 — we can't target these in CSS without class
// names. Instead: on mousemove, scan computed styles and replace
// any green with our accent. On mouseleave, clear the overrides
// so the non-hover state (CSS variable driven) takes back over.
function fixSliderHover(slider) {
  if (!_accColor) return;
  slider.querySelectorAll('*').forEach(el => {
    try {
      if (SPOTIFY_GREENS.has(getComputedStyle(el).backgroundColor)) {
        el.style.setProperty('background-color', _accColor, 'important');
      }
    } catch (_) {}
  });
}

function clearSliderHover(slider) {
  slider.querySelectorAll('[style]').forEach(el => {
    el.style.removeProperty('background-color');
  });
}

function bindSliderHovers() {
  document.querySelectorAll(SLIDER_SEL).forEach(slider => {
    if (slider._omHover) return;
    slider._omHover = true;
    let raf;
    slider.addEventListener('mousemove', () => {
      if (raf) return;
      raf = requestAnimationFrame(() => { raf = null; fixSliderHover(slider); });
    }, { passive: true });
    slider.addEventListener('mouseleave', () => clearSliderHover(slider), { passive: true });
  });
}

let _bgObserver = null;
function startObserver() {
  if (_bgObserver) return;
  _bgObserver = new MutationObserver(mutations => {
    for (const m of mutations) {
      if (m.type === 'childList') {
        m.addedNodes.forEach(n => {
          if (n.nodeType !== 1) return;
          fixTree(n);
          bindSliderHovers();
        });
      }
      if (m.type === 'attributes') fixEl(m.target);
    }
  });
  _bgObserver.observe(document.documentElement, {
    childList: true, subtree: true,
    attributes: true, attributeFilter: ['style']
  });
}

// ── Load from server ───────────────────────────────────────────
function load() {
  GM_xmlhttpRequest({
    method: 'GET', url: SERVER + '/spotify.css',
    onload(res) {
      injectCSS(res.responseText);
      setTimeout(() => injectCSS(res.responseText), 800);
    },
    onerror() { console.warn('[omarchy-spotify] CSS: server not reachable'); }
  });

  GM_xmlhttpRequest({
    method: 'GET', url: SERVER + '/',
    onload(res) {
      try {
        const c = JSON.parse(res.responseText);
        _bgColor  = c.color0 || c.background || '#121212';
        _accColor = c.color2  || c.accent     || '#1db954';
        fixTree(document.body);
        startObserver();
        setTimeout(bindSliderHovers, 1000);
      } catch(e) {}
    },
    onerror() { console.warn('[omarchy-spotify] JSON: server not reachable'); }
  });
}

// ── Scroll handler ─────────────────────────────────────────────
let _scrollRaf;
document.addEventListener('scroll', () => {
  if (!_bgColor || _scrollRaf) return;
  _scrollRaf = requestAnimationFrame(() => {
    _scrollRaf = null;
    [
      '[data-testid="global-nav-bar"]',
      '[data-testid="now-playing-bar"]',
    ].forEach(sel => {
      const el = document.querySelector(sel);
      if (el) fixTree(el);
    });
    document.querySelectorAll('[style*="background"]').forEach(fixEl);
  });
}, { passive: true, capture: true });

// ── Boot ───────────────────────────────────────────────────────
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
    setTimeout(() => { load(); setTimeout(bindSliderHovers, 1000); }, 300);
  }
}).observe(document.documentElement, { subtree: true, childList: true });
