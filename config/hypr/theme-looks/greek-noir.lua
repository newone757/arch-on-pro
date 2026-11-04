-- Greek Noir's Hyprland look, hand-written from its design: thick flat
-- bronze border, tight gaps, small rounding, short hard shadow.
-- Loaded only while Greek Noir is active, by hypr/theme-looks.lua.

hl.config({
  general = {
    col = {
      active_border = "rgb(706e5e)",
      inactive_border = "rgb(171717)",
    },
    border_size = 3,
    gaps_in = 5,
    gaps_out = 5,
  },
  group = {
    col = {
      border_active = "rgba(706e5eee)",
      border_inactive = "rgb(171717)",
    },
    groupbar = {
      col = {
        active = "rgba(706e5e99)",
        inactive = "rgba(17171788)",
      },
      text_color = "rgb(f25623)",
      text_color_inactive = "rgba(88a57dee)",
    },
  },
  decoration = {
    rounding = 4,
    rounding_power = 3,
    shadow = {
      enabled = true,
      render_power = 8,
      range = 8,
      color = "rgba(16161680)", -- #161616 at 50%
    },
  },
})
