# arch-on-air

Arch Linux dotfiles for MacBook Air M1, running [armarchy](https://github.com/jondkinney/armarchy) (Hyprland + Wayland).

Starting from scratch? See [docs/armarchy-m1-install-guide.md](docs/armarchy-m1-install-guide.md) for getting Arch onto Apple Silicon in the first place.

---

## What's here

```
config/
├── hypr/
│   ├── hyprland.conf       # Source order, env vars, lid switch suspend
│   ├── bindings.conf       # App launchers, window management, custom keybinds
│   ├── input.conf          # Trackpad settings and 3/4-finger gestures
│   ├── looknfeel.conf      # Gaps, borders, animations, scrolling layout config
│   ├── monitors.conf       # Display scale and VRR
│   └── scripts/            # Gesture scripts for scrolling layout navigation
├── omarchy/
│   ├── hooks/theme-set     # Syncs theme files and reloads Hyprland after theme change
│   └── branding/about.txt  # Custom AIR ASCII logo for fastfetch
├── fastfetch/
│   └── config.jsonc        # System info layout with hardware/software/uptime sections
└── waybar/                 # Status bar layout and styles

docs/
└── armarchy-m1-install-guide.md
```

---

## What's changed from armarchy defaults

**Hyprland 0.55.x fixes** — the default `looknfeel.conf` references two options removed in newer Hyprland (`col.border_locked_* = -1` and `dwindle { pseudotile }`). The default is replaced here with a user-owned version that drops both.

**Theme hook** — `config/omarchy/hooks/theme-set` copies `waybar.css` and the theme's Hyprland conf into stable files so switching wallpapers with Aether doesn't clobber your theme colors. It also ensures Hyprland reloads *after* those files are written, fixing a timing bug in the default flow where the reload fires before the hook runs.

**3-finger gestures** — swipe left/right cycles window focus, up/down moves focus vertically. In scrolling layout (`Super+L`), left/right uses `layoutmsg focus` for proper viewport behavior rather than just moving focus. Wrapping at the ends is disabled.

**4-finger gestures** — swipe left/right switches workspaces.

**Super+copy/paste/cut fix** — after a Hyprland update, `sendshortcut` silently does nothing without an explicit `activewindow` target. Super+C/V/X are overridden in `bindings.conf` with the corrected syntax.

---

## Applying these configs

```bash
git clone https://github.com/newone757/arch-on-air.git
cd arch-on-air
```

Symlink or copy what you need into `~/.config/`. The scripts need to be executable:

```bash
chmod +x config/hypr/scripts/*
chmod +x config/omarchy/hooks/theme-set
```

---

## Hinterlands theme

Modified Hinterlands (reworked borders and shadows for clearer window focus) is in a separate repo:

```bash
omarchy-theme-install https://github.com/newone757/armarchy-hinterlands-theme
```
