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

- [x] ✅ **Hyprland configs** — done 2026-08-22, ported (not copied) into
      `config/hypr/*.lua`, sitting alongside the old `.conf` files kept as reference.
      4.0 rewrote this whole layer: Hyprland 0.56.1 now has **native Lua config**
      (an `hl`/`o` API, `~/.config/hypr/*.lua`), a completely different mechanism
      from the old `source =`-chained `.conf` files. The fork's own
      `/usr/share/omarchy/default/hypr/*.lua` was diffed line-by-line against each
      old `.conf` to find genuine deltas — most of the old files turned out to
      already be covered by current defaults (see per-file notes below) or
      superseded entirely by better native 4.0 mechanisms:
  - `monitors.lua`: ported 2x scale (unchanged) + VRR. VRR needed a global
    `misc.vrr = 1` in addition to the per-monitor flag (the per-monitor flag
    alone did nothing on this Hyprland version) — `hyprctl monitors` still
    reports `vrr: false` though; that's Asahi's `apple-dcp` driver not yet
    exposing real adaptive sync (fixed discrete refresh-rate list, not a
    continuous range), not a config problem.
  - `input.lua`: ported natural_scroll + scroll_factor (0.1, vs 4.0's default
    0.4) and the Nautilus/waypaper/Aether touchpad scroll overrides
    (Alacritty/kitty/ghostty are already 4.0 defaults). kb_options/repeat
    rate/numlock were already matching defaults, no override needed. Ported
    the 4-finger vertical workspace-switch gesture (`hl.gesture`).
  - `looknfeel.lua`: the old file's header said it fully *replaced* the
    default because of a Hyprland 0.55.x bug (`col.border_locked_*` rejecting
    `-1`, `dwindle:pseudotile` removed) — almost everything in it turns out to
    already be 4.0's own default now (bezier curves, dwindle, master, misc,
    cursor, binds all match exactly). The only genuine deltas: `gaps_out = 6`
    (default 10), `layout = "scrolling"` (default `dwindle` — the user
    actually runs the niri-like scrolling layout), the `scrolling{}` block's
    tuning, `group.col.border_locked_*` pinned explicitly via
    `hl.get_config()` reading back the live theme's border color (belt-and-
    suspenders past the original 0.55.x bug), and the `GUM_CONFIRM_*` env vars.
  - `hyprland.lua`: only the `XCURSOR_SIZE`/`HYPRCURSOR_SIZE=20` override
    survives (default is 24) — everything else is now handled by the fork's
    own `require()` chain. The Parallels-clipboard windowrule was dropped
    (Parallels is macOS-only, N/A on this Asahi Linux install). The
    `theme-border.conf` Aether-overwrites-border-color workaround was **not**
    ported — it targeted `~/.config/omarchy/current/theme/hyprland.conf`,
    a path/mechanism 4.0 replaced with `~/.local/state/omarchy/current/theme/
    hyprland.lua` loaded through the fork's own official theme pipeline, not
    something a viewer app should be touching anymore. Revisit only if that
    specific bug resurfaces.
  - `bindings.lua`: most of the old file is superseded by better 4.0 native
    defaults — bar toggle already lives on SUPER+SHIFT+SPACE (no need to
    reclaim SUPER+W from close-window anymore), screenshot is a much richer
    native capture menu (PRINT/capture-menu bindings), the old
    sendshortcut-activewindow bug for universal copy/paste/cut is fixed
    upstream. Genuinely ported: Typora (SHIFT+W, default now points at the
    new Omawrite app), Claude (SHIFT+A, default now points at ChatGPT),
    Reddit + Lightroom CC (SHIFT+R/L, free keys, not in defaults), the
    scroll-to-focus-column mouse binding (default scrolls workspaces instead,
    wrong gesture for the scrolling layout), and the custom `super-j` script
    (default SUPER+J always calls dwindle's `togglesplit`, which is a no-op
    in the scrolling layout — the script picks the right dispatcher per the
    active workspace's actual layout).
  - **Found and fixed a real bug along the way, not just a port**: 4.0's own
    default lid-switch bindings target a device literally named `"Lid
    Switch"`, but `hyprctl devices` shows this machine's actual switch is
    named `"Apple SMC power/lid events"` (exactly what the old 3.5.1 config
    already knew) — the stock 4.0 default silently never fires on this Mac.
    Rebound the correct device name to 4.0's own native handlers
    (`omarchy-system-lid-close` / `omarchy-hyprland-monitor-clamshell`),
    which are smarter than the old config's blunt lock+suspend (they
    correctly skip locking when docked in clamshell mode with an external
    display).
- [x] ✅ **EasyEffects autostart** — done 2026-08-22. `config/hypr/autostart.lua`:
      `o.launch_on_start("easyeffects --service-mode")` (the current flag; the
      old `--gapplication-service` is deprecated). Runs the MBP 16 M1 preset's
      filter chain headless, no window, on Hyprland start.
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
- [x] ✅ **Waypaper wallpaper picker** — done in Phase B, 2026-08-22 (see
      `config/waypaper/config.ini` and commit `8ecd769`). `backend = none`
      (Quickshell paints the background itself, no swaybg/swww/hyprpaper
      needed) and `post_command = omarchy-theme-bg-set "$wallpaper"`, which
      updates `~/.local/state/omarchy/current/background` (moved from
      `~/.config/omarchy/current/background`) and both Quickshell's
      background plugin and its lock screen read the new path.

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

- [x] ✅ **Custom themes (×8)** — done 2026-08-22. Turned out much smaller than
      expected once the actual mechanism was understood: 4.0's theme pipeline is
      template-driven — a theme only needs to supply `colors.toml` (mode, accent,
      selection, muted, 4 background + 4 foreground variants, 2 hyprland border
      gradients, 6 ANSI hues ×2 for regular/bright — confirmed by reading
      `/usr/share/omarchy/default/themed/*.tpl`, 17 templates covering the
      *entire* stack: the whole Quickshell shell UI, alacritty/kitty/ghostty/
      foot, btop, neovim, vscode, helix, chromium, even Hyprland's own border
      colors) — everything else is auto-generated by `omarchy theme set`/
      `refresh`. No hand-written shell.toml or per-app configs needed per theme.
      Old 8-role/16-ANSI `colors.toml` (per theme, under `~/Projects/<name>-theme/`)
      was the source of truth for the actual intended palette; mapped
      mechanically into the new 24-key schema (`red`/`yellow`/`green`/`cyan`/
      `blue`/`magenta` = ANSI color1/3/2/6/4/5, `bright_*` = color9-14,
      `dark_background`/`darker_background`/`lighter_background` scaled from
      `background`, hyprland border gradient = accent → color15). Verified live
      via `omarchy theme set` + screenshots for 2 of the 8 (armarchy-hinterlands'
      grayscale palette and sea-side's teal palette both rendered correctly and
      cohesively); the other 6 applied without error via the same mechanical
      mapping, not independently screenshot-verified. New `colors.toml` lives in
      each theme's existing `config/omarchy/themes/<name>/` overlay dir
      (`sea-side` didn't have one before — created fresh, no icons.color/
      chromium.theme carried forward since it never had them). Old Waybar CSS
      per theme is untouched/left as historical reference, same as
      `config/waybar/` itself.
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
