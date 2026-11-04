-- Turbonite's Hyprland look, hand-written from its design: rust/brass
-- gradient border, wide gaps, medium rounding, amber group-tab text.
-- Loaded only while Turbonite is active, by hypr/theme-looks.lua.

local border_gradient = {
  colors = { "rgba(48191bee)", "rgba(847b4eee)", "rgba(31363aee)", "rgba(0b0c0cee)", "rgba(48191bee)" },
  angle = 45,
}

hl.config({
  general = {
    col = {
      active_border = border_gradient,
      inactive_border = "rgb(131415)",
    },
    gaps_in = 7,
    gaps_out = 11,
    border_size = 2,
  },
  group = {
    col = {
      border_active = border_gradient,
      border_inactive = "rgb(131415)",
    },
    groupbar = {
      col = {
        active = "rgba(48191b99)",
        inactive = "rgba(13141588)",
      },
      text_color = "rgb(ed9a1d)",
      text_color_inactive = "rgba(ebd698ee)",
    },
  },
  decoration = {
    rounding = 6,
    rounding_power = 3,
    shadow = {
      enabled = true,
      range = 16,
      color = "rgba(00000088)",
    },
  },
})

-- Keep Discord (Vesktop), VS Code and Chromium-based browsers fully opaque
-- and never dimmed under this theme.
for _, class in ipairs({
  "^(vesktop|Vesktop)$",
  "^(code|VSCode|VSCodium)$",
  "^(chromium|Chromium|google-chrome|Brave|brave-browser)$",
}) do
  hl.window_rule({ opacity = "1.0 override", no_dim = true, match = { class = class } })
end
