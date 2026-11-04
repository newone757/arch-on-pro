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

-- 4-finger horizontal: switch workspaces (3-finger handled separately by the
-- super-scroll-dispatch daemon — see autostart.lua).
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- 4-finger vertical: scroll_move — drags the scrolling layout's columns with
-- the fingers niri-style, snapping to a column on release. Only does anything
-- on workspaces using the scrolling layout (Super+L). Vertical rather than
-- horizontal so left/right stays workspace switching, matching the bar.
-- scale multiplies how far the columns travel per finger distance (1 = 1:1).
hl.gesture({ fingers = 4, direction = "vertical", action = "scroll_move", scale = 2.5 })

-- 4-finger pinch in/out: summon/hide Mirador (moved off up/down; a 4-finger
-- tap isn't possible — libinput only does 1–3 finger taps).
hl.gesture({
  fingers = 4,
  direction = "pinchin",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("omarchy-shell shell summon mirador '{}'"))
  end,
})

hl.gesture({
  fingers = 4,
  direction = "pinchout",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("omarchy-shell shell hide mirador"))
  end,
})

-- 3-finger browser tab gestures. Previously handled by a raw-evdev daemon
-- (super-scroll-dispatch) reading the trackpad device directly, but
-- Hyprland's own native gesture engine (used above for the 4-finger
-- gestures) appears to hold the trackpad in a way that starves that
-- daemon of multi-touch events entirely — it saw literally nothing, not
-- even with debug logging. Using hl.gesture directly sidesteps that,
-- since it's the same mechanism already proven to receive touch data.
hl.gesture({
  fingers = 3,
  direction = "left",
  action = function()
    hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Tab", window = "activewindow" }))
  end,
})
hl.gesture({
  fingers = 3,
  direction = "right",
  action = function()
    hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL SHIFT", key = "Tab", window = "activewindow" }))
  end,
})
hl.gesture({
  fingers = 3,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "W", window = "activewindow" }))
  end,
})
hl.gesture({
  fingers = 3,
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "T", window = "activewindow" }))
  end,
})
