-- Velora's Hyprland look, hand-written from its design (glass: blur behind
-- the shell's translucent surfaces, see-through windows, soft shadows).
-- Loaded only while Velora is active, by hypr/theme-looks.lua.

local glass_ignore_alpha = 0.2
-- Must sit between the menu scrim alpha (0.25) and card alpha (0.43) in
-- Velora's shell.toml, so the scrim stays unblurred and the card is frosted.
local scrim_card_ignore_alpha = 0.33

local glass_active_opacity = 0.92
local glass_inactive_opacity = 0.88
local terminal_active_opacity = 0.80
local terminal_inactive_opacity = 0.76

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
  },
  group = {
    col = {
      border_active = { colors = { "rgba(ffffff55)", "rgba(ffffff22)" }, angle = 90 },
      border_inactive = "rgba(3a3a3a55)",
      border_locked_active = { colors = { "rgba(ff990088)", "rgba(ff990022)" }, angle = 90 },
      border_locked_inactive = "rgba(3a3a3a77)",
    },
    groupbar = {
      font_size = 10,
      gaps_in = 3,
      gaps_out = 3,
    },
  },
  decoration = {
    rounding = 10,
    rounding_power = 3,
    active_opacity = glass_active_opacity,
    inactive_opacity = glass_inactive_opacity,
    fullscreen_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 25,
      render_power = 3,
      color = "rgba(00000055)",
      color_inactive = "rgba(00000044)",
      offset = { 0, 5 },
      scale = 1.0,
    },
    blur = {
      enabled = true,
      size = 20,
      passes = 3,
      noise = 0.0117,
      contrast = 1.15,
      brightness = 1.0,
      vibrancy = 0.20,
      popups = true,
      popups_ignorealpha = glass_ignore_alpha,
    },
  },
})

-- Omarchy tags windows default-opacity; apps that must stay solid (mpv, OBS,
-- Steam, games, PiP...) drop the tag first, so those opt-outs still hold.
o.window({ tag = "default-opacity" }, { opacity = glass_active_opacity .. " " .. glass_inactive_opacity })
o.window({ tag = "chromium-based-browser" }, { opacity = glass_active_opacity .. " " .. glass_inactive_opacity })
o.window({ tag = "firefox-based-browser" }, { opacity = glass_active_opacity .. " " .. glass_inactive_opacity })
o.window(
  "(Alacritty|kitty|com\\.mitchellh\\.ghostty|org\\.omarchy\\.about)",
  { opacity = terminal_active_opacity .. " " .. terminal_inactive_opacity }
)

-- Personal tweak (not Velora's design): terminals match the top bar's glass.
-- Fading the whole window also fades the text, which made small terminal
-- text hard to read. Instead the window stays fully opaque here and foot
-- makes only its background translucent (alpha 0.52, the bar's value, set
-- by ~/.config/omarchy/hooks/theme-set.d/velora-glass), with the blur
-- above behind it — so text stays crisp and the background looks like the bar.
-- "override" stops decoration.active/inactive_opacity being multiplied in.
o.window({ tag = "terminal" }, { opacity = "1.0 override 1.0 override" })

-- Blur behind the Omarchy shell's layer surfaces (bar + its popups, menus,
-- notifications, OSD...). The tint for each lives in Velora's shell.toml.
hl.layer_rule({
  name = "velora-glass-bar",
  match = { namespace = "^omarchy-bar$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = glass_ignore_alpha,
})

hl.layer_rule({
  name = "velora-glass-scrim-cards",
  match = { namespace = "^omarchy-(menu|clipboard|emojis|polkit|image-selector)$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = scrim_card_ignore_alpha,
})

hl.layer_rule({
  name = "velora-glass-overlays",
  match = {
    namespace = "^omarchy-(keyboard-panel|notifications|osd|reminders|network-qr|disk-speedtest|network-speedtest)$",
  },
  blur = true,
  blur_popups = true,
  ignore_alpha = glass_ignore_alpha,
})

hl.curve("veloraWater", { type = "bezier", points = { { 0.22, 0.9 }, { 0.36, 1.0 } } })
hl.curve("veloraFlow", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.curve("veloraRipple", { type = "bezier", points = { { 0.33, 0.0 }, { 0.2, 1.0 } } })
hl.curve("veloraStream", { type = "bezier", points = { { 0.4, 0.0 }, { 0.4, 1.0 } } })
hl.curve("veloraCascade", { type = "bezier", points = { { 0.19, 1.0 }, { 0.22, 1.0 } } })
hl.curve("veloraStandard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("veloraAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("veloraOvershot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3.0, bezier = "veloraWater" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.8, bezier = "veloraCascade" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.4, bezier = "veloraStream" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.6, bezier = "veloraFlow" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.4, bezier = "veloraWater" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.0, bezier = "veloraCascade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "veloraRipple" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.0, bezier = "veloraWater" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.4, bezier = "veloraFlow" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.5, bezier = "veloraStandard" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.5, bezier = "veloraOvershot", style = "popin 80%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.3, bezier = "veloraAccel", style = "popin 90%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.8, bezier = "veloraFlow" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "veloraWater" })
hl.animation({ leaf = "border", enabled = true, speed = 2.9, bezier = "veloraWater" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 3.5, bezier = "veloraFlow" })
