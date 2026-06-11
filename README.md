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
├── setup-easyeffects       # Installs EasyEffects + plugins and deploys preset
├── setup-titdb             # Installs TITDB palm/edge rejection daemon
└── omarchy-icons-apply-color  # Recolors OmarchyIcons folder SVGs

usr/share/asahi-audio/j316/
└── graph.json              # Tuned speaker DSP (Bankstown bass amt reduced)

etc/
├── modprobe.d/
│   └── hid_apple.conf               # fnmode=1: media keys default, fn for F-keys
├── modules-load.d/
│   └── uinput.conf                  # Load uinput module at boot (required by titdb)
├── pacman.d/hooks/
│   └── asahi-audio-tune.hook        # Re-applies tuning after asahi-audio upgrades
├── systemd/system/titdb.service.d/
│   └── override.conf                # Pins device path + flex mode for titdb
└── udev/rules.d/
    ├── 99-hide-macos-partitions.rules
    └── 99-uinput.rules              # Grants uinput group access to /dev/uinput

config/
├── hypr/
│   ├── hyprland.conf       # Source order, env vars, lid switch suspend
│   ├── bindings.conf       # App launchers, window management, custom keybinds
│   ├── input.conf          # Trackpad settings and 3/4-finger gestures
│   ├── looknfeel.conf      # Gaps, borders, animations, scrolling layout config
│   ├── monitors.conf       # Display scale (2x) and VRR — tuned for 16" retina
│   └── scripts/            # Gesture scripts for scrolling layout navigation
├── systemd/user/
│   ├── auto-brightness.service          # Systemd user service for ALS auto-brightness
│   └── super-scroll-dispatch.service    # Systemd user service for the gesture daemon
├── omarchy/
│   ├── hooks/theme-set     # Syncs theme files and reloads Hyprland after theme change
│   └── branding/about.txt  # Custom ASCII logo for fastfetch
├── fastfetch/
│   └── config.jsonc        # System info layout with hardware/software/uptime sections
├── waypaper/
│   └── config.ini          # Wallpaper picker config (backend: swaybg, folder: ~/Wallpapers)
└── waybar/                 # Status bar layout and styles

local/share/easyeffects/output/
├── MBP 16 M1.json          # Custom preset for MacBook Pro 16" M1 (default)
├── Perfect EQ.json         # Community Perfect EQ preset
└── Laptop.json             # Community Laptop preset

local/share/applications/
├── Lightroom CC.desktop    # Webapp shortcut (shows in Walker launcher)
└── icons/
    └── Lightroom CC.png    # 128x128 icon for the above

docs/
└── armarchy-m1-install-guide.md
```

---

## What's changed from Omarchy defaults

**Display scaling** — `monitors.conf` uses 2x scaling (`monitor=,preferred,auto,2`) with `GDK_SCALE=2` for the 16" retina display. Integer 2x gives sharper rendering than fractional scaling.

**Hyprland 0.55.x fixes** — the default `looknfeel.conf` references two options removed in newer Hyprland (`col.border_locked_* = -1` and `dwindle { pseudotile }`). The default is replaced here with a user-owned version that drops both.

**Theme hook** — `config/omarchy/hooks/theme-set` copies `waybar.css` and the theme's Hyprland conf into stable files so switching wallpapers with Aether doesn't clobber your theme colors. It also ensures Hyprland reloads *after* those files are written, fixing a timing bug in the default flow where the reload fires before the hook runs.

**Trackpad palm/edge rejection (titdb)** — the MacBook trackpad is large enough that thumbs and palm edges routinely fire accidental taps and cursor jumps. [TITDB](https://github.com/tascvh/trackpad-is-too-damn-big) runs as a system daemon, grabs the hardware device, and re-emits a virtual device with the edges dead-zoned. Flex mode is used so you can still slide into the edge from the active area and multitouch gestures work across the full pad. Runs as a systemd service at boot. See `setup-titdb` for install instructions.

**disable_while_typing** — `input.conf` enables Hyprland's built-in trackpad suppression while keys are held. Pairs with titdb for belt-and-suspenders coverage.

**Gesture daemon (super-scroll-dispatch)** — a Python evdev daemon that reads raw multitouch events and dispatches Hyprland actions for gestures Hyprland can't handle natively. Runs as a systemd user service (`systemctl --user enable --now super-scroll-dispatch`). The trackpad device is hardcoded to `/dev/input/event4` in the script — if gestures stop working after a reboot, check `libinput list-devices` and update `TRACKPAD_DEV` if the path changed.

Gestures handled by the daemon:
- **2-finger horizontal (Nautilus)** → back/forward (`Alt+Left/Right`)
- **2-finger pinch (Nautilus)** → zoom (`Ctrl+=/−`)
- **3-finger vertical (right half of pad)** → resize current column (`colresize ±0.05`); up = wider, down = narrower
- **3-finger horizontal (anywhere)** → browser tab next/prev (`Ctrl+Tab` / `Ctrl+Shift+Tab`)
- **3-finger vertical (left half of pad)** → browser tab close/new (`Ctrl+W` / `Ctrl+T`)
- **4-finger horizontal** → navigate columns in scrolling layout (or `cyclenext` otherwise)

4-finger vertical workspace switching is handled natively by Hyprland via `gesture = 4, vertical, workspace` in `input.conf`.

**Workspace animations** — `looknfeel.conf` replaces the disabled workspace animation with `slidevert` (vertical slide, speed 8) so workspace switching has visible direction. Matches the 4-finger up/down gesture.

**Keybinding changes** — `Super+W` unbound from Typora and rebound to `omarchy-toggle-waybar` (hide/show the status bar). Theme menu moved from `Super+Shift+Ctrl+Space` to `Super+Shift+Space`. `Super+Shift+W` retains Typora.

**Super+copy/paste/cut fix** — after a Hyprland update, `sendshortcut` silently does nothing without an explicit `activewindow` target. Super+C/V/X are overridden in `bindings.conf` with the corrected syntax.

**Function row fix** — by default on this hardware the function row acts as F1-F12, requiring `fn` for media/brightness/volume keys. `etc/modprobe.d/hid_apple.conf` sets `fnmode=1` to flip this. Copy it to `/etc/modprobe.d/` and apply live with `echo 1 | sudo tee /sys/module/hid_apple/parameters/fnmode`.

**Notch support** — enables the full panel height including the notch area. Add `appledrm.show_notch=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, then run `sudo grub-mkconfig -o /boot/grub/grub.cfg` and reboot. The waybar height is set to 33px to align with the notch on the 16" display at 2x scaling.

**Hide macOS partitions from Nautilus** — `etc/udev/rules.d/99-hide-macos-partitions.rules` hides the APFS partitions (macOS system, data, recovery, and update volumes) from the Nautilus sidebar. Copy it to `/etc/udev/rules.d/` and apply with `sudo udevadm control --reload-rules && sudo udevadm trigger`. To unhide them, delete the file and reload: `sudo rm /etc/udev/rules.d/99-hide-macos-partitions.rules && sudo udevadm control --reload-rules && sudo udevadm trigger`.

**Super+Shift+S screenshot** — adds a Windows 11-style screenshot shortcut. Smart mode: click a window to capture it, or drag to select a region. Opens in Satty for annotation and copies to clipboard.

**Waybar pill margins** — side margins reduced from 14px to 6px (matching the 4px top gap) so the pills sit closer to the display's curved corners. Window `gaps_out` set to 6px to align window edges with the pill edges.

**Battery tooltip** — hovering the battery icon shows estimated time remaining (or time to full when charging), draw in watts, and capacity percentage.

**Speaker tuning** — `asahi-audio` is installed and provides the j316 DSP pipeline, but the default Bankstown bass enhancement (`amt: 1.8`) is too aggressive on this hardware. `usr/share/asahi-audio/j316/graph.json` reduces it to `1.0` for tighter, less muddy low end. A pacman hook keeps the tuning in place after `asahi-audio` upgrades.

**Fastfetch branding** — `branding/about.txt` uses the built-in Arch Linux ASCII logo (two-tone red/blue) with block-style "ARM" text beneath it, replacing the default Omarchy logo.

**Waypaper** — GUI wallpaper picker (`yay -S waypaper`). Config sets backend to `swaybg` (matching omarchy's default), wallpaper folder to `~/Wallpapers`, and 3-column grid. Scroll speed boosted via `scroll_touchpad 3.0` in `input.conf`.

---

## Applying these configs

```bash
git clone https://github.com/newone757/arch-on-pro.git
cd arch-on-pro
```

Symlink or copy what you need into `~/.config/`. Copy `local/` into `~/.local/`. The scripts need to be executable:

```bash
chmod +x config/hypr/scripts/*
chmod +x config/omarchy/hooks/theme-set
```

**EasyEffects** (PipeWire system-wide EQ and dynamics for MacBook speakers):

```bash
./bin/setup-easyeffects
```

Installs `easyeffects`, `calf` (bass enhancer, exciter), and `mda.lv2` (bass loudness), then deploys the `MBP 16 M1` preset to `~/.local/share/easyeffects/output/`. Open EasyEffects, click the star icon, and load **MBP 16 M1**. The preset runs a 7-stage chain: Gate → Compressor → Multiband Compressor → Bass Loudness → Bass Enhancer → Equalizer (10-band, tuned for the 16" speakers) → Limiter. EasyEffects is set to autostart on login.

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

**Trackpad palm/edge rejection** (suppresses accidental cursor jumps from large trackpad):

```bash
./bin/setup-titdb
```

Installs `titdb-git` from AUR, sets up the `uinput` group and udev rule, loads the `uinput` kernel module at boot, and enables the `titdb` systemd service. Runs in flex mode with left/right edges dead-zoned 10% and bottom 15%. To tune: edit `/etc/systemd/system/titdb.service.d/override.conf` and run `sudo systemctl restart titdb`.

**Windows 11 ARM VM** (dockurr/windows via Docker, connects over RDP):

```bash
omarchy-windows-vm install
```

Installs `freerdp` and `openbsd-netcat`, writes `~/.config/windows/docker-compose.yml`, and starts the unattended Windows 11 ARM install (20–40 min, monitor at `http://127.0.0.1:8006`). Once done, launch via Walker (Super+Space → "Windows"). The launcher uses `omarchy-launch-or-focus` so a second Walker invocation focuses the existing RDP window rather than opening a duplicate.

The compose file in this repo has credentials and timezone redacted — fill in `USERNAME`, `PASSWORD`, and `TZ` before first use, or just run `omarchy-windows-vm install` and let the interactive prompts handle it. Either way, copy the result to `~/.config/windows/docker-compose.yml`.

Two post-install patches applied on top of the Omarchy fork defaults:
- `restart: "no"` — prevents the container from autostarting at boot (Docker daemon is enabled; without this Windows would start on every reboot)
- Ports bound to `127.0.0.1` — the script already does this, noted here for clarity since default Docker behavior would expose them on all interfaces

The Windows icon is copied from the Omarchy fork during `omarchy-windows-vm install` — no need to track it separately here. Storage lives in `~/.windows/` (VM disk) and `~/Windows/` (shared folder with host).

To remove everything:

```bash
omarchy-windows-vm remove
rm -rf ~/.windows ~/Windows
```

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
