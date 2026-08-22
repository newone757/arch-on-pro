# Omarchy 3.5.1 → 4.0 (Quattro) Migration Checklist

Target path: fresh Asahi install → [`maralcbr/omarchy-mx-mac`](https://github.com/maralcbr/omarchy-mx-mac)
installer (Omarchy `4.0.0-mac.6`). There is **no in-place upgrade** — this is a
wipe-and-reinstall, then reapply everything below.

**The core disruption:** Omarchy 4.0 rewrote the desktop shell in **Quickshell** and
removed **Waybar, Walker, Mako, SwayOSD, hyprlock, hypridle, swaybg, polkit-gnome**.
Palette expanded **8 → 24 colors**. Everything that lived in those tools must be
rebuilt; everything at the Hyprland / PipeWire / kernel / systemd layer survives.

Legend: ✅ survives (reapply) · 🟡 survives but needs adaptation · 🔴 rebuild from
scratch · ❓ verify on the mac fork before relying on it.

---

## Tier A — Survives as-is (just reapply from repo)

Hardware / kernel / systemd / PipeWire level — untouched by the Quickshell rewrite.

- [ ] ✅ **Auto-brightness ALS daemon** — `bin/auto-brightness`, `setup-auto-brightness`,
      `config/systemd/user/auto-brightness.service`. Needs `iio-sensor-proxy` + `aop_als`
      kernel module (Asahi 6.19+). *Only the waybar readout is lost (see Tier C).*
- [ ] ✅ **Speaker EQ — asahi-audio j316 DSP tune** — `usr/share/asahi-audio/j316/graph.json`
      (Bankstown 1.8→1.0), `setup-asahi-audio-tune`, `etc/pacman.d/hooks/asahi-audio-tune.hook`.
- [ ] ✅ **Speaker EQ — EasyEffects 7-stage chain** — `local/share/easyeffects/output/MBP 16 M1.json`
      (+ Perfect EQ, Laptop), `setup-easyeffects` (calf + mda.lv2). Re-add autostart (Tier B).
- [ ] ✅ **Trackpad palm/edge rejection (titdb)** — `setup-titdb`,
      `etc/systemd/system/titdb.service.d/override.conf`, `etc/modules-load.d/uinput.conf`,
      `etc/udev/rules.d/99-uinput.rules`. System daemon, shell-independent.
- [ ] ✅ **Gesture daemon (super-scroll-dispatch)** — Python evdev daemon +
      `config/systemd/user/super-scroll-dispatch.service` + `config/hypr/scripts/*`
      (scroll-next-col, scroll-prev-col, super-j, browser-tab-*). Dispatches Hyprland
      actions, not shell. ⚠️ Re-check hardcoded `TRACKPAD_DEV=/dev/input/event4` after install.
- [ ] ✅ **fn-key mode** — `etc/modprobe.d/hid_apple.conf` (fnmode=1).
- [ ] ✅ **Hide macOS partitions** — `etc/udev/rules.d/99-hide-macos-partitions.rules`.
- [ ] ✅ **Notch kernel flag** — `appledrm.show_notch=1` in GRUB. Applied and confirmed post-reboot. *Panel-alignment part redone in Tier C — see below, done.*
- [ ] ✅ **fastfetch branding** — `config/fastfetch/config.jsonc`, `config/omarchy/branding/about.txt`.
- [ ] ✅ **Brave flags / Widevine ARM** — `config/brave-flags.conf`, `bin/setup-brave`, `bin/setup-zen`.
- [ ] ✅ **App shortcuts** — `local/share/applications/Lightroom CC.desktop` (+icon),
      `windows-vm.desktop`. Standard XDG — shown by whatever launcher 4.0 ships.
- [ ] ✅ **Spotify userscript** — `config/violentmonkey/omarchy-spotify-theme.user.js`.

---

## Tier B — Survives but needs adaptation

Works at its own layer, but touches something that changed (palette, launcher name,
background source, autostart mechanism).

- [ ] 🟡 **Hyprland configs** — `hyprland.conf`, `bindings.conf`, `input.conf`,
      `looknfeel.conf`, `monitors.conf`. Hyprland is still the compositor, BUT:
  - Re-verify the `source =` / include order against 4.0's default hypr layout.
  - `looknfeel.conf` carries Hyprland 0.55.x fixes (dropped `col.border_locked_*`,
    `dwindle{pseudotile}`) — re-check against the Hyprland version 4.0 ships.
  - `monitors.conf` 2x scale + VRR — should port unchanged.
  - Several bindings reference removed tools — see Tier C.
- [ ] 🟡 **input.conf gestures** — 4-finger native workspace, `scroll_touchpad 0.4`,
      `disable_while_typing`. Port; confirm gesture syntax unchanged in new Hyprland.
- [ ] 🟡 **EasyEffects autostart** — was login-autostart; re-add via 4.0's autostart mechanism.
- [ ] 🟡 **Icon theming** — `bin/omarchy-icons-apply-color` + OmarchyIcons fork.
      Depends on the `theme-set` hook still firing (Tier C) and reads the accent from the
      palette — verify against the new 24-color `colors.toml` format.
- [ ] 🟡 **omarchy-theme-server** (Spotify web theming, port 7842) — `bin/omarchy-theme-server`
      + systemd service. Independent HTTP server, but reads the active palette → update
      for 24-color format.
- [ ] 🟡 **Brave theme policy** — `etc/brave/policies/managed/dark-mode.json` + per-theme
      `chromium.theme` accent written by `omarchy-theme-set-browser`. Survives; accent
      source is the expanded palette.
- [ ] 🟡 **Windows 11 ARM VM** — `config/windows/docker-compose.yml`, `windows-vm.desktop`.
      Docker-level so it runs, but the launcher used `omarchy-launch-or-focus` + Walker;
      rewire to the new launcher. Depends on `omarchy-windows-vm` helper existing (❓ Tier D).
- [ ] 🟡 **Waypaper wallpaper picker** — `config/waypaper/config.ini`. Backend is set to
      **`swaybg`, which 4.0 removed** → switch backend (or hand wallpaper to Quickshell).
      `post_command` updates the `current/background` symlink that **hyprlock** read — the
      lock screen is now Quickshell, so re-point this at whatever the new lock screen reads.

---

## Tier C — Must be rebuilt from scratch (the Quickshell shell layer)

This is where most of your *visible* work lived. None of it ports; it's re-implemented
as Quickshell QML / 4.0 config.

- [ ] 🔴 **Waybar, entirely** — `config/waybar/{config.jsonc,style.css,theme-colors.css}`.
      Rebuild in Quickshell: floating-pill look, module layout, clock-far-right,
      **6px side margins**, **33px height notch alignment**, `#custom-omarchy` logo color.
- [ ] 🔴 **Battery tooltip** (time-remaining / watts / capacity) — reimplement as a
      Quickshell widget.
- [ ] 🔴 **waybar-brightness readout** — `bin/waybar-brightness`. The auto-brightness
      *daemon* survives (Tier A); only this bar indicator is gone → Quickshell widget or drop.
- [ ] 🔴 **Toggle-bar binding** — `Super+W → omarchy-toggle-waybar`. No Waybar to toggle;
      rebind to the Quickshell bar toggle (or repurpose the key).
- [x] ✅ **Notch panel alignment** — done 2026-08-22. Redone for Quickshell as two
      separate fixes, both in `config/omarchy/`: (1) `shell.json` moves the 5
      widgets that used to sit in the bar's `center` section (indicators, clock,
      keyboard-layout, weather, system-update) into `right`, since `center` sits
      geometrically behind the physical notch and was hiding the clock + the
      indicators' hover-reveal icons; (2) `shell.toml` (new machine-level style
      override, separate from `shell.json` — see its header comment) sets
      `[bar] size-horizontal = 32` so the bar's height matches the notch cutout
      instead of leaving it poking out below. 32 was tuned by eye against the
      physical notch; the kernel-reported value (74 native / 2x scale = 37) reads
      visibly too tall, so don't "correct" it back to 37 if this ever comes up
      again. (Kernel flag stays — Tier A, already done.)
- [ ] 🔴 **Launcher bindings** — anything bound to Walker (app launch, theme menu at
      `Super+Shift+Space`, Windows VM focus) → point at the Quickshell launcher.
- [ ] 🔴 **Mako/OSD** — no tracked config, but if you tuned notifications/OSD live, they're
      now Quickshell. Nothing to migrate from the repo.

---

## Tier D — Themes + verify-on-fork unknowns

- [ ] 🔴 **Custom themes (×8)** — 7 in-repo (armarchy-hinterlands, break-through, dead-eye,
      dew-point, frozen-bliss, sullen-fog, toxic-city) + sea-side (separate repo). The
      **8→24 color palette** means every theme needs expansion, not a copy. Waybar CSS in
      each is obsolete; add Quickshell theming. Per-theme `chromium.theme` / `icons.color` /
      `icons.theme` survive conceptually.
- [ ] 🔴 **theme-set hook** — `config/omarchy/hooks/theme-set` synced `waybar.css` + hypr
      conf and reloaded Hyprland. Waybar half is obsolete; confirm 4.0 still supports custom
      theme hooks and rebuild around the new theme pipeline.
- [ ] ❓ **omarchy-* helper commands** — does the mac fork ship `omarchy-windows-vm`,
      `omarchy-launch-or-focus`, `omarchy-theme-set-browser`, `omarchy-toggle-*`? Verify;
      4.0 renamed/removed some.
- [ ] ❓ **16" M1 hardware** — mac fork is regression-tested on **14" M1 Pro (`j314s`)**;
      **16" is not on the tested list**. Validate: internal speakers (j316 DSP path),
      external display, notch, suspend, brightness before trusting it as daily driver.
- [ ] ❓ **Asahi audio node name** — this repo uses `j316`; confirm the fork's asahi-audio
      package still exposes the `j316` graph path after the version bump.

---

## Suggested sequence

This is a direct wipe-and-reinstall of the 16" daily driver — there is no comparable
test machine (the M1 Air has no notch and different speakers/sensors, so it validates
none of the hardware-specific work). So the strategy is: do everything that *can* be
prepared on the current 3.5.1 system first, minimize the blind reinstall window, and
validate the two unknowns before committing.

1. **Snapshot is current** — repo pushed, drift committed. ✅
2. **Prototype the Quickshell bar on the current 3.5.1 machine.** Quickshell is just a
   package — install it and build/test the bar QML (Tier C) *alongside* the running
   Waybar (spare workspace/monitor) so the shell rebuild is ready before the wipe, not after.
3. **Rework one theme** end-to-end to the 24-color format as a template for the rest.
4. **De-risk the 16" unknowns before wiping** (can't be tested any other way):
   - Check Asahi's feature-support matrix for the 16" M1 (`j316`) — speakers, notch,
     suspend, external display, brightness.
   - Search the `omarchy-mx-mac` issues/discussions for any 16" reports.
   - Back up everything not in this repo (EasyEffects runtime db, wallpapers, ~/Projects, VM disks).
5. **Fresh-install the 16"** once the reapply kit + bar + one theme are proven and the
   hardware matrix looks acceptable.
6. **Reapply Tier A/B** from the repo, then finish porting remaining themes.
