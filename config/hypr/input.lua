-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Omarchy's default kb_options already includes compose:caps (plus
-- shift:both_capslock_cancel, new in 4.0) — no override needed there.
-- Touchpad: slower scroll + natural (inverse) scrolling, both differ from
-- the 4.0 default (scroll_factor 0.4, natural_scroll false).
hl.config({
  input = {
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.1,
    },
  },
})

-- App-specific touchpad scroll speeds. Alacritty/kitty/foot (1.5) and
-- ghostty (0.2) are already Omarchy defaults — only the extras below.
o.window("org.gnome.Nautilus", { scroll_touchpad = 1.5 })
o.window("waypaper", { scroll_touchpad = 0.4 })
o.window("Aether", { scroll_touchpad = 0.4 })

-- 4-finger vertical: switch workspaces (3-finger handled separately by the
-- super-scroll-dispatch daemon — see autostart.lua).
hl.gesture({ fingers = 4, direction = "vertical", action = "workspace" })
