-- Per-theme Hyprland looks for themes installed from git repos.
--
-- Omarchy won't load Lua that git-installed themes ship (a repo could slip in
-- code that runs on every Hyprland load), so those themes lose their borders,
-- gaps, blur, shadows and animations. hypr/theme-looks/<theme>.lua holds a
-- hand-written copy of each one's settings; this loads the one matching the
-- active theme, if there is one.
--
-- Required in hyprland.lua right after Omarchy's defaults (where a theme's own
-- hyprland.lua would load), so personal overrides in hypr/*.lua still win.

local f = io.open(os.getenv("HOME") .. "/.local/state/omarchy/current/theme.name", "r")
if not f then
  return
end

local name = f:read("*l")
f:close()

if name and name:match("^[%w_-]+$") then
  local look = os.getenv("HOME") .. "/.config/hypr/theme-looks/" .. name .. ".lua"
  local exists = io.open(look, "r")
  if exists then
    exists:close()
    require("hypr.theme-looks." .. name)
  end
end
