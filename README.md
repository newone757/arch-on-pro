# arch-on-pro

Arch Linux dotfiles for MacBook Pro (Apple Silicon), running [Omarchy](https://omarchy.org/) (Hyprland + Wayland).

Starting from scratch? See [docs/armarchy-m1-install-guide.md](docs/armarchy-m1-install-guide.md) for getting Arch onto Apple Silicon in the first place.

---

## What's here

```
bin/
├── auto-brightness         # ALS auto-brightness daemon (see setup-auto-brightness)
├── setup-auto-brightness   # Installs auto-brightness + systemd service
├── setup-asahi-audio-tune  # Applies custom speaker tuning + pacman hook
├── setup-brave             # Automates fresh Brave install setup
└── omarchy-icons-apply-color  # Recolors OmarchyIcons folder SVGs

usr/share/asahi-audio/j316/
└── graph.json              # Tuned speaker DSP (Bankstown bass amt reduced)

etc/pacman.d/hooks/
└── asahi-audio-tune.hook   # Re-applies tuning after asahi-audio upgrades

config/
├── hypr/
│   ├── hyprland.conf       # Source order, env vars, lid switch suspend
│   ├── bindings.conf       # App launchers, window management, custom keybinds
│   ├── input.conf          # Trackpad settings and 3/4-finger gestures
│   ├── looknfeel.conf      # Gaps, borders, animations, scrolling layout config
│   ├── monitors.conf       # Display scale (2x) and VRR — tuned for 16" retina
│   └── scripts/            # Gesture scripts for scrolling layout navigation
├── systemd/user/
│   └── auto-brightness.service  # Systemd user service for ALS auto-brightness
├── omarchy/
│   ├── hooks/theme-set     # Syncs theme files and reloads Hyprland after theme change
│   └── branding/about.txt  # Custom ASCII logo for fastfetch
├── fastfetch/
│   └── config.jsonc        # System info layout with hardware/software/uptime sections
└── waybar/                 # Status bar layout and styles

docs/
└── armarchy-m1-install-guide.md
```

---

## What's changed from Omarchy defaults

**Display scaling** — `monitors.conf` uses 2x scaling (`monitor=,preferred,auto,2`) with `GDK_SCALE=2` for the 16" retina display. Integer 2x gives sharper rendering than fractional scaling.

**Hyprland 0.55.x fixes** — the default `looknfeel.conf` references two options removed in newer Hyprland (`col.border_locked_* = -1` and `dwindle { pseudotile }`). The default is replaced here with a user-owned version that drops both.

**Theme hook** — `config/omarchy/hooks/theme-set` copies `waybar.css` and the theme's Hyprland conf into stable files so switching wallpapers with Aether doesn't clobber your theme colors. It also ensures Hyprland reloads *after* those files are written, fixing a timing bug in the default flow where the reload fires before the hook runs.

**3-finger gestures** — swipe left/right cycles window focus, up/down moves focus vertically. In scrolling layout (`Super+L`), left/right uses `layoutmsg focus` for proper viewport behavior rather than just moving focus. Wrapping at the ends is disabled.

**4-finger gestures** — swipe left/right switches workspaces.

**Super+copy/paste/cut fix** — after a Hyprland update, `sendshortcut` silently does nothing without an explicit `activewindow` target. Super+C/V/X are overridden in `bindings.conf` with the corrected syntax.

**Function row fix** — by default on this hardware the function row acts as F1-F12, requiring `fn` for media/brightness/volume keys. `etc/modprobe.d/hid_apple.conf` sets `fnmode=1` to flip this. Copy it to `/etc/modprobe.d/` and apply live with `echo 1 | sudo tee /sys/module/hid_apple/parameters/fnmode`.

**Notch support** — enables the full panel height including the notch area. Add `appledrm.show_notch=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, then run `sudo grub-mkconfig -o /boot/grub/grub.cfg` and reboot. The waybar height is set to 33px to align with the notch on the 16" display at 2x scaling.

**Hide macOS partitions from Nautilus** — `etc/udev/rules.d/99-hide-macos-partitions.rules` hides the APFS partitions (macOS system, data, recovery, and update volumes) from the Nautilus sidebar. Copy it to `/etc/udev/rules.d/` and apply with `sudo udevadm control --reload-rules && sudo udevadm trigger`. To unhide them, delete the file and reload: `sudo rm /etc/udev/rules.d/99-hide-macos-partitions.rules && sudo udevadm control --reload-rules && sudo udevadm trigger`.

**Super+Shift+S screenshot** — adds a Windows 11-style screenshot shortcut. Smart mode: click a window to capture it, or drag to select a region. Opens in Satty for annotation and copies to clipboard.

**Waybar pill margins** — side margins reduced from 14px to 6px (matching the 4px top gap) so the pills sit closer to the display's curved corners. Window `gaps_out` set to 6px to align window edges with the pill edges.

**Battery tooltip** — hovering the battery icon shows estimated time remaining (or time to full when charging), draw in watts, and capacity percentage.

**Speaker tuning** — `asahi-audio` is installed and provides the j316 DSP pipeline, but the default Bankstown bass enhancement (`amt: 1.8`) is too aggressive on this hardware. `usr/share/asahi-audio/j316/graph.json` reduces it to `1.0` for tighter, less muddy low end. A pacman hook keeps the tuning in place after `asahi-audio` upgrades.

**Fastfetch branding** — `branding/about.txt` uses the built-in Arch Linux ASCII logo (two-tone red/blue) with block-style "ARM" text beneath it, replacing the default Omarchy logo.

---

## Applying these configs

```bash
git clone https://github.com/newone757/arch-on-pro.git
cd arch-on-pro
```

Symlink or copy what you need into `~/.config/`. The scripts need to be executable:

```bash
chmod +x config/hypr/scripts/*
chmod +x config/omarchy/hooks/theme-set
```

**Speaker tuning** (reduced bass enhancement for less muddy sound):

```bash
./bin/setup-asahi-audio-tune
```

Copies the tuned DSP config to `/etc/asahi-audio/j316/` and `/usr/share/asahi-audio/j316/`, installs a pacman hook to re-apply after `asahi-audio` upgrades, and restarts WirePlumber.

**Auto-brightness** (ambient light sensor → display brightness):

```bash
./bin/setup-auto-brightness
```

Installs `iio-sensor-proxy`, drops the script into `~/.local/bin/`, and enables the systemd user service. Requires the `aop_als` kernel module (included in Asahi 6.19+).

---

## Custom themes

```bash
omarchy-theme-install https://github.com/newone757/armarchy-hinterlands-theme
omarchy-theme-install https://github.com/newone757/dew-point-theme
omarchy-theme-install https://github.com/newone757/toxic-city-theme
omarchy-theme-install https://github.com/newone757/break-through-theme
omarchy-theme-install https://github.com/newone757/dead-eye-theme
omarchy-theme-install https://github.com/newone757/sullen-fog-theme
omarchy-theme-install https://github.com/newone757/frozen-bliss-theme
```
