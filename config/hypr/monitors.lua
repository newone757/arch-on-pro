-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
-- misc.vrr is the master switch (0 off / 1 on / 2 fullscreen-only) — the
-- per-monitor vrr flag alone doesn't enable it on this Hyprland version.
hl.config({ misc = { vrr = 1 } })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale, vrr = 1 })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
