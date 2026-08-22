-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    gaps_out = 6,

    -- niri-like side-scrolling layout instead of the 4.0 default (dwindle).
    layout = "scrolling",
  },
})

-- Locked group tab borders: match the active/inactive border colors instead
-- of falling back to Hyprland's own default (a legacy -1 sentinel broke on
-- 0.55.x — this pins them explicitly regardless of what the current version
-- does under the hood). Read back after the default + theme have set them.
hl.config({
  group = {
    col = {
      border_locked_active = hl.get_config("general.col.active_border"),
      border_locked_inactive = hl.get_config("general.col.inactive_border"),
    },
  },
})

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({
  scrolling = {
    wrap_focus = false,
    fullscreen_on_one_column = true,
    column_width = 0.5,
    focus_fit_method = 1,
    follow_focus = true,
    follow_min_visible = 0.1,
  },
})

-- Style Gum confirm prompts (used by various omarchy-* scripts) to match
-- the terminal theme.
hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", "6") -- Cyan
hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", "0") -- Black
hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", "2") -- Green
hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", "7") -- White
hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", "8") -- Dark grey

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- 4.0's default disables the workspaces animation entirely (enabled=false),
-- so workspace switches (including the 4-finger gesture in input.lua) fell
-- back to a generic transition instead of a directional slide. Style must
-- match the gesture direction in input.lua — horizontal gesture, horizontal
-- slide ("slide", not "slidevert").
hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "default", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 8, bezier = "default", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 8, bezier = "default", style = "slide" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })
