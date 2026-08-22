-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- This keyboard (16" M1, j316) has no dedicated backlight key on its F-row,
-- so reuse the screen-brightness keys (F1/F2) with SUPER for the keyboard
-- backlight until the ALS auto-brightness daemon from arch-on-pro is set up.
o.bind("SUPER + XF86MonBrightnessUp", "Keyboard brightness up", "omarchy-brightness-keyboard up", { locked = true, repeating = true })
o.bind("SUPER + XF86MonBrightnessDown", "Keyboard brightness down", "omarchy-brightness-keyboard down", { locked = true, repeating = true })
o.bind("SUPER + SHIFT + XF86MonBrightnessUp", "Keyboard backlight cycle", "omarchy-brightness-keyboard cycle", { locked = true })

-- Ported from the 3.5.1 config (see arch-on-pro/config/hypr/bindings.conf).
-- Most of the old file is superseded by 4.0's own default bindings (bar
-- toggle already lives on SUPER+SHIFT+SPACE, screenshot/capture is a much
-- richer native menu now, the sendshortcut activewindow bug is fixed
-- upstream) — only what's genuinely still needed is kept below.

-- SUPER+Q closes the active window instead of the default SUPER+W (muscle
-- memory from 3.5.1). SUPER+W is left unbound/free rather than reassigned.
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Lid switch: THIS HARDWARE'S switch device is named "Apple SMC power/lid
-- events", not the generic "Lid Switch" 4.0's own default bindings assume
-- (confirmed via `hyprctl devices` — no "Lid Switch" device exists here at
-- all, so those default binds silently never fire on this Mac). Rebind to
-- the correct device name, but keep pointing at 4.0's own native handlers
-- (omarchy-system-lid-close correctly skips locking when docked/clamshell
-- with an external display, unlike the old config's blunt lock+suspend).
o.bind("switch:on:Apple SMC power/lid events", nil, "omarchy-system-lid-close", { locked = true })
o.bind("switch:off:Apple SMC power/lid events", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })

-- Webapp/app launches that conflict with or are missing from 4.0's defaults.
hl.unbind("SUPER + SHIFT + W") -- default: Omawrite
o.bind("SUPER + SHIFT + W", "Typora", "uwsm-app -- typora --enable-wayland-ime")
hl.unbind("SUPER + SHIFT + A") -- default: ChatGPT
o.bind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai" })
o.bind("SUPER + SHIFT + R", "Reddit", { webapp = "https://reddit.com" })
o.bind("SUPER + SHIFT + L", "Lightroom CC", { webapp = "https://lightroom.adobe.com/home", focus = true })

-- Super + two-finger scroll moves focus between columns instead of the
-- default's switch-workspace — the natural gesture for the niri-like
-- scrolling layout set in looknfeel.lua.
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.bind("SUPER + mouse_down", "Focus next column", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + mouse_up", "Focus previous column", hl.dsp.focus({ direction = "l" }))

-- Layout-aware split/consume: default SUPER+J always calls togglesplit,
-- which is a dwindle-only concept and does nothing useful in the scrolling
-- layout this config uses. The script picks the right dispatcher for
-- whichever layout the active workspace is actually in.
hl.unbind("SUPER + J")
o.bind("SUPER + J", "Split or consume window", "~/.config/hypr/scripts/super-j")

-- Restore 3.5.1 muscle memory for these two — both collide with newer 4.0
-- defaults that happen to land on the same keys (Toggle top bar, Google
-- Maps). The underlying actions still exist elsewhere (SUPER+SHIFT+CTRL+
-- SPACE for theme menu, PRINT for screenshot); this just puts them back on
-- the keys already in muscle memory.
hl.unbind("SUPER + SHIFT + SPACE") -- default: Toggle top bar
o.bind("SUPER + SHIFT + SPACE", "Theme menu", "omarchy-menu toggle theme")
hl.unbind("SUPER + SHIFT + S") -- default: Google Maps
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

-- Default Music binding (omarchy-launch-spotify) checks for a native
-- /usr/bin/spotify binary first and falls back to launching an installer
-- when it's missing — there's no ARM64 build, so on this machine it opens
-- an installer prompt instead of music. Bind straight to the webapp, same
-- as the 3.5.1 config did for the same reason.
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "Music", { webapp = "https://open.spotify.com" })
