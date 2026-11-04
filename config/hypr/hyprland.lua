-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Smaller cursor — default 24 renders too large at 2x retina scale.
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

-- Omarchy's own default rule (default/hypr/apps/moonlight.lua) forces every
-- Moonlight window fullscreen:
--   o.window("com.moonlight_stream.Moonlight", { fullscreen = true, idle_inhibit = "fullscreen" })
-- That's why Moonlight's own Display Mode setting appeared to be ignored. User
-- config loads after Omarchy's defaults, so this overrides it. idle_inhibit is
-- re-declared as "focus" because the default only inhibited idle *while
-- fullscreen* -- without that the laptop would sleep mid-stream.
o.window(
  "com.moonlight_stream.Moonlight",
  { fullscreen = false, idle_inhibit = "focus" }
)
